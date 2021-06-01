*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 17.12.2015 at 03:21:35
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/ART_CUST................................*
DATA:  BEGIN OF STATUS_/ADESSO/ART_CUST              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/ART_CUST              .
CONTROLS: TCTRL_/ADESSO/ART_CUST
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/ART_CUST              .
TABLES: /ADESSO/ART_CUST               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
