*&---------------------------------------------------------------------*
*& Report ZSCH_06_SAND_UHR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_06_sand_uhr.

DATA: gr_gui_timer TYPE REF TO cl_gui_timer.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: on_finished FOR EVENT finished
                  OF cl_gui_timer
      IMPORTING sender.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_finished.
    STATICS: ld_kruemel TYPE i.
    ADD 1 TO ld_kruemel.
    IF ld_kruemel < 10.
      WRITE: '.'.
      sender->run( ).
    ELSE.
      sender->cancel( ).
      WRITE: 'Fertig!'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  CREATE OBJECT gr_gui_timer.
  SET HANDLER lcl_event_handler=>on_finished FOR gr_gui_timer.
  gr_gui_timer->interval = 1.
  gr_gui_timer->run( ).
  WRITE / 'Sanduhr läuft: '.
