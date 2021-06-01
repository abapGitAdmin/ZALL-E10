class /ADESSO/CL_MDC_SOLUTION_METHOD definition
  public
  create public .

public section.

  class-data GR_PREVIOUS type ref to CX_ROOT .

  class-methods SHOW_DISPLAY
    importing
      !IS_CHECK_LIST_RESULT type /IDXGC/S_CHECK_LIST_RESULT
    raising
      /IDXGC/CX_UTILITY_ERROR .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_SOLUTION_METHOD IMPLEMENTATION.


  METHOD show_display.
    DATA: ls_proc_header_data TYPE /idxgc/s_proc_hdr,
          lr_ctx              TYPE REF TO /idxgc/cl_pd_doc_context,
          ls_proc_step_data   TYPE /idxgc/s_proc_step_data,
          ls_proc_step_key    TYPE /idxgc/s_proc_step_key.

    TRY .
        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = is_check_list_result-proc_ref ).

        CALL METHOD lr_ctx->get_header_data
          IMPORTING
            es_proc_hdr = ls_proc_header_data.

        CALL METHOD lr_ctx->get_proc_step_data
          EXPORTING
            iv_proc_step_ref  = is_check_list_result-proc_step_ref
          IMPORTING
            es_proc_step_data = ls_proc_step_data.

        ls_proc_step_key-proc_id = ls_proc_header_data-proc_id.
        ls_proc_step_key-proc_ref = ls_proc_header_data-proc_ref.
        ls_proc_step_key-proc_step_no = ls_proc_step_data-proc_step_no.
        ls_proc_step_key-proc_step_ref = ls_proc_step_data-proc_step_ref.

        CALL FUNCTION '/ADESSO/MDC_SHOW_DISPLAY'
          EXPORTING
            is_process_step_key = ls_proc_step_key.

      CATCH /idxgc/cx_process_error INTO gr_previous.
        IF lr_ctx IS BOUND.
          TRY.
              lr_ctx->close( ).
            CATCH /idxgc/cx_process_error INTO gr_previous.
              /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
          ENDTRY.
        ENDIF.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
