FUNCTION /adesso/mte_ent_partner.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FIRMA) TYPE  EMG_FIRMA
*"     REFERENCE(X_PARTNER) LIKE  BUT000-PARTNER
*"     REFERENCE(PFAD_DAT_ENT) TYPE  EMG_PFAD
*"  EXPORTING
*"     REFERENCE(ANZ_OBJ) TYPE  I
*"     REFERENCE(ANZ_INIT) TYPE  I
*"     REFERENCE(ANZ_EKUN) TYPE  I
*"     REFERENCE(ANZ_BUT000) TYPE  I
*"     REFERENCE(ANZ_BUTICOM) TYPE  I
*"     REFERENCE(ANZ_BUT001) TYPE  I
*"     REFERENCE(ANZ_BUT0BK) TYPE  I
*"     REFERENCE(ANZ_BUT020) TYPE  I
*"     REFERENCE(ANZ_BUT021) TYPE  I
*"     REFERENCE(ANZ_BUT0CC) TYPE  I
*"     REFERENCE(ANZ_SHIPTO) TYPE  I
*"     REFERENCE(ANZ_TAXNUM) TYPE  I
*"     REFERENCE(ANZ_ECCARD) TYPE  I
*"     REFERENCE(ANZ_ECCARDH) TYPE  I
*"     REFERENCE(ANZ_BUT0IS) TYPE  I
*"  TABLES
*"      MELDUNG STRUCTURE  /ADESSO/MT_MESSAGES OPTIONAL
*"  EXCEPTIONS
*"      NO_OPEN
*"      NO_CLOSE
*"      WRONG_DATA
*"      NO_DATA
*"      ERROR
*"----------------------------------------------------------------------
  DATA  object          TYPE  emg_object.
  DATA  ent_file        TYPE  emg_pfad.
  DATA: ums_fuba        TYPE  funcname.
  DATA: o_key           TYPE  emg_oldkey.

  DATA: h_lines         TYPE i.
  DATA: help_date       TYPE sy-datum.

* --> Nuss 17.09.2015
  DATA: wa_fkkvkp TYPE fkkvkp,
        it_fkkvkp TYPE STANDARD TABLE OF fkkvkp,
        wa_rel    TYPE /adesso/mte_rel,
        bank_ok(1)   TYPE c.
* <-- Nuss 17.09.2015

* --> Nuss 02.11.2015
  DATA: help_date_from LIKE sy-datum,
        help_date_to LIKE sy-datum.
* <-- Nuss 02.11.2015

  CONSTANTS: tz TYPE tzonref-tzone VALUE 'CET'.

  object     = 'PARTNER'.
  ent_file   = pfad_dat_ent.
  oldkey_par = x_partner.

* Ermitteln des Umschlüsselungs-Fubas
  CLEAR ums_fuba.
  SELECT SINGLE zfuba INTO ums_fuba
         FROM /adesso/mt_umsfu
              WHERE object = object
                AND firma  = firma
                AND zricht = 'ENT'.


*>   Initialisierung
  PERFORM init_par.
  CLEAR: ipar_out, wpar_out, meldung, anz_obj.
  REFRESH: ipar_out, meldung.
*<


*> Datenermittlung ---------
  SELECT * FROM but000 WHERE partner EQ oldkey_par.

* ipar_init
    CLEAR ekun.
    SELECT SINGLE * FROM ekun WHERE partner = but000-partner.
    SELECT SINGLE * FROM but100 WHERE partner = but000-partner.
    MOVE-CORRESPONDING ekun   TO ipar_init.
    MOVE-CORRESPONDING but000 TO ipar_init.
    ipar_init-bpext = but000-partner.             "Nuss 04.11.2014
    ipar_init-bu_type = but000-type.
    ipar_init-bu_rltyp = but100-rltyp.
    APPEND ipar_init.
    CLEAR ipar_init.

* ipar_ekun
    IF NOT ekun IS INITIAL.
      MOVE-CORRESPONDING ekun TO ipar_ekun.
      APPEND ipar_ekun.
      CLEAR ipar_ekun.
    ENDIF.

* ipar_but000
    MOVE-CORRESPONDING but000 TO ipar_but000.
    APPEND ipar_but000.
    CLEAR ipar_but000.

* ipar_but0bk
    SELECT * FROM but0bk WHERE partner = but000-partner.
      MOVE-CORRESPONDING but0bk TO ipar_but0bk.
**    --> Nuss 17.09.2015 Projekt DVV-WBD
**    Bankdaten nur übernehmen, wenn sie mit einem Vertragskonto verknüpft sind, die Abwasser haben
      CLEAR: wa_fkkvkp, it_fkkvkp, bank_ok.
*     Vertragskonten selektieren
      SELECT * FROM fkkvkp INTO TABLE it_fkkvkp
         WHERE ( gpart = but000-partner OR
                 abwre = but000-partner OR     "Nuss 01.10.2015
                 abwra = but000-partner ) "OR     "Nuss 01.10.2015
*                 abwma = but000-partner OR     "Nuss 01.10.2015
*                 abwrh = but000-partner OR     "Nuss 01.10.2015
*                 def_rec = but000-partner )    "Nuss 01.10.2015
          AND  ( abvty = ipar_but0bk-bkvid OR
                 ebvty = ipar_but0bk-bkvid ).
*      Ist ein Vertragskonto relevant ?
      LOOP AT it_fkkvkp INTO wa_fkkvkp.

        CLEAR wa_rel.
        SELECT SINGLE * FROM /adesso/mte_rel INTO wa_rel
          WHERE firma = firma
           AND object = 'ACCOUNT'
           AND obj_key = wa_fkkvkp-vkont.
        IF sy-subrc = 0.
          bank_ok = 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
**     Wenn Bankverbindung nicht übereinstimmt, Bankdaten nicht übernehmen
      IF bank_ok IS INITIAL.
        CLEAR ipar_but0bk.
        CONTINUE.
      ENDIF.
**   <-- Nuss 17.09.2015




**    Struktur wurde erweitert. Datümer aus BUT0BK in Struktur übertragen
**    Zeitstempel in Datum konvertieren
      CONVERT TIME STAMP but0bk-bk_valid_from TIME ZONE tz
        INTO DATE ipar_but0bk-bk_date_from.

      IF but0bk-bk_valid_to = '99991231235959'.
        MOVE '99991231' TO ipar_but0bk-bk_date_to.
      ELSE.
        CONVERT TIME STAMP but0bk-bk_valid_to TIME ZONE tz
         INTO DATE ipar_but0bk-bk_date_to.
      ENDIF.

