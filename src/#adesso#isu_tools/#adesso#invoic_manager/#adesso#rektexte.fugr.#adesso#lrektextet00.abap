*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01.02.2017 at 09:52:12
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/REKTEXTE................................*
DATA:  BEGIN OF STATUS_/ADESSO/REKTEXTE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/REKTEXTE              .
CONTROLS: TCTRL_/ADESSO/REKTEXTE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/REKTEXTE              .
TABLES: /ADESSO/REKTEXTE               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
