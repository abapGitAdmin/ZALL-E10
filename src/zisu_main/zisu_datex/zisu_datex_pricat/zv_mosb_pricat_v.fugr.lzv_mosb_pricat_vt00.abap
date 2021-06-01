*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 03.01.2018 at 10:29:00
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_MOSB_PRICAT_V................................*
TABLES: ZV_MOSB_PRICAT_V, *ZV_MOSB_PRICAT_V. "view work areas
CONTROLS: TCTRL_ZV_MOSB_PRICAT_V
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZV_MOSB_PRICAT_V. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_MOSB_PRICAT_V.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_MOSB_PRICAT_V_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_MOSB_PRICAT_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_MOSB_PRICAT_V_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_MOSB_PRICAT_V_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_MOSB_PRICAT_V.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_MOSB_PRICAT_V_TOTAL.

*.........table declarations:.................................*
TABLES: ZMOSB_PRICAT_VER               .
