FUNCTION /ADESSO/MTB_BEL_DEVICE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"     REFERENCE(PFAD_DAT_BEL) TYPE  EMG_PFAD
*"     REFERENCE(OBJECT) TYPE  EMG_OBJECT OPTIONAL
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

*  DATA  object          TYPE  emg_object.
  DATA  bel_file        TYPE  emg_pfad.
  DATA  ent_file        TYPE  emg_pfad.
  DATA  rep_name        TYPE  programm.
  DATA  form_name       TYPE  text30.
  DATA  syn_fehler      TYPE  text60.
  DATA: itrans          LIKE  /adesso/mt_transfer.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.

*  object   = 'DEVICE'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'EQUI'.

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
    if not syn_fehler is initial.
        meldung-meldung = syn_fehler.
        APPEND meldung.
    endif.

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
      IF itrans-oldkey NE oldkey_dev AND
            oldkey_dev NE space.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DEVICE'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung    = meldung
                    i_EQUI     = i_EQUI
                    i_EGERS    = i_EGERS
                    i_EGERH    = i_EGERH
                    i_CLHEAD   = i_CLHEAD
                    i_CLDATA   = i_CLDATA
               CHANGING
                    oldkey_dev = oldkey_dev.
        ENDIF.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_dev USING oldkey_dev
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.

      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'EQUI'.
          clear x_i_EQUI.
          MOVE itrans-data TO x_i_EQUI.
          MOVE-corresponding x_i_EQUI TO i_EQUI.
          APPEND i_EQUI.
          CLEAR i_EQUI.
        WHEN 'EGERS'.
          clear x_i_EGERS.
          MOVE itrans-data TO x_i_EGERS.
          MOVE-corresponding x_i_EGERS TO i_EGERS.
          APPEND i_EGERS.
          CLEAR i_EGERS.
        WHEN 'EGERH'.
          clear x_i_EGERH.
          MOVE itrans-data TO x_i_EGERH.
          MOVE-corresponding x_i_EGERH TO i_EGERH.
          APPEND i_EGERH.
          CLEAR i_EGERH.
        WHEN 'CLHEAD'.
          clear x_i_CLHEAD.
          MOVE itrans-data TO x_i_CLHEAD.
          MOVE-corresponding x_i_CLHEAD TO i_CLHEAD.
          APPEND i_CLHEAD.
          CLEAR i_CLHEAD.
        WHEN 'CLDATA'.
          clear x_i_CLDATA.
          MOVE itrans-data TO x_i_CLDATA.
          MOVE-corresponding x_i_CLDATA TO i_CLDATA.
          APPEND i_CLDATA.
          CLEAR i_CLDATA.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_dev.

    ELSE.


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DEVICE'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung    = meldung
                    i_EQUI     = i_EQUI
                    i_EGERS    = i_EGERS
                    i_EGERH    = i_EGERH
                    i_CLHEAD   = i_CLHEAD
                    i_CLDATA   = i_CLDATA
               CHANGING
                    oldkey_dev = oldkey_dev.
        ENDIF.


* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_dev USING oldkey_dev
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_dev_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_dev_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.







ENDFUNCTION.
