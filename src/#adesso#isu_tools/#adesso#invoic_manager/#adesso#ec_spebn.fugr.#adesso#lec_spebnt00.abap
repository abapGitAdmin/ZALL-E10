*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.12.2015 at 12:50:19
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/EC_SPEBN................................*
DATA:  BEGIN OF STATUS_/ADESSO/EC_SPEBN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/EC_SPEBN              .
CONTROLS: TCTRL_/ADESSO/EC_SPEBN
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: */ADESSO/EC_SPEBN              .
TABLES: /ADESSO/EC_SPEBN               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
