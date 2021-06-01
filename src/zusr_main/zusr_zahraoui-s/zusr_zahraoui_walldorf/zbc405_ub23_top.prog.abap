*&---------------------------------------------------------------------*
*&  Include           ZBC405_UB23_TOP
*&---------------------------------------------------------------------*
DATA:
  gt_flights TYPE TABLE OF sflight,
  gs_flights TYPE sflight.

" 2 Selectionop
SELECT-OPTIONS:
so_car FOR gs_flights-carrid,
so_con FOR gs_flights-connid.


SELECTION-SCREEN BEGIN OF BLOCK ki WITH FRAME TITLE t2.

  PARAMETERS: pa_fulls radiobutton GROUP r1 DEFAULT 'X',
              pa_list RADIOBUTTON GROUP r1,
              "auf23

              pa_ausg RADIOBUTTON GROUP r1.
  SELECTION-SCREEN END OF block ki.
" aufg. s23
