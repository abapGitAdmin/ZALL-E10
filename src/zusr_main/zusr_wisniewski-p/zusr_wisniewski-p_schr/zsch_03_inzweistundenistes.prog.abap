*&---------------------------------------------------------------------*
*& Report ZSCH_03_INZWEISTUNDENISTES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSCH_03_INZWEISTUNDENISTES.

DATA: gd_inzweistunden TYPE sy-uzeit.

START-OF-SELECTION.

WRITE: 'jetzt ist es: ', sy-uzeit.
gd_inzweistunden = sy-uzeit + 200.
WRITE: / 'Und in zwei Stunden ist es: ', gd_inzweistunden.
