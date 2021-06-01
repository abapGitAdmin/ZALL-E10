class ZCL_AGC_DEF_BADI_MSG_PROC_WF definition
  public
  inheriting from /IDXGC/CL_DEF_BADI_MSG_PROC_WF
  create public .

public section.

  methods /IDXGC/IF_BADI_MSG_PROCESSING~HANDLE_MESSAGE_WITH_REFERENCE
    redefinition .
  methods /IDXGC/IF_BADI_MSG_PROCESSING~HANDLE_NONUNIQUE_PROCESS
    redefinition .
protected section.

  methods HANDLE_NONUNIQUE_PROCESS_DCR
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_AGC_DEF_BADI_MSG_PROC_WF IMPLEMENTATION.


  METHOD /idxgc/if_badi_msg_processing~handle_message_with_reference.
***************************************************************************************************
* THIMEL.R, 20151001, Kopie aus dem Standard mit Korrektur zu Status für Storno
*   Änderungen sind mit +++++ markiert. Vorarbeit durch Somberg.J.
***************************************************************************************************
    DATA:
      lr_process              TYPE REF TO /idxgc/if_process,
      lr_process_data         TYPE REF TO /idxgc/if_process_data_pdoc,
      ls_proc_data_back       TYPE        /idxgc/s_proc_data,
      ls_proc_data            TYPE        /idxgc/s_proc_data,
      ls_proc_step_data       TYPE        /idxgc/s_proc_step_data,
      ls_process_config       TYPE        /idxgc/s_proc_config_all,
      ls_message_step_key     TYPE        /idxgc/s_proc_step_key,
      ls_validate_result      TYPE        /idxgc/s_validate_result,
      lv_found_proc_id        TYPE        /idxgc/de_boolean_flag,
      lr_previous             TYPE REF TO /idxgc/cx_general,
      lt_proc_stat_not_active TYPE        /idxgc/t_proc_stat_config,
      lv_step_not_relevant    TYPE        flag,
      lv_pdoc_not_active      TYPE        /idxgc/de_boolean_flag.

    FIELD-SYMBOLS:
      <lfs_msg_field_value>  TYPE any,
      <lfs_proc_field_value> TYPE any,
      <lfs_step_config>      TYPE /idxgc/s_proc_step_config_all.


*--------------------------------------------------------------------*
    IF ( is_message_step_data-proc_ref IS INITIAL ). "no data provided.
      CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_source_pos
        IMPORTING
          ev_class_name  = gv_class_name
          ev_method_name = gv_method_name.

      MESSAGE e001(/idxgc/process) INTO gv_mtext WITH gv_class_name gv_method_name.
      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
    ENDIF.


*1. get process data from given PROC_REF, and retrieve process configuration
* to determine if potential step is executable for inbound message

**1.1  Instantiate this process with given PROC_REF
    TRY.
        CALL METHOD /idxgc/cl_process=>/idxgc/if_process~get_instance
          EXPORTING
            iv_process_ref = is_message_step_data-proc_ref
            iv_edit_mode   = cl_isu_wmode=>co_display
          RECEIVING
            rr_process     = lr_process.

      CATCH /idxgc/cx_process_error INTO lr_previous.
        MESSAGE e011(/idxgc/ide) INTO gv_mtext.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
          EXPORTING
            ir_previous = lr_previous.
    ENDTRY.

*--------------------------------------------------------------------*
* If got multiple step data after IDoc mapping, will call multiple this method
* If non first time calling, get process data from CT_PROCESS_DATA_VALID.
* Because this parameter includes all mapped step data
    lr_process_data ?= lr_process->get_process_data( ).

    IF ct_process_data_valid IS INITIAL.
      CALL METHOD lr_process_data->get_process_data(
        IMPORTING
          es_process_data = ls_proc_data_back ).
    ELSE.
      READ TABLE ct_process_data_valid INTO ls_proc_data_back INDEX 1.
    ENDIF.

*   Check Pdoc status
    TRY.
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_all_process_status
          EXPORTING
            iv_status_active       = /idxgc/if_constants=>gc_false
            iv_status_complete     = /idxgc/if_constants=>gc_true
            iv_status_not_relevant = /idxgc/if_constants=>gc_true
          IMPORTING
            et_process_status      = lt_proc_stat_not_active.
      CATCH /idxgc/cx_config_error.
    ENDTRY.

    READ TABLE lt_proc_stat_not_active WITH KEY status = ls_proc_data_back-status TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      lv_pdoc_not_active = /idxgc/if_constants=>gc_true.
    ENDIF.

    ls_proc_step_data-step2    = is_message_step_data-step.
    ls_proc_step_data-proc_ref = ls_proc_data_back-proc_ref.

