class ZCL_Z_ODATA_IE_01_DPC_EXT definition
  public
  inheriting from ZCL_Z_ODATA_IE_01_DPC
  create public .

public section.
protected section.

  methods PRODUCTSET_CREATE_ENTITY
    redefinition .
  methods PRODUCTSET_GET_ENTITY
    redefinition .
  methods PRODUCTSET_GET_ENTITYSET
    redefinition .
  methods PRODUCTSET_UPDATE_ENTITY
    redefinition .
  methods PRODUCTSET_DELETE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_ODATA_IE_01_DPC_EXT IMPLEMENTATION.


  METHOD productset_create_entity.

    DATA: ls_headerdata TYPE bapi_epm_product_header,
          ls_product    LIKE er_entity.
    DATA: lt_return TYPE STANDARD TABLE OF bapiret2.

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = ls_product
    ).


    ls_headerdata-product_id  = ls_product-product_id.
    ls_headerdata-category    = ls_product-category.
    ls_headerdata-name  = ls_product-name.
    ls_headerdata-supplier_id = ls_product-supplier_id.
    ls_headerdata-measure_unit = 'EA'.
    ls_headerdata-currency_code = 'EUR'.
    ls_headerdata-tax_tarif_code = '1'.
    ls_headerdata-type_code = 'AD'.


    CALL FUNCTION 'BAPI_EPM_PRODUCT_CREATE'
      EXPORTING
        headerdata = ls_headerdata
*       PERSIST_TO_DB            = ABAP_TRUE
      TABLES
