class ZCL_AGC_DP_OUT_UTILMD_005 definition
  public
  inheriting from /IDEXGE/CL_DP_OUT_UTILMD_003
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_PROCESS_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROCESS_DATA_SRC_ADD type /IDXGC/S_PROC_STEP_DATA_ALL optional .
  methods GET_POD_REF
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type DATS
    returning
      value(RR_ISU_POD) type ref to ZCL_AGC_ISU_POD
    raising
      ZCX_AGC_MASTERDATA .
  methods GET_SETTLUNIT_VIA_EEDMSETTLUN
    importing
      !IV_INT_UI type INT_UI optional
    exporting
      !EV_SETTLUNIT type E_EDMSETTLUNIT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods DELETE_TEMP_EXTUI .

  methods /IDXGC/IF_DP_OUT~PROCESS_CONFIGURATION_STEPS
    redefinition .
  methods ANSWER_CATEGORY
    redefinition .
  methods CANCELLATION_DUE_DATE
    redefinition .
  methods CANCELLATION_PERIOD
    redefinition .
  methods COMMUNICATION_DEVICE_DATA_SEQ
    redefinition .
  methods COMMUNITY_DISCOUNT_PERCENTAGE
    redefinition .
  methods COMMUNITY_DISCOUNT_SEQ
    redefinition .
  methods CONFIRMED_CONTRACT_END_DATE
    redefinition .
  methods CONTROLLING_DEVICE_DATA_SEQ
    redefinition .
  methods CONTROL_AREA
    redefinition .
  methods CONVERTER_DATA_SEQ
    redefinition .
  methods CONVERTER_QUANTITY_TRANSFORMER
    redefinition .
  methods CUSTOMER_CLASSIFICATION_GROUP
    redefinition .
  methods CUSTOMER_VALUE
    redefinition .
  methods END_DATE_OF_DELIVERY
    redefinition .
  methods END_DATE_OF_SETTLEMENT
    redefinition .
  methods ENERGY_DIRECTION
    redefinition .
  methods FIRST_PERIODIC_READING
    redefinition .
  methods FRANCHISE_FEE_AMOUNT
    redefinition .
  methods FRANCHISE_FEE_ASSIGNMENT
    redefinition .
  methods FRANCHISE_FEE_GROUP
    redefinition .
  methods FRANCHISE_FEE_SEQ
    redefinition .
  methods GABI_CASE_GROUP_CLASSIFICATION
    redefinition .
  methods GET_INST_TYPE
    redefinition .
  methods GET_SETTLUNIT_VIA_POD
    redefinition .
  methods GRID_USAGE_CONTRACT_TYPE
    redefinition .
  methods INSTANTIATE
    redefinition .
  methods INVOLVED_SUPPLIER
    redefinition .
  methods LOAD_PROFILE_ASSIGNMENT
    redefinition .
  methods LOCAL_CONTROL_GROUP
    redefinition .
  methods LOSS_FACTOR
    redefinition .
  methods MABIS_TIME_SERIES_CATEGORY
    redefinition .
  methods MAXIMUM_DEMAND
    redefinition .
  methods MDS_BASIC_RESPONSIBILITY
    redefinition .
  methods MEASURED_VALUE_AQUISITION
    redefinition .
  methods METERING_DATA_SERVICE
    redefinition .
  methods METERING_DEVICE_DATA_SEQ
    redefinition .
  methods METERING_OPERATION_SERVICE
    redefinition .
  methods METERING_PROCEDURE
    redefinition .
  methods METER_NUMBER
    redefinition .
  methods METER_TYPE
    redefinition .
  methods METER_VOLUME
    redefinition .
  methods MOS_BASIC_RESPONSIBILITY
    redefinition .
  methods NEXT_POSSIBLE_DATE
    redefinition .
  methods NEXT_PROCESSING_DATE
    redefinition .
  methods NOTES_TO_TRANSACTION
    redefinition .
  methods OBIS_DATA_SEQ
    redefinition .
  methods OFF_PEAK_ENABLED
    redefinition .
  methods PARTNER_NAME
    redefinition .
  methods PAYER_GRID_USAGE
    redefinition .
  methods PAYER_OF_GRID_USAGE
    redefinition .
  methods PLANNED_PERIODIC_READING
    redefinition .
  methods PLANNED_READING_PERIOD
    redefinition .
  methods POINT_OF_DELIVERY
    redefinition .
  methods PRESSURE_LEVEL
    redefinition .
  methods RATE_NUMBER
    redefinition .
  methods REFERENCE_TO_METER
    redefinition .
  methods REFERENCE_TO_METER_DDE
    redefinition .
  methods REFERENCE_TO_METER_DEB
    redefinition .
  methods REFERENCE_TO_OBIS
    redefinition .
  methods REFERENCE_TO_REQUEST
    redefinition .
  methods REGISTER_DECIMALS_BEFORE_AFTER
    redefinition .
  methods REJECTION_REASON
    redefinition .
  methods SETTLEMENT_TERRITORY
    redefinition .
  methods SETTLEMENT_UNIT
    redefinition .
  methods SET_OF_PROFILES
    redefinition .
  methods START_DATE_BILLLING_YEAR
    redefinition .
  methods START_DATE_OF_DELIVERY
    redefinition .
  methods START_DATE_OF_SETTLEMENT
    redefinition .
  methods START_OF_DELIVERY_DATE
    redefinition .
  methods SUPPLY_DIRECTION
    redefinition .
  methods TAX_INFO
    redefinition .
  methods TAX_INFO_SEQ
    redefinition .
  methods TEMPERATUE_DEPENDENT_WORK
    redefinition .
  methods TEMPERATURE_MEASUREMENT_POINT
    redefinition .
  methods TRANSACTION_REASON
    redefinition .
  methods TRANSACTION_REASON_SECOND
    redefinition .
  methods TRANSACTION_REF_RESPONSE
    redefinition .
  methods TRANSACTION_REF_REVERSAL
    redefinition .
  methods VALID_FROM_DATE
    redefinition .
  methods VOLTAGE_LEVEL
    redefinition .
  methods VOLTAGE_LEVEL_MEASUREMENT
    redefinition .
  methods VOLUME_CORRECTOR_DATA_SEQ
    redefinition .
  methods YEARLY_CONSUMPTION
    redefinition .
  methods YEARLY_CONSUMPTION_FORECAST
    redefinition .
protected section.

  data LR_ISU_POD type ref to ZCL_AGC_ISU_POD .
  data GV_MTEXT type STRING .
  data LT_POD_TABLE type ZAGC_TT_POD .
  data SIT_METER_PROC_DETAILS type /IDXGC/T_PROFILE_DETAILS .
  data SIV_TRANSREASON type /IDXGC/DE_MSGTRANSREASON .
  data SIS_OS_DATA type ZOS_ORDERS .

  methods GET_METERING_PROCEDURE_DETAILS
    raising
      /IDXGC/CX_PROCESS_ERROR .

  methods GET_DEVICE_REGISTER_DATA
    redefinition .
  methods GET_POD_DEV_RELATION_DATA
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_AGC_DP_OUT_UTILMD_005 IMPLEMENTATION.


  METHOD /IDXGC/IF_DP_OUT~PROCESS_CONFIGURATION_STEPS.
    ">>>SCHMIDT.C 20150302 Kopie aus dem Standard mit Anpassungen für nicht regulierte Sparten (Wasser / Abwasser / Heizenergie / Warmwasser usw.)
    DATA: lt_bmid_config           TYPE         /idxgc/t_bmid_conf,
          ls_bmid_config           TYPE         /idxgc/bmid_conf,
          ls_bmid_config_group_ide TYPE         /idxgc/bmid_conf,
          lt_bmid_config_group_ide TYPE         /idxgc/t_bmid_conf,
          lt_edi_comp              TYPE         /idxgc/t_edi_comp,
          lt_exception             TYPE         abap_excpbind_tab,
          ls_exception             TYPE LINE OF abap_excpbind_tab,
          lv_mtext                 TYPE         string,
          lx_previous              TYPE REF TO  /idxgc/cx_general,
          ls_process_data_src      TYPE         /idxgc/s_proc_step_data_all,
          ls_diverse               TYPE         /idxgc/s_diverse_details.
    DATA: lv_non_proc_condition TYPE /idxgc/de_non_pro_condition.

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
      IF ls_bmid_config-data_from_source IS NOT INITIAL.
        siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_source.
      ELSEIF ls_bmid_config-data_add_source IS NOT INITIAL.
        siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source.
      ELSE.
        siv_data_processing_mode = /idxgc/if_constants_add=>gc_default_processing.
      ENDIF.

* Check wehther the field is mandatory
      siv_mandatory_data = ls_bmid_config-mandatory.

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
            AND dependent_str = ls_bmid_config-edifact_structur..
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
                  CALL METHOD me->(ls_bmid_config_group_ide-method).
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
           ( ls_bmid_config-spartyp = /idxgc/if_constants=>gc_divcat_all ) OR
           ( zcl_agc_masterdata=>is_reg_division_type( iv_division_type = gs_process_step_data-spartyp ) = abap_false ).
*   Call specific method
          TRY .
              CALL METHOD me->(ls_bmid_config-method).
            CATCH cx_sy_dyn_call_illegal_method.
              MESSAGE e060(/idxgc/process_add) INTO lv_mtext WITH ls_bmid_config-method ls_bmid_config-edifact_structur.
              CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
            CATCH /idxgc/cx_process_error INTO lx_previous.
              IF ls_bmid_config-mandatory IS NOT INITIAL AND ( zcl_agc_masterdata=>is_reg_division_type( iv_division_type = gs_process_step_data-spartyp ) = abap_true AND ">>>SCHMIDT.C Anpassung für nicht regulierte Sparten
                                                               zcl_agc_masterdata=>is_reg_process( is_process_step_data = gs_process_step_data ) = abap_true ). ">>>SCHMIDT.C Anpassung für kundeneigene Prozesse (Bsp.: Stilllegung)
                CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
              ELSE.
                DELETE lt_bmid_config WHERE dependent_str = ls_bmid_config-edifact_structur.
                CONTINUE.
              ENDIF.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD answer_category.
    ">>>SCHMIDT.C 20150107 Der Antwortstaus wird aus dem Workflow übergeben

  ENDMETHOD.


  METHOD CANCELLATION_DUE_DATE.
    DATA: ls_diverse     TYPE /idxgc/s_diverse_details,
          lv_possenddate TYPE dats,
          lv_anlage      TYPE anlage.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ec102.
      TRY.
          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            IF <fs_diverse>-noticeper+3(1) = 'T'.

              IF <fs_diverse>-validstart_date IS NOT INITIAL. "Ggf. schon in VALID_START_DATE schon gefüllt
                lv_possenddate = <fs_diverse>-validstart_date.
              ELSE.

                me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).
                lv_anlage = lr_isu_pod->get_anlage( ).

                CALL FUNCTION 'Z_LW_CHECK_CONTRACTDURATION'
                  EXPORTING
                    i_anlage                = lv_anlage
                    i_auszdat               = sy-datum
                  IMPORTING
                    e_possend               = lv_possenddate
                  EXCEPTIONS
                    user_decision_necessary = 1.

              ENDIF.

              CASE strlen( lv_possenddate ).
                WHEN 8.
                  <fs_diverse>-notper_keydate = lv_possenddate.
                WHEN OTHERS.
                  <fs_diverse>-notper_keyday = lv_possenddate.
              ENDCASE.

            ENDIF.
          ENDIF.
        CATCH zcx_agc_masterdata.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD CANCELLATION_PERIOD.
    DATA:    BEGIN OF cnt,
               days   TYPE tfmatage,
               months TYPE tfmatage,
               years  TYPE tfmatage,
             END OF cnt.

    DATA: ls_diverse          TYPE /idxgc/s_diverse_details,
          lv_possenddate      TYPE dats,
          ls_ever             TYPE ever,
          ls_v_eanl           TYPE v_eanl,
          lv_kuendfrist       TYPE char35,
          lv_zz               TYPE char2,
          ls_zlw_contract_sws TYPE zlw_contract_kd.

    FIELD-SYMBOLS: <fs_diverse>     TYPE /idxgc/s_diverse_details,
                   <fs_respstatus> TYPE /idxgc/s_msgsts_details.

    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ec102.

      TRY.
          LOOP AT gs_process_step_data-msgrespstatus ASSIGNING <fs_respstatus>
            WHERE respstatus = /idxgc/if_constants_ide=>gc_respstatus_z12.

            READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
            IF <fs_diverse> IS ASSIGNED.

              me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

              ls_ever = lr_isu_pod->get_ever( ).
              ls_v_eanl = lr_isu_pod->get_v_eanl( ).

              IF ls_ever-zzskuenddat IS NOT INITIAL AND ls_v_eanl-aklasse <> 'S'.
                lv_kuendfrist = '00TT'.
              ELSEIF ls_ever-kuenddat IS NOT INITIAL AND ls_ever-vende IS NOT INITIAL.
                CALL FUNCTION 'FIMA_DAYS_AND_MONTHS_AND_YEARS'
                  EXPORTING
                    i_date_from = ls_ever-kuenddat
                    i_date_to   = ls_ever-vende
                  IMPORTING
                    e_days      = cnt-days
                    e_months    = cnt-months
                    e_years     = cnt-years.

                IF cnt-days > 99.
                  IF cnt-months < 10.
                    MOVE cnt-months TO lv_zz.
                    CONCATENATE '0' lv_zz INTO lv_kuendfrist+0(2).
                  ELSE.
                    lv_kuendfrist+0(2) = cnt-months.
                  ENDIF.
                  lv_kuendfrist+2(1) = 'M'.
                ELSE.
                  IF cnt-days < 10.
                    MOVE cnt-days TO lv_zz.
                    CONCATENATE '0' lv_zz INTO lv_kuendfrist+0(2).
                  ELSE.
                    lv_kuendfrist+0(2) = cnt-days.
                  ENDIF.
                  lv_kuendfrist+2(1) = 'T'.
                ENDIF.

                lv_kuendfrist+3(1) = 'T'.
              ELSE.
                CALL FUNCTION 'Z_ZEBI_TARIFTYPMERKMALE'
                  EXPORTING
                    iv_tariftyp      = ls_v_eanl-tariftyp
                    iv_termine_lesen = abap_true
                  IMPORTING
                    es_contract_kd   = ls_zlw_contract_sws
                  EXCEPTIONS
                    OTHERS           = 3.
                IF sy-subrc <> 0.
                  CLEAR ls_zlw_contract_sws.
                ENDIF.

                CASE ls_zlw_contract_sws-kuenper.
                  WHEN '0'.
                    lv_kuendfrist+2(1) = 'T'.
                  WHEN '3'.
                    lv_kuendfrist+2(1) = 'W'.
                  WHEN '1'.
                    lv_kuendfrist+2(1) = 'M'.
                  WHEN OTHERS.
                    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
                ENDCASE.

                lv_kuendfrist+0(2) = ls_zlw_contract_sws-kfrist+1(2).
                lv_kuendfrist+3(1) = 'T'.
              ENDIF.

              READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
              IF <fs_diverse> IS ASSIGNED.
                <fs_diverse>-noticeper = lv_kuendfrist.
              ELSE.
                ls_diverse-item_id = siv_itemid.
                ls_diverse-noticeper = lv_kuendfrist.
                APPEND ls_diverse TO gs_process_step_data-diverse.
              ENDIF.
            ELSE.
              /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
            ENDIF.
          ENDLOOP.
        CATCH zcx_agc_masterdata /idxgc/cx_process_error.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDTRY.
    ENDIF.


  ENDMETHOD.


  METHOD COMMUNICATION_DEVICE_DATA_SEQ.
    ">>>SCHMIDT.C 20150203 Quellschritte lesen
    DATA: ls_non_meter_dev_src TYPE /idxgc/s_nonmeter_details.

    FIELD-SYMBOLS: <fs_non_meter_dev> TYPE /idxgc/s_nonmeter_details.

    "Bei EoG Bestätigungen immer die Quelldaten zurücksenden
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      LOOP AT gs_process_data_src-non_meter_dev INTO ls_non_meter_dev_src
        WHERE device_qual   = /idxgc/if_constants_ide=>gc_seq_action_code_z05.
        ls_non_meter_dev_src-item_id = siv_itemid.

        READ TABLE gs_process_step_data-non_meter_dev ASSIGNING <fs_non_meter_dev>
          WITH KEY item_id = siv_itemid
                   device_qual   = /idxgc/if_constants_ide=>gc_seq_action_code_z05
                   meternumber   = ls_non_meter_dev_src-meternumber
                   device_number = ls_non_meter_dev_src-device_number.
        IF sy-subrc = 0.
          <fs_non_meter_dev> = ls_non_meter_dev_src.
        ELSE.
          APPEND ls_non_meter_dev_src TO gs_process_step_data-non_meter_dev.
        ENDIF.
      ENDLOOP.
    ELSE.

      CALL METHOD super->communication_device_data_seq.

    ENDIF.
  ENDMETHOD.


  METHOD COMMUNITY_DISCOUNT_PERCENTAGE.
*----------------------------------------------------------------------*
*>>>SCHMIDT.C 20150220 Kundeneigene Implementierung der Ermittlung des Gemeinderabatts
*----------------------------------------------------------------------*

    DATA: ls_diverse_src     TYPE /idxgc/s_diverse_details,
          ls_diverse         TYPE /idxgc/s_diverse_details,
          lv_msgtext         TYPE string,
          lv_community_dscnt TYPE /idxgc/de_community_discnt,
          lv_value           TYPE dec_16_10_s.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    CHECK siv_context_rff_ave = /idxgc/if_constants_ide=>gc_seq_action_code_z12.

    "Quellschrittdaten lesen
    IF siv_data_from_source = /idxgc/if_constants=>gc_true.
      READ TABLE gs_process_data_src-diverse INTO ls_diverse_src WITH KEY item_id = siv_itemid.
      IF ls_diverse_src-community_dscnt IS NOT INITIAL.
        lv_community_dscnt = ls_diverse_src-community_dscnt.
      ENDIF.
    ENDIF.

    IF lv_community_dscnt IS INITIAL.
      TRY.
          me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

          lv_community_dscnt = lr_isu_pod->get_com_disc_perc( ).

        CATCH zcx_agc_masterdata.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDTRY.
    ENDIF.

    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
    IF <fs_diverse> IS ASSIGNED.
      WRITE lv_community_dscnt TO <fs_diverse>-community_dscnt NO-GROUPING LEFT-JUSTIFIED DECIMALS 2.
      SHIFT <fs_diverse>-community_dscnt LEFT DELETING LEADING space.
    ELSE.
      WRITE lv_community_dscnt TO ls_diverse-community_dscnt NO-GROUPING LEFT-JUSTIFIED DECIMALS 2.
      SHIFT <fs_diverse>-community_dscnt LEFT DELETING LEADING space.
      ls_diverse-item_id = siv_itemid.
      APPEND ls_diverse TO gs_process_step_data-diverse.
    ENDIF.

* Check whether the field is required, otherwise raise exception for the missing field.
    READ TABLE gs_process_step_data-diverse INTO ls_diverse INDEX siv_itemid.
    IF siv_mandatory_data IS NOT INITIAL AND ls_diverse-community_dscnt IS INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH text-501 INTO lv_msgtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD COMMUNITY_DISCOUNT_SEQ.
*----------------------------------------------------------------------*
*Kopie aus /idexge/cl_dp_out_utilmd_005
*----------------------------------------------------------------------*

    DATA: ls_diverse TYPE /idxgc/s_diverse_details.

    CLEAR: siv_context_rff_ave.

