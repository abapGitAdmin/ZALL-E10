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
REPORT zboe_programm LINE-SIZE 50. "Ausgabebreit der Liste festlegen

DATA: gv_name     TYPE string VALUE 'Klaus',
      gv_nachname TYPE zboe_nachname VALUE 'Meyer',
      gv_strasse  TYPE string,
      gv_alter    TYPE i.

WRITE: gv_name, "einfache WRITE Ausgabe
     / gv_nachname. "Zeilenumbruch

SKIP 3. "Überspring 3 Zeilen bei der Ausgabe
ULINE. "Unterstreicht eine Zeile
