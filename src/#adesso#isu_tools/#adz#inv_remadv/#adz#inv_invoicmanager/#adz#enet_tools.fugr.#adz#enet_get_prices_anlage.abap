FUNCTION /ADZ/ENET_GET_PRICES_ANLAGE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(ABR_AB) TYPE  INV_DATE_FROM
*"     REFERENCE(ABR_BIS) TYPE  INV_DATE_TO
*"     REFERENCE(DISPLAY) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(ABR_PREIS) TYPE  /ADZ/ENET_PREIS OPTIONAL
*"     REFERENCE(INT_INV_DOC_NO) TYPE  INV_INT_INV_DOC_NO OPTIONAL
*"  EXPORTING
*"     REFERENCE(ZAEHLERFREMD) TYPE  BOOLEAN
*"  CHANGING
*"     VALUE(ARTIKEL_PREIS) TYPE  /ADZ/ENET_PREIS_ARTIKEL_T OPTIONAL
*"  EXCEPTIONS
*"      KEIN_NETZ
*"----------------------------------------------------------------------

  TYPES: BEGIN OF t_preise,
           betrieb TYPE /adz/enet_preise_t,
           messung TYPE /adz/enet_preise_t,
           summe   TYPE /adz/enet_preise_t,
           hardw   TYPE /adz/enet_preise_t,
           gp      TYPE /adz/enet_preise_t,
           ap      TYPE /adz/enet_preise_t,
           lp      TYPE /adz/enet_preise_t,
           blind   TYPE /adz/enet_preise_t,
           ka      TYPE /adz/enet_preise_t,
           kwk_a   TYPE /adz/enet_preise_t,
           kwk_b   TYPE /adz/enet_preise_t,
           abrech  TYPE /adz/enet_preise_t,
           skap    TYPE /adz/enet_preise_t,
           skapp   TYPE /adz/enet_preise_t,
           sku_a   TYPE /adz/enet_preise_t,
           sku_b   TYPE /adz/enet_preise_t,
           sku_c   TYPE /adz/enet_preise_t,
           off_a   TYPE /adz/enet_preise_t,
           off_b   TYPE /adz/enet_preise_t,
           off_c   TYPE /adz/enet_preise_t,
           abu_a   TYPE /adz/enet_preise_t,
           abu_b   TYPE /adz/enet_preise_t,
           abu_c   TYPE /adz/enet_preise_t,
         END OF t_preise.


  DATA:
    lv_netz_nr      TYPE grid_id,
    lv_zaehler_id   TYPE /adz/zaehlerd,
    ls_enet_zaehler TYPE /adz/zaehler,
    ls_eanl         TYPE eanl,
    ls_eanlh        TYPE eanlh,
    lt_adrc         TYPE ieadrc,
    ls_adrc         TYPE adrc,
    ls_preise       TYPE t_preise,
    ls_netz_nsp     TYPE grid_id,
    ls_netz_msp     TYPE grid_id,
    ls_netz_hsp     TYPE grid_id,
    ls_netz_nr      TYPE grid_id,
    lv_rlmslp       TYPE c, "1 = RLM 0 = SLP
    lv_custrlmslp   TYPE string,
    lv_custreport   TYPE string,
    lv_ka_id        TYPE grid_id,
    lv_spebene      TYPE /adz/spebene,
    ls_enet_netze   TYPE /adz/netze.

  SELECT SINGLE * FROM eanl
    INTO ls_eanl
    WHERE anlage = anlage.

  "Kunden Exit zum Identifikatiom RLM/SLP
  SELECT SINGLE value FROM /adz/inv_cust INTO lv_custreport WHERE report = 'GLOBAL' AND field = 'CUST_REPORT'.
  SELECT SINGLE value FROM /adz/inv_cust INTO lv_custrlmslp WHERE report = 'GLOBAL' AND field = 'RLMSLP_FORM'.
  IF lv_custrlmslp IS NOT INITIAL AND lv_custreport IS NOT INITIAL.
    CALL FUNCTION '/ADZ/CUST_RLM_SLP'
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

  READ TABLE lt_adrc INTO ls_adrc INDEX 1.

  CALL FUNCTION '/ADZ/ENET_NETZE_ZU_ADRESSE'
    EXPORTING
      adrc      = ls_adrc
      ab        = abr_ab
    IMPORTING
      netz_nsp  = ls_netz_nsp
      netz_msp  = ls_netz_msp
      netz_hsp  = ls_netz_hsp
      ka_id     = lv_ka_id
    EXCEPTIONS
      kein_netz = 1
      OTHERS    = 2.

  SELECT SINGLE adspebene FROM /adz/ec_spebn INTO lv_spebene WHERE custspebene = ls_eanl-spebene AND sparte = 'ST'.
  CASE lv_spebene.
    WHEN 1.
      ls_netz_nr = ls_netz_nsp.
    WHEN 2 OR 3 OR 4.
      ls_netz_nr = ls_netz_msp.
    WHEN 5 OR 6 OR 7.
      ls_netz_nr = ls_netz_hsp.
    WHEN OTHERS.
      ls_netz_nr = ls_netz_nsp.
  ENDCASE.

  SHIFT ls_netz_nr LEFT DELETING LEADING ' '.
  SELECT SINGLE * FROM /adz/netze
    INTO ls_enet_netze
    WHERE netz_nr = ls_netz_nr
    AND status_id = '3000'.

  IF sy-subrc <> 0.
  "  MESSAGE 'Kein gültiges Netz gefunden' TYPE 'E'.
    RAISE kein_netz.
  ENDIF.

  CALL FUNCTION '/ADZ/ENET_ZAEHLERNR'
    EXPORTING
      anlage       = anlage
      netz_nr      = ls_netz_nr
      abr_preis    = abr_preis
      ab           = abr_ab
      bis          = abr_bis
      rlmslp       = lv_rlmslp
    IMPORTING
      zahlernummer = lv_zaehler_id
      zaehlerfremd = zaehlerfremd.

  CALL FUNCTION '/ADZ/ENET_MDIENST_ENTGELTE'
    EXPORTING
      mdienst_nr    = ls_enet_netze-standard_mdienst
      messgebiet_nr = ls_enet_netze-standard_gebiet_mdienst
      anlage        = anlage
      ab            = abr_ab
      bis           = abr_bis
      zaehlernr     = lv_zaehler_id
    IMPORTING
      betrieb       = ls_preise-betrieb
      messung       = ls_preise-messung
      summe         = ls_preise-summe
      hardw         = ls_preise-hardw
    EXCEPTIONS
      kein_dienstl  = 1
      falsche_daten = 2
      OTHERS        = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.




  CALL FUNCTION '/ADZ/ENET_NNE'
    EXPORTING
      netz_nr   = ls_netz_nr
      anlage    = anlage
      spebene   = lv_spebene
      zaehlernr = lv_zaehler_id
      ab        = abr_ab
      bis       = abr_bis
    IMPORTING
      ap        = ls_preise-ap
      lp        = ls_preise-lp
      gp        = ls_preise-gp.


  CALL FUNCTION '/ADZ/ENET_BLINDSTROM'
    EXPORTING
      netz_nr        = ls_netz_nr
      ab             = abr_ab
      bis            = abr_bis
      int_inv_doc_no = int_inv_doc_no
    IMPORTING
      preise         = ls_preise-blind.


  CALL FUNCTION '/ADZ/ENET_KA'
    EXPORTING
      ka_id          = lv_ka_id
      ab             = abr_ab
      bis            = abr_bis
      int_inv_doc_no = int_inv_doc_no
      anlage         = anlage
    IMPORTING
      preise         = ls_preise-ka.
  .

  CALL FUNCTION '/ADZ/ENET_KWK'
    EXPORTING
      netz_nr = ls_netz_nr
      ab      = abr_ab
      bis     = abr_bis
    IMPORTING
      kat_a   = ls_preise-kwk_a
      kat_b   = ls_preise-kwk_b.

  CALL FUNCTION '/ADZ/ENET_UMLAGE'
    EXPORTING
      netz_nr = ls_netz_nr
      ab      = abr_ab
      bis     = abr_bis
    IMPORTING
      skap    = ls_preise-skap
      skapp   = ls_preise-skapp
      sku_a   = ls_preise-sku_a
      sku_b   = ls_preise-sku_b
      sku_c   = ls_preise-sku_c
      off_a   = ls_preise-off_a
      off_b   = ls_preise-off_b
      off_c   = ls_preise-off_c
      abu_a   = ls_preise-abu_a
      abu_b   = ls_preise-abu_b
      abu_c   = ls_preise-abu_c.


  CALL FUNCTION '/ADZ/ENET_ABRECHNUNG'
    EXPORTING
      netz_nr   = ls_netz_nr
      anlage    = anlage
      zaehlerid = lv_zaehler_id
      ab        = abr_ab
      bis       = abr_bis
    IMPORTING
      preise    = ls_preise-abrech.


  CALL FUNCTION '/ADZ/ENET_MAPPING'
    EXPORTING
      i_preise   = ls_preise
    IMPORTING
      art_preise = artikel_preis.


  break struck-f.
  IF display = 'X'.

    CALL FUNCTION '/ADZ/ENET_DISPLAY'
      EXPORTING
        i_preise = ls_preise.


  ENDIF.


ENDFUNCTION.
