*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.01.2017 at 16:43:27
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/EDIVAR..................................*
DATA:  BEGIN OF STATUS_/ADESSO/EDIVAR                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/EDIVAR                .
CONTROLS: TCTRL_/ADESSO/EDIVAR
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: */ADESSO/EDIVAR                .
TABLES: /ADESSO/EDIVAR                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
