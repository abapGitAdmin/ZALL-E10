class ZCL_AGC_DP_OUT_UTILMD_007 definition
  public
  inheriting from ZCL_AGC_DP_OUT_UTILMD_006
  create public .

public section.

  methods ALREADY_EXCH_METERING_PROC
    redefinition .
  methods ALREADY_EXCH_POD_TYPE
    redefinition .
  methods CORRESPONDENCE_ADDRESS
    redefinition .
  methods DELIVERY_POINT_ADDRESS_DATA
    redefinition .
  methods NAME_ADDRESS_MR_CARD
    redefinition .
  methods NAME_ADDRESS_REFERENCE_Z05
    redefinition .
  methods PARTNER_NAME
    redefinition .
  methods SUPPLY_OWNER_NAME
    redefinition .
  methods MDS_BASIC_RESPONSIBILITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_DP_OUT_UTILMD_007 IMPLEMENTATION.


  METHOD already_exch_metering_proc.
***************************************************************************************************
* THIMEL.R, 20160308, Methode implementiert für SDÄ
***************************************************************************************************
    DATA: lr_badi_datapro TYPE REF TO /idxgc/badi_data_provision,
          lr_previous     TYPE REF TO cx_root,
          ls_diverse      TYPE        /idxgc/s_diverse_details,
          lv_class_name   TYPE        seoclsname,
          lv_method_name  TYPE        seocpdname,
          lv_mtext        TYPE        string.

    IF gs_process_step_data-bmid(2) = 'CH'. "Nur für SDÄ
      IF siv_mandatory_data = abap_true.
        TRY.
            GET BADI lr_badi_datapro.
          CATCH cx_badi_not_implemented cx_badi_multiply_implemented INTO lr_previous.
            MESSAGE e007(/idxgc/general) INTO lv_mtext WITH /idxgc/if_constants_ddic_add=>gc_badi_data_provision.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
        ENDTRY.

        TRY.
            CALL BADI lr_badi_datapro->already_exch_metering_proc
              EXPORTING
                is_process_data_src     = gs_process_data_src
                is_process_data_src_add = gs_process_data_src_add
                is_process_data         = gs_process_step_data
                iv_itemid               = siv_itemid
              CHANGING
                ct_diverse              = gs_process_step_data-diverse.

          CATCH /idxgc/cx_process_error INTO lr_previous.
            CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_source_pos
              IMPORTING
                ev_class_name  = lv_class_name
                ev_method_name = lv_method_name.
            MESSAGE e021(/idxgc/ide_add) INTO lv_mtext WITH lv_class_name lv_method_name.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
        ENDTRY.

* Check whether the field is required, otherwise raise exception for the missing field
        READ TABLE gs_process_step_data-diverse INTO ls_diverse INDEX siv_itemid.
        IF ( siv_mandatory_data = abap_true ) AND ( ls_diverse-exch_meter_proc IS INITIAL ).
          MESSAGE e038(/idxgc/ide_add) WITH text-121 INTO lv_mtext.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD already_exch_pod_type.
***************************************************************************************************
* THIMEL.R, 20160308, Methode implementiert für SDÄ
***************************************************************************************************
    DATA: lr_badi_datapro TYPE REF TO /idxgc/badi_data_provision,
          lr_previous     TYPE REF TO cx_root,
          lv_mtext        TYPE        string,
          lv_class_name   TYPE        seoclsname,
          lv_method_name  TYPE        seocpdname.

    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

    IF gs_process_step_data-bmid(2) = 'CH'. "Nur für SDÄ
      LOOP AT gs_process_step_data-pod ASSIGNING <fs_pod> WHERE item_id = siv_itemid.

        IF siv_mandatory_data = abap_true.
          TRY.
              GET BADI lr_badi_datapro.
            CATCH cx_badi_not_implemented cx_badi_multiply_implemented INTO lr_previous.
              MESSAGE e007(/idxgc/general) INTO lv_mtext WITH /idxgc/if_constants_ddic_add=>gc_badi_data_provision.
              /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
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
            CATCH /idxgc/cx_process_error INTO lr_previous.
              CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_source_pos
                IMPORTING
                  ev_class_name  = lv_class_name
                  ev_method_name = lv_method_name.
              MESSAGE e021(/idxgc/ide_add) INTO lv_mtext WITH lv_class_name lv_method_name.
              /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
          ENDTRY.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD correspondence_address.