*--------------------------------------------------------------------*
* Determine potential step number(s) of current inbound message from DATEX process
    CLEAR:
      ct_process_data_valid,
      ct_process_data_with_reserve.

    CALL METHOD lr_process->gr_process_config->get_process_config(
      IMPORTING
        es_process_config = ls_process_config ).

    lv_found_proc_id = /idxgc/if_constants=>gc_false.

    SORT ls_process_config-steps BY bmid.

    LOOP AT ls_process_config-steps[] ASSIGNING <lfs_step_config>
      WHERE bmid = is_message_step_data-bmid.
*--------------------------------------------------------------------*

* check relevance of step
      CLEAR lv_step_not_relevant.
      TRY.
          CALL METHOD me->check_config_step_not_relevant
            EXPORTING
              is_process_config    = ls_process_config
              is_message_step_data = is_message_step_data
              is_config_step       = <lfs_step_config>
            IMPORTING
              ev_step_not_relevant = lv_step_not_relevant.
        CATCH /idxgc/cx_process_error INTO lr_previous.
          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
            EXPORTING
              ir_previous = lr_previous.
      ENDTRY.
      IF lv_step_not_relevant = abap_true.
        CONTINUE.
      ENDIF.

* add step to process
      ls_proc_step_data-proc_step_no     = <lfs_step_config>-proc_step_no.

      CASE ls_process_config-engine_type.
        WHEN /idxgc/if_constants_add=>gc_type_process_engine.
          ls_proc_data = ls_proc_data_back.

*       Set the step status to NEW first
          ls_proc_step_data-proc_step_status = if_isu_ide_switch_constants=>co_swtmsg_status_new.

**       Move message header data to process header
*        DO.
*          ASSIGN COMPONENT sy-index OF STRUCTURE is_message_step_data-proc TO <lfs_msg_field_value>.
*          IF sy-subrc = 0.
*            CHECK <lfs_msg_field_value> IS NOT INITIAL.
*            ASSIGN COMPONENT sy-index OF STRUCTURE ls_proc_data-hdr TO <lfs_proc_field_value>.
*            <lfs_proc_field_value> = <lfs_msg_field_value>.
*          ELSE.
*            EXIT.
*          ENDIF.
*        ENDDO.

          INSERT ls_proc_step_data INTO TABLE ls_proc_data-steps.

          CALL METHOD lr_process_data->refresh
            EXPORTING
              is_process_data = ls_proc_data.

          CLEAR ls_validate_result.

*       Check if potential step is executable
          ls_message_step_key-proc_ref     = is_message_step_data-proc_ref.
          ls_message_step_key-proc_id      = <lfs_step_config>-proc_id.
          ls_message_step_key-proc_step_no = <lfs_step_config>-proc_step_no.

          TRY.
              CALL METHOD lr_process->is_executable
                EXPORTING
                  is_process_step_key = ls_message_step_key
                IMPORTING
                  es_result           = ls_validate_result.

            CATCH /idxgc/cx_process_error INTO lr_previous.
              MESSAGE e011(/idxgc/ide) INTO gv_mtext.
              CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
                EXPORTING
                  ir_previous = lr_previous.
          ENDTRY.

        WHEN /idxgc/if_constants_add=>gc_type_workflow
          OR space.

          IF lv_pdoc_not_active = /idxgc/if_constants=>gc_true.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*          ls_proc_step_data-proc_step_status = /idxgc/if_pd_wf_constants=>gc_proc_step_status_reverse.
            IF is_message_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_er901.
              ls_proc_step_data-proc_step_status = if_isu_ide_switch_constants=>co_swtmsg_status_new.
            ELSE.
              ls_proc_step_data-proc_step_status = /idxgc/if_pd_wf_constants=>gc_proc_step_status_reverse.
            ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            ls_validate_result-executable = /idxgc/if_constants=>gc_execute_with_reserve.
          ELSE.
            ls_proc_step_data-proc_step_status = if_isu_ide_switch_constants=>co_swtmsg_status_new.
            ls_validate_result-executable = /idxgc/if_constants=>gc_execute_ok.
          ENDIF.

          ls_proc_data = ls_proc_data_back.

          INSERT ls_proc_step_data INTO TABLE ls_proc_data-steps.
          CALL METHOD lr_process_data->refresh
            EXPORTING
              is_process_data = ls_proc_data.

      ENDCASE.


