FUNCTION /ADESSO/MTE_ENT_FACTS_SPAR.
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
  DATA: ums_fuba        TYPE  funcname.
  DATA: p_beginn        LIKE  sy-datum.
  DATA: p_ende          LIKE  sy-datum.
  DATA: o_key           TYPE  emg_oldkey.

  DATA:  h_betrag TYPE prsbtr.
  DATA:  h_int    TYPE int4.
  DATA:  h_ab       type date.
  DATA:  h_bis      type date.
  DATA:  h_ab_temp  type date.
  DATA:  h_bis_temp type date.
  DATA:  h_index    type i.


  DATA: BEGIN OF iettifn OCCURS 0.
          INCLUDE STRUCTURE ettifn.
  DATA: END OF iettifn.

  object   = 'FACTS'.
  oldkey_fac = x_anlage.

  REFRESH ifac_facts.
  clear h_index.

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

  p_beginn = '20000101'.  "Beginn der Anlagen

* Strukturen füllen
  SELECT SINGLE * FROM eanl WHERE anlage = oldkey_fac.

  IF sy-subrc EQ 0.
*   ifac_key
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
  CLEAR iettifn.
  REFRESH iettifn.
  SELECT * FROM ettifn  INTO CORRESPONDING FIELDS OF TABLE iettifn
                          WHERE anlage  EQ eanl-anlage
                            AND inaktiv EQ space.

* Doppelte Einträge (mit Lfd-Nr) führen zu Fehlern in der MIG
  SORT iettifn.
  DELETE ADJACENT DUPLICATES FROM iettifn
         COMPARING anlage operand saison ab.

  LOOP AT iettifn.
    MOVE-CORRESPONDING iettifn TO ifac_facts.
    APPEND ifac_facts.
  ENDLOOP.

* Nur bestimmte Datenkonstellation wurde in der falsch migriert;
* Nur diese Anlagen müssen hier aufgebaut werden
  delete iettifn where operand ne 'SAM_SPAR'.
  describe table iettifn lines sy-tfill.
  if sy-tfill ne 1.
    RAISE wrong_data.
    exit.
  endif.

  p_ende = p_beginn - 1.
  LOOP AT ifac_facts.
    SELECT SINGLE optyp FROM te221 INTO ifac_facts-optyp
                         WHERE operand = ifac_facts-operand.

    IF sy-subrc > 0.
      DELETE ifac_facts.
      CONTINUE.
    ENDIF.

    CASE ifac_facts-operand.

      WHEN 'SAF_BGPN'.
        ifac_facts-operand = 'SLPGRUNDI'.
        ifac_facts-optyp = 'TPRICE'.
        ifac_facts-string1 = 'SJ4IVP0001'.
        MULTIPLY ifac_facts-wert1 BY 12.
        CLEAR h_betrag.
        MOVE ifac_facts-wert1 TO h_betrag.
*       MOVE ifac_facts-wert1 TO ifac_facts-betrag.
        CLEAR ifac_facts-wert1.
        MOVE h_betrag TO ifac_facts-betrag.
*       MULTIPLY ifac_facts-betrag BY 12.
        ifac_facts-waers   = 'EUR'.

      WHEN 'SAPM_V_AP'.
        ifac_facts-operand = 'SQP1E0AHI'.
        ifac_facts-string1 = 'SJ1IVP0001'.

      WHEN 'SAM_KWKINF'.
        ifac_facts-operand = 'SQ-KWK-INF'.

      WHEN   'SAM_SPAR'.
        ifac_facts-operand = 'SQ-VORVERB'.

*       Zeitscheibe um ein Jahr nach hinten versetzen
        ifac_facts-bis = ifac_facts-ab - 1.
        ifac_facts-ab(4) = ifac_facts-ab(4) - 1.

      WHEN 'SAM_KWKGRV'.
        ifac_facts-operand = 'SQ-KWK-KUM'.

      WHEN 'SAM_NEVINF'.
        ifac_facts-operand = 'SQ-SOU-INF'.

      WHEN 'SAM_NEVRV'.
        ifac_facts-operand = 'SQ-SOU-KUM'.

      WHEN 'SAM_OSINF'.
        ifac_facts-operand = 'SQ-OFF-INF'.

      WHEN 'SAM_OSRV'.
        ifac_facts-operand = 'SQ-OFF-KUM'.

      WHEN OTHERS.
*    Do nothing

    ENDCASE.

    MODIFY ifac_facts.
  ENDLOOP.

  clear ifac_facts.
  ifac_facts-operand = 'SF-ANZ-HH'.
  ifac_facts-optyp = 'FACTOR'.
  ifac_facts-anlage = x_anlage.
  ifac_facts-ab = '20000101'.
  ifac_facts-bis = '99991231'.
  ifac_facts-wert1 = '1'.
  append ifac_facts.
  clear ifac_facts.

  ifac_facts-operand = 'SRT-NNEBER'.
  ifac_facts-optyp = 'RATETYPE'.
  ifac_facts-anlage = x_anlage.
  ifac_facts-ab = '20000101'.
  ifac_facts-bis = '99991231'.
  ifac_facts-tarifart = 'NESNSOLH'.
  ifac_facts-kondigr = 'S'.
  append ifac_facts.
  clear ifac_facts.

  DESCRIBE TABLE ifac_facts LINES sy-tfill.
  IF  sy-tfill = 0.
    meldung-meldung =
     'keine relevanten Fakten in Tabelle ETTIFN gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

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
*   CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_FACTS'
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

  ADD 1 TO anz_obj.
  oldkey_fac+1(2) = '99'.  "Merkmal zur Unterscheidung der MIG_Key's

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_fac_out USING oldkey_fac
                             firma
                             object.

  LOOP AT ifac_out INTO wfac_out.
    TRANSFER wfac_out TO pfad_dat_ent.
  ENDLOOP.





ENDFUNCTION.
