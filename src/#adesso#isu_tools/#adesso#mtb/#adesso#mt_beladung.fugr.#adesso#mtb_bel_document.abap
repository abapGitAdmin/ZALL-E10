FUNCTION /adesso/mtb_bel_document.
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
  DATA  pobject          TYPE  emg_object. "für Paydoc
  DATA  bel_file        TYPE  emg_pfad.
  DATA  ent_file        TYPE  emg_pfad.
  DATA  pbel_file        TYPE  emg_pfad. "für Paydoc
  DATA  rep_name        TYPE  programm.
  DATA  form_name       TYPE  text30.
  DATA  syn_fehler      TYPE  text60.
  DATA  prep_name        TYPE  programm. "für Paydoc
  DATA  pform_name       TYPE  text30. "für Paydoc
  DATA  psyn_fehler      TYPE  text60. "für Paydoc
  DATA: itrans          LIKE  /adesso/mt_transfer.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: pidttyp         TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.
  DATA: pums_fuba        TYPE  funcname. "für Paydoc
  DATA: pcount(3) TYPE n.
  DATA: poldkey LIKE temksv-oldkey.
  DATA: laugrd LIKE dfkkop-augrd,
        lopbel LIKE dfkkop-opbel.

  object   = 'DOCUMENT'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'KO'.

  pobject   = 'PAYDOC'.
  pbel_file = pfad_dat_bel.
  REPLACE 'DOCUMENT' WITH 'PAYDOC' INTO pbel_file.
  pidttyp = 'FKKKO'.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'BEL'.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR pums_fuba.
  SELECT SINGLE zfuba INTO pums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = pobject
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

* Generierung des Reports für die Übergabestrukturen
*  CALL FUNCTION '/ADESSO/MTB_REP_GENERATE'
*    EXPORTING
*      firma               = firma
*      object              = pobject
*   IMPORTING
*     rep_name             = prep_name
*     form_name            = pform_name
*     syn_fehler           = psyn_fehler
*   TABLES
**    CODING              =
*     meldung              = meldung
*   EXCEPTIONS
*     error               = 1
*     OTHERS              = 2
*            .
*  IF sy-subrc <> 0.
*    IF NOT psyn_fehler IS INITIAL.
*      meldung-meldung = psyn_fehler.
*      APPEND meldung.
*    ENDIF.
*
*    RAISE gen_error.
*  ELSE.
*    TRANSLATE prep_name TO UPPER CASE.
*    TRANSLATE pform_name TO UPPER CASE.
*  ENDIF.


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
      IF itrans-oldkey NE oldkey_doc AND
            oldkey_doc NE space.
        SORT idoc_op BY augst DESCENDING.
* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DOCUMENT'
          CALL FUNCTION ums_fuba
               EXPORTING
                    firma       = firma
               TABLES
                    meldung     = meldung
                    idoc_ko     = idoc_ko
                    idoc_op     = idoc_op
                    idoc_opk    = idoc_opk
                    idoc_opl    = idoc_opl
                    idoc_addinf = idoc_addinf
               CHANGING
                    oldkey_doc  = oldkey_doc.
        ENDIF.
        CLEAR pcount.
        READ TABLE idoc_ko INDEX 1.
        CLEAR laugrd.
        SORT idoc_op BY augrd.
        LOOP AT idoc_op.
          IF idoc_op-augst = '9'.
*            IF laugrd <> idoc_op-augrd.
*              laugrd = idoc_op-augrd.
            IF lopbel <> idoc_op-opbel.
*                OR laugrd <> idoc_op-augrd.
              IF NOT laugrd IS INITIAL.
*              CHECK NOT idoc_op-augst IS INITIAL.
*              CHECK NOT ipay_fkkopk[] IS INITIAL.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
                PERFORM aufbereitung_dat_pay USING oldkey_pay
                                                   prep_name
                                                   pform_name.
*          CLEAR laugrd.
              ENDIF.
              laugrd = idoc_op-augrd.
              lopbel = idoc_op-opbel.
            ENDIF.
*            ON CHANGE OF idoc_op-augrd.
*              CHECK NOT idoc_op-augrd IS INITIAL.
            IF ipay_fkkko[] IS INITIAL.
              ADD 1 TO pcount.
              CONCATENATE oldkey_doc pcount INTO oldkey_pay.
              MOVE-CORRESPONDING idoc_ko TO ipay_fkkko.
              ipay_fkkko-blart = 'ZM'.
              ipay_fkkko-augrd = idoc_op-augrd.
              ipay_fkkko-budat = sy-datum.
              ipay_fkkko-bldat = idoc_op-augdt.
              ipay_fkkko-oibel = idoc_op-opbel.
              APPEND ipay_fkkko.
              CLEAR ipay_fkkko.
            ENDIF.
