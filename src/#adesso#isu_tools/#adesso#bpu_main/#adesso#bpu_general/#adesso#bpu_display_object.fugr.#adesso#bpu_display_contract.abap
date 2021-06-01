FUNCTION /adesso/bpu_display_contract.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_VERTRAG) TYPE  VERTRAG
*"  EXCEPTIONS
*"      ERROR_OCCURRED
*"----------------------------------------------------------------------

  CALL FUNCTION 'ISU_S_CONTRACT_DISPLAY'
    EXPORTING
      x_vertrag      = iv_vertrag
      x_no_change    = abap_true
      x_no_other     = abap_true
    EXCEPTIONS
      not_found      = 1
      key_invalid    = 2
      system_error   = 3
      not_authorized = 4
      dpp            = 5
      OTHERS         = 6.
  IF sy-subrc <> 0.
    RAISE error_occurred.
  ENDIF.

ENDFUNCTION.
