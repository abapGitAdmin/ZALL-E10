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
REPORT zboe_komplexe_datentypen.

TYPES: BEGIN OF lty_s_mitarbeiter,
         pernr   TYPE i,
         vorname TYPE string,
         name    TYPE string,
         alter   TYPE i,
       END OF lty_s_mitarbeiter.

* erzeugt eine Tabelle vom Type der Struktur lty_s_mitarbeiter
TYPES lty_lt_mitarbeiter TYPE TABLE OF lty_s_mitarbeiter.

DATA gs_mitarbeiter TYPE lty_s_mitarbeiter.
DATA gt_mitarbeiter TYPE lty_lt_mitarbeiter.
* Alternative Notation die ohne Definition des Tabellentypes auskommt
DATA gt_mitarbeiter2 TYPE SORTED TABLE OF lty_s_mitarbeiter WITH UNIQUE KEY pernr.

gs_mitarbeiter-pernr = 2.
gs_mitarbeiter-vorname = 'Hans'.
gs_mitarbeiter-name = 'Peter'.
gs_mitarbeiter-alter = 50.
*APPEND gs_mitarbeiter TO gt_mitarbeiter2.
INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2.
CLEAR gs_mitarbeiter.

gs_mitarbeiter-pernr = 1.
gs_mitarbeiter-vorname = 'Paul'.
gs_mitarbeiter-name = 'Müller'.
gs_mitarbeiter-alter = 23.
*APPEND gs_mitarbeiter TO gt_mitarbeiter2.
INSERT gs_mitarbeiter INTO TABLE gt_mitarbeiter2.

*Insert mit INDEX -> Muss manuell angegeben werden um den Datensatz an der richtigen Stelle einzufügen
*INSERT gs_mitarbeiter INTO gt_mitarbeiter2 INDEX 1.

**********************************************************************
* Auslesen einer internen Tabelle
**********************************************************************

CLEAR gs_mitarbeiter.

**********************************************************************
* Anhängen von mehreren Zeilen an eine Tabelle
**********************************************************************
APPEND LINES OF gt_mitarbeiter2 TO gt_mitarbeiter.
*INSERT LINES OF gt_mitarbeiter2 INTO TABLE gt_mitarbeiter2.
INSERT LINES OF gt_mitarbeiter2 INTO TABLE gt_mitarbeiter.


**********************************************************************
* Anhängen von Zeilen mit Einschränkungen
**********************************************************************
INSERT LINES OF gt_mitarbeiter2 FROM 1 TO 2 INTO TABLE gt_mitarbeiter.

READ TABLE gt_mitarbeiter2 INDEX 2 INTO gs_mitarbeiter.
READ TABLE gt_mitarbeiter2 WITH TABLE KEY pernr = 1 INTO gs_mitarbeiter.
READ TABLE gt_mitarbeiter2 WITH KEY name = 'Peter' INTO gs_mitarbeiter.

*Mehrere Datensätze mit Hilfe von LOOP auslesen
LOOP AT gt_mitarbeiter INTO gs_mitarbeiter WHERE pernr = 1 AND name = 'Meyer'.
  WRITE: gs_mitarbeiter-vorname, gs_mitarbeiter-name, gs_mitarbeiter-alter, /.
  CLEAR gs_mitarbeiter. " Struktur löschen damit keine falschen Werte gespeichert werden beim nächsten Durchlauf
ENDLOOP.
**********************************************************************
* Zeile einer Tabelle modifizieren
**********************************************************************
SORT gt_mitarbeiter BY name ASCENDING. "Tabelle sortieren nach Namen aufsteigend -> SORTED TABLE und HASED TABLE können nicht sortiert werden!

gs_mitarbeiter-pernr = 2.
gs_mitarbeiter-vorname = 'Hans'.
gs_mitarbeiter-name = 'Meyer'.
gs_mitarbeiter-alter = 50.

MODIFY TABLE gt_mitarbeiter2 FROM gs_mitarbeiter. "Wenn Primärschlüssel vorhanden
MODIFY gt_mitarbeiter2 FROM gs_mitarbeiter INDEX 2. " Wenn kein Primärschlüssel vorhanden / wenn er nicht verwendet werden soll!

**********************************************************************
* Zeile einer Tabelle löschen
**********************************************************************
DELETE TABLE gt_mitarbeiter2 FROM gs_mitarbeiter. "Sucht Zeile auf Basis des Primärschlüssels und löscht
  IF sy-subrc <> 0.
    WRITE: 'Löschen nicht erfolgreich!'.
  ENDIF.
DELETE gt_mitarbeiter2 INDEX 2.

WRITE: gs_mitarbeiter-vorname, gs_mitarbeiter-name, gs_mitarbeiter-alter.
