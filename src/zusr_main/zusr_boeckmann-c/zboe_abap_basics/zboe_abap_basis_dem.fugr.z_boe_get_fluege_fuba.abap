FUNCTION z_boe_get_fluege_fuba.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_CARRID) TYPE  S_CARR_ID
*"  EXPORTING
*"     REFERENCE(ET_FLUEGE) TYPE  ZBOE_FLISTE
*"----------------------------------------------------------------------

  SELECT * FROM spfli INTO TABLE et_fluege WHERE carrid = iv_carrid.

IF sy-subrc <> 0.
  WRITE: 'Fehler beim Auslesen der Tabelle!'.
ENDIF.

ENDFUNCTION.
