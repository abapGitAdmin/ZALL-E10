*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 22.03.2016 at 15:51:09 by user THIMEL.R
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZAGC_MRCONTACT..................................*
TABLES: ZAGC_MRCONTACT, *ZAGC_MRCONTACT. "view work areas
CONTROLS: TCTRL_ZAGC_MRCONTACT
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZAGC_MRCONTACT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZAGC_MRCONTACT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZAGC_MRCONTACT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZAGC_MRCONTACT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZAGC_MRCONTACT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZAGC_MRCONTACT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZAGC_MRCONTACT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZAGC_MRCONTACT_TOTAL.

*.........table declarations:.................................*
TABLES: /IDXGC/MRCONTACT               .
