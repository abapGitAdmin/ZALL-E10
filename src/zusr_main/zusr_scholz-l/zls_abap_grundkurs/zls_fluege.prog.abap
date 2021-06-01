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
REPORT zls_fluege.

DATA: lt_fluege TYPE TABLE OF spfli,
      ls_flug   TYPE spfli.

PARAMETERS pa_ges TYPE spfli-carrid.

CALL FUNCTION 'Z_LS_GET_FLUEGE'
  EXPORTING
    carrid = pa_ges
  IMPORTING
    LISTE  = lt_fluege
  .


IF sy-subrc <> 0.
  WRITE 'Fehler!'.
ELSE.
  LOOP AT lt_fluege INTO ls_flug.
    WRITE: ls_flug-connid, ls_flug-cityfrom, ls_flug-countryfr, ls_flug-cityto, ls_flug-countryto, /.
  ENDLOOP.
ENDIF.
