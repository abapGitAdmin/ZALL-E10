*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LINKASSO_FGF03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILL_C_FKKCOLLP_IP
*&---------------------------------------------------------------------*
FORM fill_c_fkkcollp_ip  USING c_fkkcollp_ip LIKE fkkcollp_ip.

  DATA: ls_but000   TYPE but000,
        ls_bus000   TYPE bus000flds,
        ls_tsad3t   TYPE tsad3t,
        ls_eadrdat  TYPE eadrdat,
        ls_fkkop    TYPE dfkkop,
        ls_ever     TYPE ever,
        lv_vertrag  TYPE vertrag,
        ls_fkkmaze  TYPE fkkmaze,
        ls_fkkmako  TYPE fkkmako,
        ls_dfkkko   TYPE dfkkko,
        ls_tfktvot  TYPE tfktvot,
        ls_tspat    TYPE tspat,
        ls_dfkkzp   TYPE dfkkzp,
        ls_dfkkop   TYPE dfkkop,
        lv_mahnkost TYPE mge1m_kk.

  DATA: lt_fkkop_ag TYPE TABLE OF fkkop.
  DATA: ls_fkkop_ag TYPE fkkop.
  DATA: h_tabix TYPE sytabix.

  DATA: ls_fkkvkp  TYPE fkkvkp,
        ls_but0bk  TYPE but0bk,
        ls_tiban   TYPE tiban,
        ls_bnka    TYPE bnka,
        ls_adr6    TYPE adr6,
        ls_nfhf    TYPE /adesso/ink_nfhf,
        ls_cust    TYPE /adesso/ink_cust,
        lt_cust    TYPE STANDARD TABLE OF /adesso/ink_cust,
        lt_fkkmaze TYPE STANDARD TABLE OF fkkmaze.

  DATA: lv_mahnv TYPE mahnv_kk,
        lv_mahns TYPE mahns_kk.

  SELECT SINGLE * FROM but000 INTO ls_but000
    WHERE partner = c_fkkcollp_ip-gpart.

  CLEAR c_fkkcollp_ip-zzanrede.

  SELECT SINGLE * FROM tsad3t INTO ls_tsad3t
  WHERE title = ls_but000-title.

  c_fkkcollp_ip-zzanrede = ls_tsad3t-title_medi.

* Name des Geschäftspartners ermitteln
* Hängt vom GP-Typ ab.

  CLEAR c_fkkcollp_ip-zzname_gp1.
  CLEAR c_fkkcollp_ip-zzname_gp2.
  CLEAR c_fkkcollp_ip-zzname_gp3.
  CLEAR c_fkkcollp_ip-zzname_gp4.

  CASE ls_but000-type.
    WHEN '1'.                  "natürliche Person
      c_fkkcollp_ip-zzname_gp1 = ls_but000-name_first.
      c_fkkcollp_ip-zzname_gp2 = ls_but000-name_last.
      c_fkkcollp_ip-zzname_gp3 = ls_but000-namemiddle. " Ehepartner
      c_fkkcollp_ip-zzname_gp4 = ls_but000-name_lst2.  " Ehepartner
    WHEN '2'.                  "Organisation.
      c_fkkcollp_ip-zzname_gp1 = ls_but000-name_org1.
      c_fkkcollp_ip-zzname_gp2 = ls_but000-name_org2.
      c_fkkcollp_ip-zzname_gp3 = ls_but000-name_org3.
      c_fkkcollp_ip-zzname_gp4 = ls_but000-name_org4.

    WHEN '3'.                    "Gruppe
      c_fkkcollp_ip-zzname_gp1 = ls_but000-name_grp1.
      c_fkkcollp_ip-zzname_gp2 = ls_but000-name_grp2.
  ENDCASE.

* Geburtsdatum
  CLEAR  c_fkkcollp_ip-zzbirthdt.
  c_fkkcollp_ip-zzbirthdt = ls_but000-birthdt.

