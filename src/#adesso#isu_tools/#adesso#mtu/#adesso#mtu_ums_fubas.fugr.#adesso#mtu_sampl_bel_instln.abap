FUNCTION /ADESSO/MTU_SAMPL_BEL_INSTLN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      INS_KEY STRUCTURE  EANLHKEY OPTIONAL
*"      INS_DATA STRUCTURE  EMG_EANL OPTIONAL
*"      INS_RCAT STRUCTURE  ISU_AITTYP OPTIONAL
*"      INS_POD STRUCTURE  EUI_EXT_OBJ_AUTO OPTIONAL
*"      INS_FACTS STRUCTURE  /ADESSO/MT_FACTS OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_INS) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* Vorläufige Lösung
refresh ins_facts.


* Tariftyp
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_tatyp IS INITIAL.
    SELECT * INTO TABLE iums_tatyp
             FROM /adesso/mtu_ttyp.
    filled_tatyp = 'X'.
    sort iums_tatyp.
  ENDIF.

  READ TABLE ins_data INDEX 1.
* Schlüssel füllen
  CLEAR ikey_tatyp.
  ikey_tatyp-mandt = sy-mandt.
  IF oldkey_ins+10(1) = 'N'.     "Netznutzung-Anlage
    ikey_tatyp-bukrs = bukrs_n.
  ELSEIF oldkey_ins+10(1) = 'V'. "Vertieb-Anlage
    ikey_tatyp-bukrs = bukrs_v.
  ENDIF.
  ikey_tatyp-bukrs_art = oldkey_ins+10(1).
  ikey_tatyp-tatyp_alt = ins_data-tariftyp.

* Umschlüsselung
  READ TABLE iums_tatyp WITH KEY ikey_tatyp BINARY SEARCH.
  IF sy-subrc = 0.
    ins_data-tariftyp = iums_tatyp-tatyp_neu.
    MODIFY ins_data INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Tariftyp-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_tatyp-bukrs
                ikey_tatyp-bukrs_art
                ikey_tatyp-tatyp_alt ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.

* Konzessionsvertrag
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_konzv IS INITIAL.
    SELECT * INTO TABLE iums_konzv
             FROM /adesso/mtu_konz.
    filled_konzv = 'X'.
    sort iums_konzv.
  ENDIF.

  READ TABLE ins_data INDEX 1.
* Schlüssel füllen
  CLEAR ikey_konzv.
  ikey_konzv-mandt = sy-mandt.
  IF oldkey_ins+10(1) = 'N'.     "Netznutzung-Anlage
    ikey_konzv-bukrs = bukrs_n.
  ELSEIF oldkey_ins+10(1) = 'V'. "Vertieb-Anlage
    ikey_konzv-bukrs = bukrs_v.
  ENDIF.
  ikey_konzv-sparte = ins_data-sparte.

* Umschlüsselung
  READ TABLE iums_konzv WITH KEY ikey_konzv BINARY SEARCH.
  IF sy-subrc = 0.
    ins_data-konzver = iums_konzv-konzver.
    MODIFY ins_data INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Konzess.Vertr-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_konzv-bukrs
                ikey_konzv-sparte ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.

* Service-Art
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_serv IS INITIAL.
    SELECT * INTO TABLE iums_serv
             FROM /adesso/mtu_serv.
    filled_serv = 'X'.
    sort iums_serv.
  ENDIF.

  READ TABLE ins_data INDEX 1.
* Schlüssel füllen
  CLEAR ikey_serv.
  ikey_serv-mandt = sy-mandt.
  IF oldkey_ins+10(1) = 'N'.     "Netznutzung-Anlage
    ikey_serv-bukrs = bukrs_n.
  ELSEIF oldkey_ins+10(1) = 'V'. "Vertieb-Anlage
    ikey_serv-bukrs = bukrs_v.
  ENDIF.
  ikey_serv-bukrs_art = oldkey_ins+10(1).
  IF ins_data-sparte = '10'.
    ikey_serv-service_alt = ins_data-service.
  ENDIF.
  ikey_serv-sparte = ins_data-sparte.

