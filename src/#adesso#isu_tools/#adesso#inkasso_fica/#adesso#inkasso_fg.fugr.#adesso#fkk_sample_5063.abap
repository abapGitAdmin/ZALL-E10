FUNCTION /adesso/fkk_sample_5063.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_FKKCOLL) LIKE  DFKKCOLL STRUCTURE  DFKKCOLL
*"  TABLES
*"      T_FKKOP STRUCTURE  FKKOP
*"      T_FKKMAZE STRUCTURE  FKKMAZE
*"  CHANGING
*"     VALUE(C_FKKCOLFILE) LIKE  FKKCOLFILE STRUCTURE  FKKCOLFILE
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
  DATA: h_tabix TYPE sytabix.

** --> Nuss 05.2017
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

  DATA: ls_text TYPE /adesso/ink_text.
  DATA: ls_ink_addi TYPE /adesso/ink_addi.

  DATA: ls_colfile_p TYPE dfkkcolfile_p_w.


  PERFORM clear_ci_colfile USING c_fkkcolfile.


  SELECT SINGLE * FROM but000 INTO ls_but000
    WHERE partner = c_fkkcolfile-gpart.

  SELECT SINGLE * FROM tsad3t INTO ls_tsad3t
  WHERE title = ls_but000-title.

  c_fkkcolfile-zzanrede = ls_tsad3t-title_medi.

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
    CLEAR ls_eadrdat.
  ENDIF.

* Name des Geschäftspartners ermitteln
* Hängt vom GP-Typ ab.
  CASE ls_but000-type.
    WHEN '1'.                  "natürliche Person
      c_fkkcolfile-zzname_gp1 = ls_but000-name_first.
      c_fkkcolfile-zzname_gp2 = ls_but000-name_last.
      c_fkkcolfile-zzname_gp3 = ls_but000-namemiddle. " Ehepartner
      c_fkkcolfile-zzname_gp4 = ls_but000-name_lst2.  " Ehepartner

    WHEN OTHERS.                  "Organisation.
      c_fkkcolfile-zzname_gp1 = ls_eadrdat-name1.
      c_fkkcolfile-zzname_gp2 = ls_eadrdat-name2.
      c_fkkcolfile-zzname_gp3 = ls_eadrdat-name3.
      c_fkkcolfile-zzname_gp4 = ls_eadrdat-name4.
  ENDCASE.



  c_fkkcolfile-zzname_cogp = ls_eadrdat-name_co.

  IF ls_eadrdat-po_box NE space.
    MOVE ls_eadrdat-country TO c_fkkcolfile-zzland.
    MOVE ls_eadrdat-city1 TO c_fkkcolfile-zzcity1gp.
    MOVE ls_eadrdat-post_code2 TO c_fkkcolfile-zzpost_code1gp.
    CONCATENATE 'Postfach' ls_eadrdat-po_box
                  INTO c_fkkcolfile-zzstreetgp
                  SEPARATED BY space.
  ELSE.
    MOVE ls_eadrdat-city1 TO c_fkkcolfile-zzcity1gp.
    MOVE ls_eadrdat-city2 TO c_fkkcolfile-zzcity2gp.
    MOVE ls_eadrdat-post_code1 TO c_fkkcolfile-zzpost_code1gp.
    MOVE ls_eadrdat-street TO c_fkkcolfile-zzstreetgp.
    MOVE ls_eadrdat-house_num1 TO c_fkkcolfile-zzhouse_num1gp.
    MOVE ls_eadrdat-house_num2 TO c_fkkcolfile-zzhouse_num2gp.
    MOVE ls_eadrdat-country TO c_fkkcolfile-zzland.
  ENDIF.

* Telefonnummern
  MOVE ls_eadrdat-tel_number  TO c_fkkcolfile-zztel1.
  MOVE ls_eadrdat-tel_extens  TO c_fkkcolfile-zztel2.
  MOVE ls_eadrdat-fax_number  TO c_fkkcolfile-zzfax1.
  MOVE ls_eadrdat-fax_extens  TO c_fkkcolfile-zzfax2.

*** --> Nuss 05.2017
*** Zusätzlich E-Mail-Adresse
  CLEAR ls_adr6.
  SELECT * FROM adr6 INTO ls_adr6
     WHERE addrnumber = ls_eadrdat-addrnumber.
    MOVE ls_adr6-smtp_addr TO c_fkkcolfile-zzsmtp.
    EXIT.
  ENDSELECT.


  CLEAR ls_fkkvkp.
  SELECT SINGLE * FROM fkkvkp INTO ls_fkkvkp
    WHERE vkont = c_fkkcolfile-vkont
      AND gpart = c_fkkcolfile-gpart.

  MOVE ls_fkkvkp-kofiz_sd TO c_fkkcolfile-zzkofiz_sd.