* In case of ES101, ES103, EB103 and CD013, community discount is requird
* if payer of grid usage is 'E10'.
* In case of EB101, community discount is required at any case.
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb101.
      siv_context_rff_ave = /idxgc/if_constants_ide=>gc_seq_action_code_z12.
      RETURN.
    ENDIF.

    READ TABLE gs_process_data_src-diverse INTO ls_diverse
           WITH KEY item_id = siv_itemid.
    IF sy-subrc = 0.
      IF ls_diverse-gridus_contrpay = /idxgc/if_constants_add=>gc_energy_grant_e10.
        siv_context_rff_ave = /idxgc/if_constants_ide=>gc_seq_action_code_z12.
      ENDIF.
    ENDIF.

    IF siv_context_rff_ave <> /idxgc/if_constants_ide=>gc_seq_action_code_z12.
      CLEAR: ls_diverse.
      READ TABLE gs_process_step_data-diverse INTO ls_diverse
           WITH KEY item_id = siv_itemid.
      IF ls_diverse-gridus_contrpay = /idxgc/if_constants_add=>gc_energy_grant_e10.
        siv_context_rff_ave = /idxgc/if_constants_ide=>gc_seq_action_code_z12.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD confirmed_contract_end_date.
    ">>>SCHMIDT.C 20150121 Wird aus bestehenden Prozessen abgeleitet
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: sg4_dtm_z05_z06

    DATA: lt_eideswtmsgdata TYPE          teideswtmsgdata,
          lt_category       TYPE TABLE OF eideswtmdcat,
          lt_direction      TYPE TABLE OF direction,
          lt_transreason    TYPE TABLE OF eideswtmdtran,
          lt_msgstatus      TYPE TABLE OF eideswtmdstatus,
          lt_moveoutdate    TYPE TABLE OF dats,
          lt_ext_ui         TYPE TABLE OF ext_ui,
          ls_diverse        TYPE          /idxgc/s_diverse_details.

    FIELD-SYMBOLS: <fs_eideswtmsgdata> TYPE eideswtmsgdata,
                   <fs_diverse>        TYPE /idxgc/s_diverse_details.

    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.

    IF <fs_diverse> IS ASSIGNED.
      LOOP AT gs_process_step_data-msgrespstatus TRANSPORTING NO FIELDS WHERE respstatus = /idxgc/if_constants_ide=>gc_respstatus_z34 OR
                                                                              respstatus = /idxgc/if_constants_ide=>gc_respstatus_z12.
      ENDLOOP.
      IF sy-subrc = 0.

        APPEND /idxgc/if_constants_ide=>gc_msg_category_e35 TO lt_category.
        APPEND /idxgc/if_constants_add=>gc_idoc_direction_outbound TO lt_direction.
        APPEND /idxgc/if_constants_ide=>gc_trans_reason_code_e03 TO lt_transreason.
        APPEND /idxgc/if_constants_ide=>gc_respstatus_e15 TO lt_msgstatus.
        APPEND /idxgc/if_constants_ide=>gc_respstatus_z01 TO lt_msgstatus.
        APPEND /idxgc/if_constants_ide=>gc_respstatus_z43 TO lt_msgstatus.
        APPEND /idxgc/if_constants_ide=>gc_respstatus_z44 TO lt_msgstatus.
        APPEND gs_process_step_data-proc_date TO lt_moveoutdate.
        APPEND gs_process_step_data-ext_ui TO lt_ext_ui.

        TRY.

            lt_eideswtmsgdata = zcl_agc_datex_utility=>search_msgdata_by_param( it_category = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_category )
                                                                                it_direction = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_direction )
                                                                                it_transreason = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_transreason )
                                                                                it_msgstatus = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_msgstatus )
                                                                                it_moveoutdate = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_moveoutdate )
                                                                                it_ext_ui =  /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_ext_ui ) ).

          CATCH /idxgc/cx_utility_error .
        ENDTRY.

        IF lines( lt_eideswtmsgdata ) <> 0. "E35 Nachricht gefunden
          SORT lt_eideswtmsgdata BY msgdate DESCENDING msgtime DESCENDING.
          READ TABLE lt_eideswtmsgdata ASSIGNING <fs_eideswtmsgdata> INDEX 1.

          IF <fs_eideswtmsgdata> IS ASSIGNED.
            <fs_diverse>-confcancdat_supp = <fs_eideswtmsgdata>-moveoutdate.
          ENDIF.

        ELSE. "Suche nach einer Abmeldung
          CLEAR lt_category.
          APPEND /idxgc/if_constants_ide=>gc_msg_category_e02 TO lt_category.

          TRY.
              lt_eideswtmsgdata = zcl_agc_datex_utility=>search_msgdata_by_param( it_category = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_category )
                                                                                  it_direction = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_direction )
                                                                                  it_transreason = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_transreason )
                                                                                  it_moveoutdate = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_moveoutdate )
                                                                                  it_ext_ui =  /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( it_table = lt_ext_ui ) ).
            CATCH /idxgc/cx_utility_error .
          ENDTRY.

          SORT lt_eideswtmsgdata BY msgdate DESCENDING msgtime DESCENDING.
          READ TABLE lt_eideswtmsgdata ASSIGNING <fs_eideswtmsgdata> INDEX 1.

          IF <fs_eideswtmsgdata> IS ASSIGNED.
            <fs_diverse>-confcancdat_cust = <fs_eideswtmsgdata>-moveoutdate.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD CONSTRUCTOR.

    DATA: ls_pod_table LIKE LINE OF lt_pod_table.

    CALL METHOD super->constructor
      EXPORTING
        is_process_data_src     = is_process_data_src
        is_process_data_src_add = is_process_data_src_add.

    TRY.
        CREATE OBJECT me->lr_isu_pod
          EXPORTING
            iv_int_ui           = is_process_data_src-int_ui
            iv_keydate          = is_process_data_src-proc_date
            iv_process_all_data = abap_false. "Nicht alle Daten prozessieren, da ich nicht alle Daten immer für jede Nachricht benötige. Dies würde nur zu unnötigen Fehlern führen!

        ls_pod_table-int_ui = is_process_data_src-int_ui.
        ls_pod_table-ext_ui = is_process_data_src-ext_ui.
        ls_pod_table-pod_ref = lr_isu_pod.
        APPEND ls_pod_table TO lt_pod_table.

      CATCH zcx_agc_masterdata .
    ENDTRY.

  ENDMETHOD.


  METHOD CONTROLLING_DEVICE_DATA_SEQ.
    ">>>SCHMIDT.C 20150203 Quellschritte lesen
    DATA: ls_non_meter_dev_src TYPE /idxgc/s_nonmeter_details.

    FIELD-SYMBOLS: <fs_non_meter_dev> TYPE /idxgc/s_nonmeter_details.

    "Bei EoG Bestätigungen immer die Quelldaten zurücksenden
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      LOOP AT gs_process_data_src-non_meter_dev INTO ls_non_meter_dev_src
        WHERE device_qual   = /idxgc/if_constants_ide=>gc_seq_action_code_z06.
        ls_non_meter_dev_src-item_id = siv_itemid.

        READ TABLE gs_process_step_data-non_meter_dev ASSIGNING <fs_non_meter_dev>
          WITH KEY item_id = siv_itemid
                   device_qual   = /idxgc/if_constants_ide=>gc_seq_action_code_z06
                   meternumber   = ls_non_meter_dev_src-meternumber
                   device_number = ls_non_meter_dev_src-device_number.
        IF sy-subrc = 0.
          <fs_non_meter_dev> = ls_non_meter_dev_src.
        ELSE.
          APPEND ls_non_meter_dev_src TO gs_process_step_data-non_meter_dev.
        ENDIF.
      ENDLOOP.
    ELSE.

      CALL METHOD super->controlling_device_data_seq.

    ENDIF.
  ENDMETHOD.


  METHOD CONTROL_AREA.
    ">>>SCHMIDT.C 20150127 Regelzone immer auf einen Defaultwert setzen
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_regelzone

    DATA: ls_diverse        TYPE /idxgc/s_diverse_details,
          lv_contrlarea_ext TYPE /idxgc/de_contrlarea_ext.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-contrlarea_ext IS NOT INITIAL.
        lv_contrlarea_ext = ls_diverse-contrlarea_ext.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.

          IF lv_contrlarea_ext IS INITIAL.
            lv_contrlarea_ext = '10YDE-RWENET---I'.
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-contrlarea_ext = lv_contrlarea_ext.
            <fs_diverse>-contrarea_cla  = /idxgc/if_constants_ide=>gc_codelist_agency_305.
          ELSE.
            ls_diverse-item_id        = siv_itemid.
            ls_diverse-contrlarea_ext = lv_contrlarea_ext.
            ls_diverse-contrarea_cla  = /idxgc/if_constants_ide=>gc_codelist_agency_305.
            APPEND ls_diverse TO gs_process_step_data-diverse.
          ENDIF.

        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD CONVERTER_DATA_SEQ.
    ">>>SCHMIDT.C 20150203 Quellschritte lesen
    DATA: ls_non_meter_dev_src TYPE /idxgc/s_nonmeter_details.

    FIELD-SYMBOLS: <fs_non_meter_dev> TYPE /idxgc/s_nonmeter_details.

    "Bei EoG Bestätigungen immer die Quelldaten zurücksenden
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      LOOP AT gs_process_data_src-non_meter_dev INTO ls_non_meter_dev_src
        WHERE device_qual   = /idxgc/if_constants_ide=>gc_seq_action_code_z04.
        ls_non_meter_dev_src-item_id = siv_itemid.

        READ TABLE gs_process_step_data-non_meter_dev ASSIGNING <fs_non_meter_dev>
          WITH KEY item_id = siv_itemid
                   device_qual   = /idxgc/if_constants_ide=>gc_seq_action_code_z04
                   meternumber   = ls_non_meter_dev_src-meternumber
                   device_number = ls_non_meter_dev_src-device_number.
        IF sy-subrc = 0.
          <fs_non_meter_dev> = ls_non_meter_dev_src.
        ELSE.
          APPEND ls_non_meter_dev_src TO gs_process_step_data-non_meter_dev.
        ENDIF.
      ENDLOOP.
    ELSE.

      CALL METHOD super->converter_data_seq.

    ENDIF.
  ENDMETHOD.


  METHOD CONVERTER_QUANTITY_TRANSFORMER.
    ">>>SCHMIDT.C 20150204 Wandlerfaktor wird immer neu aus der Wicklungsgruppe berechnet
    DATA: ls_pod_dev_relation TYPE          /idxgc/s_pod_dev_relation,
          ls_device_data      TYPE          /idxgc/s_device_data,
          ls_non_meter_device TYPE          /idxgc/s_nonmeter_details,
          ls_dev_meter        TYPE          /idxgc/s_device_data,
          ls_dev_transformer  TYPE          /idxgc/s_device_data,
          ls_ezuz             TYPE          ezuz,
          ls_etdz             TYPE          etdz,
          lv_con_fact         TYPE          /idexge/e_conv_factor,
          ls_etyp             TYPE          etyp,
          lv_mtext            TYPE          string,
          lt_ewik             TYPE TABLE OF ewik,
          lv_wgruppe          TYPE          wgruppe,
          lv_wspannp          TYPE          ewik-wspann VALUE 1,
          lv_wspanns          TYPE          ewik-wspann VALUE 1,
          lv_wstromp          TYPE          ewik-wstrom VALUE 1,
          lv_wstroms          TYPE          ewik-wstrom VALUE 1.

    FIELD-SYMBOLS: <fs_non_meter_dev> TYPE         /idxgc/s_nonmeter_details,
                   <fs_ewik>          LIKE LINE OF lt_ewik.

    "Bei Antwort auf EoG werden die Wandlerdaten bereits aus dem Quellschritt in der Sequenzgruppe Z04 gefüllt
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      RETURN.
    ENDIF.

    LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.

      IF ls_pod_dev_relation-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
        CONTINUE.
      ENDIF.

      LOOP AT ls_pod_dev_relation-device_data INTO ls_dev_transformer
              WHERE metertype = /idexge/if_constants_dp=>gc_cci_trans_conv.

        ls_non_meter_device-item_id = siv_itemid.
        ls_non_meter_device-device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z04.
        ls_non_meter_device-device_number = ls_dev_transformer-geraet.
        ls_non_meter_device-transform_type = ls_dev_transformer-metertype_code.

        "----------------------------------------------------------
        "Wandlerfaktor immer neu aus der Wicklungsgruppe ermitteln
        "----------------------------------------------------------
        IF lv_con_fact IS INITIAL AND ls_dev_transformer-metertype_code <> 'MUW'.
          "1. Schritt Wicklungsgruppe bestimmen
          SELECT SINGLE wgruppe FROM etyp INTO lv_wgruppe WHERE matnr = ls_dev_transformer-matnr.

          CALL FUNCTION 'ISU_DB_EWIK_SELECT_ALL'
            EXPORTING
              x_wgruppe     = lv_wgruppe
            TABLES
              t_ewik        = lt_ewik
            EXCEPTIONS
              not_found     = 1
              system_error  = 2
              not_qualified = 3
              OTHERS        = 4.
          IF sy-subrc <> 0.
          ENDIF.

          LOOP AT lt_ewik ASSIGNING <fs_ewik>.
            IF <fs_ewik>-wtyp = '1'. "Primärwicklung
              IF <fs_ewik>-wstrom IS NOT INITIAL.
                lv_wstromp = <fs_ewik>-wstrom.
              ENDIF.
              IF <fs_ewik>-wspann IS NOT INITIAL.
                lv_wspannp = <fs_ewik>-wspann.
              ENDIF.
            ELSEIF <fs_ewik>-wtyp = '2'. "Sekundärwicklung
              IF <fs_ewik>-wstrom IS NOT INITIAL.
                lv_wstroms = <fs_ewik>-wstrom.
              ENDIF.
              IF <fs_ewik>-wspann IS NOT INITIAL.
                lv_wspanns = <fs_ewik>-wspann.
              ENDIF.
            ENDIF.
          ENDLOOP.

          "2. Schritt Wandlerfaktor berechnen
          lv_con_fact = ( lv_wstromp * lv_wspannp ) / ( lv_wstroms * lv_wspanns ).
          SHIFT lv_con_fact LEFT DELETING LEADING space.
        ELSEIF ls_dev_transformer-metertype_code = 'MUW'.
          CLEAR: lv_con_fact.
        ENDIF.

        ls_non_meter_device-transform_const = lv_con_fact.


        LOOP AT ls_pod_dev_relation-device_data INTO ls_dev_meter
              WHERE metertype = /idexge/if_constants_dp=>gc_cci_meter_type.
          ls_non_meter_device-meternumber = ls_dev_meter-geraet.

          READ TABLE gs_process_step_data-non_meter_dev ASSIGNING <fs_non_meter_dev>
                WITH KEY item_id = siv_itemid
                         device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z04
                         meternumber = ls_dev_meter-geraet
                         device_number = ls_dev_transformer-geraet.
          IF sy-subrc <> 0.
            APPEND ls_non_meter_device TO gs_process_step_data-non_meter_dev.
          ELSE.
            <fs_non_meter_dev>-transform_type = ls_non_meter_device-transform_type.
            <fs_non_meter_dev>-transform_const = ls_non_meter_device-transform_const.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD CUSTOMER_CLASSIFICATION_GROUP.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF05
    "Form: hole_ist_hhk_vnb_gue
    DATA: ls_diverse          TYPE /idxgc/s_diverse_details,
          lv_group_alloc_enwg TYPE /idxgc/de_group_alloc_enwg.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-group_alloc_enwg IS NOT INITIAL.
        lv_group_alloc_enwg = ls_diverse-group_alloc_enwg.
      ENDIF.
    ENDIF.

    IF lv_group_alloc_enwg IS INITIAL.
      TRY.
          me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

          READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
          IF lr_isu_pod->get_metmethod( ) = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_e01 AND "Bei Neuanlage RLM immer Z18 (M4466, M4876)
             ls_diverse-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z37.
            lv_group_alloc_enwg = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_z18.
          ELSE.
            IF lv_group_alloc_enwg IS INITIAL.
              IF lr_isu_pod->get_kz_hhk( ) = abap_true.
                lv_group_alloc_enwg = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_z15.
              ELSE.
                lv_group_alloc_enwg = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_z18.
              ENDIF.
            ENDIF.
          ENDIF.
        CATCH zcx_agc_masterdata.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDTRY.
    ENDIF.

    IF lv_group_alloc_enwg IS NOT INITIAL.
      READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
      IF <fs_diverse> IS ASSIGNED.
        <fs_diverse>-group_alloc_enwg = lv_group_alloc_enwg.
      ELSE.
        CLEAR: ls_diverse.
        ls_diverse-item_id = siv_itemid.
        ls_diverse-group_alloc_enwg = lv_group_alloc_enwg.
        APPEND ls_diverse TO gs_process_step_data-diverse.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD CUSTOMER_VALUE.
    ">>>SCHMIDT.C 20150107
    "Klasse: ZCL_EDM_UTILITY
    "Methode: GET_CUSTOMER_VALUE_ANLAGE

    DATA: ls_pod_quant      TYPE /idxgc/s_pod_quant_details,
          lv_customer_value TYPE /idxgc/de_quantitiy_ext,
          ls_diverse        TYPE /idxgc/s_diverse_details,
          lt_ettifn         TYPE iettifn,
          lv_progyearcons   TYPE eideswtmdprogyearcons.

    FIELD-SYMBOLS: <fs_pod_quant> TYPE /idxgc/s_pod_quant_details,
                   <fs_ettifn>    TYPE ettifn.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       ( gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103 AND
       ( siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z37 OR siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z38 ) ).

      READ TABLE gs_process_data_src-pod_quant INTO ls_pod_quant WITH KEY item_id = siv_itemid
                                                                          ext_ui = gs_process_step_data-ext_ui
                                                                          quant_type_qual = /idexge/if_constants_dp=>gc_qty_y02.
      IF ls_pod_quant-quantitiy_ext IS NOT INITIAL.
        lv_customer_value = ls_pod_quant-quantitiy_ext.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        READ TABLE gs_process_step_data-pod_quant INTO ls_pod_quant WITH KEY item_id = siv_itemid
                                                                            ext_ui = gs_process_step_data-ext_ui
                                                                            quant_type_qual = /idexge/if_constants_dp=>gc_qty_31.

        lv_progyearcons = ls_pod_quant-quantitiy_ext.

        CASE gs_process_step_data-bmid.
          WHEN zif_agc_datex_utilmd_co=>gc_bmid_zmd01 OR
               zif_agc_datex_utilmd_co=>gc_bmid_zmd11.                          "Stammdatenänderung (Mantis 4578)
            READ TABLE gs_process_step_data-diverse INTO ls_diverse INDEX 1.

            IF ls_diverse-prof_code_sy IS NOT INITIAL OR ls_diverse-prof_code_an IS NOT INITIAL OR ls_pod_quant-quantitiy_ext IS NOT INITIAL.
              IF  zcl_messagedata=>utilmd_bedingung8( gs_process_step_data-int_ui ) = abap_true
              AND lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02
              AND lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas
              AND zcl_agc_masterdata=>is_netz( ) = abap_true.

                IF lv_customer_value IS INITIAL.
                  lv_customer_value = lr_isu_pod->get_customer_value( iv_progyearcons = lv_progyearcons ).
                ENDIF.

                READ TABLE gs_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WITH KEY item_id = siv_itemid
                                                                                            ext_ui = gs_process_step_data-ext_ui
                                                                                            quant_type_qual = /idexge/if_constants_dp=>gc_qty_y02.

                IF <fs_pod_quant> IS ASSIGNED.
                  <fs_pod_quant>-quantitiy_ext = lv_customer_value.
                  <fs_pod_quant>-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
                ELSE.
                  ls_pod_quant-item_id = siv_itemid.
                  ls_pod_quant-quantitiy_ext = lv_customer_value.
                  IF zcl_agc_datex_utility=>check_dummy_pod( iv_ext_ui = gs_process_step_data-ext_ui ) = abap_false.
                    ls_pod_quant-ext_ui = gs_process_step_data-ext_ui.
                  ENDIF.
                  ls_pod_quant-quant_type_qual = /idexge/if_constants_dp=>gc_qty_y02.
                  ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
                  APPEND ls_pod_quant TO gs_process_step_data-pod_quant.
                ENDIF.
              ENDIF.
            ENDIF.

          WHEN OTHERS.
            IF lr_isu_pod->get_metmethod( ) <> /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01 AND
               lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.

              IF lv_customer_value IS INITIAL.
                IF zcl_agc_masterdata=>is_netz( ) = abap_true.
                  lv_customer_value = lr_isu_pod->get_customer_value( iv_progyearcons = lv_progyearcons ).
                ELSE.
                  lt_ettifn = zcl_edm_utility=>get_instln_facts_cv( iv_anlage = lr_isu_pod->get_anlage( ) ).
                  LOOP AT lt_ettifn ASSIGNING <fs_ettifn> WHERE ab <= gs_process_step_data-proc_date AND bis >= gs_process_step_data-proc_date.
                    lv_customer_value = <fs_ettifn>-wert1.
                  ENDLOOP.
                ENDIF.
              ENDIF.

              READ TABLE gs_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WITH KEY item_id = siv_itemid
                                                                                          ext_ui = gs_process_step_data-ext_ui
                                                                                          quant_type_qual = /idexge/if_constants_dp=>gc_qty_y02.

              IF <fs_pod_quant> IS ASSIGNED.
                <fs_pod_quant>-quantitiy_ext = round( val = lv_customer_value dec = 4 mode = cl_abap_math=>round_half_even ).
                <fs_pod_quant>-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
              ELSE.
                ls_pod_quant-item_id = siv_itemid.
                ls_pod_quant-quantitiy_ext = round( val = lv_customer_value dec = 4 mode = cl_abap_math=>round_half_even ).
                IF zcl_agc_datex_utility=>check_dummy_pod( iv_ext_ui = gs_process_step_data-ext_ui ) = abap_false.
                ls_pod_quant-ext_ui = gs_process_step_data-ext_ui.
                endif.
                ls_pod_quant-quant_type_qual = /idexge/if_constants_dp=>gc_qty_y02.
                ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
                APPEND ls_pod_quant TO gs_process_step_data-pod_quant.
              ENDIF.
            ENDIF.
        ENDCASE.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.


  ENDMETHOD.


  METHOD DELETE_TEMP_EXTUI.
    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

* Sonderbehandlung für den LN:
* temporäre ZP-Bez. dürfen nicht kommuniziert werden.
    IF gs_process_step_data-proc_view = zif_agc_datex_utilmd_co=>gc_proc_view_02.
      LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod>.
        IF zcl_agc_datex_utility=>check_dummy_pod( iv_ext_ui = <fs_pod>-ext_ui ) = abap_true.
          DELETE gs_process_step_data-pod.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD END_DATE_OF_DELIVERY.
    ">>>SCHMIDT.C 20150107 Wird vom Workflow gesetzt und im Mapping gefüllt. Kann ggf. hier noch einmal überarbeitet werden
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: movein_moveout_date
    DATA: ls_diverse_src TYPE /idxgc/s_diverse_details,
          lv_date        TYPE dats.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    CASE gs_process_step_data-bmid.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ec101.
        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
        IF <fs_diverse> IS ASSIGNED.
          IF <fs_diverse>-endnextposs_from IS NOT INITIAL.
            CLEAR <fs_diverse>-contr_end_date.
            CLEAR <fs_diverse>-contr_start_date.
          ELSE.
            IF <fs_diverse>-contr_end_date IS INITIAL.
              lv_date = <fs_diverse>-contr_start_date.
              CALL FUNCTION 'ISU_DATE_MODIFIKATION'
                EXPORTING
                  m_art       = abap_true
                  day         = 1
                CHANGING
                  date        = lv_date
                EXCEPTIONS
                  check_error = 1
                  OTHERS      = 2.
              IF sy-subrc <> 0.
              ENDIF.
              <fs_diverse>-contr_end_date = lv_date.
              CLEAR <fs_diverse>-contr_start_date.
            ENDIF.
          ENDIF.
        ENDIF.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ec103.
        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
        IF <fs_diverse> IS ASSIGNED.
          READ TABLE gs_process_data_src-diverse INTO ls_diverse_src INDEX 1.
          IF ls_diverse_src-contr_end_date IS NOT INITIAL.
            <fs_diverse>-contr_end_date = ls_diverse_src-contr_end_date.
            CLEAR <fs_diverse>-endnextposs_from.
          ELSE.
            CLEAR <fs_diverse>-contr_end_date.
          ENDIF.
        ENDIF.
* >>> Wolf.A., 12.03.2015: auskommentiert, da der Zeiger bei ELSE-Klausel nicht zugewiesen ist. Neue Logik oben.
* Sollte gelöscht werden, nachdem die Tests positiv abgeschlossen werden.

*        READ TABLE gs_process_data_src-diverse INTO ls_diverse_src INDEX 1.
*        IF ls_diverse_src-contr_end_date IS NOT INITIAL.
*          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
*          IF <fs_diverse> IS ASSIGNED.
*            <fs_diverse>-contr_end_date = ls_diverse_src-contr_end_date.
*            CLEAR <fs_diverse>-endnextposs_from.
*          ENDIF.
*        ELSE.
*          CLEAR <fs_diverse>-contr_end_date.
*        ENDIF.
* <<<
      WHEN /idxgc/if_constants_ide=>gc_bmid_es301. "Bei Abmeldeanfragen werden die Daten der ursprünglichen Anmeldung des neuen Lieferanten als Grundlage genommen. Daher muss das DTM+93 Datum errechnet werden
        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
        IF <fs_diverse> IS ASSIGNED.
          IF <fs_diverse>-contr_end_date IS INITIAL AND <fs_diverse>-contr_start_date IS NOT INITIAL.
            <fs_diverse>-contr_end_date = <fs_diverse>-contr_start_date - 1.
          ENDIF.
          CLEAR <fs_diverse>-contr_start_date.
        ENDIF.
    ENDCASE.


  ENDMETHOD.


  METHOD END_DATE_OF_SETTLEMENT.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_bilanz_beg_ende

    DATA: lv_mtext                  TYPE string,
          ls_diverse                TYPE /idxgc/s_diverse_details,
          lv_end_date_of_settlement TYPE /idxgc/de_endsettldate.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-endsettldate IS NOT INITIAL.
        lv_end_date_of_settlement = ls_diverse-endsettldate.
      ENDIF.
    ENDIF.

    TRY.

        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.

        IF <fs_diverse> IS ASSIGNED.
          IF lv_end_date_of_settlement IS INITIAL AND <fs_diverse>-contr_end_date IS NOT INITIAL.
            me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

            IF me->lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.
              <fs_diverse>-endsettldate = <fs_diverse>-contr_end_date.
            ELSEIF me->lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02 OR
                   me->lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14.
              CALL FUNCTION 'Z_LW_SETTLUNIT_FRISTEN'
                EXPORTING
                  i_refdate  = sy-datum
                  i_kalender = zif_agc_datex_utilmd_co=>gc_fabrikkalender_de_stand
                  i_auszdat  = <fs_diverse>-contr_end_date
                IMPORTING
                  e_settlend = <fs_diverse>-endsettldate.
            ELSE.
              <fs_diverse>-endsettldate = <fs_diverse>-contr_end_date.
            ENDIF.
          ELSE.
            <fs_diverse>-endsettldate = lv_end_date_of_settlement.
          ENDIF.
          <fs_diverse>-endsettlform = /idxgc/if_constants_ide=>gc_dtm_format_code_102.

        ELSE.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.

      CATCH zcx_agc_masterdata.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

*>>> THIMEL.R 20150322 Bilanzierungsbeginn und -ende nur übermitteln wenn Bilanzierung stattfindet.
    IF <fs_diverse>-startsettldate is not INITIAL and <fs_diverse>-endsettldate is not INITIAL AND
       <fs_diverse>-startsettldate > <fs_diverse>-endsettldate.
      clear: <fs_diverse>-startsettldate, <fs_diverse>-startsettlform, <fs_diverse>-endsettldate, <fs_diverse>-endsettlform.
    endif.
*<<< THIMEL.R 20150322


  ENDMETHOD.


  METHOD ENERGY_DIRECTION.
    ">>>SCHMIDT.C 20150203 Antwort auf EoG schon in der Sequenzgruppe SEQ Z03 gefüllt
    IF gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb103.
      super->energy_direction( ).
    ENDIF.
  ENDMETHOD.


  METHOD FIRST_PERIODIC_READING.

    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_next_abl

    DATA: lv_adatsoll          TYPE dats,
          lv_abdatum           TYPE dats,
          lv_bisdatum          TYPE dats,
          lv_stelle            TYPE i,
          lv_planned_perio_red TYPE dats,
          lv_mtext             TYPE string,
          ls_diverse           TYPE /idxgc/s_diverse_details.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-initmr_year IS NOT INITIAL.
        lv_planned_perio_red = ls_diverse-initmr_year.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF me->lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02 OR
           me->lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14.

          IF lv_planned_perio_red IS INITIAL.

            CHECK: gr_inst IS NOT INITIAL.
            "Get next meter reading date
            CALL METHOD gr_inst->get_next_meterread_date
              EXPORTING
                x_keydate       = gs_process_step_data-proc_date
              IMPORTING
                y_mr_date       = lv_adatsoll
              EXCEPTIONS
                invalid_object  = 1
                keydate_invalid = 2
                not_found       = 3
                not_selected    = 4
                OTHERS          = 5.
            IF sy-subrc <> 0.
              MESSAGE e038(/idxgc/ide_add) WITH text-020 INTO lv_mtext.
              /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
            ENDIF.

            "-------------------ABDATUM--------------------
            lv_abdatum = lv_adatsoll.

            " 1 Woche abziehen.
            CALL FUNCTION 'ISU_DATE_MODIFIKATION'
              EXPORTING
                m_art       = '-'
                day         = '7'
              CHANGING
                date        = lv_abdatum
              EXCEPTIONS
                check_error = 1
                OTHERS      = 2.
            IF sy-subrc <> 0.
              MOVE lv_adatsoll TO lv_abdatum.
            ENDIF.

            " Wir müssen aber im gleichen Monat bleiben.
            IF lv_abdatum+4(2) NE lv_adatsoll+4(2).
              MOVE lv_adatsoll TO lv_abdatum.
              MOVE '01' TO lv_abdatum+6(2).
            ENDIF.

            "-------------------BISDATUM--------------------

            MOVE lv_adatsoll TO lv_bisdatum.

            " 1 Woche abziehen.
            CALL FUNCTION 'ISU_DATE_MODIFIKATION'
              EXPORTING
                m_art       = space
                day         = '7'
              CHANGING
                date        = lv_bisdatum
              EXCEPTIONS
                check_error = 1
                OTHERS      = 2.
            IF sy-subrc <> 0.
              MOVE lv_adatsoll TO lv_bisdatum.
            ENDIF.

            " Wir müssen aber im gleichen Monat bleiben.
            IF lv_bisdatum+4(2) NE lv_adatsoll+4(2).
              MOVE lv_adatsoll TO lv_bisdatum.
              " Letzter Kalendertag des Monats ist nicht nötig. der 28. ist immer in Woche 4
              MOVE '28' TO lv_bisdatum+6(2).
            ENDIF.

            " Ab-Datum
            MOVE lv_abdatum+4(2) TO lv_planned_perio_red+lv_stelle(2).
            ADD 2 TO lv_stelle.

