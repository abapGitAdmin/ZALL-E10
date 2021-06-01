FUNCTION /ADESSO/MTU_SAMPL_BEL_PAYMENT .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IPAY_FKKKO STRUCTURE  EMIG_PAY_FKKKO OPTIONAL
*"      IPAY_FKKOPK STRUCTURE  FKKOPK OPTIONAL
*"      IPAY_SELTNS STRUCTURE  EMIG_PAY_SELTNS OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_PAY) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* Hauptbuchkonto für Abschläge
  read table ipay_fkkopk index 1.
  ipay_fkkopk-hkont = '0035641041'.
  modify ipay_fkkopk index 1.


* Tabelle einlesen
  IF filled_mwst IS INITIAL.
    SELECT * INTO TABLE iums_mwst
             FROM /adesso/mtu_mwst.
    filled_mwst = 'X'.
    SORT iums_mwst.
  ENDIF.

*  LOOP AT ibpm_eabps..
** Schlüssel füllen
*    CLEAR ikey_stort.
*    ikey_mwst-mandt = sy-mandt.
*    ikey_mwst-bukrs = bukrs_v.
*    ikey_mwst-mwskz_alt = ibpm_eabps-mwskz.
**
** Umschlüsselung
*    READ TABLE iums_mwst WITH KEY ikey_mwst BINARY SEARCH.
*    IF sy-subrc = 0.
*      ibpm_eabps-mwskz = iums_mwst-mwstk_neu.
*      MODIFY ibpm_eabps.
*    ELSE.
*      CONCATENATE 'Fehler bei Standort-Umschlüsselung,'
*                  '(Umschl-Key:'
*                  ikey_mwst-bukrs
*                  ikey_mwst-mwskz_alt ')'
*                  INTO meldung-meldung SEPARATED BY space.
*      APPEND meldung.
*    ENDIF.
*
*  ENDLOOP.
*
*  LOOP AT ibpm_ejvl..
** Schlüssel füllen
*    CLEAR ikey_mwst.
*    ikey_mwst-mandt = sy-mandt.
*    ikey_mwst-bukrs = bukrs_v.
*    ikey_mwst-mwskz_alt = ibpm_ejvl-mwskz.
**
** Umschlüsselung
*    READ TABLE iums_mwst WITH KEY ikey_mwst BINARY SEARCH.
*    IF sy-subrc = 0.
*      ibpm_ejvl-mwskz = iums_mwst-mwstk_neu.
*      MODIFY ibpm_ejvl.
*    ELSE.
*      CONCATENATE 'Fehler bei Standort-Umschlüsselung,'
*                  '(Umschl-Key:'
*                  ikey_mwst-bukrs
*                  ikey_mwst-mwskz_alt ')'
*                  INTO meldung-meldung SEPARATED BY space.
*      APPEND meldung.
*    ENDIF.
*
*  ENDLOOP.
*



ENDFUNCTION.