*  Adresse zum GP ermitteln
  CLEAR ls_eadrdat.
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'B'
      x_partner                  = c_fkkcollp_ip-gpart
    IMPORTING
      y_eadrdat                  = ls_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  MOVE ls_eadrdat-city1 TO c_fkkcollp_ip-zzcity1gp.
  MOVE ls_eadrdat-city2 TO c_fkkcollp_ip-zzcity2gp.
  MOVE ls_eadrdat-post_code1 TO c_fkkcollp_ip-zzpost_code1gp.
  MOVE ls_eadrdat-street TO c_fkkcollp_ip-zzstreetgp.
  MOVE ls_eadrdat-house_num1 TO c_fkkcollp_ip-zzhouse_num1gp.
  MOVE ls_eadrdat-house_num2 TO c_fkkcollp_ip-zzhouse_num2gp.
  MOVE ls_eadrdat-country TO c_fkkcollp_ip-zzland.

* Telefonnummern
  CLEAR c_fkkcollp_ip-zztel1.
  CLEAR c_fkkcollp_ip-zztel2.
  CLEAR c_fkkcollp_ip-zzfax1.
  CLEAR c_fkkcollp_ip-zzfax2.

  MOVE ls_eadrdat-tel_number  TO c_fkkcollp_ip-zztel1.
  MOVE ls_eadrdat-tel_extens  TO c_fkkcollp_ip-zztel2.
  MOVE ls_eadrdat-fax_number  TO c_fkkcollp_ip-zzfax1.
  MOVE ls_eadrdat-fax_extens  TO c_fkkcollp_ip-zzfax2.

*** Zusätzlich E-Mail-Adresse
  CLEAR ls_adr6.
  CLEAR c_fkkcollp_ip-zzsmtp.
  SELECT * FROM adr6 INTO ls_adr6
     WHERE addrnumber = ls_eadrdat-addrnumber.
    MOVE ls_adr6-smtp_addr TO c_fkkcollp_ip-zzsmtp.
    EXIT.
  ENDSELECT.

*** Erweiterung Bankdaten
  CLEAR ls_fkkvkp.
  SELECT SINGLE * FROM fkkvkp INTO ls_fkkvkp
    WHERE vkont = c_fkkcollp_ip-vkont
      AND gpart = c_fkkcollp_ip-gpart.

  MOVE ls_fkkvkp-kofiz_sd TO c_fkkcollp_ip-zzkofiz_sd.

  IF ls_fkkvkp-ebvty IS NOT INITIAL.
    CLEAR ls_but0bk.
    SELECT SINGLE * FROM but0bk INTO ls_but0bk
      WHERE partner = c_fkkcollp_ip-gpart
       AND bkvid = ls_fkkvkp-ebvty.
    IF sy-subrc = 0.
**   BLZ und Kontonummer sowie abw. Kontoinhaber
      MOVE ls_but0bk-bankl TO c_fkkcollp_ip-zzbankl.
      MOVE ls_but0bk-bankn TO c_fkkcollp_ip-zzbankn.
      MOVE ls_but0bk-koinh TO c_fkkcollp_ip-zzkoinh.
**    IBAN
      CLEAR ls_tiban.
      SELECT * FROM tiban INTO ls_tiban
        WHERE banks = ls_but0bk-banks
          AND bankl = ls_but0bk-bankl
          AND bankn = ls_but0bk-bankn.
        MOVE ls_tiban-iban TO c_fkkcollp_ip-zziban.
        EXIT.
      ENDSELECT.
**    Name der Bank und BIC
      CLEAR ls_bnka.
      SELECT SINGLE * FROM bnka INTO ls_bnka
        WHERE banks = ls_but0bk-banks
          AND bankl = ls_but0bk-bankl.

      MOVE ls_bnka-banka TO c_fkkcollp_ip-zzbanka.
      MOVE ls_bnka-swift TO c_fkkcollp_ip-zzswift.

    ENDIF.

  ENDIF.

* Vertrag ermitteln
  CLEAR ls_fkkop.
  SELECT SINGLE * FROM dfkkop INTO ls_fkkop
      WHERE opbel = c_fkkcollp_ip-opbel
       AND vkont = c_fkkcollp_ip-vkont.

  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_fkkop-vtref
      IMPORTING
        output = c_fkkcollp_ip-zzvertrag.
  ENDIF.

