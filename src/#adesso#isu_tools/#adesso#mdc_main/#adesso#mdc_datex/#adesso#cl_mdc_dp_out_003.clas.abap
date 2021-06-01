class /ADESSO/CL_MDC_DP_OUT_003 definition
  public
  inheriting from /IDXGC/CL_DP_OUT_MDC_003
  final
  create public .

public section.

  data GV_MTEXT type STRING .

  methods /IDXGC/IF_DP_OUT~PROCESS_CONFIGURATION_STEPS
    redefinition .
  methods /IDXGC/IF_DP_OUT~PROCESS_DATA_PROVISION
    redefinition .
  methods ALREADY_EXCH_POD_TYPE
    redefinition .
  methods NAME_ADDRESS_MR_CARD
    redefinition .
  methods POINT_OF_DELIVERY
    redefinition .
protected section.

  data LR_DP_OUT type ref to /ADESSO/IF_MDC_DP_OUT .
  data LR_DP_OUT_COND type ref to /ADESSO/CL_MDC_DP_OUT_COND .
  data GV_AMID type /IDXGC/DE_AMID .
private section.

  methods DET_AMID
    importing
      !IV_BMID type /IDXGC/DE_BMID
    raising
      /IDXGC/CX_PROCESS_ERROR .
ENDCLASS.



CLASS /ADESSO/CL_MDC_DP_OUT_003 IMPLEMENTATION.


  METHOD /idxgc/if_dp_out~process_configuration_steps.
***************************************************************************************************
* 20160222, THIMEL.R, Kopie aus /ADESSO/CL_MDC_DP_OUT_001
*   Coding übernommen aus Oberklasse.
*   Änderungen sind durch +++++ gekenzeichnet.
***************************************************************************************************
    DATA: lt_bmid_config           TYPE /idxgc/t_bmid_conf,
          ls_bmid_config           TYPE /idxgc/bmid_conf,
          ls_bmid_config_group_ide TYPE /idxgc/bmid_conf,
          lt_bmid_config_group_ide TYPE /idxgc/t_bmid_conf,
          lt_edi_comp              TYPE /idxgc/t_edi_comp,  "#EC NEEDED
          lv_mtext                 TYPE string,             "#EC NEEDED
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
                    CATCH /idxgc/cx_general.
                      "Wenn kein Customizing vorhanden ist wird der Standard genutzt.
                  ENDTRY.
                  IF lr_dp_out_cond->evaluate_condition( is_process_step_data = gs_process_step_data
                       iv_edifact_structur = ls_bmid_config_group_ide-edifact_structur iv_dp_condition = ls_cust_odp-dp_condition ) = abap_true.
                    IF ls_cust_odp-source_dp_class = /adesso/if_mdc_co=>gc_source_dp_class_gen.
                      CALL METHOD lr_dp_out->call_method( EXPORTING is_bmid_config = ls_bmid_config_group_ide CHANGING cs_process_step_data = gs_process_step_data ).
                    ELSE.
                      CALL METHOD me->(ls_bmid_config_group_ide-method).
                    ENDIF.
                  ELSE.
                    ls_bmid_config_group_ide-mandatory = abap_false. "Es sollen nur die abh. Strukturen gelöscht werden. Im SAP-Customizing sind bei SDÄ viele Einträge Mussfeld, die eigentlich keins sind.
                    MESSAGE e043(/adesso/mdc_process) INTO gv_mtext WITH ls_bmid_config_group_ide-edifact_structur.
                    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
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
              ELSE.
                ls_bmid_config-mandatory = abap_false. "Es sollen nur die abh. Strukturen gelöscht werden. Im SAP-Customizing sind bei SDÄ viele Einträge Mussfeld, die eigentlich keins sind.
                MESSAGE e043(/adesso/mdc_process) INTO gv_mtext WITH ls_bmid_config-edifact_structur.
                /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
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
***************************************************************************************************
* 20170210, THIMEL.R, Kopie aus /ADESSO/CL_MDC_DP_OUT_002
***************************************************************************************************
    DATA: lr_previous   TYPE REF TO cx_root,
          ls_msg_config TYPE /idxgc/msg_out.
***************************************************************************************************
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


  METHOD already_exch_pod_type.