* Wolf.A.: übernommen aus dem Standard (/IDEXGE/CL_DP_OUT_UTILMD_007)

    DATA:
      ls_name_address_src TYPE        /idxgc/s_nameaddr_details,
      lr_badi_datapro     TYPE REF TO /idxgc/badi_data_provision,
      lx_previous         TYPE REF TO /idxgc/cx_process_error,
      lr_root             TYPE REF TO cx_root,
      lv_class_name       TYPE        seoclsname,
      lv_method_name      TYPE        seocpdname,
      lv_mtext            TYPE        string.

    FIELD-SYMBOLS:
      <fs_name_address> TYPE /idxgc/s_nameaddr_details.

* Check the data processing mode and fill the data accordingly
    CASE siv_data_processing_mode.
* get data from source step
      WHEN /idxgc/if_constants_add=>gc_data_from_source.
        DELETE gs_process_step_data-name_address
               WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.

        LOOP AT gs_process_data_src-name_address INTO ls_name_address_src
          WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.
          APPEND ls_name_address_src TO gs_process_step_data-name_address.
        ENDLOOP.

* get data from additional source step
      WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
        DELETE gs_process_step_data-name_address
               WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.

        LOOP AT gs_process_data_src_add-name_address INTO ls_name_address_src
          WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.
          APPEND ls_name_address_src TO gs_process_step_data-name_address.
        ENDLOOP.

* get data from default determination logic
      WHEN /idxgc/if_constants_add=>gc_default_processing.

* Get partner address data
        TRY.
            GET BADI lr_badi_datapro.
          CATCH cx_badi_not_implemented
                cx_badi_multiply_implemented INTO lr_root.
            MESSAGE e007(/idxgc/general) INTO lv_mtext
                                         WITH /idxgc/if_constants_ddic_add=>gc_badi_data_provision.
            CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
              EXPORTING
                ir_previous = lr_root.
        ENDTRY.
        TRY.
            CALL BADI lr_badi_datapro->correspondence_address
              EXPORTING
                is_process_data_src     = gs_process_data_src
                is_process_data_src_add = gs_process_data_src_add
                is_process_data         = gs_process_step_data
                iv_itemid               = siv_itemid
              CHANGING
                ct_name_address         = gs_process_step_data-name_address.
          CATCH /idxgc/cx_process_error INTO lx_previous.
            CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_source_pos
              IMPORTING
                ev_class_name  = lv_class_name
                ev_method_name = lv_method_name.
            MESSAGE e021(/idxgc/ide_add) INTO lv_mtext WITH lv_class_name lv_method_name.
            /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
        ENDTRY.

      WHEN OTHERS.
