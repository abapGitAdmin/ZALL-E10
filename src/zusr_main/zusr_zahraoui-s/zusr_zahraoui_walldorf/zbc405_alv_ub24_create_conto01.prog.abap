*----------------------------------------------------------------------*
***INCLUDE ZBC405_ALV_UB24_CREATE_CONTO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CREATE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE create_control OUTPUT.
 " aufga24
  IF go_container IS NOT BOUND.
    CREATE OBJECT go_container
      EXPORTING
*       parent         =
        container_name = 'MY_CONTROL_AREA'
*       style          =
*       lifetime       = lifetime_default
*       repid          =
*       dynnr          =
*       no_autodef_progid_dynnr     =
      EXCEPTIONS
*       cntl_error     = 1
*       cntl_system_error           = 2
*       create_error   = 3
*       lifetime_error = 4
*       lifetime_dynpro_dynpro_link = 5
        OTHERS         = 1.
    IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      MESSAGE a015(bc405).
    ENDIF.



  ENDIF.
  " Alv erzeugen und link zu container control durch try und cl_salv_table
TRY.
  cl_salv_table=>factory(
    EXPORTING
*      list_display   = if_salv_c_bool_sap=>false " ALV wird im Listenmodus angezeigt
      r_container    =    go_container                       " Abstracter Container fuer GUI Controls
*      container_name =
   IMPORTING
      r_salv_table   = go_alv                        " Basisklasse einfache ALV Tabellen
    CHANGING
      t_table        = gt_flights
  ).
CATCH cx_salv_msg INTO go_error.
  ENDTRY.

  go_alv->display( ).
ENDMODULE.
