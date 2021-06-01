class ZCL_AGC_DP_OUT_UTILMD_006 definition
  public
  inheriting from ZCL_AGC_DP_OUT_UTILMD_005
  create public .

public section.

  interfaces /ADESSO/IF_MDC_DP_OUT .

  aliases CALL_METHOD
    for /ADESSO/IF_MDC_DP_OUT~CALL_METHOD .
  aliases SET_PROCESS_STEP_DATA
    for /ADESSO/IF_MDC_DP_OUT~SET_PROCESS_STEP_DATA .

  methods ANSWER_CATEGORY
    redefinition .
  methods COMMUNITY_DISCOUNT_SEQ
    redefinition .
  methods CORRECTED_POINT_OF_DELIVERY
    redefinition .
  methods CUSTOMER_VALUE
    redefinition .
  methods DELIVERY_POINT_ADDRESS_DATA
    redefinition .
  methods FIRST_PERIODIC_READING_1
    redefinition .
  methods FRANCHISE_FEE_ASSIGNMENT
    redefinition .
  methods FRANCHISE_FEE_GROUP
    redefinition .
  methods FRANCHISE_FEE_SEQ
    redefinition .
  methods FRANCHISE_FEE_SEQ_1
    redefinition .
  methods GAS_QUALITY
    redefinition .
  methods LOCAL_CONTROL_GROUP_1
    redefinition .
  methods MARKET_AREA
    redefinition .
  methods MESSAGE_CATEGORY
    redefinition .
  methods METERING_DATA_SERVICE
    redefinition .
  methods METERING_OPERATION_SERVICE
    redefinition .
  methods METER_TYPE
    redefinition .
  methods METER_VOLUME_1
    redefinition .
  methods NOTE_TO_POINT_OF_DELIVERY
    redefinition .
  methods OFF_PEAK_ENABLED_1
    redefinition .
  methods POINT_OF_DELIVERY
    redefinition .
  methods POINT_OF_DELIVERY_DATA_SEQ
    redefinition .
  methods SETTLEMENT_TERRITORY
    redefinition .
  methods SETTLEMENT_UNIT
    redefinition .
  methods TAX_INFO_1
    redefinition .
  methods TAX_INFO_SEQ_1
    redefinition .
  methods TEMPERATUE_DEPENDENT_WORK
    redefinition .
  methods TEMPERATURE_MEASUREMENT_POINT
    redefinition .
  methods TRANSACTION_REASON
    redefinition .
  methods VOLUME_CORRECTOR_ATTRIBUTE_1
    redefinition .
  methods VOLUME_CORRECTOR_DATA_1
    redefinition .
  methods VOLUME_CORRECTOR_DATA_SEQ_1
    redefinition .
  methods YEARLY_CONSUMPTION_FORECAST
    redefinition .
  methods PARTNER_NAME
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_DP_OUT_UTILMD_006 IMPLEMENTATION.


  METHOD /adesso/if_mdc_dp_out~call_method.
***************************************************************************************************
* THIMEL.R 20150901 Einführung SDÄ auf Common Layer
*   Variablen setzen wie in /IDXGC/IF_DP_OUT~PROCESS_CONFIGURATION_STEPS
* THIMEL.R 20150918 Sonderbehandlung für nicht regulierte Sparten.
***************************************************************************************************
    siv_data_from_source = is_bmid_config-data_from_source.
    siv_data_from_add_source = is_bmid_config-data_add_source.
    IF is_bmid_config-data_from_source IS NOT INITIAL.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_source.
    ELSEIF is_bmid_config-data_add_source IS NOT INITIAL.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source.
    ELSE.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_default_processing.
    ENDIF.

    IF zcl_agc_masterdata=>is_reg_division_type( iv_division_type = gs_process_step_data-spartyp ) = abap_true AND
       zcl_agc_masterdata=>is_reg_process( is_process_step_data = gs_process_step_data ) = abap_true.
      siv_mandatory_data = is_bmid_config-mandatory.
    ELSE.
      siv_mandatory_data = abap_false.
    ENDIF.

    gs_process_step_data = cs_process_step_data.
    CALL METHOD me->(is_bmid_config-method).
    cs_process_step_data = gs_process_step_data.
  ENDMETHOD.


  METHOD /adesso/if_mdc_dp_out~set_process_step_data.
    gs_process_step_data = is_process_step_data.
    me->instantiate( ).
  ENDMETHOD.


  METHOD answer_category.
    DATA: ls_rejection_details TYPE /idxgc/s_rejection_details,
          ls_msgrespstatus     TYPE /idxgc/s_msgsts_details.

    FIELD-SYMBOLS: <lfs_check_details> TYPE /idxgc/s_check_details.

    IF gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_dso      OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_rec      OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_dso OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_rec.

      CASE gs_process_step_data-bmid+4(1).
        WHEN '4'.
          ls_rejection_details-rejection = /idxgc/if_constants_ide=>gc_respstatus_e15.
          INSERT ls_rejection_details INTO TABLE gs_process_step_data-rejection_list.

          ls_msgrespstatus-respstatus = /idxgc/if_constants_ide=>gc_respstatus_e15.
          ls_msgrespstatus-item_id    = siv_itemid.
          INSERT  ls_msgrespstatus INTO TABLE gs_process_step_data-msgrespstatus.
        WHEN '5'.
          LOOP AT gs_process_data_src-check ASSIGNING <lfs_check_details> WHERE rejection_code IS NOT INITIAL.
            EXIT.
          ENDLOOP.

          IF <lfs_check_details> IS ASSIGNED.
            ls_rejection_details-rejection = <lfs_check_details>-rejection_code.
            INSERT ls_rejection_details INTO TABLE gs_process_step_data-rejection_list.

            ls_msgrespstatus-respstatus = <lfs_check_details>-rejection_code.
            ls_msgrespstatus-item_id    = siv_itemid.
            INSERT  ls_msgrespstatus INTO TABLE gs_process_step_data-msgrespstatus.
          ENDIF.
      ENDCASE.
