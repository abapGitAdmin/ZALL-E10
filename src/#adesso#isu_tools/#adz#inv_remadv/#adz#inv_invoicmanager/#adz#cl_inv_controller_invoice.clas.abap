CLASS /adz/cl_inv_controller_invoice  DEFINITION INHERITING FROM /adz/cl_inv_controller_common
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS :
      constructor,
      read_data REDEFINITION,
      get_data  REDEFINITION,
      get_gui_event_handler REDEFINITION.
      .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA  mo_selector TYPE REF TO /adz/cl_inv_select_invoice.

ENDCLASS.



CLASS /ADZ/CL_INV_CONTROLLER_INVOICE IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    CREATE OBJECT mo_selector.
  ENDMETHOD.


  METHOD get_data.
    " Daten zurückgeben
    GET REFERENCE OF mo_selector->mt_out_invoice_data  INTO rrt_table.
    FIELD-SYMBOLS <lt_data> type any table.
    assign rrt_table->* to <lt_data>.
    if sy-sysid = 'E10' and lines( <lt_data> ) eq 0.
        " only for testing
*        FIELD-SYMBOLS: <ls_data> type /adz/inv_s_out_basic.
*        insert INITIAL LINE INTO table <lt_data> ASSIGNING <ls_data>.
*        <ls_data>-quantity = 7.
*        <ls_data>-lights  = '3'.
        <lt_data> = value /adz/inv_t_out_reklamon(
           (  lights = '1' waiting = 'W1' quantity = 7 LS_STATUS = '01' ls_pdoc_ref = '1704'  )
           (  lights = '2' waiting = 'W2' quantity = 7  )
           (  lights = '3' waiting = 'W3' quantity = 7  )
           (  lights = '3' waiting = 'W4' quantity = 7  )
           (  lights = '3' waiting = 'W5' quantity = 100  )
         ).
        <lt_data> = value /adz/inv_t_out_reklamon( base <lt_data> for i = 1 until i > 70 (
          lights = '1' waiting = |W{ i }| quantity = i ) ).
    endif.
  ENDMETHOD.


  METHOD read_data.
    " Daten lesen
    ms_selscreen = is_sel_screen.
    mo_selector->read_invman_data( is_sel_screen =  is_sel_screen ).
  ENDMETHOD.

  METHOD  get_gui_event_handler.
    rif_handler = new /adz/cl_inv_func_invoice(  irt_out_table = get_data( )   is_selscreen = ms_selscreen ).
    rif_handler->mo_controller = me.
  ENDMETHOD.

ENDCLASS.
