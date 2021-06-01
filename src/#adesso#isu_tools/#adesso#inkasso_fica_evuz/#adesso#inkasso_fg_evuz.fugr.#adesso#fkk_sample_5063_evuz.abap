FUNCTION /adesso/fkk_sample_5063_evuz.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_FKKCOLL) TYPE  DFKKCOLL
*"  TABLES
*"      T_FKKOP STRUCTURE  FKKOP
*"      T_FKKMAZE STRUCTURE  FKKMAZE
*"  CHANGING
*"     REFERENCE(C_FKKCOLFILE) TYPE  FKKCOLFILE
*"----------------------------------------------------------------------


  DATA: ls_but000   TYPE but000,
        ls_bus000   TYPE bus000flds,
        ls_tsad3t   TYPE tsad3t,
        ls_eadrdat  TYPE eadrdat,
        ls_fkkop    TYPE fkkop,
        ls_ever     TYPE ever,
        lv_vertrag  TYPE vertrag,
        ls_fkkmaze  TYPE fkkmaze,
        ls_fkkmako  TYPE fkkmako,
        ls_dfkkko   TYPE dfkkko,
        ls_tfktvot  TYPE tfktvot,
        ls_tspat    TYPE tspat,
        lv_mahnkost TYPE mge1m_kk.

  DATA: lt_fkkop_ag TYPE TABLE OF fkkop.
  DATA: ls_fkkop_ag TYPE fkkop.
  DATA: ls_fkkvkp  TYPE fkkvkp.
  DATA: h_tabix TYPE sytabix.

  DATA: lt_bankdetails  TYPE TABLE OF bapibus1006_bankdetails.
  DATA: ls_bankdetails  TYPE bapibus1006_bankdetails.
  DATA: ls_bnka    TYPE bnka.
  DATA: ls_cust    TYPE /adesso/i_cuevuz.
  DATA: lt_cust    TYPE STANDARD TABLE OF /adesso/i_cuevuz.
  DATA: lt_fkkmaze TYPE STANDARD TABLE OF fkkmaze.


  DATA: ls_adr2    TYPE adr2.
  DATA: lt_adr2    TYPE TABLE OF adr2.
  DATA: ls_adr6    TYPE adr6.
  DATA: lt_adr6    TYPE TABLE OF adr6.

  PERFORM clear_c_colfile USING c_fkkcolfile.

  SELECT SINGLE * FROM but000 INTO ls_but000
    WHERE partner = c_fkkcolfile-gpart.

  SELECT SINGLE * FROM tsad3t INTO ls_tsad3t
  WHERE title = ls_but000-title.

  c_fkkcolfile-zzanrede = ls_tsad3t-title_medi.

* Name des Geschäftspartners ermitteln
* Hängt vom GP-Typ ab.

  CASE ls_but000-type.
    WHEN '1'.                  "natürliche Person
      c_fkkcolfile-zzname_gp1 = ls_but000-name_first.
      c_fkkcolfile-zzname_gp2 = ls_but000-name_last.
      c_fkkcolfile-zzname_gp3 = ls_but000-namemiddle. " Ehepartner

    WHEN '2'.                  "Organisation.
      c_fkkcolfile-zzname_gp1 = ls_but000-name_org1.
      c_fkkcolfile-zzname_gp2 = ls_but000-name_org2.
      c_fkkcolfile-zzname_gp3 = ls_but000-name_org3.
      c_fkkcolfile-zzname_gp4 = ls_but000-name_org4.

    WHEN '3'.                    "Gruppe
      c_fkkcolfile-zzname_gp1 = ls_but000-name_grp1.
      c_fkkcolfile-zzname_gp2 = ls_but000-name_grp2.

  ENDCASE.


* Geburtsdatum
  c_fkkcolfile-zzbirthdt = ls_but000-birthdt.

