*&---------------------------------------------------------------------*
*& Report  /ADESSO/MTD_EJVL_UP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/mtd_ejvl_up.

TABLES: ejvl,
        dfkkop,
        dfkklocks.

DATA: iejvl TYPE TABLE OF ejvl WITH HEADER LINE,
      ilocks LIKE TABLE OF dfkklocks WITH HEADER LINE,
      unix_file LIKE temfd-path.
DATA: BEGIN OF iabp OCCURS 0,
        opbel LIKE ejvl-opbel,
      END OF iabp.
DATA: oldfaedn LIKE dfkkop-faedn.

DATA: headcount TYPE i,
      poscount TYPE i,
      nomigcount TYPE i,
      notfound TYPE i.

PARAMETERS: exp_path LIKE temfd-path
            DEFAULT '/rkudat/rkustd/isu/evuit/525e/',
            file(30) TYPE c  DEFAULT 'EJVL' LOWER CASE,
            file2(30) TYPE c LOWER CASE,
            pfaedn LIKE sy-datum,
            ptage(1) TYPE n DEFAULT 7,
            ptemksv AS CHECKBOX DEFAULT 'X',
            pfirma TYPE emg_firma,
            pecht AS CHECKBOX.



START-OF-SELECTION.

* Einlesen der alten JVL-Daten
  CONCATENATE exp_path file INTO unix_file.

  OPEN DATASET unix_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  DO.
    READ DATASET unix_file INTO iejvl.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    APPEND iejvl.
  ENDDO.
  CLOSE DATASET unix_file.

* Einlesen der JVL-ABPs
  CONCATENATE exp_path file2 INTO unix_file.

  OPEN DATASET unix_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  DO.
    READ DATASET unix_file INTO iabp.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    APPEND iabp.
  ENDDO.
  CLOSE DATASET unix_file.

  WRITE : / 'Datum' , sy-datum.
  WRITE : / 'Uhrzeit', sy-uzeit.
  WRITE : / 'System', sy-sysid.
  WRITE : / 'Mandant', sy-mandt.
  WRITE : / 'Benutzer', sy-uname.
  IF pecht IS INITIAL.
    WRITE : / 'Testlauf. Keine Daten werden geändert'.
  ELSE.
    WRITE : / 'Echtlauf. Daten werden geändert'.
  ENDIF.
  DESCRIBE TABLE iejvl LINES sy-tfill.
  WRITE : / sy-tfill, 'JVL-Daten aus Datei gelesen'.
  SORT iejvl BY opbel.
  DELETE ADJACENT DUPLICATES FROM iejvl COMPARING opbel.
  DESCRIBE TABLE iejvl LINES sy-tfill.
  WRITE : / sy-tfill, 'Abschlagspläne ohne Duplicate in IEJVL'.
  DESCRIBE TABLE iabp LINES sy-tfill.
  WRITE : / sy-tfill, 'ABP-Daten echter JVLer aus Datei gelesen'.
  ULINE.

  WRITE : / 'Laufprotokoll'.
  SORT iabp.

* Alle JVL-Daten ablaufen
  LOOP AT iejvl.
* anhand der JVL-datei prüfen, ob ein echter JVLer vorliegt
    READ TABLE iabp WITH KEY opbel = iejvl-opbel BINARY SEARCH.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
    IF NOT ptemksv IS INITIAL.
* Ggfls über TEMKSv umschlüsseln.
      SELECT SINGLE newkey INTO iejvl-opbel FROM temksv
             WHERE firma = pfirma
             AND   object = 'BBP_MULT'
             AND   oldkey = iabp-opbel.
      IF sy-subrc <> 0.
        WRITE : / 'Fehler bei Umschlüsselung ABP', iabp-opbel.
        ADD 1 TO nomigcount.
        CONTINUE.
      ENDIF.
    ENDIF.

* Update der Fälligkeit und des Sperrbeginns
    SELECT * FROM ejvl WHERE opbel = iejvl-opbel.
      oldfaedn = ejvl-faedn.
      ejvl-faedn = iejvl-faedn.
      ejvl-fdate = sy-datum + ptage.
      UPDATE ejvl.
      WRITE : / 'ABP', ejvl-opbel, 'Vertrag', ejvl-vertrag,
                'neue Fälligkeit', ejvl-faedn,
                'Sperrbeginn', ejvl-fdate.
      ADD 1 TO poscount.
    ENDSELECT.
    IF sy-subrc = 0.
      ADD 1 TO headcount.
      IF NOT pfaedn IS INITIAL.
        oldfaedn = pfaedn.
      ENDIF.
      SELECT * FROM dfkkop WHERE opbel = iejvl-opbel
                           AND   augst <> '9'
                           AND   hvorg = '0045'
                           AND   faedn = oldfaedn.
        dfkkop-faedn = iejvl-faedn.
        dfkkop-faeds = iejvl-faedn.
        UPDATE dfkkop.
        CONCATENATE dfkkop-opbel dfkkop-opupw dfkkop-opupk dfkkop-opupz
                    INTO dfkklocks-loobj1.
        CLEAR: ilocks, ilocks[].
        SELECT * FROM dfkklocks
                 WHERE loobj1 = dfkklocks-loobj1
                 AND   lotyp  = '02'
                 AND   proid = '09'
                 AND   lockr = 'J'
                 AND   gpart = dfkkop-gpart
                 AND   vkont = dfkkop-vkont.
          ilocks = dfkklocks.
          ilocks-fdate = sy-datum + ptage.
          APPEND ilocks.
          DELETE dfkklocks.

        ENDSELECT.
        INSERT dfkklocks FROM TABLE ilocks.
      ENDSELECT.
      WRITE : sy-dbcnt, 'DFKKOP-Sätze'.
    ELSE.
      WRITE : / 'Abschlagsplan', iejvl-opbel, 'in EJVL nicht gefunden'.
      ADD 1 TO notfound.
    ENDIF.
    IF pecht IS INITIAL.
      ROLLBACK WORK.
    ELSE.
      COMMIT WORK.
    ENDIF.
  ENDLOOP.
  ULINE.
  WRITE : / 'Summen'.
  WRITE : / 'Nicht migrierte Abschlagspläne', nomigcount.
  WRITE : / 'Nicht gefundene Abschlagspläne', notfound.
  WRITE : / 'Gefundene Abschlagspläne', headcount.
  WRITE : / 'Geänderte JVL-Positionen', poscount.
  GET TIME.
  WRITE : / 'Ende das Laufs', sy-datum, sy-uzeit.