*       CONVERSION_FACTORS       =
        return     = lt_return.

  IF lt_return IS NOT INITIAL.
    mo_context->get_message_container( )->add_messages_from_bapi(
      it_bapi_messages         = lt_return
      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid            = /iwbep/cx_mgw_busi_exception=>business_error
        message_container = mo_context->get_message_container( ).
  ENDIF.

  er_entity = ls_product.
  ENDMETHOD.


  method PRODUCTSET_DELETE_ENTITY.
  DATA: ls_key_tab     TYPE /iwbep/s_mgw_name_value_pair,
        ls_product_id  TYPE bapi_epm_product_id,
        lt_return      TYPE STANDARD TABLE OF bapiret2.

  LOOP AT it_key_tab INTO ls_key_tab.
    IF ls_key_tab-name EQ 'ProductId'.
      ls_product_id-product_id = ls_key_tab-value.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_EPM_PRODUCT_DELETE'
    EXPORTING
      product_id    = ls_product_id
*     PERSIST_TO_DB = ABAP_TRUE
    TABLES
      return        = lt_return.

  IF lt_return IS NOT INITIAL.
    mo_context->get_message_container( )->add_messages_from_bapi(
      it_bapi_messages         = lt_return
      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid            = /iwbep/cx_mgw_busi_exception=>business_error
        message_container = mo_context->get_message_container( ).
  ENDIF.
  endmethod.


  METHOD productset_get_entity.



    DATA: ls_key_tab    TYPE /iwbep/s_mgw_name_value_pair,
          ls_product_id TYPE bapi_epm_product_id,
          ls_headerdata TYPE bapi_epm_product_header.

    LOOP AT it_key_tab INTO ls_key_tab.
      IF ls_key_tab-name EQ 'ProductId'.
        ls_product_id-product_id = ls_key_tab-value.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_DETAIL'
      EXPORTING
        product_id = ls_product_id
      IMPORTING
        headerdata = ls_headerdata
*   TABLES
*       CONVERSION_FACTORS       =
*       RETURN     =
      .

    er_entity-product_id = ls_headerdata-product_id.
    er_entity-category  = ls_headerdata-category.
    er_entity-name      = ls_headerdata-name.



  ENDMETHOD.


  METHOD productset_get_entityset.


    DATA: ls_headerdata TYPE bapi_epm_product_header,
          lt_headerdata TYPE STANDARD TABLE OF bapi_epm_product_header,
          ls_product    LIKE LINE OF et_entityset.


*** Paging_DEKLARATION
*ProductSET?$top=3&$skip=5
    DATA: lv_maxrows TYPE bapi_epm_max_rows,
          lv_start   TYPE int4,
          lv_end     TYPE int4.

***INLINECOUNT DEKLARATION
*ProductSet?$top=3&$skip=0&$inlinecount=allpages
 DATA: lr_mr_api TYPE REF TO if_mr_api.
       lr_mr_api = cl_mime_repository_api=>if_mr_api~get_api( ).


*** FilterBEGINN
*ProductSET?$filter=ProductId ge 'HT-1000' and ProductId le 'HT-1007'
    DATA: ls_selparamproductid     TYPE bapi_epm_product_id_range,
          lt_selparamproductid     TYPE STANDARD TABLE OF bapi_epm_product_id_range,
          ls_selparamcategories    TYPE bapi_epm_product_categ_range,
          lt_selparamcategories    TYPE STANDARD TABLE OF bapi_epm_product_categ_range,
          ls_filter_select_options TYPE /iwbep/s_mgw_select_option,
          ls_select_option         TYPE /iwbep/s_cod_select_option.

    LOOP AT it_filter_select_options INTO ls_filter_select_options.
      IF ls_filter_select_options-property EQ 'ProductId'.
        LOOP AT ls_filter_select_options-select_options INTO ls_select_option.
          ls_selparamproductid-sign   = ls_select_option-sign.
          ls_selparamproductid-option = ls_select_option-option.
          ls_selparamproductid-low    = ls_select_option-low.
          ls_selparamproductid-high   = ls_select_option-high.
          APPEND ls_selparamproductid TO lt_selparamproductid.
        ENDLOOP.
      ELSEIF ls_filter_select_options-property EQ 'Category'.
        LOOP AT ls_filter_select_options-select_options INTO ls_select_option.
          ls_selparamcategories-sign   = ls_select_option-sign.
          ls_selparamcategories-option = ls_select_option-option.
          ls_selparamcategories-low    = ls_select_option-low.
          ls_selparamcategories-high   = ls_select_option-high.
          APPEND ls_selparamcategories TO lt_selparamcategories.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
***ENDFILTETR

***PagingBEGINN
**OHNE INLINECOUNT
    lv_maxrows-bapimaxrow = 0.
    IF ( is_paging-top IS NOT INITIAL ) .
      lv_maxrows-bapimaxrow = is_paging-top + is_paging-skip.
    ENDIF.

**MIT INLINECOUNT
*    lv_maxrows-bapimaxrow = 0.
*    IF ( is_paging-top IS NOT INITIAL ) and ( io_tech_request_context->has_inlinecount( ) EQ abap_false ).
*      lv_maxrows-bapimaxrow = is_paging-top + is_paging-skip.
*    ENDIF.
***PagingBEGINN

    CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_LIST'
      EXPORTING
        max_rows           = lv_maxrows
      TABLES
        headerdata         = lt_headerdata
        selparamproductid  = lt_selparamproductid
*       SELPARAMSUPPLIERNAMES       =
        selparamcategories = lt_selparamcategories
*       RETURN             =
      .


***PagingERGÄNZUNG
**MIT INLINECOUNT
*    IF io_tech_request_context->has_inlinecount( ) EQ abap_true.
*      es_response_context-inlinecount = lines( lt_headerdata ).
*    ENDIF.

    lv_start = 1.
    IF is_paging-skip IS NOT INITIAL.
      lv_start = is_paging-skip + 1.
    ENDIF.

    IF is_paging-top IS NOT INITIAL.
      lv_end = is_paging-top + lv_start - 1.
    ELSE.
      lv_end = lines( lt_headerdata ).
    ENDIF.
***PagingERGÄNZUNG

    LOOP AT lt_headerdata INTO ls_headerdata FROM lv_start TO lv_end.
      ls_product-product_id = ls_headerdata-product_id.
      ls_product-category  = ls_headerdata-category.
      ls_product-name      = ls_headerdata-name.
      APPEND ls_product TO et_entityset.
    ENDLOOP.



  ENDMETHOD.


  method PRODUCTSET_UPDATE_ENTITY.


  DATA: ls_key_tab     TYPE /iwbep/s_mgw_name_value_pair,
        ls_product_id  TYPE bapi_epm_product_id,
        ls_headerdata  TYPE bapi_epm_product_header,
        ls_headerdatax TYPE bapi_epm_product_headerx,
        ls_product     LIKE er_entity,
        lt_return      TYPE STANDARD TABLE OF bapiret2.

  io_data_provider->read_entry_data( IMPORTING es_data = ls_product ).

  LOOP AT it_key_tab INTO ls_key_tab.
    IF ls_key_tab-name EQ 'ProductId'.
      ls_product_id-product_id = ls_key_tab-value.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'BAPI_EPM_PRODUCT_GET_DETAIL'
    EXPORTING
      product_id               = ls_product_id
    IMPORTING
      headerdata               = ls_headerdata
*   TABLES
*     CONVERSION_FACTORS       =
*     RETURN                   =
            .

  ls_headerdata-category     = ls_product-category.
  ls_headerdata-name         = ls_product-name.
  ls_headerdata-supplier_id  = ls_product-supplier_id.
  ls_headerdata-price        = ls_product-price.

  ls_headerdatax-product_id  = ls_headerdata-product_id.
  ls_headerdatax-category    = 'X'.
  ls_headerdatax-name        = 'X'.
  ls_headerdatax-supplier_id = 'X'.

  CALL FUNCTION 'BAPI_EPM_PRODUCT_CHANGE'
    EXPORTING
      product_id          = ls_product_id
      headerdata          = ls_headerdata
      headerdatax         = ls_headerdatax
*     PERSIST_TO_DB       = ABAP_TRUE
    TABLES
*     CONVERSION_FACTORS  =
*     CONVERSION_FACTORSX =
      return              = lt_return.

  IF lt_return IS NOT INITIAL.
    mo_context->get_message_container( )->add_messages_from_bapi(
      it_bapi_messages         = lt_return
      iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first ).

    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid            = /iwbep/cx_mgw_busi_exception=>business_error
        message_container = mo_context->get_message_container( ).
  ENDIF.

  er_entity = ls_product.
  endmethod.
ENDCLASS.
