*----------------------------------------------------------------------*
***INCLUDE /ADESSO/WO_MONITOR_U01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UC_VIEW_VKONT
*&---------------------------------------------------------------------*
FORM uc_view_vkont  USING ff_vkont TYPE vkont_kk
                          ff_gpart TYPE gpart_kk.

  CHECK NOT ff_vkont IS INITIAL.

  SET PARAMETER ID 'BPA' FIELD ff_gpart.
  SET PARAMETER ID 'KTO' FIELD ff_vkont.

  CALL FUNCTION 'FKK_ACCOUNT_CHANGE'
    EXPORTING
      i_vkont       = ff_vkont
      i_gpart       = ff_gpart
      i_ch_mode     = '1'
      i_no_other    = 'X'
      i_no_change   = 'X'
    EXCEPTIONS
      error_message = 1.

  IF sy-subrc = 1.
*   raises only in dialog
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UC_DISPLAY_APPROVAL
*&---------------------------------------------------------------------*
FORM uc_display_approval USING ff_vkont TYPE vkont_kk
                               ff_gpart TYPE gpart_kk.

  DATA: ls_wo_cust TYPE /adesso/wo_cust.  "Customizing allgemein
  DATA: lt_thead   TYPE TABLE OF thead,
        ls_thead   TYPE thead,
        lv_pattern TYPE char30,
        lv_select  TYPE char30,
        ls_stxh    TYPE stxh,
        lt_stxh    TYPE STANDARD TABLE OF stxh,
        lt_texte   TYPE text_lh,
        ls_texte   TYPE itclh,
        ls_lines   TYPE tline,
        lt_text    TYPE catsxt_longtext_itab,
        ls_text    TYPE txline,
        ls_line    TYPE tline,
        lv_date    TYPE char10,
        lv_time    TYPE char8,
        lv_object  TYPE /adesso/inkasso_value,
        lv_id      TYPE /adesso/inkasso_value.

  CHECK NOT ff_vkont IS INITIAL.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'OBJECT'
             wo_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option    = 'INTVERM'
             wo_category  = 'APPROVAL'
             wo_field     = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CONCATENATE ff_gpart '_'
              ff_vkont '_'
              INTO lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
    WHERE tdobject = lv_object
      AND tdname LIKE lv_select
      AND tdid     = lv_id
      AND tdspras  = sy-langu.

  LOOP AT lt_stxh INTO ls_stxh.
    MOVE-CORRESPONDING ls_stxh TO ls_thead.
    APPEND ls_thead TO lt_thead.
    CLEAR ls_thead.
  ENDLOOP.

  CALL FUNCTION 'READ_TEXT_TABLE'
    IMPORTING
      text_table              = lt_texte
    TABLES
      text_headers            = lt_thead
    EXCEPTIONS
      wrong_access_to_archive = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SORT lt_texte BY header-tdname DESCENDING.

  LOOP AT lt_texte INTO ls_texte.

*         Datum Formatieren
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_texte-header-tdfdate
      IMPORTING
        date_external            = lv_date
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   Zeit umformatieren
    CONCATENATE ls_texte-header-tdftime(2)
                ':'
                ls_texte-header-tdftime+2(2)
                ':'
                ls_texte-header-tdftime+4(2)
                 INTO lv_time.

    CONCATENATE ls_texte-header-tdfuser
                lv_date
                lv_time
                INTO ls_text
                SEPARATED BY space.

    APPEND ls_text TO lt_text.
    CLEAR ls_text.
*         Texte einlesen
    LOOP AT ls_texte-lines INTO ls_lines.
      MOVE ls_lines-tdline TO ls_text.
      APPEND ls_text TO lt_text.
      CLEAR ls_text.
    ENDLOOP.
    APPEND INITIAL LINE TO lt_text.
  ENDLOOP.

  CALL FUNCTION 'CATSXT_SIMPLE_TEXT_EDITOR'
    EXPORTING
      im_title        = 'MONITOR AUSBUCHUNG'
      im_display_mode = 'X'
*     IM_START_COLUMN = 10
*     IM_START_ROW    = 10
    CHANGING
      ch_text         = lt_text.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_GET_KONTENSTAND
*&---------------------------------------------------------------------*
FORM ucom_get_kontenstand USING fs_header TYPE /adesso/wo_header.

  IF fs_header IS NOT INITIAL.
    SET PARAMETER ID 'BPA' FIELD fs_header-gpart.
    SET PARAMETER ID 'KTO' FIELD fs_header-vkont.
    CALL TRANSACTION 'FPL9' AND SKIP FIRST SCREEN.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_GET_CIC