*     Bestimmen der Woche
*     1 = Abl. vom 01. bis einschl. 07. Kalendertag
*     2 = Abl. vom 08. bis einschl. 14. Kalendertag
*     3 = Abl. vom 15. bis einschl. 21. Kalendertag
*     4 = Abl. vom 22. bis letzen Kalendertag.
            MOVE '0' TO lv_planned_perio_red+lv_stelle(1). " Erste W ist immer 0
            ADD 1 TO lv_stelle.
            IF  lv_abdatum+6(2) GE '01'
            AND lv_abdatum+6(2) LE '07'.
              MOVE '1' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_abdatum+6(2) GE '08'
            AND lv_abdatum+6(2) LE '14'.
              MOVE '2' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_abdatum+6(2) GE '15'
            AND lv_abdatum+6(2) LE '21'.
              MOVE '3' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_abdatum+6(2) GE '22'
            AND lv_abdatum+6(2) LE '31'.
              MOVE '4' TO lv_planned_perio_red+lv_stelle(1).
            ENDIF.
            ADD 1 TO lv_stelle.


            MOVE lv_bisdatum+4(2) TO lv_planned_perio_red+lv_stelle(2).
            ADD 2 TO lv_stelle.

*     Bestimmen der Woche
*     1 = Abl. vom 01. bis einschl. 07. Kalendertag
*     2 = Abl. vom 08. bis einschl. 14. Kalendertag
*     3 = Abl. vom 15. bis einschl. 21. Kalendertag
*     4 = Abl. vom 22. bis letzen Kalendertag.
            MOVE '0' TO lv_planned_perio_red+lv_stelle(1). " Erste W ist immer 0
            ADD 1 TO lv_stelle.

            IF  lv_bisdatum+6(2) GE '01'
            AND lv_bisdatum+6(2) LE '07'.
              MOVE '1' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_bisdatum+6(2) GE '08'
            AND lv_bisdatum+6(2) LE '14'.
              MOVE '2' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_bisdatum+6(2) GE '15'
            AND lv_bisdatum+6(2) LE '21'.
              MOVE '3' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_bisdatum+6(2) GE '22'
            AND lv_bisdatum+6(2) LE '31'.
              MOVE '4' TO lv_planned_perio_red+lv_stelle(1).
            ENDIF.

            IF lv_bisdatum(4) = lv_abdatum(4).
              MOVE lv_bisdatum(4) TO lv_planned_perio_red.
            ELSE.
              MOVE lv_bisdatum(4) TO lv_planned_perio_red.
            ENDIF.
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-initmr_year = lv_planned_perio_red.
          ELSE.
            ls_diverse-item_id = siv_itemid.
            ls_diverse-initmr_year = lv_planned_perio_red.
            APPEND ls_diverse TO gs_process_step_data-diverse.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD FRANCHISE_FEE_AMOUNT.
    ">>>SCHMIDT.C 20150203 Wird nicht verwendet. Keine Relevanz in Solingen
  ENDMETHOD.


  METHOD FRANCHISE_FEE_ASSIGNMENT.
    ">>>SCHMIDT.C 20150107 Hier wird immer Z08 übermittelt

    DATA: ls_register_code TYPE tekennziff,
          lv_mtext         TYPE string.

    FIELD-SYMBOLS:
      <fs_charges> TYPE /idxgc/s_charges_details.

    "Bei der Antwort auf EoG wurden die Daten bereits aus dem Quellschritt übernommen
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      RETURN.
    ENDIF.

    LOOP AT gs_process_step_data-charges ASSIGNING <fs_charges>.

*   In case of ES101, franchise_fee is not a required field
      IF ( gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101 ) AND
         ( <fs_charges>-franchise_fee IS INITIAL ).
        CONTINUE.
      ENDIF.

      <fs_charges>-fr_fee_assign = /idxgc/if_constants_ide=>gc_cci_chardesc_code_z08.

    ENDLOOP.

  ENDMETHOD.


  METHOD FRANCHISE_FEE_GROUP.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF05
    "Form: hole_konzabgabe

    DATA: lv_mtext           TYPE string,
          ls_ttyp_attributes TYPE zepdprodukttariftyp,
          ls_v_eanl          TYPE v_eanl.

    FIELD-SYMBOLS: <fs_charges> TYPE /idxgc/s_charges_details.

    "Bei der Antwort auf EoG wurden die Daten bereits aus dem Quellschritt übernommen
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      RETURN.
    ENDIF.

    TRY.
        LOOP AT gs_process_step_data-charges ASSIGNING <fs_charges>.

          me->lr_isu_pod = get_pod_ref( iv_int_ui = zcl_agc_masterdata=>get_int_ui( iv_ext_ui = <fs_charges>-ext_ui ) iv_keydate = gs_process_step_data-proc_date ).

          ls_ttyp_attributes = lr_isu_pod->get_ttyp_attributes( ).

          IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.
            IF ls_ttyp_attributes-zepdkautilmd IS NOT INITIAL.
              <fs_charges>-franchise_fee = ls_ttyp_attributes-zepdkautilmd.
            ELSE.
              IF lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.
                <fs_charges>-franchise_fee = 'SA'.
              ELSE.
                <fs_charges>-franchise_fee = 'TA'.
              ENDIF.
            ENDIF.
          ENDIF.

          IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.
            IF gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb101.
              IF ls_ttyp_attributes-zepdkautilmd IS NOT INITIAL.
                <fs_charges>-franchise_fee = ls_ttyp_attributes-zepdkautilmd.
              ELSE.
                <fs_charges>-franchise_fee = 'SA'.
              ENDIF.
            ELSE.
              IF ls_ttyp_attributes-zepdkautilmdgrv IS NOT INITIAL.
                <fs_charges>-franchise_fee = ls_ttyp_attributes-zepdkautilmdgrv.
              ELSE.
                IF lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.
                  <fs_charges>-franchise_fee = 'TA'.
                ELSE.
                  <fs_charges>-franchise_fee = 'SA'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          IF <fs_charges>-franchise_fee IS INITIAL.
            MESSAGE e051(/idxgc/ide_add) WITH <fs_charges>-reg_code INTO lv_mtext.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
          ENDIF.
        ENDLOOP.

      CATCH zcx_agc_masterdata.
    ENDTRY.
  ENDMETHOD.


  METHOD FRANCHISE_FEE_SEQ.
    ">>>SCHMIDT.C 20150203 Für EoG aus Quellschritt übernehmen

    DATA: ls_charges_data_src TYPE /idxgc/s_charges_details,
          ls_pod_dev_relation TYPE /idxgc/s_pod_dev_relation,
          ls_register_data    TYPE /idxgc/s_register_data,
          ls_charges_data     TYPE /idxgc/s_charges_details,
          ls_meter_dev        TYPE /idxgc/s_meterdev_details.

    FIELD-SYMBOLS: <fs_charges_data> TYPE /idxgc/s_charges_details.

    CLEAR: siv_context_rff_ave.

    "EoG-Bestätigung: Daten aus Quellschritt
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      LOOP AT gs_process_data_src-charges INTO ls_charges_data_src
        WHERE charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
        READ TABLE gs_process_step_data-pod TRANSPORTING NO FIELDS
          WITH KEY ext_ui = ls_charges_data_src-ext_ui.
        CHECK sy-subrc = 0.
        ls_charges_data_src-item_id = siv_itemid.

        READ TABLE gs_process_step_data-charges ASSIGNING <fs_charges_data>
          WITH KEY item_id     = siv_itemid
                   ext_ui      = ls_charges_data_src-ext_ui
                   reg_code    = ls_charges_data_src-reg_code
                   charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
        IF sy-subrc = 0.
          <fs_charges_data> = ls_charges_data_src.
        ELSE.
          APPEND ls_charges_data_src TO gs_process_step_data-charges.
        ENDIF.
      ENDLOOP.

    ELSE.
      ">>>SCHMIDT.C 20150224 Kopie aus dem Standard mit Anpassung der IF-Abfrage (= durch CP ersetzt!) =>Nach IDEXGE Patch zurück bauen!
*     In case the field "Register Code" is not filled in the trigger report,
*     segment group SG8_SEQ+Z07 should not be displayed in the IDOC
      IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101.
        CHECK gs_process_data_src-charges IS NOT INITIAL.
      ENDIF.

      me->get_device_register_data( ).

      LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.

*   In GENF processes, tranche POD is parent POD
        IF ls_pod_dev_relation-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.  "Parent
          CONTINUE.
        ENDIF.

        LOOP AT ls_pod_dev_relation-register_data INTO ls_register_data.

*            Data will only be filled for division electricity and special reg codes
          IF ( ( gs_process_step_data-spartyp = /idxgc/if_constants_ide=>gc_division_ele AND
                 ( ls_register_data-kennziff CP /idxgc/if_constants_ide=>gc_obis_ele_meter OR
                   ls_register_data-kennziff CP /idxgc/if_constants_ide=>gc_obis_ele_advance OR
                   ls_register_data-kennziff CP /idxgc/if_constants_ide=>gc_obis_ele_load_shape ) ) OR
*            Data will only be filled for division gas and special reg codes
               ( gs_process_step_data-spartyp = /idxgc/if_constants_ide=>gc_division_gas AND
                 ( ls_register_data-kennziff CP /idxgc/if_constants_ide=>gc_obis_gas_opr_meter OR
                   ls_register_data-kennziff CP /idxgc/if_constants_ide=>gc_obis_gas_opr_meter_diff OR
                   ls_register_data-kennziff CP /idxgc/if_constants_ide=>gc_obis_gas_std_meter OR
                   ls_register_data-kennziff CP /idxgc/if_constants_ide=>gc_obis_gas_std_meter_diff OR
                   ls_register_data-kennziff CP /idxgc/if_constants_ide=>gc_obis_gas_energy_prof_val ) ) ).

*       Fill segment data
            IF ls_register_data-meternumber IS NOT INITIAL.
              SHIFT ls_register_data-meternumber LEFT DELETING LEADING '0'.
              MODIFY ls_pod_dev_relation-register_data FROM ls_register_data.
            ENDIF.

            IF siv_context_rff_ave IS INITIAL.
              siv_context_rff_ave = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
            ENDIF.
            ls_charges_data-charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.

            READ TABLE gs_process_step_data-charges TRANSPORTING NO FIELDS
            WITH KEY item_id     = siv_itemid
                     ext_ui      = ls_pod_dev_relation-ext_ui
                     reg_code    = ls_register_data-kennziff
                     charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
            IF sy-subrc <> 0.
              ls_charges_data-item_id  = siv_itemid.
              ls_charges_data-ext_ui   = ls_pod_dev_relation-ext_ui.
              ls_charges_data-reg_code = ls_register_data-kennziff.
              APPEND ls_charges_data TO gs_process_step_data-charges.
            ENDIF.
          ENDIF.
        ENDLOOP.

      ENDLOOP.

* If without charges data, get data from source data
      IF ls_charges_data IS INITIAL.

        READ TABLE gs_process_data_src-charges INTO ls_charges_data
                                               WITH KEY item_id     = siv_itemid
                                                        charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
        IF sy-subrc = 0.
          ls_charges_data-item_id  = siv_itemid.
          ls_charges_data-ext_ui   = ls_pod_dev_relation-ext_ui.
          APPEND ls_charges_data TO gs_process_step_data-charges.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD GABI_CASE_GROUP_CLASSIFICATION.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF02
    "Form: hole_fallgruppe_gabi

    DATA: ls_diverse          TYPE /idxgc/s_diverse_details,
          lv_group_alloc_gabi TYPE /idxgc/de_group_alloc_gabi.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-group_alloc_gabi IS NOT INITIAL.
        lv_group_alloc_gabi = ls_diverse-group_alloc_gabi.
      ENDIF.
    ENDIF.

    IF lv_group_alloc_gabi IS INITIAL.
      TRY.
          me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

          IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas AND
             lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.

            IF lv_group_alloc_gabi IS INITIAL.
              TRY.
                  lv_group_alloc_gabi = lr_isu_pod->get_fallgruppe_gabi( ).
                CATCH zcx_agc_masterdata.
                  lv_group_alloc_gabi = 'GABi-RLMmT'.
              ENDTRY.
            ENDIF.
          ENDIF.
        CATCH zcx_agc_masterdata.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDTRY.
    ENDIF.

    IF lv_group_alloc_gabi IS NOT INITIAL.
      READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
      IF <fs_diverse> IS ASSIGNED.
        <fs_diverse>-group_alloc_gabi = lv_group_alloc_gabi.
      ELSE.
        CLEAR: ls_diverse.
        ls_diverse-item_id = siv_itemid.
        ls_diverse-group_alloc_gabi = lv_group_alloc_gabi.
        APPEND ls_diverse TO gs_process_step_data-diverse.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD GET_DEVICE_REGISTER_DATA.
    ">>>SCHMIDT.C 20150107 Muss aus der aktuellen Logik übernommen werden.
    "----------------------------------------------------------------------

    DATA: ls_v_eger        TYPE v_eger,
          ls_register_data TYPE /idxgc/s_register_data,
          lt_register_data TYPE /idxgc/t_register_data,
          lv_anlage        TYPE anlage.

    FIELD-SYMBOLS: <fs_pod_dev_relation> TYPE /idxgc/s_pod_dev_relation,
                   <fs_device_data>      TYPE /idxgc/s_device_data.

    IF sit_pod_dev_relation IS INITIAL.
      me->get_pod_dev_relation_data( ).
    ENDIF.

    LOOP AT sit_pod_dev_relation ASSIGNING <fs_pod_dev_relation>
         WHERE device_data IS INITIAL
           AND register_data IS INITIAL.

      ">>>SCHMIDT.C 20150225 Anpassung wg. Aufruf eigener Methode
      TRY.
          me->lr_isu_pod = get_pod_ref( iv_int_ui = <fs_pod_dev_relation>-int_ui iv_keydate = gs_process_step_data-proc_date ).
          <fs_pod_dev_relation>-device_data = lr_isu_pod->get_device_data( ).
        CATCH zcx_agc_masterdata.
          CONTINUE.
      ENDTRY.

      CHECK: <fs_pod_dev_relation>-device_data IS NOT INITIAL.

      LOOP AT <fs_pod_dev_relation>-device_data ASSIGNING <fs_device_data>.
        MOVE-CORRESPONDING <fs_device_data> TO ls_v_eger.
*     Fill Register data
        CALL METHOD me->fill_register_data
          EXPORTING
            is_v_eger        = ls_v_eger
          IMPORTING
            et_register_data = lt_register_data.
        LOOP AT lt_register_data INTO ls_register_data.
          ">>>SCHMIDT.C 20150225 Nur die Zählwerke übermitteln, die aktuell der Anlage zugeordnet und abrechnungsrelevant sind.
* >>> Wolf.A., adesso AG, 17.04.2015, Mantis 4869
* Hintergrund: die vorangehende Methode FILL_REGISTER_DATA liest die relevanten Werte aus der Tabelle ETDZ aus.
* Dort können allerdings zu einer LOGIKZW-Nr. mehrere Einträge (Zeitscheiben) existieren (bei Änderungen
* der Zählwerkskonfiguration (z.B. Änderung der OBIS)). Daher ist es wichtig, nur die aktuell (zum Stichtag) gültigen
* Zählwerke zur weiteren Prüfung heranzuziehen. Sonst werden nicht mehr aktuelle ZW ebenfalls kommuniziert.
          IF ls_register_data-bis < gs_process_step_data-proc_date.
            DELETE lt_register_data.
            CONTINUE.
          ENDIF.
* <<< Wolf.A., adesso AG, 17.04.2015, Mantis 4869
          TRY.
              lv_anlage = lr_isu_pod->get_anlage( ).
            CATCH zcx_agc_masterdata.
              CONTINUE.
          ENDTRY.
          SELECT COUNT(*) FROM easts
            WHERE anlage = lv_anlage AND
                  logikzw = ls_register_data-logikzw AND
                  bis >= gs_process_step_data-proc_date AND
                  ab <=  gs_process_step_data-proc_date AND
                  zwnabr = ''.
          IF sy-subrc <> 0.
            DELETE lt_register_data.
            CONTINUE.
          ENDIF.
          "<<<SCHMIDT.C 20150225

          SHIFT ls_register_data-meternumber LEFT DELETING LEADING '0'.
          READ TABLE <fs_pod_dev_relation>-register_data TRANSPORTING NO FIELDS
                WITH KEY equnr = ls_register_data-equnr
                         register = ls_register_data-register
                         bis = ls_register_data-bis.
          IF sy-subrc <> 0.
            APPEND ls_register_data TO <fs_pod_dev_relation>-register_data.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  METHOD GET_INST_TYPE.
    ">>>SCHMIDT.C 20150203 Anpassung an kundeneigene Ermittlung
    DATA: lv_metmethod TYPE eideswtmdmetmethod.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        lv_metmethod = lr_isu_pod->get_metmethod( ).

        CASE lv_metmethod.
          WHEN /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.
            siv_inst_type = '01'.
          WHEN /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02.
            siv_inst_type = '02'.
          WHEN /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_z29.
            siv_inst_type = '03'.
        ENDCASE.

      CATCH zcx_agc_masterdata.
    ENDTRY.
  ENDMETHOD.


  METHOD GET_METERING_PROCEDURE_DETAILS.
    DATA: lr_data_provision TYPE REF TO /idxgc/badi_data_provision,
          lx_previous       TYPE REF TO /idxgc/cx_general.

    TRY.
        GET BADI lr_data_provision.
      CATCH cx_badi_not_implemented.
    ENDTRY.

    TRY.
        CALL BADI lr_data_provision->metering_procedure_details
          EXPORTING
            is_process_data_src     = gs_process_data_src
            is_process_data_src_add = gs_process_data_src_add
            is_process_data         = gs_process_step_data
            iv_itemid               = siv_itemid
          IMPORTING
            et_profile_details      = sit_meter_proc_details.
      CATCH /idxgc/cx_utility_error INTO lx_previous.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
    ENDTRY.
  ENDMETHOD.


  METHOD GET_POD_DEV_RELATION_DATA.
    ">>>SCHMIDT.C 20150203 Übernahme aus dem Standard mit Füllung interner Tabelle
    DATA:
      ls_pod              TYPE         /idxgc/s_pod_info_details,
      ls_pod_dev_relation TYPE         /idxgc/s_pod_dev_relation,
      ls_pod_table        LIKE LINE OF lt_pod_table.

    LOOP AT gs_process_step_data-pod INTO ls_pod
              WHERE item_id = siv_itemid
                AND loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.

      READ TABLE sit_pod_dev_relation TRANSPORTING NO FIELDS
            WITH KEY ext_ui = ls_pod-ext_ui.
      IF sy-subrc <> 0.
        ls_pod_dev_relation-ext_ui = ls_pod-ext_ui.
        ls_pod_dev_relation-int_ui = ls_pod-int_ui.
        ls_pod_dev_relation-pod_type = ls_pod-pod_type.
        APPEND ls_pod_dev_relation TO sit_pod_dev_relation.

        READ TABLE lt_pod_table TRANSPORTING NO FIELDS WITH KEY int_ui = ls_pod-int_ui.
        IF sy-subrc <> 0.
          "Füllen der POD-Tabelle
          ls_pod_table-ext_ui = ls_pod-ext_ui.
          ls_pod_table-int_ui = ls_pod-int_ui.

          TRY.
              CREATE OBJECT lr_isu_pod
                EXPORTING
                  iv_int_ui           = ls_pod-int_ui
                  iv_keydate          = gs_process_step_data-proc_date
                  iv_process_all_data = abap_false.
              ls_pod_table-pod_ref = lr_isu_pod.
              APPEND ls_pod_table TO lt_pod_table.
            CATCH zcx_agc_masterdata .
          ENDTRY.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD GET_POD_REF.

    DATA: ls_pod_table LIKE LINE OF lt_pod_table.

    FIELD-SYMBOLS: <fs_pod_table> LIKE LINE OF me->lt_pod_table.

    LOOP AT me->lt_pod_table ASSIGNING <fs_pod_table> WHERE int_ui = iv_int_ui.
      rr_isu_pod = <fs_pod_table>-pod_ref.
      EXIT.
    ENDLOOP.

    IF rr_isu_pod IS NOT BOUND.
      TRY.
          CREATE OBJECT rr_isu_pod
            EXPORTING
              iv_int_ui           = iv_int_ui
              iv_keydate          = iv_keydate
              iv_process_all_data = abap_false.
          ls_pod_table-int_ui = iv_int_ui.
          ls_pod_table-ext_ui = rr_isu_pod->get_ext_ui( ).
          ls_pod_table-pod_ref = rr_isu_pod.
          APPEND ls_pod_table TO lt_pod_table.
        CATCH zcx_agc_masterdata.
          zcx_agc_masterdata=>raise_exception_from_msg( ).
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD GET_SETTLUNIT_VIA_EEDMSETTLUN.

    DATA: lt_eedmsettlunit TYPE        t_eedmsettlunit,
          ls_eedmsettlunit TYPE        eedmsettlunit,
          lr_badi_error    TYPE REF TO cx_badi_not_implemented, "#EC NEEDED
          lr_exit_obj      TYPE REF TO isu_changedoc,
          lt_settlview     TYPE        t_eedmsettlview,
          ls_basic_data    TYPE        eide_chngdoc_basic,
          lv_int_ui        TYPE        int_ui,
          lv_servprov      TYPE        service_prov,
          lv_keydate       TYPE        dats.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    IF iv_int_ui IS NOT INITIAL.
      lv_int_ui = iv_int_ui.
    ELSE.
      lv_int_ui = gs_process_step_data-int_ui.
    ENDIF.

    IF lv_servprov IS INITIAL.
      lv_servprov = gs_process_step_data-assoc_servprov.
    ENDIF.

* prepare instance for badi
    TRY.
        GET BADI lr_exit_obj.
      CATCH cx_badi_not_implemented INTO lr_badi_error. "#EC NO_HANDLER
    ENDTRY.

* Lesen aller m?glichen Sichten (001, 002) und anschl. festlegen der relevanten Sicht
    SELECT * FROM eedmsettlview INTO TABLE lt_settlview.
    ls_basic_data-sender   = gs_process_step_data-own_servprov.
    ls_basic_data-receiver = gs_process_step_data-assoc_servprov.

    CALL BADI lr_exit_obj->get_settlmentview_out
      EXPORTING
        imp_basic_data = ls_basic_data
        impt_settlview = lt_settlview
      IMPORTING
        exp_settlview  = siv_settlview
      EXCEPTIONS
        not_found      = 1
        error_occurred = 2.
    IF sy-subrc <> 0.
    ENDIF.

    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
    IF <fs_diverse> IS ASSIGNED.
      IF <fs_diverse>-startsettldate IS NOT INITIAL.
        lv_keydate = <fs_diverse>-startsettldate.
      ELSEIF <fs_diverse>-endsettldate IS NOT INITIAL.
        lv_keydate = <fs_diverse>-endsettldate.
      ELSE.
        lv_keydate = gs_process_step_data-proc_date.
      ENDIF.
      IF zcl_agc_masterdata=>is_netz( ) = abap_true.
        CALL METHOD cl_isu_edm_settlunit=>find_settlunit_supplier
          EXPORTING
            x_servprov   = lv_servprov
            x_settlview  = siv_settlview
*            x_datefrom   = <fs_diverse>-startsettldate      "Wolf.A., 26.03.2015, Mantis 4829
*            x_dateto     = <fs_diverse>-startsettldate      "Wolf.A., 26.03.2015, Mantis 4829
            x_datefrom   = lv_keydate                        "Wolf.A., 26.03.2015, Mantis 4829
            x_dateto     = lv_keydate                        "Wolf.A., 26.03.2015, Mantis 4829
          IMPORTING
            yt_settlunit = lt_eedmsettlunit
          EXCEPTIONS
            not_found    = 1
            OTHERS       = 2.
        IF sy-subrc <> 0.
        ENDIF.
      ELSE.
        SELECT * FROM eedmsettlunit INTO TABLE lt_eedmsettlunit WHERE settltransco = lv_servprov AND
                                                                      settlsupplier = gs_process_step_data-own_servprov.

      ENDIF.

      SORT lt_eedmsettlunit BY dateto.
      READ TABLE lt_eedmsettlunit INTO ls_eedmsettlunit INDEX 1.
      ev_settlunit = ls_eedmsettlunit-settlunit.
    ENDIF.
  ENDMETHOD.


  METHOD GET_SETTLUNIT_VIA_POD.
    ">>>SCHMIDT.C 20150304 Kopie aus dem Standard mit Anpassung. Es darf nicht nur immer mit MOVEINDATE gesucht werden.
    DATA: lt_eedmuisettlunit TYPE        t_eedmuisettlunit,
          ls_eedmuisettlunit TYPE        eedmuisettlunit,
          lr_badi_error      TYPE REF TO cx_badi_not_implemented, "#EC NEEDED
          lr_exit_obj        TYPE REF TO isu_changedoc,
          lt_settlview       TYPE        t_eedmsettlview,
          ls_basic_data      TYPE        eide_chngdoc_basic,
          lv_int_ui          TYPE        int_ui,
          lv_keydate         TYPE        dats.

    FIELD-SYMBOLS: <fs_eedmuisettlunit> TYPE eedmuisettlunit,
                   <fs_diverse>         TYPE /idxgc/s_diverse_details.

    ">>>SCHMIDT.C Anpassung des Selektionsdatums je nach Anwendungsfall / Nachricht
    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
    IF <fs_diverse> IS ASSIGNED.
      CASE gs_process_step_data-bmid.
        WHEN /idxgc/if_constants_ide=>gc_bmid_ee101 OR
             /idxgc/if_constants_ide=>gc_bmid_ee103.
          lv_keydate = <fs_diverse>-endsettldate.
        WHEN OTHERS.
          lv_keydate = <fs_diverse>-startsettldate.
      ENDCASE.
    ENDIF.
    IF lv_keydate IS INITIAL.
      lv_keydate = gs_process_step_data-proc_date. "Zur Not das Prozessdatum nehmen. Bei Anmeldung = CONTR_START_DATE und bei Abmeldung CONTR_END_DATE
    ENDIF.

    IF iv_int_ui IS NOT INITIAL.
      lv_int_ui = iv_int_ui.
    ELSE.
      lv_int_ui = gs_process_step_data-int_ui.
    ENDIF.

