*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LWO_REQF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST_ABGRD
*&---------------------------------------------------------------------*
FORM value_request_abgrd  CHANGING ff_abgrd.
*----------------------------------------------------------------------*
  DATA: lt_tfk048a        LIKE tfk048a  OCCURS 0 WITH HEADER LINE,
        lf_txt50          LIKE tfk048at-abtxt,
        lt_field_tab      LIKE dfies    OCCURS 0 WITH HEADER LINE,
        lt_value_tab(100) TYPE c        OCCURS 0 WITH HEADER LINE,
        lf_retfield       TYPE dfies-fieldname,
        lt_returntab      LIKE ddshretval OCCURS 0 WITH HEADER LINE.
*----------------------------------------------------------------------*
  CALL FUNCTION 'FKK_DB_TFK048A_MULTIPLE'
    EXPORTING
      i_xwotr       = '1'
    TABLES
      t_tfk048a     = lt_tfk048a
    EXCEPTIONS
      input_error   = 1
      nothing_found = 2
      OTHERS        = 3.

  IF sy-subrc <> 0.
    MESSAGE s801(dh).
*   Keine Werte gefunden
    EXIT.
  ENDIF.

  LOOP AT lt_tfk048a.
* -------------------  fill value + text -----------------------------*
    lt_value_tab = lt_tfk048a-abgrd.
    APPEND: lt_value_tab.

    CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
      EXPORTING
        i_abgrd   = lt_tfk048a-abgrd
      IMPORTING
        e_txt50   = lf_txt50
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc =  0.
      lt_value_tab = lf_txt50.
      APPEND: lt_value_tab.
    ELSE.
      CLEAR lt_value_tab.
      APPEND: lt_value_tab.
    ENDIF.
  ENDLOOP.
* --------------------- fill field table ------------------------------*
  lt_field_tab-tabname = 'TFK048A'.
  lt_field_tab-fieldname = 'ABGRD'.
  APPEND lt_field_tab.
  lt_field_tab-tabname = 'TFK048AT'.
  lt_field_tab-fieldname = 'ABTXT'.
  APPEND lt_field_tab.

  lf_retfield = 'ABGRD'.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = lf_retfield
      value_org       = 'C'
    TABLES
      value_tab       = lt_value_tab
      field_tab       = lt_field_tab
      return_tab      = lt_returntab
    EXCEPTIONS
      parameter_error = 0
      no_values_found = 0.

  READ TABLE lt_returntab INDEX 1.
  IF sy-subrc = 0.
    ff_abgrd = lt_returntab-fieldval.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST_WOIGD
*&---------------------------------------------------------------------*
FORM value_request_woigd  CHANGING ff_woigd.
*----------------------------------------------------------------------*
  DATA: lt_wo_igrd        LIKE /adesso/wo_igrd  OCCURS 0 WITH HEADER LINE,
        ls_wo_igrdt       LIKE /adesso/wo_igrdt,
        lt_field_tab      LIKE dfies    OCCURS 0 WITH HEADER LINE,
        lt_value_tab(100) TYPE c        OCCURS 0 WITH HEADER LINE,
        lf_retfield       TYPE dfies-fieldname,
        lt_returntab      LIKE ddshretval OCCURS 0 WITH HEADER LINE.
*----------------------------------------------------------------------*

  SELECT * FROM /adesso/wo_igrd INTO TABLE lt_wo_igrd.
  IF sy-subrc <> 0.
    MESSAGE s801(dh).
*   Keine Werte gefunden
    EXIT.
  ENDIF.

  LOOP AT lt_wo_igrd.
* -------------------  fill value + text -----------------------------*
    lt_value_tab = lt_wo_igrd-woigd.
    APPEND: lt_value_tab.

    SELECT SINGLE * FROM /adesso/wo_igrdt
           INTO ls_wo_igrdt
           WHERE spras = sy-langu
           AND   woigd = lt_wo_igrd-woigd.

    IF sy-subrc NE 0.
      CLEAR:  lt_value_tab.
      APPEND: lt_value_tab.
    ELSE.
      lt_value_tab = ls_wo_igrdt-woigdt.
      APPEND: lt_value_tab.
    ENDIF.

  ENDLOOP.

* --------------------- fill field table ------------------------------*
  lt_field_tab-tabname   = '/ADESSO/WO_IGRD'.
  lt_field_tab-fieldname = 'WOIGD'.
  APPEND lt_field_tab.
  lt_field_tab-tabname   = '/ADESSO/WO_IGRDT'.
  lt_field_tab-fieldname = 'WOIGDT'.
  APPEND lt_field_tab.

  lf_retfield = 'WOIGD'.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = lf_retfield
      value_org       = 'C'
    TABLES
      value_tab       = lt_value_tab
      field_tab       = lt_field_tab
      return_tab      = lt_returntab
    EXCEPTIONS
      parameter_error = 0
      no_values_found = 0.

  READ TABLE lt_returntab INDEX 1.
  IF sy-subrc = 0.
    ff_woigd = lt_returntab-fieldval.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST_WOVKS
