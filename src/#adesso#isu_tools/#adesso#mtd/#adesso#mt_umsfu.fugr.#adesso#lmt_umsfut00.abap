*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 19.06.2015 at 11:51:32
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/MT_UMSFU................................*
DATA:  BEGIN OF STATUS_/ADESSO/MT_UMSFU              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MT_UMSFU              .
CONTROLS: TCTRL_/ADESSO/MT_UMSFU
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/MT_UMSFU              .
TABLES: /ADESSO/MT_UMSFU               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
