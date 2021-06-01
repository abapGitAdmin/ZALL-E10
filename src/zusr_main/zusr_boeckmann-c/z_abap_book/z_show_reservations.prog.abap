*&---------------------------------------------------------------------*
*& Report Z_SHOW_RESERVATIONS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_SHOW_RESERVATIONS.


CLASS report_reservations DEFINITION.
    PUBLIC SECTION.
      CLASS-METHODS show_all.
ENDCLASS.

CLASS report_reservations IMPLEMENTATION.
    METHOD show_all.
      DATA: reservations TYPE TABLE OF zreservations,
            alv          TYPE REF TO cl_salv_table.
      SELECT *
          FROM zreservations
        INTO TABLE reservations
        ORDER BY date_from.
      TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = alv
            CHANGING t_table = reservations ).
        alv->display( ).
        CATCH cx_salv_msg.
          MESSAGE 'ALV display not possible' TYPE 'I'
              DISPLAY LIKE 'E'.
      ENDTRY.
    ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  report_reservations=>show_all( ).
