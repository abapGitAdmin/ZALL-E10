FUNCTION /adesso/bpu_display_instln .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_ANLAGE) TYPE  ANLAGE
*"     VALUE(IV_KEYDATE) TYPE  /IDXGC/DE_KEYDATE
*"  EXCEPTIONS
*"      ERROR_OCCURRED
*"----------------------------------------------------------------------
  DATA: lv_keydate TYPE stichtag.

  lv_keydate = iv_keydate.

  CALL FUNCTION 'ISU_S_INSTLN_DISPLAY'
    EXPORTING
      x_anlage       = iv_anlage
      x_keydate      = lv_keydate
      x_no_change    = abap_true
      x_no_other     = abap_true
    EXCEPTIONS
      not_found      = 1
      general_fault  = 2
      not_authorized = 3
      cancelled      = 4
      OTHERS         = 5.
  IF sy-subrc <> 0.
    RAISE error_occurred.
  ENDIF.

ENDFUNCTION.
