FUNCTION /ADESSO/FKK_SAMPLE_5052_SWK.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_POSTYP) TYPE  POSTYP_KK
*"     REFERENCE(I_FKKCOLLH_I) LIKE  FKKCOLLH_I STRUCTURE  FKKCOLLH_I
*"         OPTIONAL
*"     REFERENCE(I_LFDNR) TYPE  LFDNR_KK OPTIONAL
*"  CHANGING
*"     REFERENCE(C_FKKCOLLP_IM) LIKE  FKKCOLLP_IM
*"  STRUCTURE  FKKCOLLP_IM OPTIONAL
*"     REFERENCE(C_FKKCOLLP_IP) LIKE  FKKCOLLP_IP
*"  STRUCTURE  FKKCOLLP_IP OPTIONAL
*"     REFERENCE(C_FKKCOLLP_IR) LIKE  FKKCOLLP_IR
*"  STRUCTURE  FKKCOLLP_IR OPTIONAL
*"--------------------------------------------------------------------

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
        lv_mahnkost TYPE mge1m_kk.


  DATA: lt_fkkop_ag TYPE TABLE OF fkkop.
  DATA: ls_fkkop_ag TYPE fkkop.
  DATA: h_tabix TYPE sytabix.

  DATA: ls_fkkvkp  TYPE fkkvkp,
        ls_but0bk  TYPE but0bk,
        ls_tiban   TYPE tiban,
        ls_bnka    TYPE bnka,
        ls_adr6    TYPE adr6,
        ls_nfhf    TYPE /adesso/nfhf,
        ls_cust    TYPE /adesso/ink_cust,
        lt_cust    TYPE STANDARD TABLE OF /adesso/ink_cust,
        lt_fkkmaze TYPE STANDARD TABLE OF fkkmaze.

  DATA: lv_mahnv TYPE mahnv_kk,
        lv_mahns TYPE mahns_kk.




  CASE i_postyp .

    WHEN '1'
      OR '5'.   "Ausgleich bzw. Teilsausgleich

*     Payment: use structure C_FKKCOLLP_IP
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
*         X_LENGTH                   = 80
*         X_LINE_COUNT               = 1
*         X_PRGCONTEXT               = ' '
*         X_SUBCONTEXT               = ' '
*         X_READ_ADRC_REGIO          = ' '
*         X_READ_ISU_DATA            = ' '
*         X_READ_MRU                 = ' '
*         X_READ_KONZ                = ' '
*         X_READ_BUKRS               = ' '
*         X_READ_ROUTE               = ' '
*         X_READ_GRID                = ' '
*         X_READ_AMS                 = ' '
*         X_READ_CUST_REGIO          = ' '
*         X_ADDRNUMBER               =
          x_partner                  = c_fkkcollp_ip-gpart
*         X_ACCOUNT                  =
*         X_PERSNUMBER               =
*         X_HAUS                     =
*         X_VSTELLE                  =
*         X_DEVLOC                   =
*         X_ANLAGE                   =
*         X_INT_UI                   =
*         X_ROB                      =
*         X_PROP                     =
*         X_ADDR1_VAL                =
*         X_EKUN_EXT                 =
*         X_FKKVKP1                  =
*         X_EHAU                     =
*         X_EVBS                     =
*         X_EGPL                     =
*         X_EANL                     =
*         X_EEWA_ROB                 =
*         X_EEWA_PROP                =
*         X_ACTUAL                   =
*         X_CHANGED_ADDRESS          = ' '
*         X_BUKRS                    = ' '
*         X_SPARTE                   = ' '
*         X_AKLASSE                  = ' '
*         X_SPEBENE                  = ' '
*         X_GRID_LEVEL_TYPE          = ' '
*         X_GRID_LEVEL               = ' '
*         X_ADDR_OBJ                 =
*         X_KEYDATE                  =
*         X_NATION                   = ' '
*         X_REFRESH_ADDRESS          =
        IMPORTING
