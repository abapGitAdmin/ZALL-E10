*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 09.09.2015 at 13:52:47
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPM_ID................................*
TABLES: /ADESSO/V_BPM_ID, */ADESSO/V_BPM_ID. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPM_ID
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPM_ID. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPM_ID.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPM_ID_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_ID.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_ID_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPM_ID_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_ID.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_ID_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPM_ID                 .