*&---------------------------------------------------------------------*
FORM value_request_wovks  CHANGING ff_wovks.
*----------------------------------------------------------------------*
  DATA: lt_wo_vks         LIKE /adesso/wo_vks  OCCURS 0 WITH HEADER LINE,
        ls_wo_vkst        LIKE /adesso/wo_vkst,
        lt_field_tab      LIKE dfies    OCCURS 0 WITH HEADER LINE,
        lt_value_tab(100) TYPE c        OCCURS 0 WITH HEADER LINE,
        lf_retfield       TYPE dfies-fieldname,
        lt_returntab      LIKE ddshretval OCCURS 0 WITH HEADER LINE.
*----------------------------------------------------------------------*

  SELECT * FROM /adesso/wo_vks INTO TABLE lt_wo_vks.
  IF sy-subrc <> 0.
    MESSAGE s801(dh).
*   Keine Werte gefunden
    EXIT.
  ENDIF.

  LOOP AT lt_wo_vks.
* -------------------  fill value + text -----------------------------*
    lt_value_tab = lt_wo_vks-wovks.
    APPEND: lt_value_tab.

    SELECT SINGLE * FROM /adesso/wo_vkst
           INTO ls_wo_vkst
           WHERE spras = sy-langu
           AND   wovks = lt_wo_vks-wovks.

    IF sy-subrc NE 0.
      CLEAR:  lt_value_tab.
      APPEND: lt_value_tab.
    ELSE.
      lt_value_tab = ls_wo_vkst-wovkt.
      APPEND: lt_value_tab.
    ENDIF.

  ENDLOOP.

* --------------------- fill field table ------------------------------*
  lt_field_tab-tabname   = '/ADESSO/WO_VKS'.
  lt_field_tab-fieldname = 'WOVKS'.
  APPEND lt_field_tab.
  lt_field_tab-tabname   = '/ADESSO/WO_VKST'.
  lt_field_tab-fieldname = 'WOVKT'.
  APPEND lt_field_tab.

  lf_retfield = 'WOVKS'.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = lf_retfield
      value_org       = 'C'
    TABLES
      value_tab       = lt_value_tab
      field_tab       = lt_field_tab
      return_tab      = lt_returntab
    EXCEPTIONS
      parameter_error = 0
      no_values_found = 0.

  READ TABLE lt_returntab INDEX 1.
  IF sy-subrc = 0.
    ff_wovks = lt_returntab-fieldval.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_GPART
*&---------------------------------------------------------------------*
FORM check_gpart USING    ff_gpart LIKE /adesso/wo_req-gpart
                 CHANGING ff_txtgp LIKE /adesso/wo_req-txtgp.
*----------------------------------------------------------------------*
  IF NOT ff_gpart IS INITIAL.
    CALL FUNCTION 'FKK_PARTNER_CHECK'
      EXPORTING
        i_partner                 = ff_gpart
      EXCEPTIONS
        partner_not_found         = 1
        partner_in_role_not_found = 2
        wrong_parameters          = 3
        OTHERS                    = 4.
    IF sy-subrc NE 0.
      CLEAR ff_txtgp.
      SET CURSOR FIELD '/ADESSO/WO_REQ-GPART'.
      MESSAGE e016(>3) WITH ff_gpart.
    ELSE.
      SET PARAMETER ID 'BPA' FIELD ff_gpart.

*     N2025166: get text corresponding to GPART
      PERFORM get_gpart_text USING    ff_gpart
                             CHANGING ff_txtgp.
    ENDIF.
  ELSE.
    CLEAR ff_txtgp.
    SET PARAMETER ID 'BPA' FIELD ' '.
  ENDIF.
ENDFORM.                               " CHECK_GPART

*&---------------------------------------------------------------------*
*&      Form  GET_GPART_TEXT
*&---------------------------------------------------------------------*
FORM get_gpart_text  USING    ff_gpart        LIKE /adesso/wo_req-gpart
                     CHANGING VALUE(ff_txtgp) LIKE /adesso/wo_req-txtgp.
* ---------------------------------------------------------------------*
  DATA: h_txtgp LIKE /adesso/wo_req-txtgp.
* ---------------------------------------------------------------------*
  IF NOT ff_gpart IS INITIAL.
    CALL FUNCTION 'FKK_PARTNER_HEADER_DISPLAY'
      EXPORTING
        x_partner = ff_gpart
      IMPORTING
        y_text1   = h_txtgp
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
      ff_txtgp = h_txtgp.
    ELSE.
      CLEAR ff_txtgp.                                       "N2025166
    ENDIF.
  ELSE.
    CLEAR ff_txtgp.                                         "N2025166
  ENDIF.

ENDFORM.                               " GET_GPART_TEXT

