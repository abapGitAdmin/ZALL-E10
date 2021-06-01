FUNCTION /adesso/mte_fill_ht_ger.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_ANLAGE) LIKE  EANL-ANLAGE
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      WRONG_DATA
*"      NO_UPDATE
*"      ERROR
*"      NO_HISTORY
*"----------------------------------------------------------------------

* Der Fuba ermittelt für das Migrationsobjekt INST_MGMT die
* Ein-/Ausbauten sowie die Wechsel von Geräten pro Anlage und schreibt
* das Ergebnis in der Tabelle /ADESSO/MTE_HTGE fort.
* Die Vorgänge bekommen ein Kennzeichen analog zu der Aktion
* (N=01, B=02,H=03,P=04,A=05,O=06,C=07)
* Bei der Entladung INST_MGMT muß der Tabelleninhalt nach AB-Datum
* und Vorgang sortiert werden und in der ermittelten Reihenfolge die
* Equipmentnummern entsprechend den Vorgängen abgearbeitet werden.


  TABLES: /adesso/mte_htge.

  TABLES: eastl,
          easts,
          egerh,
          equi,
          egers,
          v_eger,
          v_equi,
          etdz,
          easte,
          ezuz,
          eanlh,
          eanl,
          egerr.

  DATA: p_beginn        LIKE  sy-datum.
  DATA: sparte LIKE eanl-sparte.
  DATA: vstelle LIKE eanl-vstelle.
  DATA: lfdnr(1) TYPE n.
  DATA: counter TYPE i.
  DATA: dat_vor LIKE sy-datum.
  DATA: counter2 TYPE i.

  DATA: ihtger LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
  DATA: ihtger_aa LIKE /adesso/mte_htge OCCURS 0 WITH HEADER LINE.
  DATA: iveger LIKE v_eger OCCURS 0 WITH HEADER LINE.
  DATA: iegerh LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: iegerh2 LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: ieasts LIKE easts OCCURS 0 WITH HEADER LINE.
  DATA: iegerr  LIKE egerr OCCURS 0 WITH HEADER LINE.
  DATA: iegerr2 LIKE egerr OCCURS 0 WITH HEADER LINE.

* interne Tabellen für Einbau/Ausbau/Wechsel
  DATA: iausbau      LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: ieinbau      LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: iwausbau     LIKE egerh OCCURS 0 WITH HEADER LINE.
*  DATA: iweinbau     LIKE egerh OCCURS 0 WITH HEADER LINE.


  DATA: BEGIN OF iweinbau OCCURS 0.
          INCLUDE STRUCTURE egerh.
  DATA: equnr_alt LIKE egerh-equnr.
  DATA: END OF iweinbau.

** Benötigte Datendeklarationen für Ermittlung des Beginndatums
** bei Sparte Gas (2 Anlagen am Zählpunkt)
  DATA: ieuiinstln TYPE ieuiinstln.
  DATA: wa_euiinstln LIKE euiinstln.
  DATA: anlage1 TYPE anlage.
  DATA: anlage2 TYPE anlage.
  DATA: h_datum1 TYPE sy-datum.
  DATA: h_datum2 TYPE sy-datum.


** Für Geräteinfosätze eigene Tabellen
** Um Inkonsistenzen zu vermeiden, gleiche Struktur wie Geräte
  DATA: iausbau_inf  LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: ieinbau_inf  LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: iwausbau_inf LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF iweinbau_inf OCCURS 0.
          INCLUDE STRUCTURE egerh.
  DATA: equnr_alt LIKE egerh-equnr.
  DATA: END OF iweinbau_inf.


  DATA: ieastl LIKE eastl OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF iequi OCCURS 0,
         equnr LIKE egerh-equnr,
        END OF iequi.

  DATA: BEGIN OF ietdz OCCURS 0,
         equnr LIKE etdz-equnr,
         logikzw LIKE etdz-logikzw,
        END OF ietdz.
  DATA: wetdz LIKE LINE OF ietdz.

  RANGES: r_logiknr FOR egerh-logiknr.
  RANGES: r_logikzw FOR easts-logikzw.
  RANGES: r_equnr   FOR equi-equnr.

  DATA: datum LIKE sy-datum.
  DATA: h_logiknr LIKE egerh-logiknr,
        h_devloc  LIKE egerh-devloc,
        h_sparte  LIKE eanl-sparte.


* Bei Sparte 03 (Wasser) wird GVERRECH auf Zählwerksebene übernommen
  DATA:
       wa_easts LIKE easts,
       it_easts LIKE TABLE OF wa_easts,
       anz_easts TYPE i,
       wa_egerh TYPE egerh,
       it_egerh LIKE TABLE OF wa_egerh,
       anz_egerh TYPE i,
       wa_etdz TYPE etdz,
       it_etdz LIKE TABLE OF wa_etdz,
       anz_etdz TYPE i.


  CLEAR: r_logiknr, r_equnr, iegerh, iegerh2, iausbau, ieinbau,
         iweinbau, ieastl, iequi, r_logikzw, sparte, vstelle.
  REFRESH: r_logiknr, r_equnr, iegerh, iegerh2, iausbau, ieinbau,
         iweinbau, ieastl, iequi, r_logikzw.


* Initialisierungen für Geräteinfosatz
  CLEAR:    iausbau_inf, ieinbau_inf, iweinbau_inf.
  REFRESH:  iausbau_inf, ieinbau_inf, iweinbau_inf.


  CLEAR: anz_obj, meldung, ihtger, ihtger_aa.
  REFRESH: meldung, ihtger, ihtger_aa.




*  AB-Datum aus Tabelle /ADESSO/MTE_DTAB
  SELECT SINGLE * FROM /adesso/mte_dtab.
  IF sy-subrc = 0.
    p_beginn = /adesso/mte_dtab-datab.
  ELSE.

*   Ermitteln des Datums, ab wann die Anlage aufgebaut werden soll.
*   Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
*   Anlage noch nie abgerechnet wurde, wird die Anlage mit dem
*   Einzugsdatum des zugeordneteten Vertrages migriert.
    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
      EXPORTING
        x_anlage          = x_anlage
      IMPORTING
        y_default_date    = p_beginn
      EXCEPTIONS
        no_contract_found = 1
        general_fault     = 2
        parameter_fault   = 3
        OTHERS            = 4.
    IF sy-subrc <> 0.
      IF sy-subrc EQ 1 AND
         p_beginn IS INITIAL.
        SELECT SINGLE * FROM eanlh WHERE anlage = x_anlage
                                     AND bis    = '99991231'.
        IF sy-subrc EQ 0.
          MOVE eanlh-ab TO p_beginn.
        ELSE.
          meldung-meldung =
            'Es ist kein Anlagen-Beginndatum zu ermitteln'.
          APPEND meldung.
          RAISE wrong_data.
        ENDIF.

      ELSE.
        meldung-meldung =
          'Es ist kein Anlagen-Beginndatum zu ermitteln'.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.
    ENDIF.


  ENDIF.


