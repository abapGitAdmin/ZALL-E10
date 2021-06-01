FUNCTION /adesso/mte_ent_inst_mgmt.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_HTGER) LIKE  /ADESSO/MTE_HTGE STRUCTURE
*"        /ADESSO/MTE_HTGE
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_INTERFACE) TYPE  I
*"     REFERENCE(ANZ_AUTO_ZW) TYPE  I
*"     REFERENCE(ANZ_AUTO_GER) TYPE  I
*"     REFERENCE(ANZ_CONTAINER) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      ERROR
*"----------------------------------------------------------------------

  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: o_key           TYPE  emg_oldkey.

  DATA: ieasts     LIKE easts OCCURS 0 WITH HEADER LINE.
  DATA: ieasts_h   LIKE easts OCCURS 0 WITH HEADER LINE. "help
  DATA: ietdz      LIKE etdz  OCCURS 0 WITH HEADER LINE.
  DATA: ieabl      LIKE eabl  OCCURS 0 WITH HEADER LINE.
  DATA: ieaste     LIKE easte  OCCURS 0 WITH HEADER LINE.
  DATA: wa_eabl    LIKE eabl.
  DATA: hochdat    LIKE sy-datum.
  DATA: h_verberw  LIKE eablh-i_verberw.
  DATA: verbrauch  LIKE easte-perverbr.
  DATA: dat_aus    LIKE sy-datum.
  DATA: dat_vor    LIKE sy-datum. "Vorgangsdatum
  DATA: v_datum    LIKE sy-datum. "Vorgangsdatum = Vergleichsdatum
  DATA: anz_tg_per TYPE i.
  DATA: logikzw_h  LIKE easts-logikzw.
  DATA: spartyp    LIKE tespt-spartyp.

  object   = 'INST_MGMT'.
  ent_file = pfad_dat_ent.

  DATA: h_kombinat TYPE egerh-kombinat.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  PERFORM init_inm.
  CLEAR: inm_out, winm_out, meldung, anz_obj, v_datum.
  REFRESH: inm_out, meldung.
*<

*> Datenermittlung ---------

* relevante Aktionen bzw. Vorgänge
*01-Einbau gesamt
*02-Ausbau gesamt
*03-Wechsel
*04-Einbau abrechnungstechnisch
*05-Ausbau abrechnungstechnisch
*06-Einbau technisch
*07-Ausbau technisch

* inm_DI_INT *********************************************>>>>>>>
  MOVE x_htger-action TO inm_di_int-action.

  CASE x_htger-action.
    WHEN '01'.                                  "01-Einbau gesamt
*     Vorgangsdatum
      IF x_htger-ab GE x_htger-ab_anlage.
        MOVE x_htger-ab TO inm_di_int-eadat.
      ELSE.
        MOVE x_htger-ab_anlage TO inm_di_int-eadat.
      ENDIF.
*     Anlage
      MOVE x_htger-anlage TO inm_di_int-anlage.
*     Geräteplatz
      MOVE x_htger-devloc TO inm_di_int-devloc.

    WHEN '02'.                                  "02-Ausbau gesamt
*     Vorgangsdatum
      MOVE x_htger-ab TO inm_di_int-eadat.
*     Anlage
      MOVE x_htger-anlage TO inm_di_int-anlage.
*     Geräteplatz
      MOVE x_htger-devloc TO inm_di_int-devloc.

    WHEN '03'.                                              "03-Wechsel
*     Vorgangsdatum
      MOVE x_htger-ab TO inm_di_int-eadat.
*     Anlage
      MOVE x_htger-anlage TO inm_di_int-anlage.
*     Geräteplatz
      MOVE x_htger-devloc TO inm_di_int-devloc.

    WHEN '04'.                                 "04-Einbau abrechnungstechnisch
*     Vorgangsdatum
      IF x_htger-ab GE x_htger-ab_anlage.
        MOVE x_htger-ab TO inm_di_int-eadat.
      ELSE.
        MOVE x_htger-ab_anlage TO inm_di_int-eadat.
      ENDIF.
