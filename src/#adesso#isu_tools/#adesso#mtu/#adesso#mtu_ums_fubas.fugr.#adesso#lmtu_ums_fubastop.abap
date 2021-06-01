FUNCTION-POOL /adesso/mtu_ums_fubas.        "MESSAGE-ID ..


TABLES: egerh,
        ezwg.

* Globale Daten
* Buchungskreis an der Stelle muss pro Lauf (und Werk) angepasst werden
* bis andere Lösung für die Umschlüsselungstabellen gefunden wird
DATA: bukrs_v TYPE bukrs VALUE '1000',        "Herne-Vertrieb
      bukrs_n TYPE bukrs VALUE '1001'.        "Herne-Netznutzung

DATA: itemksv TYPE TABLE OF temksv WITH HEADER LINE.

* Daten für die Kumulierung der EABPS
DATA: BEGIN OF wa_key_old,
        vtref LIKE sfkkop-vtref,
        tvorg LIKE sfkkop-tvorg,
        mwskz LIKE sfkkop-mwskz,
        faedn LIKE sfkkop-faedn,
        grbbp LIKE sfkkop-grbbp,
      END OF wa_key_old.
DATA: wa_key_new LIKE wa_key_old.
DATA: ibpm_eabps2 TYPE sfkkop OCCURS 0 WITH HEADER LINE.


* Umschlüsselung-Tabellen mit Datenumfeld

* Tariftyp
DATA: filled_tatyp   TYPE c.
DATA: iums_tatyp     TYPE TABLE OF /adesso/mtu_tatyp WITH HEADER LINE.
DATA: BEGIN OF ikey_tatyp,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        bukrs_art    TYPE /adesso/mtu_tatyp-bukrs_art,
        tatyp_alt    TYPE tariftyp,
        spebene      TYPE spebene,
      END OF ikey_tatyp.

* Mehrwertsteuerkennzeichen
DATA: filled_mwst   TYPE c.
DATA: iums_mwst     TYPE TABLE OF /adesso/mtu_mwst WITH HEADER LINE.
DATA: BEGIN OF ikey_mwst,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        sparte       TYPE spart,
        mwskz_alt    TYPE mwskz,
      END OF ikey_mwst.

* Konzessionsvertrag
DATA: filled_konzv   TYPE c.
DATA: iums_konzv     TYPE TABLE OF /adesso/mtu_konz WITH HEADER LINE.
DATA: BEGIN OF ikey_konzv,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        sparte       TYPE sparte,
      END OF ikey_konzv.

* Verbrauchsstellen-Art
DATA: filled_vbart   TYPE c.
DATA: iums_vbart     TYPE TABLE OF /adesso/mtu_vbar WITH HEADER LINE.
DATA: BEGIN OF ikey_vbart,
        mandt        TYPE mandt,
        vbsart_alt    TYPE vbsart,
      END OF ikey_vbart.

* Service-Art
DATA: filled_serv   TYPE c.
DATA: iums_serv     TYPE TABLE OF /adesso/mtu_serv WITH HEADER LINE.
DATA: BEGIN OF ikey_serv,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        bukrs_art    TYPE /adesso/mtu_bukrs_art,
        service_alt  TYPE sercode,
        sparte       TYPE sparte,
      END OF ikey_serv.

* Ableseeinheit
DATA: filled_ableh  TYPE c.
DATA: iums_ableh    TYPE TABLE OF /adesso/mtu_abeh WITH HEADER LINE.
DATA: BEGIN OF ikey_ableh,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        ableh_alt    TYPE ableinheit,
      END OF ikey_ableh.

* Anrede
DATA: filled_anred   TYPE c.
DATA: iums_anred     TYPE TABLE OF /adesso/mtu_anrd WITH HEADER LINE.
DATA: BEGIN OF ikey_anred,
        mandt        TYPE mandt,
        anrede_alt   TYPE ad_title,
      END OF ikey_anred.

* Buchungskreis
DATA: filled_bukrs   TYPE c.
DATA: iums_bukrs     TYPE TABLE OF /adesso/mtu_bukr WITH HEADER LINE.
DATA: BEGIN OF ikey_bukrs,
        mandt        TYPE mandt,
        bukrs_alt    TYPE bukrs,
        bukrs_art    TYPE /adesso/mtu_bukrs_art,
      END OF ikey_bukrs.

* Verrechnungstyp
DATA: filled_verty   TYPE c.
DATA: iums_verty     TYPE TABLE OF /adesso/mtu_vrty WITH HEADER LINE.
DATA: BEGIN OF ikey_verty,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        vertyp_alt   TYPE vertyp_kk,
      END OF ikey_verty.

* Kontenfindungsmerkmal
DATA: filled_kofi    TYPE c.
DATA: iums_kofi      TYPE TABLE OF /adesso/mtu_kofi WITH HEADER LINE.
DATA: BEGIN OF ikey_kofi,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        kofi_alt     TYPE e_kofiz_sd,
      END OF ikey_kofi.