* Umschlüsselung
  READ TABLE iums_serv WITH KEY ikey_serv BINARY SEARCH.
  IF sy-subrc = 0.
    ins_data-service = iums_serv-service_neu.
    MODIFY ins_data INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Service-Art-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_serv-bukrs
                ikey_serv-bukrs_art
                ikey_serv-service_alt
                ikey_serv-sparte ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.

* Ableseeinheit
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_ableh IS INITIAL.
    SELECT * INTO TABLE iums_ableh
             FROM /adesso/mtu_abeh.
    filled_ableh = 'X'.
    sort iums_ableh.
  ENDIF.

  READ TABLE ins_data INDEX 1.
* Schlüssel füllen
  CLEAR ikey_ableh.
  ikey_ableh-mandt = sy-mandt.
  IF oldkey_ins+10(1) = 'N'.     "Netznutzung-Anlage
    ikey_ableh-bukrs = bukrs_n.
  ELSEIF oldkey_ins+10(1) = 'V'. "Vertieb-Anlage
    ikey_ableh-bukrs = bukrs_v.
  ENDIF.
  ikey_ableh-ableh_alt = ins_data-ableinh.

* Umschlüsselung
  READ TABLE iums_ableh WITH KEY ikey_ableh BINARY SEARCH.
  IF sy-subrc = 0.
    ins_data-ableinh = iums_ableh-ableh_neu.
    MODIFY ins_data INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Abl.Einheit-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_ableh-bukrs
                ikey_ableh-ableh_alt ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.

  READ TABLE ins_pod INDEX 1.
  IF sy-subrc = 0.
    IF ins_pod-uistrutyp = 'Z2'.
      ins_pod-uistrutyp = '02'.
      MODIFY ins_pod INDEX 1.
    ENDIF.
    IF ins_pod-grid_id = '000291'.
      ins_pod-grid_id = '000291_N'.
      MODIFY ins_pod INDEX 1.
    ENDIF.
  ENDIF.

*-----------------------------------------------------------------------
* Anlagefakten
*-----------------------------------------------------------------------
* Umschl-Tabellen für Fakten und Preise einlesen
  IF filled_oper IS INITIAL.
    SELECT * INTO TABLE iums_oper
             FROM /adesso/mtu_oper.
    filled_oper = 'X'.
    sort iums_oper.
  ENDIF.

  IF filled_prkey IS INITIAL.
    SELECT * INTO TABLE iums_prkey
             FROM /adesso/mtu_pkey.
    filled_prkey = 'X'.
    sort iums_prkey.
  ENDIF.

  READ TABLE ins_data INDEX 1.
  loop at ins_facts.
*   Fakten-Umschlüsselung nach Zusatz-Regeln (höhere Prio)
    case ins_facts-operand.
      when 'STGSFLAG01'.
        IF oldkey_ins+10(1) = 'V'.      "Vertieb-Anlage
          ins_facts-optyp = 'RATETYPE'.
          ins_facts-operand = 'STTAÖKO'.
          ins_facts-tarifart = 'SÖKOREDU'.
          ins_facts-kondigr = '00'.
          modify ins_facts.
        else.
          delete ins_facts.
        endif.
