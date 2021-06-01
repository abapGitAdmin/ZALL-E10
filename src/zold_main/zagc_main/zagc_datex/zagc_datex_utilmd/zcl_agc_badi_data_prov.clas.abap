class ZCL_AGC_BADI_DATA_PROV definition
  public
  create public .

public section.

  interfaces /IDXGC/IF_DATA_PROVISION .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_BADI_DATA_PROV IMPLEMENTATION.


  method /IDXGC/IF_DATA_PROVISION~ADDITIONAL_STATUS_INFORMATION.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~ADD_IDENTIFICATION_INFORMATION.
  endmethod.


  METHOD /idxgc/if_data_provision~already_exch_metering_proc.
    DATA: lr_previous        TYPE REF TO cx_root,
          lv_anlage          TYPE        anlage,
          lv_exch_meter_proc TYPE        /idxgc/de_exch_meter_proc.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    TRY .
        lv_anlage = zcl_agc_masterdata=>get_anlage( iv_int_ui = is_process_data-int_ui iv_keydate = is_process_data-proc_date ).
        lv_exch_meter_proc = zcl_agc_masterdata=>get_metmethod( iv_anlage = lv_anlage iv_keydate = is_process_data-proc_date ).
      CATCH zcx_agc_masterdata INTO lr_previous.
        /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lr_previous ).
    ENDTRY.

    IF lv_exch_meter_proc IS NOT INITIAL.
      READ TABLE ct_diverse ASSIGNING <fs_diverse> WITH KEY item_id = iv_itemid.
      IF sy-subrc = 0.
        <fs_diverse>-exch_meter_proc = lv_exch_meter_proc.
      ELSE.
        APPEND INITIAL LINE TO ct_diverse ASSIGNING <fs_diverse>.
        <fs_diverse>-item_id = iv_itemid.
        <fs_diverse>-exch_meter_proc = lv_exch_meter_proc.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD /idxgc/if_data_provision~already_exch_pod_type.
    DATA: ls_uichild TYPE zlw_uichild.

    FIELD-SYMBOLS: <fs_pod> TYPE /idxgc/s_pod_info_details.

    READ TABLE ct_pod ASSIGNING <fs_pod> WITH KEY item_id = iv_itemid.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM zlw_uichild AS ch
        JOIN zlw_uiparent AS pa ON ch~ext_ui_parent = pa~ext_ui_parent AND ch~datefrom = pa~datefrom AND ch~timefrom = pa~timefrom
        INTO CORRESPONDING FIELDS OF ls_uichild
        WHERE ( ch~ext_ui_child = <fs_pod>-ext_ui OR ch~ext_ui_parent = <fs_pod>-ext_ui )
          AND pa~datefrom < is_process_data-proc_date AND pa~dateto > is_process_data-proc_date.
      IF sy-subrc = 0.
        IF ls_uichild-ext_ui_parent = <fs_pod>-ext_ui.
          <fs_pod>-exch_pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
        ELSEIF ls_uichild-ext_ui_child = <fs_pod>-ext_ui.
          <fs_pod>-exch_pod_type = /idxgc/if_constants_ide=>gc_pod_type_z31.
        ENDIF.
      ELSE.
        <fs_pod>-exch_pod_type = /idxgc/if_constants_ide=>gc_pod_type_z71.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  method /IDXGC/IF_DATA_PROVISION~COMMERCIAL_STATUS.
  endmethod.


  METHOD /idxgc/if_data_provision~community_discount_percentage.

  ENDMETHOD.


  METHOD /idxgc/if_data_provision~consumption_partition.

  ENDMETHOD.


  METHOD /idxgc/if_data_provision~correspondence_address.
*----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2015
**
** Usage: Get address for correspondence with end consumer
**
**
** Status: <Completed>
*----------------------------------------------------------------------*
** Change History:
*
** Oct. 2015: Status: Created
*----------------------------------------------------------------------*
* 20160222, RT, Kopie vom Standard ohne Änderungen
* 20160229, AW, Anpassung wg. ES101
*----------------------------------------------------------------------*
    DATA: ls_nameaddr_details TYPE /idxgc/s_nameaddr_details,
          ls_name_address_src TYPE /idxgc/s_nameaddr_details.

    DATA: lr_utility  TYPE REF TO /idxgc/cl_utility_generic,
          lx_previous TYPE REF TO cx_root.
    DATA:
      ls_euitrans    TYPE          euitrans,
      lv_ext_ui      TYPE          ext_ui,
      lt_pod_partner TYPE TABLE OF bapiisupodpartner,
      ls_pod_partner TYPE          bapiisupodpartner,
      lv_bu_partner  TYPE          bu_partner,
      lv_mtext       TYPE          string.

