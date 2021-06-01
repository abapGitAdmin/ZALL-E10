FUNCTION /adesso/mtb_bel_adrstreet.
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
*  DATA: lehau LIKE ehauisu.
  DATA: lestr LIKE adrstreet.

  object   = 'ADRSTREET'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
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
*      IF itrans-oldkey NE oldkey_con AND
      IF itrans-oldkey NE oldkey_reg AND
            oldkey_reg NE space.

        READ TABLE i_co_str INDEX 1.
        SELECT SINGLE * FROM adrstreet INTO lestr
        WHERE strt_code = i_co_str-strt_code.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
*        IF sy-subrc <> 0.
          IF NOT ums_fuba IS INITIAL.
            CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
                 TABLES
                      meldung    = meldung
                      i_co_str   = i_co_str
                      i_co_pcd   = i_co_pcd
                 CHANGING
                      oldkey_reg = oldkey_reg.
          ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_reg USING oldkey_reg
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.
*        ELSE.
*          CONCATENATE 'Strassennamen' i_co_str-strt_code
*          'ist bereits vorhanden' INTO meldung-meldung.
*          APPEND meldung.
*          CLEAR: i_co_str, i_co_pcd.
*          REFRESH: i_co_str, i_co_pcd.
*        ENDIF.
      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'STREET'.
          CLEAR x_i_co_str.
          MOVE itrans-data TO x_i_co_str.
          MOVE-CORRESPONDING x_i_co_str TO i_co_str.
          APPEND i_co_str.
          CLEAR i_co_str.
        WHEN 'STRSEC'.
          CLEAR x_i_co_pcd.
          MOVE itrans-data TO x_i_co_pcd.
          MOVE-CORRESPONDING x_i_co_pcd TO i_co_pcd.
          APPEND i_co_pcd.
          CLEAR i_co_pcd.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_reg.

    ELSE.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        READ TABLE i_co_str INDEX 1.
        SELECT SINGLE * FROM adrstreet INTO lestr
        WHERE strt_code = i_co_str-strt_code.
* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
          IF NOT ums_fuba IS INITIAL.
            CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
                 TABLES
                      meldung    = meldung
                      i_co_str   = i_co_str
                      i_co_pcd   = i_co_pcd
                 CHANGING
                      oldkey_reg = oldkey_reg.
          ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_reg USING oldkey_reg
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_reg_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_reg_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.

ENDFUNCTION.
