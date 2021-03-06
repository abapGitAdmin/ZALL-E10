*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK gb_hdr WITH FRAME TITLE TEXT-bk1.

*PARAMETERS:
*  p_ownsp TYPE e_dexservprovself MATCHCODE OBJECT serviceprovider OBLIGATORY,
*  p_rcver TYPE e_dexservprov OBLIGATORY.
*
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 1(31) TEXT-t02 FOR FIELD p_pvw.
*PARAMETERS:
*  p_pvw  TYPE /idxgc/de_proc_view  MODIF ID txt,
*  p_pvwt TYPE eideswtviewtxt MODIF ID txt.
*SELECTION-SCREEN END OF LINE.
*
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 1(31) TEXT-t03 FOR FIELD p_pty.
*PARAMETERS:
*  p_pty  TYPE /idxgc/de_proc_type MODIF ID txt,
*  p_ptyt TYPE eideswttypetxt MODIF ID txt.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN COMMENT 1(31) TEXT-t01 FOR FIELD p_pid.
*PARAMETERS:
*  p_pid  TYPE /idxgc/de_proc_id OBLIGATORY,
*  p_pidt TYPE /idxgc/de_proc_descr MODIF ID txt.
*SELECTION-SCREEN END OF LINE.

*SELECTION-SCREEN COMMENT 1(31) TEXT-t01.

* Z14: Master Data for Point of Delivery
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z30  RADIOBUTTON GROUP g1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 6(70) TEXT-t10 FOR FIELD p_z30.
SELECTION-SCREEN END OF LINE.

* Z27: Transfer of Transaction Data
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z34  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(70) TEXT-t11 FOR FIELD p_z34.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_hdr.


SELECTION-SCREEN BEGIN OF BLOCK gb_z30 WITH FRAME TITLE TEXT-bk2.

** Z14: Master Data for Point of Delivery
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: p_z14  RADIOBUTTON GROUP g1 DEFAULT 'X'.
*SELECTION-SCREEN COMMENT 6(70) TEXT-t04 FOR FIELD p_z14.
*SELECTION-SCREEN END OF LINE.
*
** Z27: Transfer of Transaction Data
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: p_z27  RADIOBUTTON GROUP g1.
*SELECTION-SCREEN COMMENT 6(60) TEXT-t05 FOR FIELD p_z27.
*SELECTION-SCREEN END OF LINE.
*
** Z28: Transfer of Energy and Demand Maximum
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: p_z28  RADIOBUTTON GROUP g1.
*SELECTION-SCREEN COMMENT 6(70) TEXT-t06 FOR FIELD p_z28.
*SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
DATA p_ext_ui TYPE ext_ui.
SELECTION-SCREEN COMMENT 1(39) TEXT-t20.
SELECT-OPTIONS extui FOR p_ext_ui OBLIGATORY.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(42) TEXT-t21.
PARAMETERS: p_date TYPE /idxgc/de_proc_date.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(42) TEXT-t22.
PARAMETERS: p_settl TYPE /idxgc/de_settl_proc.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_z30.


SELECTION-SCREEN BEGIN OF BLOCK gb_z34 WITH FRAME TITLE TEXT-bk3.

SELECTION-SCREEN BEGIN OF LINE.
DATA p_logbel TYPE e_logbelnr.
SELECTION-SCREEN COMMENT 1(39) TEXT-t30.
SELECT-OPTIONS logbel FOR p_logbel OBLIGATORY.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_z34.