*&---------------------------------------------------------------------*
FORM ucom_get_cic  USING ff_vkont TYPE vkont_kk.

  DATA: ls_bdc        TYPE bdcdata.
  DATA: lt_bdc        TYPE TABLE OF bdcdata.
  DATA: lt_messtab    TYPE TABLE OF bdcmsgcoll.

  DATA: lv_screen_no TYPE cicfwscreenno.
  DATA: lv_tcode     TYPE sy-tcode.

  PERFORM get_cic_frame_for_user CHANGING lv_screen_no.

  CLEAR lt_bdc.

  ls_bdc-fnam = 'BDC_OKCODE'.
  ls_bdc-fval = '=RFSH'.
  APPEND ls_bdc TO lt_bdc.
  CLEAR ls_bdc.

  ls_bdc-fnam = 'EFINDD_CIC-A_VKONT'.
  ls_bdc-fval = ff_vkont.
  APPEND ls_bdc TO lt_bdc.
  CLEAR ls_bdc.

  IF lv_screen_no IS NOT INITIAL.
    CLEAR ls_bdc.
    ls_bdc-program = 'SAPLCIC0'.
    ls_bdc-dynpro = lv_screen_no.
    ls_bdc-dynbegin = 'X'.
    APPEND ls_bdc TO lt_bdc.
    CLEAR ls_bdc.

    SORT lt_bdc
      BY program DESCENDING
           fnam  ASCENDING.
  ELSE.
    MESSAGE w020.
    CLEAR  lt_bdc.
  ENDIF.

  lv_tcode = 'CIC0'.

  CALL FUNCTION 'CALL_CIC_TRANSACTION'
    EXPORTING
      tcode            = lv_tcode
      skipfirst        = 'X'
    TABLES
      in_bdcdata       = lt_bdc
      out_messtab      = lt_messtab
    EXCEPTIONS
      no_authorization = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CIC_FRAME_FOR_USER
*&---------------------------------------------------------------------*
FORM get_cic_frame_for_user  CHANGING ff_screen_no TYPE cicfwscreenno.

  DATA: lt_cic_prof TYPE TABLE OF cicprofiles.

  CALL FUNCTION 'CIC_GET_ORG_PROFILES'
    EXPORTING
      agent                 = sy-uname
    TABLES
      profile_list          = lt_cic_prof
    EXCEPTIONS
      call_center_not_found = 1
      agent_group_not_found = 2
      profiles_not_found    = 3
      no_hr_record          = 4
      cancel                = 5
      OTHERS                = 6.
  IF sy-subrc <> 0.
    MESSAGE e003.
    EXIT.
  ENDIF.

* existiert mind. 1 Eintrag
  IF lines( lt_cic_prof ) EQ 0.
    MESSAGE e020.
    EXIT.
  ENDIF.

* 1. Datensatz aus Tabelle zuweisen
  FIELD-SYMBOLS: <fs_prof> TYPE cicprofiles.
  READ TABLE lt_cic_prof ASSIGNING <fs_prof> INDEX 1.
* Fehlerprüfung
  IF <fs_prof> IS NOT ASSIGNED.
    MESSAGE e020.
    EXIT.
  ENDIF.

* Passendes CIC-Profil lesen
* Konfiguration auslesen um die DYNPRO-Nr zu gelangen
  SELECT SINGLE frame_screen
    INTO ff_screen_no
    FROM cicprofile
      INNER JOIN cicconf
        ON cicconf~frame_conf = cicprofile~framework_id
    WHERE cicprofile~cicprof = <fs_prof>-cicprof.

  IF ff_screen_no IS INITIAL.
    MESSAGE e020.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_EDIT_DOCU
*&---------------------------------------------------------------------*
FORM ucom_edit_docu USING ff_gpart
                             ff_vkont
                             ff_ic_docu.

  DATA: ls_wo_cust  TYPE /adesso/wo_cust.  "Customizing allgemein
  DATA: lt_text     TYPE catsxt_longtext_itab,
        ls_text     TYPE txline,
        lt_head     TYPE TABLE OF thead,
        ls_head     TYPE thead,
        ls_line     TYPE tline,
        lt_line     TYPE TABLE OF tline,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        lv_pattern  TYPE char30,
        lv_select   TYPE char30,
        lv_object   TYPE /adesso/inkasso_value,
        lv_id       TYPE /adesso/inkasso_value.
  DATA: lv_function(1).

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'OBJECT'
             wo_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'DOCU'
             wo_field    = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CALL FUNCTION 'J_1BNFE_EDITOR_CALL'
    EXPORTING
      iv_titel       = 'AUSBUCHUNGS_MONITOR'
*     IV_MAX_NUMBER_CHARS       =
*     IV_DISPLAY     = ' '
    TABLES
      ct_textlines   = lt_text
    EXCEPTIONS
      user_cancelled = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.


  LOOP AT lt_text INTO ls_text.
    MOVE ls_text TO ls_line-tdline.
    APPEND ls_line TO lt_line.
  ENDLOOP.

  CONCATENATE ff_gpart '_'
              ff_vkont '_'
              INTO  lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND tdname LIKE lv_select
           AND tdid = lv_id
           AND tdspras = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.
  READ TABLE lt_stxh INTO ls_stxh INDEX 1.
  IF sy-subrc = 0.
    lv_lfdnr = ls_stxh-tdname+24(3).
    ADD 1 TO lv_lfdnr.
    CONCATENATE lv_pattern lv_lfdnr INTO ls_head-tdname.
  ELSE.
    CONCATENATE lv_pattern '001' INTO ls_head-tdname.
  ENDIF.

  ls_head-tdobject = lv_object.
  ls_head-tdid   = lv_id.
  ls_head-tdspras = sy-langu.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = ls_head
    IMPORTING
      function = lv_function
    TABLES
      lines    = lt_line
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      OTHERS   = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF lv_function = const_insert.
    PERFORM set_status_icon
            USING 'DOCU'
                  ff_ic_docu.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_ALLOW
