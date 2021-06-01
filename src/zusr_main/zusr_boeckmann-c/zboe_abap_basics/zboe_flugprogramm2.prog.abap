************************************************************************
*            _                                _____
*           | |                         /\   / ____|
*   __ _  __| | ___  ___ ___  ___      /  \ | |  __
*  / _` |/ _` |/ _ \/ __/ __|/ _ \    / /\ \| | |_ |
* | (_| | (_| |  __/\__ \__ \ (_) |  / ____ \ |__| |
*  \__,_|\__,_|\___||___/___/\___/  /_/    \_\_____|
*
* Author: BOECKMANN-C                                  Datum: 21.05.2019
*
* Beschreibung:
*
************************************************************************
* Änderungen:
* Nutzer      Datum      Beschreibung
* XXXXX-X     TT.MM.JJJJ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
************************************************************************

REPORT zboe_flugprogramm2.

**********************************************************************
* Struktur anlegen, um die Daten des Joins speichern zu können
**********************************************************************
TYPES: BEGIN OF lty_stastistik,
         carrid    TYPE spfli-carrid,
         carrname  TYPE scarr-carrname,
         flugdauer TYPE spfli-fltime,
       END OF lty_stastistik.

DATA: gs_stastistik    TYPE lty_stastistik,
      gt_stastistik   TYPE TABLE OF lty_stastistik.
**********************************************************************
* Join Anweisung
**********************************************************************
SELECT spfli~carrid carrname MAX( fltime ) AS flugdauer
  FROM spfli JOIN scarr ON spfli~carrid = scarr~carrid
   INTO CORRESPONDING FIELDS OF TABLE gt_stastistik
     WHERE spfli~fltype = 'X'
        GROUP BY spfli~carrid carrname
          HAVING AVG( fltime ) > 420
           ORDER BY flugdauer DESCENDING. "#EC CI_BUFFJOIN
**********************************************************************
* Ausgabe der Ergebnisse
**********************************************************************
IF sy-subrc <> 0.
  WRITE 'Es ist ein Fehler aufgetreten!'.
ELSE.
  LOOP AT gt_stastistik INTO gs_stastistik.
    WRITE: / gs_stastistik-carrid, gs_stastistik-carrname, gs_stastistik-flugdauer.
    ULINE.
  ENDLOOP.
ENDIF.
