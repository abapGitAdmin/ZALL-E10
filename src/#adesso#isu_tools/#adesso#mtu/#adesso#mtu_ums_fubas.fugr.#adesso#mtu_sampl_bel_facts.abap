FUNCTION /ADESSO/MTU_SAMPL_BEL_FACTS .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IFAC_KEY STRUCTURE  EANLHKEY OPTIONAL
*"      IFAC_FACTS STRUCTURE  /ADESSO/MT_FACTS OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_FAC) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------
* Umschl-Tabellen für Fakten und Preise einlesen
  IF filled_oper IS INITIAL.
    SELECT * INTO TABLE iums_oper
             FROM /adesso/mtu_oper.
    filled_oper = 'X'.
    SORT iums_oper.
  ENDIF.

  IF filled_prkey IS INITIAL.
    SELECT * INTO TABLE iums_prkey
             FROM /adesso/mtu_pkey.
    filled_prkey = 'X'.
    SORT iums_prkey.
  ENDIF.

  IF filled_taart IS INITIAL.
    SELECT * INTO TABLE iums_taart
             FROM /adesso/mtu_tart.
    filled_taart = 'X'.
    SORT iums_taart.
  ENDIF.


  LOOP AT ifac_facts.
*   Fakten-Umschlüsselung nach Zusatz-Regeln (höhere Prio)
    CASE ifac_facts-operand.
      WHEN 'STGSFLAG01'.
        IF oldkey_fac+10(1) = 'V'.      "Vertieb-Anlage
          ifac_facts-optyp = 'RATETYPE'.
          ifac_facts-operand = 'STTAÖKO'.
          ifac_facts-tarifart = 'SÖKOREDU'.
          ifac_facts-kondigr = '00'.
          MODIFY ifac_facts.
        ELSE.
          DELETE ifac_facts.
        ENDIF.
*       speziele Rregel haben Vorgang vor der normalen Umschlüsselung
        CONTINUE.
      WHEN 'SFLAGPROD'.
        IF oldkey_fac+10(1) = 'V'.      "Vertieb-Anlage
          ifac_facts-optyp = 'RATETYPE'.
          ifac_facts-operand = 'STTAÖKO'.
          ifac_facts-tarifart = 'SÖKOREDU'.
          ifac_facts-kondigr = '00'.
          MODIFY ifac_facts.
        ELSE.
          DELETE ifac_facts.
        ENDIF.
        CONTINUE.
      WHEN 'STGSFLAG02'.
        IF oldkey_fac+10(1) = 'V'.      "Vertieb-Anlage
          ifac_facts-optyp = 'RATETYPE'.
          ifac_facts-operand = 'STTAÖKOWÄR'.
          ifac_facts-tarifart = 'SÖKOVOLL'.
          ifac_facts-kondigr = '00'.
          MODIFY ifac_facts.
        ELSE.
          DELETE ifac_facts.
        ENDIF.
        CONTINUE.
      WHEN 'SFLAGEINB'.
        IF oldkey_fac+10(1) = 'V'.      "Vertieb-Anlage
          ifac_facts-optyp = 'RATETYPE'.
          ifac_facts-operand = 'STTAÖKOWÄR'.
          ifac_facts-tarifart = 'SÖKOVOLL'.
          ifac_facts-kondigr = '00'.
          MODIFY ifac_facts.
        ELSE.
          DELETE ifac_facts.
        ENDIF.
        CONTINUE.
      WHEN 'STGSFLAG03'.
        IF oldkey_fac+10(1) = 'V'.      "Vertieb-Anlage
          ifac_facts-optyp = 'RATETYPE'.
          ifac_facts-operand = 'STTAÖKOWÄR'.
          ifac_facts-tarifart = 'SÖKOVOLL'.
          ifac_facts-kondigr = '00'.
          MODIFY ifac_facts.
        ELSE.
          DELETE ifac_facts.
        ENDIF.
        CONTINUE.
      WHEN 'STFLAGWÄPU'.
        IF oldkey_fac+10(1) = 'V'.      "Vertieb-Anlage
          ifac_facts-optyp = 'RATETYPE'.
          ifac_facts-operand = 'STTAÖKOWÄR'.
          ifac_facts-tarifart = 'SÖKOVOLL'.
          ifac_facts-kondigr = '00'.
          MODIFY ifac_facts.
        ELSE.
          DELETE ifac_facts.
        ENDIF.
        CONTINUE.
      WHEN 'STGSFÖFREI'.
        IF oldkey_fac+10(1) = 'V'.      "Vertieb-Anlage
          ifac_facts-optyp = 'RATETYPE'.
          ifac_facts-operand = 'STTAÖKO'.
          ifac_facts-tarifart = 'SÖKOFREI'.
          ifac_facts-kondigr = '00'.
          MODIFY ifac_facts.
        ELSE.
          DELETE ifac_facts.
        ENDIF.
        CONTINUE.
      WHEN 'ST_FLAG_RE'.
        IF oldkey_fac+10(1) = 'V'.      "Vertieb-Anlage
          ifac_facts-optyp = 'RATETYPE'.
          ifac_facts-operand = 'STTAREGEN'.
          ifac_facts-tarifart = 'STREGEN'.
          ifac_facts-kondigr = 'HE'.
          MODIFY ifac_facts.
        ELSE.
          DELETE ifac_facts.
        ENDIF.
        CONTINUE.
    ENDCASE.