*            ENDON.
            ipay_fkkopk-betrw = idoc_op-augbt.
*            IF ipay_fkkopk-betrw < 0.
*              ipay_fkkopk-betrw = ipay_fkkopk-betrw * -1.
*            ENDIF.
            ipay_fkkopk-bukrs = idoc_op-bukrs.
            IF ipay_fkkopk-bukrs+3(1) = 1.
              ipay_fkkopk-hkont = '0076990400'.
            ELSE.
              ipay_fkkopk-hkont = '0076990300'.
            ENDIF.
            ipay_fkkopk-valut = idoc_op-augvd.
            APPEND ipay_fkkopk.
            CLEAR ipay_fkkopk.
            MOVE-CORRESPONDING idoc_op TO ipay_seltns.
            ipay_seltns-giart = idoc_op-gpart.
            ipay_seltns-viont = idoc_op-vkont.
            ipay_seltns-fiedn = idoc_op-faedn.
            ipay_seltns-oibel = idoc_op-opbel.
            ipay_seltns-viref = idoc_op-vtref.
            ipay_seltns-betrw = idoc_op-augbt.
            ipay_seltns-augrd = idoc_op-augrd.
            APPEND ipay_seltns.
            CLEAR ipay_seltns.

          ENDIF.
          AT LAST.
            IF NOT laugrd IS INITIAL.
*              CHECK NOT idoc_op-augst IS INITIAL.
*              CHECK NOT ipay_fkkopk[] IS INITIAL.
*  Dateiaufbereitung zum erstellen der Workbench-Dateien
              PERFORM aufbereitung_dat_pay USING oldkey_pay
                                                 prep_name
                                                 pform_name.
            ENDIF.
*            CLEAR laugrd.
          ENDAT.
        ENDLOOP.
        IF NOT idoc_ko[] IS INITIAL.
*  Dateiaufbereitung zum erstellen der Workbench-Dateien
          PERFORM aufbereitung_dat_doc USING oldkey_doc
                                             rep_name
                                             form_name.
          anz_obj = anz_obj + 1.
        ELSE.
          CLEAR: idoc_ko, idoc_op, idoc_opk, idoc_opl, idoc_addinf.
          REFRESH: idoc_ko, idoc_op, idoc_opk, idoc_opl, idoc_addinf.
        ENDIF.
      ENDIF.

* füllen der entsprechenden internern Tabellen je Altsystemschlüssel zum
* bearbeiten im Umschlüsselung-FUBA und später zur Aufbereitung der
* Migrationsdaten
* => je Datentyp eigene Tabelle
      CASE itrans-dttyp.
        WHEN 'KO'.
          CLEAR x_idoc_ko.
          MOVE itrans-data TO x_idoc_ko.
          MOVE-CORRESPONDING x_idoc_ko TO idoc_ko.
          APPEND idoc_ko.
          CLEAR idoc_ko.
          CLEAR laugrd.
        WHEN 'OP'.
          CLEAR x_idoc_op.
          MOVE itrans-data TO x_idoc_op.
          MOVE-CORRESPONDING x_idoc_op TO idoc_op.
          APPEND idoc_op.
          CLEAR idoc_op.
        WHEN 'OPK'.
          CLEAR x_idoc_opk.
          MOVE itrans-data TO x_idoc_opk.
          MOVE-CORRESPONDING x_idoc_opk TO idoc_opk.
          APPEND idoc_opk.
          CLEAR idoc_opk.
        WHEN 'OPL'.
          CLEAR x_idoc_opl.
          MOVE itrans-data TO x_idoc_opl.
          MOVE-CORRESPONDING x_idoc_opl TO idoc_opl.
          APPEND idoc_opl.
          CLEAR idoc_opl.
        WHEN 'ADDINF'.
          CLEAR x_idoc_addinf.
          MOVE itrans-data TO x_idoc_addinf.
          MOVE-CORRESPONDING x_idoc_addinf TO idoc_addinf.
          APPEND idoc_addinf.
          CLEAR idoc_addinf.
      ENDCASE.

      MOVE itrans-oldkey TO oldkey_doc.

    ELSE.
      SORT idoc_op BY augst DESCENDING.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_BEL_DOCUMENT'
        CALL FUNCTION ums_fuba
             EXPORTING
                  firma       = firma
             TABLES
                  meldung     = meldung
                  idoc_ko     = idoc_ko
                  idoc_op     = idoc_op
                  idoc_opk    = idoc_opk
                  idoc_opl    = idoc_opl
                  idoc_addinf = idoc_addinf
             CHANGING
                  oldkey_doc  = oldkey_doc.
      ENDIF.

      CLEAR pcount.
      CLEAR laugrd.
      SORT idoc_op BY augrd.
      READ TABLE idoc_ko INDEX 1.
      LOOP AT idoc_op.
        IF idoc_op-augst = '9'.
