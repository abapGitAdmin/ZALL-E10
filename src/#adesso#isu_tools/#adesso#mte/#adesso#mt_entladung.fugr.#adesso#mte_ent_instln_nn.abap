FUNCTION /adesso/mte_ent_instln_nn.
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

  object   = 'INSTLN_NN'.
  ent_file = pfad_dat_ent.
  oldkey_inn = x_anlage.


* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.

*>   Initialisierung
  PERFORM init_inn.
  CLEAR: inn_out, winn_out, meldung, anz_obj.
  REFRESH: inn_out, meldung.
*<

*> Datenermittlung ---------


* Alle Zeitscheiben aus Anlage in ieanlh einlesen
  SELECT anlage bis FROM eanlh
            INTO TABLE ieanlh
                     WHERE anlage = oldkey_inn.
*                        AND    bis GE p_beginn.

  IF sy-subrc EQ 0.

    SORT ieanlh BY bis ASCENDING.
    READ TABLE ieanlh INDEX 1.

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
*   inn_key
    MOVE v_eanl-anlage TO inn_key-anlage.
    MOVE '99991231'    TO inn_key-bis.

    APPEND inn_key.
    CLEAR  inn_key.

*   inn_data
    MOVE-CORRESPONDING v_eanl TO inn_data.

    APPEND inn_data.
    CLEAR  inn_data.

*   inn_rcat
    MOVE-CORRESPONDING v_eanl TO inn_rcat.
    APPEND inn_rcat.
    CLEAR  inn_rcat.

  ELSE.
*   Dateninkonsistenz
    meldung-meldung =
     'Anlage nicht in Tabelle V_EANL gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Zählpunktstrukturen füllen
* inn_pod
  SELECT * FROM euiinstln WHERE anlage = ieanlh-anlage
                            AND dateto = '99991231'.
    ret_code = '0'.

    SELECT SINGLE * FROM euihead
                      WHERE int_ui = euiinstln-int_ui.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING euihead TO inn_pod.
    ELSE.
      MOVE sy-subrc TO ret_code.
      EXIT.
    ENDIF.


**  Es können Zählpunkte mit mehreren EUIGRID existieren

*    SELECT SINGLE * FROM euigrid
*                      WHERE int_ui = euiinstln-int_ui
*                        AND dateto GE sy-datum " p_datab "p_beginn
*                        AND datefrom LE sy-datum. "p_datab. "p_beginn.
*    IF sy-subrc EQ 0.
*      MOVE-CORRESPONDING euigrid TO inn_pod.
***   Bei GRID_ID die führenden Nullen raus wg. Umschlüsselung CSV-Datei
*      SHIFT inn_pod-grid_id LEFT DELETING LEADING '0'.
*    ELSE.
*      MOVE sy-subrc TO ret_code.
*      EXIT.
*    ENDIF.

    CLEAR: it_euigrid, wa_euigrid.
    SELECT * FROM euigrid INTO TABLE it_euigrid
       WHERE int_ui = euiinstln-int_ui.
    IF sy-subrc NE 0.
      MOVE sy-subrc TO ret_code.
      EXIT.
    ENDIF.
*   Netze aufsteigend sortieren, da für die Migration die älteste ZS
*   Benötigt wird.
    SORT it_euigrid BY dateto ASCENDING.
    DESCRIBE TABLE it_euigrid LINES anz_netz.
*   Es gibt mehr als 1 Netzzeitscheibe.
    IF anz_netz > 1.
      MOVE ieanlh-anlage TO /adesso/mte_rel-obj_key.
      MOVE 'INSTLNCHNN' TO /adesso/mte_rel-object.
      MOVE firma TO /adesso/mte_rel-firma.
      MODIFY /adesso/mte_rel.
*      COMMIT WORK.
    ENDIF.
*   Jetzt die älteste Zeitscheibe lesen
    READ TABLE it_euigrid INTO wa_euigrid INDEX 1.
    MOVE-CORRESPONDING wa_euigrid TO inn_pod.
*   Bei GRID_ID die führenden Nullen raus wg. Umschlüsselung CSV-Datei
    SHIFT inn_pod-grid_id LEFT DELETING LEADING '0'.

    SELECT SINGLE * FROM euitrans
                      WHERE int_ui = euiinstln-int_ui
                        AND dateto GE sy-datum "p_datab "p_beginn
                        AND datefrom LE sy-datum. "p_datab. "p_beginn.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING euitrans TO inn_pod.
    ELSE.
      MOVE sy-subrc TO ret_code.
      EXIT.
    ENDIF.

  ENDSELECT.

  IF sy-subrc EQ 0 AND ret_code EQ 0.

    inn_pod-int_ui = euiinstln-int_ui.
*   Füllen INN_POD aus EUIGRID
    inn_pod-datefrom = wa_euigrid-datefrom.
    inn_pod-timefrom = wa_euigrid-timefrom.

    APPEND inn_pod.
    CLEAR  inn_pod.
  ENDIF.

** Fakten
** werden in einem eigenen Migrationsobjekt migriert

*< Datenermittlung ---------

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_inn.
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
        inn_key    = inn_key
        inn_data   = inn_data
        inn_rcat   = inn_rcat
        inn_pod    = inn_pod
      CHANGING
        oldkey_inn = oldkey_inn
      EXCEPTIONS
        no_adress  = 1
        no_key     = 2.
    IF sy-subrc <> 0.
      meldung-meldung = meldung.
      APPEND meldung.
    ENDIF.
    CASE sy-subrc.
      WHEN 1.
        RAISE no_adress.
      WHEN 2.
        RAISE no_key.
    ENDCASE.
  ENDIF.

* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_inn_out USING oldkey_inn
                             firma
                             object
                             anz_key
                             anz_data
                             anz_rcat
                             anz_pod.

  LOOP AT inn_out INTO winn_out.
    TRANSFER winn_out TO ent_file.
  ENDLOOP.


ENDFUNCTION.