*>>> WOLF.A, 29.02.2016. Adresse soll immer neu gelesen werden
*    IF is_process_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101.
**   Should get the data from source step
*      READ TABLE is_process_data_src-name_address INTO ls_name_address_src
*            WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.
*
*      IF sy-subrc = 0.
*        ls_nameaddr_details-streetname    = ls_name_address_src-streetname.
*        ls_nameaddr_details-poboxid       = ls_name_address_src-poboxid.
*        ls_nameaddr_details-houseid_compl = ls_name_address_src-houseid_compl.
*        ls_nameaddr_details-district      = ls_name_address_src-district.
*        ls_nameaddr_details-cityname      = ls_name_address_src-cityname.
*        ls_nameaddr_details-postalcode    = ls_name_address_src-postalcode.
*        ls_nameaddr_details-countrycode   = ls_name_address_src-countrycode.
*
*        ls_nameaddr_details-item_id         = iv_itemid.
*        ls_nameaddr_details-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.
*        APPEND ls_nameaddr_details TO ct_name_address.
*      ENDIF.
*      RETURN.
*    ENDIF.
*<<< WOLF.A, 29.02.2016. Adresse soll immer neu gelesen werden

    IF is_process_data-bu_partner IS INITIAL.
* Get the external pod name
      IF is_process_data-ext_ui IS INITIAL.
        CALL FUNCTION 'ISU_DB_EUITRANS_INT_SINGLE'
          EXPORTING
            x_int_ui     = is_process_data-int_ui
          IMPORTING
            y_euitrans   = ls_euitrans
          EXCEPTIONS
            not_found    = 1
            system_error = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_mtext.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.
        lv_ext_ui = ls_euitrans-ext_ui.
      ELSE.
        lv_ext_ui = is_process_data-ext_ui.
      ENDIF.

* Get BP by process date and POD
      CALL FUNCTION 'BAPI_ISUPOD_GETPARTNER'
        EXPORTING
          keydate         = is_process_data-proc_date
          pointofdelivery = lv_ext_ui
        TABLES
          partner         = lt_pod_partner.
      READ TABLE lt_pod_partner INTO ls_pod_partner INDEX 1.
      lv_bu_partner = ls_pod_partner-partner.

    ELSE.
      lv_bu_partner = is_process_data-bu_partner.
    ENDIF.

    IF lv_bu_partner IS NOT INITIAL.
      TRY .
          lr_utility = /idxgc/cl_utility_generic=>get_instance( ).

          CALL METHOD lr_utility->get_partner_name_addr_data
            EXPORTING
              iv_bu_partner     = lv_bu_partner
              iv_key_date       = is_process_data-proc_date
            IMPORTING
              es_name_addr_data = ls_nameaddr_details.
        CATCH /idxgc/cx_utility_error INTO lx_previous.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
      ENDTRY.
    ENDIF.
* For Z04, only the address data is needed
    CLEAR:
     ls_nameaddr_details-fam_comp_name1,
     ls_nameaddr_details-fam_comp_name2,
     ls_nameaddr_details-first_name,
     ls_nameaddr_details-name_add1,
     ls_nameaddr_details-name_add2,
     ls_nameaddr_details-ad_title_ext,
     ls_nameaddr_details-name_format_code.

    ls_nameaddr_details-item_id         = iv_itemid.
    ls_nameaddr_details-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z04.

    APPEND ls_nameaddr_details TO ct_name_address.

  ENDMETHOD.


  method /IDXGC/IF_DATA_PROVISION~CUSTOMER_VALUE.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~DEVICE_DATA.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~FRANCHISE_FEE_AMOUNT.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~FRANCHISE_FEE_ASSIGN.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~FRANCHISE_FEE_GROUP.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~GAS_QUALITY.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~GET_MSCONS_MD_MSG_REF.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~LOCAL_CONTROL_GROUP.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~MABIS_TIME_SERIES_CATEGORY.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~MARKET_AREA.
  endmethod.


  METHOD /idxgc/if_data_provision~metering_procedure_details.

    DATA: ls_profile_details TYPE /idxgc/s_profile_details.

    ls_profile_details-item_id    = iv_itemid.
    TRY.
        IF is_process_data-int_ui IS NOT INITIAL.
          ls_profile_details-meter_proc = zcl_agc_masterdata=>get_metmethod( iv_anlage = zcl_agc_masterdata=>get_anlage( iv_int_ui = is_process_data-int_ui ) ).
        ENDIF.
      CATCH zcx_agc_masterdata.
    ENDTRY.

    APPEND ls_profile_details TO et_profile_details.
  ENDMETHOD.


  method /IDXGC/IF_DATA_PROVISION~METER_READING_TYPE.
  endmethod.


  METHOD /idxgc/if_data_provision~name_address_mr_card.
