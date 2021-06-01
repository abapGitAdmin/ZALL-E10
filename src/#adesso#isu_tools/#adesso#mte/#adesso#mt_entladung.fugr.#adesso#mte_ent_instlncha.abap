FUNCTION /adesso/mte_ent_instlncha.
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


  DATA: BEGIN OF ieanlh OCCURS 0,
          anlage LIKE eanlh-anlage,
          bis    LIKE eanlh-bis,
          ab     LIKE eanlh-ab,
        END OF ieanlh,

        wa_ieanlh   LIKE eanlh,
        it_ieanlh_h LIKE TABLE OF wa_ieanlh.

  DATA: oldkey_datei LIKE /adesso/mt_transfer-oldkey.
  DATA: counter(1) TYPE n.

  object   = 'INSTLNCHA'.
  ent_file = pfad_dat_ent.
  oldkey_ich = x_anlage.

* Werden historische Zeitscheigben übernommen,
* müssen die Enddaten berichtigt werden.
  DATA:
        wa_bis_akt TYPE eanlh-bis.

  REFRESH ich_facts.


* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  PERFORM init_ich.
  CLEAR: ich_out, wich_out, meldung, anz_obj.
  REFRESH: ich_out, meldung.
*<



*> Datenermittlung ---------

* ermitteln des Datums, ab wann die Anlage aufgebaut ist.
* Es wird das Beginn-Datum der Abrechnungsperiode genommen. Wenn die
* Anlage noch nie abgerechnet wurde, wird die Anlage mit dem
* Einzugsdatum des zugeordneteten Vertrages migriert.
  CALL FUNCTION 'ISU_BILLING_DATES_FOR_INSTLN'
    EXPORTING
      x_anlage          = oldkey_ich
*     X_DPC_MR          =
    IMPORTING
*     Y_BEGABRPE        =
*     Y_BEGNACH         =
      y_default_date    = p_beginn
    EXCEPTIONS
      no_contract_found = 1
      general_fault     = 2
      parameter_fault   = 3
      OTHERS            = 4.
  IF sy-subrc <> 0.
    IF sy-subrc EQ 1 AND
       p_beginn IS INITIAL.
      SELECT SINGLE * FROM eanlh WHERE anlage = oldkey_ich
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

* Für INSTLN wurde die jüngste Zeitscheibe genommen und
* die Anlage in die Relevanztabelle für instlncha weggeschrieben:
*  - immer, wenn es ZS in der Abr. Periode gibt
*
* Ermitteln, ob es mehrere Zeitscheiben in der Abr. Periode gibt
  SELECT * FROM eanlh
            INTO CORRESPONDING FIELDS OF TABLE ieanlh
                     WHERE anlage = oldkey_ich
                        AND    bis GE p_beginn.
  IF sy-subrc EQ 0.
*   Es gibt Historie in der Abr. Periode
    SORT ieanlh BY bis.
    IF x_historisch = ' '.
*     Keine ZS vor Beginn der Abr. Periode genwünscht;
*     Diese Zeitscheibe wurde schon bei INSTLN migriert
      DELETE ieanlh INDEX 1.
    ENDIF.
  ELSE.
*   Dateninkonsistenz
    meldung-meldung =
     'Anlage nicht in Tabelle EANLH vorhanden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

* Historische Zeitscheibe in der ieanlh einführen;
* Nur, wenn es Historie vor Beginn der Abr. Periode gibt
  IF x_historisch = 'X'.
*   und, wenn es angefordert wurde
    SELECT * FROM eanlh
      INTO CORRESPONDING FIELDS OF TABLE it_ieanlh_h
      WHERE anlage = oldkey_ich
        AND bis < p_beginn.

    IF sy-subrc = 0.
*     Frühestes Beginndatum ermitteln (= Beginn der Anlage)
      SORT it_ieanlh_h BY ab.
      CLEAR wa_ieanlh.
      READ TABLE it_ieanlh_h
        INDEX 1
        INTO  wa_ieanlh
        TRANSPORTING anlage ab.

*     Späteste Enddatum ermitteln (= Datum vor Beg. Abr.Pe.)
      SORT it_ieanlh_h BY bis DESCENDING.
      READ TABLE it_ieanlh_h
        INDEX 1
        INTO wa_ieanlh
        TRANSPORTING bis.

      MOVE-CORRESPONDING wa_ieanlh TO ieanlh.
      APPEND ieanlh.
    ENDIF.

