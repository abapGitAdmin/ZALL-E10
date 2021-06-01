FUNCTION /ADESSO/MTE_ENT_REFVALUES.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_ANLAGE) LIKE  EANL-ANLAGE
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
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
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: p_beginn        LIKE  sy-datum.
  data: o_key           TYPE  EMG_OLDKEY.

  object   = 'REFVALUES'.
  ent_file = pfad_dat_ent.
  oldkey_rva = x_anlage.

  REFRESH irva_ettifb.



* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: irva_out, wrva_out, irva_ettifb, meldung, anz_obj.
  REFRESH: irva_out, irva_ettifb, meldung.
*<


*> Datenermittlung ---------

* ermitteln des Datums, ab wann die Anlage aufgebaut werden soll.
* Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
* Anlage noch nie abgerechnet wurde, wird die Anlage mit dem
* Einzugsdatum des zugeordneteten Vertrages migriert.
  CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
    EXPORTING
      x_anlage                = oldkey_rva
*   X_DPC_MR                =
   IMPORTING
*   Y_BEGABRPE              =
*   Y_BEGNACH               =
     y_default_date          = p_beginn
   EXCEPTIONS
     no_contract_found       = 1
     general_fault           = 2
     parameter_fault         = 3
     OTHERS                  = 4
            .
  IF sy-subrc <> 0.
    IF sy-subrc EQ 1 AND
       p_beginn IS INITIAL.
      SELECT SINGLE * FROM eanlh WHERE anlage = oldkey_rva
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
  ENDIF.


* ettifb
  SELECT * FROM ettifb  WHERE anlage EQ oldkey_rva
                          AND bis    GT p_beginn.

    MOVE-CORRESPONDING ettifb TO irva_ettifb.

    APPEND irva_ettifb.

  ENDSELECT.

  IF sy-subrc NE 0.
    meldung-meldung =
      'Es sind keine Bezugsgrößen in ETTIFB zu ermitteln'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_rva.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_REFVALUE'
    CALL FUNCTION ums_fuba
         EXPORTING
              firma       = firma
         TABLES
              meldung     = meldung
              irva_ettifb = irva_ettifb
         CHANGING
              oldkey_rva  = oldkey_rva.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_rva_out USING oldkey_rva
                             firma
                             object.


  LOOP AT irva_out INTO wrva_out.
    TRANSFER wrva_out TO ent_file.
  ENDLOOP.

ENDFUNCTION.
