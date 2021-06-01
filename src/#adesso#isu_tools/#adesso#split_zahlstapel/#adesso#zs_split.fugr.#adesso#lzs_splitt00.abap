*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 11.09.2017 at 13:42:59
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/ZS_SPLIT................................*
DATA:  BEGIN OF STATUS_/ADESSO/ZS_SPLIT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/ZS_SPLIT              .
CONTROLS: TCTRL_/ADESSO/ZS_SPLIT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/ZS_SPLIT              .
TABLES: /ADESSO/ZS_SPLIT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
