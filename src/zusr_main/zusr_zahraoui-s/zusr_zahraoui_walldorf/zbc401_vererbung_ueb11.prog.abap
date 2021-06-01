*&---------------------------------------------------------------------*
*& Report ZBC401_VERERBUNG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_vererbung_ueb11.

"CONSTANTS ca1.



INCLUDE MY_INTERFACE.

INCLUDE Z_ALLE_KLASSE.
DATA:
      "9 nur carrier
  go_carrier TYPE REF TO lcl_carrier,
  go_airplane TYPE REF TO lcl_airplane,
  go_cargo    TYPE REF TO cargo,
  go_passager TYPE REF TO lcl_passenger,
  "enfernen gt tabelle

 " gt_plan     TYPE TABLE OF REF TO lcl_airplane,
  gt_airplanes TYPE TABLE OF REF TO lcl_airplane,
  gv_count    TYPE i.


START-OF-SELECTION.

  lcl_airplane=>displa_no( ).
  "Carrier
  create OBJECT go_carrier
  EXPORTING
    iv_name = 'le carrier'.


  " passager
  CREATE OBJECT go_passager
    EXPORTING
      iv_name         = 'zri9a'
      iv_planetype    = 'A310-200'
      iv_seats        = 20
    EXCEPTIONS
      wrong_planetype = 1.
  " üb8 APPEND go_passager TO gt_plan.
  IF sy-subrc = 0.
 "   APPEND go_passager TO gt_airplanes.
      go_carrier->add_airplane( go_passager ).
      ENDIF.
  " cargo
  CREATE OBJECT go_cargo
    EXPORTING
      iv_name         = 'ferari'
      iv_planetype    = 'DC-8-72'
      iv_cargo       = 20
    EXCEPTIONS
      wrong_planetype = 1.
  IF sy-subrc = 0.
   "üb8  APPEND go_cargo TO gt_airplanes.
    "üb9
      go_carrier->add_airplane( go_cargo ).
  ENDIF.
  go_carrier->lif_partner~display_partner( ).

  "APPEND go_cargo TO gt_plan.
*  go_passager->displayattributes( ).
*  go_cargo->displayattributes( ).
  "üb8
  "üb11 Entfernen der Aifruf von disp.attri.
*  LOOP AT gt_airplanes INTO go_airplane.
*    go_airplane->displayattributes( ).
*
*  ENDLOOP.

  "anzahl
*  gv_count = lcl_airplane=>get_no_airplanes( ).
*  SKIP 2.
*  WRITE: / 'Anzahl von Flugs'(ca1), gv_count.
