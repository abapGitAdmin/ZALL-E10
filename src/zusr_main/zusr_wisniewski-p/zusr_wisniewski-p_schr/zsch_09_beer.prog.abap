*&---------------------------------------------------------------------*
*& Report ZSCH_09_BEER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_09_beer.

CLASS lcl_bier DEFINITION.
  PUBLIC SECTION.
    DATA: gd_stammwuerze    TYPE p LENGTH 3 DECIMALS 2 VALUE '12.50'.
    TYPES: gdt_alkoholgehalt TYPE p LENGTH 3 DECIMALS 2.
    METHODS: write_stammwuerze,
      brauen,
      set_aloholgehalt IMPORTING id__alkoholgehalt TYPE gdt_alkoholgehalt.
  PROTECTED SECTION.
    DATA: gd_volumen TYPE i VALUE 333.
  PRIVATE SECTION.
    DATA: gd_alkoholgehalt TYPE gdt_alkoholgehalt VALUE '4.5'.
ENDCLASS.

CLASS lcl_bier IMPLEMENTATION.
  METHOD write_stammwuerze.
    WRITE: me->gd_stammwuerze.
  ENDMETHOD.
  METHOD brauen.
    WRITE: / 'Ich braue und braue den ganzen lieben Tag'.
  ENDMETHOD.
  METHOD set_aloholgehalt.
    me->gd_alkoholgehalt = id__alkoholgehalt.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_bier_untergaerig DEFINITION
    INHERITING FROM lcl_bier.
  PUBLIC SECTION.
    METHODS: brauen REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_bier_untergaerig IMPLEMENTATION.
  METHOD brauen.
    CALL METHOD super->brauen.
    WRITE: / 'sogar untergärig'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_bier_obergaerig DEFINITION
  INHERITING FROM lcl_bier.
  PUBLIC SECTION.
    METHODS: brauen REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS lcl_bier_obergaerig IMPLEMENTATION.
  METHOD brauen.
    CALL METHOD super->brauen.
    WRITE: / 'sogar obergärig'.
  ENDMETHOD.
ENDCLASS.

DATA: gr_untergaerig TYPE REF TO lcl_bier_untergaerig,
      gr_obergaerig  TYPE REF TO lcl_bier_obergaerig,
      gr_bier        TYPE REF TO lcl_bier.


START-OF-SELECTION.
  CREATE OBJECT gr_untergaerig.
  CREATE OBJECT gr_obergaerig.
  CREATE OBJECT gr_bier.

  TRY.
      gr_obergaerig ?= gr_bier.
    CATCH cx_sy_move_cast_error.
      WRITE: 'Das ging leider in die Hose'.
  ENDTRY.
  CALL METHOD gr_untergaerig->write_stammwuerze.
  WRITE: gr_untergaerig->gd_stammwuerze.

  CALL METHOD gr_obergaerig->write_stammwuerze.
