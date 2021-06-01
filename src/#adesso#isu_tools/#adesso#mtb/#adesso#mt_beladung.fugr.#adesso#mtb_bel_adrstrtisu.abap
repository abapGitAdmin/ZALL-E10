FUNCTION /ADESSO/MTB_BEL_ADRSTRTISU.
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
*  DATA: lestr LIKE adrstrtstr.
  DATA: lestr LIKE adrstreetd.

  object   = 'ADRSTRTISU'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
*  idttyp   = 'CO_EHA'.
*  idttyp   = 'ISU'.
  idttyp   = 'STREET'.

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
      IF itrans-oldkey NE oldkey_rag AND
            oldkey_rag NE space.

        READ TABLE i_co_ist INDEX 1.
        SELECT single * FROM adrstreet INTO lestr
        WHERE strt_code = i_co_ist-strt_code.
* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
            CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
                 TABLES
                      meldung    = meldung
                      i_co_ist   = i_co_ist
                      i_co_isu   = i_co_isu
                      i_co_mru   = i_co_mru
                      i_co_con   = i_co_con
                      i_co_css   = i_co_css
                 CHANGING
                      oldkey_rag = oldkey_rag.
          ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_rag USING oldkey_rag
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.
      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'STREET'.
          CLEAR x_i_co_isT.
          MOVE itrans-data TO x_i_co_isT.
          MOVE-CORRESPONDING x_i_co_ist TO i_co_ist.
          APPEND i_co_ist.
          CLEAR i_co_ist.

        WHEN 'ISU'.
          CLEAR x_i_co_isu.
          MOVE itrans-data TO x_i_co_isu.
          MOVE-CORRESPONDING x_i_co_isu TO i_co_isu.
          APPEND i_co_isu.
          CLEAR i_co_isu.
        WHEN 'MRU'.
          CLEAR x_i_co_mru.
          MOVE itrans-data TO x_i_co_mru.
          MOVE-CORRESPONDING x_i_co_mru TO i_co_mru.
          APPEND i_co_mru.
          CLEAR i_co_mru.
        WHEN 'KON'.
          CLEAR x_i_co_con.
          MOVE itrans-data TO x_i_co_con.
          MOVE-CORRESPONDING x_i_co_con TO i_co_con.
          APPEND i_co_con.
          CLEAR i_co_con.
        WHEN 'CCS'.
          CLEAR x_i_co_css.
          MOVE itrans-data TO x_i_co_css.
          MOVE-CORRESPONDING x_i_co_css TO i_co_css.
          APPEND i_co_css.
          CLEAR i_co_css.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_rag.

    ELSE.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        READ TABLE i_co_ist INDEX 1.


        SELECT SINGLE * FROM ADRSTReet INTO lestr
        WHERE country   = 'DE' and
              strt_code = i_co_ist-strt_code.
* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
            CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
                 TABLES
                      meldung    = meldung
                      i_co_ist   = i_co_ist
                      i_co_isu   = i_co_isu
                      i_co_mru   = i_co_mru
                      i_co_con   = i_co_con
                      i_co_css   = i_co_css
                 CHANGING
                      oldkey_rag = oldkey_rag.
          ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_rag USING oldkey_rag
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.
      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_rag_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_rag_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.



ENDFUNCTION.
