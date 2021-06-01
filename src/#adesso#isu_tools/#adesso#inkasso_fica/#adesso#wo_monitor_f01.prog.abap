*----------------------------------------------------------------------*
***INCLUDE /ADESSO/WO_MONITOR_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SELECT_WOMON_REQ
*&---------------------------------------------------------------------*
FORM select_womon_req .

  DATA: ls_wo_cust  TYPE /adesso/wo_cust.
  DATA: lf_wohkf    TYPE /adesso/wo_wohkf.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'AUSBUCHUNG'
             wo_category = 'HERKUNFT'
             wo_field    = 'WOHKF'.

  IF sy-subrc = 0.
    lf_wohkf = ls_wo_cust-wo_value.
  ELSE.
    lf_wohkf = 'REQ'.
  ENDIF.


  REFRESH gr_wosta.
  CLEAR gs_wosta.
  gs_wosta-option = 'EQ'.
  gs_wosta-sign   = 'I'.

* Vormerkung Ausbuchung
  IF p_vorm = const_marked.
    gs_wosta-low = const_wosta_vorm.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Zur Korrektur / Prüfung
  IF p_ilook = const_marked.
    gs_wosta-low = const_wosta_look.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Genehmigung 1
  IF p_frei1 = const_marked.
    gs_wosta-low = const_wosta_frei1.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Genehmigt
  IF p_frei2 = const_marked.
    gs_wosta-low = const_wosta_frei2.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Abgelehnt
  IF p_decl = const_marked.
    gs_wosta-low = const_wosta_decl.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Ausgebucht
  IF p_opwo = const_marked.
    gs_wosta-low = const_wosta_opwo.
    APPEND gs_wosta TO gr_wosta.
    gr_abdat[] = so_abdat[].
  ENDIF.

  CHECK gr_wosta[] IS NOT INITIAL.

  REFRESH gt_gpvk.
  SELECT wo~gpart wo~vkont
         INTO  TABLE gt_gpvk
         FROM /adesso/wo_mon AS wo
         WHERE gpart IN so_gpart
         AND   vkont IN so_vkont
         AND   abgrd IN so_abgrd
         AND   woigd IN so_woigd
         AND   abdat IN gr_abdat
         AND   hvorg IN gr_hvorg
         AND   wovks IN gr_vks
         AND   wosta IN gr_wosta
         AND   wohkf =  lf_wohkf.

  SORT gt_gpvk.
  DELETE ADJACENT DUPLICATES FROM gt_gpvk.

  CHECK gt_gpvk[] IS NOT INITIAL.


  SELECT * FROM /adesso/wo_mon
    FOR ALL ENTRIES IN @gt_gpvk
    WHERE gpart =  @gt_gpvk-gpart
    AND   vkont =  @gt_gpvk-vkont
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.

** Vormerkung Ausbuchung
*  IF p_vorm = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_vorm
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Genehmigung 1
*  IF p_frei1 = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_frei1
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Genehmigt
*  IF p_frei2 = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_frei2
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Abgelehnt
*  IF p_decl = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_decl
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Ausgebucht
*  IF p_opwo = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_opwo
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_WOMON_INK
*&---------------------------------------------------------------------*
FORM select_womon_ink .

  DATA: ls_wo_cust  TYPE /adesso/wo_cust.
  DATA: lf_wohkf    TYPE /adesso/wo_wohkf.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INKASSO'
             wo_category = 'HERKUNFT'
             wo_field    = 'WOHKF'.

  IF sy-subrc = 0.
    lf_wohkf = ls_wo_cust-wo_value.
  ELSE.
    lf_wohkf = 'INK'.
  ENDIF.

  REFRESH gr_wosta.
  CLEAR gs_wosta.
  gs_wosta-option = 'EQ'.
  gs_wosta-sign   = 'I'.

* Zur Korrektur / Prüfung
  IF p_ilook = const_marked.
    gs_wosta-low = const_wosta_look.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Bereit zur Genehmigung
  IF p_iready = const_marked.
    gs_wosta-low = const_wosta_ready.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Genehmigung 1
  IF p_ifrei1 = const_marked.
    gs_wosta-low = const_wosta_frei1.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Genehmigt
  IF p_ifrei2 = const_marked.
    gs_wosta-low = const_wosta_frei2.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Abgelehnt
  IF p_idecl = const_marked.
    gs_wosta-low = const_wosta_decl.
    APPEND gs_wosta TO gr_wosta.
  ENDIF.

* Ausgebucht
  IF p_iopwo = const_marked.
    gs_wosta-low = const_wosta_opwo.
    APPEND gs_wosta TO gr_wosta.
    gr_abdat[] = so_abdat[].
  ENDIF.

  CHECK gr_wosta[] IS NOT INITIAL.

  REFRESH gt_gpvk.
  SELECT wo~gpart wo~vkont
         INTO TABLE gt_gpvk
         FROM /adesso/wo_mon AS wo
         WHERE gpart IN so_gpart
         AND   vkont IN so_vkont
         AND   abgrd IN so_abgrd
         AND   abdat IN gr_abdat
         AND   woigd IN so_woigd
         AND   hvorg IN gr_hvorg
         AND   wovks IN gr_vks
         AND   wosta IN gr_wosta
         AND   wohkf =  lf_wohkf.

  SORT gt_gpvk.
  DELETE ADJACENT DUPLICATES FROM gt_gpvk.

  CHECK gt_gpvk[] IS NOT INITIAL.


  SELECT * FROM /adesso/wo_mon
    FOR ALL ENTRIES IN @gt_gpvk
    WHERE gpart =  @gt_gpvk-gpart
    AND   vkont =  @gt_gpvk-vkont
    APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.

** Prüfung Gerichtlich
*  IF p_ilook = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_look
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Bereit zur Genehmigung
*  IF p_iready = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_ready
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Genehmigung 1
*  IF p_ifrei1 = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_frei1
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Genehmigt
*  IF p_ifrei2 = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_frei2
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Abgelehnt
*  IF p_idecl = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_decl
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.
*
** Ausgebucht
*  IF p_iopwo = const_marked.
*    SELECT * FROM /adesso/wo_mon
*      FOR ALL ENTRIES IN @gt_gpvk
*      WHERE gpart =  @gt_gpvk-gpart
*      AND   vkont =  @gt_gpvk-vkont
*      AND   wosta =  @const_wosta_opwo
*      AND   wohkf =  @lf_wohkf
*      AND   abgrd IN @so_abgrd
*      AND   woigd IN @so_woigd
*      APPENDING CORRESPONDING FIELDS OF TABLE @gt_wo_out.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
FORM f4_for_variant CHANGING ff_variant TYPE disvariant-variant.

  PERFORM alv_variant_init.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = g_variant
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      ff_variant = gx_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.

