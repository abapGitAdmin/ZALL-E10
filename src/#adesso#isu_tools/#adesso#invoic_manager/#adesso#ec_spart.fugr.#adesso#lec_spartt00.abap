*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 12.08.2015 at 13:33:29
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/EC_SPART................................*
DATA:  BEGIN OF STATUS_/ADESSO/EC_SPART              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/EC_SPART              .
CONTROLS: TCTRL_/ADESSO/EC_SPART
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/EC_SPART              .
TABLES: /ADESSO/EC_SPART               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