*     Anlage
      MOVE x_htger-anlage TO inm_di_int-anlage.
*     Geräteplatz
*     move x_htger-devloc to inm_DI_INT-devloc.

    WHEN '05'.                                "05-Ausbau abrechnungstechnisch
*     Vorgangsdatum
      MOVE x_htger-ab TO inm_di_int-eadat.
*     Anlage
      MOVE x_htger-anlage TO inm_di_int-anlage.
*     Geräteplatz
*     move x_htger-devloc to inm_DI_INT-devloc.

    WHEN '06'.                               "06-Einbau technisch
*     Vorgangsdatum
      IF x_htger-ab GE x_htger-ab_anlage.
        MOVE x_htger-ab TO inm_di_int-eadat.
      ELSE.
        MOVE x_htger-ab_anlage TO inm_di_int-eadat.
      ENDIF.
*     Anlage
*     move x_htger-anlage to inm_DI_INT-anlage.
*     Geräteplatz
      MOVE x_htger-devloc TO inm_di_int-devloc.

    WHEN '07'.                               "07-Ausbau technisch
*     Vorgangsdatum
      MOVE x_htger-ab TO inm_di_int-eadat.
*     Anlage
*     move x_htger-anlage to inm_DI_INT-anlage.
*     Geräteplatz
      MOVE x_htger-devloc TO inm_di_int-devloc.

  ENDCASE.

  MOVE  inm_di_int-eadat TO v_datum.
  APPEND inm_di_int.
  CLEAR  inm_di_int.
* inm_DI_INT **********************************************<<<<<<<<


* inm_DI_GER **********************************************>>>>>>>>
  CLEAR inm_di_ger.
* move                              to  inm_di_ger-trenre.
* move                              to  inm_di_ger-progt.
*  -- Wandlernummer = Zaehlernummer für Geräteverknüpfung
* MOVE                              TO  inm_di_ger-wandnre.
  CLEAR inm_di_ger-abrfakt.
* MOVE  space                       TO  inm_di_ger-drucknre.

* Sparte ist in vielen Projekten für diverse Entscheidungen nötig
  MOVE x_htger-sparte           TO inm_di_ger-sparte.

* Gerätenummern
  IF  x_htger-action  EQ  '02'  OR " Ausbau Gesamt
      x_htger-action  EQ  '05'  OR " Ausbau abr.technisch
      x_htger-action  EQ  '07'.    " Ausbau technisch
    MOVE   x_htger-equnr        TO  inm_di_ger-equnralt.
    MOVE  'X'                   TO  inm_di_ger-ausbau.
  ENDIF.

  IF  x_htger-action  EQ  '03'.   " Wechsel
    MOVE   x_htger-equnr        TO  inm_di_ger-equnrneu.
    MOVE   x_htger-equnr_alt    TO  inm_di_ger-equnralt.
  ENDIF.

  IF  x_htger-action  EQ  '01'  OR " Einbau Gesamt
      x_htger-action  EQ  '04'  OR " Einbau abr.technisch
      x_htger-action  EQ  '06'.    " Einbau technisch
    MOVE   x_htger-equnr        TO  inm_di_ger-equnrneu.
  ENDIF.

* Gerätewechsel (Vorgangsgrund)
  IF  x_htger-action  EQ  '01'  OR " Einbau Gesamt
      x_htger-action  EQ  '02'  OR " Ausbau Gesamt
      x_htger-action  EQ  '03'  OR " Wechsel
      x_htger-action  EQ  '06'  OR " Einbau technisch
      x_htger-action  EQ  '07'.    " Ausbau technisch
    MOVE   x_htger-gerwechs      TO  inm_di_ger-gerwechs.
  ENDIF.

*GVERRECHG (Verrechnungspreis zahlen), KONDIGRG(Tariffaktengruppe) usw.
  IF  x_htger-action  EQ  '01'  OR " Einbau Gesamt
      x_htger-action  EQ  '03'  OR " Wechsel
      x_htger-action  EQ  '04'.    " Einbau abr.technisch
    MOVE   x_htger-gverrech        TO  inm_di_ger-gverrechg.
    MOVE   x_htger-kondigr         TO  inm_di_ger-kondigrg.
    MOVE   x_htger-preiskla        TO  inm_di_ger-preisklag.
    MOVE   x_htger-tarifart        TO  inm_di_ger-tarifartg.