***************************************************************************************************
* THIMEL.R, 20160223, Kopie aus dem Standard mit Anpassung für "Eigene Daten lesen"
*   Anpassungen sind mit "+++++" gekennzeichnet
***************************************************************************************************
    DATA: ls_pod_src      TYPE /idxgc/s_pod_info_details,
          lr_badi_datapro TYPE REF TO /idxgc/badi_data_provision,
          lx_previous     TYPE REF TO /idxgc/cx_process_error,
          lr_root         TYPE REF TO cx_root,
          lv_source_exist TYPE flag,
          lv_value_from   TYPE /idxgc/de_value_from,
          lv_mtext        TYPE string,                      "#EC NEEDED
          lv_class_name   TYPE seoclsname,
          lv_method_name  TYPE seocpdname,
          lv_service_type TYPE intcode.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    DATA: ls_cust_main TYPE /adesso/mdc_s_main.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    FIELD-SYMBOLS:
          <fs_pod>              TYPE /idxgc/s_pod_info_details.

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    TRY.
        ls_cust_main = /adesso/cl_mdc_customizing=>get_general_customizing( ).
      CATCH /idxgc/cx_general INTO lr_root.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_root ).
    ENDTRY.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    CASE siv_data_processing_mode.
* get data from source step
      WHEN /idxgc/if_constants_add=>gc_data_from_source.
        LOOP AT gs_process_data_src-pod INTO ls_pod_src
             WHERE item_id = siv_itemid
               AND loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.

          READ TABLE gs_process_step_data-pod ASSIGNING <fs_pod>
               WITH KEY item_id = siv_itemid
                         ext_ui = ls_pod_src-ext_ui
                  loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.
          IF sy-subrc = 0.
            <fs_pod>-exch_pod_type = ls_pod_src-exch_pod_type.
          ENDIF.
        ENDLOOP.

* get data from additional source step
      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
        LOOP AT gs_process_data_src_add-pod INTO ls_pod_src
             WHERE item_id = siv_itemid
               AND loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.

          READ TABLE gs_process_step_data-pod ASSIGNING <fs_pod>
               WITH KEY item_id = siv_itemid
                         ext_ui = ls_pod_src-ext_ui
                  loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.
          IF sy-subrc = 0.
            <fs_pod>-exch_pod_type = ls_pod_src-exch_pod_type.
          ENDIF.
        ENDLOOP.

* get data from default determination logic
      WHEN /idxgc/if_constants_add=>gc_default_processing.

*     In case of BMID CH173: only fill already exchanged Pod type if sender is SUPPL
        IF gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_ch173.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*+++++ Im Netz auch füllen wenn Sender Lieferant ist.
          IF ls_cust_main-global_intcode = /idxgc/if_constants_add=>gc_srvcat_dist.
            TRY.
                CALL METHOD /idxgc/cl_utility_service_isu=>get_service_type
                  EXPORTING
                    iv_service_id   = gs_process_step_data-assoc_servprov
                  RECEIVING
                    rv_service_type = lv_service_type.
              CATCH /idxgc/cx_utility_error .
*         Do nothing
            ENDTRY.
            CHECK lv_service_type EQ /idxgc/if_constants_add=>gc_srvcat_supp.
          ELSE.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            TRY.
                CALL METHOD /idxgc/cl_utility_service_isu=>get_service_type
                  EXPORTING
                    iv_service_id   = gs_process_step_data-own_servprov
                  RECEIVING
                    rv_service_type = lv_service_type.
              CATCH /idxgc/cx_utility_error .
*         Do nothing
            ENDTRY.
            CHECK lv_service_type EQ /idxgc/if_constants_add=>gc_srvcat_supp.
          ENDIF. "+++++
        ENDIF.
*     In case of BMID CH214 and CH223:
*     only fill already exchanged Pod type if receiver is SUPPL
        IF gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_ch214 OR
           gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_ch223 .
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*+++++ Im Vertrieb immer füllen für den Vergleich.
          IF ls_cust_main-global_intcode <> /idxgc/if_constants_add=>gc_srvcat_supp.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            TRY.
                CALL METHOD /idxgc/cl_utility_service_isu=>get_service_type
                  EXPORTING
                    iv_service_id   = gs_process_step_data-assoc_servprov
                  RECEIVING
                    rv_service_type = lv_service_type.
              CATCH /idxgc/cx_utility_error .
