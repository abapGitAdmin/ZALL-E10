FUNCTION /adesso/mtb_bel_devicerate.
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
  DATA: oldanl LIKE itrans-oldkey.
  DATA: itemksv LIKE TABLE OF temksv WITH HEADER LINE.
  DATA: olddrt LIKE itrans-oldkey.
  DATA: veranz TYPE n.

  object   = 'DEVICERATE'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'DRINT'.

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
     OTHERS              = 2.
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
      IF itrans-oldkey NE oldkey_drt AND
            oldkey_drt NE space.

        olddrt = oldkey_drt.
*>>>2VERTRAGSMODELL
*        CLEAR: itemksv, itemksv[].
*
*        SELECT * FROM temksv INTO TABLE itemksv
*                      WHERE firma = firma
*                      AND   object = 'INSTLN'
*                      AND oldkey LIKE oldanl.
*        DESCRIBE TABLE itemksv LINES veranz.
*        IF veranz = 0.
*          READ TABLE idrt_DRINT INDEX 1.
*          MESSAGE s001(/adesso/mt) WITH 'keine Umschlüsselung für Anlage'
*                      idrt_DRINT-anlage 'vorhanden' INTO meldung-meldung.
*          APPEND meldung.
*        ENDIF.
*        SORT itemksv BY oldkey." DESCENDING.
*<<<2VERTRAGSMODELL

*>>>2VERTRAGSMODELL
*        LOOP AT itemksv.
*<<<2VERTRAGSMODELL
        idrt_drint2[]   = idrt_drint[].
        idrt_drdev2[]   = idrt_drdev[].
        idrt_drreg2[]   = idrt_drreg[].
*>>>2VERTRAGSMODELL
**       Anlagenschlüssel aktualisieren (immer erforderlich) bei V und N
*          LOOP AT idrt_DRINT.
*            idrt_DRINT-anlage = itemksv-newkey.
*            MODIFY idrt_DRINT.
*          ENDLOOP.
*<<<2VERTRAGSMODELL

*>>>2VERTRAGSMODELL
*          CONCATENATE olddrt itemksv-oldkey+10(2) INTO oldkey_drt.
* Alten Schlüssel nicht erweitern
        oldkey_drt = olddrt.
*<<<2VERTRAGSMODELL

*>>>2VERTRAGSMODELL
*          IF itemksv-oldkey+10(1) = 'N'.
*** Bei Netzanlagen  müssen auf Zählwerksebene das
*** Verrechnungspreiskennzeichen und die Preisklasse gelöscht werden
*              loop at idrt_DRREG.
*               CLEAR idrt_DRREG-gverrech.
*               CLEAR idrt_DRREG-preiskla.
*               MODIFY idrt_DRREG.
*              endloop.
*          endif.
*<<<2VERTRAGSMODELL


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
**         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DEVICERA'
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

*
**  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_drt USING oldkey_drt
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.

        idrt_drint[]   = idrt_drint2[].
        idrt_drdev[]   = idrt_drdev2[].
        idrt_drreg[]   = idrt_drreg2[].

*>>>2VERTRAGSMODELL
*        endloop.
*<<<2VERTRAGSMODELL
        CLEAR: idrt_drint, idrt_drdev, idrt_drreg.
        REFRESH: idrt_drint, idrt_drdev, idrt_drreg.
        CLEAR: idrt_drint2, idrt_drdev2, idrt_drreg2.
        REFRESH: idrt_drint2, idrt_drdev2, idrt_drreg2.

      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'DRINT'.
          CLEAR x_idrt_drint.
          MOVE itrans-data TO x_idrt_drint.
          MOVE-CORRESPONDING x_idrt_drint TO idrt_drint.
          CONCATENATE idrt_drint-anlage '%' INTO oldanl.
          APPEND idrt_drint.
          CLEAR idrt_drint.
        WHEN 'DRDEV'.
          CLEAR x_idrt_drdev.
          MOVE itrans-data TO x_idrt_drdev.
          MOVE-CORRESPONDING x_idrt_drdev TO idrt_drdev.
          APPEND idrt_drdev.
          CLEAR idrt_drdev.
        WHEN 'DRREG'.
          CLEAR x_idrt_drreg.
          MOVE itrans-data TO x_idrt_drreg.
          MOVE-CORRESPONDING x_idrt_drreg TO idrt_drreg.
          APPEND idrt_drreg.
          CLEAR idrt_drreg.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_drt.

    ELSE.

      olddrt = oldkey_drt.

      idrt_drint2[]   = idrt_drint[].
      idrt_drdev2[]   = idrt_drdev[].
      idrt_drreg2[]   = idrt_drreg[].

      CONCATENATE olddrt itemksv-oldkey+10(2) INTO oldkey_drt.
      oldkey_drt = olddrt.


** Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.
**         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DEVICERA'
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


**  Dateiaufbereitung zum erstellen der Workbench-Dateien
      PERFORM aufbereitung_dat_drt USING oldkey_drt
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      idrt_drint[]   = idrt_drint2[].
      idrt_drdev[]   = idrt_drdev2[].
      idrt_drreg[]   = idrt_drreg2[].

      CLEAR: idrt_drint, idrt_drdev, idrt_drreg.
      REFRESH: idrt_drint, idrt_drdev, idrt_drreg.
      CLEAR: idrt_drint2, idrt_drdev2, idrt_drreg2.
      REFRESH: idrt_drint2, idrt_drdev2, idrt_drreg2.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_drt_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_drt_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.


ENDFUNCTION.
