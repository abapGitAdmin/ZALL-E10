class ZCL_AGC_PD_MSG_OUT definition
  public
  inheriting from /IDXGC/CL_PD_MSG_OUT
  create public .

public section.
protected section.

  methods ENHANCE_STEP_DATA
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_AGC_PD_MSG_OUT IMPLEMENTATION.


  METHOD enhance_step_data.
    ">>>SCHMIDT.C 20150211 Kopie aus dem Standard + Erweiterung für Stammdatenänderung (SERV_PROV_NEW / SERV_PROV_OLD )

* This method should be used to enhance the data already passed
* to the step (from the START interface, from inbound processing
* or from the BPEM processing) with the step data
*
* 1) Add all data from standard data model
* 2) All all data from IDEX data model (for example, from previous messages)
* 3) Call SPECIFIC BAdIs to read data from the implementation team (for example,
*    if a specific BAdI Method exists to read PoD/Meter technical data)
* 4) Determine the outbound response code from source step

    DATA:
      lr_previous         TYPE REF TO /idxgc/cx_general,
      lt_dexformat        TYPE        idexformat,
      lv_dexformat        TYPE        e_dexformat,

      lr_dp_out           TYPE REF TO /idxgc/if_dp_out,
      ls_process_data_src TYPE        /idxgc/s_proc_step_data_all,
      ls_step             TYPE        /idxgc/s_proc_step_data,
      ls_msg_config       TYPE        /idxgc/msg_out,
      lv_service_prov_old TYPE        eideserprov_old,
      ls_service          TYPE        eedmuiservice,
      ls_tecde            TYPE        tecde,
      lv_service          TYPE        sercode,
      lt_uiservice        TYPE        t_eedmuiservice,
      ls_process_agent    TYPE        /idxgc/s_proc_agent,
      lv_distributor      TYPE        service_prov_dist,
      lv_lines            TYPE        i.

    DATA: ls_process_data_src_add TYPE /idxgc/s_proc_step_data_all.
    FIELD-SYMBOLS:
      <fs_step_data> TYPE /idxgc/s_proc_step_data.

    DATA:
      lt_proc_step_data_src TYPE /idxgc/t_proc_step_data.
    FIELD-SYMBOLS:
      <lfs_proc_step_data> TYPE /idxgc/s_proc_step_data.

    DATA: lv_data_prov_class TYPE /idxgc/de_dataprov_class,
          lv_bmid_var        TYPE /idxgc/bmid_var.
**--------------------------------------------------------------------*
* 1) Will be handled by the individual outbound steps

    IF cs_process_step_data-content_type IS INITIAL.
      cs_process_step_data-content_type = /idxgc/if_constants=>gc_cont_type_initial.
    ENDIF.

**--------------------------------------------------------------------*
*convert INT_UI from EXT_UI if not filled at header level yet
    IF cs_process_step_data-int_ui IS INITIAL
      AND cs_process_step_data-ext_ui IS NOT INITIAL.
*convert from EXT_UI to INT_UI
      TRY.
          CALL METHOD /idxgc/cl_utility_service_isu=>get_intui_from_extui
            EXPORTING
              iv_ext_ui = cs_process_step_data-ext_ui
              iv_date   = cs_process_step_data-proc_date
            IMPORTING
              rv_int_ui = cs_process_step_data-int_ui.
        CATCH /idxgc/cx_utility_error INTO lr_previous.
*not a prpblem as PoD could be OPTIONAL in Basic DATEX
      ENDTRY.
*convert EXT_UI from INT_UI if not filled at step header level yet
    ELSEIF cs_process_step_data-ext_ui IS INITIAL
      AND cs_process_step_data-int_ui IS NOT INITIAL.
*convert from INT_UI to EXT_UI
      TRY.
          CALL METHOD /idxgc/cl_utility_service_isu=>get_extui_from_intui
            EXPORTING
              iv_int_ui = cs_process_step_data-int_ui
              iv_date   = cs_process_step_data-proc_date
            RECEIVING
              rv_ext_ui = cs_process_step_data-ext_ui.
        CATCH /idxgc/cx_utility_error INTO lr_previous.
*not a prpblem as PoD could be OPTIONAL in Basic DATEX
      ENDTRY.
    ENDIF.

    IF is_process_data_src-steps[] IS NOT INITIAL.
      lt_proc_step_data_src = is_process_data_src-steps[].
      SORT lt_proc_step_data_src BY proc_step_timestamp DESCENDING.
      READ TABLE lt_proc_step_data_src ASSIGNING <lfs_proc_step_data> INDEX 1.
      IF <lfs_proc_step_data> IS ASSIGNED.
        IF cs_process_step_data-step-ext_ui IS INITIAL.
          cs_process_step_data-step-ext_ui = <lfs_proc_step_data>-step2-ext_ui.
        ENDIF.
      ENDIF.
    ENDIF.
