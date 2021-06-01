************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: XXXXX-X                                      Datum: TT.MM.JJJJ
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************
report zdr_zz_0000_studenten.

types: begin of lty_s_student,
         name       type string,
         vorname    type string,
         matrikelnr type i,
         abschluss  type string,
       end of lty_s_student,
       lty_t_student type table of lty_s_student with key matrikelnr.

data: gs_student type lty_s_student,
      gt_student type lty_t_student.

gs_student-name = 'Mueller'.
gs_student-vorname = 'Alex'.
gs_student-matrikelnr = 1.
gs_student-abschluss = 'M.Sc.'.
insert gs_student into table gt_student.
clear gs_student.

gs_student-name = 'Meyer'.
gs_student-vorname = 'Tom'.
gs_student-matrikelnr = 2.
gs_student-abschluss = 'B.Sc.'.
insert gs_student into table gt_student.
clear gs_student.

gs_student-name = 'Holtmann'.
gs_student-vorname = 'Dieter'.
gs_student-matrikelnr = 3.
gs_student-abschluss = 'Prof. Dr.'.
insert gs_student into table gt_student.
clear gs_student.

delete gt_student where matrikelnr = 2.

loop at gt_student into gs_student.
  write: 'Name: ', gs_student-name, /,
         'Vorname: ', gs_student-vorname, /,
         'Matrikelnummer: ', gs_student-matrikelnr, /,
         'Abschluss: ', gs_student-abschluss, /.
  clear gs_student.
endloop.

write: 'Test'.
