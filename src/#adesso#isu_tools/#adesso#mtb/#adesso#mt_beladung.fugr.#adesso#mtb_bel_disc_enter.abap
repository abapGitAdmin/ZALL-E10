FUNCTION /ADESSO/MTB_BEL_DISC_ENTER.
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
  DATA: olddce          LIKE itrans-oldkey.
  DATA: itemksv LIKE TABLE OF temksv WITH HEADER LINE.
  DATA: itemksv2 LIKE TABLE OF temksv WITH HEADER LINE.
  DATA: veranz TYPE n.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.

  object   = 'DISC_ENTER'.
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
      IF itrans-oldkey NE oldkey_dce AND
            oldkey_dce NE space.

          olddce = oldkey_dce.

          CLEAR: itemksv, itemksv[].
          SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'DISC_DOC'
                        AND oldkey   = olddce.


           if sy-subrc ne 0.

             SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'DISC_DOC'
                        AND oldkey like old_disc.

            endif.

          DESCRIBE TABLE itemksv LINES veranz.
          IF veranz = 0.
            READ TABLE idce_header INDEX 1.
           MESSAGE s001(/adesso/mt_n) WITH
                               'keine Umschlüsselung für Sperrbeleg'
                  idce_header-discno 'vorhanden' INTO meldung-meldung.
            APPEND meldung.
          ENDIF.


          LOOP AT itemksv.

            idce_header2[] = idce_header[].
            idce_ANLAGE2[] = idce_ANLAGE[].
            idce_DEVICE2[] = idce_DEVICE[].
            clear idce_ANLAGE3[].

            READ TABLE idce_header INDEX 1.
            idce_header-discno = itemksv-newkey.
            MODIFY idce_header INDEX 1.
            oldkey_dce = itemksv-newkey.


* wenn eine Anlage vorhanden ist, muß der Datensatz in der Struktur
* vielleicht idce_ANLAGE gedoppelt werden

           loop at idce_ANLAGE.
            CONCATENATE idce_ANLAGE-anlage '%' INTO oldanl.

             SELECT * FROM temksv INTO TABLE itemksv2
                        WHERE firma = firma
                        AND   object = 'INSTLN'
                        AND oldkey like oldanl.

             if sy-subrc eq 0.
              loop at itemksv2.
               move-corresponding idce_ANLAGE to idce_ANLAGE3.
               move itemksv-newkey to idce_ANLAGE3-anlage.
               append idce_ANLAGE3.
              endloop.
             endif.
           endloop.

            idce_ANLAGE[]  = idce_ANLAGE3[].



* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
            IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DISC_ENT'
              CALL FUNCTION ums_fuba
                   EXPORTING
                        firma       = firma
                   TABLES
                        meldung     = meldung
                        idce_header = idce_header
                        idce_ANLAGE = idce_ANLAGE
                        idce_DEVICE = idce_DEVICE
                   CHANGING
                        oldkey_dce  = oldkey_dce.
            ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
            PERFORM aufbereitung_dat_dce USING oldkey_dce
                                               rep_name
                                               form_name.
            anz_obj = anz_obj + 1.
            idce_header[] = idce_header2[].
            idce_ANLAGE[] = idce_ANLAGE2[].
            idce_DEVICE[] = idce_DEVICE2[].

          ENDLOOP.

      clear: idce_header[], idce_header2[],
             idce_ANLAGE[], idce_ANLAGE2[],
             idce_DEVICE[], idce_DEVICE2[].
*<

      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'HEADER'.
          CLEAR x_idce_header.
          MOVE itrans-data TO x_idce_header.
          MOVE-CORRESPONDING x_idce_header TO idce_header.
          CONCATENATE idce_header-DISCNO '%' INTO old_disc.
          APPEND idce_header.
          CLEAR idce_header.
        WHEN 'ANLAGE'.
          CLEAR x_idce_ANLAGE.
          MOVE itrans-data TO x_idce_ANLAGE.
          MOVE-CORRESPONDING x_idce_ANLAGE TO idce_ANLAGE.
*          APPEND idce_ANLAGE.
          CLEAR idce_ANLAGE.
        WHEN 'DEVICE'.
          CLEAR x_idce_DEVICE.
          MOVE itrans-data TO x_idce_DEVICE.
          MOVE-CORRESPONDING x_idce_DEVICE TO idce_DEVICE.
          APPEND idce_DEVICE.
          CLEAR idce_DEVICE.
      ENDCASE.


     MOVE itrans-oldkey TO oldkey_dce.

    ELSE.


          olddce = oldkey_dce.

          CLEAR: itemksv, itemksv[].
          SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'DISC_DOC'
                        AND oldkey   = olddce.


           if sy-subrc ne 0.

             SELECT * FROM temksv INTO TABLE itemksv
                        WHERE firma = firma
                        AND   object = 'DISC_DOC'
                        AND oldkey like old_disc.

            endif.

          DESCRIBE TABLE itemksv LINES veranz.
          IF veranz = 0.
            READ TABLE idce_header INDEX 1.
           MESSAGE s001(/adesso/mt_n) WITH
                               'keine Umschlüsselung für Sperrbeleg'
                  idce_header-discno 'vorhanden' INTO meldung-meldung.
            APPEND meldung.
          ENDIF.


          LOOP AT itemksv.

            idce_header2[] = idce_header[].
            idce_ANLAGE2[] = idce_ANLAGE[].
            idce_DEVICE2[] = idce_DEVICE[].
            clear idce_ANLAGE3[].

            READ TABLE idce_header INDEX 1.
            idce_header-discno = itemksv-newkey.
            MODIFY idce_header INDEX 1.
            oldkey_dce = itemksv-newkey.


* wenn eine Anlage vorhanden ist, muß der Datensatz in der Struktur
* vielleicht idce_ANLAGE gedoppelt werden

           loop at idce_ANLAGE.
            CONCATENATE idce_ANLAGE-anlage '%' INTO oldanl.

             SELECT * FROM temksv INTO TABLE itemksv2
                        WHERE firma = firma
                        AND   object = 'INSTLN'
                        AND oldkey like oldanl.

             if sy-subrc eq 0.
              loop at itemksv2.
               move-corresponding idce_ANLAGE to idce_ANLAGE3.
               move itemksv-newkey to idce_ANLAGE3-anlage.
               append idce_ANLAGE3.
              endloop.
             endif.
           endloop.

            idce_ANLAGE[]  = idce_ANLAGE3[].



* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
            IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DISC_ENT'
              CALL FUNCTION ums_fuba
                   EXPORTING
                        firma       = firma
                   TABLES
                        meldung     = meldung
                        idce_header = idce_header
                        idce_ANLAGE = idce_ANLAGE
                        idce_DEVICE = idce_DEVICE
                   CHANGING
                        oldkey_dce  = oldkey_dce.
            ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
            PERFORM aufbereitung_dat_dce USING oldkey_dce
                                               rep_name
                                               form_name.
            anz_obj = anz_obj + 1.
            idce_header[] = idce_header2[].
            idce_ANLAGE[] = idce_ANLAGE2[].
            idce_DEVICE[] = idce_DEVICE2[].

          ENDLOOP.

      clear: idce_header[], idce_header2[],
             idce_ANLAGE[], idce_ANLAGE2[],
             idce_DEVICE[], idce_DEVICE2[].
*<

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_dce_down INDEX 1.
  IF sy-subrc NE 0.
    CLEAR anz_obj.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_dce_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.






ENDFUNCTION.
