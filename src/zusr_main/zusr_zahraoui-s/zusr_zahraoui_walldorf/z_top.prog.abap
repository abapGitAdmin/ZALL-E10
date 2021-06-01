*&---------------------------------------------------------------------*
*&  Include           Z_TOP
*&---------------------------------------------------------------------*



DATA: gs_spfli TYPE spfli.
CONSTANTS gc_mark VALUE 'X'.
"TABLES sscrfields.
DATA gv_switch TYPE n VALUE '1'.
TABLES sscrfields.


*  SELECTION-SCREEN END OF SCREEN 102.


""" wieso wird nix angezeigt"""für connection
selection-screen BEGIN OF SCREEN 1001 AS SUBSCREEN.

  SELECT-OPTIONS:
so_fnr FOR gs_spfli-connid MEMORY ID car,
so_con FOR gs_spfli-connid.

SELECTION-SCREEN SKIP.
" drucktaste anlegen auf aktuelenm selecktion bild
" user
SELECTION-SCREEN PUSHBUTTON pos_low(20) gv_text USER-COMMAND details.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK aa WITH FRAME TITLE TEXT-tld.

SELECT-OPTIONS:
so_ab FOR gs_spfli-cityfrom,
so_an FOR gs_spfli-cityto.
SELECTION-SCREEN END OF BLOCK aa.

SELECTION-SCREEN END OF SCREEN 1001.


" für Flüge

SELECTION-SCREEN BEGIN OF SCREEN 1002 AS SUBSCREEN.
SELECT-OPTIONS:
" Drucktsaste verhindert, dass es  wird für mehrfachselecktion erzeugt
so_datu2 FOR gs_spfli-arrtime NO-EXTENSION.

SELECTION-SCREEN END OF SCREEN 1002 .


"output Parameter

SELECTION-SCREEN BEGIN OF SCREEN 1003 AS SUBSCREEN.
" übung 3 variante bis zeile48
SELECTION-SCREEN BEGIN OF BLOCK param WITH FRAME TITLE text-tl3.

  "block vom radiobutton
SELECTION-SCREEN BEGIN OF BLOCK ra WITH FRAME.


PARAMETERS:
  pa_kn1 RADIOBUTTON GROUP w,
  pa_kn2 RADIOBUTTON GROUP w,
  pa_kn3 RADIOBUTTON GROUP w DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK ra.

PARAMETERS:

 so_land LIKE gs_spfli-countryfr.
SELECTION-SCREEN END OF BLOCK param.

SELECTION-SCREEN END OF SCREEN 1003.


SELECTION-SCREEN BEGIN OF TABBED BLOCK Flugsgeselschaft
  FOR 5 LINES.
SELECTION-SCREEN TAB (20) tab1 USER-COMMAND conn

DEFAULT SCREEN 1001.

SELECTION-SCREEN TAB (20) tab2 USER-COMMAND date

DEFAULT SCREEN 1002.
SELECTION-SCREEN TAB (20) tab3 USER-COMMAND type

DEFAULT SCREEN 1003.

SELECTION-SCREEN END OF BLOCK Flugsgeselschaft.
