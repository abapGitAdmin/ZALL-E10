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
REPORT z_mvc.

DATA : lv_vbeln TYPE vbap-vbeln.

*Create selection screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
PARAMETERS : p_werks TYPE vbap-werks OBLIGATORY.
SELECT-OPTIONS : s_vbeln1 FOR lv_vbeln .
SELECTION-SCREEN END OF BLOCK b1 .

*create selection screen class
CLASS cl_sel DEFINITION FINAL .
  PUBLIC SECTION .
    TYPES: t_vbeln  TYPE RANGE OF vbeln .
    DATA : s_vbeln TYPE t_vbeln .
    DATA : s_werks TYPE werks_ext  .
* Method to get the screen data
    METHODS : get_screen IMPORTING lp_werks TYPE werks_ext
                                   ls_vbeln TYPE t_vbeln .
ENDCLASS .                    "CL_SEL DEFINITION
*&---------------------------------------------------------------------*
*&       CLASS (IMPLEMENTATION)  SEL
*&---------------------------------------------------------------------*
*        TEXT
*----------------------------------------------------------------------*
CLASS cl_sel IMPLEMENTATION.
*  Method implementation for screen
  METHOD get_screen .
    me->s_werks = lp_werks.
    me->s_vbeln = ls_vbeln[] .
  ENDMETHOD .                    "GET_SCREEN
ENDCLASS.               "SEL
*----------------------------------------------------------------------*
*       CLASS CL_FETCH DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_fetch DEFINITION .
  PUBLIC SECTION.
    DATA : it_vbap TYPE STANDARD TABLE OF vbap .
    DATA : sel_obj TYPE REF TO cl_sel .
*  GET_SEL method to get the object of screen class
    METHODS : get_sel.
*  After getting selection screen call method Fetch data
    METHODS : fetch_data .
ENDCLASS .                    "CL_FETCH DEFINITION

*----------------------------------------------------------------------*
*       CLASS CL_FETCH IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_fetch IMPLEMENTATION .
  METHOD get_sel.
* create object of selection class
    CREATE OBJECT sel_obj.
  ENDMETHOD.
  METHOD fetch_data .
* Fetch the data from selection screen
    IF sel_obj IS BOUND .
      SELECT * FROM vbap INTO TABLE me->it_vbap UP TO 10 ROWS
      WHERE vbeln IN me->sel_obj->s_vbeln
      AND werks EQ me->sel_obj->s_werks .
    ENDIF .
  ENDMETHOD .                    "FETCH_DATA
ENDCLASS .                    "CL_FETCH IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS CL_CONTROLLER DEFINITION
*----------------------------------------------------------------------*
* controller class to get the data from MODEL
*----------------------------------------------------------------------*
CLASS cl_controller DEFINITION.
  PUBLIC SECTION.
    DATA    : obj_model TYPE REF TO cl_fetch .
*   GET_OBJECT method to get object of model
    METHODS : get_object IMPORTING gen_name TYPE char30.
ENDCLASS .                    "CL_CONTROLLER DEFINITION

*----------------------------------------------------------------------*
*       CLASS CL_CONTROLLER IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_controller IMPLEMENTATION .
  METHOD get_object.
    DATA : lv_object TYPE REF TO object.
*  GEN_NAME is of type CHAR30
    CREATE OBJECT lv_object TYPE (gen_name).
    IF sy-subrc EQ 0.
      obj_model ?= lv_object .
    ENDIF.
  ENDMETHOD .                    "GET_OBJECT
ENDCLASS .                    "CL_CONTROLLER IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS CL_ALV DEFINITION
*----------------------------------------------------------------------*
*CL_ALV class our VIEW
*----------------------------------------------------------------------*
CLASS cl_alv DEFINITION .
  PUBLIC SECTION .
    METHODS : display_alv IMPORTING con_obj TYPE REF TO cl_controller.
ENDCLASS .                    "CL_ALV DEFINITION

*----------------------------------------------------------------------*
*       CLASS CL_ALV IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_alv IMPLEMENTATION.
  METHOD display_alv .
    DATA: lx_msg TYPE REF TO cx_salv_msg.
    DATA: o_alv TYPE REF TO cl_salv_table.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      =  con_obj->obj_model->it_vbap ).
      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.
    o_alv->display( ).

  ENDMETHOD.                    "DISPLAY_ALV
ENDCLASS.                    "CL_ALV IMPLEMENTATION

DATA: o_display TYPE REF TO cl_alv .
DATA: o_con     TYPE REF TO cl_controller .

INITIALIZATION .
*Creating object of CL_ALV(View class) and CL_CONTROLLER(controller class).
  CREATE OBJECT : o_display ,o_con.

START-OF-SELECTION.
*call the method GET_OBJECT to get the object of CL_FETCH(model class)
  CALL METHOD o_con->get_object
    EXPORTING
      gen_name = 'CL_FETCH'.

* GET_SEL method of class CL_FETCH to get the object of CL_SEL class
  CALL METHOD o_con->obj_model->get_sel .
* Once we have the obejct of CL_SEL we can call its method GET_SCREEN
*to get the selection screen
  CALL METHOD o_con->obj_model->sel_obj->get_screen(
    EXPORTING
      lp_werks = p_werks
      ls_vbeln = s_vbeln1[] ).
*Finally we can call FETCH_DATA method and pass our data to controller
  CALL METHOD o_con->obj_model->fetch_data.
*The controller  will turn pass the data CL_ALV our VIEW class.
END-OF-SELECTION .
*Display data
  CALL METHOD o_display->display_alv
    EXPORTING
      con_obj = o_con.