*>>> Wolf.A., adesso AG, 20.10.2015, Mantis 5089: Berücksichtigung SDÄ Bestandsliste
    ELSEIF gs_process_step_data-proc_id = zif_agc_datex_co=>gc_proc_id_mdchg_blist_dso.
      LOOP AT gs_process_data_src-check ASSIGNING <lfs_check_details> WHERE rejection_code IS NOT INITIAL.
        EXIT.
      ENDLOOP.

      IF <lfs_check_details> IS ASSIGNED.
        ls_rejection_details-rejection = <lfs_check_details>-rejection_code.
        INSERT ls_rejection_details INTO TABLE gs_process_step_data-rejection_list.

        ls_msgrespstatus-respstatus = <lfs_check_details>-rejection_code.
        ls_msgrespstatus-item_id    = siv_itemid.
        INSERT  ls_msgrespstatus INTO TABLE gs_process_step_data-msgrespstatus.
      ELSE.
        ls_rejection_details-rejection = /idxgc/if_constants_ide=>gc_respstatus_e15.
        INSERT ls_rejection_details INTO TABLE gs_process_step_data-rejection_list.

        ls_msgrespstatus-respstatus = /idxgc/if_constants_ide=>gc_respstatus_e15.
        ls_msgrespstatus-item_id    = siv_itemid.
        INSERT  ls_msgrespstatus INTO TABLE gs_process_step_data-msgrespstatus.
      ENDIF.
*<<< Wolf.A., adesso AG, 20.10.2015, Mantis 5089: Berücksichtigung SDÄ Bestandsliste
    ELSE.
      super->answer_category( ).
    ENDIF.
  ENDMETHOD.


  method COMMUNITY_DISCOUNT_SEQ.
***************************************************************************************************
* THIMEL.R, 20150929, Kopie aus /IDEXGE/CL_DP_OUT_UTILMD_005
*   Erweiterung für SDÄ
***************************************************************************************************
    DATA: ls_diverse TYPE /idxgc/s_diverse_details.

    CLEAR: siv_context_rff_ave.

* In case of ES101, ES103, EB103 and CD013, community discount is requird
* if payer of grid usage is 'E10'.
* In case of EB101, community discount is required at any case.
    IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb101 OR
       gs_process_step_data-bmid CS 'CH'. "Erweiterung für SDÄ
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
  endmethod.


  METHOD corrected_point_of_delivery.
***************************************************************************************************
* THIMEL.R, 20150919, Einführung SDÄ auf Common Layer
***************************************************************************************************
    DATA: ls_euitrans TYPE euitrans.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    SELECT SINGLE * FROM euitrans INTO ls_euitrans
      WHERE int_ui = gs_process_step_data-int_ui AND datefrom <= gs_process_step_data-proc_date AND dateto >= gs_process_step_data-proc_date.
    IF ls_euitrans-ext_ui IS NOT INITIAL.
      READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
      IF <fs_diverse> IS ASSIGNED.
        <fs_diverse>-pod_corrected = ls_euitrans-ext_ui.
      ELSE.
        APPEND INITIAL LINE TO gs_process_step_data-diverse ASSIGNING <fs_diverse>.
        <fs_diverse>-item_id       = siv_itemid.
        <fs_diverse>-pod_corrected = ls_euitrans-ext_ui.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD customer_value.
    ">>>SCHMIDT.C 20150107
    "Klasse: ZCL_EDM_UTILITY
    "Methode: GET_CUSTOMER_VALUE_ANLAGE
    "THIMEL.R, 20150919, Anpassung für SDÄ

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

        IF gs_process_step_data-bmid CS 'CH'.

          lv_customer_value = lr_isu_pod->get_customer_value( ).
          CHECK lv_customer_value IS NOT INITIAL.

          READ TABLE gs_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WITH KEY item_id = siv_itemid
                                                                                      ext_ui = gs_process_step_data-ext_ui
                                                                                      quant_type_qual = /idexge/if_constants_dp=>gc_qty_y02.

          IF <fs_pod_quant> IS ASSIGNED.
            <fs_pod_quant>-quantitiy_ext = lv_customer_value.
            SHIFT <fs_pod_quant>-quantitiy_ext LEFT DELETING LEADING space.
            <fs_pod_quant>-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
          ELSE.
            ls_pod_quant-item_id = siv_itemid.
            ls_pod_quant-quantitiy_ext = lv_customer_value.
            SHIFT ls_pod_quant-quantitiy_ext LEFT DELETING LEADING space.
            IF zcl_agc_datex_utility=>check_dummy_pod( iv_ext_ui = gs_process_step_data-ext_ui ) = abap_false.
              ls_pod_quant-ext_ui = gs_process_step_data-ext_ui.
            ENDIF.
            ls_pod_quant-quant_type_qual = /idexge/if_constants_dp=>gc_qty_y02.
            ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
            APPEND ls_pod_quant TO gs_process_step_data-pod_quant.
          ENDIF.

        ELSE.
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
              ENDIF.
              ls_pod_quant-quant_type_qual = /idexge/if_constants_dp=>gc_qty_y02.
              ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
              APPEND ls_pod_quant TO gs_process_step_data-pod_quant.
            ENDIF.
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.


  ENDMETHOD.


  method DELIVERY_POINT_ADDRESS_DATA.
