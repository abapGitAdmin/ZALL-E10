*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 03.01.2018 at 11:07:30
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_MOSB_PRICAT_P................................*
TABLES: ZV_MOSB_PRICAT_P, *ZV_MOSB_PRICAT_P. "view work areas
CONTROLS: TCTRL_ZV_MOSB_PRICAT_P
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZV_MOSB_PRICAT_P. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_MOSB_PRICAT_P.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_MOSB_PRICAT_P_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_MOSB_PRICAT_P.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_MOSB_PRICAT_P_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_MOSB_PRICAT_P_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_MOSB_PRICAT_P.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_MOSB_PRICAT_P_TOTAL.

*.........table declarations:.................................*
TABLES: ZMOSB_PRICE                    .
