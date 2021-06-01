FUNCTION /adesso/mte_ent_meterread.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_HTGER) LIKE  /ADESSO/MTE_HTGE STRUCTURE
*"        /ADESSO/MTE_HTGE
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_IEABLU) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      ERROR
*"      NO_DATA
*"      NO_REASON
*"----------------------------------------------------------------------

  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: o_key           TYPE  emg_oldkey.
  DATA: beg_dat LIKE sy-datum.
  DATA: einz_anl_dat LIKE sy-datum.
  DATA: ieabl LIKE eabl OCCURS 0 WITH HEADER LINE.
  DATA: wa_eablg LIKE eablg.
  DATA: w_einzdat       LIKE ever-einzdat.
* Flag: Ablesegrund gefunden
  DATA: x_reason TYPE i.

  object   = 'METERREAD'.
  ent_file = pfad_dat_ent.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  CLEAR: imrd_ieablu, oldkey_mrd, wa_eablg, imrd_out, wmrd_out,
         meldung, anz_obj, beg_dat, ieabl.
  REFRESH: imrd_ieablu, imrd_out, meldung, ieabl.
*<


* Bestimmen des Beginn-Datums

* Aktuellen vertrag überprüfen
  SELECT SINGLE einzdat INTO w_einzdat
         FROM ever
         WHERE anlage = x_htger-anlage
           AND einzdat < x_htger-ab_anlage
           AND auszdat > x_htger-ab_anlage.

  IF sy-subrc = 0 AND
     w_einzdat < x_htger-ab_anlage.
*   Beginn-Datum auf den Einzug setzen
    CASE x_htger-action.
      WHEN '01'. "01-Einbau gesamt
        IF x_htger-ab GE w_einzdat.
          MOVE x_htger-ab TO beg_dat.
        ELSE.
          MOVE w_einzdat TO beg_dat.
        ENDIF.
      WHEN '02'. "02-Ausbau gesamt
        MOVE x_htger-ab TO beg_dat.
*    WHEN '03'.                                              "03-Wechsel
*      MOVE x_htger-ab TO beg_dat.
      WHEN '04'. "04-Einbau abrechnungstechnisch
        IF x_htger-ab GE w_einzdat.
          MOVE x_htger-ab TO beg_dat.
        ELSE.
          MOVE w_einzdat TO beg_dat.
        ENDIF.
      WHEN '05'. "05-Ausbau abrechnungstechnisch
        MOVE x_htger-ab TO beg_dat.
      WHEN '06'. "06-Einbau technisch
        IF x_htger-ab GE w_einzdat.
          MOVE x_htger-ab TO beg_dat.
        ELSE.
          MOVE w_einzdat TO beg_dat.
        ENDIF.
      WHEN '07'. "07-Ausbau technisch
        MOVE x_htger-ab TO beg_dat.
    ENDCASE.
  ELSE.

*   Mit Beginn-Datum  aus der Anlage arbeiten
    CASE x_htger-action.
      WHEN '01'. "01-Einbau gesamt
        IF x_htger-ab GE x_htger-ab_anlage.
          MOVE x_htger-ab TO beg_dat.
        ELSE.
          MOVE x_htger-ab_anlage TO beg_dat.
        ENDIF.
      WHEN '02'. "02-Ausbau gesamt
        MOVE x_htger-ab TO beg_dat.
*    WHEN '03'.                                              "03-Wechsel
*      MOVE x_htger-ab TO beg_dat.
      WHEN '04'. "04-Einbau abrechnungstechnisch
        IF x_htger-ab GE x_htger-ab_anlage.
          MOVE x_htger-ab TO beg_dat.
        ELSE.
          MOVE x_htger-ab_anlage TO beg_dat.
        ENDIF.
      WHEN '05'. "05-Ausbau abrechnungstechnisch
        MOVE x_htger-ab TO beg_dat.
      WHEN '06'. "06-Einbau technisch
        IF x_htger-ab GE x_htger-ab_anlage.
          MOVE x_htger-ab TO beg_dat.
        ELSE.
          MOVE x_htger-ab_anlage TO beg_dat.
        ENDIF.
      WHEN '07'. "07-Ausbau technisch
        MOVE x_htger-ab TO beg_dat.
    ENDCASE.
  ENDIF.

