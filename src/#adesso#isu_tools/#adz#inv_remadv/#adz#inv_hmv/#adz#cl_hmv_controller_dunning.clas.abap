CLASS /adz/cl_hmv_controller_dunning  DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /adz/if_inv_controller_basic.
    METHODS :
      constructor
        IMPORTING
          is_constants  TYPE  /adz/hmv_s_constants
          is_sel_params TYPE /adz/hmv_s_dunning_sel_params,

      read_data,
      get_data      RETURNING VALUE(rrt_table) TYPE REF TO data,
      get_gui_event_handler RETURNING VALUE(rif_handler) TYPE REF TO /adz/if_inv_salv_table_evt_hlr,
      read_extract,
      save_extract
        IMPORTING
          iv_extract_text TYPE string
          iv_uzeit_text   TYPE string
          iv_uzeit        TYPE syst_uzeit
        .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA  mo_selector TYPE REF TO /adz/cl_hmv_select_dunning.
    DATA  ms_selscreen TYPE /adz/hmv_s_dunning_sel_params.
    DATA  mv_repid     TYPE repid.

ENDCLASS.



CLASS /adz/cl_hmv_controller_dunning IMPLEMENTATION.

  METHOD constructor.
    mo_selector = NEW /adz/cl_hmv_select_dunning( is_constants = is_constants ).
    ms_selscreen = is_sel_params.
    mv_repid    = is_constants-repid.
  ENDMETHOD.


  METHOD get_data.
    " Daten zurückgeben
    GET REFERENCE OF mo_selector->mt_out  INTO rrt_table.
    FIELD-SYMBOLS <lt_data> TYPE ANY TABLE.
    ASSIGN rrt_table->* TO <lt_data>.
    IF sy-sysid = 'E10' AND lines( <lt_data> ) EQ 0.
      " only for testing
      <lt_data> = VALUE /adz/hmv_t_out_dunning(
         (  vkont = '07' bcaug = '1' bukrs = 'A7' waers = 'EUR' )
       ).
      <lt_data> = VALUE /adz/hmv_t_out_dunning( BASE <lt_data> FOR i = 1 UNTIL i > 70 (
        status = '1' bcbln = |{ i }|  ) ).
    ENDIF.
  ENDMETHOD.

  METHOD read_data.
    " Daten lesen
    mo_selector->read_data( is_sel_screen =  ms_selscreen ).
  ENDMETHOD.

  METHOD read_extract.
    " Extrakt lesen
    DATA lrt_data TYPE REF TO data.
    lrt_data = REF #( mo_selector->mt_out ).
    /adz/cl_inv_select_basic=>read_extract(
      EXPORTING  iv_repid = mv_repid
      CHANGING   crt_data = lrt_data
    ).
  ENDMETHOD.

  METHOD save_extract.
    DATA lrt_data TYPE REF TO data.
    lrt_data = get_data(  ).
    /adz/cl_inv_select_basic=>save_extract(
      EXPORTING
        iv_repid        = mv_repid
        iv_extract_text = iv_extract_text
        iv_uzeit_text   = iv_uzeit_text
        iv_uzeit        = iv_uzeit
      CHANGING
        crt_data        = lrt_data
    ).
  ENDMETHOD.

  METHOD /adz/if_inv_controller_basic~refresh_data.
    read_data(  ).
    get_data(  ).
  ENDMETHOD.

  METHOD  get_gui_event_handler.
    rif_handler = NEW /adz/cl_hmv_func_dunning( irt_out_table = get_data( )  is_selscreen = ms_selscreen ).
    rif_handler->mo_controller = me.
  ENDMETHOD.
ENDCLASS.
