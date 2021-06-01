FUNCTION /adesso/mte_fill_ht_ger_neu.
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
*"      NO_DEVICE
*"----------------------------------------------------------------------
* Der Fuba ermittelt für das Migrationsobjekt INST_MGMT die
* Ein-/Ausbauten sowie die Wechsel von Geräteinfosätzen pro Anlage und schreibt
* das Ergebnis in der Tabelle /ADESSO/MTE_HTGE fort.
* Die Vorgänge bekommen ein Kennzeichen analog zu der Aktion
* (H=03, P=04, A=05)
* Bei der Entladung INST_MGMT muß der Tabelleninhalt nach AB-Datum
* und Vorgang sortiert werden und in der ermittelten Reihenfolge die
* Equipmentnummern entsprechend den Vorgängen abgearbeitet werden.


  TABLES: /adesso/mte_htge,
          /adesso/mte_dtab.          "Nuss 22.10.2015

  TABLES: eastl,
          easts,
          etdz,
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
  DATA: ieasts LIKE easts OCCURS 0 WITH HEADER LINE.
  DATA: iegerr  LIKE egerr OCCURS 0 WITH HEADER LINE.
  DATA: iegerr2 LIKE egerr OCCURS 0 WITH HEADER LINE.


** Für Geräteinfosätze
  DATA: iausbau_inf  LIKE egerr OCCURS 0 WITH HEADER LINE.
  DATA: ieinbau_inf  LIKE egerr OCCURS 0 WITH HEADER LINE.
  DATA: iwausbau_inf LIKE egerr OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF iweinbau_inf OCCURS 0.
          INCLUDE STRUCTURE egerr.
  DATA: equnr_alt LIKE egerr-equnr.
  DATA: END OF iweinbau_inf.

  DATA: ieastl LIKE eastl OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF iequi OCCURS 0,
          equnr LIKE egerr-equnr,
        END OF iequi.

  DATA: BEGIN OF ietdz OCCURS 0,
          equnr   LIKE etdz-equnr,
          logikzw LIKE etdz-logikzw,
          zwfakt  LIKE etdz-zwfakt,     "Nuss 19.11.2012
        END OF ietdz.
  DATA: wetdz LIKE LINE OF ietdz.

  RANGES: r_logiknr FOR egerr-logiknr.
  RANGES: r_logikzw FOR easts-logikzw.
  RANGES: r_equnr   FOR equi-equnr.

  DATA: datum LIKE sy-datum.
  DATA: h_logiknr LIKE egerr-logiknr,
        h_sparte  LIKE eanl-sparte.

** --> Nuss 17.03.2016 für WBD
  DATA: ls_erch TYPE erch,
        lt_erch TYPE STANDARD TABLE OF erch,
        wa_erch TYPE erch.
** <-- Nuss 17.03.2016

  CLEAR: r_logiknr, r_equnr, ieastl, iequi, r_logikzw, sparte, vstelle.
  REFRESH: r_logiknr, r_equnr, ieastl, iequi, r_logikzw.

* Initialisierungen für Geräteinfosatz
  CLEAR:    iausbau_inf, ieinbau_inf, iweinbau_inf.
  REFRESH:  iausbau_inf, ieinbau_inf, iweinbau_inf.

  CLEAR: anz_obj, meldung, ihtger.
  REFRESH: meldung, ihtger.

* --> Nuss 22.10.2015
* Beginndatum des Geräts ermitteln

  SELECT SINGLE * FROM /adesso/mte_dtab.
  IF sy-subrc = 0.
    p_beginn = /adesso/mte_dtab-datab.
    p_beginn = p_beginn + 1.
  ELSE.
* <-- Nuss 22.10.2015



*   Ermitteln des Datums, ab wann die Anlage aufgebaut werden soll.
*   Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
*   Anlage noch nie abgerechnet wurde, wird die Anlage mit dem
*   Einzugsdatum des zugeordneteten Vertrages migriert.
    CLEAR ls_erch.                               "Nuss 17.03.2016
    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
      EXPORTING
        x_anlage          = x_anlage
      IMPORTING
