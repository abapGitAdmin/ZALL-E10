*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 20.10.2015 at 11:21:42
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/EC_PAUSC................................*
DATA:  BEGIN OF STATUS_/ADESSO/EC_PAUSC              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/EC_PAUSC              .
CONTROLS: TCTRL_/ADESSO/EC_PAUSC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/EC_PAUSC              .
TABLES: /ADESSO/EC_PAUSC               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