***************************************************************************************************
* THIMEL-R, 20150913, Kopie aus dem aktuellen Standard /IDEXGE/CL_DP_OUT_UTILMD_006
*   In der alten Version wurde COUNTRY_CODE_EXT befüllt.
*   Parameter X_ACTUAL gesetzt für SDÄ
***************************************************************************************************

*----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2014
**
** Usage:
** Set point of delivery address information
**
** Status: <Completed>
*----------------------------------------------------------------------*

** Change History:
*
** Nov. 2012: Status: Created
** Nov. 2014: Status: Redefined
*             Add the logic to allow customer retrieve data from
*             source or additional source flag.
**
*----------------------------------------------------------------------*
    DATA: ls_name_address         TYPE /idxgc/s_nameaddr_details,
          ls_name_address_src     TYPE /idxgc/s_nameaddr_details,
          ls_name_address_src_add TYPE /idxgc/s_nameaddr_details,
          lv_class_name           TYPE seoclsname,
          lv_method_name          TYPE seocpdname,
          lv_msgtext              TYPE string,
          ls_adrpstcode           TYPE adrpstcode,
          lt_adrpstcode           TYPE TABLE OF adrpstcode,
          lv_lines                TYPE i.

    FIELD-SYMBOLS:
      <fs_name_address>      TYPE /idxgc/s_nameaddr_details,
      <fs_name_address_comp> TYPE /idxgc/s_nameaddr_details.

* Check the data processing mode and fill the data accordingly
    CASE siv_data_processing_mode.
* get data from source step
      WHEN /idxgc/if_constants_add=>gc_data_from_source.
       DELETE  gs_process_step_data-name_address
            WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.

        LOOP AT gs_process_data_src-name_address INTO ls_name_address_src
          WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
          APPEND ls_name_address_src TO gs_process_step_data-name_address.
        ENDLOOP.
        IF siv_mandatory_data IS NOT INITIAL AND sy-subrc = 4 .
           MESSAGE e038(/idxgc/ide_add) WITH text-401 INTO lv_msgtext.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.
* get data from additional source step
      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
       DELETE  gs_process_step_data-name_address
            WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.

        LOOP AT gs_process_data_src_add-name_address INTO ls_name_address_src_add
          WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
          APPEND ls_name_address_src TO gs_process_step_data-name_address.
        ENDLOOP.
         IF siv_mandatory_data IS NOT INITIAL AND sy-subrc = 4 .
           MESSAGE e038(/idxgc/ide_add) WITH text-401 INTO lv_msgtext.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.
* get data from default determination logic
      WHEN /idxgc/if_constants_add=>gc_default_processing.

        CASE gs_process_step_data-bmid.
          WHEN /idxgc/if_constants_ide=>gc_bmid_es101 OR
               /idxgc/if_constants_ide=>gc_bmid_es102 OR
               /idxgc/if_constants_ide=>gc_bmid_ec101.
*       Should get the data from source step
            READ TABLE gs_process_data_src-name_address INTO ls_name_address_src
                  WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.

            IF sy-subrc = 0.
              ls_name_address-streetname      = ls_name_address_src-streetname.
              ls_name_address-poboxid         = ls_name_address_src-poboxid.
              ls_name_address-houseid         = ls_name_address_src-houseid.
              ls_name_address-houseid_add     = ls_name_address_src-houseid_add.
              ls_name_address-postalcode      = ls_name_address_src-postalcode.
              ls_name_address-cityname        = ls_name_address_src-cityname.
              ls_name_address-countrycode     = ls_name_address_src-countrycode.
              ls_name_address-nameaddr_add1   = ls_name_address_src-nameaddr_add1.
              ls_name_address-nameaddr_add2   = ls_name_address_src-nameaddr_add2.
            ENDIF.
