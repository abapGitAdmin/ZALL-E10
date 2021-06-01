class ZCL_ZBOE_GELSENWASSER__DPC_EXT definition
  public
  inheriting from ZCL_ZBOE_GELSENWASSER__DPC
  create public .

public section.

  class-data GV_MESSAGE type BAPI_MSG .
protected section.

  methods ZBOE_BUCODESET_CREATE_ENTITY
    redefinition .
  methods ZBOE_BUCODESET_DELETE_ENTITY
    redefinition .
  methods ZBOE_BUCODESET_GET_ENTITY
    redefinition .
  methods ZBOE_BUCODESET_GET_ENTITYSET
    redefinition .
  methods ZBOE_BUCODESET_UPDATE_ENTITY
    redefinition .
  methods ZBOE_KOPFDATSET_CREATE_ENTITY
    redefinition .
  methods ZBOE_KOPFDATSET_DELETE_ENTITY
    redefinition .
  methods ZBOE_KOPFDATSET_GET_ENTITY
    redefinition .
  methods ZBOE_KOPFDATSET_GET_ENTITYSET
    redefinition .
  methods ZBOE_KOPFDATSET_UPDATE_ENTITY
    redefinition .
  methods ZBOE_NOTESET_CREATE_ENTITY
    redefinition .
  methods ZBOE_NOTESET_DELETE_ENTITY
    redefinition .
  methods ZBOE_NOTESET_GET_ENTITY
    redefinition .
  methods ZBOE_NOTESET_GET_ENTITYSET
    redefinition .
  methods ZBOE_NOTESET_UPDATE_ENTITY
    redefinition .
  methods ZBOE_POSDATSET_CREATE_ENTITY
    redefinition .
  methods ZBOE_POSDATSET_DELETE_ENTITY
    redefinition .
  methods ZBOE_POSDATSET_GET_ENTITY
    redefinition .
  methods ZBOE_POSDATSET_GET_ENTITYSET
    redefinition .
  methods ZBOE_POSDATSET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZBOE_GELSENWASSER__DPC_EXT IMPLEMENTATION.


  method ZBOE_BUCODESET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZBOE_BUCODESET_CREATE_ENTITY
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

    DATA ls_bucode TYPE zboe_s_zbucode_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_bucode ).

    IF ls_bucode IS NOT INITIAL.
      MESSAGE 'Fehler beim Auslesen der Daten aus ZBOE_KOPFDAT!' TYPE 'E'.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
      INSERT zboe_bucode FROM ls_bucode.
    ELSE.
       MESSAGE e000(zboe_nc_gelsenwasser) INTO gv_message.
    ENDIF.
  endmethod.


  METHOD zboe_bucodeset_delete_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_BUCODESET_DELETE_ENTITY
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

    DATA: lv_param TYPE zboe_zan_id,
          ls_bucode  TYPE zboe_s_zbucode_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.
      DELETE FROM zboe_bucode WHERE buco_id = @lv_param.
    ENDIF.
  ENDMETHOD.


  METHOD zboe_bucodeset_get_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_BUCODESET_GET_ENTITY
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

    DATA: lv_param TYPE zboe_zan_id,
          ls_bucode  TYPE zboe_s_zbucode_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

      SELECT SINGLE * FROM zboe_bucode WHERE buco_id = @lv_param INTO @er_entity."ls_kopf.
      "MOVE-CORRESPONDING ls_kopf TO er_entity.
    ENDIF.

  ENDMETHOD.


  method ZBOE_BUCODESET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZBOE_BUCODESET_GET_ENTITYSET
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

    SELECT * FROM zboe_bucode INTO CORRESPONDING FIELDS OF TABLE et_entityset.

  endmethod.


  METHOD zboe_bucodeset_update_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_BUCODESET_UPDATE_ENTITY
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
    DATA: ls_bucode        TYPE zboe_s_zbucode_odata,
          ls_bucode_update TYPE zboe_s_zbucode_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_bucode ).

    SELECT SINGLE * FROM zboe_bucode INTO ls_bucode WHERE buco_id = ls_bucode-buco_id.
    IF ls_bucode_update IS INITIAL.
      MESSAGE 'Fehler! Den Datensatz gibt es überhaupt nicht' TYPE 'E'.
    ENDIF.
    UPDATE zboe_bucode FROM ls_bucode.

    IF sy-subrc <> 0.
      MESSAGE 'Fehler beim Update der Datenbank' TYPE 'E'.
    ENDIF.
  ENDMETHOD.


  method ZBOE_KOPFDATSET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZBOE_KOPFDATSET_CREATE_ENTITY
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

    DATA ls_kopfdat TYPE zboe_s_kopfdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_kopfdat ).

    IF ls_kopfdat IS NOT INITIAL.
      MESSAGE 'Fehler beim Auslesen der Daten aus ZBOE_KOPFDAT!' TYPE 'E'.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
      INSERT zboe_kopfdat FROM ls_kopfdat.
    ELSE.
       MESSAGE e000(zboe_nc_gelsenwasser) INTO gv_message.
    ENDIF.

  endmethod.


  METHOD zboe_kopfdatset_delete_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_KOPFDATSET_DELETE_ENTITY
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

    DATA: lv_param TYPE zboe_zan_id,
          ls_kopf  TYPE zboe_s_kopfdat_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.
      DELETE FROM zboe_kopfdat WHERE zan_id = @lv_param.
    ENDIF.
