*&---------------------------------------------------------------------*
*&  Include           Z_SEL_MODE_OWN_FUNCT_SALV_CL
*&---------------------------------------------------------------------*

CLASS gcl_event_handler DEFINITION.

  PUBLIC SECTION.

    METHODS: constructor IMPORTING cr_salv    TYPE REF TO cl_salv_table
                                   it_sflight TYPE flighttab.

    METHODS: handle_toolbar_click FOR EVENT added_function OF cl_salv_events_table
      IMPORTING e_salv_function.


  PROTECTED SECTION.

    DATA: gr_salv_class    TYPE REF TO cl_salv_table.
    DATA: gt_sflight_class TYPE REF TO flighttab.

    METHODS: display_popup
      CHANGING ct_sflight_display TYPE flighttab.

ENDCLASS.

CLASS gcl_event_handler IMPLEMENTATION.

  METHOD constructor.
*   Importparameter in globale Klassenattribute übernehmen
    gr_salv_class      = cr_salv.
    GET REFERENCE OF it_sflight INTO gt_sflight_class.
  ENDMETHOD.                    "constructor

  METHOD handle_toolbar_click.

    DATA: lr_selections          TYPE REF TO cl_salv_selections.
    DATA: lt_sel_rows            TYPE salv_t_row.
    DATA: lv_sel_row             TYPE int4.
    DATA: ls_sflight             TYPE sflight.
    DATA: lt_sflight_display     TYPE flighttab.

    CASE e_salv_function.
      WHEN 'NFUNC'.
*Hier behandeln wir unsere Funktion


*       Instanz des Selection-Objektes holen
        lr_selections = gr_salv_class->get_selections( ).
*       Indes der markierten Zeilen bestimmen
        lt_sel_rows = lr_selections->get_selected_rows( ).
*       Die selektierten Datensätze ermitteln
        LOOP AT lt_sel_rows INTO lv_sel_row.
*         selektierte Zeilen auslesen
          READ TABLE gt_sflight_class->* INTO ls_sflight INDEX lv_sel_row.
*         Datensatz für die Anzeige übernehmen
          APPEND ls_sflight TO lt_sflight_display.
        ENDLOOP.

*       Daten in einem separaten Pop-Up visualisieren

        display_popup(
        CHANGING   ct_sflight_display = lt_sflight_display ).
      WHEN OTHERS.
* Wenn sonst irgendwas passiert, soll keine Reaktion erfolgen

    ENDCASE.
  ENDMETHOD.                    "handle_toolbar_click

  METHOD display_popup.

    DATA: lr_salv_popup          TYPE REF TO cl_salv_table.
    DATA: lr_err_salv            TYPE REF TO cx_salv_msg.
    DATA: lv_string              TYPE string.

    TRY.
*      ALV-instanz erzeugen
        CALL METHOD cl_salv_table=>factory
          EXPORTING
            list_display = if_salv_c_bool_sap=>false
          IMPORTING
            r_salv_table = lr_salv_popup
          CHANGING
            t_table      = ct_sflight_display.
      CATCH cx_salv_msg INTO lr_err_salv.
*        Fehler anzeigen

        lv_string = lr_err_salv->get_text( ).
        MESSAGE lv_string TYPE 'E'.

    ENDTRY.
*   Größe des Fensters setzen

    lr_salv_popup->set_screen_popup(
    start_column = 5
    end_column  = 160
    start_line  = 5
    end_line    = 15 ).

*   Anzeige anstoßen
    lr_salv_popup->display( ).
  ENDMETHOD.                    "display_popup
ENDCLASS.                    "gcl_event_handler IMPLEMENTATION
