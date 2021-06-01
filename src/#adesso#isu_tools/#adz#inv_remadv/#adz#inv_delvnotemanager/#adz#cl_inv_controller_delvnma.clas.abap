CLASS /adz/cl_inv_controller_delvnma  DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /adz/if_inv_controller_basic.

    METHODS :
      constructor,
      read_data             IMPORTING is_sel_screen TYPE /adz/inv_s_delvnoteman_selpar,
      get_data              RETURNING VALUE(rrt_table) TYPE REF TO data,
      get_gui_event_handler RETURNING VALUE(rif_handler) TYPE REF TO /adz/if_inv_salv_table_evt_hlr
      .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA  mo_selector TYPE REF TO /adz/cl_inv_select_delvnoteman.
    DATA  ms_selscreen TYPE /adz/inv_s_delvnoteman_selpar.

ENDCLASS.



CLASS /adz/cl_inv_controller_delvnma IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    CREATE OBJECT mo_selector.
  ENDMETHOD.


  METHOD get_data.
    " Daten zurückgeben
    get reference of  mo_selector->mt_out_data  into rrt_table.
    FIELD-SYMBOLS <lt_data> TYPE ANY TABLE.
    ASSIGN rrt_table->* TO <lt_data>.
    IF sy-sysid = 'E10' AND lines( <lt_data> ) EQ 0.
      " only for testing
        <lt_data> = value /adz/inv_t_out_delvnoteman(
           (  lights = '0' ext_reference = 'W1' quantity_ext = '20191128225959.00000' more_cases = 'X' )
           (  lights = '1' ext_reference = 'W11'  )
           (  lights = '2' ext_reference = 'W2' )
           (  lights = '3' ext_reference = 'W3' )
           (  lights = '3' ext_reference = 'W4' )
           (  lights = '3' ext_reference = 'W5' )
         ).

      <lt_data> = VALUE /adz/inv_t_out_delvnoteman( BASE <lt_data> FOR i = 1 UNTIL i > 70 (
        status = '1' ext_reference = |{ i }|  ) ).
    ENDIF.
  ENDMETHOD.


  METHOD read_data.
    " Daten lesen
    ms_selscreen = is_sel_screen.
    mo_selector->read_data( is_sel_screen =  is_sel_screen ).
  ENDMETHOD.

  METHOD /adz/if_inv_controller_basic~refresh_data.
    read_data( ms_selscreen ).
    get_data(  ).
  ENDMETHOD.

  METHOD  get_gui_event_handler.
    rif_handler = NEW /adz/cl_inv_func_delvnoteman(  irt_out_table = get_data( )   is_selscreen_dnm = ms_selscreen ).
    rif_handler->mo_controller = me.
  ENDMETHOD.

ENDCLASS.
