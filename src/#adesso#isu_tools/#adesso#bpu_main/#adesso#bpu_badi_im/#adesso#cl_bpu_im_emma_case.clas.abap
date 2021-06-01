class /ADESSO/CL_BPU_IM_EMMA_CASE definition
  public
  create public .

public section.

  interfaces IF_EX_EMMA_CASE .
protected section.

  methods SET_CUSTFIELDS
    importing
      !IV_CASENR type EMMA_CNR
    returning
      value(RS_CUSTFIELDS) type EMMA_CCI
    raising
      /IDXGC/CX_GENERAL .
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPU_IM_EMMA_CASE IMPLEMENTATION.


  method IF_EX_EMMA_CASE~CHECK_AFTER_PROCESS_EXEC_LIST.
  endmethod.


  METHOD if_ex_emma_case~check_before_change.
    DATA: ls_cust_gen     TYPE /adesso/bpu_s_gen,
          lv_start_screen TYPE /adesso/bpu_start_screen.

***** Startbild setzen ****************************************************************************
    GET PARAMETER ID /adesso/if_bpu_co=>gc_param_id_emma_start_screen FIELD lv_start_screen.
    IF lv_start_screen IS INITIAL.
      TRY.
          ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).
        CATCH /idxgc/cx_general.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDTRY.
      SET PARAMETER ID /adesso/if_bpu_co=>gc_param_id_emma_start_screen FIELD ls_cust_gen-start_screen.
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_emma_case~check_before_display.
    DATA: ls_cust_gen     TYPE /adesso/bpu_s_gen,
          lv_start_screen TYPE /adesso/bpu_start_screen.

***** Startbild setzen ****************************************************************************
    GET PARAMETER ID /adesso/if_bpu_co=>gc_param_id_emma_start_screen FIELD lv_start_screen.
    IF lv_start_screen IS INITIAL.
      TRY.
          ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).
        CATCH /idxgc/cx_general.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDTRY.
      SET PARAMETER ID /adesso/if_bpu_co=>gc_param_id_emma_start_screen FIELD ls_cust_gen-start_screen.
    ENDIF.
  ENDMETHOD.


  method IF_EX_EMMA_CASE~CHECK_BEFORE_PROCESS_EXECUTION.
  endmethod.


  method IF_EX_EMMA_CASE~CHECK_BEFORE_SAVE.
  endmethod.


  method IF_EX_EMMA_CASE~CHECK_IDENTICAL_CASE.
  endmethod.


  METHOD if_ex_emma_case~complete_case.
    DATA: lr_bpu_data_provision TYPE REF TO /adesso/cl_bpu_data_provision,
          lr_bpu_emma_case      TYPE REF TO /adesso/cl_bpu_emma_case,
          ls_cust_gen           TYPE /adesso/bpu_s_gen.


    IF is_case-mainobjtype = /idxgc/if_constants=>gc_object_pdoc_bor. "Nur für Klärfälle zu Prozessdokumenten

      TRY.
          lr_bpu_emma_case = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = is_case-casenr ).
          lr_bpu_emma_case->set_case( is_case = is_case ).
        CATCH /idxgc/cx_general.
          RETURN. "Ohne Änderungen weiter.
      ENDTRY.


***** Individuelle Objekte am Klärungsfall erzeugen ***********************************************
      TRY.
          ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).
          CREATE OBJECT lr_bpu_data_provision TYPE (ls_cust_gen-data_prov_class) EXPORTING iv_casenr = is_case-casenr.
          ct_objects = lr_bpu_data_provision->get_case_objects( it_actual_objects = it_objects ).
        CATCH /idxgc/cx_general.
          "Ohne individuelle Objekte weiter
      ENDTRY.


***** Fälligkeitsdatum übersteuern ****************************************************************
      TRY.
          /adesso/cl_bpu_utility=>det_due_date_time( EXPORTING iv_casenr          = is_case-casenr
                                                               iv_actual_due_date = is_case-due_date
                                                               iv_actual_due_time = is_case-due_time
                                                     IMPORTING ev_due_date        = ev_duedate
                                                               ev_due_time        = ev_duetime ).
        CATCH /idxgc/cx_general.
          "Ohne neues Fälligkeitsdatum weiter
      ENDTRY.


