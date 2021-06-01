FUNCTION /ADESSO/ENET_GET_PREIS_ANL_GAS .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(ABR_AB) TYPE  INV_DATE_FROM
*"     REFERENCE(ABR_BIS) TYPE  INV_DATE_TO
*"     REFERENCE(DISPLAY) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(ABR_PREIS) TYPE  /ADESSO/ENET_PREIS OPTIONAL
*"     REFERENCE(INT_INV_DOC_NO) TYPE  INV_INT_INV_DOC_NO OPTIONAL
*"  EXPORTING
*"     REFERENCE(ZAEHLERFREMD) TYPE  BOOLEAN
*"  CHANGING
*"     REFERENCE(ARTIKEL_PREIS) TYPE  /ADESSO/ENET_PREIS_ARTIKEL_T
*"       OPTIONAL
*"  EXCEPTIONS
*"      KEIN_NETZ
*"----------------------------------------------------------------------
  TYPES: BEGIN OF t_preise,
           betrieb TYPE /adesso/enet_preise_t,
           messung TYPE /adesso/enet_preise_t,
           summe   TYPE /adesso/enet_preise_t,
           abrech  TYPE /adesso/enet_preise_t,
           hardw   TYPE /adesso/enet_preise_t,
           dienstl TYPE /adesso/enet_preise_t,
           gp      TYPE /adesso/enet_preise_t,
           ap      TYPE /adesso/enet_preise_t,
           lp      TYPE /adesso/enet_preise_t,
           farb    TYPE /adesso/enet_preise_t,
           flei    TYPE /adesso/enet_preise_t,
           ka      TYPE /adesso/enet_preise_t,
           kwk_a   TYPE /adesso/enet_preise_t,
           kwk_b   TYPE /adesso/enet_preise_t,
         END OF t_preise.


  DATA: ls_eanl           TYPE eanl,
        ls_preise         TYPE t_preise,
        lt_adrc           TYPE TABLE OF adrc,
        ls_adrc           TYPE adrc,
        ls_euigrid        TYPE euigrid,
        lv_int_ui         TYPE int_ui,
        lv_aklasse        TYPE aklasse,
        lv_zaehler_id     TYPE /adesso/zaehlerd,
        lv_spebene(2)     TYPE c,
        ls_eanlh          TYPE eanlh,
        nd_vnbg_nr        TYPE  /adesso/enet_gas_vnbg_nr,
        nd_teilnetz_nr    TYPE  /adesso/enet_gas_teilnetz_nr,
        nd_netzbereich_nr TYPE  /adesso/enet_gas_netzber_nr,
        md_vnbg_nr        TYPE  /adesso/enet_gas_vnbg_nr,
        md_teilnetz_nr    TYPE  /adesso/enet_gas_teilnetz_nr,
        md_netzbereich_nr TYPE  /adesso/enet_gas_netzber_nr,
        hd_vnbg_nr        TYPE  /adesso/enet_gas_vnbg_nr,
        hd_teilnetz_nr    TYPE  /adesso/enet_gas_teilnetz_nr,
        hd_netzbereich_nr TYPE  /adesso/enet_gas_netzber_nr,
        ka_id             TYPE  /adesso/enet_gas_vnbg_nr,
        lv_rlmslp         TYPE c, "1 = RLM 0 = SLP
        lv_custrlmslp     TYPE string,
        lv_custreport     TYPE string,
        lv_vnbg_nr        TYPE  /adesso/enet_gas_vnbg_nr,
        lv_teilnetz_nr    TYPE  /adesso/enet_gas_teilnetz_nr,
        lv_netzbereich_nr TYPE  /adesso/enet_gas_netzber_nr,
        ls_netzbereich    TYPE /adesso/g_bereic.

  SELECT SINGLE * FROM eanl
    INTO ls_eanl
    WHERE anlage = anlage.


  CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
    EXPORTING
      x_address_type             = 'I'
      x_anlage                   = anlage
    IMPORTING
      y_ieadrc                   = lt_adrc
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

  "Kunden Exit zum Identifikatiom RLM/SLP
  SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custreport WHERE report = 'GLOBAL' AND field = 'CUST_REPORT'.
  SELECT SINGLE value FROM /adesso/inv_cust INTO lv_custrlmslp WHERE report = 'GLOBAL' AND field = 'RLMSLP_FORM'.
  IF lv_custrlmslp IS NOT INITIAL AND lv_custreport IS NOT INITIAL.
    CALL FUNCTION '/ADESSO/CUST_RLM_SLP'
      EXPORTING
        anlage       = anlage
        datbis       = abr_bis
        datab        = abr_ab
        custform     = lv_custrlmslp
        custprogramm = lv_custreport
      IMPORTING
        rlmslp       = lv_rlmslp.
  ELSE.
    SELECT * FROM eanlh INTO ls_eanlh
      WHERE anlage = anlage
        AND bis GE abr_bis.
      EXIT.
    ENDSELECT.

    IF ls_eanlh-aklasse = '02'. "Sonderkunden
      lv_rlmslp = '1'.
    ELSE.
      lv_rlmslp = '0'.
    ENDIF.
  ENDIF.

  READ TABLE lt_adrc INTO ls_adrc INDEX 1.

  CALL FUNCTION '/ADESSO/ENET_NETZE_ZU_ADR_GAS'
    EXPORTING
      adrc              = ls_adrc
      ab                = abr_ab
    IMPORTING
      nd_vnbg_nr        = nd_vnbg_nr
      nd_teilnetz_nr    = nd_teilnetz_nr
      nd_netzbereich_nr = nd_netzbereich_nr
      md_vnbg_nr        = md_vnbg_nr
      md_teilnetz_nr    = md_teilnetz_nr
      md_netzbereich_nr = md_netzbereich_nr
      hd_vnbg_nr        = hd_vnbg_nr
      hd_teilnetz_nr    = hd_teilnetz_nr
      hd_netzbereich_nr = hd_netzbereich_nr
      ka_id             = ka_id
    EXCEPTIONS
      kein_netz         = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

    if lv_spebene IS INITIAL.
    SELECT SINGLE int_ui FROM euiinstln INTO lv_int_ui
      WHERE anlage = anlage
      AND datefrom le abr_bis
      AND dateto ge abr_bis.
    SELECT SINGLE * FROM euigrid INTO ls_euigrid
      WHERE int_ui = lv_int_ui
      AND datefrom le abr_bis
      AND dateto ge abr_bis.
      lv_spebene = ls_euigrid-grid_level.

  ENDIF.

