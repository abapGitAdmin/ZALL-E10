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
REPORT zls_bc400_select_sflight.

* Prozentuale Auslastung von Flügen

DATA: gs_auslastung TYPE zls_sbc400focc.

PARAMETERS: gv_flge TYPE string.

SELECT spfli~carrid spfli~connid sflight~fldate sflight~seatsmax sflight~seatsocc
  FROM spfli JOIN sflight ON spfli~carrid = sflight~carrid
  INTO gs_auslastung
  WHERE airpto <> '' AND spfli~carrid = gv_flge.

  " Berechnung der Prozentualen Auslastung
  gs_auslastung-percentage = gs_auslastung-seatsocc / gs_auslastung-seatsmax * 100.

  WRITE: 'Der Flug mit der Nummer', gs_auslastung-connid,
         'ist am',  gs_auslastung-fldate,
         'zu', gs_auslastung-percentage, '% ausgelastet.', /.
  CLEAR gs_auslastung.

ENDSELECT.
