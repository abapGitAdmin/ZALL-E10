CLASS /adz/cl_inv_controller_reklamo DEFINITION INHERITING FROM /adz/cl_inv_controller_common
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    METHODS :
      constructor,
      read_data REDEFINITION,
      get_data  REDEFINITION,
      get_gui_event_handler  REDEFINITION.
    .

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA  mo_selector     TYPE REF TO /adz/cl_inv_select_reklamon.

ENDCLASS.



CLASS /ADZ/CL_INV_CONTROLLER_REKLAMO IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    CREATE OBJECT mo_selector.
  ENDMETHOD.


  METHOD get_data.
    " Daten zurückgeben
    GET REFERENCE OF mo_selector->mt_out_reklamon_data INTO rrt_table.

    FIELD-SYMBOLS <lt_data> TYPE ANY TABLE.
    ASSIGN rrt_table->* TO <lt_data>.
    IF sy-sysid = 'E10' and lines( <lt_data> ) EQ 0.
      " only for debugging
      FIELD-SYMBOLS: <ls_data> TYPE /adz/inv_s_out_reklamon.
      <lt_data> = value /adz/inv_t_out_reklamon( base <lt_data> for i = 1 until i > 70 (
          lights = '1' waiting = |W{ i }| quantity = i ) ).
    ENDIF.

  ENDMETHOD.


  METHOD read_data.
    " Daten lesen
    ms_selscreen = is_sel_screen.
    mo_selector->read_reklamon_data( is_sel_screen =  is_sel_screen ).
  ENDMETHOD.


  METHOD  get_gui_event_handler.
    rif_handler = new /adz/cl_inv_func_reklamon( irt_out_table = get_data( )  is_selscreen = ms_selscreen ).
    rif_handler->mo_controller = me.
  ENDMETHOD.
ENDCLASS.
