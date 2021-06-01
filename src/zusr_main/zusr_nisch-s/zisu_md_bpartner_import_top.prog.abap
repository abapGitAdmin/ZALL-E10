*&---------------------------------------------------------------------*
*& Include ZISU_MD_BPARTNER_IMPORT_TOP                       Report ZISU_MD_BPARTNER_IMPORT
*&
*&---------------------------------------------------------------------*
REPORT zisu_md_bpartner_import.

TABLES sscrfields.

TYPES:
  BEGIN OF ty_bpartner,
    vorname  TYPE bu_nameor1,
    nachname TYPE bu_nameor2,
  END OF ty_bpartner.

TYPES: tt_bpartner TYPE STANDARD TABLE OF ty_bpartner WITH KEY vorname nachname.

PARAMETERS:
  p_file TYPE rlgrap-filename,
  p_test TYPE abap_bool AS CHECKBOX DEFAULT abap_true.

SELECTION-SCREEN: FUNCTION KEY 1.