*  Adresse zum AbwRE ermitteln
  IF ls_fkkvkp-abwrh NE space.
    CLEAR ls_eadrdat.
    CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
      EXPORTING
        x_address_type             = 'B'
        x_partner                  = ls_fkkvkp-abwrh
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
      CLEAR ls_eadrdat.
    ENDIF.

    CONCATENATE ls_eadrdat-name1
                ls_eadrdat-name2
                ls_eadrdat-name3
                ls_eadrdat-name4
                INTO c_fkkcolfile-zzname_re
                SEPARATED BY space.

    c_fkkcolfile-zzname_core = ls_eadrdat-name_co.

    IF ls_eadrdat-po_box NE space.
      CONCATENATE 'Postfach'
                  ls_eadrdat-po_box
                  INTO c_fkkcolfile-zzstreet_re
                  SEPARATED BY space.

      CONCATENATE ls_eadrdat-country
                  ls_eadrdat-post_code2
                  ls_eadrdat-city1
                  INTO c_fkkcolfile-zzcity_re
                  SEPARATED BY space.
    ELSE.
      CONCATENATE ls_eadrdat-street
                  ls_eadrdat-house_num1
                  ls_eadrdat-house_num2
                  INTO c_fkkcolfile-zzstreet_re
                  SEPARATED BY space.

      CONCATENATE ls_eadrdat-country
                  ls_eadrdat-post_code1
                  ls_eadrdat-city1
                  ls_eadrdat-city2
                  INTO c_fkkcolfile-zzcity_re
                  SEPARATED BY space.
    ENDIF.

  ENDIF.

*** Erweiterung Bankdaten
  IF ls_fkkvkp-ebvty IS NOT INITIAL.
    CLEAR ls_but0bk.
    SELECT SINGLE * FROM but0bk INTO ls_but0bk
      WHERE partner = c_fkkcolfile-gpart
       AND bkvid = ls_fkkvkp-ebvty.
    IF sy-subrc = 0.
**   BLZ und Kontonummer sowie abw. Kontoinhaber
      MOVE ls_but0bk-bankl TO c_fkkcolfile-zzbankl.
      MOVE ls_but0bk-bankn TO c_fkkcolfile-zzbankn.
      MOVE ls_but0bk-koinh TO c_fkkcolfile-zzkoinh.
**    IBAN
      CLEAR ls_tiban.
      SELECT * FROM tiban INTO ls_tiban
        WHERE banks = ls_but0bk-banks
          AND bankl = ls_but0bk-bankl
          AND bankn = ls_but0bk-bankn.
        MOVE ls_tiban-iban TO c_fkkcolfile-zziban.
        EXIT.
      ENDSELECT.
**    Name der Bank und BIC
      CLEAR ls_bnka.
      SELECT SINGLE * FROM bnka INTO ls_bnka
        WHERE banks = ls_but0bk-banks
          AND bankl = ls_but0bk-bankl.

      MOVE ls_bnka-banka TO c_fkkcolfile-zzbanka.
      MOVE ls_bnka-swift TO c_fkkcolfile-zzswift.

    ENDIF.


  ENDIF.
** --> Ende Nuss 05.2017

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

  MOVE ls_eadrdat-city1 TO c_fkkcolfile-zzcity1vs.
  MOVE ls_eadrdat-city2 TO c_fkkcolfile-zzcity2vs.
  MOVE ls_eadrdat-post_code1 TO c_fkkcolfile-zzpost_code1vs.
  MOVE ls_eadrdat-street TO c_fkkcolfile-zzstreetvs.
  MOVE ls_eadrdat-house_num1 TO c_fkkcolfile-zzhouse_num1vs.
  MOVE ls_eadrdat-house_num2 TO c_fkkcolfile-zzhouse_num2vs.

** Abrechnungszeitraum
  MOVE ls_fkkop-abrzu TO c_fkkcolfile-zzabrzu.
  MOVE ls_fkkop-abrzo TO c_fkkcolfile-zzabrzo.

* Text zum Teilvorgang
  CLEAR ls_tfktvot.
  SELECT SINGLE * FROM tfktvot INTO ls_tfktvot
    WHERE spras = sy-langu
      AND applk = 'R'
      AND hvorg = ls_fkkop-hvorg
      AND tvorg = ls_fkkop-tvorg.

  MOVE ls_tfktvot-txt30 TO c_fkkcolfile-zztvorgtxt.

