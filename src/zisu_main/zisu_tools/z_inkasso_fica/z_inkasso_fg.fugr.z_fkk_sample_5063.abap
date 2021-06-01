FUNCTION z_fkk_sample_5063.
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

  SELECT SINGLE * FROM but000 INTO ls_but000
    WHERE partner = c_fkkcolfile-gpart.

  CLEAR c_fkkcolfile-zzanrede.

  SELECT SINGLE * FROM tsad3t INTO ls_tsad3t
  WHERE title = ls_but000-title.

  c_fkkcolfile-zzanrede = ls_tsad3t-title_medi.

* Name des Geschäftspartners ermitteln
* Hängt vom GP-Typ ab.

  CLEAR c_fkkcolfile-zzname_gp1.
  CLEAR c_fkkcolfile-zzname_gp2.
  CLEAR c_fkkcolfile-zzname_gp3.
  CLEAR c_fkkcolfile-zzname_gp4.

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
  CLEAR  c_fkkcolfile-zzbirthdt.
  c_fkkcolfile-zzbirthdt = ls_but000-birthdt.

*  Adresse zum GP ermitteln
  CLEAR ls_eadrdat.
  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'B'
*     X_LENGTH                   = 80
*     X_LINE_COUNT               = 1
*     X_PRGCONTEXT               = ' '
*     X_SUBCONTEXT               = ' '
*     X_READ_ADRC_REGIO          = ' '
*     X_READ_ISU_DATA            = ' '
*     X_READ_MRU                 = ' '
*     X_READ_KONZ                = ' '
*     X_READ_BUKRS               = ' '
*     X_READ_ROUTE               = ' '
*     X_READ_GRID                = ' '
*     X_READ_AMS                 = ' '
*     X_READ_CUST_REGIO          = ' '
*     X_ADDRNUMBER               =
      x_partner                  = c_fkkcolfile-gpart
*     X_ACCOUNT                  =
*     X_PERSNUMBER               =
*     X_HAUS                     =
*     X_VSTELLE                  =
*     X_DEVLOC                   =
*     X_ANLAGE                   =
*     X_INT_UI                   =
*     X_ROB                      =
*     X_PROP                     =
*     X_ADDR1_VAL                =
*     X_EKUN_EXT                 =
*     X_FKKVKP1                  =
*     X_EHAU                     =
*     X_EVBS                     =
*     X_EGPL                     =
*     X_EANL                     =
*     X_EEWA_ROB                 =
*     X_EEWA_PROP                =
*     X_ACTUAL                   =
*     X_CHANGED_ADDRESS          = ' '
*     X_BUKRS                    = ' '
*     X_SPARTE                   = ' '
*     X_AKLASSE                  = ' '
*     X_SPEBENE                  = ' '
*     X_GRID_LEVEL_TYPE          = ' '
*     X_GRID_LEVEL               = ' '
*     X_ADDR_OBJ                 =
*     X_KEYDATE                  =
*     X_NATION                   = ' '
*     X_REFRESH_ADDRESS          =
    IMPORTING
*     Y_ADDR_LINES               =
*     Y_LINE_COUNT               =
      y_eadrdat                  = ls_eadrdat
*     Y_ADRC_REGIO               =
*     Y_ADDR_DATA                =
*     Y_CUST_REGIO               =
*     Y_EHAU                     =
*     Y_IEADRC                   =
* TABLES
*     T_ISU_REGK                 =
*     T_ISU_REGS                 =
*     T_ISU_REGR                 =
*     T_ISU_REGG                 =
*     T_ISU_REGA                 =
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

  MOVE ls_eadrdat-city1 TO c_fkkcolfile-zzcity1gp.
  MOVE ls_eadrdat-city2 TO c_fkkcolfile-zzcity2gp.
  MOVE ls_eadrdat-post_code1 TO c_fkkcolfile-zzpost_code1gp.
  MOVE ls_eadrdat-street TO c_fkkcolfile-zzstreetgp.
  MOVE ls_eadrdat-house_num1 TO c_fkkcolfile-zzhouse_num1gp.
  MOVE ls_eadrdat-house_num2 TO c_fkkcolfile-zzhouse_num2gp.
  MOVE ls_eadrdat-country TO c_fkkcolfile-zzland.

