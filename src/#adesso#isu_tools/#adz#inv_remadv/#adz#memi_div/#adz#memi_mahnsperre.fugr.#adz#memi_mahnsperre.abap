FUNCTION /ADZ/MEMI_MAHNSPERRE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_BELNR) TYPE  /IDXMM/DE_DOC_ID
*"     REFERENCE(IX_GET_LOCKHIST) TYPE  BOOLEAN OPTIONAL
*"     REFERENCE(IX_SET_LOCK) TYPE  BOOLEAN OPTIONAL
*"     REFERENCE(IX_DEL_LOCK) TYPE  BOOLEAN OPTIONAL
*"     REFERENCE(IV_NO_POPUP) TYPE  BOOLEAN OPTIONAL
*"  EXPORTING
*"     REFERENCE(EV_DONE) TYPE  BOOLEAN
*"  CHANGING
*"     REFERENCE(IV_DATE_FROM) TYPE  DATS OPTIONAL
*"     REFERENCE(IV_DATE_TO) TYPE  DATS OPTIONAL
*"     REFERENCE(IV_LOCKR) TYPE  LOCKR_KK OPTIONAL
*"----------------------------------------------------------------------
  TYPE-POOLS: slis.

  TYPES: BEGIN OF t_data .
           INCLUDE STRUCTURE /adz/mem_mloc.
           TYPES: chk TYPE c,                   "For multiple selection
         END OF t_data.
  DATA: timestamp TYPE timestampl.
  DATA lt_data TYPE TABLE OF t_data.
  DATA ls_data LIKE LINE OF lt_data.
  DATA ls_mloc TYPE /adz/mem_mloc.

  DATA:
    l_selfield TYPE slis_selfield.

  DATA lv_title TYPE sy-title.  " Popup dialog caption

  IF ix_del_lock = 'X'.
    SELECT * FROM /adz/mem_mloc INTO CORRESPONDING FIELDS OF TABLE lt_data WHERE doc_id = iv_belnr AND lvorm = ' ' AND tdate >= sy-datum.
    LOOP AT lt_data REFERENCE INTO DATA(lr_data).
      lr_data->chk = 'X'.
    ENDLOOP.
    IF sy-subrc = 0.
      IF iv_no_popup = ' '.
        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
          EXPORTING
            i_title              = lv_title
            i_selection          = 'X'
            i_zebra              = 'X'
            i_allow_no_selection = 'X'
            i_checkbox_fieldname = 'CHK'
            i_tabname            = 'LT_DATA'
            i_structure_name     = '/ADZ/MEM_MLOC'
          IMPORTING
            es_selfield          = l_selfield
          TABLES
            t_outtab             = lt_data
          EXCEPTIONS
            program_error        = 1
            OTHERS               = 2.
        WRITE: 'Selected entries:'.
      ENDIF.

      LOOP AT lt_data INTO ls_data WHERE chk = 'X'.
        CLEAR ls_mloc.
        ls_data-lvorm = 'X'.
        ls_data-crnam = sy-uname.
        ls_data-adatum = sy-datum.
        MOVE-CORRESPONDING ls_data TO ls_mloc.
        UPDATE /adz/mem_mloc FROM ls_mloc.
      ENDLOOP.
      IF sy-subrc = 0.
        ev_done = 'X'.
      ENDIF.
    ENDIF.


  ELSEIF ix_get_lockhist = 'X'.

    CALL FUNCTION '/ADZ/MEMI_LOCKHIST'
      EXPORTING
        doc_id = iv_belnr.

  ELSEIF ix_set_lock = 'X'.
    IF iv_no_popup = ' '.
      DATA:
        t_sval LIKE TABLE OF sval,
        w_sval LIKE          sval.
      DATA:    l_answer TYPE char1.
      CLEAR:   w_sval.
      REFRESH: t_sval.

      w_sval-tabname   = 'FKKMAZE'.
      w_sval-fieldname = 'MANSP'.
      w_sval-field_obl = 'X'.
      w_sval-fieldtext = 'Sperrgrund'.
      w_sval-value     = iv_lockr.
      APPEND w_sval TO t_sval.

      w_sval-tabname   = 'DFKKLOCKS'.
      w_sval-fieldname = 'FDATE'.
      w_sval-field_obl = 'X'.
      w_sval-fieldtext = 'von Datum'.
      w_sval-value     = iv_date_from.
      APPEND w_sval TO t_sval.

      w_sval-tabname   = 'DFKKLOCKS'.
      w_sval-fieldname = 'TDATE'.
      w_sval-field_obl = 'X'.
      w_sval-fieldtext = 'bis Datum'.
      w_sval-value     = iv_date_to.
      APPEND w_sval TO t_sval.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title  = 'Mahnsperre'
          start_column = '5'
          start_row    = '5'
        IMPORTING
          returncode   = l_answer
        TABLES
          fields       = t_sval.
      IF l_answer IS INITIAL.
        l_answer = 'j'.
      ENDIF.

      LOOP AT t_sval INTO w_sval.
        CASE w_sval-fieldname.
          WHEN 'MANSP'.
            iv_lockr = w_sval-value.
          WHEN 'FDATE'.
            iv_date_from = w_sval-value.
          WHEN 'TDATE'.
            iv_date_to = w_sval-value.
        ENDCASE.
      ENDLOOP.
    ELSE.
      l_answer = 'j'.
    ENDIF.
    IF NOT l_answer CA 'jJyY'.
      ev_done = ' '.
    ELSE.
*      DATA: ls_mloc TYPE /adz/hmv_mloc.
      DATA ls_memidoc_u TYPE /idxmm/memidoc.
      DATA lt_memidoc_u TYPE /idxmm/t_memi_doc.
      DATA lr_memidoc TYPE REF TO /idxmm/cl_memi_document_db.

      IF iv_date_from IS NOT INITIAL AND
         iv_date_to IS NOT INITIAL.
        IF iv_date_to LE iv_date_from.
          MESSAGE 'Ab-Datum größer als Bis-Datum' TYPE 'E'.
        ENDIF.
      ENDIF.
      IF iv_date_from < sy-datum.
        MESSAGE 'Mahnsperren müssen in der Zukunft liegen.' TYPE 'E'.
      ENDIF.

      ls_mloc-doc_id    = iv_belnr.
      ls_mloc-lockr     = iv_lockr.
      ls_mloc-fdate     = iv_date_from.
      ls_mloc-tdate     = iv_date_to.
      GET TIME STAMP FIELD ls_mloc-timestamp.
      ls_mloc-crnam     = sy-uname.
      ls_mloc-azeit     = sy-timlo.
      ls_mloc-adatum    = sy-datum.
      ls_mloc-lvorm     = ''.
      MODIFY /adz/mem_mloc FROM ls_mloc.

      IF sy-subrc = 0.
        ev_done = 'X'.
*      <t_out>-mansp  = iv_lockr.
*      <t_out>-fdate  = iv_date_from.
*      <t_out>-tdate  = iv_date_to.
**      <t_out>-status = icon_locked.
      ENDIF.
    ENDIF.
*
  ENDIF.
  IF ev_done = 'X'.
    COMMIT WORK.
  ENDIF.

ENDFUNCTION.
