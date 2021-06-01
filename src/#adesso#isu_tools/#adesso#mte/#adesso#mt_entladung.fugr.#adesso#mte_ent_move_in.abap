FUNCTION /adesso/mte_ent_move_in.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_VERTRAG) LIKE  EVER-VERTRAG
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_EVERD) TYPE  I
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
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: p_beginn        LIKE  sy-datum.
  DATA: o_key           TYPE  emg_oldkey.

** --> Nuss 17.03.2016 für WBD
  DATA: ls_erch TYPE erch,
        lt_erch TYPE STANDARD TABLE OF erch,
        wa_erch TYPE erch.
** <-- Nuss 17.03.2016

  object     = 'MOVE_IN'.
  ent_file   = pfad_dat_ent.
  oldkey_moi = x_vertrag.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.



*>   Initialisierung
  CLEAR: imoi_out, wmoi_out, imoi_ever, meldung, anz_obj.
  REFRESH: imoi_out, imoi_ever, meldung.
*<


*> Datenermittlung ---------
  CLEAR ever.
  SELECT SINGLE * FROM ever WHERE vertrag = oldkey_moi.
  IF sy-subrc NE 0.
    meldung-meldung =
      'Der Vertrag ist in EVER nicht vorhanden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Das echte Einzugsdatum aus dem Altsystem wird in den MIG-Projekten
* immer nur zur Informationszwecken genuzt.
  MOVE ever-einzdat TO ever-einzdat_alt.
* Das neue Einzug-DAT wird erst weiter unten projektabhängig festgelegt
  CLEAR ever-einzdat.


  MOVE-CORRESPONDING ever TO imoi_ever.

* Einzugsdatum aus Tabelle /ADESSO/MTE_DTAB
  SELECT SINGLE * FROM /adesso/mte_dtab.
  IF sy-subrc = 0.
    p_beginn = /adesso/mte_dtab-datab.
  ELSE.

*> Einzugsdatum aus Anlagenbeginn ermitteln

* ermitteln des Datums, ab wann die Anlage aufgebaut worden ist.
* Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
* Anlage noch nie abgerechnet wurde, wurde die Anlage mit dem
* Einzugsdatum des zugeordneteten Vertrages migriert.
    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
      EXPORTING
        x_anlage          = ever-anlage
*       X_DPC_MR          =
      IMPORTING
*       Y_BEGABRPE        =
*       Y_BEGNACH         =
        y_previous_bill   = ls_erch      "Nuss 17.03.2016
        y_default_date    = p_beginn
      EXCEPTIONS
        no_contract_found = 1
        general_fault     = 2
        parameter_fault   = 3
        OTHERS            = 4.
    IF sy-subrc <> 0.
      IF sy-subrc EQ 1 AND
         p_beginn IS INITIAL.
        SELECT SINGLE * FROM eanlh WHERE anlage = oldkey_ins
                                     AND bis    = '99991231'.
        IF sy-subrc EQ 0.
          MOVE eanlh-ab TO p_beginn.
        ELSE.
          meldung-meldung =
            'Es ist kein Anlagen-Beginndatum zu ermitteln'.
          APPEND meldung.
          RAISE wrong_data.
        ENDIF.

      ELSE.
        meldung-meldung =
          'Es ist kein Anlagen-Beginndatum zu ermitteln'.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.
**  --> Nuss 17.03.2016  für WBD
*   Bei Zwischenabrechnungen wird das Einzugsdatum auf den Folgetag der letzten Turnusabrechnung
*   gesetzt.
    ELSE.
      IF ls_erch-abrvorg = '02'.
        CLEAR lt_erch.
        SELECT * FROM erch INTO TABLE lt_erch
          WHERE vertrag = ls_erch-vertrag
            AND abrvorg = '01'
            AND erchc_v = 'X'
            AND simulation = ' '
            AND stornodat = '00000000'.
        IF lt_erch IS NOT INITIAL.
          SORT lt_erch BY endabrpe DESCENDING.
          READ TABLE lt_erch INTO wa_erch INDEX 1.
          p_beginn = ( wa_erch-endabrpe + 1 ).
**      Es lag noch keine Turnusabrechnung vor
        ELSE.
          p_beginn = ever-einzdat_alt.
        ENDIF.
      ENDIF.
    ENDIF.
** <-- Nuss 17.03.2016

    ENDIF.

* --> Nuss 22.10.2015
*  p_beginn = p_beginn + 1.
* <-- Nuss 22.10.2015

  MOVE p_beginn TO imoi_ever-einzdat.

  APPEND imoi_ever.
*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_moi.
  CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
    EXPORTING
      i_firma  = firma
      i_object = object
      i_oldkey = o_key
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    meldung-meldung =
        'Fehler bei wegschreiben in Entlade-KSV'.
    APPEND meldung.
    RAISE error.
  ENDIF.
*<< Wegschreiben des Objektschlüssels in Entlade-KSV

  ADD 1 TO anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
  IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_MOVE_IN'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma      = firma
      TABLES
        meldung    = meldung
        imoi_ever  = imoi_ever
      CHANGING
        oldkey_moi = oldkey_moi.
  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_moi_out USING oldkey_moi
                             firma
                             object
                             anz_everd.

  LOOP AT imoi_out INTO wmoi_out.
    TRANSFER wmoi_out TO ent_file.
  ENDLOOP.





ENDFUNCTION.