*  Adresse zum GP ermitteln
  CLEAR ls_eadrdat.
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'B'
      x_partner                  = c_fkkcolfile-gpart
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

  MOVE ls_eadrdat-city1      TO c_fkkcolfile-zzcity1gp.
  MOVE ls_eadrdat-city2      TO c_fkkcolfile-zzcity2gp.
  MOVE ls_eadrdat-post_code1 TO c_fkkcolfile-zzpost_code1gp.
  MOVE ls_eadrdat-street     TO c_fkkcolfile-zzstreetgp.
  MOVE ls_eadrdat-house_num1 TO c_fkkcolfile-zzhouse_num1gp.
  MOVE ls_eadrdat-house_num2 TO c_fkkcolfile-zzhouse_num2gp.
  MOVE ls_eadrdat-country    TO c_fkkcolfile-zzland.

  IF ls_eadrdat-name_co NE space.
    c_fkkcolfile-zzname_gp3 = ls_eadrdat-name_co.
  ENDIF.

* Fax
  CONCATENATE ls_eadrdat-fax_number
              ls_eadrdat-fax_extens
              INTO c_fkkcolfile-zzfax1.

  REFRESH: lt_adr2, lt_adr6.

  SELECT * FROM adr2
    INTO TABLE lt_adr2
    WHERE addrnumber = ls_eadrdat-addrnumber.

  LOOP AT lt_adr2 INTO ls_adr2.
    CASE ls_adr2-r3_user.
      WHEN '1'.
        c_fkkcolfile-zztel1 = ls_adr2-tel_number.
      WHEN '3'.
        c_fkkcolfile-zzmobil = ls_adr2-tel_number.
    ENDCASE.
  ENDLOOP.

  SELECT * FROM adr6
    INTO  TABLE lt_adr6
    WHERE addrnumber = ls_eadrdat-addrnumber.

  LOOP AT lt_adr6 INTO ls_adr6.
    IF ls_adr6-flgdefault = 'X'.
      c_fkkcolfile-zzsmtp = ls_adr6-smtp_addr.
    ENDIF.
  ENDLOOP.

*** Erweiterung Bankdaten
  CALL FUNCTION 'BUPA_BANKDETAILS_GET'
    EXPORTING
      iv_partner     = c_fkkcolfile-gpart
      iv_valid_date  = sy-datlo
    TABLES
      et_bankdetails = lt_bankdetails.

  CLEAR ls_fkkvkp.
  SELECT SINGLE * FROM fkkvkp INTO ls_fkkvkp
    WHERE vkont = c_fkkcolfile-vkont
      AND gpart = c_fkkcolfile-gpart.

  IF ls_fkkvkp-ebvty IS NOT INITIAL.
    READ TABLE lt_bankdetails INTO ls_bankdetails
         WITH KEY bankdetailid = ls_fkkvkp-ebvty.
  ELSE.
    READ TABLE lt_bankdetails INTO ls_bankdetails INDEX 1.
  ENDIF.

  IF sy-subrc = 0.
**  BLZ und Kontonummer, IBAN sowie abw. Kontoinhaber
    c_fkkcolfile-zzbankl = ls_bankdetails-bank_key.
    c_fkkcolfile-zzbankn = ls_bankdetails-bank_acct.
    c_fkkcolfile-zzkoinh = ls_bankdetails-accountholder.
    c_fkkcolfile-zziban  = ls_bankdetails-iban.

**  Name der Bank und BIC
    CLEAR ls_bnka.
    SELECT SINGLE * FROM bnka INTO ls_bnka
      WHERE banks = ls_bankdetails-bank_ctry
        AND bankl = ls_bankdetails-bank_key.
    IF sy-subrc = 0.
      c_fkkcolfile-zzbanka = ls_bnka-banka.
      c_fkkcolfile-zzswift = ls_bnka-swift.
    ENDIF.
  ENDIF.

* Vertrag ermitteln
  CLEAR ls_fkkop.
  READ TABLE t_fkkop INTO ls_fkkop
    WITH KEY opbel = c_fkkcolfile-opbel
             vkont = c_fkkcolfile-vkont.

  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_fkkop-vtref
      IMPORTING
        output = c_fkkcolfile-zzvertrag.
  ENDIF.

