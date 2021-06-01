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
REPORT ZLS_STUDENT_STRUKTUR.

**********************************************************************
* Aufgabe 1: Struktur anlegen
**********************************************************************
TYPES: BEGIN OF lty_s_student,
  name           TYPE string,
  vorname        TYPE strng,
  matrikelnr(10) TYPE n,
  studienfach    TYPE string,
  semester       TYPE i,
  abschluss      TYPE string,
END OF lty_s_student.

DATA gs_student TYPE lty_s_student.

gs_student-name        = 'Mustermann'.
gs_student-vorname     = 'Max'.
gs_student-matrikelnr  = '1234567'.
gs_student-studienfach = 'Architektur'.
gs_student-semester     = 4.
gs_student-abschluss   = 'B.A.'.

WRITE: gs_student-name,
       gs_student-vorname,
       gs_student-matrikelnr,
       gs_student-studienfach,
       gs_student-semester,
       gs_student-abschluss.

**********************************************************************
* Aufgabe 2: Tabelle anlegen
**********************************************************************
DATA gt_student TYPE TABLE OF lty_s_student WITH KEY matrikelnr.

APPEND gs_student TO gt_student.
CLEAR gs_student.

gs_student-name        = 'Meier'.
gs_student-vorname     = 'Marius'.
gs_student-matrikelnr  = '999'.
gs_student-studienfach = 'Informatik'.
gs_student-semester     = 2.
gs_student-abschluss   = 'M.Sc.'.

APPEND gs_student TO gt_student.
CLEAR gs_student.

gs_student-name        = 'Scholz'.
gs_student-vorname     = 'Lena'.
gs_student-matrikelnr  = '7201392'.
gs_student-studienfach = 'Wirtschaftsinformatik'.
gs_student-semester     = 4.
gs_student-abschluss   = 'B.A.'.

APPEND gs_student TO gt_student.
CLEAR gs_student.

DELETE gt_student INDEX 2.

CLEAR gs_student.
LOOP AT gt_student INTO gs_student.
  WRITE: gs_student-name,
         gs_student-vorname,
         gs_student-matrikelnr,
         gs_student-studienfach,
         gs_student-semester,
         gs_student-abschluss.
  CLEAR gs_student.
ENDLOOP.






**********************************************************************
* Struktur
**********************************************************************
TYPES: BEGIN OF lty_s_obst,
  sorte TYPE string,
  anzahl TYPE i,
END OF lty_s_obst.

DATA gs_obst TYPE lty_s_obst.

gs_obst-sorte = 'Apfel'.
gs_obst-anzahl = 12.

WRITE: gs_obst-sorte, gs_obst-anzahl.

**********************************************************************
* Tabelle
**********************************************************************
DATA gt_obst TYPE TABLE OF lty_s_obst.

APPEND gs_obst TO gt_obst.
CLEAR gs_obst.

gs_obst-sorte = 'Birne'.
gs_obst-anzahl = 10.

APPEND gs_obst TO gt_obst.
CLEAR gs_obst.

gs_obst-sorte = 'Clementine'.
gs_obst-anzahl = 19.

APPEND gs_obst TO gt_obst.
CLEAR gs_obst.

LOOP AT gt_obst INTO gs_obst WHERE anzahl >= 12.
  WRITE: gs_obst-sorte, gs_obst-anzahl.
  CLEAR gs_obst.
ENDLOOP.







**********************************************************************
* Neue Übung
**********************************************************************
TYPES: BEGIN OF lty_s_farbe,
  name    TYPE string,
  code(6) TYPE c,
END OF lty_s_farbe.

DATA gs_farbe TYPE lty_s_farbe.

gs_farbe-name = 'rot'.
gs_farbe-code = 'FF0000'.

***** Tabelle *****
DATA gt_farbe TYPE TABLE OF lty_s_farbe WITH KEY code.

APPEND gs_farbe TO gt_farbe.
CLEAR gs_farbe.

gs_farbe-name = 'blau'.
gs_farbe-code = '0000FF'.
APPEND gs_farbe TO gt_farbe.
CLEAR gs_farbe.

LOOP AT gt_farbe INTO gs_farbe.
  WRITE: gs_farbe-name, gs_farbe-code.
  CLEAR gs_farbe.
ENDLOOP.
