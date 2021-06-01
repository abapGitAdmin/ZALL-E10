FUNCTION /adesso/mtb_bel_instln_nn.
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

  object   = 'INSTLN_NN'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'KEY'.

*  REFRESH ins_facts.

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
      IF itrans-oldkey NE oldkey_inn AND
            oldkey_inn NE space.


*       Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.

          CALL FUNCTION ums_fuba
            EXPORTING
              firma      = firma
            TABLES
              meldung    = meldung
              inn_key    = inn_key
              inn_data   = inn_data
              inn_rcat   = inn_rcat
              inn_pod    = inn_pod
            CHANGING
              oldkey_inn = oldkey_inn.
        ENDIF.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_inn USING oldkey_inn
                                           anlanz
                                           anlcount
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.


*-----------------------------------------------------------<<<
      ENDIF.
* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'KEY'.
          CLEAR x_inn_key.
          MOVE itrans-data TO x_inn_key.
          MOVE-CORRESPONDING x_inn_key TO inn_key.
          APPEND inn_key.
          CLEAR inn_key.
        WHEN 'DATA'.
          CLEAR x_inn_data.
          MOVE itrans-data TO x_inn_data.
          MOVE-CORRESPONDING x_inn_data TO inn_data.
          anlanz = 1.
          anlcount = 1.
          APPEND inn_data.
          CLEAR inn_data.
        WHEN 'RCAT'.
          CLEAR x_inn_rcat.
          MOVE itrans-data TO x_inn_rcat.
          MOVE-CORRESPONDING x_inn_rcat TO inn_rcat.
          APPEND inn_rcat.
          CLEAR inn_rcat.
        WHEN 'POD'.
          CLEAR x_inn_pod.
          MOVE itrans-data TO x_inn_pod.
          MOVE-CORRESPONDING x_inn_pod TO inn_pod.
          APPEND inn_pod.
          CLEAR inn_pod.

*        WHEN 'FACTS'. "Datentyp Fakten aus eigener Tabelle
*          MOVE itrans-data TO ins_facts.
*          APPEND ins_facts.
*          CLEAR ins_facts.

      ENDCASE.

      MOVE itrans-oldkey TO oldkey_inn.


    ELSE.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.

        CALL FUNCTION ums_fuba
          EXPORTING
            firma      = firma
          TABLES
            meldung    = meldung
            inn_key    = inn_key
            inn_data   = inn_data
            inn_rcat   = inn_rcat
            inn_pod    = inn_pod
          CHANGING
            oldkey_inn = oldkey_inn.
      ENDIF.

* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_inn USING oldkey_inn
                                         anlanz
                                         anlcount
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_inn_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhandenn bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.


*    --> Nuss 15.09.2015
*    PERFORM erst_mig_datei3 TABLES i_inn_down
*                            USING firma
*                                  object
*                                  idttyp
*                                  bel_file.

    PERFORM erst_mig_datei TABLES i_inn_down
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