*       speziele Rregel haben Vorgang vor der normalen Umschlüsselung
        continue.
      when 'SFLAGPROD'.
        IF oldkey_ins+10(1) = 'V'.      "Vertieb-Anlage
          ins_facts-optyp = 'RATETYPE'.
          ins_facts-operand = 'STTAÖKO'.
          ins_facts-tarifart = 'SÖKOREDU'.
          ins_facts-kondigr = '00'.
          modify ins_facts.
        else.
          delete ins_facts.
        endif.
        continue.
      when 'STGSFLAG02'.
        IF oldkey_ins+10(1) = 'V'.      "Vertieb-Anlage
          ins_facts-optyp = 'RATETYPE'.
          ins_facts-operand = 'STTAÖKO'.
          ins_facts-tarifart = 'SÖKOWÄRM'.
          ins_facts-kondigr = '00'.
          modify ins_facts.
        else.
          delete ins_facts.
        endif.
        continue.
      when 'SFLAGEINB'.
        IF oldkey_ins+10(1) = 'V'.      "Vertieb-Anlage
          ins_facts-optyp = 'RATETYPE'.
          ins_facts-operand = 'STTAÖKO'.
          ins_facts-tarifart = 'SÖKOWÄRM'.
          ins_facts-kondigr = '00'.
          modify ins_facts.
        else.
          delete ins_facts.
        endif.
        continue.
      when 'STGSFLAG03'.
        IF oldkey_ins+10(1) = 'V'.      "Vertieb-Anlage
          ins_facts-optyp = 'RATETYPE'.
          ins_facts-operand = 'STTAÖKO'.
          ins_facts-tarifart = 'SÖKOWÄRM'.
          ins_facts-kondigr = '00'.
          modify ins_facts.
        else.
          delete ins_facts.
        endif.
        continue.
      when 'STFLAGWÄPU'.
        IF oldkey_ins+10(1) = 'V'.      "Vertieb-Anlage
          ins_facts-optyp = 'RATETYPE'.
          ins_facts-operand = 'STTAÖKO'.
          ins_facts-tarifart = 'SÖKOWÄRM'.
          ins_facts-kondigr = '00'.
          modify ins_facts.
        else.
          delete ins_facts.
        endif.
        continue.
      when 'STGSFÖFREI'.
        IF oldkey_ins+10(1) = 'V'.      "Vertieb-Anlage
          ins_facts-optyp = 'RATETYPE'.
          ins_facts-operand = 'STTAÖKO'.
          ins_facts-tarifart = 'SÖKOFREI'.
          ins_facts-kondigr = '00'.
          modify ins_facts.
        else.
          delete ins_facts.
        endif.
        continue.
    endcase.

*   Fakten-Umschlüsselung nach Umschl-Tabelle (normale Regel)
*   Schlüssel füllen
    CLEAR ikey_oper.
    ikey_oper-mandt = sy-mandt.
    IF oldkey_ins+10(1) = 'N'.     "Netznutzung-Anlage
      ikey_oper-bukrs = bukrs_n.
    ELSEIF oldkey_ins+10(1) = 'V'. "Vertieb-Anlage
      ikey_oper-bukrs = bukrs_v.
    ENDIF.
    ikey_oper-bukrs_art = oldkey_ins+10(1).
    ikey_oper-oper_alt = ins_facts-operand.

*   Operanden suchen
    READ TABLE iums_oper WITH KEY ikey_oper BINARY SEARCH.
    IF sy-subrc = 0.
      if iums_oper-oper_neu is initial.
*       Operand soll im Zielsystem nicht mehr vorkommen
        delete ins_facts.
      else.
*       Umschlüsselung (Wert-neu --> Wert-alt)
        ins_facts-operand = iums_oper-oper_neu.
        MODIFY ins_facts.
*       Prüfen, ob auch eine Preisumschlüsselung notwendig ist
        if ins_facts-optyp = 'QPRICE' or
           ins_facts-optyp = 'LPRICE' or
           ins_facts-optyp = 'SPRICE' or
           ins_facts-optyp = 'TPRICE'.
          clear ikey_prkey.
          ikey_prkey-mandt = sy-mandt.
          ikey_prkey-bukrs = bukrs_v.
          ikey_prkey-price_alt = ins_facts-string1.

          read table iums_prkey with key ikey_prkey binary search.
          if sy-subrc = 0.
            ins_facts-string1 = iums_prkey-price_neu.
            modify ins_facts.
          else.
            CONCATENATE 'Fehler bei Preis-Umschlüsselung,'
                        '(Umschl-Key:'
                        ikey_prkey-bukrs
                        ikey_prkey-bukrs_art
                        ikey_prkey-price_alt ')'
                        INTO meldung-meldung SEPARATED BY space.
            APPEND meldung.
          endif.
        endif.
      endif.
    ELSE.
*     fehlender Eintrag -->  1:1 Übernahme
      CONCATENATE 'Fehler bei Operand-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_oper-bukrs
                  ikey_oper-bukrs_art
                  ikey_oper-oper_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  endloop.


ENDFUNCTION.
