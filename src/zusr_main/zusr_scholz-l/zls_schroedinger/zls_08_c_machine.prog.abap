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
REPORT zls_08_c_machine.

**********************************************************************
**********************************************************************
* Wasserbehälter
**********************************************************************
CLASS lcl_wasserbehaelter DEFINITION.
  PUBLIC SECTION.
    METHODS: get_wasserstand
      RETURNING VALUE(rd_wasserstand) TYPE i,
      set_wasserstand
        IMPORTING id_wasserstand TYPE i,
      check_wasser_haerte.

    CONSTANTS: gc_wasser_haerte_grenze TYPE f VALUE '14.0'.
  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA: kalkgehalt      TYPE i,
          gd_wasserstand  TYPE i,
          gd_wasserhaerte TYPE f.

ENDCLASS.

CLASS lcl_wasserbehaelter IMPLEMENTATION.
  METHOD get_wasserstand.
    rd_wasserstand = me->gd_wasserstand.
  ENDMETHOD.

  METHOD set_wasserstand.
    me->gd_wasserstand = id_wasserstand.
  ENDMETHOD.

  METHOD check_wasser_haerte.
    IF me->gd_wasserhaerte > gc_wasser_haerte_grenze.
      MESSAGE 'AU, das tut weh!' TYPE 'I'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

**********************************************************************
**********************************************************************
* K A F F E E V O L L A U T O M A T
**********************************************************************
CLASS lcl_kaffeevollautomat DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: anz_kva TYPE i.

    METHODS: constructor,
      ein_kaffee_bitte
        IMPORTING
          VALUE(id_espresso)      TYPE abap_bool OPTIONAL
          VALUE(id_verlaengerter) TYPE abap_bool OPTIONAL,
      bohne_nachfuellen
        IMPORTING ir_bohne TYPE REF TO zls_gcl_sch_08_cbean,
      on_loaded
        FOR EVENT loaded
        OF zls_gcl_sch_08_cbean_box.

    CLASS-METHODS add_1_to_anz_kva.

  PRIVATE SECTION.
    DATA: gd_wasserstand     TYPE i,
          gr_wasserbehaelter TYPE REF TO lcl_wasserbehaelter,
          gr_bohnenbehaelter TYPE REF TO zls_gcl_sch_08_cbean_box.
ENDCLASS.

CLASS lcl_kaffeevollautomat IMPLEMENTATION.
  METHOD constructor.
    CALL METHOD me->add_1_to_anz_kva.

    CREATE OBJECT me->gr_wasserbehaelter.

    me->gr_wasserbehaelter->set_wasserstand( id_wasserstand = 1000 ).

    CREATE OBJECT me->gr_bohnenbehaelter.

    SET HANDLER me->on_loaded
      FOR me->gr_bohnenbehaelter.
  ENDMETHOD.

  METHOD ein_kaffee_bitte.

  ENDMETHOD.

  METHOD add_1_to_anz_kva.
    anz_kva = anz_kva + 1.
  ENDMETHOD.

  METHOD bohne_nachfuellen.
    me->gr_bohnenbehaelter->add_bean_to_box( ir_cbean = ir_bohne ).
  ENDMETHOD.

  METHOD on_loaded.
    WRITE 'Voll! STOPP!!'.
  ENDMETHOD.
ENDCLASS.


DATA gd_zubereitungsart TYPE char40 VALUE 'Espresso'.

* Referenz auf Kaffeevollautomat
DATA: gr_maikes_kva TYPE REF TO lcl_kaffeevollautomat,
      gr_mein_kva   TYPE REF TO lcl_kaffeevollautomat.

**********************************************************************
**********************************************************************
* Start-of-section
**********************************************************************
START-OF-SELECTION.
  CREATE OBJECT gr_maikes_kva.
  CREATE OBJECT gr_mein_kva.

  DATA: gr_golden_bean TYPE REF TO zls_gcl_sch_08_cbean.

  DO 75 TIMES.
    CREATE OBJECT gr_golden_bean.
    gr_mein_kva->bohne_nachfuellen( ir_bohne = gr_golden_bean ).
    WRITE: gr_golden_bean->get_volume( ).
  ENDDO.
