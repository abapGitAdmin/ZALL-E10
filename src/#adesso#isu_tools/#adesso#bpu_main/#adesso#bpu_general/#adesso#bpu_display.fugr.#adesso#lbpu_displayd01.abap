*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LBPU_DISPLAYD01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class lcl_gui_alv_event_receiver
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
*CLASS lcl_gui_alv_event_receiver DEFINITION.
*  PUBLIC SECTION.
*    METHODS:
*      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
*        IMPORTING e_row_id e_column_id es_row_no.
*ENDCLASS.
*CLASS lcl_gui_alv_event_receiver IMPLEMENTATION.
*
*  METHOD handle_hotspot_click .
*    DATA: l_mess   TYPE string,
*          l_row(2) TYPE c.
*
*    WRITE es_row_no-row_id TO l_row.
*    CONCATENATE 'Hotspot click at: ' e_column_id-fieldname 'in'
*                                     l_row 'row.'
*                                     INTO l_mess SEPARATED BY space.
*    MESSAGE l_mess TYPE 'I'.
*  ENDMETHOD .
*ENDCLASS.
