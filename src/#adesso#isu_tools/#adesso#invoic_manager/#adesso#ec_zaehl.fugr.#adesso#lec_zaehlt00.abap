*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 22.07.2015 at 11:50:02
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/EC_ZAEHL................................*
DATA:  BEGIN OF STATUS_/ADESSO/EC_ZAEHL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/EC_ZAEHL              .
CONTROLS: TCTRL_/ADESSO/EC_ZAEHL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/EC_ZAEHL              .
TABLES: /ADESSO/EC_ZAEHL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
