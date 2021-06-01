*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 23.05.2017 at 15:18:09
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/INKBIRTH................................*
DATA:  BEGIN OF STATUS_/ADESSO/INKBIRTH              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INKBIRTH              .
CONTROLS: TCTRL_/ADESSO/INKBIRTH
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/INKBIRTH              .
TABLES: /ADESSO/INKBIRTH               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
