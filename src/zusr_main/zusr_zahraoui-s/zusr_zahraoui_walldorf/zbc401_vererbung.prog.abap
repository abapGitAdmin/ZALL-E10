*&---------------------------------------------------------------------*
*& Report ZBC401_VERERBUNG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_vererbung.

CLASS lcl_airplane DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING  par_name TYPE string
        EXCEPTIONS wrong_planetype,

      displayattri.

    CLASS-METHODS:
      display_an.
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
  WRITE: / 'Anzahl von der Sitze : ',mv_seatsmax.skip.
  uline.

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

DATA:
      go_airplane TYPE REF TO lcl_airplane,
      go_passager TYPE REF TO lcl_passenger,
      go_cargo TYPE REF TO cargo,
      gv_count TYPE i.


START-OF-SELECTION.

  lcl_airplane=>display_an( ).
" passager
  CREATE OBJECT go_passager

  EXPORTING
    pa_name = 'zri9a'
   " mv_seatsmax = 25
   pa_seats = 20

    EXCEPTIONS wrong_planetype = 1.

  " cargo
  CREATE OBJECT go_cargo

  EXPORTING
    pa_name = 'ferari'
   " mv_seatsmax = 25
   pa_cargo = 20

    EXCEPTIONS wrong_planetype = 1.

    go_passager->displayattri( ).
    go_cargo->displayattri( ).

    "anzahl
  "  gv_count = lcl_airplane=>display_an( ).
