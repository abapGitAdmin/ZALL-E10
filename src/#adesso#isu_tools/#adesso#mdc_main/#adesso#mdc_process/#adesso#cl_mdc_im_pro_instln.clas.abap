class /ADESSO/CL_MDC_IM_PRO_INSTLN definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_MDC_PRO_CHG .
  interfaces IF_BADI_INTERFACE .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GV_MTEXT type STRING .

  methods SET_INSTLN_DATA
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    changing
      !CS_OBJ type ISU01_INSTLN
      !CS_AUTO type ISU01_INSTLN_AUTO
    raising
      /IDXGC/CX_UTILITY_ERROR .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_IM_PRO_INSTLN IMPLEMENTATION.


  METHOD /adesso/if_mdc_pro_chg~change_auto.
    DATA: ls_obj    TYPE isu01_instln,
          ls_auto   TYPE isu01_instln_auto,
          lv_anlage TYPE anlage.

    TRY.
        lv_anlage = /adesso/cl_mdc_masterdata=>get_anlage( iv_int_ui  = is_proc_step_data-int_ui iv_keydate = is_proc_step_data-proc_date ).
      CATCH /idxgc/cx_general INTO gr_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

    CALL FUNCTION 'ISU_S_INSTLN_PROVIDE'
      EXPORTING
        x_anlage        = lv_anlage
        x_keydate       = is_proc_step_data-proc_date
        x_wmode         = /idxgc/cl_pod_rel_access=>gc_change
        x_no_dialog     = abap_true
      IMPORTING
        y_obj           = ls_obj
        y_auto          = ls_auto
      EXCEPTIONS
        not_found       = 1
        invalid_keydate = 2
        foreign_lock    = 3
        not_authorized  = 4
        invalid_wmode   = 5
        general_fault   = 6
        OTHERS          = 7.
    IF sy-subrc <> 0.
      MESSAGE e036(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    CALL FUNCTION 'ISU_O_INSTLN_CLOSE'
      CHANGING
        xy_obj = ls_obj.

    me->set_instln_data( EXPORTING is_proc_step_data = is_proc_step_data CHANGING cs_obj = ls_obj cs_auto = ls_auto ).

    /adesso/cl_mdc_datex_utility=>disable_datex( iv_int_ui = is_proc_step_data-int_ui ).

    CALL FUNCTION 'ISU_S_INSTLN_CHANGE'
      EXPORTING
        x_anlage       = lv_anlage
        x_keydate      = is_proc_step_data-proc_date
        x_upd_online   = abap_true
        x_no_dialog    = abap_true
        x_auto         = ls_auto
        x_obj          = ls_obj
      EXCEPTIONS
        not_found      = 1
        foreign_lock   = 2
        not_authorized = 3
        cancelled      = 4
        input_error    = 5
        general_fault  = 6
        OTHERS         = 7.
    IF sy-subrc <> 0.
      MESSAGE e037(/adesso/mdc_process) INTO gv_mtext.
      /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
    ENDIF.

    /adesso/cl_mdc_datex_utility=>enable_datex( iv_int_ui = is_proc_step_data-int_ui ).

  ENDMETHOD.


  METHOD /adesso/if_mdc_pro_chg~change_manual.

    CALL FUNCTION '/ADESSO/MDC_CHANGE_INSTLN' STARTING NEW TASK 'MDC_CHANGE_INSTLN'
      EXPORTING
        is_proc_step_data = is_proc_step_data.

  ENDMETHOD.


  METHOD set_instln_data.
    DATA: lref_analyze_mr_period TYPE REF TO /idexge/analyze_mr_period,
          lv_ableinh             TYPE  ableinheit.

    FIELD-SYMBOLS: <fs_diverse>         TYPE /idxgc/s_diverse_details,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

    READ TABLE is_proc_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.

    LOOP AT is_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result> WHERE compname = /adesso/if_mdc_co=>gc_compname_diverse.
      CASE <fs_mtd_code_result>-fieldname.
        WHEN /adesso/if_mdc_co=>gc_fieldname_volt_level_meas.
          cs_auto-data-spebene = <fs_diverse>-volt_level_meas.
        WHEN /adesso/if_mdc_co=>gc_fieldname_press_level_offt.
          cs_auto-data-drckstuf = <fs_diverse>-press_level_offt.
      ENDCASE.
    ENDLOOP.

    TRY .
        IF lref_analyze_mr_period IS INITIAL.
          GET BADI lref_analyze_mr_period.
        ENDIF.
        CALL BADI lref_analyze_mr_period->analyze_mr_period
          EXPORTING
            iv_int_ui      = is_proc_step_data-int_ui
            iv_keydate     = is_proc_step_data-proc_date
            iv_mr_period   = <fs_diverse>-mrperiod_length
          IMPORTING
            ev_ableinh     = lv_ableinh
          EXCEPTIONS
            error_occurred = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
          MESSAGE e037(/adesso/mdc_process) INTO gv_mtext.
          /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
        ENDIF.
      CATCH cx_badi_not_implemented.
    ENDTRY.
    IF NOT lv_ableinh IS INITIAL.
      cs_auto-data-ableinh = lv_ableinh.
    ENDIF.

    cs_auto-contr-use-data   = abap_true.
    cs_auto-contr-use-okcode = abap_true.
    cs_auto-contr-okcode     = 'SAVE'.
  ENDMETHOD.
ENDCLASS.
