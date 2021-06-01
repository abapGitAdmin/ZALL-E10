class ZCL_ZKERK_GELSENWASSER_DPC_EXT definition
  public
  inheriting from ZCL_ZKERK_GELSENWASSER_DPC
  create public .

public section.
protected section.

  methods BUCHUNGSCODESET_CREATE_ENTITY
    redefinition .
  methods BUCHUNGSCODESET_DELETE_ENTITY
    redefinition .
  methods BUCHUNGSCODESET_GET_ENTITY
    redefinition .
  methods BUCHUNGSCODESET_GET_ENTITYSET
    redefinition .
  methods KOPFDATENSET_CREATE_ENTITY
    redefinition .
  methods KOPFDATENSET_DELETE_ENTITY
    redefinition .
  methods KOPFDATENSET_GET_ENTITY
    redefinition .
  methods KOPFDATENSET_GET_ENTITYSET
    redefinition .
  methods KOPFDATENSET_UPDATE_ENTITY
    redefinition .
  methods NOTIZSET_CREATE_ENTITY
    redefinition .
  methods NOTIZSET_DELETE_ENTITY
    redefinition .
  methods NOTIZSET_GET_ENTITY
    redefinition .
  methods NOTIZSET_GET_ENTITYSET
    redefinition .
  methods POSITIONSDATENSE_CREATE_ENTITY
    redefinition .
  methods POSITIONSDATENSE_GET_ENTITY
    redefinition .
  methods POSITIONSDATENSE_GET_ENTITYSET
    redefinition .
  methods POSITIONSDATENSE_DELETE_ENTITY
    redefinition .
  " müsste eigentlich hier stehen.
  " methods KOPFDATENSET_CREAT_ENTITY
  "   redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZKERK_GELSENWASSER_DPC_EXT IMPLEMENTATION.


  method BUCHUNGSCODESET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->BUCHUNGSCODESET_CREATE_ENTITY
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

    DATA: ls_kerk_create TYPE zkerk_s_buchungdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_kerk_create ).

    INSERT INTO zkerk_buchungdat values ls_kerk_create. "hier natürlich nich die eigene Struktur sondern die tabelle die man erstellen will.

  endmethod.


  method BUCHUNGSCODESET_DELETE_ENTITY.
**TRY.
*CALL METHOD SUPER->BUCHUNGSCODESET_DELETE_ENTITY
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

      DATA: lv_param TYPE ZKERK_BUCO_ID,
          ls_kopf  TYPE zkerk_s_buchungdat_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

     " SELECT SINGLE *
     " FROM zkerk_zakopfdat
     " WHERE nummer_zahlungsanweisung = @lv_param
     "   INTO @ls_kopf.

      DELETE  " zkerk_zakopfdat
      " geht über die Tabelle.
      FROM zkerk_buchungdat  " @ls_kopf. "
      where BUCHUNGSCODE_ID = <fs_key_tab>-value.

    ENDIF.

  endmethod.


  method BUCHUNGSCODESET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->BUCHUNGSCODESET_GET_ENTITY
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
          ls_kopf  TYPE ZKERK_S_BUCHUNGDAT_ODATA.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

      SELECT SINGLE *
      FROM ZKERK_BUCHUNGDAT
      WHERE BUCHUNGSCODE_ID = @lv_param
        INTO @ls_kopf.
      MOVE-CORRESPONDING ls_kopf TO er_entity.
    ENDIF.


  endmethod.


  method BUCHUNGSCODESET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->BUCHUNGSCODESET_GET_ENTITYSET
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

        SELECT * FROM ZKERK_BUCHUNGDAT INTO TABLE et_entityset.



  endmethod.


  METHOD kopfdatenset_create_entity.
**TRY.
*CALL METHOD SUPER->KOPFDATENSET_CREATE_ENTITY
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

    DATA: ls_kerk_create TYPE zkerk_s_zakopfdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_kerk_create ).

    INSERT INTO zkerk_zakopfdat values ls_kerk_create. "hier natürlich nich die eigene Struktur sondern die tabelle die man erstellen will.


  ENDMETHOD.


  method KOPFDATENSET_DELETE_ENTITY.
**TRY.
*CALL METHOD SUPER->KOPFDATENSET_DELETE_ENTITY
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


    DATA: lv_param TYPE zkerk_zan_id,
          ls_kopf  TYPE zkerk_s_zakopfdat_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

     " SELECT SINGLE *
     " FROM zkerk_zakopfdat
     " WHERE nummer_zahlungsanweisung = @lv_param
     "   INTO @ls_kopf.

      DELETE  " zkerk_zakopfdat
      " geht über die Tabelle.
      FROM zkerk_zakopfdat  " @ls_kopf. "
      where NUMMER_ZAHLUNGSANWEISUNG = <fs_key_tab>-value.

    ENDIF.


  endmethod.


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


  method KOPFDATENSET_GET_ENTITYSET.
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

