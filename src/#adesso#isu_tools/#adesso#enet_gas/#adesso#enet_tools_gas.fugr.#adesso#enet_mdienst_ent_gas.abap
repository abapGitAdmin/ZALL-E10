FUNCTION /ADESSO/ENET_MDIENST_ENT_GAS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(MDIENST_NR) TYPE  INT4
*"     REFERENCE(MESSGEBIET_NR) TYPE  INT4
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"     REFERENCE(ZAEHLERNR) TYPE  /ADESSO/ZAEHLERD
*"  EXPORTING
*"     REFERENCE(BETRIEB) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(MESSUNG) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(SUMME) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(HARDW) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(DIENSTL) TYPE  /ADESSO/ENET_PREISE_T
*"  EXCEPTIONS
*"      KEIN_DIENSTL
*"      FALSCHE_DATEN
*"----------------------------------------------------------------------

  DATA: ls_marktpartner     TYPE /adesso/g_mpmess,
        ls_zadenet_messprei TYPE /adesso/g_messpr,
        ls_preisregelungen  TYPE /adesso/g_mprreg,
        ls_messprei         TYPE /adesso/g_messpr,
        lv_zahelrnr         TYPE i,
        lv_ab               TYPE dats,
        lv_bis              TYPE dats,
        ls_edef_har         TYPE /adesso/g_hardwa,
        ls_edef_dien         TYPE /adesso/g_dnlstg,
        lv_ende             TYPE c,
        ls_preise           TYPE LINE OF /adesso/enet_preise_t.

  lv_zahelrnr = zaehlernr.

  SELECT SINGLE * FROM /adesso/g_mpmess
    INTO ls_marktpartner
    WHERE mpm_nr = mdienst_nr
    AND status_id = '4200'.

  IF sy-subrc <> 0.
    " RAISE kein_dienstl.
    break struck-f.
  ENDIF.

  lv_ab = ab.
  DO 100 TIMES.


    SELECT SINGLE * FROM /adesso/g_mprreg
      INTO ls_preisregelungen
      WHERE messgebiet_nr = messgebiet_nr
      AND gueltig_bis > lv_ab
      AND gueltig_seit <= lv_ab.
    " AND status_id =.
      if sy-subrc <> 0.
       lv_ende = 'X'.
        ENDIF.
    IF ls_preisregelungen-gueltig_bis => bis.
      lv_ende = 'X'.
      lv_bis = bis.
    ELSE.
      lv_bis = ls_preisregelungen-gueltig_bis.
    ENDIF.



   " SELECT SINGLE * FROM /adesso/g_messpr
   SELECT  * FROM /adesso/g_messpr
      INTO ls_zadenet_messprei
      WHERE
    zaehler_id = lv_zahelrnr
     AND
      preisregelung_id = ls_preisregelungen-preisregelung_id.
    "  AND standard = '1'.

    IF sy-subrc = 0.
      DATA: lt_hardware TYPE TABLE OF /adesso/g_enthhw,
            ls_zaehler  TYPE /adesso/G_ZAEHLR,
            ls_hardware TYPE /adesso/g_enthhw.

        ls_preise-ab = lv_ab.
        ls_preise-bis = lv_bis.
        ls_preise-preis = ls_zadenet_messprei-preis_komponente_1.
        ls_preise-bemerkung = 'Ohne Hardware'.
        APPEND ls_preise TO betrieb .

        SELECT SINGLE * FROM /adesso/G_ZAEHLR INTO ls_zaehler WHERE zaehler_id = lv_zahelrnr.
        SELECT * FROM   /adesso/g_hardwa INTO ls_edef_har
          WHERE druck_ebene_entnahme = ls_zaehler-DRUCK_EBENE_ENTNAHME
          AND	druck_ebene_messung = ls_zaehler-druck_ebene_messung
          AND lieferstelle = ls_zaehler-lieferstelle
          AND zaehlverfahren = ls_zaehler-zaehlverfahren.
          READ TABLE lt_hardware TRANSPORTING NO FIELDS WITH KEY hardware_id =  ls_edef_har-hardware_id.
          IF sy-subrc <> 0.
            SELECT SINGLE * FROM /adesso/g_messpr INTO ls_messprei
        WHERE zaehler_id = 0 AND hardware_id = ls_edef_har-hardware_id AND
        preisregelung_id = ls_preisregelungen-preisregelung_id.
              if sy-subrc = 0.
            ls_zadenet_messprei-preis_komponente_1 = ls_zadenet_messprei-preis_komponente_1 + ls_messprei-preis_komponente_1.
            endif.
          ENDIF.
        ENDSELECT.

        SELECT * FROM   /adesso/g_hardwa INTO ls_edef_har
          WHERE druck_ebene_entnahme = ''
          AND	druck_ebene_messung = ''
          AND lieferstelle = ls_zaehler-lieferstelle
          AND zaehlverfahren = ls_zaehler-zaehlverfahren.
          READ TABLE lt_hardware TRANSPORTING NO FIELDS WITH KEY hardware_id =  ls_edef_har-hardware_id.
          IF sy-subrc <> 0.
          SELECT SINGLE * FROM /adesso/g_messpr INTO ls_messprei
      WHERE zaehler_id = 0 AND hardware_id = ls_edef_har-hardware_id AND
      preisregelung_id = ls_preisregelungen-preisregelung_id.
              if sy-subrc = 0.
            ls_zadenet_messprei-preis_komponente_1 = ls_zadenet_messprei-preis_komponente_1 + ls_messprei-preis_komponente_1.
            endif.
          ENDIF.
        ENDSELECT.

        ls_preise-ab = lv_ab.
        ls_preise-bis = lv_bis.
        ls_preise-preis = ls_zadenet_messprei-preis_komponente_1.
        ls_preise-bemerkung = 'Mit Hardware'.
        APPEND ls_preise TO betrieb .

      ls_preise-ab = lv_ab.
      ls_preise-bis = lv_bis.
      ls_preise-preis =  ls_zadenet_messprei-preis_komponente_2.
      APPEND ls_preise TO messung .

      ls_preise-ab = lv_ab.
      ls_preise-bis = lv_bis.
      ls_preise-preis = ls_zadenet_messprei-preis_summe_k1_k2.
      APPEND ls_preise TO summe.


    ENDIF.
    endselect.

    SELECT * FROM /adesso/g_messpr INTO ls_zadenet_messprei
      WHERE zaehler_id = 0 AND HARDWARE_ID <> 0 AND
      preisregelung_id = ls_preisregelungen-preisregelung_id.
     " AND standard = '1'.

      SELECT SINGLE * FROM /adesso/g_hardwa INTO ls_edef_har WHERE hardware_id = ls_zadenet_messprei-hardware_id.

      ls_preise-ab = lv_ab.
      ls_preise-bis = lv_bis.
      ls_preise-preis = ls_zadenet_messprei-preis_summe_k1_k2.
      ls_preise-bemerkung = ls_edef_har-hardware_bezeichnung.
      APPEND ls_preise TO hardw.

      ENDSELECT.


         SELECT * FROM /adesso/g_messpr INTO ls_messprei
      WHERE zaehler_id = 0 AND hardware_id <> 0 AND
      preisregelung_id = ls_preisregelungen-preisregelung_id.
      " AND standard = '1'.

      SELECT SINGLE * FROM /adesso/g_hardwa INTO ls_edef_har WHERE hardware_id = ls_zadenet_messprei-hardware_id.

      ls_preise-ab = lv_ab.
      ls_preise-bis = lv_bis.
      ls_preise-preis = ls_zadenet_messprei-preis_summe_k1_k2.
      ls_preise-bemerkung = ls_edef_har-hardware_bezeichnung.
      APPEND ls_preise TO hardw.

    ENDSELECT.

    SELECT * FROM /adesso/g_messpr INTO ls_messprei
        WHERE zaehler_id = 0 AND hardware_id <> 0 AND
        preisregelung_id = ls_preisregelungen-preisregelung_id.
      " AND standard = '1'.

      SELECT SINGLE * FROM /adesso/g_dnlstg INTO ls_edef_dien WHERE dienstleistung_id = ls_zadenet_messprei-dienstleistung_id.

      ls_preise-ab = lv_ab.
      ls_preise-bis = lv_bis.
      ls_preise-preis = ls_zadenet_messprei-preis_summe_k1_k2.
      ls_preise-bemerkung = ls_edef_har-hardware_bezeichnung.
      APPEND ls_preise TO dienstl.
      ENDSELECT.



    IF lv_ende = 'X'.
      EXIT.
    ELSE.
      lv_ab = lv_bis + 1.
    ENDIF.

  ENDDO.




ENDFUNCTION.