*       y_begabrpe        = p_beginn
        y_previous_bill   = ls_erch               "Nuss 17.03.2016
        y_default_date    = p_beginn              "Nuss 13.11.2015
      EXCEPTIONS
        no_contract_found = 1
        general_fault     = 2
        parameter_fault   = 3
        OTHERS            = 4.

*   Wenn kein Beginn der Abrechnungsperiode ermittelt werden
*   konnte (es existiert kein Folgevertrag), dann raus
*   Es werden für diese Anlage keine Geräte eingebaut.
    IF sy-subrc = 0 AND
       p_beginn IS INITIAL.
      RAISE no_device.
    ENDIF.

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
**  --> Nuss 17.03.2016 für WBD
**  Bei Zwischenabrechnungen den Folgetag der letzten Turnusabrechnung holen
    ELSE.
      IF ls_erch-abrvorg = '02'.
        CLEAR lt_erch.
        SELECT * FROM erch INTO TABLE lt_erch
          WHERE vertrag = ls_erch-vertrag
           AND abrvorg = '01'
           AND erchc_v = 'X'
           AND simulation = ' '
           AND stornodat = '00000000'.
        IF lt_erch IS NOT INITIAL.
          SORT lt_erch BY endabrpe DESCENDING.
          READ TABLE lt_erch INTO wa_erch INDEX 1.
          p_beginn = ( wa_erch-endabrpe + 1 ).
**      Es lag noch keine Turnusabrechnung vor
        ELSE.
          SELECT SINGLE einzdat FROM ever INTO p_beginn
            WHERE anlage = x_anlage
              AND einzdat LE sy-datum
              AND auszdat GE sy-datum.
        ENDIF.
      ENDIF.
**  <-- Nuss 17.03.2016
    ENDIF.

  ENDIF.                                  "Nuss 22.10.2015

* -----------Arbeits-Tabellen für die eine ANLAGE aufbauen ------------
* 1. Mit Zeitscheiben der abr.techn.  eingebauten Geräteinfosätze   --> iegerr, iegerr2
* Zu der Anlage aller betroffenen Logiknr aus EASTL lesen
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

  LOOP AT ieastl.
    MOVE 'I'                           TO r_logiknr-sign.
    MOVE 'EQ'                          TO r_logiknr-option.
    MOVE ieastl-logiknr                TO r_logiknr-low.
    APPEND r_logiknr.
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
*   IEGERR2 - Geräteinfosätze in die parallele Tab. transpotieren
    SELECT * FROM egerr INTO TABLE iegerr2
      WHERE equnr IN r_equnr
        AND  bis   GE p_beginn
             AND ( einbdat NE '00000000' OR
                ausbdat NE '00000000' ).

  ELSE.
    meldung-meldung =
  'keine Historie zum Geräteinfosatz vorhanden (Tabelle EGERR)'.
    APPEND meldung.
    RAISE no_history.
  ENDIF.

****** Aufbau der Arbeitstabellen mit Gerätebewegungen *********>>>>

*---- AUSBAU (auch im Wechselrahmen)---------------------------->>>>

*    Aufbau folgender Tabellen:
* 1. IAUSBAU_INF  - Reine Ausbauprozesse
* 2. IWEINBAU_INF - Einbau innerhalb eines Wechsels
* 3. IWAUSBAU_INF - Ausbau innerhalb eines Wechsels

  LOOP AT iegerr2 WHERE ausbdat IS NOT INITIAL.
*     Verarbeitung der Geräte, die in der Abr. Periode ausgebaut wurden
*     Ermitteln des Geräteplatzes und der logischen Gerätenummer
*     als er noch eingebaut war
    CLEAR: datum, h_logiknr.
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
      MOVE h_logiknr TO iwausbau_inf-logiknr.
      APPEND iwausbau_inf.

      MOVE-CORRESPONDING iegerr   TO iweinbau_inf. "Wechsel-Einbau
      MOVE iegerr2-equnr TO iweinbau_inf-equnr_alt.
      APPEND iweinbau_inf.

      EXIT.
    ENDLOOP.

