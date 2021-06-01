FUNCTION /ADZ/ENET_MAPPING_GAS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_PREISE)
*"  EXPORTING
*"     REFERENCE(ART_PREISE) TYPE  /ADZ/ENET_PREIS_ARTIKEL_T
*"----------------------------------------------------------------------

  DATA:
    lt_nametab TYPE TABLE OF /adz/nametab_s,
    ls_nametab TYPE /adz/nametab_s,
    ls_art_preise TYPE /ADZ/PREIS_ARTIKEL_S.

  ls_nametab-name = 'BETRIEB' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'MESSUNG' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'SUMME' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'HARDW' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'ABRECH' .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'GP'  .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'FLEI'  .
  APPEND ls_nametab TO lt_nametab.
    ls_nametab-name = 'FARB'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'AP'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'LP'  .
  APPEND ls_nametab TO lt_nametab.
  ls_nametab-name = 'KA'  .
  APPEND ls_nametab TO lt_nametab.


  DATA ls_anz TYPE /adz/nametab_preis_s.
  DATA    ls_preis_dat        TYPE /adz/enet_preis_dats.
  DATA lt_anz TYPE /adz/enet_nametab_preis.
  DATA ls_keyinfo TYPE slis_keyinfo_alv.
  DATA lv_artnr TYPE inv_product_id.
  FIELD-SYMBOLS: <preis> TYPE /adz/enet_preise_t.

  LOOP AT lt_nametab INTO ls_nametab.
    ASSIGN COMPONENT ls_nametab-name OF STRUCTURE i_preise TO <preis>.
    SELECT  art_nr FROM /adz/art_cust INTO lv_artnr WHERE enet_preis = ls_nametab-name.
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