* do nothing
    ENDCASE.

    READ TABLE gs_process_step_data-name_address TRANSPORTING NO FIELDS
        WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.

    IF sy-subrc <> 0 AND siv_mandatory_data = abap_true.
      MESSAGE e038(/idxgc/ide_add) WITH text-163 INTO lv_mtext.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD delivery_point_address_data.
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
** Feb. 2016  Status: Redefined (Wolf. A.)
*             Hausnummer + Hausnummerzusatz in einem Feld
*----------------------------------------------------------------------*
    DATA: ls_name_address         TYPE          /idxgc/s_nameaddr_details,
          ls_name_address_src     TYPE          /idxgc/s_nameaddr_details,
          ls_name_address_src_add TYPE          /idxgc/s_nameaddr_details,
          lv_class_name           TYPE          seoclsname,
          lv_method_name          TYPE          seocpdname,
          lv_msgtext              TYPE          string,
          ls_adrpstcode           TYPE          adrpstcode,
          lt_adrpstcode           TYPE TABLE OF adrpstcode,
          lv_lines                TYPE          i,
          lr_badi_datapro         TYPE REF TO   /idxgc/badi_data_provision,
          lx_previous             TYPE REF TO   /idxgc/cx_process_error,
          lr_root                 TYPE REF TO   cx_root,
          lr_utility              TYPE REF TO   /idxgc/cl_utility_generic,
          lv_houseid              TYPE          /idxgc/de_houseid,
          lv_houseid_add          TYPE          /idxgc/de_houseid_add.

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
              ls_name_address-houseid_compl   = ls_name_address_src-houseid_compl.
              ls_name_address-district        = ls_name_address_src-district.
              ls_name_address-postalcode      = ls_name_address_src-postalcode.
              ls_name_address-cityname        = ls_name_address_src-cityname.
              ls_name_address-countrycode     = ls_name_address_src-countrycode.
              ls_name_address-addr_add1       = ls_name_address_src-addr_add1.
              ls_name_address-addr_add2       = ls_name_address_src-addr_add2.
              ls_name_address-addr_add3       = ls_name_address_src-addr_add3.
              ls_name_address-addr_add4       = ls_name_address_src-addr_add4.
              ls_name_address-addr_add5       = ls_name_address_src-addr_add5.
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
            ls_name_address-district        = sis_dp_address-cityp_code.
            ls_name_address-postalcode      = sis_dp_address-post_code1.
            ls_name_address-cityname        = sis_dp_address-city1.
            ls_name_address-countrycode     = sis_dp_address-country.
            ls_name_address-addr_add1       = sis_dp_address-city2.
            ls_name_address-addr_add2       = sis_dp_address-city2+35(5).
            TRY .
                lr_utility = /idxgc/cl_utility_generic=>get_instance( ).

                lv_houseid     = sis_dp_address-house_num1.
                lv_houseid_add = sis_dp_address-house_num2.
                CALL METHOD lr_utility->concat_houseid_compl
                  EXPORTING
                    iv_housenum      = lv_houseid
                    iv_house_sup     = lv_houseid_add
                  IMPORTING
                    ev_houseid_compl = ls_name_address-houseid_compl.

              CATCH /idxgc/cx_utility_error INTO lr_root.
                CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_root ).
            ENDTRY.
          ENDIF.

        ELSEIF ( sis_dp_address IS NOT INITIAL ) AND
               ( ls_name_address IS INITIAL ).
          ls_name_address-streetname      = sis_dp_address-street.
          ls_name_address-poboxid         = sis_dp_address-po_box.
          ls_name_address-district        = sis_dp_address-cityp_code.
          ls_name_address-postalcode      = sis_dp_address-post_code1.
          ls_name_address-cityname        = sis_dp_address-city1.
          ls_name_address-countrycode     = sis_dp_address-country.
          ls_name_address-addr_add1       = sis_dp_address-city2.
          ls_name_address-addr_add2       = sis_dp_address-city2+35(5).
          TRY .
              lr_utility = /idxgc/cl_utility_generic=>get_instance( ).

              lv_houseid     = sis_dp_address-house_num1.
              lv_houseid_add = sis_dp_address-house_num2.
              CALL METHOD lr_utility->concat_houseid_compl
                EXPORTING
                  iv_housenum      = lv_houseid
                  iv_house_sup     = lv_houseid_add
                IMPORTING
                  ev_houseid_compl = ls_name_address-houseid_compl.

            CATCH /idxgc/cx_utility_error INTO lr_root.
              CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_root ).
          ENDTRY.
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

        READ TABLE gs_process_step_data-name_address ASSIGNING <fs_name_address>
          WITH KEY item_id   = siv_itemid
             party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
        IF sy-subrc = 0.
          <fs_name_address>-streetname      = ls_name_address-streetname.
          <fs_name_address>-poboxid         = ls_name_address-poboxid.
          <fs_name_address>-houseid_compl   = ls_name_address-houseid_compl.
          <fs_name_address>-district        = ls_name_address-district.
          <fs_name_address>-postalcode      = ls_name_address-postalcode.
          <fs_name_address>-cityname        = ls_name_address-cityname.
          <fs_name_address>-countrycode     = ls_name_address-countrycode.
          "<fs_name_address>-addr_add1   = ls_name_address-addr_add1.
          "<fs_name_address>-addr_add2   = ls_name_address-addr_add2.
          "<fs_name_address>-addr_add3   = ls_name_address-addr_add3.
          "<fs_name_address>-addr_add4   = ls_name_address-addr_add4.
          "<fs_name_address>-addr_add5   = ls_name_address-addr_add5.
        ELSE.
          ls_name_address-item_id         = siv_itemid.
          ls_name_address-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
          CLEAR: ls_name_address-countrycode_ext,
                 ls_name_address-addr_add1,
                 ls_name_address-addr_add2,
                 ls_name_address-addr_add3,
                 ls_name_address-addr_add4,
                 ls_name_address-addr_add5.
          APPEND ls_name_address TO gs_process_step_data-name_address.
        ENDIF.
      WHEN OTHERS.
