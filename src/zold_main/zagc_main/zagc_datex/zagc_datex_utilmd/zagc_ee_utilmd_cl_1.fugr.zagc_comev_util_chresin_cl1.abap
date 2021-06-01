*This function module was copied from /IDEXGE/COMEV_UTIL41_CHGRES_IN

*Changes are backuped with old code commented
FUNCTION ZAGC_COMEV_UTIL_CHRESIN_CL1.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(INPUT_METHOD) LIKE  BDWFAP_PAR-INPUTMETHD
*"     REFERENCE(MASS_PROCESSING) LIKE  BDWFAP_PAR-MASS_PROC
*"  EXPORTING
*"     REFERENCE(WORKFLOW_RESULT) TYPE  BDWFAP_PAR-RESULT
*"     REFERENCE(APPLICATION_VARIABLE) TYPE  BDWFAP_PAR-APPL_VAR
*"     REFERENCE(IN_UPDATE_TASK) TYPE  BDWFAP_PAR-UPDATETASK
*"     REFERENCE(CALL_TRANSACTION_DONE) TYPE  BDWFAP_PAR-CALLTRANS
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      WRONG_FUNCTION_CALLED
*"--------------------------------------------------------------------

  DATA :
     l_dexbasicproc       TYPE e_dexbasicproc,
     lw_sender            TYPE eservprovtype,
     lw_receiver          TYPE eservprovtype,
     l_category           TYPE char3,
     l_request            TYPE kennzx,
     l_response           TYPE kennzx,
     l_task_data          TYPE edextask_data_intf,
     lt_parameter         TYPE idexprocparval,
     lw_parameter         TYPE edexprocparval,
     lv_count_pod         TYPE i,
     l_msgv1              TYPE symsgv,
     lt_idoc_status       TYPE t_idoc_status,
     lv_ext_ui             TYPE ext_ui,
     l_keydate            TYPE e_edmdatefrom,
     l_comevent           TYPE comevent,
     lt_interface_data    TYPE abap_parmbind_tab,
     l_interface_data     TYPE LINE OF abap_parmbind_tab,
     lt_xyt_parameter     TYPE iide_parameter,
     l_xyt_parameter      TYPE eide_parameter,
     l_euitrans           TYPE euitrans,
     lv_status            TYPE e_dexstatus.
  DATA:
*    A flag that indicates whether there is "Answer Status" STS segment
*    (CATEGORY = 'E01') in the incoming UTILMD response.
     lv_has_answer_sts    TYPE flag.

*<<< IDEX-GE (Note 1293599)
* Overwrite idoc data for Response of Change Notification
  READ TABLE idoc_contrl INDEX 1.                          "#EC .., bzw

  TRY.
      IF gref_exit_utilmd_in IS INITIAL.
        GET BADI gref_exit_utilmd_in.
      ENDIF.
      CALL BADI gref_exit_utilmd_in->overwrite_idoc_data_resp
        EXPORTING
          is_idoc_control = idoc_contrl
        CHANGING
          ct_idoc_data    = idoc_data[].
    CATCH cx_badi_not_implemented.                      "#EC NO_HANDLER
  ENDTRY.
*>>> IDEX-GE (End)

*$*$ initialization
  PERFORM init.


  PERFORM idoc_open TABLES idoc_contrl
                           idoc_data
                    USING  idoc_contrl-idoctp                    "idoc_type
                           '/IDXGC/UTILMD'                       "message type
                           '/IDEXGE/COMEV_UTIL_CHRES_IN_CL'.     "func module
*******************************************************************************

  DO.
    exit_err. "check if error occurred
    PERFORM get_unh_1.
    exit_err.
*
    PERFORM get_segments_bgm_1.
    exit_err.

*    PERFORM get_bgm_1.
*    exit_err.

    READ TABLE gt_sgm_bgm_2 INTO g_sgm_bgm_2 INDEX 1.
    PERFORM get_bgm_1.

* check if category is supported - only E03
    IF g_bgm_2-document_name_code NE cl_isu_datex_co=>co_vdew_changedoc.

      PERFORM invalid_value USING g_sgm_bgm_2 'DOCUMENT_NAME_CODE' g_bgm_2-document_name_code.
    ENDIF.
