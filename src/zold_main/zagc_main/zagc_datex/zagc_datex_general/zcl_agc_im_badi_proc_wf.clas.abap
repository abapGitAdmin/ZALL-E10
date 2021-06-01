class ZCL_AGC_IM_BADI_PROC_WF definition
  public
  inheriting from /IDXGC/CL_DEF_BADI_PROC_WF
  create public .

public section.

  methods /IDXGC/IF_EX_BADI_PROC_WF~CHECK_WF_START
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_IM_BADI_PROC_WF IMPLEMENTATION.


  METHOD /idxgc/if_ex_badi_proc_wf~check_wf_start.
    DATA: lv_proc_ref TYPE /idxgc/de_proc_ref.

    TRY.
        CALL METHOD super->/idxgc/if_ex_badi_proc_wf~check_wf_start
          EXPORTING
            iv_objtype         = iv_objtype
            iv_objkey          = iv_objkey
            iv_event           = iv_event
            it_event_container = it_event_container.
      CATCH /idxgc/cx_process_error.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

    lv_proc_ref = iv_objkey.

    IF zcl_agc_datex_utility=>check_cl_process_is_enabled( iv_proc_ref = lv_proc_ref ) = abap_false.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
