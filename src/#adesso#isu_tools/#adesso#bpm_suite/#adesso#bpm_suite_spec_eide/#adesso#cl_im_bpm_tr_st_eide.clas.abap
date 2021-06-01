class /ADESSO/CL_IM_BPM_TR_ST_EIDE definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_BPM_TRANS_START .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_IM_BPM_TR_ST_EIDE IMPLEMENTATION.


  METHOD /adesso/if_bpm_trans_start~transaction_start.
    DATA:  ls_case_hdr              TYPE  bapi_emma_case_hdr,
           lt_solution_paths        TYPE TABLE OF bapi_emma_case_solution_path,
           lv_pdoc_no               TYPE /idxgc/de_proc_ref,
           lt_objects               TYPE emma_cobj_t,
           ls_objects               LIKE LINE OF lt_objects,
           lv_proc_step_ref	        TYPE /idxgc/de_proc_step_ref,
           lv_exception_code        TYPE /idxgc/de_excp_code,
           lx_utility               TYPE REF TO /idxgc/cx_utility_error,
           lt_alv_check_list_result	TYPE /idxgc/t_alv_check_list_result,
           ls_alv_check_list_result LIKE LINE OF lt_alv_check_list_result,
           lv_standard_mode         TYPE kennzx,
           lv_case_locked           TYPE kennzx,
           lv_excp_solving_cls      TYPE /idxgc/de_excp_solving_cls,
           lv_excp_solving_mtd      TYPE /idxgc/de_excp_solving_mtd,
           ls_check_list_result     TYPE /idxgc/s_check_list_result,
           lv_wmode                 TYPE emma_ctxn_wmode,
           lv_case_stat             TYPE emma_cstatus,
           lr_case_db               TYPE REF TO cl_emma_dbl,
           lr_case                  TYPE REF TO cl_emma_case,
           ls_bpm_esm               TYPE /adesso/bpm_esm,
           lr_ctx                   TYPE REF TO /idxgc/cl_pd_doc_context,
           ls_proc_hdr              TYPE /idxgc/s_proc_hdr,
           ls_proc_step_data        TYPE /idxgc/s_proc_step_data.

    lv_standard_mode = abap_true.

    "Aus der Transaktion EMMACL sollen die Klärungsfälle nicht automatisch im Änderungsmodus geöffnet werden
    IF iv_wmode = cl_emma_case_txn=>co_wmode_display.
      IF sy-tcode <> 'EMMACL'.
        lv_wmode = cl_emma_case_txn=>co_wmode_change.
      ELSE.
        lv_wmode = iv_wmode.
      ENDIF.
    ELSE.
      lv_wmode = iv_wmode.
    ENDIF.

    SELECT SINGLE status FROM emma_case INTO lv_case_stat WHERE casenr = iv_casenr.

    "Nur im Änderungsmodus und wenn BPEM-Fall noch nicht abgeschlossen ist
    IF lv_wmode = cl_emma_case_txn=>co_wmode_change AND
       ( lv_case_stat = cl_emma_case=>co_status_new OR lv_case_stat = cl_emma_case=>co_status_inproc ).

      CALL FUNCTION 'BAPI_EMMA_CASE_GET_DETAIL'
        EXPORTING
          case           = iv_casenr
        IMPORTING
          case_detail    = ls_case_hdr
        TABLES
          objects        = lt_objects
          solution_paths = lt_solution_paths.

      READ TABLE lt_solution_paths WITH KEY method = 'SHOWCHECKLISTRESULT' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.

        lv_pdoc_no = ls_case_hdr-mainobjkey.

        READ TABLE lt_objects WITH KEY celemname = 'ProcStepRef' INTO ls_objects.
        lv_proc_step_ref = ls_objects-id.

        READ TABLE lt_objects WITH KEY celemname = 'ExceptionCode' INTO ls_objects.
        lv_exception_code = ls_objects-id.

        TRY.
            CALL METHOD /idxgc/cl_check_list_result=>fetch_check_list_result
              EXPORTING
                iv_pdoc_no               = lv_pdoc_no
                iv_proc_step_ref         = lv_proc_step_ref
                iv_exception_code        = lv_exception_code
              IMPORTING
                et_alv_check_list_result = lt_alv_check_list_result.
          CATCH /idxgc/cx_utility_error INTO lx_utility.
            lv_standard_mode = abap_true.
        ENDTRY.

        LOOP AT lt_alv_check_list_result INTO ls_alv_check_list_result WHERE excp_solving_cls IS NOT INITIAL AND
                                                                             excp_solving_mtd IS NOT INITIAL.
          "Prüfung Customizing ob automatisiertes Ausführen der Methoden erlaubt sind
          TRY.
              lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = lv_pdoc_no ).
              lr_ctx->get_header_data( IMPORTING es_proc_hdr = ls_proc_hdr ).
              lr_ctx->get_proc_step_data( EXPORTING iv_proc_step_ref = lv_proc_step_ref
                                          IMPORTING es_proc_step_data = ls_proc_step_data ).

              ls_bpm_esm = /adesso/cl_bpm_cust_spec_eide=>determine_esm( iv_proc_id = ls_proc_hdr-proc_id
                                                                         iv_proc_version = ls_proc_hdr-proc_version
                                                                         iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                                         iv_chkid = ls_alv_check_list_result-check_id
                                                                         iv_excn_name =  ls_alv_check_list_result-check_result ).

              IF ls_bpm_esm IS INITIAL.
                lv_standard_mode = abap_true.
                CONTINUE.
              ELSE.
                lv_standard_mode = abap_false.
              ENDIF.
            CATCH /idxgc/cx_process_error /adesso/cx_bpm_utility.
              lv_standard_mode = abap_true.
              CONTINUE.
          ENDTRY.

          "Prüfung ob mehrere verschiedene Lösungsmethoden hinterlegt sind. Falls ja->keine automatisierte Ausführung der Methode
          IF lv_excp_solving_cls IS INITIAL AND  lv_excp_solving_mtd IS INITIAL.
            lv_excp_solving_cls =  ls_alv_check_list_result-excp_solving_cls.
            lv_excp_solving_mtd =  ls_alv_check_list_result-excp_solving_mtd.
            lv_standard_mode = abap_false.
          ELSE.
            IF lv_excp_solving_cls NE ls_alv_check_list_result-excp_solving_cls OR
               lv_excp_solving_mtd NE  ls_alv_check_list_result-excp_solving_mtd.
              lv_standard_mode = abap_true.
            ENDIF.
          ENDIF.
        ENDLOOP.

        IF lv_standard_mode IS INITIAL.

          MOVE-CORRESPONDING ls_alv_check_list_result TO ls_check_list_result.

          TRY.
              "Sperre auf den BPEM-Fall setzen
              lr_case_db = cl_emma_dbl=>create_dblayer( ).
              CALL METHOD lr_case_db->enqueue_case
                EXPORTING
                  iv_case      = iv_casenr
                EXCEPTIONS
                  foreign_lock = 1
                  system_error = 2
                  OTHERS       = 3.
              IF sy-subrc = 0. "Nur Lösungsmethode ausführen wenn der Fall noch nicht gesperrt ist.
                CALL METHOD /idxgc/cl_check_list_result=>use_cl_2_solve_exception
                  EXPORTING
                    is_check_list_result = ls_check_list_result.

                lr_case = lr_case_db->read_case_detail( iv_case = iv_casenr ).
                lr_case_db->dequeue_case( ir_case = lr_case ).

                IF lr_case IS BOUND.
                  IF /adesso/cl_bpm_exe_proc_eide=>av_seqnr_to_exc_bpem_proc IS NOT INITIAL.
                    CALL METHOD lr_case->execute_process
                      EXPORTING
                        iv_sequnr           = /adesso/cl_bpm_exe_proc_eide=>av_seqnr_to_exc_bpem_proc
                      EXCEPTIONS
                        process_not_found   = 1
                        system_error        = 2
                        invalid_case_object = 3
                        case_ccat_not_found = 4
                        dataflow_error      = 5
                        OTHERS              = 6.
                    IF sy-subrc <> 0.
                      CLEAR /adesso/cl_bpm_exe_proc_eide=>av_no_transaction_start.
                    ENDIF.
                    COMMIT WORK AND WAIT. "Muss ausgeführt werden auf Grund des Ereignisses
                    cl_emma_case_functions=>complete_no_dialog( EXPORTING iv_casenr = iv_casenr
                                                                EXCEPTIONS complete_failed = 1 OTHERS = 2 ).
                    IF sy-subrc = 0.
                      cl_emma_case_functions=>confirm_no_dialog( EXPORTING iv_casenr = iv_casenr
                                                                 EXCEPTIONS confirm_failed = 1 OTHERS = 2 ).
                      IF sy-subrc <> 0.
                        EXIT.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.

              ENDIF.
            CATCH /idxgc/cx_utility_error.
              lv_standard_mode = abap_true.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.

    IF /adesso/cl_bpm_exe_proc_eide=>av_no_transaction_start = abap_false.
      CLEAR: /adesso/cl_bpm_exe_proc_eide=>av_no_transaction_start, /adesso/cl_bpm_exe_proc_eide=>av_seqnr_to_exc_bpem_proc.
      CALL FUNCTION 'EMMA_CASE_TRANSACTION_START'
        EXPORTING
          iv_casenr                = iv_casenr
          iv_ccat                  = iv_ccat
          iv_template_case         = iv_template_case
          iv_wmode                 = lv_wmode
          iv_allow_toggle_dispchan = iv_allow_toggle_dispchan
          iv_next_prev_case        = iv_next_prev_case
        IMPORTING
          ev_casenr                = ev_casenr
          ev_okcode                = ev_okcode
        EXCEPTIONS
          case_not_found           = 1
          incorrect_workmode       = 2
          incorrect_parameters     = 3.
      IF sy-subrc <> 0.
        /adesso/cx_bpm_general=>raise_exception_from_msg( ).
      ENDIF.
    ELSE.
      CLEAR: /adesso/cl_bpm_exe_proc_eide=>av_no_transaction_start, /adesso/cl_bpm_exe_proc_eide=>av_seqnr_to_exc_bpem_proc.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
