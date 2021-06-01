*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 16.06.2015 at 16:24:38
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/MTE_GPZS................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_GPZS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_GPZS              .
CONTROLS: TCTRL_/ADESSO/MTE_GPZS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/MTE_GPZS              .
TABLES: /ADESSO/MTE_GPZS               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