**--------------------------------------------------------------------*
*Fill BMID according config
    IF gs_process_step_config-bmid IS INITIAL.
      MESSAGE e020(/idxgc/process_add) INTO gv_mtext WITH gs_process_step_config-proc_id /idxgc/if_constants_add=>gc_table_proc_config.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
    ELSE.
      cs_process_step_data-bmid = gs_process_step_config-bmid.
    ENDIF.

* Fill sender from head data
    CASE is_process_data_src-hdr-proc_view.
      WHEN /idxgc/if_constants_add=>gc_view_dso.
        CLEAR ls_step.
        READ TABLE is_process_data_src-steps INTO ls_step WITH KEY proc_step_no = gs_process_step_config-proc_step_src.
        cs_process_step_data-own_servprov = ls_step-own_servprov.

        IF cs_process_step_data-own_servprov IS INITIAL.
* Get distributor
          CALL METHOD /idxgc/cl_utility_isu_add=>get_distributor_assignment
            EXPORTING
              iv_ext_ui      = cs_process_step_data-ext_ui
              iv_date        = cs_process_step_data-proc_date
            IMPORTING
              ev_distributor = lv_distributor.

          cs_process_step_data-own_servprov = lv_distributor.

        ENDIF.

      WHEN /idxgc/if_constants_add=>gc_view_supn.
        IF ( cs_process_step_data-bmid = zif_agc_datex_utilmd_co=>gc_bmid_zmd01 OR
             cs_process_step_data-bmid = zif_agc_datex_utilmd_co=>gc_bmid_zmd02 OR
             cs_process_step_data-bmid = zif_agc_datex_utilmd_co=>gc_bmid_zmd03 OR
             cs_process_step_data-bmid = zif_agc_datex_utilmd_co=>gc_bmid_zmd11 OR
             cs_process_step_data-bmid = zif_agc_datex_utilmd_co=>gc_bmid_zmd12 OR
             cs_process_step_data-bmid = zif_agc_datex_utilmd_co=>gc_bmid_zmd13 ) AND
             cs_process_step_data-proc_type = zif_agc_datex_utilmd_co=>gc_proc_type_97.
          cs_process_step_data-own_servprov  = is_process_data_src-hdr-service_prov_old.
        ELSE.
          cs_process_step_data-own_servprov  = is_process_data_src-hdr-service_prov_new.
        ENDIF.
      WHEN /idxgc/if_constants_add=>gc_view_supc.
        cs_process_step_data-own_servprov  = is_process_data_src-hdr-service_prov_old.
      WHEN /idxgc/if_constants_add=>gc_view_sender OR /idxgc/if_constants_add=>gc_view_supb.
        lt_proc_step_data_src = is_process_data_src-steps[].
        READ TABLE lt_proc_step_data_src INTO ls_step
          WITH KEY proc_step_no = gs_process_step_config-proc_step_src.
        cs_process_step_data-own_servprov = ls_step-own_servprov.
      WHEN OTHERS.
        MESSAGE e039(/idxgc/process_add) INTO gv_mtext WITH is_process_data_src-hdr-proc_view.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
    ENDCASE.

    IF gs_edexproc-dexbasicproc EQ /idxgc/if_constants_ide=>gc_basicproc_e_aperak.
      lt_proc_step_data_src = is_process_data_src-steps[].
      READ TABLE lt_proc_step_data_src INTO ls_step
        WITH KEY proc_step_no = gs_process_step_config-proc_step_src.
      cs_process_step_data-own_servprov = ls_step-own_servprov.
    ENDIF.

* try to get the format from the maintained the dex process between service providers
    CALL METHOD cl_isu_datex_controller=>get_dexformat
      EXPORTING
        x_dexbasicproc  = gs_edexproc-dexbasicproc
        x_keydate       = sy-datum
        x_servprovself  = cs_process_step_data-own_servprov
        x_servprov      = cs_process_step_data-assoc_servprov
      IMPORTING
        yt_dexformat    = lt_dexformat
      EXCEPTIONS
        no_servprovself = 1
        no_servprov     = 2
        no_function     = 3
        error_occurred  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0 OR lt_dexformat IS INITIAL.
