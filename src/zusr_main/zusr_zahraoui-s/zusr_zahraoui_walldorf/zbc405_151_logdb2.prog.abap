*&---------------------------------------------------------------------*
*& Report  ZBC405_15_LOGDB2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE ZBC405_LOGDB_15_TOP.
*INCLUDE ZBC405_LOGDB_S3_TOP                     .    " global Data

* INCLUDE ZBC405_LOGDB_S3_O01                     .  " PBO-Modules
* INCLUDE ZBC405_LOGDB_S3_I01                     .  " PAI-Modules
* INCLUDE ZBC405_LOGDB_S3_F01                     .  " FORM-Routines
" event
INITIALIZATION.
  carrid-sign = 'I'.
  carrid-option = 'BT'.
  carrid-low = 'AA'.
  carrid-high = 'LH'.
  APPEND carrid.


  " Event get spfli
  " output write


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
