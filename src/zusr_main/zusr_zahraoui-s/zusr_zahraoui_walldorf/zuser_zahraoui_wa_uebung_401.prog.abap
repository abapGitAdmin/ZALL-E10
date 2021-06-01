*&---------------------------------------------------------------------*
*& Report ZUSER_ZAHRAOUI_WA_UEBUNG_401
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZUSER_ZAHRAOUI_WA_UEBUNG_401.



class aaa DEFINITION.
  PUBLIC SECTION.
  METHODS:
          getmet
          IMPORTING var1 type i
          exporting var2 type i
          CHANGING var3 type string.
  PROTECTED SECTION.
  types: var3 TYPE i .

  PRIVATE SECTION.
  data:
         var1 TYPE i,
         var2 like var1,

*

*statische Attribute existieren einmal pro Klasse und sichtber für alle instanzen de Klasse
*


endclass.
ENDCLASS.


class aaa IMPLEMENTATION.

  METHOD:
  getmet .
  endmethod.

  ENDCLASS.
