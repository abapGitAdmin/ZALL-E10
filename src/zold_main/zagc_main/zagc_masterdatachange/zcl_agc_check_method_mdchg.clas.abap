class ZCL_AGC_CHECK_METHOD_MDCHG definition
  public
  create public .

public section.

  constants AC_NEG_ANSWER type /IDXGC/DE_CHECK_RESULT value 'NEG_ANSWER'. "#EC NOTEXT
  constants AC_POS_ANSWER type /IDXGC/DE_CHECK_RESULT value 'POS_ANSWER'. "#EC NOTEXT
  constants AC_ERROR type /IDXGC/DE_CHECK_RESULT value 'ERROR'. "#EC NOTEXT

  class-methods CHECK_ANSWER_ZD0
    importing
      !IS_PROCESS_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
    exporting
      !ET_CHECK_RESULT type /IDXGC/T_CHECK_RESULT
    changing
      !CR_DATA type ref to DATA
      !CR_DATA_LOG type ref to DATA
    raising
      /IDXGC/CX_UTILITY_ERROR .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
private section.
ENDCLASS.



CLASS ZCL_AGC_CHECK_METHOD_MDCHG IMPLEMENTATION.


  METHOD check_answer_zd0.

    DATA: lr_process_data_step TYPE REF TO /idxgc/cl_process_data,
          ls_proc_step_data    TYPE        /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fr_process_log>        TYPE REF TO  /idxgc/if_process_log,
                   <fr_proc_data_extern>   TYPE REF TO  /idxgc/if_process_data_extern,
                   <fs_check_result_final> LIKE LINE OF et_check_result,
                   <fs_msgrespstatus>      TYPE         /idxgc/s_msgsts_details.

    ASSIGN cr_data_log->* TO <fr_process_log>.
    ASSIGN cr_data->* TO <fr_proc_data_extern>.
    lr_process_data_step ?= <fr_proc_data_extern>.

    APPEND INITIAL LINE TO et_check_result ASSIGNING <fs_check_result_final>.

***** Schrittdaten vom aktuellen Schritt holen ****************************************************
    TRY.
        ls_proc_step_data = lr_process_data_step->/idxgc/if_process_data_extern~get_process_step_data( is_process_step_key ).

        READ TABLE ls_proc_step_data-msgrespstatus ASSIGNING <fs_msgrespstatus> INDEX 1.

        IF <fs_msgrespstatus> IS ASSIGNED.
          IF <fs_msgrespstatus>-respstatus = 'ZE0'.
            <fs_check_result_final> = ac_neg_answer.
          ELSE.
            <fs_check_result_final> = ac_pos_answer.
          ENDIF.
        ELSE.
          /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
        ENDIF.

      CATCH /idxgc/cx_process_error /idxgc/cx_utility_error INTO gr_previous.
        <fs_check_result_final> = ac_error.
        <fr_process_log>->add_message_to_process_log( ).
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
