FUNCTION /ADESSO/MTE_ENT_MOVE_IN_H.
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

  object     = 'MOVE_IN_H'.
  ent_file   = pfad_dat_ent.
  oldkey_moh = x_vertrag.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  CLEAR: imoh_out, wmoh_out, imoh_ever, meldung, anz_obj.
  REFRESH: imoh_out, imoh_ever, meldung.

*> Datenermittlung ---------
  CLEAR ever.
  SELECT SINGLE * FROM ever WHERE vertrag = oldkey_moh.
  IF sy-subrc NE 0.
    meldung-meldung =
      'Der Vertrag ist in EVER nicht vorhanden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

  MOVE-CORRESPONDING ever TO imoh_ever.
  MOVE ever-einzdat TO imoh_ever-einzdat_alt.

* Das Objekt kann auch die historischen Verträge betreffen,
* die noch nicht abgerechnet wurden. BegAbrPe ist dann wie bei
* MOVE_IN migrationsrelevant
  IF ever-fakturiert IS INITIAL.
    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
      EXPORTING
        x_anlage       = ever-anlage
      IMPORTING
*       Änderung eingeführt, ungetestet nach dem ersten MIG-Lauf;
*       Das Default-Date bringt bei beendeten Verträgen das Auszdat + 1Tag;
*       Das verursachte Fehler bei beendeten Verträgen ohne Kz-Fakturiert
        y_begabrpe = p_beginn
*       y_default_date = p_beginn
      EXCEPTIONS
        OTHERS         = 4.

    IF sy-subrc = 0 AND
       p_beginn IS NOT INITIAL.

**    Größeren Wert von Einzugsdatum und Beginn der Abrechnungsperiode nehmen
*      MOVE p_beginn TO imoh_ever-einzdat.
      IF p_beginn GE ever-einzdat.
        MOVE p_beginn TO imoh_ever-einzdat.
      ELSE.
        MOVE ever-einzdat TO imoh_ever-einzdat.
      ENDIF.

    ENDIF.
  ENDIF.

  APPEND imoh_ever.
*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_moh.
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
        imoi_ever  = imoh_ever
      CHANGING
        oldkey_moh = oldkey_moh.
  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_moh_out USING oldkey_moh
                             firma
                             object
                             anz_everd.


  LOOP AT imoh_out INTO wmoh_out.
    TRANSFER wmoh_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
