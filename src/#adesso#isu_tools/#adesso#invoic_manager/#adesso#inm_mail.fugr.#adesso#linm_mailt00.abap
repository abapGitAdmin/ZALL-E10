*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10.07.2015 at 11:21:47
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/INM_MAIL................................*
DATA:  BEGIN OF STATUS_/ADESSO/INM_MAIL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INM_MAIL              .
CONTROLS: TCTRL_/ADESSO/INM_MAIL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/INM_MAIL              .
TABLES: /ADESSO/INM_MAIL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
