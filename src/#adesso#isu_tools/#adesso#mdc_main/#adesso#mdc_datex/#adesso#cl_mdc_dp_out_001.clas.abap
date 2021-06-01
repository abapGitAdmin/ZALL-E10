class /ADESSO/CL_MDC_DP_OUT_001 definition
  public
  inheriting from /IDXGC/CL_DP_OUT_MDC_001
  final
  create public .

public section.

  data GV_MTEXT type STRING .

  methods /IDXGC/IF_DP_OUT~PROCESS_CONFIGURATION_STEPS
    redefinition .
  methods /IDXGC/IF_DP_OUT~PROCESS_DATA_PROVISION
    redefinition .
  methods POINT_OF_DELIVERY
    redefinition .
protected section.

  data LR_DP_OUT type ref to /ADESSO/IF_MDC_DP_OUT .
  data LR_DP_OUT_COND type ref to /ADESSO/CL_MDC_DP_OUT_COND .
  data GV_AMID type /IDXGC/DE_AMID .

  methods DET_AMID
    importing
      !IV_BMID type /IDXGC/DE_BMID
    raising
      /IDXGC/CX_PROCESS_ERROR .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_DP_OUT_001 IMPLEMENTATION.


METHOD /idxgc/if_dp_out~process_configuration_steps.
***************************************************************************************************
* THIMEL.R, 20150824, SDÄ auf Common Layer Engine
*   Coding übernommen aus Oberklasse.
*   Änderungen sind durch +++++ gekenzeichnet.
***************************************************************************************************
  DATA: lt_bmid_config           TYPE /idxgc/t_bmid_conf,
        ls_bmid_config           TYPE /idxgc/bmid_conf,
        ls_bmid_config_group_ide TYPE /idxgc/bmid_conf,
        lt_bmid_config_group_ide TYPE /idxgc/t_bmid_conf,
        lt_edi_comp              TYPE /idxgc/t_edi_comp,    "#EC NEEDED
        lv_mtext                 TYPE string,               "#EC NEEDED
        lx_previous              TYPE REF TO /idxgc/cx_general,
        ls_process_data_src      TYPE /idxgc/s_proc_step_data_all,
        ls_diverse               TYPE /idxgc/s_diverse_details.
  DATA: lv_non_proc_condition     TYPE /idxgc/de_non_pro_condition.

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  DATA: lr_previous TYPE REF TO cx_root,
        ls_cust_odp TYPE /adesso/mdc_s_odp.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  TRY .
      CALL METHOD /idxgc/if_dp_out~get_configuration
        IMPORTING
          et_bmid_config = lt_bmid_config
          et_edi_comp    = lt_edi_comp.
    CATCH /idxgc/cx_process_error INTO lx_previous.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
  ENDTRY.

  CALL METHOD me->instantiate( ).

  SORT lt_bmid_config BY step_index.

* Field "Non Processing Condition" is used to distinguish different processes(GPKE & GENF), if it is
* set to initial, the segment will be used to all processes.
  CASE gs_process_step_data-sup_direct_int.
    WHEN /idxgc/if_constants_add=>gc_sup_direct_supply.
      lv_non_proc_condition = /idxgc/if_constants_add=>gc_non_proc_condition_01.
    WHEN /idxgc/if_constants_add=>gc_sup_direct_feeding.
      lv_non_proc_condition = /idxgc/if_constants_add=>gc_non_proc_condition_02.
    WHEN OTHERS.
  ENDCASE.

  LOOP AT lt_bmid_config INTO ls_bmid_config
    WHERE ( non_process_cond IS INITIAL ) OR
          ( non_process_cond = lv_non_proc_condition ).

* Fill the flag siv_data_from_source and siv_data_from_add_source in case customer use them
    siv_data_from_source = ls_bmid_config-data_from_source.
    siv_data_from_add_source = ls_bmid_config-data_add_source.

    IF ls_bmid_config-data_from_source IS NOT INITIAL.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_source.
    ELSEIF ls_bmid_config-data_add_source IS NOT INITIAL.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source.
    ELSE.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_default_processing.
    ENDIF.

* Check wehther the field is mandatory
    siv_mandatory_data = ls_bmid_config-mandatory.

* Check wehther MDC object indicator is active
    siv_mdc_object = ls_bmid_config-mdc_object.

    IF ls_bmid_config-edifact_group EQ /idxgc/if_constants_add=>gc_edifact_group_ide.
      IF gs_process_data_src IS NOT INITIAL.
        ls_process_data_src = gs_process_data_src.
      ELSE.
        ls_process_data_src = gs_process_data_src_add.
      ENDIF.