***   --> Nuss 09.11.2015
***   WBD-Projekt
***   Wenn die Bank nicht mehr gültig ist, diese Bankverbindung
***   nicht übernehmen
      IF ipar_but0bk-bk_date_to IS NOT INITIAL.              "Nuss 12.11.2015
        IF ipar_but0bk-bk_date_to LT sy-datum.
          CLEAR ipar_but0bk.
          CONTINUE.
        ENDIF.
      ENDIF.                                      "Nuss 12.11.2015
****  <-- Nuss 09.11.2015

      CONVERT TIME STAMP but0bk-bk_move_date TIME ZONE tz
        INTO DATE ipar_but0bk-bk_move_date.
*     --> Nuss 31.08.2015
*     IBAN ermitteln
      SELECT SINGLE * FROM tiban WHERE
        banks = but0bk-banks AND
        bankl = but0bk-bankl AND
        bankn = but0bk-bankn AND
        bkont = but0bk-bkont.
      IF sy-subrc EQ 0.
        MOVE tiban-iban TO ipar_but0bk-iban.
      ENDIF.
*    <-- Nuss 31.08.2015


      APPEND ipar_but0bk.
      CLEAR ipar_but0bk.
    ENDSELECT.

* ipar_but020
    SELECT * FROM but020 WHERE partner = but000-partner.

* externe Adressnummer nicht manipulieren!
*       add 1 to ipar_but020-ADEXT_ADDR.
      MOVE but020-addrnumber TO ipar_but020-adext_addr.
      MOVE 'I' TO ipar_but020-chind_addr.


      SELECT SINGLE * FROM adrc WHERE addrnumber = but020-addrnumber.
      IF sy-subrc EQ 0.

*> ipar_SHIPTO ??
        MOVE-CORRESPONDING but020 TO ipar_shipto.
        MOVE-CORRESPONDING adrc   TO ipar_shipto.
        IF NOT but020-adext IS INITIAL.
          APPEND ipar_shipto.
          CLEAR  ipar_shipto.
        ENDIF.
* <

        MOVE-CORRESPONDING but020 TO ipar_but020.
        MOVE-CORRESPONDING adrc TO ipar_but020.

        SELECT SINGLE * FROM adrct
                        WHERE addrnumber = but020-addrnumber.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING adrct TO ipar_but020.
        ENDIF.

*     Konvertieren Zeitstempel bei Adressen in Datum
        CONVERT TIME STAMP but020-addr_valid_from  TIME ZONE tz
           INTO DATE ipar_but020-addr_date_from.

        IF but020-addr_valid_to = '99991231235959'.
          MOVE '99991231' TO ipar_but020-addr_date_to.
        ELSE.
          CONVERT TIME STAMP but020-addr_valid_to TIME ZONE tz
           INTO DATE ipar_but020-addr_date_to.
        ENDIF.

        CONVERT TIME STAMP but020-addr_move_date TIME ZONE tz
          INTO DATE ipar_but020-addr_move_date.

**   Adresse muss zum Tagesdatum gültig sein.
        IF ipar_but020-addr_date_to LT sy-datum OR
           ipar_but020-addr_date_from GT sy-datum.
          CLEAR ipar_but020.
          CONTINUE.
        ENDIF.


***     Kommunikationsdaten
        CLEAR: iadr2, iadr3, iadr4, iadr5, iadr6, iadr12, iadr13.
        REFRESH: iadr2, iadr3, iadr4, iadr5, iadr6, iadr12, iadr13.

***     Telefonnummern
        SELECT * FROM adr2 INTO TABLE iadr2
           WHERE addrnumber = but020-addrnumber.
***     Faxnummern
        SELECT * FROM adr3 INTO TABLE iadr3
           WHERE addrnumber = but020-addrnumber.
***     Teletext (TTX)
        SELECT * FROM adr4 INTO TABLE iadr4
           WHERE addrnumber = but020-addrnumber.
***     Telex (TLX)
        SELECT * FROM adr5 INTO TABLE iadr5
           WHERE addrnumber = but020-addrnumber.
***     E-Mail-Adressen
        SELECT * FROM adr6 INTO TABLE iadr6
           WHERE addrnumber = but020-addrnumber.
***     FTP und URL
        SELECT * FROM adr12 INTO TABLE iadr12
            WHERE addrnumber = but020-addrnumber.
***     Pager (SMS)
        SELECT * FROM adr13 INTO TABLE iadr13
            WHERE addrnumber = but020-addrnumber.


* Land aus der adrc nochmal übernehmen.
* könnte aus den untergeordneten Tabellen gecleart worden sein.
        ipar_but020-country = adrc-country.
      ELSE.
        meldung-meldung = 'keine Adressdaten gefunden'.
        APPEND meldung.
        RAISE wrong_data.
      ENDIF.
      APPEND ipar_but020.
      CLEAR ipar_but020.

***   -> Nuss 04.11.2015
*** Prüfen, ob die Kommunikationsdaten gültig sind
      CLEAR help_date.
*     Telefon
      LOOP AT iadr2.
*       Bis-Datum kleiner Tagesdatum, nivht mejr gültig, raus.
        IF iadr2-valid_to IS INITIAL.
          CONTINUE.
        ENDIF.
        help_date = iadr2-valid_to(8).
        IF help_date LT sy-datum.
          DELETE iadr2.
          CONTINUE.
        ENDIF.
*      AB-Datum
        CLEAR help_date.
        IF iadr2-valid_from IS NOT INITIAL.
          help_date = iadr2-valid_from(8).
          IF help_date GT sy-datum.
            help_date = sy-datum.
          ENDIF.
        ENDIF.
      ENDLOOP.
*     Fax
      CLEAR help_date.
      LOOP AT iadr3.
*       Bis-Datum kleiner Tagesdatum, nivht mejr gültig, raus.
        IF iadr3-valid_to IS INITIAL.
          CONTINUE.
        ENDIF.
        help_date = iadr3-valid_to(8).
        IF help_date LT sy-datum.
          DELETE iadr3.
          CONTINUE.
        ENDIF.
*      AB-Datum
        CLEAR help_date.
        IF iadr3-valid_from IS NOT INITIAL.
          help_date = iadr3-valid_from(8).
          IF help_date GT sy-datum.
            help_date = sy-datum.
          ENDIF.
        ENDIF.
      ENDLOOP.
*     E-Mail
      CLEAR help_date.
      LOOP AT iadr6.