*&---------------------------------------------------------------------*
FORM ucom_allow  USING ff_ucomm LIKE sy-ucomm
                       ff_gplocked LIKE gv_gplocked.

  DATA: ls_header     TYPE /adesso/wo_header.
  DATA: ls_items      TYPE /adesso/wo_items.
  DATA: ls_wo_mon     TYPE /adesso/wo_mon.
  DATA: ls_wo_mon_h   TYPE /adesso/wo_mon_h.
  DATA: ls_rc         TYPE syst_subrc.
  DATA: ls_wosta      TYPE /adesso/wo_wosta.
  DATA: ls_womonh_cha LIKE gs_womonh_cha.

  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_poserr   TYPE sy-tabix.
  DATA: lf_iverm  TYPE /adesso/inkasso_text.

  CLEAR ls_womonh_cha.

* pop-up to enter text
  CALL SCREEN 9100
     STARTING AT 21 2.

  IF ok EQ 'CANC'.
    CLEAR ok.
    EXIT.
  ELSE.
    lf_iverm = /adesso/wo_req-freetext.
  ENDIF.
  CLEAR ok.

  LOOP AT gt_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
*    CLEAR gs_stat.
*    READ TABLE gt_stat INTO gs_stat
*         WITH KEY begru = gs_bgus-begru
*                  ucomm = ff_ucomm
*                  agsta = ls_header-agsta.
*
*    IF sy-subrc NE 0.
*      CLEAR gs_stat.
*      ADD 1 TO lf_nochange.
*      CONTINUE.
*    ENDIF.

    CASE ls_header-wosta.
      WHEN '01'.
        ls_wosta = '11'.
      WHEN '02'.
        ls_wosta = '11'.
      WHEN '10'.
        ls_wosta = '11'.
      WHEN '11'.
        ls_wosta = '12'.
      WHEN OTHERS.
        ADD 1 TO lf_nochange.
        CONTINUE.
    ENDCASE.

    CLEAR lf_poserr.

* jetzt alle Posten bearbeiten
    LOOP AT gt_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      SELECT SINGLE * FROM /adesso/wo_mon
             INTO  ls_wo_mon
             WHERE opbel = ls_items-opbel
             AND   opupw = ls_items-opupw
             AND   opupk = ls_items-opupk
             AND   opupz = ls_items-opupz.

      IF sy-subrc = 0.
        ls_wo_mon-wosta = ls_wosta.
        MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.

        CLEAR ls_rc.
        PERFORM update_womon_wohist
                USING ls_wo_mon ls_wo_mon_h ls_rc.

        IF ls_rc = 0.
          ls_items-wosta = ls_wosta.
          PERFORM set_status_icon USING ls_items-wosta ls_items-status.
        ELSE.
          PERFORM set_status_icon USING 'ERR' ls_items-status.
          PERFORM set_status_icon USING 'ERR' ls_header-status.
          ADD 1 TO lf_poserr.
        ENDIF.

      ELSE.
        PERFORM set_status_icon USING 'ERR' ls_items-status.
        PERFORM set_status_icon USING 'ERR' ls_header-status.
        ADD 1 TO lf_poserr.
      ENDIF.

      MODIFY gt_items FROM ls_items.

    ENDLOOP.

*   ICON auf Genehmigungsstatus setzen
    IF lf_poserr = 0.
      ls_header-wosta = ls_wosta.
      PERFORM set_status_icon USING ls_header-wosta ls_header-status.
      PERFORM create_approval USING ls_header-gpart
                                    ls_header-vkont
                                    ls_header-wosta
                                    ls_header-intverm
                                    lf_iverm
                                    ls_womonh_cha.
    ENDIF.

    MODIFY gt_header FROM ls_header.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_DECL
*&---------------------------------------------------------------------*
FORM ucom_decl  USING ff_ucomm LIKE sy-ucomm
                      ff_gplocked LIKE gv_gplocked.

  DATA: ls_header   TYPE /adesso/wo_header.
  DATA: ls_items    TYPE /adesso/wo_items.
  DATA: ls_wo_mon   TYPE /adesso/wo_mon.
  DATA: ls_wo_mon_h TYPE /adesso/wo_mon_h.
  DATA: ls_rc       TYPE syst_subrc.
  DATA: ls_wosta    TYPE /adesso/wo_wosta.

  DATA: lf_nochange   TYPE sy-tabix.
  DATA: lf_poserr     TYPE sy-tabix.
  DATA: lf_iverm      TYPE /adesso/inkasso_text.
  DATA: ls_womonh_cha LIKE gs_womonh_cha.

  CLEAR ls_womonh_cha.

* pop-up to enter text
  CALL SCREEN 9100
     STARTING AT 21 2.

  IF ok EQ 'CANC'.
    CLEAR ok.
    EXIT.
  ELSE.
    lf_iverm = /adesso/wo_req-freetext.
  ENDIF.
  CLEAR ok.

  LOOP AT gt_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
