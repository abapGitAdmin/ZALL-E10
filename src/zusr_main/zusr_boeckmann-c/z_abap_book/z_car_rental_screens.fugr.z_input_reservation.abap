FUNCTION z_input_reservation.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(CAR_CATEGORY) TYPE  ZCARS-CATEGORY
*"     REFERENCE(DATE_FROM) TYPE  ZRESERVATIONS-DATE_FROM
*"     REFERENCE(DATE_TO) TYPE  ZRESERVATIONS-DATE_TO
*"----------------------------------------------------------------------

  CALL SELECTION-SCREEN 1200 STARTING AT 10 10.

  IF sy-subrc <> 0.
    LEAVE PROGRAM.
  ENDIF.

  car_category = category.
  date_from = day_from.
  date_to = day_to.

ENDFUNCTION.
