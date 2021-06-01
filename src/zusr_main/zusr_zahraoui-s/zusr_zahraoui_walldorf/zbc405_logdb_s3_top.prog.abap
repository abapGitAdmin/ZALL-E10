*&---------------------------------------------------------------------*
*& Include ZBC405_LOGDB_S3_TOP                               Report ZBC405_15_LOGDB2
*&
*&---------------------------------------------------------------------*
REPORT ZBC405_15_LOGDB2.
NODES: spfli, sflight,sbook.
"NODES: spfli, sflight,sbook.
"Selection screen einfügen
SELECTION-SCREEN BEGIN OF BLOCK rak WITH FRAME.
  SELECT-OPTIONS so_kund FOR sbook-customid.
  selection-SCREEN END OF BLOCK rak.
"var
DATA: gv_freie_plaetze TYPE sflight-seatsocc.