* -----------Arbeits-Tabellen für die eine ANLAGE aufbauen ------------
* 1. Mit Zeitscheiben der abr.techn.  eingebauten Geräte     --> iegerh
* 2. Mit Zeitscheiben der auch nur techn. eingebauten Geräte --> iegerh2
* 3. Parallel ähnliche Tabellen für egerr und egerr2
*
* Zu der Anlage aller betrofffenen Logiknr aus EASTL lesen
  SELECT * FROM eastl INTO TABLE ieastl
                   WHERE anlage  EQ  x_anlage
                     AND logiknr NE  '0'
                     AND bis     GE  p_beginn.
  IF sy-subrc NE 0.
    meldung-meldung =
      'keine Geräte zur Anlage vorhanden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* IEGERH-Tabelle mit abr. techn. eingebauten Geräten aufbauen
* (alle Geräte, als sie in der Anlage drin waren)
  LOOP AT ieastl.
    MOVE 'I'                           TO r_logiknr-sign.
    MOVE 'EQ'                          TO r_logiknr-option.
    MOVE ieastl-logiknr                TO r_logiknr-low.
    APPEND r_logiknr.
  ENDLOOP.

  SELECT * FROM egerh INTO TABLE iegerh
      WHERE logiknr IN r_logiknr
        AND bis     GE p_beginn
        AND ( einbdat NE '00000000' OR
              ausbdat NE '00000000' ).

* Range-Tabelle mit Equipment-Nummer (Hilfstabelle für weitere Selektion)
  LOOP AT iegerh.
    MOVE 'I'                           TO r_equnr-sign.
    MOVE 'EQ'                          TO r_equnr-option.
    MOVE iegerh-equnr                  TO r_equnr-low.
    APPEND r_equnr.
  ENDLOOP.

* IEGERR-Tabelle mit abr. techn. eingebauten Gerinfosätzen aufbauen
* (alle Geräte, die in der Anlage drin waren)
  SELECT * FROM egerr INTO TABLE iegerr
     WHERE logiknr  IN r_logiknr
      AND bis     GE p_beginn
      AND ( einbdat NE '00000000' OR
            ausbdat NE '00000000' ).

* Range-Tabelle um die Gerinfosaätze ergänzen
  LOOP AT iegerr.
    MOVE 'I'              TO r_equnr-sign.
    MOVE 'EQ'             TO r_equnr-option.
    MOVE iegerr-equnr     TO r_equnr-low.
    APPEND r_equnr.
  ENDLOOP.

  IF NOT r_equnr IS INITIAL.
*   IEGERH2-Tabelle mit allen Zeitscheiben der Geräte;
*   auch die technische Einbau-ZS
*   (alle Geräte einschließlich Ausbau-Zeitscheiben)
    SELECT * FROM egerh INTO TABLE iegerh2
        WHERE equnr   IN r_equnr
          AND bis     GE p_beginn
          AND ( einbdat NE '00000000' OR
                ausbdat NE '00000000' ).

*   IEGERR2 - Geräteinfosätze in die parallele Tab. transpotieren
    SELECT * FROM egerr INTO TABLE iegerr2
      WHERE equnr IN r_equnr
        AND  bis   GE p_beginn
             AND ( einbdat NE '00000000' OR
                ausbdat NE '00000000' ).

  ELSE.
    meldung-meldung =
  'keine Historie zum Gerät vorhanden (Tabelle EGERH; EGERR)'.
    APPEND meldung.
    RAISE no_history.
  ENDIF.

****** Aufbau der Arbeitstabellen mit Gerätebewegungen *********>>>>

*---- AUSBAU (auch im Wechselrahmen)---------------------------->>>>

*    Aufbau folgender Tabellen:
* 1. IAUSBAU  - Reine Ausbauprozesse
* 2. IWEINBAU - Einbau innerhalb eines Wechsels
* 3. IWAUSBAU - Ausbau innerhalb eines Wechsels

  LOOP AT iegerh2 WHERE NOT ausbdat IS INITIAL.
*   Verarbeitung der Geräte, die in der Abr. Periode ausgebaut wurden

*   Ermitteln des Geräteplatzes und der logischen Gerätenummer
*   als er noch eingebaut war
    CLEAR: datum, h_logiknr, h_devloc.
    datum = iegerh2-ausbdat - 1.

    LOOP AT iegerh  WHERE equnr EQ iegerh2-equnr
                      AND bis   EQ datum
                      AND NOT logiknr IS INITIAL.
      MOVE iegerh-logiknr TO h_logiknr.
      MOVE iegerh-devloc  TO h_devloc.
      EXIT.
    ENDLOOP.

    IF sy-subrc NE 0. "d.h. war in dieser Anlage nie eingebaut o. Zeits
*     Es sind keine Vorgängerdaten ermittelbar, d.h. es ist ein Ausbau
*     der eine andere Anlage betrifft oder liegt ausserhalb der Zeitscheibe
*     Der Satz wird für aktuelle Anlage nicht weiter verarbeitet.
      CONTINUE.
    ENDIF.


*   Ist zu diesem Zeitpunkt ein anderes Gerät eingebaut worden, also
*   Gerätewechsel ?
    LOOP AT iegerh WHERE equnr NE iegerh2-equnr
                      AND logiknr EQ h_logiknr
                      AND einbdat EQ iegerh2-ausbdat
                      AND ausbdat IS INITIAL.

*     Es gab gleichzeitig einen Einbau;
*     Füllen der Wechsel-Arbeitstabellen
      MOVE-CORRESPONDING iegerh2  TO iwausbau. "Wechsel-Ausbau
      MOVE h_devloc TO iwausbau-devloc.
      MOVE h_logiknr TO iwausbau-logiknr.
      APPEND iwausbau.

      MOVE-CORRESPONDING iegerh   TO iweinbau. "Wechsel-Einbau
      MOVE iegerh2-equnr TO iweinbau-equnr_alt.
      APPEND iweinbau.

      EXIT.
    ENDLOOP.

*   Es gab nur den Ausbau
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING iegerh2  TO iausbau.  "Ausbau
      IF iausbau-devloc EQ space.
        MOVE h_devloc TO iausbau-devloc.
        MOVE h_logiknr TO iausbau-logiknr.
      ENDIF.
      APPEND iausbau.
    ENDIF.

  ENDLOOP.

* Obiges Coding mit der gleichen Logik für Geräteinfosätze,
* Nur wenn IEGERH2 leer ist

