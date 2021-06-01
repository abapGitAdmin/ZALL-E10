FUNCTION /adesso/mtb_bel_dunning.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"     REFERENCE(PFAD_DAT_BEL) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      GEN_ERROR
*"      ERROR
*"----------------------------------------------------------------------
  DATA  object          TYPE  emg_object.
  DATA  bel_file        TYPE  emg_pfad.
  DATA  ent_file        TYPE  emg_pfad.
  DATA  rep_name        TYPE  programm.
  DATA  form_name       TYPE  text30.
  DATA  syn_fehler      TYPE  text60.
  DATA: itrans          LIKE  /adesso/mt_transfer.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.
  DATA: wa_temksv       TYPE temksv.
  DATA: wa_dfkkop       TYPE dfkkop.
  DATA: h_betrw         TYPE dfkkop-betrw.


  object   = 'DUNNING'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'KEY'.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
        FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'BEL'.

* Generierung des Reports für die Übergabestrukturen
  CALL FUNCTION '/ADESSO/MTB_REP_GENERATE'
    EXPORTING
      firma      = firma
      object     = object
    IMPORTING
      rep_name   = rep_name
      form_name  = form_name
      syn_fehler = syn_fehler
    TABLES
*     CODING     =
      meldung    = meldung
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    IF NOT syn_fehler IS INITIAL.
      meldung-meldung = syn_fehler.
      APPEND meldung.
    ENDIF.

    RAISE gen_error.
  ELSE.
    TRANSLATE rep_name TO UPPER CASE.
    TRANSLATE form_name TO UPPER CASE.
  ENDIF.


* Einlesen der Datei
  OPEN DATASET ent_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.

* Error wenn falscher Pfad bzw.Datei
  IF sy-subrc NE 0.
    CONCATENATE 'Öffnen der Datei' ent_file 'nicht möglich'
      INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE no_open.
  ENDIF.

* Dataset lesen
  DO.

    CLEAR: itrans.
    READ DATASET ent_file INTO itrans.

    IF sy-subrc EQ 0.

*   Migrationsfirma prüfen.
      IF itrans-firma NE firma.
        CONCATENATE 'Falsche Migrationsfirma:'
                     itrans-firma
          INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.

*     Daten werden um einen Altsystemschlüssel verzögert aufgebaut, weil
*     erstmal alle Strukturtabellen für den Umschlüsselungs-FUBA ermittelt
*     werden müssen (siehe: case itrans-dttyp).
      IF itrans-oldkey NE oldkey_dun AND
            oldkey_dun NE space.


*       Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.

          CALL FUNCTION ums_fuba
            EXPORTING
              firma      = firma
            TABLES
              meldung    = meldung
              idun_key   = idun_key
              idun_fkkma = idun_fkkma
            CHANGING
              oldkey_dun = oldkey_dun.
        ENDIF.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_dun USING oldkey_dun
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.

      ENDIF.

** füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
** bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
** Migrationsdaten
** => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'KEY'.
          CLEAR x_dun_key.
          MOVE itrans-data TO x_dun_key.
          MOVE-CORRESPONDING x_dun_key TO idun_key.
          APPEND idun_key.
          CLEAR idun_key.
        WHEN 'FKKMA'.
          CLEAR x_dun_fkkma.
          MOVE itrans-data TO x_dun_fkkma.
*         Wenn die Wiederholungsgruppe 000 ist
*         Werden die Felder für OPUPK und OPUPZ
*         zum neuen Beleg für den Betrag und die Fälligkeit selektiert
          IF x_dun_fkkma-opupw IS INITIAL.

**       Initialisierung der OPUPW, OPUPK, OPUPZ ausgesternt, da
**       es Belege mit mehreren Positionen bei der gleichen Fälligkeit gibt
*            CLEAR x_dun_fkkma-opupw.
*            CLEAR x_dun_fkkma-opupk.
*            CLEAR x_dun_fkkma-opupz.

            CLEAR wa_temksv.
            SELECT SINGLE * FROM temksv INTO wa_temksv
              WHERE firma = firma
              AND object = 'DOCUMENT'
              AND oldkey = x_dun_fkkma-opbel.
**          Beleg wurde in TEMKSV-gefunden
**          Lesen in der DFKKOP mit dem NEWKEY,
**          dem Fälligkeitsdatum und dem Betrag

