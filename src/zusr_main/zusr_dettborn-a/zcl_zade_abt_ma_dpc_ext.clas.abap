class ZCL_ZADE_ABT_MA_DPC_EXT definition
  public
  inheriting from ZCL_ZADE_ABT_MA_DPC
  create public .

public section.
protected section.

  methods ABTEILUNGSET_CREATE_ENTITY
    redefinition .
  methods ABTEILUNGSET_DELETE_ENTITY
    redefinition .
  methods ABTEILUNGSET_GET_ENTITY
    redefinition .
  methods ABTEILUNGSET_GET_ENTITYSET
    redefinition .
  methods ABTEILUNGSET_UPDATE_ENTITY
    redefinition .
  methods MITARBEITERSET_CREATE_ENTITY
    redefinition .
  methods MITARBEITERSET_DELETE_ENTITY
    redefinition .
  methods MITARBEITERSET_GET_ENTITY
    redefinition .
  methods MITARBEITERSET_GET_ENTITYSET
    redefinition .
  methods MITARBEITERSET_UPDATE_ENTITY
    redefinition .
PRIVATE SECTION.
  CONSTANTS:
    BEGIN OF gc_key_tab_name,
      manr              TYPE string  VALUE 'Nr',
      maname            TYPE string  VALUE 'Name',
      abtid             TYPE string  VALUE 'Id',
      abtbez            type string  value 'Bez',
    END OF gc_key_tab_name.
ENDCLASS.



CLASS ZCL_ZADE_ABT_MA_DPC_EXT IMPLEMENTATION.


METHOD abteilungset_create_entity.
  DATA:
    ls_entity           TYPE zcl_zade_abt_ma_mpc=>ts_abteilung,
    lr_abt              TYPE REF TO zadecl_abt,
    ls_abt              TYPE zade_abt.

  io_data_provider->read_entry_data(
    IMPORTING
      es_data = ls_entity ).

  lr_abt = zadecl_abt=>create_abt( zadecl_abt=>gc_abtid_initial ).
  ls_abt = lr_abt->gs_abt.

  ls_abt-bez = ls_entity-bez.

  lr_abt->set_abt( ls_abt ).
  lr_abt->save_abt( ).

  er_entity-id  = lr_abt->gs_abt-id.
  er_entity-bez = lr_abt->gs_abt-bez.
ENDMETHOD.


METHOD abteilungset_delete_entity.
  DATA:
    lr_key_tab          TYPE REF TO /iwbep/s_mgw_name_value_pair,
    lr_abt              TYPE REF TO zadecl_abt,
    lv_key_value_abtid  TYPE zade_abtid.

  READ TABLE it_key_tab  REFERENCE INTO lr_key_tab
    WITH KEY name = gc_key_tab_name-abtid.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  lv_key_value_abtid = lr_key_tab->value.

  IF lv_key_value_abtid = zadecl_abt=>gc_abtid_initial.
    RETURN.
  ENDIF.

  lr_abt = zadecl_abt=>create_abt( lv_key_value_abtid ).

  IF lr_abt->gs_abt-id = zadecl_abt=>gc_abtid_initial.
    RETURN.
  ENDIF.

  lr_abt->delete_abt( ).
ENDMETHOD.


METHOD abteilungset_get_entity.
  DATA:
    lr_key_tab          TYPE REF TO /iwbep/s_mgw_name_value_pair,
    lr_abt              TYPE REF TO zadecl_abt,
    lv_key_value_abtid  TYPE zade_abtid.

  READ TABLE it_key_tab  REFERENCE INTO lr_key_tab
    WITH KEY name = gc_key_tab_name-abtid.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  lv_key_value_abtid = lr_key_tab->value.

  IF lv_key_value_abtid = zadecl_abt=>gc_abtid_initial.
    RETURN.
  ENDIF.

  lr_abt = zadecl_abt=>create_abt( lv_key_value_abtid ).

  IF lr_abt->gs_abt-id = zadecl_abt=>gc_abtid_initial.
    RETURN.
  ENDIF.

  er_entity-id  = lr_abt->gs_abt-id.
  er_entity-bez = lr_abt->gs_abt-bez.
ENDMETHOD.


