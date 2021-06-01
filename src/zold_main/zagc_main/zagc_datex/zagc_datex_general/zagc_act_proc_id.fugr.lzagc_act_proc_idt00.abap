*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 25.08.2015 at 19:48:45 by user SCHMIDT.C
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZAGC_ACT_PROC_ID................................*
DATA:  BEGIN OF STATUS_ZAGC_ACT_PROC_ID              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAGC_ACT_PROC_ID              .
CONTROLS: TCTRL_ZAGC_ACT_PROC_ID
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZAGC_ACT_PROC_ID              .
TABLES: ZAGC_ACT_PROC_ID               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
