*&---------------------------------------------------------------------*
*&  Include           /ADO/WB_DASHBOARD_F01
*&---------------------------------------------------------------------*

FORM setup_salv CHANGING co_salv_table TYPE REF TO cl_salv_table.

  DATA(lo_selections) = co_salv_table->get_selections( ).
  lo_selections->set_selection_mode( if_salv_c_selection_mode=>multiple ).

ENDFORM.
