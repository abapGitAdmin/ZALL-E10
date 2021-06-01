FUNCTION /ADESSO/ENET_UMLAGE.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(NETZ_NR) TYPE  GRID_ID
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"  EXPORTING
*"     REFERENCE(SKAP) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(SKAPP) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(SKU_A) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(SKU_B) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(SKU_C) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(OFF_A) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(OFF_B) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(OFF_C) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(ABU_A) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(ABU_B) TYPE  /ADESSO/ENET_PREISE_T
*"     REFERENCE(ABU_C) TYPE  /ADESSO/ENET_PREISE_T
*"--------------------------------------------------------------------

  DATA: ls_umlagen       TYPE /adesso/umlagen,
        lt_umlagen       TYPE TABLE OF /adesso/umlagen,
        lv_ab            TYPE dats,
        lv_bis           TYPE dats,
        lv_ende          TYPE c,
        lv_string        TYPE string,
        lt_string        TYPE TABLE OF string,
        lv_select_string TYPE string,
        ls_preise        TYPE LINE OF /adesso/enet_preise_t.
  FIELD-SYMBOLS <extab> TYPE STANDARD TABLE.
  lv_ab = ab.

  "Stringtabelle für loop aufbauen
  APPEND 'SKAP' TO lt_string.
  APPEND 'SKAPP' TO lt_string.
  APPEND 'SKU_A' TO lt_string.
  APPEND 'SKU_B' TO lt_string.
  APPEND 'SKU_C' TO lt_string.
  APPEND 'Off_A' TO lt_string.
  APPEND 'Off_B' TO lt_string.
  APPEND 'Off_C' TO lt_string.
  APPEND 'ABU_A' TO lt_string.
  APPEND 'ABU_B' TO lt_string.
  APPEND 'ABU_C' TO lt_string.



  LOOP AT lt_string INTO lv_string.
    lv_select_string = lv_string.
    REPLACE 'P' INTO lv_select_string WITH '+'.
    lv_bis = bis.
    lv_ab = ab.
    CLEAR lv_ende.
    CLEAR ls_umlagen.
    DO 100 TIMES.
      SELECT SINGLE * FROM /adesso/umlagen INTO ls_umlagen WHERE netz_nr = netz_nr AND gueltig_seit =< lv_ab AND gueltig_bis => lv_ab AND preistyp = lv_select_string .
      "Zum Beginn der Rechnung ist keine Zeitscheibe vorhanden.
      IF sy-subrc <> 0.
        "erste Zeitscheibe bestimmen
        SELECT * FROM /adesso/umlagen INTO TABLE lt_umlagen WHERE netz_nr = netz_nr AND preistyp = lv_select_string .
        SORT lt_umlagen BY gueltig_seit ASCENDING.
        READ TABLE lt_umlagen INTO ls_umlagen INDEX 1.
        IF sy-subrc = 0.
          lv_ab = ls_umlagen-gueltig_seit.
          ls_preise-ab = ab.
          ls_preise-bis = ls_umlagen-gueltig_seit - 1.
          ls_preise-preis = 0.
          ASSIGN (lv_string) TO <extab>.
          IF sy-subrc = 0.
            APPEND ls_preise TO <extab>.
            CLEAR ls_preise.
          ENDIF.
        ENDIF.
      ELSE.
        IF ls_umlagen-gueltig_bis > bis.
          lv_ende = 'X'.
          lv_bis = bis.
        ELSE.
          lv_bis = ls_umlagen-gueltig_bis.
        ENDIF.
        IF sy-subrc = 0.
          ls_preise-ab = lv_ab.
          ls_preise-bis = lv_bis.
          ls_preise-preis = ls_umlagen-preis.
          ASSIGN (lv_string) TO <extab>.
          IF sy-subrc = 0.
            APPEND ls_preise TO <extab>.
          ENDIF.
        ENDIF.
        IF lv_ende = 'X'.
          EXIT.
        ELSE.
          lv_ab = lv_bis + 1.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDLOOP.



ENDFUNCTION.