*    CLEAR gs_stat.
*    READ TABLE gt_stat INTO gs_stat
*         WITH KEY begru = gs_bgus-begru
*                  ucomm = ff_ucomm
*                  agsta = ls_header-agsta.
*
*    IF sy-subrc NE 0.
*      CLEAR gs_stat.
*      ADD 1 TO lf_nochange.
*      CONTINUE.
*    ENDIF.

    CASE ls_header-wosta.
      WHEN '01'.
        ls_wosta = '13'.
      WHEN '02'.
        ls_wosta = '13'.
      WHEN '10'.
        ls_wosta = '13'.
      WHEN '11'.
        ls_wosta = '13'.
      WHEN OTHERS.
        ADD 1 TO lf_nochange.
        CONTINUE.
    ENDCASE.

    CLEAR lf_poserr.

* jetzt alle Posten bearbeiten
    LOOP AT gt_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      SELECT SINGLE * FROM /adesso/wo_mon
             INTO  ls_wo_mon
             WHERE opbel = ls_items-opbel
             AND   opupw = ls_items-opupw
             AND   opupk = ls_items-opupk
             AND   opupz = ls_items-opupz.

      IF sy-subrc = 0.
        ls_wo_mon-wosta = ls_wosta.
        MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.

        CLEAR ls_rc.
        PERFORM update_womon_wohist
                USING ls_wo_mon ls_wo_mon_h ls_rc.

        IF ls_rc = 0.
          ls_items-wosta = ls_wosta.
          PERFORM set_status_icon USING ls_items-wosta ls_items-status.
        ELSE.
          PERFORM set_status_icon USING 'ERR' ls_items-status.
          PERFORM set_status_icon USING 'ERR' ls_header-status.
          ADD 1 TO lf_poserr.
        ENDIF.

      ELSE.
        PERFORM set_status_icon USING 'ERR' ls_items-status.
        PERFORM set_status_icon USING 'ERR' ls_header-status.
        ADD 1 TO lf_poserr.
      ENDIF.

      MODIFY gt_items FROM ls_items.

    ENDLOOP.

*   ICON auf Genehmigungsstatus setzen
    IF lf_poserr = 0.
      ls_header-wosta = ls_wosta.
      PERFORM set_status_icon USING ls_header-wosta ls_header-status.
      PERFORM create_approval USING ls_header-gpart
                                    ls_header-vkont
                                    ls_header-wosta
                                    ls_header-intverm
                                    lf_iverm
                                    ls_womonh_cha.
    ENDIF.

    MODIFY gt_header FROM ls_header.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_WROFF
*&---------------------------------------------------------------------*
FORM ucom_wroff   USING ff_ucomm LIKE sy-ucomm
                        ff_gplocked LIKE gv_gplocked.

  DATA: ls_header     TYPE /adesso/wo_header.
  DATA: ls_items      TYPE /adesso/wo_items.
  DATA: ls_wo_mon     TYPE /adesso/wo_mon.
  DATA: ls_wo_mon_h   TYPE /adesso/wo_mon_h.
  DATA: ls_rc         TYPE syst_subrc.
  DATA: lf_wosta      TYPE /adesso/wo_wosta.
  DATA: lf_opbel      TYPE opbel_kk.
  DATA: lf_opbel_mnsr TYPE opbel_kk.
  DATA: lf_applk      TYPE applk_kk.
  DATA: ls_fkkko      TYPE fkkko.
  DATA: ls_rfka1      TYPE rfka1.
  DATA: ls_fkkko_vk   TYPE fkkko.
  DATA: ls_rfka1_vk   TYPE rfka1.
  DATA: ls_fkkcl      TYPE fkkcl.
  DATA: lt_fkkcl      TYPE TABLE OF fkkcl.
  DATA: lt_fkkcl_mnsr TYPE TABLE OF fkkcl.
  DATA: lt_seltab     TYPE TABLE OF iseltab.
  DATA: ls_seltab     TYPE iseltab.
  DATA: lf_lines      LIKE sy-tfill.
  DATA: lt_split      TYPE TABLE OF fkkop_split_by_key.
  DATA: ls_buktab     TYPE ibuktab.
  DATA: lt_buktab     TYPE TABLE OF ibuktab.

  DATA: BEGIN OF ls_items_mnsr,
          opbel TYPE opbel_kk,
          opupw TYPE opupw_kk,
          opupk TYPE opupk_kk,
          opupz TYPE opupz_kk,
        END OF ls_items_mnsr.
  DATA: lt_items_mnsr LIKE TABLE OF ls_items_mnsr.

  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_poserr   TYPE sy-tabix.

  CLEAR: lf_applk, ls_fkkko, ls_rfka1.
  PERFORM prepare_wroff CHANGING lf_applk ls_fkkko ls_rfka1.

  LOOP AT gt_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

    IF ls_header-wosta NE '12'.
      ADD 1 TO lf_nochange.
      PERFORM set_status_icon USING 'ERR' ls_header-status.
      MODIFY gt_header FROM ls_header.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
