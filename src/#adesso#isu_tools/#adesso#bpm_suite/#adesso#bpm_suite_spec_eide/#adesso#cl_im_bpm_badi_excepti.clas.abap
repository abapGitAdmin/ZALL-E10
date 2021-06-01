class /ADESSO/CL_IM_BPM_BADI_EXCEPTI definition
  public
  inheriting from /IDXGC/CL_DEF_BADI_EXCEPTION
  create public .

public section.

  methods /IDXGC/IF_BADI_EXCEPTION~CREATE_EXCEPTION
    redefinition .
protected section.

  methods DET_CUST_TXT
    importing
      !IR_PROC_DATA type ref to /IDXGC/IF_PROCESS_DATA_EXTERN
      !IS_EXCEPTION_DATA type /IDXGC/S_EXCP_DATA
      !IS_EXCEPTION_CONFIG type /IDXGC/S_EXCP_CONFIG
    returning
      value(RV_BPM_TXT) type EMMA_CASETXT
    raising
      /ADESSO/CX_BPM_GENERAL .
private section.
ENDCLASS.



CLASS /ADESSO/CL_IM_BPM_BADI_EXCEPTI IMPLEMENTATION.


  METHOD /idxgc/if_badi_exception~create_exception.

    DATA: lv_engine_type        TYPE /idxgc/de_engine_type,
          ls_bpm_txt            TYPE /adesso/bpm_txt,
          ls_proc_key           TYPE        /idxgc/s_proc_key,
          lr_proc_doc           TYPE REF TO /idxgc/if_process_document,
          lr_proc_data          TYPE REF TO /idxgc/if_process_data_extern,
          ls_proc_step_key      TYPE        /idxgc/s_proc_step_key,
          ls_proc_step_data_all TYPE        /idxgc/s_proc_step_data_all,
          lr_previous           TYPE REF TO /idxgc/cx_general,
          ls_case_data          TYPE        emma_case,
          lr_dbl                TYPE REF TO cl_emma_dbl,
          lr_case_old           TYPE REF TO cl_emma_case,
          lr_case               TYPE REF TO cl_emma_case,
          lv_mtext              TYPE        string.

    FIELD-SYMBOLS: <fs_check_result>    TYPE /idxgc/s_check_details,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

    TRY.
        "Bei der Prozess-Engine sind die Schrittdaten zum Zeitpunkt der BPM Erstellung noch nicht auf der DB gespeichert. Daher müssen die Daten mit gereicht werden!
        IF ir_process_data IS BOUND.
          lv_engine_type = /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_engine_type( iv_process_id = ir_process_data->gs_process_data-proc_id
                                                                                             iv_process_version = ir_process_data->gs_process_data-proc_version ).

          IF lv_engine_type = 'P'. "Prozess-Engine
            /adesso/cl_bpm_fill_cont_eide=>ar_process_data_engine = ir_process_data.
          ENDIF.
        ENDIF.

        CALL METHOD super->/idxgc/if_badi_exception~create_exception
          EXPORTING
            is_exception_data   = is_exception_data
            is_exception_config = is_exception_config
            ir_process_data     = ir_process_data
            iv_simulate         = iv_simulate
          CHANGING
            cv_exception_number = cv_exception_number
            cr_process_document = cr_process_document
            cr_process_log      = cr_process_log.

        "**************************************************
        "Eindeutige Klärungsfalltexte
        "**************************************************
        ls_proc_step_key-proc_ref      = is_exception_data-proc_ref.
        ls_proc_step_key-proc_step_ref = is_exception_data-proc_step_ref.

        IF ir_process_data IS NOT BOUND AND
           is_exception_data-proc_ref IS NOT INITIAL.

          ls_proc_key-proc_ref = is_exception_data-proc_ref.

          IF cr_process_document IS NOT BOUND.
            TRY.
                lr_proc_doc = /idxgc/cl_process_document=>/idxgc/if_process_document~get_instance( is_process_key = ls_proc_key
                                                                                                   iv_fast_mode = /idxgc/if_constants=>gc_true
                                                                                                   iv_edit_mode = cl_isu_wmode=>co_display ).

              CATCH /idxgc/cx_process_error INTO lr_previous.
                MESSAGE e011(/idxgc/process) WITH ls_proc_key-proc_ref.
                /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lr_previous ).
            ENDTRY.
          ENDIF.

          TRY.
              lr_proc_data ?= lr_proc_doc->get_process_data( ).

            CATCH /idxgc/cx_process_error INTO lr_previous.
              lr_proc_doc->close( ).

              MESSAGE e043(/idxgc/utility) WITH ls_proc_key-proc_ref.
              /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lr_previous ).
          ENDTRY.

          IF cr_process_document IS NOT SUPPLIED.
            cr_process_document->close( ).
          ENDIF.

        ELSEIF ir_process_data IS BOUND.
          lr_proc_data  = ir_process_data.
        ENDIF.

        IF lr_proc_data IS BOUND.