*      ENDIF.
          WHEN OTHERS.
        ENDCASE.


        IF ( sis_dp_address IS INITIAL ) AND
           ( gs_process_data_src-int_ui IS NOT INITIAL ) AND
           ( ls_name_address IS INITIAL ).
          CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
            EXPORTING
              x_address_type             = 'Z'
              x_int_ui                   = gs_process_data_src-int_ui
              x_actual                   = abap_true
            IMPORTING
              y_eadrdat                  = sis_dp_address
            EXCEPTIONS
              not_found                  = 1
              parameter_error            = 2
              object_not_given           = 3
              address_inconsistency      = 4
              installation_inconsistency = 5
              OTHERS                     = 6.
          IF sy-subrc = 0.
            ls_name_address-streetname      = sis_dp_address-street.
            ls_name_address-poboxid         = sis_dp_address-po_box.
            ls_name_address-houseid         = sis_dp_address-house_num1.
            ls_name_address-houseid_add     = sis_dp_address-house_num2.
            ls_name_address-postalcode      = sis_dp_address-post_code1.
            ls_name_address-cityname        = sis_dp_address-city1.
            ls_name_address-countrycode     = sis_dp_address-country.
            ls_name_address-nameaddr_add1   = sis_dp_address-city2.
            ls_name_address-nameaddr_add2   = sis_dp_address-city2+35(5).
          ENDIF.

        ELSEIF ( sis_dp_address IS NOT INITIAL ) AND
               ( ls_name_address IS INITIAL ).
          ls_name_address-streetname      = sis_dp_address-street.
          ls_name_address-poboxid         = sis_dp_address-po_box.
          ls_name_address-houseid         = sis_dp_address-house_num1.
          ls_name_address-houseid_add     = sis_dp_address-house_num2.
          ls_name_address-postalcode      = sis_dp_address-post_code1.
          ls_name_address-cityname        = sis_dp_address-city1.
          ls_name_address-countrycode     = sis_dp_address-country.
          ls_name_address-nameaddr_add1   = sis_dp_address-city2.
          ls_name_address-nameaddr_add2   = sis_dp_address-city2+35(5).
        ENDIF.

        IF siv_mandatory_data IS NOT INITIAL AND ls_name_address IS INITIAL.
          MESSAGE e038(/idxgc/ide_add) WITH text-401 INTO lv_msgtext.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.

* In case of master data missing, do the following logic to determine country_code
        IF ( ls_name_address-postalcode IS NOT INITIAL ) AND ( ls_name_address-countrycode IS INITIAL ).
          SELECT country
            FROM adrpstcode
            INTO CORRESPONDING FIELDS OF TABLE lt_adrpstcode
           WHERE post_code = ls_name_address-postalcode. "#EC CI_SGLSELECT

          IF sy-subrc = 0.
            DESCRIBE TABLE lt_adrpstcode LINES lv_lines.
            IF lv_lines > 1.
              ls_name_address-countrycode = 'DE'.
            ELSE.
              READ TABLE lt_adrpstcode INTO ls_adrpstcode INDEX 1.
              ls_name_address-countrycode = ls_adrpstcode-country.
            ENDIF.
          ELSE.
            ls_name_address-countrycode = 'DE'.
          ENDIF.
        ENDIF.

        READ TABLE gs_process_step_data-name_address
          ASSIGNING <fs_name_address_comp> WITH KEY item_id = siv_itemid
                                             party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
        IF sy-subrc = 0.
          IF <fs_name_address_comp>-streetname    = ls_name_address-streetname AND
             <fs_name_address_comp>-poboxid       = ls_name_address-poboxid AND
             <fs_name_address_comp>-houseid       = ls_name_address-houseid AND
             <fs_name_address_comp>-houseid_add   = ls_name_address-houseid_add AND
             <fs_name_address_comp>-postalcode    = ls_name_address-postalcode AND
             <fs_name_address_comp>-cityname      = ls_name_address-cityname AND
             <fs_name_address_comp>-countrycode   = ls_name_address-countrycode.

*     For all the address is the same as bussiness partner address, clear partner address
            CLEAR:<fs_name_address_comp>-streetname,
                  <fs_name_address_comp>-poboxid,
                  <fs_name_address_comp>-houseid,
                  <fs_name_address_comp>-houseid_add,
                  <fs_name_address_comp>-postalcode,
                  <fs_name_address_comp>-cityname,
                  <fs_name_address_comp>-countrycode,
                  <fs_name_address_comp>-nameaddr_add1,
                  <fs_name_address_comp>-nameaddr_add2.
          ENDIF.
        ENDIF.

        READ TABLE gs_process_step_data-name_address ASSIGNING <fs_name_address>
          WITH KEY item_id   = siv_itemid
             party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
        IF sy-subrc = 0.
          <fs_name_address>-streetname      = ls_name_address-streetname.
          <fs_name_address>-poboxid         = ls_name_address-poboxid.
          <fs_name_address>-houseid         = ls_name_address-houseid.
          <fs_name_address>-houseid_add     = ls_name_address-houseid_add.
          <fs_name_address>-postalcode      = ls_name_address-postalcode.
          <fs_name_address>-cityname        = ls_name_address-cityname.
          <fs_name_address>-countrycode     = ls_name_address-countrycode.
          "<fs_name_address>-nameaddr_add1   = ls_name_address-nameaddr_add1.
          "<fs_name_address>-nameaddr_add2   = ls_name_address-nameaddr_add2.
        ELSE.
          ls_name_address-item_id         = siv_itemid.
          ls_name_address-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
          CLEAR: ls_name_address-countrycode_ext,
                 ls_name_address-nameaddr_add1,
                 ls_name_address-nameaddr_add2.
          APPEND ls_name_address TO gs_process_step_data-name_address.
        ENDIF.
      WHEN OTHERS.
* do nothing
    ENDCASE.

  ENDMETHOD.


  METHOD first_periodic_reading_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->first_periodic_reading( ).

  ENDMETHOD.


  METHOD franchise_fee_assignment.
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
      "<<< Somberg.J kommentiert, da Konzessionsabgabe ungleich 'TA' Mussfeld ist für ES101
