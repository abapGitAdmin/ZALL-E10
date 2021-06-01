class /ADZ/CL_BDR_SOLVE_ISSUES definition
  public
  create public .

public section.

  class-methods CHECK_CHG_DEV_CONFIG_SOLUTION
    importing
      !IS_CHECK_LIST_RESULT type /IDXGC/S_CHECK_LIST_RESULT
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_CHG_SETTL_SOLUTION
    importing
      !IS_CHECK_LIST_RESULT type /IDXGC/S_CHECK_LIST_RESULT
    raising
      /IDXGC/CX_UTILITY_ERROR .
  class-methods CHECK_RECL_VALUE_SOLUTION
    importing
      !IS_CHECK_LIST_RESULT type /IDXGC/S_CHECK_LIST_RESULT
    raising
      /IDXGC/CX_UTILITY_ERROR .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /ADZ/CL_BDR_SOLVE_ISSUES IMPLEMENTATION.


  METHOD check_chg_dev_config_solution.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: SCHMIDT-M, THIMEL-R                                                     Datum: 01.03.2019
*
* Beschreibung: Pop-Up für Änderung Gerätekonfiguration mit Ablehngründen anzeigen.
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    DATA: lr_ctx            TYPE REF TO /idxgc/cl_pd_doc_context,
          lr_badi_exception TYPE REF TO /idxgc/badi_exception,
          lx_previous       TYPE REF TO cx_root,
          lt_selectlist     TYPE TABLE OF spopli,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data,
          lv_answer         TYPE c,
          lv_rejection_code TYPE /idxgc/de_rejection_code.

    FIELD-SYMBOLS: <ls_selectlist> TYPE spopli,
                   <ls_check>      TYPE /idxgc/s_check_details.

    TRY.
        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no     = is_check_list_result-proc_ref
                                                         iv_wmode       = cl_isu_wmode=>co_change
                                                         iv_skip_buffer = abap_true ).
      CATCH /idxgc/cx_process_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    TRY.
        lr_ctx->get_proc_step_data( EXPORTING iv_proc_step_ref  = is_check_list_result-proc_step_ref
                                    IMPORTING es_proc_step_data = ls_proc_step_data ).
      CATCH /idxgc/cx_process_error INTO lx_previous.
        TRY.
            lr_ctx->close( ).
          CATCH /idxgc/cx_process_error INTO lx_previous.
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
        ENDTRY.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    IF line_exists( ls_proc_step_data-check[ check_id = is_check_list_result-check_id ] ).
      ASSIGN ls_proc_step_data-check[ check_id = is_check_list_result-check_id ] TO <ls_check>.
    ENDIF.

    IF <ls_check> IS NOT ASSIGNED.
      MESSAGE e051(/adz/bdr_messages).
    ENDIF.

    IF is_check_list_result-addinfo = /adz/if_bdr_co=>gc_cr_rejected.
