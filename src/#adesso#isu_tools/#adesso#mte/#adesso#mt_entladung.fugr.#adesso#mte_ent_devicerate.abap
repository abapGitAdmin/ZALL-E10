FUNCTION /adesso/mte_ent_devicerate.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_HTGER) LIKE  /ADESSO/MTE_HTGE STRUCTURE
*"        /ADESSO/MTE_HTGE
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
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

  DATA: beg_dat LIKE sy-datum.


*  DATA: ieabl LIKE eabl OCCURS 0 WITH HEADER LINE.
*  data: wa_eablg like eablg.

  object   = 'DEVICERATE'.
  ent_file = pfad_dat_ent.

  DATA: ieasts LIKE easts OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF ietdz OCCURS 0,
         equnr LIKE etdz-equnr,
         logikzw LIKE etdz-logikzw,
        END OF ietdz.


  RANGES: r_logiknr FOR egerh-logiknr.
  RANGES: r_logikzw FOR easts-logikzw.

  DATA: ieastl LIKE eastl OCCURS 0 WITH HEADER LINE.
  DATA: iegerh LIKE egerh OCCURS 0 WITH HEADER LINE.
  DATA: iegerr LIKE egerr OCCURS 0 WITH HEADER LINE.


** Datendeklarationen für Ermittlung GVERECH bei Wasser
  DATA:  wa_easts LIKE easts,
         it_easts LIKE TABLE OF wa_easts,
         anz_easts TYPE i,
         wa_egerh TYPE egerh,
         it_egerh LIKE TABLE OF wa_egerh,
         anz_egerh TYPE i,
         wa_etdz TYPE etdz,
         it_etdz LIKE TABLE OF wa_etdz,
         anz_etdz TYPE i.

  DATA: counter TYPE i.
  DATA: counter2 TYPE i.




* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.



*>   Initialisierung
  CLEAR: idrt_drint, idrt_drdev, idrt_drreg,
         idrt_drint_h, idrt_drdev_h, idrt_drreg_h,
         oldkey_drt, idrt_out, wdrt_out,
         meldung, anz_obj, beg_dat,
         ieasts, ieastl, ietdz, r_logiknr, r_logikzw, iegerh.
  REFRESH: idrt_drint, idrt_drdev, idrt_drreg, idrt_out, meldung,
           ieasts, ieastl, ietdz, r_logiknr, r_logikzw, iegerh,
           idrt_drint_h, idrt_drdev_h, idrt_drreg_h.

*<


* Bestimmen des Beginn-Datums
  CASE x_htger-action.
    WHEN '01'. "01-Einbau gesamt
      IF x_htger-ab GE x_htger-ab_anlage.
        MOVE x_htger-ab TO beg_dat.
      ELSE.
        MOVE x_htger-ab_anlage TO beg_dat.
      ENDIF.
    WHEN '02'. "02-Ausbau gesamt
      MOVE x_htger-ab TO beg_dat.
    WHEN '03'.                                              "03-Wechsel
      MOVE x_htger-ab TO beg_dat.
    WHEN '04'. "04-Einbau abrechnungstechnisch
      IF x_htger-ab GE x_htger-ab_anlage.
        MOVE x_htger-ab TO beg_dat.
      ELSE.
        MOVE x_htger-ab_anlage TO beg_dat.
      ENDIF.
    WHEN '05'. "05-Ausbau abrechnungstechnisch
      MOVE x_htger-ab TO beg_dat.
    WHEN '06'. "06-Einbau technisch
      IF x_htger-ab GE x_htger-ab_anlage.
        MOVE x_htger-ab TO beg_dat.
      ELSE.
        MOVE x_htger-ab_anlage TO beg_dat.
      ENDIF.
    WHEN '07'. "07-Ausbau technisch
      MOVE x_htger-ab TO beg_dat.
  ENDCASE.

