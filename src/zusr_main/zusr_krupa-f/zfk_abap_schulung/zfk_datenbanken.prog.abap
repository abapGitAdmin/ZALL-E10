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
REPORT ZFK_DATENBANKEN.

DATA: gt_spfli TYPE TABLE OF SPFLI,
      gs_spfli TYPE SPFLI.

SELECT * FROM SPFLI INTO TABLE gt_spfli WHERE carrid = 'LH'.

  LOOP AT gt_spfli INTO gs_spfli.
      Write: gs_spfli-carrid.
  ENDLOOP.