* by default, use IDXGC_UTILMD as the data exchange format
      CASE gs_edexproc-dexbasicproc.
        WHEN /idxgc/if_constants_ide=>gc_basicproc_e_utilreq
          OR /idxgc/if_constants_ide=>gc_basicproc_e_utilres
          OR /idxgc/if_constants_ide=>gc_basicproc_e_utilinf
          .
          lv_dexformat = /idxgc/if_constants_ide=>gc_dexformat. " IDXGC_UTILMD

        WHEN /idxgc/if_constants_ide=>gc_basicproc_e_aperak.
          lv_dexformat = /idxgc/if_constants_ide=>gc_dexformat_aperak. " IDXGC_APERAK

        WHEN /idxgc/if_constants_ide=>gc_basicproc_e_ordrsp.
          lv_dexformat = /idxgc/if_constants_ide=>gc_dexformat_ordrsp.  "IDXGC_ORDRSP
        WHEN OTHERS.
      ENDCASE.

    ELSE.
      CASE lines( lt_dexformat ).
        WHEN 1.
          READ TABLE lt_dexformat INTO lv_dexformat INDEX 1.
        WHEN OTHERS.
*       Dexformat could not be uniquely determined
          MESSAGE e020(/idxgc/ide) INTO gv_mtext
                                   WITH gs_edexproc-dexbasicproc
                                        cs_process_step_data-own_servprov
                                        cs_process_step_data-assoc_servprov.
*       Create general error log entry
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
      ENDCASE.
    ENDIF.
* The data provision class maintain in BMID configuration level has the highest priority
    TRY .
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_bmid_msg_config
          EXPORTING
            iv_bmid       = cs_process_step_data-bmid
            iv_valid_from = sy-datum
*           iv_valid_from = cs_process_step_data-proc_date
          IMPORTING
            es_bmid_var   = lv_bmid_var.

      CATCH /idxgc/cx_config_error INTO lr_previous.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
          EXPORTING
            ir_previous = lr_previous.
    ENDTRY.
    IF lv_bmid_var-data_prov_class IS NOT INITIAL.
      lv_data_prov_class = lv_bmid_var-data_prov_class.
    ELSE.
      TRY .
          CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_msg_class_config
            EXPORTING
              iv_dexbasicproc = gs_edexproc-dexbasicproc
              iv_dexformat    = lv_dexformat
            IMPORTING
              es_msg_config   = ls_msg_config.
        CATCH /idxgc/cx_config_error INTO lr_previous.
          CALL METHOD gr_process_log->add_message_to_process_log.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
            EXPORTING
              ir_previous = lr_previous.
      ENDTRY.
      lv_data_prov_class = ls_msg_config-data_prov_class.
    ENDIF.
    CALL METHOD /idxgc/cl_process_document=>pad_number
      CHANGING
        xy_switchnum = me->gs_process_step_key-proc_ref.

    CLEAR ls_step.
    ls_process_data_src-proc = is_process_data_src-hdr.
    READ TABLE is_process_data_src-steps INTO ls_step WITH KEY proc_step_no = gs_process_step_config-proc_step_src.
    IF sy-subrc EQ 0.
*   Source step really exists, take its data:
      MOVE-CORRESPONDING ls_step TO ls_process_data_src-step.
* Check if there is addtional source step
      DESCRIBE TABLE is_process_data_src-steps LINES lv_lines.
      IF lv_lines > 1.
        ls_process_data_src_add-proc = is_process_data_src-hdr.
        CLEAR ls_step.
        READ TABLE is_process_data_src-steps INTO ls_step WITH KEY proc_step_no = gs_process_step_config-step_no_src_add.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING ls_step TO ls_process_data_src_add-step.
        ENDIF.
      ENDIF.
    ELSE.
*   Source step didn't exist, try additional source step directly afterwards:
      CLEAR ls_step.
      ls_process_data_src_add-proc = is_process_data_src-hdr.
      READ TABLE is_process_data_src-steps INTO ls_step WITH KEY proc_step_no = gs_process_step_config-step_no_src_add.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING ls_step TO ls_process_data_src_add-step.
      ENDIF.
    ENDIF.

*Filled basic data exchange to data container
    cs_process_step_data-dexbasicproc = gs_edexproc-dexbasicproc.

    CREATE OBJECT lr_dp_out
      TYPE
        (lv_data_prov_class)
      EXPORTING
        is_process_data_src     = ls_process_data_src
        is_process_data_src_add = ls_process_data_src_add.

    CALL METHOD lr_dp_out->process_data_provision
      CHANGING
        cs_process_step_data = cs_process_step_data.

*--------------------------------------------------------------------*
* 4) Will be handled by the individual outbound steps

  ENDMETHOD.
ENDCLASS.
