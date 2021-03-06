*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 03.07.2017 at 14:20:25
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: /ADESSO/V_BPU_CC................................*
TABLES: /ADESSO/V_BPU_CC, */ADESSO/V_BPU_CC. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_CC
TYPE TABLEVIEW USING SCREEN '0014'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_CC. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_CC.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_CC_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_CC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_CC_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_CC_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_CC.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_CC_TOTAL.

*...processing: /ADESSO/V_BPU_DD................................*
TABLES: /ADESSO/V_BPU_DD, */ADESSO/V_BPU_DD. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_DD
TYPE TABLEVIEW USING SCREEN '0015'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_DD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_DD.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_DD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_DD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_DD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_DD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_DD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_DD_TOTAL.

*...processing: /ADESSO/V_BPU_ES................................*
TABLES: /ADESSO/V_BPU_ES, */ADESSO/V_BPU_ES. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_ES
TYPE TABLEVIEW USING SCREEN '0013'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_ES. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_ES.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_ES_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_ES.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_ES_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_ES_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_ES.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_ES_TOTAL.

*...processing: /ADESSO/V_BPU_GE................................*
TABLES: /ADESSO/V_BPU_GE, */ADESSO/V_BPU_GE. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_GE
TYPE TABLEVIEW USING SCREEN '0008'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_GE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_GE.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_GE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_GE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_GE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_GE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_GE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_GE_TOTAL.

*...processing: /ADESSO/V_BPU_ID................................*
TABLES: /ADESSO/V_BPU_ID, */ADESSO/V_BPU_ID. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_ID
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_ID. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_ID.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_ID_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_ID.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_ID_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_ID_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_ID.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_ID_TOTAL.

*...processing: /ADESSO/V_BPU_OB................................*
TABLES: /ADESSO/V_BPU_OB, */ADESSO/V_BPU_OB. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_OB
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_OB. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_OB.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_OB_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_OB.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_OB_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_OB_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_OB.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_OB_TOTAL.

*...processing: /ADESSO/V_BPU_PI................................*
TABLES: /ADESSO/V_BPU_PI, */ADESSO/V_BPU_PI. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_PI
TYPE TABLEVIEW USING SCREEN '0010'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_PI. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_PI.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_PI_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_PI.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_PI_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_PI_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_PI.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_PI_TOTAL.

*...processing: /ADESSO/V_BPU_PR................................*
TABLES: /ADESSO/V_BPU_PR, */ADESSO/V_BPU_PR. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_PR
TYPE TABLEVIEW USING SCREEN '0016'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_PR. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_PR.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_PR_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_PR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_PR_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_PR_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_PR.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_PR_TOTAL.

*...processing: /ADESSO/V_BPU_RD................................*
TABLES: /ADESSO/V_BPU_RD, */ADESSO/V_BPU_RD. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_RD
TYPE TABLEVIEW USING SCREEN '0005'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_RD. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_RD.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_RD_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_RD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_RD_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_RD_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_RD.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_RD_TOTAL.

*...processing: /ADESSO/V_BPU_RU................................*
TABLES: /ADESSO/V_BPU_RU, */ADESSO/V_BPU_RU. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_RU
TYPE TABLEVIEW USING SCREEN '0012'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_RU. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_RU.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_RU_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_RU.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_RU_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_RU_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_RU.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_RU_TOTAL.

*...processing: /ADESSO/V_BPU_SP................................*
TABLES: /ADESSO/V_BPU_SP, */ADESSO/V_BPU_SP. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_SP
TYPE TABLEVIEW USING SCREEN '0017'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_SP. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_SP.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_SP_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_SP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_SP_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_SP_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_SP.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_SP_TOTAL.

*...processing: /ADESSO/V_BPU_TX................................*
TABLES: /ADESSO/V_BPU_TX, */ADESSO/V_BPU_TX. "view work areas
CONTROLS: TCTRL_/ADESSO/V_BPU_TX
TYPE TABLEVIEW USING SCREEN '0011'.
DATA: BEGIN OF STATUS_/ADESSO/V_BPU_TX. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_/ADESSO/V_BPU_TX.
* Table for entries selected to show on screen
DATA: BEGIN OF /ADESSO/V_BPU_TX_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_TX.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_TX_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF /ADESSO/V_BPU_TX_TOTAL OCCURS 0010.
INCLUDE STRUCTURE /ADESSO/V_BPU_TX.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF /ADESSO/V_BPU_TX_TOTAL.

*.........table declarations:.................................*
TABLES: /ADESSO/BPU_CCAT               .
TABLES: /ADESSO/BPU_DUED               .
TABLES: /ADESSO/BPU_ESM                .
TABLES: /ADESSO/BPU_GEN                .
TABLES: /ADESSO/BPU_ID                 .
TABLES: /ADESSO/BPU_OBJ                .
TABLES: /ADESSO/BPU_PID                .
TABLES: /ADESSO/BPU_PRIO               .
TABLES: /ADESSO/BPU_RDP                .
TABLES: /ADESSO/BPU_RULE               .
TABLES: /ADESSO/BPU_SOP                .
TABLES: /ADESSO/BPU_TXT                .
