FUNCTION /adesso/mtu_sampl_bel_inst_mgm.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      INM_DI_INT STRUCTURE  EMG_WOL OPTIONAL
*"      INM_DI_ZW STRUCTURE  REG30_ZW_C OPTIONAL
*"      INM_DI_GER STRUCTURE  REG30_GERA OPTIONAL
*"      INM_DI_CNT STRUCTURE  EMG_INSTALL_CONTAINER OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_INM) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

DATA: sparte LIKE etyp-sparte.
DATA: spartyp LIKE tespt-spartyp.


* Gerätetyp-Daten einspielen
  IF filled_gertyp IS INITIAL.
    SELECT * INTO TABLE igertyp
             FROM etyp.
    filled_gertyp = 'X'.
    SORT igertyp.
  ENDIF.

CLEAR sparte.
*   Preisklasse aus dem Gerätetyp übernehmen und auf Geräteebene setzen
*   Tarifart und Faktengruppe setzen
*-----------------------------------------------------------------------
  LOOP AT inm_di_ger
*   Nur für Neu-Eingebaute
    WHERE NOT equnrneu IS INITIAL.

*   Equi-Nr im Zielsystem ermitteln
    CLEAR itemksv.
    SELECT SINGLE newkey
           INTO itemksv-newkey
           FROM temksv
           WHERE firma = 'EVU01'
             AND   object = 'DEVICE'
             AND oldkey = inm_di_ger-equnrneu.
    IF sy-subrc > 0.
      CONCATENATE 'Equipment-Neu'
                  inm_di_ger-equnrneu
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
       MOVE igertyp-sparte TO sparte.
       READ TABLE inm_di_int INDEX 1.
       IF inm_di_int-action = '01' OR
          inm_di_int-action = '04'.


*       Preisklasse und Verrechnungskennzeichen setzen
        inm_di_ger-preisklag = igertyp-preiskla.
        inm_di_ger-gverrechg = 'X'.

* Spartentyp ermitteln (KLE061004)
   SELECT SINGLE spartyp FROM tespt INTO spartyp
                  WHERE sparte = igertyp-sparte.

*       Tarifart und Faktengruppe setzen
        CASE spartyp.
          WHEN '01'.
            inm_di_ger-tarifartg = 'STROMVP'.
            inm_di_ger-kondigrg = '00'.
          WHEN '02'.
            inm_di_ger-tarifartg = 'GASVP'.
            inm_di_ger-kondigrg = '00'.
          WHEN '03'.
            inm_di_ger-tarifartg = 'WASSERVP'.
            inm_di_ger-kondigrg = '00'.
          WHEN '05'.
            inm_di_ger-tarifartg = 'FWÄRMEVP'.
            inm_di_ger-kondigrg = '00'.
        ENDCASE.

        MODIFY inm_di_ger.
       ENDIF.

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
  LOOP AT inm_di_zw
    WHERE NOT preisklae IS INITIAL.
*   regeln mit Prio-1 für Null_Preisklassen
    IF inm_di_zw-preisklae = 'SPVNULL000' OR
       inm_di_zw-preisklae = 'STNULLVERR' OR
       inm_di_zw-preisklae = 'GTNULLVERR' OR
       inm_di_zw-preisklae = 'GTVPNULL00' OR
       inm_di_zw-preisklae = 'WTNULLVERR' OR
       inm_di_zw-preisklae = 'WTVPNULL00' OR
       inm_di_zw-preisklae = 'WTVPQN0000'.
      CLEAR inm_di_zw-preisklae.
      CLEAR inm_di_zw-gverrech.
      MODIFY inm_di_zw.
      CONTINUE.
    ENDIF.

*   Schlüssel füllen
    CLEAR ikey_prskl.
    ikey_prskl-mandt = sy-mandt.
    ikey_prskl-bukrs = bukrs_v.
    ikey_prskl-prskl_alt = inm_di_zw-preisklae.

*   Umschlüsselung
    READ TABLE iums_prskl WITH KEY ikey_prskl BINARY SEARCH.
    IF sy-subrc = 0.
      inm_di_zw-preisklae = iums_prskl-prskl_neu.
      MODIFY inm_di_zw.
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
*>alle Luftdruckgebiete erstmal auf 'G_HTHE1' umschlüsseln
LOOP AT inm_di_zw WHERE pr_area_ai NE space.
    inm_di_zw-pr_area_ai = 'G_HTHE1'.
    MODIFY inm_di_zw.
ENDLOOP.
*<

*>alle Brennwertbezirke erstmal auf 'GT20' umschlüsseln
LOOP AT inm_di_zw WHERE calor_area NE space.
    inm_di_zw-calor_area = 'GT20'.
    MODIFY inm_di_zw.