*    Aufbau folgender Tabellen:
* 1. IAUSBAU_INF  - Reine Ausbauprozesse
* 2. IWEINBAU_INF - Einbau innerhalb eines Wechsels
* 3. IWAUSBAU_INF - Ausbau innerhalb eines Wechsels

  IF iegerh2 IS INITIAL.
    LOOP AT iegerr2 WHERE NOT ausbdat IS INITIAL.
*     Verarbeitung der Geräte, die in der Abr. Periode ausgebaut wurden

*     Ermitteln des Geräteplatzes und der logischen Gerätenummer
*     als er noch eingebaut war
      CLEAR: datum, h_logiknr, h_devloc.
      datum = iegerr2-ausbdat - 1.

      LOOP AT iegerr  WHERE equnr EQ iegerr2-equnr
                        AND bis   EQ datum
                        AND NOT logiknr IS INITIAL.
        MOVE iegerr-logiknr TO h_logiknr.
        EXIT.
      ENDLOOP.

      IF sy-subrc NE 0. "d.h. war in dieser Anlage nie eingebaut o. Zeits
*       Es sind keine Vorgängerdaten ermittelbar, d.h. es ist ein Ausbau
*       der eine andere Anlage betrifft oder liegt ausserhalb der Zeitscheibe
*       Der Satz wird für aktuelle Anlage nicht weiter verarbeitet.
        CONTINUE.
      ENDIF.

*     Ist zu diesem Zeitpunkt ein anderes Gerät eingebaut worden, also
*     Gerätewechsel ?
      LOOP AT iegerr WHERE equnr NE iegerr2-equnr
                        AND logiknr EQ h_logiknr
                        AND einbdat EQ iegerr2-ausbdat
                        AND ausbdat IS INITIAL.

*       Es gab gleichzeitig einen Einbau;
*       Füllen der Wechsel-Arbeitstabellen
        MOVE-CORRESPONDING iegerr2  TO iwausbau_inf. "Wechsel-Ausbau
*       MOVE h_devloc TO iwausbau_inf-devloc.
        MOVE h_logiknr TO iwausbau_inf-logiknr.
        APPEND iwausbau_inf.

        MOVE-CORRESPONDING iegerr   TO iweinbau_inf. "Wechsel-Einbau
        MOVE iegerr2-equnr TO iweinbau_inf-equnr_alt.
        APPEND iweinbau_inf.

        EXIT.
      ENDLOOP.

*     Es gab nur den Ausbau
      IF sy-subrc NE 0.
        MOVE-CORRESPONDING iegerr2  TO iausbau_inf.  "Ausbau
        IF iausbau_inf-devloc EQ space.
          MOVE h_devloc TO iausbau_inf-devloc.
          MOVE h_logiknr TO iausbau_inf-logiknr.
        ENDIF.
        APPEND iausbau_inf.
      ENDIF.

    ENDLOOP.
  ENDIF.
*---- AUSBAU ----------------------------------------------------<<<<<

*---- EINBAU (ohne Wechselbegleitung)---------------------------->>>>>
*    Aufbau der Tabelle
* 1  IEINBAU  - Reine Einbauprozesse
  LOOP AT iegerh WHERE ausbdat IS INITIAL.

* Gegenprüfen, ob Equipment Wechseleinbau ist
    READ TABLE iweinbau WITH KEY equnr   = iegerh-equnr
                                 bis     = iegerh-bis
                                 ab      = iegerh-ab
                                 logiknr = iegerh-logiknr
                                 einbdat = iegerh-einbdat.
    IF sy-subrc NE 0.
* steht nicht in Wechseltabelle => reiner Einbau
      MOVE-CORRESPONDING iegerh TO ieinbau. "Einbau
      APPEND ieinbau.
    ENDIF.

  ENDLOOP.

*** --> Nuss 26.05.2008/2
*** reiner Einbau, wenn Geräteinfosätze
  IF iegerh IS INITIAL.
    LOOP AT iegerr WHERE ausbdat IS INITIAL.

* Gegenprüfen, ob Equipment Wechseleinbau ist
      READ TABLE iweinbau_inf WITH KEY equnr   = iegerr-equnr
                                       bis     = iegerr-bis
                                       ab      = iegerr-ab
                                       logiknr = iegerr-logiknr
                                       einbdat = iegerr-einbdat.
      IF sy-subrc NE 0.
* steht nicht in Wechseltabelle => reiner Einbau
        MOVE-CORRESPONDING iegerr TO ieinbau_inf. "Einbau
        APPEND ieinbau_inf.
      ENDIF.

    ENDLOOP.
  ENDIF.
*** <-- Ende Nuss 26.05.2008/2

*<< Einbau, Ausbau und Wechsel ermitteln


* Ermitteln der zugehörigen logischen Zählwerksnummern
* zu der Anlage (aus EASTS lesen)
  SELECT * FROM easts INTO TABLE ieasts
                   WHERE anlage  EQ  x_anlage
                     AND logikzw NE  '0'
                     AND bis     GE  p_beginn.

  LOOP AT ieasts.
    MOVE 'I'                           TO r_logikzw-sign.
    MOVE 'EQ'                          TO r_logikzw-option.
    MOVE ieasts-logikzw                TO r_logikzw-low.
    APPEND r_logikzw.
  ENDLOOP.

* Ermitteln der logischen Zählwerksnummern zum Gerät
  SELECT equnr logikzw FROM etdz INTO TABLE ietdz
                   WHERE equnr   IN r_equnr
                   AND logikzw   IN r_logikzw
                     AND bis     GE  p_beginn.

  SORT ietdz BY equnr logikzw.
  DELETE ADJACENT DUPLICATES FROM ietdz COMPARING ALL FIELDS .


* Sparte ermitteln
  SELECT SINGLE sparte vstelle INTO (sparte, vstelle)
                    FROM eanl WHERE anlage = x_anlage.


* ---------- Füllen der DB-Hilfstabelle mit Gerätebewegungen ---------
* !! bei Abwasseranlage werden alle Vorgänge nur abrechnungstechnisch
* verarbeitet (muß noch eingebaut werden). Dann muss auch die interne
* Tabelle iwausbau betrachtet werden (wg. abrechnungstechnischer Ausbau)


* Vorgang   Action   Text
*  N          01  Einbau gesamt
*  B          02  Ausbau gesamt
*  H          03  Wechsel
*  P          04  Einbau abrechnungstechnisch
*  A          05  Ausbau abrechnungstechnisch
*  O          06  Einbau technisch
*  C          07  Ausbau technisch
*             08  Storno technischer Einbau
*             09  Storno technischer Ausbau
*             10  Storno technischer Wechsel
*             11  Storno technischer Einbau, Ausbau, Wechsel


*if sparte ne '60'.

