class /ADESSO/CL_BPU_UTILITY definition
  public
  final
  create public .

public section.

  class-methods DET_AUTO_EXEC_CHECK_RESULT
    importing
      !IV_CASENR type EMMA_CNR
    returning
      value(RS_CHECK_LIST_RESULT) type /IDXGC/S_CHECK_LIST_RESULT
    raising
      /IDXGC/CX_GENERAL .
  class-methods DET_CASE_OBJECTS_AND_METHODS
    importing
      !IV_CASENR type EMMA_CNR optional
      !IR_BPU_EMMA_CASE type ref to /ADESSO/CL_BPU_EMMA_CASE optional
    returning
      value(RT_CUST_OBJ) type /ADESSO/BPU_T_OBJ
    raising
      /IDXGC/CX_GENERAL .
  class-methods DET_CASETXT
    importing
      !IV_CASENR type EMMA_CNR
      !IV_ACTUAL_CASETXT type EMMA_CASETXT
    returning
      value(RV_CASETXT) type EMMA_CASETXT
    raising
      /IDXGC/CX_GENERAL .
  class-methods DET_CCAT
    importing
      !IV_CASENR type EMMA_CNR
      !IV_ACTUAL_CCAT type EMMA_CCAT
    returning
      value(RV_CCAT) type EMMA_CCAT
    raising
      /IDXGC/CX_GENERAL .
  class-methods DET_DESCRIPTION
    importing
      !IV_CASENR type EMMA_CNR
      !IT_ACTUAL_TLINE type TSFTEXT
    returning
      value(RT_TLINE) type TSFTEXT
    raising
      /IDXGC/CX_GENERAL .
  class-methods DET_DUE_DATE_TIME
    importing
      !IV_CASENR type EMMA_CNR
      !IV_ACTUAL_DUE_DATE type EMMA_CDUEDATE
      !IV_ACTUAL_DUE_TIME type EMMA_CDUETIME
    exporting
      !EV_DUE_DATE type EMMA_CDUEDATE
      !EV_DUE_TIME type EMMA_CDUETIME
    raising
      /IDXGC/CX_GENERAL .
  class-methods DET_PRIO
    importing
      !IV_CASENR type EMMA_CNR
      !IV_ACTUAL_PRIO type EMMA_CPRIO
    returning
      value(RV_PRIO) type EMMA_CPRIO
    raising
      /IDXGC/CX_GENERAL .
  class-methods DET_PROCESSES
    importing
      !IV_CASENR type EMMA_CNR
      !IT_ACTUAL_PROC type EMMA_CTXN_ALVPROCS_T
    returning
      value(RT_PROC) type EMMA_CTXN_ALVPROCS_CHG_T
    raising
      /IDXGC/CX_GENERAL .
  class-methods DET_RULES_AND_METHODS
    importing
      !IV_CASENR type EMMA_CNR optional
      !IR_BPU_EMMA_CASE type ref to /ADESSO/CL_BPU_EMMA_CASE optional
    returning
      value(RT_CUST_RDP) type /ADESSO/BPU_T_RDP
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_CASES_BY_PARAM
    importing
      !IV_ORG_TYPE type OTYPE optional
      !IV_ORG_NAME type ACTORID optional
      !IT_CASENR type EMMA_RANGES_TAB optional
      !IT_CCAT type EMMA_RANGES_TAB optional
      !IT_CASESTAT type EMMA_RANGES_TAB optional
      !IT_CURRPROC type EMMA_RANGES_TAB optional
      !IT_MAINOBJKEY type EMMA_RANGES_TAB optional
      !IV_ORG_TYPE_EXCLUDE type OTYPE optional
      !IV_ORG_NAME_EXCLUDE type ACTORID optional
    returning
      value(RT_EMMA_CASE) type EMMA_CL_CASE_T
    raising
      /IDXGC/CX_GENERAL .
  class-methods MOVE_CORRESPONDING_IGNORE_INIT
    importing
      !IS_STRUCT_SOURCE type ANY
    changing
      !CS_STRUCT_DEST type ANY
    raising
      /IDXGC/CX_GENERAL .
  PROTECTED SECTION.
private section.

  class-data GV_MTEXT type STRING .
ENDCLASS.



CLASS /ADESSO/CL_BPU_UTILITY IMPLEMENTATION.


  METHOD det_auto_exec_check_result.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
