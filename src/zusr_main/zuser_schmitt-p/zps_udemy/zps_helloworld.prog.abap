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
REPORT zps_helloworld LINE-SIZE 50. "Ausgabebreite der Liste beschränken auf 50 Zeichen"


*--------------------------------------------------------------------------*
*DATA gv_name TYPE string. "ohne Vorbelegung"
*DATA gv_nachname TYPE string VALUE 'Schmitt'. "mit Vorbelegung"
*DATA gv_alter TYPE integer.

*----------------------------------Kettensatz-----------------------------*
DATA: gv_name     TYPE string,
      gv_nachname TYPE string VALUE 'Schmitt',
      gv_alter    TYPE i.

*--------------------------------------------------------------------------*

gv_name = 'Philip'    .   "Wert zuweisung"

*--------------------------------------------------------------------------*
WRITE: 'HELLO WORLD!',
       /'Udemy',
        'Grundkurs',
       / gv_name,            "Ausgabe der Variable"
         gv_nachname .
ULINE."fügt eine Linie in der nächsten Zeile ein"
SKIP 3. "Überspringt 3 Zeilen"
WRITE 'Hier geht es weiter.'.