* Automatische Ablehnung für Fristüberschreitung, daher hier keine Auswahl
*      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
*      <ls_selectlist>-varoption = 'Z34 - Ablehnung - Fristüberschreitung'.

      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z48 - Ablehnung - Keine / falsche Parameter für TAF-Konfiguration'.

      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z49 - Ablehnung - Kein stabiler Verb.-aufbau zur Konf. des TAF'.

      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z56 - Ablehnung - Änderung zum gewünschten Termin schon umgesetzt'.

      CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
        EXPORTING
          mark_max           = 1
          start_col          = 10
          start_row          = 10
          textline1          = space
          textline2          = 'Bitte den Grund der Ablehnung auswählen:'
          titel              = 'Auswahl Ablehnungsgrund'
        IMPORTING
          answer             = lv_answer
        TABLES
          t_spopli           = lt_selectlist
        EXCEPTIONS
          not_enough_answers = 1
          too_much_answers   = 2
          too_much_marks     = 3
          OTHERS             = 4.

      IF line_exists( lt_selectlist[ selflag = abap_true ] ) AND lv_answer <> 'A'.
        lv_rejection_code = lt_selectlist[ selflag = abap_true ]-varoption(3).
      ELSE.
        MESSAGE e050(/adz/bdr_messages).
      ENDIF.

      <ls_check>-rejection_code   = lv_rejection_code.
      <ls_check>-proc_step_value  = /adz/if_bdr_co=>gc_proc_value-rejected.
      <ls_check>-check_result     = /adz/if_bdr_co=>gc_cr_rejected.
      <ls_check>-excp_solved_flag = abap_true.
    ELSE.
      <ls_check>-rejection_code   = /idxgc/if_constants_ide=>gc_respstatus_z13.
      <ls_check>-proc_step_value  = /adz/if_bdr_co=>gc_proc_value-accepted.
      <ls_check>-check_result     = /adz/if_bdr_co=>gc_cr_accepeted.
      <ls_check>-excp_solved_flag = abap_true.
    ENDIF.

    APPEND INITIAL LINE TO ls_proc_step_data-proc_step_values ASSIGNING FIELD-SYMBOL(<ls_proc_step_value>).
    <ls_proc_step_value>-proc_step_value = <ls_check>-proc_step_value.

    TRY.
        lr_ctx->update_proc_steps( is_proc_step_data = ls_proc_step_data ).
        lr_ctx->close_and_save( iv_no_commit = abap_true ).
        COMMIT WORK AND WAIT.
      CATCH /idxgc/cx_process_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    TRY.
        GET BADI lr_badi_exception
          FILTERS
            iv_proc_cluster = /adz/if_bdr_co=>gc_proc_cluster_adzbdr.

        CALL BADI lr_badi_exception->reprocess_step
          EXPORTING
            iv_process_ref         = is_check_list_result-proc_ref
            iv_process_step_ref    = is_check_list_result-proc_step_ref
            iv_cancel_current_step = abap_false
            iv_copy_step           = abap_false
            iv_compl_current_step  = abap_true.
      CATCH cx_badi_not_implemented cx_badi_multiply_implemented /idxgc/cx_utility_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

  ENDMETHOD.


  METHOD check_chg_settl_solution.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: SCHMIDT-M, THIMEL-R                                                     Datum: 01.03.2019
*
* Beschreibung: Pop-Up für Änderung Bilanzierungsverfahren mit Ablehngründen anzeigen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************

    DATA: lr_ctx            TYPE REF TO /idxgc/cl_pd_doc_context,
          lr_badi_exception TYPE REF TO /idxgc/badi_exception,
          lx_previous       TYPE REF TO cx_root,
          lt_selectlist     TYPE TABLE OF spopli,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data,
          lv_answer         TYPE c,
          lv_rejection_code TYPE /idxgc/de_rejection_code.

    FIELD-SYMBOLS: <ls_selectlist> TYPE spopli,
                   <ls_check>      TYPE /idxgc/s_check_details.

    TRY.
        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no     = is_check_list_result-proc_ref
                                                         iv_wmode       = cl_isu_wmode=>co_change
                                                         iv_skip_buffer = abap_true ).
      CATCH /idxgc/cx_process_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    TRY.
        lr_ctx->get_proc_step_data( EXPORTING iv_proc_step_ref  = is_check_list_result-proc_step_ref
                                    IMPORTING es_proc_step_data = ls_proc_step_data ).
      CATCH /idxgc/cx_process_error INTO lx_previous.
        TRY.
            lr_ctx->close( ).
          CATCH /idxgc/cx_process_error INTO lx_previous.
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
        ENDTRY.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    IF line_exists( ls_proc_step_data-check[ check_id = is_check_list_result-check_id ] ).
      ASSIGN ls_proc_step_data-check[ check_id = is_check_list_result-check_id ] TO <ls_check>.
    ENDIF.

    IF <ls_check> IS NOT ASSIGNED.
      MESSAGE e051(/adz/bdr_messages).
    ENDIF.

    IF is_check_list_result-addinfo = /adz/if_bdr_co=>gc_cr_rejected.