* prepare instance for badi
    TRY.
        GET BADI lr_exit_obj.
      CATCH cx_badi_not_implemented INTO lr_badi_error. "#EC NO_HANDLER
    ENDTRY.

* Lesen aller m?glichen Sichten (001, 002) und anschl. festlegen der relevanten Sicht
    SELECT * FROM eedmsettlview INTO TABLE lt_settlview.
    ls_basic_data-sender   = gs_process_step_data-own_servprov.
    ls_basic_data-receiver = gs_process_step_data-assoc_servprov.

    CALL BADI lr_exit_obj->get_settlmentview_out
      EXPORTING
        imp_basic_data = ls_basic_data
        impt_settlview = lt_settlview
      IMPORTING
        exp_settlview  = siv_settlview
      EXCEPTIONS
        not_found      = 1
        error_occurred = 2.
    IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*        RAISING error_occurred.
    ENDIF.

* Auslesen aller Settlunits zum PoD
    CALL METHOD cl_isu_edm_ui_settlunit=>select_pod
      EXPORTING
        im_int_ui       = lv_int_ui
      IMPORTING
        ex_iuisettlunit = lt_eedmuisettlunit.

* Zuordnungen mit der festgelegten Sicht auslesen und sortieren.
    LOOP AT lt_eedmuisettlunit ASSIGNING <fs_eedmuisettlunit>.
      IF  NOT <fs_eedmuisettlunit>-settlview = siv_settlview OR
              <fs_eedmuisettlunit>-bis < lv_keydate.
        CLEAR <fs_eedmuisettlunit>-settlview.
      ENDIF.
    ENDLOOP.
    DELETE lt_eedmuisettlunit WHERE settlview IS INITIAL.

    SORT lt_eedmuisettlunit BY bis.
    READ TABLE lt_eedmuisettlunit INTO ls_eedmuisettlunit INDEX 1.
    ev_settlunit = ls_eedmuisettlunit-settlunit.


  ENDMETHOD.


  METHOD GRID_USAGE_CONTRACT_TYPE.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_zz_statusnenu

    DATA: ls_diverse          TYPE /idxgc/s_diverse_details,
          lv_gridus_contrinfo TYPE /idxgc/de_gridus_contrinfo,
          ls_ever             TYPE ever.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103 OR "Antwort auf EoG
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es103. "Antwort auf Anmeldung NN

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-gridus_contrinfo IS NOT INITIAL.
        lv_gridus_contrinfo = ls_diverse-gridus_contrinfo.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lv_gridus_contrinfo IS INITIAL.
          ls_ever = lr_isu_pod->get_ever( ).
          IF ls_ever-zz_nn_direkt = abap_true.
            lv_gridus_contrinfo = /idxgc/if_constants_ide=>gc_agr_01_agree_tpcode_e01.
          ELSE.
            lv_gridus_contrinfo = /idxgc/if_constants_ide=>gc_agr_01_agree_tpcode_e02.
          ENDIF.
        ENDIF.

        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
        IF <fs_diverse> IS ASSIGNED.
          <fs_diverse>-gridus_contrinfo = lv_gridus_contrinfo.
        ELSE.
          ls_diverse-item_id = siv_itemid.
          ls_diverse-gridus_contrinfo = lv_gridus_contrinfo.
          APPEND ls_diverse TO gs_process_step_data-diverse.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD INSTANTIATE.
    DATA: ls_ever TYPE ever.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    TRY.
        CALL METHOD super->instantiate.
      CATCH /idxgc/cx_process_error .
    ENDTRY.

    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
    IF <fs_diverse> IS ASSIGNED.
      siv_transreason = <fs_diverse>-msgtransreason.
    ENDIF.

    IF zcl_agc_datex_utility=>check_ever_from_online_service( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ) = abap_true.
      TRY.
          ls_ever = zcl_agc_masterdata=>get_ever( iv_anlage = zcl_agc_masterdata=>get_anlage( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ) iv_keydate = gs_process_step_data-proc_date ).

          SELECT SINGLE * FROM zos_orders INTO sis_os_data WHERE guid EQ ls_ever-zos_order_guid AND
                                                                 vertrag EQ ls_ever-vertrag.

        CATCH zcx_agc_masterdata.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD INVOLVED_SUPPLIER.
    ">>>SCHMIDT.C 20150210 Anpassung beteiligter Marktpartner anhand der Quellschritte im Customizing
    DATA: lv_servprov      TYPE          service_prov,
          lt_servprov      TYPE TABLE OF service_prov,
          ls_marpaadd      TYPE          /idxgc/s_marpaadd_details,
          lv_service_type  TYPE          intcode,
          ls_eservprov     TYPE          eservprov,
          ls_control       TYPE          edidc,
          lv_extcodelistid TYPE          /idxgc/de_codelist_agency.

    CASE gs_process_step_data-bmid.
      WHEN /idxgc/if_constants_ide=>gc_bmid_es102.

*       ES102 required in case of answer status Z35 (OSUP)
        READ TABLE gs_process_step_data-msgrespstatus TRANSPORTING NO FIELDS WITH KEY item_id = siv_itemid
                                                                                      respstatus = /idxgc/if_constants_ide=>gc_respstatus_z35.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        IF gs_process_data_src_add-assoc_servprov IS NOT INITIAL.
          lv_servprov = gs_process_data_src_add-assoc_servprov.
          APPEND lv_servprov TO lt_servprov.
        ENDIF.

      WHEN /idxgc/if_constants_ide=>gc_bmid_es301    "Abmeldung NN (Abmeldeanfrage)
        OR /idxgc/if_constants_ide=>gc_bmid_es500.   "Infomeldung über Aufh. zuk. Vers. (ZC9)

        IF gs_process_data_src-service_prov_new IS NOT INITIAL.
          lv_servprov = gs_process_data_src-service_prov_new.
          APPEND lv_servprov TO lt_servprov.
        ENDIF.

      WHEN /idxgc/if_constants_ide=>gc_bmid_es200.   "Infomeldung über existierende Zuordnung (Z26)
        IF gs_process_data_src_add-assoc_servprov IS NOT INITIAL.
          lv_servprov = gs_process_data_src_add-assoc_servprov.
          APPEND lv_servprov TO lt_servprov.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.

    LOOP AT lt_servprov INTO lv_servprov.
*     Get service category
      CALL FUNCTION 'ISU_GET_SERVICETYPE_PROVIDER'
        EXPORTING
          x_service_prov = lv_servprov
        IMPORTING
          y_service_type = lv_service_type
        EXCEPTIONS
          general_fault  = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
      ENDIF.

      IF lv_service_type IS NOT INITIAL.
*       Get receiver information
        CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
          EXPORTING
            x_serviceid = lv_servprov
          IMPORTING
            y_eservprov = ls_eservprov
          EXCEPTIONS
            not_found   = 1.
        IF sy-subrc <> 0.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
        ENDIF.

*       Get External code list agency of receiver
        IF ls_eservprov-externalidtyp IS NOT INITIAL.
          CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
            EXPORTING
              x_ext_idtyp     = ls_eservprov-externalidtyp
              x_idoc_control  = ls_control
            IMPORTING
              y_extcodelistid = lv_extcodelistid
            EXCEPTIONS
              not_supported   = 1
              error_occured   = 2
              OTHERS          = 3.
          IF sy-subrc <> 0.
            CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
          ENDIF.
        ENDIF.

        ls_marpaadd-item_id          = siv_itemid.
        ls_marpaadd-party_func_qual  = /idxgc/if_constants_ide=>gc_nad_02_qual_vy.
        "       ls_marpaadd-ext_ui           = gs_process_step_data-ext_ui. Keine Referenz auf den ZP mitsenden
        ls_marpaadd-party_identifier = ls_eservprov-externalid.
        ls_marpaadd-codelist_agency  = lv_extcodelistid.
        ls_marpaadd-serviceid        = lv_servprov.
        APPEND ls_marpaadd TO gs_process_step_data-marketpartner_add.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD LOAD_PROFILE_ASSIGNMENT.

    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_slp

    DATA: ls_diverse          TYPE /idxgc/s_diverse_details,
          lv_profile_group    TYPE /idxgc/de_profile_group,
          lv_profil           TYPE zedmlastprofil,
          lv_kz_eigen         TYPE kennzx,
          lv_prof_code_an_cla TYPE /idxgc/de_prof_code_an_cla,
          lv_sparte           TYPE sparte.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-prof_code_an IS NOT INITIAL AND
         ls_diverse-profile_group IS NOT INITIAL AND
         ls_diverse-prof_code_an_cla IS NOT INITIAL.
        lv_profil = ls_diverse-prof_code_an.
        lv_profile_group = ls_diverse-profile_group.
        lv_prof_code_an_cla = ls_diverse-prof_code_an_cla.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_metmethod( ) <>  /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.

          IF lv_profil IS INITIAL AND
             lv_profile_group IS INITIAL AND
             lv_prof_code_an_cla IS INITIAL.

            IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.
              lv_profile_group = /idexge/if_constants_dp=>gc_loadprofile_clt_z12.
            ELSE.
              IF lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02 OR
                 lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_z29.
                lv_profile_group = /idexge/if_constants_dp=>gc_loadprofile_clt_z02.
              ELSEIF lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14.
                lv_profile_group = /idexge/if_constants_dp=>gc_loadprofile_clt_z03.
              ENDIF.
            ENDIF.

            lv_profil = lr_isu_pod->get_profil( ).
            lv_sparte = lr_isu_pod->get_sparte( ).

            CALL FUNCTION 'ZLW2_CHECK_LASTPROFIL'
              EXPORTING
                im_sparte     = lv_sparte
                im_profile    = lv_profil
              IMPORTING
                ex_kz_eigen   = lv_kz_eigen
              EXCEPTIONS
                general_fault = 1
                OTHERS        = 2.
            IF sy-subrc <> 0.
            ENDIF.

            IF lv_kz_eigen = abap_true.
              lv_prof_code_an_cla = cl_isu_datex_co=>co_pod_from_dist.
            ELSE.
              lv_prof_code_an_cla = cl_isu_datex_co=>co_vdew.
            ENDIF.
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-prof_code_an = lv_profil.
            <fs_diverse>-profile_group = lv_profile_group.
            <fs_diverse>-prof_code_an_cla = lv_prof_code_an_cla.
          ELSE.
            ls_diverse-prof_code_an = lv_profil.
            ls_diverse-profile_group = lv_profile_group.
            ls_diverse-item_id = siv_itemid.
            ls_diverse-prof_code_an_cla = lv_prof_code_an_cla.
            APPEND ls_diverse TO gs_process_step_data-diverse.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD LOCAL_CONTROL_GROUP.
    DATA: lv_reglabel              TYPE /idexge/reglabel,
          lt_reg_code_data         TYPE /idxgc/t_reg_code_details,
          lt_reg_code_data_collect TYPE /idxgc/t_reg_code_details,
          ls_reg_code_data         TYPE /idxgc/s_reg_code_details,
          ls_reg_code_data_source  TYPE /idxgc/s_reg_code_details,
          ls_reg_code_data_next    TYPE /idxgc/s_reg_code_details,
          lv_lines                 TYPE i,
          lv_lines_collect         TYPE i,
          lv_mtext                 TYPE string,
          lv_processing            TYPE flag.

    FIELD-SYMBOLS:
      <fs_reg_code_data>         TYPE /idxgc/s_reg_code_details,
      <fs_reg_code_data_collect> TYPE /idxgc/s_reg_code_details.

    "Bei der Antwort auf EoG wurden die Daten bereits aus dem Quellschritt übernommen
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      RETURN.
    ENDIF.

* In case the field "Register Code" is not filled in the trigger report,
* segment group SG8_SEQ+Z02 should not be displayed in the IDOC
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101.
      CHECK gs_process_data_src-reg_code_data IS NOT INITIAL.
    ENDIF.

* Fill register label only in case of non RLM
    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF me->lr_isu_pod->get_metmethod( ) <> /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.

*   Read all register data for current item ID
          LOOP AT gs_process_step_data-reg_code_data INTO ls_reg_code_data_source
            WHERE item_id = siv_itemid.
            APPEND ls_reg_code_data_source TO lt_reg_code_data.
          ENDLOOP.

          SORT lt_reg_code_data ASCENDING BY item_id ext_ui meternumber.

*   Determine lines of table as end condition
          DESCRIBE TABLE lt_reg_code_data LINES lv_lines.

          lv_processing = abap_false.
          LOOP AT lt_reg_code_data INTO ls_reg_code_data.
*     Create for each meternumber its own register table
            APPEND ls_reg_code_data TO lt_reg_code_data_collect.

*     Check if end of register list reached
            IF sy-tabix = lv_lines.
              lv_processing = abap_true.
*     or read next register entry (row) and compare key fields (current/next row)
            ELSE.
              READ TABLE lt_reg_code_data INTO ls_reg_code_data_next INDEX sy-tabix + 1.
*       Check if current key is equal to next key
              IF ls_reg_code_data_next-item_id     NE ls_reg_code_data-item_id OR
                 ls_reg_code_data_next-ext_ui      NE ls_reg_code_data-ext_ui  OR
                 ls_reg_code_data_next-meternumber NE ls_reg_code_data-meternumber.

                lv_processing = abap_true.
              ENDIF.
            ENDIF.

            IF lv_processing = abap_true.
*       Processing for current register table
*       In case of 1 register, no need to fill the register label
              DESCRIBE TABLE lt_reg_code_data_collect LINES lv_lines_collect.
              CHECK lv_lines_collect > 1.
              LOOP AT lt_reg_code_data_collect ASSIGNING <fs_reg_code_data_collect>.
                SELECT SINGLE reglabel FROM /idexge/reg_labl INTO lv_reglabel
                 WHERE spartyp  = gs_process_step_data-spartyp AND
                       kennziff = <fs_reg_code_data_collect>-reg_code.
                IF lv_reglabel IS INITIAL.
                  lv_reglabel = 'HT'.
                ENDIF.
                LOOP AT gs_process_step_data-reg_code_data ASSIGNING <fs_reg_code_data>
                  WHERE item_id EQ <fs_reg_code_data_collect>-item_id
                    AND ext_ui EQ <fs_reg_code_data_collect>-ext_ui
                    AND meternumber EQ <fs_reg_code_data_collect>-meternumber
                    AND reg_code EQ <fs_reg_code_data_collect>-reg_code.
                  <fs_reg_code_data>-reg_label = lv_reglabel.
                ENDLOOP.

              ENDLOOP.

              CLEAR: lt_reg_code_data_collect,
                     lv_lines_collect.
              lv_processing = abap_false.
            ENDIF.

          ENDLOOP.

        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD LOSS_FACTOR.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF05
    "Form: hole_verlustfaktor

    DATA: ls_lw_spebene  TYPE zlw_spebene,
          ls_v_eanl      TYPE v_eanl,
          lv_loss_factor TYPE /idxgc/de_lossfact_ext_1.

    FIELD-SYMBOLS: <fs_pod>     TYPE /idxgc/s_pod_info_details,
                   <fs_pod_src> TYPE /idxgc/s_pod_info_details,
                   <fs_diverse> TYPE /idxgc/s_diverse_details.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.

          LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod> WHERE item_id = siv_itemid AND
                                                                    loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.

            READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
            IF <fs_diverse> IS ASSIGNED.

              IF <fs_pod>-volt_level_meas <> <fs_diverse>-volt_level_offt.

                "Quellschrittdaten lesen oder bei Antwort auf EoG
                IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
                   gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
                  READ TABLE gs_process_data_src-pod ASSIGNING <fs_pod_src> WITH KEY item_id = siv_itemid
                                                                                     ext_ui = <fs_pod>-ext_ui.
                  IF <fs_pod_src> IS ASSIGNED.
                    lv_loss_factor = <fs_pod_src>-lossfact_ext.
                  ENDIF.
                ENDIF.

                IF lv_loss_factor IS INITIAL.

                  me->lr_isu_pod = get_pod_ref( iv_int_ui = <fs_pod>-int_ui iv_keydate = gs_process_step_data-proc_date ).
                  lv_loss_factor = lr_isu_pod->get_loss_factor( ).
                  SHIFT lv_loss_factor LEFT DELETING LEADING space.

                ENDIF.

                <fs_pod>-lossfact_ext = lv_loss_factor.

              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.

      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD MABIS_TIME_SERIES_CATEGORY.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF08
    "Form: hole_zeitreihentyp

    DATA: ls_timeser           TYPE /idxgc/s_timeser_details,
          ls_mabis_time_series TYPE zlwzeitreihentyp.

    FIELD-SYMBOLS: <fs_timeser> TYPE /idxgc/s_timeser_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_step_data-time_series ASSIGNING <fs_timeser> WITH KEY item_id = siv_itemid
                                                                                  ext_ui = gs_process_step_data-ext_ui.

      IF <fs_timeser> IS ASSIGNED.
        ls_mabis_time_series-zz_katzeitreityp = <fs_timeser>-timseries_msgcat.
        ls_mabis_time_series-zz_zeitreihentyp = <fs_timeser>-time_series_type.
      ENDIF.

    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.

          IF ls_mabis_time_series-zz_katzeitreityp IS INITIAL AND
              ls_mabis_time_series-zz_zeitreihentyp IS INITIAL.
            ls_mabis_time_series = lr_isu_pod->get_mabis_time_series( ).
          ENDIF.

          READ TABLE gs_process_step_data-time_series ASSIGNING <fs_timeser> WITH KEY item_id = siv_itemid
                                                                                      ext_ui = gs_process_step_data-ext_ui.
          IF <fs_timeser> IS ASSIGNED.
            <fs_timeser>-timseries_msgcat = ls_mabis_time_series-zz_katzeitreityp.
            <fs_timeser>-time_series_type = ls_mabis_time_series-zz_zeitreihentyp.
          ELSE.
            ls_timeser-timseries_msgcat = ls_mabis_time_series-zz_katzeitreityp.
            ls_timeser-time_series_type = ls_mabis_time_series-zz_zeitreihentyp.
            ls_timeser-item_id = siv_itemid.
            ls_timeser-ext_ui = gs_process_step_data-ext_ui.
            APPEND ls_timeser TO gs_process_step_data-time_series.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD MAXIMUM_DEMAND.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF05
    "Form: hole_maxdemand
    DATA: ls_pod_quant TYPE /idxgc/s_pod_quant_details,
          lv_maxdemand TYPE /idxgc/de_quantitiy_ext.

    FIELD-SYMBOLS: <fs_pod_quant> TYPE /idxgc/s_pod_quant_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-pod_quant INTO ls_pod_quant WITH KEY item_id = siv_itemid
                                                                          ext_ui = gs_process_step_data-ext_ui
                                                                         quant_type_qual = /idexge/if_constants_dp=>gc_qty_z03.
      IF ls_pod_quant-quantitiy_ext IS NOT INITIAL.
        lv_maxdemand = ls_pod_quant-quantitiy_ext.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.

          IF lv_maxdemand IS INITIAL.
            lv_maxdemand = lr_isu_pod->get_maxdemand( ).
          ENDIF.

          READ TABLE gs_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WITH KEY item_id = siv_itemid
                                                                                      ext_ui = gs_process_step_data-ext_ui
                                                                                      quant_type_qual = /idexge/if_constants_dp=>gc_qty_z03.

          IF <fs_pod_quant> IS ASSIGNED.
            <fs_pod_quant>-quantitiy_ext = lv_maxdemand.
            <fs_pod_quant>-measure_unit_ext = /idxgc/if_constants_ide=>gc_measure_unit_ext_kwt.
          ELSE.
            ls_pod_quant-item_id = siv_itemid.
            ls_pod_quant-quantitiy_ext = lv_maxdemand.
            IF zcl_agc_datex_utility=>check_dummy_pod( iv_ext_ui = gs_process_step_data-ext_ui ) = abap_false.
              ls_pod_quant-ext_ui = gs_process_step_data-ext_ui.
            ENDIF.
            ls_pod_quant-quant_type_qual = /idexge/if_constants_dp=>gc_qty_z03.
            ls_pod_quant-measure_unit_ext = /idxgc/if_constants_ide=>gc_measure_unit_ext_kwt.
            APPEND ls_pod_quant TO gs_process_step_data-pod_quant.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD MDS_BASIC_RESPONSIBILITY.
    ">>>SCHMIDT.C 20150204 JA / NEIN Entscheidung erweitert

    DATA: ls_pod_dev_relation  TYPE /idxgc/s_pod_dev_relation,
          ls_service_provider  TYPE /idxgc/s_service_provider,
          ls_marketpartner_add TYPE /idxgc/s_marpaadd_details,
          lt_marketpartner_add TYPE /idxgc/t_marpaadd_details,
          lv_party_identifier  TYPE dunsnr,
          lv_mp_counter        TYPE /idxgc/de_mp_counter,
          lv_abr_n_messzv      TYPE char4.

    FIELD-SYMBOLS: <fs_marketpartner_add> TYPE /idxgc/s_marpaadd_details.

    LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.

      IF ls_pod_dev_relation-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
        CONTINUE.
      ENDIF.

      LOOP AT ls_pod_dev_relation-service_provider INTO ls_service_provider
              WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dde.

        SELECT COUNT(*) FROM zlw_msd_msb_eig WHERE externalid = ls_service_provider-externalid.
        IF sy-subrc = 0.
          lv_abr_n_messzv = /idxgc/if_constants_ide=>gc_de_yes.
        ELSE.
          lv_abr_n_messzv = /idxgc/if_constants_ide=>gc_de_no.
        ENDIF.

        READ TABLE gs_process_step_data-marketpartner_add ASSIGNING <fs_marketpartner_add>
              WITH KEY item_id = siv_itemid
                       party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dde
                       ext_ui = ls_pod_dev_relation-ext_ui
                       serviceid = ls_service_provider-serviceid.
        IF sy-subrc = 0.
          <fs_marketpartner_add>-mds_is_default = lv_abr_n_messzv.
        ELSE.
          ls_marketpartner_add-item_id = siv_itemid.
          ls_marketpartner_add-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dde.
          ls_marketpartner_add-ext_ui = ls_pod_dev_relation-ext_ui.
          ls_marketpartner_add-party_identifier = ls_service_provider-externalid.
          ls_marketpartner_add-serviceid = ls_service_provider-serviceid.
          ls_marketpartner_add-mds_is_default = lv_abr_n_messzv.
          IF ls_service_provider-codelist_agency IS INITIAL.
            ls_marketpartner_add-codelist_agency = /idxgc/if_constants_ide=>gc_codelist_agency_293.
          ELSE.
            ls_marketpartner_add-codelist_agency = ls_service_provider-codelist_agency.
          ENDIF.
          APPEND ls_marketpartner_add TO lt_marketpartner_add.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    SORT lt_marketpartner_add BY party_identifier ASCENDING.
    LOOP AT lt_marketpartner_add INTO ls_marketpartner_add.
      IF lv_party_identifier <> ls_marketpartner_add-party_identifier.
        lv_party_identifier = ls_marketpartner_add-party_identifier.
        lv_mp_counter = lv_mp_counter + 1.
      ENDIF.

      ls_marketpartner_add-mp_counter = lv_mp_counter.
      APPEND ls_marketpartner_add TO gs_process_step_data-marketpartner_add.
    ENDLOOP.
  ENDMETHOD.


  METHOD MEASURED_VALUE_AQUISITION.
    ">>>SCHMIDT.C 20150203 Anpassung der Prüfung auf das Zählverfahren

    "Daten für die Antwort auf EoG schon in Sequenzgruppe SEQ Z03 gefüllt
    IF gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb103.
      super->measured_value_aquisition( ).
    ENDIF.

  ENDMETHOD.


  METHOD METERING_DATA_SERVICE.
    ">>>SCHMIDT.C 20150204 mdl / MDL stehen an den ZEDM-Zeitscheiden

    DATA: ls_service_provider TYPE /idxgc/s_service_provider,
          ls_mdl              TYPE eservprov,
          lv_codelistid       TYPE e_edmideextcodelistid.

    FIELD-SYMBOLS: <fs_pod_dev_relation> TYPE /idxgc/s_pod_dev_relation.

    CLEAR: siv_context_rff_ave.

    TRY.
        LOOP AT sit_pod_dev_relation ASSIGNING <fs_pod_dev_relation>.
          IF <fs_pod_dev_relation>-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
            CONTINUE.
          ENDIF.

          me->lr_isu_pod = get_pod_ref( iv_int_ui = <fs_pod_dev_relation>-int_ui iv_keydate = gs_process_step_data-proc_date ).

          IF lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_z29.
            CONTINUE.
          ENDIF.

          ls_mdl = lr_isu_pod->get_mdl( ).