* Collect relevant provision methods based on dependency of EDIFACT and group
      REFRESH lt_bmid_config_group_ide.
      APPEND ls_bmid_config TO lt_bmid_config_group_ide.
      LOOP AT lt_bmid_config INTO ls_bmid_config_group_ide
        WHERE ( non_process_cond IS INITIAL
          OR non_process_cond = lv_non_proc_condition )
          AND edifact_group EQ /idxgc/if_constants_add=>gc_edifact_group_ide
          AND dependent_str = ls_bmid_config-edifact_structur.
        APPEND ls_bmid_config_group_ide TO lt_bmid_config_group_ide.
      ENDLOOP.
      SORT lt_bmid_config_group_ide BY step_index.
      DELETE lt_bmid_config
        WHERE dependent_str = ls_bmid_config-edifact_structur
          AND edifact_group EQ /idxgc/if_constants_add=>gc_edifact_group_ide.

* Process all relevant provision methods for each diverse item
      LOOP AT ls_process_data_src-diverse INTO ls_diverse.
        siv_itemid = ls_diverse-item_id.
        LOOP AT lt_bmid_config_group_ide INTO ls_bmid_config_group_ide.
*       If the division category doesn't set in the configuration, we consider it as the same meaning
*       with value 99(For all sectors).
          IF ( ls_bmid_config_group_ide-spartyp = gs_process_step_data-spartyp ) OR
             ( ls_bmid_config_group_ide-spartyp IS INITIAL ) OR
             ( ls_bmid_config_group_ide-spartyp = /idxgc/if_constants=>gc_divcat_all ).
*       Call specific method
            TRY .
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                TRY.
                    CLEAR: ls_cust_odp.
                    ls_cust_odp = /adesso/cl_mdc_customizing=>get_dp_config( iv_amid = gv_amid iv_edifact_structur = ls_bmid_config_group_ide-edifact_structur ).
                  CATCH /idxgc/cx_general INTO lr_previous.
                    "Wenn kein Customizing vorhanden ist wird der Standard genutzt.
                ENDTRY.
                IF lr_dp_out_cond->evaluate_condition( is_process_step_data = gs_process_step_data
                  iv_edifact_structur = ls_bmid_config_group_ide-edifact_structur iv_dp_condition = ls_cust_odp-dp_condition ) = abap_true.
                  IF ls_cust_odp-source_dp_class = /adesso/if_mdc_co=>gc_source_dp_class_gen.
                    CALL METHOD lr_dp_out->call_method( EXPORTING is_bmid_config = ls_bmid_config_group_ide CHANGING cs_process_step_data = gs_process_step_data ).
                  ELSE.
                    CALL METHOD me->(ls_bmid_config_group_ide-method).
                  ENDIF.
                ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
              CATCH cx_sy_dyn_call_illegal_method.
                MESSAGE e060(/idxgc/process_add) INTO lv_mtext
                  WITH ls_bmid_config_group_ide-method ls_bmid_config_group_ide-edifact_structur.
                CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
              CATCH /idxgc/cx_process_error INTO lx_previous.
                IF ls_bmid_config_group_ide-mandatory IS NOT INITIAL.
                  CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
                ELSE.
                  DELETE lt_bmid_config WHERE dependent_str = ls_bmid_config-edifact_structur.
                  DELETE lt_bmid_config_group_ide WHERE dependent_str = ls_bmid_config-edifact_structur.
                  CONTINUE.
                ENDIF.
            ENDTRY.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ELSE.
      siv_itemid = 1.
*   If the division category doesn't set in the configuration, we consider it as the same meaning
*   with value 99(For all sectors).
      IF ( ls_bmid_config-spartyp = gs_process_step_data-spartyp ) OR
         ( ls_bmid_config-spartyp IS INITIAL ) OR
         ( ls_bmid_config-spartyp = /idxgc/if_constants=>gc_divcat_all ).