**          Zusätzlich werden OPUPW, OPUPK und OPUPZ in die Selektion genommen
**          1. Prüfung;
**          Prüfung mit Positionsdaten aus der Quelle (OPUPW, OPUKP, OPUPZ)
**          Fälligkeitsdatum und Betrag
            IF sy-subrc EQ 0.
              CLEAR h_betrw.
              MOVE x_dun_fkkma-betrw TO h_betrw.
              CLEAR wa_dfkkop.
              SELECT SINGLE * FROM dfkkop INTO wa_dfkkop
                WHERE opbel = wa_temksv-newkey
                AND opupw = x_dun_fkkma-opupw
                AND opupk = x_dun_fkkma-opupk
                AND opupz = x_dun_fkkma-opupz
                AND  faedn = x_dun_fkkma-faedn
                AND betrw = h_betrw.
              IF sy-subrc = 0.
                MOVE wa_dfkkop-opupw TO x_dun_fkkma-opupw.
                MOVE wa_dfkkop-opupk TO x_dun_fkkma-opupk.
                MOVE wa_dfkkop-opupz TO x_dun_fkkma-opupz.
              ELSE.

**            Der Eintrag wurde nicht in der DFKKOP gefunden
**            Es handelt sich um einen Teilausgleich
**            2. Prüfung
**            Selektion mit Belegnummer, Positionen und Fälligkeit
                CLEAR wa_dfkkop.
                SELECT SINGLE * FROM dfkkop INTO wa_dfkkop
                  WHERE opbel = wa_temksv-newkey
                  AND opupw = x_dun_fkkma-opupw
                  AND opupk = x_dun_fkkma-opupk
                  AND opupz = x_dun_fkkma-opupz
                  AND  faedn = x_dun_fkkma-faedn.
                IF sy-subrc = 0.
                  MOVE wa_dfkkop-opupw TO x_dun_fkkma-opupw.
                  MOVE wa_dfkkop-opupk TO x_dun_fkkma-opupk.
                  MOVE wa_dfkkop-opupz TO x_dun_fkkma-opupz.
                ELSE.
**              Eintrag wurde nicht in der DFKKOP gefunden
**              3. Prüfung
**              Prüfung mit Fälligkeit und Betrag.
                  CLEAR wa_dfkkop.
                  SELECT SINGLE * FROM dfkkop INTO wa_dfkkop
                     WHERE opbel = wa_temksv-newkey
                    AND faedn = x_dun_fkkma-faedn
                    AND betrw = h_betrw.
                  IF sy-subrc = 0.
                    MOVE wa_dfkkop-opupw TO x_dun_fkkma-opupw.
                    MOVE wa_dfkkop-opupk TO x_dun_fkkma-opupk.
                    MOVE wa_dfkkop-opupz TO x_dun_fkkma-opupz.
                  ELSE.

**              Der Eintrag wurde in der DFKKOP nicht gefunden
**              4. Prüfung
**              Es handelt sich hier um einen Teilausgleich
**              In der Mahnhistorie steht noch der gesamte Betrag
**              Jetzt nur noch mit Belegnummer und Fälligkeitsdatum selektieren
                    CLEAR wa_dfkkop.
                    SELECT SINGLE * FROM dfkkop INTO wa_dfkkop
                      WHERE opbel = wa_temksv-newkey
                        AND faedn = x_dun_fkkma-faedn.
                    IF sy-subrc = 0.
                      MOVE wa_dfkkop-opupw TO x_dun_fkkma-opupw.
                      MOVE wa_dfkkop-opupk TO x_dun_fkkma-opupk.
                      MOVE wa_dfkkop-opupz TO x_dun_fkkma-opupz.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          MOVE-CORRESPONDING x_dun_fkkma TO idun_fkkma.
          APPEND idun_fkkma.
          CLEAR idun_fkkma.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_dun.

    ELSE.

*       Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.

        CALL FUNCTION ums_fuba
          EXPORTING
            firma      = firma
          TABLES
            meldung    = meldung
            idun_key   = idun_key
            idun_fkkma = idun_fkkma
          CHANGING
            oldkey_dun = oldkey_dun.
      ENDIF.

* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_dun USING oldkey_dun
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE idun_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES idun_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.


ENDFUNCTION.
