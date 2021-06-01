FUNCTION /ADESSO/MTU_SAMPL_BEL_PREMISE .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      I_EVBSD STRUCTURE  EVBSD OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_PRE) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* Verbrauchsstellen-Art
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_vbart IS INITIAL.
    SELECT * INTO TABLE iums_vbart
             FROM /adesso/mtu_vbar.
    filled_vbart = 'X'.
    SORT iums_vbart.
  ENDIF.

  READ TABLE i_evbsd INDEX 1.
  IF NOT i_evbsd-vbsart IS INITIAL.
*   Schlüssel füllen
    CLEAR ikey_vbart.
    ikey_vbart-mandt = sy-mandt.
    ikey_vbart-vbsart_alt = i_evbsd-vbsart.

*   Umschlüsselung
    READ TABLE iums_vbart WITH KEY ikey_vbart BINARY SEARCH.
    IF sy-subrc = 0.
      i_evbsd-vbsart = iums_vbart-vbsart_neu.
      MODIFY i_evbsd INDEX 1.
    ELSE.
      CONCATENATE 'Fehler bei Verbr.St.Art-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_vbart-vbsart_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDIF.





ENDFUNCTION.
