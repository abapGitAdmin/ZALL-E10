*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.04.2019 at 09:24:55
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_PRICAT_ITEM..................................*
TABLES: ZV_PRICAT_ITEM, *ZV_PRICAT_ITEM. "view work areas
CONTROLS: TCTRL_ZV_PRICAT_ITEM
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZV_PRICAT_ITEM. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_PRICAT_ITEM.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_PRICAT_ITEM_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_PRICAT_ITEM.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_PRICAT_ITEM_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_PRICAT_ITEM_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_PRICAT_ITEM.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_PRICAT_ITEM_TOTAL.

*.........table declarations:.................................*
TABLES: ZISU_PRICAT_ITEM               .
TABLES: ZMOSB_CLASS_TXT                .
TABLES: ZMOSB_PC_ADD_TXT               .