**   In case of ES101, franchise_fee is not a required field
*      IF ( gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101 ) AND
*         ( <fs_charges>-franchise_fee IS INITIAL ).
*        CONTINUE.
*      ENDIF.

      <fs_charges>-fr_fee_assign = /idxgc/if_constants_ide=>gc_cci_chardesc_code_z08.

    ENDLOOP.

  ENDMETHOD.


  METHOD franchise_fee_group.
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

          me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ). "RT, Mantis 5041, EXT_UI ist bei SDÄ leer.

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
          IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101 AND <fs_charges>-franchise_fee = 'TA'.
            DELETE gs_process_step_data-charges.
          ENDIF.
        ENDLOOP.

      CATCH zcx_agc_masterdata.
    ENDTRY.
  ENDMETHOD.


  METHOD franchise_fee_seq.

    ">>>Schmidt.C 20150203 Für EoG aus Quellschritt übernehmen
    ">>>Somberg.J 20150915 Für ES101 aussternen

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
*      ">>>SCHMIDT.C 20150224 Kopie aus dem Standard mit Anpassung der IF-Abfrage (= durch CP ersetzt!) =>Nach IDEXGE Patch zurück bauen!
**     In case the field "Register Code" is not filled in the trigger report,
**     segment group SG8_SEQ+Z07 should not be displayed in the IDOC
*      IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101.
*        CHECK gs_process_data_src-charges IS NOT INITIAL.
*      ENDIF.

      me->get_device_register_data( ).

      IF gs_process_step_data-bmid NE /idxgc/if_constants_ide=>gc_bmid_es101. " Maxim Schmidt, 30.03.2016, Mantis 5295: Test LW22_Anfrage nicht korrekt
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
      ENDIF. " Maxim Schmidt, 30.03.2016, Mantis 5295: Test LW22_Anfrage nicht korrekt
* If without charges data, get data from source data
      IF ls_charges_data IS INITIAL.
        IF gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101. "Falls es zum Zeitpunkt der Anmeldung noch kein Gerät in der Anlage gibt soll trotzdem die KA mit gesendet werden
*>>> Maxim Schmidt, 30.03.2016, Mantis 5295: Test LW22_Anfrage nicht korrekt
*            ls_charges_data-charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z07.
*            ls_charges_data-item_id  = siv_itemid.
*            APPEND ls_charges_data TO gs_process_step_data-charges.
*<<< Maxim Schmidt, 30.03.2016, Mantis 5295: Test LW22_Anfrage nicht korrekt
        ELSE.
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
    ENDIF.
  ENDMETHOD.


  METHOD franchise_fee_seq_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************
    FIELD-SYMBOLS: <fs_charges> TYPE /idxgc/s_charges_details.

    me->franchise_fee_seq( ).

    "Kein RFF Segment für SDÄ
    LOOP AT gs_process_step_data-charges ASSIGNING <fs_charges>.
      CLEAR: <fs_charges>-ext_ui.
    ENDLOOP.

  ENDMETHOD.


  METHOD gas_quality.
    DATA: ls_diverse     TYPE /idxgc/s_diverse_details,
          lv_gas_quality TYPE /idxgc/de_gas_quality.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-gas_quality IS NOT INITIAL.
        lv_gas_quality = ls_diverse-gas_quality.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.

          IF lv_gas_quality IS INITIAL.
            lv_gas_quality = lr_isu_pod->get_gas_quality( ).
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-gas_quality = lv_gas_quality.
          ELSE.
            ls_diverse-item_id     = siv_itemid.
            ls_diverse-gas_quality = lv_gas_quality.
            APPEND ls_diverse TO gs_process_step_data-diverse.
          ENDIF.

        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD local_control_group_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->local_control_group( ).

  endmethod.


  METHOD market_area.
    DATA: ls_diverse     TYPE /idxgc/s_diverse_details,
          lv_market_area TYPE /idxgc/de_market_area.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    "Quellschrittdaten lesen oder bei Antwort auf EoG
    IF siv_data_from_source = /idxgc/if_constants=>gc_true OR
       gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb103.

      READ TABLE gs_process_data_src-diverse INTO ls_diverse WITH KEY item_id = siv_itemid.
      IF ls_diverse-market_area_a IS NOT INITIAL.
        lv_market_area = ls_diverse-market_area_a.
      ENDIF.
    ENDIF.

    TRY.
        me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas.

          IF lv_market_area IS INITIAL.
            lv_market_area = lr_isu_pod->get_market_area( ).
          ENDIF.

          READ TABLE gs_process_step_data-diverse ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
          IF <fs_diverse> IS ASSIGNED.
            <fs_diverse>-market_area_a = lv_market_area.
          ELSE.
            ls_diverse-item_id     = siv_itemid.
            ls_diverse-market_area_a = lv_market_area.
            APPEND ls_diverse TO gs_process_step_data-diverse.
          ENDIF.

        ENDIF.
      CATCH zcx_agc_masterdata.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD message_category.
