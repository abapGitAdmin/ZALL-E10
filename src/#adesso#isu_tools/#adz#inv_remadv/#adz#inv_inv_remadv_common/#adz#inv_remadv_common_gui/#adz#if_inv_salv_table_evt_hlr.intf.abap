INTERFACE /adz/if_inv_salv_table_evt_hlr
  PUBLIC.
  DATA mo_controller type ref to  /ADZ/IF_INV_CONTROLLER_BASIC.
  METHODS:
      on_user_command  FOR EVENT user_command of CL_GUI_ALV_GRID
         importing
           e_ucomm
           sender,
*      ,on_added_function FOR EVENT if_salv_events_functions~added_function
*         OF cl_salv_events_table
*        IMPORTING e_salv_function
      on_hotspotclick for event HOTSPOT_CLICK of cl_gui_alv_grid
         importing
           E_ROW_ID
           E_COLUMN_ID
           ES_ROW_NO
  .

ENDINTERFACE.