*   Adresse der Verbrauchsstelle
  CLEAR ls_ever.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = c_fkkcollp_ip-zzvertrag
    IMPORTING
      output = lv_vertrag.

  SELECT SINGLE * FROM ever INTO ls_ever
    WHERE vertrag = lv_vertrag.

* Einzugsdatum
  c_fkkcollp_ip-zzeinzdat = ls_ever-einzdat.


  CLEAR ls_eadrdat.
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'I'
      x_anlage                   = ls_ever-anlage
    IMPORTING
      y_eadrdat                  = ls_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  MOVE ls_eadrdat-city1 TO c_fkkcollp_ip-zzcity1vs.
  MOVE ls_eadrdat-city2 TO c_fkkcollp_ip-zzcity2vs.
  MOVE ls_eadrdat-post_code1 TO c_fkkcollp_ip-zzpost_code1vs.
  MOVE ls_eadrdat-street TO c_fkkcollp_ip-zzstreetvs.
  MOVE ls_eadrdat-house_num1 TO c_fkkcollp_ip-zzhouse_num1vs.
  MOVE ls_eadrdat-house_num2 TO c_fkkcollp_ip-zzhouse_num2vs.

** Abrechnungszeitraum
  MOVE ls_fkkop-abrzu TO c_fkkcollp_ip-zzabrzu.
  MOVE ls_fkkop-abrzo TO c_fkkcollp_ip-zzabrzo.

* Text zum Teilvorgang
  CLEAR ls_tfktvot.
  SELECT SINGLE * FROM tfktvot INTO ls_tfktvot
    WHERE spras = sy-langu
      AND applk = 'R'
      AND hvorg = ls_fkkop-hvorg
      AND tvorg = ls_fkkop-tvorg.

  MOVE ls_tfktvot-txt30 TO c_fkkcollp_ip-zztvorgtxt.


* Sparte (Langtext)
  CLEAR ls_tspat.
  SELECT SINGLE * FROM tspat INTO ls_tspat
     WHERE spras = sy-langu
       AND spart = ls_fkkop-spart.

  MOVE ls_tspat-vtext TO c_fkkcollp_ip-zzspartxt.

* Fälligkeitsdatum
  MOVE ls_fkkop-faedn TO c_fkkcollp_ip-zzfaellig.

* Belegdatum
  CLEAR ls_dfkkko.
  SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
      WHERE opbel = ls_fkkop-opbel.

  MOVE ls_dfkkko-bldat TO c_fkkcollp_ip-zzbldat.

* Rechnungsnummer = Druckbelegnummer = XBLNR mitgeben
  MOVE ls_dfkkko-xblnr TO c_fkkcollp_ip-zzrechnung.
* Feld immer auf 16 Stellen voll auffüllen.
  SHIFT c_fkkcollp_ip-zzrechnung RIGHT DELETING TRAILING space.
  TRANSLATE c_fkkcollp_ip-zzrechnung USING ' 0'.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_C_FKKCOLLP_IR
*&---------------------------------------------------------------------*
FORM fill_c_fkkcollp_ir  USING c_fkkcollp_ir LIKE fkkcollp_ir
                               i_lfdnr TYPE lfdnr_kk.

  DATA: ls_but000    TYPE but000,
        ls_bus000    TYPE bus000flds,
        ls_tsad3t    TYPE tsad3t,
        ls_eadrdat   TYPE eadrdat,
        ls_fkkop     TYPE dfkkop,
        ls_ever      TYPE ever,
        lv_vertrag   TYPE vertrag,
        ls_fkkmaze   TYPE fkkmaze,
        ls_fkkmako   TYPE fkkmako,
        ls_dfkkko    TYPE dfkkko,
        ls_tfktvot   TYPE tfktvot,
        ls_tspat     TYPE tspat,
        ls_dfkkzp    TYPE dfkkzp,
        ls_dfkkop    TYPE dfkkop,
        lv_mahnkost  TYPE mge1m_kk,
        ls_dfkkcollh TYPE dfkkcollh,
        ls_tfk050dt  TYPE tfk050dt.


  DATA: lt_fkkop_ag TYPE TABLE OF fkkop.
  DATA: ls_fkkop_ag TYPE fkkop.
  DATA: h_tabix TYPE sytabix.

  DATA: ls_fkkvkp  TYPE fkkvkp,
        ls_but0bk  TYPE but0bk,
        ls_tiban   TYPE tiban,
        ls_bnka    TYPE bnka,
        ls_adr6    TYPE adr6,
        ls_nfhf    TYPE /adesso/ink_nfhf,
        ls_cust    TYPE /adesso/ink_cust,
        lt_cust    TYPE STANDARD TABLE OF /adesso/ink_cust,
        lt_fkkmaze TYPE STANDARD TABLE OF fkkmaze.

  DATA: lv_mahnv TYPE mahnv_kk,
        lv_mahns TYPE mahns_kk.

