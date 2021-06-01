class ZCL_ZUPW_ZAP_GELSENWAS_DPC_EXT definition
  public
  inheriting from ZCL_ZUPW_ZAP_GELSENWAS_DPC
  create public .

public section.
protected section.

  methods ZUPW_ZAP_HEADDAT_CREATE_ENTITY
    redefinition .
  methods ZUPW_ZAP_HEADDAT_DELETE_ENTITY
    redefinition .
  methods ZUPW_ZAP_HEADDAT_GET_ENTITY
    redefinition .
  methods ZUPW_ZAP_HEADDAT_GET_ENTITYSET
    redefinition .
  methods ZUPW_ZAP_HEADDAT_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZUPW_ZAP_GELSENWAS_DPC_EXT IMPLEMENTATION.


  METHOD zupw_zap_headdat_create_entity.
**TRY.
*CALL METHOD SUPER->ZUPW_ZAP_HEADDAT_CREATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.

"TODO Nummernkreis fehlt

    DATA ls_newentity TYPE zupw_zap_s_headdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_newentity ).

    INSERT INTO zupw_zap_headdat VALUES ls_newentity.

  ENDMETHOD.


  METHOD zupw_zap_headdat_delete_entity.
**TRY.
*CALL METHOD SUPER->ZUPW_ZAP_HEADDAT_DELETE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.

    DATA : lv_param TYPE zalo_boco_id,
           ls_kopf  TYPE zalo_s_book_code_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.

      DELETE FROM zalo_book_code WHERE boco_id = @lv_param.

    ELSE.
      MESSAGE e002(zalo_nc_gwasser).
    ENDIF.

  ENDMETHOD.


  METHOD zupw_zap_headdat_get_entity.
**TRY.
*CALL METHOD SUPER->ZUPW_ZAP_HEADDAT_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.

    DATA lv_param TYPE ZPW_ZAN_ID.
    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.
      SELECT SINGLE * FROM zupw_zap_headdat WHERE zan_id = @lv_param INTO @er_entity.
    ENDIF.

  ENDMETHOD.


  METHOD zupw_zap_headdat_get_entityset.
**TRY.
*CALL METHOD SUPER->ZUPW_ZAP_HEADDAT_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.

    SELECT * FROM zupw_zap_headdat INTO CORRESPONDING FIELDS OF TABLE @et_entityset.

  ENDMETHOD.


  METHOD zupw_zap_headdat_update_entity.
**TRY.
*CALL METHOD SUPER->ZUPW_ZAP_HEADDAT_UPDATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.

    DATA: ls_zan_import TYPE zupw_zap_s_headdat_odata,
          ls_zan_update TYPE zupw_zap_s_headdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_zan_import ).
    SELECT SINGLE * FROM zupw_zap_headdat INTO ls_zan_update WHERE zan_id = ls_zan_import-zan_id.
    IF ls_zan_update IS INITIAL.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
      MESSAGE 'Fehler! Den Datensatz gibt es überhaupt nicht!' TYPE 'E'.
    ENDIF.
    UPDATE zupw_zap_headdat FROM ls_zan_import.

    IF sy-subrc =  4.
      MESSAGE ' Fehler beim Updaten der Datenbank' TYPE 'E'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
