class /ADESSO/CL_BPU_EMMA_CASE definition
  public
  final
  create public .

public section.

  class-methods CREATE_TEMPORARY_CASE
    importing
      !IS_EXCEPTION_DATA type /IDXGC/S_EXCP_DATA
      !IS_EXCEPTION_CONFIG type /IDXGC/S_EXCP_CONFIG
      !IR_PROCESS_DATA type ref to /IDXGC/IF_PROCESS_DATA_EXTERN optional
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_INSTANCE
    importing
      !IV_CASENR type EMMA_CNR optional
      !IV_SKIP_BUFFER type /IDXGC/DE_BOOLEAN_FLAG default ABAP_FALSE
      !IS_CHECK_LIST_RESULT type /IDXGC/S_CHECK_LIST_RESULT optional
    returning
      value(RR_EMMA_CASE) type ref to /ADESSO/CL_BPU_EMMA_CASE
    raising
      /IDXGC/CX_GENERAL .
  methods CONSTRUCTOR
    importing
      !IV_CASENR type EMMA_CNR
      !IS_CASE type EMMA_CASE optional
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL optional
      !IV_EXCEPTION_CODE type /IDXGC/DE_EXCP_CODE optional
      !IV_SKIP_BUFFER type /IDXGC/DE_BOOLEAN_FLAG default ABAP_FALSE
    raising
      /IDXGC/CX_GENERAL .
  methods CLEAR_SEQNR_TO_EXCECUTE .
  methods EXECUTE_SOLVING_METHOD
    importing
      !IS_CHECK_LIST_RESULT type /IDXGC/S_CHECK_LIST_RESULT
    raising
      /IDXGC/CX_GENERAL .
  methods GET_CASE
    importing
      !IV_SKIP_BUFFER type /IDXGC/DE_BOOLEAN_FLAG default ABAP_FALSE
    returning
      value(RS_CASE) type EMMA_CASE .
  methods GET_CHECKS_FOR_EXCEPTION_CODE
    returning
      value(RT_CHECK) type /IDXGC/T_CHECK_DETAILS .
  methods GET_DESCRIPTION
    returning
      value(RT_TLINE) type TSFTEXT
    raising
      /IDXGC/CX_GENERAL .
  methods GET_EXCEPTION_CODE
    returning
      value(RV_EXCEPTION_CODE) type /IDXGC/DE_EXCP_CODE .
  methods GET_MESSAGES
    returning
      value(RT_MESSAGE) type EMMA_CTXN_ALVMSG_T
    raising
      /IDXGC/CX_GENERAL .
  methods GET_OBJECTS
    returning
      value(RT_OBJECTS) type /ADESSO/BPU_T_EMMA_CASE_OBJECT .
  methods GET_PROC_STEP_DATA
    returning
      value(RS_PROC_STEP_DATA) type /IDXGC/S_PROC_STEP_DATA_ALL .
  methods GET_SEQNR_TO_EXCECUTE
    returning
      value(RV_SEQNR_TO_EXECUTE) type EMMA_SEQNR .
  methods GET_SOLUTION_PATHS
    returning
      value(RT_SOLUTION_PATH) type EMMA_CSOP_T .
  methods GET_START_TRANSACTION_FLAG
    returning
      value(RV_START_TRANSACTION_FLAG) type ABAP_BOOL .
  methods SET_CASE
    importing
      !IS_CASE type EMMA_CASE
    raising
      /IDXGC/CX_GENERAL .
  methods SET_SEQNR_TO_EXCECUTE
    importing
      !IV_SEQNR type EMMA_SEQNR .
  methods SET_START_TRANSACTION_FLAG
    importing
      !IV_START_TRANSACTION_FLAG type ABAP_BOOL .
  PROTECTED SECTION.
