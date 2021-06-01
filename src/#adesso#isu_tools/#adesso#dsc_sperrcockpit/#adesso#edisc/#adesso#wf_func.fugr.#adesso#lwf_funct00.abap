*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 25.02.2016 at 11:46:14
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/SPT_STCU................................*
DATA:  BEGIN OF STATUS_/ADESSO/SPT_STCU              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/SPT_STCU              .
CONTROLS: TCTRL_/ADESSO/SPT_STCU
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /ADESSO/SPT_WFFU................................*
DATA:  BEGIN OF STATUS_/ADESSO/SPT_WFFU              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/SPT_WFFU              .
CONTROLS: TCTRL_/ADESSO/SPT_WFFU
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: */ADESSO/SPT_STCU              .
TABLES: */ADESSO/SPT_WFFU              .
TABLES: /ADESSO/SPT_STCU               .
TABLES: /ADESSO/SPT_WFFU               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
