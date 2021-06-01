FUNCTION /adesso/mtu_sampl_bel_account.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IACC_INIT STRUCTURE  FKKVK_HDR_DI OPTIONAL
*"      IACC_VK STRUCTURE  FKKVK_S_DI OPTIONAL
*"      IACC_VKP STRUCTURE  FKKVKP_S_DI OPTIONAL
*"      IACC_VKLOCK STRUCTURE  FKKVKLOCK_S_DI OPTIONAL
*"      IACC_VKCORR STRUCTURE  FKKVK_CORR_S_DI OPTIONAL
*"      IACC_VKTXEX STRUCTURE  FKKVK_TAXEX_S_DI OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_ACC) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------

* Bezeichnung setzen wenn nicht gepflegt!
  READ TABLE iacc_vk INDEX 1.
  IF sy-subrc <> 0.
    iacc_vk-vkbez = space.
    APPEND iacc_vk.
  ENDIF.

* Aussteuerungsprüfgruppe und Formular umschlüsseln.
  READ TABLE iacc_vkp INDEX 1.
  IF iacc_vkp-formkey = 'ZDUA_RECHNUNG_SAM'.
    iacc_vkp-formkey = 'ZDUA_SAMMELRECH'.
  ELSE.
    iacc_vkp-formkey = 'ZDUA_RECHNUNG_TK'.
  ENDIF.
  IF iacc_vkp-ausgrup_in = '001'.
    iacc_vkp-ausgrup_in = 'A002'.
  ELSE.
    iacc_vkp-ausgrup_in = 'A003'.
  ENDIF.
  MODIFY iacc_vkp INDEX 1.

* Ausgangszahlweg umsetzen
  READ TABLE iacc_vkp INDEX 1.
  IF iacc_vkp-azawe = 'Z'.
    CLEAR iacc_vkp-azawe.
    MODIFY iacc_vkp INDEX 1.
  ELSEIF iacc_vkp-azawe IS INITIAL.
    iacc_vkp-azawe = 'V'.
    MODIFY iacc_vkp INDEX 1.
  ENDIF.

* Mahnsperrgrund setzen
  READ TABLE iacc_vkp INDEX 1.
  IF iacc_vkp-mansp = 'G'.
    iacc_vkp-mansp = 'V'.
    MODIFY iacc_vkp INDEX 1.
  ENDIF.

  LOOP AT iacc_vklock WHERE proid_key = '01'
                      AND   lotyp_key = '06'.
    IF iacc_vklock-lockr_key = 'G'.
      iacc_vklock-lockr_key = 'V'.
      MODIFY iacc_vklock.
    ENDIF.
  ENDLOOP.

* Verrechnugstyp
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_verty IS INITIAL.
    SELECT * INTO TABLE iums_verty
             FROM /adesso/mtu_vrty.
    filled_verty = 'X'.
    SORT iums_verty.
  ENDIF.

  READ TABLE iacc_vkp INDEX 1.
* Schlüssel füllen
  CLEAR ikey_verty.
  ikey_verty-mandt = sy-mandt.
  ikey_verty-bukrs = iacc_vkp-opbuk.
  ikey_verty-vertyp_alt = iacc_vkp-vertyp.

* Umschlüsselung
  READ TABLE iums_verty WITH KEY ikey_verty BINARY SEARCH.
  IF sy-subrc = 0.
    iacc_vkp-vertyp = iums_verty-vertyp_neu.
    MODIFY iacc_vkp INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Verrech.Typ-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_verty-bukrs
                ikey_verty-vertyp_alt ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.

* Kontenfindungsmerkmal
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_kofi IS INITIAL.
    SELECT * INTO TABLE iums_kofi
             FROM /adesso/mtu_kofi.
    filled_kofi = 'X'.
    SORT iums_kofi.
  ENDIF.

  READ TABLE iacc_vkp INDEX 1.
  READ TABLE iacc_init INDEX 1.
* erst sonderbehandlung für Vertragskonten mit Ziel-kofiz 6
  SELECT SINGLE kofiz FROM /adesso/mtu_vkkf
                           INTO iums_kofi-kofi_neu
                           WHERE vkont = iacc_init-vkont.
  IF sy-subrc = 0.
    iacc_vkp-kofiz_sd = iums_kofi-kofi_neu.
    MODIFY iacc_vkp INDEX 1.
  ELSE.
* Schlüssel füllen
    CLEAR ikey_kofi.
    ikey_kofi-mandt = sy-mandt.
    ikey_kofi-bukrs = iacc_vkp-opbuk.
    ikey_kofi-kofi_alt = iacc_vkp-kofiz_sd.

* Umschlüsselung
    READ TABLE iums_kofi WITH KEY ikey_kofi BINARY SEARCH.
    IF sy-subrc = 0.
      iacc_vkp-kofiz_sd = iums_kofi-kofi_neu.
      MODIFY iacc_vkp INDEX 1.
    ELSE.
* Für Kofiz 01 keine Fehlermeldung mehr ausgeben
      IF iacc_vkp-kofiz_sd <> '01'.
        CONCATENATE 'Fehler bei KoFiz-Umschlüsselung,'
                    '(Umschl-Key:'
                    ikey_kofi-bukrs
                    ikey_kofi-kofi_alt ')'
                    INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
      ENDIF.
    ENDIF.
  ENDIF.
* Mahnverfahren
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_mahnv IS INITIAL.
    SELECT * INTO TABLE iums_mahnv
             FROM /adesso/mtu_mhnv.
    filled_mahnv = 'X'.
    SORT iums_mahnv.
  ENDIF.

  READ TABLE iacc_vkp INDEX 1.
* Schlüssel füllen
  CLEAR ikey_mahnv.
  ikey_mahnv-mandt = sy-mandt.
  ikey_mahnv-bukrs = iacc_vkp-opbuk.
  ikey_mahnv-mahnv_alt = iacc_vkp-mahnv.

* Umschlüsselung
  READ TABLE iums_mahnv WITH KEY ikey_mahnv BINARY SEARCH.
  IF sy-subrc = 0.
    iacc_vkp-mahnv = iums_mahnv-mahnv_neu.
    MODIFY iacc_vkp INDEX 1.
  ELSE.
* Keine Meldung mehr für Mahnverfahren 01
    IF iacc_vkp-mahnv <> '01'.
      CONCATENATE 'Fehler bei MahnVerfahr.-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_mahnv-bukrs
                  ikey_mahnv-mahnv_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDIF.

ENDFUNCTION.
