class ZCL_ZSHW_GELSENWASSER_DPC_EXT definition
  public
  inheriting from ZCL_ZSHW_GELSENWASSER_DPC
  create public .

public section.
protected section.

  methods KOPFDATENSET_GET_ENTITYSET
    redefinition .
  methods KOPFDATENSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZSHW_GELSENWASSER_DPC_EXT IMPLEMENTATION.


  METHOD kopfdatenset_get_entity.
**TRY.
*CALL METHOD SUPER->KOPFDATENSET_GET_ENTITY
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

    DATA: lv_param TYPE zzshw_zan_id,
          ls_kopf  TYPE zzshw_s_paorhea_odata.


    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.


      SELECT SINGLE *
        FROM zzshw_paorhea

            WHERE   zantest = @lv_param
        INTO @ls_kopf.

            MOVE-CORRESPONDING ls_kopf to er_entity.
    ENDIF.


  ENDMETHOD.


  METHOD kopfdatenset_get_entityset.
**TRY.
*CALL METHOD SUPER->KOPFDATENSET_GET_ENTITYSET
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

    DATA lt_tabelle TYPE TABLE OF zzshw_s_paorhea_odata.
    SELECT * FROM zzshw_paorhea INTO TABLE lt_tabelle.
    MOVE-CORRESPONDING lt_tabelle TO et_entityset.


  ENDMETHOD.
ENDCLASS.