*     Es gab nur den Ausbau
    IF sy-subrc NE 0.
*   --> Nuss 13.11.2015 WBD
*     Das Gerät muss vorher aber auch eingebaut werden
      MOVE-CORRESPONDING iegerr2 TO ieinbau_inf .
      APPEND ieinbau_inf.
*  <-- Nuss 13.11.2015

      MOVE-CORRESPONDING iegerr2  TO iausbau_inf.  "Ausbau
      APPEND iausbau_inf.
    ENDIF.

  ENDLOOP.
*---- AUSBAU ----------------------------------------------------<<<<<

*---- EINBAU (ohne Wechselbegleitung)---------------------------->>>>>
*   Aufbau der Tabelle
* 1 IEINBAU_INF - Reine Einbauprozesse
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
  SELECT equnr logikzw zwfakt FROM etdz INTO TABLE ietdz
                   WHERE equnr   IN r_equnr
                   AND logikzw   IN r_logikzw
                     AND bis     GE  p_beginn.

  SORT ietdz BY equnr logikzw.
  DELETE ADJACENT DUPLICATES FROM ietdz COMPARING ALL FIELDS .


* Sparte ermitteln
  SELECT SINGLE sparte vstelle INTO (sparte, vstelle)
                    FROM eanl WHERE anlage = x_anlage.


* ---------- Füllen der DB-Hilfstabelle mit Gerätebewegungen ---------

* Vorgang   Action   Text
*  H          03  Wechsel
*  P          04  Einbau abrechnungstechnisch
*  A          05  Ausbau abrechnungstechnisch



* Einbau -------------------------------------------------------------
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

    LOOP AT ieastl WHERE logiknr = ieinbau_inf-logiknr
                     AND bis    GE dat_vor
                     AND ab     LE ieinbau_inf-bis.

      counter2 = counter2 + 1.

      IF counter2 = 1.
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

    LOOP AT ietdz WHERE equnr = ieinbau_inf-equnr
                    AND logikzw  IN r_logikzw.
      CLEAR counter.

*     Abrechnungsfaktor übernehmen
      MOVE ietdz-zwfakt TO ihtger-abrfakt.

      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND bis     GE dat_vor
                       AND ab      LE ieinbau_inf-bis.

        counter = counter + 1.

        IF counter > 1.
*       Kennzeichen für Tarifänderung auf Zählwerksebene
          MOVE 'T' TO ihtger-kennz_tzw.
          EXIT.
        ENDIF.
      ENDLOOP.


    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.

  ENDLOOP.

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


*   Vorgangsdatum
    CLEAR dat_vor.
    IF iweinbau_inf-ab GE p_beginn.
      MOVE iweinbau_inf-ab TO dat_vor.
    ELSE.
      MOVE p_beginn TO dat_vor.
    ENDIF.


    SORT ieastl BY ab.
    CLEAR counter2.

* Tarifdaten auf Geräteebene ermitteln und vielleicht auch Tarifwechsel
    LOOP AT ieastl WHERE logiknr = iweinbau_inf-logiknr
                     AND bis    GE dat_vor
                     AND ab     LE iweinbau_inf-bis.

      counter2 = counter2 + 1.

      IF counter2 = 1.
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
    LOOP AT ietdz WHERE equnr = iweinbau_inf-equnr
                    AND logikzw  IN r_logikzw.
      CLEAR counter.

**    Abrechnungsfaktor aus der ETDZ
      MOVE ietdz-zwfakt TO ihtger-abrfakt.

      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND bis     GE dat_vor
                       AND ab      LE iweinbau_inf-bis.

        counter = counter + 1.

        IF counter > 1.
*       Kennzeichen für Tarifänderung auf Zählwerksebene
          MOVE 'T' TO ihtger-kennz_tzw.
          EXIT.
        ENDIF.
      ENDLOOP.

* Prüfen, ob genau zum Wechseltag eine Tarifänderung stattgefunden hat
      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND ab      EQ dat_vor.
