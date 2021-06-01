FUNCTION /ADESSO/ENET_KWK .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(NETZ_NR) TYPE  GRID_ID
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"  EXPORTING
*"     REFERENCE(KAT_A) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(KAT_B) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(KAT_C) TYPE  /ADESSO/ENET_PREISE_T
*"--------------------------------------------------------------------

  DATA: ls_kwk    TYPE /adesso/enet_kwk,
        lv_ab     TYPE dats,
        lv_bis    TYPE dats,
        lv_ende   TYPE c,
        ls_preise TYPE LINE OF /adesso/enet_preise_t.
  lv_ab = ab.
  DO 100 TIMES.
    SELECT SINGLE * FROM /adesso/enet_kwk INTO ls_kwk WHERE netz_nr = netz_nr AND gueltig_seit =< lv_ab AND gueltig_bis => lv_ab.
    IF ls_kwk-gueltig_bis > bis.
      lv_ende = 'X'.
      lv_bis = bis.
    ELSE.
      lv_bis = ls_kwk-gueltig_bis.
    ENDIF.
    IF sy-subrc = 0.
      ls_preise-ab = lv_ab.
      ls_preise-bis = lv_bis.
      ls_preise-preis = ls_kwk-kwk_aufschlag.
      APPEND ls_preise TO kat_a." = ls_kwk-kwk_aufschlag.
      ls_preise-preis = ls_kwk-kwk_aufschlag_kat_b.
      APPEND ls_preise TO kat_b.
      "Categorie C ist immer 0.25 Cent / KWH
      ls_preise-preis = '0.00025000'.
      APPEND ls_preise TO kat_c.
    ENDIF.
    IF lv_ende = 'X'.
      EXIT.
    ELSE.
      lv_ab = lv_bis + 1.
    ENDIF.
  ENDDO.



ENDFUNCTION.
