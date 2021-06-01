class ZCL_HOTEL definition
  public
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_NAME type STRING
      !IV_BEDS type I .
  methods DISPLAY_ATTRIBUTES .
  class-methods DISPLAY_NO_HOTELS .
protected section.
private section.

  constants C_POS type I value 30 ##NO_TEXT.
  data MV_NAME type STRING .
  data MV_BEDS type I .
  class-data GV_NO_HOTELS type I .
ENDCLASS.



CLASS ZCL_HOTEL IMPLEMENTATION.


  method CONSTRUCTOR.
    mv_name = iv_name.
    mv_beds = iv_beds.
  endmethod.


  method DISPLAY_ATTRIBUTES.
    WRITE:
    / 'Hotel'(001),       at c_pos mv_name,
    / 'bets Anzahl'(002), at c_pos mv_beds.
    uline.
    ULINE.
    skip.
  endmethod.


  method DISPLAY_NO_HOTELS.
    WRITE:
    / 'gesamte Anzahl vom Hotels '(003), gv_no_hotels.
  endmethod.
ENDCLASS.
