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

REPORT  zusr_ker_rp_pdoc_create_bdr.

*INCLUDE zuse_ker_pdoc_create_bdr_top3.
**INCLUDE /idxgl/rp_pdoc_create_bdr_top.

INCLUDE zuse_ker_pdoc_create_bdr_sel3.
*INCLUDE /idxgl/rp_pdoc_create_bdr_sel.

INCLUDE zuse_ker_pdoc_create_bdr_frm3.
*INCLUDE /idxgl/rp_pdoc_create_bdr_frm.

*für die message
AT SELECTION-SCREEN.
  IF sy-ucomm = 'R01'.
    PERFORM pf_message_screen.
  ENDIF.

* für den RADIOBUTTON wechsel.
AT SELECTION-SCREEN OUTPUT.
* Set text fields no input
  PERFORM pf_set_text_noinput.
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'P_Z26'.
        screen-required = '2'.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON d_eui2.
  IF sy-ucomm = 'ONLI'.
    IF p_z16 IS INITIAL.
      MESSAGE 'Import-Belegnummer eingeben' TYPE 'I'. "besseer w      "e055(00). eine andere möglichkeit für MESSAGE
    ENDIF.
  ENDIF.



AT USER-COMMAND.
  IF sy-ucomm = 'R01'.
    PERFORM pf_set_text_noinput.
  ENDIF.



*** if lines( d_eui2 ) = 0.
*** MESSAGE 'test' TYPE 'I'.
***   CALL SELECTION-SCREEN 1000.
*** endif.
*
*AT SELECTION-SCREEN ON BLOCK gb_hdr.
** Set OK_CODE
*  CLEAR ok_code.
*  ok_code = sy-ucomm.
** Validate own service provider
*  PERFORM pf_valid_ownsp.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pid.
** Set value help for process ID
*  PERFORM pf_set_proc_id.
** After process id is selected, update the process type and view
*  PERFORM pf_update_type_view.
*
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
*
*  AT SELECTION-SCREEN ON p_pdate.
*    PERFORM test.
*
*FORM test.
*  if p_pdate eq '1'.
*    ENDIF.
*ENDFORM.
*
*START-OF-SELECTION.
** Trigger the process engine
*  PERFORM pf_start_report.