"  SELECT SINGLE adspebene FROM /adesso/ec_spebn INTO lv_spebene WHERE custspebene = ls_eanl-spebene AND sparte = 'GA'.
  CASE lv_spebene.
    WHEN 'NV' or 'ND'.
      lv_vnbg_nr          = nd_vnbg_nr.
      lv_teilnetz_nr      = nd_teilnetz_nr.
      lv_netzbereich_nr   = nd_netzbereich_nr.
    WHEN 'MV' or 'MD'.
      lv_vnbg_nr        =  md_vnbg_nr.
      lv_teilnetz_nr    =  md_teilnetz_nr.
      lv_netzbereich_nr =  md_netzbereich_nr.
    WHEN 'HD' or 'HV'.
      lv_vnbg_nr          = hd_vnbg_nr.
      lv_teilnetz_nr      = hd_teilnetz_nr.
      lv_netzbereich_nr   = hd_netzbereich_nr.
    WHEN OTHERS.
      lv_vnbg_nr          = nd_vnbg_nr.
      lv_teilnetz_nr      = nd_teilnetz_nr.
      lv_netzbereich_nr   = nd_netzbereich_nr.
  ENDCASE.

  SELECT SINGLE * FROM /adesso/g_bereic
    INTO ls_netzbereich
    WHERE vnbg_nr  = lv_vnbg_nr
      AND teilnetz_nr = lv_teilnetz_nr
      AND netzbereich_nr =  lv_netzbereich_nr.

  IF sy-subrc <> 0.
  "  MESSAGE 'Kein gültiges Netz gefunden' TYPE 'E'.
    RAISE kein_netz.
  ENDIF.

   SELECT aklasse FROM eanlh INTO lv_aklasse
        WHERE anlage = ANLAGE
          AND bis GE abr_bis.
      EXIT.
    ENDSELECT.

  CALL FUNCTION '/ADESSO/ENET_ZAEHLERNR_GAS'
    EXPORTING
      anlage       = anlage
      abr_preis    = abr_preis
      vnbg_nr      = ls_netzbereich-vnbg_nr
      tarifgebiet  = ls_netzbereich-tarifgebiet
      spebene      = lv_spebene
      rlmslp      = lv_rlmslp
      ab           = abr_ab
      bis          = abr_bis
    IMPORTING
      zahlernummer = lv_zaehler_id
      fremd        = zaehlerfremd.

    CALL FUNCTION '/ADESSO/ENET_MDIENST_ENT_GAS'
      EXPORTING
        mdienst_nr          = ls_netzbereich-standard_mdienst
        messgebiet_nr       = ls_netzbereich-standard_gebiet_mdienst
        anlage              = anlage
        ab                  = abr_ab
        bis                 = abr_bis
        zaehlernr           = lv_zaehler_id
     IMPORTING
       BETRIEB             = ls_preise-betrieb
       MESSUNG             = ls_preise-messung
       SUMME               = ls_preise-summe
       HARDW               = ls_preise-hardw
       dienstl             = ls_preise-dienstl
     EXCEPTIONS
       KEIN_DIENSTL        = 1
       FALSCHE_DATEN       = 2
       OTHERS              = 3
              .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

CALL FUNCTION '/ADESSO/ENET_ABRECHNUNG_GAS'
  EXPORTING
    vnbg_nr           = ls_netzbereich-vnbg_nr
    tarifgebiet       = ls_netzbereich-tarifgebiet
    anlage            = anlage
    zaehlerid         = lv_zaehler_id
    ab                = abr_ab
    bis               = abr_bis
 IMPORTING
   PREISE            = ls_preise-abrech
          .

CALL FUNCTION '/ADESSO/ENET_NNE_GAS'
  EXPORTING
    vnbg_nr              = ls_netzbereich-vnbg_nr
    tarifgebiet          = ls_netzbereich-tarifgebiet
    anlage               = anlage
    int_inv_doc_no       = int_inv_doc_no
    ab                   = abr_ab
    bis                  = abr_bis
    zaehlernr            = lv_zaehler_id
 IMPORTING
   AP                   = ls_preise-ap
   LP                   = ls_preise-lp
   GP                   = ls_preise-gp
   farb                  = ls_preise-FARB
   flei                  = ls_preise-FLEI
          .

CALL FUNCTION '/ADESSO/ENET_KA_GAS'
  EXPORTING
    ka_id           =  ka_id
    ab              = abr_ab
    bis             = abr_bis
    int_inv_doc_no = int_inv_doc_no
 IMPORTING
   PREISE          = ls_preise-ka
          .

  CALL FUNCTION '/ADESSO/ENET_MAPPING_GAS'
    EXPORTING
      i_preise   = ls_preise
    IMPORTING
      art_preise = artikel_preis.


  break struck-f.
  IF display = 'X'.

    CALL FUNCTION '/ADESSO/ENET_DISPLAY_GAS'
      EXPORTING
        i_preise = ls_preise.


  ENDIF.



ENDFUNCTION.