private section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GT_EMMA_CASE_REF type /ADESSO/BPU_T_EMMA_CASE_REF .
  class-data GV_MTEXT type STRING .
  data GS_CASE type EMMA_CASE .
  data GS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL .
  data GS_PROC_STEP_KEY type /IDXGC/S_PROC_STEP_KEY .
  data GT_CHECK type /IDXGC/T_CHECK_DETAILS .
  data GT_MESSAGE type EMMA_CTXN_ALVMSG_T .
  data GT_OBJECT type /ADESSO/BPU_T_EMMA_CASE_OBJECT .
  data GT_SOLUTION_PATH type EMMA_CSOP_T .
  data GT_TLINE type TSFTEXT .
  data GV_EXCEPTION_CODE type /IDXGC/DE_EXCP_CODE .
  data GV_START_TRANSACTION_FLAG type ABAP_BOOL .
  data GV_SEQNR_TO_EXECUTE type EMMA_SEQNR .
  constants GC_PROCEXEC_STATUS_SYSTEM type EMMA_PROCEX_STATUS value '3' ##NO_TEXT.

  class-methods GET_CASENR_FOR_CHECK_RESULT
    importing
      !IS_CHECK_LIST_RESULT type /IDXGC/S_CHECK_LIST_RESULT
    returning
      value(RV_CASENR) type EMMA_CNR
    raising
      /IDXGC/CX_GENERAL .
  methods UPDATE_DB_CASE_SOLPATH_TRACK
    importing
      !IS_SOLP type EMMA_CSOLP
    raising
      /IDXGC/CX_GENERAL .
ENDCLASS.



