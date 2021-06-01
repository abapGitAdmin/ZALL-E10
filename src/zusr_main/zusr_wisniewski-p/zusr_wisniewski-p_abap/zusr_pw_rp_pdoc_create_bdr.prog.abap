*----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2014
**
** Usage:
* a) The report is used to create business data request via process engine
*
** Status: Initial
*----------------------------------------------------------------------*
** Change History:
**  May 2014:  Created
**
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  /IDXGC/RP_PDOC_CREATE_BDR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zusr_pw_rp_pdoc_create_bdr.

*INCLUDE ZUSR_PW_RP_PDOC_CREATE_BDR_TOP.
*INCLUDE /idxgl/rp_pdoc_create_bdr_top.

*INCLUDE ZUSR_PW_RP_PDOC_CREATE_BDR_SEL.
*INCLUDE /idxgl/rp_pdoc_create_bdr_sel.

*INCLUDE ZUSR_PW_RP_PDOC_CREATE_BDR_FRM.
*INCLUDE /idxgl/rp_pdoc_create_bdr_frm.

*AT SELECTION-SCREEN OUTPUT.
** Set text fields no input
*  PERFORM pf_set_text_noinput.

*AT SELECTION-SCREEN ON BLOCK gb_hdr.
** Set OK_CODE
*  CLEAR ok_code.
*  ok_code = sy-ucomm.
** Validate own service provider
*  PERFORM pf_valid_ownsp.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pid.
** Set value help for process ID
*  PERFORM pf_set_proc_id.
** After process id is selected, update the process type and view
*  PERFORM pf_update_type_view.

*AT SELECTION-SCREEN.
** Avoid user commond ONLI overwrite OK_CODE
*  IF sy-ucomm EQ space.
*    CLEAR ok_code.
*    ok_code = sy-ucomm.
*  ENDIF.
*
*  CASE ok_code.
*    WHEN space.
*      PERFORM pf_on_action_enter.
*    WHEN gc_ucomm_onli.
*      PERFORM pf_on_action_onli.
*  ENDCASE.
*
*START-OF-SELECTION.
** Trigger the process engine
*  PERFORM pf_start_report.

SELECTION-SCREEN BEGIN OF BLOCK gb_hdr WITH FRAME TITLE TEXT-bk1.

*SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z30  RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND chng.
*SELECTION-SCREEN COMMENT 6(70) TEXT-t10 FOR FIELD p_z30.
*SELECTION-SCREEN END OF LINE.

*SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_z34  RADIOBUTTON GROUP g1.
*SELECTION-SCREEN COMMENT 6(70) TEXT-t11 FOR FIELD p_z34.
*SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_hdr.


SELECTION-SCREEN BEGIN OF BLOCK gb_z30 WITH FRAME TITLE TEXT-bk2.

SELECTION-SCREEN BEGIN OF LINE.
DATA p_ext_ui TYPE ext_ui.
SELECTION-SCREEN COMMENT 1(39) TEXT-t20 FOR FIELD s_extui.
SELECT-OPTIONS s_extui FOR p_ext_ui.
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
SELECT-OPTIONS logbel FOR p_logbel.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK gb_z34.

AT SELECTION-SCREEN.
  IF sy-ucomm = 'CHNG'.
    PERFORM pf_update_screen.
  ENDIF.

*  AT SELECTION-SCREEN ON BLOCK gb_hdr.
*  IF sy-ucomm = 'CHNG'.
*    IF p_z30 = abap_true.
*      MESSAGE 'selection! z30' TYPE 'I'.
*    ELSEIF p_z34 = abap_true.
*      MESSAGE 'selection! z34' TYPE 'I'.
*    ENDIF.
*    MESSAGE 'selection!' TYPE 'I'.
*  ENDIF.

*AT USER-COMMAND.
*  IF sy-ucomm = 'chng'.
*    IF p_z30 = abap_true.
*      MESSAGE 'user! z30' TYPE 'I'.
*    ELSEIF p_z34 = abap_true.
*      MESSAGE 'user! z34' TYPE 'I'.
*    ENDIF.
*    MESSAGE 'user!' TYPE 'I'.
*  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  PF_UPDATE_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_update_screen .
  IF p_z30 = abap_true.
    LOOP AT SCREEN.
      screen-input = 1.
    ENDLOOP.
    MODIFY SCREEN.
    MESSAGE 'selection! z30' TYPE 'I'.
  ELSEIF p_z34 = abap_true.
    LOOP AT SCREEN.
      screen-input = 0.
    ENDLOOP.
    MODIFY SCREEN.
    MESSAGE 'selection! z34' TYPE 'I'.
  ENDIF.
ENDFORM.