*   add entry to list of potential processes/steps where applicable
      IF ls_validate_result-executable = /idxgc/if_constants=>gc_execute_ok.
        INSERT lr_process_data->gs_process_data INTO TABLE ct_process_data_valid.
        lv_found_proc_id = /idxgc/if_constants=>gc_true.

      ELSEIF ls_validate_result-executable = /idxgc/if_constants=>gc_execute_with_reserve.
        INSERT lr_process_data->gs_process_data INTO TABLE ct_process_data_with_reserve.
        lv_found_proc_id = /idxgc/if_constants=>gc_true.
      ENDIF.

      CLEAR ls_validate_result.
    ENDLOOP.

* sy-subrc ne 0 if process does not contain a matching step for BMID.
    IF  sy-subrc NE 0.
      MESSAGE e018(/idxgc/ide_add) INTO gv_mtext WITH is_message_step_data-bmid is_message_step_data-proc_ref.
      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
        EXPORTING
          ir_previous = lr_previous.
    ENDIF.

*--------------------------------------------------------------------*
* If process reference exists in message data BUT no valid step was found
* then assign the message data to process ref anyway (as it MUST belong here)
* however create a corresponding exception "for information".
    IF lv_found_proc_id = /idxgc/if_constants=>gc_false.

* Add entry to this step ID
      INSERT lr_process_data->gs_process_data INTO TABLE ct_process_data_with_reserve.

*   Add exception information
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      IF lr_process_data->gs_process_data-proc_id = /adesso/if_bpm_eide_co=>gc_proc_id_8030.
        CLEAR cs_exception_data.
      ELSE.
        cs_exception_data-exception_code   = /idxgc/if_constants=>gc_exception_unexpected_step.
        cs_exception_data-exception_caller = /idxgc/if_constants=>gc_exception_caller_idex.
      ENDIF.
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ENDIF.

  ENDMETHOD.


  METHOD /idxgc/if_badi_msg_processing~handle_nonunique_process.
***************************************************************************************************
* THIMEL.R, 20150204, CL Einführung
*   Bei alten Workflow-Prozessen sind für einige BMIDs mehrere Prozesse definiert. Diese müssen hier
*     gefiltert werden.
* THIMEL.R, 20151001, Alte SDÄ entfernt.
***************************************************************************************************
    DATA:
      lr_previous           TYPE REF TO /idxgc/cx_general,
      lt_proc_data_valid    TYPE        /idxgc/t_proc_data,
      ls_process_data_valid TYPE        /idxgc/s_proc_data,
      lv_tlines             TYPE        i,
      lv_proc_id            TYPE        /idxgc/de_proc_id.

    FIELD-SYMBOLS:
      <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
      <fs_diverse_details> TYPE /idxgc/s_diverse_details.

***** SUPER-Methode *******************************************************************************
    TRY.
        CALL METHOD super->/idxgc/if_badi_msg_processing~handle_nonunique_process
          EXPORTING
            it_proc_data       = it_proc_data
            it_process_config  = it_process_config
            is_message_data    = is_message_data
            iv_dexproc         = iv_dexproc
          CHANGING
            cr_process_data    = cr_process_data
            cs_process_key_all = cs_process_key_all
            cs_exception_data  = cs_exception_data.
      CATCH /idxgc/cx_ide_error.
***** Eigene Logik für alte Workflow-Prozesse: Richtigen Prozess zur BMID ermitteln ***************
        IF lines( it_proc_data ) > 1 AND cr_process_data IS INITIAL.

          READ TABLE is_message_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*---- ES101 - Anmeldung NN ------------------------------------------------------------------------
          IF <fs_proc_step_data>-bmid = /idxgc/if_constants_ide=>gc_bmid_es101.
            READ TABLE <fs_proc_step_data>-diverse ASSIGNING <fs_diverse_details> INDEX 1.
            IF <fs_diverse_details>-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_e03.
              lv_proc_id = zif_agc_datex_utilmd_co=>gc_proc_id_9112.
            ELSEIF <fs_diverse_details>-msgtransreason = zif_agc_datex_utilmd_co=>gc_trans_reason_code_z28.
              lv_proc_id = zif_agc_datex_utilmd_co=>gc_proc_id_9912.
            ELSE.
              lv_proc_id = zif_agc_datex_utilmd_co=>gc_proc_id_9012.
            ENDIF.
