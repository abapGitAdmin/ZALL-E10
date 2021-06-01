CLASS /adz/cl_inv_controller_common DEFINITION
  ABSTRACT PUBLIC
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES /ADZ/IF_INV_CONTROLLER_BASIC.

    METHODS :
      read_data ABSTRACT
        IMPORTING is_sel_screen TYPE /adz/inv_s_sel_screen,
      get_data ABSTRACT
        RETURNING VALUE(rrt_table) TYPE REF TO data,
      get_gui_event_handler ABSTRACT
        RETURNING VALUE(rif_handler) type ref to /adz/if_inv_salv_table_evt_hlr
      .
  PROTECTED SECTION.
    DATA  ms_selscreen    type /adz/inv_s_sel_screen.

ENDCLASS.



CLASS /adz/cl_inv_controller_common IMPLEMENTATION.
  method /ADZ/IF_INV_CONTROLLER_BASIC~refresh_data.
    read_data( ms_selscreen ).

    DATA(lrt_data) = get_data(  ).
    if /ADZ/IF_INV_CONTROLLER_BASIC~mo_gui is not INITIAL.
        FIELD-SYMBOLS <lt_data> type any table.
        assign lrt_data->* to <lt_data>.
       /ADZ/IF_INV_CONTROLLER_BASIC~mo_gui->set_nr_of_nows( iv_nr_rows =  lines( <lt_data> ) ).
    endif.
  endmethod.

ENDCLASS.

