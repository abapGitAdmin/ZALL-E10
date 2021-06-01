*&---------------------------------------------------------------------*
*& Report ZSCH_15_TCODE_CHECKER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsch_15_tcode_checker.

DATA: gd_message TYPE string.
PARAMETERS: pa_tcode TYPE tcode.

AT SELECTION-SCREEN.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
           ID 'schoe' FIELD '__________'.
  IF sy-subrc <> 0.
    CONCATENATE
    'Leider keine Berechtigung für Transaktionscode'
    pa_tcode
    INTO gd_message SEPARATED BY space.
    MESSAGE gd_message TYPE 'E'.
  ENDIF.

START-OF-SELECTION.
  WRITE: /
  'Gratuliere, du hast die Berechtigung für die transaktion',
  pa_tcode.
