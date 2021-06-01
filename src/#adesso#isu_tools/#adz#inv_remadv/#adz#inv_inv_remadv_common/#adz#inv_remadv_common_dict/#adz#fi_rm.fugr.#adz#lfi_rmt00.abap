*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 08.01.2021 at 14:23:36
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADZ/FI_REMAD...................................*
DATA:  BEGIN OF STATUS_/ADZ/FI_REMAD                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_/ADZ/FI_REMAD                 .
CONTROLS: TCTRL_/ADZ/FI_REMAD
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: /ADZ/V_INV_CUST.................................*
TABLES: /ADZ/V_INV_CUST, */ADZ/V_INV_CUST. "view work areas
CONTROLS: TCTRL_/ADZ/V_INV_CUST
TYPE TABLEVIEW USING SCREEN '0005'.
DATA: BEGIN OF STATUS_/ADZ/V_INV_CUST. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_INV_CUST.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_INV_CUST_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_INV_CUST.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_INV_CUST_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_INV_CUST_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_INV_CUST.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_INV_CUST_TOTAL.

*...processing: /ADZ/V_INV_FUNC.................................*
TABLES: /ADZ/V_INV_FUNC, */ADZ/V_INV_FUNC. "view work areas
CONTROLS: TCTRL_/ADZ/V_INV_FUNC
TYPE TABLEVIEW USING SCREEN '0004'.
DATA: BEGIN OF STATUS_/ADZ/V_INV_FUNC. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_INV_FUNC.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_INV_FUNC_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_INV_FUNC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_INV_FUNC_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_INV_FUNC_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_INV_FUNC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_INV_FUNC_TOTAL.

*...processing: /ADZ/V_INV_USR..................................*
TABLES: /ADZ/V_INV_USR, */ADZ/V_INV_USR. "view work areas
CONTROLS: TCTRL_/ADZ/V_INV_USR
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF STATUS_/ADZ/V_INV_USR. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_INV_USR.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_INV_USR_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_INV_USR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_INV_USR_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_INV_USR_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_INV_USR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_INV_USR_TOTAL.

*.........table declarations:.................................*
TABLES: */ADZ/FI_REMAD                 .
TABLES: /ADZ/FI_REMAD                  .
TABLES: /ADZ/INV_CUST                  .
TABLES: /ADZ/INV_FUNC                  .
TABLES: /ADZ/INV_USR                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
