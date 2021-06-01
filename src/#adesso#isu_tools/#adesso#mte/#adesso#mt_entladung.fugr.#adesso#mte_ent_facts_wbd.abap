FUNCTION /adesso/mte_ent_facts_wbd.
*"--------------------------------------------------------------------
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
*"--------------------------------------------------------------------

  DATA  object          TYPE  emg_object.
  DATA: ums_fuba        TYPE  funcname.
  DATA: p_beginn        LIKE  sy-datum.
  DATA: p_ende          LIKE  sy-datum.
  DATA: o_key           TYPE  emg_oldkey.

  DATA: iettifn         TYPE ettifn OCCURS 0 WITH HEADER LINE.
  DATA: ieanlh          TYPE eanlh OCCURS 0 WITH HEADER LINE.

  object   = 'FACTS'.
  oldkey_fac = x_anlage.

  REFRESH ifac_facts.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.



*>   Initialisierung
  PERFORM init_fac.
  CLEAR: ifac_out, wfac_out, meldung, anz_obj.
  REFRESH: ifac_out, meldung.
*<


*> Datenermittlung ---------
*  SELECT SINGLE * FROM /adesso/mte_dtab.
*  IF sy-subrc = 0.
*    p_beginn = /adesso/mte_dtab-datab.
*  ELSE.
*
** ermitteln des Datums, ab wann die Anlage aufgebaut worden ist.
** Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
** Anlage noch nie abgerechnet wurde, wird die Anlage mit dem
** Einzugsdatum des zugeordneteten Vertrages migriert.
*    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
*      EXPORTING
*        x_anlage          = oldkey_fac
**       X_DPC_MR          =
*      IMPORTING
**       Y_BEGABRPE        =
**       Y_BEGNACH         =
*        y_default_date    = p_beginn
*      EXCEPTIONS
*        no_contract_found = 1
*        general_fault     = 2
*        parameter_fault   = 3
*        OTHERS            = 4.
*
*    IF sy-subrc <> 0.
*      IF sy-subrc EQ 1 AND
*         p_beginn IS INITIAL.
*        SELECT SINGLE * FROM eanlh WHERE anlage = oldkey_fac
*                                     AND bis    = '99991231'.
*        IF sy-subrc EQ 0.
*          MOVE eanlh-ab TO p_beginn.
*        ELSE.
*          meldung-meldung =
*            'Es ist kein Anlagen-Beginndatum zu ermitteln'.
*          APPEND meldung.
*          RAISE wrong_data.
*        ENDIF.
*
*      ELSE.
*        meldung-meldung =
*          'Es ist kein Anlagen-Beginndatum zu ermitteln'.
*        APPEND meldung.
*        RAISE wrong_data.
*      ENDIF.
*    ENDIF.
*  ENDIF.

* Strukturen füllen



  SELECT SINGLE * FROM eanl WHERE anlage = oldkey_fac.

  IF sy-subrc EQ 0.
*ifac_key
    MOVE eanl-anlage TO ifac_key-anlage.
    MOVE '99991231'    TO ifac_key-bis.
    APPEND ifac_key.
    CLEAR  ifac_key.

  ELSE.
    meldung-meldung =
     'Anlage nicht in Tabelle EANL gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Fakten
* ifac_facts

  SELECT * FROM eanlh INTO TABLE ieanlh
           WHERE anlage EQ eanl-anlage.

  SORT ieanlh BY ab ASCENDING.

  READ TABLE ieanlh INDEX 1.
  p_beginn = ieanlh-ab.


*  SELECT * FROM ettifn  INTO CORRESPONDING FIELDS OF TABLE ifac_facts
*                        WHERE anlage  EQ eanl-anlage
*                          AND bis     EQ '99991231'
*                          AND inaktiv EQ space.

  SELECT * FROM ettifn  INTO TABLE iettifn
                        WHERE anlage  EQ eanl-anlage
*                          AND bis     EQ '99991231'
                          AND inaktiv EQ space.

  p_ende = p_beginn - 1.
*  LOOP AT ifac_facts.
  LOOP AT iettifn.
    MOVE-CORRESPONDING iettifn TO ifac_facts.

    SELECT SINGLE optyp FROM te221 INTO ifac_facts-optyp
                         WHERE operand = ifac_facts-operand.

*   Ausschluß der über die TE221 rausgefilterten Operanden
    IF sy-subrc > 0.
      CLEAR ifac_facts.
      CONTINUE.
    ENDIF.

    CASE ifac_facts-optyp.

      WHEN 'QUANT'.
*    IF ifac_facts-optyp NE 'QUANT'.
        IF ifac_facts-bis LE p_ende.
          CLEAR ifac_facts.
          CONTINUE.
        ELSE.
          IF ifac_facts-ab LT p_beginn.
            MOVE p_beginn TO ifac_facts-ab.
          ENDIF.
*          MODIFY ifac_facts.
          APPEND ifac_facts.
          CLEAR ifac_facts.
        ENDIF.
      WHEN OTHERS.
        IF ifac_facts-bis LE p_ende.
          CLEAR ifac_facts.
          CONTINUE.
        ELSE.
          IF ifac_facts-ab LT p_beginn.
            MOVE p_beginn TO ifac_facts-ab.
          ENDIF.
*          MODIFY ifac_facts.
          APPEND ifac_facts.
          CLEAR ifac_facts.
        ENDIF.
*    ENDIF.
    ENDCASE.
  ENDLOOP.


  DESCRIBE TABLE ifac_facts LINES sy-tfill.
* if  sy-subrc > 0.
  IF  sy-tfill = 0.
    meldung-meldung =
     'keine relevanten Fakten in Tabelle ETTIFN gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_fac.
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


* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
  IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_FACTS'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma      = firma
      TABLES
        meldung    = meldung
        ifac_key   = ifac_key
        ifac_facts = ifac_facts
      CHANGING
        oldkey_fac = oldkey_fac.
  ENDIF.

* Im Umschl.Fuba können die Fakten auch noch gelöscht werden
  DESCRIBE TABLE ifac_facts LINES sy-tfill.
  IF  sy-tfill = 0.
    meldung-meldung =
     'keine relevanten Fakten in Tabelle ETTIFN gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

  ADD 1 TO anz_obj.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_fac_out USING oldkey_fac
                             firma
                             object.

  LOOP AT ifac_out INTO wfac_out.
    TRANSFER wfac_out TO pfad_dat_ent.
  ENDLOOP.

ENDFUNCTION.
