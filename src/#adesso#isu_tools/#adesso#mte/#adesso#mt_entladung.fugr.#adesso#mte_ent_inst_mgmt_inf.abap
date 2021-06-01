FUNCTION /ADESSO/MTE_ENT_INST_MGMT_INF.
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
  DATA: ieasts_h   LIKE easts OCCURS 0 WITH HEADER LINE.
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

  DATA: ieabl2     LIKE eabl OCCURS 0 WITH HEADER LINE.
  DATA: hilfs_dat  LIKE sy-datum.

  DATA: no_zero(1)    TYPE c.

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
*01-Einbau gesamt (nicht für Geräteinfosätze)
*02-Ausbau gesamt (nicht für Gereäteinfosätze)
*03-Wechsel
*04-Einbau abrechnungstechnisch
*05-Ausbau abrechnungstechnisch
*06-Einbau technisch (nicht für Gereäteinfosätze)
*07-Ausbau technisch (nicht für Geräteinfosätze )

* inm_DI_INT *********************************************>>>>>>>
  MOVE x_htger-action TO inm_di_int-action.

  CASE x_htger-action.

    WHEN '01'.                                  "01-Einbau gesamt
*   Kommt nicht vor (Geräteinfosätze)

    WHEN '02'.                                  "02-Ausbau gesamt
*   Kommt nicht vor (Geräteinfosatz)

    WHEN '03'.                                              "03-Wechsel
*     Vorgangsdatum
      MOVE x_htger-ab TO inm_di_int-eadat.
*     Anlage
      MOVE x_htger-anlage TO inm_di_int-anlage.

    WHEN '04'.                                 "04-Einbau abrechnungstechnisch
*     Vorgangsdatum
      IF x_htger-ab GE x_htger-ab_anlage.
        MOVE x_htger-ab TO inm_di_int-eadat.
      ELSE.

*       Beachte Beginn der Verträge in der Zukunft.
*        MOVE x_htger-ab_anlage TO inm_di_int-eadat.
        IF x_htger-ab_anlage LE sy-datum.
          MOVE x_htger-ab_anlage TO inm_di_int-eadat.
        ELSE.
          MOVE x_htger-ab TO inm_di_int-eadat.
        ENDIF.

      ENDIF.
*     Anlage
      MOVE x_htger-anlage TO inm_di_int-anlage.

    WHEN '05'.                                "05-Ausbau abrechnungstechnisch
*     Vorgangsdatum
**     --> Nuss WBD 13.11.2015
*      MOVE x_htger-ab TO inm_di_int-eadat.      "Nuss auskommentiert 13.11.2015
      MOVE x_htger-bis TO inm_di_int-eadat.
      ADD 1 TO inm_di_int-eadat.
*      <-- Nuss 13.11.2015
*     Anlage
      MOVE x_htger-anlage TO inm_di_int-anlage.

    WHEN '06'.                               "06-Einbau technisch
*     Kommt nicht vor (Geräteinfosatz)

    WHEN '07'.                               "07-Ausbau technisch
*     Kommt nicht vor (Geräteinfosatz)

  ENDCASE.

  MOVE  inm_di_int-eadat TO v_datum.
  APPEND inm_di_int.
  CLEAR  inm_di_int.
* inm_DI_INT **********************************************<<<<<<<<


* inm_DI_GER **********************************************>>>>>>>>
  CLEAR inm_di_ger.

* Sparte
  MOVE x_htger-sparte           TO inm_di_ger-sparte.

* Gerätenummern
  IF  x_htger-action  EQ  '05'." Ausbau abr.technisch
    MOVE   x_htger-equnr  TO  inm_di_ger-equnralt.
    MOVE  'X'              TO  inm_di_ger-ausbau.
  ENDIF.

  IF  x_htger-action  EQ  '03'.   " Wechsel
    MOVE   x_htger-equnr        TO  inm_di_ger-equnrneu.
    MOVE   x_htger-equnr_alt    TO  inm_di_ger-equnralt.
  ENDIF.

  IF x_htger-action  EQ  '04'." Einbau abr.technisch
    MOVE   x_htger-equnr        TO  inm_di_ger-equnrneu.
  ENDIF.

* Gerätewechsel (Vorgangsgrund)
  IF  x_htger-action  EQ  '03'. " Wechsel
    MOVE   x_htger-gerwechs      TO  inm_di_ger-gerwechs.
  ENDIF.

*GVERRECHG (Verrechnungspreis zahlen), KONDIGRG(Tariffaktengruppe) usw.
  IF   x_htger-action  EQ  '03'  OR " Wechsel
       x_htger-action  EQ  '04'.    " Einbau abr.technisch
    MOVE   x_htger-gverrech        TO  inm_di_ger-gverrechg.
    MOVE   x_htger-kondigr         TO  inm_di_ger-kondigrg.
    MOVE   x_htger-preiskla        TO  inm_di_ger-preisklag.
    MOVE   x_htger-tarifart        TO  inm_di_ger-tarifartg.

