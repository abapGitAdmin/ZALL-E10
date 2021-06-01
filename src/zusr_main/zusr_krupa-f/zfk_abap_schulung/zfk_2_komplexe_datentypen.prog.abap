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
REPORT zfk_2_komplexe_datentypen.

**********************************************************************
* Definieren des Strukturtypen & Tabelle
**********************************************************************
TYPES: BEGIN OF lty_s_mitarbeiter,
         pernr   TYPE i,
         vorname TYPE string,
         name    TYPE string,
         alter   TYPE i,
       END OF lty_s_mitarbeiter.

TYPES lty_t_mitarbeiter TYPE TABLE OF lty_s_mitarbeiter.
**********************************************************************
* Erzeugen von Strukturen, Tabellen und Anhängen
**********************************************************************

DATA gs_mitarbeiter TYPE lty_s_mitarbeiter.
DATA gt_mitarbeiter TYPE lty_t_mitarbeiter.
DATA gt_mitarbeiter2 TYPE SORTED TABLE OF lty_s_mitarbeiter WITH UNIQUE KEY pernr. "Tabelle erzeugen ohne Tabellentypen erzeugen

gs_mitarbeiter-pernr = 2.
gs_mitarbeiter-vorname = 'Florian'.
gs_mitarbeiter-name = 'Krupa'.
gs_mitarbeiter-alter = 22.

INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2.
CLEAR gs_mitarbeiter.


gs_mitarbeiter-pernr = 1.
gs_mitarbeiter-vorname = 'Hans'.
gs_mitarbeiter-name = 'Schmitt'.
gs_mitarbeiter-alter = 35.
*APPEND gs_mitarbeiter TO gt_mitarbeiter2.
INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2.

APPEND LINES OF gt_mitarbeiter2 TO gt_mitarbeiter.
APPEND LINES OF gt_mitarbeiter2 TO gt_mitarbeiter.




**********************************************************************
* Auslesen von Datensätzen
**********************************************************************

ULINE.
READ TABLE gt_mitarbeiter INDEX 4 INTO gs_mitarbeiter.
WRITE gs_mitarbeiter-pernr.
ULINE.
READ TABLE gt_mitarbeiter2 WITH TABLE KEY pernr = 1 INTO gs_mitarbeiter.
WRITE gs_mitarbeiter-pernr.

READ TABLE gt_mitarbeiter2 WITH KEY vorname = 'Florian' INTO gs_mitarbeiter.
WRITE gs_mitarbeiter-pernr.

CLEAR gs_mitarbeiter.


WRITE / 'Print Table'.
LOOP AT gt_mitarbeiter INTO gs_mitarbeiter.
  WRITE: / gs_mitarbeiter-pernr,  gs_mitarbeiter-vorname,  gs_mitarbeiter-name,  gs_mitarbeiter-alter.
  CLEAR gs_mitarbeiter.

ENDLOOP.


CLEAR gs_mitarbeiter.






**********************************************************************
* MODIFY TABLE Befehl
**********************************************************************
SORT gt_mitarbeiter BY pernr DESCENDING.

LOOP AT gt_mitarbeiter INTO gs_mitarbeiter.
  WRITE: / gs_mitarbeiter-pernr,  gs_mitarbeiter-vorname,  gs_mitarbeiter-name,  gs_mitarbeiter-alter.
  CLEAR gs_mitarbeiter.

ENDLOOP.






gs_mitarbeiter-pernr = 2.
gs_mitarbeiter-vorname = 'Florian'.
gs_mitarbeiter-name = 'Krupa'.
gs_mitarbeiter-alter = 25.

MODIFY TABLE gt_mitarbeiter2 FROM gs_mitarbeiter.

READ TABLE gt_mitarbeiter2 WITH TABLE KEY pernr = 2 INTO gs_mitarbeiter.
*WRITE / gs_mitarbeiter-alter.

**********************************************************************
* DELETE Befehl
**********************************************************************

DELETE TABLE gt_mitarbeiter2 FROM gs_mitarbeiter.
DELETE gt_mitarbeiter2 INDEX 1.




**********************************************************************
* Print zum Testen
**********************************************************************
*WRITE: / gs_mitarbeiter-vorname, / gs_mitarbeiter-name, / gs_mitarbeiter-alter.
