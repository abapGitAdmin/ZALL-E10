*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK gb_hdr WITH FRAME TITLE text-bk1.
PARAMETERS:
  p_ownsp       TYPE e_dexservprovself MATCHCODE OBJECT serviceprovider OBLIGATORY,
  p_rcver       TYPE e_dexservprov OBLIGATORY.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-t02 FOR FIELD p_pvw.
PARAMETERS:
  p_pvw         TYPE /idxgc/de_proc_view  MODIF ID txt,
  p_pvwt        TYPE eideswtviewtxt MODIF ID txt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-t03 FOR FIELD p_pty.
PARAMETERS:
  p_pty         TYPE /idxgc/de_proc_type MODIF ID txt,
  p_ptyt        TYPE eideswttypetxt MODIF ID txt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-t01 FOR FIELD p_pid.
PARAMETERS:
  p_pid         TYPE /idxgc/de_proc_id OBLIGATORY,
  p_pidt        TYPE /idxgc/de_proc_descr MODIF ID txt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_hdr.

SELECTION-SCREEN begin of block gb_msg with frame TITLE text-bk2.

* Z14: Master Data for Point of Delivery
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z14  RADIOBUTTON GROUP g1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 6(70) text-t04 FOR FIELD p_z14.
SELECTION-SCREEN END OF LINE.

* Z27: Transfer of Transaction Data
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z27  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(60) text-t05 FOR FIELD p_z27.
SELECTION-SCREEN END OF LINE.

* Z28: Transfer of Energy and Demand Maximum
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z28  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(70) text-t06 FOR FIELD p_z28.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK gb_msg.
