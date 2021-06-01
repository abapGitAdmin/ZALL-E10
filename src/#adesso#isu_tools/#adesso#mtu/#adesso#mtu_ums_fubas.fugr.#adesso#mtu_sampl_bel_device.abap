FUNCTION /adesso/mtu_sampl_bel_device.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"      I_EQUI STRUCTURE  V_EQUI OPTIONAL
*"      I_EGERS STRUCTURE  EGERS OPTIONAL
*"      I_EGERH STRUCTURE  EGERH OPTIONAL
*"      I_CLHEAD STRUCTURE  EMG_CLSHEAD OPTIONAL
*"      I_CLDATA STRUCTURE  API_AUSP
*"  CHANGING
*"     REFERENCE(OLDKEY_DEV) TYPE  EMG_OLDKEY
*"----------------------------------------------------------------------
* PM-Werk und MM-Werk
  READ TABLE i_equi INDEX 1.
  i_equi-swerk = '1001'.
  i_equi-werk = '1001'.
  MODIFY i_equi INDEX 1.

* Lagerort
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_lgort IS INITIAL.
    SELECT * INTO TABLE iums_lgort
             FROM /adesso/mtu_lgor.
    filled_lgort = 'X'.
    SORT iums_lgort.
  ENDIF.

  READ TABLE i_equi INDEX 1.
* Schlüssel füllen
  CLEAR ikey_lgort.
  ikey_lgort-mandt = sy-mandt.
  ikey_lgort-bukrs = bukrs_v.
  ikey_lgort-lgort_alt = i_equi-lager.

* Umschlüsselung
  READ TABLE iums_lgort WITH KEY ikey_lgort BINARY SEARCH.
  IF sy-subrc = 0.
    i_equi-lager = iums_lgort-lgort_neu.
    MODIFY i_equi INDEX 1.
  ELSE.
    CONCATENATE 'Fehler bei Lager-Ort-Umschlüsselung,'
                '(Umschl-Key:'
                ikey_lgort-bukrs
                ikey_lgort-lgort_alt ')'
                INTO meldung-meldung SEPARATED BY space.
    APPEND meldung.
  ENDIF.

* Ergänzende Regeln
  READ TABLE i_egers INDEX 1.
  IF i_equi-lager = 'NETZ' AND
     i_equi-tplnr IS INITIAL.
    IF i_egers-bglstat = '2' OR
       i_egers-bglstat = '3'.
       i_equi-lager = 'UNBG'.
    ELSEIF i_egers-bglstat = '1' OR
           i_egers-bglstat IS INITIAL.
       i_equi-lager = 'BEGL'.
    ENDIF.
  ENDIF.


* Material-Nummer
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_mat IS INITIAL.
    SELECT * INTO TABLE iums_mat
             FROM /adesso/mtu_mat.
    filled_mat = 'X'.
    SORT iums_mat.
  ENDIF.

  READ TABLE i_equi INDEX 1.
* Schlüssel füllen
  CLEAR ikey_mat.
  ikey_mat-mandt = sy-mandt.
  ikey_mat-bukrs = bukrs_v.
  ikey_mat-matnr_alt = i_equi-matnr.
  ikey_mat-mattyp = i_equi-typbz.

* Umschlüsselung
  READ TABLE iums_mat WITH KEY ikey_mat BINARY SEARCH.
  IF sy-subrc = 0.
    i_equi-matnr = iums_mat-matnr_neu.
*   wegen Konvertierungsroutine darf die Mat-Nr nicht 10-Stellig sein
    SHIFT i_equi-matnr BY 10 PLACES.
    MODIFY i_equi INDEX 1.
  ELSE.
*   Für die meisten Geräte läuft die Umschlüsselung nicht mit Hilfe
*   von Herst.Bezeichnung
    CLEAR ikey_mat-mattyp.
    READ TABLE iums_mat WITH KEY ikey_mat BINARY SEARCH.
    IF sy-subrc = 0.
      i_equi-matnr = iums_mat-matnr_neu.
      SHIFT i_equi-matnr BY 10 PLACES.
      MODIFY i_equi INDEX 1.
    ELSE.
      SHIFT i_equi-matnr BY 10 PLACES.
      MODIFY i_equi INDEX 1.
      CONCATENATE 'Fehler bei Material-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_mat-bukrs
                  ikey_mat-matnr_alt
                  ikey_mat-mattyp ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDIF.

* Zählwerksgruppe
* Hinweis ! Wegen Nutzung von MatNr-Neu ander Stelle darf diese Coding
*           nicht vor materialumschlüsselung stehen
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_zaehw IS INITIAL.
    SELECT * INTO TABLE iums_zaehw
             FROM /adesso/mtu_zw.
    filled_zaehw = 'X'.
    SORT iums_zaehw.
  ENDIF.

  READ TABLE i_egerh INDEX 1.
