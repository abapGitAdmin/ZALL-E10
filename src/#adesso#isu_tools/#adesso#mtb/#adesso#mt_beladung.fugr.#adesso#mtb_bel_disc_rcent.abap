FUNCTION /adesso/mtb_bel_disc_rcent.
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
  DATA: old_disc        LIKE itrans-oldkey.
  DATA: oldanl          LIKE itrans-oldkey.
  DATA: olddcm          LIKE itrans-oldkey.
  DATA: itemksv LIKE TABLE OF temksv WITH HEADER LINE.
  DATA: itemksv2 LIKE TABLE OF temksv WITH HEADER LINE.
  DATA: veranz TYPE n.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.

  object   = 'DISC_RCENT'.
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
      IF itrans-oldkey NE oldkey_dcm AND
            oldkey_dcm NE space.

          olddcm = oldkey_dcm.

          CLEAR: itemksv, itemksv[].
          SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'DISC_DOC'
                        AND oldkey   = olddcm.


           IF sy-subrc NE 0.

             SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'DISC_DOC'
                        AND oldkey LIKE old_disc.

            ENDIF.

          DESCRIBE TABLE itemksv LINES veranz.
          IF veranz = 0.
            READ TABLE idcm_header INDEX 1.
           MESSAGE s001(/adesso/mt_n) WITH
                               'keine Umschlüsselung für Sperrbeleg'
                  idcm_header-discno 'vorhanden' INTO meldung-meldung.
            APPEND meldung.
          ENDIF.


          LOOP AT itemksv.

            idcm_header2[] = idcm_header[].
            idcm_anlage2[] = idcm_anlage[].
            idcm_device2[] = idcm_device[].
            CLEAR idcm_anlage3[].

            READ TABLE idcm_header INDEX 1.
            idcm_header-discno = itemksv-newkey.
            MODIFY idcm_header INDEX 1.
            oldkey_dcm = itemksv-newkey.


* wenn eine Anlage vorhanden ist, muß der Datensatz in der Struktur
* vielleicht idcm_ANLAGE gedoppelt werden

           LOOP AT idcm_anlage.
            CONCATENATE idcm_anlage-anlage '%' INTO oldanl.

             SELECT * FROM temksv INTO TABLE itemksv2
                        WHERE firma = firma
                        AND   object = 'INSTLN'
                        AND oldkey LIKE oldanl.

             IF sy-subrc EQ 0.
              LOOP AT itemksv2.
               MOVE-CORRESPONDING idcm_anlage TO idcm_anlage3.
               MOVE itemksv-newkey TO idcm_anlage3-anlage.
               APPEND idcm_anlage3.
              ENDLOOP.
             ENDIF.
           ENDLOOP.

            idcm_anlage[]  = idcm_anlage3[].



* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
            IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DISC_RCE'
              CALL FUNCTION ums_fuba
                   EXPORTING
                        firma       = firma
                   TABLES
                        meldung     = meldung
                        idcm_header = idcm_header
                        idcm_anlage = idcm_anlage
                        idcm_device = idcm_device
                   CHANGING
                        oldkey_dcm  = oldkey_dcm.
            ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
            PERFORM aufbereitung_dat_dcm USING oldkey_dcm
                                               rep_name
                                               form_name.
            anz_obj = anz_obj + 1.
            idcm_header[] = idcm_header2[].
            idcm_anlage[] = idcm_anlage2[].
            idcm_device[] = idcm_device2[].

          ENDLOOP.

        CLEAR: idcm_header[], idcm_header2[],
               idcm_anlage[], idcm_anlage2[],
               idcm_device[], idcm_device2[].
