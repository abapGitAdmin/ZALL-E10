INTERFACE zif_alv_event_handler
  PUBLIC.

  METHODS handle_top_of_page DEFAULT IGNORE
        FOR EVENT top_of_page OF if_salv_events_list
    IMPORTING
        !r_top_of_page
        !page
        !table_index.
  METHODS handle_end_of_page DEFAULT IGNORE
        FOR EVENT end_of_page OF if_salv_events_list
    IMPORTING
        !r_end_of_page
        !page .
  METHODS handle_before_salv_function
        FOR EVENT before_salv_function OF if_salv_events_functions
    IMPORTING
        !e_salv_function.
  METHODS handle_added_function DEFAULT IGNORE
        FOR EVENT added_function OF if_salv_events_functions
    IMPORTING
        !e_salv_function.
  METHODS handle_after_salv_function DEFAULT IGNORE
        FOR EVENT after_salv_function OF if_salv_events_functions
    IMPORTING
        !e_salv_function.

ENDINTERFACE.
