*&---------------------------------------------------------------------*
*& Report ZBC401_VERERBUNG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_vererbung_ueb8.

"CONSTANTS ca1.

CLASS lcl_airplane DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
                   iv_name      TYPE string
                   iv_planetype TYPE saplane-planetype
        EXCEPTIONS wrong_planetype,

      displayattributes.

    CLASS-METHODS:
      class_constructor,
      displa_no,
      get_no_airplanes RETURNING VALUE(rv_count) TYPE i.

  PROTECTED SECTION.
    CONSTANTS: c_pos TYPE i VALUE 30.

  PRIVATE SECTION.
    TYPES:

    ty_planetypes TYPE STANDARD TABLE OF saplane
    WITH NON-UNIQUE KEY planetype.

    DATA:
      mv_name      TYPE  string,
      mv_planetype TYPE saplane-planetype,
      mv_weight    TYPE saplane-weight,
      mv_tankcap   TYPE saplane-tankcap.

    CLASS-DATA:
      gv_no_airplanes TYPE i,
      gt_planetypes   TYPE ty_planetypes.
    CLASS-METHODS:
      get_technical_attributes
        IMPORTING
          iv_type    TYPE saplane-planetype
        EXPORTING
          ev_weight  TYPE saplane-weight
          ev_tankcap TYPE saplane-tankcap
        EXCEPTIONS
          wrong_planetype.
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

    get_technical_attributes(
      EXPORTING
        iv_type         = iv_planetype
      IMPORTING
        ev_weight       = mv_weight
        ev_tankcap      = mv_tankcap
      EXCEPTIONS
        wrong_planetype = 1 ).
*    others          = 2

    IF sy-subrc <> 0.
      RAISE wrong_planetype.
    ELSE.
      gv_no_airplanes = gv_no_airplanes + 1.
    ENDIF.
  ENDMETHOD.

  METHOD displayattributes.

    WRITE :
            / icon_ws_plane AS ICON,
            / ' Name von der Flugsplan '(001), AT c_pos mv_name,
            / ' Type von der Flugsplan '(002), AT c_pos mv_planetype,
            / ' Gewicht von der Flugsplan '(003), AT c_pos mv_weight
            LEFT-JUSTIFIED,
            / ' Kpacität von dem Tank '(004), AT c_pos mv_tankcap
            LEFT-JUSTIFIED.

  ENDMETHOD.

  METHOD displa_no.
    SKIP.
    WRITE:
     /'anzahl : ' ,
     AT c_pos  gv_no_airplanes LEFT-JUSTIFIED.
  ENDMETHOD.
  METHOD get_no_airplanes.
    rv_count = gv_no_airplanes.
  ENDMETHOD.

      METHOD get_technical_attributes.
    DATA:
          ls_planetype TYPE saplane.
    READ TABLE gt_planetypes INTO ls_planetype
    WITH TABLE KEY planetype = iv_type
    TRANSPORTING weight tankcap.
    IF sy-subrc = 0.
      ev_weight = ls_planetype-weight.
      ev_tankcap = ls_planetype-tankcap.
    ELSE.
      RAISE wrong_planetype.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
""""
CLASS cargo DEFINITION INHERITING FROM lcl_airplane.
  PUBLIC SECTION.

    METHODS:
      constructor
        IMPORTING
                   iv_name      TYPE string
                   iv_planetype TYPE saplane-planetype
                   iv_cargo     TYPE s_plan_car
       EXCEPTIONS wrong_planetype,

      displayattributes REDEFINITION.
  PRIVATE SECTION.
    DATA:
    mv_cargo TYPE s_plan_car.

ENDCLASS.
""""""""""""
"""""""""""""

CLASS cargo IMPLEMENTATION.

  METHOD constructor.
    super->constructor(

    EXPORTING
       iv_name = iv_name
       iv_planetype = iv_planetype
    "   pa_cargo = mv_gargo
      EXCEPTIONS
        wrong_planetype = 1 ).
    IF sy-subrc <> 0.
      RAISE wrong_planetype.
    ENDIF.
    mv_cargo = iv_cargo.

  ENDMETHOD.

  METHOD displayattributes.
    super->displayattributes( ).
    WRITE: / 'Maximal cargo : '(005), AT c_pos  mv_cargo LEFT-JUSTIFIED.
    ULINE.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_passenger DEFINITION INHERITING FROM lcl_airplane.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
                   iv_name      TYPE string
                   iv_planetype TYPE saplane-planetype
                   iv_seats     TYPE s_seatsmax

        EXCEPTIONS wrong_planetype,

      displayattributes REDEFINITION.
  PRIVATE SECTION.
    DATA:
          "anzahl      TYPE i,
          mv_seats TYPE s_seatsmax.

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
    mv_seats = iv_seats.
  ENDMETHOD.

  METHOD displayattributes.
    super->displayattributes( ).
    WRITE: / 'Anzahl von der Sitze : '(006), at c_pos mv_seats
    LEFT-JUSTIFIED.
    ULINE.
  ENDMETHOD.
ENDCLASS.

DATA:
  go_airplane TYPE REF TO lcl_airplane,
  go_cargo    TYPE REF TO cargo,
  go_passager TYPE REF TO lcl_passenger,
  gt_airplanes TYPE TABLE OF REF TO lcl_airplane,
  gv_count    TYPE i.


START-OF-SELECTION.

  lcl_airplane=>displa_no( ).
  " passager
  CREATE OBJECT go_passager
    EXPORTING
      iv_name         = 'zri9a'
      iv_planetype    = 'A310-200'
      iv_seats        = 20
    EXCEPTIONS
      wrong_planetype = 1.
  " üb8 APPEND go_passager TO gt_plan.
  IF sy-subrc = 0.
    APPEND go_passager TO gt_airplanes.
      ENDIF.
  " cargo
  CREATE OBJECT go_cargo
    EXPORTING
      iv_name         = 'ferari'
      iv_planetype    = 'DC-8-72'
      iv_cargo       = 20
    EXCEPTIONS
      wrong_planetype = 1.
  IF sy-subrc = 0.
     APPEND go_cargo TO gt_airplanes.
  ENDIF.

  "APPEND go_cargo TO gt_plan.
*  go_passager->displayattributes( ).
*  go_cargo->displayattributes( ).
  "üb8
  LOOP AT gt_airplanes INTO go_airplane.
    go_airplane->displayattributes( ).

  ENDLOOP.

  "anzahl
  gv_count = lcl_airplane=>get_no_airplanes( ).
  SKIP 2.
  WRITE: / 'Anzahl von Flüge'(ca1), gv_count.