METHOD abteilungset_get_entityset.
  DATA:
    lr_key_tab          TYPE REF TO /iwbep/s_mgw_name_value_pair,
    lr_entityset        TYPE REF TO zcl_zade_abt_ma_mpc=>ts_abteilung,
    lt_obj_abt          TYPE zadecl_abt_tt,
    lr_abt              TYPE REF TO zadecl_abt,

    BEGIN OF ls_key_value,
      abtbez            TYPE zade_abtbez,
    END OF ls_key_value.

  ls_key_value-abtbez = ''.

  READ TABLE it_key_tab  REFERENCE INTO lr_key_tab
    WITH KEY name = gc_key_tab_name-abtbez.
  IF sy-subrc = 0.
    ls_key_value-abtbez = lr_key_tab->value.
  ENDIF.

  lt_obj_abt[] = zadecl_abt=>create_abt_list( ls_key_value-abtbez ).

  LOOP AT lt_obj_abt  INTO lr_abt.
    APPEND INITIAL LINE  TO et_entityset  REFERENCE INTO lr_entityset.

    lr_entityset->id  = lr_abt->gs_abt-id.
    lr_entityset->bez = lr_abt->gs_abt-bez.
  ENDLOOP.
ENDMETHOD.


METHOD abteilungset_update_entity.
  DATA:
    ls_entity           TYPE zcl_zade_abt_ma_mpc=>ts_abteilung,
    lr_abt              TYPE REF TO zadecl_abt,
    ls_abt              TYPE zade_abt.

  io_data_provider->read_entry_data(
    IMPORTING
      es_data = ls_entity ).

  lr_abt = zadecl_abt=>create_abt( ls_entity-id ).
  IF lr_abt->gs_abt-id = zadecl_abt=>gc_abtid_initial.
    RETURN.
  ENDIF.

  ls_abt = lr_abt->gs_abt.

  ls_abt-bez = ls_entity-bez.

  lr_abt->set_abt( ls_abt ).
  lr_abt->save_abt( ).

  er_entity-id  = lr_abt->gs_abt-id.
  er_entity-bez = lr_abt->gs_abt-bez.
ENDMETHOD.


METHOD mitarbeiterset_create_entity.
ENDMETHOD.


METHOD mitarbeiterset_delete_entity.
ENDMETHOD.


METHOD mitarbeiterset_get_entity.
  DATA:
    lr_key_tab          TYPE REF TO /iwbep/s_mgw_name_value_pair,
    lr_ma               TYPE REF TO zadecl_ma,
    lv_key_value_manr   TYPE zade_manr.

  READ TABLE it_key_tab  REFERENCE INTO lr_key_tab
    WITH KEY name = gc_key_tab_name-manr.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  lv_key_value_manr = lr_key_tab->value.

  IF lv_key_value_manr = zadecl_ma=>gc_manr_initial.
    RETURN.
  ENDIF.

  lr_ma = zadecl_ma=>create_ma( lv_key_value_manr ).

  IF lr_ma->gs_ma-nr = zadecl_ma=>gc_manr_initial.
    RETURN.
  ENDIF.

  er_entity-nr    = lr_ma->gs_ma-nr.
  er_entity-name  = lr_ma->gs_ma-name.
  er_entity-abtid = lr_ma->gs_ma-abtid.
ENDMETHOD.


METHOD mitarbeiterset_get_entityset.
  DATA:
    lr_key_tab          TYPE REF TO /iwbep/s_mgw_name_value_pair,
    lr_entityset        TYPE REF TO zcl_zade_abt_ma_mpc=>ts_mitarbeiter,
    lt_obj_ma           TYPE zadecl_ma_tt,
    lr_ma               TYPE REF TO zadecl_ma,

    BEGIN OF ls_key_value,
      maname            TYPE zade_maname,
      abtid             TYPE zade_abtid,
    END OF ls_key_value.

  ls_key_value-maname = ''.
  ls_key_value-abtid  = zadecl_abt=>gc_abtid_initial.

  READ TABLE it_key_tab  REFERENCE INTO lr_key_tab
    WITH KEY name = gc_key_tab_name-maname.
  IF sy-subrc = 0.
    ls_key_value-maname = lr_key_tab->value.
  ENDIF.

  READ TABLE it_key_tab  REFERENCE INTO lr_key_tab
    WITH KEY name = gc_key_tab_name-abtid.
  IF sy-subrc = 0.
    ls_key_value-abtid = lr_key_tab->value.
  ENDIF.

  lt_obj_ma[] = zadecl_ma=>create_ma_list(
                    iv_maname = ls_key_value-maname
                    iv_abtid  = ls_key_value-abtid ).

  LOOP AT lt_obj_ma  INTO lr_ma.
    APPEND INITIAL LINE  TO et_entityset  REFERENCE INTO lr_entityset.

    lr_entityset->nr    = lr_ma->gs_ma-nr.
    lr_entityset->name  = lr_ma->gs_ma-name.
    lr_entityset->abtid = lr_ma->gs_ma-abtid.
  ENDLOOP.
ENDMETHOD.


METHOD mitarbeiterset_update_entity.
ENDMETHOD.
ENDCLASS.