*!!!! Diese Felder werden bei Wechsel auf der Beladeseite
*     wieder gelöscht. Werden aber für den abrechnungtech. Einbau
*     wegen Anlagendoppelung benötigt


  ENDIF.

* MESSDRCK und Abrechnungsfaktor
  IF  x_htger-action  EQ  '01'  OR " Einbau Gesamt
      x_htger-action  EQ  '06'.    " Einbau technisch

    SELECT SINGLE spartyp FROM tespt INTO spartyp
                   WHERE sparte = x_htger-sparte.

    IF spartyp EQ '02' OR
       spartyp EQ '03' OR
       spartyp EQ '04'.
      MOVE   x_htger-messdrck       TO  inm_di_ger-messdrck.
**    An dieser Stelle auch den eventuell vorhandenen Druckregler
      MOVE    x_htger-drucknre       TO inm_di_ger-drucknre.
    ENDIF.

    MOVE   x_htger-abrfakt        TO  inm_di_ger-abrfakt.
  ENDIF.

  APPEND inm_di_ger.
  CLEAR  inm_di_ger.
* inm_DI_GER **********************************************<<<<<<<<


* inm_DI_ZW ***********************************************>>>>>>>
  CLEAR: ieasts, ietdz, ieabl, dat_aus.
  REFRESH: ieasts, ietdz, ieabl.
  CLEAR inm_di_zw.

*-----------------------------------------------------------------
* Einbau technisch
*-----------------------------------------------------------------
  IF  x_htger-action  EQ  '06'.  " Einbau technisch

    SELECT * FROM etdz INTO TABLE ietdz
                        WHERE equnr = x_htger-equnr
                          AND bis    = '99991231'.
    IF  sy-subrc NE 0.
**    Wenn es ein Zähler ist, dann Fehlermeldung
      CLEAR h_kombinat.
      SELECT kombinat FROM egerh INTO h_kombinat
         WHERE equnr = x_htger-equnr
           AND bis = '99991231'.
        EXIT.
      ENDSELECT.
      IF h_kombinat = 'Z'.
        CONCATENATE 'Anlage ' x_htger-anlage ': Keine Daten zu EQUNR ' x_htger-equnr ' zu Datum '
                     x_htger-ab ' in Tabelle ETDZ gefunden (06)'
                      INTO meldung-meldung.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.
    ENDIF.

    LOOP AT ietdz.
      CLEAR inm_di_zw.
*     Abrechnungsfaktor
      CLEAR                     inm_di_zw-abrfakte.
*     Anzahl Ableseergebnisse pro Ablesung
      MOVE  '1'              TO inm_di_zw-anzerg.
*     Equipmentnummer
      MOVE x_htger-equnr     TO inm_di_zw-equnre.
*     Zählwerk
      MOVE ietdz-zwnummer    TO inm_di_zw-zwnummere.
*     Abgelesener Zählerstand
      SELECT * FROM eabl INTO TABLE ieabl
                            WHERE equnr    = x_htger-equnr
                              AND zwnummer = ietdz-zwnummer
*                             AND adat     LE x_htger-ab.
                              AND adat     LE ietdz-ab.
*     Zählerstand holen, der am nächsten am Einbaudatum dran ist
      SORT ieabl BY adat DESCENDING.
      LOOP AT ieabl.

*         BKA-Sparte (z.B. Heizkosten)
        inm_di_zw-zwstandce = ieabl-v_zwstand + ieabl-n_zwstand.
        REPLACE '.' WITH ',' INTO inm_di_zw-zwstandce.
        EXIT.
      ENDLOOP.

* ----Periodenverbrauch
*     MOVE   TO inm_di_zw-perverbr.
*     MOVE   TO inm_di_zw-anzdaysofperiod.

      IF ietdz-spartyp = '02'. "GAS
