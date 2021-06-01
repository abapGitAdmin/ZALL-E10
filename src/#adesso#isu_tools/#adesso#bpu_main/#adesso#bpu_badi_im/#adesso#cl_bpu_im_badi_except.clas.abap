class /ADESSO/CL_BPU_IM_BADI_EXCEPT definition
  public
  inheriting from /IDXGC/CL_DEF_BADI_EXCEPTION
  create public .

public section.

  methods /IDXGC/IF_BADI_EXCEPTION~CREATE_EXCEPTION
    redefinition .
protected section.

  methods GET_CASETXT
    importing
      !IV_CASENR type EMMA_CNR
      !IS_EXCEPTION_DATA type /IDXGC/S_EXCP_DATA
      !IS_EXCEPTION_CONFIG type /IDXGC/S_EXCP_CONFIG
    returning
      value(RV_EMMA_CASETXT) type EMMA_CASETXT
    raising
      /IDXGC/CX_GENERAL .
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPU_IM_BADI_EXCEPT IMPLEMENTATION.


  METHOD /idxgc/if_badi_exception~create_exception.
    DATA: lr_previous         TYPE REF TO /idxgc/cx_general,
          ls_exception_config	TYPE /idxgc/s_excp_config,
          ls_case             TYPE emma_case,
          lr_dbl              TYPE REF TO cl_emma_dbl,
          lr_dbcase           TYPE REF TO cl_emma_case,
          lr_case             TYPE REF TO cl_emma_case.
    "lv_mtext            TYPE string.

    FIELD-SYMBOLS: <fs_check>           TYPE /idxgc/s_check_details,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

***** Prozessdaten ermitteln **********************************************************************
    TRY.
        /adesso/cl_bpu_emma_case=>create_temporary_case( is_exception_data   = is_exception_data
                                                         is_exception_config = is_exception_config
                                                         ir_process_data     = ir_process_data ).
      CATCH /idxgc/cx_general INTO lr_previous.
        cr_process_log->add_exception_to_process_log( ir_exception = lr_previous ).
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lr_previous ).
    ENDTRY.


***** Klärfallkategorie ggf. übersteuern und Klärfall erzeugen ************************************
    ls_exception_config = is_exception_config.
    TRY.
        ls_exception_config-case_category = /adesso/cl_bpu_utility=>det_ccat( iv_casenr      = /adesso/if_bpu_co=>gc_temporary_casenr
                                                                              iv_actual_ccat = is_exception_config-case_category ).
      CATCH /idxgc/cx_general INTO lr_previous.
        cr_process_log->add_exception_to_process_log( ir_exception = lr_previous ).
        "Mit Standard-Kategorie weiter
    ENDTRY.

    CALL METHOD super->/idxgc/if_badi_exception~create_exception
      EXPORTING
        is_exception_data   = is_exception_data
        is_exception_config = ls_exception_config
        ir_process_data     = ir_process_data
        iv_simulate         = iv_simulate
      CHANGING
        cv_exception_number = cv_exception_number
        cr_process_document = cr_process_document
        cr_process_log      = cr_process_log.


***** Klärfalltext ggf. übersteuern und Klärfall aktualisieren ************************************
    IF cv_exception_number IS NOT INITIAL.
      IF lr_dbl IS INITIAL.
        lr_dbl = cl_emma_dbl=>create_dblayer( ).
      ENDIF.

      lr_case = lr_dbl->read_case_detail( iv_case = cv_exception_number ).
      IF lr_case IS NOT BOUND.
        RETURN.
      ENDIF.
      lr_dbcase = lr_case->clone( ).
      ls_case = lr_case->get_data( ).

      TRY.
          ls_case-casetxt = /adesso/cl_bpu_utility=>det_casetxt( iv_casenr = cv_exception_number iv_actual_casetxt = ls_case-casetxt ).
        CATCH /idxgc/cx_general INTO lr_previous.
          cr_process_log->add_exception_to_process_log( ir_exception = lr_previous ).
          "Mit Standard-Text weiter
      ENDTRY.

      TRY.
          ls_case-casetxt = me->get_casetxt( iv_casenr           = cv_exception_number
                                             is_exception_data   = is_exception_data
                                             is_exception_config = is_exception_config ).
        CATCH /idxgc/cx_general.
          "Alten Text beibehalten
      ENDTRY.

      lr_case->set_data( iv_case = ls_case ).
      lr_dbl->change_case( EXPORTING  ir_case = lr_case
                                      ir_dbcase = lr_dbcase
                           EXCEPTIONS error_inserting_objects = 1
                                      error_updating_case     = 2
                                      error_saving_text       = 3
                                      OTHERS                  = 4 ).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD GET_CASETXT.
    "Kundenindividuell in jedem System zu implementieren.
    /idxgc/cx_general=>raise_exception_from_msg( ).
  ENDMETHOD.
ENDCLASS.
