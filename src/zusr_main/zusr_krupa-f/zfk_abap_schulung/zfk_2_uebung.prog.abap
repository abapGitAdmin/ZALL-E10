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
REPORT zfk_2_uebung.

**********************************************************************
* Strukturtyp definieren
**********************************************************************

TYPES: BEGIN OF lty_s_student,
         name    TYPE string,
         vorname TYPE string,
         mnr(10) TYPE n,
         sub     TYPE string,
         sem     TYPE i,
         dgr     TYPE string,
       END OF lty_s_student.
**********************************************************************
* Strukturen, Tabelle erzeugen und füllen
**********************************************************************
DATA: gs_stud1     TYPE lty_s_student,
*      gt_studenten TYPE SORTED TABLE OF lty_s_student WITH UNIQUE KEY mnr.
      gt_studenten TYPE TABLE OF lty_s_student WITH KEY mnr.

gs_stud1-name = 'Hesseler'.
gs_stud1-vorname = 'Martin'.
gs_stud1-mnr = 1.
gs_stud1-sub = 'ERP'.
gs_stud1-sem = 3.
gs_stud1-dgr = 'B.A.'.

INSERT gs_stud1 INTO TABLE gt_studenten.
CLEAR gs_stud1.

gs_stud1-name = 'Fuchs'.
gs_stud1-vorname = 'Sebastian'.
gs_stud1-mnr = 2.
gs_stud1-sub = 'WI'.
gs_stud1-sem = 2.
gs_stud1-dgr = 'B.A.'.

INSERT gs_stud1 INTO TABLE gt_studenten.
CLEAR gs_stud1.

gs_stud1-name = 'Weber'.
gs_stud1-vorname = 'Erik'.
gs_stud1-mnr = 4.
gs_stud1-sub = 'Statistik'.
gs_stud1-sem = 9.
gs_stud1-dgr = 'M.Sc.'.

INSERT gs_stud1 INTO TABLE gt_studenten.

**********************************************************************
* Löschen des Sebastians
**********************************************************************

CLEAR gs_stud1.
gs_stud1-mnr = 2.

DELETE TABLE gt_studenten FROM gs_stud1.

**********************************************************************
* Ausgabe über LOOP
**********************************************************************
CLEAR gs_stud1.

LOOP AT gt_studenten INTO gs_stud1 .
  WRITE: 'Name: ', gs_stud1-name,
    / 'Vorname: ', gs_stud1-vorname,
    / 'Matrikelnr.: ', gs_stud1-mnr,
    / 'Studienfach: ', gs_stud1-sub,
    / 'Semeseter: ', gs_stud1-sem,
    / 'Abschluss: ', gs_stud1-dgr, /.
  CLEAR gs_stud1.
ENDLOOP.
