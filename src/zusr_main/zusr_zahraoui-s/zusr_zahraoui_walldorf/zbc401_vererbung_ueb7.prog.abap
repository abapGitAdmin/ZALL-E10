*&---------------------------------------------------------------------*
*& Report ZBC401_VERERBUNG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_vererbung_ueb7.

CLASS lcl_airplane DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING  iv_name      TYPE string
                   iv_planetype TYPE saplane-planetype
        EXCEPTIONS wrong_planetype,
      displayattri.

    CLASS-METHODS:
      class_constructor,
      "display_n_o_airplanes
      display_an ,
      get_n_o_airplanes
        RETURNING VALUE(rv_count) TYPE i.

  PROTECTED SECTION.
    DATA: c_pos TYPE i VALUE 30.

  PRIVATE SECTION.
    TYPES:

    ty_planetypes TYPE STANDARD TABLE OF saplane
    WITH NON-UNIQUE KEY planetype.

    DATA:
      "mv_name
      mv_name      TYPE  string,
      mv_planetype TYPE saplane-planetype,
      mv_weight    TYPE saplane-weight,
      mv_tankcap   TYPE saplane-tankcap.

    CLASS-DATA:
      gv_anzahl     TYPE i,
      gt_planetypes TYPE ty_planetypes.
    CLASS-METHODS:
      "get_technical_attributes
      get_technical_attr
        IMPORTING
                   iv_type   TYPE saplane-planetype
        EXPORTING
                   ev_weight TYPE saplane-weight
                   ev_tankap TYPE saplane-tankcap
        EXCEPTIONS wrong_planetype.


ENDCLASS.
*********************************
CLASS lcl_airplane IMPLEMENTATION.
*  PUBLIC SECTION.
  METHOD class_constructor.

    SELECT * FROM saplane INTO TABLE gt_planetypes.
  ENDMETHOD.

  METHOD constructor.

    mv_name = iv_name.
    mv_planetype = iv_planetype.
    get_technical_attr(
    EXPORTING
      iv_type = iv_planetype
      IMPORTING
        ev_weight = mv_weight
        ev_tankap = mv_tankcap
         EXCEPTIONS wrong_planetype = 1 ).
    IF sy-subrc <> 0.
      RAISE wrong_planetype.
    ELSE.
      gv_anzahl = gv_anzahl + 1.

    ENDIF.

  ENDMETHOD.

  METHOD displayattri.

    WRITE:
    / icon_ws_plane AS ICON,
    / ' Name der Flugplanes : '(001), AT c_pos  mv_name,
    / 'Type der  Flugplanes : '(002), AT c_pos mv_planetype,
    / 'Gewicht '(003),                AT c_pos mv_weight
     LEFT-JUSTIFIED,
     / 'Kapcität vom Tank :'(004), AT c_pos mv_tankcap
     LEFT-JUSTIFIED.
  ENDMETHOD.

  METHOD display_an.
    SKIP.
    WRITE:
    / 'Anzahl von Der Flüge: '(ca1),
      gv_anzahl LEFT-JUSTIFIED.
  ENDMETHOD.

  METHOD get_n_o_airplanes.
    rv_count = gv_anzahl.
  ENDMETHOD.

  METHOD get_technical_attr.
    DATA: ls_planetype TYPE saplane.
    READ TABLE gt_planetypes INTO ls_planetype
    WITH TABLE KEY planetype = iv_type
    TRANSPORTING weight tankcap.
    IF sy-subrc = 0.
      ev_weight = ls_planetype-weight.
      ev_tankap = ls_planetype-tankcap.
    ELSE.
      RAISE wrong_planetype.

    ENDIF.
  ENDMETHOD.

ENDCLASS.



CLASS cargo DEFINITION INHERITING FROM lcl_airplane.
  PUBLIC SECTION.

    METHODS:
      constructor
        IMPORTING
                   iv_name      TYPE string
                   iv_planetype TYPE saplane-planetype
                   iv_cargo     TYPE s_plan_car
                   "pa_cargo TYPE scplane-cargomax

        EXCEPTIONS wrong_planetype,


      displayattri REDEFINITION.

  PRIVATE SECTION.
*  METHODs:
*  getmax_cargo returning value(rv_max_cargo) TYPE s_plan_car.

    DATA:

"mv_cargo TYPE s_plan_car.

mv_cargo TYPE s_plan_car.



ENDCLASS.
""""""""""""
"""""""""""""

CLASS cargo IMPLEMENTATION.

  METHOD constructor.
    super->constructor(

    EXPORTING
     iv_name = iv_name
    "   pa_cargo = mv_gargo
    iv_planetype = iv_planetype

      EXCEPTIONS
        wrong_planetype = 1
    ).
    IF sy-subrc <> 0.
      RAISE wrong_planetype.

    ENDIF.
    mv_cargo = iv_cargo.
  ENDMETHOD.

  METHOD displayattri.
    super->displayattri( ).
    WRITE: / 'Maximal cargo : '(005),AT c_pos mv_cargo
    LEFT-JUSTIFIED.
    ULINE.
  ENDMETHOD.
ENDCLASS.

" üb7
CLASS lcl_passenger DEFINITION INHERITING FROM lcl_airplane.
  PUBLIC SECTION.

    METHODS:
      constructor
        IMPORTING
                   iv_name      TYPE string
                   iv_planetype TYPE saplane-planetype
                   iv_seats     TYPE s_seatsmax

        EXCEPTIONS wrong_planetype,

      displayattri REDEFINITION.



  PRIVATE SECTION.

    DATA: anzahl      TYPE i,
          "üb 7 gleiche type wie saplane -seatsmax
          mv_seatsmax TYPE s_seatsmax.

ENDCLASS.

CLASS lcl_passenger IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
    EXPORTING
       iv_name = iv_name
       iv_planetype = iv_planetype
      EXCEPTIONS
        wrong_planetype = 1 ).
    IF sy-subrc <> 0.
      RAISE wrong_planetype.
    ENDIF.
    "üb7 frage 3 wie in unterklasse ist
    mv_seatsmax = iv_seats.
  ENDMETHOD.

  METHOD displayattri.
    super->displayattri( ).
    WRITE: / 'Anzahl von der Sitze : '(006),AT c_pos mv_seatsmax
    LEFT-JUSTIFIED.
    ULINE.
  ENDMETHOD.
ENDCLASS.

"Instanzenvon der Klassen instanszieren
DATA:
  go_airplane TYPE REF TO lcl_airplane,
  go_cargo    TYPE REF TO cargo,
  go_passager TYPE REF TO lcl_passenger,
  gt_plan     TYPE TABLE OF REF TO lcl_airplane,
  gv_count    TYPE i.


START-OF-SELECTION.



  lcl_airplane=>display_an( ).

  " passager
  CREATE OBJECT go_passager
    EXPORTING
      iv_name         = 'ryanair air'
      iv_planetype    = 'A310-200'
      iv_seats        = 200
    EXCEPTIONS
      wrong_planetype = 1.
  IF sy-subrc = 0.
    "ffk
  ENDIF.

  " cargo
  CREATE OBJECT go_cargo
    EXPORTING
      iv_name         = 'air maroc'
      iv_planetype    = 'DC-8-72'
      iv_cargo        = 400
    EXCEPTIONS
      wrong_planetype = 1.
  IF sy-subrc = 0.

  ENDIF.

  go_passager->displayattri( ).
  go_cargo->displayattri( ).


  "anzahl
  gv_count = lcl_airplane=>get_n_o_airplanes( ).
  SKIP 2.
  WRITE: / 'anzahl Pläne der Flüge'(ca1), gv_count.






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
