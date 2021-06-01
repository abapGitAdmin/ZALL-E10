*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 30.07.2015 at 15:21:26
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/EC_AUSGR................................*
DATA:  BEGIN OF STATUS_/ADESSO/EC_AUSGR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/EC_AUSGR              .
CONTROLS: TCTRL_/ADESSO/EC_AUSGR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/EC_AUSGR              .
TABLES: /ADESSO/EC_AUSGR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
