************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT ZLS_ZEICHENARTIGE_DT.

**********************************************************************
* Deklaration
**********************************************************************
DATA: gv_char(10) TYPE c,
      gv_numc(10) TYPE n,
      gv_string   TYPE string.

**********************************************************************
* Vaiablenbelegung
**********************************************************************
gv_char   = 'TestTestTest'.
gv_numc   = '12345'.
gv_string = 'Das ist ein String'.

**********************************************************************
* Zusammenfügen von Zeichenketten
**********************************************************************
CONCATENATE gv_char gv_numc INTO gv_string SEPARATED BY ' '.
WRITE / gv_string.

**********************************************************************
* Suchen in Zeichenketten
**********************************************************************
FIND 'Test' IN gv_string.
IF sy-subrc =  0.
  WRITE / 'Gefunden'.
ENDIF.

**********************************************************************
* Ersetzen von Zeichenketten
**********************************************************************
REPLACE ALL OCCURRENCES OF 'Test' IN gv_string WITH 'Hallo! '.

IF sy-subrc = 0.
  WRITE / gv_string.
ENDIF.

**********************************************************************
* Zerlegen von Zeichenketten
**********************************************************************
DATA: gv_ganzer_name TYPE string VALUE 'Hans Meyer',
      gv_vorname     TYPE string,
      gv_nachname    TYPE string.

SPLIT gv_ganzer_name AT ' ' INTO gv_vorname gv_nachname.
IF sy-subrc = 0.
  ULINE.
  WRITE: 'Vorname: ', gv_vorname, /, 'Nachname: ', gv_nachname.
ENDIF.

**********************************************************************
* Verdichten von Zeichenketten
**********************************************************************
DATA: gv_verdichtung TYPE string VALUE ' das  ist      ein Verdichtungstest.'.

ULINE.
WRITE gv_verdichtung.

CONDENSE gv_verdichtung.
WRITE / gv_verdichtung.

CONDENSE gv_verdichtung NO-GAPS.
WRITE / gv_verdichtung.

**********************************************************************
* Umwandeln von Zeichenketten
**********************************************************************
TRANSLATE gv_verdichtung TO UPPER CASE.
ULINE.
WRITE gv_verdichtung.

**********************************************************************
* Textsymbole
**********************************************************************
WRITE text-001.
