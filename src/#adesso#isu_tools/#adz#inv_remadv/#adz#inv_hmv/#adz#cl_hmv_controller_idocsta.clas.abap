CLASS /adz/cl_hmv_controller_idocsta  DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES  /adz/if_inv_controller_basic.
    METHODS :
      constructor   IMPORTING  is_constants   TYPE /adz/hmv_s_constants,
      read_data     IMPORTING  is_sel_params  TYPE /adz/hmv_s_idoc_sel_params,
      get_data      RETURNING VALUE(rrt_table) TYPE REF TO data,
      get_statitics RETURNING VALUE(rs_stats) TYPE /adz/hmv_idoc,
      get_gui_event_handler RETURNING VALUE(rif_handler) TYPE REF TO /adz/if_inv_salv_table_evt_hlr
      .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA  mo_selector TYPE REF TO /adz/cl_hmv_select_idoc_status.
    DATA  ms_selscreen TYPE /adz/hmv_s_idoc_sel_params.

ENDCLASS.



CLASS /adz/cl_hmv_controller_idocsta IMPLEMENTATION.

  METHOD constructor.
    mo_selector = NEW /adz/cl_hmv_select_idoc_status( is_constants = is_constants ).
  ENDMETHOD.


  METHOD get_data.
    " Daten zurückgeben
    GET REFERENCE OF mo_selector->mt_out  INTO rrt_table.
    FIELD-SYMBOLS <lt_data> TYPE ANY TABLE.
    ASSIGN rrt_table->* TO <lt_data>.
  ENDMETHOD.


  METHOD read_data.
    " Daten lesen
    ms_selscreen = is_sel_params.
    mo_selector->read_idoc_data( is_sel_screen =  is_sel_params ).
  ENDMETHOD.

  METHOD /adz/if_inv_controller_basic~refresh_data.
    read_data( ms_selscreen ).
    get_data(  ).
  ENDMETHOD.

  METHOD get_statitics.
    rs_stats = mo_selector->get_statistics( ).
  ENDMETHOD.

  METHOD  get_gui_event_handler.
    rif_handler = NEW /adz/cl_hmv_func_idoc_status( irt_out_table = get_data( ) ).
    rif_handler->mo_controller = me.
  ENDMETHOD.
ENDCLASS.