*    CLEAR gs_stat.
*    READ TABLE gt_stat INTO gs_stat
*         WITH KEY begru = gs_bgus-begru
*                  ucomm = ff_ucomm
*                  agsta = ls_header-agsta.
*
*    IF sy-subrc NE 0.
*      CLEAR gs_stat.
*      ADD 1 TO lf_nochange.
*      CONTINUE.
*    ENDIF.

    REFRESH: lt_seltab, lt_fkkcl.
    CLEAR:   ls_seltab.
    ls_seltab-selnr = '0001'.
    ls_seltab-selfn = 'VKONT'.
    ls_seltab-selcu = ls_header-vkont.
    APPEND ls_seltab TO lt_seltab.

    CALL FUNCTION 'FKK_OPEN_ITEM_SELECT'
      EXPORTING
        i_applk             = lf_applk
        i_payment_date      = ls_rfka1-budat
        i_withhtax_out      = ' '
        i_withhtax_in       = ' '
      TABLES
        t_seltab            = lt_seltab
        t_fkkcl             = lt_fkkcl
      EXCEPTIONS
        concurrent_clearing = 1
        OTHERS              = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF lt_fkkcl[] IS INITIAL.
      ADD 1 TO lf_nochange.
      PERFORM set_status_icon USING 'ERR' ls_header-status.
      MODIFY gt_header FROM ls_header.
      CONTINUE.
    ENDIF.

    ls_fkkko_vk = ls_fkkko.
    ls_fkkko_vk-abgrd = ls_header-abgrd.

    ls_rfka1_vk = ls_rfka1.
    ls_rfka1_vk-abgrd = ls_header-abgrd.
    ls_rfka1_vk-gpart = ls_header-gpart.
    ls_rfka1_vk-vkont = ls_header-vkont.

    REFRESH lt_buktab.
    SELECT SINGLE stdbk FROM fkkvkp
          INTO ls_buktab-bukrs
           WHERE vkont = ls_header-vkont.
    APPEND ls_buktab TO lt_buktab.

    PERFORM openitem_by_5008_check(saplfka1)
            TABLES lt_fkkcl
            USING  ls_rfka1_vk
                   'FP04'.

    DESCRIBE TABLE lt_fkkcl LINES lf_lines.
    IF lf_lines = 0.
      ADD 1 TO lf_nochange.
      PERFORM set_status_icon USING 'ERR' ls_header-status.
      MODIFY gt_header FROM ls_header.
      CONTINUE.
    ENDIF.

    CASE ls_header-wosta.
      WHEN '12'.
        lf_wosta = '20'.
      WHEN OTHERS.
        ADD 1 TO lf_nochange.
        CONTINUE.
    ENDCASE.

* openitem_activate
    LOOP AT lt_fkkcl INTO ls_fkkcl.
      ls_fkkcl-xaktp = const_marked.
      ls_fkkcl-augbw = ls_fkkcl-betrw.
      ls_fkkcl-augbh = ls_fkkcl-betrh.
      ls_fkkcl-augrd = ls_rfka1_vk-augrd.
      IF NOT ls_fkkcl-stakz IS INITIAL.
        ls_fkkcl-xclon = 'X'.
      ENDIF.
      MODIFY lt_fkkcl FROM ls_fkkcl.
    ENDLOOP.

*   Posten mit Mahnung nach SR
    REFRESH: lt_items_mnsr.
    LOOP AT gt_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont
         AND   xmnsr = const_marked.
      MOVE-CORRESPONDING ls_items TO ls_items_mnsr.
      COLLECT ls_items_mnsr INTO lt_items_mnsr.
    ENDLOOP.

*   Splitten Posten mit Mahnung nach SR oder nicht
    LOOP AT lt_items_mnsr INTO ls_items_mnsr.
      LOOP AT lt_fkkcl INTO ls_fkkcl
           WHERE opbel = ls_items_mnsr-opbel
           AND   opupw = ls_items_mnsr-opupw
           AND   opupk = ls_items_mnsr-opupk
           AND   opupz = ls_items_mnsr-opupz.
        APPEND ls_fkkcl TO lt_fkkcl_mnsr.
        DELETE lt_fkkcl.
      ENDLOOP.
    ENDLOOP.

    CALL FUNCTION 'FKK_OPEN_ITEM_ENQUEUE'
      TABLES
        t_enqtab = ht_enqtab.

    IF lt_fkkcl[] IS NOT INITIAL.
      CALL FUNCTION 'FKK_OPEN_ITEM_ENQUEUE'
        TABLES
          t_enqtab = ht_enqtab.

      CALL FUNCTION 'FKK_WRITEOFF'
        EXPORTING
          i_fkkko       = ls_fkkko_vk
          i_rfka1       = ls_rfka1_vk
        IMPORTING
          e_opbel       = lf_opbel
        TABLES
          t_fkkcl       = lt_fkkcl
          t_fkkcl_split = lt_split
          t_buktab      = lt_buktab
        EXCEPTIONS
          OTHERS        = 1.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
        PERFORM set_status_icon USING 'ERR' ls_header-status.
        MODIFY gt_header FROM ls_header.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF lt_fkkcl_mnsr[] IS NOT INITIAL.
      CALL FUNCTION 'FKK_WRITEOFF'
        EXPORTING
          i_fkkko       = ls_fkkko_vk
          i_rfka1       = ls_rfka1_vk
        IMPORTING
          e_opbel       = lf_opbel_mnsr
        TABLES
          t_fkkcl       = lt_fkkcl_mnsr
          t_fkkcl_split = lt_split
          t_buktab      = lt_buktab
        EXCEPTIONS
          OTHERS        = 1.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
        PERFORM set_status_icon USING 'ERR' ls_header-status.
        MODIFY gt_header FROM ls_header.
        CONTINUE.
      ENDIF.
    ENDIF.

    CALL FUNCTION 'FKK_OPEN_ITEM_DEQUEUE'.

    CLEAR lf_poserr.

