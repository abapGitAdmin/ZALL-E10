*&---------------------------------------------------------------------*
*& Include ZBC405_LOGDB_S3_TOP                               Report ZBC405_15_LOGDB2
*&
*&---------------------------------------------------------------------*
REPORT ZBC405_15_LOGDB2.
TABLES: spfli, sflight,sbook.
"NODES: spfli, sflight,sbook.
"var
DATA: gv_freie_plaetze TYPE sflight-seatsocc.