*---- EE101 - Abmeldung NN ------------------------------------------------------------------------
          ELSEIF <fs_proc_step_data>-bmid = /idxgc/if_constants_ide=>gc_bmid_ee101.
            READ TABLE <fs_proc_step_data>-diverse ASSIGNING <fs_diverse_details> INDEX 1.
            IF <fs_diverse_details>-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_e03.
              lv_proc_id = zif_agc_datex_utilmd_co=>gc_proc_id_9132.
            ELSEIF <fs_diverse_details>-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_zc9.
              lv_proc_id = zif_agc_datex_utilmd_co=>gc_proc_id_9184.
            ELSEIF <fs_diverse_details>-msgtransreason = zif_agc_datex_utilmd_co=>gc_trans_reason_code_z27.
              lv_proc_id = zif_agc_datex_utilmd_co=>gc_proc_id_9910.
            ELSEIF <fs_diverse_details>-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z33
               AND sy-mandt = zif_agc_datex_co=>gc_mandt_110.
              lv_proc_id = zif_agc_datex_utilmd_co=>gc_proc_id_9013.
            ELSE.
              lv_proc_id = zif_agc_datex_utilmd_co=>gc_proc_id_9032.
            ENDIF.
          ENDIF.


***** Eigene Logik für alte Workflow-Prozesse: Objekt erzeugen bei eindeutigen Daten **************
          IF lv_proc_id IS NOT INITIAL.

            lt_proc_data_valid = it_proc_data.
            DELETE lt_proc_data_valid WHERE proc_id <> lv_proc_id.

            DESCRIBE TABLE lt_proc_data_valid LINES lv_tlines.
            CASE lv_tlines.
              WHEN 1.
                READ TABLE lt_proc_data_valid INTO ls_process_data_valid INDEX 1.
                IF sy-subrc = 0.
                  TRY.
                      CREATE OBJECT cr_process_data
                        TYPE
                        /idxgc/cl_process_data
                        EXPORTING
                          is_process_data = ls_process_data_valid.

                    CATCH /idxgc/cx_general INTO lr_previous.
                      MESSAGE e015(/idxgc/ide) INTO gv_mtext.
                      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
                        EXPORTING
                          ir_previous = lr_previous.
                  ENDTRY.

                  cs_process_key_all-proc_ref = ls_process_data_valid-proc_ref.
                  cs_process_key_all-proc_id = ls_process_data_valid-proc_id.
                ENDIF.
              WHEN OTHERS.
                MESSAGE e003(/idxgc/ide) INTO gv_mtext.
                CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ).
            ENDCASE.
          ENDIF.
        ENDIF.
    ENDTRY.

  ENDMETHOD.


  METHOD handle_nonunique_process_dcr.

    "Kopie aus dem Standard mit Ergänzung um Logik für ROM MSCONS

    DATA: ls_proc_step_data_init TYPE        /idxgc/s_proc_step_data,
          lt_proc_data_valid     TYPE        /idxgc/t_proc_data,
          ls_proc_msg_dev        TYPE        /idxgc/s_meterdev_details,
          ls_process_data_valid  TYPE        /idxgc/s_proc_data,
          lr_previous            TYPE REF TO /idxgc/cx_general,
          lv_srvcat_receiver     TYPE        intcode,
          ls_marketpartner       TYPE        /idxgc/s_markpar_details,
          ls_proc_data           TYPE        /idxgc/s_proc_data.

    FIELD-SYMBOLS:
      <fs_proc_step_data> TYPE /idxgc/s_proc_step_data.

    READ TABLE is_message_data-steps ASSIGNING <fs_proc_step_data> INDEX 1.

*   Check if a DCR prcess exists and NOT_ALLOWED_ASS_MSG is ABAP_FALSE
    LOOP AT it_proc_data INTO ls_proc_data
      WHERE proc_ref IS NOT INITIAL
        AND proc_date = is_message_data-proc_date
        AND ( proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_dso
        OR    proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_rec )
        AND not_allowed_ass_msg = abap_false.

      SORT ls_proc_data-steps BY proc_step_no ASCENDING.
      READ TABLE ls_proc_data-steps INTO ls_proc_step_data_init INDEX 1.

      IF ls_proc_step_data_init-own_servprov = is_proc_step_data_msg-own_servprov.
