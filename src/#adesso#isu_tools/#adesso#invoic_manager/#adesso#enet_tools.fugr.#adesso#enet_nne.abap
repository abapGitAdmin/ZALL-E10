FUNCTION /ADESSO/ENET_NNE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(NETZ_NR) TYPE  GRID_ID
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(SPEBENE) TYPE  /ADESSO/SPEBENE
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"     REFERENCE(ZAEHLERNR) TYPE  /ADESSO/ZAEHLERD
*"     REFERENCE(INT_INV_DOC_NO) TYPE  INV_INT_INV_DOC_NO OPTIONAL
*"  EXPORTING
*"     REFERENCE(AP) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(LP) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(GP) TYPE  /ADESSO/ENET_PREISE_T
*"----------------------------------------------------------------------

  DATA: lv_feldname         TYPE string,
        lv_feldname_ap      TYPE string,
        lv_feldname_lp      TYPE string,
        lv_feldname_gp      TYPE string,
        ls_nne              TYPE /adesso/enet_nne,
        lv_zeit_ok          TYPE c,
        lv_ab               TYPE dats,
        lv_bis              TYPE dats,
        lv_ende             TYPE c,
        lv_hh_gw(3)         TYPE c,
        ls_ever             TYPE ever,
        ls_ettifn           TYPE ettifn,
        lt_ettifn           TYPE TABLE OF ettifn,
        lt_tinv_inv_line_b  TYPE TABLE OF tinv_inv_line_b,
        ls_tinv_inv_line_b  TYPE tinv_inv_line_b,
        lv_ausgrup          TYPE ausgrup,
        lv_kuart            TYPE /adesso/kundenart,
        lv_vertrag          TYPE vertrag,
        lv_spebene_enet(30) TYPE c,
        lv_zahelrnr         TYPE int4,
        ls_preis            TYPE LINE OF /adesso/enet_preise_t,
        lv_bendauer         TYPE i VALUE 1.
  FIELD-SYMBOLS <comp>.


  lv_zahelrnr = zaehlernr.

  CALL FUNCTION 'ISU_MOVE_DATES_DETERMINE'
    EXPORTING
      x_anlage     = anlage
      x_datum      = ab
    IMPORTING
      y_ever       = ls_ever
    EXCEPTIONS
      not_found    = 1
      system_error = 2
      OTHERS       = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SELECT  * FROM ettifn INTO TABLE lt_ettifn WHERE anlage = anlage AND operand = 'SKF_VORBDR' AND ab =< ab .
  IF sy-subrc = 0.
    SORT lt_ettifn BY ab DESCENDING.
    READ TABLE lt_ettifn INTO ls_ettifn INDEX 1.
    lv_bendauer = ls_ettifn-wert1.
  ENDIF.