*>>> THIMEL.R 20150407 Mantis 4877 Austausch gegen FuBa
*          CASE ls_mdl-externalid(1).
*            WHEN '9'.
*              lv_codelistid = cl_isu_datex_co=>co_vdew.
*            WHEN OTHERS.
*              lv_codelistid = cl_isu_datex_co=>co_ean.
*          ENDCASE.
          CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
            EXPORTING
              x_ext_idtyp     = ls_mdl-externalidtyp
            IMPORTING
              y_extcodelistid = lv_codelistid
            EXCEPTIONS
              not_supported   = 1
              error_occured   = 2
              OTHERS          = 3.
          IF sy-subrc <> 0.
            MESSAGE e038(/idxgc/ide_add) WITH text-021 INTO gv_mtext.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
          ENDIF.
*<<< THIMEL.R 20150407 Mantis 4877

          IF ls_mdl-externalid IS INITIAL.
            MESSAGE e038(/idxgc/ide_add) WITH text-021 INTO gv_mtext.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
          ENDIF.

          ls_service_provider-serviceid = ls_mdl-serviceid.
          ls_service_provider-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dde.
          ls_service_provider-externalid = ls_mdl-externalid.
          ls_service_provider-sec_ext_id = ls_mdl-sec_ext_id.
          ls_service_provider-codelist_agency = lv_codelistid.
          APPEND ls_service_provider TO <fs_pod_dev_relation>-service_provider.

          IF siv_context_rff_ave IS INITIAL.
            siv_context_rff_ave = /idxgc/if_constants_ide=>gc_nad_qual_dde.
          ENDIF.

          CLEAR: ls_mdl, lv_codelistid.
        ENDLOOP.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD METERING_DEVICE_DATA_SEQ.
    ">>>SCHMIDT.C 20150203 Kopie aus dem Standard mit Ausnahme der Mengenumwerterlogik (Zeile 91 - 112 )

    DATA: ls_pod_dev_relation   TYPE /idxgc/s_pod_dev_relation,
          ls_device_data        TYPE /idxgc/s_device_data,
          ls_meter_device_src   TYPE /idxgc/s_meterdev_details,
          ls_meter_device_bak   TYPE /idxgc/s_meterdev_details,
          ls_meter_device       TYPE /idxgc/s_meterdev_details,
          ls_non_meter_device   TYPE /idxgc/s_nonmeter_details,
          ls_pod                TYPE /idxgc/s_pod_info_details,
          ls_etyp               TYPE etyp,
          lv_mtext              TYPE string,
          ls_meter_proc_details TYPE /idxgc/s_profile_details.

    FIELD-SYMBOLS: <fs_meter_device> TYPE /idxgc/s_meterdev_details.

    CASE siv_data_processing_mode.
      WHEN /idxgc/if_constants_add=>gc_data_from_source.
        SORT gs_process_data_src-meter_dev BY item_id ext_ui meternumber.
        LOOP AT gs_process_data_src-meter_dev INTO ls_meter_device_src.
          ls_meter_device-item_id = siv_itemid.
          ls_meter_device-ext_ui = ls_meter_device_src-ext_ui.
          CALL FUNCTION 'CONVERSION_EXIT_GERNR_OUTPUT'
            EXPORTING
              input  = ls_meter_device_src-meternumber
            IMPORTING
              output = ls_meter_device-meternumber.

*         In DE, meternumber is always filled, but still need to edit mdev_id_count
*         for it will be used in mapping exit
          IF ( ls_meter_device-item_id = ls_meter_device_bak-item_id ) AND
             ( ls_meter_device-ext_ui = ls_meter_device_bak-ext_ui ) AND
             ( ls_meter_device-meternumber = ls_meter_device_bak-meternumber ).
            ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count.
          ELSE.
            ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count + 1.
          ENDIF.

          APPEND ls_meter_device TO gs_process_step_data-meter_dev.
          ls_meter_device_bak = ls_meter_device.
        ENDLOOP.

        SORT gs_process_step_data-meter_dev BY item_id ext_ui meternumber mdev_id_count.
        DELETE ADJACENT DUPLICATES FROM gs_process_step_data-meter_dev
                              COMPARING item_id ext_ui meternumber mdev_id_count.

* get data from additional source step, it should only used in some BMIDs
* In this case, attribute sit_meter_proc_details is not filled.
      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
        SORT gs_process_data_src_add-meter_dev BY item_id ext_ui meternumber.
        LOOP AT gs_process_data_src_add-meter_dev INTO ls_meter_device_src.
          ls_meter_device-item_id = siv_itemid.
          ls_meter_device-ext_ui = ls_meter_device_src-ext_ui.
          CALL FUNCTION 'CONVERSION_EXIT_GERNR_OUTPUT'
            EXPORTING
              input  = ls_meter_device_src-meternumber
            IMPORTING
              output = ls_meter_device-meternumber.

*         In DE, meternumber is always filled, but still need to edit mdev_id_count
*         for it will be used in mapping exit
          IF ( ls_meter_device-item_id = ls_meter_device_bak-item_id ) AND
             ( ls_meter_device-ext_ui = ls_meter_device_bak-ext_ui ) AND
             ( ls_meter_device-meternumber = ls_meter_device_bak-meternumber ).
            ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count.
          ELSE.
            ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count + 1.
          ENDIF.

          APPEND ls_meter_device TO gs_process_step_data-meter_dev.
          ls_meter_device_bak = ls_meter_device.
        ENDLOOP.

        SORT gs_process_step_data-meter_dev BY item_id ext_ui meternumber mdev_id_count.
        DELETE ADJACENT DUPLICATES FROM gs_process_step_data-meter_dev
                              COMPARING item_id ext_ui meternumber mdev_id_count.

* get data from default determination logic
      WHEN /idxgc/if_constants_add=>gc_default_processing.

        CLEAR: siv_context_rff_ave.

* Try to get meter number from source step only for ES101 or EC101
        IF ( ( gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_es101 OR
               gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_ec101 ) AND
            sis_os_data IS INITIAL ).

*   Component meter_dev could be filled in other method(meter_number)
          IF gs_process_step_data-meter_dev IS NOT INITIAL.
            RETURN.
          ENDIF.

          SORT gs_process_data_src-meter_dev BY item_id ext_ui meternumber.
          LOOP AT gs_process_data_src-meter_dev INTO ls_meter_device_src.
            ls_meter_device-item_id = siv_itemid.
            CALL FUNCTION 'CONVERSION_EXIT_GERNR_OUTPUT'
              EXPORTING
                input  = ls_meter_device_src-meternumber
              IMPORTING
                output = ls_meter_device-meternumber.

*     In DE, meternumber is always filled, but still need to edit mdev_id_count
*     for it will be used in mapping exit
            IF ( ls_meter_device-item_id = ls_meter_device_bak-item_id ) AND
               ( ls_meter_device-ext_ui = ls_meter_device_bak-ext_ui ) AND
               ( ls_meter_device-meternumber = ls_meter_device_bak-meternumber ).
              ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count.
            ELSE.
              ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count + 1.
            ENDIF.

            APPEND ls_meter_device TO gs_process_step_data-meter_dev.
            ls_meter_device_bak = ls_meter_device.
          ENDLOOP.

          SORT gs_process_step_data-meter_dev BY item_id ext_ui meternumber mdev_id_count.
          DELETE ADJACENT DUPLICATES FROM gs_process_step_data-meter_dev
                                COMPARING item_id ext_ui meternumber mdev_id_count.

        ELSEIF ( ( gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_es101 OR
                   gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_ec101 ) AND
                sis_os_data IS NOT INITIAL ). "Weiche für Online Services
          ls_meter_device-item_id = siv_itemid.
          ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count + 1.

          CALL FUNCTION 'CONVERSION_EXIT_GERNR_OUTPUT'
            EXPORTING
              input  = sis_os_data-sernr
            IMPORTING
              output = ls_meter_device-meternumber.
          APPEND ls_meter_device TO gs_process_step_data-meter_dev.
        ELSEIF gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_eb103.
          LOOP AT gs_process_step_data-pod INTO ls_pod.
            LOOP AT gs_process_data_src-meter_dev INTO ls_meter_device_src.
              READ TABLE gs_process_step_data-meter_dev ASSIGNING <fs_meter_device>
                WITH KEY item_id       = siv_itemid
                         meternumber   = ls_meter_device_src-meternumber.
              IF sy-subrc = 0.
                <fs_meter_device> = ls_meter_device_src.
              ELSE.
                ls_meter_device_src-item_id = siv_itemid.
                APPEND ls_meter_device_src TO gs_process_step_data-meter_dev.
              ENDIF.
            ENDLOOP.
          ENDLOOP.
        ENDIF.

        IF gs_process_step_data-meter_dev IS NOT INITIAL.
          RETURN.
        ENDIF.

        IF sit_meter_proc_details IS INITIAL.
          CALL METHOD me->get_metering_procedure_details( ).
        ENDIF.

        READ TABLE sit_meter_proc_details INTO ls_meter_proc_details
                              WITH KEY item_id = siv_itemid.

* Determine all devices (meter as well as non-meter devices)
        me->get_device_register_data( ).

        LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.
          IF ls_pod_dev_relation-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
            CONTINUE.
          ENDIF.

          IF gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_eb101
            OR gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_eb103
            OR gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_es103
            OR gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_cd013
            OR gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_cd023.
            IF ls_meter_proc_details-meter_proc = /idxgc/if_check_method_add=>gc_meter_proc_z29.
              CONTINUE.
            ENDIF.
          ENDIF.

* get the meters (not other devices)
          LOOP AT ls_pod_dev_relation-device_data INTO ls_device_data
            WHERE metertype = /idexge/if_constants_dp=>gc_cci_meter_type.

*     Fill meter device structure
            IF siv_context_rff_ave IS INITIAL.
              siv_context_rff_ave = /idxgc/if_constants_ide=>gc_seq_action_code_z03.
            ENDIF.


            READ TABLE gs_process_step_data-meter_dev TRANSPORTING NO FIELDS
                  WITH KEY item_id = siv_itemid
                           meternumber = ls_device_data-geraet.
            IF sy-subrc <> 0.
              ls_meter_device-item_id = siv_itemid.
              CALL FUNCTION 'CONVERSION_EXIT_GERNR_OUTPUT'
                EXPORTING
                  input  = ls_device_data-geraet
                IMPORTING
                  output = ls_meter_device-meternumber.
*       In DE, meternumber is always filled, but still need to edit mdev_id_count
*       for it will be used in mapping exit
              IF ( ls_meter_device-ext_ui = ls_meter_device_bak-ext_ui ) AND
                 ( ls_meter_device-meternumber = ls_meter_device_bak-meternumber ).
                ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count.
              ELSE.
                ls_meter_device-mdev_id_count = ls_meter_device_bak-mdev_id_count + 1.
              ENDIF.

              APPEND ls_meter_device TO gs_process_step_data-meter_dev.
              ls_meter_device_bak = ls_meter_device.
            ENDIF.
*>>>SCHMIDT.C 20150303 Mengenumwerter werden in Solingen anders ermittelt
*            IF ls_device_data-metertype EQ /idexge/if_constants_dp=>gc_cci_meter_type.
**     Read ETYP to determine the meter type (pure meter or combination of meter and corrector)
*              CALL FUNCTION 'ISU_DB_ETYP_SINGLE'
*                EXPORTING
*                  x_matnr      = ls_device_data-matnr
*                IMPORTING
*                  y_etyp       = ls_etyp
*                EXCEPTIONS
*                  not_found    = 1
*                  system_error = 2
*                  OTHERS       = 3.
**       Combination of meter and corrector - corrector type exists
**       Fill non-meter device structure in addition to meter structure
*              IF sy-subrc = 0 AND ls_etyp-/idexge/corrector_type IS NOT INITIAL.
*                CHECK gs_process_step_data-spartyp = /idxgc/if_constants_add=>gc_divcat_gas.
*                ls_non_meter_device-item_id        = siv_itemid.
*                ls_non_meter_device-device_qual    = /idxgc/if_constants_ide=>gc_seq_action_code_z09.
*                ls_non_meter_device-meternumber    = ls_device_data-geraet.
*                ls_non_meter_device-device_number  = ls_device_data-geraet.
*                ls_non_meter_device-corrector_type = ls_etyp-/idexge/corrector_type.
*                APPEND ls_non_meter_device TO gs_process_step_data-non_meter_dev.
*              ENDIF.
*            ENDIF.
          ENDLOOP.
        ENDLOOP.

        SORT gs_process_step_data-meter_dev BY item_id ext_ui meternumber mdev_id_count.
        DELETE ADJACENT DUPLICATES FROM gs_process_step_data-meter_dev
                              COMPARING item_id ext_ui meternumber mdev_id_count.
      WHEN OTHERS.
* DO NOTHING.
    ENDCASE.

* 2.Check whether the field is mandatory, otherwise raise exception for empty field
    IF siv_mandatory_data IS NOT INITIAL AND gs_process_step_data-meter_dev IS INITIAL.
      IF sit_meter_proc_details IS INITIAL.
        CALL METHOD me->get_metering_procedure_details( ).
      ENDIF.
      READ TABLE sit_meter_proc_details INTO ls_meter_proc_details
                            WITH KEY item_id = siv_itemid.
      IF ls_meter_proc_details-meter_proc <> /idxgc/if_check_method_add=>gc_meter_proc_z29.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD METERING_OPERATION_SERVICE.
    ">>>SCHMIDT.C 20150204 MSB / MDL stehen an den ZEDM-Zeitscheiden

    DATA: ls_service_provider TYPE /idxgc/s_service_provider,
          ls_msb              TYPE eservprov,
          lv_codelistid       TYPE e_edmideextcodelistid.

    FIELD-SYMBOLS: <fs_pod_dev_relation> TYPE /idxgc/s_pod_dev_relation.

    CLEAR: siv_context_rff_ave.

    TRY.
        LOOP AT sit_pod_dev_relation ASSIGNING <fs_pod_dev_relation>.

          IF <fs_pod_dev_relation>-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
            CONTINUE.
          ENDIF.

          me->lr_isu_pod = get_pod_ref( iv_int_ui = <fs_pod_dev_relation>-int_ui iv_keydate = gs_process_step_data-proc_date ).

          IF lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_z29.
            CONTINUE.
          ENDIF.

          ls_msb = lr_isu_pod->get_msb( ).

*>>> THIMEL.R 20150407 Mantis 4877 Austausch gegen FuBa
*          CASE ls_mdl-externalid(1).
*            WHEN '9'.
*              lv_codelistid = cl_isu_datex_co=>co_vdew.
*            WHEN OTHERS.
*              lv_codelistid = cl_isu_datex_co=>co_ean.
*          ENDCASE.
          CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
            EXPORTING
              x_ext_idtyp     = ls_msb-externalidtyp
            IMPORTING
              y_extcodelistid = lv_codelistid
            EXCEPTIONS
              not_supported   = 1
              error_occured   = 2
              OTHERS          = 3.
          IF sy-subrc <> 0.
            MESSAGE e038(/idxgc/ide_add) WITH text-021 INTO gv_mtext.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
          ENDIF.
*<<< THIMEL.R 20150407 Mantis 4877

          IF ls_msb-externalid IS INITIAL.
            MESSAGE e038(/idxgc/ide_add) WITH text-021 INTO gv_mtext.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
          ENDIF.

          ls_service_provider-serviceid = ls_msb-serviceid.
          ls_service_provider-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_deb.
          ls_service_provider-externalid = ls_msb-externalid.
          ls_service_provider-sec_ext_id = ls_msb-sec_ext_id.
          ls_service_provider-codelist_agency = lv_codelistid.
          APPEND ls_service_provider TO <fs_pod_dev_relation>-service_provider.

          IF siv_context_rff_ave IS INITIAL.
            siv_context_rff_ave = /idxgc/if_constants_ide=>gc_nad_qual_deb.
          ENDIF.

          CLEAR: ls_msb, lv_codelistid.
        ENDLOOP.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD METERING_PROCEDURE.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF02
    "Form: hole_metmethod
    DATA: ls_diverse   TYPE /idxgc/s_diverse_details,
          lv_metmethod TYPE /idxgc/de_meter_proc.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-meter_proc IS NOT INITIAL.
        lv_metmethod = ls_diverse-meter_proc.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lv_metmethod IS INITIAL.
          lv_metmethod = lr_isu_pod->get_metmethod( ).
        ENDIF.

        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
        IF <fs_diverse> IS ASSIGNED.
          <fs_diverse>-meter_proc = lv_metmethod.
        ELSE.
          ls_diverse-item_id = siv_itemid.
          ls_diverse-meter_proc = lv_metmethod.
          APPEND ls_diverse TO gs_process_step_data-diverse.
        ENDIF.

      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD METER_NUMBER.
*    TRY.
*        CALL METHOD super->meter_number.
*      CATCH /idxgc/cx_process_error .
*    ENDTRY.
  ENDMETHOD.


  METHOD METER_TYPE.
    ">>>SCHMIDT.C 20150203 Antwort auf EoG schon in der Sequenzgruppe SEQ Z03 gefüllt
    IF gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb103.
      super->meter_type( ).
    ENDIF.

  ENDMETHOD.


  METHOD METER_VOLUME.
    ">>>SCHMIDT.C 20150203 Antwort auf EoG schon in der Sequenzgruppe SEQ Z03 gefüllt
    IF gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb103.
      super->meter_volume( ).
    ENDIF.
  ENDMETHOD.


  METHOD MOS_BASIC_RESPONSIBILITY.
    ">>>SCHMIDT.C 20150204 JA / NEIN Entscheidung erweitert

    DATA: ls_pod_dev_relation  TYPE /idxgc/s_pod_dev_relation,
          ls_service_provider  TYPE /idxgc/s_service_provider,
          ls_marketpartner_add TYPE /idxgc/s_marpaadd_details,
          lt_marketpartner_add TYPE /idxgc/t_marpaadd_details,
          lv_party_identifier  TYPE dunsnr,
          lv_mp_counter        TYPE /idxgc/de_mp_counter,
          lv_abr_n_messzv      TYPE char4.

    FIELD-SYMBOLS: <fs_marketpartner_add> TYPE /idxgc/s_marpaadd_details.

    LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.

      IF ls_pod_dev_relation-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
        CONTINUE.
      ENDIF.

      LOOP AT ls_pod_dev_relation-service_provider INTO ls_service_provider
              WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_deb.

        SELECT COUNT(*) FROM zlw_msd_msb_eig WHERE externalid = ls_service_provider-externalid.
        IF sy-subrc = 0.
          lv_abr_n_messzv = /idxgc/if_constants_ide=>gc_de_yes.
        ELSE.
          lv_abr_n_messzv = /idxgc/if_constants_ide=>gc_de_no.
        ENDIF.

        READ TABLE gs_process_step_data-marketpartner_add ASSIGNING <fs_marketpartner_add>
              WITH KEY item_id = siv_itemid
                       party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_deb
                       ext_ui = ls_pod_dev_relation-ext_ui
                       serviceid = ls_service_provider-serviceid.
        IF sy-subrc = 0.
          <fs_marketpartner_add>-mos_is_default = lv_abr_n_messzv.
        ELSE.
          ls_marketpartner_add-item_id = siv_itemid.
          ls_marketpartner_add-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_deb.
          ls_marketpartner_add-ext_ui = ls_pod_dev_relation-ext_ui.
          ls_marketpartner_add-party_identifier = ls_service_provider-externalid.
          ls_marketpartner_add-serviceid = ls_service_provider-serviceid.
          ls_marketpartner_add-mos_is_default = lv_abr_n_messzv.
          IF ls_service_provider-codelist_agency IS INITIAL.
            ls_marketpartner_add-codelist_agency = /idxgc/if_constants_ide=>gc_codelist_agency_293.
          ELSE.
            ls_marketpartner_add-codelist_agency = ls_service_provider-codelist_agency.
          ENDIF.
          APPEND ls_marketpartner_add TO lt_marketpartner_add.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    SORT lt_marketpartner_add BY party_identifier ASCENDING.
    LOOP AT lt_marketpartner_add INTO ls_marketpartner_add.
      IF lv_party_identifier <> ls_marketpartner_add-party_identifier.
        lv_party_identifier = ls_marketpartner_add-party_identifier.
        lv_mp_counter = lv_mp_counter + 1.
      ENDIF.

      ls_marketpartner_add-mp_counter = lv_mp_counter.
      APPEND ls_marketpartner_add TO gs_process_step_data-marketpartner_add.
    ENDLOOP.

  ENDMETHOD.


  METHOD NEXT_POSSIBLE_DATE.
    ">>>SCHMIDT.C 20150127
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_possend

    DATA: ls_diverse     TYPE /idxgc/s_diverse_details,
          ls_diverse_src TYPE /idxgc/s_diverse_details,
          ls_eideswtdoc  TYPE eideswtdoc,
          lv_possenddate TYPE dats.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse_src WITH KEY item_id = siv_itemid.
      IF ls_diverse_src-endnextposs_from IS NOT INITIAL.
        lv_possenddate = ls_diverse_src-endnextposs_from.
      ENDIF.
    ENDIF.

    TRY.
        IF lv_possenddate IS NOT INITIAL.
          IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ec101.
            "Daten sollten aus dem Workflow kommen und im Mapping gefüllt werden
          ELSEIF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_ec103.
            READ TABLE gs_process_data_src-diverse INTO ls_diverse_src WITH KEY item_id = siv_itemid.
            IF ls_diverse_src-endnextposs_from IS NOT INITIAL.
              READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
              IF <fs_diverse> IS ASSIGNED.
                IF <fs_diverse>-msgtransreason = zif_agc_datex_utilmd_co=>gc_trans_reason_code_z01.
                  "Der nächstmögliche Termin wird in den Wechselbelegkopf geschrieben <<<ACHTUNG Wenn Prozess komplett auf Common-Layer gehen muss das geändert werden!!!!
                  SELECT SINGLE * FROM eideswtdoc INTO ls_eideswtdoc WHERE switchnum = gs_process_step_data-proc_ref.
                  lv_possenddate = ls_eideswtdoc-moveoutdate.
                ELSE.
                  lv_possenddate = ls_diverse_src-endnextposs_from.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
        IF <fs_diverse> IS ASSIGNED.
          IF <fs_diverse>-contr_end_date IS INITIAL.
            <fs_diverse>-endnextposs_from = lv_possenddate.
          ENDIF.
        ELSE.
          ls_diverse-item_id = siv_itemid.
          ls_diverse-endnextposs_from = lv_possenddate.
          APPEND ls_diverse TO gs_process_step_data-diverse.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD NEXT_PROCESSING_DATE.
    ">>>SCHMIDT.C 20150107 Wird aus dem Workflow übergeben und im Mapping gesetzt
  ENDMETHOD.


  METHOD NOTES_TO_TRANSACTION.
*--------------------------------------------------------------------*
* Die gesamte Logik zur Ermittlung des Nachrichtenkommentars (FTX+ACB)
* wurde aus dem FuBa Z_LW_GET_MESSAGEDATA und seinen Unterprogrammen
* soweit wie möglich und notig übernommen und wird in der Klasse
* ZCL_AGC_COMMENT_BUILDER abgebildet.
*
* Die Kommentargenerierung erfolgt vorgangsbezogen (je nach BMID).
*--------------------------------------------------------------------*

    DATA: ls_rejection_list TYPE        /idxgc/s_rejection_details,
          ls_msgcomments    TYPE        /idxgc/s_msgcom_details,
          lr_typedescr      TYPE REF TO cl_abap_typedescr,
          lr_classdescr     TYPE REF TO cl_abap_classdescr,
          lv_methname       TYPE        abap_methname,
          lv_comment        TYPE        /idxgc/de_free_text_value.

    FIELD-SYMBOLS:
      <fs_process_step_data> TYPE /idxgc/s_msgcom_details.


*--------------------------------------------------------------------*
* 1. Beschreibung der Klasse ZCL_AGC_COMMENT_BUILDER lesen
*--------------------------------------------------------------------*
    CALL METHOD cl_abap_typedescr=>describe_by_name
      EXPORTING
        p_name         = 'ZCL_AGC_COMMENT_BUILDER'
      RECEIVING
        p_descr_ref    = lr_typedescr
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lr_classdescr ?= lr_typedescr.

*--------------------------------------------------------------------*
* 2. Prüfen, ob es zum BMID eine Methode mit vorgangsbezogener
*    Kommentarfindung gibt
*--------------------------------------------------------------------*
    CONCATENATE 'GET_COMMENT_' gs_process_step_data-bmid INTO lv_methname.

    READ TABLE lr_classdescr->methods TRANSPORTING NO FIELDS WITH KEY name = lv_methname.

