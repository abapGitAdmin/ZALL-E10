REPORT  zuse_ker_rp_pdoc_creat_bdr4.



CONSTANTS:
  gc_scr_grp_txt        TYPE screen-group1 VALUE 'TXT',
* eigene Constanten
  gc_test               TYPE String VALUE 'AD_DO_S_LF',
  gc_test2              TYPE String VALUE 'AD_DO_S_NB',
  gc_test3              TYPE i      VALUE '8020'.

*START-OF-SELECTION.
** Trigger the process engine
*  PERFORM pf_fill.

LOAD-OF-PROGRAM.
PERFORM pf_fill.

FORM pf_set_text_noinput .
  LOOP AT SCREEN.
        IF screen-group1 EQ gc_scr_grp_txt.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " PF_SET_TEXT_NOINPUT






SELECTION-SCREEN BEGIN OF BLOCK gb_hdr WITH FRAME TITLE TEXT-bk1.
PARAMETERS:
  p_ownsp TYPE e_dexservprovself MATCHCODE OBJECT serviceprovider OBLIGATORY,
  p_rcver TYPE e_dexservprov OBLIGATORY.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-t02 FOR FIELD p_pvw.
PARAMETERS:
  p_pvw  TYPE /idxgc/de_proc_view  MODIF ID txt,
  p_pvwt TYPE eideswtviewtxt MODIF ID txt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-t03 FOR FIELD p_pty.
PARAMETERS:
  p_pty  TYPE /idxgc/de_proc_type MODIF ID txt,
  p_ptyt TYPE eideswttypetxt MODIF ID txt.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-t01 FOR FIELD p_pid.
PARAMETERS:
  p_pid  TYPE /idxgc/de_proc_id OBLIGATORY,
  p_pidt TYPE /idxgc/de_proc_descr MODIF ID txt.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_hdr.

SELECTION-SCREEN BEGIN OF BLOCK gb_msg WITH FRAME TITLE TEXT-bk2.

* Z14: Master Data for Point of Delivery
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z14  RADIOBUTTON GROUP g1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 6(70) TEXT-t04 FOR FIELD p_z14.
SELECTION-SCREEN END OF LINE.

* Z27: Transfer of Transaction Data
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z27  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(60) TEXT-t05 FOR FIELD p_z27.
SELECTION-SCREEN END OF LINE.

* Z28: Transfer of Energy and Demand Maximum
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z28  RADIOBUTTON GROUP g1.
SELECTION-SCREEN COMMENT 6(70) TEXT-t06 FOR FIELD p_z28.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK gb_msg.



FORM pf_fill .
if 0 = 0.
p_ownsp = gc_test.
p_rcver = gc_test2.
p_pid   = gc_test3.
ENDIF.
  MODIFY SCREEN.
ENDFORM.


AT SELECTION-SCREEN OUTPUT.
* Set text fields no input
  PERFORM pf_set_text_noinput.
