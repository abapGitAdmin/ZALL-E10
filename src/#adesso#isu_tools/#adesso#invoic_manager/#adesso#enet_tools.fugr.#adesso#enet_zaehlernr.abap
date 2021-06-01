FUNCTION /ADESSO/ENET_ZAEHLERNR.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(ABR_PREIS) TYPE  /ADESSO/ENET_PREIS OPTIONAL
*"     REFERENCE(NETZ_NR) TYPE  GRID_ID OPTIONAL
*"     REFERENCE(BIS) TYPE  DATS
*"     REFERENCE(AB) TYPE  DATS
*"     REFERENCE(RLMSLP) TYPE  C
*"  EXPORTING
*"     REFERENCE(ZAHLERNUMMER) TYPE  INT4
*"     REFERENCE(ZAEHLERFREMD) TYPE  BOOLEAN
*"----------------------------------------------------------------------
  TYPES: BEGIN OF t_equnr ,
          equnr TYPE equnr,
          END OF t_equnr.

  DATA:   ls_isu07_install_struc TYPE isu07_install_struc,
          lv_matnr               TYPE matnr,
          lv_funklas             TYPE funklas,
          lv_string              TYPE string,
          lv_zaehl(10)           TYPE c,
          ls_zaehl               TYPE /adesso/ec_zaehl,
          ls_ietdz               TYPE etdz,
          lt_equnr               TYPE TABLE OF t_equnr,
          ls_egerr               TYPE egerr,
          ls_equnr               TYPE equnr,
          ls_eastl               TYPE LINE OF isu07_install_struc-ieastl.


  CALL FUNCTION 'ISU_DB_INSTALL_STRUC_SINGLE'
    EXPORTING
      x_anlage       = anlage
    IMPORTING
      y_instal_struc = ls_isu07_install_struc
*     Y_INSTAL_STRUC_OLD       =
    .

  LOOP AT LS_ISU07_INSTALL_STRUC-IETDZ INTO LS_IETDZ.
    READ TABLE LT_EQUNR TRANSPORTING NO FIELDS WITH KEY equnr = LS_IETDZ-EQUNR.
    if sy-subrc <> 0.
    append LS_IETDZ-EQUNR to LT_EQUNR.
    ENDIF.
  ENDLOOP.
  LOOP AT LT_EQUNR INTO LS_EQUNR.
    SELECT SINGLE * FROM egerr INTO ls_egerr WHERE equnr = ls_equnr AND bis > bis AND ab < ab.
      if sy-subrc = 0.
        ZAHLERNUMMER = ls_egerr-ZZ_METER_ID.
      ENDIF.
  ENDLOOP.
  if ZAHLERNUMMER IS  INITIAL.
  LOOP AT LT_EQUNR INTO LS_EQUNR.
    SELECT SINGLE * FROM egerr INTO ls_egerr WHERE equnr = ls_equnr AND bis > bis .
      if sy-subrc = 0.
        ZAHLERNUMMER = ls_egerr-ZZ_METER_ID.
      ENDIF.
  ENDLOOP.
  ENDIF.
  if ZAHLERNUMMER IS INITIAL.
  LOOP AT ls_isu07_install_struc-ieastl INTO ls_eastl WHERE bis >= bis.
  if ls_eastl-preiskla cs 'FREMD'.
    ZAEHLERFREMD = 'X'.
    exit.
    endif.
  ENDLOOP.


  SELECT SINGLE * FROM /adesso/ec_zaehl INTO ls_zaehl WHERE preis = ls_eastl-preiskla AND sparte = 'ST'.
  IF sy-subrc = 0.
    zahlernummer = ls_zaehl-zaehler.
  ELSE.
    SELECT SINGLE zaehler_id FROM /adesso/abrech INTO lv_zaehl WHERE netz_nr = netz_nr AND preis = abr_preis.
    IF sy-subrc = 0.
      zahlernummer = lv_zaehl.
    ELSEif RLMSLP = 1.
      zahlernummer = 1000.
    ELSEIF RLMSLP = 0.
      zahlernummer = 100.
    ENDIF.
  ENDIF.
  ENDIF.


ENDFUNCTION.