*&---------------------------------------------------------------------*
*&      Form  CHECK_VKONT
*&---------------------------------------------------------------------*
FORM check_vkont USING    ff_vkont LIKE /adesso/wo_req-vkont
                 CHANGING ff_txtvk LIKE /adesso/wo_req-txtvk.
*----------------------------------------------------------------------*
  DATA: h_fkkvk LIKE fkkvk.
*----------------------------------------------------------------------*
  IF NOT ff_vkont IS INITIAL.
    CALL FUNCTION 'FKK_FKKVK_READ'
      EXPORTING
        i_vkont   = ff_vkont
      IMPORTING
        e_fkkvk   = h_fkkvk
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc NE 0.
      CLEAR ff_txtvk.
      SET CURSOR FIELD '/ADESSO/WO_REQ-VKONT'.
      MESSAGE e001(>3) WITH ff_vkont.
    ELSE.
      SET PARAMETER ID 'KTO' FIELD ff_vkont.
      ff_txtvk = h_fkkvk-vkbez.
    ENDIF.
  ELSE.
    CLEAR ff_txtvk.
    SET PARAMETER ID 'KTO' FIELD ' '.
  ENDIF.

ENDFORM.                               " CHECK_VKONT

*&---------------------------------------------------------------------*
*&      Form  CHECK_GPART_VKONT
*&---------------------------------------------------------------------*
FORM check_gpart_vkont USING ff_gpart LIKE /adesso/wo_req-gpart
                             ff_vkont LIKE /adesso/wo_req-vkont.
*----------------------------------------------------------------------*
  IF NOT ff_gpart IS INITIAL AND NOT ff_vkont IS INITIAL.
    CALL FUNCTION 'FKK_ACCOUNT_READ'
      EXPORTING
        i_vkont      = ff_vkont
        i_gpart      = ff_gpart
        i_only_gpart = 'X'
      EXCEPTIONS
        not_found    = 1
        foreign_lock = 2
        OTHERS       = 3.
    IF sy-subrc NE 0.
      SET CURSOR FIELD '/ADESSO/WO_REQ-VKONT'.
      MESSAGE e002(>3) WITH ff_vkont ff_gpart.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECK_GPART_VKONT

*&---------------------------------------------------------------------*
*&      Form  GET_GPART
*&---------------------------------------------------------------------*
FORM get_gpart USING    ff_vkont LIKE /adesso/wo_req-vkont
               CHANGING ff_gpart LIKE /adesso/wo_req-gpart
                        ff_txtgp LIKE /adesso/wo_req-txtgp.
*----------------------------------------------------------------------*
  IF ff_gpart IS INITIAL.

    CALL FUNCTION 'FKK_GET_BU_PARTNER_OF_ACCOUNT'
      EXPORTING
        i_vkont      = ff_vkont
      IMPORTING
        e_partner    = ff_gpart
      EXCEPTIONS
        system_error = 1
        OTHERS       = 2.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      SET PARAMETER ID 'BPA' FIELD ff_gpart.

*   N2025166: get text corresponding to GPART
      PERFORM get_gpart_text USING    ff_gpart
                             CHANGING ff_txtgp.

    ENDIF.

  ENDIF.
ENDFORM.                               " GET_GPART

*&---------------------------------------------------------------------*
*&      Form  CHECK_ABGRD
*&---------------------------------------------------------------------*
FORM check_abgrd USING    ff_abgrd        LIKE /adesso/wo_req-abgrd
                 CHANGING VALUE(ff_text)  LIKE /adesso/wo_req-txgrd.
*----------------------------------------------------------------------*
  DATA: lf_xwotr       LIKE tfk048a-xwotr,
        lf_xtabg       LIKE tfk048a-xtabg,
        lf_value_text1 LIKE dd07t-ddtext,
        lf_value_text2 LIKE dd07t-ddtext.
*----------------------------------------------------------------------*
  CALL FUNCTION 'FKK_DB_TFK048A_SINGLE'
    EXPORTING
      i_abgrd           = ff_abgrd
    IMPORTING
      e_xtabg           = lf_xtabg
      e_xwotr           = lf_xwotr
    EXCEPTIONS
      not_found         = 1
      initial_parameter = 2
      OTHERS            = 3.

  IF sy-subrc NE 0.
    SET CURSOR FIELD 'RFKA1-ABGRD'.
    CLEAR lf_xtabg.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF lf_xwotr = '2'.
* --------- write-off reason is only allowed for mass write-off ------*
      CALL FUNCTION 'STF4_GET_DOMAIN_VALUE_TEXT'
        EXPORTING
          iv_domname      = 'XWOTR_KK'
          iv_value        = '1'
        IMPORTING
          ev_value_text   = lf_value_text1
        EXCEPTIONS
          value_not_found = 0.

      CALL FUNCTION 'STF4_GET_DOMAIN_VALUE_TEXT'
        EXPORTING
          iv_domname      = 'XWOTR_KK'
          iv_value        = '2'
        IMPORTING
          ev_value_text   = lf_value_text2
        EXCEPTIONS
          value_not_found = 0.

      SET CURSOR FIELD '/ADESSO/WO_REQ-ABGRD'.
      MESSAGE e861(>3) WITH ff_abgrd lf_value_text2 lf_value_text1.