*       Brennwertbezirk bei Gas
        MOVE ietdz-calor_area  TO inm_di_zw-calor_area.
*       Luftdruckgebiet
        MOVE ietdz-pr_area_ai  TO inm_di_zw-pr_area_ai.
*       Temperaturgebiet
        MOVE ietdz-temp_area   TO inm_di_zw-temp_area.
*       Gasdruckgebiet
        MOVE ietdz-gas_prs_ar  TO inm_di_zw-gas_prs_ar.
      ENDIF.

*     Zählwerk nicht ablesen
      MOVE ietdz-nablesen  TO inm_di_zw-nablesene.
*     Steuergruppe für  Auftragserst. bei zeitvariablen Ablesungen
      MOVE ietdz-steuergrp  TO inm_di_zw-steuergrpe.

*     Gaskorrekturdruck bei Gas
*     MOVE ietdz-crgpress  TO inm_di_zw-crgpress.
*     Gasdruckgebiet
*     MOVE ietdz-gas_prs_ar  TO inm_di_zw-gas_prs_ar.
*     Gasverfahren
*     Code zur Identifizierung eines Zählwerks
*     MOVE ietdz-kennziff   TO inm_di_zw-kennziffe.
*     Nichtzählendes Zählwerk
*     MOVE ietdz-kzmessw    TO inm_di_zw-kzmesswe.

      APPEND inm_di_zw.
      CLEAR inm_di_zw.

    ENDLOOP.

  ENDIF.

*-----------------------------------------------------------
* Einbau Gesamt und abr.technisch  plus  Wechsel
*-----------------------------------------------------------
  IF  x_htger-action  EQ  '01'  OR " Einbau Gesamt
      x_htger-action  EQ  '03'  OR " Wechsel
      x_htger-action  EQ  '04'.    " Einbau abr.technisch.

    CLEAR inm_di_zw.

    CLEAR: ieasts_h.
    REFRESH ieasts_h.
    CLEAR: logikzw_h, ieasts.
    REFRESH ieasts.

    SELECT * FROM easts INTO TABLE ieasts_h
                        WHERE anlage = x_htger-anlage.

    IF  sy-subrc NE 0.
      CONCATENATE 'Keine Daten zu Anlage ' x_htger-anlage
                  ' in Tabelle EASTS gefunden'
                    INTO meldung-meldung.
      APPEND meldung.
      RAISE wrong_data.
    ENDIF.

    SORT ieasts_h BY logikzw ab .

    CLEAR: logikzw_h, ieasts.
    REFRESH ieasts.

    LOOP AT ieasts_h WHERE bis GE v_datum.
*    LOOP AT ieasts_h.
      IF ieasts_h-logikzw NE logikzw_h.
        MOVE-CORRESPONDING ieasts_h TO ieasts.
        APPEND ieasts.
      ENDIF.
      MOVE ieasts_h-logikzw TO logikzw_h.
    ENDLOOP.

    SELECT * FROM etdz INTO TABLE ietdz
                        WHERE equnr = x_htger-equnr
*                         AND ab    = x_htger-ab.
                          AND bis    GE v_datum
                          AND ab     LE v_datum.
    IF  sy-subrc NE 0.

**    Wenn es ein Zähler ist, dann Fehlermeldung
      CLEAR h_kombinat.
      SELECT kombinat FROM egerh INTO h_kombinat
         WHERE equnr = x_htger-equnr
           AND  bis = '99991231'.
        EXIT.
      ENDSELECT.
      IF h_kombinat = 'Z'.

        CONCATENATE 'Anlage ' x_htger-anlage ': Keine Daten zu EQUNR ' x_htger-equnr ' zu Datum '
                     x_htger-ab ' in Tabelle ETDZ gefunden'
                      INTO meldung-meldung.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.
    ENDIF.

    SORT ietdz BY zwnummer ab.

    LOOP AT ietdz.

      LOOP AT ieasts WHERE logikzw EQ ietdz-logikzw.