*--------------------------------------------------------------------*
* 3. Falls ja, dann diese ausführen
*--------------------------------------------------------------------*
    CHECK sy-subrc EQ 0.

    CALL METHOD zcl_agc_comment_builder=>(lv_methname)
      EXPORTING
        is_proc_step_data       = gs_process_step_data
        is_proc_data_src_add    = gs_process_data_src_add
        is_proc_data_src        = gs_process_data_src
        iv_data_from_add_source = siv_data_from_add_source
        iv_itemid               = siv_itemid
      RECEIVING
        rv_comment              = lv_comment.

*   rausgehen, falls kein Kommentar ermittelt wurde
    CHECK lv_comment IS NOT INITIAL.

*--------------------------------------------------------------------*
* 4.a ggf. den in den Prozessdaten bereits vorhandenen Kommentar um den
*     ermittelten ergänzen
*--------------------------------------------------------------------*
    LOOP AT gs_process_step_data-msgcomments
      ASSIGNING <fs_process_step_data>
      WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.

      CONCATENATE lv_comment <fs_process_step_data>-free_text_value
        INTO <fs_process_step_data>-free_text_value
        SEPARATED BY space.

      EXIT.
    ENDLOOP.

*--------------------------------------------------------------------*
* 4.b sonst den ermittelten Kommentar übernehmen
*--------------------------------------------------------------------*
    IF sy-subrc NE 0.
      ls_msgcomments-text_subj_qual  = /idxgc/if_constants_ide=>gc_msg_comments_acb.
      ls_msgcomments-item_id         = siv_itemid.
      ls_msgcomments-commentnum      = ls_msgcomments-commentnum + 1.
      ls_msgcomments-free_text_value = lv_comment.
      APPEND ls_msgcomments TO gs_process_step_data-msgcomments.
    ENDIF.

  ENDMETHOD.


  METHOD OBIS_DATA_SEQ.
    DATA: ls_reg_code_data_src TYPE /idxgc/s_reg_code_details.

    FIELD-SYMBOLS: <fs_reg_code_data> TYPE /idxgc/s_reg_code_details.

    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      LOOP AT gs_process_data_src-reg_code_data INTO ls_reg_code_data_src.
        READ TABLE gs_process_step_data-pod TRANSPORTING NO FIELDS
          WITH KEY ext_ui = ls_reg_code_data_src-ext_ui.
        CHECK sy-subrc = 0.
        ls_reg_code_data_src-item_id = siv_itemid.

        READ TABLE gs_process_step_data-reg_code_data ASSIGNING <fs_reg_code_data>
          WITH KEY item_id     = siv_itemid
                   meternumber = ls_reg_code_data_src-meternumber
                   reg_code    = ls_reg_code_data_src-reg_code
                   ext_ui      = ls_reg_code_data_src-ext_ui.
        IF sy-subrc = 0.
          <fs_reg_code_data> = ls_reg_code_data_src.
        ELSE.
          APPEND ls_reg_code_data_src TO gs_process_step_data-reg_code_data.
        ENDIF.
      ENDLOOP.

    ELSE.
      super->obis_data_seq( ).
    ENDIF.

  ENDMETHOD.


  METHOD OFF_PEAK_ENABLED.

    ">>>SCHMIDT.C 20150203 Anpassung an Zählverfahrenabfrage

    DATA: ls_register_code TYPE tekennziff,
          lv_mtext         TYPE string.

    FIELD-SYMBOLS: <fs_reg_code_data> TYPE /idxgc/s_reg_code_details.

    "Bei der Antwort auf EoG wurden die Daten bereits aus dem Quellschritt übernommen
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      RETURN.
    ENDIF.

    TRY.

        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom AND
           ( lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02 OR
             lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14 ).

          CHECK lines( gs_process_step_data-reg_code_data ) > 1.

          LOOP AT gs_process_step_data-reg_code_data ASSIGNING <fs_reg_code_data>.

            CALL FUNCTION 'ISU_DB_TEKENNZIFF_SINGLE'
              EXPORTING
                im_spartyp    = gs_process_step_data-spartyp
                im_kennziff   = <fs_reg_code_data>-reg_code
              IMPORTING
                ex_tekennziff = ls_register_code
              EXCEPTIONS
                not_found     = 1
                general_fault = 2
                OTHERS        = 3.

            IF sy-subrc = 0.
              IF ls_register_code-eusage = /idxgc/if_constants_ide=>gc_eusage_on_peak.       "'001'
                <fs_reg_code_data>-tarif_alloc = /idexge/if_constants_dp=>gc_assign_on_peak.
              ELSEIF ls_register_code-eusage = /idxgc/if_constants_ide=>gc_eusage_off_peak.  "'002'
                <fs_reg_code_data>-tarif_alloc = /idexge/if_constants_dp=>gc_assign_off_peak.
              ENDIF.
            ENDIF.

          ENDLOOP.

        ENDIF.

      CATCH zcx_agc_masterdata /idxgc/cx_process_error.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD PARTNER_NAME.
    ">>>SCHMIDT.C 2015024 Anpassung wegen Partnerformat (Alle GP sind als Organisation angelegt) und wegen Vor- und Nachnamentausch

    DATA:
      ls_bus000           TYPE bus000,
      ls_but000           TYPE but000,
      lv_bu_partner       TYPE bu_partner,
      lv_title_aca1       TYPE ad_title1t,
      ls_name_address     TYPE /idxgc/s_nameaddr_details,
      ls_name_address_src TYPE /idxgc/s_nameaddr_details,
      lv_class_name       TYPE seoclsname,
      lv_method_name      TYPE seocpdname,
      lv_msgtext          TYPE string,
      ls_zbus000_anrede   TYPE zbus000_anrede,
      lv_partnerformat    TYPE char3.

    FIELD-SYMBOLS:
      <fs_name_address> TYPE /idxgc/s_nameaddr_details.

* In case of ES101, get data directly from srouce step data
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es301. "Abmeldeanfrage aus dem Netz. GP wird im Prozess erst später angelegt nach der Antwort auf die Abmeldeanfrage

*   Should get the data from source step
      READ TABLE gs_process_data_src-name_address INTO ls_name_address_src
            WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.

      IF sy-subrc = 0.

        ls_name_address-bpkind = ls_name_address_src-bpkind.
        ls_name_address-name_format_code = ls_name_address_src-name_format_code.
        ls_name_address-ad_title_ext = ls_name_address_src-ad_title_ext.
        ls_name_address-fam_comp_name1 = ls_name_address_src-fam_comp_name1.
        ls_name_address-fam_comp_name2 = ls_name_address_src-fam_comp_name2.
        ls_name_address-first_name1 = ls_name_address_src-first_name1.
        ls_name_address-first_name2 = ls_name_address_src-first_name2.

      ENDIF.

    ENDIF.

* Cannot get the data from source step data
    IF ls_name_address IS INITIAL.

      READ TABLE gs_process_data_src-name_address INTO ls_name_address_src
            WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.

*   Get business partner information
      lv_bu_partner = gs_process_data_src-bu_partner .
      IF lv_bu_partner IS NOT INITIAL.

        CALL FUNCTION 'BUP_PARTNER_GET'
          EXPORTING
            i_partner         = lv_bu_partner
          IMPORTING
            e_but000          = ls_bus000
          EXCEPTIONS
            partner_not_found = 1
            wrong_parameters  = 2
            internal_error    = 3
            OTHERS            = 4.
      ENDIF.

      MOVE-CORRESPONDING ls_bus000 TO ls_but000.
      CLEAR ls_but000-title. "Titel sind in aller Regel nicht korrekt gefüllt. Daher löschen und anhand der Logik neu ermitteln

      "Wir haben immer eine Organisation
      CALL FUNCTION 'Z_ZBUP_BUPA_NAME_CHECK'
        EXPORTING
          i_but000         = ls_but000
          i_only_initial   = abap_true
        IMPORTING
          e_zbus000_anrede = ls_zbus000_anrede
        EXCEPTIONS
          not_found        = 1
          multi_found      = 2
          title_found      = 3
          no_title         = 4
          OTHERS           = 5.
      CASE sy-subrc.
        WHEN 0.
        WHEN 2.
          ls_zbus000_anrede-title = 'HRFR'.
        WHEN OTHERS.
          ls_zbus000_anrede-title = 'NON'.
      ENDCASE.

      CASE ls_zbus000_anrede-title.
        WHEN 'HR' OR 'FR' OR 'FD' OR 'HD' OR 'EH' OR 'FA' OR 'HRFR'.
          lv_partnerformat = /idxgc/if_constants_ide=>gc_name_format_code_person.
        WHEN OTHERS.
          lv_partnerformat = /idxgc/if_constants_ide=>gc_name_format_code_company.
      ENDCASE.

      CASE lv_partnerformat.
        WHEN /idxgc/if_constants_ide=>gc_name_format_code_person.
          ls_name_address-fam_comp_name1 = ls_bus000-name_org2.
          ls_name_address-fam_comp_name2 = ls_bus000-name_org3.
          ls_name_address-first_name1 = ls_bus000-name_org1.
          ls_name_address-first_name2 = ls_bus000-name_org4.
          ls_name_address-name_format_code = lv_partnerformat.         "Wolf.A., Mantis 4953
        WHEN /idxgc/if_constants_ide=>gc_name_format_code_company.
          ls_name_address-fam_comp_name1   = ls_bus000-name_org1.
          ls_name_address-fam_comp_name2   = ls_bus000-name_org2.
          ls_name_address-name_format_code = lv_partnerformat.         "Wolf.A., Mantis 4953
      ENDCASE.

      ls_name_address-bpkind = ls_bus000-type.

* >>> Wolf.A., adesso AG, 19.06.2015, Mantis 4953. Wenn die beiden Partnerformate unterschiedlich sind, und somit das Format
* aus der Source übernommen wird, gleichzeitig aber andere Felder befüllt werden (siehe obige CASE-Anweisung), kann es dazu führen,
* dass im anderen Mandant der Geschäftspartner nicht autom. angelegt werden kann. Nach Abstimmung mit Hr. Mones erfolgt folgende Anpassung:
*
*      IF ls_name_address_src-name_format_code <> lv_partnerformat AND ls_name_address_src-name_format_code IS NOT INITIAL.
*        ls_name_address-name_format_code = ls_name_address_src-name_format_code.
*      ELSE.
*        ls_name_address-name_format_code = lv_partnerformat.
*      ENDIF.
* <<< Wolf.A., adesso AG, 19.06.2015, Mantis 4953.

* Get academic title 1
      IF ls_bus000-title_aca1 IS NOT INITIAL.
        CALL FUNCTION 'ADDR_TSAD2_READ'
          EXPORTING
            title_key     = ls_bus000-title_aca1
          IMPORTING
            title_text    = lv_title_aca1
          EXCEPTIONS
            key_not_found = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          CLEAR: lv_title_aca1.
        ENDIF.
        ls_name_address-ad_title_ext = ls_bus000-title_aca1.
      ENDIF.

    ENDIF.

* Cannot get the correct data
    IF ls_name_address IS INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH text-006 INTO lv_msgtext.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

    READ TABLE gs_process_step_data-name_address
      ASSIGNING <fs_name_address> WITH KEY item_id = siv_itemid
                                   party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
    IF sy-subrc = 0.
      <fs_name_address>-first_name1    = ls_name_address-first_name1.
      <fs_name_address>-first_name2    = ls_name_address-first_name2.
      <fs_name_address>-fam_comp_name1 = ls_name_address-fam_comp_name1.
      <fs_name_address>-fam_comp_name2 = ls_name_address-fam_comp_name2.
      <fs_name_address>-ad_title_ext   = ls_name_address-ad_title_ext.

    ELSE.
      ls_name_address-item_id         = siv_itemid.
      ls_name_address-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
      APPEND ls_name_address TO gs_process_step_data-name_address.
    ENDIF.


  ENDMETHOD.


  METHOD PAYER_GRID_USAGE.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_zz_zahler

    "Hinweis: Diese Methode ist identisch mit der Methode PAYER_OF_GRID_USAGE.
    "Aus irgendeinem Grund benutzt die SAP im GNS-Customizing auf Vertriebsseite die Methode PAYER_OF_GRID_USAGE. Auf der Netzseite allerdings wird diese Methode durchlaufen.
    "Bitte beachten und evtl. Entwicklungen parallel durchführen.

    DATA: ls_diverse         TYPE /idxgc/s_diverse_details,
          lv_gridus_contrpay TYPE /idxgc/de_gridus_contrpay,
          ls_ever            TYPE ever.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103 OR "Antwort auf EoG
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es103. "Antwort auf Anmeldung NN

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-gridus_contrpay IS NOT INITIAL.
        lv_gridus_contrpay = ls_diverse-gridus_contrpay.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lv_gridus_contrpay IS INITIAL.
          ls_ever = lr_isu_pod->get_ever( ).
          IF ls_ever-zz_nn_direkt = abap_true.
            lv_gridus_contrpay = /idxgc/if_constants_ide=>gc_agr_01_agree_tpcode_e09.
          ELSE.
            lv_gridus_contrpay = /idxgc/if_constants_ide=>gc_agr_01_agree_tpcode_e10.
          ENDIF.
        ENDIF.

        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
        IF <fs_diverse> IS ASSIGNED.
          <fs_diverse>-gridus_contrpay = lv_gridus_contrpay.
        ELSE.
          ls_diverse-item_id         = siv_itemid.
          ls_diverse-gridus_contrpay = lv_gridus_contrpay.
          APPEND ls_diverse TO gs_process_step_data-diverse.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD PAYER_OF_GRID_USAGE.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_zz_zahler

    "Hinweis: Diese Methode ist identisch mit der Methode PAYER_GRID_USAGE.
    "Aus irgendeinem Grund benutzt die SAP im GNS-Customizing auf Netzseite die Methode PAYER_GRID_USAGE. Auf der Vertriebsseite allerdings wird diese Methode durchlaufen.
    "Bitte beachten und evtl. Entwicklungen parallel durchführen.

    DATA: ls_diverse         TYPE /idxgc/s_diverse_details,
          lv_gridus_contrpay TYPE /idxgc/de_gridus_contrpay,
          ls_ever            TYPE ever.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103 OR "Antwort auf EoG
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es103. "Antwort auf Anmeldung NN

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-gridus_contrpay IS NOT INITIAL.
        lv_gridus_contrpay = ls_diverse-gridus_contrpay.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lv_gridus_contrpay IS INITIAL.
          ls_ever = lr_isu_pod->get_ever( ).
          IF ls_ever-zz_nn_direkt = abap_true.
            lv_gridus_contrpay = /idxgc/if_constants_ide=>gc_agr_01_agree_tpcode_e09.
          ELSE.
            lv_gridus_contrpay = /idxgc/if_constants_ide=>gc_agr_01_agree_tpcode_e10.
          ENDIF.
        ENDIF.

        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
        IF <fs_diverse> IS ASSIGNED.
          <fs_diverse>-gridus_contrpay = lv_gridus_contrpay.
        ELSE.
          ls_diverse-item_id         = siv_itemid.
          ls_diverse-gridus_contrpay = lv_gridus_contrpay.
          APPEND ls_diverse TO gs_process_step_data-diverse.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD PLANNED_PERIODIC_READING.
    ">>>SCHMIDT.C 20150107
    "INCLUDE: LZ_LW_CONTAINERFUBASF01
    "FORM: hole_next_abl

    DATA: lv_adatsoll          TYPE dats,
          lv_abdatum           TYPE dats,
          lv_bisdatum          TYPE dats,
          lv_stelle            TYPE i,
          lv_planned_perio_red TYPE dats,
          lv_mtext             TYPE string,
          ls_diverse           TYPE /idxgc/s_diverse_details.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-nextmr_date IS NOT INITIAL.
        lv_planned_perio_red = ls_diverse-nextmr_date.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF me->lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02 OR
           me->lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14.

          IF lv_planned_perio_red IS INITIAL.
            CHECK: gr_inst IS NOT INITIAL.
            "Get next meter reading date
            CALL METHOD gr_inst->get_next_meterread_date
              EXPORTING
                x_keydate       = gs_process_step_data-proc_date
              IMPORTING
                y_mr_date       = lv_adatsoll
              EXCEPTIONS
                invalid_object  = 1
                keydate_invalid = 2
                not_found       = 3
                not_selected    = 4
                OTHERS          = 5.
            IF sy-subrc <> 0.
              MESSAGE e038(/idxgc/ide_add) WITH text-020 INTO lv_mtext.
              /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
            ENDIF.

            "-------------------ABDATUM--------------------
            lv_abdatum = lv_adatsoll.

            " 1 Woche abziehen.
            CALL FUNCTION 'ISU_DATE_MODIFIKATION'
              EXPORTING
                m_art       = '-'
                day         = '7'
              CHANGING
                date        = lv_abdatum
              EXCEPTIONS
                check_error = 1
                OTHERS      = 2.
            IF sy-subrc <> 0.
              MOVE lv_adatsoll TO lv_abdatum.
            ENDIF.

            " Wir müssen aber im gleichen Monat bleiben.
            IF lv_abdatum+4(2) NE lv_adatsoll+4(2).
              MOVE lv_adatsoll TO lv_abdatum.
              MOVE '01' TO lv_abdatum+6(2).
            ENDIF.

            "-------------------BISDATUM--------------------

            MOVE lv_adatsoll TO lv_bisdatum.

            " 1 Woche abziehen.
            CALL FUNCTION 'ISU_DATE_MODIFIKATION'
              EXPORTING
                m_art       = space
                day         = '7'
              CHANGING
                date        = lv_bisdatum
              EXCEPTIONS
                check_error = 1
                OTHERS      = 2.
            IF sy-subrc <> 0.
              MOVE lv_adatsoll TO lv_bisdatum.
            ENDIF.

            " Wir müssen aber im gleichen Monat bleiben.
            IF lv_bisdatum+4(2) NE lv_adatsoll+4(2).
              MOVE lv_adatsoll TO lv_bisdatum.
              " Letzter Kalendertag des Monats ist nicht nötig. der 28. ist immer in Woche 4
              MOVE '28' TO lv_bisdatum+6(2).
            ENDIF.

            " Ab-Datum
            MOVE lv_abdatum+4(2) TO lv_planned_perio_red+lv_stelle(2).
            ADD 2 TO lv_stelle.

*     Bestimmen der Woche
*     1 = Abl. vom 01. bis einschl. 07. Kalendertag
*     2 = Abl. vom 08. bis einschl. 14. Kalendertag
*     3 = Abl. vom 15. bis einschl. 21. Kalendertag
*     4 = Abl. vom 22. bis letzen Kalendertag.
            MOVE '0' TO lv_planned_perio_red+lv_stelle(1). " Erste W ist immer 0
            ADD 1 TO lv_stelle.
            IF  lv_abdatum+6(2) GE '01'
            AND lv_abdatum+6(2) LE '07'.
              MOVE '1' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_abdatum+6(2) GE '08'
            AND lv_abdatum+6(2) LE '14'.
              MOVE '2' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_abdatum+6(2) GE '15'
            AND lv_abdatum+6(2) LE '21'.
              MOVE '3' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_abdatum+6(2) GE '22'
            AND lv_abdatum+6(2) LE '31'.
              MOVE '4' TO lv_planned_perio_red+lv_stelle(1).
            ENDIF.
            ADD 1 TO lv_stelle.


            MOVE lv_bisdatum+4(2) TO lv_planned_perio_red+lv_stelle(2).
            ADD 2 TO lv_stelle.

*     Bestimmen der Woche
*     1 = Abl. vom 01. bis einschl. 07. Kalendertag
*     2 = Abl. vom 08. bis einschl. 14. Kalendertag
*     3 = Abl. vom 15. bis einschl. 21. Kalendertag
*     4 = Abl. vom 22. bis letzen Kalendertag.
            MOVE '0' TO lv_planned_perio_red+lv_stelle(1). " Erste W ist immer 0
            ADD 1 TO lv_stelle.

            IF  lv_bisdatum+6(2) GE '01'
            AND lv_bisdatum+6(2) LE '07'.
              MOVE '1' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_bisdatum+6(2) GE '08'
            AND lv_bisdatum+6(2) LE '14'.
              MOVE '2' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_bisdatum+6(2) GE '15'
            AND lv_bisdatum+6(2) LE '21'.
              MOVE '3' TO lv_planned_perio_red+lv_stelle(1).
            ELSEIF lv_bisdatum+6(2) GE '22'
            AND lv_bisdatum+6(2) LE '31'.
              MOVE '4' TO lv_planned_perio_red+lv_stelle(1).
            ENDIF.
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-nextmr_date = lv_planned_perio_red.
            IF strlen( lv_planned_perio_red ) = 4.
              <fs_diverse>-nextmr_period = /idxgc/if_constants_ide=>gc_dtm_format_code_106.
            ELSE.
              <fs_diverse>-nextmr_period = /idxgc/if_constants_ide=>gc_dtm_format_code_104.
            ENDIF.
          ELSE.
            ls_diverse-item_id = siv_itemid.
            ls_diverse-nextmr_date = lv_planned_perio_red.
            IF strlen( lv_planned_perio_red ) = 4.
              ls_diverse-nextmr_period = /idxgc/if_constants_ide=>gc_dtm_format_code_106.
            ELSE.
              ls_diverse-nextmr_period = /idxgc/if_constants_ide=>gc_dtm_format_code_104.
            ENDIF.
            APPEND ls_diverse TO gs_process_step_data-diverse.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD PLANNED_READING_PERIOD.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_turnus_intervall
*>>> THIMEL.R 20150421 M4859 Immer mitschicken (auch bei RLM) (+ Ablauf geändert für EoG da falsch)

    DATA:   ls_diverse         TYPE /idxgc/s_diverse_details,
            lv_mrperiod_length TYPE /idxgc/de_mrperiod_length,
            lv_msgtext         TYPE string,
            ls_v_eanl          TYPE v_eanl.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-mrperiod_length IS NOT INITIAL.
        lv_mrperiod_length = ls_diverse-mrperiod_length.
      ENDIF.
    ENDIF.

*        IF me->lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02 OR
*           me->lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14.

    IF lv_mrperiod_length IS INITIAL.
      TRY.
          me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

          ls_v_eanl = me->lr_isu_pod->get_v_eanl( ).

          IF ls_v_eanl-ableinh = 'A9999'.
            lv_mrperiod_length = 12.
          ELSE.
            lv_mrperiod_length = me->lr_isu_pod->get_period_length( ).
          ENDIF.

        CATCH zcx_agc_masterdata.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDTRY.
    ENDIF.

*        ENDIF.

    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
    IF <fs_diverse> IS ASSIGNED.
      <fs_diverse>-mrperiod_length = lv_mrperiod_length.
    ELSE.
      ls_diverse-item_id = siv_itemid.
      ls_diverse-mrperiod_length = lv_mrperiod_length.
      APPEND ls_diverse TO gs_process_step_data-diverse.
    ENDIF.

  ENDMETHOD.


  METHOD POINT_OF_DELIVERY.
    ">>>SCHMIDT.C 20150303 Kopie aus dem Standard mit Anpassung für no_ref_pod_data

    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

    CALL METHOD super->point_of_delivery.

    CASE gs_process_step_data-bmid.
      WHEN /idxgc/if_constants_ide=>gc_bmid_es101 OR       "Anmeldung NN
           /idxgc/if_constants_ide=>gc_bmid_ec103.         "Positive Antwort auf Kündigung
        LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod>.
          <fs_pod>-no_ref_pod_data = abap_true.
        ENDLOOP.
    ENDCASE.

  ENDMETHOD.


  METHOD PRESSURE_LEVEL.
    ">>>SCHMIDT.C 20150127 Druckstufe wird anhand einer Z-Tabelle ermittel. Standard kann so nicht genutzt werden

    DATA: ls_diverse        TYPE /idxgc/s_diverse_details,
          ls_lw_spebene     TYPE zlw_spebene,
          ls_v_eanl         TYPE v_eanl,
          lv_pressure_level TYPE /idxgc/de_press_level_offt.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-press_level_offt IS NOT INITIAL.
        lv_pressure_level = ls_diverse-press_level_offt.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.

          IF lv_pressure_level IS INITIAL.
            ls_v_eanl = lr_isu_pod->get_v_eanl( ).

            SELECT SINGLE * FROM zlw_spebene INTO ls_lw_spebene
              WHERE zz_mandt = sy-mandt AND
                    "spebene  = ls_v_eanl-spebene AND
                    sparte = ls_v_eanl-sparte AND
                    "zzespebene_ms = ls_v_eanl-zzespebene_ms AND
                    zzenetz1 = ls_v_eanl-zzenetz1.

            IF sy-subrc <> 0.
              /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
            ENDIF.
            lv_pressure_level = ls_lw_spebene-zz_spebene.
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-press_level_offt = lv_pressure_level.
          ELSE.
            ls_diverse-item_id = siv_itemid.
            ls_diverse-press_level_offt = lv_pressure_level.
            APPEND ls_diverse TO  gs_process_step_data-diverse.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD RATE_NUMBER.
    ">>>SCHMIDT.C 20150203 Antwort auf EoG schon in der Sequenzgruppe SEQ Z03 gefüllt
    IF gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb103.
      super->rate_number( ).
    ENDIF.
  ENDMETHOD.


  METHOD REFERENCE_TO_METER.

    DATA: ls_pod_dev_relation     TYPE        /idxgc/s_pod_dev_relation,
          ls_register_data        TYPE        /idxgc/s_register_data,
          ls_reg_code_data        TYPE        /idxgc/s_reg_code_details,
          ls_non_meter_device     TYPE        /idxgc/s_nonmeter_details,
          ls_non_meter_device_bak TYPE        /idxgc/s_nonmeter_details,
          ls_dev_meter            TYPE        /idxgc/s_device_data,
          ls_dev_transformer      TYPE        /idxgc/s_device_data,
          ls_dev_corrector        TYPE        /idxgc/s_device_data,
          ls_dev_comm_equip       TYPE        /idxgc/s_device_data,
          ls_dev_tech_contr       TYPE        /idxgc/s_device_data,
          lr_badi_access          TYPE REF TO /idxgc/badi_data_access,
          lr_badi_process         TYPE REF TO /idxgc/badi_md_chg_rep,
          lt_dev_list             TYPE        /idxgc/t_device_list,
          lt_reg_list             TYPE        /idxgc/t_reg_list,
          ls_reg_list_corrector   TYPE        /idxgc/s_reg_list,
          ls_reg_list_meter       TYPE        /idxgc/s_reg_list,
          lv_ref_dev_type         TYPE        /idxgc/de_ref_dev_type.

    FIELD-SYMBOLS:
      <fs_reg_code> TYPE /idxgc/s_reg_code_details.

    CASE siv_context_rff_ave.
