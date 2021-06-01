*&---------------------------------------------------------------------*
*& Report ZPROG_D_SANDUHR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROG_D_SANDUHR.

* Der Taktgeber
DATA: gr_gui_timer TYPE REF TO cl_gui_timer.
* Klasse für die Timer-Reaktion
CLASS lcl_event_handler DEFINITION.
PUBLIC SECTION.
* Falls der Timer sich meldet, reagieren wir darauf
CLASS-METHODS: on_finished FOR EVENT finished
OF cl_gui_timer
IMPORTING sender.
ENDCLASS.
* Da kommt die Implementierung
CLASS lcl_event_handler IMPLEMENTATION.
METHOD on_finished.
STATICS: ld_kruemel TYPE i.
ADD 1 TO ld_kruemel.
* Lauf Pferdchen, lauf weiter
IF ld_kruemel < 10.
WRITE: '.'.
sender->run( ).
* Brrrr, es ist vorbei
ELSE.
sender->cancel( ).
WRITE: 'Fertig!'.
ENDIF.
ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
* Den Timer erzeugen
CREATE OBJECT gr_gui_timer.
* Wer reagiert womit auf den Timer?
SET HANDLER lcl_event_handler=>on_finished
FOR gr_gui_timer.
* Setze das Intervall auf eine Sekunde
gr_gui_timer->interval =  1.
* Lauf Pferdchen, lauf
gr_gui_timer->run( ).
* Sanduhr starten
WRITE / 'Sanduhr läuft: '.
