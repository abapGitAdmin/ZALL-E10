*&---------------------------------------------------------------------*
*& Report ZZZ_DEBUG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZZZ_DEBUG.
TYPES:
    BEGIN OF zeile_typ,
       value TYPE c LENGTH 2,
    END OF zeile_typ.

DATA:
      lt_itab TYPE STANDARD TABLE OF zeile_typ,
      ls_value TYPE zeile_typ,
      lv_before TYPE c LENGTH 2,
      lv_after TYPE c LENGTH 2.

lv_before = 1.
ls_value = lv_before.

APPEND ls_value to lt_itab.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = lv_before
  IMPORTING
    output = lv_after.

APPEND lv_after to lt_itab.

WRITE: 'Alles erledigt'.
