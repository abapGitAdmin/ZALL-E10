class /ADESSO/CL_IM_BPM_EMMA_CASE definition
  public
  create public .

public section.

  interfaces IF_EX_EMMA_CASE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_IM_BPM_EMMA_CASE IMPLEMENTATION.


  method IF_EX_EMMA_CASE~CHECK_AFTER_PROCESS_EXEC_LIST.
  endmethod.


  method IF_EX_EMMA_CASE~CHECK_BEFORE_CHANGE.
  endmethod.


  method IF_EX_EMMA_CASE~CHECK_BEFORE_DISPLAY.
  endmethod.


  method IF_EX_EMMA_CASE~CHECK_BEFORE_PROCESS_EXECUTION.
  endmethod.


  method IF_EX_EMMA_CASE~CHECK_BEFORE_SAVE.
  endmethod.


  method IF_EX_EMMA_CASE~CHECK_IDENTICAL_CASE.
  endmethod.


  METHOD if_ex_emma_case~complete_case.

    DATA: lv_bparea              TYPE emma_bparea,
          lr_bpm_badi_compl_case TYPE REF TO /adesso/bpm_badi_compl_case,
          lv_custfields	         TYPE emma_cci,
          lt_objects             TYPE emma_cobj_t.


    TRY.
        lv_bparea = /adesso/cl_bpm_utility=>det_bparea( iv_ccat = is_case-ccat ).

        TRY.
            GET BADI lr_bpm_badi_compl_case
              FILTERS
                business_process_area = lv_bparea.

            CALL METHOD lr_bpm_badi_compl_case->imp->complete_case
              EXPORTING
                iv_ccat       = is_case-ccat
                is_case       = is_case
                it_objects    = ct_objects
              IMPORTING
                ev_custfields = lv_custfields
                et_objects    = lt_objects.

            APPEND LINES OF lt_objects TO ct_objects.
            SORT ct_objects ASCENDING.
            DELETE ADJACENT DUPLICATES FROM ct_objects.

            ev_custfields = lv_custfields.

          CATCH cx_badi_not_implemented /adesso/cx_bpm_general /adesso/cx_bpm_utility.
            CLEAR lt_objects.
        ENDTRY.

      CATCH /adesso/cx_bpm_utility .
        RAISE no_case.
    ENDTRY.
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
ENDCLASS.