*DATA: lt_posidtn TYPE TABLE OF ZKERK_S_ZAKOPFDAT_ODATA.
    SELECT * FROM ZKERK_ZAKOPFDAT INTO TABLE et_entityset.
*    MOVE-CORRESPONDING lt_posidtn TO et_entityset.





  endmethod.


  METHOD kopfdatenset_update_entity.
**TRY.
*CALL METHOD SUPER->KOPFDATENSET_UPDATE_ENTITY
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
    DATA: ls_kerk_import TYPE zkerk_s_zakopfdat_odata,
          ls_kerk_update TYPE zkerk_s_zakopfdat_odata.
    "Struktur angelegt.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_kerk_import ).
    SELECT SINGLE *
    FROM zkerk_zakopfdat
    INTO ls_kerk_update
    WHERE nummer_zahlungsanweisung = ls_kerk_import-nummer_zahlungsanweisung.

      IF ls_kerk_update IS INITIAL.
      "Fehler! Den Datensatz gibt es überhaupt nicht!
    MESSAGE e001(ZKERK_NC_GWASSER).
    ENDIF.

     IF sy-subrc <> 0. "anderer Fehler mit gleicher ausgabe
      MESSAGE e001(ZKERK_NC_GWASSER).
     ENDIF.

    UPDATE zkerk_zakopfdat FROM ls_kerk_import.

  ENDMETHOD.


  method NOTIZSET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->NOTIZSET_CREATE_ENTITY
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

    DATA: ls_kerk_create TYPE zkerk_s_zanotiz_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_kerk_create ).

    INSERT INTO zkerk_zanotiz values ls_kerk_create. "hier natürlich nich die eigene Struktur sondern die tabelle die man erstellen will.

  endmethod.


  method NOTIZSET_DELETE_ENTITY.
**TRY.
*CALL METHOD SUPER->NOTIZSET_DELETE_ENTITY
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


     DATA: lv_param TYPE ZKERK_NOTIZ_ID,
          ls_kopf  TYPE zkerk_s_zanotiz_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

     " SELECT SINGLE *
     " FROM zkerk_zakopfdat
     " WHERE nummer_zahlungsanweisung = @lv_param
     "   INTO @ls_kopf.

      DELETE  " zkerk_zakopfdat
      " geht über die Tabelle.
      FROM zkerk_zanotiz  " @ls_kopf. "
      where NOTIZ_ID = <fs_key_tab>-value.

    ENDIF.


  endmethod.


  method NOTIZSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->NOTIZSET_GET_ENTITY
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
          ls_kopf  TYPE zkerk_s_zanotiz_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

      SELECT SINGLE *
      FROM zkerk_zanotiz
      WHERE NOTIZ_ID = @lv_param
        INTO @ls_kopf.
      MOVE-CORRESPONDING ls_kopf TO er_entity.
    ENDIF.


  endmethod.


  method NOTIZSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->NOTIZSET_GET_ENTITYSET
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

   SELECT * FROM ZKERK_ZANOTIZ INTO TABLE et_entityset.

  endmethod.


  method POSITIONSDATENSE_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->POSITIONSDATENSE_CREATE_ENTITY
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


    DATA: ls_kerk_create TYPE zkerk_s_zaposdat_odata.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_kerk_create ).

    INSERT INTO zkerk_zaposdat values ls_kerk_create. "hier natürlich nich die eigene Struktur sondern die tabelle die man erstellen will.

  endmethod.


  method POSITIONSDATENSE_DELETE_ENTITY.
**TRY.
*CALL METHOD SUPER->POSITIONSDATENSE_DELETE_ENTITY
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

         DATA: lv_param TYPE ZKERK_BUCO_ID,
          ls_kopf  TYPE zkerk_s_ZAPOSDAT_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

     " SELECT SINGLE *
     " FROM zkerk_zakopfdat
     " WHERE nummer_zahlungsanweisung = @lv_param
     "   INTO @ls_kopf.

      DELETE  " zkerk_zakopfdat
      " geht über die Tabelle.
      FROM ZKERK_ZAPOSDAT  " @ls_kopf. "
      where BUCHUNGSCODE_ID = <fs_key_tab>-value.

    ENDIF.


  endmethod.


  method POSITIONSDATENSE_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->POSITIONSDATENSE_GET_ENTITY
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

     DATA: lv_param TYPE ZKERK_BUCO_ID,
          ls_kopf  TYPE zkerk_s_zaposdat_odata.

    READ TABLE it_key_tab INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_key_tab>).

    IF <fs_key_tab> IS ASSIGNED.
      lv_param = <fs_key_tab>-value.

      SELECT SINGLE *
      FROM zkerk_zaposdat
      WHERE BUCHUNGSCODE_ID = @lv_param
        INTO @ls_kopf.
      MOVE-CORRESPONDING ls_kopf TO er_entity.
    ENDIF.


  endmethod.


  method POSITIONSDATENSE_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->POSITIONSDATENSE_GET_ENTITYSET
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


       SELECT * FROM ZKERK_ZAPOSDAT INTO TABLE et_entityset.


  endmethod.
ENDCLASS.