* jetzt alle Posten bearbeiten
    LOOP AT gt_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

* Ausgeglichene oder stornierte Posten nicht berücksichtigen
      CHECK ls_items-augdt IS INITIAL.

      SELECT SINGLE * FROM /adesso/wo_mon
             INTO  ls_wo_mon
             WHERE opbel = ls_items-opbel
             AND   opupw = ls_items-opupw
             AND   opupk = ls_items-opupk
             AND   opupz = ls_items-opupz.

      IF sy-subrc NE '0'.
        CONTINUE.
      ENDIF.

*     Beleg ausgebucht
      READ TABLE lt_fkkcl INTO ls_fkkcl
           WITH KEY opbel = ls_items-opbel.

      IF sy-subrc = 0.
        ls_wo_mon-wosta = lf_wosta.
        ls_wo_mon-abbel = lf_opbel.
        ls_wo_mon-abdat = ls_fkkko_vk-budat.
        MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.

        CLEAR ls_rc.
        PERFORM update_womon_wohist
                USING ls_wo_mon ls_wo_mon_h ls_rc.

        IF ls_rc = 0.
          ls_items-wosta = lf_wosta.
          ls_items-abbel = lf_opbel.
          ls_items-abdat = ls_fkkko_vk-budat.
          PERFORM set_status_icon USING ls_items-wosta ls_items-status.
        ELSE.
          PERFORM set_status_icon USING 'ERR' ls_items-status.
          PERFORM set_status_icon USING 'ERR' ls_header-status.
          ADD 1 TO lf_poserr.
        ENDIF.
        MODIFY gt_items FROM ls_items.
        CONTINUE.
      ENDIF.

*     Beleg ausgebucht Mahnung nach SR
      READ TABLE lt_fkkcl_mnsr INTO ls_fkkcl
           WITH KEY opbel = ls_items-opbel.

      IF sy-subrc = 0.
        ls_wo_mon-wosta = lf_wosta.
        ls_wo_mon-abbel = lf_opbel_mnsr.
        ls_wo_mon-abdat = ls_fkkko_vk-budat.
        MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.

        CLEAR ls_rc.
        PERFORM update_womon_wohist
                USING ls_wo_mon ls_wo_mon_h ls_rc.

        IF ls_rc = 0.
          ls_items-wosta = lf_wosta.
          ls_items-abbel = lf_opbel_mnsr.
          ls_items-abdat = ls_fkkko_vk-budat.
          PERFORM set_status_icon USING ls_items-wosta ls_items-status.
        ELSE.
          PERFORM set_status_icon USING 'ERR' ls_items-status.
          PERFORM set_status_icon USING 'ERR' ls_header-status.
          ADD 1 TO lf_poserr.
        ENDIF.
        MODIFY gt_items FROM ls_items.
        CONTINUE.
      ENDIF.

    ENDLOOP.

*   ICON auf Genehmigungsstatus setzen
    IF lf_poserr = 0.
      ls_header-wosta = lf_wosta.
      PERFORM set_status_icon USING ls_header-wosta ls_header-status.
      PERFORM create_contact USING ls_header.
    ENDIF.

    MODIFY gt_header FROM ls_header.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UC_DISPLAY_DOCU
*&---------------------------------------------------------------------*
FORM uc_display_docu USING ff_vkont TYPE vkont_kk
                           ff_gpart TYPE gpart_kk.

  DATA: ls_wo_cust TYPE /adesso/wo_cust.  "Customizing allgemein
  DATA: lt_thead   TYPE TABLE OF thead,
        ls_thead   TYPE thead,
        lv_pattern TYPE char30,
        lv_select  TYPE char30,
        ls_stxh    TYPE stxh,
        lt_stxh    TYPE STANDARD TABLE OF stxh,
        lt_texte   TYPE text_lh,
        ls_texte   TYPE itclh,
        ls_lines   TYPE tline,
        lt_text    TYPE catsxt_longtext_itab,
        ls_text    TYPE txline,
        ls_line    TYPE tline,
        lv_date    TYPE char10,
        lv_time    TYPE char8,
        lv_object  TYPE /adesso/inkasso_value,
        lv_id      TYPE /adesso/inkasso_value.

  CHECK NOT ff_vkont IS INITIAL.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'OBJECT'
             wo_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option    = 'INTVERM'
             wo_category  = 'DOCU'
             wo_field     = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CONCATENATE ff_gpart '_'
              ff_vkont '_'
              INTO lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
    WHERE tdobject = lv_object
      AND tdname LIKE lv_select
      AND tdid     = lv_id
      AND tdspras  = sy-langu.

  LOOP AT lt_stxh INTO ls_stxh.
    MOVE-CORRESPONDING ls_stxh TO ls_thead.
    APPEND ls_thead TO lt_thead.
    CLEAR ls_thead.
  ENDLOOP.

  CALL FUNCTION 'READ_TEXT_TABLE'
    IMPORTING
      text_table              = lt_texte
    TABLES
      text_headers            = lt_thead
    EXCEPTIONS
      wrong_access_to_archive = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SORT lt_texte BY header-tdname DESCENDING.

  LOOP AT lt_texte INTO ls_texte.