*<

      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'HEADER'.
          CLEAR x_idcm_header.
          MOVE itrans-data TO x_idcm_header.
          MOVE-CORRESPONDING x_idcm_header TO idcm_header.
          CONCATENATE idcm_header-discno '%' INTO old_disc.
          APPEND idcm_header.
          CLEAR idcm_header.
        WHEN 'ANLAGE'.
          CLEAR x_idcm_anlage.
          MOVE itrans-data TO x_idcm_anlage.
          MOVE-CORRESPONDING x_idcm_anlage TO idcm_anlage.
*          if not idcm_ANLAGE-anlage is initial.
*           CONCATENATE idcm_ANLAGE-anlage '%' INTO oldanl.
*          endif.
          APPEND idcm_anlage.
          CLEAR idcm_anlage.
        WHEN 'DEVICE'.
          CLEAR x_idcm_device.
          MOVE itrans-data TO x_idcm_device.
          MOVE-CORRESPONDING x_idcm_device TO idcm_device.
          APPEND idcm_device.
          CLEAR idcm_device.
      ENDCASE.


*      MOVE itrans-oldkey TO oldkey_dcm.

    ELSE.


          olddcm = oldkey_dcm.

          CLEAR: itemksv, itemksv[].
          SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'DISC_DOC'
                        AND oldkey   = olddcm.


           IF sy-subrc NE 0.

             SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'DISC_DOC'
                        AND oldkey LIKE old_disc.

            ENDIF.

          DESCRIBE TABLE itemksv LINES veranz.
          IF veranz = 0.
            READ TABLE idcm_header INDEX 1.
           MESSAGE s001(/adesso/mt_n) WITH
                               'keine Umschlüsselung für Sperrbeleg'
                  idcm_header-discno 'vorhanden' INTO meldung-meldung.
            APPEND meldung.
          ENDIF.


          LOOP AT itemksv.

            idcm_header2[] = idcm_header[].
            idcm_anlage2[] = idcm_anlage[].
            idcm_device2[] = idcm_device[].
            CLEAR idcm_anlage3[].

            READ TABLE idcm_header INDEX 1.
            idcm_header-discno = itemksv-newkey.
            MODIFY idcm_header INDEX 1.
            oldkey_dcm = itemksv-newkey.


* wenn eine Anlage vorhanden ist, muß der Datensatz in der Struktur
* vielleicht idcm_ANLAGE gedoppelt werden

           LOOP AT idcm_anlage.
            CONCATENATE idcm_anlage-anlage '%' INTO oldanl.

             SELECT * FROM temksv INTO TABLE itemksv2
                        WHERE firma = firma
                        AND   object = 'INSTLN'
                        AND oldkey LIKE oldanl.

             IF sy-subrc EQ 0.
              LOOP AT itemksv2.
               MOVE-CORRESPONDING idcm_anlage TO idcm_anlage3.
               MOVE itemksv-newkey TO idcm_anlage3-anlage.
               APPEND idcm_anlage3.
              ENDLOOP.
             ENDIF.
           ENDLOOP.

            idcm_anlage[]  = idcm_anlage3[].



* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
            IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DISC_RCE'
              CALL FUNCTION ums_fuba
                   EXPORTING
                        firma       = firma
                   TABLES
                        meldung     = meldung
                        idcm_header = idcm_header
                        idcm_anlage = idcm_anlage
                        idcm_device = idcm_device
                   CHANGING
                        oldkey_dcm  = oldkey_dcm.
            ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
            PERFORM aufbereitung_dat_dcm USING oldkey_dcm
                                               rep_name
                                               form_name.
            anz_obj = anz_obj + 1.
            idcm_header[] = idcm_header2[].
            idcm_anlage[] = idcm_anlage2[].
            idcm_device[] = idcm_device2[].

          ENDLOOP.

        CLEAR: idcm_header[], idcm_header2[],
               idcm_anlage[], idcm_anlage2[],
               idcm_device[], idcm_device2[].
*<

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_dcm_down INDEX 1.
  IF sy-subrc NE 0.
    CLEAR anz_obj.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_dcm_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.


ENDFUNCTION.