* do nothing
    ENDCASE.

  ENDMETHOD.


  METHOD mds_basic_responsibility.
***************************************************************************************************
* SCHMIDT.C 20150204 JA / NEIN Entscheidung erweitert
* THIMEL.R, 20160308, Logik aus Klasse ...005 übernommen, EXT_UI bei SDÄ löschen
***************************************************************************************************

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
          IF gs_process_step_data-bmid(2) <> 'CH'. "THIMEL.R, 20160308, Mantis 5258
            ls_marketpartner_add-ext_ui = ls_pod_dev_relation-ext_ui.
          ENDIF.
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


  method NAME_ADDRESS_MR_CARD.
* Wolf.A.: übernommen aus dem Standard (/IDEXGE/CL_DP_OUT_UTILMD_007)
  DATA:
    ls_name_address_src    TYPE /idxgc/s_nameaddr_details,
    ls_name_address_src_ud TYPE /idxgc/s_nameaddr_details,
    ls_name_address_src_dp TYPE /idxgc/s_nameaddr_details,
    ls_name_address_z05    TYPE /idxgc/s_nameaddr_details,
    lr_badi_datapro        TYPE REF TO /idxgc/badi_data_provision,
    lx_previous            TYPE REF TO /idxgc/cx_process_error,
    lr_root                TYPE REF TO cx_root,
    lv_class_name          TYPE seoclsname,
    lv_method_name         TYPE seocpdname,
    lv_mtext               TYPE string.

  FIELD-SYMBOLS:
      <fs_name_address>    TYPE /idxgc/s_nameaddr_details.

  IF gs_process_step_data-bmid NE /idxgc/if_constants_ide=>gc_bmid_es101 AND
     gs_process_step_data-bmid NE /idxgc/if_constants_ide=>gc_bmid_es103 AND
     gs_process_step_data-bmid NE /idxgc/if_constants_ide=>gc_bmid_eb103 AND
     gs_process_step_data-bmid NE /idxgc/if_constants_ide=>gc_bmid_eb101.
    RETURN.
  ENDIF.

  IF gs_process_step_data-bmid EQ /idxgc/if_constants_ide=>gc_bmid_eb101.
* In case of flatrate installation, data is not to be filled
    IF siv_inst_type IS INITIAL.
      CALL METHOD me->get_inst_type( ).
    ENDIF.
    IF siv_inst_type = /idexge/if_constants_dp=>gc_inst_type_rate_instal.
      RETURN.
    ENDIF.
* If reference to POD corresponds to POD with POD type Z30, data is not to be filled
    IF sit_pod_dev_relation IS INITIAL.
      CALL METHOD me->get_pod_dev_relation_data.
    ENDIF.
    READ TABLE sit_pod_dev_relation TRANSPORTING NO FIELDS
      WITH KEY pod_type = /idxgc/if_constants_ide=>gc_pod_type_z70.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.
  ENDIF.

*Check the data processing mode and fill the data accordingly
  CASE siv_data_processing_mode.
*get data from source step
    WHEN /idxgc/if_constants_add=>gc_data_from_source.
      DELETE gs_process_step_data-name_address
             WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.

      LOOP AT gs_process_data_src-name_address INTO ls_name_address_src
        WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.
        APPEND ls_name_address_src TO gs_process_step_data-name_address.
      ENDLOOP.

