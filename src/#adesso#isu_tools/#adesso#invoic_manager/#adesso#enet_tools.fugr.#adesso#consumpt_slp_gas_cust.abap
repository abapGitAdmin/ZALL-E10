FUNCTION /ADESSO/CONSUMPT_SLP_GAS_CUST.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(DATBIS) TYPE  D
*"     REFERENCE(DATAB) TYPE  D
*"     REFERENCE(CUSTFORM) TYPE  STRING
*"     REFERENCE(CUSTPROGRAMM) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(CONSUMPT) TYPE  TINV_INV_LINE_B-QUANTITY
*"----------------------------------------------------------------------

PERFORM (CUSTFORM) IN PROGRAM (CUSTPROGRAMM) USING anlage datab datbis CHANGING CONSUMPT.



ENDFUNCTION.
