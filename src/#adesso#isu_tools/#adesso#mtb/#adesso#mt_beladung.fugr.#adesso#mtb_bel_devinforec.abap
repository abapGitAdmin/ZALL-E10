FUNCTION /adesso/mtb_bel_devinforec.
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

  object   = 'DEVINFOREC'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'DVMINT'.

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
      IF itrans-oldkey NE oldkey_dir AND
            oldkey_dir NE space.
* Umschlüsselungs-Fuba?
        IF NOT ums_fuba IS INITIAL.
          CALL FUNCTION ums_fuba
            EXPORTING
              firma         = firma
            TABLES
              meldung       = meldung
              idir_int      = i_dvmint
              idir_dev      = i_dvmdev
              idir_dev_flag = i_dvmdfl
              idir_reg      = i_dvmreg
              idir_reg_flag = i_dvmrfl
            CHANGING
              oldkey_dir    = oldkey_dir.
        ENDIF.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_devinforec USING oldkey_dir
                                               rep_name
                                               form_name.
        anz_obj = anz_obj + 1.


      ENDIF.
* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'DVMINT'.
          CLEAR x_i_dvmint.
          MOVE itrans-data TO x_i_dvmint.
          MOVE-CORRESPONDING x_i_dvmint TO i_dvmint.
          APPEND i_dvmint.
          CLEAR i_dvmint.
        WHEN 'DVMDEV'.
          CLEAR x_i_dvmdev.
          MOVE itrans-data TO x_i_dvmdev.
          MOVE-CORRESPONDING x_i_dvmdev TO i_dvmdev.
          APPEND i_dvmdev.
          CLEAR i_dvmdev.
        WHEN 'DVMDFL'.
          CLEAR x_i_dvmdfl.
          MOVE itrans-data TO x_i_dvmdfl.
          MOVE-CORRESPONDING x_i_dvmdfl TO i_dvmdfl.
          APPEND i_dvmdfl.
          CLEAR i_dvmdfl.
        WHEN 'DVMREG'.
          CLEAR x_i_dvmreg.
          MOVE itrans-data TO x_i_dvmreg.
          MOVE-CORRESPONDING x_i_dvmreg TO i_dvmreg.
          APPEND i_dvmreg.
          CLEAR i_dvmreg.
        WHEN 'DVMRFL'.
          CLEAR x_i_dvmrfl.
          MOVE itrans-data TO x_i_dvmrfl.
          MOVE-CORRESPONDING x_i_dvmrfl TO i_dvmrfl.
          APPEND i_dvmrfl.
          CLEAR i_dvmrfl.

      ENDCASE.

      MOVE itrans-oldkey TO oldkey_dir.

    ELSE.

* Umschlüsselungs-Fuba?
      IF NOT ums_fuba IS INITIAL.
        CALL FUNCTION ums_fuba
          EXPORTING
            firma         = firma
          TABLES
            meldung       = meldung
            idir_int      = i_dvmint
            idir_dev      = i_dvmdev
            idir_dev_flag = i_dvmdfl
            idir_reg      = i_dvmreg
            idir_reg_flag = i_dvmrfl
          CHANGING
            oldkey_dir    = oldkey_dir.
      ENDIF.

* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_devinforec USING oldkey_dir
                                             rep_name
                                             form_name.
      anz_obj = anz_obj + 1.

      EXIT.
    ENDIF.

  ENDDO.

* Erstellen der Migrationsdatei
  READ TABLE i_dir_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_dir_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.


ENDFUNCTION.
