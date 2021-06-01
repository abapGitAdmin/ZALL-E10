************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 07.06.2019
*
* Beschreibung: ALV GRID MIT ABSPRÜNGEN ZUM KLÄRFALL UND PDOC
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT zboe_emma_case NO STANDARD PAGE HEADING.

TYPES:
  BEGIN OF ts_table_alv,
    "TODO: change the rows
    casenr         TYPE emma_cnr,
    casetxt        TYPE emma_casetxt,
    status         TYPE emma_cstatus, "Status des Klärfalls WIRD aktuell nicht befüllt
    "    mainobjecttype TYPE emma_mainobjtype,
    mainobjectkey  TYPE swo_typeid,
    pdoc_status    TYPE eideswtstat,
    pdoc_statustxt TYPE eideswtstatt,
    "    complex       TYPE char1,
    alv_color      TYPE lvc_t_scol,
    "   error_text     TYPE text256,
  END OF ts_table_alv.

DATA: lr_table     TYPE REF TO cl_salv_table,
      lr_grid      TYPE REF TO cl_salv_form_layout_grid, "cl_gui_alv_grid for more-line-selection
      lr_functions TYPE REF TO cl_salv_functions_list,
      lr_columns   TYPE REF TO cl_salv_columns_table,
      lr_column    TYPE REF TO cl_salv_column_table,
      lt_table_alv TYPE TABLE OF ts_table_alv,
      ls_table_alv TYPE ts_table_alv.

DATA: lv_pdoc_status    TYPE eideswtstat,
      lv_pdoc_statustxt TYPE eideswtstatt.

***********************************************************************
* EVENT HANDLER DEFINITION
***********************************************************************
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_link_click
                    FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column. "Spalte                    "#EC NEEDED

*another Method for more than 1 line clicked
ENDCLASS.

***********************************************************************
* EVENT HANDLER FOR on_click IMPLEMENTATION incl. FUNCTION CALL
***********************************************************************
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_link_click.

    DATA: lv_switchnum TYPE eideswtnum.

    READ TABLE lt_table_alv INTO ls_table_alv INDEX row.

    IF sy-subrc = 0.
      CASE column.
        WHEN 'MAINOBJECTKEY'.
          TRY.
              lv_switchnum = CONV #( ls_table_alv-mainobjectkey ).

              CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY'
                EXPORTING
                  x_switchnum    = lv_switchnum
                EXCEPTIONS
                  general_fault  = 1
                  not_found      = 2
                  not_authorized = 3
                  OTHERS         = 4.
              IF sy-subrc <> 0.
              ENDIF.
            CATCH cx_sy_authorization_error.
              RETURN.
          ENDTRY.
        WHEN 'CASENR'.
          CALL METHOD cl_emma_case=>if_badi_emma_case~transaction_start
            EXPORTING
              iv_casenr            = ls_table_alv-casenr
              iv_wmode             = cl_emma_case_txn=>co_wmode_display
            EXCEPTIONS
              case_not_found       = 1
              incorrect_workmode   = 2
              incorrect_parameters = 3
              OTHERS               = 4.
          IF sy-subrc <> 0.
          ENDIF.
        WHEN OTHERS.
          "Do nothing.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_optimize_column DEFINITION.
  PUBLIC SECTION.
    METHODS set_column_optimize
      IMPORTING icl_alv TYPE REF TO cl_salv_table.

ENDCLASS.

CLASS lcl_optimize_column IMPLEMENTATION.
  METHOD set_column_optimize.
    DATA: lcl_columns_table TYPE REF TO cl_salv_columns_table.

    IF icl_alv IS NOT INITIAL.
      lcl_columns_table = icl_alv->get_columns( ).
      lcl_columns_table->set_optimize( abap_true ).
***make more lines clickable TODO
    ENDIF.
  ENDMETHOD.
ENDCLASS.

DATA: gr_events    TYPE REF TO lcl_handle_events.