* Einbau -------------------------------------------------------------
  LOOP AT ieinbau.
    MOVE-CORRESPONDING ieinbau TO ihtger.
    MOVE sparte TO ihtger-sparte.
    MOVE vstelle TO ihtger-vstelle.
    MOVE x_anlage TO ihtger-anlage.
    MOVE p_beginn TO ihtger-ab_anlage.
    MOVE 'N' TO ihtger-vorgang. "Einbau gesamt
    MOVE '01' TO ihtger-action.

*     Vorgangsdatum
    CLEAR dat_vor.
    IF ieinbau-ab GE p_beginn.
      MOVE ieinbau-ab TO dat_vor.
    ELSE.
      MOVE p_beginn TO dat_vor.
    ENDIF.


* Tarifdaten auf Geräteebene ermitteln und vielleicht auch Tarifwechsel
    SORT ieastl BY ab.
    CLEAR counter2.
*>------------------------------------------------------------KLE200904
*    LOOP AT ieastl WHERE logiknr = ieinbau-logiknr
**                     AND ab BETWEEN ieinbau-ab and ieinbau-bis.
*                     AND ab BETWEEN dat_vor and ieinbau-bis.

    LOOP AT ieastl WHERE logiknr = ieinbau-logiknr
                     AND bis    GE dat_vor
                     AND ab     LE ieinbau-bis.
*<------------------------------------------------------------KLE200904

      counter2 = counter2 + 1.

*      IF ieastl-ab = ieinbau-ab.  "Kle 14.09.04
      IF counter2 = 1.
        MOVE ieastl-preiskla TO ihtger-preiskla.
        MOVE ieastl-gverrech TO ihtger-gverrech.

**       > Aschoff 20.05.2008
*       Flag Verrechnungspreis Zahlen wird für Sparte Wasser
*       auf Zählwerksebene ermittelt.
        IF ihtger-sparte = '03'.

*         Gerätenummer ermitteln
          CLEAR it_egerh.
          SELECT * FROM egerh INTO TABLE it_egerh
            WHERE logiknr = ieinbau-logiknr
              AND bis GE dat_vor
              AND ab  LE ieinbau-bis.

          CLEAR anz_egerh.
          DESCRIBE TABLE it_egerh LINES anz_egerh.

**         Zählwerknummern ermitteln
          IF anz_egerh > 0.
            CLEAR it_etdz.
            SELECT * FROM etdz INTO TABLE it_etdz
              FOR ALL ENTRIES IN it_egerh
              WHERE equnr = it_egerh-equnr
                AND bis >= it_egerh-bis.

          ENDIF.

          CLEAR anz_etdz.
          DESCRIBE TABLE it_etdz LINES anz_etdz.

*         Zählwerke ermitteln
          IF anz_etdz > 0.
            SELECT * FROM easts
              INTO TABLE it_easts
              FOR ALL ENTRIES IN it_etdz
              WHERE anlage = x_anlage
                AND logikzw = it_etdz-logikzw
                AND bis     >= it_etdz-bis.
          ENDIF.

          CLEAR anz_easts.
          DESCRIBE TABLE it_easts LINES anz_easts.
          IF anz_easts > 1.
            WRITE: / 'Bitte prüfen: Für Anlage ',
                     ieastl-anlage,
                     ' Gerätenummer', ieinbau-logiknr,
                     ' Bis-Datum ', ieinbau-bis,
                     ' ist die eindeutige Zuordnung eines Zählwerks nicht möglich.'.

          ELSE.
            CLEAR wa_easts.
            LOOP AT it_easts INTO wa_easts.
              MOVE wa_easts-gverrech TO ihtger-gverrech.
              MOVE wa_easts-preiskla TO ihtger-preiskla.    "MAK230508
              CLEAR wa_easts.
            ENDLOOP.
          ENDIF.

        ENDIF.
*     < Aschoff 20.05.2008

        MOVE ieastl-tarifart TO ihtger-tarifart.
        MOVE ieastl-kondigr  TO ihtger-kondigr.

* Messdruck und Abrechnungsfaktor ermitteln
        SELECT SINGLE * FROM ezuz WHERE logiknr2 = ieinbau-logiknr
                                    AND      bis = '99991231'.
        IF sy-subrc EQ 0.
          MOVE ezuz-messdrck TO ihtger-messdrck.
          MOVE ezuz-abrfakt  TO ihtger-abrfakt.
        ELSE.
* Messdruck und Abrechnungsfaktor ermitteln
          SELECT SINGLE * FROM ezuz WHERE logiknr2 = ieinbau-logiknr
                                      AND      bis GE ieinbau-ab
                                     AND ( messdrck NE 0 OR
                                           abrfakt  NE 0 ).

          IF sy-subrc EQ 0.
            MOVE ezuz-messdrck TO ihtger-messdrck.
            MOVE ezuz-abrfakt  TO ihtger-abrfakt.

** --> Nuss 28.05.2008
** Weitere Prüfung:
** Es kann sich um ein Gerät handeln, das von einem Druckregler geregelt wird
** In LOGIKNR2 steht nicht das Gerät selbst
** Gerät über LOGIKZW ermitteln

          ELSE.
            CLEAR wetdz.
            READ TABLE ietdz INTO wetdz
              WITH KEY equnr = ieinbau-equnr.
            IF sy-subrc EQ 0.
              SELECT SINGLE * FROM ezuz WHERE logikzw = wetdz-logikzw
                           AND bis = '99991231'
                          AND ( messdrck NE 0 OR
                            abrfakt NE 0 ).
              IF sy-subrc EQ 0.
                MOVE ezuz-messdrck TO ihtger-messdrck.
                MOVE ezuz-abrfakt  TO ihtger-abrfakt.
              ENDIF.

** --> Nuss 30.05.2008
** Über Logiknr2 aus der EZUZ die Equipmentnummer des Druckregles
** aus der EGERH lesen.
              IF sy-subrc = 0.
                CLEAR wa_egerh.
                SELECT * FROM egerh INTO wa_egerh
                  WHERE logiknr = ezuz-logiknr2
                   AND bis      = '99991231'.
                  EXIT.
                ENDSELECT.
                MOVE wa_egerh-equnr TO ihtger-drucknre.
              ENDIF.
** <-- Nuss 30.05.2008
            ENDIF.
** <-- Nuss 28.05.2008

          ENDIF.

        ENDIF.

      ELSE.
*   wenn es noch einen zweiten Satz innerhalb der Zeitscheibe gibt, dann
*   Kennzeichen für Tarifänderung in Tabelle schreiben (Geräteebene)
        MOVE 'T' TO ihtger-kennz_tg.
      ENDIF.
    ENDLOOP.

    CLEAR counter.

