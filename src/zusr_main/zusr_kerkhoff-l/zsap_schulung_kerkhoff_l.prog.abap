*&---------------------------------------------------------------------*
*& Report ZSAP_SCHULUNG_KERKHOFF_L
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSAP_schulung_kerkhoff_l.


DATA:
      firstname(10) TYPE c,
      alter(5) TYPE n,
      int1 type int1 value 12.


firstname = 'Andre' .


WRITE:  `Hello World!` .

IF firstname = 'Lukas'.
WRITE: / `Hallo` , firstname .
else.
  WRITE: `Du bist nicht Lukas sondern` , firstname .
ENDIF.
WRITE: / alter.
alter = +5.
alter = +40.
WRITE: / alter.
Write: / int1.

DO 3 TIMES.
Write: 'test'.
ENDDO.
