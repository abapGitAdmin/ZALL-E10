FUNCTION /ADZ/MDC_CHANGE_CONTRACT .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_PROC_STEP_DATA) TYPE  /IDXGC/S_PROC_STEP_DATA_ALL
*"  EXCEPTIONS
*"      GENERAL_ERROR
*"--------------------------------------------------------------------
  DATA: ls_ever TYPE ever.

  TRY.
      ls_ever = /adz/cl_mdc_masterdata=>get_ever( iv_int_ui = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
    CATCH /idxgc/cx_general.
      MESSAGE e010(/adz/mdc_process).
  ENDTRY.

  /adz/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  CALL FUNCTION 'ISU_S_CONTRACT_CHANGE'
    EXPORTING
      x_vertrag      = ls_ever-vertrag
      x_upd_online   = abap_true
*     X_NO_DIALOG    =
    EXCEPTIONS
      not_found      = 1
      foreign_lock   = 2
      key_invalid    = 3
      input_error    = 4
      system_error   = 5
      not_authorized = 6
      dpp            = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
    /adz/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
    MESSAGE e010(/adz/mdc_process).
  ENDIF.

  /adz/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

ENDFUNCTION.