* Gibt es Tarifänderungen auf Zählwerksebene ???
*>------------------------------------------------------------KLE200904
*    LOOP AT ieasts WHERE logikzw IN r_logikzw
**                     AND ab BETWEEN ieinbau-ab and ieinbau-bis.
*                     AND ab BETWEEN dat_vor and ieinbau-bis.


    LOOP AT ietdz WHERE equnr = ieinbau-equnr
                    AND logikzw  IN r_logikzw.
      CLEAR counter.

      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND bis     GE dat_vor
                       AND ab      LE ieinbau-bis.

        counter = counter + 1.
*        LOOP AT ietdz WHERE equnr = ieinbau-equnr
*                        AND logikzw = ieasts-logikzw.
*        ENDLOOP.
*        IF sy-subrc EQ 0 and counter > 1.
        IF counter > 1.
*<------------------------------------------------------------KLE200904
*       Kennzeichen für Tarifänderung auf Zählwerksebene
          MOVE 'T' TO ihtger-kennz_tzw.
          EXIT.
        ENDIF.
      ENDLOOP.                                              "KLE200904

*      IF ieasts-ab = ieinbau-ab.
**    Zählwerkstarife zum Vorgangsdatum (keine Tarifänderung)
*      ELSE.
** wenn eine Zeitscheibe für das Gerät mit den zugehörigen logischen
** Zählwerksnummen existiert, wo das AB-Datum ungleich dem Vorgangsdatum
** liegt, dann existiert eine Tarifänderung auf Zählerebene (denk ich)
*        LOOP AT ietdz WHERE equnr = ieinbau-equnr
*                        AND logikzw = ieasts-logikzw.
**       Kennzeichen für Tarifänderung auf Zählwerksebene
*          MOVE 'T' TO ihtger-kennz_tzw.
*        ENDLOOP.
*        IF sy-subrc EQ 0.
*          EXIT.
*        ENDIF.
*      ENDIF.

    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.

  ENDLOOP.



** --> Nuss 26.05.2008/2
* Einbau Geräteinfosatz-----------------------------------------------------
* Nur Abrechnungstechnischer Einbau
  LOOP AT ieinbau_inf.
    MOVE-CORRESPONDING ieinbau_inf TO ihtger.
    MOVE sparte TO ihtger-sparte.
    MOVE vstelle TO ihtger-vstelle.
    MOVE x_anlage TO ihtger-anlage.
    MOVE p_beginn TO ihtger-ab_anlage.
    MOVE 'P' TO ihtger-vorgang. "Einbau abrechnungstechnisch
    MOVE '04' TO ihtger-action.

*     Vorgangsdatum
    CLEAR dat_vor.
    IF ieinbau_inf-ab GE p_beginn.
      MOVE ieinbau_inf-ab TO dat_vor.
    ELSE.
      MOVE p_beginn TO dat_vor.
    ENDIF.


* Tarifdaten auf Geräteebene ermitteln und vielleicht auch Tarifwechsel
    SORT ieastl BY ab.
    CLEAR counter2.
*>------------------------------------------------------------KLE200904
*    LOOP AT ieastl WHERE logiknr = ieinbau-logiknr
**                     AND ab BETWEEN ieinbau-ab and ieinbau-bis.
*                     AND ab BETWEEN dat_vor and ieinbau-bis.

    LOOP AT ieastl WHERE logiknr = ieinbau_inf-logiknr
                     AND bis    GE dat_vor
                     AND ab     LE ieinbau_inf-bis.
*<------------------------------------------------------------KLE200904

      counter2 = counter2 + 1.

*      IF ieastl-ab = ieinbau-ab.  "Kle 14.09.04
      IF counter2 = 1.
        MOVE ieastl-preiskla TO ihtger-preiskla.
        MOVE ieastl-gverrech TO ihtger-gverrech.

        MOVE ieastl-tarifart TO ihtger-tarifart.
        MOVE ieastl-kondigr  TO ihtger-kondigr.

* Messdruck und Abrechnungsfaktor ermitteln
        SELECT SINGLE * FROM ezuz WHERE logiknr2 = ieinbau_inf-logiknr
                                    AND      bis = '99991231'.
        IF sy-subrc EQ 0.
          MOVE ezuz-messdrck TO ihtger-messdrck.
          MOVE ezuz-abrfakt  TO ihtger-abrfakt.
        ELSE.
* Messdruck und Abrechnungsfaktor ermitteln
          SELECT SINGLE * FROM ezuz WHERE logiknr2 = ieinbau_inf-logiknr
                                      AND      bis GE ieinbau_inf-ab
                                     AND ( messdrck NE 0 OR
                                           abrfakt  NE 0 ).

          IF sy-subrc EQ 0.
            MOVE ezuz-messdrck TO ihtger-messdrck.
            MOVE ezuz-abrfakt  TO ihtger-abrfakt.

** --> Nuss 28.05.2008
** Weitere Prüfung:
** Es kann sich um ein Gerät handeln, das von einem Druckregler geregelt wird
** In LOGIKNR2 steht nicht das Gerät selbst
** Gerät über LOGIKZW ermitteln

          ELSE.
            CLEAR wetdz.
            READ TABLE ietdz INTO wetdz
              WITH KEY equnr = ieinbau_inf-equnr.
            IF sy-subrc EQ 0.
              SELECT SINGLE * FROM ezuz WHERE logikzw = wetdz-logikzw
                           AND bis = '99991231'
                          AND ( messdrck NE 0 OR
                            abrfakt NE 0 ).
              IF sy-subrc EQ 0.
                MOVE ezuz-messdrck TO ihtger-messdrck.
                MOVE ezuz-abrfakt  TO ihtger-abrfakt.
              ENDIF.
            ENDIF.
** --> Nuss 30.05.2008
** Über Logiknr2 aus der EZUZ die Equipmentnummer des Druckregles
** aus der EGERH lesen.
            IF sy-subrc = 0.
              CLEAR wa_egerh.
              SELECT * FROM egerh INTO wa_egerh
                WHERE logiknr = ezuz-logiknr2
                 AND bis      = '99991231'.
                EXIT.
              ENDSELECT.
              MOVE wa_egerh-equnr TO ihtger-drucknre.
            ENDIF.
** <-- Nuss 30.05.2008



** <-- Nuss 28.05.2008
          ENDIF.

        ENDIF.

      ELSE.
*   wenn es noch einen zweiten Satz innerhalb der Zeitscheibe gibt, dann
*   Kennzeichen für Tarifänderung in Tabelle schreiben (Geräteebene)
        MOVE 'T' TO ihtger-kennz_tg.
      ENDIF.
    ENDLOOP.

    CLEAR counter.

