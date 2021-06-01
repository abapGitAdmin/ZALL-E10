*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10.09.2015 at 10:28:38
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPM_OB................................*
TABLES: /ADESSO/V_BPM_OB, */ADESSO/V_BPM_OB. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPM_OB
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPM_OB. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPM_OB.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPM_OB_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_OB.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_OB_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPM_OB_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_OB.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_OB_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPM_OBJ                .
