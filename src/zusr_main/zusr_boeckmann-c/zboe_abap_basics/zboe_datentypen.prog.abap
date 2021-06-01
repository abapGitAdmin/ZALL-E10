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
REPORT zboe_datentypen.

**********************************************************************
* Datendeklarationen
**********************************************************************

DATA: gv_char(10) TYPE c,
      gv_numc(10) TYPE n,
      gv_string   TYPE string.

**********************************************************************
* Variablenbelegung
**********************************************************************

gv_char = 'TestTestTest'.
gv_numc = '12345'.
gv_string = 'Dies ist ein String!'.

**********************************************************************
* Ausgabe der Variablen
**********************************************************************

WRITE: gv_char, /, gv_numc, /,gv_string.

**********************************************************************
* Zusammenfügen von Zzeichenketten
**********************************************************************

CONCATENATE gv_char gv_numc INTO gv_string SEPARATED BY ' '.

WRITE / gv_string.

**********************************************************************
* Suchen in Zeichenketten
**********************************************************************

FIND 'HALLO' IN gv_string.
IF sy-subrc = 0.
  WRITE / 'Das Suchmuster wurde mindestens einmal im Suchbereich gefunden'.
ENDIF.
IF sy-subrc = 4.
  WRITE / 'Das suchmuster wurde nicht im Suchbereich gefunden'.
ENDIF.
IF sy-subrc = 8.
  WRITE / 'Das Suchmuster enthält bei der Zeichenkettenverarbeitung ein ungültiges double-Byte-zeichen'.
ENDIF.

**********************************************************************
* Ersetzen von Zeichen in Zeichenketten
**********************************************************************
REPLACE ALL OCCURRENCES OF 'Test' IN gv_string WITH 'Hallo'.

IF sy-subrc = 0.
  WRITE / gv_string.
ENDIF.

**********************************************************************
* Aufteilen von Zeichenketten
**********************************************************************
DATA: gv_nachname    TYPE string,
      gv_vorname     TYPE string,
      gv_ganzer_name TYPE string VALUE 'Hans Meyer'.

SPLIT gv_ganzer_name AT ' ' INTO gv_vorname gv_nachname.

IF sy-subrc = 0.
  ULINE.
  WRITE: / 'Vorname: ', gv_vorname, /, 'Nachname: ', gv_nachname.
ENDIF.

**********************************************************************
* Verdichten von Zeichenketten
**********************************************************************
DATA: gv_verdichtung TYPE string VALUE ' Das ist ein Verdichtungstext'.

ULINE.
WRITE / gv_verdichtung.
CONDENSE gv_verdichtung NO-GAPS.

WRITE / gv_verdichtung.

**********************************************************************
* Umwandeln von Zeichenketten
**********************************************************************
TRANSLATE gv_verdichtung TO UPPER CASE.
ULINE.
WRITE / gv_verdichtung.

**********************************************************************
* Textsymbole
**********************************************************************
ULINE.
WRITE / text-001.

**********************************************************************
*
**********************************************************************
