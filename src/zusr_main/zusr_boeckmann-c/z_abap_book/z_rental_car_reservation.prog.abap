*&---------------------------------------------------------------------*
*& Subroutinenpool   Z_RENTAL_CAR_RESERVATION
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
PROGRAM z_rental_car_reservation.

* DECLARATIONS

CLASS cl_car_rental DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.
ENDCLASS.

* IMPLEMENTATIONS

CLASS cl_car_rental IMPLEMENTATION.
  METHOD main.
    DATA: id           TYPE zcustomer_id,
          customer     TYPE REF TO zcl_customer,
          ans          TYPE c LENGTH 1,
          reservations TYPE REF TO zcl_car_reservations.

* CREATE CUSTOMER
    CALL FUNCTION 'Z_INPUT_CUSTOMER'
      IMPORTING
        customer_id = id.
    TRY.
        CREATE OBJECT customer EXPORTING id = id.
      CATCH zcx_no_customer.
        MESSAGE 'UNKNOWN CUSTOMER'
                TYPE 'I' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

* CREATE OBJECTS FOR RESERVATIONS
    reservations = zcl_car_reservations=>car_reservations.

    DO.
      "Customer reserves a car
      TRY.
          customer->reserve_a_car( reservations ).
        CATCH zcx_no_car_available.
          MESSAGE 'No car available!'
          TYPE 'I' DISPLAY LIKE 'E'.
      ENDTRY.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = 'Other reservations?'
          text_button_1         = 'Yes'
          text_button_2         = 'No'
          display_cancel_button = ' '
        IMPORTING
          answer                = ans.
      IF ans = '2'.
        EXIT.
      ENDIF.

    ENDDO.
    "Persist data on database

    reservations->persist_reservations( ).

  ENDMETHOD.
ENDCLASS.