***************************************************************************************************
* THIMEL.R 20150316 Einführung CL
*    Für Stornonachrichten haben wir keinen eigenen Prozess. Die Kategorie muss also vom aktuellen
*       Prozess übernommen werden.
* THIMEL.R 20150424 M4901 Mehrere Stornos im Prozess
*    Bei mehreren Stornos im Prozess muss die richtige Ursprungsnachricht gefunden werden.
* THIMEL.R 20150901 Anpassung für Stammdatenänderung und Gerätereplikation
***************************************************************************************************
    DATA: lv_bmid    TYPE /idxgc/de_bmid,
          lv_msgtext TYPE string.

    lv_bmid = gs_process_step_data-bmid.

    IF lv_bmid = /idxgc/if_constants_ide=>gc_bmid_er901 OR
       lv_bmid = /idxgc/if_constants_ide=>gc_bmid_er902 OR
       lv_bmid = /idxgc/if_constants_ide=>gc_bmid_er903.
      IF gs_process_step_data-assoc_servprov = gs_process_data_src_add-assoc_servprov. ">>>THIMEL.R 20150424 M4901
        gs_process_step_data-docname_code = gs_process_data_src_add-docname_code.
      ELSE.
        gs_process_step_data-docname_code = gs_process_data_src-docname_code.
      ENDIF.

      gs_process_step_data-document_ident = siv_refno.

      IF gs_process_step_data-docname_code IS INITIAL.
        MESSAGE e038(/idxgc/ide_add) WITH text-201 INTO lv_msgtext.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.
    ELSEIF gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_dso      OR
           gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_rec      OR
           gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_dso OR
           gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_rec.
      gs_process_step_data-docname_code = /idxgc/if_constants_ide=>gc_msg_category_e03.
      gs_process_step_data-document_ident = siv_refno.
    ELSE.
      CALL METHOD super->message_category.
    ENDIF.

  ENDMETHOD.


  method METERING_DATA_SERVICE.
***************************************************************************************************
* SCHMIDT.C 20150204 mdl / MDL stehen an den ZEDM-Zeitscheiden
* THIMEL.R 20151009 M5118 Kopiert aus ZCL_AGC_DP_OUT_UTILMD_005
*   Bei SDÄ muss ggf. die Tabelle SIT_POD_DEV_RELATION vorher gefüllt werden.
***************************************************************************************************
    DATA: ls_service_provider TYPE /idxgc/s_service_provider,
          ls_mdl              TYPE eservprov,
          lv_codelistid       TYPE e_edmideextcodelistid.

    FIELD-SYMBOLS: <fs_pod_dev_relation> TYPE /idxgc/s_pod_dev_relation.

    CLEAR: siv_context_rff_ave.
*>>> THIMEL.R 20151009 M5118
    IF sit_pod_dev_relation IS INITIAL.
      me->get_pod_dev_relation_data( ).
    ENDIF.
*<<< THIMEL.R 20151009 M5118
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


  METHOD METERING_OPERATION_SERVICE.
***************************************************************************************************
* SCHMIDT.C 20150204 MSB / MDL stehen an den ZEDM-Zeitscheiden
* THIMEL.R 20151009 M5118 Kopiert aus ZCL_AGC_DP_OUT_UTILMD_005
*   Bei SDÄ muss ggf. die Tabelle SIT_POD_DEV_RELATION vorher gefüllt werden.
***************************************************************************************************
    DATA: ls_service_provider TYPE /idxgc/s_service_provider,
          ls_msb              TYPE eservprov,
          lv_codelistid       TYPE e_edmideextcodelistid.

    FIELD-SYMBOLS: <fs_pod_dev_relation> TYPE /idxgc/s_pod_dev_relation.

    CLEAR: siv_context_rff_ave.

*>>> THIMEL.R 20151009 M5118
    IF sit_pod_dev_relation IS INITIAL.
      me->get_pod_dev_relation_data( ).
    ENDIF.
*<<< THIMEL.R 20151009 M5118
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


  METHOD meter_type.
    TRY.
        CALL METHOD super->meter_type.
      CATCH /idxgc/cx_process_error.
        IF siv_mandatory_data = abap_true.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.
    ENDTRY.
  ENDMETHOD.


  METHOD meter_volume_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->meter_volume( ).

  ENDMETHOD.


  METHOD note_to_point_of_delivery.
***************************************************************************************************
* THIMEL.R, 20150924, Eigene Logik für SWS: Sonderkennzeichen zu Verträgen werden hier übermittelt
***************************************************************************************************
    DATA: lr_previous        TYPE REF TO cx_root,
          lv_free_text_value TYPE        /idxgc/de_free_text_value.

    FIELD-SYMBOLS: <fs_msgcomments> TYPE /idxgc/s_msgcom_details.

    IF gs_process_step_data-bmid CS 'CH'. "Nur für Stammdatenänderungen
      TRY.
          IF me->lr_isu_pod IS NOT BOUND.
            me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).
          ENDIF.
          lv_free_text_value = zcl_agc_masterdata=>get_contract_comment( is_ever = me->lr_isu_pod->get_ever( ) ).
        CATCH zcx_agc_masterdata INTO lr_previous.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
      ENDTRY.

      READ TABLE gs_process_step_data-msgcomments ASSIGNING <fs_msgcomments> WITH KEY item_id = siv_itemid text_subj_qual = zif_agc_datex_utilmd_co=>gc_text_subj_qual_aai.
      IF <fs_msgcomments> IS NOT ASSIGNED.
        APPEND INITIAL LINE TO gs_process_step_data-msgcomments ASSIGNING <fs_msgcomments>.
        <fs_msgcomments>-text_subj_qual = zif_agc_datex_utilmd_co=>gc_text_subj_qual_aai.
        <fs_msgcomments>-item_id        = siv_itemid.
        <fs_msgcomments>-commentnum     = <fs_msgcomments>-commentnum + 1.
      ENDIF.

      <fs_msgcomments>-free_text_value = lv_free_text_value.
    ENDIF.
  ENDMETHOD.


  METHOD off_peak_enabled_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->off_peak_enabled( ).

  ENDMETHOD.


  METHOD partner_name.
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
      IF gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_es103. "Wolf.A., adesso AG, 12.01.2016, Mantis 4960
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
*>>> Wolf.A., adesso AG, 12.01.2016, Mantis 4960
      ELSE.         "Bei Antwort auf Anmeldung (Netzseite) soll der Titel bereits korrekt hinterlegt worden sein.
        CASE ls_but000-title.
          WHEN 'P001'.
            lv_partnerformat = /idxgc/if_constants_ide=>gc_name_format_code_person.
          WHEN 'F001'.
            lv_partnerformat = /idxgc/if_constants_ide=>gc_name_format_code_company.
          WHEN OTHERS.
            lv_partnerformat = /idxgc/if_constants_ide=>gc_name_format_code_company.
        ENDCASE.
      ENDIF.
