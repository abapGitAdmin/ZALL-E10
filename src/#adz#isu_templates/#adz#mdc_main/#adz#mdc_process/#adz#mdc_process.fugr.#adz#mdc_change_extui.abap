FUNCTION /ADZ/MDC_CHANGE_EXTUI .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_PROC_STEP_DATA) TYPE  /IDXGC/S_PROC_STEP_DATA_ALL
*"  EXCEPTIONS
*"      GENERAL_ERROR
*"--------------------------------------------------------------------
  /adz/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  CALL FUNCTION 'ISU_S_UI_CHANGE'
    EXPORTING
      x_int_ui     = is_proc_step_data-int_ui
      x_keydate    = is_proc_step_data-proc_date
      x_upd_online = abap_true
    EXCEPTIONS
      not_found    = 1
      foreign_lock = 2
      input_error  = 3
      system_error = 4
      OTHERS       = 5.
  IF sy-subrc <> 0.
    /adz/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
    MESSAGE e019(/adz/mdc_process).
  ENDIF.

  /adz/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

ENDFUNCTION.
