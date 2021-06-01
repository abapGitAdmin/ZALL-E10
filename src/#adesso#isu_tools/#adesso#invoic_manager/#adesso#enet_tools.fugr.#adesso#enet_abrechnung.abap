FUNCTION /adesso/enet_abrechnung.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(NETZ_NR) TYPE  GRID_ID
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(ZAEHLERID) TYPE  /ADESSO/ZAEHLERD
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"  EXPORTING
*"     REFERENCE(PREISE) TYPE  /ADESSO/ENET_PREISE_T
*"----------------------------------------------------------------------

  DATA: ls_abrechnung       TYPE /adesso/abrech,
        ls_abrechnung2      TYPE /adesso/abrech,
        lv_ab               TYPE d,
        lv_bis              TYPE d,
        lv_zaehler_char(10) TYPE c,
        ls_preise           TYPE /adesso/enet_preis_dats,
        lt_abrechnung       TYPE TABLE OF /adesso/abrech.

  lv_zaehler_char = zaehlerid.
  SHIFT lv_zaehler_char LEFT DELETING LEADING ' '.
  SELECT * FROM /adesso/abrech INTO TABLE lt_abrechnung WHERE netz_nr = netz_nr AND zaehler_id = lv_zaehler_char AND STANDARD = '1' AND Id = '1 '.
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
      ELSEIF sy-subrc <> 0.
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