*   Ausbuchungsgrund &1 darf nicht für diese Transaktion verwendet werde
    ENDIF.
  ENDIF.

  CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
    EXPORTING
      i_abgrd = ff_abgrd
    IMPORTING
      e_txt50 = ff_text
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc NE 0.
    CLEAR ff_text.
  ENDIF.

ENDFORM.                               " CHECK_ABGRD

*&---------------------------------------------------------------------*
*&      Form  GET_WOIGD_TXT
*&---------------------------------------------------------------------*
FORM get_woigd_txt  USING    ff_woigd LIKE /adesso/wo_req-woigd
                    CHANGING ff_txigd LIKE /adesso/wo_req-txigd.

  DATA: ls_wo_igrdt LIKE /adesso/wo_igrdt.

  SELECT SINGLE * FROM /adesso/wo_igrdt
         INTO ls_wo_igrdt
         WHERE spras = sy-langu
         AND   woigd = ff_woigd.

  IF sy-subrc NE 0.
    MESSAGE e036 WITH ff_woigd.
  ELSE.
    ff_txigd = ls_wo_igrdt-woigdt.
  ENDIF.

ENDFORM.                               " GET_WOIGD_TXT

*&---------------------------------------------------------------------*
*&      Form  GET_WOVKS_TXT
*&---------------------------------------------------------------------*
FORM get_wovks_txt  USING    ff_wovks LIKE /adesso/wo_req-wovks
                    CHANGING ff_txvks LIKE /adesso/wo_req-txvks.

  DATA: ls_wo_vkst LIKE /adesso/wo_vkst.

  SELECT SINGLE * FROM /adesso/wo_vkst
         INTO ls_wo_vkst
         WHERE spras = sy-langu
         AND   wovks = ff_wovks.

  IF sy-subrc NE 0.
    MESSAGE e037 WITH ff_wovks.
  ELSE.
    ff_txvks = ls_wo_vkst-wovkt.
  ENDIF.

ENDFORM.                               " GET_WOIGD_TXT

*-----------------------------------------------------------------------
*        EXIT-Kommandos aus Dynpro 0100
*-----------------------------------------------------------------------
FORM exit_code USING ff_okcode       LIKE okcode
                     fs_wo_req       STRUCTURE /adesso/wo_req.
*                     p_rfka1_buffer STRUCTURE rfka1.
*----------------------------------------------------------------------*
  DATA: h_title  LIKE rfka1-txt01,
        h_answer LIKE boole-boole.
*----------------------------------------------------------------------*
  CLEAR h_answer.
  CASE ff_okcode.
    WHEN 'BACK'.
      h_title = TEXT-bac.
    WHEN 'EXIT'.
      h_title = TEXT-exi.
    WHEN 'CANC'.
      h_title = TEXT-can.
    WHEN 'DELS'.
      CLEAR: fs_wo_req.
      REFRESH: gt_tc_fkkop.
      REFRESH: gt_editor_text, gt_i_text.
      SET SCREEN sy-dynnr.
      LEAVE SCREEN.
    WHEN 'FPL9'.
      SET PARAMETER ID 'BPA' FIELD fs_wo_req-gpart.
      SET PARAMETER ID 'KTO' FIELD fs_wo_req-vkont.
      CALL TRANSACTION 'FPL9' AND SKIP FIRST SCREEN.
    WHEN 'CIC'.
      PERFORM ucom_get_cic USING fs_wo_req-vkont.
    WHEN 'FP4H'.
      SET PARAMETER ID 'BPA' FIELD fs_wo_req-gpart.
      SET PARAMETER ID 'KTO' FIELD fs_wo_req-vkont.
      CALL TRANSACTION 'FP04H' AND SKIP FIRST SCREEN.
*----------- reversal for the external write-off process --------------*
*    WHEN 'STORN'.
*      SUBMIT rfkkwoh_tmp
*      VIA SELECTION-SCREEN
*      AND RETURN.
  ENDCASE.

  IF ff_okcode = 'BACK' OR ff_okcode = 'EXIT' OR ff_okcode = 'CANC'.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = h_title
        text_question  = TEXT-001
      IMPORTING
        answer         = h_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDIF.

  IF h_answer NE '2'.          " '2' means NO
    CASE ff_okcode.
      WHEN 'EXIT'.
        SET SCREEN 0.
        LEAVE SCREEN.
      WHEN 'CANC'.
        SET SCREEN 0.
        LEAVE SCREEN.
      WHEN 'BACK'.
        SET SCREEN 0.
        LEAVE SCREEN.
    ENDCASE.
  ENDIF.

