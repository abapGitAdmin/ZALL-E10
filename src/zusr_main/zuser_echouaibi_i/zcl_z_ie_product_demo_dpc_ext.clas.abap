class ZCL_Z_IE_PRODUCT_DEMO_DPC_EXT definition
  public
  inheriting from ZCL_Z_IE_PRODUCT_DEMO_DPC
  create public .

public section.
protected section.

  methods PRODUCTSET_GET_ENTITY
    redefinition .
  methods PRODUCTSET_GET_ENTITYSET
    redefinition .
  methods PRODUCTSET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_IE_PRODUCT_DEMO_DPC_EXT IMPLEMENTATION.


  METHOD productset_get_entity.

    DATA: ls_itkeytab TYPE /IWBEP/S_MGW_NAME_VALUE_PAIR.
    DATA: ls_product_id TYPE bapi_epm_product_id.
    DATA: ls_headerdata TYPE bapi_epm_product_header.


    READ TABLE it_key_tab into ls_itkeytab with key name = 'ProductID'.

    ls_product_id = ls_itkeytab-value.

    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_DETAIL'
      EXPORTING
        product_id = ls_product_id
      IMPORTING
        headerdata = ls_headerdata
* TABLES
*       CONVERSION_FACTORS       =
*       RETURN     =
      .

  er_entity-productid = ls_headerdata-product_id.
  er_entity-name = ls_headerdata-name.
  er_entity-price = ls_headerdata-price.
  er_entity-currency = ls_headerdata-currency_code.


  endmethod.


  METHOD productset_get_entityset.


    DATA: ls_entity TYPE zcl_z_ie_product_demo_mpc=>ts_product.
    DATA: lv_maxrow TYPE  bapi_epm_max_rows.

    DATA: lt_productset TYPE TABLE OF bapi_epm_product_header.

    DATA: lt_order_tab TYPE abap_sortorder_tab.
    DATA: ls_order_tab TYPE abap_sortorder.

    DATA: lt_bapi_opt TYPE TABLE OF bapi_epm_product_id_range.
    DATA: ls_bapi_opt TYPE bapi_epm_product_id_range.
    DATA: ls_filter_select_option TYPE /iwbep/s_mgw_select_option.
    DATA: ls_select_option TYPE /iwbep/s_cod_select_option.

    DATA: ls_paging TYPE /iwbep/s_mgw_paging.

** INS{ Paging--------------------------------------------------------
**    IF is_paging-top <> 0.
**      lv_maxrow-bapimaxrow = is_paging-top.
**    ELSE.
**      lv_maxrow-bapimaxrow = 50.
**    ENDIF.
**
**    IF is_paging-skip <> 0.
**
**      lv_maxrow-bapimaxrow = lv_maxrow-bapimaxrow + is_paging-skip.
**
**    ENDIF.
** END} Paging--------------------------------------------------------

** INS Filter_selectoption--------------------------------------------------------
*/sap/opu/odata/sap/Z_IE_PRODUCT_DEMO_SRV/ProductSET?$filter=ProductID ge 'HT-1000' and ProductID le 'HT-1020'
    LOOP AT it_filter_select_options INTO ls_filter_select_option.
      IF ls_filter_select_option-property = 'ProductID'.

        LOOP AT ls_filter_select_option-select_options INTO ls_select_option.

          ls_bapi_opt-sign = ls_select_option-sign.
          ls_bapi_opt-option = ls_select_option-option.
          ls_bapi_opt-high = ls_select_option-high.
          ls_bapi_opt-low = ls_select_option-low.

          APPEND ls_bapi_opt TO lt_bapi_opt.

        ENDLOOP.
        ENDIF.

      ENDLOOP.
** END Filter_selectoption--------------------------------------------------------

* BAPI AUFRUF
      CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_LIST'
*        EXPORTING
*          max_rows          = lv_maxrow
        TABLES
          headerdata        = lt_productset
          selparamproductid = lt_bapi_opt
*         SELPARAMSUPPLIERNAMES       =
*         SELPARAMCATEGORIES          =
*         RETURN            =
        .

      LOOP AT lt_productset INTO DATA(ls_productset).

        ls_entity-productid = ls_productset-product_id.
        ls_entity-name = ls_productset-name.
        ls_entity-price = ls_productset-price.
        ls_entity-currency = ls_productset-currency_code.

        APPEND ls_entity TO et_entityset.

      ENDLOOP.

** INS} für Sortieren--------------------------------------------------------
      LOOP AT it_order INTO DATA(is_order).

        TRANSLATE is_order-property TO UPPER CASE.

        ls_order_tab-name = is_order-property.

        IF is_order-order = 'desc'.

          ls_order_tab-descending = 'X'.

        ENDIF.

        ls_order_tab-astext = 'X'.


        APPEND ls_order_tab TO lt_order_tab.
      ENDLOOP.

      SORT et_entityset BY (lt_order_tab).
** END} für Sortieren--------------------------------------------------------

** INS} Paging--------------------------------------------------------
***      IF is_paging-skip <> 0.
***
***        DELETE et_entityset FROM 1 TO is_paging-skip.
***
***      ENDIF.
** END} Paging--------------------------------------------------------
    ENDMETHOD.


  method PRODUCTSET_UPDATE_ENTITY.


    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).


    LOOP AT it_key_tab INTO DATA(ls_keytab) WHERE name = 'ProductID'.

    select SINGLE * from snwd_pd INTO @DATA(ls_product) WHERE PRODUCT_ID = @ls_keytab-value.

      ls_product-price = er_entity-price.

      UPDATE snwd_pd from ls_product.

      COMMIT WORK.


    ENDLOOP.




  endmethod.
ENDCLASS.