*----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2015
**
** Usage: Get address for meter reading card
**
**
** Status: <Completed>
*----------------------------------------------------------------------*
** Change History:
*
** Oct. 2015: Status: Created
*----------------------------------------------------------------------*
* 20160222, THIMEL.R, Kopie aus dem Standard ohne Änderungen
* 20160229, AW/THIMEL.R, Anpassung wg. ES101 / SWS-spezifischen GPs
*----------------------------------------------------------------------*
    DATA: ls_nameaddr_details TYPE /idxgc/s_nameaddr_details,
          ls_name_address_src TYPE /idxgc/s_nameaddr_details.

    DATA: lr_utility  TYPE REF TO /idxgc/cl_utility_generic,
          lx_previous TYPE REF TO cx_root.
    DATA:
      ls_euitrans    TYPE          euitrans,
      lv_ext_ui      TYPE          ext_ui,
      lt_pod_partner TYPE TABLE OF bapiisupodpartner,
      ls_pod_partner TYPE          bapiisupodpartner,
      lv_bu_partner  TYPE          bu_partner,
      lv_mtext       TYPE          string.

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    DATA: lt_partner     TYPE bup_t_cent_uuidkey_api,
          lt_data_addr   TYPE bup_t_addr_data_api,
          ls_mrcontact   TYPE /idxgc/mrcontact,
          lv_houseid     TYPE /idxgc/de_houseid,
          lv_houseid_add TYPE /idxgc/de_houseid_add.

    FIELD-SYMBOLS: <fs_data_addr> TYPE bup_s_addr_data_api,
                   <fs_partner>   TYPE bup_s_cent_uuidkey_api.
*>>> WOLF.A, 29.02.2016. Adresse soll immer neu gelesen werden
*    IF is_process_data-bmid = /idxgc/if_constants_ide=>gc_bmid_es101.
**   Should get the data from source step
*      READ TABLE is_process_data_src-name_address INTO ls_name_address_src
*            WITH KEY party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.
*      IF sy-subrc = 0.
*        ls_name_address_src-item_id = iv_itemid.
*        APPEND ls_name_address_src TO ct_name_address.
*      ENDIF.
*      RETURN.
*    ENDIF.
*<<< WOLF.A, 29.02.2016. Adresse soll immer neu gelesen werden
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    IF is_process_data-bu_partner IS INITIAL.
* Get the external pod name
      IF is_process_data-ext_ui IS INITIAL.
        CALL FUNCTION 'ISU_DB_EUITRANS_INT_SINGLE'
          EXPORTING
            x_int_ui     = is_process_data-int_ui
          IMPORTING
            y_euitrans   = ls_euitrans
          EXCEPTIONS
            not_found    = 1
            system_error = 2
            OTHERS       = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_mtext.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
        ENDIF.
        lv_ext_ui = ls_euitrans-ext_ui.
      ELSE.
        lv_ext_ui = is_process_data-ext_ui.
      ENDIF.

* Get BP by process date and POD
      CALL FUNCTION 'BAPI_ISUPOD_GETPARTNER'
        EXPORTING
          keydate         = is_process_data-proc_date
          pointofdelivery = lv_ext_ui
        TABLES
          partner         = lt_pod_partner.
      READ TABLE lt_pod_partner INTO ls_pod_partner INDEX 1.
      lv_bu_partner = ls_pod_partner-partner.

    ELSE.
      lv_bu_partner = is_process_data-bu_partner.
    ENDIF.

    IF lv_bu_partner IS NOT INITIAL.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Lesen Tabelle /IDXGC/MRCONTACT und SWS spezifische Umsetzung (Adresse hat spezieller Adressart)
      TRY.
          ls_mrcontact = /adesso/cl_isu_mrcontact=>db_select_mrcontact( iv_int_ui = is_process_data-int_ui iv_keydate = is_process_data-proc_date ).
        CATCH /idxgc/cx_general INTO lx_previous.
          /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
      ENDTRY.
      IF ls_mrcontact IS NOT INITIAL.
        lv_bu_partner = ls_mrcontact-contact_bp.
      ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      TRY .
          lr_utility = /idxgc/cl_utility_generic=>get_instance( ).

          CALL METHOD lr_utility->get_partner_name_addr_data
            EXPORTING
              iv_bu_partner     = lv_bu_partner
              iv_key_date       = is_process_data-proc_date
            IMPORTING
              es_name_addr_data = ls_nameaddr_details.
        CATCH /idxgc/cx_utility_error INTO lx_previous.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
      ENDTRY.
    ENDIF.

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Namen mappen da nur Organisationen angelegt sind bei SWS
    ls_nameaddr_details-name_format_code = zcl_agc_datex_utility=>get_name_format_code( iv_partner = lv_bu_partner ).
    IF ls_nameaddr_details-name_format_code = /idxgc/if_constants_ide=>gc_name_format_code_person.
      ls_nameaddr_details-first_name     = ls_nameaddr_details-fam_comp_name1.
      ls_nameaddr_details-fam_comp_name1 = ls_nameaddr_details-fam_comp_name2.
      CLEAR: ls_nameaddr_details-fam_comp_name2.
    ENDIF.
    CLEAR: ls_nameaddr_details-ad_title, ls_nameaddr_details-ad_title_ext.

