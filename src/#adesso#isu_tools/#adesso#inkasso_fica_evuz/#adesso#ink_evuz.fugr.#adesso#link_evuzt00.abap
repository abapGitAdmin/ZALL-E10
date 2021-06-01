*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 30.10.2019 at 15:30:02
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/I_CUEVUZ................................*
DATA:  BEGIN OF STATUS_/ADESSO/I_CUEVUZ              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/I_CUEVUZ              .
CONTROLS: TCTRL_/ADESSO/I_CUEVUZ
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/I_CUEVUZ              .
TABLES: /ADESSO/I_CUEVUZ               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
