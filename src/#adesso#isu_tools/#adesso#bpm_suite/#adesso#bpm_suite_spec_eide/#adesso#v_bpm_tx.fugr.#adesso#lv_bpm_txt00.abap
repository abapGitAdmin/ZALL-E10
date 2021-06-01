*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 15.09.2015 at 14:02:37
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPM_TX................................*
TABLES: /ADESSO/V_BPM_TX, */ADESSO/V_BPM_TX. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPM_TX
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPM_TX. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPM_TX.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPM_TX_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_TX.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_TX_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPM_TX_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_TX.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_TX_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPM_TXT                .
