*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 09.07.2015 at 16:35:36
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/INV_CHK.................................*
DATA:  BEGIN OF STATUS_/ADESSO/INV_CHK               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INV_CHK               .
CONTROLS: TCTRL_/ADESSO/INV_CHK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/INV_CHK               .
TABLES: /ADESSO/INV_CHK                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