*         Datum Formatieren
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_texte-header-tdfdate
      IMPORTING
        date_external            = lv_date
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   Zeit umformatieren
    CONCATENATE ls_texte-header-tdftime(2)
                ':'
                ls_texte-header-tdftime+2(2)
                ':'
                ls_texte-header-tdftime+4(2)
                 INTO lv_time.

    CONCATENATE ls_texte-header-tdfuser
                lv_date
                lv_time
                INTO ls_text
                SEPARATED BY space.

    APPEND ls_text TO lt_text.
    CLEAR ls_text.
*         Texte einlesen
    LOOP AT ls_texte-lines INTO ls_lines.
      MOVE ls_lines-tdline TO ls_text.
      APPEND ls_text TO lt_text.
      CLEAR ls_text.
    ENDLOOP.
    APPEND INITIAL LINE TO lt_text.
  ENDLOOP.

  CALL FUNCTION 'CATSXT_SIMPLE_TEXT_EDITOR'
    EXPORTING
      im_title        = 'MONITOR AUSBUCHUNG'
      im_display_mode = 'X'
*     IM_START_COLUMN = 10
*     IM_START_ROW    = 10
    CHANGING
      ch_text         = lt_text.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_CORRECT
*&---------------------------------------------------------------------*
FORM ucom_correct USING ff_ucomm LIKE sy-ucomm
                        ff_gplocked LIKE gv_gplocked.

  DATA: ls_header     TYPE /adesso/wo_header.
  DATA: ls_items      TYPE /adesso/wo_items.
  DATA: ls_wo_mon     TYPE /adesso/wo_mon.
  DATA: ls_wo_mon_h   TYPE /adesso/wo_mon_h.
  DATA: ls_rc         TYPE syst_subrc.
  DATA: ls_wosta      TYPE /adesso/wo_wosta.
  DATA: ls_womonh_cha LIKE gs_womonh_cha.

  DATA: lf_nochange TYPE sy-tabix.
  DATA: lf_poserr   TYPE sy-tabix.
  DATA: lf_iverm  TYPE /adesso/inkasso_text.

  CLEAR ls_womonh_cha.

* pop-up to enter text
  CALL SCREEN 9100
     STARTING AT 21 2.

  IF ok EQ 'CANC'.
    CLEAR ok.
    EXIT.
  ELSE.
    lf_iverm = /adesso/wo_req-freetext.
  ENDIF.
  CLEAR ok.

  LOOP AT gt_header INTO ls_header
       WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
    IF ls_header-locked IS NOT INITIAL.
      ff_gplocked = 'X'.
      CONTINUE.
    ENDIF.

* Berechtigung für Status ?
*    CLEAR gs_stat.
*    READ TABLE gt_stat INTO gs_stat
*         WITH KEY begru = gs_bgus-begru
*                  ucomm = ff_ucomm
*                  agsta = ls_header-agsta.
*
*    IF sy-subrc NE 0.
*      CLEAR gs_stat.
*      ADD 1 TO lf_nochange.
*      CONTINUE.
*    ENDIF.

    CASE ls_header-wosta.
      WHEN '01'.
        ls_wosta = '02'.
      WHEN '10'.
        ls_wosta = '02'.
      WHEN '11'.
        ls_wosta = '02'.
      WHEN '12'.
        ls_wosta = '02'.
      WHEN OTHERS.
        ADD 1 TO lf_nochange.
        CONTINUE.
    ENDCASE.

    CLEAR lf_poserr.

* jetzt alle Posten bearbeiten
    LOOP AT gt_items INTO ls_items
         WHERE gpart = ls_header-gpart
         AND   vkont = ls_header-vkont.

** Ausgeglichene oder stornierte Posten nicht berücksichtigen
*      CHECK ls_items-augdt IS INITIAL.

      SELECT SINGLE * FROM /adesso/wo_mon
             INTO  ls_wo_mon
             WHERE opbel = ls_items-opbel
             AND   opupw = ls_items-opupw
             AND   opupk = ls_items-opupk
             AND   opupz = ls_items-opupz.

      IF sy-subrc = 0.
        ls_wo_mon-wosta = ls_wosta.
        MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.

        CLEAR ls_rc.
        PERFORM update_womon_wohist
                USING ls_wo_mon ls_wo_mon_h ls_rc.

        IF ls_rc = 0.
          ls_items-wosta = ls_wosta.
          PERFORM set_status_icon USING ls_items-wosta ls_items-status.
        ELSE.
          PERFORM set_status_icon USING 'ERR' ls_items-status.
          PERFORM set_status_icon USING 'ERR' ls_header-status.
          ADD 1 TO lf_poserr.
        ENDIF.

      ELSE.
        PERFORM set_status_icon USING 'ERR' ls_items-status.
        PERFORM set_status_icon USING 'ERR' ls_header-status.
        ADD 1 TO lf_poserr.
      ENDIF.

      MODIFY gt_items FROM ls_items.

    ENDLOOP.

