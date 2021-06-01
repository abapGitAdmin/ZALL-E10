FUNCTION /adesso/mtu_sampl_bel_devloc.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      I_EGPLD STRUCTURE  EGPLD OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DLC) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* Standort-Werk
  READ TABLE i_egpld INDEX 1.
  i_egpld-swerk = '1001'.              "Herne

  MODIFY i_egpld INDEX 1.

* Standort
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_stort IS INITIAL.
    SELECT * INTO TABLE iums_stort
             FROM /adesso/mtu_stor.
    filled_stort = 'X'.
    SORT iums_stort.
  ENDIF.

  READ TABLE i_egpld INDEX 1.
* Schlüssel füllen
  CLEAR ikey_stort.
  ikey_stort-mandt = sy-mandt.
  ikey_stort-bukrs = bukrs_v.
  ikey_stort-stort_alt = i_egpld-stort.

* Umschlüsselung
  READ TABLE iums_stort WITH KEY ikey_stort BINARY SEARCH.
  IF sy-subrc = 0.
    i_egpld-stort = iums_stort-stort_neu.
    MODIFY i_egpld INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Standort-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_stort-bukrs
                ikey_stort-stort_alt ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.




ENDFUNCTION.