CLASS /ADESSO/CL_BPU_EMMA_CASE IMPLEMENTATION.


  METHOD clear_seqnr_to_excecute.

    CLEAR: gv_seqnr_to_execute.

  ENDMETHOD.


  METHOD constructor.
    DATA: lr_dbl      TYPE REF TO cl_emma_dbl,
          lr_case     TYPE REF TO cl_emma_case,
          lr_ctx      TYPE REF TO /idxgc/cl_pd_doc_context,
          lt_object   TYPE emma_cobj_t,
          lt_cust_obj TYPE /adesso/bpu_t_obj.

    FIELD-SYMBOLS: <fs_object> TYPE /adesso/bpu_s_emma_case_object.

    gv_start_transaction_flag = abap_true.

    IF iv_casenr = /adesso/if_bpu_co=>gc_temporary_casenr.
      gs_case           = is_case.
      gs_case-casenr    = iv_casenr.
      gs_proc_step_data = is_proc_step_data.
      gv_exception_code = iv_exception_code.
    ELSE.
      lr_dbl = cl_emma_dbl=>create_dblayer( ).
      IF lr_dbl IS INITIAL.
        MESSAGE e214(emma) WITH iv_casenr INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.

      lr_dbl->read_case_detail( EXPORTING  iv_case   = iv_casenr
                                RECEIVING  er_case   = lr_case
                                EXCEPTIONS not_found = 1
                                           OTHERS    = 2 ).
      IF sy-subrc <> 0.
        MESSAGE e214(emma) WITH iv_casenr INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.

      gs_case = lr_case->get_data( ).
      lr_case->get_objects( IMPORTING et_objects = lt_object ).
      MOVE-CORRESPONDING lt_object TO gt_object.
      gt_solution_path = lr_case->get_solpath( ).

      IF gs_case-mainobjtype = /idxgc/if_constants=>gc_object_pdoc_bor.
        gs_proc_step_data-proc_ref = gs_case-mainobjkey.

        LOOP AT gt_object ASSIGNING <fs_object>.
          CASE <fs_object>-celemname.
            WHEN /idxgc/if_constants_ddic=>gc_bor_param_proc_step_ref.
              gs_proc_step_key-proc_step_ref = <fs_object>-id.
            WHEN /idxgc/if_constants_ddic=>gc_bor_param_exception_code.
              gv_exception_code              = <fs_object>-id.
            WHEN /idxgc/if_constants_ddic=>gc_bor_param_proc_step_no.
              gs_proc_step_key-proc_step_no  = <fs_object>-id.
            WHEN /idxgc/if_constants_ddic=>gc_bor_param_proc_id.
              gs_proc_step_key-proc_id       = <fs_object>-id.
          ENDCASE.
        ENDLOOP.

        TRY.
            lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = gs_proc_step_data-proc_ref iv_skip_buffer = iv_skip_buffer ).
            gs_proc_step_data = lr_ctx->gr_process_data_extern->get_process_step_data( is_process_step_key = gs_proc_step_key ).
            lr_ctx->close( ).
          CATCH /idxgc/cx_process_error INTO gr_previous.
            IF lr_ctx IS BOUND.
              lr_ctx->close( ).
            ENDIF.
            "RT, 07.05.2019, Ggf. ist der Schritt noch nicht gespeichert. Das ist dann kein Fehler.
            "/idxgc/cx_general=>raise_exception_from_msg( ir_previous = gr_previous ).
        ENDTRY.
      ENDIF.

      lt_cust_obj = /adesso/cl_bpu_utility=>det_case_objects_and_methods( ir_bpu_emma_case = me ).
      LOOP AT lt_cust_obj ASSIGNING FIELD-SYMBOL(<fs_cust_obj>).
        LOOP AT gt_object ASSIGNING <fs_object> WHERE celemname = <fs_cust_obj>-object.
          <fs_object>-display_method = <fs_cust_obj>-display_method.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    LOOP AT gs_proc_step_data-check ASSIGNING FIELD-SYMBOL(<fs_check>) WHERE exception_code = gv_exception_code.
      APPEND <fs_check> TO gt_check.
    ENDLOOP.

  ENDMETHOD.


  METHOD create_temporary_case.
    DATA: lr_proc_doc       TYPE REF TO /idxgc/if_process_document,
          lr_proc_data      TYPE REF TO /idxgc/if_process_data_extern,
          lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          ls_proc_key       TYPE /idxgc/s_proc_key,
          ls_proc_step_key  TYPE /idxgc/s_proc_step_key,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          ls_cust_gen       TYPE /adesso/bpu_s_gen,
          ls_case           TYPE emma_case.

    FIELD-SYMBOLS: <fs_emma_case_ref> TYPE /adesso/bpu_s_emma_case_ref.

    ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).

    ls_proc_step_key-proc_ref      = is_exception_data-proc_ref.
    ls_proc_step_key-proc_step_ref = is_exception_data-proc_step_ref.

    IF ir_process_data IS NOT BOUND AND is_exception_data-proc_ref IS NOT INITIAL.
      ls_proc_key-proc_ref = is_exception_data-proc_ref.
      TRY.
          lr_proc_doc = /idxgc/cl_process_document=>/idxgc/if_process_document~get_instance( is_process_key = ls_proc_key
                                                                                             iv_fast_mode   = abap_true
                                                                                             iv_edit_mode   = cl_isu_wmode=>co_display ).
        CATCH /idxgc/cx_process_error INTO gr_previous.
          MESSAGE e011(/idxgc/process) WITH ls_proc_key-proc_ref.
          /idxgc/cx_general=>raise_exception_from_msg( ir_previous = gr_previous ).
      ENDTRY.

      TRY.
          lr_proc_data ?= lr_proc_doc->get_process_data( ).
        CATCH /idxgc/cx_process_error INTO gr_previous.
          lr_proc_doc->close( ).
          MESSAGE e043(/idxgc/utility) WITH ls_proc_key-proc_ref.
          /idxgc/cx_general=>raise_exception_from_msg( ir_previous = gr_previous ).
      ENDTRY.
    ELSEIF ir_process_data IS BOUND.
      lr_proc_data = ir_process_data.
    ENDIF.

    IF lr_proc_data IS BOUND.
      TRY.
          ls_proc_step_data = lr_proc_data->get_process_step_data( ls_proc_step_key ).
        CATCH /idxgc/cx_process_error INTO gr_previous.
          MESSAGE e132(/idxgc/utility) WITH ls_proc_step_key-proc_ref ls_proc_step_key-proc_step_no.
          /idxgc/cx_general=>raise_exception_from_msg( ir_previous = gr_previous ).
      ENDTRY.
    ELSE.
      MESSAGE e001(/adesso/bpu_general) INTO gv_mtext.
      "cr_process_log->add_message_to_process_log( is_process_step_key = ls_proc_step_key is_business_log = /idxgc/if_constants=>gc_true ).
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.


    LOOP AT gt_emma_case_ref TRANSPORTING NO FIELDS WHERE casenr = /adesso/if_bpu_co=>gc_temporary_casenr.
      DELETE gt_emma_case_ref.
    ENDLOOP.


    ls_case-ccat   = is_exception_config-case_category.
    ls_case-casenr = /adesso/if_bpu_co=>gc_temporary_casenr.

    CREATE OBJECT lr_bpu_emma_case
      EXPORTING
        iv_casenr         = ls_case-casenr
        iv_exception_code = is_exception_data-exception_code
        is_case           = ls_case
        is_proc_step_data = ls_proc_step_data.

    APPEND INITIAL LINE TO gt_emma_case_ref ASSIGNING <fs_emma_case_ref>.
    <fs_emma_case_ref>-emma_case_ref = lr_bpu_emma_case.
    <fs_emma_case_ref>-casenr = ls_case-casenr.
    <fs_emma_case_ref>-last_access_date = sy-datum.
    <fs_emma_case_ref>-last_access_time = sy-uzeit.

    SORT gt_emma_case_ref BY last_access_date DESCENDING last_access_time DESCENDING.
    IF lines( gt_emma_case_ref ) > ls_cust_gen-buffer_size_case.
      DELETE gt_emma_case_ref FROM ls_cust_gen-buffer_size_case + 1.
    ENDIF.
  ENDMETHOD.


  METHOD execute_solving_method.
    DATA: lr_dbl  TYPE REF TO cl_emma_dbl,
          lr_case TYPE REF TO cl_emma_case,
          lt_solp TYPE emma_csop_t,
          ls_solp TYPE emma_csolp.

    FIELD-SYMBOLS: <fs_solp> TYPE emma_csop.

    TRY.
        "Sperre auf den BPEM-Fall setzen
        lr_dbl = cl_emma_dbl=>create_dblayer( ).
        lr_dbl->enqueue_case( EXPORTING  iv_case      = gs_case-casenr
                              EXCEPTIONS foreign_lock = 1
                                         system_error = 2
                                         OTHERS       = 3 ).
        IF sy-subrc = 0. "Nur Lösungsmethode ausführen wenn der Fall noch nicht gesperrt ist.
          TRY.
              READ TABLE gt_solution_path ASSIGNING <fs_solp> WITH KEY method = /idxgc/if_constants_add=>gc_method_show_chk_list_rlt.
              IF sy-subrc = 0.
                ls_solp-client        = sy-mandt.
                ls_solp-casenr        = gs_case-casenr.
                ls_solp-seqnr         = <fs_solp>-seqnr.
                ls_solp-xproca        = abap_true.
                ls_solp-procex_by     = sy-uname.
                ls_solp-procex_date   = sy-datum.
                ls_solp-procex_time   = sy-uzeit.
                ls_solp-procex_status = cl_emma_case_txn=>co_procexec_status_success.
              ENDIF.

              /idxgc/cl_check_list_result=>use_cl_2_solve_exception( is_check_list_result = is_check_list_result ).

            CATCH /idxgc/cx_utility_error INTO gr_previous.
              gv_start_transaction_flag = abap_true.
              IF ls_solp IS NOT INITIAL.
                ls_solp-procex_status = gc_procexec_status_system.
                update_db_case_solpath_track( EXPORTING is_solp = ls_solp ).
              ENDIF.
              /idxgc/cx_general=>raise_exception_from_msg( ir_previous = gr_previous ).
          ENDTRY.
          IF ls_solp IS NOT INITIAL.
            update_db_case_solpath_track( EXPORTING is_solp = ls_solp ).
          ENDIF.

          lr_case = lr_dbl->read_case_detail( iv_case = gs_case-casenr ).

          IF lr_case IS BOUND.
            lr_dbl->dequeue_case( ir_case = lr_case ).

            IF gv_seqnr_to_execute IS NOT INITIAL.
              CALL METHOD lr_case->execute_process
                EXPORTING
                  iv_sequnr           = gv_seqnr_to_execute
                EXCEPTIONS
                  process_not_found   = 1
                  system_error        = 2
                  invalid_case_object = 3
                  case_ccat_not_found = 4
                  dataflow_error      = 5
                  OTHERS              = 6.
              IF sy-subrc <> 0.
                gv_start_transaction_flag = abap_true.
              ENDIF.

              lt_solp = lr_case->get_solpath( ). "Aktuelle Einträge lesen
              READ TABLE lt_solp ASSIGNING <fs_solp> INDEX gv_seqnr_to_execute.
              IF sy-subrc = 0.
                MOVE-CORRESPONDING <fs_solp> TO ls_solp.
                ls_solp-client = sy-mandt.
                ls_solp-casenr = gs_case-casenr.
                ls_solp-xproca = abap_true.
                ls_solp-seqnr  = gv_seqnr_to_execute.
                update_db_case_solpath_track( EXPORTING is_solp = ls_solp ).
              ENDIF.
              COMMIT WORK AND WAIT. "Muss ausgeführt werden auf Grund des Ereignisses
              cl_emma_case_functions=>complete_no_dialog( EXPORTING  iv_casenr       = gs_case-casenr
                                                          EXCEPTIONS complete_failed = 1
                                                                     OTHERS          = 2 ).
              IF sy-subrc = 0.
                cl_emma_case_functions=>confirm_no_dialog( EXPORTING  iv_casenr      = gs_case-casenr
                                                           EXCEPTIONS confirm_failed = 1
                                                                      OTHERS         = 2 ).
                IF sy-subrc <> 0.
                  gv_start_transaction_flag = abap_true.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

        ENDIF.
      CATCH /idxgc/cx_utility_error INTO gr_previous.
        /idxgc/cx_general=>raise_exception_from_msg( ir_previous = gr_previous ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_case.

    IF iv_skip_buffer = abap_true.
      SELECT SINGLE * FROM emma_case INTO gs_case WHERE casenr = gs_case-casenr.
    ENDIF.
    rs_case = gs_case.

  ENDMETHOD.


  METHOD get_casenr_for_check_result.
    DATA: lt_casenr       TYPE emma_cnr_t,
          ls_emma_cobject TYPE emma_cobject,
          ls_emma_case    TYPE emma_case.

    SELECT casenr FROM emma_cobject INTO TABLE lt_casenr
      WHERE refstruct  = /idxgc/if_pd_wf_constants=>gc_refstruct_prst_hdr
        AND reffield   = /idxgc/if_pd_wf_constants=>gc_reffield_step_ref
        AND id         = is_check_list_result-proc_step_ref.
    LOOP AT lt_casenr ASSIGNING FIELD-SYMBOL(<fv_casenr>).
      SELECT SINGLE * FROM emma_cobject INTO ls_emma_cobject
        WHERE casenr     = <fv_casenr>
          AND celemname  = /idxgc/if_constants_ddic=>gc_bor_param_exception_code
          AND id = is_check_list_result-exception_code.
      IF sy-subrc <> 0.
        DELETE lt_casenr.
        CONTINUE.
      ENDIF.
      SELECT SINGLE * FROM emma_case INTO ls_emma_case
        WHERE casenr = <fv_casenr>
          AND ( status = cl_emma_case=>co_status_new OR status = cl_emma_case=>co_status_inproc ).
      IF sy-subrc <> 0.
        DELETE lt_casenr.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    IF lines( lt_casenr ) = 1.
      rv_casenr = lt_casenr[ 1 ].
    ELSE.
      MESSAGE e014(/adesso/bpu_general) INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_checks_for_exception_code.

    rt_check = gt_check.

  ENDMETHOD.


  METHOD get_description.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
*   Die Beschreibung wird nachgelesen, falls benötigt.
***************************************************************************************************
    DATA: lr_dbl                  TYPE REF TO cl_emma_dbl,
          lr_case                 TYPE REF TO cl_emma_case,
          lr_badi_emma_case_trans TYPE REF TO badi_emma_case_transaction,
          lt_cont                 TYPE swconttab,
          lt_text_line            TYPE tsftext,
          ls_tline                TYPE tline,
          ls_thead                TYPE thead,
          lv_tname                TYPE tdobname.

    IF gt_tline IS INITIAL.
      lr_dbl = cl_emma_dbl=>create_dblayer( ).
      IF lr_dbl IS INITIAL.
        MESSAGE e214(emma) WITH gs_case-casenr INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.

      lr_dbl->read_case_detail( EXPORTING  iv_case   = gs_case-casenr
                                RECEIVING  er_case   = lr_case
                                EXCEPTIONS not_found = 1
                                           OTHERS    = 2 ).
      IF sy-subrc <> 0.
        MESSAGE e214(emma) WITH gs_case-casenr INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.

      lr_case->build_container_from_objects( EXPORTING iv_xmsg        = abap_true
                                                       iv_contval_ext = abap_true
                                             IMPORTING et_cont        = lt_cont ).

      lr_dbl->read_ccat_text( EXPORTING  iv_ccat            = gs_case-ccat
                              IMPORTING  es_thead           = ls_thead
                                         et_tline           = gt_tline
                              EXCEPTIONS error_reading_text = 1
                                         OTHERS             = 2 ).
      IF sy-subrc <> 0.
        REFRESH gt_tline.
        lv_tname = gs_case-ccat.
        CALL FUNCTION 'INIT_TEXT'
          EXPORTING
            id       = cl_emma_case=>co_text_idccat
            language = sy-langu
            name     = lv_tname
            object   = cl_emma_case=>co_text_obj
          IMPORTING
            header   = ls_thead
          TABLES
            lines    = gt_tline
          EXCEPTIONS
            id       = 1
            language = 2
            name     = 3
            object   = 4
            OTHERS   = 5.
        IF sy-subrc <> 0.
          /idxgc/cx_general=>raise_exception_from_msg( ).
        ENDIF.
      ENDIF.

      TRY.
          GET BADI lr_badi_emma_case_trans.
        CATCH cx_badi_not_implemented.
          "BAdI muss nicht implementiert sein.
      ENDTRY.

      IF lr_badi_emma_case_trans IS NOT INITIAL.
        TRY.
            CALL BADI lr_badi_emma_case_trans->change_description
              EXPORTING
                is_case  = gs_case
                ir_case  = lr_case
              CHANGING
                cs_thead = ls_thead
                ct_tline = gt_tline
              EXCEPTIONS
                OTHERS   = 1.
          CATCH cx_sy_dyn_call_illegal_method.
            MESSAGE e199(emma) WITH 'BADI_EMMA_CASE_TRANSACTION' 'CHANGE_DESCRIPTION'.
        ENDTRY.
      ENDIF.
      IF gt_tline IS NOT INITIAL.
        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          TABLES
            itf_text    = gt_tline
            text_stream = lt_text_line.
        CALL FUNCTION 'NOTE_CONVERT_TEXT_TO_ITF'
          EXPORTING
            raw         = 'X'
          TABLES
            text_stream = lt_text_line
            itf_text    = gt_tline.
        ls_tline-tdformat = '*'.
        MODIFY gt_tline FROM ls_tline INDEX 1 TRANSPORTING tdformat.


        LOOP AT gt_tline ASSIGNING FIELD-SYMBOL(<fs_tline>) WHERE tdformat  = '/' AND   tdline(8) = 'INCLUDE '.
          <fs_tline>-tdformat = '/:'.
        ENDLOOP.
        CALL FUNCTION 'TEXT_INCLUDE_REPLACE'
          EXPORTING
            header = ls_thead
          TABLES
            lines  = gt_tline.

        IF lt_cont IS NOT INITIAL.
          CALL FUNCTION 'EMMA_TEXTLINES_REPLACE'
            EXPORTING
              text_header     = ls_thead
            TABLES
              text_lines      = gt_tline
              container       = lt_cont
            CHANGING
              new_text_header = ls_thead
            EXCEPTIONS
              OTHERS          = 0.
        ENDIF.
      ENDIF.

      IF lr_badi_emma_case_trans IS NOT INITIAL.
        TRY.
            CALL BADI lr_badi_emma_case_trans->change_description_output
              EXPORTING
                is_case  = gs_case
                ir_case  = lr_case
                it_cont  = lt_cont
              CHANGING
                cs_thead = ls_thead
                ct_tline = gt_tline
              EXCEPTIONS
                OTHERS   = 1.
          CATCH cx_sy_dyn_call_illegal_method.
            MESSAGE e199(emma) WITH 'BADI_EMMA_CASE_TRANSACTION' 'CHANGE_DESCRIPTION_OUTPUT'.
        ENDTRY.
      ENDIF.
    ENDIF.

    rt_tline = gt_tline.

  ENDMETHOD.


  METHOD get_exception_code.
    rv_exception_code = gv_exception_code.
  ENDMETHOD.


  METHOD get_instance.

    DATA: lr_emma_dbl46 TYPE REF TO cl_emma_dbl46,
          lt_casenr     TYPE emma_cnr_t,
          ls_cust_gen   TYPE /adesso/bpu_s_gen,
          lv_swo_typeid TYPE swo_typeid,
          lv_casenr     TYPE emma_cnr.


    FIELD-SYMBOLS: <fs_emma_case_ref> TYPE /adesso/bpu_s_emma_case_ref.

    ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).

    IF is_check_list_result IS NOT SUPPLIED AND iv_casenr IS NOT SUPPLIED.
      MESSAGE e013(/adesso/bpu_general) INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ELSEIF is_check_list_result IS SUPPLIED AND iv_casenr IS NOT SUPPLIED.
      lv_casenr = get_casenr_for_check_result( is_check_list_result = is_check_list_result ).
    ELSE.
      lv_casenr = iv_casenr.
    ENDIF.

    READ TABLE gt_emma_case_ref ASSIGNING <fs_emma_case_ref> WITH KEY casenr = lv_casenr.
    IF sy-subrc = 0 AND iv_skip_buffer = abap_false.
      rr_emma_case = <fs_emma_case_ref>-emma_case_ref.
      <fs_emma_case_ref>-last_access_date = sy-datum.
      <fs_emma_case_ref>-last_access_time = sy-uzeit.
      RETURN.
    ENDIF.

    CREATE OBJECT rr_emma_case EXPORTING iv_casenr = lv_casenr.
    IF <fs_emma_case_ref> IS NOT ASSIGNED.
      APPEND INITIAL LINE TO gt_emma_case_ref ASSIGNING <fs_emma_case_ref>.
    ENDIF.
    <fs_emma_case_ref>-casenr = lv_casenr.
    <fs_emma_case_ref>-emma_case_ref = rr_emma_case.
    <fs_emma_case_ref>-last_access_date = sy-datum.
    <fs_emma_case_ref>-last_access_time = sy-uzeit.

    SORT gt_emma_case_ref BY last_access_date DESCENDING last_access_time DESCENDING.
    IF lines( gt_emma_case_ref ) > ls_cust_gen-buffer_size_case.
      DELETE gt_emma_case_ref FROM ls_cust_gen-buffer_size_case + 1.
    ENDIF.

  ENDMETHOD.


  METHOD get_messages.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
