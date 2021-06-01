*&---------------------------------------------------------------------*
*& Report ZWIS_SCHULUNG_HELLO_WORLD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zwis_schulung_hello_world.

DATA: str1 TYPE string VALUE 'hallo 2'.

DO 3 TIMES.
  WRITE 'Hello World!'.
  WRITE str1.
ENDDO.
