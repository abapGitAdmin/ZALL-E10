FUNCTION /adesso/r412_drucksperre.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(X_INVOICE_UNIT) TYPE  ISU21_INVOICE_UNIT
*"     REFERENCE(X_INVOICE_PARAM) TYPE  ISU21_INVOICE_PARAM
*"  CHANGING
*"     REFERENCE(XY_PRINTLOCK) LIKE  ERDK-PRINTLOCK
*"     REFERENCE(XY_EDIDISPATCH) LIKE  ERDK-EDIDISPATCH
*"--------------------------------------------------------------------

*-----------------------------------------------------------------------
* Please use the following values to set the parameter XY_PRINTLOCK
*-----------------------------------------------------------------------
* ' '  - No Printlock
* '1'  - Non-removeable printlock
* '2'  - Removeable printlock
*-----------------------------------------------------------------------
* To enable EDI dispatching, please set the parameter XY_EDIDISPATCH
* to 'X'. Attention! Parameter XY_EDIDISPATCH no longer supported
*-----------------------------------------------------------------------
* Änderungshistorie:
* Kopie des Standard FUBAs ISU_SAMPLE_R412
*
* Datum        Benutzer  Grund
*"----------------------------------------------------------------------

  DATA: ls_erdz   TYPE erdz,
        lt_edivar TYPE TABLE OF /adesso/edivar.

  FIELD-SYMBOLS: <ls_edivar> TYPE /adesso/edivar.

  READ TABLE x_invoice_unit-print_doc-t_erdz INTO ls_erdz INDEX 1.
  SELECT * FROM /adesso/edivar INTO TABLE lt_edivar.

  IF x_invoice_unit-print_doc-erdk-vkont = x_invoice_unit-acc-fkkvkp-vkont
  AND x_invoice_unit-acc-fkkvkp-zzedivar IS NOT INITIAL.

    READ TABLE lt_edivar ASSIGNING <ls_edivar>
      WITH KEY edivariante = x_invoice_unit-acc-fkkvkp-zzedivar
               sparte = ls_erdz-sparte.

    IF sy-subrc EQ 0.

      IF x_invoice_unit-print_doc-erdk-abrvorg = '06'.
        IF <ls_edivar>-ediea16 IS NOT INITIAL AND <ls_edivar>-drucksperre IS NOT INITIAL.
          xy_printlock = '2'.
        ENDIF.
      ELSE.

        IF <ls_edivar>-drucksperre IS NOT INITIAL.
          xy_printlock = '2'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.
