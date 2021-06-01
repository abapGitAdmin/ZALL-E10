*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_SEL
*&---------------------------------------------------------------------*

DATA: " Data besser oben deklarieren zur obersicht
 p_eui TYPE ext_ui,
 p_log TYPE E_LOGBELNR.
*Erster Block

SELECTION-SCREEN BEGIN OF BLOCK gb_ntp WITH FRAME TITLE text-bk1.

SELECTION-SCREEN COMMENT 1(31) text-t00.

parameters: p_z16 RADIOBUTTON GROUP g4 DEFAULT 'X' USER-COMMAND r01.

parameters: p_z26 RADIOBUTTON GROUP g4.


SELECTION-SCREEN END OF BLOCK gb_ntp.
*Zweiter Block


SELECTION-SCREEN BEGIN OF BLOCK gb_msg WITH FRAME TITLE text-bk2.

SELECT-OPTIONS d_eui FOR p_eui MODIF ID Z16.

PARAMETERS: p_pdate TYPE /idxgc/de_proc_date MODIF ID Z16.

PARAMETERS: p_sproc TYPE /IDXGC/DE_SETTL_PROC MODIF ID Z16.

SELECT-OPTIONS d_eui2 FOR p_log MODIF ID Z26. " OBLIGATORY.

SELECTION-SCREEN END OF BLOCK gb_msg.