*         Y_ADDR_LINES               =
*         Y_LINE_COUNT               =
          y_eadrdat                  = ls_eadrdat
*         Y_ADRC_REGIO               =
*         Y_ADDR_DATA                =
*         Y_CUST_REGIO               =
*         Y_EHAU                     =
*         Y_IEADRC                   =
* TABLES
*         T_ISU_REGK                 =
*         T_ISU_REGS                 =
*         T_ISU_REGR                 =
*         T_ISU_REGG                 =
*         T_ISU_REGA                 =
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
*         X_LENGTH                   = 80
*         X_LINE_COUNT               = 1
*         X_PRGCONTEXT               = ' '
*         X_SUBCONTEXT               = ' '
*         X_READ_ADRC_REGIO          = ' '
*         X_READ_ISU_DATA            = ' '
*         X_READ_MRU                 = ' '
*         X_READ_KONZ                = ' '
*         X_READ_BUKRS               = ' '
*         X_READ_ROUTE               = ' '
*         X_READ_GRID                = ' '
*         X_READ_AMS                 = ' '
*         X_READ_CUST_REGIO          = ' '
*         X_ADDRNUMBER               =
*         X_PARTNER                  =
*         X_ACCOUNT                  =
*         X_PERSNUMBER               =
*         X_HAUS                     =
*         X_VSTELLE                  =
*         X_DEVLOC                   =
          x_anlage                   = ls_ever-anlage
*         X_INT_UI                   =
*         X_ROB                      =
*         X_PROP                     =
*         X_ADDR1_VAL                =
*         X_EKUN_EXT                 =
*         X_FKKVKP1                  =
*         X_EHAU                     =
*         X_EVBS                     =
*         X_EGPL                     =
*         X_EANL                     =
*         X_EEWA_ROB                 =
*         X_EEWA_PROP                =
*         X_ACTUAL                   =
*         X_CHANGED_ADDRESS          = ' '
*         X_BUKRS                    = ' '
*         X_SPARTE                   = ' '
*         X_AKLASSE                  = ' '
*         X_SPEBENE                  = ' '
*         X_GRID_LEVEL_TYPE          = ' '
*         X_GRID_LEVEL               = ' '
*         X_ADDR_OBJ                 =
*         X_KEYDATE                  =
*         X_NATION                   = ' '
*         X_REFRESH_ADDRESS          =
        IMPORTING
*         Y_ADDR_LINES               =
*         Y_LINE_COUNT               =
          y_eadrdat                  = ls_eadrdat
*         Y_ADRC_REGIO               =
*         Y_ADDR_DATA                =
*         Y_CUST_REGIO               =
*         Y_EHAU                     =
*         Y_IEADRC                   =
*     TABLES
*         T_ISU_REGK                 =
*         T_ISU_REGS                 =
*         T_ISU_REGR                 =
*         T_ISU_REGG                 =
*         T_ISU_REGA                 =
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

** Zusätzliche Daten zur Zahlung
      CLEAR ls_dfkkzp.
      SELECT * FROM dfkkzp INTO ls_dfkkzp
        WHERE opbel = c_fkkcollp_ip-opbel.

        MOVE ls_dfkkzp-opbel TO c_fkkcollp_ip-zzopbel.
        MOVE ls_dfkkzp-valut TO c_fkkcollp_ip-zzvaluta.
        MOVE ls_dfkkzp-betrz TO c_fkkcollp_ip-zzbetrz.
        MOVE ls_dfkkzp-koinh TO c_fkkcollp_ip-zzkoinhzahlung.
        MOVE ls_dfkkzp-iban  TO c_fkkcollp_ip-zzibanzahlung.
        MOVE ls_dfkkzp-txtvw TO c_fkkcollp_ip-zztxtvw.
        EXIT.
      ENDSELECT.



*   when '2' .
*     Recall: use structure C_FKKCOLLP_IR


*   when '3' .
*     Master data changes: use structure C_FKKCOLLP_IM

  ENDCASE .



ENDFUNCTION.