** --> Nuss 05.2017
* Forderungsart
  CLEAR ls_nfhf.
  SELECT SINGLE * FROM /adesso/ink_nfhf INTO ls_nfhf
    WHERE hvorg = ls_fkkop-hvorg.
  IF sy-subrc = 0.
    MOVE ls_nfhf-art TO c_fkkcolfile-zzart.
  ELSE.
    c_fkkcolfile-zzart = 'NF'.
  ENDIF.
* <-- Nuss 05.2017


* Sparte (Langtext)
  CLEAR ls_tspat.
  SELECT SINGLE * FROM tspat INTO ls_tspat
     WHERE spras = sy-langu
       AND spart = ls_fkkop-spart.

  MOVE ls_tspat-vtext TO c_fkkcolfile-zzspartxt.

* Fälligkeitsdatum
  MOVE ls_fkkop-faedn TO c_fkkcolfile-zzfaellig.

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
  CLEAR: lt_cust.
  SELECT * FROM /adesso/ink_cust INTO TABLE lt_cust.
*  Mahnstufe
  CLEAR: ls_cust, lv_mahns.
  READ TABLE lt_cust INTO ls_cust
     WITH KEY inkasso_option = 'FKKMAZE'
              inkasso_field   = 'MAHNS'.
  IF sy-subrc = 0.
    lv_mahns = ls_cust-inkasso_value.
  ENDIF.
*  Mahnverfahren
  CLEAR: ls_cust, lv_mahnv.
  READ TABLE lt_cust INTO ls_cust
  WITH KEY inkasso_option = 'FKKMAZE'
           inkasso_field = 'MAHNV'.
  IF sy-subrc = 0.
    lv_mahnv = ls_cust-inkasso_value.
  ENDIF.

* Jetzt die FKKMAZE lesen und die jüngste Mahnung zum Beleg, Mahnstufe und Mahnverfahren
* lesen.
  IF lv_mahns IS NOT INITIAL AND lv_mahnv IS NOT INITIAL.
    CLEAR lt_fkkmaze.
    SELECT * FROM fkkmaze INTO TABLE lt_fkkmaze
      WHERE gpart = c_fkkcolfile-gpart
        AND vkont = c_fkkcolfile-vkont
        AND opbel = c_fkkcolfile-opbel
        AND mahns = lv_mahns
        AND mahnv = lv_mahnv.
    IF sy-subrc = 0.
      SORT lt_fkkmaze BY ausdt DESCENDING.
      READ TABLE lt_fkkmaze INTO ls_fkkmaze INDEX 1.
      MOVE ls_fkkmaze-ausdt TO c_fkkcolfile-zzausdt.
    ENDIF.

  ENDIF.

** --> Nuss 05.2017
** Freitext lesen
*  CLEAR ls_text.
*  SELECT * FROM /adesso/ink_text INTO ls_text
*    WHERE gpart = c_fkkcolfile-gpart
*      AND vkont = c_fkkcolfile-vkont
*      AND opbel = c_fkkcolfile-opbel.
*    EXIT.
*  ENDSELECT.
*  IF ls_text IS NOT INITIAL.
*    MOVE ls_text-freetext TO c_fkkcolfile-zzfreetext.
*  ENDIF.
** <-- Nuss 05.2017

** Freitext und Zusatzinfos lesen
  SELECT SINGLE * FROM /adesso/ink_addi INTO ls_ink_addi
    WHERE gpart = c_fkkcolfile-gpart
      AND vkont = c_fkkcolfile-vkont
      AND inkgp = i_fkkcoll-inkgp
      AND agdat = i_fkkcoll-agdat.

  IF sy-subrc = 0.

    c_fkkcolfile-zzfreetext  = ls_ink_addi-freetext.
    c_fkkcolfile-zzunbverz   = ls_ink_addi-unbverz.
    c_fkkcolfile-zzminderj   = ls_ink_addi-minderj.
    c_fkkcolfile-zzerbenhaft = ls_ink_addi-erbenhaft.
    c_fkkcolfile-zzbetreuung = ls_ink_addi-betreuung.
    c_fkkcolfile-zzinsolvenz = ls_ink_addi-insolvenz.

  ENDIF.

  CLEAR ls_colfile_p.
  MOVE-CORRESPONDING c_fkkcolfile TO ls_colfile_p.

  IF gf_laufd IS NOT INITIAL.
    ls_colfile_p-laufd = gf_laufd.
    ls_colfile_p-laufi = gf_laufi.
    ls_colfile_p-inkgp = i_fkkcoll-inkgp.
    INSERT dfkkcolfile_p_w FROM ls_colfile_p.
  ENDIF.

ENDFUNCTION.
