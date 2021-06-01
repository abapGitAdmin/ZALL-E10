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
REPORT z_test_678_1.

TABLES ztc_studenten.

DATA gt_student TYPE TABLE OF ztc_studenten.
"DATA gs_student LIKE LINE OF gt_student.
DATA gs_student TYPE ztc_studenten.

gs_student-matrikelnummer = 8.
gs_student-name = 'abc'.
gs_student-vorname = 'Sabine'.
gs_student-geschlecht = 'W'.
gs_student-studiengang = 'Soziologie'.







UPDATE ZTC_STUDenten FROM gs_student.



IF sy-subrc = 0.
  WRITE 'Erfolg'.
  else.
    WRITE 'fehler'.


ENDIF.












"Modify




"Delete















































































*
*DATA zahl0 TYPE i VALUE 5.
*
*DATA erg TYPE p DECIMALS 3.
*DATA gepacktezahl TYPE p DECIMALS 2 VALUE '3432'.
*DATA gepacktezahl2 TYPE p DECIMALS 2 VALUE '11'.
*DATA wort TYPE string VALUE 'Mein name ist Hans'.
*
*TRANSLATE wort TO UPPER CASE.
*write wort.
*
*WRITE text-001.
*
*DATA zahl1 TYPE i VALUE 5.
*DATA zahl2 LIKE zahl1 VALUE 10.
*
*
*
*
*
*
*
*
*TRANSLATE wort TO UPPER CASE.
*write wort.
*
*WRITE text-001.
*
*DATA zahl3 TYPE i VALUE 5.
*DATA zahl4 LIKE zahl1 VALUE 10.
*
*
*
*
*
*TRANSLATE wort TO UPPER CASE.
*write wort.
*
*WRITE text-001.
*
*
*TYPES: BEGIN OF fahrzeug,
*         nummer TYPE i,
*         model TYPE char20,
*         farbe TYPE char10,
*         ps    TYPE i,
*       END OF fahrzeug.
*
*
*
*
*DATA mercedes TYPE fahrzeug.
*
*DATA itab TYPE Sorted TABLE OF fahrzeug WITH UNIQUE Key nummer.
*DATA wa LIKE LINE OF itab.
*
*mercedes-nummer = 1.
*mercedes-model = 'amg'.
*mercedes-farbe ='black'.
*mercedes-ps = 400.
*APPEND mercedes to itab.
*
*
*
*mercedes-nummer = 2.
*mercedes-model = 'S'.
*mercedes-farbe ='white'.
*mercedes-ps = 370.
*APPEND mercedes to itab.
*
*
*mercedes-nummer = 3.
*mercedes-model = 'E'.
*mercedes-farbe ='red'.
*mercedes-ps = 400.
*APPEND mercedes to itab.
*
*
*mercedes-nummer = 4.
*mercedes-model = 'A'.
*mercedes-farbe ='blue'.
*mercedes-ps = 370.
*APPEND mercedes to itab.
*
*mercedes-nummer = 5.
*mercedes-model = 'G'.
*mercedes-farbe ='silver'.
*mercedes-ps = 400.
*APPEND mercedes to itab.
*"delete itab INDEX 3." muss eine interne Tabelle sein
*
*
*mercedes-nummer = 6.
*mercedes-model = 'C'.
*mercedes-farbe ='green'.
*mercedes-ps = 370.
*APPEND mercedes to itab.
*
*clear wa.
*
*loop at itab INTO wa WHERE farbe = 'black'.
*  WRITE sy-tabix.
*  WRITE / : wa-nummer,
*          wa-model,
*          wa-farbe,
*          wa-ps.
*
*  ULINE.
*
*
*
*  ENDLOOP.


*TYPES: BEGIN OF student,
*         name           TYPE string,
*         vorname        TYPE string,
*         matrikelnummer TYPE char10,
*         studienfach    TYPE string,
*         semester       TYPE i,
*         abschluss      TYPE string,
*       END OF student.
*
*
*TYPES: lt_stud TYPE STANDARD TABLE OF student WITH KEY matrikelnummer.
*
*
*
*DATA gtstudenten TYPE lt_stud.
*DATA gsstudenten LIKE LINE OF gtstudenten.
*
*
*
*gsstudenten-name = 'Mustermann'.
*gsstudenten-vorname = 'Max'.
*gsstudenten-matrikelnummer = 0001234567.
*gsstudenten-studienfach = 'Architektur'.
*gsstudenten-semester = 4.
*gsstudenten-abschluss = 'B.A.'.
*INSERT gsstudenten INTO TABLE gtstudenten.
*CLEAR gsstudenten.
*
*gsstudenten-name = 'Cayli'.
*gsstudenten-vorname = 'Taha'.
*gsstudenten-matrikelnummer = 03242424324.
*gsstudenten-studienfach = 'Info'.
*gsstudenten-semester = 9.
*gsstudenten-abschluss = 'B.A.'.
*INSERT gsstudenten INTO TABLE gtstudenten.
*CLEAR gsstudenten.
*
*gsstudenten-name = 'dscdcdsc'.
*gsstudenten-vorname = 'sdcsdc'.
*gsstudenten-matrikelnummer = 99999999.
*gsstudenten-studienfach = 'Architektur'.
*gsstudenten-semester = 1.
*gsstudenten-abschluss = 'B.A.'.
*INSERT gsstudenten INTO TABLE gtstudenten.
*CLEAR gsstudenten.
*
*LOOP AT gtstudenten INTO gsstudenten.
*
*  WRITE: / 'Name: ', gsstudenten-name,
*       / 'Vorname: ', gsstudenten-vorname,
*       / 'Matrikelnummer: ', gsstudenten-matrikelnummer,
*       / 'Studienfach: ', gsstudenten-studienfach,
*       / 'Semester: ', gsstudenten-semester,
*       / 'Abschluss: ', gsstudenten-abschluss.
*SKIP.
*ENDLOOP.
*
*DELETE gtstudenten WHERE matrikelnummer = 99999999.
*
*ULINE.
*
*LOOP AT gtstudenten INTO gsstudenten.
*
*  WRITE: / 'Name: ', gsstudenten-name,
*       / 'Vorname: ', gsstudenten-vorname,
*       / 'Matrikelnummer: ', gsstudenten-matrikelnummer,
*       / 'Studienfach: ', gsstudenten-studienfach,
*       / 'Semester: ', gsstudenten-semester,
*       / 'Abschluss: ', gsstudenten-abschluss.
*skip.
*ENDLOOP.

*
*WRITE: / 'Name: ', gsstudenten-name,
*       / 'Vorname: ', gsstudenten-vorname,
*       / 'Matrikelnummer: ', gsstudenten-matrikelnummer,
*       / 'Studienfach: ', gsstudenten-studienfach,
*       / 'Semester: ', gsstudenten-semester,
*       / 'Abschluss: ', gsstudenten-Abschluss.


"INCLUDE ZTahaInclude.