* Mahnverfahren
DATA: filled_mahnv   TYPE c.
DATA: iums_mahnv     TYPE TABLE OF /adesso/mtu_mhnv WITH HEADER LINE.
DATA: BEGIN OF ikey_mahnv,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        mahnv_alt    TYPE mahnv_kk,
      END OF ikey_mahnv.

* Operanden
DATA: filled_oper    TYPE c.
DATA: iums_oper      TYPE TABLE OF /adesso/mtu_oper WITH HEADER LINE.
DATA: BEGIN OF ikey_oper,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        bukrs_art    TYPE /adesso/mtu_bukrs_art,
        oper_alt     TYPE e_operand,
      END OF ikey_oper.

* Preisschlüssel
DATA: filled_prkey   TYPE c.
DATA: iums_prkey     TYPE TABLE OF /adesso/mtu_pkey WITH HEADER LINE.
DATA: BEGIN OF ikey_prkey,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        bukrs_art    TYPE /adesso/mtu_bukrs_art,
        price_alt    TYPE e_preis,
      END OF ikey_prkey.

* Preisklasse
DATA: filled_prskl   TYPE c.
DATA: iums_prskl     TYPE TABLE OF /adesso/mtu_prkl WITH HEADER LINE.
DATA: BEGIN OF ikey_prskl,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        prskl_alt    TYPE preiskla,
      END OF ikey_prskl.

* Gerätetypen
DATA: filled_gertyp  TYPE c.
DATA: igertyp        TYPE TABLE OF etyp WITH HEADER LINE.
DATA: BEGIN OF ikey_gertyp,
        mandt        TYPE sy-mandt,
        matnr        TYPE matnr,
      END OF ikey_gertyp.

* Tarifart
DATA: filled_taart   TYPE c.
DATA: iums_taart     TYPE TABLE OF /adesso/mtu_tart WITH HEADER LINE.
DATA: BEGIN OF ikey_taart,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        bukrs_art    TYPE /adesso/mtu_bukrs_art,
        taart_alt    TYPE tarifart,
      END OF ikey_taart.

* Standort-Devloc
DATA: filled_stort   TYPE c.
DATA: iums_stort     TYPE TABLE OF /adesso/mtu_stor WITH HEADER LINE.
DATA: BEGIN OF ikey_stort,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        stort_alt    TYPE pmloc,
      END OF ikey_stort.

* Hersteller
DATA: filled_herst   TYPE c.
DATA: iums_herst     TYPE TABLE OF /adesso/mtu_hers WITH HEADER LINE.
DATA: BEGIN OF ikey_herst,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        herst_alt    TYPE herst,
      END OF ikey_herst.

* Material-Nummer
DATA: filled_mat     TYPE c.
DATA: iums_mat       TYPE TABLE OF /adesso/mtu_mat WITH HEADER LINE.
DATA: BEGIN OF ikey_mat,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        matnr_alt    TYPE matnr,
        mattyp       TYPE typbz,
      END OF ikey_mat.

* Zählwerksgruppe
DATA: filled_zaehw   TYPE c.
DATA: iums_zaehw     TYPE TABLE OF /adesso/mtu_zw WITH HEADER LINE.
DATA: BEGIN OF ikey_zaehw,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        zwgrp_alt    TYPE e_zwgruppe,
        zwnr_alt     TYPE e_zwnummer,
        matnr_neu    TYPE matnr,
      END OF ikey_zaehw.

* Ein-/Ausgangs-Gruppe
DATA: filled_eagrp   TYPE c.
DATA: iums_eagrp     TYPE TABLE OF /adesso/mtu_eagr WITH HEADER LINE.
DATA: BEGIN OF ikey_eagrp,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        eagrp_alt    TYPE eagruppe,
      END OF ikey_eagrp.

* Lagerort
DATA: filled_lgort   TYPE c.
DATA: iums_lgort     TYPE TABLE OF /adesso/mtu_lgor WITH HEADER LINE.
DATA: BEGIN OF ikey_lgort,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        lgort_alt    TYPE lgort_d,
      END OF ikey_lgort.

* Wechselgrund
DATA: filled_wechs   TYPE c.
DATA: iums_wechs     TYPE TABLE OF /adesso/mtu_wech WITH HEADER LINE.
DATA: BEGIN OF ikey_wechs,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        gerwechs_alt TYPE gerwechs,
      END OF ikey_wechs.

* Los
DATA: filled_los     TYPE c.
DATA: iums_los       TYPE TABLE OF /adesso/mtu_los WITH HEADER LINE.
DATA: BEGIN OF ikey_los,
        mandt        TYPE mandt,
        bukrs        TYPE bukrs,
        los_alt      TYPE los,
      END OF ikey_los.

* Hauptvorgänge
DATA: filled_hv     TYPE c.
DATA: iums_hv       TYPE TABLE OF /adesso/mtu_hvtv WITH HEADER LINE.


* Kontakte
DATA: filled_kt     TYPE c.
DATA: iums_kt       TYPE TABLE OF /adesso/mtu_ktkt WITH HEADER LINE.