*   Call specific method
        TRY .
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            TRY.
                CLEAR: ls_cust_odp.
                ls_cust_odp = /adesso/cl_mdc_customizing=>get_dp_config( iv_amid = gv_amid iv_edifact_structur = ls_bmid_config-edifact_structur ).
              CATCH /idxgc/cx_general INTO lr_previous.
                "Wenn kein Customizing vorhanden ist wird der Standard genutzt.
            ENDTRY.
            IF lr_dp_out_cond->evaluate_condition( is_process_step_data = gs_process_step_data
              iv_edifact_structur = ls_bmid_config-edifact_structur iv_dp_condition = ls_cust_odp-dp_condition ) = abap_true.
              IF ls_cust_odp-source_dp_class = /adesso/if_mdc_co=>gc_source_dp_class_gen.
                CALL METHOD lr_dp_out->call_method( EXPORTING is_bmid_config = ls_bmid_config CHANGING cs_process_step_data = gs_process_step_data ).
              ELSE.
                CALL METHOD me->(ls_bmid_config-method).
              ENDIF.
            ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          CATCH cx_sy_dyn_call_illegal_method.
            MESSAGE e060(/idxgc/process_add) INTO lv_mtext WITH ls_bmid_config-method ls_bmid_config-edifact_structur.
            CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
          CATCH /idxgc/cx_process_error INTO lx_previous.
            IF ls_bmid_config-mandatory IS NOT INITIAL.
              CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
            ELSE.
              DELETE lt_bmid_config WHERE dependent_str = ls_bmid_config-edifact_structur.
              CONTINUE.
            ENDIF.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDLOOP.

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
** Check MDC Object Indicator
*  READ TABLE lt_bmid_config TRANSPORTING NO FIELDS WITH KEY mdc_object = abap_true.
*  IF ( sy-subrc = 0 ) AND ( siv_mdc_object_indicator IS INITIAL ).
*    MESSAGE e203(/idxgc/process_add) INTO lv_mtext WITH ls_bmid_config-bmid_var+0(5).
*    CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
*  ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ENDMETHOD.


  METHOD /idxgc/if_dp_out~process_data_provision.
    DATA: lr_previous   TYPE REF TO cx_root,
          ls_msg_config TYPE /idxgc/msg_out.

    gs_process_step_data = cs_process_step_data.

* Set attributes
    CALL METHOD me->set_attributes.

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    det_amid( iv_bmid = gs_process_step_data-bmid ).

    TRY.
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_msg_class_config
          EXPORTING
            iv_dexbasicproc = gs_process_step_data-dexbasicproc
            iv_dexformat    = /idxgc/if_constants_ide=>gc_dexformat
          IMPORTING
            es_msg_config   = ls_msg_config.
      CATCH /idxgc/cx_config_error INTO lr_previous.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
    ENDTRY.

    CREATE OBJECT lr_dp_out
      TYPE
        (ls_msg_config-data_prov_class)
      EXPORTING
        is_process_data_src     = gs_process_data_src
        is_process_data_src_add = gs_process_data_src_add.

    lr_dp_out->set_process_step_data( is_process_step_data = cs_process_step_data ).

    CREATE OBJECT lr_dp_out_cond
      EXPORTING
        is_process_data_src     = gs_process_data_src
        is_process_data_src_add = gs_process_data_src_add.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    CALL METHOD me->/idxgc/if_dp_out~process_configuration_steps.
    cs_process_step_data = gs_process_step_data.

  ENDMETHOD.


  METHOD det_amid.
    DATA: lr_badi_data_access TYPE REF TO /idxgc/badi_data_access,
          ls_amid_key_field   TYPE /idxgc/s_amid_key_field.

    ls_amid_key_field-bmid       = iv_bmid.
    ls_amid_key_field-begda      = sy-datum.

    TRY.
        GET BADI lr_badi_data_access
          FILTERS
            iv_proc_cluster = ''.

      CATCH cx_badi_not_implemented cx_badi_multiply_implemented.
        MESSAGE e007(/idxgc/general) INTO gv_mtext WITH /idxgc/if_constants=>gc_badi_data_access.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        RETURN.
    ENDTRY.

    TRY.
        CALL BADI lr_badi_data_access->get_amid
          EXPORTING
            is_amid_key_field = ls_amid_key_field
          IMPORTING
            ev_amid           = gv_amid.
      CATCH /idxgc/cx_utility_error.
        MESSAGE e006(/idxgc/general) INTO gv_mtext WITH /idxgc/if_constants=>gc_badi_data_access /idxgc/if_constants=>gc_badi_get_amid.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

    IF gv_amid IS INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH 'AMID' INTO gv_mtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD point_of_delivery.
***************************************************************************************************
* THIMEL.R, 20150919, Bei SDÄ gibt es keine RFF+AVE in den SEQ-Segmenten.
* THIMEL.R, 20151102, Bei SDÄ ZD0 (BMID ZCH01 und ZCH02) muss das Segment mitgeschickt werden.
***************************************************************************************************
    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

    CALL METHOD super->point_of_delivery.

    IF gs_process_step_data-bmid <> /adesso/if_mdc_co=>gc_bmid_zch01 AND gs_process_step_data-bmid <> /adesso/if_mdc_co=>gc_bmid_zch02.
      LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod> WHERE item_id = siv_itemid.
        <fs_pod>-no_ref_pod_data = abap_true.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
