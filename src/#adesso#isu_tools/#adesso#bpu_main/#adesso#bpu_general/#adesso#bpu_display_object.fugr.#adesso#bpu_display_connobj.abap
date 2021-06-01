FUNCTION /adesso/bpu_display_connobj.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_HAUS) TYPE  HAUS
*"  EXCEPTIONS
*"      ERROR_OCCURRED
*"----------------------------------------------------------------------

  CALL FUNCTION 'ISU_S_CONNOBJ_DISPLAY'
    EXPORTING
      x_haus         = iv_haus
      x_no_change    = abap_true
      x_no_other     = abap_true
    EXCEPTIONS
      not_found      = 1
      general_fault  = 2
      invalid_key    = 3
      not_authorized = 4
      OTHERS         = 5.
  IF sy-subrc <> 0.
    RAISE error_occurred.
  ENDIF.

ENDFUNCTION.
