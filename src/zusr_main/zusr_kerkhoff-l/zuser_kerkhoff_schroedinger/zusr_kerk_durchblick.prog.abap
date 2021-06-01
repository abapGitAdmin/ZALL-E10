*&---------------------------------------------------------------------*
*& Report ZUSR_KERK_DURCHBLICK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* Projekt 12
REPORT zusr_kerk_durchblick.

PARAMETERS: pa_proj TYPE zsch03kerkhoff-projekt OBLIGATORY.

DATA: gs_project TYPE zsch03kerkhoff.

START-OF-SELECTION.
  WRITE: 'Durchblick 2.0'.

  SELECT SINGLE * FROM zsch03kerkhoff INTO gs_project
    WHERE projekt = pa_proj.

  IF sy-subrc = 0.
    WRITE: / gs_project.
  ELSE.
    WRITE: / 'Och schade, nichts gefunden für Projekt = ', pa_proj.
  ENDIF.
