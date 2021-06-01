*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 16.06.2015 at 13:50:06
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/MT_FIRMA................................*
DATA:  BEGIN OF STATUS_/ADESSO/MT_FIRMA              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MT_FIRMA              .
CONTROLS: TCTRL_/ADESSO/MT_FIRMA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/MT_FIRMA              .
TABLES: /ADESSO/MT_FIRMA               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