ENDFORM.                               " EXIT_CODE

*&---------------------------------------------------------------------*
*&      Form  UCOM_GET_CIC
*&---------------------------------------------------------------------*
FORM ucom_get_cic USING ff_vkont TYPE vkont_kk.

* --> nuss 04.2018
  DATA: iv_screen_no TYPE cicfwscreenno.
  DATA: wa_bdc    TYPE bdcdata,
        t_bdc     TYPE TABLE OF bdcdata,
        t_messtab TYPE TABLE OF bdcmsgcoll.

  DATA:  lv_tcode TYPE sy-tcode.
* <-- Nuss 04.2018

  PERFORM get_cic_frame_for_user CHANGING iv_screen_no.

  CLEAR t_bdc.

  wa_bdc-fnam = 'BDC_OKCODE'.
  wa_bdc-fval = '=RFSH'.
  APPEND wa_bdc TO t_bdc.
  CLEAR wa_bdc.

  wa_bdc-fnam = 'EFINDD_CIC-A_VKONT'.
  wa_bdc-fval = ff_vkont.
  APPEND wa_bdc TO t_bdc.
  CLEAR wa_bdc.

  IF iv_screen_no IS NOT INITIAL.
    CLEAR wa_bdc.
    wa_bdc-program = 'SAPLCIC0'.
    wa_bdc-dynpro = iv_screen_no.
    wa_bdc-dynbegin = 'X'.
    APPEND wa_bdc TO t_bdc.
    CLEAR wa_bdc.

    SORT t_bdc
      BY program DESCENDING
           fnam  ASCENDING.
  ELSE.
    MESSAGE w020.
    CLEAR  t_bdc.
  ENDIF.

  lv_tcode = 'CIC0'.

  CALL FUNCTION 'CALL_CIC_TRANSACTION'
    EXPORTING
      tcode            = lv_tcode
      skipfirst        = 'X'
    TABLES
      in_bdcdata       = t_bdc
      out_messtab      = t_messtab
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
FORM get_cic_frame_for_user  CHANGING iv_screen_no TYPE cicfwscreenno.

  DATA: it_cic_prof TYPE TABLE OF cicprofiles.

  CALL FUNCTION 'CIC_GET_ORG_PROFILES'
    EXPORTING
      agent                 = sy-uname
    TABLES
      profile_list          = it_cic_prof
    EXCEPTIONS
      call_center_not_found = 1
      agent_group_not_found = 2
      profiles_not_found    = 3
      no_hr_record          = 4
      cancel                = 5
      OTHERS                = 6.
  IF sy-subrc <> 0.
    MESSAGE e020.
    EXIT.
  ENDIF.

* existiert mind. 1 Eintrag
  IF lines( it_cic_prof ) EQ 0.
    MESSAGE e020.
    EXIT.
  ENDIF.

* 1. Datensatz aus Tabelle zuweisen
  FIELD-SYMBOLS: <fs_prof> TYPE cicprofiles.
  READ TABLE it_cic_prof ASSIGNING <fs_prof> INDEX 1.
* Fehlerprüfung
  IF <fs_prof> IS NOT ASSIGNED.
    MESSAGE e020.
    EXIT.
  ENDIF.

* Passendes CIC-Profil lesen
* Konfiguration auslesen um die DYNPRO-Nr zu gelangen
  SELECT SINGLE frame_screen
    INTO iv_screen_no
    FROM cicprofile
      INNER JOIN cicconf
        ON cicconf~mandt = cicprofile~mandt
        AND cicconf~frame_conf = cicprofile~framework_id
    WHERE cicprofile~mandt = sy-mandt
    AND cicprofile~cicprof = <fs_prof>-cicprof.

  IF iv_screen_no IS INITIAL.
    MESSAGE e020.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_EDITOR_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_editor_text.

  DATA: lf_stext_modified TYPE i.

* retrieve table from control
  CALL METHOD stext_editor->get_text_as_r3table
    EXPORTING
      only_when_modified = cl_gui_textedit=>true
    IMPORTING
      table              = gt_editor_text
      is_modified        = lf_stext_modified
    EXCEPTIONS
      OTHERS             = 1.

  IF sy-subrc NE 0.
    MESSAGE e800(bmen).
  ENDIF.

* change table if text has been modified
  IF lf_stext_modified = cl_gui_textedit=>true.
    gv_text_modified = 'X'.
    gt_i_text[] = gt_editor_text[].
  ENDIF.

ENDFORM.                               " GET_EDITOR_TEXT
*&---------------------------------------------------------------------*
*&      Form  UCOM_ENTR
*&---------------------------------------------------------------------*
FORM ucom_entr  USING    fs_wo_req   STRUCTURE /adesso/wo_req
                CHANGING ft_tc_fkkop LIKE gt_tc_fkkop.

  PERFORM select_items USING fs_wo_req
                       CHANGING ft_tc_fkkop.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UCOM_WOREQ
