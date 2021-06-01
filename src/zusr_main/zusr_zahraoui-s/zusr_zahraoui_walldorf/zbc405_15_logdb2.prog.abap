*&---------------------------------------------------------------------*
*& Report  ZBC405_15_LOGDB2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zbc405_logdb_s3_top                     .    " global Data

* INCLUDE ZBC405_LOGDB_S3_O01                     .  " PBO-Modules
* INCLUDE ZBC405_LOGDB_S3_I01                     .  " PAI-Modules
* INCLUDE ZBC405_LOGDB_S3_F01                     .  " FORM-Routines
" event

*INITIALIZATION.
*  carrid-sign = 'I'.
*  carrid-option = 'BT'.
*  carrid-low = 'AA'.
*  carrid-high = 'LH'.
*  APPEND carrid.
  "Üb15 direkt nach Initialisation gibt es event at selection screen output.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'AIRP_TO'.
      screen-name = 0.
      MODIFY SCREEN.

    ENDIF.
  ENDLOOP.
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
  " aufagbe 15 ab hier soll überprüft, ob mit seloctuion option
  CHECK so_kund.
  WRITE: sbook-bookid,
         sbook-customid,
         sbook-smoker,
         sbook-luggweight UNIT sbook-wunit,
         sbook-wunit,
         sbook-order_date.
  " üb15 get spfli late bezüglich spfli hier flugverbindung und

GET spfli LATE.
  ULINE.
  NEW-PAGE.

*GET sflight LATE.
*  ULINE.