*<<< Wolf.A., adesso AG, 12.01.2016, Mantis 4960

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


  METHOD point_of_delivery.

    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

    TRY.
        CALL METHOD super->point_of_delivery.

        CASE gs_process_step_data-bmid.
          WHEN /idxgc/if_constants_ide=>gc_bmid_ch122. "Versand Stammdatenänderung Gerätewechsel
            LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod>.
              <fs_pod>-no_ref_pod_data = abap_true.
            ENDLOOP.
        ENDCASE.

      CATCH /idxgc/cx_process_error .
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD point_of_delivery_data_seq.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
*   Für die Gerätedatenermittlung bei SDÄ muss teilweise diese Methode aufgerufen werden. Es wird
*   aber nie ein RFF+AVE angegeben.
* THIMEL.R, 20151102, RFF+AVE wird bei ZD0 angegeben. Kennzeichen wird auch beim ZP gesetzt. Daher
*   kann die Ermittlung hier eigentlich entfernt werden. > Löschen bei nächster FA.
***************************************************************************************************
    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

    CALL METHOD super->point_of_delivery_data_seq.

    CHECK gs_process_step_data-bmid(2) = 'CH'.

    LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod>
      WHERE item_id = siv_itemid.
      <fs_pod>-no_ref_pod_data = abap_true.
    ENDLOOP.
  ENDMETHOD.


  METHOD settlement_territory.
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
          lv_settlterr_ext = zcl_agc_masterdata=>get_settlement_territory( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ir_isu_pod = lr_isu_pod ).

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


  METHOD settlement_unit.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_bilanzkreisverantw

    "01.10.2015 - Ergänzung für SDÄ BMID CH*

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

        IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas AND ls_v_eanl-zzedmmgebiet CS 'EXT' AND gs_process_step_data-bmid(2) <> 'CH'.

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


  METHOD tax_info_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->tax_info( ).

  ENDMETHOD.


  METHOD tax_info_seq_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->tax_info_seq( ).

  ENDMETHOD.


  METHOD temperatue_dependent_work.
***************************************************************************************************
* THIMEL.R, 20150927, Kopiert aus ZCL_AGC_DP_OUT_UTILMD_005 und Umstellung auf PROGYEARCONS auch
*   für Vertrieb.
* THIMEL.R, 20151006, Anpassung für SDÄ Vergleich (M5111)
***************************************************************************************************
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
            IF gs_process_step_data-bmid <> /idxgc/if_constants_ide=>gc_bmid_eb101.
              lv_temperatue_dep_wk = lr_isu_pod->get_progyearcons( ).
              IF lv_temperatue_dep_wk IS INITIAL.
                lv_temperatue_dep_wk = lr_isu_pod->get_perverbr( ).
              ENDIF.
            ELSE.
              IF siv_transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z36 AND "Bei Z36 EoG immer den Periodenverbrauch auf 1 setzen.
                  gs_process_step_data-bmid = /idxgc/if_constants_ide=>gc_bmid_eb101.
                lv_temperatue_dep_wk = 1.
              ELSEIF siv_transreason <> /idxgc/if_constants_ide=>gc_trans_reason_code_z36.
                lv_temperatue_dep_wk = lr_isu_pod->get_progyearcons( ).
                IF lv_temperatue_dep_wk IS INITIAL.
                  lv_temperatue_dep_wk = lr_isu_pod->get_perverbr( ).
                ENDIF.
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
            SHIFT ls_pod_quant-quantitiy_ext LEFT DELETING LEADING space. "THIMEL.R, 20151006, M5111
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


  METHOD temperature_measurement_point.
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
*>>> Maxim Schmidt, 14.10.2015, Mantis 5122: PROD - Änderung des Temperaturanbieters bei NN-Anmeldungen für TLP-Anlagen
*              lv_tempanbieter   = 'ZT2'.
              lv_tempanbieter   = 'ZT3'.
*<<< Maxim Schmidt, 14.10.2015, Mantis 5122: PROD - Änderung des Temperaturanbieters bei NN-Anmeldungen für TLP-Anlagen
            ELSE.
              lv_tempmessstelle = ls_v_eanl-zztempmessstelle.
              lv_tempanbieter   = ls_v_eanl-zztempanbieter.
            ENDIF.

          ELSEIF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom AND
                 lr_isu_pod->get_metmethod( ) = zcl_agc_masterdata=>gc_metmethod_e14.
            lv_tempmessstelle = '10415'.
