FUNCTION Z_LS_GET_FLUEGE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(CARRID) TYPE  S_CARR_ID
*"  EXPORTING
*"     REFERENCE(LISTE) TYPE  ZLS_FLISTE
*"----------------------------------------------------------------------


SELECT * FROM spfli INTO TABLE LISTE WHERE carrid = CARRID.



ENDFUNCTION.
