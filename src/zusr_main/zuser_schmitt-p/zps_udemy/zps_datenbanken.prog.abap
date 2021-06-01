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
REPORT ZPS_DATENBANKEN.

DATA: gt_spfli TYPE TABLE OF SPFLI,
      gs_spfli TYPE SPFLI.

SELECT * From SPFLI INTO TABLE gt_spfli WHERE carrid = 'LH'.
SELECT * From SPFLI INTO TABLE @DATA(gt_struc2).



LOOP AT gt_struc2 INTO gs_spfli .
  WRITE: gs_spfli-carrid, /.
ENDLOOP.
