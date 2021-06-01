FUNCTION /ADZ/ENET_ABRECHNUNG_GAS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VNBG_NR) TYPE  /ADZ/ENET_GAS_VNBG_NR
*"     REFERENCE(TARIFGEBIET) TYPE  /ADZ/ENET_GAS_TARIFGEBIET
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(ZAEHLERID) TYPE  /ADZ/ZAEHLERD
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"  EXPORTING
*"     REFERENCE(PREISE) TYPE  /ADZ/ENET_PREISE_T
*"----------------------------------------------------------------------

  DATA: ls_abrechnung       TYPE /ADZ/G_ABRPR,
        ls_abrechnung2      TYPE /ADZ/G_ABRPR,
        lv_ab               TYPE d,
        lv_bis              TYPE d,
        lv_zaehler_int      TYPE i,
        lv_lieferstelle     TYPE /adz/g_zaehlr-lieferstelle,
        ls_preise           TYPE /adz/enet_preis_dats,
        lt_abrechnung       TYPE TABLE OF /ADZ/G_ABRPR.

  SELECT SINGLE lieferstelle FROM /adz/g_zaehlr INTO lv_lieferstelle WHERE zaehler_id  = ZAEHLERID.

  lv_zaehler_int = zaehlerid.
*  SHIFT lv_zaehler_char LEFT DELETING LEADING ' '.
  if 1 = 0.
  SELECT * FROM /ADZ/G_ABRPR INTO TABLE lt_abrechnung WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND zaehler_id = ZAEHLERID.
    IF sy-subrc <> 0.
      if lv_lieferstelle = 'SLP'.
        lv_zaehler_int = 1000.
        ELSE.
        lv_zaehler_int = 1100.
        endif.
     SELECT * FROM /ADZ/G_ABRPR INTO TABLE lt_abrechnung WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND zaehler_id = lv_zaehler_int.
    ENDIF.
    ELSE.
      SELECT * FROM /ADZ/G_ABRPR INTO TABLE lt_abrechnung WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet.
    ENDIF.
  SORT lt_abrechnung BY gueltig_seit ASCENDING.

  LOOP AT lt_abrechnung  INTO ls_abrechnung.
    CLEAR ls_preise.
    IF ls_abrechnung-gueltig_seit < ab.
      READ TABLE lt_abrechnung INTO ls_abrechnung2 INDEX sy-tabix + 1.
      IF sy-subrc = 0 AND ls_abrechnung2-gueltig_seit > ab.
        ls_preise-ab = ab.
        ls_preise-bis = ls_abrechnung2-gueltig_seit - 1.
        ls_preise-preis = ls_abrechnung-preis.
      ELSEIF lines( lt_abrechnung ) < sy-tabix + 1.
        ls_preise-ab = ab.
        ls_preise-bis = '99991231'.
        ls_preise-preis = ls_abrechnung-preis.
      ELSE.
        CONTINUE.
      ENDIF.
    ELSEIF ls_abrechnung-gueltig_seit <= bis.
      READ TABLE lt_abrechnung INTO ls_abrechnung2 INDEX sy-tabix + 1.
      IF sy-subrc = 0 AND ls_abrechnung2-gueltig_seit < bis.
        ls_preise-ab = ls_abrechnung-gueltig_seit.
        ls_preise-bis = ls_abrechnung2-gueltig_seit - 1.
        ls_preise-preis = ls_abrechnung-preis.
      ELSEIF sy-subrc = 0 AND ls_abrechnung2-gueltig_seit > bis.
        ls_preise-ab = ls_abrechnung-gueltig_seit.
        ls_preise-bis = bis.
        ls_preise-preis = ls_abrechnung-preis.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF ls_preise IS NOT INITIAL.
      APPEND ls_preise TO preise.
    ENDIF.

  ENDLOOP.



ENDFUNCTION.
