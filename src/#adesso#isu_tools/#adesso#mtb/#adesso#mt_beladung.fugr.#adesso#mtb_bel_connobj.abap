FUNCTION /adesso/mtb_bel_connobj.
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
  DATA: lehau LIKE ehauisu.

  object   = 'CONNOBJ'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'CO_EHA'.

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
      IF itrans-oldkey NE oldkey_con AND
            oldkey_con NE space..

        READ TABLE i_co_eha INDEX 1.
        SELECT SINGLE * FROM ehauisu INTO lehau
        WHERE haus = i_co_eha-haus.
* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_CONNOBJ'
            CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
                 TABLES
                      meldung    = meldung
                      i_co_eha   = i_co_eha
                      i_co_adr   = i_co_adr
                      i_co_com   = i_co_com
                 CHANGING
                      oldkey_con = oldkey_con.
          ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_con USING oldkey_con
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.
      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'CO_EHA'.
          CLEAR x_i_co_eha.
          MOVE itrans-data TO x_i_co_eha.
          MOVE-CORRESPONDING x_i_co_eha TO i_co_eha.
          APPEND i_co_eha.
          CLEAR i_co_eha.
        WHEN 'CO_ADR'.
          CLEAR x_i_co_adr.
          MOVE itrans-data TO x_i_co_adr.
          MOVE-CORRESPONDING x_i_co_adr TO i_co_adr.
          APPEND i_co_adr.
          CLEAR i_co_adr.
        WHEN 'CO_COM'.
          CLEAR x_i_co_com.
          MOVE itrans-data TO x_i_co_com.
          MOVE-CORRESPONDING x_i_co_com TO i_co_com.
          APPEND i_co_com.
          CLEAR i_co_com.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_con.

    ELSE.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        READ TABLE i_co_eha INDEX 1.
        SELECT SINGLE * FROM ehauisu INTO lehau
        WHERE haus = i_co_eha-haus.
* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_CONNOBJ'
            CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
                 TABLES
                      meldung    = meldung
                      i_co_eha   = i_co_eha
                      i_co_adr   = i_co_adr
                      i_co_com   = i_co_com
                 CHANGING
                      oldkey_con = oldkey_con.
          ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_con USING oldkey_con
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.
      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_con_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_con_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.


ENDFUNCTION.
