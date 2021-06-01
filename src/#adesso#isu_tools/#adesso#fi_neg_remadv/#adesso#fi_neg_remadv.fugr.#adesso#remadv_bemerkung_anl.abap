FUNCTION /adesso/remadv_bemerkung_anl.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INT_INV_DOC_NO) TYPE  TINV_INT_INV_DOC_NO
*"  EXPORTING
*"     REFERENCE(OK_CODE) TYPE  OK
*"----------------------------------------------------------------------
  TYPES: BEGIN OF t_int_doc_no,
           int_doc_no TYPE inv_int_inv_doc_no,
         END OF t_int_doc_no.
  DATA lt_int_doc_no TYPE TABLE OF t_int_doc_no.
  DATA ls_int_doc_no TYPE inv_int_inv_doc_no.
  DATA ls_remtext TYPE /adesso/remtext.
  CLEAR: ok, bemerkung, gt_bemerkung, gs_bemerkung.

  lt_int_doc_no = int_inv_doc_no.
  SELECT * FROM /adesso/remtext INTO CORRESPONDING FIELDS OF TABLE gt_bemerkung FOR ALL ENTRIES IN lt_int_doc_no WHERE int_inv_doc_nr  = lt_int_doc_no-int_doc_no.
  IF sy-subrc <> 0.
    CALL SCREEN 9001 STARTING AT 10 10 .
  ELSE.
    CALL SCREEN 9000 STARTING AT 10 10 .
  ENDIF.

  IF ok = 'SAV'.
    LOOP AT int_inv_doc_no INTO ls_int_doc_no.
      ls_remtext-uname = sy-uname.
      ls_remtext-datum = sy-datum.
      ls_remtext-action = 'Bemerkung'.
      ls_remtext-zeit = sy-uzeit.
      ls_remtext-text = bemerkung.
      ls_remtext-int_inv_doc_nr = ls_int_doc_no.
      INSERT INTO /adesso/remtext VALUES ls_remtext.
    ENDLOOP.
  ENDIF.


ENDFUNCTION.
