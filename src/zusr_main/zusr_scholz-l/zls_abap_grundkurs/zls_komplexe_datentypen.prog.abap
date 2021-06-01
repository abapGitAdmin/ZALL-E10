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
REPORT ZLS_KOMPLEXE_DATENTYPEN.

**********************************************************************
* Typdefinition und Datendeklaration
**********************************************************************
* Datendeklaration
TYPES: BEGIN OF lty_s_mitarbeiter,
  pernr   TYPE i,
  vorname TYPE string,
  name    TYPE string,
  alter   TYPE i,
 END OF lty_s_mitarbeiter.

TYPES lty_t_mitarbeiter TYPE TABLE OF lty_s_mitarbeiter.

* Deklaration
DATA gs_mitarbeiter TYPE lty_s_mitarbeiter.
DATA gt_mitarbeiter TYPE lty_t_mitarbeiter.
DATA gt_mitarbeiter2 TYPE SORTED TABLE OF lty_s_mitarbeiter WITH UNIQUE KEY pernr.

**********************************************************************
* Feldzuweisung
**********************************************************************
gs_mitarbeiter-pernr   = 2.
gs_mitarbeiter-vorname = 'Hans'.
gs_mitarbeiter-name    = 'Müller'.
gs_mitarbeiter-alter   = 50.
APPEND gs_mitarbeiter TO gt_mitarbeiter2.
CLEAR gs_mitarbeiter.

gs_mitarbeiter-pernr   = 1.
gs_mitarbeiter-vorname = 'Peter'.
gs_mitarbeiter-name    = 'Müller'.
gs_mitarbeiter-alter   = 50.
*APPEND gs_mitarbeiter TO gt_mitarbeiter2.
INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2.
*INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2 INDEX 1.
CLEAR gs_mitarbeiter.

APPEND LINES OF gt_mitarbeiter2 TO gt_mitarbeiter.
INSERT LINES OF gt_mitarbeiter2 INTO TABLE gt_mitarbeiter.

**********************************************************************
* Auslesen von Datensätzen
**********************************************************************
READ TABLE gt_mitarbeiter2 INDEX 2 INTO gs_mitarbeiter.
READ TABLE gt_mitarbeiter2 WITH TABLE KEY pernr = 1 INTO gs_mitarbeiter.
READ TABLE gt_mitarbeiter2 WITH KEY vorname = 'Hans' INTO gs_mitarbeiter.

CLEAR gs_mitarbeiter.
LOOP AT gt_mitarbeiter INTO gs_mitarbeiter WHERE pernr = 1.
  WRITE: gs_mitarbeiter-vorname, gs_mitarbeiter-name, gs_mitarbeiter-alter, /.
  CLEAR gs_mitarbeiter.
ENDLOOP.

**********************************************************************
* Verändern der Datensätze
**********************************************************************
SORT gt_mitarbeiter BY name ASCENDING.

gs_mitarbeiter-pernr   = 1.
gs_mitarbeiter-vorname = 'Peter'.
gs_mitarbeiter-name    = 'Meier'.
gs_mitarbeiter-alter   = 50.

* MODIFY TABLE gt_mitarbeiter2 FROM gs_mitarbeiter.
MODIFY gt_mitarbeiter2 FROM gs_mitarbeiter INDEX 1.

**********************************************************************
* Löschen von Datensätzen
**********************************************************************
DELETE TABLE gt_mitarbeiter2 FROM gs_mitarbeiter.

IF sy-subrc <> 0.
  WRITE 'Löchen hat nicht geklappt'.
ENDIF.

DELETE gt_mitarbeiter2 INDEX 2.
