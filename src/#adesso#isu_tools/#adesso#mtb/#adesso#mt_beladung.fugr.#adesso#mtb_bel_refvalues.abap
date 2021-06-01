FUNCTION /adesso/mtb_bel_refvalues.
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
  DATA: oldanl          LIKE itrans-oldkey.
*  DATA: itemksv LIKE TABLE OF temksv WITH HEADER LINE.
  DATA: veranz TYPE n.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.

  object   = 'REFVALUES'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'KEY'.

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
      IF itrans-oldkey NE oldkey_rva AND
            oldkey_rva NE space.


*>>>2VERTRAGSMODELL
*> Die Bezugsgrößen werden nur für die Vertriebsanlage benötigt
*      SELECT * FROM temksv INTO TABLE itemksv
*                    WHERE firma = firma
*                    AND   object = 'INSTLN'
*                    AND oldkey LIKE oldanl.
*
*      DESCRIBE TABLE itemksv LINES veranz.
*      IF veranz = 0.
*        READ TABLE irva_ETTIFB INDEX 1.
*        MESSAGE s001(/adesso/mt_n) WITH 'keine Umschlüsselung für Anlage'
*        irva_ETTIFB-anlage 'vorhanden' INTO meldung-meldung.
*        APPEND meldung.
*      ENDIF.
*<<<2VERTRAGSMODELL

*>>>2VERTRAGSMODELL
*      LOOP AT itemksv.
*        if itemksv-oldkey+10(1) = 'V'.
*         loop at irva_ETTIFB.
*          irva_ETTIFB-anlage = itemksv-newkey.
*          modify irva_ETTIFB.
*         endloop.
*        endif.
*      endloop.
*<<<2VERTRAGSMODELL


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_REFVALUE'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung      = meldung
                    irva_ettifb  = irva_ettifb
                CHANGING
                    oldkey_rva   = oldkey_rva.
        ENDIF.


*  Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_rva USING oldkey_rva
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.

      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'ETTIFB'.
          MOVE itrans-data TO irva_ettifb.
*>>>2VERTRAGSMODELL
*          CONCATENATE irva_ETTIFB-anlage '%' INTO oldanl.
*<<<2VERTRAGSMODELL
          APPEND irva_ettifb.
          CLEAR irva_ettifb.

*        WHEN 'KEY'.
*          MOVE itrans-data TO irva_KEY.
*          APPEND irva_KEY.
*          CLEAR irva_KEY.
*        WHEN 'REFVAL'.
*          MOVE itrans-data TO irva_REFVAL.
*          APPEND irva_REFVAL.
*          CLEAR irva_REFVAL.
*        WHEN 'TRE'.
*          MOVE itrans-data TO irva_TRE.
*          APPEND irva_TRE.
*          CLEAR irva_TRE.
*        WHEN 'BART'.
*          MOVE itrans-data TO irva_BART.
*          APPEND irva_BART.
*          CLEAR irva_BART.
*        WHEN 'HIST'.
*          MOVE itrans-data TO irva_HIST.
*          APPEND irva_HIST.
*          CLEAR irva_HIST.
*        WHEN 'HZG'.
*          MOVE itrans-data TO irva_HZG.
*          APPEND irva_HZG.
*          CLEAR irva_HZG.
*        WHEN 'ADDR'.
*          MOVE itrans-data TO irva_ADDR.
*          APPEND irva_ADDR.
*          CLEAR irva_ADDR.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_rva.

    ELSE.

*>>>2VERTRAGSMODELL
*> Die Bezugsgrößen werden nur für die Vertriebsanlage benötigt
*      SELECT * FROM temksv INTO TABLE itemksv
*                    WHERE firma = firma
*                    AND   object = 'INSTLN'
*                    AND oldkey LIKE oldanl.
*
*      DESCRIBE TABLE itemksv LINES veranz.
*      IF veranz = 0.
*        READ TABLE irva_ETTIFB INDEX 1.
*        MESSAGE s001(/adesso/mt_n) WITH 'keine Umschlüsselung für Anlage'
*        irva_ETTIFB-anlage 'vorhanden' INTO meldung-meldung.
*        APPEND meldung.
*      ENDIF.
*<<<2VERTRAGSMODELL

*>>>2VERTRAGSMODELL
*      LOOP AT itemksv.
*        if itemksv-oldkey+10(1) = 'V'.
*         loop at irva_ETTIFB.
*          irva_ETTIFB-anlage = itemksv-newkey.
*          modify irva_ETTIFB.
*         endloop.
*        endif.
*      endloop.
*<<<2VERTRAGSMODELL


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_REFVALUE'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma          = firma
               TABLES
                    meldung      = meldung
                    irva_ettifb  = irva_ettifb
               CHANGING
                    oldkey_rva   = oldkey_rva.
        ENDIF.


* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_rva USING oldkey_rva
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_rva_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhanden bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_rva_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.







ENDFUNCTION.