*       Bis-Datum kleiner Tagesdatum, nivht mejr gültig, raus.
        IF iadr6-valid_to IS INITIAL.
          CONTINUE.
        ENDIF.
        help_date = iadr6-valid_to(8).
        IF help_date LT sy-datum.
          DELETE iadr6.
          CONTINUE.
        ENDIF.
*      AB-Datum
        CLEAR help_date.
        IF iadr6-valid_from IS NOT INITIAL.
          help_date = iadr6-valid_from(8).
          IF help_date GT sy-datum.
            help_date = sy-datum.
          ENDIF.
        ENDIF.
      ENDLOOP.
*     URL
*     Pager
      CLEAR help_date.
      LOOP AT iadr13.
*       Bis-Datum kleiner Tagesdatum, nivht mejr gültig, raus.
        IF iadr13-valid_to IS INITIAL.
          CONTINUE.
        ENDIF.
        help_date = iadr13-valid_to(8).
        IF help_date LT sy-datum.
          DELETE iadr13.
          CONTINUE.
        ENDIF.
*      AB-Datum
        CLEAR help_date.
        IF iadr13-valid_from IS NOT INITIAL.
          help_date = iadr13-valid_from(8).
          IF help_date GT sy-datum.
            help_date = sy-datum.
          ENDIF.
        ENDIF.
      ENDLOOP.

**    Kommunikationsdaten zur Adresse übertragen
**    Es kann mehrere Kommunikationsdaten je Adresse geben
***   Telefonnnummern
      DATA: ind LIKE sy-tabix.
      LOOP AT iadr2.
        ind = sy-tabix.

        IF ind = 1.
          READ TABLE ipar_but020 WITH KEY adext_addr = iadr2-addrnumber BINARY SEARCH.

          ipar_but020-chind_tel  = 'I'.
          ipar_but020-tel_consnr = iadr2-consnumber.
          ipar_but020-tel_cntry  = iadr2-country.
          ipar_but020-tel_number = iadr2-tel_number.
          ipar_but020-tel_extens = iadr2-tel_extens.
          ipar_but020-tel_deflt  = iadr2-flgdefault.
*         ipar_but020-tel_remark
          ipar_but020-tel_home   = iadr2-home_flag.
          ipar_but020-tel_mobile = iadr2-r3_user.
          ipar_but020-tel_receiv = iadr2-dft_receiv.
          ipar_but020-tel_valid_from = iadr2-valid_from.
          ipar_but020-tel_valid_to   = iadr2-valid_to.
          ipar_but020-tel_dont_use   = iadr2-flg_nouse.
          MODIFY ipar_but020 INDEX sy-tabix.
          CLEAR ipar_but020.
        ELSE.
          ipar_but020-adext_addr = but020-addrnumber.
          ipar_but020-chind_tel  = 'I'.
          ipar_but020-tel_consnr = iadr2-consnumber.
          ipar_but020-tel_cntry  = iadr2-country.
          ipar_but020-tel_number = iadr2-tel_number.
          ipar_but020-tel_extens = iadr2-tel_extens.
          ipar_but020-tel_deflt  = iadr2-flgdefault.
*         ipar_but020-tel_remark
          ipar_but020-tel_home   = iadr2-home_flag.
          ipar_but020-tel_mobile = iadr2-r3_user.
          ipar_but020-tel_receiv = iadr2-dft_receiv.
          ipar_but020-tel_valid_from = iadr2-valid_from.
          ipar_but020-tel_valid_to   = iadr2-valid_to.
          ipar_but020-tel_dont_use   = iadr2-flg_nouse.
          APPEND ipar_but020.
          CLEAR ipar_but020.
        ENDIF.
      ENDLOOP.
**    Faxnummern
      LOOP AT iadr3.
        ind = sy-tabix.
        IF ind = 1.
          READ TABLE ipar_but020 WITH KEY adext_addr = iadr3-addrnumber BINARY SEARCH.

          ipar_but020-chind_fax  = 'I'.
          ipar_but020-fax_consnr = iadr3-consnumber.
          ipar_but020-fax_cntry  = iadr3-country.
          ipar_but020-fax_number = iadr3-fax_number.
          ipar_but020-fax_extens = iadr3-fax_extens.
          ipar_but020-fax_deflt  = iadr3-flgdefault.
*          ipar_but020-fax_remark
          ipar_but020-fax_home   = iadr3-home_flag.
          ipar_but020-fax_valid_from = iadr3-valid_from.
          ipar_but020-fax_valid_to   = iadr3-valid_to.
          ipar_but020-fax_dont_use   = iadr3-flg_nouse.
          MODIFY ipar_but020 INDEX sy-tabix.
          CLEAR ipar_but020.
        ELSE.
          ipar_but020-adext_addr = but020-addrnumber.
          ipar_but020-chind_fax  = 'I'.
          ipar_but020-fax_consnr = iadr3-consnumber.
          ipar_but020-fax_cntry  = iadr3-country.
          ipar_but020-fax_number = iadr3-fax_number.
          ipar_but020-fax_extens = iadr3-fax_extens.
          ipar_but020-fax_deflt  = iadr3-flgdefault.
*          ipar_but020-fax_remark
          ipar_but020-fax_home   = iadr3-home_flag.
          ipar_but020-fax_valid_from = iadr3-valid_from.
          ipar_but020-fax_valid_to   = iadr3-valid_to.
          ipar_but020-fax_dont_use   = iadr3-flg_nouse.
          APPEND ipar_but020.
          CLEAR ipar_but020.
        ENDIF.
      ENDLOOP.
**    Teletext
**    Telex

**    E-Mail-Adressen
      LOOP AT iadr6.
        ind = sy-tabix.
        IF ind = 1.
          READ TABLE ipar_but020 WITH KEY adext_addr = iadr6-addrnumber BINARY SEARCH.
          ipar_but020-chind_smtp = 'I'.
          ipar_but020-smtp_consnr = iadr6-consnumber.
          ipar_but020-smtp_addr   = iadr6-smtp_addr.
          ipar_but020-smtp_deflt  = iadr6-flgdefault.
*          ipar_but020-smtp_remark
          ipar_but020-smtp_home   = iadr6-home_flag.
          ipar_but020-smtp_valid_from = iadr6-valid_from.
          ipar_but020-smtp_valid_to   = iadr6-valid_to.
          ipar_but020-smtp_dont_use   = iadr6-flg_nouse.
          MODIFY ipar_but020 INDEX sy-tabix.
          CLEAR ipar_but020.
        ELSE.
          ipar_but020-adext_addr  = but020-addrnumber.
          ipar_but020-chind_smtp = 'I'.
          ipar_but020-smtp_consnr = iadr6-consnumber.
          ipar_but020-smtp_addr   = iadr6-smtp_addr.
          ipar_but020-smtp_deflt  = iadr6-flgdefault.
