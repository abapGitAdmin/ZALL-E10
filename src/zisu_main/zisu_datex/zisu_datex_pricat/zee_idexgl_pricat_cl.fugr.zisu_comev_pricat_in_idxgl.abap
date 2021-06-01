FUNCTION ZISU_COMEV_PRICAT_IN_IDXGL .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT_METHOD) TYPE  INPUTMETHD
*"     REFERENCE(MASS_PROCESSING) TYPE  MASS_PROC
*"  EXPORTING
*"     REFERENCE(WORKFLOW_RESULT) TYPE  WF_RESULT
*"     REFERENCE(APPLICATION_VARIABLE) TYPE  APPL_VAR
*"     REFERENCE(IN_UPDATE_TASK) TYPE  UPDATETASK
*"     REFERENCE(CALL_TRANSACTION_DONE) TYPE  CALLTRANS2
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      ERROR_OCCURRED
*"--------------------------------------------------------------------
  DATA:
     ls_idoc_contrl    TYPE edidc,
     ls_status1        TYPE bdidocstat,
     ls_task_data      TYPE edextask_data_intf.

* The event function module could only process one IDoc at a time
  PERFORM handle_idoc_control USING    idoc_contrl[]
                              CHANGING ls_idoc_contrl.


* Call BAdI Method
  TRY.
      IF gref_badi_isu_pricat_in IS INITIAL.
        GET BADI gref_badi_isu_pricat_in.
      ENDIF.
      CALL BADI gref_badi_isu_pricat_in->overwrite_idoc_data
        EXPORTING
          is_idoc_control = ls_idoc_contrl
        CHANGING
          ct_idoc_data    = idoc_data[]
        EXCEPTIONS
          error_occurred  = 1
          OTHERS          = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING error_occurred.
      ENDIF.
    CATCH cx_badi_not_implemented.
  ENDTRY.

* Check Realease information
  PERFORM check_release USING    ls_idoc_contrl
                                 idoc_data[]
                        CHANGING gs_unh
                                 gs_status.

* Prepare data for import of PRICAT
  PERFORM prepare_inbound_data USING    ls_idoc_contrl
                                        idoc_data[]
                               CHANGING gs_status
                                        ls_task_data.

* Start processing of datex PRICAT import
  PERFORM start_imppricat
        USING    ls_task_data
                 ls_idoc_contrl
                 idoc_data[]
        CHANGING gs_status.

  CLEAR:
   idoc_status,
   idoc_status[].

  IF gs_status-status = co_stat_formal_err.
* Formal error
    gs_status-status = co_stat_appl_err.
    PERFORM add_status USING    ls_idoc_contrl-docnum
                                gc_funcname
                       CHANGING gs_status
                                idoc_status[].
  ELSE.
* No formal error
    ls_status1-status = co_stat_formal_ok.
    PERFORM add_status USING    ls_idoc_contrl-docnum
                                gc_funcname
                       CHANGING ls_status1
                                idoc_status[].
    IF gs_status-status = co_stat_appl_err OR
       gs_status-status = co_stat_appl_part.
*     processing (partly) failed
      PERFORM add_status USING    ls_idoc_contrl-docnum
                                  gc_funcname
                         CHANGING gs_status
                                  idoc_status[].
    ELSE.
*     processing finished
      ls_status1-status = co_stat_appl_ok.
      PERFORM add_status USING    ls_idoc_contrl-docnum
                                  gc_funcname
                         CHANGING ls_status1
                                  idoc_status[].
    ENDIF.
  ENDIF.

* set internal table return_variables
  IF ls_status1-status = co_stat_appl_ok.
    workflow_result = '0'.
    return_variables-wf_param   = 'Processed_IDOCs'.
    return_variables-doc_number =  idoc_contrl-docnum.
    APPEND return_variables.
  ELSE.
    workflow_result = '99999'.
    return_variables-wf_param   = 'Error_IDOCs'.
    return_variables-doc_number =  idoc_contrl-docnum.
    APPEND return_variables.
  ENDIF.

* save log
  ecclog_save.
ENDFUNCTION.