ENDMETHOD.


  METHOD zboe_kopfdatset_get_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_KOPFDATSET_GET_ENTITY
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

    DATA: lv_param TYPE zboe_zan_id,
          ls_kopf  TYPE zboe_s_kopfdat_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
    lv_param = <fs_key_tab>-value.

    SELECT SINGLE * FROM zboe_kopfdat WHERE zan_id = @lv_param INTO @er_entity."ls_kopf.
      "MOVE-CORRESPONDING ls_kopf TO er_entity.

    ENDIF.

  ENDMETHOD.


  METHOD zboe_kopfdatset_get_entityset.
**TRY.
*CALL METHOD SUPER->ZBOE_KOPFDATSET_GET_ENTITYSET
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

  SELECT * FROM zboe_kopfdat INTO CORRESPONDING FIELDS OF TABLE et_entityset.

  ENDMETHOD.


  METHOD zboe_kopfdatset_update_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_KOPFDATSET_UPDATE_ENTITY
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

    DATA: ls_kopfdat TYPE zboe_s_kopfdat_odata,
         ls_kopfdat_update TYPE zboe_s_kopfdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_kopfdat ).

    SELECT SINGLE * FROM zboe_kopfdat into ls_kopfdat where zan_id = ls_kopfdat_update-zan_id.
    IF ls_kopfdat_update IS INITIAL.
      MESSAGE 'Fehler! Den Datensatz gibt es überhaupt nicht' TYPE 'E'.
    ENDIF.
    UPDATE zboe_kopfdat from ls_kopfdat.

    IF sy-subrc <> 0.
       MESSAGE 'Fehler beim Update der Datenbank' TYPE 'E'.
    ENDIF.
  ENDMETHOD.


  METHOD zboe_noteset_create_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_NOTESET_CREATE_ENTITY
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

    DATA ls_note TYPE zboe_s_note_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_note ).

    IF ls_note IS NOT INITIAL.
      MESSAGE 'Fehler beim Auslesen der Daten aus ZBOE_KOPFDAT!' TYPE 'E'.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
      INSERT zboe_note FROM ls_note.
    ELSE.
      MESSAGE e000(zboe_nc_gelsenwasser) INTO gv_message.
    ENDIF.



  ENDMETHOD.


  METHOD zboe_noteset_delete_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_NOTESET_DELETE_ENTITY
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

    DATA: lv_param TYPE zboe_note_id,
          ls_note  TYPE zboe_s_note_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.
      DELETE FROM zboe_note WHERE note_id = @lv_param.
    ENDIF.
  ENDMETHOD.


  METHOD zboe_noteset_get_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_NOTESET_GET_ENTITY
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

    DATA: lv_param TYPE zboe_note_id,
          ls_note  TYPE zboe_s_note_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.
      SELECT SINGLE * FROM zboe_note WHERE note_id = @lv_param INTO @er_entity."ls_kopf.
      "MOVE-CORRESPONDING ls_kopf TO er_entity.
    ENDIF.

  ENDMETHOD.


  method ZBOE_NOTESET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZBOE_NOTESET_GET_ENTITYSET
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

     SELECT * FROM zboe_note INTO CORRESPONDING FIELDS OF TABLE et_entityset.

  endmethod.


  METHOD zboe_noteset_update_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_NOTESET_UPDATE_ENTITY
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

    DATA: ls_note        TYPE zboe_s_note_odata,
          ls_note_update TYPE zboe_s_note_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_note ).

    SELECT SINGLE * FROM zboe_note INTO ls_note WHERE note_id = ls_note_update-note_id.
    IF ls_note_update IS INITIAL.
      MESSAGE 'Fehler! Den Datensatz gibt es überhaupt nicht' TYPE 'E'.
    ENDIF.
    UPDATE zboe_note FROM ls_note.

    IF sy-subrc <> 0.
      MESSAGE 'Fehler beim Update der Datenbank' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


  METHOD zboe_posdatset_create_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_POSDATSET_CREATE_ENTITY
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

    DATA ls_posdat TYPE zboe_s_posdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_posdat ).

    IF ls_posdat IS NOT INITIAL.
      MESSAGE 'Fehler beim Auslesen der Daten aus ZBOE_KOPFDAT!' TYPE 'E'.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
      INSERT zboe_posdat FROM ls_posdat.
    ELSE.
      MESSAGE e000(zboe_nc_gelsenwasser) INTO gv_message.
    ENDIF.

  ENDMETHOD.


  METHOD zboe_posdatset_delete_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_POSDATSET_DELETE_ENTITY
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

    DATA: lv_param   TYPE zboe_pdat_id,
          ls_posdat  TYPE zboe_s_posdat_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.
      DELETE FROM zboe_posdat WHERE pdat_id = @lv_param.
    ENDIF.

  ENDMETHOD.


  method ZBOE_POSDATSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZBOE_POSDATSET_GET_ENTITY
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

    DATA: lv_param TYPE zboe_pdat_id,
          ls_posdat  TYPE zboe_s_posdat_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
    lv_param = <fs_key_tab>-value.

    SELECT SINGLE * FROM zboe_posdat WHERE pdat_id = @lv_param INTO @er_entity."ls_kopf.
      "MOVE-CORRESPONDING ls_kopf TO er_entity.

    ENDIF.

  endmethod.


  method ZBOE_POSDATSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZBOE_POSDATSET_GET_ENTITYSET
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

    SELECT * FROM zboe_posdat INTO CORRESPONDING FIELDS OF TABLE et_entityset.

  endmethod.


  METHOD zboe_posdatset_update_entity.
**TRY.
*CALL METHOD SUPER->ZBOE_POSDATSET_UPDATE_ENTITY
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

    DATA: ls_posdat         TYPE zboe_s_posdat_odata,
          ls_posdat_update  TYPE zboe_s_posdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_posdat ).

    SELECT SINGLE * FROM zboe_posdat INTO ls_posdat WHERE pdat_id = ls_posdat_update-zan_id.
    IF ls_posdat_update IS INITIAL.
      MESSAGE 'Fehler! Den Datensatz gibt es überhaupt nicht' TYPE 'E'.
    ENDIF.
    UPDATE zboe_posdat FROM ls_posdat.

    IF sy-subrc <> 0.
      MESSAGE 'Fehler beim Update der Datenbank' TYPE 'E'.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