*   Die Nachrichten werden nachgelesen, falls benötigt.
***************************************************************************************************
    DATA: lr_dbl                   TYPE REF TO cl_emma_dbl,
          lr_case                  TYPE REF TO cl_emma_case,
          lt_msg_link              TYPE emma_msg_link_tab,
          lt_msg_link_txt          TYPE emma_cmsg_link_txt_t,
          ls_docu_index            TYPE dokil,
          lv_seqnr                 TYPE emma_seqnr,
          lv_flag_object_not_found TYPE flag.

    IF gt_message IS INITIAL.
      lr_dbl = cl_emma_dbl=>create_dblayer( ).
      IF lr_dbl IS INITIAL.
        MESSAGE e214(emma) WITH gs_case-casenr INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
      lr_dbl->read_case_detail( EXPORTING  iv_case   = gs_case-casenr
                                RECEIVING  er_case   = lr_case
                                EXCEPTIONS not_found = 1
                                           OTHERS    = 2 ).
      IF sy-subrc <> 0.
        MESSAGE e214(emma) WITH gs_case-casenr INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.

      lt_msg_link     = lr_case->get_messages( ).
      lt_msg_link_txt = lr_case->get_case_msgtxt( ).

      LOOP AT lt_msg_link ASSIGNING FIELD-SYMBOL(<fs_msg_link>).
        IF <fs_msg_link>-hidden = abap_false.
          READ TABLE lt_msg_link_txt ASSIGNING FIELD-SYMBOL(<fs_msg_link_txt>) INDEX sy-tabix.

          APPEND INITIAL LINE TO gt_message ASSIGNING FIELD-SYMBOL(<fs_message>).
          <fs_message>-seqnr = lv_seqnr + 1.
          MOVE-CORRESPONDING <fs_msg_link> TO <fs_message>.
          <fs_message>-msgtxt  = <fs_msg_link_txt>-message.
          <fs_message>-msgtrig = abap_true.

          CONCATENATE <fs_msg_link>-msgid <fs_msg_link>-msgno INTO ls_docu_index-object.

          CALL FUNCTION 'DOCU_EXIST_CHECK'
            EXPORTING
              id               = 'NA'
              langu            = sy-langu
              object           = ls_docu_index-object
            IMPORTING
              docu_index       = ls_docu_index
              object_not_found = lv_flag_object_not_found
            EXCEPTIONS
              OTHERS           = 0.
          IF ls_docu_index-selfdef IS INITIAL AND lv_flag_object_not_found IS INITIAL.
            <fs_message>-msgltxt = '@35@'. "icon_system_help.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    rt_message = gt_message.

  ENDMETHOD.


  METHOD get_objects.

    rt_objects = gt_object.

  ENDMETHOD.


  METHOD get_proc_step_data.

    rs_proc_step_data = gs_proc_step_data.

  ENDMETHOD.


  METHOD get_seqnr_to_excecute.

    rv_seqnr_to_execute = gv_seqnr_to_execute.

  ENDMETHOD.


  METHOD get_solution_paths.

    rt_solution_path = gt_solution_path.

  ENDMETHOD.


  METHOD get_start_transaction_flag.

    rv_start_transaction_flag = gv_start_transaction_flag.

  ENDMETHOD.


  METHOD set_case.
    DATA: lv_casenr TYPE emma_cnr.

    IF gs_case-casenr = is_case-casenr.
      gs_case         = is_case.
    ELSE.
      lv_casenr       = gs_case-casenr.
      gs_case         = is_case.
      gs_case-casenr  = lv_casenr.
    ENDIF.
  ENDMETHOD.


  METHOD set_seqnr_to_excecute.

    IF iv_seqnr IS INITIAL.
      CLEAR gv_seqnr_to_execute.
    ELSE.
      gv_seqnr_to_execute = iv_seqnr.
    ENDIF.

  ENDMETHOD.


  METHOD set_start_transaction_flag.

    gv_start_transaction_flag = iv_start_transaction_flag.

  ENDMETHOD.


  METHOD update_db_case_solpath_track.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
* - Umsetzung analog zu CL_EMMA_DBL46->CHANGE_CASE_SOLPATH_TRACK
* - Zusätzlich wird das Flag "Automatischer Lösungsprozess" auch mit übernommen.
***************************************************************************************************
    UPDATE emma_csolp
        SET xproca        = is_solp-xproca
            procex_date   = is_solp-procex_date
            procex_time   = is_solp-procex_time
            procex_by     = is_solp-procex_by
            procex_status = is_solp-procex_status
            xprocm        = is_solp-xprocm
        WHERE casenr = is_solp-casenr AND
              seqnr  = is_solp-seqnr.
    IF sy-subrc <> 0.
      MESSAGE e012(/adesso/bpu_general) INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
