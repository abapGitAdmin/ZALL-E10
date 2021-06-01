*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 03.01.2018 at 10:03:47
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZMOSB_PRI_CLASS.................................*
DATA:  BEGIN OF STATUS_ZMOSB_PRI_CLASS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMOSB_PRI_CLASS               .
CONTROLS: TCTRL_ZMOSB_PRI_CLASS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZMOSB_CLASS_TXT               .
TABLES: *ZMOSB_PRI_CLASS               .
TABLES: ZMOSB_CLASS_TXT                .
TABLES: ZMOSB_PRI_CLASS                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