*         Do nothing
            ENDTRY.
            CHECK lv_service_type EQ /idxgc/if_constants_add=>gc_srvcat_supp.
          ENDIF. "+++++
        ENDIF.

        LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod>
             WHERE item_id = siv_itemid.
*             AND loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.
          CLEAR: lv_source_exist, lv_value_from.

* Try to get data from source step firstly
          READ TABLE gs_process_data_src-pod INTO ls_pod_src
               WITH KEY item_id = siv_itemid
                        ext_ui  = <fs_pod>-ext_ui.

          IF ls_pod_src-exch_pod_type IS NOT INITIAL.
            lv_source_exist = abap_true.
          ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* THIMEL.R, 20160307, Wert immer neu lesen. Die Methode unten löscht den Wert sonst bei CH206/214.
*       Check where to get data, source step or master data
*          CALL METHOD me->check_source_master
*            EXPORTING
*              iv_source_exist = lv_source_exist
*            IMPORTING
*              ev_value_from   = lv_value_from.

          lv_value_from = /idxgc/if_constants_add=>gc_value_from_master.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          CASE lv_value_from.
            WHEN /idxgc/if_constants_add=>gc_value_from_source.
              <fs_pod>-exch_pod_type = ls_pod_src-exch_pod_type.

            WHEN /idxgc/if_constants_add=>gc_value_from_master.
              IF siv_mandatory_data = abap_true.
                TRY.
                    GET BADI lr_badi_datapro.

                  CATCH cx_badi_not_implemented
                        cx_badi_multiply_implemented INTO lr_root.

                    MESSAGE e007(/idxgc/general) INTO lv_mtext
                                                 WITH /idxgc/if_constants_ddic_add=>gc_badi_data_provision. "'/IDXGC/BADI_DATA_PROVISION'
                    CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
                      EXPORTING
                        ir_previous = lr_root.
                ENDTRY.

                TRY.
                    CALL BADI lr_badi_datapro->already_exch_pod_type
                      EXPORTING
                        is_process_data_src     = gs_process_data_src
                        is_process_data_src_add = gs_process_data_src_add
                        is_process_data         = gs_process_step_data
                        iv_itemid               = siv_itemid
                      CHANGING
                        ct_pod                  = gs_process_step_data-pod.

                  CATCH /idxgc/cx_process_error INTO lx_previous.
                    CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_source_pos
                      IMPORTING
                        ev_class_name  = lv_class_name
                        ev_method_name = lv_method_name.
                    MESSAGE e021(/idxgc/ide_add) INTO lv_mtext WITH lv_class_name lv_method_name.
                    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
                ENDTRY.
              ENDIF.
            WHEN OTHERS .
*         do nothing.
          ENDCASE.
        ENDLOOP.

      WHEN OTHERS .
* do nothing.
    ENDCASE.

    READ TABLE gs_process_step_data-pod INTO ls_pod_src
         WITH KEY item_id = siv_itemid
            loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.

    IF ls_pod_src-exch_pod_type IS NOT INITIAL.
      IF siv_mdc_object = abap_true.
        siv_mdc_object_indicator = abap_true.
      ENDIF.
    ELSE.
      IF siv_mandatory_data = abap_true.
        MESSAGE e038(/idxgc/ide_add) WITH text-171 INTO lv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD det_amid.
***************************************************************************************************
* 20160222, THIMEL.R, Kopie aus /ADESSO/CL_MDC_DP_OUT_001
***************************************************************************************************
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


  METHOD name_address_mr_card.
***************************************************************************************************
* THIMEL-R, 20160331, MDC_OBJECT Variable leeren damit BAdI aufgerufen wird.
***************************************************************************************************
    siv_mdc_object = abap_false.

    CALL METHOD super->name_address_mr_card.
  ENDMETHOD.


  method POINT_OF_DELIVERY.
***************************************************************************************************
* THIMEL.R, 20160222, Kopie aus /ADESSO/CL_MDC_DP_OUT_001
***************************************************************************************************
    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

    CALL METHOD super->point_of_delivery.

    IF gs_process_step_data-bmid <> /adesso/if_mdc_co=>gc_bmid_zch01 AND gs_process_step_data-bmid <> /adesso/if_mdc_co=>gc_bmid_zch02.
      LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod> WHERE item_id = siv_itemid.
        <fs_pod>-no_ref_pod_data = abap_true.
      ENDLOOP.
    ENDIF.
  endmethod.
ENDCLASS.