*   get sender and receiver from NAD segment
    PERFORM get_sender_nad_7 CHANGING lw_sender.
    PERFORM get_receiver_nad_7 CHANGING lw_receiver.

*   check if message contains requests or responds (has to
*   be the same for all PODs) -- segment STS contains information
*   about status of response (for responds) or transaction code
*   (for requests)
    PERFORM get_segments_ide_2.
    exit_err.
    LOOP AT gt_sgm_ide_2 INTO g_sgm_ide_2.
      PERFORM get_ide_2.
      IF NOT g_ide_2-object_identifier IS INITIAL.
        lv_count_pod = lv_count_pod + 1.
      ENDIF.
      exit_err.

* for change document processing, determine external PoD and keydate from the message
      IF g_bgm_2-document_name_code = cl_isu_datex_co=>co_vdew_changedoc.
*     get external POD
        PERFORM get_segments_loc_4 USING g_sgm_ide_2-segnum.
        LOOP AT gt_sgm_loc_4 INTO g_sgm_loc_4.
          PERFORM get_loc_4.
          IF g_loc_4-location_func_code_quali = cl_isu_datex_co=>co_loc_vdew_pod.
            lv_ext_ui = g_loc_4-location_identifier.
          ENDIF.
          exit_err.
        ENDLOOP.
        exit_err.

        PERFORM get_segments_dtm_3 USING g_sgm_ide_2-segnum.
        exit_err.
        LOOP AT gt_sgm_dtm_3 INTO g_sgm_dtm_3.
          PERFORM get_dtm_3.
          CASE g_dtm_3-date_time_period_fc_qualifier.
            WHEN cl_isu_datex_co=>co_dtm_vdew_start OR
****************************Changes to version 4.1 ****************************
                 cl_isu_datex_co=>co_dtm_vdew_end OR
                 co_dtm_settl_begin OR
                 co_dtm_settl_end OR
*******************************************************************************
                 cl_isu_datex_co=>co_dtm_vdew_valid.
              l_keydate = g_dtm_3-date_time_period_value.
              CALL FUNCTION 'ISU_DATE_FORMAT_CHECK'
                EXPORTING
                  x_date          = l_keydate
                EXCEPTIONS
                  wrong_format    = 1
                  date_is_initial = 2
                  system_error    = 3
                  OTHERS          = 4.
              IF sy-subrc <> 0.
                PERFORM invalid_value USING g_sgm_dtm_3 'DATE_TIME_PERIOD_VALUE' g_dtm_3-date_time_period_value.
              ENDIF.
*            WHEN cl_isu_datex_co=>co_dtm_vdew_end.
            WHEN co_dtm_mr_period OR co_dtm_mrperiod_date.
*             do nothing here
            WHEN OTHERS.
              PERFORM invalid_value USING g_sgm_dtm_3 'DATE_TIME_PERIOD_FC_QUALIFIER' g_dtm_3-date_time_period_fc_qualifier.
          ENDCASE.
          exit_err.
        ENDLOOP.
        exit_err.
      ENDIF. " additional data for change documents

      PERFORM get_segments_sts_3 USING g_sgm_ide_2-segnum.
      LOOP AT gt_sgm_sts_3 INTO g_sgm_sts_3.
        PERFORM get_sts_3.
        IF g_bgm_2-document_name_code = cl_isu_datex_co=>co_vdew_changedoc AND
           g_sts_3-status_category_code_1 = cl_isu_datex_co=>co_sts_vdew_response.

          lv_has_answer_sts = co_true.

          CASE  g_sts_3-status_reason_descr_code_1.
            WHEN /idexge/datex_proc_chng_res=>co_res_ok.
              lv_status = space.
            WHEN /idexge/datex_proc_chng_res=>co_res_error OR
               /idexge/datex_proc_chng_res=>co_res_deadline_exceed OR
               /idexge/datex_proc_chng_res=>co_res_measurement OR
               /idexge/datex_proc_chng_res=>co_res_settlement OR
               /idexge/datex_proc_chng_res=>co_res_no_authorization OR
               /idexge/datex_proc_chng_res=>co_res_date_missing OR
               /idexge/datex_proc_chng_res=>co_res_tranreason_implausible.
              lv_status = 'X'.
            WHEN OTHERS.
*<<< IDEX-GE (Note 1293599): Check invalid answer status in STS segment
              PERFORM invalid_value
                  USING g_sgm_sts_3
                        'STATUS_REASON_DESCR_CODE_1'
                        g_sts_3-status_reason_descr_code_1.
