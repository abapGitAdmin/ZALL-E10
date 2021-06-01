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
REPORT zps_uebung_udemy_1.

**********************************************************************
*Strukturtyp
**********************************************************************
TYPES:BEGIN OF lyt_s_student,
        name            TYPE string,
        vorname         TYPE string,
        matrikel_nr(10) TYPE n,
        studienfach     TYPE string,
        semester        TYPE i,
        abschluss(5)    TYPE c,
      END OF lyt_s_student,
      lyt_t_studenten TYPE TABLE OF lyt_s_student WITH KEY matrikel_nr . "Tabellenstruktur

DATA: gt_studenten TYPE lyt_t_studenten, "Tabelle
      gs_student   TYPE lyt_s_student. "Student

**********************************************************************
*Erste struktur + Ausgabe
**********************************************************************
gs_student-name = 'Schmitt'.
gs_student-vorname = 'Philip'.
gs_student-matrikel_nr = '7201488'.
gs_student-studienfach = 'Wirtschaftsinformatik'.
gs_student-semester = 5.
gs_student-abschluss = 'B.A.'.


WRITE: 'Name:', gs_student-name,/ 'Vorname:' ,  gs_student-vorname,
       / 'Matrikelnr:',  gs_student-matrikel_nr,
       / 'Studienfach:',  gs_student-studienfach,
       / 'Semester:',  gs_student-semester,
       / 'Abschluss:',   gs_student-abschluss.

**********************************************************************
*Datensätze anlegen
**********************************************************************
INSERT gs_student INTO TABLE gt_studenten.
CLEAR gs_student.

gs_student-name = 'Scholz'.
gs_student-vorname = 'Luisa'.
gs_student-matrikel_nr = '7201489'.
gs_student-studienfach = 'Wirtschaftsinformatik'.
gs_student-semester = 5.
gs_student-abschluss = 'B.A.'.

INSERT gs_student INTO TABLE gt_studenten.
CLEAR gs_student.

gs_student-name = 'Schulte'.
gs_student-vorname = 'Marvin'.
gs_student-matrikel_nr = '7201490'.
gs_student-studienfach = 'Wirtschaftsinformatik'.
gs_student-semester = 4.
gs_student-abschluss = 'B.A.'.

INSERT gs_student INTO TABLE gt_studenten.
CLEAR gs_student.

gs_student-name = 'Scholz'.
gs_student-vorname = 'Lisa'.
gs_student-matrikel_nr = '7201418'.
gs_student-studienfach = 'Wirtschaftsinformatik'.
gs_student-semester = 5.
gs_student-abschluss = 'B.A.'.

INSERT gs_student INTO TABLE gt_studenten.
CLEAR gs_student.

**********************************************************************
*Löschen
**********************************************************************
DELETE TABLE gt_studenten WITH TABLE KEY matrikel_nr = 7201488.
DELETE gt_studenten WHERE matrikel_nr = 2.

**********************************************************************
*Ausgabe der Studenten
**********************************************************************
LOOP AT gt_studenten INTO gs_student.
  WRITE: 'Name:', gs_student-name,/ 'Vorname:' ,  gs_student-vorname,
       / 'Matrikelnr:',  gs_student-matrikel_nr,
       / 'Studienfach:',  gs_student-studienfach,
       / 'Semester:',  gs_student-semester,
       / 'Abschluss:',   gs_student-abschluss.
  ULINE.
  CLEAR gs_student.
ENDLOOP.
