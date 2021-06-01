FUNCTION /ADESSO/MDC_CHANGE_PARTNER .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_PROC_STEP_DATA) TYPE  /IDXGC/S_PROC_STEP_DATA_ALL
*"  EXCEPTIONS
*"      GENERAL_ERROR
*"----------------------------------------------------------------------
  DATA: lv_valdt TYPE bu_valdt_di.

  /adesso/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  lv_valdt = is_proc_step_data-proc_date.

  CALL FUNCTION 'ISU_S_PARTNER_CHANGE'
    EXPORTING
      x_partner      = is_proc_step_data-bu_partner
      x_valdt        = lv_valdt
      x_upd_online   = abap_true
    EXCEPTIONS
      not_found      = 1
      foreign_lock   = 2
      not_authorized = 3
      cancelled      = 4
      input_error    = 5
      general_fault  = 6
      OTHERS         = 7.
  IF sy-subrc <> 0.
    /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
    MESSAGE e010(/adesso/mdc_process).
  ENDIF.

  /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

ENDFUNCTION.
