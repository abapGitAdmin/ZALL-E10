FUNCTION /ADESSO/MTB_BEL_POD.
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

  object   = 'POD'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'UIHEAD'.

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
      IF itrans-oldkey NE oldkey_pod AND
            oldkey_pod NE space.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_POD'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung      = meldung
                    ipod_UIHEAD  = ipod_UIHEAD
                    ipod_UISRC   = ipod_UISRC
                    ipod_UITANL  = ipod_UITANL
                    ipod_ZWNUMM  = ipod_ZWNUMM
                    ipod_UIEXT   = ipod_UIEXT
                    ipod_UIGRID  = ipod_UIGRID
               CHANGING
                    oldkey_pod   = oldkey_pod.
        ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_pod USING oldkey_pod
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.

      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'UIHEAD'.
          MOVE itrans-data TO ipod_UIHEAD.
          APPEND ipod_UIHEAD.
          CLEAR ipod_UIHEAD.
        WHEN 'UISRC'.
          MOVE itrans-data TO ipod_UISRC.
          APPEND ipod_UISRC.
          CLEAR ipod_UISRC.
        WHEN 'UITANL'.
          MOVE itrans-data TO ipod_UITANL.
          APPEND ipod_UITANL.
          CLEAR ipod_UITANL.
        WHEN 'ZWNUMM'.
          MOVE itrans-data TO ipod_ZWNUMM.
          APPEND ipod_ZWNUMM.
          CLEAR ipod_ZWNUMM.
        WHEN 'UIEXT'.
          MOVE itrans-data TO ipod_UIEXT.
          APPEND ipod_UIEXT.
          CLEAR ipod_UIEXT.
        WHEN 'UIGRID'.
          MOVE itrans-data TO ipod_UIGRID.
          APPEND ipod_UIGRID.
          CLEAR ipod_UIGRID.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_pod.

    ELSE.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_POD'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung      = meldung
                    ipod_UIHEAD  = ipod_UIHEAD
                    ipod_UISRC   = ipod_UISRC
                    ipod_UITANL  = ipod_UITANL
                    ipod_ZWNUMM  = ipod_ZWNUMM
                    ipod_UIEXT   = ipod_UIEXT
                    ipod_UIGRID  = ipod_UIGRID
               CHANGING
                    oldkey_pod   = oldkey_pod.
        ENDIF.


* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_pod USING oldkey_pod
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_pod_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_pod_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.



ENDFUNCTION.
