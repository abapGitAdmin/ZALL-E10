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
REPORT zls_datenbanken.

DATA: gt_spfli TYPE TABLE OF spfli,
      gs_spfli TYPE spfli.

SELECT * FROM spfli INTO TABLE gt_spfli WHERE carrid = 'LH'.
SELECT SINGLE * FROM spfli INTO gs_spfli WHERE carrid = 'LH'.


IF sy-subrc <> 0.
  WRITE 'Fehler!'.
ELSE.
  LOOP AT gt_spfli INTO gs_spfli.
    WRITE: gs_spfli-carrid, gs_spfli-connid, /.
  ENDLOOP.
ENDIF.
