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
REPORT zps_zeichenartige_dt.
**********************************************************************
*Datendeklaration
**********************************************************************
DATA: gv_char(10) TYPE c, "Zahl in der Klammer gibt die Zahl der Zeichen an. Zeichen über Länge10 werden abgeschnitten"
      gv_numc(10) TYPE n, "Reserviert Speicher für 10 Zeichen. Ob diese benötit werden ist irrelevant"
      gv_string   TYPE string. "Passt seine Länge an."

gv_char = 'TESTTESTTEST'.
gv_numc = '13456'.
gv_string = 'HELLO, HOLA y Bonjour'.

WRITE: gv_char, / gv_numc, / gv_string.

**********************************************************************
*Zusammenfügen von Zeichenketten
**********************************************************************
CONCATENATE gv_char gv_numc INTO gv_string. "Concatenate fügt verschiedene Zeichenketten in einer Zielvariable zusammen. Diese wird dabei überschriebn."
WRITE: / gv_string.

CONCATENATE gv_char gv_numc INTO gv_string SEPARATED BY ' - '. "Zusammengefügte Zeichenketten werden durch ein frei wählbares Zeichen getrennt."
WRITE: / gv_string.

**********************************************************************
*Suchen in Zeichenketten
**********************************************************************
FIND 'TEST' IN gv_string.

IF sy-subrc = 0.
  WRITE / 'Die Zeichenkette wurde in der Zielvariable gefunden!'.
ENDIF.

**********************************************************************
*Ersetzten einer Zeichenkette durch eine andere
**********************************************************************
REPLACE 'TEST' IN gv_string WITH 'Bonjour'. "REPLACE tauscht nur den ersten Fund in der Zeichenkette aus."
IF sy-subrc = 0.                            "sy-subrc gibt 0 zurück, wenn es min. einen F"
  WRITE / gv_string.
ENDIF.
*------------*

REPLACE ALL OCCURRENCES OF 'TEST' IN gv_string WITH 'Bonjour'. "Durch 'ALL OCCURENCIE OF' werden alle Treffer durch die Zeichenkette ausgetauscht."
IF sy-subrc = 0.
  WRITE / gv_string.
ENDIF.


**********************************************************************
*Zeichenketten zerlegen
**********************************************************************
DATA: gv_ganzer_name TYPE string VALUE 'Philip Schmitt',
      gv_nachname    TYPE string,
      gv_name        TYPE string.

ULINE.
WRITE: / 'Zeichenkette vor der Trennung: ' , gv_ganzer_name.
SPLIT gv_ganzer_name AT ' ' INTO gv_name gv_nachname.


IF sy-subrc = 0.
  WRITE: / 'Name: ',gv_name,/ 'Nachname: ' ,gv_nachname.
ENDIF.

**********************************************************************
*Verdichten von Zeichenketten
**********************************************************************
ULINE.
DATA: gv_verdichtung TYPE string VALUE '   das   ist   ein  Beispiels   der  Verdichtet   werden soll  .'.
WRITE / gv_verdichtung.

CONDENSE gv_verdichtung. "führende u. schließende Leerzeichen werden entfernt und sonstige
"direkt aufeinander folgende Leerzeichen entweder durch genau ein Leerzeichen ersetzt."
WRITE / gv_verdichtung.

CONDENSE  gv_verdichtung NO-GAPS.
WRITE / gv_verdichtung.

**********************************************************************
*Umwandeln von Zeichenketten
**********************************************************************
TRANSLATE gv_verdichtung TO UPPER CASE. "TO LOWER CASE."
WRITE / gv_verdichtung.

**********************************************************************
*Verendung von Textsymbolen
**********************************************************************
ULINE.
WRITE / text-001.
