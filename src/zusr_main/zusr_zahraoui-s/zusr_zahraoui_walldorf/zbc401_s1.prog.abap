*&---------------------------------------------------------------------*
*& Report ZBC401_S1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_s1.


CLASS lcl_airplane DEFINITION.
  PUBLIC SECTION.

    METHODS:
      constructor
        IMPORTING
          iv_name   TYPE string
          iv_pltype TYPE saplane-planetype

        EXCEPTIONS
          wrong_planetype,

      display_attributes.

    CLASS-METHODS:
      display_no,
      get_nummer RETURNING VALUE(rv_count) TYPE i.


  PRIVATE SECTION.

    TYPES ty_planetypes TYPE STANDARD TABLE OF saplane
    WITH NON-UNIQUE KEY planetype.

    DATA:
      mv_name      TYPE  string,
      mv_planetype TYPE  saplane-planetype,
      gv_no        TYPE i,
      mv_wiege     TYPE saplane-weight,
      mv_tankcap   TYPE saplane-tankcap.

    CLASS-DATA:
      gt_planetypes TYPE ty_planetypes,
      gv_nummer     TYPE i.

    CLASS-METHODS:

      get_teck_ttr
        IMPORTING
          iv_type   TYPE saplane-planetype
        EXPORTING
          ev_weight TYPE saplane-weight
          ev_tank   TYPE  saplane-tankcap
        EXCEPTIONS
          wrong_planetype.

ENDCLASS.
CLASS lcl_airplane IMPLEMENTATION.

  METHOD constructor.
*    DATA: ls_plane TYPE saplane.

    mv_name = iv_name.
    mv_planetype =  iv_pltype.
*

*select single *
*  from saplane INTO ls_plane
*
*  where planetype = iv_pltype.


    get_teck_ttr(
     EXPORTING
       iv_type = iv_pltype
      IMPORTING
         ev_weight = mv_wiege
         ev_tank =  mv_tankcap
         EXCEPTIONS
           wrong_planetype = 1 ).
    IF sy-subrc <> 0
     .
      RAISE wrong_planetype.
    ELSE.
      gv_no = gv_no + 1.


    ENDIF.
  ENDMETHOD.

  METHOD display_attributes.
    WRITE: / 'Name von der Fluggeselschaft : ', mv_name,
           / 'Type von der Flüge : ' , mv_planetype.
  ENDMETHOD.

  METHOD display_no.
    WRITE: / 'Anzahl von der flüge : ' , gv_nummer.
  ENDMETHOD.

  METHOD  get_teck_ttr.

    DATA ls_planetype TYPE saplane.

    READ TABLE gt_planetypes INTO ls_planetype
                WITH TABLE KEY planetype = iv_type
                TRANSPORTING weight tankcap.
    IF sy-subrc <> 0
     .
      ev_weight = ls_planetype-weight.
      ev_tank = ls_planetype-tankcap.
    ELSE.
      RAISE wrong_planetype.
    ENDIF.
  ENDMETHOD.



  METHOD get_nummer.

    rv_count = gv_nummer.

  ENDMETHOD.

ENDCLASS.

DATA:
  go_lcl_air TYPE REF TO lcl_airplane,
  gt_lcl     TYPE TABLE OF REF TO lcl_airplane,
  gv_count   TYPE i.


START-OF-SELECTION.

  lcl_airplane=>display_no( ).

  CREATE OBJECT go_lcl_air
    EXPORTING
      iv_name         = 'AIr Berlin'
      iv_pltype       = '740'
    EXCEPTIONS
      wrong_planetype = 1.
  IF sy-subrc = 0.
    APPEND go_lcl_air TO gt_lcl.

  ENDIF.


  CREATE OBJECT go_lcl_air
    EXPORTING
      iv_name         = 'AIr Maroc'
      iv_pltype       = '744'
    EXCEPTIONS
      wrong_planetype = 1.
  IF sy-subrc = 0.
    APPEND go_lcl_air TO gt_lcl.

  ENDIF.


  CREATE OBJECT go_lcl_air
    EXPORTING
      iv_name         = 'AIr france'
      iv_pltype       = '780'
    EXCEPTIONS
      wrong_planetype = 1.
  IF sy-subrc = 0.
    APPEND go_lcl_air TO gt_lcl.

  ENDIF.



  LOOP AT gt_lcl INTO go_lcl_air.
    go_lcl_air->display_attributes( ).
  ENDLOOP.

  gv_count = lcl_airplane=>get_nummer( ).

  SKIP.
  WRITE: / 'anzehl der Flüge: ', gv_count.
