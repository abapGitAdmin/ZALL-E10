*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 03.01.2018 at 09:54:25
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMOSB_PRICAT....................................*
DATA:  BEGIN OF STATUS_ZMOSB_PRICAT                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMOSB_PRICAT                  .
CONTROLS: TCTRL_ZMOSB_PRICAT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMOSB_PRICAT                  .
TABLES: *ZMOSB_PRICAT_TXT              .
TABLES: ZMOSB_PRICAT                   .
TABLES: ZMOSB_PRICAT_TXT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