*       If the inbound MSCONS is removal MSCONS, we don#t need to check the meter number
        IF is_proc_step_data_msg-bmid = /idxgc/if_constants_ide=>gc_bmid_cm020.
          APPEND ls_proc_data TO lt_proc_data_valid.
          EXIT.
        ENDIF.

*       Compare the meter number in the initial message.
        READ TABLE is_proc_step_data_msg-meter_dev[] INTO ls_proc_msg_dev INDEX 1.
        READ TABLE ls_proc_step_data_init-meter_dev[]
          WITH KEY meternumber = ls_proc_msg_dev-meternumber TRANSPORTING NO FIELDS.

*       Meter number doesn't match, continue check with next PDoc
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

*       It is an installation MSCONS and the meter number is also valid
*       --> It is the valid process
        APPEND ls_proc_data TO lt_proc_data_valid.
        EXIT.
      ENDIF.
    ENDLOOP.

* Create and start process
    IF lt_proc_data_valid IS NOT INITIAL.
      READ TABLE lt_proc_data_valid INTO ls_process_data_valid INDEX 1.
      IF sy-subrc = 0.
        TRY.
            CREATE OBJECT cr_process_data
              TYPE
              /idxgc/cl_process_data
              EXPORTING
                is_process_data = ls_process_data_valid.

          CATCH /idxgc/cx_general INTO lr_previous.
            MESSAGE e015(/idxgc/ide) INTO gv_mtext.
            CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
              EXPORTING
                ir_previous = lr_previous.
        ENDTRY.

        cs_process_key_all-proc_ref = ls_process_data_valid-proc_ref.
        cs_process_key_all-proc_id  = ls_process_data_valid-proc_id.
      ENDIF.

    ELSE.
      READ TABLE <fs_proc_step_data>-marketpartner INTO ls_marketpartner
           WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_01_qual_mr.
      TRY.
          CALL METHOD /idxgc/cl_md_chg_utils=>det_srv_cat
            EXPORTING
              iv_serviceid = ls_marketpartner-serviceid
            RECEIVING
              rv_srv_cat   = lv_srvcat_receiver.
        CATCH /idxgc/cx_mdchg_utility_error .
      ENDTRY.

      IF lv_srvcat_receiver = /idxgc/if_constants_add=>gc_srvcat_dist.
*     If master data change, we will direct trigger the DCR process
        IF is_proc_step_data_msg-bmid = /idxgc/if_constants_ide=>gc_bmid_cm014 OR            "CM014/CH121
           is_proc_step_data_msg-bmid = /idxgc/if_constants_ide=>gc_bmid_ch121 .
          cs_process_key_all-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_dso.        "8011
        ELSE.
          IF <fs_proc_step_data>-mr_reason_ext = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_rom.
            cs_process_key_all-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_dso. "8011
          ELSE.
            cs_process_key_all-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_dso. "8013
          ENDIF.
        ENDIF.
      ELSE.
*     If master data change, we will direct trigger the DCR process
        IF is_proc_step_data_msg-bmid = /idxgc/if_constants_ide=>gc_bmid_cm014 OR
           is_proc_step_data_msg-bmid = /idxgc/if_constants_ide=>gc_bmid_ch122 OR
           is_proc_step_data_msg-bmid = /idxgc/if_constants_ide=>gc_bmid_ch123 .
          cs_process_key_all-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_rec.        "8012
        ELSE.
          IF <fs_proc_step_data>-mr_reason_ext = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_rom.
            cs_process_key_all-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_rec. "8012
          ELSE.
            cs_process_key_all-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_rec. "8014
          ENDIF.
        ENDIF.
      ENDIF.

*   Create and start process
      LOOP AT it_proc_data INTO ls_process_data_valid
        WHERE proc_id = cs_process_key_all-proc_id
          AND proc_ref IS INITIAL.
        TRY.
            CREATE OBJECT cr_process_data
              TYPE
              /idxgc/cl_process_data
              EXPORTING
                is_process_data = ls_process_data_valid.

          CATCH /idxgc/cx_general INTO lr_previous.
            MESSAGE e015(/idxgc/ide) INTO gv_mtext.
            CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
              EXPORTING
                ir_previous = lr_previous.
        ENDTRY.
        EXIT.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
