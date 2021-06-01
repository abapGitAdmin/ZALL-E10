FUNCTION /ADZ/ENET_BLINDSTROM .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(NETZ_NR) TYPE  GRID_ID
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"     REFERENCE(INT_INV_DOC_NO) TYPE  INV_INT_INV_DOC_NO OPTIONAL
*"  EXPORTING
*"     REFERENCE(PREISE) TYPE  /ADZ/ENET_PREISE_T
*"----------------------------------------------------------------------

  DATA ls_preis LIKE LINE OF preise.
  DATA: ls_blindst TYPE /adz/eblindst,
        ls_tinv_inv_line_b TYPE tinv_inv_line_b,
        lv_netz_nr TYPE grid_id,
        lt_tinv_inv_line_b TYPE  TABLE OF tinv_inv_line_b .
  lv_netz_nr = netz_nr.
  SHIFT lv_netz_nr LEFT DELETING LEADING ' '.
  SELECT * FROM tinv_inv_line_b INTO TABLE lt_tinv_inv_line_b WHERE int_inv_doc_no = int_inv_doc_no.
  LOOP AT lt_tinv_inv_line_b INTO ls_tinv_inv_line_b WHERE product_id = '9990001000508'.


    SELECT SINGLE * FROM /adz/eblindst
      INTO ls_blindst
      WHERE netz_nr = netz_nr
      AND gueltig_seit <= ls_tinv_inv_line_b-date_from
      AND gueltig_bis >= ls_tinv_inv_line_b-date_to.

      if sy-subrc = 0.
        ls_preis-ab = ls_tinv_inv_line_b-date_from.
        ls_preis-bis = ls_tinv_inv_line_b-date_to.
        ls_preis-preis = ls_blindst-blindstrompreis.
        APPEND ls_preis to preise.
      ENDIF.



  ENDLOOP.


ENDFUNCTION.