*> Datenermittlung ---------
* Es werden nur die Vorgänge: 01, 03, 06 geprüft und ausgewertet
* bzw. in diesen FuBa übermittelt

  SELECT * FROM eabl INTO TABLE ieabl
                  WHERE equnr = x_htger-equnr
*                 AND adat > beg_dat
                  AND adat GE beg_dat
                  AND adat < x_htger-bis.


  IF sy-subrc NE 0.
    RAISE no_data.
  ENDIF.

  CLEAR x_reason.

  LOOP AT ieabl.

    CLEAR: imrd_ieablu, oldkey_mrd, wa_eablg, imrd_out, wmrd_out.
    REFRESH: imrd_ieablu, imrd_out.

    SELECT SINGLE * FROM eablg INTO wa_eablg
        WHERE ablbelnr EQ ieabl-ablbelnr
         AND (  ablesgr EQ '01' OR   "Turnusablesung
                "ablesgr EQ '02' OR   "Zwischenabl. m. Abrechnung
                ablesgr EQ '04' OR   "Beglaubigungsablesung
                ablesgr EQ '06' OR   "Einzugsablesung
                "ablesgr EQ '07' OR   "Gebietsabg. o. Abrechnung
                "ablesgr EQ '09' OR   "Zwischenabl. o. Abrechnung
                "ablesgr EQ '10' OR   "Kontrollablesung
                "ablesgr EQ '11' OR   "Abl. nach Prog./Anpassung
                ablesgr EQ '13' OR   "Sperrablesung
                "ablesgr EQ '14' OR   "Masch. errechnet n. Abr.
                "ablesgr EQ '16' OR   "Abl. vor Prog./Anpassung
                "ablesgr EQ '17' OR   "Zählwerksbeziehungsabl.
                ablesgr EQ '18' OR   "Wiederin betriebnahmeabl.
                ablesgr EQ '19' OR   "Anlieferungsablesung
                ablesgr EQ '21' ).   "Abr.techn. Einbau

    "ablesgr EQ '20' OR   "Geräteprüfungsabl.
    "ablesgr EQ '23' ).   "Einmalablesung Umbau

    IF sy-subrc EQ 0.
      x_reason = 1.
      MOVE-CORRESPONDING ieabl TO imrd_ieablu.
      MOVE-CORRESPONDING wa_eablg TO imrd_ieablu.

      MOVE ieabl-v_zwstand TO imrd_ieablu-zwstand.
      CONDENSE imrd_ieablu-zwstand.


      APPEND imrd_ieablu.
    ELSE.
      CONTINUE.
    ENDIF.

* Altsystemschlüssel
    oldkey_mrd = ieabl-ablbelnr.

*< Datenermittlung ---------

*>> Wegschreiben des Objektschlüssels in Entlade-KSV
    o_key = oldkey_mrd.

    CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
      EXPORTING
        i_firma  = firma
        i_object = object
        i_oldkey = o_key
      EXCEPTIONS
        error    = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
**      Doppelte Sätze entstehen durch Zuordnung mehrere Anlagen zu einem
**      Equipment.
      meldung-meldung =
          'Fehler bei wegschreiben in Entlade-KSV'.
      APPEND meldung.
      RAISE error.
    ENDIF.
*<< Wegschreiben des Objektschlüssels in Entlade-KSV
    ADD 1 TO anz_obj.

* Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
    IF NOT ums_fuba IS INITIAL.
*         CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_METERREA'
      CALL FUNCTION ums_fuba
        EXPORTING
          firma       = firma
        TABLES
          meldung     = meldung
          imrd_ieablu = imrd_ieablu
        CHANGING
          oldkey_mrd  = oldkey_mrd.
    ENDIF.

* Sätze für Datei in interne Tabelle schreiben
    LOOP AT imrd_ieablu.
      wmrd_out-firma  = firma.
      wmrd_out-object = object.
      wmrd_out-dttyp  = 'IEABLU'.
      wmrd_out-oldkey = oldkey_mrd.
      wmrd_out-data   = imrd_ieablu.
      ADD 1 TO anz_ieablu.
      APPEND wmrd_out TO imrd_out.
    ENDLOOP.

    LOOP AT imrd_out INTO wmrd_out.
      TRANSFER wmrd_out TO ent_file.
    ENDLOOP.

  ENDLOOP.

  IF x_reason = 0.
    RAISE no_reason.
  ENDIF.





ENDFUNCTION.