*&---------------------------------------------------------------------*
FORM ucom_woreq  USING    fs_wo_req STRUCTURE /adesso/wo_req
                          ft_tc_fkkop LIKE gt_tc_fkkop
                          ft_i_text like gt_i_text.

  DATA: lt_wo_mon   TYPE TABLE OF /adesso/wo_mon.
  DATA: ls_wo_mon   TYPE /adesso/wo_mon.
  DATA: lt_wo_mon_h TYPE TABLE OF /adesso/wo_mon_h.
  DATA: ls_wo_mon_h TYPE /adesso/wo_mon_h.
  DATA: ls_tc_fkkop TYPE /adesso/wo_fkkcoll.
  DATA: ls_dfkkko   TYPE dfkkko.
  DATA: ls_cust     TYPE /adesso/wo_cust.
  DATA: lf_wohkf    TYPE /adesso/wo_mon-wohkf.
  DATA: lf_wosta    TYPE /adesso/wo_mon-wosta.
  DATA: lf_begru    TYPE /adesso/wo_mon-begru.
  DATA: lf_lockr    TYPE lockr_kk.
  DATA: lf_lines    TYPE syst-tabix.

  DATA: lf_stext_modified TYPE i.
  DATA: lt_editor_text TYPE TABLE OF text80.

* Text nochmal nachlesen
  CALL METHOD stext_editor->get_text_as_r3table
    EXPORTING
      only_when_modified = cl_gui_textedit=>true
    IMPORTING
      table              = lt_editor_text
      is_modified        = lf_stext_modified
    EXCEPTIONS
      OTHERS             = 1.

  IF sy-subrc NE 0.
    MESSAGE e800(bmen).
  ENDIF.


* change table if text has been modified
  IF lf_stext_modified = cl_gui_textedit=>true.
    gv_text_modified = 'X'.
    ft_i_text[] = lt_editor_text[].
  ENDIF.

  IF ft_i_text[] IS INITIAL.
    MESSAGE e033.
  ENDIF.

  CLEAR: ls_cust.
  READ TABLE gt_cust INTO ls_cust
       WITH KEY wo_option   = 'AUSBUCHUNG'
                wo_category = 'HERKUNFT'
                wo_field    = 'WOHKF'.

  IF sy-subrc = 0.
    lf_wohkf = ls_cust-wo_value.
  ENDIF.

  CLEAR: ls_cust.
  READ TABLE gt_cust INTO ls_cust
       WITH KEY wo_option   = 'AUSBUCHUNG'
                wo_category = 'STATUS'
                wo_field    = 'WOSTA'.

  IF sy-subrc = 0.
    lf_wosta = ls_cust-wo_value.
  ENDIF.

  CLEAR: ls_cust.
  READ TABLE gt_cust INTO ls_cust
       WITH KEY wo_option   = 'AUSBUCHUNG'
                wo_category = 'MAHNSP'
                wo_field    = 'LOCKR'.

  IF sy-subrc = 0.
    lf_lockr = ls_cust-wo_value.
  ENDIF.

  LOOP AT gt_tc_fkkop INTO ls_tc_fkkop.

    CLEAR ls_wo_mon.
    MOVE-CORRESPONDING ls_tc_fkkop TO ls_wo_mon.

    SELECT SINGLE * FROM dfkkko
           INTO ls_dfkkko
           WHERE opbel = ls_tc_fkkop-opbel.

    IF sy-subrc = 0.
      ls_wo_mon-herkf = ls_dfkkko-herkf.
      ls_wo_mon-blart = ls_dfkkko-blart.
    ENDIF.

    ls_wo_mon-wohkf = lf_wohkf.
    ls_wo_mon-wosta = lf_wosta.
    ls_wo_mon-orgbe = gs_begr-orgbe.
    ls_wo_mon-begru = gs_bgus-begru.

    ls_wo_mon-abgrd        = fs_wo_req-abgrd.
    ls_wo_mon-woigd        = fs_wo_req-woigd.
    ls_wo_mon-wovks        = fs_wo_req-wovks.
    ls_wo_mon-inso_datum   = fs_wo_req-inso_datum.
    ls_wo_mon-inso_akte    = fs_wo_req-inso_akte.
    ls_wo_mon-inso_gericht = fs_wo_req-inso_gericht.
    ls_wo_mon-vgl_betrw    = fs_wo_req-vgl_betrw.

    ls_wo_mon-erdat = sy-datum.
    ls_wo_mon-ernam = sy-uname.
    APPEND ls_wo_mon TO lt_wo_mon.

    MOVE-CORRESPONDING ls_wo_mon TO ls_wo_mon_h.
    ls_wo_mon_h-lfdnr = 1.
    ls_wo_mon_h-aenam = sy-uname.
    ls_wo_mon_h-aedat = sy-datlo.
    ls_wo_mon_h-acptm = sy-timlo.
    APPEND ls_wo_mon_h TO lt_wo_mon_h.

  ENDLOOP.

  CHECK lt_wo_mon[] IS NOT INITIAL.

  CALL FUNCTION '/ADESSO/WO_MON_DB_MODE'
    EXPORTING
      i_mode   = 'I'
    TABLES
      t_wo_mon = lt_wo_mon
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.

  IF sy-subrc = 0.
    INSERT /adesso/wo_mon_h FROM TABLE lt_wo_mon_h
           ACCEPTING DUPLICATE KEYS.
    COMMIT WORK.
    PERFORM save_docu USING fs_wo_req
                            ft_i_text.

    PERFORM save_approvals USING fs_wo_req.

    PERFORM set_mahnsperre USING fs_wo_req
                                 lf_lockr.

    DESCRIBE TABLE ft_tc_fkkop LINES lf_lines.
    WRITE lf_lines TO char(6).
    MESSAGE s034 WITH char(6) fs_wo_req-vkont.

  ELSE.
    ROLLBACK WORK.
    MESSAGE e035 WITH fs_wo_req-vkont.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_ITEMS
