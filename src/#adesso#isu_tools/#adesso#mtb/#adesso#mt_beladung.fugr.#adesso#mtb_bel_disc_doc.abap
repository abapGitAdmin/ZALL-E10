FUNCTION /adesso/mtb_bel_disc_doc.
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
  DATA: oldanl          LIKE itrans-oldkey.
  DATA: olddcd          LIKE itrans-oldkey.
  DATA: itemksv LIKE TABLE OF temksv WITH HEADER LINE.
  DATA: veranz TYPE n.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.

  object   = 'DISC_DOC'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'HEADER'.

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

* Daten werden um einen Altsystemschlüssel verzögert aufgebaut, weil
* erstmal alle Strukturtabellen für den Umschlüsselungs-FUBA ermittelt
* werden müssen (siehe: case itrans-dttyp).
      IF itrans-oldkey NE oldkey_dcd AND
            oldkey_dcd NE space.



        IF NOT oldanl IS INITIAL.  "nur dann doppeln

          olddcd = oldkey_dcd.

          CLEAR: itemksv, itemksv[].
          SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'INSTLN'
                        AND oldkey LIKE oldanl.

          DESCRIBE TABLE itemksv LINES veranz.
          IF veranz = 0.
            READ TABLE idcd_header INDEX 1.
         MESSAGE s001(/adesso/mt_n) WITH 'keine Umschlüsselung für Anlage'
                  idcd_header-anlage 'vorhanden' INTO meldung-meldung.
            APPEND meldung.
          ENDIF.


          LOOP AT itemksv.
            idcd_header2[] = idcd_header[].

            READ TABLE idcd_header INDEX 1.
            idcd_header-anlage = itemksv-newkey.
            MODIFY idcd_header INDEX 1.
            CONCATENATE olddcd itemksv-oldkey+10(2) INTO oldkey_dcd.


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
            IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DISC_DOC'
              CALL FUNCTION ums_fuba
                   EXPORTING
                        firma       = firma
                   TABLES
                        meldung     = meldung
                        idcd_header = idcd_header
                        idcd_fkkmaz = idcd_fkkmaz
                   CHANGING
                        oldkey_dcd  = oldkey_dcd.
            ENDIF.

            READ TABLE idcd_header INDEX 1.
            IF sy-subrc NE 0.
             anz_obj = anz_obj - 1.
            ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
            PERFORM aufbereitung_dat_dcd USING oldkey_dcd
                                               rep_name
                                               form_name.
            anz_obj = anz_obj + 1.




            idcd_header[] = idcd_header2[].

          ENDLOOP.
          CLEAR: idcd_header[],idcd_header2[].
*<

        ELSE.


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DISC_DOC'
            CALL FUNCTION ums_fuba
                 EXPORTING
                      firma       = firma
                 TABLES
                      meldung     = meldung
                      idcd_header = idcd_header
                      idcd_fkkmaz = idcd_fkkmaz
                 CHANGING
                      oldkey_dcd  = oldkey_dcd.
          ENDIF.

            READ TABLE idcd_header INDEX 1.
            IF sy-subrc NE 0.
             anz_obj = anz_obj - 1.
            ENDIF.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_dcd USING oldkey_dcd
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.

        ENDIF.
      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'HEADER'.
          CLEAR x_idcd_header.
          MOVE itrans-data TO x_idcd_header.
          MOVE-CORRESPONDING x_idcd_header TO idcd_header.
          IF NOT idcd_header-anlage IS INITIAL.
            CONCATENATE idcd_header-anlage '%' INTO oldanl.
          ELSE.
            CLEAR oldanl.
          ENDIF.

          APPEND idcd_header.
          CLEAR idcd_header.
        WHEN 'FKKMAZ'.
          CLEAR x_idcd_fkkmaz.
          MOVE itrans-data TO x_idcd_fkkmaz.
          MOVE-CORRESPONDING x_idcd_fkkmaz TO idcd_fkkmaz.
          APPEND idcd_fkkmaz.
          CLEAR idcd_fkkmaz.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_dcd.

    ELSE.


      IF NOT oldanl IS INITIAL.  "nur dann doppeln

        olddcd = oldkey_dcd.

        CLEAR: itemksv, itemksv[].
        SELECT * FROM temksv INTO TABLE itemksv
                      WHERE firma = firma
                      AND   object = 'INSTLN'
                      AND oldkey LIKE oldanl.

        DESCRIBE TABLE itemksv LINES veranz.
        IF veranz = 0.
          READ TABLE idcd_header INDEX 1.
         MESSAGE s001(/adesso/mt_n) WITH 'keine Umschlüsselung für Anlage'
              idcd_header-anlage 'vorhanden' INTO meldung-meldung.
          APPEND meldung.
        ENDIF.


        LOOP AT itemksv.
          idcd_header2[] = idcd_header[].

          READ TABLE idcd_header INDEX 1.
          idcd_header-anlage = itemksv-newkey.
          MODIFY idcd_header INDEX 1.
          CONCATENATE olddcd itemksv-oldkey+10(2) INTO oldkey_dcd.


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DISC_DOC'
            CALL FUNCTION ums_fuba
                 EXPORTING
                      firma       = firma
                 TABLES
                      meldung     = meldung
                      idcd_header = idcd_header
                      idcd_fkkmaz = idcd_fkkmaz
                 CHANGING
                      oldkey_dcd  = oldkey_dcd.
          ENDIF.

            READ TABLE idcd_header INDEX 1.
            IF sy-subrc NE 0.
             anz_obj = anz_obj - 1.
            ENDIF.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_dcd USING oldkey_dcd
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.
          idcd_header[] = idcd_header2[].

        ENDLOOP.
          CLEAR: idcd_header[],idcd_header2[].
*<

      ELSE.



* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DISC_DOC'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma       = firma
               TABLES
                    meldung     = meldung
                    idcd_header = idcd_header
                    idcd_fkkmaz = idcd_fkkmaz
               CHANGING
                    oldkey_dcd  = oldkey_dcd.
        ENDIF.

            READ TABLE idcd_header INDEX 1.
            IF sy-subrc NE 0.
             anz_obj = anz_obj - 1.
            ENDIF.

* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
        PERFORM aufbereitung_dat_dcd USING oldkey_dcd
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.

      ENDIF.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_dcd_down INDEX 1.
  IF sy-subrc NE 0.
    CLEAR anz_obj.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_dcd_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.







ENDFUNCTION.
