*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 05.03.2018 at 12:46:03
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/HMV_AKTO................................*
DATA:  BEGIN OF STATUS_/ADESSO/HMV_AKTO              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/HMV_AKTO              .
CONTROLS: TCTRL_/ADESSO/HMV_AKTO
            TYPE TABLEVIEW USING SCREEN '0012'.
*...processing: /ADESSO/HMV_CONS................................*
DATA:  BEGIN OF STATUS_/ADESSO/HMV_CONS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/HMV_CONS              .
CONTROLS: TCTRL_/ADESSO/HMV_CONS
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /ADESSO/HMV_IVAL................................*
DATA:  BEGIN OF STATUS_/ADESSO/HMV_IVAL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/HMV_IVAL              .
CONTROLS: TCTRL_/ADESSO/HMV_IVAL
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: /ADESSO/HMV_MSGT................................*
DATA:  BEGIN OF STATUS_/ADESSO/HMV_MSGT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/HMV_MSGT              .
CONTROLS: TCTRL_/ADESSO/HMV_MSGT
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: /ADESSO/HMV_MVER................................*
DATA:  BEGIN OF STATUS_/ADESSO/HMV_MVER              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/HMV_MVER              .
CONTROLS: TCTRL_/ADESSO/HMV_MVER
            TYPE TABLEVIEW USING SCREEN '0011'.
*...processing: /ADESSO/HMV_SART................................*
DATA:  BEGIN OF STATUS_/ADESSO/HMV_SART              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/HMV_SART              .
CONTROLS: TCTRL_/ADESSO/HMV_SART
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: /ADESSO/HMV_SEGN................................*
DATA:  BEGIN OF STATUS_/ADESSO/HMV_SEGN              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/HMV_SEGN              .
CONTROLS: TCTRL_/ADESSO/HMV_SEGN
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: /ADESSO/HMV_XPRO................................*
DATA:  BEGIN OF STATUS_/ADESSO/HMV_XPRO              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADESSO/HMV_XPRO              .
CONTROLS: TCTRL_/ADESSO/HMV_XPRO
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: /ADESSO/V_HMV_AR................................*
TABLES: /ADESSO/V_HMV_AR, */ADESSO/V_HMV_AR. "view work areas
CONTROLS: TCTRL_/ADESSO/V_HMV_AR
TYPE TABLEVIEW USING SCREEN '0007'.
DATA: BEGIN OF STATUS_/ADESSO/V_HMV_AR. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_HMV_AR.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_HMV_AR_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_HMV_AR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_HMV_AR_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_HMV_AR_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_HMV_AR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_HMV_AR_TOTAL.

*...processing: /ADESSO/V_HMV_MS................................*
TABLES: /ADESSO/V_HMV_MS, */ADESSO/V_HMV_MS. "view work areas
CONTROLS: TCTRL_/ADESSO/V_HMV_MS
TYPE TABLEVIEW USING SCREEN '0008'.
DATA: BEGIN OF STATUS_/ADESSO/V_HMV_MS. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_HMV_MS.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_HMV_MS_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_HMV_MS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_HMV_MS_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_HMV_MS_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_HMV_MS.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_HMV_MS_TOTAL.

*...processing: /ADESSO/V_HMV_SG................................*
TABLES: /ADESSO/V_HMV_SG, */ADESSO/V_HMV_SG. "view work areas
CONTROLS: TCTRL_/ADESSO/V_HMV_SG
TYPE TABLEVIEW USING SCREEN '0009'.
DATA: BEGIN OF STATUS_/ADESSO/V_HMV_SG. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_HMV_SG.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_HMV_SG_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_HMV_SG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_HMV_SG_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_HMV_SG_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_HMV_SG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_HMV_SG_TOTAL.

*...processing: /ADESSO/V_HMV_XP................................*
TABLES: /ADESSO/V_HMV_XP, */ADESSO/V_HMV_XP. "view work areas
CONTROLS: TCTRL_/ADESSO/V_HMV_XP
TYPE TABLEVIEW USING SCREEN '0010'.
DATA: BEGIN OF STATUS_/ADESSO/V_HMV_XP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_HMV_XP.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_HMV_XP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_HMV_XP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_HMV_XP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_HMV_XP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_HMV_XP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_HMV_XP_TOTAL.

*.........table declarations:.................................*
TABLES: */ADESSO/HMV_AKTO              .
TABLES: */ADESSO/HMV_CONS              .
TABLES: */ADESSO/HMV_IVAL              .
TABLES: */ADESSO/HMV_MSGT              .
TABLES: */ADESSO/HMV_MVER              .
TABLES: */ADESSO/HMV_SART              .
TABLES: */ADESSO/HMV_SEGN              .
TABLES: */ADESSO/HMV_XPRO              .
TABLES: /ADESSO/HMV_AKTO               .
TABLES: /ADESSO/HMV_CONS               .
TABLES: /ADESSO/HMV_IVAL               .
TABLES: /ADESSO/HMV_MSGT               .
TABLES: /ADESSO/HMV_MVER               .
TABLES: /ADESSO/HMV_SART               .
TABLES: /ADESSO/HMV_SEGN               .
TABLES: /ADESSO/HMV_XPRO               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
