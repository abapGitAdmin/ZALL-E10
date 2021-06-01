FUNCTION ZHA_EXTRACT_LEADING_ZEROS.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_STR) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(EV_STR) TYPE  STRING
*"----------------------------------------------------------------------
  ev_str = iv_str.
  SHIFT ev_str LEFT DELETING LEADING '0'.
  ev_str = |{ ev_str }\|{ ev_str }|.

ENDFUNCTION.
