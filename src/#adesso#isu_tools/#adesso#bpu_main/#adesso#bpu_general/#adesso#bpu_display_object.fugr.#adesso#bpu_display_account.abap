FUNCTION /adesso/bpu_display_account.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_ACCOUNT) TYPE  VKONT_KK
*"     VALUE(IV_KEYDATE) TYPE  /IDXGC/DE_KEYDATE
*"  EXCEPTIONS
*"      ERROR_OCCURRED
*"----------------------------------------------------------------------
  DATA: lv_valdt TYPE bu_valdt_di.

  lv_valdt = iv_keydate.

  CALL FUNCTION 'ISU_S_ACCOUNT_DISPLAY'
    EXPORTING
      x_account      = iv_account
      x_valdt        = lv_valdt
      x_no_other     = abap_true
      x_no_change    = abap_true
    EXCEPTIONS
      not_found      = 1
      foreign_lock   = 2
      internal_error = 3
      input_error    = 4
      OTHERS         = 5.
  IF sy-subrc <> 0.
    RAISE error_occurred.
  ENDIF.
ENDFUNCTION.