* Gibt es Tarifänderungen auf Zählwerksebene ???
*>------------------------------------------------------------KLE200904
*    LOOP AT ieasts WHERE logikzw IN r_logikzw
**                     AND ab BETWEEN ieinbau-ab and ieinbau-bis.
*                     AND ab BETWEEN dat_vor and ieinbau-bis.


    LOOP AT ietdz WHERE equnr = ieinbau_inf-equnr
                    AND logikzw  IN r_logikzw.
      CLEAR counter.

      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND bis     GE dat_vor
                       AND ab      LE ieinbau_inf-bis.

        counter = counter + 1.
*        LOOP AT ietdz WHERE equnr = ieinbau-equnr
*                        AND logikzw = ieasts-logikzw.
*        ENDLOOP.
*        IF sy-subrc EQ 0 and counter > 1.
        IF counter > 1.
*<------------------------------------------------------------KLE200904
*       Kennzeichen für Tarifänderung auf Zählwerksebene
          MOVE 'T' TO ihtger-kennz_tzw.
          EXIT.
        ENDIF.
      ENDLOOP.                                              "KLE200904

*      IF ieasts-ab = ieinbau-ab.
**    Zählwerkstarife zum Vorgangsdatum (keine Tarifänderung)
*      ELSE.
** wenn eine Zeitscheibe für das Gerät mit den zugehörigen logischen
** Zählwerksnummen existiert, wo das AB-Datum ungleich dem Vorgangsdatum
** liegt, dann existiert eine Tarifänderung auf Zählerebene (denk ich)
*        LOOP AT ietdz WHERE equnr = ieinbau-equnr
*                        AND logikzw = ieasts-logikzw.
**       Kennzeichen für Tarifänderung auf Zählwerksebene
*          MOVE 'T' TO ihtger-kennz_tzw.
*        ENDLOOP.
*        IF sy-subrc EQ 0.
*          EXIT.
*        ENDIF.
*      ENDIF.

    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.

  ENDLOOP.
** <-- Nuss 26.05.2008/2



*Wechsel--------------------------------------------------------------
  LOOP AT iweinbau.
    MOVE-CORRESPONDING iweinbau TO ihtger.
    MOVE iweinbau-equnr_alt TO ihtger-equnr_alt.
    MOVE sparte TO ihtger-sparte.
    MOVE vstelle TO ihtger-vstelle.
    MOVE x_anlage TO ihtger-anlage.
    MOVE p_beginn TO ihtger-ab_anlage.
    MOVE 'H' TO ihtger-vorgang. "Wechsel
    MOVE '03' TO ihtger-action.


*     Vorgangsdatum
    CLEAR dat_vor.
    IF iweinbau-ab GE p_beginn.
      MOVE iweinbau-ab TO dat_vor.
    ELSE.
      MOVE p_beginn TO dat_vor.
    ENDIF.


    SORT ieastl BY ab.
    CLEAR counter2.
* Tarifdaten auf Geräteebene ermitteln und vielleicht auch Tarifwechsel
*>------------------------------------------------------------KLE200904
*    LOOP AT ieastl WHERE logiknr = iweinbau-logiknr
**                     AND ab BETWEEN iweinbau-ab and iweinbau-bis.
*                     AND ab BETWEEN dat_vor and iweinbau-bis.

    LOOP AT ieastl WHERE logiknr = iweinbau-logiknr
                     AND bis    GE dat_vor
                     AND ab     LE iweinbau-bis.
*<------------------------------------------------------------KLE200904

      counter2 = counter2 + 1.

      IF counter2 = 1.
*      IF ieastl-ab = iweinbau-ab.
        MOVE ieastl-preiskla TO ihtger-preiskla.
        MOVE ieastl-gverrech TO ihtger-gverrech.

*       > Aschoff 20.05.2008
*       Flag Verrechnungspreis Zahlen wird für Sparte Wasser
*       auf Zählwerksebene ermittelt.
        IF ihtger-sparte = '03'.

*         Gerätenummern ermitteln
          CLEAR it_egerh.
          SELECT * FROM egerh INTO TABLE it_egerh
            WHERE logiknr = iweinbau-logiknr
              AND bis GE dat_vor
              AND ab  LE iweinbau-bis.

          CLEAR anz_egerh.
          DESCRIBE TABLE it_egerh LINES anz_egerh.

*         Zählwerknumern ermitteln
          IF anz_egerh > 0.
            CLEAR it_etdz.
            SELECT * FROM etdz INTO TABLE it_etdz
              FOR ALL ENTRIES IN it_egerh
              WHERE equnr = it_egerh-equnr
                AND bis >= it_egerh-bis.

          ENDIF.

          CLEAR anz_etdz.
          DESCRIBE TABLE it_etdz LINES anz_etdz.

*         Zählwerke ermitteln
          IF anz_etdz > 0.
            SELECT * FROM easts
              INTO TABLE it_easts
              FOR ALL ENTRIES IN it_etdz
              WHERE anlage = x_anlage
                AND logikzw = it_etdz-logikzw
                AND bis     >= it_etdz-bis.
          ENDIF.

          CLEAR anz_easts.
          DESCRIBE TABLE it_easts LINES anz_easts.
          IF anz_easts > 1.
            WRITE: / 'Bitte prüfen: Für Anlage ',
                     ieastl-anlage,
                     ' Gerätenummer', ieinbau-logiknr,
                     ' Bis-Datum ', ieinbau-bis,
                     ' ist die eindeutige Zuordnung eines Zählwerks nicht möglich.'.

          ELSE.
            CLEAR wa_easts.
            LOOP AT it_easts INTO wa_easts.
              MOVE wa_easts-gverrech TO ihtger-gverrech.
              CLEAR wa_easts.
            ENDLOOP.
          ENDIF.

        ENDIF.
*     < Aschoff 20.05.2008
        MOVE ieastl-tarifart TO ihtger-tarifart.
        MOVE ieastl-kondigr  TO ihtger-kondigr.
      ELSE.
*   wenn es noch einen zweiten Satz innerhalb der Zeitscheibe gibt, dann
*   Kennzeichen für Tarifänderung in Tabelle schreiben (Geräteebene)
        MOVE 'T' TO ihtger-kennz_tg.
      ENDIF.
    ENDLOOP.





    CLEAR counter.
* Gibt es Tarifänderungen auf Zählwerksebene ???
*>------------------------------------------------------------KLE200904
*    LOOP AT ieasts WHERE logikzw IN r_logikzw
**                     AND ab BETWEEN iweinbau-ab and iweinbau-bis.
*                     AND ab BETWEEN dat_vor and iweinbau-bis.


    LOOP AT ietdz WHERE equnr = iweinbau-equnr
                    AND logikzw  IN r_logikzw.
      CLEAR counter.

      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND bis     GE dat_vor
                       AND ab      LE iweinbau-bis.

        counter = counter + 1.