*   ICON auf Genehmigungsstatus setzen
    IF lf_poserr = 0.
      ls_header-wosta = ls_wosta.
      PERFORM set_status_icon USING ls_header-wosta ls_header-status.
      PERFORM create_approval USING ls_header-gpart
                                    ls_header-vkont
                                    ls_header-wosta
                                    ls_header-intverm
                                    lf_iverm
                                    ls_womonh_cha.

      PERFORM create_intverm_ink USING ls_header-gpart
                                       ls_header-vkont
                                       ls_header-wosta
                                       ls_header-intverm
                                       lf_iverm
                                       ls_header-wohkf.
    ENDIF.

    MODIFY gt_header FROM ls_header.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UCOM_STORNO
*&---------------------------------------------------------------------*
FORM ucom_storno USING ff_ucomm    LIKE sy-ucomm
                       ff_gplocked LIKE gv_gplocked.


*  DATA: ls_dfkkko TYPE dfkkko.
*  DATA: ls_dfkkop TYPE dfkkop.
*
*  DATA: ls_items LIKE /adesso/wo_items,
*        lt_items LIKE STANDARD TABLE OF /adesso/wo_items.
*
*  DATA: rspar_tab  TYPE TABLE OF rsparams,
*        rspar_line LIKE LINE OF rspar_tab.
*
*  DATA: lt_cust TYPE TABLE OF /adesso/ink_cust,
*        ls_cust TYPE /adesso/ink_cust.
*
*  SELECT * FROM /adesso/ink_cust INTO TABLE  lt_cust
*    WHERE inkasso_option = 'STORNO'
*      AND inkasso_field =  'BLART'.
*
*  IF sy-subrc NE 0.
*    MESSAGE e007.
*  ENDIF.
*
*  LOOP AT gt_items INTO ls_items
*     WHERE sel IS NOT INITIAL.
*
** Ausgeglichene oder stornierte Posten nicht berücksichtigen
*    CHECK ls_items-augdt IS INITIAL.
*
** Storno Mahnkosten immer zulassen
**    CHECK ls_items-agsta NOT BETWEEN '01' AND '02'.
*
*    SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
*           WHERE opbel = ls_items-opbel.
*
*    READ TABLE lt_cust TRANSPORTING NO FIELDS
*         WITH KEY inkasso_value = ls_dfkkko-blart.
*
*    IF sy-subrc = 0.
*      APPEND ls_items TO lt_items.
*    ENDIF.
*  ENDLOOP.
*
*  IF lt_items IS INITIAL.
*    MESSAGE e006.
*  ENDIF.
*
** Normale ALV-Tabelle
*  LOOP AT lt_items INTO ls_items.
*
*    rspar_line-selname = 'SC_OPBEL-LOW'.
*    rspar_line-kind = 'S'.
*    rspar_line-sign = 'I'.
*    rspar_line-option = 'EQ'.
*    rspar_line-low = ls_items-opbel.
*    APPEND rspar_line TO rspar_tab.
*    CLEAR rspar_line.
*
*  ENDLOOP.
*
*  PERFORM fill_rspar_rfkkstor TABLES rspar_tab.
*
*  IF rspar_tab IS NOT INITIAL.
*    SUBMIT rfkkstor  VIA SELECTION-SCREEN
*                     WITH SELECTION-TABLE rspar_tab
*                     AND RETURN.
*  ENDIF.
*
*  LOOP AT t_items INTO ls_items WHERE sel IS NOT INITIAL.
*
*    CLEAR ls_dfkkop.
*    SELECT SINGLE * FROM dfkkop INTO ls_dfkkop
*       WHERE opbel = ls_items-opbel
*         AND opupw = ls_items-opupw
*         AND opupk = ls_items-opupk
*         AND opupz = ls_items-opupz.
*
*    IF ls_dfkkop-augbl IS NOT INITIAL AND
*       ls_dfkkop-augrd = '05'.
*
*      ls_items-augdt = ls_dfkkop-augdt.
*      ls_items-augrd = ls_dfkkop-augrd.
*
*      IF ls_items-agsta BETWEEN '97' AND '99'.
*        PERFORM set_agsta_dfkkcoll USING ls_items-opbel
*                                         ls_items-inkps
*                                         c_mode_del
*                                         ls_items-agsta
*                                         ' '.
*      ENDIF.
*
*      CALL FUNCTION 'ICON_CREATE'
*        EXPORTING
*          name                  = 'ICON_STORNO'
*          info                  = TEXT-013
*        IMPORTING
*          result                = ls_items-status
*        EXCEPTIONS
*          icon_not_found        = 1
*          outputfield_too_short = 2
*          OTHERS                = 3.
*
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*    ENDIF.
*
*    MODIFY t_items FROM ls_items.
*
*  ENDLOOP.

ENDFORM.
