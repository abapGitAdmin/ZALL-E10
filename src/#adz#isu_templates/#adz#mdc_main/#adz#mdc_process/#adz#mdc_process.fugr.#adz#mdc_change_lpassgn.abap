FUNCTION /ADZ/MDC_CHANGE_LPASSGN .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_PROC_STEP_DATA) TYPE  /IDXGC/S_PROC_STEP_DATA_ALL
*"  EXCEPTIONS
*"      GENERAL_ERROR
*"--------------------------------------------------------------------
  DATA: lv_anlage TYPE anlage.

  TRY.
      lv_anlage = /adz/cl_mdc_masterdata=>get_anlage( iv_int_ui = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
    CATCH /idxgc/cx_general.
      MESSAGE e042(/adz/mdc_process).
  ENDTRY.

  /adz/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  CALL FUNCTION 'ISU_S_INSTLN_CHANGE'
    EXPORTING
      x_anlage       = lv_anlage
      x_keydate      = is_proc_step_data-proc_date
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
    /adz/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
    MESSAGE e042(/adz/mdc_process).
  ENDIF.

  /adz/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

ENDFUNCTION.
