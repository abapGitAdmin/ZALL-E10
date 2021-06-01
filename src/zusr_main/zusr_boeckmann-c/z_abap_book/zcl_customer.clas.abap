class ZCL_CUSTOMER definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !ID type ZCUSTOMERS-ID
    raising
      ZCX_NO_CUSTOMER .
  methods RESERVE_A_CAR
    importing
      !CAR_RESERVATIONS type ref to ZCL_CAR_RESERVATIONS
    raising
      ZCX_NO_CAR_AVAILABLE .
protected section.
private section.

  data CUSTOMER_WA type ZCUSTOMERS .
ENDCLASS.



CLASS ZCL_CUSTOMER IMPLEMENTATION.


  method CONSTRUCTOR.
    SELECT SINGLE *
      FROM zcustomers
      INTO customer_wa
      WHERE id = id.

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_no_customer.
      ENDIF.
  endmethod.


  method RESERVE_A_CAR.

    DATA: category      TYPE zcars-category,
          date_from     TYPE zreservations-date_from,
          date_to       TYPE zreservations-date_to.

    CALL FUNCTION 'Z_INPUT_RESERVATION'
      IMPORTING
        car_category = category
        date_from    = date_from
        date_to      = date_to.

    car_reservations->make_reservation(
                          customer  = me->customer_wa-id
                          category  = category
                          date_from = date_from
                          date_to   = date_to ).

  endmethod.
ENDCLASS.