*                       AND ab      LE ietdz-ab
*                       AND bis     GE ietdz-bis.

        CLEAR inm_di_zw.

*       Abrechnungsfaktor
        CLEAR                   inm_di_zw-abrfakte.
*       Anzahl Ableseergebnisse pro Ablesung
        MOVE  '1'     TO  inm_di_zw-anzerg.
*       Equipmentnummer
        MOVE x_htger-equnr     TO inm_di_zw-equnre.
*       Zählwerk
        MOVE ietdz-zwnummer    TO inm_di_zw-zwnummere.

*       Vorgangsdatum
        CLEAR dat_vor.
        IF x_htger-ab GE x_htger-ab_anlage.
          MOVE x_htger-ab TO dat_vor.
        ELSE.
          MOVE x_htger-ab_anlage TO dat_vor.
        ENDIF.

        CLEAR wa_eabl.
        SELECT * FROM eabl INTO TABLE ieabl
                              WHERE equnr    = x_htger-equnr
                                AND zwnummer = ietdz-zwnummer
                                AND adat    LE dat_vor.

*       Zählerstand holen, der am nächsten am Einbaudatum dran ist
        SORT ieabl BY adat DESCENDING.
        LOOP AT ieabl.

          inm_di_zw-zwstandce = ieabl-v_zwstand + ieabl-n_zwstand.
          REPLACE '.' WITH ',' INTO inm_di_zw-zwstandce.

          MOVE-CORRESPONDING ieabl TO wa_eabl.
          EXIT.
        ENDLOOP.

        IF x_htger-action  NE  '03'.                      " Wechsel
*         hochgerechneten Periodenverbrauch ermitteln
          CLEAR verbrauch.
*         Hochrechnungsdatum ermitteln:
          hochdat = wa_eabl-adat + 365.

*         Verbrauch hochrechnen:
          CALL FUNCTION 'ISU_REGISTER_EXTRAPOLATION'
            EXPORTING
              x_equnr    = wa_eabl-equnr
              x_zwnummer = wa_eabl-zwnummer
              x_geraet   = wa_eabl-gernr
              x_logikzw  = ietdz-logikzw
              x_stanzvor = wa_eabl-stanzvor
              x_stanznac = wa_eabl-stanznac
              x_adatsoll = hochdat
              x_zuorddat = wa_eabl-zuorddat
              x_abdat    = wa_eabl-adat
              x_anlage   = x_htger-anlage
*             x_ablbelnr = wa_eabl-ablbelnr
            IMPORTING
              y_verberw  = h_verberw
            EXCEPTIONS
              not_found  = 1
              OTHERS     = 2.

          verbrauch = h_verberw.
          CLEAR hochdat.

          IF verbrauch NE 0.
            MOVE verbrauch TO inm_di_zw-perverbr.
            MOVE '365' TO inm_di_zw-anzdaysofperiod.

          ELSE.
*           Periodenverbrauch aus EASTE
            SELECT  * FROM easte INTO TABLE ieaste
                                  WHERE logikzw EQ ieasts-logikzw.
*                                  AND ab      LE ieasts-ab.

            SORT ieaste BY ab DESCENDING.
            READ TABLE ieaste INDEX 1.

            IF sy-subrc EQ 0.
              MOVE ieaste-perverbr TO inm_di_zw-perverbr.
              anz_tg_per = ieaste-bis - ieaste-ab + 1.
              IF anz_tg_per < 1000.
                MOVE anz_tg_per TO inm_di_zw-anzdaysofperiod.
              ELSE.
                MOVE '365' TO inm_di_zw-anzdaysofperiod.
              ENDIF.
            ELSE.
              CONCATENATE 'kein Periodenverbrauch in EASTE gefunden'
                          '-> 99 eingetragen'
                        INTO meldung-meldung.
              APPEND meldung.

              MOVE '99' TO inm_di_zw-perverbr.

            ENDIF.
          ENDIF.
        ENDIF.


        IF  x_htger-action  EQ  '01' OR                      "   Einbau Gesamt

