class ZCL_CAR_RESERVATIONS definition
  public
  final
  create private .

public section.

  class-data CAR_RESERVATIONS type ref to ZCL_CAR_RESERVATIONS read-only .

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR .
  methods MAKE_RESERVATION
    importing
      !CUSTOMER type ZCUSTOMERS-ID
      !CATEGORY type ZCARS-CATEGORY
      !DATE_FROM type ZRESERVATIONS-DATE_FROM
      !DATE_TO type ZRESERVATIONS-DATE_TO
    raising
      ZCX_NO_CAR_AVAILABLE .
  methods PERSIST_RESERVATIONS .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA reservation_tab TYPE t_reservation_tab .
ENDCLASS.



CLASS ZCL_CAR_RESERVATIONS IMPLEMENTATION.


  METHOD class_constructor.
    CREATE OBJECT car_reservations.
  ENDMETHOD.


  METHOD constructor.
    SELECT *
            FROM zreservations
            INTO TABLE me->reservation_tab.
  ENDMETHOD.


  METHOD make_reservation.
    DATA: license_plate   TYPE zcars-license_plate,
          reservation_wa  LIKE LINE OF reservation_tab,
          reservation_num TYPE i,
          mess            TYPE string.

    reservation_num = lines( reservation_tab ).

    SELECT license_plate
           FROM zcars
           INTO (license_plate)
           WHERE category = category.

      LOOP AT reservation_tab
        TRANSPORTING NO FIELDS
        WHERE license_plate = license_plate
              AND NOT ( date_from > date_to OR date_to < date_from ).
      ENDLOOP.

      IF sy-subrc <> 0.
        reservation_wa-reservation_id   = reservation_num + 1.
        reservation_wa-customer_id      = customer.
        reservation_wa-license_plate    = license_plate.
        reservation_wa-date_from        = date_from.
        reservation_wa-date_to          = date_to.
        INSERT reservation_wa INTO TABLE reservation_tab.
        IF sy-subrc = 0.
          CONCATENATE license_plate ' reserved!' INTO mess.
          MESSAGE mess TYPE 'I'.
        ELSE.
          MESSAGE 'Internal Error!' TYPE 'I' DISPLAY LIKE 'E'.
          LEAVE PROGRAM.
        ENDIF.
        RETURN.
      ENDIF.

    ENDSELECT.

    RAISE EXCEPTION TYPE zcx_no_car_available.

  ENDMETHOD.


    METHOD PERSIST_RESERVATIONS.

      DELETE FROM zreservations.
      INSERT zreservations
             FROM TABLE reservation_tab.
    ENDMETHOD.
ENDCLASS.