*          ipar_but020-smtp_remark
          ipar_but020-smtp_home   = iadr6-home_flag.
          ipar_but020-smtp_valid_from = iadr6-valid_from.
          ipar_but020-smtp_valid_to   = iadr6-valid_to.
          ipar_but020-smtp_dont_use   = iadr6-flg_nouse.
          APPEND ipar_but020.
          CLEAR ipar_but020.
        ENDIF.
      ENDLOOP.

***   URL
      LOOP AT iadr12.
        ind = sy-tabix.
        IF ind = 1.
          READ TABLE ipar_but020 WITH KEY adext_addr = iadr12-addrnumber BINARY SEARCH.
          ipar_but020-chind_uri = 'I'.
          ipar_but020-uri_consnr = iadr12-consnumber.
          ipar_but020-uri_type   = iadr12-uri_type.
          ipar_but020-uri_screen = iadr12-uri_addr.
          ipar_but020-uri_deflt  = iadr12-flgdefault.
*          ipar_but020-uri_remark
          ipar_but020-uri_home   = iadr12-home_flag.
          ipar_but020-uri_dont_use   = iadr12-flg_nouse.
          MODIFY ipar_but020 INDEX sy-tabix.
          CLEAR ipar_but020.
        ELSE.
          ipar_but020-adext_addr  = but020-addrnumber.
          ipar_but020-chind_uri = 'I'.
          ipar_but020-uri_consnr = iadr12-consnumber.
          ipar_but020-uri_type   = iadr12-uri_type.
          ipar_but020-uri_screen = iadr12-uri_addr.
          ipar_but020-uri_deflt  = iadr12-flgdefault.
*          ipar_but020-uri_remark
          ipar_but020-uri_home   = iadr12-home_flag.
          ipar_but020-uri_dont_use   = iadr12-flg_nouse.
          APPEND ipar_but020.
          CLEAR ipar_but020.
        ENDIF.
      ENDLOOP.

*     Pager
      LOOP AT iadr13.
        ind = sy-tabix.
        IF ind = 1.
          READ TABLE ipar_but020 WITH KEY adext_addr = iadr13-addrnumber BINARY SEARCH.
          ipar_but020-chind_pag = 'I'.
          ipar_but020-pag_consnr = iadr13-consnumber.
          ipar_but020-pag_serv = iadr13-pager_serv.
          ipar_but020-pag_nmbr = iadr13-pager_nmbr.
          ipar_but020-pag_deflt  = iadr13-flgdefault.
**          ipar_but020-pag_remark
          ipar_but020-pag_home   = iadr13-home_flag.
          ipar_but020-pag_valid_from = iadr13-valid_from.
          ipar_but020-pag_valid_to   = iadr13-valid_to.
          ipar_but020-pag_dont_use   = iadr13-flg_nouse.
          MODIFY ipar_but020 INDEX sy-tabix.
          CLEAR ipar_but020.
        ELSE.
          ipar_but020-adext_addr  = but020-addrnumber.
          ipar_but020-chind_pag = 'I'.
          ipar_but020-pag_consnr = iadr13-consnumber.
          ipar_but020-pag_serv = iadr13-pager_serv.
          ipar_but020-pag_nmbr = iadr13-pager_nmbr.
          ipar_but020-pag_deflt  = iadr13-flgdefault.
**          ipar_but020-pag_remark
          ipar_but020-pag_home   = iadr13-home_flag.
          ipar_but020-pag_valid_from = iadr13-valid_from.
          ipar_but020-pag_valid_to   = iadr13-valid_to.
          ipar_but020-pag_dont_use   = iadr13-flg_nouse.
          APPEND ipar_but020.
          CLEAR ipar_but020.
        ENDIF.
      ENDLOOP.

    ENDSELECT.


**** ipar_but021
***  nur aufbauen, wenn in but020 mehr als ein Eintrag
    CLEAR h_lines.
    CLEAR: ibut020.
    REFRESH ibut020.
*    DESCRIBE TABLE ipar_but020 LINES h_lines.
    SELECT * FROM but020 INTO TABLE ibut020
       WHERE partner = but000-partner.
***  ---> Nuss 02.11.2015
*** Prüfen, ob diese Adressen auch zum Tagesdatum gültig sind
    LOOP AT ibut020.

      IF  ibut020-addr_valid_to = '99991231235959'.
        MOVE '99991231' TO help_date_to.
      ELSE.
        CONVERT TIME STAMP ibut020-addr_valid_to TIME ZONE tz
         INTO DATE help_date_to.
      ENDIF.

      CONVERT TIME STAMP ibut020-addr_valid_from TIME ZONE tz
       INTO DATE help_date_from.

*  Adresse muss zum Tagesdatum gültig sein
      IF help_date_to LT sy-datum
        OR help_date_from GT sy-datum.
        DELETE ibut020.
      ELSE.
      ENDIF.
    ENDLOOP.
*   <-- Nuss 02.11.2015

    DESCRIBE TABLE ibut020 LINES h_lines.

    IF h_lines GT 1.
      SELECT * FROM but021_fs WHERE partner = but000-partner.
****     Nur Unendlich-Zeitscheiben
**        IF but021_fs-valid_to = '99991231235959'.
*
**       Konvertieren Zeitstempel bei Adressen in Datum
**       Zum Tagesdatum ungültige Zeitscheiben werden nicht übernommen
        CLEAR help_date.
        CONVERT TIME STAMP but021_fs-valid_from  TIME ZONE tz
           INTO DATE help_date.
        IF help_date GT sy-datum.
          CLEAR ipar_but021.
          CONTINUE.
**      Übernahme Datum
        ELSE.
          MOVE help_date TO ipar_but021-advw_date_from.
        ENDIF.
*
        CLEAR help_date.
        IF but021_fs-valid_to = '99991231235959'.
          MOVE '99991231' TO help_date.
          MOVE help_date TO ipar_but021-advw_date_to.
        ELSE.
          CONVERT TIME STAMP but021_fs-valid_to  TIME ZONE tz
               INTO DATE help_date.
          IF help_date LT sy-datum.
            CLEAR ipar_but021.
            CONTINUE.