*            IF laugrd <> idoc_op-augrd.
*              laugrd = idoc_op-augrd.
          IF lopbel <> idoc_op-opbel.
*              OR laugrd <> idoc_op-augrd.
            IF NOT laugrd IS INITIAL.
*              CHECK NOT idoc_op-augst IS INITIAL.
*              CHECK NOT ipay_fkkopk[] IS INITIAL.

*  Dateiaufbereitung zum erstellen der Workbench-Dateien
              PERFORM aufbereitung_dat_pay USING oldkey_pay
                                                 prep_name
                                                 pform_name.
*          CLEAR laugrd.
            ENDIF.
            laugrd = idoc_op-augrd.
            lopbel = idoc_op-opbel.
          ENDIF.
*            ON CHANGE OF idoc_op-augrd.
*              CHECK NOT idoc_op-augrd IS INITIAL.
          IF ipay_fkkko[] IS INITIAL.
            ADD 1 TO pcount.
            CONCATENATE oldkey_doc pcount INTO oldkey_pay.
            MOVE-CORRESPONDING idoc_ko TO ipay_fkkko.
            ipay_fkkko-blart = 'ZM'.
            ipay_fkkko-augrd = idoc_op-augrd.
            ipay_fkkko-budat = sy-datum.
            ipay_fkkko-bldat = idoc_op-augdt.
            ipay_fkkko-oibel = idoc_op-opbel.
            APPEND ipay_fkkko.
            CLEAR ipay_fkkko.
          ENDIF.
*            ENDON.
          ipay_fkkopk-betrw = idoc_op-augbt.
*          IF ipay_fkkopk-betrw < 0.
*            ipay_fkkopk-betrw = ipay_fkkopk-betrw * -1.
*          ENDIF.
          ipay_fkkopk-bukrs = idoc_op-bukrs.
          IF ipay_fkkopk-bukrs+3(1) = 1.
            ipay_fkkopk-hkont = '0076990400'.
          ELSE.
            ipay_fkkopk-hkont = '0076990300'.
          ENDIF.
          ipay_fkkopk-valut = idoc_op-augvd.
          APPEND ipay_fkkopk.
          CLEAR ipay_fkkopk.
          MOVE-CORRESPONDING idoc_op TO ipay_seltns.
          ipay_seltns-giart = idoc_op-gpart.
          ipay_seltns-viont = idoc_op-vkont.
          ipay_seltns-fiedn = idoc_op-faedn.
          ipay_seltns-oibel = idoc_op-opbel.
          ipay_seltns-viref = idoc_op-vtref.
          ipay_seltns-betrw = idoc_op-augbt.
          ipay_seltns-augrd = idoc_op-augrd.
          APPEND ipay_seltns.
          CLEAR ipay_seltns.

        ENDIF.
        AT LAST.
          IF NOT laugrd IS INITIAL.
*              CHECK NOT idoc_op-augst IS INITIAL.
*              CHECK NOT ipay_fkkopk[] IS INITIAL.
*  Dateiaufbereitung zum erstellen der Workbench-Dateien
            PERFORM aufbereitung_dat_pay USING oldkey_pay
                                               prep_name
                                               pform_name.
          ENDIF.
*            CLEAR laugrd.
        ENDAT.
      ENDLOOP.


**  Dateiaufbereitung zum erstellen der Workbench-Dateien
*      PERFORM aufbereitung_dat_pay USING oldkey_pay
*                                         prep_name
*                                         pform_name.
* Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      IF NOT idoc_ko[] IS INITIAL.
        PERFORM aufbereitung_dat_doc USING oldkey_doc
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.
      ELSE.
        CLEAR: idoc_ko, idoc_op, idoc_opk, idoc_opl, idoc_addinf.
        REFRESH: idoc_ko, idoc_op, idoc_opk, idoc_opl, idoc_addinf.
      ENDIF.

      EXIT.

    ENDIF.
  ENDDO.


* Erstellen der Migrationsdatei
  READ TABLE i_doc_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhandenn bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_doc_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.

* Erstellen der Migrationsdatei
  READ TABLE i_pay_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' pobject
                 'vorhandenn bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_pay_down
                            USING firma
                                  pobject
                                  pidttyp
                                  pbel_file.

    CONCATENATE  'Datei' pbel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.







ENDFUNCTION.
