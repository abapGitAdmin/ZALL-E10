FUNCTION /adesso/mtu_sampl_bel_inst_chs.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  EXPORTING
*"     REFERENCE(OLDKEY_ICH) TYPE  EMG_OLDKEY
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      ICH_KEY STRUCTURE  EANLHKEY OPTIONAL
*"      ICH_DATA STRUCTURE  EMG_EANL OPTIONAL
*"      ICH_RCAT STRUCTURE  ISU_AITTYP OPTIONAL
*"      ICH_FACTS STRUCTURE  /ADESSO/MT_FACTS OPTIONAL
*"----------------------------------------------------------------------

* Tariftyp
*-----------------------------------------------------------------------
TABLES: /adesso/mtu_ttyp.

* Tabelle einlesen
  IF filled_tatyp IS INITIAL.
    SELECT * INTO TABLE iums_tatyp
             FROM /adesso/mtu_ttyp.
    filled_tatyp = 'X'.
    SORT iums_tatyp.
  ENDIF.

  READ TABLE ich_data INDEX 1.
* Schlüssel füllen
  CLEAR ikey_tatyp.
  ikey_tatyp-mandt = sy-mandt.
  IF oldkey_ich+10(1) = 'N'.     "Netznutzung-Anlage
    ikey_tatyp-bukrs = bukrs_n.
  ELSEIF oldkey_ich+10(1) = 'V'. "Vertieb-Anlage
    ikey_tatyp-bukrs = bukrs_v.
  ENDIF.
  ikey_tatyp-bukrs_art = oldkey_ich+10(1).
  ikey_tatyp-tatyp_alt = ich_data-tariftyp.

* Umschlüsselung
  READ TABLE iums_tatyp WITH KEY ikey_tatyp BINARY SEARCH.
  IF sy-subrc = 0.
    ich_data-tariftyp = iums_tatyp-tatyp_neu.
    MODIFY ich_data INDEX 1.
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
    SORT iums_konzv.
  ENDIF.

  READ TABLE ich_data INDEX 1.
* Schlüssel füllen
  CLEAR ikey_konzv.
  ikey_konzv-mandt = sy-mandt.
  IF oldkey_ich+10(1) = 'N'.     "Netznutzung-Anlage
    ikey_konzv-bukrs = bukrs_n.
  ELSEIF oldkey_ich+10(1) = 'V'. "Vertieb-Anlage
    ikey_konzv-bukrs = bukrs_v.
  ENDIF.
  ikey_konzv-sparte = ich_data-sparte.

* Umschlüsselung
  READ TABLE iums_konzv WITH KEY ikey_konzv BINARY SEARCH.
  IF sy-subrc = 0.
    ich_data-konzver = iums_konzv-konzver.
    MODIFY ich_data INDEX 1.
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
    SORT iums_serv.
  ENDIF.

  READ TABLE ich_data INDEX 1.
* Schlüssel füllen
  CLEAR ikey_serv.
  ikey_serv-mandt = sy-mandt.
  IF oldkey_ich+10(1) = 'N'.     "Netznutzung-Anlage
    ikey_serv-bukrs = bukrs_n.
  ELSEIF oldkey_ich+10(1) = 'V'. "Vertieb-Anlage
    ikey_serv-bukrs = bukrs_v.
  ENDIF.
  ikey_serv-bukrs_art = oldkey_ich+10(1).
  IF ich_data-sparte = '10'.
    ikey_serv-service_alt = ich_data-service.
  ENDIF.
  ikey_serv-sparte = ich_data-sparte.

* Umschlüsselung
  READ TABLE iums_serv WITH KEY ikey_serv BINARY SEARCH.
  IF sy-subrc = 0.
    ich_data-service = iums_serv-service_neu.
    MODIFY ich_data INDEX 1.
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
    SORT iums_ableh.
  ENDIF.

  READ TABLE ich_data INDEX 1.
* Schlüssel füllen
  CLEAR ikey_ableh.
  ikey_ableh-mandt = sy-mandt.
  IF oldkey_ich+10(1) = 'N'.     "Netznutzung-Anlage
    ikey_ableh-bukrs = bukrs_n.
  ELSEIF oldkey_ich+10(1) = 'V'. "Vertieb-Anlage
    ikey_ableh-bukrs = bukrs_v.
  ENDIF.
  ikey_ableh-ableh_alt = ich_data-ableinh.

* Umschlüsselung
  READ TABLE iums_ableh WITH KEY ikey_ableh BINARY SEARCH.
  IF sy-subrc = 0.
    ich_data-ableinh = iums_ableh-ableh_neu.
    MODIFY ich_data INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Abl.Einheit-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_ableh-bukrs
                ikey_ableh-ableh_alt ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.




ENDFUNCTION.
