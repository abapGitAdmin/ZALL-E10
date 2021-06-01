*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 22.09.2015 at 11:17:01
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/MTE_RLAE................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLAE              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLAE              .
CONTROLS: TCTRL_/ADESSO/MTE_RLAE
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /ADESSO/MTE_RLAK................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLAK              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLAK              .
CONTROLS: TCTRL_/ADESSO/MTE_RLAK
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /ADESSO/MTE_RLAN................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLAN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLAN              .
CONTROLS: TCTRL_/ADESSO/MTE_RLAN
            TYPE TABLEVIEW USING SCREEN '0010'.
*...processing: /ADESSO/MTE_RLBK................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLBK              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLBK              .
CONTROLS: TCTRL_/ADESSO/MTE_RLBK
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /ADESSO/MTE_RLGP................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLGP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLGP              .
CONTROLS: TCTRL_/ADESSO/MTE_RLGP
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: /ADESSO/MTE_RLPT................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLPT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLPT              .
CONTROLS: TCTRL_/ADESSO/MTE_RLPT
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: /ADESSO/MTE_RLSP................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLSP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLSP              .
CONTROLS: TCTRL_/ADESSO/MTE_RLSP
            TYPE TABLEVIEW USING SCREEN '0009'.
*...processing: /ADESSO/MTE_RLTT................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLTT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLTT              .
CONTROLS: TCTRL_/ADESSO/MTE_RLTT
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: /ADESSO/MTE_RLVK................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLVK              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLVK              .
CONTROLS: TCTRL_/ADESSO/MTE_RLVK
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: /ADESSO/MTE_RLVT................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_RLVT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_RLVT              .
CONTROLS: TCTRL_/ADESSO/MTE_RLVT
            TYPE TABLEVIEW USING SCREEN '0008'.
*.........table declarations:.................................*
TABLES: */ADESSO/MTE_RLAE              .
TABLES: */ADESSO/MTE_RLAK              .
TABLES: */ADESSO/MTE_RLAN              .
TABLES: */ADESSO/MTE_RLBK              .
TABLES: */ADESSO/MTE_RLGP              .
TABLES: */ADESSO/MTE_RLPT              .
TABLES: */ADESSO/MTE_RLSP              .
TABLES: */ADESSO/MTE_RLTT              .
TABLES: */ADESSO/MTE_RLVK              .
TABLES: */ADESSO/MTE_RLVT              .
TABLES: /ADESSO/MTE_RLAE               .
TABLES: /ADESSO/MTE_RLAK               .
TABLES: /ADESSO/MTE_RLAN               .
TABLES: /ADESSO/MTE_RLBK               .
TABLES: /ADESSO/MTE_RLGP               .
TABLES: /ADESSO/MTE_RLPT               .
TABLES: /ADESSO/MTE_RLSP               .
TABLES: /ADESSO/MTE_RLTT               .
TABLES: /ADESSO/MTE_RLVK               .
TABLES: /ADESSO/MTE_RLVT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
