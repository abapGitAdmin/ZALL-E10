*&---------------------------------------------------------------------*
*&  Include           ZBC401_01_CARRIER
*&---------------------------------------------------------------------*

CLASS lcl_airplane DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING  par_name TYPE string
        EXCEPTIONS wrong_planetype,

      displayattri.

    CLASS-METHODS:
      display_an RETURNING VALUE(rv_count) TYPE i.
  PROTECTED SECTION.
    DATA: c_pos TYPE i VALUE 30.

  PRIVATE SECTION.
    TYPES:

    ty_planetypes TYPE STANDARD TABLE OF saplane
    WITH NON-UNIQUE KEY planetype.

    DATA:
          pa_name TYPE  string.

    CLASS-DATA:
    gv_anzahl TYPE i.

ENDCLASS.
*********************************
CLASS lcl_airplane IMPLEMENTATION.
*  PUBLIC SECTION.
  METHOD constructor.

    pa_name = par_name.

  ENDMETHOD.

  METHOD displayattri.

    WRITE :/ ' Name ', pa_name.

  ENDMETHOD.
*    EXPORT pa_name = par_name
*    exceptions =
*   endmethod.
  METHOD display_an.

    WRITE: /'anzahl : ' , gv_anzahl.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_passenger DEFINITION INHERITING FROM lcl_airplane.
  PUBLIC SECTION.

    METHODS:
      constructor
        IMPORTING
                   pa_name  TYPE string
                   pa_seats TYPE s_seatsmax

        EXCEPTIONS wrong_planetype,

      displayattri REDEFINITION,
      lc_anzahl.


  PRIVATE SECTION.

    DATA: anzahl      TYPE i,
          mv_seatsmax TYPE saplane-seatsmax.

ENDCLASS.



CLASS lcl_passenger IMPLEMENTATION.
  METHOD constructor.
    super->constructor(

    EXPORTING
       par_name = pa_name
      EXCEPTIONS
        wrong_planetype = 1
    ).

  ENDMETHOD.

  METHOD displayattri.
    super->displayattri( ).
    WRITE: / 'Anzahl von der Sitze : ',mv_seatsmax.SKIP.
    ULINE.

  ENDMETHOD.
  METHOD lc_anzahl.
    anzahl = anzahl + 1.
  ENDMETHOD.



ENDCLASS.
CLASS cargo DEFINITION INHERITING FROM lcl_airplane.
  PUBLIC SECTION.

    METHODS:
      constructor
        IMPORTING
                   pa_name  TYPE string
                   pa_cargo TYPE scplane-cargomax


        EXCEPTIONS wrong_planetype,
      getcargo RETURNING VALUE(rv_cargo) TYPE s_plan_car,

      displayattri REDEFINITION.



  PRIVATE SECTION.
*  METHODs:
*  getmax_cargo returning value(rv_max_cargo) TYPE s_plan_car.

    DATA:
      mv_gargo TYPE scplane-cargomax,
      mv_cargo TYPE s_plan_car,
      rv_count TYPE i.


ENDCLASS.
""""""""""""
"""""""""""""

CLASS cargo IMPLEMENTATION.

  METHOD constructor.
    super->constructor(

    EXPORTING
       par_name = pa_name
    "   pa_cargo = mv_gargo

      EXCEPTIONS
        wrong_planetype = 1
    ).
    mv_gargo = pa_cargo.

  ENDMETHOD.

  METHOD displayattri.
    super->displayattri( ).
    WRITE: / 'Maximal cargo : ', mv_gargo.


  ENDMETHOD.
  METHOD  getcargo.

    rv_cargo = mv_cargo.

  ENDMETHOD.
ENDCLASS.

CLASS lcl_carrier DEFINITION.

  PUBLIC SECTION.
INTERFACEs:
lif_partner.

    METHODS: constructor IMPORTING pa_name TYPE string,
      displayattributes,
      add_airplane IMPORTING
                     io_plane TYPE REF TO lcl_airplane.


  PRIVATE SECTION.
    "-----------------------------------
    DATA: mv_name     TYPE string,
          mt_airplane TYPE TABLE OF REF TO lcl_airplane.
    METHODS:
      display_airplanes.
   "   getmax_cargo RETURNING VALUE(rv_max_cargo) TYPE  s_plan_car.



*---------------------------------------------------------------------*
* CLASS lcl_carrier IMPLEMENTATION
*---------------------------------------------------------------------*

ENDCLASS.

CLASS lcl_carrier IMPLEMENTATION.


  METHOD constructor.

    mv_name = pa_name.

  ENDMETHOD. "constructor

  METHOD add_airplane.
    APPEND io_plane TO mt_airplane.

  ENDMETHOD. "add_airplane


  METHOD displayattributes.

   "_ DATA: highest_cargo TYPE s_plan_car.
    WRITE: icon_flight AS ICON, mv_name . ULINE. ULINE.
  "   display_airplanes( ).
    me->display_airplanes( ).
    "   WRITE: / ' Highest Cargo = ', highest_cargo.

  ENDMETHOD. "display_attributes

  METHOD display_airplanes.
    DATA: lo_plane TYPE REF TO lcl_airplane.
    LOOP AT mt_airplane INTO lo_plane.

      lo_plane->displayattri( ).

    ENDLOOP.
  ENDMETHOD. "display_airplanes


*  METHOD getmax_cargo
*  .
*    DATA: lo_plane TYPE REF TO lcl_airplane,
*          lo_cargo TYPE REF TO cargo.
*
*    LOOP AT mt_airplane INTO lo_plane.
*      lo_cargo ?= lo_plane.
*      IF rv_max_cargo < lo_cargo->getcargo( ).
*        rv_max_cargo = lo_cargo->getcargo( ).
*
*      ENDIF.
*
*    ENDLOOP.
*  ENDMETHOD.

  METHOD lif_partner~display_partner.
    me->displayattributes( ).
  ENDMETHOD.
ENDCLASS.
