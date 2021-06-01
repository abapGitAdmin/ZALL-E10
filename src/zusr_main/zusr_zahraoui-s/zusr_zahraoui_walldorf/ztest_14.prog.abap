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
REPORT ztest_14.

NODES: spfli, sflight, sbook.
DATA: gv_freie_plaetze TYPE sflight-seatsocc.


INITIALIZATION.
  carrid-sign = 'I'.
  carrid-option = 'BT'.
  carrid-low = 'AA'.
  carrid-high = 'LH'.
  APPEND carrid.


  " Event get spfli
  " output write

GET spfli.
  WRITE: spfli-carrid,
         spfli-connid,
         spfli-cityfrom,
         spfli-airpfrom,
         spfli-cityto,
         spfli-airpto.
  "Event spflight.

GET sflight.
  " berechnug frei plltzr

  gv_freie_plaetze = sflight-seatsmax - sflight-seatsocc.

  " Ausgabe
  WRITE: sflight-fldate,
         sflight-price ,
         sflight-currency CURRENCY sflight-currency ,
         sflight-planetype,
         sflight-seatsmax,
         sflight-seatsocc,
         gv_freie_plaetze.

  " Event von Scbook
  GET sbook.
  WRITE: sbook-bookid,
         sbook-customid,
         sbook-smoker,
         sbook-luggweight UNIT sbook-wunit,
         sbook-wunit.