*get data from additional source step
    WHEN /idxgc/if_constants_add=>gc_data_from_add_source.
      DELETE gs_process_step_data-name_address
             WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.

      LOOP AT gs_process_data_src_add-name_address INTO ls_name_address_src
        WHERE party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.
        APPEND ls_name_address_src TO gs_process_step_data-name_address.
      ENDLOOP.

*get data from default determination logic
    WHEN /idxgc/if_constants_add=>gc_default_processing.

*Get partner address data
      TRY.
          GET BADI lr_badi_datapro.
        CATCH cx_badi_not_implemented
              cx_badi_multiply_implemented INTO lr_root.
          MESSAGE e007(/idxgc/general) INTO lv_mtext
                                       WITH /idxgc/if_constants_ddic_add=>gc_badi_data_provision.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
            EXPORTING
              ir_previous = lr_root.
      ENDTRY.
      TRY.
          CALL BADI lr_badi_datapro->name_address_mr_card
            EXPORTING
              is_process_data_src     = gs_process_data_src
              is_process_data_src_add = gs_process_data_src_add
              is_process_data         = gs_process_step_data
              iv_itemid               = siv_itemid
            CHANGING
              ct_name_address         = gs_process_step_data-name_address.
        CATCH /idxgc/cx_process_error INTO lx_previous.
          CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_current_source_pos
            IMPORTING
              ev_class_name  = lv_class_name
              ev_method_name = lv_method_name.
          MESSAGE e021(/idxgc/ide_add) INTO lv_mtext WITH lv_class_name lv_method_name.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
      ENDTRY.

    WHEN OTHERS.
*do nothing
  ENDCASE.

  READ TABLE gs_process_step_data-name_address TRANSPORTING NO FIELDS
      WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.
  IF sy-subrc <> 0.

* If cannot find the MR card name and address from master data, get from source step

    READ TABLE gs_process_data_src-name_address INTO ls_name_address_src_ud
      WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_ud.
    READ TABLE gs_process_data_src-name_address INTO ls_name_address_src_dp
      WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_dp.

    IF ls_name_address_src_ud IS NOT INITIAL OR
      ls_name_address_src_dp IS NOT INITIAL.

* Get the name data from NAD+UD of the source step
      MOVE-CORRESPONDING ls_name_address_src_ud TO  ls_name_address_z05.

* Get the address data from NAD+DP of the source step
      MOVE-CORRESPONDING ls_name_address_src_dp TO  ls_name_address_z05.
      ls_name_address_z05-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.
      APPEND ls_name_address_z05 TO gs_process_step_data-name_address .

    ENDIF.
  ENDIF.

  READ TABLE gs_process_step_data-name_address TRANSPORTING NO FIELDS
       WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.

  IF sy-subrc <> 0 AND siv_mandatory_data = abap_true.
    MESSAGE e038(/idxgc/ide_add) WITH text-164 INTO lv_mtext.
    CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.

ENDMETHOD.


  METHOD name_address_reference_z05.
* Wolf.A.: übernommen aus dem Standard (/IDEXGE/CL_DP_OUT_UTILMD_007)

    DATA: ls_pod_dev_relation TYPE /idxgc/s_pod_dev_relation,
          ls_device_data      TYPE /idxgc/s_device_data,
          ls_name_address_ref TYPE /idxgc/s_naddrref_details,
          lt_service_provider TYPE /idxgc/t_service_provider,
          lv_count            TYPE i.

    READ TABLE  gs_process_step_data-name_address TRANSPORTING NO FIELDS
      WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF sit_pod_dev_relation IS INITIAL.
      CALL METHOD me->get_pod_dev_relation_data.
    ENDIF.

    LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.
      CLEAR ls_name_address_ref.
      ls_name_address_ref-item_id         = siv_itemid.
      ls_name_address_ref-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.
      ls_name_address_ref-ext_ui          = ls_pod_dev_relation-ext_ui.

