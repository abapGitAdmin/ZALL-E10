*&---------------------------------------------------------------------*
*&  Include           Z_RENTAL
*&---------------------------------------------------------------------*
CLASS vehicle DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          iv_make TYPE string
        ,

      displayattributes.

    CLASS-METHODS:
      get_count EXPORTING ev_count TYPE i.
    EVENTS: vehicle_created.

  PROTECTED SECTION.
    CONSTANTS: c_pos TYPE i VALUE 30.

  PRIVATE SECTION.
    DATA:
       mv_make     TYPE  string.

    CLASS-DATA:
       gv_no_vehicle TYPE i.
ENDCLASS.

CLASS vehicle IMPLEMENTATION.
  METHOD constructor.
    mv_make = iv_make.
    ADD 1 TO gv_no_vehicle.
    RAISE EVENT vehicle_created.

  ENDMETHOD.
  METHOD displayattributes.
    WRITE mv_make.
  ENDMETHOD.
  METHOD get_count.
    ev_count = gv_no_vehicle.
  ENDMETHOD.

ENDCLASS.

CLASS rental DEFINITION.
  PUBLIC SECTION.
    INTERFACES: lif_partner.
    METHODS:
      constructor IMPORTING iv_name TYPE string,
      displayattributes.
  PRIVATE SECTION.
    DATA:
      mv_name     TYPE string,
      mt_vehicles TYPE TABLE OF REF TO vehicle.
    METHODS:
      on_vehicles_created FOR EVENT vehicle_created OF vehicle
        IMPORTING sender.
ENDCLASS.
CLASS rental IMPLEMENTATION.
  METHOD lif_partner~display_partner.
    displayattributes( ).
  ENDMETHOD.
  METHOD constructor.
    mv_name = iv_name.
    SET HANDLER on_vehicles_created FOR ALL INSTANCES.
  ENDMETHOD.
  METHOD on_vehicles_created.
    APPEND sender TO mt_vehicles.
  ENDMETHOD.
METHOD displayattributes.
  DATA: lo_vehicle type REF TO vehicle.
  WRITE: / icon_transport_proposal as ICON,
          mv_name.
  WRITE: / 'Hier kommt die die cehicle liste :'.
  ULINE 2.
  LOOP AT  mt_vehicles INTO lo_vehicle.
    lo_vehicle->displayattributes( ).
 ENDLOOP.

  ENDMETHOD.
ENDCLASS.
