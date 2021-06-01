*&---------------------------------------------------------------------*
*& Report ZBC401_VERERBUNG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc401_vererbung_ueb12.

"CONSTANTS ca1.



INCLUDE my_interface_12.
*INCLUDE MY_INTERFACE.

INCLUDE z_alle_klasse_12.
*INCLUDE Z_ALLE_KLASSE.
DATA:
  "9 nur carrier
  go_carrier   TYPE REF TO lcl_carrier,
  " üb12
  go_agency    TYPE REF TO travel_agency,
  go_airplane  TYPE REF TO lcl_airplane,
  go_cargo     TYPE REF TO cargo,
  go_passager  TYPE REF TO lcl_passenger,
  "enfernen gt tabelle

  " gt_plan     TYPE TABLE OF REF TO lcl_airplane,
  gt_airplanes TYPE TABLE OF REF TO lcl_airplane,
  gv_count     TYPE i.


START-OF-SELECTION.

  lcl_airplane=>displa_no( ).
  "üb12
  CREATE OBJECT go_agency
    EXPORTING
      iv_name = 'Reise zahraoui gmbh'.

  "Carrier
  CREATE OBJECT go_carrier
    EXPORTING
      iv_name = 'le carrier'.
  "übung 12 : übergabe der Reie die rRefenrenzen auf
  "bereits erzeugte per aufruf addpartners
  go_agency->add_partner( go_carrier ).

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
      iv_planetype    = 'A310-200'
      iv_cargo        = 20
    EXCEPTIONS
      wrong_planetype = 1.
  IF sy-subrc = 0.
    "üb8  APPEND go_cargo TO gt_airplanes.
    "üb9
    go_carrier->add_airplane( go_cargo ).
  ENDIF.
  "  go_carrier->lif_partner~display_partner( ).
  "Üb12 letze Frage
  go_agency->display_attributes( ).
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
