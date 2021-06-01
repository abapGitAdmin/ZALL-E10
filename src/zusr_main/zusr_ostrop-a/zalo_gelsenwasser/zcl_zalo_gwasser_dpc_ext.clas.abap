class ZCL_ZALO_GWASSER_DPC_EXT definition
  public
  inheriting from ZCL_ZALO_GWASSER_DPC
  create public .

public section.
protected section.

  methods ZALO_BOOK_CODESE_CREATE_ENTITY
    redefinition .
  methods ZALO_BOOK_CODESE_DELETE_ENTITY
    redefinition .
  methods ZALO_BOOK_CODESE_GET_ENTITY
    redefinition .
  methods ZALO_BOOK_CODESE_GET_ENTITYSET
    redefinition .
  methods ZALO_BOOK_CODESE_UPDATE_ENTITY
    redefinition .
  methods ZALO_NOTATIONSET_CREATE_ENTITY
    redefinition .
  methods ZALO_NOTATIONSET_DELETE_ENTITY
    redefinition .
  methods ZALO_NOTATIONSET_GET_ENTITY
    redefinition .
  methods ZALO_NOTATIONSET_GET_ENTITYSET
    redefinition .
  methods ZALO_NOTATIONSET_UPDATE_ENTITY
    redefinition .
  methods ZALO_POSIDATSET_CREATE_ENTITY
    redefinition .
  methods ZALO_POSIDATSET_DELETE_ENTITY
    redefinition .
  methods ZALO_POSIDATSET_GET_ENTITY
    redefinition .
  methods ZALO_POSIDATSET_GET_ENTITYSET
    redefinition .
  methods ZALO_POSIDATSET_UPDATE_ENTITY
    redefinition .
  methods ZALO_ZAHLANWSET_CREATE_ENTITY
    redefinition .
  methods ZALO_ZAHLANWSET_DELETE_ENTITY
    redefinition .
  methods ZALO_ZAHLANWSET_GET_ENTITY
    redefinition .
  methods ZALO_ZAHLANWSET_GET_ENTITYSET
    redefinition .
  methods ZALO_ZAHLANWSET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZALO_GWASSER_DPC_EXT IMPLEMENTATION.


  METHOD zalo_book_codese_create_entity.
**TRY.
*CALL METHOD SUPER->ZALO_BOOK_CODESE_CREATE_ENTITY
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

    DATA: ls_boco TYPE zalo_s_book_code_odata.
"nummernkreis fehlt
    io_data_provider->read_entry_data( IMPORTING es_data = ls_boco ).

    IF ls_boco IS NOT INITIAL.
      INSERT INTO zalo_book_code VALUES ls_boco.
    ELSE.
      MESSAGE e000(ZALO_NC_GWASSER).
    ENDIF.


  ENDMETHOD.


  METHOD zalo_book_codese_delete_entity.
**TRY.
*CALL METHOD SUPER->ZALO_BOOK_CODESE_DELETE_ENTITY
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


  METHOD zalo_book_codese_get_entity.
**TRY.
*CALL METHOD SUPER->ZALO_BOOK_CODESE_GET_ENTITY
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

    DATA : lv_param TYPE zalo_boco_id,
           ls_kopf  TYPE zalo_s_book_code_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.

      SELECT SINGLE * FROM zalo_book_code WHERE boco_id = @lv_param INTO @er_entity."ls_kopf.

      IF sy-subrc <> 0 .
        MESSAGE e004(zalo_nc_gwasser).
      ENDIF.

      "MOVE-CORRESPONDING ls_kopf to er_entity.

    ENDIF.

  ENDMETHOD.


  METHOD zalo_book_codese_get_entityset.
**TRY.
*CALL METHOD SUPER->ZALO_BOOK_CODESE_GET_ENTITYSET
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

    SELECT * FROM zalo_book_code INTO CORRESPONDING FIELDS OF TABLE et_entityset.

  ENDMETHOD.


  METHOD zalo_book_codese_update_entity.
