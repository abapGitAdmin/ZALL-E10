FUNCTION /adesso/bpu_display_partner.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_PARTNER) TYPE  BU_PARTNER
*"     VALUE(IV_KEYDATE) TYPE  /IDXGC/DE_KEYDATE
*"  EXCEPTIONS
*"      ERROR_OCCURRED
*"----------------------------------------------------------------------
  DATA: lv_valdt TYPE bu_valdt_di.

  lv_valdt = iv_keydate.

  CALL FUNCTION 'ISU_S_PARTNER_DISPLAY'
    EXPORTING
      x_partner      = iv_partner
      x_valdt        = lv_valdt
      x_no_change    = abap_true
      x_no_other     = abap_true
    EXCEPTIONS
      not_found      = 1
      general_fault  = 2
      not_authorized = 3
      cancelled      = 4
      dpp            = 5
      OTHERS         = 6.
  IF sy-subrc <> 0.
    RAISE error_occurred.
  ENDIF.
ENDFUNCTION.