*!!!! Diese Felder werden bei Wechsel auf der Beladeseite
*     wieder gelöscht. Werden aber für den abrechnungtech. Einbau
*     wegen Anlagendoppelung benötigt
  ENDIF.

  APPEND inm_di_ger.
  CLEAR  inm_di_ger.
* inm_DI_GER **********************************************<<<<<<<<


* inm_DI_ZW ***********************************************>>>>>>>
  CLEAR: ieasts, ietdz, ieabl, dat_aus.
  REFRESH: ieasts, ietdz, ieabl.
  CLEAR inm_di_zw.


*-----------------------------------------------------------
* Einbau abr.technisch  plus  Wechsel
*-----------------------------------------------------------
  IF  x_htger-action  EQ  '03'  OR " Wechsel
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
      IF ieasts_h-logikzw NE logikzw_h.
        MOVE-CORRESPONDING ieasts_h TO ieasts.
        APPEND ieasts.
      ENDIF.
      MOVE ieasts_h-logikzw TO logikzw_h.
    ENDLOOP.

    SELECT * FROM etdz INTO TABLE ietdz
                        WHERE equnr = x_htger-equnr
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

        CLEAR inm_di_zw.

*       Abrechnungsfaktor
*        CLEAR                   inm_di_zw-abrfakte.
        MOVE x_htger-abrfakt  TO inm_di_zw-abrfakte.
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

*         Beachte Vertragsbeginn in der Zukunft
*          MOVE x_htger-ab_anlage TO dat_vor.
          IF x_htger-ab_anlage LE sy-datum.
            MOVE x_htger-ab_anlage TO dat_vor.
          ELSE.
            MOVE x_htger-ab TO dat_vor.
          ENDIF.

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

        IF x_htger-action  NE  '03'.                      " kein Wechsel
*         hochgerechneten Periodenverbrauch ermitteln
          CLEAR verbrauch.
*         Hochrechnungsdatum ermitteln:

**         Für die Hochrechnung jüngstes Datum nach dem Einbau nehmen
*          hochdat = wa_eabl-adat + 365.
          CLEAR ieabl2.
          REFRESH ieabl2.
          hilfs_dat = dat_vor - 1.
          SELECT * FROM eabl INTO TABLE ieabl2
               WHERE equnr = x_htger-equnr
                 AND zwnummer = ietdz-zwnummer
                 AND adat GE hilfs_dat.

          SORT ieabl2 BY adat DESCENDING.
          LOOP AT ieabl2.
            hochdat = ieabl2-adat + 365.
            EXIT.
          ENDLOOP.

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
*                x_ablbelnr = wa_eabl-ablbelnr
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



        IF  x_htger-action  EQ  '04'.                        "   Einbau abr.technisch
*         Zählwerk nicht ablesen
          MOVE ietdz-nablesen  TO inm_di_zw-nablesene.
*         Steuergruppe für  Auftragserst. bei zeitvariablen Ablesungen
          MOVE ietdz-steuergrp  TO inm_di_zw-steuergrpe.
        ENDIF.

*
        IF  x_htger-action  EQ  '03'  OR    " Wechsel
            x_htger-action  EQ  '04'.       " Einbau abr.technisch

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
  IF  x_htger-action  EQ  '05'. " Ausbau abr.technisch

*    MOVE  x_htger-ab  TO  dat_aus.
*    SUBTRACT  1  FROM  dat_aus.


    MOVE x_htger-bis TO dat_aus.

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
  IF  x_htger-action  EQ  '04'.    " Einbau abr.technisch
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

** Bei Einbauten mit Nullablesungen in der Zukunft
** wird das Vorgangsdatum um einen Tag zurückgesetzt.
** Wenn der Netzbetreiber später eine MSCONS schickt
** mit dem tatsächlichen Ablesergebnis, könnte dieses
** nicht mehr erfasst werden.
  CLEAR no_zero.
  READ TABLE inm_di_int INDEX 1.

  IF inm_di_int-eadat GT sy-datum.
    LOOP AT inm_di_zw WHERE zwstandce NE 0.
      no_zero = 'X'.
    ENDLOOP.
    IF no_zero IS INITIAL.
      LOOP AT inm_di_int.
        inm_di_int-eadat = ( inm_di_int-eadat - 1 ).
        MODIFY inm_di_int INDEX sy-tabix.
      ENDLOOP.
    ENDIF.
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
  PERFORM fill_inm_inf_out  USING oldkey_inm
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