* Rückrufgrund setzen
  SELECT SINGLE * FROM dfkkcollh INTO ls_dfkkcollh
         WHERE opbel = c_fkkcollp_ir-opbel
         AND   inkps = c_fkkcollp_ir-inkps
         AND   lfdnr = i_lfdnr.

  IF sy-subrc = 0.

    CASE ls_dfkkcollh-agsta.

      WHEN '20'.
        CLEAR c_fkkcollp_ir-txtvw.
        CONCATENATE TEXT-acl '/' TEXT-aic
                    INTO c_fkkcollp_ir-txtvw SEPARATED BY space.

      WHEN '30'.
        CLEAR c_fkkcollp_ir-txtvw.
        c_fkkcollp_ir-txtvw = TEXT-sel.
        c_fkkcollp_ir-rudat   = sy-datum.

      WHEN '31' OR '32'.
        CLEAR c_fkkcollp_ir-txtvw.
        c_fkkcollp_ir-txtvw = TEXT-sdc.
        c_fkkcollp_ir-rudat   = sy-datum.

      WHEN OTHERS.
        IF ls_dfkkcollh-xsold = 'X'.
          CLEAR c_fkkcollp_ir-txtvw.
          c_fkkcollp_ir-txtvw = TEXT-sdc.
          c_fkkcollp_ir-rudat   = sy-datum.
        ELSE.
          SELECT SINGLE * FROM tfk050dt INTO ls_tfk050dt
                 WHERE spras = sy-langu
                 AND   deagr = ls_dfkkcollh-rugrd.

          IF sy-subrc = 0.
            CONCATENATE c_fkkcollp_ir-txtvw '/' ls_tfk050dt-inrtxt
                        INTO c_fkkcollp_ir-txtvw SEPARATED BY space.
          ENDIF.
        ENDIF.

    ENDCASE.

  ENDIF.

  SELECT SINGLE * FROM but000 INTO ls_but000
    WHERE partner = c_fkkcollp_ir-gpart.

  CLEAR c_fkkcollp_ir-zzanrede.

  SELECT SINGLE * FROM tsad3t INTO ls_tsad3t
  WHERE title = ls_but000-title.

  c_fkkcollp_ir-zzanrede = ls_tsad3t-title_medi.

* Name des Geschäftspartners ermitteln
* Hängt vom GP-Typ ab.

  CLEAR c_fkkcollp_ir-zzname_gp1.
  CLEAR c_fkkcollp_ir-zzname_gp2.
  CLEAR c_fkkcollp_ir-zzname_gp3.
  CLEAR c_fkkcollp_ir-zzname_gp4.

  CASE ls_but000-type.
    WHEN '1'.                  "natürliche Person
      c_fkkcollp_ir-zzname_gp1 = ls_but000-name_first.
      c_fkkcollp_ir-zzname_gp2 = ls_but000-name_last.
      c_fkkcollp_ir-zzname_gp3 = ls_but000-namemiddle. " Ehepartner
      c_fkkcollp_ir-zzname_gp4 = ls_but000-name_lst2.  " Ehepartner

    WHEN '2'.                  "Organisation.
      c_fkkcollp_ir-zzname_gp1 = ls_but000-name_org1.
      c_fkkcollp_ir-zzname_gp2 = ls_but000-name_org2.
      c_fkkcollp_ir-zzname_gp3 = ls_but000-name_org3.
      c_fkkcollp_ir-zzname_gp4 = ls_but000-name_org4.

    WHEN '3'.                    "Gruppe
      c_fkkcollp_ir-zzname_gp1 = ls_but000-name_grp1.
      c_fkkcollp_ir-zzname_gp2 = ls_but000-name_grp2.
  ENDCASE.

