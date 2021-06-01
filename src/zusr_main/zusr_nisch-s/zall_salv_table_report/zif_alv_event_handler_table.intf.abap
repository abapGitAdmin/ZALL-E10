INTERFACE zif_alv_event_handler_table
  PUBLIC .


  INTERFACES zif_alv_event_handler .

  ALIASES handle_added_function
    FOR zif_alv_event_handler~handle_added_function .
  ALIASES handle_after_salv_function
    FOR zif_alv_event_handler~handle_after_salv_function .
  ALIASES handle_before_salv_function
    FOR zif_alv_event_handler~handle_before_salv_function .
  ALIASES handle_end_of_page
    FOR zif_alv_event_handler~handle_end_of_page .
  ALIASES handle_top_of_page
    FOR zif_alv_event_handler~handle_top_of_page .

  DATA ao_salv_table TYPE REF TO cl_salv_table READ-ONLY .
  DATA ar_table TYPE REF TO data READ-ONLY .

  METHODS handle_double_click DEFAULT IGNORE
        FOR EVENT double_click OF if_salv_events_actions_table
    IMPORTING
        !row
        !column .
  METHODS handle_link_click DEFAULT IGNORE
        FOR EVENT link_click OF if_salv_events_actions_table
    IMPORTING
        !row
        !column .
  METHODS set_table
    IMPORTING
      !io_salv_table TYPE REF TO cl_salv_table
      !ir_table      TYPE REF TO data .
ENDINTERFACE.