ENDLOOP.
*<


  READ TABLE inm_di_int INDEX 1.
  LOOP AT inm_di_zw
       WHERE tarifart(1) = 'G'.
    CASE inm_di_int-action.
      WHEN '01'.
        inm_di_zw-thgver = 'TK02'.
        inm_di_zw-festtemp = 'T1'.
        inm_di_zw-pr_area_ai = 'G_HTHE1'.
        inm_di_zw-calor_area = 'GT20'.
      WHEN '04'.
        inm_di_zw-thgver = 'TK02'.
        inm_di_zw-festtemp = 'T1'.
      WHEN '06'.
        inm_di_zw-pr_area_ai = 'G_HTHE1'.
        inm_di_zw-calor_area = 'GT20'.
    ENDCASE.
    MODIFY inm_di_zw.
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

  LOOP AT inm_di_zw
    WHERE NOT tarifart IS INITIAL.
*   Schlüssel füllen
    CLEAR ikey_taart.
    ikey_taart-mandt = sy-mandt.
    IF oldkey_inm+28(1) = 'N'.     "Netznutzung-Anlage
      ikey_taart-bukrs = bukrs_n.
    ELSEIF oldkey_inm+28(1) = 'V'. "Vertieb-Anlage
      ikey_taart-bukrs = bukrs_v.
    ENDIF.
    ikey_taart-bukrs_art = oldkey_inm+28(1).
    ikey_taart-taart_alt = inm_di_zw-tarifart.

*   Umschlüsselung
    READ TABLE iums_taart WITH KEY ikey_taart BINARY SEARCH.
    IF sy-subrc = 0.
      inm_di_zw-tarifart = iums_taart-taart_neu.
      inm_di_zw-kondigre = iums_taart-fakgrp.
      MODIFY inm_di_zw.
    ELSE.

     READ TABLE inm_di_int INDEX 1.    "Kle 30.08.2004
     IF inm_di_int-action = '01' OR    "Kle 30.08.2004
        inm_di_int-action = '04'.      "Kle 30.08.2004


        CONCATENATE 'Fehler bei Tarifart-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_taart-bukrs
                  ikey_taart-bukrs_art
                  ikey_taart-taart_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
     ENDIF.                            "Kle 30.08.2004
    ENDIF.
  ENDLOOP.

* Gerätewechsel-Grund
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_wechs IS INITIAL.
    SELECT * INTO TABLE iums_wechs
             FROM /adesso/mtu_wech.
    filled_wechs = 'X'.
  ENDIF.

  LOOP AT inm_di_ger WHERE gerwechs NE space.
*   Schlüssel füllen
    CLEAR ikey_wechs.
    ikey_wechs-mandt = sy-mandt.
    ikey_wechs-bukrs = bukrs_v.
    ikey_wechs-gerwechs_alt = inm_di_ger-gerwechs.

*   Umschlüsselung
    READ TABLE iums_wechs WITH KEY ikey_wechs BINARY SEARCH.
    IF sy-subrc = 0.
      inm_di_ger-gerwechs = iums_wechs-gerwechs_neu.
      MODIFY inm_di_ger.
    ELSE.
      CONCATENATE 'Fehler bei Wechselgrund-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_wechs-bukrs
                  ikey_wechs-gerwechs_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDLOOP.


* bei diesen Vorgängen wird der Wechsel fest auf 90 gesetzt
* Notlösung wegen falscher Customizing-Einstellung
   READ TABLE inm_di_int INDEX 1.
   CHECK inm_di_int-action = '01'. " or
*         inm_di_int-action = '02' or
*         inm_di_int-action = '03'.
   LOOP AT inm_di_ger.
     inm_di_ger-gerwechs = '90'.
     MODIFY inm_di_ger.
   ENDLOOP.

* Die Vorgänge '02' und '03' dürfen nicht auf '90'
* gesetzt werden, da sonst der Beglaubigungsstatus
* gelöscht wird.
*!!!!!!!!
* Falls es bei der Migration Probleme mit der Umschlüsselung gibt,
* dann bei '02' und '03' den Vorgangsgrund auf '99' setzen.
* !!!!!!!
** !!! dann Dekommentieren !!!!!!!
*   check inm_di_int-action = '02' or
*         inm_di_int-action = '03'.
*   loop at inm_di_ger.
*     inm_di_ger-gerwechs = '99'.
*     modify inm_di_ger.
*   endloop.



* Kennziffer ermitteln
*-----------------------------------------------------------------------
  READ TABLE inm_di_int INDEX 1.
   CHECK inm_di_int-action = '01' OR
         inm_di_int-action = '04'.

   LOOP AT inm_di_zw.
     SELECT SINGLE * FROM egerh  WHERE equnr = itemksv-newkey.

        SELECT SINGLE kennziff FROM ezwg INTO inm_di_zw-kennziffe
                                  WHERE zwgruppe = egerh-zwgruppe
                                    AND zwnummer = inm_di_zw-zwnummere.
     MODIFY inm_di_zw.
   ENDLOOP.




ENDFUNCTION.