* Geburtsdatum
  CLEAR  c_fkkcollp_ir-zzbirthdt.
  c_fkkcollp_ir-zzbirthdt = ls_but000-birthdt.

*  Adresse zum GP ermitteln
  CLEAR ls_eadrdat.
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'B'
      x_partner                  = c_fkkcollp_ir-gpart
    IMPORTING
      y_eadrdat                  = ls_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  MOVE ls_eadrdat-city1 TO c_fkkcollp_ir-zzcity1gp.
  MOVE ls_eadrdat-city2 TO c_fkkcollp_ir-zzcity2gp.
  MOVE ls_eadrdat-post_code1 TO c_fkkcollp_ir-zzpost_code1gp.
  MOVE ls_eadrdat-street TO c_fkkcollp_ir-zzstreetgp.
  MOVE ls_eadrdat-house_num1 TO c_fkkcollp_ir-zzhouse_num1gp.
  MOVE ls_eadrdat-house_num2 TO c_fkkcollp_ir-zzhouse_num2gp.
  MOVE ls_eadrdat-country TO c_fkkcollp_ir-zzland.

* Telefonnummern
  CLEAR c_fkkcollp_ir-zztel1.
  CLEAR c_fkkcollp_ir-zztel2.
  CLEAR c_fkkcollp_ir-zzfax1.
  CLEAR c_fkkcollp_ir-zzfax2.

  MOVE ls_eadrdat-tel_number  TO c_fkkcollp_ir-zztel1.
  MOVE ls_eadrdat-tel_extens  TO c_fkkcollp_ir-zztel2.
  MOVE ls_eadrdat-fax_number  TO c_fkkcollp_ir-zzfax1.
  MOVE ls_eadrdat-fax_extens  TO c_fkkcollp_ir-zzfax2.

*** Zusätzlich E-Mail-Adresse
  CLEAR ls_adr6.
  CLEAR c_fkkcollp_ir-zzsmtp.
  SELECT * FROM adr6 INTO ls_adr6
     WHERE addrnumber = ls_eadrdat-addrnumber.
    MOVE ls_adr6-smtp_addr TO c_fkkcollp_ir-zzsmtp.
    EXIT.
  ENDSELECT.

*** Erweiterung Bankdaten
  CLEAR ls_fkkvkp.
  SELECT SINGLE * FROM fkkvkp INTO ls_fkkvkp
    WHERE vkont = c_fkkcollp_ir-vkont
      AND gpart = c_fkkcollp_ir-gpart.

  MOVE ls_fkkvkp-kofiz_sd TO c_fkkcollp_ir-zzkofiz_sd.

  IF ls_fkkvkp-ebvty IS NOT INITIAL.
    CLEAR ls_but0bk.
    SELECT SINGLE * FROM but0bk INTO ls_but0bk
      WHERE partner = c_fkkcollp_ir-gpart
       AND bkvid = ls_fkkvkp-ebvty.
    IF sy-subrc = 0.
**   BLZ und Kontonummer sowie abw. Kontoinhaber
      MOVE ls_but0bk-bankl TO c_fkkcollp_ir-zzbankl.
      MOVE ls_but0bk-bankn TO c_fkkcollp_ir-zzbankn.
      MOVE ls_but0bk-koinh TO c_fkkcollp_ir-zzkoinh.
**    IBAN
      CLEAR ls_tiban.
      SELECT * FROM tiban INTO ls_tiban
        WHERE banks = ls_but0bk-banks
          AND bankl = ls_but0bk-bankl
          AND bankn = ls_but0bk-bankn.
        MOVE ls_tiban-iban TO c_fkkcollp_ir-zziban.
        EXIT.
      ENDSELECT.
