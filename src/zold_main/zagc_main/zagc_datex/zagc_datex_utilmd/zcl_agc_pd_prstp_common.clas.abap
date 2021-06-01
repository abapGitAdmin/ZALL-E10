class ZCL_AGC_PD_PRSTP_COMMON definition
  public
  inheriting from /IDXGC/CL_PD_PROCESS_STEPS
  create public .

public section.

  data GV_MSGNUM type EIDESWTMDNUM .
  data GV_MSGNUM_REQ type EIDESWTMDNUM .
  data GS_MSGDATA type EIDESWTMSGDATA .

  methods Z_SEND_MESSAGE
    importing
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO
      !IV_MSGNUM type /IDXGC/DE_PROC_STEP_REF
      !IV_MSGNUM_REQ type /IDXGC/DE_PROC_STEP_REF
      !IV_MSGDATA type EIDESWTMSGDATA
    raising
      /IDXGC/CX_PROCESS_ERROR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_PD_PRSTP_COMMON IMPLEMENTATION.


  METHOD z_send_message.
    DATA: ls_proc_step_id     TYPE        /idxgc/s_proc_step_id,
          ls_proc_step_config TYPE        /idxgc/s_proc_step_config_all,
          lr_ctx              TYPE REF TO /idxgc/cl_pd_doc_context.

    DATA: lv_send_msg_flag TYPE        kennzx,
          lr_badi_proc_wf  TYPE REF TO /idxgc/badi_proc_wf.

    DATA: lx_previous      TYPE REF TO /idxgc/cx_general,
          lx_evt_exception TYPE REF TO cx_swf_evt_exception,
          lr_container     TYPE REF TO if_swf_ifs_parameter_container.

    DATA: ls_proc_step_data TYPE /idxgc/s_proc_step_data.

    DATA: lt_enq    TYPE TABLE OF seqg3,
          lv_number TYPE          syst_tabix,
          lv_subrc  TYPE          syst_subrc,
          lv_garg   TYPE          eqegraarg.

    gv_msgnum = iv_msgnum.
    gv_msgnum_req = iv_msgnum_req.
    gs_msgdata = iv_msgdata.

* Get context in change mode
    CALL METHOD me->get_context
      EXPORTING
        iv_wmode = cl_isu_wmode=>co_change
      RECEIVING
        rr_ctx   = lr_ctx.

    IF NOT iv_msgnum IS INITIAL
    OR NOT iv_msgnum_req IS INITIAL.
* Kontext-Klasse muss echt refresht werden
      TRY.
          CALL METHOD lr_ctx->close
            EXPORTING
              iv_synchron = abap_false.
        CATCH /idxgc/cx_process_error .
      ENDTRY.
      CALL METHOD me->get_context
        EXPORTING
          iv_wmode = cl_isu_wmode=>co_change
        RECEIVING
          rr_ctx   = lr_ctx.
    ENDIF.

* Get process step configuration entry
    ls_proc_step_id-proc_id      = giv_proc_id.
    ls_proc_step_id-proc_version = giv_proc_version.
    ls_proc_step_id-proc_step_no = iv_proc_step_no.

    TRY.
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_step_config
          EXPORTING
            is_process_step_id     = ls_proc_step_id
          RECEIVING
            rs_process_step_config = ls_proc_step_config.
      CATCH /idxgc/cx_config_error INTO lx_previous.
        lr_ctx->add_message_log( ).
        lr_ctx->close( ).
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

* Check Condition for sending the message or not
    TRY.
        IF lr_badi_proc_wf IS INITIAL.
          GET BADI lr_badi_proc_wf.
        ENDIF.
        CALL BADI lr_badi_proc_wf->condition_for_send_message
          EXPORTING
            iv_pdoc_no          = giv_pdoc_no
            iv_proc_step_no     = iv_proc_step_no
            iv_send_msg_overdue = ls_proc_step_config-send_msg_overdue
            iv_bmid             = ls_proc_step_config-bmid
          IMPORTING
            ev_send_msg_flag    = lv_send_msg_flag.
      CATCH cx_badi_not_implemented.
    ENDTRY.

    IF lv_send_msg_flag EQ abap_false.
      lr_ctx->close( ).
      RETURN.
    ENDIF.

* Call EXECUTE of class maintained in process step configuration to send message
    CALL METHOD lr_ctx->execute
      EXPORTING
        iv_proc_step_no  = iv_proc_step_no
        iv_proc_step_ref = iv_msgnum.
*      iv_proc_step_source = iv_msgnum_req.

* Populate event container
    CALL METHOD cl_swf_evt_event=>get_event_container
      EXPORTING
        im_objcateg  = /idxgc/if_constants_add=>gc_object_catid_bo
        im_objtype   = /idxgc/if_constants_add=>gc_object_pdoc_bor
        im_event     = /idxgc/if_constants_add=>gc_evt_deadlinectrlfinished
      RECEIVING
        re_reference = lr_container.

* Set the value of an element
    TRY.
        CALL METHOD lr_container->set
          EXPORTING
            name  = /idxgc/if_constants_add=>gc_proc_step_no
            value = iv_proc_step_no.
      CATCH cx_swf_cnt_cont_access_denied .
      CATCH cx_swf_cnt_elem_access_denied .
      CATCH cx_swf_cnt_elem_not_found .
      CATCH cx_swf_cnt_elem_type_conflict .
      CATCH cx_swf_cnt_unit_type_conflict .
      CATCH cx_swf_cnt_elem_def_invalid .
      CATCH cx_swf_cnt_container .
    ENDTRY.

* Raise event DeadlineControlFinished
    TRY.
        CALL METHOD cl_swf_evt_event=>raise
          EXPORTING
            im_objcateg        = /idxgc/if_constants_add=>gc_object_catid_bo
            im_objtype         = /idxgc/if_constants_add=>gc_object_pdoc_bor
            im_event           = /idxgc/if_constants_add=>gc_evt_deadlinectrlfinished
            im_objkey          = giv_pdoc_no
            im_event_container = lr_container.
      CATCH cx_swf_evt_exception INTO lx_evt_exception.
        lr_ctx->add_message_log( ).
        lr_ctx->close( ).
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

* Close document and save
    lr_ctx->close_and_save( ).

*>>> THIMEL.R 20150414 Mantis 4875 WB noch gesperrt
    CONCATENATE sy-mandt iv_msgdata-switchnum INTO lv_garg.
    DO 5 TIMES.
      CALL FUNCTION 'ENQUEUE_READ'
        EXPORTING
          gclient               = sy-mandt
          gname                 = 'EIDESWTDOC'
          garg                  = lv_garg
          guname                = sy-uname
        IMPORTING
          number                = lv_number
          subrc                 = lv_subrc
        TABLES
          enq                   = lt_enq
        EXCEPTIONS
          communication_failure = 1
          system_failure        = 2
          OTHERS                = 3.
      IF sy-subrc <> 0 OR lv_number > 0 OR lv_subrc <> 0.
        lr_ctx->close( ).
        WAIT UP TO 1 SECONDS.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
*<<< THIMEL.R 20150414 Mantis 4875
  ENDMETHOD.
ENDCLASS.
