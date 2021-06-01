FUNCTION /ADESSO/MTB_BEL_PAYMENT_NEU.
*"--------------------------------------------------------------------
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
*"--------------------------------------------------------------------

  DATA  object          TYPE  emg_object.
  DATA  bel_file        TYPE  emg_pfad.
  DATA  ent_file        TYPE  emg_pfad.
  DATA  rep_name        TYPE  programm.
  DATA  form_name       TYPE  text30.
  DATA  syn_fehler      TYPE  text60.
  DATA: itrans          LIKE  /adesso/mt_transfer.
  DATA: idttyp          TYPE  emg_dttyp.
  DATA: ums_fuba        TYPE  funcname.
  DATA: wa_summe        TYPE  betrw_kk.

  DATA: BEGIN OF ipay_seltns2 OCCURS 0,
          oibel LIKE emig_pay_seltns-oibel,
          viref LIKE emig_pay_seltns-viref,
          giart LIKE emig_pay_seltns-giart,
          viont LIKE emig_pay_seltns-viont,
          fiedn LIKE emig_pay_seltns-fiedn,
          augrd LIKE emig_pay_seltns-augrd,
          waers LIKE emig_pay_seltns-waers,
          betrw LIKE emig_pay_seltns-betrw,
        END OF ipay_seltns2.

  object   = 'PAYMENT'.
  bel_file = pfad_dat_bel.
  ent_file = pfad_dat_ent.
  idttyp   = 'FKKKO'.

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

* open Dataset
  OPEN DATASET ent_file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
*  OPEN DATASET ent_file FOR INPUT IN TEXT MODE ENCODING NON-UNICODE.

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

*     Migrationsfirma prüfen.
      IF itrans-firma NE firma.
        CONCATENATE 'Falsche Migrationsfirma:'
                     itrans-firma
          INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.


      IF itrans-oldkey NE oldkey_pay AND
            oldkey_pay NE space.

*       aus mehreren Abschlägen (verschiedene Sparten) werden jetzt
*       pro Fälligkeit separate Einträge erstellt
**       --> Auskommentiert für WBD-Projekt
**       Da haben wir nir eine Sparte
*        REFRESH ipay_seltns2.
*        LOOP AT ipay_seltns.
*          MOVE-CORRESPONDING ipay_seltns TO ipay_seltns2.
*          APPEND ipay_seltns2.
*        ENDLOOP.
*        REFRESH ipay_seltns.
*
**       SORT ipay_seltns2 BY giart viont fiedn augrd waers.
*        SORT ipay_seltns2 BY giart viont fiedn.
*
*        LOOP AT ipay_seltns2.
*          AT NEW fiedn.
*            CLEAR wa_summe.
*          ENDAT.
*
*          ADD ipay_seltns2-betrw TO wa_summe.
*
*          AT END OF fiedn.
*            CLEAR ipay_seltns.
*            MOVE-CORRESPONDING ipay_seltns2 TO ipay_seltns.
*            MOVE wa_summe TO ipay_seltns-betrw.
*            APPEND ipay_seltns.
*          ENDAT.
*        ENDLOOP.

*       Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
        IF NOT ums_fuba IS INITIAL.
          CALL FUNCTION ums_fuba
            EXPORTING
              firma       = firma
            TABLES
              meldung     = meldung
              ipay_fkkko  = ipay_fkkko
              ipay_fkkopk = ipay_fkkopk
              ipay_seltns = ipay_seltns
            CHANGING
              oldkey_pay  = oldkey_pay.
        ENDIF.
*         Dateiaufbereitung zum erstellen der Workbench-Dateien
        PERFORM aufbereitung_dat_pay USING oldkey_pay
                                           rep_name
                                           form_name.
        anz_obj = anz_obj + 1.
      ENDIF.

      CASE itrans-dttyp.
        WHEN 'FKKKO'.
          CLEAR x_ipay_fkkko.
          MOVE itrans-data TO x_ipay_fkkko.
          MOVE-CORRESPONDING x_ipay_fkkko TO ipay_fkkko.
          APPEND ipay_fkkko.
          CLEAR ipay_fkkko.
        WHEN 'FKKOPK'.
          IF NOT ipay_fkkko[] IS INITIAL.
            CLEAR x_ipay_fkkopk.
            MOVE itrans-data TO x_ipay_fkkopk.
            MOVE-CORRESPONDING x_ipay_fkkopk TO ipay_fkkopk.
            APPEND ipay_fkkopk.
            CLEAR ipay_fkkopk.
          ENDIF.
        WHEN 'SELTNS'.
          IF NOT ipay_fkkko[] IS INITIAL.
            CLEAR x_ipay_seltns.
            MOVE itrans-data TO x_ipay_seltns.
            MOVE-CORRESPONDING x_ipay_seltns TO ipay_seltns.
            APPEND ipay_seltns.
            CLEAR ipay_seltns.
          ENDIF.
      ENDCASE.

      IF NOT ipay_fkkko[] IS INITIAL.
        MOVE itrans-oldkey TO oldkey_pay.
      ENDIF.

    ELSE.
**     Auskpommentiert für WBD-Projekt
*      REFRESH ipay_seltns2.
*      LOOP AT ipay_seltns.
*        MOVE-CORRESPONDING ipay_seltns TO ipay_seltns2.
*        APPEND ipay_seltns2.
*      ENDLOOP.
*      REFRESH ipay_seltns.
*
**     SORT ipay_seltns2 BY giart viont fiedn augrd waers.
*      SORT ipay_seltns2 BY giart viont fiedn.
*
*      LOOP AT ipay_seltns2.
*        AT NEW fiedn.
*          CLEAR wa_summe.
*        ENDAT.
*
*        ADD ipay_seltns2-betrw TO wa_summe.
*
*        AT END OF fiedn.
*          CLEAR ipay_seltns.
*          MOVE-CORRESPONDING ipay_seltns2 TO ipay_seltns.
*          MOVE wa_summe TO ipay_seltns-betrw.
*          APPEND ipay_seltns.
*        ENDAT.
*      ENDLOOP.

*     Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
      IF NOT ums_fuba IS INITIAL.
        CALL FUNCTION ums_fuba
          EXPORTING
            firma       = firma
          TABLES
            meldung     = meldung
            ipay_fkkko  = ipay_fkkko
            ipay_fkkopk = ipay_fkkopk
            ipay_seltns = ipay_seltns
          CHANGING
            oldkey_pay  = oldkey_pay.
      ENDIF.

*     Verarbeitung der noch fehlenden Sätze (Altsystemschlüssel)
      PERFORM aufbereitung_dat_pay USING oldkey_pay
                                         rep_name
                                         form_name.
      anz_obj = anz_obj + 1.

      EXIT.
    ENDIF.

  ENDDO.

* Erstellen der Migrationsdatei
  READ TABLE i_pay_down INDEX 1.
  IF sy-subrc NE 0.
    CONCATENATE  'Keine Datensätze für Objekt' object
                 'vorhandenn bzw. erzeugt'
           INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
    RAISE error.

  ELSE.
    PERFORM erst_mig_datei TABLES i_pay_down
                            USING firma
                                  object
                                  idttyp
                                  bel_file.

    CONCATENATE  'Datei' bel_file 'wurde erzeugt'
             INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.

  ENDIF.


ENDFUNCTION.
