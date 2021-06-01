FUNCTION Z_FK_GETFLIGHTS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(GSID) TYPE  S_CARR_ID
*"  EXPORTING
*"     REFERENCE(FLIGHTS) TYPE  ZFK_FLISTE
*"----------------------------------------------------------------------

SELECT * FROM spfli INTO TABLE flights WHERE carrid = GSID.

IF sy-subrc <> 0.
  WRITE 'Eine passende Fehlermeldung!'.
ENDIF.


ENDFUNCTION.