* - Es wird nur ein Prüfergebnis zurückgegeben wenn die Lösungsmethode automatisch ausführbar ist.
* - Bei mehreren Prüfergebnissen müssen alle Lösungsmethoden automatisch ausführbar sein.
***************************************************************************************************
    TYPES: BEGIN OF ts_adv_check_list_result.
            INCLUDE TYPE /idxgc/s_check_list_result.
    TYPES:   exec_sol_met_type TYPE /adesso/bpu_exec_sol_met_type.
    TYPES: END OF ts_adv_check_list_result.
    TYPES: tt_adv_check_list_result TYPE TABLE OF ts_adv_check_list_result.

    DATA: lr_bpu_emma_case         TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_adv_check_list_result TYPE tt_adv_check_list_result,
          lt_solp                  TYPE emma_csop_t,
          lt_check                 TYPE /idxgc/t_check_details,
          ls_proc_step_data        TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fs_check>                 TYPE /idxgc/s_check_details,
                   <fs_adv_check_list_result> TYPE ts_adv_check_list_result.

    lr_bpu_emma_case  = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    lt_check          = lr_bpu_emma_case->get_checks_for_exception_code( ).
    lt_solp           = lr_bpu_emma_case->get_solution_paths( ).

    READ TABLE lt_solp WITH KEY method = /idxgc/if_constants_add=>gc_method_show_chk_list_rlt TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      "Prüfung ob mehrere verschiedene Lösungsmethoden hinterlegt sind. Falls ja->keine automatisierte Ausführung der Methode
      LOOP AT lt_check ASSIGNING <fs_check> WHERE excp_solving_cls IS NOT INITIAL AND excp_solving_mtd IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_adv_check_list_result ASSIGNING <fs_adv_check_list_result>.
        MOVE-CORRESPONDING <fs_check> TO <fs_adv_check_list_result>.
        <fs_adv_check_list_result>-exec_sol_met_type = /adesso/cl_bpu_customizing=>get_exec_sol_met_type( iv_proc_id      = ls_proc_step_data-proc_id
                                                                                                          iv_proc_version = ls_proc_step_data-proc_version
                                                                                                          iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                                                                          iv_check_id     = <fs_check>-check_id
                                                                                                          iv_check_result = <fs_check>-check_result ).
      ENDLOOP.
      DELETE ADJACENT DUPLICATES FROM lt_adv_check_list_result COMPARING excp_solving_cls excp_solving_mtd exec_sol_met_type.
      IF lines( lt_adv_check_list_result ) = 1.
        IF lt_adv_check_list_result[ 1 ]-exec_sol_met_type = /adesso/if_bpu_co=>gc_exec_sol_met_type_02.
          MOVE-CORRESPONDING lt_adv_check_list_result[ 1 ] TO rs_check_list_result.
          rs_check_list_result-proc_ref      = ls_proc_step_data-proc_ref.
          rs_check_list_result-proc_step_ref = ls_proc_step_data-proc_step_ref.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD det_casetxt.
    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_check          TYPE /idxgc/t_check_details,
          lt_casetxt        TYPE TABLE OF emma_casetxt,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          ls_cust_txt       TYPE /adesso/bpu_s_txt,
          ls_cust_gen       TYPE /adesso/bpu_s_gen,
          lv_casetxt_1      TYPE emma_casetxt,
          lv_casetxt_2      TYPE emma_casetxt,
          lv_casetxt_3      TYPE emma_casetxt,
          lv_num_casetxt    TYPE char2.

    FIELD-SYMBOLS: <fs_check>   TYPE /idxgc/s_check_details,
                   <fv_casetxt> TYPE emma_casetxt.

    ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).

    lr_bpu_emma_case  = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    lt_check          = lr_bpu_emma_case->get_checks_for_exception_code( ).

    IF lt_check IS NOT INITIAL.
      LOOP AT lt_check ASSIGNING <fs_check>.
        CLEAR ls_cust_txt.
        ls_cust_txt = /adesso/cl_bpu_customizing=>get_cust_texts( iv_proc_id      = ls_proc_step_data-proc_id
                                                                  iv_proc_version = ls_proc_step_data-proc_version
                                                                  iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                                  iv_check_id     = <fs_check>-check_id
                                                                  iv_check_result = <fs_check>-check_result ).
        APPEND INITIAL LINE TO lt_casetxt ASSIGNING <fv_casetxt>.
        CASE ls_cust_txt-casetxt_source.
          WHEN /adesso/if_bpu_co=>gc_casetxt_source_01.
            <fv_casetxt> = <fs_check>-excn_txt.
          WHEN /adesso/if_bpu_co=>gc_casetxt_source_02.
            <fv_casetxt> = ls_cust_txt-casetxt.
          WHEN OTHERS. "Wenn im Prozesscustomizing keine Einträge sind, dann wird im generellen Customizing geschaut.
            IF ls_cust_gen-casetxt_source_std = /adesso/if_bpu_co=>gc_casetxt_source_01.
              <fv_casetxt> = <fs_check>-excn_txt.
            ELSE. "Wenn gar nichts da ist wird der Standardtext verwendet.
              <fv_casetxt> = iv_actual_casetxt.
            ENDIF.
        ENDCASE.
      ENDLOOP.
    ELSE.
      ls_cust_txt = /adesso/cl_bpu_customizing=>get_cust_texts( iv_proc_id      = ls_proc_step_data-proc_id
                                                                iv_proc_version = ls_proc_step_data-proc_version
                                                                iv_proc_step_no = ls_proc_step_data-proc_step_no ).
      APPEND INITIAL LINE TO lt_casetxt ASSIGNING <fv_casetxt>.
      CASE ls_cust_txt-casetxt_source.
        WHEN /adesso/if_bpu_co=>gc_casetxt_source_02.
          <fv_casetxt> = ls_cust_txt-casetxt.
        WHEN OTHERS. "Wenn im Prozesscustomizing keine Einträge sind, dann wird im generellen Customizing geschaut.
          <fv_casetxt> = iv_actual_casetxt.
      ENDCASE.
    ENDIF.

    SORT lt_casetxt.
    DELETE ADJACENT DUPLICATES FROM lt_casetxt.

    lv_num_casetxt = lines( lt_casetxt ).

    IF lv_num_casetxt = 1.
      rv_casetxt = lt_casetxt[ 1 ].
    ELSEIF lv_num_casetxt > 1.
      CASE lv_num_casetxt.
        WHEN 2.
          lv_casetxt_1 = lt_casetxt[ 1 ].
          lv_casetxt_2 = lt_casetxt[ 2 ].
          CONCATENATE 'Multi-' lv_num_casetxt ':' INTO rv_casetxt.
          CONCATENATE rv_casetxt lv_casetxt_1(23) INTO rv_casetxt SEPARATED BY space.
          CONCATENATE rv_casetxt lv_casetxt_2(23) INTO rv_casetxt SEPARATED BY ' | '.
        WHEN 3.
          lv_casetxt_1 = lt_casetxt[ 1 ].
          lv_casetxt_2 = lt_casetxt[ 2 ].
          lv_casetxt_3 = lt_casetxt[ 3 ].
          CONCATENATE 'Multi-' lv_num_casetxt ':' INTO rv_casetxt.
          CONCATENATE rv_casetxt lv_casetxt_1(15) INTO rv_casetxt SEPARATED BY space.
          CONCATENATE rv_casetxt lv_casetxt_2(15) lv_casetxt_3(15) INTO rv_casetxt SEPARATED BY ' | '.
        WHEN OTHERS.
          lv_casetxt_1 = lt_casetxt[ 1 ].
          lv_casetxt_2 = lt_casetxt[ 2 ].
          lv_casetxt_3 = lt_casetxt[ 3 ].
          CONCATENATE 'Multi-' lv_num_casetxt ':' INTO rv_casetxt.
          CONCATENATE rv_casetxt lv_casetxt_1(14) INTO rv_casetxt SEPARATED BY space.
          CONCATENATE rv_casetxt lv_casetxt_2(14) lv_casetxt_3(14) '...' INTO rv_casetxt SEPARATED BY ' | '.
      ENDCASE.
    ELSE.
      rv_casetxt = iv_actual_casetxt.
    ENDIF.

  ENDMETHOD.


  METHOD det_case_objects_and_methods.
    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_check          TYPE /idxgc/t_check_details,
          lt_obj_group_id   TYPE TABLE OF /adesso/bpu_obj_group_id,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          lv_obj_group_id   TYPE /adesso/bpu_obj_group_id.

    FIELD-SYMBOLS: <fs_check>        TYPE /idxgc/s_check_details,
                   <fv_obj_group_id> TYPE /adesso/bpu_obj_group_id.

    IF ir_bpu_emma_case IS NOT INITIAL.
      lr_bpu_emma_case = ir_bpu_emma_case.
    ELSEIF iv_casenr IS NOT INITIAL.
      lr_bpu_emma_case = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ELSE.
      MESSAGE e013(/adesso/bpu_general) WITH 'DET_CASE_OBJECTS_AND_METHODS' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    lt_check          = lr_bpu_emma_case->get_checks_for_exception_code( ).