*> Datenermittlung ---------
* Es werden nur die Vorgänge: 01, 03 geprüft und ausgewertet
* bzw. in diesen FuBa übermittelt

* geplante Vorgehensweise
* Es werden die Tarifänderungen für ZW und GER getrennt betrachtet
* und der Stichtag im Kopf weggeschrieben. Doppelte Einträge werden
* gelöscht.
* Anschließend wird der Kopf nach Datum sortiert und alle zugehörigen
* Datensätze mit gleichem ab-Datum dazugelesen und in Datei geschrieben


* Tarifänderungen auf Geräteebene
  IF x_htger-kennz_tg = 'T'.

*> log. Gerätenummer ermitteln
    SELECT * FROM egerh INTO TABLE iegerh
        WHERE equnr   = x_htger-equnr
          AND bis     = x_htger-bis
          AND ab      = x_htger-ab.

    LOOP AT iegerh.
      MOVE 'I'                           TO r_logiknr-sign.
      MOVE 'EQ'                          TO r_logiknr-option.
      MOVE iegerh-logiknr                TO r_logiknr-low.
      APPEND r_logiknr.
    ENDLOOP.
*<

*** Wenn kein EGERH, dann für EGERR prüfen (Geräteinfosätze)
    IF iegerh IS INITIAL.
      SELECT * FROM egerr INTO TABLE iegerr
        WHERE equnr = x_htger-equnr
          AND   bis = x_htger-bis
          AND   ab  = x_htger-ab.

      LOOP AT iegerr.
        MOVE 'I'                     TO r_logiknr-sign.
        MOVE 'EQ'                    TO r_logiknr-option.
        MOVE iegerr-logiknr          TO r_logiknr-low.
        APPEND r_logiknr.
      ENDLOOP.
    ENDIF.

    SELECT * FROM eastl INTO TABLE ieastl
                     WHERE anlage  EQ  x_htger-anlage
                       AND logiknr IN  r_logiknr
                       AND bis     GE  beg_dat.

    SORT ieastl BY ab.
    CLEAR counter2.
* Tarifänderungen bestimmen
* Tarifdaten auf Geräteebene ermitteln bei Tarifwechsel



    LOOP AT ieastl WHERE bis    GE beg_dat
                     AND ab     LE x_htger-bis.


*      IF ieastl-ab = x_htger-ab.
*      ELSE.
*       if ieastl-ab > beg_dat.
      counter2 = counter2 + 1.
      IF counter2 > 1.
*   wenn es noch einen zweiten Satz innerhalb der Zeitscheibe gibt, dann
*   Datensatz für Tarifänderung in Tabelle schreiben (Geräteebene)
        MOVE ieastl-preiskla TO idrt_drdev_h-preiskla.
        MOVE ieastl-gverrech TO idrt_drdev_h-gverrech.

**     Flag Verrechnungspreis Zahlen wird für Sparte Wasser
**     auf Zählwerksebene ermittelt
        IF x_htger-sparte = '03'.
*       Gerätenummer ermitteln
          SELECT * FROM egerh INTO TABLE it_egerh
             WHERE logiknr = ieastl-logiknr
               AND  ab  GE ieastl-ab
               AND  bis GE ieastl-bis.

          CLEAR anz_egerh.
          DESCRIBE TABLE it_egerh LINES anz_egerh.

** Zählwerksnummern ermitteln.
          IF anz_egerh > 0.
            CLEAR: it_etdz.
            SELECT * FROM etdz INTO TABLE it_etdz
              FOR ALL ENTRIES IN it_egerh
                WHERE equnr = it_egerh-equnr
               AND   bis GE it_egerh-bis.
          ENDIF.

          CLEAR anz_etdz.
          DESCRIBE TABLE it_etdz LINES anz_etdz.