*******************************************************************************
*   OBIS Data (Z02)
*******************************************************************************
      WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z02.

        LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.

          LOOP AT ls_pod_dev_relation-register_data INTO ls_register_data.

            IF ls_register_data-meternumber IS NOT INITIAL.
              SHIFT ls_register_data-meternumber LEFT DELETING LEADING '0'.
              MODIFY ls_pod_dev_relation-register_data FROM ls_register_data.
            ENDIF.

            READ TABLE ls_pod_dev_relation-device_data TRANSPORTING NO FIELDS WITH KEY geraet = ls_register_data-meternumber metertype = /idexge/if_constants_dp=>gc_cci_corrector.
            IF sy-subrc = 0.
              lv_ref_dev_type = /idxgc/if_constants_ide=>gc_rff_qual_z11.
            ELSE.
              lv_ref_dev_type = /idxgc/if_constants_ide=>gc_rff_qual_mg.
            ENDIF.

            READ TABLE gs_process_step_data-reg_code_data ASSIGNING <fs_reg_code>
                  WITH KEY item_id = siv_itemid
                           meternumber = ls_register_data-meternumber
                           reg_code = ls_register_data-kennziff.

            IF <fs_reg_code> IS ASSIGNED.
              <fs_reg_code>-ref_dev_type = lv_ref_dev_type.
              SHIFT <fs_reg_code>-meternumber LEFT DELETING LEADING '0'.
            ELSE.
              ls_reg_code_data-item_id = siv_itemid.
              ls_reg_code_data-ref_dev_type = lv_ref_dev_type.
              ls_reg_code_data-meternumber = ls_register_data-meternumber.
              SHIFT ls_reg_code_data-meternumber LEFT DELETING LEADING '0'.
              ls_reg_code_data-reg_code = ls_register_data-kennziff.
              APPEND ls_reg_code_data TO gs_process_step_data-reg_code_data.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

*******************************************************************************
*   Transformer Data (Z04)
*******************************************************************************
      WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z04.
        TRY.
            CALL METHOD super->reference_to_meter.
          CATCH /idxgc/cx_process_error .
        ENDTRY.

*******************************************************************************
*   Communication Equipment Data (Z05)
*******************************************************************************
      WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z05.
        TRY.
            CALL METHOD super->reference_to_meter.
          CATCH /idxgc/cx_process_error .
        ENDTRY.

*******************************************************************************
*   Data for Technical Control Equipment (Z06)
*******************************************************************************
      WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z06.
        TRY.
            CALL METHOD super->reference_to_meter.
          CATCH /idxgc/cx_process_error .
        ENDTRY.

*******************************************************************************
*   Corrector Data (Z09)
*******************************************************************************
      WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z09.

        LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.

          IF ls_pod_dev_relation-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
            CONTINUE.
          ENDIF.

          IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101.
            CHECK gs_process_data_src-reg_code_data IS NOT INITIAL.
          ENDIF.

          LOOP AT ls_pod_dev_relation-device_data INTO ls_dev_transformer
                  WHERE metertype = /idexge/if_constants_dp=>gc_cci_corrector.
            ls_non_meter_device-item_id = siv_itemid.
            ls_non_meter_device-device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z09.
            ls_non_meter_device-device_number = ls_dev_transformer-geraet.

            IF ( ls_non_meter_device-item_id = ls_non_meter_device_bak-item_id ) AND
               ( ls_non_meter_device-device_qual = ls_non_meter_device_bak-device_qual ) AND
               ( ls_non_meter_device-device_number = ls_non_meter_device_bak-device_number ).
              ls_non_meter_device-dev_id_count = ls_non_meter_device_bak-dev_id_count.
            ELSE.
              ls_non_meter_device-dev_id_count = ls_non_meter_device_bak-dev_id_count + 1.
            ENDIF.

            LOOP AT ls_pod_dev_relation-device_data INTO ls_dev_meter
                    WHERE metertype = /idexge/if_constants_dp=>gc_cci_meter_type.
              ls_non_meter_device-meternumber = ls_dev_meter-geraet.
              SHIFT ls_non_meter_device-meternumber LEFT DELETING LEADING '0'.

              READ TABLE gs_process_step_data-non_meter_dev TRANSPORTING NO FIELDS
                    WITH KEY item_id = siv_itemid
                             device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z04
                             meternumber = ls_dev_meter-geraet
                             device_number = ls_dev_transformer-geraet.
              IF sy-subrc <> 0.
                APPEND ls_non_meter_device TO gs_process_step_data-non_meter_dev.
                ls_non_meter_device_bak = ls_non_meter_device.
              ENDIF.

            ENDLOOP.
          ENDLOOP.
        ENDLOOP.

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.


  method REFERENCE_TO_METER_DDE.
    ">>>SCHMIDT.C 20150204 Nicht relevant s.h. MSB
  endmethod.


  METHOD REFERENCE_TO_METER_DEB.
    ">>>SCHMIDT.C 20150204 Wird nicht verwendet, da in Solingen nie für unterschiedliche Zähler auch unterschiedliche MSB zuständig sind
  ENDMETHOD.


  METHOD REFERENCE_TO_OBIS.

    DATA: ls_pod_dev_relation TYPE /idxgc/s_pod_dev_relation,
          ls_register_data    TYPE /idxgc/s_register_data,
          ls_charges          TYPE /idxgc/s_reg_code_details.

    FIELD-SYMBOLS:
      <fs_charges> TYPE /idxgc/s_charges_details.


    CASE siv_context_rff_ave.
      WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z07.
        LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.
          IF ls_pod_dev_relation-pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
            CONTINUE.
          ENDIF.

          LOOP AT ls_pod_dev_relation-register_data INTO ls_register_data.

            READ TABLE gs_process_step_data-charges ASSIGNING <fs_charges>
                  WITH KEY item_id  = siv_itemid
                           ext_ui   = ls_pod_dev_relation-ext_ui
                           reg_code = ls_register_data-kennziff.
            IF sy-subrc = 0. ">>>SCHMIDT.C 20150225 Nur dann die Referenz auf die OBIS setzen, wenn die OBIS auch relevant für die Konzessionsabgabe ist (s.h. Methode für SEQ+Z07)
              <fs_charges>-reg_code = ls_register_data-kennziff.
            ENDIF.

          ENDLOOP.
        ENDLOOP.
      WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z10.
        super->reference_to_obis( ).
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD REFERENCE_TO_REQUEST.
    ">>>SCHMIDT.C 20150224 Referenznummer der ORDERS Anfrage wird im Mapping ISU_TO_PDOC_DATA in das Feld DOCUMENT_IDENT geschrieben

    DATA: lv_ref_to_request TYPE /idxgc/de_ref_to_request_1,
          ls_diverse        TYPE /idxgc/s_diverse_details.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_cd023 OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_cd013.

      IF gs_process_data_src-document_ident IS NOT INITIAL.
        lv_ref_to_request = gs_process_data_src-document_ident.
      ELSEIF gs_process_data_src_add-document_ident IS NOT INITIAL.
        lv_ref_to_request = gs_process_data_src-document_ident.
      ELSE.
        MESSAGE e038(/idxgc/ide_add) WITH text-402 INTO gv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.

      READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
      IF <fs_diverse> IS ASSIGNED.
        <fs_diverse>-ref_to_request = lv_ref_to_request.
      ELSE.
        ls_diverse-item_id         = siv_itemid.
        ls_diverse-ref_to_request = lv_ref_to_request.
        APPEND ls_diverse TO gs_process_step_data-diverse.
      ENDIF.

    ELSE.
      super->reference_to_request( ).
    ENDIF.

  ENDMETHOD.


  METHOD REGISTER_DECIMALS_BEFORE_AFTER.
