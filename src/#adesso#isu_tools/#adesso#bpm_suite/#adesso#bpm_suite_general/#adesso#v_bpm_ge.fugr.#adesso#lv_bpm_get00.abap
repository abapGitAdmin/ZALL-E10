*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 09.09.2015 at 13:50:58
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPM_GE................................*
TABLES: /ADESSO/V_BPM_GE, */ADESSO/V_BPM_GE. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPM_GE
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPM_GE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPM_GE.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPM_GE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_GE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_GE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPM_GE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_GE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_GE_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPM_GEN                .