*  SELECT SINGLE spannungsebene FROM /adesso/zaehler INTO lv_spebene_enet WHERE zaehler_id = lv_zahelrnr.
  lv_ausgrup = ls_ever-ausgrup.
  SELECT SINGLE kundenart FROM /adesso/ec_ausgr INTO lv_kuart WHERE ausgrup = lv_ausgrup.
  IF lv_kuart = 1.
    lv_hh_gw = 'GW_'.
  ELSE.
    lv_hh_gw = 'HH_'.
  ENDIF.




  lv_ab = ab.
  DO 100 TIMES.
    "Netzentgelte ziehen
    SELECT SINGLE * FROM /adesso/enet_nne INTO ls_nne WHERE netz_nr = netz_nr AND gueltig_seit <= lv_ab AND gueltig_bis => lv_ab.
    IF sy-subrc = 0.
      IF ls_nne-gueltig_bis < bis.
        lv_bis = ls_nne-gueltig_bis.
      ELSE.
        lv_bis = bis.
        lv_ende = 'X'.
      ENDIF.
      "Preise 3 mal holen einmal für  Benutzungsdauer und für ohne Lastgangmessung
      DO 4 TIMES.
        IF sy-index = 1.
          lv_bendauer = 0.
        ELSE.
          lv_bendauer = 10000000.
        ENDIF.
        "Feldname zusammen Bauen
        "1. Spebene
        CASE spebene.
          WHEN 1 .
            lv_feldname = 'NS_'.
            IF lv_bendauer <= ls_nne-bdgrenze_nieder AND ( sy-index = 1 or sy-index = 3 ).
              lv_feldname = lv_feldname && '1_'.
            ELSEIF lv_bendauer > ls_nne-bdgrenze_nieder AND ( sy-index = 1 or sy-index = 3 ).
              lv_feldname = lv_feldname && '2_'.
            ELSEIF sy-index = 2.
              lv_feldname = lv_feldname && 'O_LM_' && lv_hh_gw.
            ELSEIF sy-index = 4.
              lv_feldname = 'SPEICHERHEIZ_' && lv_feldname.
            ENDIF.
          WHEN 2 OR 3 OR 4.
            lv_feldname = 'MS_'.
            CASE spebene.
              WHEN 3.
                lv_feldname = lv_feldname && 'NS_MESS_'.
              WHEN 4.
                lv_feldname = lv_feldname && 'NS_UMSP_'.
              WHEN OTHERS.
            ENDCASE.
            IF lv_bendauer <= ls_nne-bdgrenze_mittel AND ( sy-index = 1 or sy-index = 3 ).
              lv_feldname = lv_feldname && '1_'.
            ELSEIF lv_bendauer > ls_nne-bdgrenze_mittel AND ( sy-index = 1 or sy-index = 3 ).
              lv_feldname = lv_feldname && '2_'.
            ELSEIF sy-index = 2.
              lv_feldname = lv_feldname && 'O_LM_' && lv_hh_gw.
            ELSEIF sy-index = 4.
              lv_feldname = 'SPEICHERHEIZ_' && lv_feldname.
            ENDIF.
          WHEN 5 OR 6 OR 7.
            lv_feldname = 'HS_'.
            CASE spebene.
              WHEN 6.
                lv_feldname = lv_feldname && 'MS_MESS_'.
              WHEN 7.
                lv_feldname = lv_feldname && 'MS_UMSP_'.
              WHEN OTHERS.
            ENDCASE.
            IF lv_bendauer <= ls_nne-bdgrenze_hochsp.
              lv_feldname = lv_feldname && '1_'.
            ELSEIF lv_bendauer > ls_nne-bdgrenze_hochsp.
              lv_feldname = lv_feldname && '2_'.
            ELSEIF sy-index = 4.
              lv_feldname = 'SPEICHERHEIZ_' && lv_feldname.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.


        "Benutzungsdauergrenze
*        BREAK-POINT.
        lv_feldname_ap = lv_feldname && 'AP'.
        lv_feldname_lp = lv_feldname && 'LP'.
        lv_feldname_gp = lv_feldname && 'GP'.

        IF lv_feldname_ap = 'SPEICHERHEIZ_NS_AP'.
          lv_feldname_ap = 'SPEICHERHEIZ_NACHT_AP'.

          ASSIGN COMPONENT lv_feldname_ap OF STRUCTURE ls_nne TO <comp>.
          IF sy-subrc = 0.
            ls_preis-preis = <comp>.
            ls_preis-ab = lv_ab.
            ls_preis-bis = lv_bis.
            ls_preis-bemerkung = lv_feldname_ap.
            APPEND ls_preis TO ap.
            CLEAR ls_preis.
          ENDIF.
          lv_feldname_ap = 'SPEICHERHEIZ_TAG_AP'.
        ENDIF.

        ASSIGN COMPONENT lv_feldname_ap OF STRUCTURE ls_nne TO <comp>.
        IF sy-subrc = 0.
          ls_preis-preis = <comp>.
          ls_preis-ab = lv_ab.
          ls_preis-bis = lv_bis.
          ls_preis-bemerkung = lv_feldname_ap.
          APPEND ls_preis TO ap.
          CLEAR ls_preis.
        ENDIF.

        ASSIGN COMPONENT lv_feldname_lp OF STRUCTURE ls_nne TO <comp>.
        IF sy-subrc = 0.
          ls_preis-preis = <comp>.
          ls_preis-ab = lv_ab.
          ls_preis-bis = lv_bis.
          ls_preis-bemerkung = lv_feldname_lp.
          APPEND ls_preis TO lp.
          CLEAR ls_preis.
        ENDIF.

        ASSIGN COMPONENT lv_feldname_gp OF STRUCTURE ls_nne TO <comp>.
        IF sy-subrc = 0.
          ls_preis-preis = <comp>.
          ls_preis-ab = lv_ab.
          ls_preis-bis = lv_bis.
          ls_preis-bemerkung = lv_feldname_gp.
          APPEND ls_preis TO gp.
          CLEAR ls_preis.
        ENDIF.


      ENDDO.
    ENDIF.
    IF lv_ende = 'X'.
      EXIT.
    ELSE.
      lv_ab = lv_bis + 1.
    ENDIF.

  ENDDO.


ENDFUNCTION.