*       Kennzeichen für Tarifänderung auf Zählwerksebene
        MOVE 'T' TO ihtger-kennz_tzw.
        EXIT.
      ENDLOOP.

    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.

  ENDLOOP.

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

**  WECHSEL-AUSBAU -- muss zunächst eingebaut werden.
  LOOP AT iwausbau_inf.
    MOVE-CORRESPONDING iwausbau_inf TO ihtger.
    MOVE sparte TO ihtger-sparte.
    MOVE vstelle TO ihtger-vstelle.
    MOVE x_anlage TO ihtger-anlage.
    MOVE p_beginn TO ihtger-ab_anlage.
    MOVE 'P' TO ihtger-vorgang. "Einbau abrechnungstechnisch
    MOVE '04' TO ihtger-action.

*     Vorgangsdatum
    CLEAR dat_vor.
    IF iwausbau_inf-ab GE p_beginn.
      MOVE iwausbau_inf-ab TO dat_vor.
    ELSE.
      MOVE p_beginn TO dat_vor.
    ENDIF.

* Tarifdaten auf Geräteebene ermitteln und vielleicht auch Tarifwechsel
    SORT ieastl BY ab.
    CLEAR counter2.

    LOOP AT ieastl WHERE logiknr = iwausbau_inf-logiknr
                     AND bis    GE dat_vor
                     AND ab     LE iwausbau_inf-bis.

      counter2 = counter2 + 1.

      IF counter2 = 1.
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

* Gibt es Tarifänderungen auf Zählwerksebene ???* Gibt es Tarifänderungen auf Zählwerksebene ???

    LOOP AT ietdz WHERE equnr = iwausbau_inf-equnr
                    AND logikzw  IN r_logikzw.
      CLEAR counter.

*     Abrechnungsfaktor übernehmen
      MOVE ietdz-zwfakt TO ihtger-abrfakt.

      LOOP AT ieasts WHERE logikzw = ietdz-logikzw
                       AND bis     GE dat_vor
                       AND ab      LE iwausbau_inf-bis.

        counter = counter + 1.

        IF counter > 1.
*       Kennzeichen für Tarifänderung auf Zählwerksebene
          MOVE 'T' TO ihtger-kennz_tzw.
          EXIT.
        ENDIF.
      ENDLOOP.


    ENDLOOP.

    APPEND ihtger.
    CLEAR ihtger.


  ENDLOOP.


* >>>>> Prüfung ob Satz schon existiert, dann alles
*       abrechnungstechnische aufbauen
* Es kann passieren, dass das Gerät in einer Anlage mit
* Gesamt-Einbau oder Wechsel oder Gesamt-Ausbau schon
* weggeschrieben wurde, das gleiche Gerät aber auch noch
* abrechnungstechnisch in einer anderen Anlage hängt.
* Wenn das passiert, muss das Gerät auch nochmal
* abrechnungstechnisch aufgebaut werden.

***  LOOP AT ihtger.
***    SELECT SINGLE * FROM /adesso/mte_htge
***             WHERE equnr   = ihtger-equnr
***               AND vorgang = ihtger-vorgang
***               AND ab      = ihtger-ab
***               AND bis     = ihtger-bis.
***    IF sy-subrc EQ 0.
***      BREAK-POINT.
***      CASE ihtger-vorgang.
***
***        WHEN 'H'. "Wechsel
*****         nichts tun, da der abrechn.techn Einbau bei Wechselvorgang
*****         automatisch in allen zugehörigen Anlagen erfolgt und er
*****         deshalb nur einmal erfolgen braucht
***          DELETE ihtger.                                    "KLE090305
***
***        WHEN OTHERS.
*****        Abrechnungstechnischer Einbau oder Ausbau
***          CONTINUE.
***      ENDCASE.
***    ENDIF.
***  ENDLOOP.

* Anfügen der Datensätze des abrechnungstechnischen Ausbaus bei Wechsel
*  LOOP AT ihtger_aa.
*    MOVE-CORRESPONDING ihtger_aa TO ihtger.
*    APPEND ihtger.
*  ENDLOOP.
*<<<<<

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
