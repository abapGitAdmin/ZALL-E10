************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT zbc405_alv_ub21.

DATA:
  gt_flights TYPE TABLE OF sflight,
  gs_flights TYPE sflight.

" 2 Selectionop
SELECT-OPTIONS:
so_car FOR gs_flights-carrid,
so_con FOR gs_flights-connid.

" aufruf der Daten mit selection

SELECT * FROM sflight INTO TABLE gt_flights
  WHERE carrid IN so_car
  AND  connid IN so_con.
" referenzanleegn zur cl_salv_table

DATA: go_alv   TYPE REF TO cl_salv_table,
      go_error TYPE REF TO cx_salv_error.

TRY .
    cl_salv_table=>factory(
*    EXPORTING
"      list_display   = if_salv_c_bool_sap=>false " ALV wird im Listenmodus angezeigt
*      r_container    =                           " Abstracter Container fuer GUI Controls
*      container_name =
      IMPORTING
        r_salv_table   =     go_alv                      " Basisklasse einfache ALV Tabellen
      CHANGING
        t_table        = gt_flights
    ).

  CATCH cx_salv_msg INTO go_error.

*    cl_sapbc405_exc_handler=>process_alv_error_msg(
*    EXPORTING
*      r_error = go_error ).
ENDTRY.

go_alv->display( ).
