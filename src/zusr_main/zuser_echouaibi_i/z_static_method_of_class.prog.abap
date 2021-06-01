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
REPORT z_static_method_of_class.


DATA gvar_time TYPE sy-uzeit.
*----------------------------------------------------------------------*
*       CLASS cl_one DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cls_one DEFINITION.
  PUBLIC SECTION.
    DATA var_txt TYPE char40 VALUE 'SAP ABAP Object Oriented'.
    CLASS-DATA: cl_var_date TYPE sy-datum.
    CLASS-METHODS cl_methode_one.
ENDCLASS.


CLASS cls_one IMPLEMENTATION.

  METHOD cl_methode_one.

    gvar_time = sy-uzeit.

    cl_var_date = sy-datum.


    write:/ 'TODAY'' S date: ', cl_var_date,
          / 'TIME: ', gvar_time.
  ENDMETHOD.

ENDCLASS.

start-OF-SELECTION.

*data: obj type REF TO cls_one.
*create OBJECT obj.

call METHOD cls_one=>cl_methode_one.