*   Get process step data
          TRY.
              ls_proc_step_data_all = lr_proc_data->get_process_step_data( ls_proc_step_key ).

            CATCH /idxgc/cx_process_error INTO lr_previous.
              MESSAGE e132(/idxgc/utility) WITH ls_proc_step_key-proc_ref ls_proc_step_key-proc_step_no.
              /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lr_previous ).
          ENDTRY.
        ELSE.
          MESSAGE e001(/adesso/bpm_txt) WITH cv_exception_number INTO lv_mtext.
          cr_process_log->add_message_to_process_log( is_process_step_key = ls_proc_step_key
                                                      is_business_log     = /idxgc/if_constants=>gc_true ).
        ENDIF.

        TRY.
            READ TABLE ls_proc_step_data_all-check ASSIGNING <fs_check_result> WITH KEY exception_code = is_exception_data-exception_code.

            IF <fs_check_result> IS ASSIGNED.
              ls_bpm_txt = /adesso/cl_bpm_cust_spec_eide=>determine_txt( iv_proc_id = ls_proc_step_data_all-proc_id
                                                                         iv_proc_version = ls_proc_step_data_all-proc_version
                                                                         iv_proc_step_no = ls_proc_step_data_all-proc_step_no
                                                                         iv_chkid = <fs_check_result>-check_id
                                                                         iv_excn_name = <fs_check_result>-check_result ).
            ELSE.
              READ TABLE ls_proc_step_data_all-mtd_code_result ASSIGNING <fs_mtd_code_result> WITH KEY exception_code = is_exception_data-exception_code.
              IF <fs_mtd_code_result> IS ASSIGNED.
                ls_bpm_txt = /adesso/cl_bpm_cust_spec_eide=>determine_txt( iv_proc_id = ls_proc_step_data_all-proc_id
                                                                           iv_proc_version = ls_proc_step_data_all-proc_version
                                                                           iv_proc_step_no = ls_proc_step_data_all-proc_step_no
                                                                           iv_chkid = /idxgc/if_constants=>gc_check_id_mtd
                                                                           iv_excn_name = <fs_check_result>-check_result ).
              ENDIF.
            ENDIF.


            IF lr_dbl IS INITIAL.
              lr_dbl = cl_emma_dbl=>create_dblayer( ).
            ENDIF.

            lr_case = lr_dbl->read_case_detail( iv_case = cv_exception_number ).

            IF lr_case IS NOT BOUND.
              RETURN.
            ENDIF.

            lr_case_old = lr_case->clone( ).

            ls_case_data = lr_case->get_data( ).
            IF ls_bpm_txt-title IS NOT INITIAL.
              ls_case_data-casetxt = ls_bpm_txt-title.
            ELSE.
              TRY.
                  ls_case_data-casetxt = me->det_cust_txt( ir_proc_data = lr_proc_data is_exception_data = is_exception_data is_exception_config = is_exception_config ).
                CATCH /adesso/cx_bpm_general.
                  "Alten Text beibehalten
              ENDTRY.
            ENDIF.

            lr_case->set_data( iv_case = ls_case_data ).

            lr_dbl->change_case( EXPORTING ir_case = lr_case
                                           ir_dbcase = lr_case_old
                                 EXCEPTIONS error_inserting_objects = 1
                                            error_updating_case     = 2
                                            error_saving_text       = 3
                                            OTHERS                  = 4 ).

            IF sy-subrc <> 0.
              RETURN.
            ENDIF.


          CATCH /adesso/cx_bpm_utility.
            RETURN. "Text aus dem Customizing beibehalten
        ENDTRY.

      CATCH /idxgc/cx_utility_error /idxgc/cx_config_error.
    ENDTRY.
  ENDMETHOD.


  METHOD det_cust_txt.
    "Kundenindividuell in jedem System zu implementieren.
    /adesso/cx_bpm_general=>raise_exception_from_msg( ).
  ENDMETHOD.
ENDCLASS.
