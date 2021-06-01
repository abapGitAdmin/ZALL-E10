*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.04.2017 at 09:32:03
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/INK_CUST................................*
DATA:  BEGIN OF STATUS_/ADESSO/INK_CUST              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INK_CUST              .
CONTROLS: TCTRL_/ADESSO/INK_CUST
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/INK_CUST              .
TABLES: /ADESSO/INK_CUST               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
