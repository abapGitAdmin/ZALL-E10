class /ADESSO/CL_MDC_IM_PRO_CONTRACT definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_MDC_PRO_CHG .
  interfaces IF_BADI_INTERFACE .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GV_MTEXT type STRING .

  methods SET_CONTRACT_DATA
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    changing
      !CS_OBJ type ISU01_CONTRACT
      !CS_AUTO type ISU01_CONTRACT_AUTO
    raising
      /IDXGC/CX_UTILITY_ERROR .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_IM_PRO_CONTRACT IMPLEMENTATION.


  METHOD /adesso/if_mdc_pro_chg~change_auto.
    DATA: ls_obj  TYPE isu01_contract,
          ls_auto TYPE isu01_contract_auto,
          ls_ever TYPE ever.

    TRY.
        ls_ever = /adesso/cl_mdc_masterdata=>get_ever( iv_int_ui = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    CALL FUNCTION 'ISU_S_CONTRACT_PROVIDE'
      EXPORTING
        x_vertrag    = ls_ever-vertrag
        x_wmode      = /idxgc/cl_pod_rel_access=>gc_change
      IMPORTING
        y_obj        = ls_obj
        y_auto       = ls_auto
      EXCEPTIONS
        not_found    = 1
        foreign_lock = 2
        key_invalid  = 3
        system_error = 4
        dpp          = 5
        OTHERS       = 6.
    IF sy-subrc <> 0.
      MESSAGE e017(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    CALL FUNCTION 'ISU_O_CONTRACT_CLOSE'
      CHANGING
        xy_obj = ls_obj.

    me->set_contract_data( EXPORTING is_proc_step_data = is_proc_step_data CHANGING cs_obj = ls_obj cs_auto = ls_auto ).

    /adesso/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

    CALL FUNCTION 'ISU_S_CONTRACT_CHANGE'
      EXPORTING
        x_vertrag      = ls_ever-vertrag
        x_upd_online   = abap_true
        x_no_dialog    = abap_true
        x_auto         = ls_auto
        x_obj          = ls_obj
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
      /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).
      MESSAGE e018(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  ENDMETHOD.


  METHOD /adesso/if_mdc_pro_chg~change_manual.

    CALL FUNCTION '/ADESSO/MDC_CHANGE_CONTRACT' STARTING NEW TASK 'MDC_CHANGE_CONTRACT'
      EXPORTING
        is_proc_step_data = is_proc_step_data.

  ENDMETHOD.


  METHOD set_contract_data.
  ENDMETHOD.
ENDCLASS.
