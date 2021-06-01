*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 02.12.2019 at 10:53:55
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADZ/V_MDC_IN...................................*
TABLES: /ADZ/V_MDC_IN, */ADZ/V_MDC_IN. "view work areas
CONTROLS: TCTRL_/ADZ/V_MDC_IN
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_/ADZ/V_MDC_IN. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_MDC_IN.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_MDC_IN_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_IN.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_IN_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_MDC_IN_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_IN.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_IN_TOTAL.

*...processing: /ADZ/V_MDC_IN_MP................................*
TABLES: /ADZ/V_MDC_IN_MP, */ADZ/V_MDC_IN_MP. "view work areas
CONTROLS: TCTRL_/ADZ/V_MDC_IN_MP
TYPE TABLEVIEW USING SCREEN '0005'.
DATA: BEGIN OF STATUS_/ADZ/V_MDC_IN_MP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_MDC_IN_MP.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_MDC_IN_MP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_IN_MP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_IN_MP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_MDC_IN_MP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_IN_MP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_IN_MP_TOTAL.

*...processing: /ADZ/V_MDC_IN_ST................................*
TABLES: /ADZ/V_MDC_IN_ST, */ADZ/V_MDC_IN_ST. "view work areas
CONTROLS: TCTRL_/ADZ/V_MDC_IN_ST
TYPE TABLEVIEW USING SCREEN '0008'.
DATA: BEGIN OF STATUS_/ADZ/V_MDC_IN_ST. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_MDC_IN_ST.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_MDC_IN_ST_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_IN_ST.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_IN_ST_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_MDC_IN_ST_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_IN_ST.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_IN_ST_TOTAL.

*...processing: /ADZ/V_MDC_IN_SY................................*
TABLES: /ADZ/V_MDC_IN_SY, */ADZ/V_MDC_IN_SY. "view work areas
CONTROLS: TCTRL_/ADZ/V_MDC_IN_SY
TYPE TABLEVIEW USING SCREEN '0006'.
DATA: BEGIN OF STATUS_/ADZ/V_MDC_IN_SY. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_MDC_IN_SY.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_MDC_IN_SY_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_IN_SY.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_IN_SY_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_MDC_IN_SY_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_IN_SY.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_IN_SY_TOTAL.

*...processing: /ADZ/V_MDC_MPG..................................*
TABLES: /ADZ/V_MDC_MPG, */ADZ/V_MDC_MPG. "view work areas
CONTROLS: TCTRL_/ADZ/V_MDC_MPG
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_/ADZ/V_MDC_MPG. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_MDC_MPG.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_MDC_MPG_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_MPG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_MPG_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_MDC_MPG_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_MPG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_MPG_TOTAL.

*...processing: /ADZ/V_MDC_MPG_S................................*
TABLES: /ADZ/V_MDC_MPG_S, */ADZ/V_MDC_MPG_S. "view work areas
CONTROLS: TCTRL_/ADZ/V_MDC_MPG_S
TYPE TABLEVIEW USING SCREEN '0004'.
DATA: BEGIN OF STATUS_/ADZ/V_MDC_MPG_S. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADZ/V_MDC_MPG_S.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADZ/V_MDC_MPG_S_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_MPG_S.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_MPG_S_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADZ/V_MDC_MPG_S_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADZ/V_MDC_MPG_S.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADZ/V_MDC_MPG_S_TOTAL.

*.........table declarations:.................................*
TABLES: /ADZ/MDC_IN                    .
TABLES: /ADZ/MDC_IN_MPG                .
TABLES: /ADZ/MDC_IN_SYO                .
TABLES: /ADZ/MDC_IN_SYOT               .
TABLES: /ADZ/MDC_MPG                   .
TABLES: /ADZ/MDC_MPG_SP                .