*   Ende der aktuellen Zeitscheibe ermitteln.
    READ TABLE ieanlh INDEX 1.
    wa_bis_akt = ieanlh-bis.

  ENDIF.

* Strukturen füllen
  CLEAR counter.
  SORT ieanlh BY ab.

  LOOP AT ieanlh.

    CLEAR: ich_out, wich_out.
    REFRESH: ich_out.
    counter = counter + 1.

    SELECT SINGLE * FROM v_eanl WHERE anlage = ieanlh-anlage
                                  AND bis    = ieanlh-bis.
    IF sy-subrc EQ 0.
*     ich_key
      MOVE v_eanl-anlage TO ich_key-anlage.
*     Für SWL wird das Bis-Datum in Emigall immer auf 31.12.9999 gesetzt
*     Dieses Coding ist demnach ohne Wirkung ------------------------>>>
      IF ieanlh-bis >= p_beginn.
        MOVE '99991231'    TO ich_key-bis.
      ELSE.
        MOVE ieanlh-bis TO ich_key-bis.
      ENDIF.

      IF x_historisch = 'X' AND ieanlh-bis < p_beginn.
        ich_key-bis = wa_bis_akt.
      ENDIF.
*     Dieses Coding ist demnach ohne Wirkung ------------------------<<<<

      APPEND ich_key.
      CLEAR  ich_key.

*     ich_data
      MOVE-CORRESPONDING v_eanl TO ich_data.

      IF ieanlh-bis < p_beginn.
*       Dummy-Werte für die historische Zeitscheibe
        CASE ich_data-sparte.
          WHEN '02'. "Gas
            IF ich_data-aklasse = 'TK'.
              ich_data-tariftyp = 'GNDUMMY'.
            ELSEIF ich_data-aklasse = 'SK'.
              ich_data-tariftyp = 'GSDUMMY'.
            ENDIF.
          WHEN '03'. " Wasser
            ich_data-tariftyp = 'WNDUMMY'.
          WHEN '08'. "Abwasser
            ich_data-tariftyp = 'ANLEER'.
          WHEN '04'. "Wärme
            ich_data-tariftyp = 'NNDUMMY'.
        ENDCASE.
*       künstlicher Beginn der aufgebauten historischen ZS
        ich_data-ab = ieanlh-ab.
      ENDIF.

      APPEND ich_data.
      CLEAR  ich_data.

*     ich_rcat
      MOVE-CORRESPONDING v_eanl TO ich_rcat.
      APPEND ich_rcat.
      CLEAR  ich_rcat.

    ELSE.
      meldung-meldung =
       'Anlagen-Zeitscheibe nicht in Tabelle V_EANL gefunden'.
      APPEND meldung.
      RAISE wrong_data.
    ENDIF.



* Fakten müssten eigentlich alle bei INSTLN migriert worden sein.


*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV

    CONCATENATE oldkey_ich '_' counter INTO o_key.
*    o_key = oldkey_ich.
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
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_INSTLNCH'
      CALL FUNCTION ums_fuba
        EXPORTING
          firma      = firma
        TABLES
          meldung    = meldung
          ich_key    = ich_key
          ich_data   = ich_data
          ich_rcat   = ich_rcat
          ich_facts  = ich_facts
        CHANGING
          oldkey_ich = oldkey_ich
        EXCEPTIONS
          no_adress  = 1
          no_key     = 2
          OTHERS     = 3.
      CASE sy-subrc.
        WHEN 1.
          RAISE no_adress.
        WHEN 2.
          RAISE no_key.
      ENDCASE.

    ENDIF.


* Sätze für Datei in interne Tabelle schreiben
    CONCATENATE oldkey_ich '_' counter INTO oldkey_datei.
*    oldkey_datei = oldkey_ich.
    PERFORM fill_ich_out USING oldkey_datei "oldkey_ich
                               firma
                               object
                               anz_key
                               anz_data
                               anz_rcat
                               anz_pod.


    LOOP AT ich_out INTO wich_out.
      TRANSFER wich_out TO ent_file.
    ENDLOOP.


  ENDLOOP.





ENDFUNCTION.