**    Name der Bank und BIC
      CLEAR ls_bnka.
      SELECT SINGLE * FROM bnka INTO ls_bnka
        WHERE banks = ls_but0bk-banks
          AND bankl = ls_but0bk-bankl.

      MOVE ls_bnka-banka TO c_fkkcollp_ir-zzbanka.
      MOVE ls_bnka-swift TO c_fkkcollp_ir-zzswift.

    ENDIF.

  ENDIF.

* Vertrag ermitteln
  CLEAR ls_fkkop.
  SELECT SINGLE * FROM dfkkop INTO ls_fkkop
      WHERE opbel = c_fkkcollp_ir-opbel
       AND vkont = c_fkkcollp_ir-vkont.

  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_fkkop-vtref
      IMPORTING
        output = c_fkkcollp_ir-zzvertrag.
  ENDIF.

*   Adresse der Verbrauchsstelle
  CLEAR ls_ever.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = c_fkkcollp_ir-zzvertrag
    IMPORTING
      output = lv_vertrag.

  SELECT SINGLE * FROM ever INTO ls_ever
    WHERE vertrag = lv_vertrag.

* Einzugsdatum
  c_fkkcollp_ir-zzeinzdat = ls_ever-einzdat.


  CLEAR ls_eadrdat.
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'I'
      x_anlage                   = ls_ever-anlage
    IMPORTING
      y_eadrdat                  = ls_eadrdat
    EXCEPTIONS
      not_found                  = 1
      parameter_error            = 2
      object_not_given           = 3
      address_inconsistency      = 4
      installation_inconsistency = 5
      OTHERS                     = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  MOVE ls_eadrdat-city1 TO c_fkkcollp_ir-zzcity1vs.
  MOVE ls_eadrdat-city2 TO c_fkkcollp_ir-zzcity2vs.
  MOVE ls_eadrdat-post_code1 TO c_fkkcollp_ir-zzpost_code1vs.
  MOVE ls_eadrdat-street TO c_fkkcollp_ir-zzstreetvs.
  MOVE ls_eadrdat-house_num1 TO c_fkkcollp_ir-zzhouse_num1vs.
  MOVE ls_eadrdat-house_num2 TO c_fkkcollp_ir-zzhouse_num2vs.

** Abrechnungszeitraum
  MOVE ls_fkkop-abrzu TO c_fkkcollp_ir-zzabrzu.
  MOVE ls_fkkop-abrzo TO c_fkkcollp_ir-zzabrzo.

* Text zum Teilvorgang
  CLEAR ls_tfktvot.
  SELECT SINGLE * FROM tfktvot INTO ls_tfktvot
    WHERE spras = sy-langu
      AND applk = 'R'
      AND hvorg = ls_fkkop-hvorg
      AND tvorg = ls_fkkop-tvorg.

  MOVE ls_tfktvot-txt30 TO c_fkkcollp_ir-zztvorgtxt.


* Sparte (Langtext)
  CLEAR ls_tspat.
  SELECT SINGLE * FROM tspat INTO ls_tspat
     WHERE spras = sy-langu
       AND spart = ls_fkkop-spart.

  MOVE ls_tspat-vtext TO c_fkkcollp_ir-zzspartxt.

* Fälligkeitsdatum
  MOVE ls_fkkop-faedn TO c_fkkcollp_ir-zzfaellig.

* Belegdatum
  CLEAR ls_dfkkko.
  SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
      WHERE opbel = ls_fkkop-opbel.

  MOVE ls_dfkkko-bldat TO c_fkkcollp_ir-zzbldat.

* Rechnungsnummer = Druckbelegnummer = XBLNR mitgeben
  MOVE ls_dfkkko-xblnr TO c_fkkcollp_ir-zzrechnung.
* Feld immer auf 16 Stellen voll auffüllen.
  SHIFT c_fkkcollp_ir-zzrechnung RIGHT DELETING TRAILING space.
  TRANSLATE c_fkkcollp_ir-zzrechnung USING ' 0'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DEL_MAHNSPERRE
*&---------------------------------------------------------------------*
FORM del_mahnsperre  USING    pv_gpart
                              pv_vkont.


  DATA: lt_locks  TYPE  dfkklocks_t.
  DATA: ls_locks  TYPE  dfkklocks.

  CALL FUNCTION 'FKK_S_LOCK_GET_FOR_VKONT'
    EXPORTING
      iv_vkont = pv_vkont
      iv_gpart = pv_gpart
      iv_date  = sy-datum
      iv_proid = '01'
    IMPORTING
      et_locks = lt_locks.