***** Priorität übersteuern ***********************************************************************
      TRY.
          ev_prio = /adesso/cl_bpu_utility=>det_prio( iv_casenr = is_case-casenr iv_actual_prio = is_case-prio ).
        CATCH /idxgc/cx_general.
          "Ohne neue Priorität weiter
      ENDTRY.


***** Felder im CI-Include füllen *****************************************************************
      TRY.
          ev_custfields = set_custfields( iv_casenr = is_case-casenr ).
        CATCH /idxgc/cx_process_error /idxgc/cx_general.
          "Ohne zusätzliche Felder im CI-Include weiter
      ENDTRY.

    ENDIF.

  ENDMETHOD.


  method IF_EX_EMMA_CASE~DETERMINE_CASE.
  endmethod.


  method IF_EX_EMMA_CASE~DETERMINE_CUSTOMER_SUBSCREEN.
  endmethod.


  method IF_EX_EMMA_CASE~PREPARE_PROCESS_EXECUTION.
  endmethod.


  method IF_EX_EMMA_CASE~PROCESS_CUSTSUB_OKCODE.
  endmethod.


  method IF_EX_EMMA_CASE~TRANSFER_DATA_FROM_CUSTSUB.
  endmethod.


  method IF_EX_EMMA_CASE~TRANSFER_DATA_TO_CUSTSUB.
  endmethod.


  method IF_EX_EMMA_CASE~UPDATE_CASE_ACTION_LOG.
  endmethod.


  METHOD set_custfields.
    DATA: lr_bpu_emma_case  TYPE REF TO /adesso/cl_bpu_emma_case,
          lr_ctx            TYPE REF TO /idxgc/cl_pd_doc_context,
          lt_proc_step_data TYPE /idxgc/t_proc_step_data,
          ls_proc_step_data TYPE /idxgc/s_proc_step_data_all.

    FIELD-SYMBOLS: <fv_custfield> TYPE any.

    lr_bpu_emma_case = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    ls_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).

    ASSIGN COMPONENT 'ZZ_EXT_UI' OF STRUCTURE rs_custfields TO <fv_custfield>.
    IF <fv_custfield> IS ASSIGNED.
      <fv_custfield> = ls_proc_step_data-ext_ui.
    ENDIF.

    ASSIGN COMPONENT 'ZZ_BU_PARTNER' OF STRUCTURE rs_custfields TO <fv_custfield>.
    IF <fv_custfield> IS ASSIGNED.
      <fv_custfield> = ls_proc_step_data-bu_partner.
    ENDIF.

    ASSIGN COMPONENT 'ZZ_PROC_ID' OF STRUCTURE rs_custfields TO <fv_custfield>.
    IF <fv_custfield> IS ASSIGNED.
      <fv_custfield> = ls_proc_step_data-proc_id.
    ENDIF.

    ASSIGN COMPONENT 'ZZ_PROC_STEP_NO' OF STRUCTURE rs_custfields TO <fv_custfield>.
    IF <fv_custfield> IS ASSIGNED.
      <fv_custfield> = ls_proc_step_data-proc_step_no.
    ENDIF.

    ASSIGN COMPONENT 'ZZ_MSGTRANSREASON' OF STRUCTURE rs_custfields TO <fv_custfield>.
    IF <fv_custfield> IS ASSIGNED.
      IF lines( ls_proc_step_data-diverse ) = 1.
        <fv_custfield> = ls_proc_step_data-diverse[ 1 ]-msgtransreason.
      ELSE.
        TRY.
            lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = ls_proc_step_data-proc_ref ).
            lr_ctx->get_proc_step_data( IMPORTING et_proc_step_data = lt_proc_step_data ).
            lr_ctx->close( ).
          CATCH /idxgc/cx_process_error.
            IF lr_ctx IS BOUND.
              lr_ctx->close( ).
            ENDIF.
        ENDTRY.
        LOOP AT lt_proc_step_data ASSIGNING FIELD-SYMBOL(<fs_proc_step_data>) WHERE diverse IS NOT INITIAL.
          IF <fs_proc_step_data>-diverse[ 1 ]-msgtransreason IS NOT INITIAL.
            <fv_custfield> = <fs_proc_step_data>-diverse[ 1 ]-msgtransreason.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
