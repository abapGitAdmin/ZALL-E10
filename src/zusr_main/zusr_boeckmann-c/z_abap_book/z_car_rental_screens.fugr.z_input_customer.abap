FUNCTION z_input_customer.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(CUSTOMER_ID) TYPE  ZCUSTOMER_ID
*"----------------------------------------------------------------------

  CALL SELECTION-SCREEN 1100 STARTING AT 10 10.

  IF sy-subrc <> 0.
    LEAVE PROGRAM.
  ENDIF.

  customer_id = id.

ENDFUNCTION.