***** Objekt-Gruppen ermitteln ********************************************************************
    IF lt_check IS NOT INITIAL.
      LOOP AT lt_check ASSIGNING <fs_check>.
        lv_obj_group_id = /adesso/cl_bpu_customizing=>get_obj_group_id( iv_proc_id      = ls_proc_step_data-proc_id
                                                                        iv_proc_version = ls_proc_step_data-proc_version
                                                                        iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                                        iv_check_id     = <fs_check>-check_id
                                                                        iv_check_result = <fs_check>-check_result ).
        IF lv_obj_group_id IS NOT INITIAL.
          COLLECT lv_obj_group_id INTO lt_obj_group_id.
        ENDIF.
      ENDLOOP.
    ELSE.
      lv_obj_group_id = /adesso/cl_bpu_customizing=>get_obj_group_id( iv_proc_id      = ls_proc_step_data-proc_id
                                                                      iv_proc_version = ls_proc_step_data-proc_version
                                                                      iv_proc_step_no = ls_proc_step_data-proc_step_no ).
      IF lv_obj_group_id IS NOT INITIAL.
        APPEND lv_obj_group_id TO lt_obj_group_id.
      ENDIF.
    ENDIF.


***** Objekte zu Gruppen ermitteln ****************************************************************
    LOOP AT lt_obj_group_id ASSIGNING <fv_obj_group_id>.
      APPEND LINES OF /adesso/cl_bpu_customizing=>get_objects_for_group_id( iv_obj_group_id = <fv_obj_group_id> ) TO rt_cust_obj.
    ENDLOOP.
    SORT rt_cust_obj BY object.
    DELETE ADJACENT DUPLICATES FROM rt_cust_obj COMPARING object.

  ENDMETHOD.


  METHOD det_ccat.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_check          TYPE /idxgc/t_check_details,
          lt_ccat           TYPE TABLE OF emma_ccat,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          lv_ccat           TYPE emma_ccat.

    FIELD-SYMBOLS: <fs_check> TYPE /idxgc/s_check_details.


    lr_bpu_emma_case  = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    lt_check          = lr_bpu_emma_case->get_checks_for_exception_code( ).

    IF lt_check IS NOT INITIAL.
      LOOP AT lt_check ASSIGNING <fs_check>.
        lv_ccat = /adesso/cl_bpu_customizing=>get_ccat( iv_proc_id      = ls_proc_step_data-proc_id
                                                        iv_proc_version = ls_proc_step_data-proc_version
                                                        iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                        iv_check_id     = <fs_check>-check_id
                                                        iv_check_result = <fs_check>-check_result ).
        IF lv_ccat IS INITIAL.
          COLLECT iv_actual_ccat INTO lt_ccat.
        ELSE.
          COLLECT lv_ccat INTO lt_ccat.
        ENDIF.
      ENDLOOP.
    ELSE.
      lv_ccat = /adesso/cl_bpu_customizing=>get_ccat( iv_proc_id      = ls_proc_step_data-proc_id
                                                      iv_proc_version = ls_proc_step_data-proc_version
                                                      iv_proc_step_no = ls_proc_step_data-proc_step_no ).
      IF lv_ccat IS INITIAL.
        COLLECT iv_actual_ccat INTO lt_ccat.
      ELSE.
        COLLECT lv_ccat INTO lt_ccat.
      ENDIF.
    ENDIF.

    IF lines( lt_ccat ) = 1.
      rv_ccat = lt_ccat[ 1 ].
    ELSE. "Bei keinem Eintrag oder mehreren Einträgen, ursprünglichen Klärfall behalten.
      rv_ccat = iv_actual_ccat.
    ENDIF.

  ENDMETHOD.


  METHOD det_description.
    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_check          TYPE /idxgc/t_check_details,
          lt_tline          TYPE tsftext,
          ls_tline_empty    TYPE tline,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          ls_case           TYPE emma_case,
          ls_cust_txt       TYPE /adesso/bpu_s_txt,
          lv_num_casetxt    TYPE char2.

    FIELD-SYMBOLS: <fs_check>  TYPE /idxgc/s_check_details,
                   <fs_tline>  TYPE tline,
                   <fs_symbol> TYPE itcst.

    lr_bpu_emma_case  = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    ls_case           = lr_bpu_emma_case->get_case( ).
    lt_check          = lr_bpu_emma_case->get_checks_for_exception_code( ).

    ls_tline_empty-tdformat = '*'.
    ls_tline_empty-tdline   = space.

    rt_tline = it_actual_tline.

    IF lt_check IS NOT INITIAL.
      LOOP AT lt_check ASSIGNING <fs_check>.
        CLEAR ls_cust_txt.
        ls_cust_txt = /adesso/cl_bpu_customizing=>get_cust_texts( iv_proc_id      = ls_proc_step_data-proc_id
                                                                  iv_proc_version = ls_proc_step_data-proc_version
                                                                  iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                                  iv_check_id     = <fs_check>-check_id
                                                                  iv_check_result = <fs_check>-check_result ).
        IF ls_cust_txt-tdname IS NOT INITIAL.
          CLEAR: lt_tline.
          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              id                      = 'ST'
              language                = sy-langu
              name                    = ls_cust_txt-tdname
              object                  = 'TEXT'
            TABLES
              lines                   = lt_tline
            EXCEPTIONS
              id                      = 1
              language                = 2
              name                    = 3
              not_found               = 4
              object                  = 5
              reference_check         = 6
              wrong_access_to_archive = 7
              OTHERS                  = 8.
          IF sy-subrc = 0.
            "Zwei Leerzeilen hinzufügen und dann Prüfung und Prüfergebnis inkl. Text einfügen
            APPEND ls_tline_empty TO rt_tline.
            APPEND ls_tline_empty TO rt_tline.

            APPEND INITIAL LINE TO rt_tline ASSIGNING <fs_tline>.
            <fs_tline>-tdformat = '*'.
            CONCATENATE 'Prüfung:      ' <fs_check>-swtchecktxt '(' <fs_check>-check_id ')' INTO <fs_tline>-tdline RESPECTING BLANKS.

            APPEND INITIAL LINE TO rt_tline ASSIGNING <fs_tline>.
            <fs_tline>-tdformat = '*'.
            CONCATENATE 'Prüfergebnis: ' <fs_check>-swtchecktxt '(' <fs_check>-check_result ')' INTO <fs_tline>-tdline RESPECTING BLANKS.

            APPEND ls_tline_empty TO rt_tline.

            APPEND LINES OF lt_tline TO rt_tline.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      ls_cust_txt = /adesso/cl_bpu_customizing=>get_cust_texts( iv_proc_id      = ls_proc_step_data-proc_id
                                                                iv_proc_version = ls_proc_step_data-proc_version
                                                                iv_proc_step_no = ls_proc_step_data-proc_step_no ).
      IF ls_cust_txt-tdname IS NOT INITIAL.
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'ST'
            language                = sy-langu
            name                    = ls_cust_txt-tdname
            object                  = 'TEXT'
          TABLES
            lines                   = lt_tline
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
          IF rt_tline IS NOT INITIAL.
            "Zwei Leerzeilen hinzufügen und dann Text einfügen
            APPEND ls_tline_empty TO rt_tline.
            APPEND ls_tline_empty TO rt_tline.
          ENDIF.
          APPEND LINES OF lt_tline TO rt_tline.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD det_due_date_time.
    TYPES: BEGIN OF ts_due_date_time,
             due_date TYPE emma_cduedate,
             due_time TYPE emma_cduetime,
           END OF ts_due_date_time,
           tt_due_date_time TYPE TABLE OF ts_due_date_time.

    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_check          TYPE /idxgc/t_check_details,
          lt_due_date_time  TYPE tt_due_date_time,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          ls_case           TYPE emma_case,
          ls_cust_dued      TYPE /adesso/bpu_s_dued.

    FIELD-SYMBOLS: <fs_check>         TYPE /idxgc/s_check_details,
                   <fs_due_date_time> TYPE ts_due_date_time.

    lr_bpu_emma_case  = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    ls_case           = lr_bpu_emma_case->get_case( ).
    lt_check          = lr_bpu_emma_case->get_checks_for_exception_code( ).

    IF lt_check IS NOT INITIAL.
      LOOP AT lt_check ASSIGNING <fs_check>.
        ls_cust_dued = /adesso/cl_bpu_customizing=>get_cust_due_date( iv_proc_id      = ls_proc_step_data-proc_id
                                                                      iv_proc_version = ls_proc_step_data-proc_version
                                                                      iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                                      iv_check_id     = <fs_check>-check_id
                                                                      iv_check_result = <fs_check>-check_result ).
        IF ls_cust_dued IS INITIAL.
          APPEND INITIAL LINE TO lt_due_date_time ASSIGNING <fs_due_date_time>.
          <fs_due_date_time>-due_date = iv_actual_due_date.
          <fs_due_date_time>-due_time = iv_actual_due_time.
        ELSE.
          APPEND INITIAL LINE TO lt_due_date_time ASSIGNING <fs_due_date_time>.
          cl_emma_case=>determine_due_date( EXPORTING iv_timtyp      = ls_cust_dued-timtyp
                                                      iv_timqty      = ls_cust_dued-timqty
                                                      iv_xddcal      = cl_emma_case=>co_ddcal_crea
                                                      iv_create_date = ls_case-created_date
                                                      iv_create_time = ls_case-created_time
                                                      iv_orig_date   = sy-datum
                                                      iv_orig_time   = sy-uzeit
                                            IMPORTING ev_due_date    = <fs_due_date_time>-due_date
                                                      ev_due_time    = <fs_due_date_time>-due_time ).
        ENDIF.
      ENDLOOP.

      SORT lt_due_date_time BY due_date due_time. "Frühestes Datum nehmen bei mehreren
      ev_due_date = lt_due_date_time[ 1 ]-due_date.
      ev_due_time = lt_due_date_time[ 1 ]-due_time.
    ELSE.
      ls_cust_dued = /adesso/cl_bpu_customizing=>get_cust_due_date( iv_proc_id      = ls_proc_step_data-proc_id
                                                                    iv_proc_version = ls_proc_step_data-proc_version
                                                                    iv_proc_step_no = ls_proc_step_data-proc_step_no ).
      IF ls_cust_dued IS NOT INITIAL.
        cl_emma_case=>determine_due_date( EXPORTING iv_timtyp      = ls_cust_dued-timtyp
                                                    iv_timqty      = ls_cust_dued-timqty
                                                    iv_xddcal      = cl_emma_case=>co_ddcal_crea
                                                    iv_create_date = ls_case-created_date
                                                    iv_create_time = ls_case-created_time
                                                    iv_orig_date   = sy-datum
                                                    iv_orig_time   = sy-uzeit
                                          IMPORTING ev_due_date    = ev_due_date
                                                    ev_due_time    = ev_due_time ).
      ELSE.
        ev_due_date = iv_actual_due_date.
        ev_due_time = iv_actual_due_time.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD det_prio.
    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_check          TYPE /idxgc/t_check_details,
          lt_prio           TYPE TABLE OF emma_cprio,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          lv_prio           TYPE emma_cprio.

    FIELD-SYMBOLS: <fs_check> TYPE /idxgc/s_check_details.

    lr_bpu_emma_case  = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    lt_check          = lr_bpu_emma_case->get_checks_for_exception_code( ).

    IF lt_check IS NOT INITIAL.
      LOOP AT lt_check ASSIGNING <fs_check>.
        lv_prio = /adesso/cl_bpu_customizing=>get_prio( iv_proc_id      = ls_proc_step_data-proc_id
                                                        iv_proc_version = ls_proc_step_data-proc_version
                                                        iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                        iv_check_id     = <fs_check>-check_id
                                                        iv_check_result = <fs_check>-check_result ).
        IF lv_prio IS INITIAL.
          APPEND iv_actual_prio TO lt_prio.
        ELSE.
          APPEND lv_prio TO lt_prio.
        ENDIF.
      ENDLOOP.
    ELSE.
      lv_prio = /adesso/cl_bpu_customizing=>get_prio( iv_proc_id      = ls_proc_step_data-proc_id
                                                      iv_proc_version = ls_proc_step_data-proc_version
                                                      iv_proc_step_no = ls_proc_step_data-proc_step_no ).
      IF lv_prio IS NOT INITIAL.
        APPEND lv_prio TO lt_prio.
      ENDIF.
    ENDIF.
    IF lt_prio IS INITIAL.
      rv_prio = iv_actual_prio.
    ELSE.
      SORT lt_prio. "Höchste Priorität zuerst
      rv_prio = lt_prio[ 1 ].
    ENDIF.
  ENDMETHOD.


  METHOD det_processes.
    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_check          TYPE /idxgc/t_check_details,
          lt_cust_sop       TYPE /adesso/bpu_t_sop,
          lt_cust_sop_temp  TYPE /adesso/bpu_t_sop,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fs_cust_sop>      TYPE /adesso/bpu_s_sop,
                   <fs_cust_sop_temp> TYPE /adesso/bpu_s_sop,
                   <fs_actual_proc>   TYPE emma_ctxn_alvprocs,
                   <fs_proc>          TYPE emma_ctxn_alvprocs_chg.

    lr_bpu_emma_case  = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    lt_check = lr_bpu_emma_case->get_checks_for_exception_code( ).
    IF lt_check IS NOT INITIAL.
      LOOP AT lt_check ASSIGNING FIELD-SYMBOL(<fs_check>).
        AT FIRST.
          lt_cust_sop = /adesso/cl_bpu_customizing=>get_cust_sop( iv_proc_id      = ls_proc_step_data-proc_id
                                                                  iv_proc_version = ls_proc_step_data-proc_version
                                                                  iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                                  iv_check_id     = <fs_check>-check_id
                                                                  iv_check_result = <fs_check>-check_result ).
          CONTINUE.
        ENDAT.
        lt_cust_sop_temp = /adesso/cl_bpu_customizing=>get_cust_sop( iv_proc_id      = ls_proc_step_data-proc_id
                                                                     iv_proc_version = ls_proc_step_data-proc_version
                                                                     iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                                     iv_check_id     = <fs_check>-check_id
                                                                     iv_check_result = <fs_check>-check_result ).
        IF lt_cust_sop <> lt_cust_sop_temp. "Nur Einträge behalten, die bei allen gleich sind.
          LOOP AT lt_cust_sop ASSIGNING <fs_cust_sop>.
            READ TABLE lt_cust_sop_temp ASSIGNING <fs_cust_sop_temp> WITH KEY seqnr = <fs_cust_sop>-seqnr.
            IF sy-subrc <> 0 OR <fs_cust_sop> <> <fs_cust_sop_temp>.
              DELETE lt_cust_sop.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ELSE.
      lt_cust_sop = /adesso/cl_bpu_customizing=>get_cust_sop( iv_proc_id      = ls_proc_step_data-proc_id
                                                              iv_proc_version = ls_proc_step_data-proc_version
                                                              iv_proc_step_no = ls_proc_step_data-proc_step_no ).
    ENDIF.

    LOOP AT it_actual_proc ASSIGNING <fs_actual_proc>.
      READ TABLE lt_cust_sop ASSIGNING <fs_cust_sop> WITH KEY seqnr = <fs_actual_proc>-seqnr.
      IF sy-subrc = 0.
        IF <fs_cust_sop>-hidden = abap_false.
          APPEND INITIAL LINE TO rt_proc ASSIGNING <fs_proc>.
          MOVE-CORRESPONDING <fs_actual_proc> TO <fs_proc>.
          IF <fs_cust_sop>-icon IS NOT INITIAL.
            <fs_proc>-icon(3) = <fs_cust_sop>-icon(3).
          ENDIF.
          IF <fs_cust_sop>-soptext IS NOT INITIAL.
            <fs_proc>-descript = <fs_cust_sop>-soptext.
          ENDIF.
        ENDIF.
      ELSE.
        IF <fs_actual_proc>-hidden = abap_false.
          APPEND INITIAL LINE TO rt_proc ASSIGNING <fs_proc>.
          MOVE-CORRESPONDING <fs_actual_proc> TO <fs_proc>.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD DET_RULES_AND_METHODS.
    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lt_check          TYPE /idxgc/t_check_details,
          lt_ccrule         TYPE TABLE OF emma_ccrule,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all,
          ls_case           TYPE emma_case,
          lv_ccrule         TYPE emma_ccrule.

    FIELD-SYMBOLS: <fs_check>  TYPE /idxgc/s_check_details,
                   <fv_ccrule> TYPE emma_ccrule.

    IF ir_bpu_emma_case IS NOT INITIAL.
      lr_bpu_emma_case = ir_bpu_emma_case.
    ELSEIF iv_casenr IS NOT INITIAL.
      lr_bpu_emma_case = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ELSE.
      MESSAGE e013(/adesso/bpu_general) WITH 'DET_RULES_AND_METHODS' INTO gv_mtext.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    lt_check          = lr_bpu_emma_case->get_checks_for_exception_code( ).