*        LOOP AT ietdz WHERE equnr = ieinbau-equnr
*                        AND logikzw = ieasts-logikzw.
*        ENDLOOP.
*        IF sy-subrc EQ 0 and counter > 1.
        IF counter > 1.
*<------------------------------------------------------------KLE200904
*       Kennzeichen für Tarifänderung auf Zählwerksebene
          MOVE 'T' TO ihtger-kennz_tzw.
          EXIT.
        ENDIF.
      ENDLOOP.                                              "KLE200904

*> KLE 10.01.2005
* Prüfen, ob genau zum Wechseltag eine Tarifänderung stattgefunden hat
      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND ab      EQ dat_vor.
*       Kennzeichen für Tarifänderung auf Zählwerksebene
        MOVE 'T' TO ihtger-kennz_tzw.
        EXIT.
      ENDLOOP.                                              "KLE200904
*< KLE 10.01.2005


*      IF ieasts-ab = iweinbau-ab.
**    nur Zählwerkstarife zum Vorgangsdatum (keine Tarifänderung)
*      ELSE.
** wenn eine Zeitscheibe für das Gerät mit den zugehörigen logischen
** Zählwerksnummen existiert, wo das AB-Datum ungleich dem Vorgangsdatum
** liegt, dann existiert eine Tarifänderung auf Zählerebene (denk ich)
*        LOOP AT ietdz WHERE equnr = iweinbau-equnr
*                        AND logikzw = ieasts-logikzw.
**       Kennzeichen für Tarifänderung auf Zählwerksebene
*          MOVE 'T' TO ihtger-kennz_tzw.
*        ENDLOOP.
*        IF sy-subrc EQ 0.
*          EXIT.
*        ENDIF.
*      ENDIF.
    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.

  ENDLOOP.

** --> Nuss 26.05.2008/2
*Wechsel Geräteinfosatz----------------------------------------------------------
  LOOP AT iweinbau_inf.
    MOVE-CORRESPONDING iweinbau_inf TO ihtger.
    MOVE iweinbau_inf-equnr_alt TO ihtger-equnr_alt.
    MOVE sparte TO ihtger-sparte.
    MOVE vstelle TO ihtger-vstelle.
    MOVE x_anlage TO ihtger-anlage.
    MOVE p_beginn TO ihtger-ab_anlage.
    MOVE 'H' TO ihtger-vorgang. "Wechsel
    MOVE '03' TO ihtger-action.


*     Vorgangsdatum
    CLEAR dat_vor.
    IF iweinbau_inf-ab GE p_beginn.
      MOVE iweinbau_inf-ab TO dat_vor.
    ELSE.
      MOVE p_beginn TO dat_vor.
    ENDIF.


    SORT ieastl BY ab.
    CLEAR counter2.
* Tarifdaten auf Geräteebene ermitteln und vielleicht auch Tarifwechsel
*>------------------------------------------------------------KLE200904
*    LOOP AT ieastl WHERE logiknr = iweinbau-logiknr
**                     AND ab BETWEEN iweinbau-ab and iweinbau-bis.
*                     AND ab BETWEEN dat_vor and iweinbau-bis.

    LOOP AT ieastl WHERE logiknr = iweinbau-logiknr
                     AND bis    GE dat_vor
                     AND ab     LE iweinbau-bis.
*<------------------------------------------------------------KLE200904

      counter2 = counter2 + 1.

      IF counter2 = 1.
*      IF ieastl-ab = iweinbau-ab.
        MOVE ieastl-preiskla TO ihtger-preiskla.
        MOVE ieastl-gverrech TO ihtger-gverrech.

        MOVE ieastl-tarifart TO ihtger-tarifart.
        MOVE ieastl-kondigr  TO ihtger-kondigr.
      ELSE.
*   wenn es noch einen zweiten Satz innerhalb der Zeitscheibe gibt, dann
*   Kennzeichen für Tarifänderung in Tabelle schreiben (Geräteebene)
        MOVE 'T' TO ihtger-kennz_tg.
      ENDIF.
    ENDLOOP.





    CLEAR counter.
* Gibt es Tarifänderungen auf Zählwerksebene ???
*>------------------------------------------------------------KLE200904
*    LOOP AT ieasts WHERE logikzw IN r_logikzw
**                     AND ab BETWEEN iweinbau-ab and iweinbau-bis.
*                     AND ab BETWEEN dat_vor and iweinbau-bis.


    LOOP AT ietdz WHERE equnr = iweinbau_inf-equnr
                    AND logikzw  IN r_logikzw.
      CLEAR counter.

      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND bis     GE dat_vor
                       AND ab      LE iweinbau_inf-bis.

        counter = counter + 1.
*        LOOP AT ietdz WHERE equnr = ieinbau-equnr
*                        AND logikzw = ieasts-logikzw.
*        ENDLOOP.
*        IF sy-subrc EQ 0 and counter > 1.
        IF counter > 1.
*<------------------------------------------------------------KLE200904
*       Kennzeichen für Tarifänderung auf Zählwerksebene
          MOVE 'T' TO ihtger-kennz_tzw.
          EXIT.
        ENDIF.
      ENDLOOP.                                              "KLE200904

*> KLE 10.01.2005
* Prüfen, ob genau zum Wechseltag eine Tarifänderung stattgefunden hat
      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND ab      EQ dat_vor.
*       Kennzeichen für Tarifänderung auf Zählwerksebene
        MOVE 'T' TO ihtger-kennz_tzw.
        EXIT.
      ENDLOOP.                                              "KLE200904
*< KLE 10.01.2005


*      IF ieasts-ab = iweinbau-ab.
**    nur Zählwerkstarife zum Vorgangsdatum (keine Tarifänderung)
*      ELSE.
** wenn eine Zeitscheibe für das Gerät mit den zugehörigen logischen
** Zählwerksnummen existiert, wo das AB-Datum ungleich dem Vorgangsdatum
** liegt, dann existiert eine Tarifänderung auf Zählerebene (denk ich)
*        LOOP AT ietdz WHERE equnr = iweinbau-equnr
*                        AND logikzw = ieasts-logikzw.
**       Kennzeichen für Tarifänderung auf Zählwerksebene
*          MOVE 'T' TO ihtger-kennz_tzw.
*        ENDLOOP.
*        IF sy-subrc EQ 0.
*          EXIT.
*        ENDIF.
*      ENDIF.
    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.

  ENDLOOP.
*** <-- Nuss 26.05.2008/2


* Ausbau----------------------------------------------------------------
  LOOP AT iausbau.
    MOVE-CORRESPONDING iausbau TO ihtger.
    MOVE sparte TO ihtger-sparte.
    MOVE vstelle TO ihtger-vstelle.
    MOVE x_anlage TO ihtger-anlage.
    MOVE p_beginn TO ihtger-ab_anlage.
    MOVE 'B' TO ihtger-vorgang. "Ausbau gesammt
    MOVE '02' TO ihtger-action.

