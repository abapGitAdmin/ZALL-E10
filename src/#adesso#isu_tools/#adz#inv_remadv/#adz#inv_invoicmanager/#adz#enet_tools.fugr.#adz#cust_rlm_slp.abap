FUNCTION /ADZ/CUST_RLM_SLP.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ANLAGE) TYPE  ANLAGE
*"     REFERENCE(DATBIS) TYPE  D
*"     REFERENCE(DATAB) TYPE  D
*"     REFERENCE(CUSTFORM) TYPE  STRING
*"     REFERENCE(CUSTPROGRAMM) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(RLMSLP) TYPE  C
*"--------------------------------------------------------------------

PERFORM (CUSTFORM) IN PROGRAM (CUSTPROGRAMM) USING anlage datab datbis CHANGING RLMSLP.



ENDFUNCTION.
