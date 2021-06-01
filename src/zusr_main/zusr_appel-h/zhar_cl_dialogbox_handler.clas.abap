CLASS zhar_cl_dialogbox_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      dialogbox_close
          FOR EVENT close OF cl_gui_dialogbox_container
          IMPORTING sender.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zhar_cl_dialogbox_handler IMPLEMENTATION.
  method dialogbox_close.
   sender->free(
      EXCEPTIONS
          OTHERS  = 1 ).
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
