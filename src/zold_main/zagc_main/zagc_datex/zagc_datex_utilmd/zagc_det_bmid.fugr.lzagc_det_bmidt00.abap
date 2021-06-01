*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 24.03.2015 at 18:15:31 by user THIMEL.R
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZAGC_DET_BMID...................................*
DATA:  BEGIN OF STATUS_ZAGC_DET_BMID                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAGC_DET_BMID                 .
CONTROLS: TCTRL_ZAGC_DET_BMID
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZAGC_DET_BMID                 .
TABLES: ZAGC_DET_BMID                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