*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
*    ........
*-----------------------------------------------------------------------
*    --> extab
*-----------------------------------------------------------------------
FORM standard_wo USING extab TYPE slis_t_extab.

  DATA: fcodes TYPE LINE OF slis_t_extab.

*  LOOP AT gt_bgss INTO gs_bgss
*       WHERE begru    = gs_bgus-begru
*       AND   bgcat_ss = 'EXCL_FKT'
*       AND   inactiv  = const_marked.
*
*    CLEAR fcodes.
*    fcodes-fcode = gs_bgss-bgfld_ss.
*    APPEND fcodes TO extab.
*
*  ENDLOOP.

  SET PF-STATUS g_status EXCLUDING extab.

ENDFORM.                    "status_standard

*&---------------------------------------------------------------------*
*&      Form  GET_APPROVALS
*&---------------------------------------------------------------------*
FORM get_approvals TABLES ft_lines STRUCTURE tline
                   USING  ff_vkont
                          ff_gpart.

  DATA: ls_wo_cust TYPE /adesso/wo_cust.  "Customizing allgemein
  DATA: ls_pattern TYPE char30,
        ls_select  TYPE char30,
        ls_stxh    TYPE stxh,
        lt_stxh    TYPE TABLE OF stxh,
        lt_thead   TYPE TABLE OF thead,
        ls_thead   TYPE thead,
        lt_text_lh TYPE text_lh,
        ls_text_lh TYPE itclh,
        ls_lines   TYPE tline,
        lt_lines   TYPE TABLE OF tline,
        lv_object  TYPE thead-tdobject,
        lv_id      TYPE thead-tdid,
        lv_date    TYPE char10,
        lv_time    TYPE char8,
        ls_user    TYPE user_addr.

*   Interne Vermerke
  CLEAR: ls_pattern, ls_select, ls_stxh, lt_stxh.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'OBJECT'
             wo_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_object.
  ENDIF.


  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'APPROVAL'
             wo_field    = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_id.
  ENDIF.

  CONCATENATE ff_gpart
              '_'
              ff_vkont
              '_'
              INTO ls_pattern.

  CONCATENATE ls_pattern '%' INTO ls_select.

  REFRESH: lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND   tdname   LIKE ls_select
           AND   tdid     = lv_id
           AND   tdspras  = sy-langu.

  LOOP AT lt_stxh INTO ls_stxh.
    MOVE-CORRESPONDING ls_stxh TO ls_thead.
    APPEND ls_thead TO lt_thead.
    CLEAR ls_thead.
  ENDLOOP.

  CALL FUNCTION 'READ_TEXT_TABLE'
    IMPORTING
      text_table              = lt_text_lh
    TABLES
      text_headers            = lt_thead
    EXCEPTIONS
      wrong_access_to_archive = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SORT lt_text_lh BY header-tdname DESCENDING.

  APPEND INITIAL LINE TO lt_lines.
  ls_lines-tdformat = '/'.
  ls_lines-tdline = TEXT-007.
  APPEND ls_lines TO lt_lines.
  ls_lines-tdline = TEXT-uli.
  APPEND ls_lines TO lt_lines.

  LOOP AT lt_text_lh INTO ls_text_lh.

    CALL FUNCTION 'FKK_GET_USER_NAME'
      EXPORTING
        i_uname     = ls_text_lh-header-tdfuser
      IMPORTING
        e_user_addr = ls_user.

*   Datum Formatieren
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_text_lh-header-tdfdate
      IMPORTING
        date_external            = lv_date
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*   Zeit umformatieren
    CONCATENATE ls_text_lh-header-tdftime(2)
                ':'
                ls_text_lh-header-tdftime+2(2)
                ':'
                ls_text_lh-header-tdftime+4(2)
                INTO lv_time.

    CONCATENATE ls_user-name_textc
                lv_date
                lv_time
                INTO ls_lines-tdline
                SEPARATED BY space.

    ls_lines-tdformat = '/'.
    APPEND ls_lines TO lt_lines.

*   Texte einlesen
    LOOP AT ls_text_lh-lines INTO ls_lines.
      ls_lines-tdformat = '/'.
      APPEND ls_lines TO lt_lines.
    ENDLOOP.
  ENDLOOP.

  APPEND LINES OF lt_lines TO ft_lines.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMIZING
*&---------------------------------------------------------------------*
FORM get_customizing .

  DATA: ls_wo_vks TYPE /adesso/wo_vks.     "Verkaufsquote
*  DATA: gs_vks    LIKE LINE OF gr_vks.
*  DATA: gs_hvorg  LIKE LINE OF gr_hvorg.
*  DATA: gs_nfhf   TYPE /adesso/ink_nfhf.   "Hauptvorgänge SR/HF/NF

  IF gt_wo_cust IS INITIAL.
    SELECT * FROM /adesso/wo_cust INTO TABLE gt_wo_cust.
  ENDIF.

  IF gt_ink_cust IS INITIAL.
    SELECT * FROM /adesso/ink_cust INTO TABLE gt_ink_cust.
  ENDIF.

  IF gt_wo_vks IS INITIAL.
    SELECT * FROM /adesso/wo_vks INTO TABLE gt_wo_vks.
  ENDIF.

  IF gt_nfhf IS INITIAL.
    SELECT * FROM /adesso/ink_nfhf INTO TABLE gt_nfhf.
  ENDIF.

  IF gt_vkst IS INITIAL.
    SELECT * FROM /adesso/wo_vkst INTO TABLE gt_vkst.
  ENDIF.

  IF gt_igrdt IS INITIAL.
    SELECT * FROM /adesso/wo_igrdt INTO TABLE gt_igrdt.
  ENDIF.

  IF gt_tfk048at IS INITIAL.
    SELECT * FROM tfk048at INTO TABLE gt_tfk048at.
  ENDIF.

  REFRESH gr_vks.
  CLEAR gs_vks.
  gs_vks-option = 'EQ'.
  gs_vks-sign   = 'I'.

* Interne Ausbuchungen
  IF p_intwo = const_marked.
*   Als erstes Eintrag für VKS = leer (Space)
    gs_vks-low    = space.
    APPEND gs_vks TO gr_vks.
    LOOP AT gt_wo_vks INTO ls_wo_vks
         WHERE woprz IS INITIAL.
      gs_vks-low    = ls_wo_vks-wovks.
      APPEND gs_vks TO gr_vks.
    ENDLOOP.
  ENDIF.

* Verkäufe
  LOOP AT gt_wo_vks INTO ls_wo_vks
       WHERE woprz IS NOT INITIAL.
    gs_vks-low    = ls_wo_vks-wovks.
    APPEND gs_vks TO gr_vks_sell.
    IF p_selwo = const_marked.
      APPEND gs_vks TO gr_vks.
    ENDIF.
  ENDLOOP.

  REFRESH gr_hvorg.
  CLEAR gs_hvorg.
  gs_hvorg-option = 'EQ'.
  gs_hvorg-sign   = 'I'.
  LOOP AT gt_nfhf INTO gs_nfhf
       WHERE schlr = const_marked.
    gs_hvorg-low    = gs_nfhf-hvorg.
    APPEND gs_hvorg TO gr_hvorg.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_STATUS_ICON