* Alle derzeitige Mahnsperre löschen
  LOOP AT lt_locks INTO ls_locks
       WHERE lotyp = '06'
       AND   proid = '01'.

    CALL FUNCTION 'FKK_S_LOCK_DELETE'
      EXPORTING
        i_loobj1 = ls_locks-loobj1
        i_gpart  = ls_locks-gpart
        i_vkont  = ls_locks-vkont
        i_proid  = ls_locks-proid
        i_lotyp  = ls_locks-lotyp
        i_lockr  = ls_locks-lockr
        i_fdate  = ls_locks-fdate
        i_tdate  = ls_locks-tdate
      EXCEPTIONS
        OTHERS   = 7.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_INTVERM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_FKKCOLLP_IP_GPART  text
*      -->P_C_FKKCOLLP_IP_VKONT  text
*----------------------------------------------------------------------*
FORM create_intverm  USING    pv_gpart
                              pv_vkont.

  DATA: lt_cust TYPE TABLE OF /adesso/ink_cust.  "Customizing allgemein
  DATA: ls_cust TYPE /adesso/ink_cust.
  DATA: ls_stxh TYPE stxh.
  DATA: lt_stxh TYPE TABLE OF stxh.
  DATA: ls_head TYPE thead.
  DATA: ls_line TYPE tline.
  DATA: lt_line TYPE TABLE OF tline.

  DATA: lv_object   TYPE /adesso/inkasso_value.
  DATA: lv_id       TYPE /adesso/inkasso_value.
  DATA: lv_pattern  TYPE char30.
  DATA: lv_select   TYPE char30.
  DATA: lv_lfdnr(3) TYPE n.

  SELECT * FROM /adesso/ink_cust
         INTO TABLE lt_cust
         WHERE inkasso_option = 'INTVERM'.

  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDOBJECT'.

  IF sy-subrc = 0.
    MOVE ls_cust-inkasso_value TO lv_object.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR ls_cust.
  READ TABLE lt_cust INTO ls_cust
    WITH KEY inkasso_option = 'INTVERM'
             inkasso_field  = 'TDID'.

  IF sy-subrc = 0.
    MOVE ls_cust-inkasso_value TO lv_id.
  ELSE.
    EXIT.
  ENDIF.

  CLEAR lv_pattern.
  CLEAR lv_select.
  CLEAR lt_stxh.
  CLEAR ls_head.
  REFRESH lt_line.

  CONCATENATE pv_gpart '_' pv_vkont  '_'
              INTO  lv_pattern.

  CONCATENATE lv_pattern '%' INTO lv_select.


  SELECT * FROM stxh INTO TABLE lt_stxh
           WHERE tdobject = lv_object
           AND   tdname   LIKE lv_select
           AND   tdid     = lv_id
           AND   tdspras  = sy-langu.

  SORT lt_stxh BY tdname DESCENDING.
  READ TABLE lt_stxh INTO ls_stxh INDEX 1.
  IF sy-subrc = 0.
    CHECK ls_stxh-tdtitle NE TEXT-tst.
    lv_lfdnr = ls_stxh-tdname+24(3).
    ADD 1 TO lv_lfdnr.
    CONCATENATE lv_pattern lv_lfdnr INTO ls_head-tdname.
  ELSE.
    CONCATENATE lv_pattern '001' INTO ls_head-tdname.
  ENDIF.

  ls_head-tdobject = lv_object.
  ls_head-tdid     = lv_id.
  ls_head-tdspras  = sy-langu.
  ls_head-tdtitle  = TEXT-tst.
  ls_line-tdline   = TEXT-sto.
  APPEND ls_line TO lt_line.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      client          = sy-mandt
      header          = ls_head
*     INSERT          = ' '
      savemode_direct = 'X'
*     OWNER_SPECIFIED = ' '
*     LOCAL_CAT       = ' '
* IMPORTING
*     FUNCTION        =
*     NEWHEADER       =
    TABLES
      lines           = lt_line
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
