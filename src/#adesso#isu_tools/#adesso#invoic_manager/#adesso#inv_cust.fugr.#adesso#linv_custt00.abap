*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 17.12.2015 at 03:24:07
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/INV_CUST................................*
DATA:  BEGIN OF STATUS_/ADESSO/INV_CUST              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INV_CUST              .
CONTROLS: TCTRL_/ADESSO/INV_CUST
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/INV_CUST              .
TABLES: /ADESSO/INV_CUST               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
