*&---------------------------------------------------------------------*
*&  Include           Z_SEL_MODE_DBL_CLICK_SALV_CL
*&---------------------------------------------------------------------*

CLASS gcl_event_handler DEFINITION.

  PUBLIC SECTION.

    METHODS: constructor IMPORTING cr_salv    TYPE REF TO cl_salv_table
                                   it_sflight TYPE flighttab.

    METHODS: handle_double_click FOR EVENT double_click OF cl_salv_events_table
      IMPORTING row
                  column.


  PROTECTED SECTION.

    DATA: gr_salv_class    TYPE REF TO cl_salv_table.
    DATA: gt_sflight_class TYPE REF TO flighttab.


ENDCLASS.

CLASS gcl_event_handler IMPLEMENTATION.

  METHOD constructor.
*   Importparameter in globale Klassenattribute übernehmen
    gr_salv_class      = cr_salv.
    GET REFERENCE OF it_sflight INTO gt_sflight_class.
  ENDMETHOD.                    "constructor

  METHOD handle_double_click.

    CONSTANTS: lc_zero              TYPE char1 VALUE '0'.
    DATA: ls_flight                 TYPE sflight.
    DATA: lv_message                TYPE char250.
    DATA: lv_row_char               TYPE char10.
    DATA: lv_value_chart            TYPE char50.

    FIELD-SYMBOLS: <lv_any_value>   TYPE any.


*   Informationen zur geklickten Zeile lesen

    READ TABLE gt_sflight_class->* INTO ls_flight INDEX row.

    CHECK sy-subrc EQ 0.
*   Wert in Feldsymbol übernehmen
    ASSIGN COMPONENT column OF STRUCTURE ls_flight TO <lv_any_value>.

    CHECK sy-subrc EQ 0.

*   Zeilenindes für die Ausgabe in lesbarere Form übernehmen
    MOVE row TO  lv_row_char.
    SHIFT lv_row_char LEFT DELETING LEADING lc_zero.
    SHIFT lv_row_char LEFT DELETING LEADING space.
*   Inhalt als Character übernehmen, da sonst eine Konvertierung
*   nicht immer möglich ist (so z.B. bei Zahlen)

    MOVE <lv_any_value> TO lv_value_chart.
    SHIFT lv_value_chart LEFT DELETING LEADING lc_zero.
    SHIFT lv_value_chart LEFT DELETING LEADING space.

*   Nachricht vorbereiten ... auf eine Konvertierung des
*   Feldinhaltes wurde hier verzichtet
    CONCATENATE: 'Sie haben Wert' lv_value_chart
                 'in Zeile' lv_row_char 'selektiert'
    INTO lv_message SEPARATED BY space.

*   Nachricht anzeigen
    MESSAGE lv_message TYPE 'I'.

  ENDMETHOD.                    "handle_toolbar_click
ENDCLASS.                    "gcl_event_handler IMPLEMENTATI
