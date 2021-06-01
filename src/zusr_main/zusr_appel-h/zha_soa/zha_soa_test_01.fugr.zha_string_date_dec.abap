FUNCTION zha_string_date_dec.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_STRING) TYPE  STRING
*"     VALUE(IV_DATE) TYPE  DATS
*"     VALUE(IV_DEC) TYPE  ZHA_DE_DECIMAL
*"  EXPORTING
*"     VALUE(EV_STRING) TYPE  STRING
*"     VALUE(EV_DATE) TYPE  DATS
*"     VALUE(EV_DEC) TYPE  ZHA_DE_DECIMAL
*"----------------------------------------------------------------------
  ev_string = |{ iv_string },{ iv_string }|.
  ev_date   = iv_date + 1.
  ev_dec    = iv_dec * 2.

ENDFUNCTION.
