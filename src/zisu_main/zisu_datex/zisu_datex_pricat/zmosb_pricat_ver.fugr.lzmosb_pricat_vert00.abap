*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 03.01.2018 at 08:54:05
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMOSB_PRICAT_VER................................*
DATA:  BEGIN OF STATUS_ZMOSB_PRICAT_VER              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMOSB_PRICAT_VER              .
CONTROLS: TCTRL_ZMOSB_PRICAT_VER
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMOSB_PCAT_V_TXT              .
TABLES: *ZMOSB_PRICAT_VER              .
TABLES: ZMOSB_PCAT_V_TXT               .
TABLES: ZMOSB_PRICAT_VER               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
