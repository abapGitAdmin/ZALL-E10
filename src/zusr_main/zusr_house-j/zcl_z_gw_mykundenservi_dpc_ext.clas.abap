class ZCL_Z_GW_MYKUNDENSERVI_DPC_EXT definition
  public
  inheriting from ZCL_Z_GW_MYKUNDENSERVI_DPC
  create public .

public section.
protected section.

  methods VERBRAUCHSKURVE__GET_ENTITY
    redefinition .
  methods VERBRAUCHSKURVE__GET_ENTITYSET
    redefinition .
  methods VERBRAUCH_MONAT__GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_GW_MYKUNDENSERVI_DPC_EXT IMPLEMENTATION.


  method VERBRAUCHSKURVE__GET_ENTITY.
**TRY.
*CALL METHOD SUPER->VERBRAUCHSKURVE__GET_ENTITY
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

    DATA: lt_zalexa_stvb_m TYPE zalexa_strmvbr_m_tt.

    FIELD-SYMBOLS: <lfs_zalexa_stvb_m> TYPE zalexa_stvb_m.

    SELECT * FROM zalexa_stvb_m INTO TABLE lt_zalexa_stvb_m.

  endmethod.


  METHOD verbrauchskurve__get_entityset.
**TRY.
*CALL METHOD SUPER->VERBRAUCHSKURVE__GET_ENTITYSET
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

    DATA: lt_zalexa_strmvbr TYPE zalexa_strmvbr_tt,
          ls_et_entityset   TYPE LINE OF zcl_z_gw_mykundenservi_mpc=>tt_verbrauchskurve,
          lv_tz             TYPE ttzz-tzone VALUE 'UTC'.


    FIELD-SYMBOLS: <lfs_zalexa_strmvbr> TYPE zalexa_strmvbr.


    SELECT * FROM zalexa_strmvbr INTO TABLE lt_zalexa_strmvbr.

    LOOP AT lt_zalexa_strmvbr ASSIGNING <lfs_zalexa_strmvbr>.
      CLEAR: ls_et_entityset.

      ls_et_entityset-partner = <lfs_zalexa_strmvbr>-partner.

      CONVERT TIME <lfs_zalexa_strmvbr>-viertelstundewert
              DATE <lfs_zalexa_strmvbr>-datum
              INTO TIME STAMP ls_et_entityset-datum TIME ZONE lv_tz.


      ls_et_entityset-kilowattstundenwert = <lfs_zalexa_strmvbr>-kilowattstundenwert.

      APPEND ls_et_entityset TO et_entityset.

    ENDLOOP.


  ENDMETHOD.


  method VERBRAUCH_MONAT__GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->VERBRAUCH_MONAT__GET_ENTITYSET
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

        DATA: lt_zalexa_stvb_m TYPE zalexa_strmvbr_m_tt.

    FIELD-SYMBOLS: <lfs_zalexa_stvb_m> TYPE zalexa_stvb_m.

    SELECT * FROM zalexa_stvb_m INTO TABLE lt_zalexa_stvb_m.

  endmethod.
ENDCLASS.
