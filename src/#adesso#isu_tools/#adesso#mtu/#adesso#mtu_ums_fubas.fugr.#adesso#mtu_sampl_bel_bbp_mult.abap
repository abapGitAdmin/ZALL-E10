FUNCTION /adesso/mtu_sampl_bel_bbp_mult.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IBPM_EABP STRUCTURE  EABP OPTIONAL
*"      IBPM_EABPV STRUCTURE  EMIGR_EVER OPTIONAL
*"      IBPM_EABPS STRUCTURE  SFKKOP OPTIONAL
*"      IBPM_EJVL STRUCTURE  EJVL OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_BPM) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------
* Wenn der Beginn der Abschlagsperiode und die erste Fälligkeit
* übereinstimmen, wird der ABP zurückgewiesen
* Daher wird in diesen Fällen bei Abschlagsbetrag 0,00 die Fälligkeit
* um einen Tag verschoben.

  DATA: labdat LIKE sy-datum.
  READ TABLE ibpm_eabp INDEX 1.
  labdat = ibpm_eabp-begperiode.

* Tabelle einlesen
  IF filled_mwst IS INITIAL.
    SELECT * INTO TABLE iums_mwst
             FROM /adesso/mtu_mwst.
    filled_mwst = 'X'.
    SORT iums_mwst.
  ENDIF.

  LOOP AT ibpm_eabps.


    IF ibpm_eabps-faedn = labdat
       AND ibpm_eabps-betrw = 0.
      ibpm_eabps-faedn = ibpm_eabps-faedn + 1.
      MODIFY ibpm_eabps.
      CONCATENATE 'Fälligkeit' ibpm_eabps-faedn
                  'um einen Tag erhöht. Altsystemschlüssel'
                  oldkey_bpm INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.

* Schlüssel füllen
    CLEAR ikey_stort.
    ikey_mwst-mandt = sy-mandt.
    ikey_mwst-bukrs = bukrs_v.
    ikey_mwst-mwskz_alt = ibpm_eabps-mwskz.
*
* Umschlüsselung
    READ TABLE iums_mwst WITH KEY ikey_mwst BINARY SEARCH.
    IF sy-subrc = 0.
      ibpm_eabps-mwskz = iums_mwst-mwstk_neu.
      MODIFY ibpm_eabps.
    ELSE.
      CONCATENATE 'Fehler bei Standort-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_mwst-bukrs
                  ikey_mwst-mwskz_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.

  ENDLOOP.

  LOOP AT ibpm_ejvl..
* Schlüssel füllen
    CLEAR ikey_mwst.
    ikey_mwst-mandt = sy-mandt.
    ikey_mwst-bukrs = bukrs_v.
    ikey_mwst-mwskz_alt = ibpm_ejvl-mwskz.
*
* Umschlüsselung
    READ TABLE iums_mwst WITH KEY ikey_mwst BINARY SEARCH.
    IF sy-subrc = 0.
      ibpm_ejvl-mwskz = iums_mwst-mwstk_neu.
      MODIFY ibpm_ejvl.
    ELSE.
      CONCATENATE 'Fehler bei Standort-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_mwst-bukrs
                  ikey_mwst-mwskz_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.

  ENDLOOP.

* Um einigen Fehlern nach der Splittung vorzugehen:
* Sort der Vertragsbezogenen Daten
  SORT ibpm_eabpv BY vtref.
  SORT ibpm_eabps BY faedn vtref.
  SORT ibpm_ejvl  BY vertrag.

* Kumulieren identischer Buchungszeile in der ibpm_eabps2
  CLEAR ibpm_eabps2.
  REFRESH ibpm_eabps2.
  CLEAR: wa_key_old.

  LOOP AT ibpm_eabps.
    MOVE-CORRESPONDING ibpm_eabps TO wa_key_new.
    IF wa_key_new NE wa_key_old.
      IF wa_key_old IS INITIAL.
        ibpm_eabps2 = ibpm_eabps.
      ELSE.
        APPEND ibpm_eabps2.
        ibpm_eabps2 = ibpm_eabps.
      ENDIF.
      wa_key_old = wa_key_new.
    ELSE.
      ADD ibpm_eabps-betrw TO ibpm_eabps2-betrw.
      ADD ibpm_eabps-betro TO ibpm_eabps2-betro.
    ENDIF.
  ENDLOOP.
  APPEND ibpm_eabps2.

  ibpm_eabps[] = ibpm_eabps2[].

ENDFUNCTION.
