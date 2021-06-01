*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 03.08.2015 at 09:29:23
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/C_ENET_G................................*
DATA:  BEGIN OF STATUS_/ADESSO/C_ENET_G              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/C_ENET_G              .
CONTROLS: TCTRL_/ADESSO/C_ENET_G
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/C_ENET_G              .
TABLES: /ADESSO/C_ENET_G               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
