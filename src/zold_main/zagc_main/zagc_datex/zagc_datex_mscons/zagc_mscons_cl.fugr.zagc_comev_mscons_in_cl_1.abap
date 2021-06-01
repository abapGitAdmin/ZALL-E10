FUNCTION zagc_comev_mscons_in_cl_1.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT_METHOD) TYPE  INPUTMETHD
*"     REFERENCE(MASS_PROCESSING) TYPE  MASS_PROC
*"  EXPORTING
*"     VALUE(WORKFLOW_RESULT) TYPE  WF_RESULT
*"     VALUE(APPLICATION_VARIABLE) TYPE  APPL_VAR
*"     VALUE(IN_UPDATE_TASK) TYPE  UPDATETASK
*"     VALUE(CALL_TRANSACTION_DONE) TYPE  CALLTRANS2
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      WRONG_FUNCTION_CALLED
*"----------------------------------------------------------------------

* Get UNB segment
  READ TABLE idoc_data WITH KEY segnam = /idxgc/if_constants_ide=>gc_segmtp_unb_01.
  IF sy-subrc <> 0.
*   illegal IDoc
    status-status = co_stat_formal_err.
    status-segnum = /idxgc/if_constants_ide=>gc_segmtp_unb_01.
    status_error status a 112 eccedi
                 /idxgc/if_constants_ide=>gc_segmtp_unb_01
                  space space space.
    IF 1 = 2. MESSAGE a112(eccedi). ENDIF.                  "#EC *
    log_add_from_status.                                    "#EC *
    PERFORM add_status TABLES idoc_status
                       USING  idoc_contrl-docnum
                              /idxgc/if_constants_ide=>gc_de_fm_mscons_1
                              status.
    EXIT.
  ELSE.
    gs_unb_01 = idoc_data-sdata.
  ENDIF.

  IF gs_unb_01-application_reference = co_util_ref_tl OR " TL
    gs_unb_01-application_reference = co_util_ref_lg. " LG
    CALL FUNCTION '/IDEXGE/COMEV_MSCONS_INT_CL_1'
      EXPORTING
        input_method          = input_method
        mass_processing       = mass_processing
      IMPORTING
        workflow_result       = workflow_result
        application_variable  = application_variable
        in_update_task        = in_update_task
        call_transaction_done = call_transaction_done
      TABLES
        idoc_contrl           = idoc_contrl
        idoc_data             = idoc_data
        idoc_status           = idoc_status
        return_variables      = return_variables
        serialization_info    = serialization_info
      EXCEPTIONS
        wrong_function_called = 1
        OTHERS                = 2.
  ELSE.

*    Mapping einbauen und dann Z-COMEV in der neuen Version aufrufen
* >>>> somberg.j beginn 14.07.2015
    CALL METHOD zcl_agc_datex_utility=>map_mscons_idoc_idxgc_to_old
      EXPORTING
        it_idoc_data = idoc_data[]
      RECEIVING
        rt_idoc_data = idoc_data[].

    CALL FUNCTION 'ZIDEXGG_COMEV_MCO22F_ACT_U'
      EXPORTING
        input_method          = input_method
        mass_processing       = mass_processing
      IMPORTING
        workflow_result       = workflow_result
        application_variable  = application_variable
        in_update_task        = in_update_task
        call_transaction_done = call_transaction_done
      TABLES
        idoc_contrl           = idoc_contrl
        idoc_data             = idoc_data
        idoc_status           = idoc_status
        return_variables      = return_variables
        serialization_info    = serialization_info
      EXCEPTIONS
        wrong_function_called = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

* <<<< somberg.j ende 14.07.2015


*    CALL FUNCTION '/IDEXGE/COMEV_MSCONS_ACT_CL_1'
*      EXPORTING
*        input_method          = input_method
*        mass_processing       = mass_processing
*      IMPORTING
*        workflow_result       = workflow_result
*        application_variable  = application_variable
*        in_update_task        = in_update_task
*        call_transaction_done = call_transaction_done
*      TABLES
*        idoc_contrl           = idoc_contrl
*        idoc_data             = idoc_data
*        idoc_status           = idoc_status
*        return_variables      = return_variables
*        serialization_info    = serialization_info
*      EXCEPTIONS
*        wrong_function_called = 1
*        OTHERS                = 2.
  ENDIF.

  IF sy-subrc = 1.
*   This error should never occur when function module is called
*   by a SAP - program
    MESSAGE a000(ej) RAISING wrong_function_called.
  ENDIF.
ENDFUNCTION.
