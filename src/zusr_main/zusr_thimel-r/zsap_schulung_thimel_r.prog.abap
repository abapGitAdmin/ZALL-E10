*&---------------------------------------------------------------------*
*& Report ZSAP_SCHULUNG_THIMEL_R
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsap_schulung_thimel_r.

TYPES: BEGIN OF ts_test,
         int1  TYPE int1,
         char1 TYPE char1,
       END OF ts_test.

DATA: lv_int    TYPE int1 VALUE 1,
      lv_string TYPE string VALUE 'Hallo Welt!',
      ls_test   TYPE ts_test.

IF lv_int = 2.
  WRITE: sy-uname, ' hat geschummelt'.
ELSE.
  DO 100 TIMES.
    WRITE: lv_string,
           /.
  ENDDO.
ENDIF.