*>>> IDEX-GE (End)
          ENDCASE.
        ENDIF.
        exit_err.
      ENDLOOP.

*     no STS-segemnt
*      IF sy-subrc <> 0.
*        l_request = 'X'.
*      ENDIF.
      exit_err.
    ENDLOOP.
    EXIT.
  ENDDO.
  DO.   " exit mechanism for error handling!
*   fill required task data
    l_task_data-dexservprov     = lw_sender-serviceid.
    l_task_data-dexservprovself = lw_receiver-serviceid.
* Change document processing
    IF g_bgm_2-document_name_code = cl_isu_datex_co=>co_vdew_changedoc.
*   fill parameter of the basic process
      lw_parameter-dexprocparno  = '01'.
      lw_parameter-dexprocparval = lv_status.
      APPEND lw_parameter TO lt_parameter.

      IF g_bgm_2-document_name_code = cl_isu_datex_co=>co_vdew_changedoc AND
         lv_has_answer_sts = co_true.

        l_dexbasicproc = /idexge/datex_proc_chng_res=>co_dexbasicproc_imp_res_chg.
      ELSE.
        IF 1 = 2. MESSAGE e068(edatex) WITH space. ENDIF. "EC *
        PERFORM add_err_status_appl USING '068' 'EDATEX' space space space space.
      ENDIF.

* Aggregated IDOCs are not supported for basic process REQ_CHANGE...
      IF lv_count_pod > 1.
        l_msgv1 = l_dexbasicproc.
        IF 1 = 2. MESSAGE e857(edatex) WITH l_msgv1. ENDIF. "EC *
        PERFORM add_err_status_appl USING '857' 'EDATEX' l_msgv1 space space space.
      ENDIF.

* provide stAtus COMPR-module

      l_interface_data-name = 'X_STATUS'.
      l_interface_data-kind = abap_func_exporting.
      GET REFERENCE OF lv_status INTO l_interface_data-value.
      INSERT l_interface_data INTO TABLE lt_interface_data.

* Provide EXT_UI
      l_interface_data-name = 'X_EXT_UI'.
      l_interface_data-kind = abap_func_exporting.
      GET REFERENCE OF lv_ext_ui INTO l_interface_data-value.
      INSERT l_interface_data INTO TABLE lt_interface_data.


      IF NOT lv_ext_ui IS INITIAL.
        IF l_keydate = '00010101'.
          l_keydate = sy-datum.
        ENDIF.
        CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
          EXPORTING
            x_ext_ui     = lv_ext_ui
            x_keydate    = l_keydate
          IMPORTING
            y_euitrans   = l_euitrans
          EXCEPTIONS
            not_found    = 1
            system_error = 2
            OTHERS       = 3.

        IF sy-subrc = 0.
          l_task_data-int_ui = l_euitrans-int_ui.
        ENDIF.
      ENDIF.
      l_task_data-dexrefdatefrom = l_keydate.
      l_task_data-dexrefdateto   = l_keydate.

    ENDIF.
    exit_err.

*   process idoc --> datex controller
    PERFORM process_res USING l_dexbasicproc
                              l_task_data
                              lt_parameter
                              lt_interface_data.
    EXIT.
  ENDDO.
* check IDOC for aggregated pod's
  IF lv_count_pod > 1.

* check for IDOC status 51
    lt_idoc_status = gr_proc->get_status( ).

    READ TABLE lt_idoc_status TRANSPORTING NO FIELDS WITH KEY status = co_stat_appl_err.

    IF sy-subrc = 0.

* set last message type 'S' to log
      CALL METHOD gr_proc->add_status_appl
        EXPORTING
          im_msgty = 'S'
          im_msgno = 453
          im_msgid = 'EIDESWD'
          im_msgv1 = space
          im_msgv2 = space
          im_msgv3 = space
          im_msgv4 = space.
      IF 1 = 2. MESSAGE s453(eideswd). ENDIF. "EC *
    ENDIF.
  ENDIF.

*$*$  close processing

  PERFORM idoc_close TABLES   idoc_status
                              return_variables
                     CHANGING in_update_task
                              call_transaction_done
                              workflow_result
                              application_variable.


ENDFUNCTION.