** Zählwerke ermitteln
          IF anz_etdz > 0.
            CLEAR it_easts.
            SELECT * FROM easts INTO TABLE it_easts
              FOR ALL ENTRIES IN it_etdz
                WHERE anlage = ieastl-anlage
                 AND  logikzw = it_etdz-logikzw
                 AND  bis GE it_etdz-bis.
          ENDIF.


        ENDIF.

        MOVE ieastl-tarifart TO idrt_drdev_h-tarifart.
        MOVE ieastl-kondigr  TO idrt_drdev_h-kondigr.
        MOVE x_htger-equnr   TO idrt_drdev_h-equnr.
        MOVE ieastl-ab       TO idrt_drdev_h-ab.
        MOVE ieastl-bis      TO idrt_drdev_h-bis.
        APPEND idrt_drdev_h.
        CLEAR idrt_drdev_h.
* Kopfsatz füllen
        MOVE x_htger-anlage   TO idrt_drint_h-anlage.
        MOVE ieastl-ab        TO idrt_drint_h-keydate.
        MOVE 'X'              TO idrt_drint_h-prorate.
        APPEND idrt_drint_h.
        CLEAR idrt_drint_h.
      ENDIF.
*       endif.
*      ENDIF.
    ENDLOOP.

  ENDIF.



* Tarifänderungen auf Zählwerksebene
  IF x_htger-kennz_tzw = 'T'.

* siehe auch FuBa fill_ht_ger
    SELECT * FROM easts INTO TABLE ieasts
                     WHERE anlage  EQ  x_htger-anlage
                       AND logikzw NE  '0'
                       AND bis     GE  beg_dat.

    LOOP AT ieasts.
      MOVE 'I'                           TO r_logikzw-sign.
      MOVE 'EQ'                          TO r_logikzw-option.
      MOVE ieasts-logikzw                TO r_logikzw-low.
      APPEND r_logikzw.
    ENDLOOP.

* Ermitteln der logischen Zählwerksnummern zum Gerät
    SELECT equnr logikzw FROM etdz INTO TABLE ietdz
                     WHERE equnr   =   x_htger-equnr
                     AND logikzw   IN  r_logikzw
                       AND bis     GE  beg_dat.

    SORT ietdz BY equnr logikzw.
    DELETE ADJACENT DUPLICATES FROM ietdz COMPARING ALL FIELDS .


    CLEAR counter.
    SORT ieasts BY ab.
* Gibt es Tarifänderungen auf Zählwerksebene ???
*    LOOP AT ieasts WHERE logikzw IN r_logikzw
*                     AND ab BETWEEN beg_dat and x_htger-bis.


*> Bei Wechsel auch noch genau zum Wechseldatum prüfen.
    IF x_htger-action = '03'.

      LOOP AT ieasts WHERE logikzw IN r_logikzw
                       AND ab     EQ beg_dat.

        LOOP AT ietdz WHERE equnr = x_htger-equnr
                        AND logikzw = ieasts-logikzw.
        ENDLOOP.
        IF sy-subrc EQ 0.
*       Datensätze für Tarifänderung auf Zählwerksebene
          SELECT SINGLE * FROM eadz
                        WHERE logikzw = ieasts-logikzw
                          AND bis     GE ieasts-ab.
          SELECT SINGLE * FROM etdz
                        WHERE logikzw = ieasts-logikzw
                          AND equnr = x_htger-equnr.

          MOVE-CORRESPONDING eadz   TO idrt_drreg_h.
          MOVE-CORRESPONDING etdz  TO idrt_drreg_h.
          MOVE-CORRESPONDING ieasts TO idrt_drreg_h.
          APPEND idrt_drreg_h.
          CLEAR idrt_drreg_h.
* Kopfsatz füllen
          MOVE x_htger-anlage   TO idrt_drint_h-anlage.
          MOVE ieasts-ab        TO idrt_drint_h-keydate.
          MOVE 'X'              TO idrt_drint_h-prorate.
          APPEND idrt_drint_h.
          CLEAR idrt_drint_h.
        ENDIF.

      ENDLOOP.

    ENDIF.