*&---------------------------------------------------------------------*
*& Selection Screen
*&---------------------------------------------------------------------*

SELECT-OPTIONS: so_cnr FOR ls_table_alv-casenr,
                so_stat FOR ls_table_alv-status.
"TODO: more selection options
*&---------------------------------------------------------------------*
*&´Start-Of-Selection
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  DATA: lt_emma_case  TYPE TABLE OF emma_case,
        lt_eideswtdoc TYPE TABLE OF eideswtdoc.
  "more selection-options...
  "Klärfallkategorie
  "Prozess-ID
  "PDOC-Status

  SELECT * FROM emma_case WHERE emma_case~status IN @so_stat AND casenr IN @so_cnr
      INTO TABLE @lt_emma_case.

***********************************************************************
* SELECT DATA
***********************************************************************

  LOOP AT lt_emma_case ASSIGNING FIELD-SYMBOL(<ls_emma_case>).
    APPEND INITIAL LINE TO lt_table_alv ASSIGNING FIELD-SYMBOL(<ls_table_alv>).
    <ls_table_alv>-casenr         = <ls_emma_case>-casenr.
    <ls_table_alv>-status         = <ls_emma_case>-status.
    <ls_table_alv>-casetxt        = <ls_emma_case>-casetxt.
    <ls_table_alv>-mainobjectkey  = <ls_emma_case>-mainobjkey. "Rename to PDOC
    "    <ls_table_alv>-mainobjecttype = <ls_emma_case>-mainobjtype.

    "Prozessstatus-Export
    SELECT status FROM eideswtdoc INTO lv_pdoc_status WHERE switchnum = <ls_emma_case>-mainobjkey.
    ENDSELECT.
    <ls_table_alv>-pdoc_status = lv_pdoc_status.

    "ProzessstatusText-Export from the PDOC ( Tab:EIDESWTDOC Feld: STATUS -> Tab:EIDESWTSTATUST Feld:STATUSTEXT)
    SELECT statustext FROM eideswtstatust INTO lv_pdoc_statustxt WHERE status = lv_pdoc_status AND SPRAS = 'DE'.
    ENDSELECT.
    <ls_table_alv>-pdoc_statustxt =  lv_pdoc_statustxt.

  ENDLOOP.

**********************************************************************
* CREATE ALV GRID
**********************************************************************

  lr_grid = NEW #(  ).
  lr_grid->create_label( text = 'Auswertung Klärfälle.' row = 1 column = 1 ).

  cl_salv_table=>factory( IMPORTING r_salv_table = lr_table
                          CHANGING  t_table      = lt_table_alv ).

  lr_columns = lr_table->get_columns( ).
  lr_columns->set_color_column( 'ALV_COLOR' ).

  lr_functions = lr_table->get_functions( ).
  lr_functions->set_all( ).

  lr_table->set_top_of_list( lr_grid ).

  lr_column ?= lr_columns->get_column( 'MAINOBJECTKEY' ).
  lr_column->set_long_text( 'PDOC' ).
  lr_column->set_medium_text( 'PDOC' ).
  lr_column->set_short_text( 'PDOC' ).

  lr_columns = lr_table->get_columns( ).
  lr_columns->set_optimize( abap_true ).

  "TODO: make lines selectable
  "TODO: button for selecting every line

**********************************************************************
* SET HANDLER ON CREATED ALV GRID
**********************************************************************
  CREATE OBJECT gr_events.

  TRY.
      "lr_column ?= lr_columns->get_column( 'CASENR' ).
      lr_column ?= lr_columns->get_column( 'MAINOBJECTKEY' ).
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

      lr_column ?= lr_columns->get_column( 'CASENR' ).
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  DATA: lr_events TYPE REF TO cl_salv_events_table.
  lr_events = lr_table->get_event( ).

  SET HANDLER gr_events->on_link_click FOR lr_events.

**********************************************************************
* SHOW ALV GRID
**********************************************************************

  lr_table->display( ).