* Schlüssel füllen
  CLEAR ikey_zaehw.
  ikey_zaehw-mandt = sy-mandt.
  ikey_zaehw-bukrs = bukrs_v.
  ikey_zaehw-zwgrp_alt = i_egerh-zwgruppe.
  ikey_zaehw-matnr_neu = i_equi-matnr.
* führende Nulle einführen
  SHIFT ikey_zaehw-matnr_neu RIGHT BY 10 PLACES.
  TRANSLATE ikey_zaehw-matnr_neu USING ' 0'.

* Umschlüsselung
  READ TABLE iums_zaehw WITH KEY ikey_zaehw BINARY SEARCH.
  IF sy-subrc = 0.
    i_egerh-zwgruppe = iums_zaehw-zwgrp_neu.
    MODIFY i_egerh INDEX 1.
  ELSE.
    CLEAR ikey_zaehw-matnr_neu.
    READ TABLE iums_zaehw WITH KEY ikey_zaehw BINARY SEARCH.
    IF sy-subrc = 0.
      i_egerh-zwgruppe = iums_zaehw-zwgrp_neu.
      MODIFY i_egerh INDEX 1.
    ELSE.
*    CONCATENATE 'Fehler bei ZW-Gruppe-Umschlüsselung,'
*                '(Umschl-Key:'
*                ikey_zaehw-bukrs
*                ikey_zaehw-zwgrp_alt ')'
*                INTO meldung-meldung SEPARATED BY space.
*    APPEND meldung.
    ENDIF.
  ENDIF.

* Ein-/Ausgangs-Gruppe
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_eagrp IS INITIAL.
    SELECT * INTO TABLE iums_eagrp
             FROM /adesso/mtu_eagr.
    filled_eagrp = 'X'.
    SORT iums_eagrp.
  ENDIF.

  READ TABLE i_egers INDEX 1.
* Schlüssel füllen
  CLEAR ikey_eagrp.
  ikey_eagrp-mandt = sy-mandt.
  ikey_eagrp-bukrs = bukrs_v.
  ikey_eagrp-eagrp_alt = i_egers-eagruppe.

* Umschlüsselung
  READ TABLE iums_eagrp WITH KEY ikey_eagrp BINARY SEARCH.
  IF sy-subrc = 0.
    i_egers-eagruppe = iums_eagrp-eagrp_neu.
    MODIFY i_egers INDEX 1.
  ELSE.
*    CONCATENATE 'Fehler bei E-/Aus-Gruppe-Umschlüsselung,'
*                '(Umschl-Key:'
*                ikey_eagrp-bukrs
*                ikey_eagrp-eagrp_alt ')'
*                INTO meldung-meldung SEPARATED BY space.
*    APPEND meldung.
  ENDIF.


* Hersteller
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_herst IS INITIAL.
    SELECT * INTO TABLE iums_herst
             FROM /adesso/mtu_hers.
    filled_herst = 'X'.
    SORT iums_herst.
  ENDIF.

  READ TABLE i_equi INDEX 1.
* Schlüssel füllen
  CLEAR ikey_herst.
  ikey_herst-mandt = sy-mandt.
  ikey_herst-bukrs = bukrs_v.
  ikey_herst-herst_alt = i_equi-herst.

* Umschlüsselung
  READ TABLE iums_herst WITH KEY ikey_herst BINARY SEARCH.
  IF sy-subrc = 0.
    i_equi-herst = iums_herst-herst_neu.
    MODIFY i_equi INDEX 1.
  ELSE.
*    CONCATENATE 'Fehler bei Hersteller-Umschlüsselung,'
*                '(Umschl-Key:'
*                ikey_herst-bukrs
*                ikey_herst-herst_alt ')'
*                INTO meldung-meldung SEPARATED BY space.
*    APPEND meldung.
  ENDIF.

* Los
*-----------------------------------------------------------------------
* Tabelle einlesen
  IF filled_los IS INITIAL.
    SELECT * INTO TABLE iums_los
             FROM /adesso/mtu_los.
    filled_los = 'X'.
    SORT iums_los.
  ENDIF.

  READ TABLE i_egers INDEX 1.
  IF NOT i_egers-los IS INITIAL.
*   Schlüssel füllen
    CLEAR ikey_los.
    ikey_los-mandt = sy-mandt.
    ikey_los-bukrs = bukrs_v.
    ikey_los-los_alt = i_egers-los.

*   Umschlüsselung
    READ TABLE iums_los WITH KEY ikey_los BINARY SEARCH.
    IF sy-subrc = 0.
      i_egers-los = iums_los-los_neu.
      MODIFY i_egers INDEX 1.
    ELSE.
      CLEAR i_egers-los.
      MODIFY i_egers INDEX 1.
      CONCATENATE 'Fehler bei Los-Umschlüsselung,'
                  '(Umschl-Key:'
                  ikey_los-bukrs
                  ikey_los-los_alt ')'
                  INTO meldung-meldung SEPARATED BY space.
      APPEND meldung.
    ENDIF.
  ENDIF.




ENDFUNCTION.