* Adresse zur Ablesekarte holen (wenn nicht vorhanden wird die Standard-Adresse genommen)
    APPEND INITIAL LINE TO lt_partner ASSIGNING <fs_partner>.
    <fs_partner>-partner = lv_bu_partner.
    cl_bup_address_api=>read_by_partner_and_usage( EXPORTING it_partner = lt_partner
      iv_adr_kind = zif_agc_datex_co=>gc_adr_kind_mread_card IMPORTING et_data_addr = lt_data_addr ).
    TRY.
        ASSIGN lt_data_addr[ 1 ] TO <fs_data_addr>.
      CATCH cx_sy_itab_line_not_found INTO lx_previous.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

* Adresse auf PDoc-Struktur mappen.
    ls_nameaddr_details-streetname    = <fs_data_addr>-location-street.
    ls_nameaddr_details-poboxid       = <fs_data_addr>-location-po_box.

    TRY.
        lv_houseid      = <fs_data_addr>-location-house_num1.
        lv_houseid_add  = <fs_data_addr>-location-house_num2.

        CALL METHOD lr_utility->concat_houseid_compl
          EXPORTING
            iv_housenum      = lv_houseid
            iv_house_sup     = lv_houseid_add
          IMPORTING
            ev_houseid_compl = ls_nameaddr_details-houseid_compl.
      CATCH /idxgc/cx_utility_error INTO lx_previous.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ir_previous = lx_previous ).
    ENDTRY.

    ls_nameaddr_details-district    = <fs_data_addr>-location-city2.
    ls_nameaddr_details-cityname    = <fs_data_addr>-location-city1.
*>>> Maxim Schmidt, 18.04.2016, Mantis: 5326: PROD: Anmeldung EoG per neg. Control abgelehnt
    IF <fs_data_addr>-location-post_code1 IS NOT INITIAL.
      ls_nameaddr_details-postalcode  = <fs_data_addr>-location-post_code1.
    ELSEIF <fs_data_addr>-location-post_code1 IS INITIAL AND <fs_data_addr>-location-post_code2 IS NOT INITIAL.
      ls_nameaddr_details-postalcode  = <fs_data_addr>-location-post_code2.
    ENDIF.
*<<< Maxim Schmidt, 18.04.2016, Mantis: 5326: PROD: Anmeldung EoG per neg. Control abgelehnt
    ls_nameaddr_details-countrycode = <fs_data_addr>-location-country.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    ls_nameaddr_details-item_id         = iv_itemid.
    ls_nameaddr_details-party_func_qual = /idxgc/if_constants_ide=>gc_nad_qual_z05.

    APPEND ls_nameaddr_details TO ct_name_address.

  ENDMETHOD.


  method /IDXGC/IF_DATA_PROVISION~PARTNER_ID_AT_SUPPLIER.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~PERCENTAGE_FEEDING_INST.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~POINT_OF_DELIVERY_TYPE.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~PRESSURE_LEVEL.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~QUANTITY_PERIOD_DETAILS.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~SETTLEMENT_TERRITORY.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~SETTLEMENT_UNIT.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~SET_OF_PROFILES.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~TAX_INFO.
  endmethod.


  METHOD /idxgc/if_data_provision~temperature_dependent_work.

  ENDMETHOD.


  method /IDXGC/IF_DATA_PROVISION~TEMPERATURE_MEASUREMENT_POINT.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~TYPE_FEEDING_INST.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~VOLTAGE_LEVEL.
  endmethod.


  method /IDXGC/IF_DATA_PROVISION~VOLTAGE_LEVEL_MEASUREMENT.
  endmethod.
ENDCLASS.
