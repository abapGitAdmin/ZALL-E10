FUNCTION /adesso/mtb_bel_instln.
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
  DATA: anlanz(1)       TYPE n.
  DATA: anlcount(1)     TYPE n.

  object   = 'INSTLN'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'KEY'.

  REFRESH ins_facts.

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

*     Daten werden um einen Altsystemschlüssel verzögert aufgebaut, weil
*     erstmal alle Strukturtabellen für den Umschlüsselungs-FUBA ermittelt
*     werden müssen (siehe: case itrans-dttyp).
      IF itrans-oldkey NE oldkey_ins AND
            oldkey_ins NE space.


*       Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.

          CALL FUNCTION ums_fuba
            EXPORTING
              firma      = firma
            TABLES
              meldung    = meldung
              ins_key    = ins_key
              ins_data   = ins_data
              ins_rcat   = ins_rcat
              ins_pod    = ins_pod
              ins_facts  = ins_facts
            CHANGING
              oldkey_ins = oldkey_ins.
        ENDIF.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_ins USING oldkey_ins
                                           anlanz
                                           anlcount
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.


      ENDIF.
* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'KEY'.
          CLEAR x_ins_key.
          MOVE itrans-data TO x_ins_key.
          MOVE-CORRESPONDING x_ins_key TO ins_key.
          APPEND ins_key.
          CLEAR ins_key.
        WHEN 'DATA'.
          CLEAR x_ins_data.
          MOVE itrans-data TO x_ins_data.
          MOVE-CORRESPONDING x_ins_data TO ins_data.
          anlanz = 1.
          anlcount = 1.
          APPEND ins_data.
          CLEAR ins_data.
        WHEN 'RCAT'.
          CLEAR x_ins_rcat.
          MOVE itrans-data TO x_ins_rcat.
          MOVE-CORRESPONDING x_ins_rcat TO ins_rcat.
          APPEND ins_rcat.
          CLEAR ins_rcat.
        WHEN 'POD'.
          CLEAR x_ins_pod.
          MOVE itrans-data TO x_ins_pod.
          MOVE-CORRESPONDING x_ins_pod TO ins_pod.
          APPEND ins_pod.
          CLEAR ins_pod.

        WHEN 'FACTS'. "Datentyp Fakten aus eigener Tabelle
          MOVE itrans-data TO ins_facts.
          APPEND ins_facts.
          CLEAR ins_facts.

      ENDCASE.

      MOVE itrans-oldkey TO oldkey_ins.


    ELSE.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.

        CALL FUNCTION ums_fuba
          EXPORTING
            firma      = firma
          TABLES
            meldung    = meldung
            ins_key    = ins_key
            ins_data   = ins_data
            ins_rcat   = ins_rcat
            ins_pod    = ins_pod
            ins_facts  = ins_facts
          CHANGING
            oldkey_ins = oldkey_ins.
      ENDIF.

* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_ins USING oldkey_ins
                                         anlanz
                                         anlcount
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_ins_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhandenn bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.

*    --> Nuss 15.09.2015
*    PERFORM erst_mig_datei3 TABLES i_ins_down
*                            USING firma
*                                  object
*                                  idttyp
*                                  bel_file.

    PERFORM erst_mig_datei TABLES i_ins_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.
*   <-- Nuss 15.09.2015

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.


  ENDIF.


ENDFUNCTION.