**      Übernahme Datum
          ELSE.
            MOVE help_date TO ipar_but021-advw_date_to.
          ENDIF.
        ENDIF.


        MOVE but021_fs-adr_kind      TO ipar_but021-adr_kind.
        MOVE but021_fs-addrnumber    TO ipar_but021-adext_advw.
        MOVE but021_fs-xdfadu        TO ipar_but021-xdfadu.
        APPEND ipar_but021.
*        ENDIF.
        CLEAR  ipar_but021.
      ENDSELECT.
***  Nur die nicht Default
    ELSE.
      SELECT * FROM but021_fs WHERE partner = but000-partner
          AND adr_kind NE 'XXDEFAULT'.
***     Nur Unendlich-Zeitscheiben
*        IF but021_fs-valid_to = '99991231235959'.
*       Konvertieren Zeitstempel bei Adressen in Datum
*       Zum Tagesdatum ungültige Zeitscheiben werden nicht übernommern
        CLEAR help_date.
        CONVERT TIME STAMP but021_fs-valid_from  TIME ZONE tz
           INTO DATE help_date.
        IF help_date GT sy-datum.
          CLEAR ipar_but021.
          CONTINUE.
**     Übernahme Datum
        ELSE.
          MOVE help_date TO ipar_but021-advw_date_from.
        ENDIF.

        CLEAR help_date.
        IF but021_fs-valid_to = '99991231235959'.
          MOVE '99991231' TO help_date.
          MOVE help_date TO ipar_but021-advw_date_to.
        ELSE.
          CONVERT TIME STAMP but021_fs-valid_to  TIME ZONE tz
               INTO DATE help_date.
          IF help_date LT sy-datum.
            CLEAR ipar_but021.
            CONTINUE.
**       Übernahme Datum
          ELSE.
            MOVE help_date TO ipar_but021-advw_date_to.
          ENDIF.
        ENDIF.
        MOVE but021_fs-adr_kind      TO ipar_but021-adr_kind.
        MOVE but021_fs-addrnumber    TO ipar_but021-adext_advw.
        MOVE but021_fs-xdfadu        TO ipar_but021-xdfadu.
        APPEND ipar_but021.
*        ENDIF.
        CLEAR  ipar_but021.
      ENDSELECT.
    ENDIF.
*** Mindestens 1 Eintrag muss das Flag XDFADU gesetzt haben
    READ TABLE ipar_but021
       WITH KEY xdfadu = 'X'.
    IF sy-subrc NE 0.
      READ TABLE ipar_but021
         WITH KEY adr_kind = 'XXDEFAULT'.
      IF sy-subrc = 0.
        ipar_but021-xdfadu = 'X'.
        MODIFY ipar_but021 INDEX sy-tabix.
      ENDIF.
    ENDIF.

* ipar_but0cc
    SELECT * FROM but0cc WHERE partner = but000-partner.
      MOVE-CORRESPONDING but0cc TO ipar_but0cc.
      APPEND ipar_but0cc.
      CLEAR ipar_but0cc.
    ENDSELECT.

* ipar_taxnum
    SELECT * FROM dfkkbptaxnum WHERE partner = but000-partner.
      MOVE-CORRESPONDING dfkkbptaxnum TO ipar_taxnum.
      APPEND ipar_taxnum.
      CLEAR ipar_taxnum.
    ENDSELECT.

* ipar_but0is
** Nur für Organistationen
    IF but000-type = '2'.
      SELECT * FROM but0is WHERE partner = but000-partner.
        MOVE-CORRESPONDING but0is TO ipar_but0is.
        ipar_but0is-ind_sect = but0is-ind_sector.
        APPEND ipar_but0is.
        CLEAR ipar_but0is.
      ENDSELECT.
**       Quellsystem sind Branchen nicht gepflegt
**       Zielsystem ist das ein Mussfeld.
**       Struktur aufbauen
      IF sy-subrc NE 0.
        ipar_but0is-istype = '0001'.
        ipar_but0is-isdef  = 'X'.
        APPEND ipar_but0is.
        CLEAR ipar_but0is.
      ENDIF.
    ENDIF.


***  Adressunabhängige Kommunikationsdaten
**  ipar_bus000icom
    IF but000-addrcomm IS NOT INITIAL.
      CLEAR: iadr2, iadr3, iadr5, iadr6, iadr12, iadr13.
      REFRESH: iadr2, iadr3, iadr4, iadr6, iadr12, iadr13.

***     Telefonnummern
      SELECT * FROM adr2 INTO TABLE iadr2
         WHERE addrnumber = but000-addrcomm.
***     Faxnummern
      SELECT * FROM adr3 INTO TABLE iadr3
         WHERE addrnumber = but000-addrcomm.
***     Teletext (TTX)
      SELECT * FROM adr4 INTO TABLE iadr4
         WHERE addrnumber = but000-addrcomm.
***     Telex (TLX)
      SELECT * FROM adr5 INTO TABLE iadr5
         WHERE addrnumber = but000-addrcomm.
***     E-Mail-Adressen
      SELECT * FROM adr6 INTO TABLE iadr6
         WHERE addrnumber = but000-addrcomm.
***     FTP und URL
      SELECT * FROM adr12 INTO TABLE iadr12
          WHERE addrnumber = but000-addrcomm.
***     Pager (SMS)
      SELECT * FROM adr13 INTO TABLE iadr13
          WHERE addrnumber = but000-addrcomm.

**  Telefonnummern
      LOOP AT iadr2.
        CLEAR h_lines.
        DESCRIBE TABLE iadr2 LINES h_lines.
        ipar_bus000icomm-icom_chind_tel = 'I'.
        ipar_bus000icomm-icom_tel_consnr = iadr2-consnumber.
        ipar_bus000icomm-icom_tel_cntry = iadr2-country.
        ipar_bus000icomm-icom_tel_number = iadr2-tel_number.
        ipar_bus000icomm-icom_tel_extens = iadr2-tel_extens.
*     Bei mehreren Einträgen kann es sein, dass ein nicht mehr aktueller Eintrag
*     als Standard definiert ist. Die adressunabhängigen Daten können nicht mehr
*     zeitscheibenabhängig gepflegt werden, deshalb muss der gültige Eintrag
*     als Standard definiert werden.
        IF h_lines GT 1.
