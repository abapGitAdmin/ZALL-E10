*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK gb_hdr WITH FRAME TITLE TEXT-bk1.
PARAMETERS:
  p_ownsp TYPE e_dexservprovself MATCHCODE OBJECT serviceprovider OBLIGATORY MODIF ID bl1,
  p_rcver TYPE e_dexservprov OBLIGATORY MODIF ID bl1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-t02 FOR FIELD p_pvw MODIF ID bl1.
PARAMETERS:
  p_pvw  TYPE /idxgc/de_proc_view  MODIF ID txt,
  p_pvwt TYPE eideswtviewtxt MODIF ID txt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-t03 FOR FIELD p_pty MODIF ID bl1.
PARAMETERS:
  p_pty  TYPE /idxgc/de_proc_type MODIF ID txt,
  p_ptyt TYPE eideswttypetxt MODIF ID txt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-t01 FOR FIELD p_pid MODIF ID bl1.
PARAMETERS:
  p_pid  TYPE /idxgc/de_proc_id OBLIGATORY MODIF ID bl1,
  p_pidt TYPE /idxgc/de_proc_descr MODIF ID txt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_hdr.

SELECTION-SCREEN BEGIN OF BLOCK gb_msg WITH FRAME TITLE TEXT-bk2.

* Z14: Master Data for Point of Delivery
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z14  RADIOBUTTON GROUP g1 DEFAULT 'X' MODIF ID bl2.
SELECTION-SCREEN COMMENT 6(70) TEXT-t04 FOR FIELD p_z14 MODIF ID bl2.
SELECTION-SCREEN END OF LINE.

* Z27: Transfer of Transaction Data
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z27  RADIOBUTTON GROUP g1 MODIF ID bl2.
SELECTION-SCREEN COMMENT 6(60) TEXT-t05 FOR FIELD p_z27 MODIF ID bl2.
SELECTION-SCREEN END OF LINE.

* Z28: Transfer of Energy and Demand Maximum
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z28  RADIOBUTTON GROUP g1 MODIF ID bl2.
SELECTION-SCREEN COMMENT 6(70) TEXT-t06 FOR FIELD p_z28 MODIF ID bl2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK gb_msg.


SELECTION-SCREEN BEGIN OF BLOCK gb_msgtyp WITH FRAME TITLE TEXT-ft1.


"SELECTION-SCREEN COMMENT 1(50) TEXT-t07.
PARAMETERS: rad_z30 RADIOBUTTON GROUP rgmt USER-COMMAND usercom DEFAULT 'X' ,
            rad_z34 RADIOBUTTON GROUP rgmt.

SELECTION-SCREEN END OF BLOCK gb_msgtyp.


SELECTION-SCREEN BEGIN OF BLOCK gb_action_msgtyp1 WITH FRAME TITLE TEXT-ft2.


DATA type_for_id_marktloc TYPE ext_ui.

SELECT-OPTIONS id_maloc FOR type_for_id_marktloc MODIF ID b30.
PARAMETERS: p_a_dat  TYPE /idxgc/de_proc_date MODIF ID b30,
            p_bilver TYPE /idxgc/de_settl_proc MODIF ID b30.

SELECTION-SCREEN END OF BLOCK gb_action_msgtyp1.

SELECTION-SCREEN BEGIN OF BLOCK gb_action_msgtyp2 WITH FRAME TITLE TEXT-ft3.

DATA: type_for_imp_belegnr TYPE e_logbelnr.

SELECT-OPTIONS im_blgnr FOR type_for_imp_belegnr MODIF ID b34.                                              " Fehler wenn Obligatory.

SELECTION-SCREEN END OF BLOCK gb_action_msgtyp2.