*&---------------------------------------------------------------------*
FORM set_status_icon  USING fp_agsta
                            fp_status.

  CASE fp_agsta.

* Vorgemerkt
    WHEN '01'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_SET_STATE'
          info                  = TEXT-s01
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*   Erneut prüfen
    WHEN '02'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_ACTION_FAULT'
          info                  = TEXT-s02
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*   Geprüft
    WHEN '03'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_AVAILABILITY_CHECK'
          info                  = TEXT-s03
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


* Bereit zur Genehmigung
    WHEN '10'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_INITIAL'
          info                  = TEXT-s10
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*   Genehmigung 1
    WHEN '11'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_COMPLETE'
          info                  = TEXT-s11
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*   Genehmigt
    WHEN '12'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_RELEASE'
          info                  = TEXT-s12
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*   Genehmigung Abgelehnt
    WHEN '13'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_DEFECT'
          info                  = TEXT-s13
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*   Ausgebucht
    WHEN '20'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_REVERSE'
          info                  = TEXT-s20
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


* Abgabestatus aus InkMon
    WHEN 'A20'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_STATUS_REVERSE'
          info                  = TEXT-a20
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'A30'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_ALLOW'
          info                  = TEXT-a30
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'A31'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_REJECT'
          info                  = TEXT-a31
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'A32'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_REJECT'
          info                  = TEXT-a32
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN '  '.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LED_GREEN'
          info                  = TEXT-agl
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'AG'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_WF_WORKITEM_OL'
          info                  = TEXT-agl
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'DOCU'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_TEXT_ACT'
          info                  = TEXT-act
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'NODOCU'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_TEXT_INA'
          info                  = TEXT-ina
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'ERR'.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name                  = 'ICON_LED_RED'
          info                  = TEXT-err
        IMPORTING
          result                = fp_status
        EXCEPTIONS
          icon_not_found        = 1
          outputfield_too_short = 2
          OTHERS                = 3.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*       --> R_UCOMM                                                   *
*       --> RS_SELFIELD                                               *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

* Daten im ALV aktualisieren (wichtig für das Selektionsfeld)
  DATA: rev_alv TYPE REF TO cl_gui_alv_grid.

  DATA: gv_gplocked(1) TYPE c.

  DATA: lv_gpart TYPE gpart_kk,
        lv_vkont TYPE vkont_kk,
        lv_opbel TYPE opbel_kk,
        lv_inkgp TYPE inkgp_kk,
        lv_abbel TYPE abbel_kk.

  rs_selfield-refresh = 'X'.
  rs_selfield-col_stable = 'X'.
  rs_selfield-row_stable = 'X'.

  CLEAR: gs_items, gs_header.
  CASE rs_selfield-tabname.

    WHEN 'GT_HEADER'.
      READ TABLE gt_header INTO gs_header
           INDEX rs_selfield-tabindex.
      lv_gpart = gs_header-gpart.
      lv_vkont = gs_header-vkont.
      lv_inkgp = gs_header-inkgp.

    WHEN 'GT_ITEMS'.
      READ TABLE gt_items INTO gs_items
           INDEX rs_selfield-tabindex.
      lv_gpart = gs_items-gpart.
      lv_vkont = gs_items-vkont.
      lv_opbel = gs_items-opbel.
      lv_abbel = gs_items-abbel.

  ENDCASE.

  CASE r_ucomm.

    WHEN 'DOCU'.
      LOOP AT gt_header INTO gs_header WHERE sel IS NOT INITIAL.

* VK für Bearbeitung gesperrt ?
        IF gs_header-locked IS NOT INITIAL.
          CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
            EXPORTING
              titel     = TEXT-inf
              textline1 = TEXT-e01
              textline2 = TEXT-e02.
        ENDIF.

        PERFORM ucom_edit_docu USING gs_header-gpart
                                     gs_header-vkont
                                     gs_header-ic_docu.

        MODIFY gt_header FROM gs_header TRANSPORTING ic_docu.
        EXIT.
      ENDLOOP.

    WHEN 'ALLOW'.

*   Prüfen Berechtigung für Funktion
*      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
*      IF lv_subrc NE 0.
*        lv_text1 = TEXT-f01.
*        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*            titel     = TEXT-err
*            textline1 = lv_text1
*            textline2 = TEXT-e03.
*        RETURN.
*      ENDIF.

      PERFORM ucom_allow  USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e01
            textline2 = TEXT-e02.
      ENDIF.

    WHEN 'CORRECT'.

*   Prüfen Berechtigung für Funktion
*      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
*      IF lv_subrc NE 0.
*        lv_text1 = TEXT-f01.
*        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*            titel     = TEXT-err
*            textline1 = lv_text1
*            textline2 = TEXT-e03.
*        RETURN.
*      ENDIF.

      PERFORM ucom_correct  USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e01
            textline2 = TEXT-e02.
      ENDIF.

    WHEN 'DECL'.

*   Prüfen Berechtigung für Funktion
*      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
*      IF lv_subrc NE 0.
*        lv_text1 = TEXT-f01.
*        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*            titel     = TEXT-err
*            textline1 = lv_text1
*            textline2 = TEXT-e03.
*        RETURN.
*      ENDIF.

      PERFORM ucom_decl USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e01
            textline2 = TEXT-e02.
      ENDIF.

    WHEN 'WROFF'.

*   Prüfen Berechtigung für Funktion
*      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
*      IF lv_subrc NE 0.
*        lv_text1 = TEXT-f01.
*        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*            titel     = TEXT-err
*            textline1 = lv_text1
*            textline2 = TEXT-e03.
*        RETURN.
*      ENDIF.

      AUTHORITY-CHECK OBJECT 'F_KKWOFF' ID 'ACTVT' FIELD '10'.
      IF sy-subrc NE 0.
        MESSAGE e459(>3).
      ENDIF.

      PERFORM ucom_wroff USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e01
            textline2 = TEXT-e02.
      ENDIF.

    WHEN 'STORNO'.

*   Prüfen Berechtigung für Funktion
*      PERFORM check_auth_for_ucomm USING r_ucomm lv_subrc.
*      IF lv_subrc NE 0.
*        lv_text1 = TEXT-f01.
*        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
*          EXPORTING
*            titel     = TEXT-err
*            textline1 = lv_text1
*            textline2 = TEXT-e03.
*        RETURN.
*      ENDIF.

      PERFORM ucom_storno USING r_ucomm gv_gplocked.

