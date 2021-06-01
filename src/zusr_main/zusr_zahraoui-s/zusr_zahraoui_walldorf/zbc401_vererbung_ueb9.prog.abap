*&---------------------------------------------------------------------*
*& Report ZBC401_VERERBUNG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_vererbung_ueb9.

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

      displayattri REDEFINITION.



  PRIVATE SECTION.

    DATA:
          mv_gargo TYPE scplane-cargomax.

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
ENDCLASS.

CLASS lcl_carrier DEFINITION.

  PUBLIC SECTION.

    METHODS: constructor IMPORTING pa_name TYPE string,
      displayattributes,
      add_airplane IMPORTING
                     io_plane TYPE REF TO lcl_airplane.


  PRIVATE SECTION.
    "-----------------------------------
    DATA: mv_name     TYPE string,
          mt_airplane TYPE TABLE OF REF TO lcl_airplane.
    methods:
    display_airplanes.

ENDCLASS. "lcl_carrier DEFINITION
*---------------------------------------------------------------------*
* CLASS lcl_carrier IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_carrier IMPLEMENTATION.

  METHOD add_airplane.
    APPEND io_plane TO mt_airplane.

  ENDMETHOD. "add_airplane


  METHOD displayattributes.

    DATA: highest_cargo TYPE s_plan_car.
    WRITE: icon_flight AS ICON, mv_name . ULINE. ULINE.
    display_airplanes( ).
     me->display_airplanes( ).
 "   WRITE: / ' Highest Cargo = ', highest_cargo.

  ENDMETHOD. "display_attributes

  METHOD display_airplanes.
    DATA: lo_plane TYPE REF TO lcl_airplane.
    LOOP AT mt_airplane INTO lo_plane.

      lo_plane->displayattri( ).

    ENDLOOP.
  ENDMETHOD. "display_airplanes

  METHOD constructor.

    mv_name = pa_name.

  ENDMETHOD. "constructor



ENDCLASS.


DATA:
  go_airplane TYPE REF TO lcl_airplane,
  go_passager TYPE REF TO lcl_passenger,
  go_cargo    TYPE REF TO cargo,
  gt_plan     TYPE TABLE OF REF TO lcl_airplane,
  go_carrier  TYPE REF TO lcl_carrier,

  gv_count    TYPE i.


START-OF-SELECTION.

create OBJECT go_carrier
exporting
  pa_name = 'Safari maroc '.


create OBJECT go_cargo

EXPORTING
  pa_name = 'Deutsche Fracht'
  pa_cargo = 20.

  lcl_airplane=>display_an( ).
  " passager
  CREATE OBJECT go_passager
    EXPORTING
      pa_name         = 'zri9a'
    " mv_seatsmax     = 25
      pa_seats        = 20
    EXCEPTIONS
      wrong_planetype = 1.
  go_carrier->add_airplane( go_cargo ).
    go_carrier->displayattributes( ).

  APPEND go_passager TO gt_plan.

  " cargo
  CREATE OBJECT go_cargo
    EXPORTING
      pa_name         = 'ferari'
    " mv_seatsmax     = 25
      pa_cargo        = 20
    EXCEPTIONS
      wrong_planetype = 1.

  APPEND go_cargo TO gt_plan.
  " go_passager->displayattri( ).
  "go_cargo->displayattri( ).

  LOOP AT gt_plan INTO go_airplane.
    go_airplane->displayattri( ).

  ENDLOOP.

  "anzahl
  gv_count = lcl_airplane=>display_an( ).

*CLASS lc_carrier DEFINITION.
*  PUBLIC SECTION.
*    METHODS:
*      constructor
*
*        IMPORTING pa_name TYPE string,
*      displayattri,
*      add_airplane
*        IMPORTING io_plane TYPE REF TO lcl_airplane.
*  PRIVATE SECTION.
*    DATA: mt_airplanes TYPE TABLE OF REF TO  lcl_airplane,
*          mv_name      TYPE string.
*
*    METHODS:
*      display_airplanes.
*
*ENDCLASS.
*CLASS lc_carrier IMPLEMENTATION.
*
*  METHOD constructor.
*    mv_name = pa_name.
*  ENDMETHOD.
*  METHOD displayattri.
*    SKIP 2.
*    WRITE:/ 'Name: ' , mv_name.
*    ULINE.
*    me->display_airplanes( ).
*
*  ENDMETHOD.
*
*  METHOD add_airplane.
*
*    APPEND io_plane TO mt_airplanes.
*
*  ENDMETHOD.
*  METHOD display_airplanes.
*    DATA: lo_plane TYPE REF TO lcl_airplane.
*    LOOP AT mt_airplanes INTO lo_plane.
*      lo_plane->displayattri( ).
*
*    ENDLOOP.
*  ENDMETHOD.
*
*ENDCLASS.
