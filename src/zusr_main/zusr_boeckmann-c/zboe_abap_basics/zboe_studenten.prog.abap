************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 15.05.2019
*
* Beschreibung: Praxis Übung 01
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
REPORT zboe_studenten.

TYPES: BEGIN OF lty_s_studenten,
         name           TYPE string,
         vorname        TYPE string,
         matrikelnummer TYPE i,
         studienfach    TYPE string,
         semester       TYPE i,
         abschluss      TYPE string,
       END OF lty_s_studenten.

DATA gs_studenten TYPE lty_s_studenten.
*gs_studenten-name           = 'Mustermann'.
*gs_studenten-vorname        = 'Max'.
*gs_studenten-matrikelnummer = '0001234567'.
*gs_studenten-studienfach    = 'Architektur'.
*gs_studenten-semester       = 4.
*gs_studenten-abschluss      = 'B.A.'.
*
*WRITE: / 'Name:',gs_studenten-name,
*/ 'Vorname:', gs_studenten-vorname,
*/ 'Matrikelnummer:',gs_studenten-matrikelnummer,
*/ 'Studienfach:',gs_studenten-studienfach,
*/ 'Semester:',gs_studenten-semester,
*/ 'Studienabschluss:',gs_studenten-abschluss.

**********************************************************************
* Tabellen Typ anlegen und mit Daten füllen
**********************************************************************
DATA gt_studenten TYPE SORTED TABLE OF lty_s_studenten WITH UNIQUE KEY matrikelnummer.

gs_studenten-name           = 'Mustermann'.
gs_studenten-vorname        = 'Max'.
gs_studenten-matrikelnummer = '0001234567'.
gs_studenten-studienfach    = 'Architektur'.
gs_studenten-semester       = 4.
gs_studenten-abschluss      = 'B.A.'.
INSERT gs_studenten INTO TABLE gt_studenten.
CLEAR gs_studenten.

gs_studenten-name           = 'Meyer'.
gs_studenten-vorname        = 'Maris'.
gs_studenten-matrikelnummer = '0000009999'.
gs_studenten-studienfach    = 'Informatik'.
gs_studenten-semester       = 2.
gs_studenten-abschluss      = 'M.A.'.
INSERT gs_studenten INTO TABLE gt_studenten.
CLEAR gs_studenten.

gs_studenten-name           = 'Schmidt'.
gs_studenten-vorname        = 'Peter'.
gs_studenten-matrikelnummer = '0005612784'.
gs_studenten-studienfach    = 'Architektur'.
gs_studenten-semester       = 4.
gs_studenten-abschluss      = 'B.A.'.
INSERT gs_studenten INTO TABLE gt_studenten.
CLEAR gs_studenten.

DELETE gt_studenten INDEX 2.

LOOP AT gt_studenten INTO gs_studenten.
  WRITE: / 'Name:',gs_studenten-name,
         / 'Vorname:', gs_studenten-vorname,
         / 'Matrikelnummer:',gs_studenten-matrikelnummer,
         / 'Studienfach:',gs_studenten-studienfach,
         / 'Semester:',gs_studenten-semester,
         / 'Studienabschluss:',gs_studenten-abschluss.
  ULINE.
  CLEAR gs_studenten. " Struktur löschen damit keine falschen Werte gespeichert werden beim nächsten Durchlauf
ENDLOOP.
