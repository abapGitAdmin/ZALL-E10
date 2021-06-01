FUNCTION /adesso/mtu_sampl_bel_partner.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      I_INIT STRUCTURE  EMG_EKUN_INIT OPTIONAL
*"      I_EKUN STRUCTURE  EKUN_DI OPTIONAL
*"      I_BUT000 STRUCTURE  BUS000_DI OPTIONAL
*"      I_BUT001 STRUCTURE  BUS001_DI OPTIONAL
*"      I_BUT0BK STRUCTURE  BUS0BK_DI OPTIONAL
*"      I_BUT020 STRUCTURE  BUS020_DI OPTIONAL
*"      I_BUT021 STRUCTURE  BUS021_DI OPTIONAL
*"      I_BUT0CC STRUCTURE  BUS0CC_DI OPTIONAL
*"      I_SHIPTO STRUCTURE  ESHIPTO_DI OPTIONAL
*"      I_TAXNUM STRUCTURE  EMG_FKKBPTAX_DI OPTIONAL
*"      I_ECCARD STRUCTURE  ECONCARD_DI OPTIONAL
*"      I_ECCRDH STRUCTURE  ECONCARDH_DI OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_PAR) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------
* Anrede
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_anred IS INITIAL.
    SELECT * INTO TABLE iums_anred
             FROM /adesso/mtu_anrd.
    filled_anred = 'X'.
    SORT iums_anred.
  ENDIF.

  READ TABLE i_but000 INDEX 1.
  IF NOT i_but000-title IS INITIAL.
*   Schlüssel füllen
    CLEAR ikey_anred.
    ikey_anred-mandt = sy-mandt.
    ikey_anred-anrede_alt = i_but000-title.

*   Umschlüsselung
    READ TABLE iums_anred WITH KEY ikey_anred BINARY SEARCH.
    IF sy-subrc = 0.
      i_but000-title = iums_anred-anrede_neu.
      MODIFY i_but000 INDEX 1.
    ELSE.
      CONCATENATE 'Fehler bei Anrede-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_anred-anrede_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDIF.


ENDFUNCTION.
