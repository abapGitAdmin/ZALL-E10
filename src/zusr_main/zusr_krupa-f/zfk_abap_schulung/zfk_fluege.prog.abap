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
REPORT zfk_fluege.

PARAMETERS: p_ges TYPE spfli-carrid.

DATA: lt_fluege TYPE TABLE OF spfli,
      ls_fluege TYPE spfli.

CALL FUNCTION 'Z_FK_GETFLIGHTS'
  EXPORTING
    gsid    = p_ges
  importing
    flights = lt_fluege.



IF sy-subrc <> 0.
  WRITE 'Eine passende Fehlermeldung'.
ELSE.
  LOOP AT lt_fluege INTO ls_fluege.
    WRITE:ls_fluege-connid, ls_fluege-cityfrom, ls_fluege-countryfr, ls_fluege-cityto, ls_fluege-countryto, /.
  ENDLOOP.

ENDIF.