**TRY.
*CALL METHOD SUPER->ZALO_BOOK_CODESE_UPDATE_ENTITY
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

    DATA: ls_boco_import TYPE zalo_s_book_code_odata,
          ls_boco_update TYPE zalo_s_book_code_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_boco_import ).
    SELECT SINGLE * FROM zalo_book_code INTO ls_boco_update WHERE boco_id = ls_boco_import-boco_id.
    IF ls_boco_update IS INITIAL.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
      MESSAGE e002(ZALO_NC_GWASSER).
    ENDIF.
    UPDATE zalo_book_code from ls_boco_import.

    IF sy-subrc <>  0.
      MESSAGE e003(ZALO_NC_GWASSER).
    ENDIF.

  ENDMETHOD.


  method ZALO_NOTATIONSET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_NOTATIONSET_CREATE_ENTITY
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

    DATA: ls_note TYPE zalo_s_notation_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_note ).

    IF ls_note IS NOT INITIAL.
      INSERT INTO zalo_notation VALUES ls_note.
    ELSE.
      MESSAGE 'Fehler beim Auslesen der Eingabe' TYPE 'E'.
    ENDIF.


  endmethod.


  METHOD zalo_notationset_delete_entity.
**TRY.
*CALL METHOD SUPER->ZALO_NOTATIONSET_DELETE_ENTITY
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

    DATA : lv_param TYPE zalo_note_id,
           ls_kopf  TYPE zalo_s_notation_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.

      DELETE FROM zalo_notation WHERE note_id = @lv_param.

    ENDIF.

  ENDMETHOD.


  METHOD zalo_notationset_get_entity.
