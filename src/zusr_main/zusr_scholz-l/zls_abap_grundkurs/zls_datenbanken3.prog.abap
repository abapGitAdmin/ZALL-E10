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
REPORT zls_datenbanken3.



TYPES: BEGIN OF lty_join_struc,
         carrid   TYPE spfli-carrid,
         carrname TYPE scarr-carrname,
         auer     TYPE spfli-fltime,
       END OF lty_join_struc.

DATA: gt_spfli  TYPE TABLE OF spfli,
      gs_spfli  TYPE spfli,
      gs_join   TYPE lty_join_struc,
      gt_join   TYPE TABLE OF lty_join_struc,
      gv_fltime TYPE s_fltime.

* SELECT AVG( fltime ) FROM spfli INTO gv_fltime WHERE carrid = 'LH'.

SELECT spfli~carrid carrname AVG( fltime ) AS dauer
  FROM spfli JOIN scarr ON spfli~carrid = scarr~carrid
  INTO CORRESPONDING FIELDS OF TABLE gt_join
  GROUP BY spfli~carrid carrname
  HAVING AVG( fltime ) > 400
  ORDER BY dauer ASCENDING.

IF sy-subrc <> 0.
  WRITE: 'Fehler'.
ELSE.
  WRITE: 'Erfolg'.

ENDIF.
