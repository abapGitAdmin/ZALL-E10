*&---------------------------------------------------------------------*
*&  Include           Z_ALV_GRID_EDITABLE_CL
*&---------------------------------------------------------------------*

CLASS gcl_event_handler DEFINITION.

  PUBLIC SECTION.

    METHODS: constructor IMPORTING ir_alv_grid TYPE REF TO cl_gui_alv_grid
                                   it_sflight  TYPE flighttab.

    METHODS: add_toolbar_function FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object
                  e_interactive.

    METHODS: handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.


  PROTECTED SECTION.
    CONSTANTS: gc_new_function  TYPE ui_func VALUE 'NEW'.

    DATA: gr_cl_alv_grid    TYPE REF TO cl_gui_alv_grid.
    DATA: gr_cl_sflight     TYPE REF TO flighttab.

    METHODS: display_popup
      CHANGING ct_sflight_display TYPE flighttab.

    METHODS: get_sel_rows RETURNING VALUE(rt_sflight_lines) TYPE flighttab.

ENDCLASS.

CLASS gcl_event_handler IMPLEMENTATION.

  METHOD constructor.
*  Importingparameter klassenglobal ablegen
    gr_cl_alv_grid = ir_alv_grid.
    GET REFERENCE OF it_sflight INTO gr_cl_sflight.
  ENDMETHOD.                    "constructor

  METHOD add_toolbar_function.

    DATA: ls_toolbar_button TYPE stb_button.
* separator einfügen
    MOVE 3 TO ls_toolbar_button-butn_type.
    APPEND ls_toolbar_button TO e_object->mt_toolbar.
    CLEAR: ls_toolbar_button.
* Toolbar um eigene Funktion erweitern
    MOVE gc_new_function TO ls_toolbar_button-function.
    MOVE '@9P@'          TO ls_toolbar_button-icon. "Siehe Tabelle ICON
    MOVE 'Zeilen anzeigen' TO ls_toolbar_button-quickinfo.
    MOVE 'Zeilen anzeigen' TO ls_toolbar_button-text.
* Funktion übernehmen
    APPEND ls_toolbar_button TO e_object->mt_toolbar.
  ENDMETHOD.                    "add_toolbar_function


  METHOD handle_user_command.

    DATA: lt_sflight_lilnes   TYPE flighttab.

    CASE: e_ucomm.
      WHEN gc_new_function .
**********************************************************
*      Behandeln der neu hinzugefügten Funktion
**********************************************************
*  Führt dazu, dass Änderungen tatsächlich ins backend
*     übertragen werden ... manchmal bei der Kombination aus
*     ALV & Dynpro-Verarbeitungen notwendig
        gr_cl_alv_grid->check_changed_data( ).

*     Zu Beginn die selektierten Zeilen bestimmen
        lt_sflight_lilnes = get_sel_rows( ).

*     Und hier ist die eigentliche Anzeige
        display_popup(
        CHANGING          ct_sflight_display = lt_sflight_lilnes ).
      WHEN OTHERS.
*     Nichts tun
    ENDCASE.
  ENDMETHOD.


  METHOD get_sel_rows.
    DATA: lt_cells    TYPE lvc_t_cell.
    DATA: ls_rows     TYPE lvc_s_row.
    DATA: ls_cell     TYPE lvc_s_cell.
    DATA: lt_rows     TYPE lvc_t_row.
    DATA: ls_sflight  TYPE sflight.
* Zeilen wurden markier

    gr_cl_alv_grid->get_selected_rows(
      IMPORTING
        et_index_rows = lt_rows                 " Indizes der selektierten Zeilen
*    et_row_no     =                  " Numerische IDs der selektierten Zeilen
    ).


* in eine Zeile wurde geklickt

    IF lt_rows[] IS INITIAL.
      gr_cl_alv_grid->get_selected_cells(
      IMPORTING      et_cell = lt_cells ).

      LOOP AT lt_cells INTO ls_cell.
        MOVE ls_cell-row_id TO ls_rows-index.
        APPEND ls_rows TO lt_rows.
      ENDLOOP.
      CLEAR ls_rows.
    ENDIF.

* Und jetzt die eigentlichen Zeilen ermitteln
    LOOP AT lt_rows INTO ls_rows.
      READ TABLE gr_cl_sflight->* INTO ls_sflight
      INDEX ls_rows-index.

      APPEND ls_sflight TO rt_sflight_lines.
    ENDLOOP.
  ENDMETHOD.                    "get_sel_rows

  METHOD display_popup.
    DATA: lr_salv_popup   TYPE REF TO cl_salv_table.
    DATA: lr_err_salv     TYPE REF TO cx_salv_msg.
    DATA: lv_string       TYPE string.
    TRY.
* ALV-instanz erzeugen
        CALL METHOD cl_salv_table=>factory
          EXPORTING
            list_display = if_salv_c_bool_sap=>false
          IMPORTING
            r_salv_table = lr_salv_popup
          CHANGING
            t_table      = ct_sflight_display.
      CATCH cx_salv_msg INTO lr_err_salv.
* Fehler anzeigen
        lv_string = lr_err_salv->get_text( ).
        MESSAGE lv_string TYPE 'E'.
    ENDTRY.

* Größe des Fensters setzen
    lr_salv_popup->set_screen_popup(
             start_column = 5
                   end_column = 160
                             start_line = 5
                                       end_line = 15 ).
* Anzeige anstoßen
    lr_salv_popup->display( ).
  ENDMETHOD. "display_popup

ENDCLASS.                    "gcl_event_handler IMPLEMENTATION
