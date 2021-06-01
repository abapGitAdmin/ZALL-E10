*&---------------------------------------------------------------------*
*&  Include           ZSALV_GUI_DIALOG_CONTAINER
*&---------------------------------------------------------------------*


CLASS gcl_event_handler DEFINITION.


  PUBLIC SECTION.

    METHODS:
      constructor IMPORTING ir_dialog_box TYPE REF TO cl_gui_dialogbox_container,
      dialogbox_close FOR EVENT close OF cl_gui_dialogbox_container IMPORTING sender.

  PROTECTED SECTION.

    DATA: gr_dialogbox_cl   TYPE REF TO cl_gui_dialogbox_container.

ENDCLASS.



CLASS gcl_event_handler IMPLEMENTATION.

  METHOD constructor.
* Dialogboxinstanz global in der Klasse ablegen
    gr_dialogbox_cl = ir_dialog_box .
  ENDMETHOD.                    "constructor

  METHOD dialogbox_close.
*  Der sender enthält in diesem Fall eine Instanz des Dalogbox-Containers
    sender->free(
    EXCEPTIONS
      OTHERS  = 1 ).

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
* Speicher der Instanz freigeben
    FREE: gr_dialogbox_cl.

  ENDMETHOD.                    "dialogbox_c

ENDCLASS.
