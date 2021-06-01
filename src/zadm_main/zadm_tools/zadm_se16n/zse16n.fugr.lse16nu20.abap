FUNCTION se16n_tax_audit_check.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IT_FIELDCAT) TYPE  LVC_T_FCAT OPTIONAL
*"     VALUE(IT_OR_SELFIELDS) TYPE  SE16N_OR_T OPTIONAL
*"     VALUE(I_TAB) TYPE  SE16N_TAB OPTIONAL
*"  CHANGING
*"     VALUE(ID_DREF) TYPE REF TO  DATA OPTIONAL
*"----------------------------------------------------------------------

  DATA:          l_dref     TYPE REF TO data.
  FIELD-SYMBOLS: <tab>      TYPE table.

  ASSIGN id_dref->* TO <tab>.
  IF <tab> IS INITIAL.
    EXIT.
  ENDIF.

*.Add Badi at the end to allow custom specifc coding

ENDFUNCTION.
