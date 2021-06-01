*&---------------------------------------------------------------------*
*& Report ZSCH_08_C_MACHINE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_08_c_machine.

TYPE-POOLS: abap.
* Definitionsteil des Kaffeevollautomaten
CLASS lcl_kaffeevollautomat DEFINITION.
* Hier kommen die Definitionen rein
* Öffentlicher Bereich
  PUBLIC SECTION.
* bohnenbehälter
    DATA: gr_bohnenbehaelter TYPE REF TO zcl_sch_08_cbean_box.
* Anzahl der Objekte
    CLASS-DATA: anz_kva TYPE i.
* Bohenen ergänzen
    METHODS bohne_nachfuellen
      IMPORTING
        ir_bohne TYPE REF TO zcl_sch_08_cbean.
* Kaffee bitte
    METHODS ein_kaffee_sil_vous_plait
      IMPORTING
        VALUE(id_espresso)      TYPE abap_bool OPTIONAL
        VALUE(id_verlaengerter) TYPE abap_bool OPTIONAL.
    METHODS constructor.
* Behandle den Schrei des Bohnenbehälters
    METHODS on_loaded
        FOR EVENT loaded
        OF zcl_sch_08_cbean_box.
* Add
    CLASS-METHODS add_1_to_anz_kva .
* Geschützter Bereich
  PROTECTED SECTION.
* Privater Bereich
  PRIVATE SECTION.
* Wasserstand
    DATA: gd_wasserstand TYPE i.
ENDCLASS.

* Implementationsteil des Kaffeevollautomaten
CLASS lcl_kaffeevollautomat IMPLEMENTATION.
  METHOD constructor.
    anz_kva = anz_kva + 1.
    CREATE OBJECT me->gr_bohnenbehaelter.
    SET HANDLER me->on_loaded FOR me->gr_bohnenbehaelter.
  ENDMETHOD.
* Hier kommen die Implementierungen rein
* Einen Kaffee bitte
  METHOD ein_kaffee_sil_vous_plait.
* Hier kommt die Implementierung rein
  ENDMETHOD.
* Hochzählen
  METHOD add_1_to_anz_kva.
* Hier kommt die Implementierung rein
  ENDMETHOD.
* bohnen nachfüllen
  METHOD bohne_nachfuellen.
* bohne übergeben
    me->gr_bohnenbehaelter->add_bean_to_box( ir_cbean = ir_bohne ).
  ENDMETHOD.
  METHOD on_loaded.
* mach etwas
  ENDMETHOD.
ENDCLASS.

* Definitionsteil des Wasserbehälters
CLASS lcl_wasserbehaelter DEFINITION.
* Hier kommen die Definitionen rein
* Öffentlicher Bereich
  PUBLIC SECTION.
* Wasserstand holen
    CONSTANTS gc_wasser_haerte_grenze TYPE f VALUE '14.0'.
    METHODS get_wasserstand
      RETURNING VALUE(rd_wasserstand) TYPE i.
    METHODS check_wasser_haerte.
* Geschützter Bereich
  PROTECTED SECTION.
* Privater Bereich
  PRIVATE SECTION.
    DATA: gd_wasserstand TYPE i.
    DATA: gd_wasser_haerte TYPE f.
ENDCLASS.

* Implementationsteil des Wasserbehälters
CLASS lcl_wasserbehaelter IMPLEMENTATION.
* Hier kommen die Implementierungen rein
* Wasserstand holen
  METHOD get_wasserstand.
    rd_wasserstand = me->gd_wasserstand.
  ENDMETHOD.
  METHOD check_wasser_haerte.
    IF me->gd_wasser_haerte > gc_wasser_haerte_grenze.
      MESSAGE 'Au, das tut weh!' TYPE 'I'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

DATA gd_zubereitungsart TYPE char40 VALUE 'Espresso'.
DATA gr_rolands_kva TYPE REF TO lcl_kaffeevollautomat.
DATA gr_mein_kva TYPE REF TO lcl_kaffeevollautomat.
DATA gr_golden_bean TYPE REF TO zcl_sch_08_cbean.

START-OF-SELECTION.

  CREATE OBJECT gr_rolands_kva.
  CREATE OBJECT gr_mein_kva.

  DO 7000 TIMES.
    CREATE OBJECT gr_golden_bean.
    gr_mein_kva->bohne_nachfuellen( ir_bohne = gr_golden_bean ).
  ENDDO.
