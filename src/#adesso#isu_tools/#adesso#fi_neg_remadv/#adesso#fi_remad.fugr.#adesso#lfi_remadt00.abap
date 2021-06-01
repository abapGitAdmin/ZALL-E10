*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 04.05.2016 at 12:48:06
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/FI_REMAD................................*
DATA:  BEGIN OF STATUS_/ADESSO/FI_REMAD              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/FI_REMAD              .
CONTROLS: TCTRL_/ADESSO/FI_REMAD
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/FI_REMAD              .
TABLES: /ADESSO/FI_REMAD               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