*>>> Maxim Schmidt, 14.10.2015, Mantis 5122: PROD - Änderung des Temperaturanbieters bei NN-Anmeldungen für TLP-Anlagen
*            lv_tempanbieter = 'ZT2'.
            lv_tempanbieter   = 'ZT3'.
*<<< Maxim Schmidt, 14.10.2015, Mantis 5122: PROD - Änderung des Temperaturanbieters bei NN-Anmeldungen für TLP-Anlagen
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

*>>> Wolf.A., adesso AG, 20.10.2015, Mantis 5089: Berücksichtigung SDÄ Bestandsliste
    DATA: ls_diverse_new    TYPE /idxgc/s_diverse_details,
          lv_msgtransreason TYPE /idxgc/de_msgtransreason.

    FIELD-SYMBOLS:
      <fs_diverse> TYPE /idxgc/s_diverse_details.
*<<< Wolf.A., adesso AG, 20.10.2015, Mantis 5089: Berücksichtigung SDÄ Bestandsliste
    IF gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_dso      OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_rec      OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_dso OR
       gs_process_step_data-proc_id = /idxgc/if_constants_add=>gc_proc_id_mdchg_park_rec.
      super->transaction_reason( ).
*>>> Wolf.A., adesso AG, 20.10.2015, Mantis 5089: Berücksichtigung SDÄ Bestandsliste
    ELSEIF gs_process_step_data-proc_id = zif_agc_datex_co=>gc_proc_id_mdchg_blist_dso.
      lv_msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_zd0.   "ZD0

      READ TABLE gs_process_step_data-diverse
          ASSIGNING <fs_diverse> WITH KEY item_id = siv_itemid.
      IF sy-subrc <> 0.
        ls_diverse_new-item_id = siv_itemid.
        ls_diverse_new-msgtransreason = lv_msgtransreason.
        APPEND ls_diverse_new TO gs_process_step_data-diverse.
      ELSE.
        <fs_diverse>-msgtransreason = lv_msgtransreason.
      ENDIF.
*<<< Wolf.A., adesso AG, 20.10.2015, Mantis 5089: Berücksichtigung SDÄ Bestandsliste
    ENDIF.
  ENDMETHOD.


  METHOD volume_corrector_attribute_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->volume_corrector_attribute( ).

  ENDMETHOD.


  METHOD volume_corrector_data_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->volume_corrector_data( ).

  ENDMETHOD.


  METHOD volume_corrector_data_seq_1.
***************************************************************************************************
* THIMEL.R, 20150918, Einführung SDÄ
***************************************************************************************************

    me->volume_corrector_data_seq( ).

  ENDMETHOD.


  METHOD yearly_consumption_forecast.
    ">>>SCHMIDT.C 20150107
    "Include: LZ_LW_CONTAINERFUBASF01
    "Form: hole_jvb
    "THIMEL.R, 20150919, Anpassung Formatierung für SDÄ wie im Standard
    DATA: ls_pod_quant        TYPE /idxgc/s_pod_quant_details,
          lv_yearly_cons_forc TYPE eideswtmdprogyearcons,
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

            CASE gs_process_step_data-bmid.
              WHEN /idxgc/if_constants_ide=>gc_bmid_eb101.
                IF zcl_agc_masterdata=>is_netz( ) = abap_true AND
                   siv_transreason <> /idxgc/if_constants_ide=>gc_trans_reason_code_z36 AND
                   siv_transreason <> /idxgc/if_constants_ide=>gc_trans_reason_code_z37 AND " Maxim Schmidt, 05.10.2015, Mantis 5070: TEST # Prognosewert #1# wird bei Neuanlagen nicht übertragen
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
*>>> THIMEL.R, 20150924, auf Lieferseite soll nicht primär der Periodenverbrauch genutzt werden.
*                IF zcl_agc_masterdata=>is_netz( ) = abap_true AND
*                   ( lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom OR
*                   lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas ).
*                lv_yearly_cons_forc = lr_isu_pod->get_progyearcons( ).
                IF lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_strom OR
                   lr_isu_pod->get_sparte( ) = zif_agc_datex_utilmd_co=>gc_sparte_gas .
                  lv_yearly_cons_forc = lr_isu_pod->get_progyearcons( ).
                  IF lv_yearly_cons_forc IS INITIAL.
                    lv_yearly_cons_forc = lr_isu_pod->get_perverbr( ).
                  ENDIF.
*<<< THIMEL.R, 20150924
                ELSE.
                  lv_yearly_cons_forc = lr_isu_pod->get_perverbr( ).
                ENDIF.
            ENDCASE.
          ENDIF.

          READ TABLE gs_process_step_data-pod_quant ASSIGNING <fs_pod_quant> WITH KEY item_id = siv_itemid
                                                                                      ext_ui = gs_process_step_data-ext_ui
                                                                                      quant_type_qual = /idexge/if_constants_dp=>gc_qty_31.

          IF <fs_pod_quant> IS ASSIGNED.
            WRITE lv_yearly_cons_forc TO <fs_pod_quant>-quantitiy_ext NO-GROUPING LEFT-JUSTIFIED DECIMALS 0.
            <fs_pod_quant>-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
          ELSE.
            ls_pod_quant-item_id = siv_itemid.
            WRITE lv_yearly_cons_forc TO ls_pod_quant-quantitiy_ext NO-GROUPING LEFT-JUSTIFIED DECIMALS 0.
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
