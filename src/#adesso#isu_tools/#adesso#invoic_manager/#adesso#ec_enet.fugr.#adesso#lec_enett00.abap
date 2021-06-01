*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 09.07.2015 at 16:37:52
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/EC_ENET.................................*
DATA:  BEGIN OF STATUS_/ADESSO/EC_ENET               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/EC_ENET               .
CONTROLS: TCTRL_/ADESSO/EC_ENET
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/EC_ENET               .
TABLES: /ADESSO/EC_ENET                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
