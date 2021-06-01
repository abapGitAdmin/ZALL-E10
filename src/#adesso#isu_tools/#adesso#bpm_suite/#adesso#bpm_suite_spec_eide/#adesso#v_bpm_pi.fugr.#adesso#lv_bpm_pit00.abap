*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 15.09.2015 at 14:16:46
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPM_PI................................*
TABLES: /ADESSO/V_BPM_PI, */ADESSO/V_BPM_PI. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPM_PI
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPM_PI. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPM_PI.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPM_PI_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_PI.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_PI_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPM_PI_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_PI.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_PI_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPM_PID                .