*   Fakten-Umschlüsselung nach Umschl-Tabelle (normale Regel)
*   Schlüssel füllen
    CLEAR ikey_oper.
    ikey_oper-mandt = sy-mandt.
    IF oldkey_fac+10(1) = 'N'.     "Netznutzung-Anlage
      ikey_oper-bukrs = bukrs_n.
    ELSEIF oldkey_fac+10(1) = 'V'. "Vertieb-Anlage
      ikey_oper-bukrs = bukrs_v.
    ENDIF.
    ikey_oper-bukrs_art = oldkey_fac+10(1).
    ikey_oper-oper_alt = ifac_facts-operand.

*   Operanden suchen
    READ TABLE iums_oper WITH KEY ikey_oper BINARY SEARCH.
    IF sy-subrc = 0.
      IF iums_oper-oper_neu IS INITIAL.
*       Operand soll im Zielsystem nicht mehr vorkommen
        DELETE ifac_facts.
        CONTINUE.
      ELSE.
*       Umschlüsselung (Wert-neu --> Wert-alt)
        ifac_facts-operand = iums_oper-oper_neu.
        MODIFY ifac_facts.
*       Prüfen, ob eine Preisumschlüsselung notwendig ist
        IF ifac_facts-optyp = 'QPRICE' OR
           ifac_facts-optyp = 'LPRICE' OR
           ifac_facts-optyp = 'SPRICE' OR
           ifac_facts-optyp = 'TPRICE'.
          CLEAR ikey_prkey.
          ikey_prkey-mandt = sy-mandt.
          ikey_prkey-bukrs = bukrs_v.
          ikey_prkey-price_alt = ifac_facts-string1.

          READ TABLE iums_prkey WITH KEY ikey_prkey BINARY SEARCH.
          IF sy-subrc = 0.
            ifac_facts-string1 = iums_prkey-price_neu.
            MODIFY ifac_facts.
          ELSE.
            CONCATENATE 'Fehler bei Preis-Umschlüsselung,'
                        '(Umschl-Key:'
                        ikey_prkey-bukrs
                        ikey_prkey-bukrs_art
                        ikey_prkey-price_alt ')'
                        INTO meldung-meldung SEPARATED BY space.
            APPEND meldung.
          ENDIF.
        ENDIF.
*       Prüfen, ob eine Tarifart-Umschlüsselung notwendig ist
        IF ifac_facts-optyp = 'RATETYPE'.
*         spezielle Regel für Tarifart SWIRKFA
          IF ifac_facts-tarifart = 'SWIRKFA'.
            DELETE ifac_facts.
            CONTINUE.
          ENDIF.

*         Schlüssel füllen
          CLEAR ikey_taart.
          ikey_taart-mandt = sy-mandt.
          IF oldkey_fac+10(1) = 'N'.     "Netznutzung-Anlage
            ikey_taart-bukrs = bukrs_n.
          ELSEIF oldkey_fac+10(1) = 'V'. "Vertieb-Anlage
            ikey_taart-bukrs = bukrs_v.
          ENDIF.
          ikey_taart-bukrs_art = oldkey_fac+10(1).
          ikey_taart-taart_alt = ifac_facts-tarifart.

*         Umschlüsselung
          READ TABLE iums_taart WITH KEY ikey_taart BINARY SEARCH.
          IF sy-subrc = 0.
            ifac_facts-tarifart = iums_taart-taart_neu.
            IF ifac_facts-tarifart NE 'STKIND'.
              ifac_facts-kondigr = iums_taart-fakgrp.
            ENDIF.
            MODIFY ifac_facts.
          ELSE.
            CONCATENATE 'Fehler bei Tarifart-Umschlüsselung,'
                        '(Umschl-Key:'
                        ikey_taart-bukrs
                        ikey_taart-bukrs_art
                        ikey_taart-taart_alt ')'
                        INTO meldung-meldung SEPARATED BY space.
            APPEND meldung.
          ENDIF.
        ENDIF.
      ENDIF.
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
  ENDLOOP.


ENDFUNCTION.
