FUNCTION /ADESSO/MTB_BEL_PARTNER.
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
  DATA: lbut000 LIKE but000.

  object   = 'PARTNER'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'INIT'.

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
        CONCATENATE 'Falsche Migrationsfirma:' itrans-firma
          INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.

* Daten werden um einen Altsystemschlüssel verzögert aufgebaut, weil
* erstmal alle Strukturtabellen für den Umschlüsselungs-FUBA ermittelt
* werden müssen (siehe: case itrans-dttyp).
      IF itrans-oldkey NE oldkey_partner AND
            oldkey_partner NE space.


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_PARTNER'
          CALL FUNCTION ums_fuba
            EXPORTING
              firma      = firma
            TABLES
              meldung    = meldung
              i_init     = i_init
              i_ekun     = i_ekun
              i_but000   = i_but000
              i_but001   = i_but001
              i_but0bk   = i_but0bk
              i_but020   = i_but020
              i_but021   = i_but021
              i_but0cc   = i_but0cc
              i_shipto   = i_shipto
              i_taxnum   = i_taxnum
              i_eccard   = i_eccard
              i_eccrdh   = i_eccrdh
              i_but0is   = i_but0is
            CHANGING
              oldkey_par = oldkey_partner.
        ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_partner USING oldkey_partner
                                               rep_name
                                               form_name.
        anz_obj = anz_obj + 1.
      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'INIT'.
          CLEAR x_i_init.
          MOVE itrans-data TO x_i_init.
          MOVE-CORRESPONDING x_i_init TO i_init.
          APPEND i_init.
          CLEAR i_init.
        WHEN 'EKUN'.
          CLEAR x_i_ekun.
          MOVE itrans-data TO x_i_ekun.
          MOVE-CORRESPONDING x_i_ekun TO i_ekun.
          APPEND i_ekun.
          CLEAR i_ekun.
        WHEN 'BUT000'.
          CLEAR x_i_but000.
          MOVE itrans-data TO x_i_but000.
          MOVE-CORRESPONDING x_i_but000 TO i_but000.
          APPEND i_but000.
          CLEAR i_but000.
         WHEN 'BUTCOM'.
          CLEAR x_i_butcom.
          MOVE itrans-data TO x_i_butcom.
          MOVE-CORRESPONDING x_i_butcom TO i_butcom.
          APPEND i_butcom.
          CLEAR i_butcom.
        WHEN 'BUT001'.
          CLEAR x_i_but001.
          MOVE itrans-data TO x_i_but001.
          MOVE-CORRESPONDING x_i_but001 TO i_but001.
          APPEND i_but001.
          CLEAR i_but001.
        WHEN 'BUT0BK'.
          CLEAR x_i_but0bk.
          MOVE itrans-data TO x_i_but0bk.
          MOVE-CORRESPONDING x_i_but0bk TO i_but0bk.
          APPEND i_but0bk.
          CLEAR i_but0bk.
        WHEN 'BUT020'.
          CLEAR x_i_but020.
          MOVE itrans-data TO x_i_but020.
          MOVE-CORRESPONDING x_i_but020 TO i_but020.
          APPEND i_but020.
          CLEAR i_but020.
        WHEN 'BUT021'.
          CLEAR x_i_but021.
          MOVE itrans-data TO x_i_but021.
          MOVE-CORRESPONDING x_i_but021 TO i_but021.
          APPEND i_but021.
          CLEAR i_but021.
        WHEN 'BUT0CC'.
          CLEAR x_i_but0cc.
          MOVE itrans-data TO x_i_but0cc.
          MOVE-CORRESPONDING x_i_but0cc TO i_but0cc.
          APPEND i_but0cc.
          CLEAR i_but0cc.
        WHEN 'SHIPTO'.
          CLEAR x_i_shipto.
          MOVE itrans-data TO x_i_shipto.
          MOVE-CORRESPONDING x_i_shipto TO i_shipto.
          APPEND i_shipto.
          CLEAR i_shipto.
        WHEN 'TAXNUM'.
          CLEAR x_i_taxnum.
          MOVE itrans-data TO x_i_taxnum.
          MOVE-CORRESPONDING x_i_taxnum TO i_taxnum.
          APPEND i_taxnum.
          CLEAR i_taxnum.
        WHEN 'ECCARD'.
          CLEAR x_i_eccard.
          MOVE itrans-data TO x_i_eccard.
          MOVE-CORRESPONDING x_i_eccard TO i_eccard.
          APPEND i_eccard.
          CLEAR i_eccard.
        WHEN 'ECCRDH'.
          CLEAR x_i_eccrdh.
          MOVE itrans-data TO x_i_eccrdh.
          MOVE-CORRESPONDING x_i_eccrdh TO i_eccrdh.
          APPEND i_eccrdh.
          CLEAR i_eccrdh.

        WHEN 'BUT0IS'.
          CLEAR x_i_but0is.
          MOVE itrans-data TO x_i_but0is.
          MOVE-CORRESPONDING x_i_but0is TO i_but0is.
          APPEND i_but0is.
          CLEAR i_but0is.


      ENDCASE.

      MOVE itrans-oldkey TO oldkey_partner.

    ELSE.

** bereits migrierte Partner ausschliessen
*      READ TABLE i_init INDEX 1.
*      SELECT SINGLE * FROM but000 INTO lbut000
*                      WHERE partner = i_init-partner.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_PARTNER'
        CALL FUNCTION ums_fuba
          EXPORTING
            firma      = firma
          TABLES
            meldung    = meldung
            i_init     = i_init
            i_ekun     = i_ekun
            i_but000   = i_but000
            i_but001   = i_but001
            i_but0bk   = i_but0bk
            i_but020   = i_but020
            i_but021   = i_but021
            i_but0cc   = i_but0cc
            i_shipto   = i_shipto
            i_taxnum   = i_taxnum
            i_eccard   = i_eccard
            i_eccrdh   = i_eccrdh
            i_but0is   = i_but0is
          CHANGING
            oldkey_par = oldkey_partner.
      ENDIF.

* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_partner USING oldkey_partner
                                             rep_name
                                             form_name.
      anz_obj = anz_obj + 1.
      EXIT.
    ENDIF.
  ENDDO.



* Erstellen der Migrationsdatei
  READ TABLE i_par_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_par_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.






ENDFUNCTION.