*   Wenn VK gesperrt (Bearbeitung durch anderen User) Meldung
      IF gv_gplocked = 'X'.
        CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
          EXPORTING
            titel     = TEXT-inf
            textline1 = TEXT-e01
            textline2 = TEXT-e02.
      ENDIF.

    WHEN 'BALANCE'.

      LOOP AT gt_header INTO gs_header WHERE sel IS NOT INITIAL.

        PERFORM ucom_get_kontenstand USING gs_header.

        EXIT.

      ENDLOOP.
      IF sy-subrc NE 0.
        MESSAGE e002.
      ENDIF.

    WHEN 'CIC'.


      LOOP AT gt_header INTO gs_header WHERE sel IS NOT INITIAL.

        PERFORM ucom_get_cic USING gs_header-vkont.

        EXIT.

      ENDLOOP.

      IF sy-subrc NE 0.
        MESSAGE e002.
      ENDIF.

    WHEN OTHERS.
*
      CASE rs_selfield-fieldname.

        WHEN 'GPART'.
          IF lv_gpart IS NOT INITIAL.
            SET PARAMETER ID 'BPA'  FIELD lv_gpart.
            CALL TRANSACTION 'FPP3'.
          ENDIF.

        WHEN 'VKONT'.
          GET CURSOR LINE sy-tabix.
          PERFORM uc_view_vkont USING  lv_vkont
                                       lv_gpart.

        WHEN 'OPBEL'.
          IF lv_opbel IS NOT INITIAL.
            SET PARAMETER ID '80B' FIELD  lv_opbel.
            CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.
          ENDIF.

        WHEN 'INKGP'.
          IF lv_inkgp IS NOT INITIAL.
            SET PARAMETER ID 'BPA' FIELD  lv_inkgp.
            CALL TRANSACTION 'FPP3'.
          ENDIF.

        WHEN 'INTVERM'.

          PERFORM uc_display_approval USING lv_vkont
                                            lv_gpart.

        WHEN 'IC_DOCU'.

          PERFORM uc_display_docu USING lv_vkont
                                        lv_gpart.

* Ausbuchungsbeleg
        WHEN 'ABBEL'.
          IF lv_abbel IS NOT INITIAL.
            SET PARAMETER ID '80B' FIELD  lv_abbel.
            CALL TRANSACTION 'FPE3' AND SKIP FIRST SCREEN.
          ENDIF.

      ENDCASE.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARE_OUTPUT
