FUNCTION /adesso/r469_drucksp_stornobel.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_CANC_DOC) TYPE  ISU21_PRINT_DOC
*"     REFERENCE(X_CANC_PARAM) TYPE  ISU21_CANC_PARAM
*"  CHANGING
*"     REFERENCE(XY_PRINTLOCK) LIKE  ERDK-PRINTLOCK
*"----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Please use the follwing values to set the parameter XY_PRINTLOCK
*-----------------------------------------------------------------------
* ' '  - No Printlock (Suggested by SAP)
* '1'  - Non-removeable printlock
* '2'  - Removeable printlock
* '3'  - Original document not yet printed, no printing necessary
*        (Suggested by SAP)
*-----------------------------------------------------------------------
* Änderungshistorie:
* Kopie des Standard FUBAs ISU_SAMPLE_R469
*
* Datum        Benutzer  Grund
*"----------------------------------------------------------------------

  DATA: ls_fkkvkp TYPE fkkvkp,
        ls_erdz   TYPE erdz,
        lt_edivar TYPE TABLE OF /adesso/edivar.

  FIELD-SYMBOLS: <ls_edivar> TYPE /adesso/edivar.

  SELECT * FROM /adesso/edivar INTO TABLE lt_edivar.

  SELECT SINGLE * FROM fkkvkp INTO ls_fkkvkp WHERE
    vkont = x_canc_doc-erdk-vkont.

  READ TABLE x_canc_doc-t_erdz INTO ls_erdz INDEX 1.

  IF ls_fkkvkp-zzedivar IS NOT INITIAL.

    READ TABLE lt_edivar ASSIGNING <ls_edivar>
      WITH KEY edivariante = ls_fkkvkp-zzedivar
               sparte = ls_erdz-sparte.
    IF sy-subrc = 0.
      IF <ls_edivar>-storno IS NOT INITIAL AND <ls_edivar>-drucksperre IS NOT INITIAL.
        xy_printlock = '2'.
      ENDIF.
      EXIT.
    ENDIF.
  ENDIF.

ENDFUNCTION.
