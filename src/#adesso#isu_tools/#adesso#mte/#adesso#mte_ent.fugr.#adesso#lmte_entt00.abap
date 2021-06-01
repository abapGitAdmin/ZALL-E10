*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.06.2015 at 09:24:58
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/MTE_ZPSI................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_ZPSI              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_ZPSI              .
CONTROLS: TCTRL_/ADESSO/MTE_ZPSI
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /ADESSO/MTE_ZPSR................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_ZPSR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_ZPSR              .
CONTROLS: TCTRL_/ADESSO/MTE_ZPSR
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /ADESSO/MTE_ZPSV................................*
DATA:  BEGIN OF STATUS_/ADESSO/MTE_ZPSV              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/MTE_ZPSV              .
CONTROLS: TCTRL_/ADESSO/MTE_ZPSV
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: */ADESSO/MTE_ZPSI              .
TABLES: */ADESSO/MTE_ZPSR              .
TABLES: */ADESSO/MTE_ZPSV              .
TABLES: /ADESSO/MTE_ZPSI               .
TABLES: /ADESSO/MTE_ZPSR               .
TABLES: /ADESSO/MTE_ZPSV               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