* Automatische Ablehnung für Fristüberschreitung, daher hier keine Auswahl
*      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
*      <ls_selectlist>-varoption = 'Z34 - Ablehnung - Fristüberschreitung'.

      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z46 - Ablehnung - Kein Wahlrecht des Bilanzierungsverfahrens'.

      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z47 - Ablehnung - Nicht alle MeLos der MaLo mit iMS ausgestattet'.

      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z56 - Ablehnung - Änderung zum gewünschten Termin schon umgesetzt'.

      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z57 - Ablehnung - Bilanzierungsproblem'.

      CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
        EXPORTING
          mark_max           = 1
          start_col          = 10
          start_row          = 10
          textline1          = space
          textline2          = 'Bitte den Grund der Ablehnung auswählen:'
          titel              = 'Auswahl Ablehnungsgrund'
        IMPORTING
          answer             = lv_answer
        TABLES
          t_spopli           = lt_selectlist
        EXCEPTIONS
          not_enough_answers = 1
          too_much_answers   = 2
          too_much_marks     = 3
          OTHERS             = 4.

      IF line_exists( lt_selectlist[ selflag = abap_true ] ) AND lv_answer <> 'A'.
        lv_rejection_code = lt_selectlist[ selflag = abap_true ]-varoption(3).
      ELSE.
        MESSAGE e050(/adz/bdr_messages).
      ENDIF.

      <ls_check>-rejection_code   = lv_rejection_code.
      <ls_check>-proc_step_value  = /adz/if_bdr_co=>gc_proc_value-rejected.
      <ls_check>-check_result     = /adz/if_bdr_co=>gc_cr_rejected.
      <ls_check>-excp_solved_flag = abap_true.
    ELSE.
      <ls_check>-rejection_code   = /idxgc/if_constants_ide=>gc_respstatus_z13.
      <ls_check>-proc_step_value  = /adz/if_bdr_co=>gc_proc_value-accepted.
      <ls_check>-check_result     = /adz/if_bdr_co=>gc_cr_accepeted.
      <ls_check>-excp_solved_flag = abap_true.
    ENDIF.

    APPEND INITIAL LINE TO ls_proc_step_data-proc_step_values ASSIGNING FIELD-SYMBOL(<ls_proc_step_value>).
    <ls_proc_step_value>-proc_step_value = <ls_check>-proc_step_value.

    TRY.
        lr_ctx->update_proc_steps( is_proc_step_data = ls_proc_step_data ).
        lr_ctx->close_and_save( iv_no_commit = abap_true ).
        COMMIT WORK AND WAIT.
      CATCH /idxgc/cx_process_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    TRY.
        GET BADI lr_badi_exception
          FILTERS
            iv_proc_cluster = /adz/if_bdr_co=>gc_proc_cluster_adzbdr.

        CALL BADI lr_badi_exception->reprocess_step
          EXPORTING
            iv_process_ref         = is_check_list_result-proc_ref
            iv_process_step_ref    = is_check_list_result-proc_step_ref
            iv_cancel_current_step = abap_false
            iv_copy_step           = abap_false
            iv_compl_current_step  = abap_true.
      CATCH cx_badi_not_implemented cx_badi_multiply_implemented /idxgc/cx_utility_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

  ENDMETHOD.


  METHOD check_recl_value_solution.