*           Bei Geräteinfosätzen erfolgt kein technischer Einbau. Wenn bei abr.techn.
*           Einbau die Bezirks- und Gebietsdaten nicht vorgegeben sind, werden die
*           bereits in der DB mit DEVINFOREC übernommene gleichnamige Werte wieder
*           gecleart
            x_htger-action  EQ  '04'.                        "   Einbau abr.technisch
          IF ietdz-spartyp = '02'. "GAS
*           Brennwertbezirk bei Gas
            MOVE ietdz-calor_area  TO inm_di_zw-calor_area.
*           Luftdruckgebiet
            MOVE ietdz-pr_area_ai  TO inm_di_zw-pr_area_ai.
*           Temperaturgebiet
            MOVE ietdz-temp_area   TO inm_di_zw-temp_area.
*           Gasdruckgebiet
            MOVE ietdz-gas_prs_ar  TO inm_di_zw-gas_prs_ar.
          ENDIF.

*         Zählwerk nicht ablesen
          MOVE ietdz-nablesen  TO inm_di_zw-nablesene.
*         Steuergruppe für  Auftragserst. bei zeitvariablen Ablesungen
          MOVE ietdz-steuergrp  TO inm_di_zw-steuergrpe.

        ENDIF.

*
        IF  x_htger-action  EQ  '01'  OR    " Einbau Gesamt
            x_htger-action  EQ  '03'  OR    " Wechsel
            x_htger-action  EQ  '04'.       " Einbau abr.technisch

          IF ietdz-spartyp = '02' AND  "GAS
             x_htger-action  NE  '03'.
*           Gaskorrekturdruck bei Gas
            MOVE ietdz-crgpress  TO inm_di_zw-crgpress.
*           Festtemperatur

*           Gasdruckgebiet
*           MOVE ietdz-gas_prs_ar  TO inm_di_zw-gas_prs_ar.
*           Gasverfahren
            SELECT SINGLE
              thgver
              festtemp
            FROM eadz
            INTO (inm_di_zw-thgver,
*                 > Aschoff 20.05.2008
                  inm_di_zw-festtemp)
*                 < Aschoff 20.05.2008
            WHERE logikzw = ietdz-logikzw
              AND bis     GE x_htger-ab.

          ENDIF.

*         Verrechnungspreis zahlen
          MOVE ieasts-gverrech  TO inm_di_zw-gverrech.
*         Code zur Identifizierung eines Zählwerks
          MOVE ietdz-kennziff   TO inm_di_zw-kennziffe.
*         Tariffaktengruppe
          MOVE ieasts-kondigr   TO inm_di_zw-kondigre.
*         Nichtzählendes Zählwerk
          MOVE ietdz-kzmessw    TO inm_di_zw-kzmesswe.
*         Preisklasse
          MOVE ieasts-preiskla  TO inm_di_zw-preisklae.
*         Rabattschlüssel
          MOVE ieasts-rabzus    TO inm_di_zw-rabzuse.
*         Tarifart
          MOVE ieasts-tarifart  TO inm_di_zw-tarifart.
*         Zählwerk nicht abrechnungsrelevant
          MOVE ieasts-zwnabr    TO inm_di_zw-zwnabr.
*         Zählwerk ist nicht bilanzierungsrelevant
          MOVE ieasts-zwnsettl  TO inm_di_zw-zwnsettle.

*!!!! Diese Felder werden bei Wechsel(03) auf der Beladeseite
*     wieder gelöscht. Werden aber für den abrechnungtech. Einbau
*     wegen Anlagendoppelung benötigt

        ENDIF.

        IF  x_htger-action  EQ  '03'. " Wechsel
          MOVE  x_htger-ab  TO  dat_aus.
          SUBTRACT  1  FROM  dat_aus.

          MOVE x_htger-equnr_alt TO inm_di_zw-equnra.
*         Zählwerk
          MOVE ietdz-zwnummer    TO inm_di_zw-zwnummera.
