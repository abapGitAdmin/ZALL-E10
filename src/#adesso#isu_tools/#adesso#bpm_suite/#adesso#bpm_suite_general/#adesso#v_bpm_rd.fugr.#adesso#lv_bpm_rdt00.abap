*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 10.09.2015 at 10:29:45
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPM_RD................................*
TABLES: /ADESSO/V_BPM_RD, */ADESSO/V_BPM_RD. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPM_RD
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPM_RD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPM_RD.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPM_RD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_RD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_RD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPM_RD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPM_RD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPM_RD_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPM_RDP                .