* Tarifdaten auf Geräteebene ermitteln
* Wird bei Ausbau sicher nicht benötigt (wird aber trotzdem mal gefüllt
* falls was vorhanden)
    LOOP AT ieastl WHERE logiknr = iausbau-logiknr
                     AND ab BETWEEN iausbau-ab AND iausbau-bis.

      IF ieastl-ab = iausbau-ab.
        MOVE ieastl-preiskla TO ihtger-preiskla.
        MOVE ieastl-gverrech TO ihtger-gverrech.

*       > Aschoff 20.05.2008
*       Flag Verrechnungspreis Zahlen wird für Sparte Wasser
*       auf Zählwerksebene ermittelt.
        IF ihtger-sparte = '03'.

*         Gerätenummern ermitteln
          CLEAR it_egerh.
          SELECT * FROM egerh INTO TABLE it_egerh
            WHERE logiknr = iausbau-logiknr
              AND bis GE dat_vor
              AND ab  LE iausbau-bis.

          CLEAR anz_egerh.
          DESCRIBE TABLE it_egerh LINES anz_egerh.

*         Zählwerknummern ermitteln
          IF anz_egerh > 0.
            CLEAR it_etdz.
            SELECT * FROM etdz INTO TABLE it_etdz
              FOR ALL ENTRIES IN it_egerh
              WHERE equnr = it_egerh-equnr
                AND bis >= it_egerh-bis.

          ENDIF.

          CLEAR anz_etdz.
          DESCRIBE TABLE it_etdz LINES anz_etdz.

*         Zählwerke ermitteln
          IF anz_etdz > 0.
            SELECT * FROM easts
              INTO TABLE it_easts
              FOR ALL ENTRIES IN it_etdz
              WHERE anlage = x_anlage
                AND logikzw = it_etdz-logikzw
                AND bis     >= it_etdz-bis.
          ENDIF.

          CLEAR anz_easts.
          DESCRIBE TABLE it_easts LINES anz_easts.
          IF anz_easts > 1.
            WRITE: / 'Bitte prüfen: Für Anlage ',
                     ieastl-anlage,
                     ' Gerätenummer', ieinbau-logiknr,
                     ' Bis-Datum ', ieinbau-bis,
                     ' ist die eindeutige Zuordnung eines Zählwerks nicht möglich.'.

          ELSE.
            CLEAR wa_easts.
            LOOP AT it_easts INTO wa_easts.
              MOVE wa_easts-gverrech TO ihtger-gverrech.
              CLEAR wa_easts.
            ENDLOOP.
          ENDIF.
        ENDIF.
*       < Aschoff 20.05.2008
        MOVE ieastl-tarifart TO ihtger-tarifart.
        MOVE ieastl-kondigr  TO ihtger-kondigr.
      ENDIF.


    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.

  ENDLOOP.

** --> Nuss 26.05.2008/2
* Ausbau Geräteinfosatz-------------------------------------------------------
  LOOP AT iausbau_inf.
    MOVE-CORRESPONDING iausbau_inf TO ihtger.
    MOVE sparte TO ihtger-sparte.
    MOVE vstelle TO ihtger-vstelle.
    MOVE x_anlage TO ihtger-anlage.
    MOVE p_beginn TO ihtger-ab_anlage.
    MOVE 'A' TO ihtger-vorgang. "Ausbau abrechnungstechnisch
    MOVE '05' TO ihtger-action.

* Tarifdaten auf Geräteebene ermitteln
* Wird bei Ausbau sicher nicht benötigt (wird aber trotzdem mal gefüllt
* falls was vorhanden)
    LOOP AT ieastl WHERE logiknr = iausbau_inf-logiknr
                     AND ab BETWEEN iausbau_inf-ab AND iausbau_inf-bis.

      IF ieastl-ab = iausbau_inf-ab.
        MOVE ieastl-preiskla TO ihtger-preiskla.
        MOVE ieastl-gverrech TO ihtger-gverrech.


        MOVE ieastl-tarifart TO ihtger-tarifart.
        MOVE ieastl-kondigr  TO ihtger-kondigr.
      ENDIF.


    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.

  ENDLOOP.
** <-- Nuss 26.05.2008/2




*endif. "Spartenabfrage

* >>>>> Prüfung ob Satz schon existiert, dann alles
*       abrechnungstechnische aufbauen
* Es kann passieren, dass das Gerät in einer Anlage mit
* Gesamt-Einbau oder Wechsel oder Gesamt-Ausbau schon
* weggeschrieben wurde, das gleiche Gerät aber auch noch
* abrechnungstechnisch in einer anderen Anlage hängt.
* Wenn das passiert, muss das Gerät auch nochmal
* abrechnungstechnisch aufgebaut werden.

  LOOP AT ihtger.
    SELECT SINGLE * FROM /adesso/mte_htge
             WHERE equnr   = ihtger-equnr
               AND vorgang = ihtger-vorgang
               AND ab      = ihtger-ab
               AND bis     = ihtger-bis.
    IF sy-subrc EQ 0.
      CASE ihtger-vorgang.
        WHEN 'N'. "Einbau gesamt
          MOVE 'P' TO ihtger-vorgang. "Einbau abrechnungstechn.
          MOVE '04' TO ihtger-action.
          CLEAR ihtger-messdrck.
          CLEAR ihtger-abrfakt.
          MODIFY ihtger.

        WHEN 'H'. "Wechsel

          DELETE ihtger.

        WHEN 'B'. "Ausbau gesamt
          MOVE 'A' TO ihtger-vorgang. "Ausbau abrechnungstechn.
          MOVE '05' TO ihtger-action.
          MODIFY ihtger.

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
    ENDIF.
  ENDLOOP.

* Anfügen der Datensätze des abrechnungstechnischen Ausbaus bei Wechsel
  LOOP AT ihtger_aa.
    MOVE-CORRESPONDING ihtger_aa TO ihtger.
    APPEND ihtger.
  ENDLOOP.


  READ TABLE ihtger INDEX 1.
  IF sy-subrc EQ 0.

* Daten in Tabelle schreiben
    INSERT  /adesso/mte_htge  FROM  TABLE  ihtger
        ACCEPTING DUPLICATE KEYS.
    IF sy-subrc NE 0.
      meldung-meldung =
        'Fehler beim INSERT in /adesso/mte_htge oder doppelte Schlüssel'.
      APPEND meldung.
      RAISE no_update.
    ENDIF.

    anz_obj = sy-dbcnt.
    COMMIT WORK.

  ENDIF.




ENDFUNCTION.
