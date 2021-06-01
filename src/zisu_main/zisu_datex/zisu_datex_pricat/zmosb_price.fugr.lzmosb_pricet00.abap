*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 03.01.2018 at 10:50:04
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMOSB_PRICE.....................................*
DATA:  BEGIN OF STATUS_ZMOSB_PRICE                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMOSB_PRICE                   .
CONTROLS: TCTRL_ZMOSB_PRICE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMOSB_PRICE                   .
TABLES: ZMOSB_PRICE                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
