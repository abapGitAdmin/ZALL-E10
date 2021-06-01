FUNCTION /ADESSO/ENET_MDIENST_ENTGELTE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(MDIENST_NR) TYPE  GRID_ID
*"     REFERENCE(MESSGEBIET_NR) TYPE  GRID_ID
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

  DATA: ls_marktpartner     TYPE /adesso/marktpa,
        ls_zadenet_messprei TYPE /adesso/messprei,
        ls_messprei         TYPE /adesso/messprei,
        ls_preisregelungen  TYPE /adesso/messpreg,
        lv_zahelrnr         TYPE i,
        lv_ab               TYPE dats,
        lv_bis              TYPE dats,
        ls_edef_har         TYPE /adesso/edef_har,
        lv_ende             TYPE c,
        ls_preise           TYPE LINE OF /adesso/enet_preise_t.

  DATA: lt_hardware TYPE TABLE OF /adesso/hardware,
        ls_zaehler  TYPE /adesso/zaehler,
        ls_hardware TYPE /adesso/hardware.

  lv_zahelrnr = zaehlernr.

  SELECT SINGLE * FROM /adesso/marktpa
    INTO ls_marktpartner
    WHERE mpm_nr = mdienst_nr
    AND status_id = '4200'.

  IF sy-subrc <> 0.
    " RAISE kein_dienstl.
    break struck-f.
  ENDIF.

  lv_ab = ab.
  DO 100 TIMES.


    SELECT SINGLE * FROM /adesso/messpreg
      INTO ls_preisregelungen
      WHERE messgebiet_nr = messgebiet_nr
      AND gueltig_bis => lv_ab
      AND gueltig_seit <= lv_ab.
    " AND status_id =.
    IF sy-subrc <> 0.
      lv_ende = 'X'.
    ENDIF.
    IF ls_preisregelungen-gueltig_bis > bis.
      lv_ende = 'X'.
      lv_bis = bis.
    ELSE.
      lv_bis = ls_preisregelungen-gueltig_bis.
    ENDIF.

    DATA lv_standart TYPE c .

    DO 5 TIMES.
      lv_standart = '1'.
      IF sy-index = 5.
        lv_standart = '0'.
      ENDIF.
      CLEAR : ls_zadenet_messprei, lt_hardware ,  ls_preise.
      SELECT SINGLE * FROM /adesso/messprei
        INTO ls_zadenet_messprei
        WHERE zaehler_id = lv_zahelrnr
        AND preisregelung_id = ls_preisregelungen-preisregelung_id
        AND standard = lv_standart.

      IF sy-subrc = 0.

        "Hardware mit einbeziehen

        SELECT * FROM /adesso/hardware INTO TABLE lt_hardware WHERE messpreis_id = ls_zadenet_messprei-messpreis_id.
        IF sy-index = 1 OR sy-index = 5.
          ls_preise-ab = lv_ab.
          ls_preise-bis = lv_bis.
          ls_preise-preis = ls_zadenet_messprei-preis_komponente_1.
          ls_preise-bemerkung = 'Ohne Hardware'.
          APPEND ls_preise TO betrieb .

        ELSE.
          SELECT SINGLE * FROM /adesso/zaehler INTO ls_zaehler WHERE zaehler_id = lv_zahelrnr.
          IF sy-index = 2.
            SELECT * FROM   /adesso/edef_har INTO ls_edef_har
              WHERE spg_ebene_entnahme = ''
              AND	spg_ebene_messung = ''
              AND lieferstelle = ls_zaehler-lieferstelle
              AND zaehlverfahren = ls_zaehler-zaehlverfahren.
              READ TABLE lt_hardware TRANSPORTING NO FIELDS WITH KEY hardware_id =  ls_edef_har-hardware_id.
              IF sy-subrc <> 0.
                SELECT SINGLE * FROM /adesso/messprei INTO ls_messprei
            WHERE zaehler_id = 0 AND hardware_id = ls_edef_har-hardware_id AND
            preisregelung_id = ls_preisregelungen-preisregelung_id.
                IF sy-subrc = 0.
                  ls_zadenet_messprei-preis_komponente_1 = ls_zadenet_messprei-preis_komponente_1 + ls_messprei-preis_komponente_1.
                ENDIF.
              ENDIF.
            ENDSELECT.
          ELSEIF sy-index = 3.
            SELECT * FROM   /adesso/edef_har INTO ls_edef_har
         WHERE spg_ebene_entnahme = ls_zaehler-spg_ebene_entnahme
         AND  spg_ebene_messung = ls_zaehler-spg_ebene_messung
         AND lieferstelle = ls_zaehler-lieferstelle
         AND zaehlverfahren = ls_zaehler-zaehlverfahren.
              READ TABLE lt_hardware TRANSPORTING NO FIELDS WITH KEY hardware_id =  ls_edef_har-hardware_id.
              IF sy-subrc <> 0.
                SELECT SINGLE * FROM /adesso/messprei INTO ls_messprei
            WHERE zaehler_id = 0 AND hardware_id = ls_edef_har-hardware_id AND
            preisregelung_id = ls_preisregelungen-preisregelung_id.
                IF sy-subrc = 0.
                  ls_zadenet_messprei-preis_komponente_1 = ls_zadenet_messprei-preis_komponente_1 + ls_messprei-preis_komponente_1.
                ENDIF.
              ENDIF.
            ENDSELECT.
          ELSE.
            SELECT * FROM   /adesso/edef_har INTO ls_edef_har
          WHERE ( spg_ebene_entnahme = ls_zaehler-spg_ebene_entnahme
         AND  spg_ebene_messung = ls_zaehler-spg_ebene_messung OR spg_ebene_entnahme = ''
         AND  spg_ebene_messung = '' )
         AND lieferstelle = ls_zaehler-lieferstelle
         AND zaehlverfahren = ls_zaehler-zaehlverfahren.
              READ TABLE lt_hardware TRANSPORTING NO FIELDS WITH KEY hardware_id =  ls_edef_har-hardware_id.
              IF sy-subrc <> 0.
                SELECT SINGLE * FROM /adesso/messprei INTO ls_messprei
            WHERE zaehler_id = 0 AND hardware_id = ls_edef_har-hardware_id AND
            preisregelung_id = ls_preisregelungen-preisregelung_id.
                IF sy-subrc = 0.
                  ls_zadenet_messprei-preis_komponente_1 = ls_zadenet_messprei-preis_komponente_1 + ls_messprei-preis_komponente_1.
                ENDIF.
              ENDIF.
            ENDSELECT.
          ENDIF.



          ls_preise-ab = lv_ab.
          ls_preise-bis = lv_bis.
          ls_preise-preis = ls_zadenet_messprei-preis_komponente_1.
          IF sy-index = 2.
            ls_preise-bemerkung = 'Mit Hardware'.
          ELSEIF sy-index = 2..
            ls_preise-bemerkung = 'Mit Wandler'.
          ELSE.
            ls_preise-bemerkung = 'Mit Wandler und Hardware'.
          ENDIF.
          APPEND ls_preise TO betrieb .
        ENDIF.


        IF sy-index = 1 OR sy-index = 5.
          CLEAR ls_preise-bemerkung.

          ls_preise-ab = lv_ab.
          ls_preise-bis = lv_bis.
          ls_preise-preis =  ls_zadenet_messprei-preis_komponente_2.
          APPEND ls_preise TO messung .

          ls_preise-ab = lv_ab.
          ls_preise-bis = lv_bis.
          ls_preise-preis = ls_zadenet_messprei-preis_summe_k1_k2.
          APPEND ls_preise TO summe.
        ENDIF.
      ENDIF.



    ENDDO.

    SELECT * FROM /adesso/messprei INTO ls_zadenet_messprei
      WHERE zaehler_id = 0 AND hardware_id <> 0 AND
      preisregelung_id = ls_preisregelungen-preisregelung_id.
      " AND standard = '1'.

      SELECT SINGLE * FROM /adesso/edef_har INTO ls_edef_har WHERE hardware_id = ls_zadenet_messprei-hardware_id.

      ls_preise-ab = lv_ab.
      ls_preise-bis = lv_bis.
      ls_preise-preis = ls_zadenet_messprei-preis_summe_k1_k2.
      ls_preise-bemerkung = ls_edef_har-hardware_bezeichnung.
      APPEND ls_preise TO hardw.

    ENDSELECT.

    SELECT * FROM /adesso/messprei INTO ls_zadenet_messprei
        WHERE zaehler_id = 0 AND hardware_id <> 0 AND
        preisregelung_id = ls_preisregelungen-preisregelung_id.
      " AND standard = '1'.

      SELECT SINGLE * FROM /adesso/edef_die INTO ls_edef_har WHERE dienstleistung_id = ls_zadenet_messprei-dienstleistung_id.

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
