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
REPORT zfk_zeichenartige_dt.
**********************************************************************
* Datendeklaration
**********************************************************************
DATA: gv_char(10) TYPE c,
      gv_nchar(4) TYPE n,
      gv_string   TYPE string.
**********************************************************************
* Belegung
**********************************************************************
gv_char = 'TestTest'.
gv_nchar = '0123456789'.
gv_string = 'Dies ist ein Test für dynamische Anpassung der Länge eines strings'.
**********************************************************************
* Ausgabe
**********************************************************************
WRITE: gv_char,
/ gv_nchar,
/ gv_string.

gv_char = 'TestBubeDameKönig'.
gv_nchar = '1011'.

CONCATENATE gv_char gv_nchar INTO gv_string SEPARATED BY ' '.

WRITE / gv_string.
**********************************************************************
* Suchen in Zeichenkette
**********************************************************************
FIND 'ube' IN gv_string.

IF sy-subrc = 0.
  WRITE / 'Gefunden!'.
ENDIF.

**********************************************************************
* Ersetzen in Zeichenketten
**********************************************************************
REPLACE 'Bube' IN gv_string WITH 'Ass'.

IF sy-subrc = 0.

  WRITE: / 'Erfolg',
   / gv_string.

ENDIF.

**********************************************************************
* Zersetzen von Zeichenketten
**********************************************************************

DATA: gv_ganzername TYPE string VALUE 'Florian Krupa',
      gv_vorname    TYPE string,
      gv_nachname   TYPE string.

SPLIT gv_ganzername AT ' ' INTO gv_vorname gv_nachname.

IF sy-subrc = 0.
  ULINE.
  WRITE: / 'Vorname: ', gv_vorname, / 'Nachname: ', gv_nachname.
ENDIF.

**********************************************************************
* Verdichten von Zeichenketten
**********************************************************************

DATA: gv_verdichtung TYPE string VALUE ' das ist ein         Verdichtungstest  '.

ULINE.

WRITE gv_verdichtung.

CONDENSE gv_verdichtung.

WRITE  / gv_verdichtung.

**********************************************************************
* Umwandeln von Zeichenketten
**********************************************************************

TRANSLATE gv_verdichtung TO UPPER CASE.

WRITE / gv_verdichtung.

**********************************************************************
* Textsymbole
**********************************************************************

Write text-001.
gv_verdichtung = text-001.
TRANSLATE gv_verdichtung TO UPPER CASE.
write / gv_verdichtung.

Write / text-001.
