class ZCL_Z_ODATA_UI5_DPC_EXT definition
  public
  inheriting from ZCL_Z_ODATA_UI5_DPC
  create public .

public section.
protected section.

  methods EPMPRODUCTSET_GET_ENTITYSET
    redefinition .
  methods EPMPRODUCTSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_ODATA_UI5_DPC_EXT IMPLEMENTATION.


  METHOD epmproductset_get_entity.

    DATA lv_product_id TYPE bapi_epm_product_id.
    DATA ls_product TYPE bapi_epm_product_header.
    DATA lt_return TYPE TABLE OF bapiret2.
    FIELD-SYMBOLS <lf_key> TYPE /iwbep/s_mgw_name_value_pair.

    READ TABLE it_key_tab INDEX 1 ASSIGNING <lf_key>.

    IF sy-subrc = 0 AND <lf_key> IS ASSIGNED.
      lv_product_id = <lf_key>-value.
      CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_DETAIL'
        EXPORTING
          product_id = lv_product_id
        IMPORTING
          headerdata = ls_product
        TABLES
          return     = lt_return.
      MOVE-CORRESPONDING ls_product TO er_entity.
    ENDIF.

  ENDMETHOD.


  METHOD epmproductset_get_entityset.

    DATA lt_products TYPE TABLE OF bapi_epm_product_header.
    DATA lt_return TYPE TABLE OF bapiret2.
    DATA lv_min TYPE i. DATA lv_max TYPE i.
    DATA lt_techorder TYPE /iwbep/t_mgw_tech_order.
    DATA lt_sortorder TYPE abap_sortorder_tab.
    FIELD-SYMBOLS <lf_order> TYPE /iwbep/s_mgw_tech_order.
    FIELD-SYMBOLS <lf_sortorder> TYPE abap_sortorder.
    FIELD-SYMBOLS <lf_products> TYPE bapi_epm_product_header.
    FIELD-SYMBOLS <lf_entityset> TYPE zcl_z_odata_ui5_mpc=>ts_epmproduct.

* Get technical request information
    IF io_tech_request_context IS BOUND.
      lt_techorder = io_tech_request_context->get_orderby( ).
    ENDIF.

* Get List of Products (to avoid a read with every call a cache could be implemented)
    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_LIST'
      TABLES
        headerdata = lt_products
        return     = lt_return.

* Sorting
    LOOP AT lt_techorder ASSIGNING <lf_order>.
      APPEND INITIAL LINE TO lt_sortorder ASSIGNING <lf_sortorder>.
      <lf_sortorder>-name = <lf_order>-property.

      IF <lf_order>-order = `desc`.
        <lf_sortorder>-descending = abap_true.
      ENDIF.
      IF <lf_order>-property = `PRODUCT_ID`
      OR <lf_order>-property = `DESCRIPTION`
      OR <lf_order>-property = `NAME`
      OR <lf_order>-property = `CURRENCY_CODE`
      OR <lf_order>-property = `SUPPLIER_NAME`.
        <lf_sortorder>-astext = abap_true.
      ENDIF.
    ENDLOOP.
    SORT lt_products BY (lt_sortorder).


* Paging
    IF is_paging-skip IS NOT INITIAL.
      lv_min = is_paging-skip + 1.
    ELSE.
      lv_min = 1.
    ENDIF.
    IF is_paging-top IS NOT INITIAL.
      lv_max = is_paging-skip + is_paging-top.
    ELSE.
      lv_max = lines( lt_products ).
    ENDIF.

    LOOP AT lt_products FROM lv_min TO lv_max ASSIGNING <lf_products>.
      APPEND INITIAL LINE TO et_entityset ASSIGNING <lf_entityset>.
      MOVE-CORRESPONDING <lf_products> TO <lf_entityset>.
    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
