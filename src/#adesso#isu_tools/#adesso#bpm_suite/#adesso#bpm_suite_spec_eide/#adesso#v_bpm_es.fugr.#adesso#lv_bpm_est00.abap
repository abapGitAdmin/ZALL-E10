*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 15.09.2015 at 14:08:23
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPM_ES................................*
TABLES: /ADESSO/V_BPM_ES, */ADESSO/V_BPM_ES. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPM_ES
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPM_ES. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPM_ES.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPM_ES_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_ES.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_ES_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPM_ES_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_ES.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_ES_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPM_ESM                .