**TRY.
*CALL METHOD SUPER->ZALO_NOTATIONSET_GET_ENTITY
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

    DATA : lv_param TYPE zalo_note_id,
           ls_kopf  TYPE zalo_s_notation_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.

      SELECT SINGLE * FROM zalo_notation WHERE note_id = @lv_param INTO @er_entity."ls_kopf.

      IF sy-subrc <> 0 .
        MESSAGE e004(zalo_nc_gwasser).
      ENDIF.

      "MOVE-CORRESPONDING ls_kopf to er_entity.

    ENDIF.

  ENDMETHOD.


  method ZALO_NOTATIONSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZALO_NOTATIONSET_GET_ENTITYSET
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

     SELECT * FROM zalo_notation INTO CORRESPONDING FIELDS OF TABLE et_entityset.

  endmethod.


  method ZALO_NOTATIONSET_UPDATE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_NOTATIONSET_UPDATE_ENTITY
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

    DATA: ls_note_import TYPE zalo_s_notation_odata,
          ls_note_update TYPE zalo_s_notation_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_note_import ).
    SELECT SINGLE * FROM zalo_notation INTO ls_note_update WHERE note_id = ls_note_import-note_id.
    IF ls_note_update IS INITIAL.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
    MESSAGE e002(ZALO_NC_GWASSER).
    ENDIF.
    UPDATE zalo_notation from ls_note_import.

     IF sy-subrc <> 0.
      MESSAGE e003(ZALO_NC_GWASSER).
    ENDIF.

  endmethod.


  method ZALO_POSIDATSET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_POSIDATSET_CREATE_ENTITY
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

    DATA: ls_pdat TYPE zalo_s_posidtn_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_pdat ).

    IF ls_pdat IS NOT INITIAL.
      INSERT INTO zalo_posidtn VALUES ls_pdat.
    ELSE.
      MESSAGE 'Fehler beim Auslesen der Eingabe' TYPE 'E'.
    ENDIF.

  endmethod.


  method ZALO_POSIDATSET_DELETE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_POSIDATSET_DELETE_ENTITY
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

    DATA : lv_param TYPE zalo_pdat_id,
           ls_kopf  TYPE zalo_s_posidtn_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.

      DELETE FROM zalo_posidtn WHERE pdat_id = @lv_param.

      ENDIF.

  endmethod.


  method ZALO_POSIDATSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_POSIDATSET_GET_ENTITY
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

    DATA : lv_param TYPE zalo_pdat_id,
           ls_kopf  TYPE zalo_s_posidtn_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.

      SELECT SINGLE * FROM zalo_posidtn WHERE pdat_id = @lv_param INTO @er_entity."ls_kopf.

        "MOVE-CORRESPONDING ls_kopf to er_entity.

    ENDIF.

  endmethod.


  method ZALO_POSIDATSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZALO_POSIDATSET_GET_ENTITYSET
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

     SELECT * FROM zalo_posidtn INTO CORRESPONDING FIELDS OF TABLE et_entityset.


  endmethod.


  method ZALO_POSIDATSET_UPDATE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_POSIDATSET_UPDATE_ENTITY
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

    DATA: ls_pdat_import TYPE zalo_s_posidtn_odata,
          ls_pdat_update TYPE zalo_s_posidtn_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_pdat_import ).
    SELECT SINGLE * FROM zalo_posidtn INTO ls_pdat_update WHERE pdat_id = ls_pdat_import-pdat_id.
    IF ls_pdat_update IS INITIAL.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
     MESSAGE e002(ZALO_NC_GWASSER).
    ENDIF.
    UPDATE zalo_posidtn from ls_pdat_import.

    IF sy-subrc <> 0.
      MESSAGE e003(ZALO_NC_GWASSER).
    ENDIF.

  endmethod.


  method ZALO_ZAHLANWSET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_ZAHLANWSET_CREATE_ENTITY
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

    DATA: ls_zanw TYPE zalo_s_kopfdtn_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_zanw ).

    IF ls_zanw IS NOT INITIAL.
      INSERT INTO zalo_kopfdtn VALUES ls_zanw.
    ELSE.
      MESSAGE e000(ZALO_NC_GWASSER).
    ENDIF.

  endmethod.


  method ZALO_ZAHLANWSET_DELETE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_ZAHLANWSET_DELETE_ENTITY
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

    DATA : lv_param TYPE zalo_zan_id,
           ls_kopf  TYPE zalo_s_kopfdtn_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.

      DELETE FROM zalo_kopfdtn WHERE zan_id = @lv_param.

    ELSE.
      MESSAGE e001(ZALO_NC_GWASSER).
    ENDIF.

  endmethod.


  method ZALO_ZAHLANWSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_ZAHLANWSET_GET_ENTITY
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

    DATA : lv_param TYPE zalo_zan_id.
          " ls_kopf  TYPE zalo_s_kopfdtn_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.

      lv_param = <fs_key_tab>-value.

      SELECT SINGLE * FROM zalo_kopfdtn WHERE zan_id = @lv_param INTO @er_entity."ls_kopf.

        "MOVE-CORRESPONDING ls_kopf to er_entity.

    ENDIF.

  endmethod.


  method ZALO_ZAHLANWSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZALO_ZAHLANWSET_GET_ENTITYSET
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

     SELECT * FROM zalo_kopfdtn INTO CORRESPONDING FIELDS OF TABLE et_entityset.

  endmethod.


  method ZALO_ZAHLANWSET_UPDATE_ENTITY.
**TRY.
*CALL METHOD SUPER->ZALO_ZAHLANWSET_UPDATE_ENTITY
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

    DATA: ls_zanw_import TYPE zalo_s_kopfdtn_odata,
          ls_zanw_update TYPE zalo_s_kopfdtn_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_zanw_import ).
    SELECT SINGLE * FROM zalo_kopfdtn INTO ls_zanw_update WHERE zan_id = ls_zanw_import-zan_id.
    IF ls_zanw_update IS INITIAL.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
MESSAGE e002(ZALO_NC_GWASSER).
    ENDIF.
    UPDATE zalo_kopfdtn from ls_zanw_import.

    IF sy-subrc <> 0.
      MESSAGE e003(ZALO_NC_GWASSER).
    ENDIF.

  endmethod.
ENDCLASS.