****** Objekt-Gruppen ermitteln ********************************************************************
    IF lt_check IS NOT INITIAL.
      LOOP AT lt_check ASSIGNING <fs_check>.
        lv_ccrule = /adesso/cl_bpu_customizing=>get_rule( iv_proc_id      = ls_proc_step_data-proc_id
                                                          iv_proc_version = ls_proc_step_data-proc_version
                                                          iv_proc_step_no = ls_proc_step_data-proc_step_no
                                                          iv_check_id     = <fs_check>-check_id
                                                          iv_check_result = <fs_check>-check_result ).
        IF lv_ccrule IS NOT INITIAL.
          COLLECT lv_ccrule INTO lt_ccrule.
        ENDIF.
      ENDLOOP.
    ELSE.
      lv_ccrule = /adesso/cl_bpu_customizing=>get_rule( iv_proc_id      = ls_proc_step_data-proc_id
                                                        iv_proc_version = ls_proc_step_data-proc_version
                                                        iv_proc_step_no = ls_proc_step_data-proc_step_no ).
      IF lv_ccrule IS NOT INITIAL.
        APPEND lv_ccrule TO lt_ccrule.
      ENDIF.
    ENDIF.


****** Objekte/Methoden zu Regeln ermitteln *******************************************************
    LOOP AT lt_ccrule ASSIGNING <fv_ccrule>.
      APPEND LINES OF /adesso/cl_bpu_customizing=>get_objects_for_rule( iv_ccrule = <fv_ccrule> ) TO rt_cust_rdp.
    ENDLOOP.
    SORT rt_cust_rdp BY ccrule object.
    DELETE ADJACENT DUPLICATES FROM rt_cust_rdp COMPARING ccrule object.

  ENDMETHOD.


  METHOD get_cases_by_param.
    DATA: lt_actors    TYPE TABLE OF bapi_swhactor,
          lt_actor_id  TYPE RANGE OF actorid,
          ls_actor_id  LIKE LINE OF lt_actor_id,
          lr_case_db   TYPE REF TO cl_emma_dbl,
          lt_emma_case TYPE emma_case_tab,
          lr_case      TYPE REF TO cl_emma_case.

    FIELD-SYMBOLS: <fs_actors>    TYPE bapi_swhactor,
                   <fs_emma_case> TYPE emma_case.

    "Benutzer einschließen
    IF iv_org_type IS NOT INITIAL AND iv_org_name IS NOT INITIAL.

      ls_actor_id-sign = 'I'.
      ls_actor_id-option = 'EQ'.
      ls_actor_id-low = iv_org_name.

      APPEND ls_actor_id TO lt_actor_id.

      CALL METHOD cl_emma_case=>determine_superior_org_obj
        EXPORTING
          iv_orgtype               = iv_org_type
          iv_orgid                 = iv_org_name
          iv_wegid                 = 'EMMA1'
          iv_plvar                 = space
          iv_begda                 = sy-datum
          iv_endda                 = sy-datum
        RECEIVING
          et_actors                = lt_actors
        EXCEPTIONS
          error_determining_actors = 1
          OTHERS                   = 2.
      IF sy-subrc = 0.
      ENDIF.

      LOOP AT lt_actors ASSIGNING <fs_actors> WHERE otype = 'S' OR otype = 'US'.
        ls_actor_id-low = <fs_actors>-objid.
        APPEND ls_actor_id TO lt_actor_id.
      ENDLOOP.

    ENDIF.

    "Benutzer ausschließen
    IF iv_org_type_exclude IS NOT INITIAL AND iv_org_name_exclude IS NOT INITIAL.

      ls_actor_id-sign = 'E'.
      ls_actor_id-option = 'EQ'.
      ls_actor_id-low = iv_org_name_exclude.

      APPEND ls_actor_id TO lt_actor_id.

      CALL METHOD cl_emma_case=>determine_superior_org_obj
        EXPORTING
          iv_orgtype               = iv_org_type_exclude
          iv_orgid                 = iv_org_name_exclude
          iv_wegid                 = 'EMMA1'
          iv_plvar                 = space
          iv_begda                 = sy-datum
          iv_endda                 = sy-datum
        RECEIVING
          et_actors                = lt_actors
        EXCEPTIONS
          error_determining_actors = 1
          OTHERS                   = 2.
      IF sy-subrc = 0.
      ENDIF.

      LOOP AT lt_actors ASSIGNING <fs_actors> WHERE otype = 'S' OR otype = 'US'.
        ls_actor_id-low = <fs_actors>-objid.
        APPEND ls_actor_id TO lt_actor_id.
      ENDLOOP.

    ENDIF.

    SELECT * FROM emma_case AS emc
      JOIN emma_cactor AS ema ON emc~casenr = ema~casenr
      INTO CORRESPONDING FIELDS OF TABLE lt_emma_case
      WHERE emc~status     IN it_casestat AND
            emc~casenr     IN it_casenr AND
            emc~ccat       IN it_ccat AND
            emc~currproc   IN it_currproc AND
            emc~mainobjkey IN it_mainobjkey AND
            ema~objid      IN lt_actor_id.

    IF iv_org_type IS NOT INITIAL AND iv_org_name IS NOT INITIAL.

      SELECT * FROM emma_case APPENDING TABLE lt_emma_case
      WHERE status IN it_casestat AND
            casenr IN it_casenr AND
            ccat IN it_ccat AND
            currproc = iv_org_name.

    ENDIF.

    lr_case_db = cl_emma_dbl=>create_dblayer( ).

    SORT lt_emma_case BY casenr.
    DELETE ADJACENT DUPLICATES FROM lt_emma_case.

    IF lr_case_db IS BOUND.
      LOOP AT lt_emma_case ASSIGNING <fs_emma_case>.
        lr_case ?= lr_case_db->read_case_detail( iv_case = <fs_emma_case>-casenr ).
        APPEND lr_case TO rt_emma_case.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD move_corresponding_ignore_init.
    DATA: lr_abap_structdescr TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS: <ft_struct_source_table> TYPE table,
                   <ft_struct_dest_table>   TYPE table.

    lr_abap_structdescr ?= cl_abap_typedescr=>describe_by_data( is_struct_source ).
    LOOP AT lr_abap_structdescr->components ASSIGNING FIELD-SYMBOL(<fs_struct_component>).
      IF <fs_struct_component>-type_kind = cl_abap_structdescr=>typekind_table.
        ASSIGN COMPONENT <fs_struct_component>-name OF STRUCTURE cs_struct_dest TO <ft_struct_dest_table>.
        ASSIGN COMPONENT <fs_struct_component>-name OF STRUCTURE is_struct_source TO <ft_struct_source_table>.
        IF <ft_struct_dest_table> IS ASSIGNED AND <ft_struct_source_table> IS ASSIGNED.
          APPEND LINES OF <ft_struct_source_table> TO <ft_struct_dest_table>.
          SORT <ft_struct_dest_table>.
          DELETE ADJACENT DUPLICATES FROM <ft_struct_dest_table>.
        ENDIF.
      ELSE.
        ASSIGN COMPONENT <fs_struct_component>-name OF STRUCTURE cs_struct_dest TO FIELD-SYMBOL(<fv_struct_dest_field>).
        IF sy-subrc = 0.
          ASSIGN COMPONENT <fs_struct_component>-name OF STRUCTURE is_struct_source TO FIELD-SYMBOL(<fv_struct_source_field>).
          IF sy-subrc = 0 AND <fv_struct_source_field> IS NOT INITIAL.
            <fv_struct_dest_field> = <fv_struct_source_field>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