**      Wenn Adresse nicht mehr gültig ist, diese nicht übernehmen
          IF iadr2-valid_to IS NOT INITIAL.
            CLEAR help_date.
            MOVE iadr2-valid_to(8) TO help_date.
            IF help_date LT sy-datum.
              CLEAR ipar_bus000icomm.
              CONTINUE.
            ENDIF.
          ENDIF.
          IF iadr2-valid_to IS NOT INITIAL AND
            iadr2-flgdefault = 'X'.
            CLEAR iadr2-flgdefault.
          ENDIF.
          IF iadr2-valid_to IS INITIAL
            AND iadr2-flgdefault IS INITIAL.
            iadr2-flgdefault = 'X'.
          ENDIF.
          IF iadr2-valid_to IS NOT INITIAL AND
            iadr2-home_flag = 'X'.
            CLEAR iadr2-home_flag.
          ENDIF.
          IF iadr2-valid_to IS INITIAL AND
            iadr2-home_flag IS INITIAL.
            iadr2-home_flag = 'X'.
          ENDIF.
        ENDIF.
        ipar_bus000icomm-icom_tel_deflt = iadr2-flgdefault.
*      ipar_bus000icomm-icom_tel_remark
        ipar_bus000icomm-icom_tel_home = iadr2-home_flag.
        ipar_bus000icomm-icom_tel_mobile = iadr2-r3_user.
        ipar_bus000icomm-icom_tel_receiv = iadr2-dft_receiv.
        ipar_bus000icomm-icom_tel_valfrom = iadr2-valid_from.
        ipar_bus000icomm-icom_tel_valto = iadr2-valid_to.
        ipar_bus000icomm-icom_teldontuse = iadr2-flg_nouse.
        APPEND ipar_bus000icomm.
        CLEAR ipar_bus000icomm.

      ENDLOOP.

* Faxnummern
      LOOP AT iadr3.
        CLEAR h_lines.
        DESCRIBE TABLE iadr3 LINES h_lines.
        ipar_bus000icomm-icom_chind_fax = 'I'.
        ipar_bus000icomm-icom_fax_consnr = iadr3-consnumber.
        ipar_bus000icomm-icom_fax_cntry = iadr3-country.
        ipar_bus000icomm-icom_fax_number = iadr3-fax_number.
        ipar_bus000icomm-icom_fax_extens = iadr3-fax_extens.
*     Bei mehreren Einträgen kann es sein, dass ein nicht mehr aktueller Eintrag
*     als Standard definiert ist. Die adressunabhängigen Daten können nicht mehr
*     zeitscheibenabhängig gepflegt werden, deshalb muss der gültige Eintrag
*     als Standard definiert werden.

        IF h_lines GT 1.
**      Wenn Adresse nicht mehr gültig ist, diese nicht übernehmen
          IF iadr3-valid_to IS NOT INITIAL.
            CLEAR help_date.
            MOVE iadr3-valid_to(8) TO help_date.
            IF help_date LT sy-datum.
              CLEAR ipar_bus000icomm.
              CONTINUE.
            ENDIF.
          ENDIF.
          IF iadr3-valid_to IS NOT INITIAL AND
            iadr3-flgdefault = 'X'.
            CLEAR iadr3-flgdefault.
          ENDIF.
          IF iadr3-valid_to IS INITIAL
            AND iadr3-flgdefault IS INITIAL.
            iadr3-flgdefault = 'X'.
          ENDIF.
          IF iadr3-valid_to IS NOT INITIAL AND
            iadr3-home_flag = 'X'.
            CLEAR iadr3-home_flag.
          ENDIF.
          IF iadr3-valid_to IS INITIAL AND
            iadr3-home_flag IS INITIAL.
            iadr3-home_flag = 'X'.
          ENDIF.
        ENDIF.
        ipar_bus000icomm-icom_fax_deflt = iadr3-flgdefault.
*      ipar_bus000icomm-icom_fax_remark
        ipar_bus000icomm-icom_fax_home = iadr3-home_flag.
        ipar_bus000icomm-icom_fax_valfrom = iadr3-valid_from.
        ipar_bus000icomm-icom_fax_valto = iadr3-valid_to.
        ipar_bus000icomm-icom_faxdontuse = iadr3-flg_nouse.
        APPEND ipar_bus000icomm.
        CLEAR ipar_bus000icomm.
      ENDLOOP.

*** Teletext nicht vorhanden
*** Telex nicht vorhanden

*     E-Mail-Adressen
      LOOP AT iadr6.
        CLEAR h_lines.
        DESCRIBE TABLE iadr6 LINES h_lines.
        ipar_bus000icomm-icom_chind_smtp = 'I'.
        ipar_bus000icomm-icom_smtp_consnr = iadr6-consnumber.
        ipar_bus000icomm-icom_smtp_addr = iadr6-smtp_addr.
*     Bei mehreren Einträgen kann es sein, dass ein nicht mehr aktueller Eintrag
*     als Standard definiert ist. Die adressunabhängigen Daten können nicht mehr
*     zeitscheibenabhängig gepflegt werden, deshalb muss der gültige Eintrag
*     als Standard definiert werden.
        IF h_lines GT 1.
**      Wenn Adresse nicht mehr gültig ist, diese nicht übernehmen
          IF iadr6-valid_to IS NOT INITIAL.
            CLEAR help_date.
            MOVE iadr6-valid_to(8) TO help_date.
            IF help_date LT sy-datum.
              CLEAR ipar_bus000icomm.
              CONTINUE.
            ENDIF.
          ENDIF.

          IF iadr6-valid_to IS NOT INITIAL AND
            iadr6-flgdefault = 'X'.
            CLEAR iadr6-flgdefault.
          ENDIF.
          IF iadr6-valid_to IS INITIAL
            AND iadr6-flgdefault IS INITIAL.
            iadr6-flgdefault = 'X'.
          ENDIF.
          IF iadr6-valid_to IS NOT INITIAL AND
            iadr6-home_flag = 'X'.
            CLEAR iadr6-home_flag.
          ENDIF.
          IF iadr6-valid_to IS INITIAL AND
            iadr6-home_flag IS INITIAL.
            iadr6-home_flag = 'X'.
          ENDIF.
        ENDIF.

        ipar_bus000icomm-icom_smtp_deflt = iadr6-flgdefault.
*     ipar_bus000icomm-icom_smtp_remark
        ipar_bus000icomm-icom_smtp_home = iadr6-home_flag.
        ipar_bus000icomm-icom_smtp_valfrom =  iadr6-valid_from.
        ipar_bus000icomm-icom_smtp_valto = iadr6-valid_to.
        ipar_bus000icomm-icom_smtpdontuse = iadr6-flg_nouse.
        APPEND ipar_bus000icomm.
        CLEAR ipar_bus000icomm.
      ENDLOOP.

