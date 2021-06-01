FUNCTION Z_DEV_ENTHALTENE_MWST.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(BRUTTOWERT) TYPE  P
*"     REFERENCE(MWSTSATZ) TYPE  P
*"  EXPORTING
*"     REFERENCE(MWST) TYPE  P
*"----------------------------------------------------------------------


  MWST = ( BRUTTOWERT * MWSTSATZ ) / ( MWSTSATZ + 100 ) .


ENDFUNCTION.
