*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 06.08.2015 at 14:06:09
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/EC_TARIF................................*
DATA:  BEGIN OF STATUS_/ADESSO/EC_TARIF              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/EC_TARIF              .
CONTROLS: TCTRL_/ADESSO/EC_TARIF
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/EC_TARIF              .
TABLES: /ADESSO/EC_TARIF               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