***************************************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: SCHMIDT-M, THIMEL-R                                                     Datum: 01.03.2019
*
* Beschreibung: Pop-Up für Änderung Bilanzierungsverfahren mit Ablehngründen anzeigen.
*
***************************************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
***************************************************************************************************
    DATA: lr_ctx            TYPE REF TO /idxgc/cl_pd_doc_context,
          lr_badi_exception TYPE REF TO /idxgc/badi_exception,
          lx_previous       TYPE REF TO cx_root,
          lt_selectlist     TYPE TABLE OF spopli,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data,
          lv_answer         TYPE c,
          lv_rejection_code TYPE /idxgc/de_rejection_code.

    FIELD-SYMBOLS: <ls_selectlist> TYPE spopli,
                   <ls_check>      TYPE /idxgc/s_check_details.

    TRY.
        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no     = is_check_list_result-proc_ref
                                                         iv_wmode       = cl_isu_wmode=>co_change
                                                         iv_skip_buffer = abap_true ).
      CATCH /idxgc/cx_process_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    TRY.
        lr_ctx->get_proc_step_data( EXPORTING iv_proc_step_ref  = is_check_list_result-proc_step_ref
                                    IMPORTING es_proc_step_data = ls_proc_step_data ).
      CATCH /idxgc/cx_process_error INTO lx_previous.
        TRY.
            lr_ctx->close( ).
          CATCH /idxgc/cx_process_error INTO lx_previous.
            /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
        ENDTRY.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    IF line_exists( ls_proc_step_data-check[ check_id = is_check_list_result-check_id ] ).
      ASSIGN ls_proc_step_data-check[ check_id = is_check_list_result-check_id ] TO <ls_check>.
    ENDIF.

    IF <ls_check> IS NOT ASSIGNED.
      MESSAGE e051(/adz/bdr_messages).
    ENDIF.

    IF is_check_list_result-addinfo = /adz/if_bdr_co=>gc_cr_rejected.
      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z54 - Ablehnung - Keine Messwertänderung durchgeführt'.

      APPEND INITIAL LINE TO lt_selectlist ASSIGNING <ls_selectlist>.
      <ls_selectlist>-varoption = 'Z55 - Ablehnung - Prüfung zur Klärung des Sachverhalts veranlasst'.

      CALL FUNCTION 'POPUP_TO_DECIDE_LIST'
        EXPORTING
          mark_max           = 1
          start_col          = 10
          start_row          = 10
          textline1          = space
          textline2          = 'Bitte den Grund der Ablehnung auswählen:'
          titel              = 'Auswahl Ablehnungsgrund'
        IMPORTING
          answer             = lv_answer
        TABLES
          t_spopli           = lt_selectlist
        EXCEPTIONS
          not_enough_answers = 1
          too_much_answers   = 2
          too_much_marks     = 3
          OTHERS             = 4.

      IF line_exists( lt_selectlist[ selflag = abap_true ] ) AND lv_answer <> 'A'.
        lv_rejection_code = lt_selectlist[ selflag = abap_true ]-varoption(3).
      ELSE.
        MESSAGE e050(/adz/bdr_messages).
      ENDIF.

      <ls_check>-rejection_code   = lv_rejection_code.
      <ls_check>-proc_step_value  = /adz/if_bdr_co=>gc_proc_value-rejected.
      <ls_check>-check_result     = /adz/if_bdr_co=>gc_cr_rejected.
      <ls_check>-excp_solved_flag = abap_true.
    ELSE.
      <ls_check>-proc_step_value  = /adz/if_bdr_co=>gc_proc_value-accepted.
      <ls_check>-check_result     = /adz/if_bdr_co=>gc_cr_accepeted.
      <ls_check>-excp_solved_flag = abap_true.
    ENDIF.

    APPEND INITIAL LINE TO ls_proc_step_data-proc_step_values ASSIGNING FIELD-SYMBOL(<ls_proc_step_value>).
    <ls_proc_step_value>-proc_step_value = <ls_check>-proc_step_value.

    TRY.
        lr_ctx->update_proc_steps( is_proc_step_data = ls_proc_step_data ).
        lr_ctx->close_and_save( iv_no_commit = abap_true ).
        COMMIT WORK AND WAIT.
      CATCH /idxgc/cx_process_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    TRY.
        GET BADI lr_badi_exception
          FILTERS
            iv_proc_cluster = /adz/if_bdr_co=>gc_proc_cluster_adzbdr.

        CALL BADI lr_badi_exception->reprocess_step
          EXPORTING
            iv_process_ref         = is_check_list_result-proc_ref
            iv_process_step_ref    = is_check_list_result-proc_step_ref
            iv_cancel_current_step = abap_false
            iv_copy_step           = abap_false
            iv_compl_current_step  = abap_true.
      CATCH cx_badi_not_implemented cx_badi_multiply_implemented /idxgc/cx_utility_error INTO lx_previous.
        /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
