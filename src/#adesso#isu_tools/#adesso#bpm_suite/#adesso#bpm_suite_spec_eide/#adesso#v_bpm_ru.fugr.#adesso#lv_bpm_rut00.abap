*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 15.09.2015 at 14:12:00
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPM_RU................................*
TABLES: /ADESSO/V_BPM_RU, */ADESSO/V_BPM_RU. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPM_RU
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPM_RU. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPM_RU.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPM_RU_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_RU.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_RU_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPM_RU_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_RU.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_RU_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPM_RULE               .
