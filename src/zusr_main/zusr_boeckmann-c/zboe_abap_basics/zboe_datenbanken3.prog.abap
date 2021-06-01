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

REPORT zboe_datenbanken3.

TYPES: BEGIN OF lty_join_struc,
         carrid    TYPE spfli-carrid,
*        connid    TYPE spfli-connid,
         carrname  TYPE scarr-carrname,
         flugdauer TYPE spfli-fltime,
       END OF lty_join_struc.

DATA: gt_flug   TYPE TABLE OF spfli,
      gs_flug   TYPE spfli,
      gs_join   TYPE lty_join_struc,
      gt_join   TYPE TABLE OF lty_join_struc,
      gv_fltime TYPE s_fltime.

*SELECT AVG( fltime ) FROM spfli INTO gv_fltime WHERE carrid = 'LH'.
SELECT spfli~carrid carrname AVG( fltime ) AS flugdauer
  FROM spfli JOIN scarr ON spfli~carrid = scarr~carrid
   INTO CORRESPONDING FIELDS OF TABLE gt_join
*    WHERE spfli-carrid = 'LH' OR spfli-carrid = 'AA'
        GROUP BY spfli~carrid carrname
          HAVING AVG( fltime ) > 400
           ORDER BY flugdauer ASCENDING.

IF sy-subrc <> 0.
  WRITE 'Es ist ein Fehler aufgetreten!'.
ELSE.
  WRITE: 'Durchschnittliche Flugdauer: ', gv_fltime.
ENDIF.

LOOP AT gt_join INTO gs_join.
  WRITE: gs_join-carrid, gs_join-carrname, gs_join-flugdauer, /.
ENDLOOP.
