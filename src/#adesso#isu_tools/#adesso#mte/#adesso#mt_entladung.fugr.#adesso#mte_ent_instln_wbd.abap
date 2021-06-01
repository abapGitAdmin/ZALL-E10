FUNCTION /adesso/mte_ent_instln_wbd.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_ANLAGE) LIKE  EANL-ANLAGE
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"     REFERENCE(X_HISTORISCH) TYPE  /ADESSO/MTE_INSTLNCHA_HISTORIC
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_KEY) TYPE  I
*"     REFERENCE(ANZ_DATA) TYPE  I
*"     REFERENCE(ANZ_RCAT) TYPE  I
*"     REFERENCE(ANZ_POD) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      GEN_ERROR
*"      ERROR
*"      NO_ADRESS
*"      NO_KEY
*"----------------------------------------------------------------------
*{   INSERT         TV1K924020                                        1


  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: p_beginn        LIKE  sy-datum.
  DATA: o_key           TYPE  emg_oldkey.
  DATA: p_datab         TYPE sy-datum.

  DATA: beg_eanl LIKE eanlh-ab.

  DATA: BEGIN OF ieanlh OCCURS 0,
          anlage LIKE eanlh-anlage,
          bis    LIKE eanlh-bis,
        END OF ieanlh.

  DATA: anz_zs TYPE i.

  DATA: ret_code LIKE sy-subrc.


  DATA: it_euigrid TYPE TABLE OF euigrid,
        wa_euigrid TYPE euigrid,
        anz_netz   TYPE i.

  DATA: wa_eanl_help      TYPE eanl,
        wa_euiinstln_help TYPE euiinstln,
        wa_euitrans_help  TYPE euitrans.

  DATA: lt_ever        TYPE STANDARD TABLE OF ever,
        lw_ever        TYPE ever,
        lt_ever_wasser TYPE STANDARD TABLE OF ever,
        lw_ever_wasser TYPE ever.

  DATA: lt_eastl        TYPE STANDARD TABLE OF eastl,
        wa_eastl        TYPE eastl,
        lt_eastl_wasser TYPE STANDARD TABLE OF eastl,
        lw_eastl_wasser TYPE  eastl.

  DATA: lw_eanl_help TYPE eanl.                        "Nuss 25.04.2016

  object   = 'INSTLN'.
  ent_file = pfad_dat_ent.
  oldkey_ins = x_anlage.

  REFRESH ins_facts.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  PERFORM init_ins.
  CLEAR: ins_out, wins_out, meldung, anz_obj.
  REFRESH: ins_out, meldung.
*<

*> Datenermittlung ---------
*  SELECT SINGLE * FROM /adesso/mte_dtab.
*  IF sy-subrc = 0.
*    p_beginn = /adesso/mte_dtab-datab.
*  ELSE.
*
** ermitteln des Datums, ab wann die Anlage aufgebaut werden soll.
** Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
** Anlage noch nie abgerechnet wurde, wird die Anlage mit dem
** Einzugsdatum des zugeordneteten Vertrages migriert.
*    CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
*      EXPORTING
*        x_anlage          = oldkey_ins
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
*        SELECT SINGLE * FROM eanlh WHERE anlage = oldkey_ins
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


*>------------------------------------------------------------
* absolutes Beginndatum der Anlage bestimmen
*  CLEAR beg_eanl.
*  SELECT * FROM eanlh
*              WHERE anlage = oldkey_ins
*              ORDER BY ab.
*    beg_eanl = eanlh-ab.
*    EXIT.
*  ENDSELECT.

* Alle Zeitscheiben aus der Abr. Periode in ieanlh einlesen
  SELECT anlage bis FROM eanlh
            INTO TABLE ieanlh
                     WHERE anlage = oldkey_ins.
*                            AND    bis GE p_beginn.

  IF sy-subrc EQ 0.
*   Die Anlagen müssen mit der neuesten ZS angelegt werden und
*   die Anlagenänderungen bauen dann in der ältesten Vergangenheit auf
    SORT ieanlh BY bis ASCENDING.
    READ TABLE ieanlh INDEX 1.

*   Ermitteln, ob es mehrere Zeitscheiben in der Abr. Periode gibt
*   dann Eintrag in der Rel-Tabelle für 'Instlncha'
    DESCRIBE TABLE ieanlh LINES anz_zs.
    IF anz_zs > 1.
      MOVE ieanlh-anlage TO /adesso/mte_rel-obj_key.
      MOVE 'INSTLNCHA' TO /adesso/mte_rel-object.
      MOVE firma TO /adesso/mte_rel-firma.
      MODIFY /adesso/mte_rel.
      COMMIT WORK.
    ENDIF.

*----------------------------------------------------------------->>>>
** Erweitern der Relevanztabelle für INSTLNCHA wenn mehrere Zeitscheiben
** in der Vergangenheit
*    IF x_historisch = 'X'.
**     Ermitteln der historischen Zeitscheibe angefordert
*      DATA: wa_eanlh TYPE eanlh.
*
*      SELECT SINGLE * FROM eanlh
*      INTO wa_eanlh
*        WHERE anlage = oldkey_ins
*        AND bis < p_beginn.
*
*      IF sy-subrc = 0.
**       Es gibt auch ZS vor dem Beg. Abr.Periode
*        MOVE oldkey_ins TO /adesso/mte_rel-obj_key.
*        MOVE 'INSTLNCHA' TO /adesso/mte_rel-object.
*        MOVE firma TO /adesso/mte_rel-firma.
**       event. Tabellenerweiterung
*        MODIFY /adesso/mte_rel.
*        COMMIT WORK.
*
*      ENDIF.
*    ENDIF.
  ELSE.
*   Dateninkonsistenz
    meldung-meldung =
     'Anlage nicht in Tabelle EANLH vorhanden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Anlage-Strukturen füllen (in ieanlh ist die älteste Zeitscheibe)
  SELECT SINGLE * FROM v_eanl WHERE anlage = ieanlh-anlage
                                AND bis    = ieanlh-bis.
  IF sy-subrc EQ 0.
*   ins_key
    MOVE v_eanl-anlage TO ins_key-anlage.
    MOVE '99991231'    TO ins_key-bis.

    APPEND ins_key.
    CLEAR  ins_key.

*   ins_data
    MOVE-CORRESPONDING v_eanl TO ins_data.

    APPEND ins_data.
    CLEAR  ins_data.

*   ins_rcat
    MOVE-CORRESPONDING v_eanl TO ins_rcat.
    APPEND ins_rcat.
    CLEAR  ins_rcat.

  ELSE.
*   Dateninkonsistenz
    meldung-meldung =
     'Anlage nicht in Tabelle V_EANL gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Zählpunktstrukturen füllen
* ins_pod
* EUIINSTLN ist vorhanden bei jeder Anlage
  SELECT * FROM euiinstln WHERE anlage = ieanlh-anlage
                            AND dateto = '99991231'.
    ret_code = '0'.

* EUIHEAD ist vorhanden bei jeder Anlage
    SELECT SINGLE * FROM euihead
                      WHERE int_ui = euiinstln-int_ui.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING euihead TO ins_pod.
    ELSE.
      MOVE sy-subrc TO ret_code.
      EXIT.
    ENDIF.

**  EUIGRID ist für Abwasseranlagen nicht vorhanden
**  Es soll ein Zählpunkt aufgebaut werden
**  GRID_ID und GRID_LEVEL sind Festwerte

    MOVE '0000154_AW' TO ins_pod-grid_id.
    MOVE 'AW' TO ins_pod-grid_level.

**  EUITRANS ist für Abwasseranlagen nicht vorhanden
**  Zählpunkt wird aufgebaut aus der Frischwasseranlage

**  --> Nuss 04.11.2015
** Da an einer Verbrauchsstelle mehrer Abwasseranlagen sein können, muss
** die Frischwasseranlage über die Geräte ermittelt werden
    CLEAR: wa_eanl_help, lt_eastl, lt_eastl_wasser.
    SELECT * FROM eastl INTO  TABLE lt_eastl
      WHERE anlage = v_eanl-anlage.

    SORT lt_eastl BY bis DESCENDING.
*   Den jüngsten Eintrag lesen
    READ TABLE lt_eastl INTO wa_eastl INDEX 1.
*   Jetzt den EASTL zur Wasseranlage lesen. Dazu mit Logiknummer und
*   Anlagennummer ungleich Abwasseranlage.

    SELECT * FROM eastl INTO table lt_eastl_wasser
      WHERE anlage NE wa_eastl-anlage
        AND logiknr EQ wa_eastl-logiknr.

    SORT lt_eastl_wasser BY bis DESCENDING.
*   Im jügsetn Eintrag steht die Wasseranlage
    READ TABLE lt_eastl_wasser INTO lw_eastl_wasser INDEX 1.
    SELECT SINGLE * FROM eanl INTO wa_eanl_help
      WHERE anlage = lw_eastl_wasser-anlage
        AND sparte = '03'.
**    Wenn keine Wasseranlage gefunden wurde, dann über Verbrauchsstelle suchen
    IF wa_eanl_help IS INITIAL.
      SELECT  * FROM eanl INTO wa_eanl_help
        WHERE sparte = '03'
         AND vstelle = v_eanl-vstelle.
        EXIT.
      ENDSELECT.
    ENDIF.

    IF wa_eanl_help IS NOT INITIAL.
*    SELECT  * FROM eanl INTO wa_eanl_help
*      WHERE sparte = '03'
*       AND vstelle = v_eanl-vstelle.
*      EXIT.
*    ENDSELECT.
*    IF sy-subrc = 0.
*  <-- Nuss 04.11.2015

      SELECT * FROM euiinstln INTO wa_euiinstln_help
        WHERE anlage = wa_eanl_help-anlage
          AND dateto = '99991231'.
        EXIT.
      ENDSELECT.
      SELECT SINGLE * FROM euitrans INTO wa_euitrans_help
        WHERE int_ui =  wa_euiinstln_help-int_ui
                          AND dateto EQ '99991231'.
      IF sy-subrc = 0.
        MOVE  wa_euitrans_help-ext_ui TO ins_pod-ext_ui.
        MOVE '02' TO ins_pod-uistrutyp.
*        MOVE '0001' TO ins_pod-uitype.    "Nuss 29.10.2015
        MOVE 'NORM' TO ins_pod-uitype.    "Nuss 29.10.2015
      ELSE.
        MOVE sy-subrc TO ret_code.
        meldung-meldung =
          'kein Zählpunkt zur Anlage ermittelber'.
        APPEND meldung.
        EXIT.
      ENDIF.
    ELSE.
      MOVE sy-subrc TO ret_code.
      meldung-meldung =
           'keine Frischwasseranlage zur Abwasseranlage gefunden'.
      APPEND meldung.
    ENDIF.


**  Erweiterung des Selects auf Datum
*    SELECT SINGLE * FROM euigrid
*                      WHERE int_ui = euiinstln-int_ui
*                        AND dateto GE p_beginn
*                        AND datefrom LE p_beginn.
*    IF sy-subrc EQ 0.
*      MOVE-CORRESPONDING euigrid TO ins_pod.
*    ELSE.
*      MOVE sy-subrc TO ret_code.
*      EXIT.
*    ENDIF.

**  Erweiterung des Selects auf Datum
*    SELECT SINGLE * FROM euitrans
*                      WHERE int_ui = euiinstln-int_ui
*                        AND dateto GE p_beginn
*                        AND datefrom LE p_beginn.
*    IF sy-subrc EQ 0.
*      MOVE-CORRESPONDING euitrans TO ins_pod.
*    ELSE.
*      MOVE sy-subrc TO ret_code.
*      EXIT.
*    ENDIF.

  ENDSELECT.

  IF sy-subrc EQ 0 AND ret_code EQ 0.

*   Felder EUIROLE_TECH und EUIROLE_DEREG
*   werden aus EUIHEAD übernommen.
*    MOVE-CORRESPONDING euiinstln TO ins_pod.

    ins_pod-int_ui = euiinstln-int_ui.
*   --> Nuss 29.10.2015
*    ins_pod-datefrom = euiinstln-datefrom.
    ins_pod-datefrom = '20000101'.             "Ab diesem Datum ist das Netz gültig
*   <-- Nuss 29.10.2015
    ins_pod-timefrom = euiinstln-timefrom.

    APPEND ins_pod.
    CLEAR  ins_pod.
  ENDIF.

** Fakten
** ins_facts
*  SELECT * FROM ettifn INTO CORRESPONDING FIELDS OF TABLE ins_facts
*                        WHERE anlage EQ ieanlh-anlage
*                          AND bis    GT p_beginn
*                          AND belnr  EQ space
*                          AND mbelnr EQ space.
*
**   MOVE-CORRESPONDING ettifn TO ins_facts.
*  LOOP AT ins_facts.
*    SELECT SINGLE optyp FROM te221 INTO ins_facts-optyp
*                         WHERE operand = ins_facts-operand.
*
*    IF ins_facts-ab LT p_beginn.
*      MOVE p_beginn TO ins_facts-ab.
*    ENDIF.
*    MODIFY ins_facts.
**    APPEND ins_facts.
*  ENDLOOP.
**  ENDSELECT.

*< Datenermittlung ---------

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_ins.
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
*    CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_INSTLN'
    CALL FUNCTION ums_fuba
      EXPORTING
        firma      = firma
      TABLES
        meldung    = meldung
        ins_key    = ins_key
        ins_data   = ins_data
        ins_rcat   = ins_rcat
        ins_pod    = ins_pod
        ins_facts  = ins_facts
      CHANGING
        oldkey_ins = oldkey_ins
      EXCEPTIONS
        no_adress  = 1
        no_key     = 2.
*    IF sy-subrc <> 0.
*      meldung-meldung = meldung.
*      APPEND meldung.
*    ENDIF.
    CASE sy-subrc.
      WHEN 1.
        RAISE no_adress.
      WHEN 2.
        RAISE no_key.
    ENDCASE.

  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_ins_out USING oldkey_ins
                             firma
                             object
                             anz_key
                             anz_data
                             anz_rcat
                             anz_pod.

  LOOP AT ins_out INTO wins_out.
    TRANSFER wins_out TO ent_file.
  ENDLOOP.

*}   INSERT
ENDFUNCTION.
