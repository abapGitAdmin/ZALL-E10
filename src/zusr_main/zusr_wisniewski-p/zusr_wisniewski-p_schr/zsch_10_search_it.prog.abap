*&---------------------------------------------------------------------*
*& Report ZSCH_10_SEARCH_IT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_10_search_it.

INTERFACE lif_search.
  METHODS get_it
    IMPORTING
      id_thing  TYPE string
    EXPORTING
      et_things TYPE stringtab.
  DATA gd_things_count TYPE i.
ENDINTERFACE.

CLASS lcl_katze DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_search.
    METHODS: get_it.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

*CLASS lcl_lieblingssuchmaschine DEFINITION.
*  PUBLIC SECTION.
*    INTERFACES lif_search.
*  PROTECTED SECTION.
*  PRIVATE SECTION.
*ENDCLASS.

CLASS lcl_katze IMPLEMENTATION.
  METHOD: lif_search~get_it.
    DATA: ld_thing LIKE LINE OF et_things.
    CONCATENATE 'Du suchst: ' id_thing INTO ld_thing SEPARATED BY space.
    APPEND 'Ich bin es, die Katze' TO et_things.
    APPEND ld_thing TO et_things.
    APPEND 'Ich bringe dir sicher nichts!' TO et_things.
  ENDMETHOD.
  METHOD get_it.

  ENDMETHOD.
ENDCLASS.

DATA: gr_schroedingers_katze TYPE REF TO lcl_katze,
      gr_search              TYPE REF TO lif_search,
      gt_things              TYPE stringtab.

START-OF-SELECTION.

  CREATE OBJECT gr_schroedingers_katze.

  CALL METHOD gr_schroedingers_katze->lif_search~get_it
    EXPORTING
      id_thing  = 'Stockerl'
    IMPORTING
      et_things = gt_things.

  CALL METHOD gr_schroedingers_katze->get_it.
