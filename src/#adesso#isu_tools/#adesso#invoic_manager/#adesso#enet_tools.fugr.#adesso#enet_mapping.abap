FUNCTION /ADESSO/ENET_MAPPING.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_PREISE)
*"  EXPORTING
*"     REFERENCE(ART_PREISE) TYPE  /ADESSO/ENET_PREIS_ARTIKEL_T
*"--------------------------------------------------------------------

  DATA:
    lt_nametab TYPE TABLE OF /adesso/nametab_s,
    ls_nametab TYPE /adesso/nametab_s,
    ls_art_preise TYPE /ADESSO/PREIS_ARTIKEL_S.

  ls_nametab-name = 'BETRIEB' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'MESSUNG' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'SUMME' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'HARDW' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'GP'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'AP'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'LP'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'BLIND' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'KA'  .
  APPEND ls_nametab TO lt_nametab.
   ls_nametab-name = 'ABRECH'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'KWK_A' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'KWK_B' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'SKAP' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'SKAPP' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'SKU_A' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'SKU_B' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'SKU_C' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'OFF_A' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'OFF_B' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'OFF_C' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'ABU_A' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'ABU_B' .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'ABU_C' .
  APPEND ls_nametab TO lt_nametab.


  DATA ls_anz TYPE /adesso/nametab_preis_s.
  DATA    ls_preis_dat        TYPE /adesso/enet_preis_dats.
  DATA lt_anz TYPE /adesso/enet_nametab_preis.
  DATA ls_keyinfo TYPE slis_keyinfo_alv.
  DATA lv_artnr TYPE inv_product_id.
  FIELD-SYMBOLS: <preis> TYPE /adesso/enet_preise_t.

  LOOP AT lt_nametab INTO ls_nametab.
    ASSIGN COMPONENT ls_nametab-name OF STRUCTURE i_preise TO <preis>.
    SELECT  art_nr FROM /adesso/art_cust INTO lv_artnr WHERE enet_preis = ls_nametab-name.
    LOOP AT <preis> INTO ls_preis_dat.
      ls_art_preise-artikelnr = lv_artnr.
      ls_art_preise-ab  = ls_preis_dat-ab.
      ls_art_preise-bis = ls_preis_dat-bis.
      ls_art_preise-preis = ls_preis_dat-preis.
      APPEND ls_art_preise to art_preise.
      CLEAR ls_art_preise.
    ENDLOOP.
    ENDSELECT.
    CLEAR lv_artnr.
  ENDLOOP.





ENDFUNCTION.
