*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01.03.2019 at 13:39:27
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/INK_BEGR................................*
DATA:  BEGIN OF STATUS_/ADESSO/INK_BEGR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INK_BEGR              .
CONTROLS: TCTRL_/ADESSO/INK_BEGR
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: /ADESSO/INK_BGSB................................*
DATA:  BEGIN OF STATUS_/ADESSO/INK_BGSB              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INK_BGSB              .
CONTROLS: TCTRL_/ADESSO/INK_BGSB
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: /ADESSO/INK_BGSS................................*
DATA:  BEGIN OF STATUS_/ADESSO/INK_BGSS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INK_BGSS              .
CONTROLS: TCTRL_/ADESSO/INK_BGSS
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /ADESSO/INK_BGUS................................*
DATA:  BEGIN OF STATUS_/ADESSO/INK_BGUS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INK_BGUS              .
CONTROLS: TCTRL_/ADESSO/INK_BGUS
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /ADESSO/INK_NFHF................................*
DATA:  BEGIN OF STATUS_/ADESSO/INK_NFHF              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INK_NFHF              .
CONTROLS: TCTRL_/ADESSO/INK_NFHF
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /ADESSO/INK_STAT................................*
DATA:  BEGIN OF STATUS_/ADESSO/INK_STAT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/INK_STAT              .
CONTROLS: TCTRL_/ADESSO/INK_STAT
            TYPE TABLEVIEW USING SCREEN '0006'.
*.........table declarations:.................................*
TABLES: */ADESSO/INK_BEGR              .
TABLES: */ADESSO/INK_BGSB              .
TABLES: */ADESSO/INK_BGSS              .
TABLES: */ADESSO/INK_BGUS              .
TABLES: */ADESSO/INK_NFHF              .
TABLES: */ADESSO/INK_STAT              .
TABLES: /ADESSO/INK_BEGR               .
TABLES: /ADESSO/INK_BGSB               .
TABLES: /ADESSO/INK_BGSS               .
TABLES: /ADESSO/INK_BGUS               .
TABLES: /ADESSO/INK_NFHF               .
TABLES: /ADESSO/INK_STAT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