*   Only in case more than 1 DDE service provider exist, reference to meter will be populated in data container
      REFRESH lt_service_provider.
      lt_service_provider = ls_pod_dev_relation-service_provider.
      DELETE lt_service_provider WHERE party_func_qual NE /idxgc/if_constants_ide=>gc_nad_qual_dde.
      DESCRIBE TABLE lt_service_provider LINES lv_count.
      IF lv_count > 1.
        LOOP AT ls_pod_dev_relation-device_data INTO ls_device_data
          WHERE metertype = /idxgc/if_constants_ide=>gc_cci_chardesc_code_e13  .
          CALL FUNCTION 'CONVERSION_EXIT_GERNR_OUTPUT'
            EXPORTING
              input  = ls_device_data-geraet
            IMPORTING
              output = ls_name_address_ref-meternumber.
          APPEND ls_name_address_ref TO gs_process_step_data-name_address_ref.
        ENDLOOP.
      ELSE.
        APPEND ls_name_address_ref TO gs_process_step_data-name_address_ref.
      ENDIF.
    ENDLOOP.

    IF gs_process_step_data-bmid CS 'CH'.
      CLEAR gs_process_step_data-name_address_ref.
      CLEAR ls_name_address_ref.
      ls_name_address_ref-item_id         = siv_itemid.
      ls_name_address_ref-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.

      me->get_device_register_data( ).
      LOOP AT sit_pod_dev_relation INTO ls_pod_dev_relation.
        LOOP AT ls_pod_dev_relation-device_data INTO ls_device_data
          WHERE metertype = /idxgc/if_constants_ide=>gc_cci_chardesc_code_e13  .
          CALL FUNCTION 'CONVERSION_EXIT_GERNR_OUTPUT'
            EXPORTING
              input  = ls_device_data-geraet
            IMPORTING
              output = ls_name_address_ref-meternumber.
          APPEND ls_name_address_ref TO gs_process_step_data-name_address_ref.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

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
*--------------------------------------------------------------------*
    DATA ls_ekun TYPE ekun.
*--------------------------------------------------------------------*

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
        ls_name_address-first_name = ls_name_address_src-first_name.
        ls_name_address-name_add1 = ls_name_address_src-name_add1.
        ls_name_address-name_add2 = ls_name_address_src-name_add2.

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

      lv_partnerformat = zcl_agc_datex_utility=>get_name_format_code( iv_partner = lv_bu_partner ).

      CASE lv_partnerformat.
        WHEN /idxgc/if_constants_ide=>gc_name_format_code_person.
          ls_name_address-fam_comp_name1 = ls_bus000-name_org2.
          ls_name_address-name_add1 = ls_bus000-name_org3.
          ls_name_address-first_name = ls_bus000-name_org1.
          ls_name_address-name_add2 = ls_bus000-name_org4.
          ls_name_address-name_format_code = lv_partnerformat.         "Wolf.A., Mantis 4953
        WHEN /idxgc/if_constants_ide=>gc_name_format_code_company.
          ls_name_address-fam_comp_name1   = ls_bus000-name_org1.
          ls_name_address-fam_comp_name2   = ls_bus000-name_org2.
          ls_name_address-name_add1   = ls_bus000-name_org3.
          ls_name_address-name_add2   = ls_bus000-name_org4.
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
*--------------------------------------------------------------------*
* WOLF.A, 21.03.2016, akadem. Titel kundenindividuell übernehmen
      CALL FUNCTION 'ISU_DB_EKUN_SINGLE'
        EXPORTING
          x_partner    = lv_bu_partner
          x_actual     = 'X'
          x_requested  = 'X'
        IMPORTING
          y_ekun       = ls_ekun
        exceptions
          not_found    = 1
          system_error = 2
          OTHERS       = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      IF ls_ekun-zemd_title_aca1 IS NOT INITIAL.
        ls_name_address-ad_title_ext = ls_ekun-zemd_title_aca1.
      ELSEIF ls_bus000-title = 'HD' OR
             ls_bus000-title = 'FD'.
        ls_name_address-ad_title_ext = 'DR'.
      ENDIF.

