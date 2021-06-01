CLASS zcl_klassentest1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES gdt_alkoholgehalt TYPE p LENGTH 3 DECIMALS 2.
    DATA:
      gd_stammwuerze TYPE p LENGTH 3 DECIMALS 2 VALUE '12.50' ##NO_TEXT.

    CLASS-METHODS class_constructor .
    METHODS: write_stammwuerze ,
      set_alkoholgehalt IMPORTING id_alkoholgehalt TYPE gdt_alkoholgehalt.
  PROTECTED SECTION.
    DATA: sgd_volumen TYPE i VALUE 333.
  PRIVATE SECTION.
    DATA gd_alkoholgehalt TYPE gdt_alkoholgehalt.
ENDCLASS.



CLASS ZCL_KLASSENTEST1 IMPLEMENTATION.


  METHOD class_constructor.
*
  ENDMETHOD.


  METHOD set_alkoholgehalt.
    gd_alkoholgehalt = id_alkoholgehalt.
  ENDMETHOD.


  METHOD write_stammwuerze.
    WRITE: me->gd_stammwuerze.
  ENDMETHOD.
ENDCLASS.