* URL
* URL's sind nicht zeitabhängig
      LOOP AT iadr12.
        ipar_bus000icomm-icom_chind_uri = 'I'.
        ipar_bus000icomm-icom_uri_consnr = iadr12-consnumber.
        ipar_bus000icomm-icom_uri_type   = iadr12-uri_type.
        ipar_bus000icomm-icom_uri_screen = iadr12-uri_addr.
        ipar_bus000icomm-icom_uri_deflt  = iadr12-flgdefault.
        ipar_bus000icomm-icom_uri_home   = iadr12-home_flag.
        ipar_bus000icomm-icom_uridontuse   = iadr12-flg_nouse.
        APPEND ipar_bus000icomm.
        CLEAR ipar_bus000icomm.
      ENDLOOP.

** Pager (SMS)
      LOOP AT iadr13.
        CLEAR h_lines.
        DESCRIBE TABLE iadr13 LINES h_lines.
        ipar_bus000icomm-icom_chind_pag = 'I'.
        ipar_bus000icomm-icom_pag_consnr = iadr13-consnumber.
        ipar_bus000icomm-icom_pag_serv = iadr13-pager_serv.
        ipar_bus000icomm-icom_pag_nmbr = iadr13-pager_nmbr.
*     Bei mehreren Einträgen kann es sein, dass ein nicht mehr aktueller Eintrag
*     als Standard definiert ist. Die adressunabhängigen Daten können nicht mehr
*     zeitscheibenabhängig gepflegt werden, deshalb muss der gültige Eintrag
*     als Standard definiert werden.
        IF h_lines GT 1.

**      Wenn Adresse nicht mehr gültig ist, diese nicht übernehmen
          IF iadr13-valid_to IS NOT INITIAL.
            CLEAR help_date.
            MOVE iadr13-valid_to(8) TO help_date.
            IF help_date LT sy-datum.
              CLEAR ipar_bus000icomm.
              CONTINUE.
            ENDIF.
          ENDIF.

          IF iadr13-valid_to IS NOT INITIAL AND
            iadr13-flgdefault = 'X'.
            CLEAR iadr13-flgdefault.
          ENDIF.
          IF iadr13-valid_to IS INITIAL
            AND iadr13-flgdefault IS INITIAL.
            iadr13-flgdefault = 'X'.
          ENDIF.
          IF iadr13-valid_to IS NOT INITIAL AND
            iadr13-home_flag = 'X'.
            CLEAR iadr13-home_flag.
          ENDIF.
          IF iadr6-valid_to IS INITIAL AND
            iadr6-home_flag IS INITIAL.
            iadr6-home_flag = 'X'.
          ENDIF.
        ENDIF.
        ipar_bus000icomm-icom_pag_deflt = iadr13-flgdefault.
*     ipar_buticom-icom_pag_remark
        ipar_bus000icomm-icom_pag_home = iadr13-home_flag.
        ipar_bus000icomm-icom_pag_valfrom = iadr13-valid_from.
        ipar_bus000icomm-icom_pag_valto = iadr13-valid_to.
        ipar_bus000icomm-icom_pagdontuse = iadr13-flg_nouse.
        APPEND ipar_bus000icomm.
        CLEAR ipar_bus000icomm.

      ENDLOOP.
    ENDIF.

