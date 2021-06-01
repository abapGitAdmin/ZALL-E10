class ZCL_ZCB_GELSENWASSER_DPC_EXT definition
  public
  inheriting from ZCL_ZCB_GELSENWASSER_DPC
  create public .

public section.
protected section.

  methods KOPFDATENSET_GET_ENTITYSET
    redefinition .
  methods KOPFDATENSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZCB_GELSENWASSER_DPC_EXT IMPLEMENTATION.


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

    DATA: lv_param TYPE zkerk_zan_id,
          ls_kopf  TYPE zkerk_s_zakopfdat_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

      SELECT SINGLE *
        FROM zkerk_zakopfdat
        WHERE nummer_zahlungsanweisung = @lv_param
        INTO @ls_kopf.

      MOVE-CORRESPONDING ls_kopf TO er_entity.

    ENDIF.
  ENDMETHOD.


  METHOD kopfdatenset_get_entityset.
*    *TRY.
*    CALL METHOD SUPER->KOPFDATENSET_GET_ENTITYSET
*      EXPORTING
*        IV_ENTITY_NAME           =
*        IV_ENTITY_SET_NAME       =
*        IV_SOURCE_NAME           =
*        IT_FILTER_SELECT_OPTIONS =
*        IS_PAGING                =
*        IT_KEY_TAB               =
*        IT_NAVIGATION_PATH       =
*        IT_ORDER                 =
*        IV_FILTER_STRING         =
*        IV_SEARCH_STRING         =
*    *    io_tech_request_context  =
*    *  IMPORTING
*    *    et_entityset             =
*    *    es_response_context      =
*        .
*    * CATCH /iwbep/cx_mgw_busi_exception .
*    * CATCH /iwbep/cx_mgw_tech_exception .
*    *ENDTRY.

    DATA lt_kopfdatenset TYPE TABLE OF zkerk_zakopfdat.

    SELECT * FROM zkerk_zakopfdat INTO TABLE lt_kopfdatenset.

    MOVE-CORRESPONDING lt_kopfdatenset TO et_entityset.

  ENDMETHOD.
ENDCLASS.
