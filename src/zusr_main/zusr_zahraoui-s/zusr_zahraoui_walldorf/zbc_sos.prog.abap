*&---------------------------------------------------------------------*
*&  Include           ZBC_SOS
*&---------------------------------------------------------------------*
START-OF-SELECTION.
" aufruf der Daten mit selection

SELECT * FROM sflight INTO TABLE gt_flights
  WHERE carrid IN so_car
  AND  connid IN so_con.

  "üb23 frage 3 case erweitern
  CASE 'X'.
    WHEN pa_fulls or  pa_list.


" referenzanleegn zur cl_salv_table

DATA: go_alv   TYPE REF TO cl_salv_table,
     "aufg22
      go_list TYPE sap_bool,
      "aufgab23
      ok_code like sy-ucomm,
      go_co TYPE REF TO cl_salv_table,
      go_error TYPE REF TO cx_salv_error.
      " aufg 22 Entscheidung für Anzeige list

IF pa_list is NOT INITIAL.
  go_list = if_salv_c_bool_sap=>true.
  ELse.
    go_list = if_salv_c_bool_sap=>false.

ENDIF.


TRY .
    cl_salv_table=>factory(
    EXPORTING
     list_display   = go_list
     "if_salv_c_bool_sap=>false " ALV wird im Listenmodus angezeigt
*      r_container    =                           " Abstracter Container fuer GUI Controls
*      container_name =
      IMPORTING
        r_salv_table   =     go_alv                      " Basisklasse einfache ALV Tabellen
      CHANGING
        t_table        = gt_flights
    ).

  CATCH cx_salv_msg INTO go_error.





ENDTRY.

go_alv->display( ).
WHEN pa_ausg .
  call SCREEN 100.
    ENDCASE.