*   Adresse der Verbrauchsstelle
  CLEAR ls_ever.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = c_fkkcolfile-zzvertrag
    IMPORTING
      output = lv_vertrag.

  SELECT SINGLE * FROM ever INTO ls_ever
    WHERE vertrag = lv_vertrag.

* Einzugsdatum
  c_fkkcolfile-zzeinzdat = ls_ever-einzdat.
  c_fkkcolfile-zzvt_beginn = ls_ever-vbeginn.

** Abrechnungszeitraum Für evuz Einzugs-/Auszugsdatum
  MOVE ls_ever-einzdat TO c_fkkcolfile-zzabrzu.
  MOVE ls_ever-auszdat TO c_fkkcolfile-zzabrzo.

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

  MOVE ls_eadrdat-city1      TO c_fkkcolfile-zzcity1vs.
  MOVE ls_eadrdat-city2      TO c_fkkcolfile-zzcity2vs.
  MOVE ls_eadrdat-post_code1 TO c_fkkcolfile-zzpost_code1vs.
  MOVE ls_eadrdat-street     TO c_fkkcolfile-zzstreetvs.
  MOVE ls_eadrdat-house_num1 TO c_fkkcolfile-zzhouse_num1vs.
  MOVE ls_eadrdat-house_num2 TO c_fkkcolfile-zzhouse_num2vs.


* Text zum Teilvorgang
  CLEAR ls_tfktvot.
  SELECT SINGLE * FROM tfktvot INTO ls_tfktvot
    WHERE spras = sy-langu
      AND applk = 'R'
      AND hvorg = ls_fkkop-hvorg
      AND tvorg = ls_fkkop-tvorg.

  MOVE ls_tfktvot-txt30 TO c_fkkcolfile-zztvorgtxt.

  IF ls_fkkop-hvorg BETWEEN '0200' AND '0299'.
    c_fkkcolfile-zzart = 'HF'.
  ENDIF.

* Sparte (Langtext)
  CLEAR ls_tspat.
  SELECT SINGLE * FROM tspat INTO ls_tspat
     WHERE spras = sy-langu
       AND spart = ls_fkkop-spart.

  MOVE ls_tspat-vtext TO c_fkkcolfile-zzspartxt.

* Fälligkeitsdatum
  MOVE ls_fkkop-faedn TO c_fkkcolfile-zzfaellig.

*{ ADD ILIASS ECHOUAIBI FÜR EVUZ
* EVUZ Zinsdatum (ein Tag nach Fälligkeit)--------------------------------*
  c_fkkcolfile-zzzinsdatum =  ls_fkkop-faedn + 1.

* END EVUZ Zinsdatum (ein Tag nach Fälligkeit)--------------------------------*

* Belegdatum
  CLEAR ls_dfkkko.
  SELECT SINGLE * FROM dfkkko INTO ls_dfkkko
      WHERE opbel = ls_fkkop-opbel.

  MOVE ls_dfkkko-bldat TO c_fkkcolfile-zzbldat.

* Rechnungsnummer = Druckbelegnummer = XBLNR mitgeben
  MOVE ls_dfkkko-xblnr TO c_fkkcolfile-zzrechnung.
* Feld immer auf 16 Stellen voll auffüllen.
  SHIFT c_fkkcolfile-zzrechnung RIGHT DELETING TRAILING space.
  TRANSLATE c_fkkcolfile-zzrechnung USING ' 0'.


* --> Nuss 05.2017
* Jüngste Mahnung
* Jetzt die FKKMAZE lesen / 1. Mahnung SR
  CLEAR lt_fkkmaze.
  SELECT * FROM fkkmaze INTO TABLE lt_fkkmaze
         WHERE gpart = c_fkkcolfile-gpart
         AND   vkont = c_fkkcolfile-vkont
         AND   opbel = c_fkkcolfile-opbel
         AND   mahns = '01'
         AND   xmsto = space.

  IF sy-subrc = 0.
    SORT lt_fkkmaze BY ausdt DESCENDING.
    READ TABLE lt_fkkmaze INTO ls_fkkmaze INDEX 1.
    MOVE ls_fkkmaze-ausdt TO c_fkkcolfile-zzausdt.
  ENDIF.

ENDFUNCTION.
