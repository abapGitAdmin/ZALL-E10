FUNCTION /ADESSO/MTB_BEL_INSTPLAN.
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
  DATA: lopbel LIKE dfkkop-opbel.
  DATA: lwa_dfkkop LIKE dfkkop.
  DATA lfaedn LIKE sy-datum.

  object   = 'INSTPLAN'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'IPKEY'.

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
      firma               = firma
      object              = object
   IMPORTING
     rep_name             = rep_name
     form_name            = form_name
     syn_fehler           = syn_fehler
   TABLES
*    CODING              =
     meldung              = meldung
   EXCEPTIONS
     error               = 1
     OTHERS              = 2
            .
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


* einlesen der Datei
* open Dataset
  OPEN DATASET ent_file FOR INPUT in text mode encoding default.

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

* Daten werden um einen Altsystemschlüssel verzögert aufgebaut, weil
* erstmal alle Strukturtabellen für den Umschlüsselungs-FUBA ermittelt
* werden müssen (siehe: case itrans-dttyp).
      IF itrans-oldkey NE oldkey_ipl AND
            oldkey_ipl NE space.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_INSTPLAN'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung    = meldung
                    ipl_ipkey  = ipl_ipkey
                    ipl_ipdata = ipl_ipdata
                    ipl_ipopky = ipl_ipopky
               CHANGING
                    oldkey_ipl = oldkey_ipl.
        ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_ipl USING oldkey_ipl
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.

      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'IPKEY'.
          CLEAR lfaedn.
          CLEAR x_ipl_ipkey.
          MOVE itrans-data TO x_ipl_ipkey.
          MOVE-CORRESPONDING x_ipl_ipkey TO ipl_ipkey.
          APPEND ipl_ipkey.
          CLEAR ipl_ipkey.
        WHEN 'IPDATA'.
          CLEAR x_ipl_ipdata.
          MOVE itrans-data TO x_ipl_ipdata.
          MOVE-CORRESPONDING x_ipl_ipdata TO ipl_ipdata.
          IF lfaedn gE ipl_ipdata-faedn or lfaedn is initial.
            lfaedn = ipl_ipdata-faedn.
          ENDIF.
          APPEND ipl_ipdata.
          CLEAR ipl_ipdata.
        WHEN 'IPOPKY'.
          CLEAR x_ipl_ipopky.
          MOVE itrans-data TO x_ipl_ipopky.
          MOVE-CORRESPONDING x_ipl_ipopky TO ipl_ipopky.
          READ TABLE ipl_ipkey INDEX 1.
          SELECT SINGLE newkey FROM temksv INTO lopbel
                        WHERE firma = firma
                        AND   object = 'DOCUMENT'
                        AND   oldkey = ipl_ipopky-opbel.
          IF sy-subrc = 0.
            SELECT opupk opupw opupz FROM dfkkop
                   INTO CORRESPONDING FIELDS OF ipl_ipopky
                   WHERE opbel = lopbel
                   AND   augst <> '9'.
*                 AND   faedn <= ipl_ipkey-bldat.
              APPEND ipl_ipopky.
            ENDSELECT.
            CLEAR ipl_ipopky.
          ELSE.
            SELECT SINGLE newkey FROM temksv INTO lopbel
                         WHERE firma = firma
                         AND   object = 'BBP_MULT'
                        AND   oldkey = ipl_ipopky-opbel.
            IF sy-subrc = 0.
              SELECT opupk opupw opupz whang whgrp FROM dfkkop
                      INTO CORRESPONDING FIELDS OF lwa_dfkkop
*                   INTO CORRESPONDING FIELDS OF ipl_ipopky
                     WHERE opbel = lopbel
                     AND   augst <> '9'
                     and hvorg = '0050'
                     AND   ( faedn <= lfaedn
*                     OR ( faedn <> '00000000' AND whang <> 0 ) ).
                     OR ( faedn = '00000000' AND whang <> 0 ) ).
                IF lwa_dfkkop-whang IS INITIAL.
                  ipl_ipopky-opupk = lwa_dfkkop-opupk.
                  ipl_ipopky-opupw = lwa_dfkkop-opupw.
                  ipl_ipopky-opupz = lwa_dfkkop-opupz.
                  APPEND ipl_ipopky.
                ELSE.
                  SELECT opupw FROM dfkkopw INTO lwa_dfkkop-opupw
                  WHERE opbel = lopbel
*                  AND   opupw = lwa_dfkkop-opupw
                  AND   whgrp = lwa_dfkkop-whgrp
                  AND augbl = space
                  AND faedn <= lfaedn
                  AND xaufl <> 'X'.
                    ipl_ipopky-opupk = lwa_dfkkop-opupk.
                    ipl_ipopky-opupw = lwa_dfkkop-opupw.
                    ipl_ipopky-opupz = lwa_dfkkop-opupz.
                    APPEND ipl_ipopky.
                  ENDSELECT.
                ENDIF.
              ENDSELECT.
            ELSE.
*              DELETE ipl_ipopky.
            ENDIF.
            CLEAR ipl_ipopky.
          ENDIF.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_ipl.

    ELSE.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_INSTPLAN'
        CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
             TABLES
                  meldung    = meldung
                  ipl_ipkey  = ipl_ipkey
                  ipl_ipdata = ipl_ipdata
                  ipl_ipopky = ipl_ipopky
             CHANGING
                  oldkey_ipl = oldkey_ipl.
      ENDIF.


* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_ipl USING oldkey_ipl
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_ipl_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_ipl_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.

ENDFUNCTION.
