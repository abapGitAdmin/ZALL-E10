*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.09.2017 at 15:30:10
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZISU_PRICAT_HDR.................................*
DATA:  BEGIN OF STATUS_ZISU_PRICAT_HDR               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZISU_PRICAT_HDR               .
CONTROLS: TCTRL_ZISU_PRICAT_HDR
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZISU_PRICAT_HDR               .
TABLES: ZISU_PRICAT_HDR                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
