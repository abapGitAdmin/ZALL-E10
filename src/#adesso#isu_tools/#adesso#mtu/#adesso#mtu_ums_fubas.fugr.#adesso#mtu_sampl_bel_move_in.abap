FUNCTION /ADESSO/MTU_SAMPL_BEL_MOVE_IN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      IMOI_EVER STRUCTURE  EVERD OPTIONAL
*"  CHANGING
*"     REFERENCE(OLDKEY_MOI) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------
* Buchungskreis
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_bukrs IS INITIAL.
    SELECT * INTO TABLE iums_bukrs
             FROM /adesso/mtu_bukr.
    filled_bukrs = 'X'.
    SORT iums_bukrs.
  ENDIF.

  READ TABLE imoi_ever INDEX 1.
* Schlüssel füllen
  CLEAR ikey_bukrs.
  ikey_bukrs-mandt = sy-mandt.
  ikey_bukrs-bukrs_alt = imoi_ever-bukrs.
  ikey_bukrs-bukrs_art = oldkey_moi+10(1).

* Umschlüsselung
  READ TABLE iums_bukrs WITH KEY ikey_bukrs BINARY SEARCH.
  IF sy-subrc = 0.
    imoi_ever-bukrs = iums_bukrs-bukrs_neu.
    MODIFY imoi_ever INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Buch.Kreis-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_bukrs-bukrs_alt
                ikey_bukrs-bukrs_art ')'
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

  READ TABLE imoi_ever INDEX 1.
  SELECT SINGLE kofiz FROM /adesso/mtu_vkkf
                      INTO iums_kofi-kofi_neu
                      WHERE vkont = imoi_ever-vkonto.
  IF sy-subrc = 0.
    imoi_ever-kofiz = iums_kofi-kofi_neu.
    MODIFY imoi_ever INDEX 1.
  ELSE.
* Schlüssel füllen
    CLEAR ikey_kofi.
    ikey_kofi-mandt = sy-mandt.
    ikey_kofi-bukrs = imoi_ever-bukrs.
    ikey_kofi-kofi_alt = imoi_ever-kofiz.

* Umschlüsselung
    READ TABLE iums_kofi WITH KEY ikey_kofi BINARY SEARCH.
    IF sy-subrc = 0.
      imoi_ever-kofiz = iums_kofi-kofi_neu.
      MODIFY imoi_ever INDEX 1.
    ELSE.
      IF imoi_ever-kofiz <> '01'.
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

  READ TABLE imoi_ever INDEX 1.
* Schlüssel füllen
  CLEAR ikey_mahnv.
  ikey_mahnv-mandt = sy-mandt.
  ikey_mahnv-bukrs = imoi_ever-bukrs.
  ikey_mahnv-mahnv_alt = imoi_ever-mahnv.

* Umschlüsselung
  READ TABLE iums_mahnv WITH KEY ikey_mahnv BINARY SEARCH.
  IF sy-subrc = 0.
    imoi_ever-mahnv = iums_mahnv-mahnv_neu.
    MODIFY imoi_ever INDEX 1.
  ELSE.
    IF NOT imoi_ever-mahnv IS INITIAL.
      IF imoi_ever-mahnv <> '01'.
        CONCATENATE 'Fehler bei MahnVerfahr.-Umschlüsselung,'
                    '(Umschl-Key:'
                    ikey_mahnv-bukrs
                    ikey_mahnv-mahnv_alt ')'
                    INTO meldung-meldung SEPARATED BY space.
        APPEND meldung.
      ENDIF.
    ENDIF.
  ENDIF.

* Mahnsperrgrund setzen
*-----------------------------------------------------------------------
  READ TABLE imoi_ever INDEX 1.
  IF imoi_ever-mansp = 'G'.
    imoi_ever-mansp = 'V'.
    MODIFY imoi_ever INDEX 1.
  ENDIF.

* Umsetzen Serviceanbieter im Vertrag
  READ TABLE imoi_ever INDEX 1.
*  IF NOT imoi_ever-serviceid IS INITIAL.
  CASE oldkey_moi+10(1).

    WHEN 'N'.
      CASE imoi_ever-sparte.
        WHEN '10'.
          imoi_ever-serviceid = '000291NETZ'.
          imoi_ever-invoicing_party = '000291NETZ'.
        WHEN '20'.
          imoi_ever-serviceid = '700162NETZ'.
          imoi_ever-invoicing_party = '700162NETZ'.
        WHEN '30'.
          IF imoi_ever-bukrs = '1001'.
            imoi_ever-serviceid = '10__30_NET'.
            imoi_ever-invoicing_party = '10__30_NET'.
          ELSEIF imoi_ever-bukrs = '1301'.
            imoi_ever-serviceid = '10_WVH_30N'.
            imoi_ever-invoicing_party = '10_WVH_30N'.
          ENDIF.
        WHEN '40'.
          IF imoi_ever-bukrs = '1001'.
            imoi_ever-serviceid = '10__40_NET'.
            imoi_ever-invoicing_party = '10__40_NET'.
          ELSEIF imoi_ever-bukrs = '1601'.
            imoi_ever-serviceid = '10_FWH_40N'.
            imoi_ever-invoicing_party = '10_FWH_40N'.
          ENDIF.
      ENDCASE.
    WHEN 'V'.
      CASE imoi_ever-sparte.
        WHEN '10'.
          imoi_ever-serviceid = '000291LIEF'.
          imoi_ever-invoicing_party = '000291LIEF'.
        WHEN '20'.
          imoi_ever-serviceid = '700162LIEF'.
          imoi_ever-invoicing_party = '700162LIEF'.
        WHEN '30'.
          IF imoi_ever-bukrs = '1000'.
            imoi_ever-serviceid = '10__30_LIE'.
            imoi_ever-invoicing_party = '10__30_LIE'.
          ELSEIF imoi_ever-bukrs = '1300'.
            imoi_ever-serviceid = '10_WVH_30L'.
            imoi_ever-invoicing_party = '10_WVH_30L'.
          ENDIF.
        WHEN '40'.
          IF imoi_ever-bukrs = '1000'.
            imoi_ever-serviceid = '10__40_LIE'.
            imoi_ever-invoicing_party = '10__40_LIENET'.
          ELSEIF imoi_ever-bukrs = '1600'.
            imoi_ever-serviceid = '10_FWH_40L'.
            imoi_ever-invoicing_party = '10_FWH_40L'.
          ENDIF.
      ENDCASE.
  ENDCASE.
* Aussteuerungsprüfgruppe umschlüsseln:
  CASE oldkey_moi+10(1).
    WHEN 'N'.
      imoi_ever-ausgrup = 'A004'.
    WHEN 'V'.
      IF imoi_ever-ausgrup = '001'.
        imoi_ever-ausgrup = 'A002'.
      ELSE.
        imoi_ever-ausgrup = 'A003'.
      ENDIF.
  ENDCASE.
  MODIFY imoi_ever INDEX 1.
*  ENDIF.

* CO-kontierung setzen.
  READ TABLE imoi_ever INDEX 1.
  IF imoi_ever-sparte = '30' AND imoi_ever-kofiz = '01'.
    CASE imoi_ever-bukrs.
      WHEN '1000'.
        imoi_ever-cokey = '910V6300'.
      WHEN '1001'.
        imoi_ever-cokey = '910N3000'.
    ENDCASE.
    MODIFY imoi_ever INDEX 1.
  ELSE.
    CLEAR imoi_ever-cokey.
    MODIFY imoi_ever INDEX 1.
  ENDIF.
ENDFUNCTION.