*      IF ls_bus000-title_aca1 IS NOT INITIAL.
*        CALL FUNCTION 'ADDR_TSAD2_READ'
*          EXPORTING
*            title_key     = ls_bus000-title_aca1
*          IMPORTING
*            title_text    = lv_title_aca1
*          EXCEPTIONS
*            key_not_found = 1
*            OTHERS        = 2.
*        IF sy-subrc <> 0.
*          CLEAR: lv_title_aca1.
*        ENDIF.
*        ls_name_address-ad_title_ext = ls_bus000-title_aca1.
*      ENDIF.
*--------------------------------------------------------------------*
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
      <fs_name_address>-first_name     = ls_name_address-first_name.
      <fs_name_address>-fam_comp_name1 = ls_name_address-fam_comp_name1.
      <fs_name_address>-fam_comp_name2 = ls_name_address-fam_comp_name2.
      <fs_name_address>-name_add1      = ls_name_address-name_add1.
      <fs_name_address>-name_add2      = ls_name_address-name_add2.
      <fs_name_address>-ad_title_ext   = ls_name_address-ad_title_ext.
    ELSE.
      ls_name_address-item_id         = siv_itemid.
      ls_name_address-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
      APPEND ls_name_address TO gs_process_step_data-name_address.
    ENDIF.


  ENDMETHOD.


  METHOD supply_owner_name.
***************************************************************************************************
* THIMEL.R, 20160229, Eigene Logik für SWS: Sonderkennzeichen zu Verträgen werden hier übermittelt
*   Logik übernommen aus Methode NOTE_TO_POINT_OF_DELIVERY.
***************************************************************************************************
    DATA: lr_previous       TYPE REF TO cx_root,
          lv_fam_comp_name1 TYPE        /idxgc/de_fam_comp_name1.

    FIELD-SYMBOLS: <fs_name_address> TYPE /idxgc/s_nameaddr_details.

    IF gs_process_step_data-bmid CS 'CH' AND ( "Nur für Stammdatenänderungen
       gs_process_step_data-assoc_servprov = 'L100014' OR "Nur im internen Verhältnis
       gs_process_step_data-assoc_servprov = 'L200001' OR
       gs_process_step_data-assoc_servprov = 'L300001' OR
       gs_process_step_data-assoc_servprov = 'L800001' OR
       gs_process_step_data-assoc_servprov = 'L900001' OR
       gs_process_step_data-assoc_servprov = 'N100001' OR
       gs_process_step_data-assoc_servprov = 'N200001' OR
       gs_process_step_data-assoc_servprov = 'N300001' OR
       gs_process_step_data-assoc_servprov = 'N800001' OR
       gs_process_step_data-assoc_servprov = 'N900001' ).
      TRY.
          IF me->lr_isu_pod IS NOT BOUND.
            me->lr_isu_pod = get_pod_ref( iv_int_ui = gs_process_step_data-int_ui iv_keydate = gs_process_step_data-proc_date ).
          ENDIF.

          lv_fam_comp_name1 = zcl_agc_masterdata=>get_contract_comment( is_ever = me->lr_isu_pod->get_ever( ) ).

        CATCH zcx_agc_masterdata INTO lr_previous.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
      ENDTRY.

      READ TABLE gs_process_step_data-name_address ASSIGNING <fs_name_address> WITH KEY item_id = siv_itemid party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_eo.
      IF <fs_name_address> IS NOT ASSIGNED.
        APPEND INITIAL LINE TO gs_process_step_data-name_address ASSIGNING <fs_name_address>.
        <fs_name_address>-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_eo.
        <fs_name_address>-item_id         = siv_itemid.
      ENDIF.
      <fs_name_address>-fam_comp_name1   = lv_fam_comp_name1.
      <fs_name_address>-first_name       = '#SWSG#'.
      <fs_name_address>-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_person.
      <fs_name_address>-streetname       = '#SWSG#'.
      <fs_name_address>-cityname         = '#SWSG#'.
      <fs_name_address>-postalcode       = '00000'.
      <fs_name_address>-countrycode      = 'DE'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