*&---------------------------------------------------------------------*
FORM select_items  USING    fs_wo_req   STRUCTURE /adesso/wo_req
                   CHANGING ft_tc_fkkop LIKE gt_tc_fkkop.

  DATA: lt_fkkop TYPE TABLE OF fkkop.
  DATA: ls_fkkop TYPE fkkop.
  DATA: ls_tc_fkkop TYPE /adesso/wo_fkkcoll.
  DATA: lf_count LIKE sy-dbcnt.

  REFRESH: ft_tc_fkkop.

  CALL FUNCTION 'FKK_BP_LINE_ITEMS_SELECT'
    EXPORTING
      i_vkont  = fs_wo_req-vkont
      ix_vkont = 'X'
      i_gpart  = fs_wo_req-gpart
      ix_gpart = 'X'
      i_augst  = ' '
      ix_augst = 'X'
    IMPORTING
      e_count  = lf_count
    TABLES
      pt_fkkop = lt_fkkop.

  IF lf_count = 0.
    MESSAGE s030.
  ELSE.
    LOOP AT lt_fkkop INTO ls_fkkop.
      CLEAR ls_tc_fkkop.
      MOVE-CORRESPONDING ls_fkkop TO ls_tc_fkkop.
      APPEND ls_tc_fkkop TO ft_tc_fkkop.
    ENDLOOP.
  ENDIF.
  SORT ft_tc_fkkop BY hvorg DESCENDING.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_ITEMS_VKONT
*&---------------------------------------------------------------------*
FORM check_items_vkont  USING    fs_wo_req   STRUCTURE /adesso/wo_req
                        CHANGING ft_tc_fkkop LIKE gt_tc_fkkop.

  DATA: ls_tc_fkkop TYPE /adesso/wo_fkkcoll.

  READ TABLE ft_tc_fkkop
       WITH KEY vkont = fs_wo_req-vkont
       TRANSPORTING NO FIELDS.

  IF sy-subrc NE 0.
    PERFORM select_items USING fs_wo_req
                         CHANGING ft_tc_fkkop.

    IF okcode = 'WOREQ'.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel        = TEXT-inf
          textline1    = TEXT-002
          textline2    = TEXT-003
          start_column = 25
          start_row    = 6.
      okcode = 'ENTR'.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SAVE_DOCU
*&---------------------------------------------------------------------*
FORM save_docu  USING fs_wo_req STRUCTURE /adesso/wo_req
                      ft_i_text LIKE gt_i_text.

  DATA: ls_cust     TYPE /adesso/wo_cust.
  DATA  ls_text     LIKE gs_text.
  DATA: lt_text     TYPE catsxt_longtext_itab,
*        ls_text     TYPE txline,
        lt_head     TYPE TABLE OF thead,
        ls_head     TYPE thead,
        ls_line     TYPE tline,
        lt_line     TYPE TABLE OF tline,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        lv_pattern  TYPE char30,
        lv_select   TYPE char30,
        lv_object   TYPE tdobject,
        lv_id       TYPE tdid.

  CLEAR ls_cust.
  READ TABLE gt_cust INTO ls_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'OBJECT'
             wo_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_cust-wo_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_cust.
  READ TABLE gt_cust INTO ls_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'DOCU'
             wo_field    = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_cust-wo_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  LOOP AT ft_i_text INTO ls_text.
    MOVE ls_text TO ls_line-tdline.
    APPEND ls_line TO lt_line.
  ENDLOOP.

  CONCATENATE fs_wo_req-gpart
              '_'
              fs_wo_req-vkont
              '_'
              INTO lv_pattern.

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
  ls_head-tdid     = lv_id.
  ls_head-tdspras  = sy-langu.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = ls_head
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

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_MAHNSPERRE
*&---------------------------------------------------------------------*
FORM set_mahnsperre  USING fs_wo_req STRUCTURE /adesso/wo_req
                           ff_lockr.

  DATA: lv_loobj1 LIKE dfkklocks-loobj1.

