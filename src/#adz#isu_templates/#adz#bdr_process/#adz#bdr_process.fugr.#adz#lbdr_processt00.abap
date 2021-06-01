*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.11.2019 at 19:49:36
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADZ/V_BDR_DEVCO................................*
TABLES: /ADZ/V_BDR_DEVCO, */ADZ/V_BDR_DEVCO. "view work areas
CONTROLS: TCTRL_/ADZ/V_BDR_DEVCO
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADZ/V_BDR_DEVCO. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_BDR_DEVCO.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_BDR_DEVCO_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_BDR_DEVCO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_BDR_DEVCO_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_BDR_DEVCO_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_BDR_DEVCO.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_BDR_DEVCO_TOTAL.

*.........table declarations:.................................*
TABLES: /ADZ/BDR_DEVCONF               .