*         Abgelesener Zählerstand
*         SELECT SINGLE v_zwstand FROM eabl INTO eabl-v_zwstand
          SELECT SINGLE * FROM eabl
                                WHERE equnr = x_htger-equnr_alt
                                  AND zwnummer = ietdz-zwnummer
                                  AND adat     = dat_aus.
          IF sy-subrc EQ 0.

            inm_di_zw-zwstandca = eabl-v_zwstand + eabl-n_zwstand.
            REPLACE '.' WITH ',' INTO inm_di_zw-zwstandca.

          ENDIF.
        ENDIF.

        APPEND inm_di_zw.
        CLEAR inm_di_zw.

      ENDLOOP.                       "etdz

      IF  sy-subrc NE 0.
        CONCATENATE 'Keine Daten zu LOGIGZW ' ietdz-logikzw
                    ' in Tabelle EASTS gefunden'
                      INTO meldung-meldung.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.

    ENDLOOP.                         "easts

  ENDIF.

*-------------------------------------------------------------
* Ausbauten
*-------------------------------------------------------------
  IF  x_htger-action  EQ  '02'  OR " Ausbau Gesamt
      x_htger-action  EQ  '05'  OR " Ausbau abr.technisch
      x_htger-action  EQ  '07'.    " Ausbau technisch

    MOVE  x_htger-ab  TO  dat_aus.
    SUBTRACT  1  FROM  dat_aus.

    SELECT * FROM etdz INTO TABLE ietdz
                       WHERE equnr = x_htger-equnr
                         AND bis   = dat_aus.

    SORT ietdz BY zwnummer ab.

    LOOP AT ietdz.
      CLEAR inm_di_zw.

      MOVE x_htger-equnr     TO inm_di_zw-equnra.
*     Zählwerk
      MOVE ietdz-zwnummer    TO inm_di_zw-zwnummera.
*     Abgelesener Zählerstand
*     SELECT SINGLE v_zwstand FROM eabl INTO eabl-v_zwstand
      SELECT SINGLE * FROM eabl
                        WHERE equnr = ietdz-equnr
                          AND zwnummer = ietdz-zwnummer
                          AND adat     = dat_aus.
      IF sy-subrc EQ 0.

        inm_di_zw-zwstandca = eabl-v_zwstand + eabl-n_zwstand.
        REPLACE '.' WITH ',' INTO inm_di_zw-zwstandca.

      ENDIF.

      APPEND inm_di_zw.
      CLEAR inm_di_zw.

    ENDLOOP.

  ENDIF.

* inm_DI_CNT
**************************************************************>>>>>>>
  IF  x_htger-action  EQ  '01'  OR " Einbau Gesamt
      x_htger-action  EQ  '04'.    " Einbau abr.technisch
    IF x_htger-ab > x_htger-ab_anlage.
      MOVE 'X' TO inm_di_cnt-no_automovein.
      APPEND inm_di_cnt.
      CLEAR inm_di_cnt.
    ENDIF.
  ENDIF.


* Altsystemschlüssel aus Equnr, Vorgang, AB-Datum, Anlage erstellen
* oldkey_inm = ...
  CONCATENATE x_htger-equnr+10(8) x_htger-vorgang x_htger-ab
             '_' x_htger-anlage INTO oldkey_inm.

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_inm.
  CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
    EXPORTING
      i_firma  = firma
      i_object = object
      i_oldkey = o_key
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    meldung-meldung =
        'Fehler bei wegschreiben in Entlade-KSV'.
    APPEND meldung.
    RAISE error.
  ENDIF.

  ADD 1 TO anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
  IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_INST_MGM'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma      = firma
      TABLES
        meldung    = meldung
        inm_di_int = inm_di_int
        inm_di_zw  = inm_di_zw
        inm_di_ger = inm_di_ger
        inm_di_cnt = inm_di_cnt
      CHANGING
        oldkey_inm = oldkey_inm.
  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_inm_out USING oldkey_inm
                              firma
                              object
                              anz_interface
                              anz_auto_zw
                              anz_auto_ger
                              anz_container.

  LOOP AT inm_out INTO winm_out.
    TRANSFER winm_out TO ent_file.
  ENDLOOP.

ENDFUNCTION.
