FUNCTION zha_string_change.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_STRING) TYPE  STRING
*"  EXPORTING
*"     VALUE(EV_STRING) TYPE  STRING
*"----------------------------------------------------------------------

  ev_string = iv_string && 'XXX'.

ENDFUNCTION.
