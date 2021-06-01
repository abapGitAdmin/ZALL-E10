FUNCTION /ADESSO/ENET_ZAEHLERNR_GAS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(ABR_PREIS) TYPE  /ADESSO/ENET_PREIS OPTIONAL
*"     REFERENCE(VNBG_NR) TYPE  /ADESSO/ENET_GAS_VNBG_NR OPTIONAL
*"     REFERENCE(TARIFGEBIET) TYPE  /ADESSO/ENET_GAS_TARIFGEBIET
*"       OPTIONAL
*"     REFERENCE(RLMSLP) TYPE  C
*"     REFERENCE(SPEBENE) TYPE  SPEBENE
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(BIS) TYPE  DATS
*"  EXPORTING
*"     REFERENCE(ZAHLERNUMMER) TYPE  INT4
*"     REFERENCE(FREMD) TYPE  BOOLEAN
*"----------------------------------------------------------------------

  TYPES: BEGIN OF t_equnr ,
           equnr TYPE equnr,
         END OF t_equnr.

  DATA:   ls_isu07_install_struc TYPE isu07_install_struc,
          lv_matnr               TYPE matnr,
          lv_funklas             TYPE funklas,
          lv_string              TYPE string,
          lv_zaehl               TYPE /adesso/zaehlerd,
          ls_zaehl               TYPE /adesso/ec_zaehl,
          ls_eastl               TYPE LINE OF isu07_install_struc-ieastl,
          lv_lieferstelle(3)     TYPE c,
          ls_ietdz               TYPE etdz,
          lt_equnr               TYPE TABLE OF t_equnr,
          ls_egerr               TYPE egerr,
          ls_equnr               TYPE equnr,
          lv_druckstufe(2)       TYPE c.


  IF rlmslp = '1'.
    lv_lieferstelle = 'LGK'.
  ELSE.
    lv_lieferstelle = 'SLP'.
  ENDIF.

  CASE spebene(1).
    WHEN 'N'.
      lv_druckstufe = 'ND'.
    WHEN 'M'.
      lv_druckstufe = 'MD'.
    WHEN 'H'.
      lv_druckstufe = 'HD'.
    WHEN OTHERS.
      lv_druckstufe = 'ND'.
  ENDCASE.




  CALL FUNCTION 'ISU_DB_INSTALL_STRUC_SINGLE'
    EXPORTING
      x_anlage       = anlage
    IMPORTING
      y_instal_struc = ls_isu07_install_struc
*     Y_INSTAL_STRUC_OLD       =
    .

  LOOP AT ls_isu07_install_struc-ietdz INTO ls_ietdz.
    READ TABLE lt_equnr TRANSPORTING NO FIELDS WITH KEY equnr = ls_ietdz-equnr.
    IF sy-subrc <> 0.
      APPEND ls_ietdz-equnr TO lt_equnr.
    ENDIF.
  ENDLOOP.
  LOOP AT lt_equnr INTO ls_equnr.
    SELECT SINGLE * FROM egerr INTO ls_egerr WHERE equnr = ls_equnr AND bis > bis AND ab < ab.
    IF sy-subrc = 0.
      zahlernummer = ls_egerr-zz_meter_id.
    ENDIF.
  ENDLOOP.
  IF zahlernummer IS  INITIAL.
    LOOP AT lt_equnr INTO ls_equnr.
      SELECT SINGLE * FROM egerr INTO ls_egerr WHERE equnr = ls_equnr AND bis > bis .
      IF sy-subrc = 0.
        zahlernummer = ls_egerr-zz_meter_id.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF zahlernummer IS  INITIAL.
    READ TABLE ls_isu07_install_struc-ieastl INTO ls_eastl INDEX 1.
    IF ls_eastl-preiskla CS 'FREMD'.
      fremd = 'X'.
    ENDIF.

    SELECT  * FROM /adesso/ec_zaehl INTO ls_zaehl WHERE preis = ls_eastl-preiskla AND sparte = 'GA'.
      SELECT SINGLE zaehler_id FROM /adesso/g_zaehlr INTO zahlernummer WHERE zaehler_id = ls_zaehl-zaehler AND lieferstelle = lv_lieferstelle AND druckstufe = lv_druckstufe.
      IF sy-subrc = 0.
        EXIT.
      ENDIF.
    ENDSELECT.
    IF zahlernummer IS INITIAL.
      SELECT  * FROM /adesso/ec_zaehl INTO ls_zaehl WHERE preis = ls_eastl-preiskla(4) AND sparte = 'GA'.
        SELECT SINGLE zaehler_id FROM /adesso/g_zaehlr INTO zahlernummer WHERE zaehler_id = ls_zaehl-zaehler AND lieferstelle = lv_lieferstelle AND druckstufe = lv_druckstufe.
        IF sy-subrc = 0.
          EXIT.
        ENDIF.
      ENDSELECT.
    ENDIF.
    IF zahlernummer IS INITIAL.
      SELECT SINGLE zaehler_id FROM /adesso/g_abrpr INTO lv_zaehl WHERE vnbg_nr = vnbg_nr AND tarifgebiet = tarifgebiet AND preis = abr_preis.
      IF sy-subrc = 0.
        zahlernummer = lv_zaehl.
      ELSE.
        IF rlmslp = 1.
          zahlernummer = 1100.
        ELSE.
          zahlernummer = 1.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.



ENDFUNCTION.
