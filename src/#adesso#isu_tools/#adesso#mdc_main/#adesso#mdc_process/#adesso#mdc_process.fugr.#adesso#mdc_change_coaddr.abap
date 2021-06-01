FUNCTION /adesso/mdc_change_coaddr .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_PROC_STEP_DATA) TYPE  /IDXGC/S_PROC_STEP_DATA_ALL
*"  EXCEPTIONS
*"      GENERAL_ERROR
*"----------------------------------------------------------------------
  DATA: lv_anlage  TYPE anlage,
        lv_premise TYPE vstelle,
        lv_haus    TYPE haus.

  TRY.
      lv_anlage  = /adesso/cl_mdc_masterdata=>get_anlage( iv_int_ui = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
      lv_premise = /adesso/cl_mdc_masterdata=>get_premise( iv_anlage = lv_anlage ).
      lv_haus    = /adesso/cl_mdc_masterdata=>get_conn_obj( iv_premise = lv_premise ).
    CATCH /idxgc/cx_general.
      MESSAGE e016(/adesso/mdc_process).
  ENDTRY.

  /adesso/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  CALL FUNCTION 'ISU_S_CONNOBJ_CHANGE'
    EXPORTING
      x_haus         = lv_haus
      x_upd_online   = abap_true
    EXCEPTIONS
      not_found      = 1
      foreign_lock   = 2
      general_fault  = 3
      invalid_key    = 4
      not_authorized = 5
      input_error    = 6
      status         = 7
      OTHERS         = 8.
  IF sy-subrc <> 0.
    /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
    MESSAGE e016(/adesso/mdc_process).
  ENDIF.

  /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

ENDFUNCTION.