* Schon Mahnsperre auf VK vorhanden, dann vorher löschen
  PERFORM del_mahnsperre  USING fs_wo_req-gpart
                                fs_wo_req-vkont.

* Dann Mahnsperre setzen
  CONCATENATE fs_wo_req-vkont fs_wo_req-gpart INTO lv_loobj1.

  CALL FUNCTION 'FKK_S_LOCK_CREATE'
    EXPORTING
      i_loobj1              = lv_loobj1
      i_gpart               = fs_wo_req-gpart
      i_vkont               = fs_wo_req-vkont
      i_proid               = '01'
      i_lotyp               = '06'
      i_lockr               = ff_lockr
      i_fdate               = sy-datum
      i_tdate               = '99991231'
      i_upd_online          = 'X'
    EXCEPTIONS
      already_exist         = 1
      imp_data_not_complete = 2
      no_authority          = 3
      enqueue_lock          = 4
      wrong_data            = 5
      OTHERS                = 6.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DEL_MAHNSPERRE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_OUT_VKONT  text
*----------------------------------------------------------------------*
FORM del_mahnsperre  USING pv_gpart
                           pv_vkont.

  DATA: lt_locks  TYPE  dfkklocks_t.
  DATA: ls_locks  TYPE  dfkklocks.

  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
    EXPORTING
      iv_vkont = pv_vkont
      iv_gpart = pv_gpart
      iv_date  = sy-datum
      iv_proid = '01'
    IMPORTING
      et_locks = lt_locks.

* Alle derzeitige Mahnsperre löschen
  LOOP AT lt_locks INTO ls_locks
       WHERE lotyp = '06'
       AND   proid = '01'.

    CALL FUNCTION 'FKK_S_LOCK_DELETE'
      EXPORTING
        i_loobj1 = ls_locks-loobj1
        i_gpart  = ls_locks-gpart
        i_vkont  = ls_locks-vkont
        i_proid  = ls_locks-proid
        i_lotyp  = ls_locks-lotyp
        i_lockr  = ls_locks-lockr
        i_fdate  = ls_locks-fdate
        i_tdate  = ls_locks-tdate
      EXCEPTIONS
        OTHERS   = 7.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_VKONT_DFKKCOLL
*&---------------------------------------------------------------------*
FORM check_vkont_dfkkcoll  USING fs_wo_req STRUCTURE /adesso/wo_req.

*  Prüfen, ob Abgabe Inkasso
  SELECT SINGLE @abap_true FROM dfkkcoll
     WHERE gpart = @fs_wo_req-gpart
     AND   vkont = @fs_wo_req-vkont
     INTO  @DATA(exists).

  IF exists = abap_true.
    MESSAGE e031 WITH fs_wo_req-vkont.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_VKONT_WOMON
*&---------------------------------------------------------------------*
FORM check_vkont_womon  USING fs_wo_req STRUCTURE /adesso/wo_req.

*  Prüfen, ob im AMonitor Ausbuchung
  SELECT SINGLE @abap_true FROM /adesso/wo_mon
     WHERE gpart = @fs_wo_req-gpart
     AND   vkont = @fs_wo_req-vkont
     INTO  @DATA(exists).

  IF exists = abap_true.
    MESSAGE e032 WITH fs_wo_req-vkont.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SAVE_APPROVALS
*&---------------------------------------------------------------------*
FORM save_approvals  USING fs_wo_req STRUCTURE /adesso/wo_req.

  DATA: ls_cust     TYPE /adesso/wo_cust.
  DATA: ls_text     LIKE gs_text,
        lt_head     TYPE TABLE OF thead,
        ls_head     TYPE thead,
        ls_line     TYPE tline,
        lt_line     TYPE TABLE OF tline,
        ls_stxh     TYPE stxh,
        lt_stxh     TYPE TABLE OF stxh,
        lv_lfdnr(3) TYPE n,
        lv_pattern  TYPE char30,
        lv_select   TYPE char30,
        lv_object   TYPE tdobject,
        lv_id       TYPE tdid.

  CLEAR ls_cust.
  READ TABLE gt_cust INTO ls_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'OBJECT'
             wo_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_cust-wo_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_cust.
  READ TABLE gt_cust INTO ls_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'APPROVAL'
             wo_field    = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_cust-wo_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  ls_line-tdline = TEXT-anf.
  APPEND ls_line TO lt_line.

  CONCATENATE fs_wo_req-gpart
              '_'
              fs_wo_req-vkont
              '_'
              INTO lv_pattern.

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
  ls_head-tdid     = lv_id.
  ls_head-tdspras  = sy-langu.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client   = sy-mandt
      header   = ls_head
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

ENDFORM.
