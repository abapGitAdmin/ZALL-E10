FUNCTION /adesso/mtu_sampl_bel_devicera.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IDRT_DRINT STRUCTURE  EMG_DEVRATE_INT OPTIONAL
*"      IDRT_DRDEV STRUCTURE  REG70_D OPTIONAL
*"      IDRT_DRREG STRUCTURE  REG70_R OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_DRT) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* Gerätetyp-Daten einspielen
  IF filled_gertyp IS INITIAL.
    SELECT * INTO TABLE igertyp
             FROM etyp.
    filled_gertyp = 'X'.
    SORT igertyp.
  ENDIF.


*   Preisklasse aus dem Gerätetyp übernehmen und auf Geräteebene setzen
*   Tarifart und Faktengruppe setzen
*-----------------------------------------------------------------------
  LOOP AT idrt_drdev
    WHERE NOT equnr IS INITIAL.

*   Equi-Nr im Zielsystem ermitteln
    CLEAR itemksv.
    SELECT SINGLE newkey
           INTO itemksv-newkey
           FROM temksv
           WHERE firma = 'EVU01'
             AND   object = 'DEVICE'
             AND oldkey = idrt_drdev-equnr.
    IF sy-subrc > 0.
      CONCATENATE 'Equipment-Neu'
                  idrt_drdev-equnr
                  'wurde noch nicht migriert'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ELSE.
*     Mat.Nummer lesen (Gerätetyp)
      CLEAR ikey_gertyp.
      ikey_gertyp-mandt = sy-mandt.
      SELECT SINGLE matnr
             INTO ikey_gertyp-matnr
             FROM equi
             WHERE equnr = itemksv-newkey.
*     Gerätetyp-Daten lesen
      READ TABLE igertyp WITH KEY ikey_gertyp BINARY SEARCH.
      IF sy-subrc = 0.
*       Preisklasse und Verrechnungskennzeichen setzen
        idrt_drdev-preiskla = igertyp-preiskla.
        idrt_drdev-gverrech = 'X'.
*       Tarifart und Faktengruppe setzen
        CASE igertyp-sparte.
          WHEN '10'.
            idrt_drdev-tarifart = 'STROMVP'.
            idrt_drdev-kondigr = '00'.
          WHEN '20'.
            idrt_drdev-tarifart = 'GASVP'.
            idrt_drdev-kondigr = '00'.
          WHEN '30'.
            idrt_drdev-tarifart = 'WASSERVP'.
            idrt_drdev-kondigr = '00'.
          WHEN '40'.
            idrt_drdev-tarifart = 'FWÄRMEVP'.
            idrt_drdev-kondigr = '00'.
        ENDCASE.
        MODIFY idrt_drdev.
      ELSE.
        CONCATENATE 'Fehlender Gerätetyp'
                    igertyp-matnr
                    'in ETYP'
                    INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Preisklassen auf Zählwerksebene umschlüsseln
*----------------------------------------------------------------------*
* Tabelle einlesen
  IF filled_prskl IS INITIAL.
    SELECT * INTO TABLE iums_prskl
             FROM /adesso/mtu_prkl.
    filled_prskl = 'X'.
    SORT iums_prskl.
  ENDIF.

* Preisklasse für das Einbau-Geräete
  LOOP AT idrt_drreg
    WHERE NOT preiskla IS INITIAL.
*   regeln mit Prio-1 für Null_Preisklassen
    IF idrt_drreg-preiskla = 'SPVNULL000' OR
       idrt_drreg-preiskla = 'STNULLVERR' OR
       idrt_drreg-preiskla = 'GTNULLVERR' OR
       idrt_drreg-preiskla = 'GTVPNULL00' OR
       idrt_drreg-preiskla = 'WTNULLVERR' OR
       idrt_drreg-preiskla = 'WTVPNULL00' OR
       idrt_drreg-preiskla = 'WTVPQN0000'.
      CLEAR idrt_drreg-preiskla.
      CLEAR idrt_drreg-gverrech.
      MODIFY idrt_drreg.
      CONTINUE.
    ENDIF.

*   Schlüssel füllen
    CLEAR ikey_prskl.
    ikey_prskl-mandt = sy-mandt.
    ikey_prskl-bukrs = bukrs_v.
    ikey_prskl-prskl_alt = idrt_drreg-preiskla.

*   Umschlüsselung
    READ TABLE iums_prskl WITH KEY ikey_prskl BINARY SEARCH.
    IF sy-subrc = 0.
      idrt_drreg-preiskla = iums_prskl-prskl_neu.
      MODIFY idrt_drreg.
    ELSE.
      CONCATENATE 'Fehler bei Preisklassen-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_prskl-bukrs
                  ikey_prskl-prskl_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDLOOP.

* Gas-Abrechnung-Parameter festsetzen
*-----------------------------------------------------------------------
  READ TABLE idrt_drint INDEX 1.
  LOOP AT idrt_drreg
       WHERE tarifart(1) = 'G'.
        idrt_drreg-thgver = 'TK02'.
        idrt_drreg-festtemp = 'T1'.
    MODIFY idrt_drreg.
  ENDLOOP.

* Tarifarten auf Zählwerksebene umschlüsseln
* (Festwerte auf Geräeteebene !)
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_taart IS INITIAL.
    SELECT * INTO TABLE iums_taart
             FROM /adesso/mtu_tart.
    filled_taart = 'X'.
  ENDIF.

  LOOP AT idrt_drreg.
*   Schlüssel füllen
    CLEAR ikey_taart.
    ikey_taart-mandt = sy-mandt.
    IF oldkey_drt+28(1) = 'N'.     "Netznutzung-Anlage "19
      ikey_taart-bukrs = bukrs_n.
    ELSEIF oldkey_drt+28(1) = 'V'. "Vertieb-Anlage "19
      ikey_taart-bukrs = bukrs_v.
    ENDIF.
    ikey_taart-bukrs_art = oldkey_drt+28(1). "19
    ikey_taart-taart_alt = idrt_drreg-tarifart.

*   Umschlüsselung
    READ TABLE iums_taart WITH KEY ikey_taart BINARY SEARCH.
    IF sy-subrc = 0.
      idrt_drreg-tarifart = iums_taart-taart_neu.
      idrt_drreg-kondigr = iums_taart-fakgrp.
      MODIFY idrt_drreg.
    ELSE.
      CONCATENATE 'Fehler bei Tarifart-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_taart-bukrs
                  ikey_taart-bukrs_art
                  ikey_taart-taart_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
