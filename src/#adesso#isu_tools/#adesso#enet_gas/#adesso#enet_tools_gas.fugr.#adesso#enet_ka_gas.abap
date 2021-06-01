FUNCTION /ADESSO/ENET_KA_GAS .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(KA_ID) TYPE  /ADESSO/ENET_GAS_VNBG_NR
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"     REFERENCE(INT_INV_DOC_NO) TYPE  INV_INT_INV_DOC_NO OPTIONAL
*"  EXPORTING
*"     REFERENCE(PREISE) TYPE  /ADESSO/ENET_PREISE_T
*"--------------------------------------------------------------------

DATA ls_preis LIKE LINE OF preise.
  DATA: ls_ka              TYPE /adesso/enet_ka,
        lv_ab              TYPE dats,
        lv_bis             TYPE dats,
        lv_kaid            TYPE grid_id,
        lt_tinv_inv_line_b TYPE TABLE OF tinv_inv_line_b,
        ls_tinv_inv_line_b TYPE tinv_inv_line_b,
        lv_verbrauch       TYPE inv_quant,
        lv_ende            TYPE c.

  SELECT * FROM tinv_inv_line_b INTO TABLE lt_tinv_inv_line_b WHERE int_inv_doc_no = int_inv_doc_no.
  LOOP AT lt_tinv_inv_line_b INTO ls_tinv_inv_line_b.

    CASE ls_tinv_inv_line_b-product_id.
      WHEN '9990001000417'.
        lv_verbrauch =  lv_verbrauch + ls_tinv_inv_line_b-quantity.
      WHEN OTHERS.
    ENDCASE.

  ENDLOOP.



  lv_kaid = ka_id.
  SHIFT lv_kaid LEFT DELETING LEADING ''.

  IF lv_verbrauch IS NOT INITIAL.
    lv_ab = ab.
    DO 100 TIMES.

      SELECT * FROM /adesso/enet_ka   INTO ls_ka
      WHERE ka_id = lv_kaid
      AND gueltig_seit < lv_ab
      AND gueltig_bis > lv_ab
              AND verbrauch_von < lv_verbrauch AND verbrauch_bis > lv_verbrauch AND energietyp = 'G'..
        "AND verbrauch_von < verbrauch AND verbrauch_bis > verbrauch..
        IF ls_ka-gueltig_bis > bis.
          lv_ende = 'X'.
          lv_bis = bis.
        ELSE.
          lv_bis = ls_ka-gueltig_bis.
        ENDIF.

        ls_preis-preis = ls_ka-ka.
        ls_preis-ab = ab.
        ls_preis-bis = bis.
        ls_preis-bemerkung = ls_ka-katyp.
        APPEND ls_preis TO preise.

      ENDSELECT.
      IF lv_ende = 'X'.
        EXIT.
      ELSE.
        lv_ab = lv_bis + 1.
      ENDIF.

    ENDDO.

  endif.
  if preise IS INITIAL.
    lv_ab = ab.
    DO 100 TIMES.

      SELECT * FROM /adesso/enet_ka   INTO ls_ka
      WHERE ka_id = lv_kaid
      AND gueltig_seit < lv_ab
      AND gueltig_bis > lv_ab.
        "AND verbrauch_von < verbrauch AND verbrauch_bis > verbrauch..
        IF ls_ka-gueltig_bis > bis.
          lv_ende = 'X'.
          lv_bis = bis.
        ELSE.
          lv_bis = ls_ka-gueltig_bis.
        ENDIF.

        ls_preis-preis = ls_ka-ka.
        ls_preis-ab = ab.
        ls_preis-bis = bis.
        ls_preis-bemerkung = ls_ka-katyp.
        APPEND ls_preis TO preise.

      ENDSELECT.
      IF lv_ende = 'X'.
        EXIT.
      ELSE.
        lv_ab = lv_bis + 1.
      ENDIF.
    ENDDO.

  ENDIF.

ENDFUNCTION.