*    Für Projekt EGUT
*    hier Auskommentiert
***  Die Adressunabhängigen Kommunikationsdaten werden in die Adressdaten
***  übertragen, sofern dort noch keine Daten vorliegen
*    LOOP AT ipar_bus000icomm.
***    Telefonnummern
*      IF ipar_bus000icomm-icom_chind_tel IS NOT INITIAL.
***      Prüfen, ob es in der BUT020 schon eine Telefonnnummer gibt
*        LOOP AT ipar_but020 WHERE tel_number IS NOT INITIAL.
*        ENDLOOP.
***      Es wurde eine Telefonnummer gefunden, dann weiter
*        IF sy-subrc = 0.
*          CONTINUE.
*        ENDIF.
*        LOOP AT ipar_but020.
*          IF ipar_but020-tel_number IS INITIAL.
*            ipar_but020-chind_tel  = 'I'.
*            ipar_but020-tel_consnr = ipar_bus000icomm-icom_tel_consnr.
*            ipar_but020-tel_cntry  = ipar_bus000icomm-icom_tel_cntry.
*            ipar_but020-tel_number = ipar_bus000icomm-icom_tel_number.
*            ipar_but020-tel_extens = ipar_bus000icomm-icom_tel_extens.
*            ipar_but020-tel_deflt  = ipar_bus000icomm-icom_tel_deflt.
**         ipar_but020-tel_remark
*            ipar_but020-tel_home   = ipar_bus000icomm-icom_tel_home.
*            ipar_but020-tel_mobile = ipar_bus000icomm-icom_tel_mobile.
*            ipar_but020-tel_receiv = ipar_bus000icomm-icom_tel_receiv.
*            ipar_but020-tel_valid_from = ipar_bus000icomm-icom_tel_valfrom.
*            ipar_but020-tel_valid_to   = ipar_bus000icomm-icom_tel_valto.
*            ipar_but020-tel_dont_use   = ipar_bus000icomm-icom_teldontuse.
*            MODIFY ipar_but020 INDEX sy-tabix.
*            CLEAR ipar_but020.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
***   Faxnummern
*      IF ipar_bus000icomm-icom_chind_fax IS NOT INITIAL.
**     Prüfen, ob es in der BUT020 schon eine Faxnummer gibt
*        LOOP AT ipar_but020 WHERE fax_number IS NOT INITIAL.
*        ENDLOOP .
***      Es wurde eine Faxnummer gefunden, dann weiter
*        IF sy-subrc = 0.
*          CONTINUE.
*        ENDIF.
*        LOOP AT ipar_but020.
*          IF ipar_but020-fax_number IS INITIAL.
*            ipar_but020-chind_fax  = 'I'.
*            ipar_but020-fax_consnr = ipar_bus000icomm-icom_fax_consnr.
*            ipar_but020-fax_cntry  = ipar_bus000icomm-icom_fax_cntry.
*            ipar_but020-fax_number = ipar_bus000icomm-icom_fax_number.
*            ipar_but020-fax_extens = ipar_bus000icomm-icom_fax_extens.
*            ipar_but020-fax_deflt  = ipar_bus000icomm-icom_fax_deflt.
**          ipar_but020-fax_remark
*            ipar_but020-fax_home   = ipar_bus000icomm-icom_fax_home.
*            ipar_but020-fax_valid_from = ipar_bus000icomm-icom_fax_valfrom.
*            ipar_but020-fax_valid_to   = ipar_bus000icomm-icom_fax_valto.
*            ipar_but020-fax_dont_use   = ipar_bus000icomm-icom_faxdontuse.
*            MODIFY ipar_but020 INDEX sy-tabix.
*            CLEAR ipar_but020.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
***   E-Mail-Adressen
*      IF  ipar_bus000icomm-icom_chind_smtp IS NOT INITIAL.
**     Prüfen, ob es schon eine EMAIL-Adresse gibt.
*        LOOP AT ipar_but020 WHERE smtp_addr IS NOT INITIAL.
*        ENDLOOP.
**     Es wurde eine E-Mail-Adresse gefunden, weiter
*        IF sy-subrc = 0.
*          CONTINUE.
*        ENDIF.
*        LOOP AT ipar_but020.
*          IF ipar_but020-smtp_addr IS INITIAL.
*            ipar_but020-chind_smtp = 'I'.
*            ipar_but020-smtp_consnr = ipar_bus000icomm-icom_smtp_consnr.
*            ipar_but020-smtp_addr   = ipar_bus000icomm-icom_smtp_addr.
*            ipar_but020-smtp_deflt  = ipar_bus000icomm-icom_smtp_deflt.
**          ipar_but020-smtp_remark
*            ipar_but020-smtp_home   = ipar_bus000icomm-icom_smtp_home.
*            ipar_but020-smtp_valid_from = ipar_bus000icomm-icom_smtp_valfrom.
*            ipar_but020-smtp_valid_to   = ipar_bus000icomm-icom_smtp_valto.
*            ipar_but020-smtp_dont_use   = ipar_bus000icomm-icom_smtpdontuse.
*            MODIFY ipar_but020 INDEX sy-tabix.
*            CLEAR ipar_but020.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
***    URLs sind nicht vorhanden
*
*** Pager
*      IF ipar_bus000icomm-icom_chind_pag IS NOT INITIAL.
***    Prüfen, ob es schon einen Pager gibt.
*        LOOP AT ipar_but020 WHERE  pag_nmbr IS NOT INITIAL.
*        ENDLOOP.
***     Es wurde ein Pager gefunden, jetzt weiter
*        IF sy-subrc = 0.
*          CONTINUE.
*        ENDIF.
*        LOOP AT ipar_but020.
*          IF ipar_but020-pag_nmbr IS INITIAL.
*            ipar_but020-chind_pag = 'I'.
*            ipar_but020-pag_consnr = ipar_bus000icomm-icom_pag_consnr.
*            ipar_but020-pag_serv = ipar_bus000icomm-icom_pag_serv.
*            ipar_but020-pag_nmbr = ipar_bus000icomm-icom_pag_nmbr.
*            ipar_but020-pag_deflt  = ipar_bus000icomm-icom_pag_deflt.
**         ipar_but020-pag_remark
*            ipar_but020-pag_home = ipar_bus000icomm-icom_pag_home.
*            ipar_but020-pag_valid_from = ipar_bus000icomm-icom_pag_valfrom.
*            ipar_but020-pag_valid_to = ipar_bus000icomm-icom_pag_valto.
*            ipar_but020-pag_dont_use = ipar_bus000icomm-icom_pagdontuse.
*            MODIFY ipar_but020 INDEX sy-tabix.
*            CLEAR ipar_but020.
*          ENDIF.
*
*        ENDLOOP.
*
*      ENDIF.
*
*    ENDLOOP.


    ADD 1 TO anz_obj.

  ENDSELECT.

  IF sy-subrc NE 0.
    meldung-meldung = 'Partnernummer nicht in BUT000 gefunden'.
    APPEND meldung.
    RAISE wrong_data.
  ENDIF.

*< Datenermittlung ---------


*>> Wegschreiben des Objektschlüssels in Entlade-KSV
  o_key = oldkey_par.
  CALL FUNCTION '/ADESSO/MTE_OBJKEY_INSERT_ONE'
    EXPORTING
      i_firma  = firma
      i_object = object
      i_oldkey = o_key
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
    meldung-meldung =
        'Fehler bei wegschreiben in Entlade-KSV'.
    APPEND meldung.
    RAISE error.
  ENDIF.
*<< Wegschreiben des Objektschlüssels in Entlade-KSV


** Umschlüsselung-FUBA (aus Customizing Tabelle s.o.)
*  IF NOT ums_fuba IS INITIAL.
**   CALL FUNCTION '/ADESSO/MTU_SAMPLE_ENT_PARTNER'
*    CALL FUNCTION ums_fuba
*      EXPORTING
*        firma            = firma
*      TABLES
*        meldung          = meldung
*        ipar_init        = ipar_init
*        ipar_ekun        = ipar_ekun
*        ipar_but000      = ipar_but000
*        ipar_bus000icomm = ipar_bus000icomm
*        ipar_but001      = ipar_but001
*        ipar_but0bk      = ipar_but0bk
*        ipar_but020      = ipar_but020
*        ipar_but021      = ipar_but021
*        ipar_but0cc      = ipar_but0cc
*        ipar_shipto      = ipar_shipto
*        ipar_taxnum      = ipar_taxnum
*        ipar_eccard      = ipar_eccard
*        ipar_eccrdh      = ipar_eccrdh
*        ipar_but0is      = ipar_but0is
*      CHANGING
*        oldkey_par       = oldkey_par.
*  ENDIF.


  DESCRIBE TABLE meldung LINES sy-tfill.
  IF sy-tfill > 0.
    RAISE wrong_data.
  ENDIF.


* Sätze für Datei in interne Tabelle schreiben
  PERFORM fill_ipar_out USING oldkey_par
                              firma
                              object
                              anz_init
                              anz_ekun
                              anz_but000
                              anz_buticom
                              anz_but001
                              anz_but0bk
                              anz_but020
                              anz_but021
                              anz_but0cc
                              anz_shipto
                              anz_taxnum
                              anz_eccard
                              anz_eccardh
                              anz_but0is.

* Import-Datei fortschreiben
  LOOP AT ipar_out INTO wpar_out.
    CATCH SYSTEM-EXCEPTIONS convt_codepage = 4.
      TRANSFER wpar_out TO ent_file.
    ENDCATCH.
    IF sy-subrc = 4.
      meldung-meldung = 'Fehler beim Konvertieren UNICODE - NON UNICODE'.
      APPEND meldung.
      RAISE error.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