*< Bei Wechsel auch noch genau zum Wechseldatum prüfen.


    LOOP AT ieasts WHERE logikzw IN r_logikzw
                     AND bis    GE beg_dat
                     AND ab     LE x_htger-bis.

      counter = counter + 1.
      LOOP AT ietdz WHERE equnr = x_htger-equnr
                      AND logikzw = ieasts-logikzw.
      ENDLOOP.
      IF sy-subrc EQ 0 AND counter > 1.
        IF ieasts-ab > beg_dat.
*       Datensätze für Tarifänderung auf Zählwerksebene
          SELECT SINGLE * FROM eadz
                        WHERE logikzw = ieasts-logikzw
                          AND bis     GE ieasts-ab.
          SELECT SINGLE * FROM etdz
                        WHERE logikzw = ieasts-logikzw
                          AND equnr = x_htger-equnr.

          MOVE-CORRESPONDING eadz   TO idrt_drreg_h.
          MOVE-CORRESPONDING etdz  TO idrt_drreg_h.
          MOVE-CORRESPONDING ieasts TO idrt_drreg_h.
          APPEND idrt_drreg_h.
          CLEAR idrt_drreg_h.
* Kopfsatz füllen
          MOVE x_htger-anlage   TO idrt_drint_h-anlage.
          MOVE ieasts-ab        TO idrt_drint_h-keydate.
          MOVE 'X'              TO idrt_drint_h-prorate.
          APPEND idrt_drint_h.
          CLEAR idrt_drint_h.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDIF.

  SORT idrt_drint_h BY anlage keydate.
  DELETE ADJACENT DUPLICATES FROM idrt_drint_h COMPARING ALL FIELDS.


* füllen der Datensätze
  LOOP AT idrt_drint_h.

    CLEAR: idrt_drint, idrt_drdev, idrt_drreg,
           oldkey_drt, idrt_out, wdrt_out.
    REFRESH: idrt_drint, idrt_drdev, idrt_drreg,
             idrt_out.

* Altsystemschlüssel
    CONCATENATE   x_htger-equnr+10(8) '_'
                  idrt_drint_h-keydate '_'
                  idrt_drint_h-anlage                       " Pos. 28
                  INTO oldkey_drt.


* idrt_DRINT
    MOVE-CORRESPONDING idrt_drint_h TO idrt_drint.
    APPEND idrt_drint.
    CLEAR idrt_drint.


*idrt_DRDEV
    LOOP AT idrt_drdev_h WHERE ab = idrt_drint_h-keydate.
      MOVE-CORRESPONDING idrt_drdev_h TO idrt_drdev.
      APPEND idrt_drdev.
      CLEAR idrt_drdev.
    ENDLOOP.

* idrt_DRREG
    LOOP AT idrt_drreg_h WHERE ab = idrt_drint_h-keydate.
      MOVE-CORRESPONDING idrt_drreg_h TO idrt_drreg.
      APPEND idrt_drreg.
      CLEAR idrt_drreg.
    ENDLOOP.


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
    o_key = oldkey_drt.
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
*<< Wegschreiben des Objektschlüssels in Entlade-KSV

    ADD 1 TO anz_obj.


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
    IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_DEVICERA'
      CALL FUNCTION ums_fuba
        EXPORTING
          firma      = firma
        TABLES
          meldung    = meldung
          idrt_drint = idrt_drint
          idrt_drdev = idrt_drdev
          idrt_drreg = idrt_drreg
        CHANGING
          oldkey_drt = oldkey_drt.
    ENDIF.



* Sätze für Datei in interne Tabelle schreiben
    PERFORM fill_drt_out USING  oldkey_drt
                                firma
                                object.




    LOOP AT idrt_out INTO wdrt_out.
      TRANSFER wdrt_out TO ent_file.
    ENDLOOP.

  ENDLOOP.




ENDFUNCTION.
