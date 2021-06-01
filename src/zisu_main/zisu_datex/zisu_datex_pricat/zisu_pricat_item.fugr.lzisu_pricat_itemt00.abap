*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.09.2017 at 11:13:46
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZISU_PRICAT_ITEM................................*
DATA:  BEGIN OF STATUS_ZISU_PRICAT_ITEM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZISU_PRICAT_ITEM              .
CONTROLS: TCTRL_ZISU_PRICAT_ITEM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZISU_PRICAT_ITEM              .
TABLES: ZISU_PRICAT_ITEM               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
