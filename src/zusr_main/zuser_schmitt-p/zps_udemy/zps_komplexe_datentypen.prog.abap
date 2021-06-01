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
REPORT zps_komplexe_datentypen LINE-SIZE 50.

**********************************************************************
* Definition Strukturtyp
**********************************************************************

TYPES: BEGIN OF lty_s_mitarbeiter,            "lty_s_:= Lokalerstrukturtyp"
         pernr   TYPE i,
         name    TYPE string,
         vorname TYPE string,
         alter   TYPE i,
       END OF lty_s_mitarbeiter.

**********************************************************************
*interne Standardtabelle
**********************************************************************
TYPES lty_t_mitarbeiter TYPE STANDARD TABLE OF lty_s_mitarbeiter. "Tabellenstruktur definiert. (keine Var.)
DATA gt_mitarbeiter TYPE lty_t_mitarbeiter. " Eine Tabelle mit MA
**********************************************************************
*interne Tabellenvariable ohne definierten Tabellenstruktur
**********************************************************************

DATA gt_mitarbeiter2 TYPE SORTED TABLE OF lty_s_mitarbeiter WITH UNIQUE KEY pernr. "Tabellenvariable definiert ohne die definierte Tabellenstruktur verwendet zu haben.

DATA gs_mitarbeiter TYPE lty_s_mitarbeiter. " Ein Mitarbeiter

**********************************************************************
*Einfügen von D atensätzen
**********************************************************************
gs_mitarbeiter-name = 'Anders'.
gs_mitarbeiter-vorname = 'Marvin'.
gs_mitarbeiter-alter = 25.
gs_mitarbeiter-pernr = 2.
INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2.
CLEAR gs_mitarbeiter.

gs_mitarbeiter-name = 'Schmitt'.
gs_mitarbeiter-vorname = 'Philip'.
gs_mitarbeiter-alter = 23.
gs_mitarbeiter-pernr = 1.

INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2. " Oder: INSERT gs_mitarbeiter INTO gt_mitarbeiter INDEX 1.
CLEAR gs_mitarbeiter.

gs_mitarbeiter-name = 'Brux'.
gs_mitarbeiter-vorname = 'Pia'.
gs_mitarbeiter-alter = 22.
gs_mitarbeiter-pernr = 3.

INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2.
CLEAR gs_mitarbeiter.

**********************************************************************
*Mehrere Datensätze in eine interne Tabelle einfügen
**********************************************************************
APPEND LINES OF gt_mitarbeiter2 TO gt_mitarbeiter.
INSERT LINES OF gt_mitarbeiter2 INTO TABLE gt_mitarbeiter. " tut das gleice wie Line 71.
*INSERT LINES OF gt_mitarbeiter2 INTO TABLE gt_mitarbeiter2. "--> geht nicht. UNIQUE KEY würde verletzt werden beim einfügen
*INSERT LINES OF gt_mitarbeiter2 FROM 3 to 8 INTO TABLE gt_mitarbeiter. "Fügt die Datensätze von Index 3 bis 8 in die Tabelle ein

*********************************************************************
*Sortieren einer Tabelle
**********************************************************************
SORT gt_mitarbeiter BY name ASCENDING.

**********************************************************************
*Aulesen von Datensätzen
**********************************************************************
READ TABLE gt_mitarbeiter2 INDEX 2 INTO gs_mitarbeiter.
CLEAR gs_mitarbeiter.
READ TABLE gt_mitarbeiter2 WITH TABLE KEY pernr = 2 INTO gs_mitarbeiter.
CLEAR gs_mitarbeiter.
READ TABLE gt_mitarbeiter2 WITH KEY name = 'Schulte' INTO gs_mitarbeiter.

**********************************************************************
*Daten in einer Tabelle verändern
*********************************************************************
gs_mitarbeiter-name = 'Meier'.
MODIFY TABLE gt_mitarbeiter2 FROM gs_mitarbeiter. "Verwendet zur Identifikation des zu ändernden Datensaztes den PK
gs_mitarbeiter-name = 'Anders'.
MODIFY gt_mitarbeiter2 FROM gs_mitarbeiter INDEX 2. "Wenn kein PK existiert oder nicht verwendet werden soll

**********************************************************************
*Löschen von Datensätzen aus einer Tabelle
**********************************************************************
DELETE TABLE gt_mitarbeiter2 FROM gs_mitarbeiter.
DELETE gt_mitarbeiter2 INDEX 1.
**********************************************************************
*Mehrere Dtensätze auslesn
**********************************************************************
LOOP AT gt_mitarbeiter2 INTO gs_mitarbeiter WHERE pernr > 0.
  WRITE gs_mitarbeiter-name.
  CLEAR gs_mitarbeiter.
ENDLOOP.