* Telefonnummern
  CLEAR c_fkkcolfile-zztel1.
  CLEAR c_fkkcolfile-zztel2.
  CLEAR c_fkkcolfile-zzfax1.
  CLEAR c_fkkcolfile-zzfax2.

  MOVE ls_eadrdat-tel_number  TO c_fkkcolfile-zztel1.
  MOVE ls_eadrdat-tel_extens  TO c_fkkcolfile-zztel2.
  MOVE ls_eadrdat-fax_number  TO c_fkkcolfile-zzfax1.
  MOVE ls_eadrdat-fax_extens  TO c_fkkcolfile-zzfax2.

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
*     X_LENGTH                   = 80
*     X_LINE_COUNT               = 1
*     X_PRGCONTEXT               = ' '
*     X_SUBCONTEXT               = ' '
*     X_READ_ADRC_REGIO          = ' '
*     X_READ_ISU_DATA            = ' '
*     X_READ_MRU                 = ' '
*     X_READ_KONZ                = ' '
*     X_READ_BUKRS               = ' '
*     X_READ_ROUTE               = ' '
*     X_READ_GRID                = ' '
*     X_READ_AMS                 = ' '
*     X_READ_CUST_REGIO          = ' '
*     X_ADDRNUMBER               =
*     X_PARTNER                  =
*     X_ACCOUNT                  =
*     X_PERSNUMBER               =
*     X_HAUS                     =
*     X_VSTELLE                  =
*     X_DEVLOC                   =
      x_anlage                   = ls_ever-anlage
*     X_INT_UI                   =
*     X_ROB                      =
*     X_PROP                     =
*     X_ADDR1_VAL                =
*     X_EKUN_EXT                 =
*     X_FKKVKP1                  =
*     X_EHAU                     =
*     X_EVBS                     =
*     X_EGPL                     =
*     X_EANL                     =
*     X_EEWA_ROB                 =
*     X_EEWA_PROP                =
*     X_ACTUAL                   =
*     X_CHANGED_ADDRESS          = ' '
*     X_BUKRS                    = ' '
*     X_SPARTE                   = ' '
*     X_AKLASSE                  = ' '
*     X_SPEBENE                  = ' '
*     X_GRID_LEVEL_TYPE          = ' '
*     X_GRID_LEVEL               = ' '
*     X_ADDR_OBJ                 =
*     X_KEYDATE                  =
*     X_NATION                   = ' '
*     X_REFRESH_ADDRESS          =
    IMPORTING
*     Y_ADDR_LINES               =
*     Y_LINE_COUNT               =
      y_eadrdat                  = ls_eadrdat
*     Y_ADRC_REGIO               =
*     Y_ADDR_DATA                =
*     Y_CUST_REGIO               =
*     Y_EHAU                     =
*     Y_IEADRC                   =
*     TABLES
*     T_ISU_REGK                 =
*     T_ISU_REGS                 =
*     T_ISU_REGR                 =
*     T_ISU_REGG                 =
*     T_ISU_REGA                 =
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
  shift c_fkkcolfile-zzrechnung right deleting trailing space.
  translate c_fkkcolfile-zzrechnung using ' 0'.

* Mahnkosten
* Buchungsdaten Mark-E zu in Faktura umgebuchten Mahnkosten
* Die bei Faktura offenen Mahnkosten werden bei Faktura mit dem Ausstellungsdatum der Rechnung versehen
* und auch so an den DL übermittelt.
* Es müssen hier die Daten der originären Gebührenbelege der Mahnkosten übermittelt werden
* Also echten Mahngebühren-Beleg ermitteln und folgende Felder neu setzen:
* c_fkkcolfile-zzfaellig
* c_fkkcolfile-zzbldat
* c_fkkcolfile-zzrechnung

  LOOP AT t_fkkop INTO ls_fkkop
       WHERE opbel = i_fkkcoll-opbel
       AND   inkps = i_fkkcoll-inkps.

    CHECK ls_fkkop-hvorg = 'KOST'.
    CHECK ls_fkkop-tvorg = 'MAHN'.

* alle ausgeglichenen Posten zum Beleg ermitteln
    CALL FUNCTION 'FKK_CLEARED_ITEMS_SELECT'
      EXPORTING
        i_augbl    = ls_fkkop-opbel
        i_aginf    = '2'
        i_xstat    = 'X'
      TABLES
        t_fkkop_ag = lt_fkkop_ag.

* Falls schon Positionen aus dem Agl-Beleg ausgeglichen geht man davon aus,
* dass dies die Mahngebühren mit dem ältesten Fälligkeitsdatum waren
* Also nach FAEDN sortieren
    SORT lt_fkkop_ag BY faedn.

* Dann gemäß der Position im Agl-Beleg den entsprechenden ausgeglichenen Posten lesen und zordnen
    h_tabix = ls_fkkop-opupk.
    READ TABLE lt_fkkop_ag INTO ls_fkkop_ag INDEX h_tabix.
    IF sy-subrc = 0.
      c_fkkcolfile-zzfaellig  = ls_fkkop_ag-faedn.
      c_fkkcolfile-zzbldat    = ls_fkkop_ag-bldat.
      c_fkkcolfile-zzrechnung = ls_fkkop_ag-opbel.
*    Feld immer auf 16 Stellen voll auffüllen.
     shift c_fkkcolfile-zzrechnung right deleting trailing space.
     translate c_fkkcolfile-zzrechnung using ' 0'.
    ENDIF.

  ENDLOOP.

* Feld immer auf 16 Stellen voll auffüllen.
  shift c_fkkcolfile-zzrechnung right deleting trailing space.
  translate c_fkkcolfile-zzrechnung using ' 0'.

ENDFUNCTION.