***************************************************************************************************
* THIMEL.R 20150227
*   Neuere Logik aus /IDEXGE/CL_DP_OUT_UTILMD_005 übernommen. Komplette Übernahme nicht möglich,
*     da nicht alle Felder vorhanden waren.
***************************************************************************************************
    DATA:
      ls_pod_dev_relation   TYPE /idxgc/s_pod_dev_relation,
      ls_register_data      TYPE /idxgc/s_register_data,
      ls_reg_code_data      TYPE /idxgc/s_reg_code_details,
      ls_meter_proc_details TYPE /idxgc/s_profile_details.

    FIELD-SYMBOLS:
      <fs_reg_code_data> TYPE /idxgc/s_reg_code_details.

    IF siv_inst_type IS INITIAL.
      CALL METHOD me->get_inst_type( ).
    ENDIF.

    IF siv_inst_type NE /idexge/if_constants_dp=>gc_inst_type_rlm.

      LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.
        LOOP AT ls_pod_dev_relation-register_data INTO ls_register_data.

          READ TABLE gs_process_step_data-reg_code_data ASSIGNING <fs_reg_code_data>
               WITH KEY item_id = siv_itemid
                        meternumber = ls_register_data-meternumber
                        reg_code = ls_register_data-kennziff.
          IF sy-subrc = 0.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = ls_register_data-stanzvor
              IMPORTING
                output = <fs_reg_code_data>-int_positons.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = ls_register_data-stanznac
              IMPORTING
                output = <fs_reg_code_data>-dec_places.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD REJECTION_REASON.
    ">>>SCHMIDT.C 20150107 Wird aus dem Workflow übernommen und im Mapping gefüllt
  ENDMETHOD.


  METHOD SETTLEMENT_TERRITORY.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_bilanzierunggebiet
    DATA: ls_setlter       TYPE /idxgc/s_setlter_details,
          lv_settlterr_ext TYPE /idxgc/de_settlterr_ext.

    FIELD-SYMBOLS: <fs_setlter> TYPE /idxgc/s_setlter_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-settl_terr INTO ls_setlter WITH KEY item_id = siv_itemid.
      IF ls_setlter-settlterr_ext IS NOT INITIAL.
        lv_settlterr_ext = ls_setlter-settlterr_ext.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.
          IF lv_settlterr_ext IS INITIAL.
            lv_settlterr_ext = '11YR000000014017'.
          ENDIF.

          READ TABLE gs_process_step_data-settl_terr ASSIGNING <fs_setlter> WITH KEY item_id = siv_itemid.
          IF sy-subrc = 0.
            <fs_setlter>-settlterr_ext = lv_settlterr_ext.
          ELSE.
            ls_setlter-item_id = siv_itemid.
            ls_setlter-settlterr_ext = lv_settlterr_ext.
            APPEND ls_setlter TO gs_process_step_data-settl_terr.
          ENDIF.

        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD SETTLEMENT_UNIT.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_bilanzkreisverantw

    DATA: lv_settlunit      TYPE          e_edmsettlunit,
          ls_settlunit_data TYPE          eedmsettlunit_db_data,
          ls_setunit_new    TYPE          /idxgc/s_setunit_details,
          ls_v_eanl         TYPE          v_eanl,
          lt_settl_prio     TYPE TABLE OF zlw2_settl_prio,
          lv_prio           TYPE          /idxgc/de_settlunit_prio.

    FIELD-SYMBOLS: <fs_diverse>    TYPE         /idxgc/s_diverse_details,
                   <fs_setunit>    TYPE         /idxgc/s_setunit_details,
                   <fs_settl_prio> LIKE LINE OF lt_settl_prio.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
      gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103..

      IF gs_process_data_src-settl_unit IS NOT INITIAL.
        LOOP AT gs_process_data_src-settl_unit INTO ls_setunit_new.
          ls_setunit_new-item_id = siv_itemid.
          APPEND ls_setunit_new TO gs_process_step_data-settl_unit.
          RETURN.
        ENDLOOP.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        ls_v_eanl = lr_isu_pod->get_v_eanl( ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas AND ls_v_eanl-zzedmmgebiet CS 'EXT'.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.

            SELECT * FROM zlw2_settl_prio2 INTO CORRESPONDING FIELDS OF TABLE lt_settl_prio
               WHERE datefrom    LE <fs_diverse>-contr_start_date AND
                     dateto      GE <fs_diverse>-contr_start_date AND
                     serviceprovider = gs_process_step_data-assoc_servprov.

            IF sy-subrc <> 0.
              SELECT * FROM zlw2_settl_prio INTO TABLE lt_settl_prio
                WHERE datefrom    LE <fs_diverse>-contr_start_date AND
                      dateto      GE <fs_diverse>-contr_start_date AND
                      zzedmmgebiet NE 'NCG LG SWS'.
            ENDIF.

            LOOP AT lt_settl_prio ASSIGNING <fs_settl_prio>.
              ls_setunit_new-settlunit_ext = <fs_settl_prio>-settlunitext.
              ls_setunit_new-item_id = siv_itemid.
              ls_setunit_new-settlunit_prio = <fs_settl_prio>-unit_prio.
              APPEND ls_setunit_new TO gs_process_step_data-settl_unit.
            ENDLOOP.
          ENDIF.
        ELSE.
          CASE gs_process_step_data-bmid.
            WHEN /idxgc/if_constants_ide=>gc_bmid_eb101.
              CALL METHOD get_settlunit_via_eedmsettlun
                IMPORTING
                  ev_settlunit = lv_settlunit.
            WHEN OTHERS.
              CALL METHOD get_settlunit_via_pod
                IMPORTING
                  ev_settlunit = lv_settlunit.
          ENDCASE.

          IF lv_settlunit IS INITIAL.
            CALL METHOD get_settlunit_via_eedmsettlun
              IMPORTING
                ev_settlunit = lv_settlunit.
          ENDIF.

          CALL METHOD cl_isu_edm_settlunit=>db_single
            EXPORTING
              im_settlunit = lv_settlunit
            IMPORTING
              ex_db_data   = ls_settlunit_data
            EXCEPTIONS
              OTHERS       = 1.
          IF sy-subrc <> 0.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
          ENDIF.

          IF ls_settlunit_data-head-settlunitext IS NOT INITIAL.
            ls_setunit_new-settlunit_ext = ls_settlunit_data-head-settlunitext.
          ENDIF.
          ls_setunit_new-item_id = siv_itemid.
          ls_setunit_new-settlunit_int = lv_settlunit.
          APPEND ls_setunit_new TO gs_process_step_data-settl_unit.

          IF  lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas
          AND gs_process_step_data-bmid NE /idxgc/if_constants_ide=>gc_bmid_es103.
            LOOP AT gs_process_step_data-settl_unit ASSIGNING <fs_setunit>.
              lv_prio = lv_prio + 1.
              <fs_setunit>-settlunit_prio = lv_prio.
            ENDLOOP.
          ENDIF.
        ENDIF.

      CATCH zcx_agc_masterdata /idxgc/cx_process_error.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD SET_OF_PROFILES.

    DATA: ls_diverse          TYPE /idxgc/s_diverse_details,
          lv_profile_group    TYPE /idxgc/de_profile_group,
          lv_profil           TYPE zedmlastprofil,
          lv_kz_eigen         TYPE kennzx,
          lv_prof_code_an_cla TYPE /idxgc/de_prof_code_an_cla.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-profile_set IS NOT INITIAL.
        lv_profil = ls_diverse-profile_set.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14 AND
           lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.

          IF lv_profil IS INITIAL.
            lv_profil = lr_isu_pod->get_profil( ).
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-profile_set = lv_profil.
          ELSE.
            ls_diverse-profile_set = lv_profil.
            ls_diverse-item_id = siv_itemid.
            APPEND ls_diverse TO gs_process_step_data-diverse.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.


  ENDMETHOD.


  METHOD START_DATE_BILLLING_YEAR.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_start_abrjahr

    DATA: ls_diverse      TYPE /idxgc/s_diverse_details,
          lv_startabrjahr TYPE dats.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-billyearstart IS NOT INITIAL.
        lv_startabrjahr = ls_diverse-billyearstart.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF me->lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.
          IF lv_startabrjahr IS INITIAL.
            IF me->lr_isu_pod->get_sparte( ) = '01'.
              MOVE gs_process_step_data-proc_date TO lv_startabrjahr.
              MOVE '0101' TO lv_startabrjahr+4(4).
            ELSEIF me->lr_isu_pod->get_sparte( ) = '02'.
              MOVE gs_process_step_data-proc_date TO lv_startabrjahr.
              MOVE '1001' TO lv_startabrjahr+4(4).

              IF lv_startabrjahr GT gs_process_step_data-proc_date.
                SUBTRACT 1 FROM lv_startabrjahr(4).
              ENDIF.
            ELSE.
              CLEAR lv_startabrjahr.
            ENDIF.
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-billyearstart = lv_startabrjahr.
          ELSE.
            ls_diverse-billyearstart = lv_startabrjahr.
            ls_diverse-item_id = siv_itemid.
            APPEND ls_diverse TO gs_process_step_data-diverse.
          ENDIF.

        ENDIF.

      CATCH zcx_agc_masterdata.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD start_date_of_delivery.
    ">>>SCHMIDT.C 20150107 Wird vom Workflow gesetzt und im Mapping gefüllt. Kann ggf. hier noch einmal überarbeitet werden
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: movein_moveout_date
    DATA: lv_serviceid TYPE          eservprov-serviceid,
          lt_ever      TYPE TABLE OF ever,
          ls_ever      TYPE          ever,
          lv_anlage    TYPE          anlage,
          lv_keydate   TYPE          dats,
          lv_vbeginn   TYPE          dats.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Bei Stammdatenändetung an zuk. Lieferanten wird das Datum aus dem Vertrag ermittelt
    CASE gs_process_step_data-bmid.
      WHEN zif_agc_datex_utilmd_co=>gc_bmid_zmd01 OR
           zif_agc_datex_utilmd_co=>gc_bmid_zmd11.        "Wolf.A., 28.04.2015, Mantis 4925
        "LZ_LW_CONTAINERFUBASO01
        "Form  HOLE_BEGINN_ZUM
        READ TABLE gs_process_step_data-diverse INDEX 1 ASSIGNING <fs_diverse>.

        IF sy-mandt = zif_datex_co=>co_mandt_210 AND ( gs_process_step_data-proc_type = zif_datex_co=>co_mdchg_inbound OR
                                                       gs_process_step_data-proc_type = zif_datex_co=>co_mdchg_outbound ).
          lv_keydate = <fs_diverse>-validstart_date.
        ELSE.
          lv_keydate = sy-datum.
        ENDIF.

        lv_serviceid = gs_process_step_data-assoc_servprov.

        SELECT SINGLE anlage FROM euiinstln INTO lv_anlage WHERE int_ui = gs_process_step_data-int_ui AND ( datefrom <= <fs_diverse>-validstart_date AND
                                                                                                              dateto >= <fs_diverse>-validstart_date ).
        IF sy-subrc = 0.

          SELECT * FROM ever INTO TABLE lt_ever WHERE anlage = lv_anlage AND invoicing_party = lv_serviceid.
          SORT lt_ever DESCENDING BY einzdat.
          READ TABLE lt_ever INDEX 1 INTO ls_ever.

          IF sy-subrc = 0.
            IF ls_ever-einzdat = '20090401' AND
               ls_ever-vbeginn IS NOT INITIAL.
              lv_vbeginn = ls_ever-vbeginn.
            ELSE.
              lv_vbeginn = ls_ever-einzdat.
            ENDIF.

            IF lv_vbeginn > lv_keydate.
              <fs_diverse>-contr_start_date = lv_vbeginn.
            ELSE.
              <fs_diverse>-contr_start_date = <fs_diverse>-validstart_date.
            ENDIF.
          ELSE.
            <fs_diverse>-contr_start_date = <fs_diverse>-validstart_date.
          ENDIF.

        ENDIF.
    ENDCASE.
  ENDMETHOD.


  METHOD START_DATE_OF_SETTLEMENT.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_bilanz_beg_ende

    DATA: lv_mtext                    TYPE string,
          ls_diverse                  TYPE /idxgc/s_diverse_details,
          lv_start_date_of_settlement TYPE /idxgc/de_startsettldate.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true.
      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-startsettldate IS NOT INITIAL.
        lv_start_date_of_settlement = ls_diverse-startsettldate.
      ENDIF.
    ENDIF.

    TRY.

        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.

        IF <fs_diverse> IS ASSIGNED.
          IF lv_start_date_of_settlement IS INITIAL.
            me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

            IF me->lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e01.
              <fs_diverse>-startsettldate = <fs_diverse>-contr_start_date.
            ELSEIF me->lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02 OR
                   me->lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14.
              CALL FUNCTION 'Z_LW_SETTLUNIT_FRISTEN'
                EXPORTING
                  i_refdate    = sy-datum
                  i_kalender   = zif_agc_datex_utilmd_co=>gc_fabrikkalender_de_stand
                  i_einzdat    = <fs_diverse>-contr_start_date
                IMPORTING
                  e_settlstart = <fs_diverse>-startsettldate.
            ELSE.
              <fs_diverse>-startsettldate = <fs_diverse>-contr_start_date.
            ENDIF.
          ELSE.
            <fs_diverse>-startsettldate = lv_start_date_of_settlement.
          ENDIF.

          <fs_diverse>-startsettlform = /idxgc/if_constants_ide=>gc_dtm_format_code_102.

        ELSE.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.

      CATCH zcx_agc_masterdata.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

*>>> THIMEL.R 20150322 Bilanzierungsbeginn und -ende nur übermitteln wenn Bilanzierung stattfindet.
    IF <fs_diverse>-startsettldate is not INITIAL and <fs_diverse>-endsettldate is not INITIAL AND
       <fs_diverse>-startsettldate > <fs_diverse>-endsettldate.
      clear: <fs_diverse>-startsettldate, <fs_diverse>-startsettlform, <fs_diverse>-endsettldate, <fs_diverse>-endsettlform.
    endif.
*<<< THIMEL.R 20150322


  ENDMETHOD.


  METHOD START_OF_DELIVERY_DATE.
    ">>>SCHMIDT.C 20150107 Wird aus dem Workflow übergeben und im Mapping gesetzt
  ENDMETHOD.


  METHOD SUPPLY_DIRECTION.
    ">>>SCHMIDT.C 20150121 In Solingen werden nur Nachrichten mit der Lieferrichtung Entnahme versendet
    DATA: lv_supply_direct TYPE /idxgc/de_supply_direct,
          ls_diverse       TYPE /idxgc/s_diverse_details.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-supply_direct IS NOT INITIAL.
        lv_supply_direct = ls_diverse-supply_direct.
      ENDIF.
    ENDIF.

    IF lv_supply_direct IS INITIAL.
      lv_supply_direct = /idxgc/if_constants_add=>gc_supply_direct_z07.
    ENDIF.

    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
    IF sy-subrc = 0.
      <fs_diverse>-supply_direct = lv_supply_direct.
    ELSE.
      ls_diverse-supply_direct = lv_supply_direct.
      ls_diverse-item_id = siv_itemid.
      APPEND ls_diverse TO gs_process_step_data-diverse.
    ENDIF.
  ENDMETHOD.


  METHOD TAX_INFO.
    ">>>SCHMIDT.C Wird nicht benötigt, da in Solingen keine Steuerinformation nach §9 StromStG erforderlich sind
  ENDMETHOD.


  METHOD TAX_INFO_SEQ.
    ">>>SCHMIDT.C Wird nicht benötigt, da in Solingen keine Steuerinformation nach §9 StromStG erforderlich sind
    CLEAR siv_context_rff_ave.
  ENDMETHOD.


  METHOD TEMPERATUE_DEPENDENT_WORK.
    "SCHMIDT.C 20150107 Muss neu implementiert werden. Sollte genauso ermittelt werden die der Jahresverbrauch.

    DATA: lv_temperatue_dep_wk TYPE /idxgc/de_quantitiy_ext,
          ls_pod_quant         TYPE /idxgc/s_pod_quant_details.

    FIELD-SYMBOLS: <fs_pod_quant> TYPE /idxgc/s_pod_quant_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       ( gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103 AND
       ( siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z37 OR siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z38 ) ).

      READ TABLE gs_process_data_src-pod_quant INTO ls_pod_quant WITH KEY item_id = siv_itemid
                                                                          ext_ui = gs_process_step_data-ext_ui
                                                                          quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z08.
      IF ls_pod_quant-quantitiy_ext IS NOT INITIAL.
        lv_temperatue_dep_wk = ls_pod_quant-quantitiy_ext.
      ENDIF.
    ENDIF.


    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14 AND
           lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.

          IF lv_temperatue_dep_wk IS INITIAL.
            IF zcl_agc_masterdata=>is_netz( ) = abap_true AND
               gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb101.
              lv_temperatue_dep_wk = lr_isu_pod->get_progyearcons( ).
            ELSE.
              IF siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z36 AND "Bei Z36 EoG immer den Periodenverbrauch auf 1 setzen.
                  gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb101.
                lv_temperatue_dep_wk = 1.
* >>> Wolf.A., 27.04.2015, Mantis 4853
              ELSEIF zcl_agc_masterdata=>is_netz( ) = abap_true AND
                     siv_transreason <> /idxgc/if_constants_ide=>gc_trans_reason_code_z36 AND
                     gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb101.
                lv_temperatue_dep_wk = lr_isu_pod->get_progyearcons( ).
* <<< Wolf.A., 27.04.2015, Mantis 4853
              ELSE.
                lv_temperatue_dep_wk = lr_isu_pod->get_perverbr( ).
              ENDIF.
            ENDIF.
          ENDIF.

          READ TABLE gs_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WITH KEY item_id = siv_itemid
                                                                                      ext_ui = gs_process_step_data-ext_ui
                                                                                      quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z08.
          IF <fs_pod_quant> IS ASSIGNED.
            <fs_pod_quant> = lv_temperatue_dep_wk.
          ELSE.
            ls_pod_quant-quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z08.
            ls_pod_quant-quantitiy_ext = lv_temperatue_dep_wk.
            IF zcl_agc_datex_utility=>check_dummy_pod( iv_ext_ui = gs_process_step_data-ext_ui ) = abap_false.
              ls_pod_quant-ext_ui = gs_process_step_data-ext_ui.
            ENDIF.
            ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
            ls_pod_quant-item_id = siv_itemid.
            APPEND ls_pod_quant TO gs_process_step_data-pod_quant.
          ENDIF.

        ENDIF.

      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.


  ENDMETHOD.


  METHOD TEMPERATURE_MEASUREMENT_POINT.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_temperaturmessstelle

    DATA: ls_diverse        TYPE /idxgc/s_diverse_details,
          ls_v_eanl         TYPE v_eanl,
          lv_tempmessstelle TYPE /idxgc/de_temp_mp,
          lv_tempanbieter   TYPE /idxgc/de_temp_mp_prov.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-temp_mp IS NOT INITIAL AND
          ls_diverse-temp_mp_prov IS NOT INITIAL.
        lv_tempmessstelle = ls_diverse-temp_mp.
        lv_tempanbieter = ls_diverse-temp_mp_prov.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lv_tempmessstelle IS INITIAL AND
           lv_tempanbieter IS INITIAL.

          IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas AND
             lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02.  "'E02' - SLP.

            ls_v_eanl = lr_isu_pod->get_v_eanl( ).

            IF ls_v_eanl-zztempmessstelle IS INITIAL AND  ls_v_eanl-zztempanbieter IS INITIAL.
              lv_tempmessstelle = '10415'.
              lv_tempanbieter   = 'ZT2'.
            ELSE.
              lv_tempmessstelle = ls_v_eanl-zztempmessstelle.
              lv_tempanbieter   = ls_v_eanl-zztempanbieter.
            ENDIF.

          ELSEIF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom AND
                 lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14.
            lv_tempmessstelle = '10415'.
            lv_tempanbieter = 'ZT2'.
          ENDIF.
        ENDIF.

        READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
        IF <fs_diverse> IS ASSIGNED.
          <fs_diverse>-temp_mp = lv_tempmessstelle.
          <fs_diverse>-temp_mp_prov = lv_tempanbieter.
          <fs_diverse>-temp_mp_cla = /idxgc/if_constants_ide=>gc_codelist_agency_293.

        ELSE.
          ls_diverse-temp_mp = lv_tempmessstelle.
          ls_diverse-temp_mp_prov = lv_tempanbieter.
          ls_diverse-temp_mp_cla = /idxgc/if_constants_ide=>gc_codelist_agency_293.
          APPEND ls_diverse TO gs_process_step_data-diverse.
        ENDIF.

      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.

  ENDMETHOD.


  METHOD transaction_reason.
    ">>>SCHMIDT.C 20150107 Der Transaktionsgrund sollte schon vom Workflow übergeben werden und dann im Mapping bereits gesetzt sein
    IF gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_dso      OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_rec      OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_dso OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_rec.
      super->transaction_reason( ).
    ENDIF.
  ENDMETHOD.


  METHOD TRANSACTION_REASON_SECOND.
    DATA: ls_diverse TYPE /idxgc/s_diverse_details.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    CASE gs_process_step_data-bmid.
      WHEN /idxgc/if_constants_ide=>gc_bmid_eb101 OR
           /idxgc/if_constants_ide=>gc_bmid_eb102 OR
           /idxgc/if_constants_ide=>gc_bmid_eb101.

        TRY.
            READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
            IF <fs_diverse> IS ASSIGNED.
              IF <fs_diverse>-contr_end_date IS NOT INITIAL.
                CASE <fs_diverse>-msgtransreason.
                  WHEN /idxgc/if_constants_ide=>gc_trans_reason_code_z36.
                    <fs_diverse>-dereg_reason = /idxgc/if_constants_ide=>gc_trans_reason_code_e01.
                  WHEN /idxgc/if_constants_ide=>gc_trans_reason_code_z38.
                    <fs_diverse>-dereg_reason = /idxgc/if_constants_ide=>gc_trans_reason_code_e03.
                ENDCASE.
              ENDIF.
            ENDIF.
          CATCH zcx_agc_masterdata.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDTRY.

      WHEN /idxgc/if_constants_ide=>gc_bmid_es102 OR            "WOLF.A, 23.03.2015 - Bei einer Antwort auf befristete Anmeldung ist der zweite Tr.Gr. anzugeben.
           /idxgc/if_constants_ide=>gc_bmid_es103.

        TRY .
            READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
            "Quellschrittdaten lesen (zweiten Tr.Gr. aus der Anmeldung übernehmen)
            READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
            IF ls_diverse-dereg_reason IS NOT INITIAL.
              <fs_diverse>-dereg_reason = ls_diverse-dereg_reason.
            ENDIF.
        CATCH zcx_agc_masterdata.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDTRY.

    WHEN OTHERS.
  ENDCASE.

ENDMETHOD.


  METHOD TRANSACTION_REF_RESPONSE.
    ">>>SCHMIDT.C 20150127 Aus dem Standard übernommen, da für Stornonachrichten auch aus den Quellschritten gelesen werden muss
    DATA:
      ls_diverse TYPE /idxgc/s_diverse_details,
      lv_msgtext TYPE string.

    FIELD-SYMBOLS:
      <fs_diverse> TYPE /idxgc/s_diverse_details.

    READ TABLE gs_process_data_src-diverse INTO ls_diverse INDEX 1.
    IF ls_diverse-transaction_no IS INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH text-015 INTO lv_msgtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
    IF <fs_diverse> IS ASSIGNED.
      <fs_diverse>-refnr_transreq = ls_diverse-transaction_no.
    ELSE.
      ls_diverse-refnr_transreq = ls_diverse-transaction_no.
      ls_diverse-item_id = siv_itemid.
      APPEND ls_diverse TO gs_process_step_data-diverse.
    ENDIF.

  ENDMETHOD.


  METHOD TRANSACTION_REF_REVERSAL.
    ">>>SCHMIDT.C 20150127 Immer aus dem Quellschritt lesen
    ">>>THIMEL.R 20150424 M4901 Mehrere Stornos im Prozess
    DATA:
      ls_diverse TYPE /idxgc/s_diverse_details,
      lv_msgtext TYPE string.

    FIELD-SYMBOLS:
      <fs_diverse> TYPE /idxgc/s_diverse_details.

    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_er901 AND gs_process_step_data-assoc_servprov = gs_process_data_src_add-assoc_servprov. ">>>THIMEL.R 20150424 M4901
      READ TABLE gs_process_data_src_add-diverse INTO ls_diverse INDEX 1.
    ELSE.
      READ TABLE gs_process_data_src-diverse INTO ls_diverse INDEX 1.
    ENDIF.

    IF ls_diverse-transaction_no IS INITIAL.
      MESSAGE e038(/idxgc/ide_add) WITH text-015 INTO lv_msgtext.
      /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

    READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
    IF <fs_diverse> IS ASSIGNED.
      <fs_diverse>-refnr_transrev = ls_diverse-transaction_no.
    ELSE.
      ls_diverse-refnr_transrev = ls_diverse-transaction_no.
      ls_diverse-item_id = siv_itemid.
      APPEND ls_diverse TO gs_process_step_data-diverse.
    ENDIF.
  ENDMETHOD.


  METHOD valid_from_date.
*>>> THIMEL.R 20150310 Redefinition da für BMID EC102 kein Logik hinterlegt war (Mantis 4701)
    DATA: lv_possenddate TYPE dats,
          lv_anlage      TYPE anlage,
          ls_diverse     TYPE /idxgc/s_diverse_details.

    FIELD-SYMBOLS: <fs_diverse>    TYPE /idxgc/s_diverse_details,
                   <fs_respstatus> TYPE /idxgc/s_msgsts_details.

    CALL METHOD super->valid_from_date.

    TRY.

        CASE gs_process_step_data-bmid.
          WHEN /idxgc/if_constants_ide=>gc_bmid_ec102.
            LOOP AT gs_process_step_data-msgrespstatus ASSIGNING <fs_respstatus>
              WHERE respstatus = /idxgc/if_constants_ide=>gc_respstatus_z12.

              READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
              IF <fs_diverse> IS ASSIGNED AND <fs_diverse>-endnextposs_from IS NOT INITIAL. "Bereits im Mapping gefüllt und durch den Workflow übergeben
                lv_possenddate = <fs_diverse>-endnextposs_from.
                CLEAR: <fs_diverse>-endnextposs_from.
              ELSE.
                me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).
                lv_anlage = lr_isu_pod->get_anlage( ).

                CALL FUNCTION 'Z_LW_CHECK_CONTRACTDURATION'
                  EXPORTING
                    i_anlage                = lv_anlage
                    i_auszdat               = sy-datum
                  IMPORTING
                    e_possend               = lv_possenddate
                  EXCEPTIONS
                    user_decision_necessary = 1.
              ENDIF.


              IF <fs_diverse> IS ASSIGNED.
                <fs_diverse>-validstart_date = lv_possenddate.
                <fs_diverse>-validstart_form = /idxgc/if_constants_ide=>gc_dtm_format_code_102.

                IF <fs_diverse>-validstart_date IS INITIAL.
                  MESSAGE e038(/idxgc/ide_add) WITH text-102 INTO gv_mtext.
                  /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
                ENDIF.
              ELSE.
                ls_diverse-item_id = siv_itemid.
                ls_diverse-validstart_date = lv_possenddate.
                ls_diverse-validstart_form = /idxgc/if_constants_ide=>gc_dtm_format_code_102.

                IF ls_diverse-validstart_date IS INITIAL.
                  MESSAGE e038(/idxgc/ide_add) WITH text-102 INTO gv_mtext.
                  /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
                ENDIF.

                APPEND ls_diverse TO gs_process_step_data-diverse.
              ENDIF.
            ENDLOOP.
        ENDCASE.

      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD voltage_level.
    ">>>SCHMIDT.C 20150127 Spannungsebene wird anhand einer Z-Tabelle ermittel. Standard kann so nicht genutzt werden

    DATA: ls_diverse       TYPE /idxgc/s_diverse_details,
          ls_lw_spebene    TYPE zlw_spebene,
          ls_v_eanl        TYPE v_eanl,
          lv_voltage_level TYPE /idxgc/de_volt_level_offt.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-volt_level_offt IS NOT INITIAL.
        lv_voltage_level = ls_diverse-volt_level_offt.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.
          IF lv_voltage_level IS INITIAL.
            ls_v_eanl = lr_isu_pod->get_v_eanl( ).

            SELECT SINGLE * FROM zlw_spebene INTO ls_lw_spebene
              WHERE zz_mandt = sy-mandt AND
                    spebene  = ls_v_eanl-spebene AND
                    sparte = ls_v_eanl-sparte AND
                    zzespebene_ms = ls_v_eanl-zzespebene_ms AND
                    zzenetz1 = ls_v_eanl-zzenetz1.

            IF sy-subrc <> 0.
              MESSAGE e106(zagc_masterdata) INTO gv_mtext.
              /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
            ENDIF.

            lv_voltage_level = ls_lw_spebene-zz_spebene.

          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-volt_level_offt = lv_voltage_level.
          ELSE.
            ls_diverse-item_id = siv_itemid.
            ls_diverse-volt_level_offt = lv_voltage_level.
            APPEND ls_diverse TO  gs_process_step_data-diverse.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        MESSAGE e106(zagc_masterdata) INTO gv_mtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD VOLTAGE_LEVEL_MEASUREMENT.
    ">>>SCHMIDT.C 20150127 Spannungsebene wird anhand einer Z-Tabelle ermittel. Standard kann so nicht genutzt werden

    DATA: ls_lw_spebene TYPE zlw_spebene,
          ls_v_eanl     TYPE v_eanl,
          ls_pod_src    TYPE /idxgc/s_pod_info_details.

    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.


    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod> WHERE item_id = siv_itemid AND
                                                                loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.

        READ TABLE gs_process_data_src-pod INTO ls_pod_src WITH KEY ext_ui = <fs_pod>-ext_ui.
        IF ls_pod_src IS NOT INITIAL.
          <fs_pod>-volt_level_meas = ls_pod_src-volt_level_meas.
        ENDIF.

      ENDLOOP.
      RETURN.
    ENDIF.


    TRY.

        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom.

          LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod> WHERE item_id = siv_itemid AND
                                                                    loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.


            me->lr_isu_pod = get_pod_ref( iv_int_ui = <fs_pod>-int_ui iv_keydate = gs_process_step_data-proc_date ).

            ls_v_eanl = lr_isu_pod->get_v_eanl( ).


            SELECT SINGLE * FROM zlw_spebene INTO ls_lw_spebene
              WHERE zz_mandt = sy-mandt AND
                    spebene  = ls_v_eanl-spebene AND
                    sparte = ls_v_eanl-sparte AND
                    zzespebene_ms = ls_v_eanl-zzespebene_ms AND
                    zzenetz1 = ls_v_eanl-zzenetz1.

            IF sy-subrc <> 0.
              /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
            ENDIF.

            <fs_pod>-volt_level_meas = ls_lw_spebene-zz_spebenemess.

          ENDLOOP.
        ENDIF.

      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD VOLUME_CORRECTOR_DATA_SEQ.
    ">>>SCHMIDT.C 20150204 Sonderfall Mengenumwerter in Solingen, da kein zählendes Gerät in der Anlage eingebaut ist
    TRY.
        CALL METHOD super->volume_corrector_data_seq.
      CATCH /idxgc/cx_process_error .
    ENDTRY.

    DATA: ls_pod_dev_relation     TYPE        /idxgc/s_pod_dev_relation,
          ls_non_meter_device     TYPE        /idxgc/s_nonmeter_details,
          ls_non_meter_device_src TYPE        /idxgc/s_nonmeter_details,
          ls_dev_corrector        TYPE        /idxgc/s_device_data,
          lr_badi_access          TYPE REF TO /idxgc/badi_data_access,
          lr_badi_process         TYPE REF TO /idxgc/badi_md_chg_rep,
          lt_dev_list             TYPE        /idxgc/t_device_list,
          lt_reg_list             TYPE        /idxgc/t_reg_list,
          ls_reg_list_corrector   TYPE        /idxgc/s_reg_list,
          ls_reg_list_meter       TYPE        /idxgc/s_reg_list.

    FIELD-SYMBOLS:
      <fs_non_meter_dev> TYPE /idxgc/s_nonmeter_details.

    "EoG-Bestätigung: Daten aus Quellschritt
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.
      LOOP AT gs_process_data_src-non_meter_dev INTO ls_non_meter_device_src
        WHERE device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z09.

        ls_non_meter_device_src-item_id = siv_itemid.

        READ TABLE gs_process_step_data-non_meter_dev ASSIGNING <fs_non_meter_dev>
          WITH KEY item_id     = siv_itemid
                   device_number = ls_non_meter_device_src-device_number
                   meternumber = ls_non_meter_device_src-meternumber
                   device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z09.
        IF sy-subrc = 0.
          <fs_non_meter_dev> = ls_non_meter_device_src.
        ELSE.
          APPEND ls_non_meter_device_src TO gs_process_step_data-non_meter_dev.
        ENDIF.
      ENDLOOP.
    ELSE.
      LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.
        LOOP AT ls_pod_dev_relation-device_data INTO ls_dev_corrector
          WHERE metertype = /idexge/if_constants_dp=>gc_cci_corrector.  "Z64
          siv_context_rff_ave = /idxgc/if_constants_ide=>gc_seq_action_code_z09.
          EXIT.
        ENDLOOP.

        IF siv_context_rff_ave = /idxgc/if_constants_ide=>gc_seq_action_code_z09.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD YEARLY_CONSUMPTION.
    ">>>SCHMIDT.C 20150128 Wurde eins zu eins aus der Z_LW_GET_MESSAGEDATA übernommen
    "Include: LZ_LW_CONTAINERFUBASF12
    "Form: hole_vorjahresverbrauch

    DATA: ls_pod_quant      TYPE /idxgc/s_pod_quant_details,
          lv_yearly_cons    TYPE /idxgc/de_quantitiy_ext,
          lv_vorjahresverbr TYPE z_vorjahresverbrauch,
          lv_value          TYPE dec10.

    FIELD-SYMBOLS: <fs_pod_quant> TYPE /idxgc/s_pod_quant_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-pod_quant INTO ls_pod_quant WITH KEY item_id = siv_itemid
                                                                          ext_ui = gs_process_step_data-ext_ui
                                                                         quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z09.
      IF ls_pod_quant-quantitiy_ext IS NOT INITIAL.
        lv_yearly_cons = ls_pod_quant-quantitiy_ext.
      ENDIF.
    ENDIF.

    IF lv_yearly_cons IS INITIAL.
      CALL FUNCTION 'ZLW2_GET_VORJAHRESVERBRAUCH'
        EXPORTING
          im_switchnum          = gs_process_step_data-proc_ref
        IMPORTING
          ex_vorjahresverbrauch = lv_vorjahresverbr
        EXCEPTIONS
          general_fault         = 01
          fehler_wb             = 02
          fehler_vt             = 03
          fehler_an             = 04
          OTHERS                = 05.
      CASE sy-subrc.
        WHEN 0.
          WRITE lv_vorjahresverbr TO lv_yearly_cons NO-GROUPING LEFT-JUSTIFIED DECIMALS 0.

          IF lv_yearly_cons CA ','.
            REPLACE ',' WITH '.' INTO lv_yearly_cons.
          ENDIF.

        WHEN OTHERS.
          MOVE 1000 TO lv_yearly_cons.
      ENDCASE.


    ENDIF.

    READ TABLE gs_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WITH KEY item_id = siv_itemid
                                                                            ext_ui = gs_process_step_data-ext_ui
                                                                            quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z09.

    IF <fs_pod_quant> IS ASSIGNED.
      SHIFT lv_yearly_cons LEFT DELETING LEADING space.
      lv_value = lv_yearly_cons DIV 1.
      <fs_pod_quant>-quantitiy_ext = lv_value.
      <fs_pod_quant>-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
    ELSE.
      ls_pod_quant-item_id = siv_itemid.
      SHIFT lv_yearly_cons LEFT DELETING LEADING space.
      lv_value = lv_yearly_cons DIV 1.
      ls_pod_quant-quantitiy_ext = lv_value.
      IF zcl_agc_datex_utility=>check_dummy_pod( iv_ext_ui = gs_process_step_data-ext_ui ) = abap_false.
        ls_pod_quant-ext_ui = gs_process_step_data-ext_ui.
      ENDIF.
      ls_pod_quant-quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z09.
      ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
      APPEND ls_pod_quant TO gs_process_step_data-pod_quant.
    ENDIF.


  ENDMETHOD.


  METHOD yearly_consumption_forecast.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_jvb
    DATA: ls_pod_quant        TYPE /idxgc/s_pod_quant_details,
          lv_yearly_cons_forc TYPE /idxgc/de_quantitiy_ext,
          lv_value            TYPE dec10.


    FIELD-SYMBOLS: <fs_pod_quant> TYPE /idxgc/s_pod_quant_details.

    "---------------------Weiche für Online Services------------------------
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101 AND
       sis_os_data IS NOT INITIAL.
      lv_yearly_cons_forc = sis_os_data-consumption.
    ENDIF.
    "-----------------------------------------------------------------------

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF lv_yearly_cons_forc IS INITIAL.
      IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
         ( gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103 AND
         ( siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z37 OR siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z38 ) ).

        READ TABLE gs_process_data_src-pod_quant INTO ls_pod_quant WITH KEY item_id = siv_itemid
                                                                            ext_ui = gs_process_step_data-ext_ui
                                                                            quant_type_qual = /idexge/if_constants_dp=>gc_qty_31.
        IF ls_pod_quant-quantitiy_ext IS NOT INITIAL.
          lv_yearly_cons_forc = ls_pod_quant-quantitiy_ext.
        ENDIF.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_metmethod( ) = /idxgc/cl_check_method_add=>/idxgc/if_check_method_add~gc_meter_proc_e02.

          IF lv_yearly_cons_forc IS INITIAL.

* >>> Wolf.A., adesso AG, 24.04.2015, Mantis 4895, 4926. Sollte überarbeitet werden.
            CASE gs_process_step_data-bmid.
              WHEN /idxgc/if_constants_ide=>gc_bmid_eb101.
                IF zcl_agc_masterdata=>is_netz( ) = abap_true AND
                   siv_transreason <> /idxgc/if_constants_ide=>gc_trans_reason_code_z36 AND
                   ( lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom OR
                   lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas ).
                  lv_yearly_cons_forc = lr_isu_pod->get_progyearcons( ).
                ELSE.
                  IF siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z36. "Bei Z36 EoG immer den Periodenverbrauch auf 1 setzen.
                    lv_yearly_cons_forc = 1.
                  ELSE.
                    lv_yearly_cons_forc = lr_isu_pod->get_perverbr( ).
                  ENDIF.
                ENDIF.
              WHEN OTHERS.
                IF zcl_agc_masterdata=>is_netz( ) = abap_true AND
                   ( lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom OR
                   lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas ).
                  lv_yearly_cons_forc = lr_isu_pod->get_progyearcons( ).
                ELSE.
                  lv_yearly_cons_forc = lr_isu_pod->get_perverbr( ).
                ENDIF.
            ENDCASE.

*            IF zcl_agc_masterdata=>is_netz( ) = abap_true AND
*               gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb101 AND      "Wolf.A., 22.04.2015, Mantis 4895
*               ( lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom OR
*                 lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas ).
*              lv_yearly_cons_forc = lr_isu_pod->get_progyearcons( ).
*            ELSE.
*              IF siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z36 AND "Bei Z36 EoG immer den Periodenverbrauch auf 1 setzen.
*                  gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb101.
*                lv_yearly_cons_forc = 1.
*              ELSE.
*                lv_yearly_cons_forc = lr_isu_pod->get_perverbr( ).
*              ENDIF.
*            ENDIF.
* <<< Wolf.A., adesso AG, 24.04.2015, Mantis 4895, 4926
          ENDIF.

          READ TABLE gs_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WITH KEY item_id = siv_itemid
                                                                                      ext_ui = gs_process_step_data-ext_ui
                                                                                      quant_type_qual = /idexge/if_constants_dp=>gc_qty_31.

          IF <fs_pod_quant> IS ASSIGNED.
            SHIFT lv_yearly_cons_forc LEFT DELETING LEADING space.
            lv_value = lv_yearly_cons_forc DIV 1. "Keine Nachkommastellen bei der Jahresverbrauchsprognose
            <fs_pod_quant>-quantitiy_ext = lv_value.
            <fs_pod_quant>-quantitiy_ext = lv_yearly_cons_forc.
            <fs_pod_quant>-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
          ELSE.
            ls_pod_quant-item_id = siv_itemid.
            SHIFT lv_yearly_cons_forc LEFT DELETING LEADING space.
            lv_value = lv_yearly_cons_forc DIV 1. "Keine Nachkommastellen bei der Jahresverbrauchsprognose
            ls_pod_quant-quantitiy_ext = lv_value.
            IF zcl_agc_datex_utility=>check_dummy_pod( iv_ext_ui = gs_process_step_data-ext_ui ) = abap_false.
              ls_pod_quant-ext_ui = gs_process_step_data-ext_ui.
            ENDIF.
            ls_pod_quant-quant_type_qual = /idexge/if_constants_dp=>gc_qty_31.
            ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
            APPEND ls_pod_quant TO gs_process_step_data-pod_quant.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