*&---------------------------------------------------------------------*
FORM prepare_output .

  DATA: ls_header  TYPE /adesso/wo_header.
  DATA: ls_items   TYPE /adesso/wo_items.
  DATA: ls_dfkkop  TYPE dfkkop.
  DATA: ls_eadrdat TYPE eadrdat.
  DATA: lv_opbetrw TYPE betrw_kk.
  DATA: lv_wobetrw TYPE betrw_kk.
  DATA: lv_h_agsta(3).

  DATA: lt_wheretab TYPE TABLE OF sdit_qry.
  DATA: ls_wheretab TYPE sdit_qry.
  DATA: lt_logfkkop TYPE STANDARD TABLE OF sfkkop.
  DATA: ls_logfkkop TYPE sfkkop.

  FIELD-SYMBOLS: <gs_wo_out> TYPE /adesso/wo_out.

  SORT gt_wo_out BY gpart vkont hvorg ASCENDING faedn DESCENDING.

  REFRESH lt_wheretab.
  ls_wheretab = 'AUGST EQ '''''.
  APPEND ls_wheretab TO lt_wheretab.

  LOOP AT gt_wo_out ASSIGNING <gs_wo_out>.

    AT NEW vkont.
      CLEAR: ls_header.
      CLEAR: lv_opbetrw.
      CLEAR: lv_wobetrw.

* Nachlesen, alle OPs
      REFRESH lt_logfkkop.
      CALL FUNCTION 'FKK_LINE_ITEMS_SELECT_LOGICAL'
        EXPORTING
          i_vkont     = <gs_wo_out>-vkont
          i_gpart     = <gs_wo_out>-gpart
        TABLES
          pt_logfkkop = lt_logfkkop
          pt_wheretab = lt_wheretab.
      SORT lt_logfkkop.
    ENDAT.

**   Summe pro VK ermitteln
*    lv_betrw = lv_betrw + <gs_wo_out>-betrw.

*   OP vorhanden, dann nicht neu und löschen
    DELETE lt_logfkkop
           WHERE opbel = <gs_wo_out>-opbel
           AND   opupw = <gs_wo_out>-opupw
           AND   opupk = <gs_wo_out>-opupk
           AND   opupz = <gs_wo_out>-opupz.

    PERFORM enrich_wo_out USING <gs_wo_out> lv_opbetrw lv_wobetrw.

    CLEAR gs_items.
    MOVE-CORRESPONDING <gs_wo_out> TO gs_items.
    APPEND gs_items TO gt_items.

    AT END OF vkont.

      CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
        EXPORTING
          x_address_type             = 'B'
          x_partner                  = <gs_wo_out>-gpart
        IMPORTING
          y_eadrdat                  = ls_eadrdat
        EXCEPTIONS
          not_found                  = 1
          parameter_error            = 2
          object_not_given           = 3
          address_inconsistency      = 4
          installation_inconsistency = 5
          OTHERS                     = 6.
      IF sy-subrc <> 0.
        CLEAR ls_eadrdat.
      ENDIF.

      <gs_wo_out>-name1 = ls_eadrdat-name1.
      <gs_wo_out>-name2 = ls_eadrdat-name2.

      PERFORM get_last_approval
              USING  <gs_wo_out>-vkont
                     <gs_wo_out>-gpart
                     <gs_wo_out>-intverm.

      PERFORM check_docu_exists
              USING  <gs_wo_out>-vkont
                     <gs_wo_out>-gpart
                     <gs_wo_out>-ic_docu.

      PERFORM get_lockr_vk
              USING  <gs_wo_out>-vkont
                     <gs_wo_out>-gpart
                     <gs_wo_out>-lockr.

      CONCATENATE 'A' <gs_wo_out>-agsta INTO lv_h_agsta.
      PERFORM set_status_icon
              USING lv_h_agsta
                    <gs_wo_out>-ic_agsta.

      CLEAR gs_header.
      MOVE-CORRESPONDING <gs_wo_out> TO gs_header.

      IF lv_opbetrw = 0.
        gs_header-betrw = lv_wobetrw.
      ELSE.
*     nur wenn noch etwas offen, wenn neue OPs vorhanden, dann hinzufügen
        LOOP AT lt_logfkkop INTO ls_logfkkop.
          MOVE-CORRESPONDING ls_logfkkop TO <gs_wo_out>.
          PERFORM enrich_wo_out USING <gs_wo_out> lv_opbetrw lv_wobetrw.
          CLEAR <gs_wo_out>-wosta.
          PERFORM set_status_icon
                  USING <gs_wo_out>-wosta <gs_wo_out>-status.
          CLEAR gs_items.
          MOVE-CORRESPONDING <gs_wo_out> TO gs_items.
          APPEND gs_items TO gt_items.
        ENDLOOP.
        gs_header-betrw = lv_opbetrw.
      ENDIF.
      APPEND gs_header TO gt_header.

    ENDAT.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_LOCKR_VK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_lockr_vk  USING ff_vkont
                         ff_gpart
                         ff_lockr.

  DATA: lt_locks  TYPE  dfkklocks_t.
  DATA: ls_locks  TYPE  dfkklocks.

*   Prüfen Mahnsperre im VK
  CLEAR ls_locks.
  REFRESH lt_locks.
  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
    EXPORTING
      iv_vkont = ff_vkont
      iv_gpart = ff_gpart
      iv_date  = sy-datum
      iv_proid = '01'
    IMPORTING
      et_locks = lt_locks.

  DELETE lt_locks  WHERE lotyp NE '06'.
  READ TABLE lt_locks INTO ls_locks INDEX 1.
  IF sy-subrc NE 0.
    CLEAR ls_locks.
  ENDIF.

  ff_lockr = ls_locks-lockr.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  UPDATE_WOMON_WOHIST
*&---------------------------------------------------------------------*
FORM update_womon_wohist  USING fs_wo_mon   TYPE /adesso/wo_mon
                                fs_wo_mon_h TYPE /adesso/wo_mon_h
                                fv_rc.

  DATA: lt_wo_mon TYPE TABLE OF /adesso/wo_mon.
  DATA: h_lfdnr   LIKE /adesso/wo_mon_h-lfdnr.

  APPEND fs_wo_mon TO lt_wo_mon.
  CHECK lt_wo_mon[] IS NOT INITIAL.

  CALL FUNCTION '/ADESSO/WO_MON_DB_MODE'
    EXPORTING
      i_mode   = 'U'
    TABLES
      t_wo_mon = lt_wo_mon
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.

  IF sy-subrc = 0.

    SELECT MAX( lfdnr ) FROM /adesso/wo_mon_h
           INTO h_lfdnr
           WHERE opbel = fs_wo_mon-opbel
           AND   opupw = fs_wo_mon-opupw
           AND   opupk = fs_wo_mon-opupk
           AND   opupz = fs_wo_mon-opupz.

    ADD 1 TO h_lfdnr.

    fs_wo_mon_h-lfdnr = h_lfdnr.
    fs_wo_mon_h-aenam = sy-uname.
    fs_wo_mon_h-aedat = sy-datlo.
    fs_wo_mon_h-acptm = sy-timlo.

    INSERT /adesso/wo_mon_h FROM fs_wo_mon_h.
    fv_rc = sy-subrc.

  ELSE.
    fv_rc = sy-subrc.
  ENDIF.


  IF fv_rc = 0.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ENRICH_WO_OUT
*&---------------------------------------------------------------------*
FORM enrich_wo_out  USING fs_wo_out  TYPE /adesso/wo_out
                          ff_opbetrw TYPE betrw_kk
                          ff_wobetrw TYPE betrw_kk.

  DATA: ls_dfkkop  TYPE dfkkop.

*   Text zum Ausbuchungsgrund
  SELECT SINGLE abtxt FROM tfk048at INTO fs_wo_out-abtxt
         WHERE spras = sy-langu
         AND   abgrd = fs_wo_out-abgrd.

*   Text zum internen Ausbuchungsgrund
  SELECT SINGLE woigdt FROM /adesso/wo_igrdt INTO fs_wo_out-woigdt
         WHERE spras = sy-langu
         AND   woigd = fs_wo_out-woigd.

*   Text zur Verkaufsquote
  IF fs_wo_out-wovks = space.
    fs_wo_out-wovkt = TEXT-kvk.
  ELSE.
    SELECT SINGLE wovkt FROM /adesso/wo_vkst INTO fs_wo_out-wovkt
           WHERE spras = sy-langu
           AND   wovks = fs_wo_out-wovks.
  ENDIF.

*   Text Sparte
  IF fs_wo_out-spart IS NOT INITIAL.
    SELECT SINGLE vtext FROM tspat INTO fs_wo_out-vtext
           WHERE spras = sy-langu
           AND   spart = fs_wo_out-spart.
  ENDIF.

*   Text zum Teil-Vorgang
  SELECT SINGLE txt30 FROM tfktvot INTO fs_wo_out-txt30
         WHERE spras = sy-langu
         AND   applk = 'R'
         AND   hvorg = fs_wo_out-hvorg
         AND   tvorg = fs_wo_out-tvorg.

* Prüfung ob noch offen
  SELECT SINGLE * FROM dfkkop
         INTO  CORRESPONDING FIELDS OF ls_dfkkop
         WHERE opbel = fs_wo_out-opbel
         AND   opupw = fs_wo_out-opupw
         AND   opupk = fs_wo_out-opupk
         AND   opupz = fs_wo_out-opupz.

  IF sy-subrc = 0.
    IF ls_dfkkop-augst = '9'.
      CASE ls_dfkkop-augrd.
        WHEN '04' OR '14'.
          SELECT SINGLE abbel abgrd abdat betrw
                 FROM dfkkwoh
                 INTO CORRESPONDING FIELDS OF fs_wo_out
                 WHERE abbel = ls_dfkkop-augbl
                 AND   opbel = fs_wo_out-opbel
                 AND   opupw = fs_wo_out-opupw
                 AND   opupk = fs_wo_out-opupk
                 AND   opupz = fs_wo_out-opupz.
          IF sy-subrc = 0.
            fs_wo_out-augrd = ls_dfkkop-augrd.
            fs_wo_out-augdt = ls_dfkkop-augdt.
            ff_wobetrw = ff_wobetrw + fs_wo_out-betrw.
            PERFORM set_status_icon
                    USING '20' fs_wo_out-status.
          ELSE.
            CLEAR: fs_wo_out-abbel.
            CLEAR: fs_wo_out-abgrd.
            CLEAR: fs_wo_out-abdat.
            fs_wo_out-augrd = ls_dfkkop-augrd.
            fs_wo_out-augdt = ls_dfkkop-augdt.
            fs_wo_out-betrw = ls_dfkkop-betrw.
            PERFORM set_status_icon
                    USING 'AG' fs_wo_out-status.
          ENDIF.
        WHEN OTHERS.
          fs_wo_out-augrd = ls_dfkkop-augrd.
          fs_wo_out-augdt = ls_dfkkop-augdt.
          fs_wo_out-betrw = ls_dfkkop-betrw.
          PERFORM set_status_icon
                  USING 'AG' fs_wo_out-status.
      ENDCASE.
    ELSE.
      ff_opbetrw = ff_opbetrw + ls_dfkkop-betrw.
      PERFORM set_status_icon
              USING fs_wo_out-wosta fs_wo_out-status.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PRE_SELECT
*&---------------------------------------------------------------------*
FORM pre_select.


  SELECT wo~gpart wo~vkont
         APPENDING TABLE gt_gpvk
         FROM /adesso/wo_mon AS wo
         WHERE gpart IN so_gpart
         AND   vkont IN so_vkont
         AND   abgrd IN so_abgrd
         AND   woigd IN so_woigd
         AND   hvorg IN gr_hvorg
         AND   wovks IN gr_vks.

  SORT gt_gpvk.
  DELETE ADJACENT DUPLICATES FROM gt_gpvk.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTACT
*&---------------------------------------------------------------------*
FORM create_contact  USING fs_header TYPE /adesso/wo_header.

  DATA: ls_wo_cust   TYPE /adesso/wo_cust.  "Customizing allgemein
  DATA: lv_auto_data TYPE bpc01_bcontact_auto .
  DATA: lv_object    TYPE bpc_obj.
  DATA: lv_bpcontact TYPE ct_contact.
  DATA: lv_textline  TYPE bpc01_text_line.
  DATA: lv_but000    TYPE but000.
  DATA: lv_inrtxt    TYPE inrtxt_kk.
  DATA: lv_category(5).
  DATA: lv_text(50).
  DATA: ls_lines   TYPE tline.
  DATA: lt_lines   TYPE TABLE OF tline.

  DATA: lv_partner  TYPE but000-partner.
  DATA: lv_vkont    TYPE fkkvkp-vkont .              "Nuss 08.02.2018
  DATA: lv_class    TYPE ct_cclass,
        lv_activity TYPE ct_activit,
        lv_type     TYPE ct_ctype,
        lv_coming   TYPE ct_coming,
        lv_funcc    TYPE funcc_kk.
  DATA: lv_gpname   TYPE bpc01_text_line.

  DATA: ls_vkst     TYPE /adesso/wo_vkst.  "Verkaufsquote Texte
  DATA: ls_igrdt    TYPE /adesso/wo_igrdt. "Int.Ausbuchungsgrund Texte
  DATA: ls_tfk048at TYPE tfk048at.          "Ausbuchungsgrund Texte

  IF fs_header-wovks IN gr_vks_sell.
    lv_category = const_sell.
    lv_text     = TEXT-003.
  ELSE.
    lv_category = const_wroff.
    lv_text     = TEXT-002.
  ENDIF.

* Kontaktklasse
  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'CONTACT'
             wo_category = 'CLASS'
             wo_field    = 'CCLASS'.
  IF sy-subrc = 0.
    lv_class = ls_wo_cust-wo_value.
  ELSE.
    lv_class = '0200'.
  ENDIF.

* Kontakt-Aktivität
  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'CONTACT'
             wo_category = lv_category
             wo_field    = 'ACTIVITY'.
  IF sy-subrc = 0.
    lv_activity = ls_wo_cust-wo_value.
  ELSE.
    lv_activity = '0010'.
  ENDIF.

* Kontakt-Typ
  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'CONTACT'
             wo_category = 'TYPE'
             wo_field    = 'CTYPE'.
  IF sy-subrc = 0.
    lv_type = ls_wo_cust-wo_value.
  ELSE.
    lv_type = '002'.
  ENDIF.

* Richtung
  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'CONTACT'
             wo_category = 'DIRECTION'
             wo_field    = 'F_COMING'.
  IF sy-subrc = 0.
    lv_coming = ls_wo_cust-wo_value.
  ELSE.
    lv_coming = '2'.
  ENDIF.

  CLEAR: lv_auto_data.

  lv_vkont   = fs_header-vkont.
  lv_partner = fs_header-gpart.

  lv_auto_data-bcontd-mandt       = sy-mandt.
  lv_auto_data-bcontd-partner     = lv_partner.
  lv_auto_data-bcontd-cclass      = lv_class.
  lv_auto_data-bcontd-activity    = lv_activity.
  lv_auto_data-bcontd-ctype       = lv_type.
  lv_auto_data-bcontd-ctdate      = sy-datum.
  lv_auto_data-bcontd-cttime      = sy-uzeit.
  lv_auto_data-bcontd-erdat       = sy-datum.
  lv_auto_data-bcontd-ernam       = sy-uname.
  lv_auto_data-text-langu         = sy-langu.
  lv_auto_data-bcontd_use         = 'X'.

*      Name zum Inkassobüro lesen
  IF lv_category = const_sell.
    SELECT SINGLE * FROM but000
           INTO lv_but000
           WHERE partner = fs_header-inkgp.

* Name Inkasso-Büro über Customizing
    CLEAR ls_wo_cust.
    READ TABLE gt_wo_cust INTO ls_wo_cust
      WITH KEY wo_option   = 'CONTACT'
               wo_category = 'NAME_IGP'
               wo_field    = fs_header-inkgp.

    IF sy-subrc = 0.
      lv_gpname = ls_wo_cust-wo_value.
    ELSE.
      CONCATENATE lv_but000-partner
                  lv_but000-name_org1
                  lv_but000-name_first
                  lv_but000-name_last
                  lv_but000-name_grp1
                  INTO lv_gpname
                  SEPARATED BY space.
    ENDIF.
  ENDIF.

* Kontakt Titel
  CLEAR lv_textline.
  CONCATENATE TEXT-001
              fs_header-vkont
              lv_text
              lv_gpname
              INTO lv_textline-tdline
              SEPARATED BY space.
  lv_textline-tdformat = '/'.
  APPEND lv_textline TO lv_auto_data-text-textt.

* Kontakt Text Ausbuchungsgrund
  READ TABLE gt_tfk048at INTO ls_tfk048at
       WITH KEY spras = sy-langu
                abgrd = fs_header-abgrd.
  CLEAR lv_textline.
  CONCATENATE TEXT-004
              ls_tfk048at-abtxt
              INTO lv_textline-tdline
              SEPARATED BY space.
  lv_textline-tdformat = '/'.
  APPEND lv_textline TO lv_auto_data-text-textt.

* Kontakt Text Interner Ausbuchungsgrund
  READ TABLE gt_igrdt INTO ls_igrdt
       WITH KEY spras = sy-langu
                woigd = fs_header-woigd.
  CLEAR lv_textline.
  CONCATENATE TEXT-005
              ls_igrdt-woigdt
              INTO lv_textline-tdline
              SEPARATED BY space.
  lv_textline-tdformat = '/'.
  APPEND lv_textline TO lv_auto_data-text-textt.

* Kontakt Text Verkaufsquote
  IF fs_header-wovks IN gr_vks_sell.
    READ TABLE gt_vkst INTO ls_vkst
         WITH KEY spras = sy-langu
                  wovks = fs_header-wovks.
    CLEAR lv_textline.
    CONCATENATE TEXT-006
                ls_vkst-wovkt
                INTO lv_textline-tdline
                SEPARATED BY space.
    lv_textline-tdformat = '/'.
    APPEND lv_textline TO lv_auto_data-text-textt.
  ENDIF.

  REFRESH lt_lines.
  PERFORM get_approvals
          TABLES lt_lines
          USING  fs_header-vkont
                 fs_header-gpart.
  APPEND LINES OF lt_lines TO lv_auto_data-text-textt.

* Erstellung Kontakt
  lv_object-objrole = 'X00040002001'.
  lv_object-objtype = 'ISUACCOUNT'.
  CONCATENATE lv_vkont lv_partner INTO lv_object-objkey.
  APPEND lv_object TO lv_auto_data-iobjects.

* abweichender FuBa
  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'CONTACT'
             wo_category = 'FUBA'.

  IF sy-subrc = 0.
    lv_funcc = ls_wo_cust-wo_value.

    CALL FUNCTION lv_funcc
      EXPORTING
        x_upd_online    = 'X'
        x_no_dialog     = 'X'
        x_auto          = lv_auto_data
        x_partner       = lv_partner
      IMPORTING
        y_new_bpcontact = lv_bpcontact
      EXCEPTIONS
        existing        = 1
        foreign_lock    = 2
        number_error    = 3
        general_fault   = 4
        input_error     = 5
        not_authorized  = 6
        OTHERS          = 7.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ELSE.

    CALL FUNCTION 'BCONTACT_CREATE'
      EXPORTING
        x_upd_online    = 'X'
        x_no_dialog     = 'X'
        x_auto          = lv_auto_data
        x_partner       = lv_partner
      IMPORTING
        y_new_bpcontact = lv_bpcontact
      EXCEPTIONS
        existing        = 1
        foreign_lock    = 2
        number_error    = 3
        general_fault   = 4
        input_error     = 5
        not_authorized  = 6
        OTHERS          = 7.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_DOCU_EXISTS
*&---------------------------------------------------------------------*
FORM check_docu_exists USING ff_vkont
                             ff_gpart
                             ff_ic_docu.

  DATA: ls_wo_cust TYPE /adesso/wo_cust.  "Customizing Ausbuchungen
  DATA: lv_object  TYPE tdobject.
  DATA: lv_id      TYPE tdid.
  DATA: lv_tdname  TYPE tdobname.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option    = 'INTVERM'
             wo_category  = 'OBJECT'
             wo_field     = 'TDOBJECT'.

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
              '001'
              INTO lv_tdname .

*  Prüfen, ob Docu existiert
  SELECT SINGLE @abap_true FROM stxh
         WHERE tdobject = @lv_object
         AND   tdname   = @lv_tdname
         AND   tdid     = @lv_id
         AND   tdspras  = @sy-langu
         INTO  @DATA(exists).

  IF exists = abap_true.
    PERFORM set_status_icon
            USING 'DOCU'
                  ff_ic_docu.
  ELSE.
    PERFORM set_status_icon
            USING 'NODOCU'
                  ff_ic_docu.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_LAST_APPROVAL
*&---------------------------------------------------------------------*
FORM get_last_approval USING ff_vkont
                             ff_gpart
                             ff_intverm.

  DATA: ls_wo_cust TYPE /adesso/wo_cust.  "Customizing allgemein
  DATA: ls_pattern TYPE char30,
        ls_select  TYPE char30,
        ls_stxh    TYPE stxh,
        lt_stxh    TYPE TABLE OF stxh,
        ls_lines   TYPE tline,
        lt_lines   TYPE TABLE OF tline,
        lv_object  TYPE thead-tdobject,
        lv_id      TYPE thead-tdid.

*   Interne Vermerke
  CLEAR: ls_pattern, ls_select, ls_stxh, lt_stxh.

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'OBJECT'
             wo_field    = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_object.
  ENDIF.


  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INTVERM'
             wo_category = 'APPROVAL'
             wo_field    = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_wo_cust-wo_value TO lv_id.
  ENDIF.

  CONCATENATE ff_gpart
              '_'
              ff_vkont
              '_'
              INTO ls_pattern.

  CONCATENATE ls_pattern '%' INTO ls_select.

  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND   tdname LIKE ls_select
           AND   tdid = lv_id
           AND   tdspras = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.

  READ TABLE lt_stxh INTO ls_stxh INDEX 1.

  IF sy-subrc = 0.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lv_id
        language                = sy-langu
        name                    = ls_stxh-tdname
        object                  = lv_object
      TABLES
        lines                   = lt_lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ELSE.
    PERFORM create_approval_ex_post USING ff_vkont ff_gpart ff_intverm.
  ENDIF.

  IF lt_lines IS NOT INITIAL.
    READ TABLE lt_lines INTO ls_lines INDEX 1.
    MOVE ls_lines-tdline TO ff_intverm.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  CREATE_APPROVAL
*&---------------------------------------------------------------------*
FORM create_approval USING ff_gpart
                           ff_vkont
                           ff_wosta
                           ff_intverm
                           ff_iverm
                           fs_womon_cha LIKE gs_womonh_cha.

  DATA: ls_wo_cust TYPE /adesso/wo_cust.  "Customizing Ausbuchungen

  DATA: lt_head     TYPE TABLE OF thead,
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
  DATA: lv_text_appr(20).

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option    = 'INTVERM'
             wo_category  = 'OBJECT'
             wo_field     = 'TDOBJECT'.

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

  CASE ff_wosta.
    WHEN '01'.
      ls_line-tdline = TEXT-s01.
    WHEN '02'.
      ls_line-tdline = TEXT-s02.
    WHEN '03'.
      ls_line-tdline = TEXT-s03.
    WHEN '10'.
      ls_line-tdline = TEXT-s10.
    WHEN '11'.
      ls_line-tdline = TEXT-s11.
    WHEN '12'.
      ls_line-tdline = TEXT-s12.
    WHEN '13'.
      ls_line-tdline = TEXT-s13.
  ENDCASE.

  CASE fs_womon_cha-agsta.
    WHEN '20'.
      CONCATENATE ls_line-tdline
                  TEXT-a20
                  INTO ls_line-tdline
                  SEPARATED BY space.
    WHEN '30'.
      CONCATENATE ls_line-tdline
                  TEXT-a30
                  INTO ls_line-tdline
                  SEPARATED BY space.
    WHEN '31'.
      CONCATENATE ls_line-tdline
                  TEXT-a31
                  INTO ls_line-tdline
                  SEPARATED BY space.
    WHEN '32'.
      CONCATENATE ls_line-tdline
                  TEXT-a32
                  INTO ls_line-tdline
                  SEPARATED BY space.
  ENDCASE.

  APPEND ls_line TO lt_line.

  ff_intverm = ls_line-tdline.

  IF ff_iverm IS NOT INITIAL.
    MOVE ff_iverm TO ls_line-tdline.
    APPEND ls_line TO lt_line.
  ENDIF.

  CONCATENATE ff_gpart '_'
              ff_vkont '_'
              INTO  lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND tdname     LIKE lv_select
           AND tdid       = lv_id
           AND tdspras    = sy-langu.

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

  IF fs_womon_cha IS NOT INITIAL.
    ls_head-tdfuser = fs_womon_cha-aenam.
    ls_head-tdfdate = fs_womon_cha-aedat.
    ls_head-tdftime = fs_womon_cha-acptm.
  ENDIF.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client          = sy-mandt
      header          = ls_head
      owner_specified = 'X'
    TABLES
      lines           = lt_line
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_APPROVAL
*&---------------------------------------------------------------------*
FORM create_intverm_ink USING ff_gpart
                              ff_vkont
                              ff_wosta
                              ff_intverm
                              ff_iverm
                              ff_wohkf.

  DATA: ls_wo_cust  TYPE /adesso/wo_cust.   "Customizing Ausbuchungen
  DATA: ls_ink_cust TYPE /adesso/ink_cust.  "Customizing Inkasso
  DATA: lf_wohkf    TYPE /adesso/wo_wohkf.

  DATA: lt_head     TYPE TABLE OF thead,
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
  DATA: lv_text_appr(20).


  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INKASSO'
             wo_category = 'HERKUNFT'
             wo_field    = 'WOHKF'.

  IF sy-subrc = 0.
    lf_wohkf = ls_wo_cust-wo_value.
  ELSE.
    lf_wohkf = 'INK'.
  ENDIF.

  CHECK ff_wohkf = lf_wohkf.

  CLEAR ls_ink_cust.
  READ TABLE gt_ink_cust INTO ls_ink_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_ink_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_ink_cust.
  READ TABLE gt_ink_cust INTO ls_ink_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_ink_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  ls_line-tdline = TEXT-s02.
  APPEND ls_line TO lt_line.

  ff_intverm = ls_line-tdline.

  IF ff_iverm IS NOT INITIAL.
    MOVE ff_iverm TO ls_line-tdline.
    APPEND ls_line TO lt_line.
    ff_intverm = ls_line-tdline.
  ENDIF.

  CONCATENATE ff_gpart '_'
              ff_vkont '_'
              INTO  lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.

  CLEAR lt_stxh.
  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND tdname     LIKE lv_select
           AND tdid       = lv_id
           AND tdspras    = sy-langu.

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
      client          = sy-mandt
      header          = ls_head
      owner_specified = 'X'
    TABLES
      lines           = lt_line
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_APPROVAL_EX_POST
*&---------------------------------------------------------------------*
FORM create_approval_ex_post  USING ff_vkont
                                    ff_gpart
                                    ff_intverm.

  DATA: ls_womonh_cha LIKE gs_womonh_cha.
  DATA: lt_womonh_cha LIKE TABLE OF gs_womonh_cha.
  DATA: ls_wo_cust    TYPE /adesso/wo_cust.
  DATA: lf_wohkf      TYPE /adesso/wo_wohkf.
  DATA: lv_proc(19).

  CLEAR ls_wo_cust.
  READ TABLE gt_wo_cust INTO ls_wo_cust
    WITH KEY wo_option   = 'INKASSO'
             wo_category = 'HERKUNFT'
             wo_field    = 'WOHKF'.

  IF sy-subrc = 0.
    lf_wohkf = ls_wo_cust-wo_value.
  ENDIF.

  SELECT * FROM /adesso/wo_mon_h
         INTO CORRESPONDING FIELDS OF TABLE lt_womonh_cha
         WHERE gpart = ff_gpart
         AND   vkont = ff_vkont
         AND   wosta BETWEEN '01' AND '19'.

  SORT lt_womonh_cha.
  DELETE ADJACENT DUPLICATES FROM lt_womonh_cha.

  LOOP AT lt_womonh_cha INTO ls_womonh_cha.
    PERFORM create_approval USING ls_womonh_cha-gpart
                                  ls_womonh_cha-vkont
                                  ls_womonh_cha-wosta
                                  ff_intverm
                                  space
                                  ls_womonh_cha.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PREPARE_WROFF
*&---------------------------------------------------------------------*
FORM prepare_wroff  CHANGING ff_applk TYPE applk_kk
                             fs_fkkko TYPE fkkko
                             fs_rfka1 TYPE rfka1.

  DATA: lf_herkf    TYPE herkf_kk.
  DATA: lf_fikey    TYPE fikey_kk.
  DATA: lf_buber    LIKE tfk033d-buber.
  DATA: ls_tfk033d  TYPE tfk033d.

  lf_herkf = const_herkf_16.
  lf_buber = const_buber_1052.
  CLEAR lf_fikey.

  CALL FUNCTION 'FKK_GET_APPLICATION'
    IMPORTING
      e_applk = ff_applk.

  PERFORM call_zp_fb_1113(saplfka1)
          USING    lf_herkf
                   ff_applk
          CHANGING lf_fikey.

  CALL FUNCTION 'FKK_FIKEY_CHECK'
    EXPORTING
      i_fikey               = lf_fikey
*     i_open_on_request     = 'X'
      i_open_without_dialog = 'X'.

  CLEAR ls_tfk033d.
  ls_tfk033d-applk = ff_applk.
  ls_tfk033d-buber = lf_buber.

  CALL FUNCTION 'FKK_ACCOUNT_DETERMINE'
    EXPORTING
      i_tfk033d           = ls_tfk033d
    IMPORTING
      e_tfk033d           = ls_tfk033d
    EXCEPTIONS
      error_in_input_data = 1
      nothing_found       = 2
      OTHERS              = 3.

  IF sy-subrc NE 0.
    MESSAGE ID   sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  fs_fkkko-mandt = sy-mandt.
  fs_fkkko-fikey = lf_fikey.
  fs_fkkko-applk = ff_applk.
  fs_fkkko-blart = ls_tfk033d-fun04.
  fs_fkkko-herkf = lf_herkf.
  fs_fkkko-ernam = sy-uname.
  fs_fkkko-cpudt = sy-datum.
  fs_fkkko-cputm = sy-uzeit.
  fs_fkkko-waers = ls_tfk033d-fun02.
  fs_fkkko-bldat = sy-datum.
  fs_fkkko-budat = sy-datum.
  fs_fkkko-wwert = sy-datum.

  MOVE-CORRESPONDING fs_fkkko TO fs_rfka1.
  fs_rfka1-prebe = ls_tfk033d-fun01.
  fs_rfka1-augrd = ls_tfk033d-fun03.
  fs_rfka1-xcoac = ls_tfk033d-fun05.
  fs_rfka1-xrule = 'X'.

ENDFORM.
