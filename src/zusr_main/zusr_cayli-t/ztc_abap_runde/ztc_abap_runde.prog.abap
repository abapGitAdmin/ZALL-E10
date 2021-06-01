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

**
* Geld sachen: Muharrem abi ,fh Dortmund, Job Raten
*Mobilcom
*
*
*
*
**
REPORT  ztc_abap_runde.

INCLUDE ztc_rp_pdoc_create_bdr_top.
*INCLUDE /idxgl/rp_pdoc_create_bdr_top.

INCLUDE ztc_rp_pdoc_create_bdr_sel.
*INCLUDE /idxgl/rp_pdoc_create_bdr_sel.

INCLUDE ztc_rp_pdoc_create_bdr_frm.
*INCLUDE /idxgl/rp_pdoc_create_bdr_frm.

AT SELECTION-SCREEN OUTPUT.
* Set text fields no input

  PERFORM pf_set_text_noinput.
  PERFORM pf_invisible.
  PERFORM pf_radio_switch.

AT SELECTION-SCREEN ON BLOCK gb_hdr.
* Set OK_CODE                                                          	 Verstehen
  CLEAR ok_code.
  ok_code = sy-ucomm.
* Validate own service provider
  IF ok_code <> 'M34'.                                                    "'M34' vermeiden
    PERFORM pf_valid_ownsp.
  ENDIF.

*  " Set OK_CODE
*  CLEAR ok_code.
*  ok_code = sy-ucomm.
** Aufgabe 3
** Validate own service provider
*  IF p_ownsp IS NOT INITIAL.
*    PERFORM pf_valid_ownsp.
**    PERFORM pf_check_parameters.
*  ENDIF.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pid.
* Set value help for process ID
  PERFORM pf_set_proc_id.
* After process id is selected, update the process type and view
  PERFORM pf_update_type_view.

AT SELECTION-SCREEN.                                                          " X
* Avoid user commond ONLI overwrite OK_CODE
  IF sy-ucomm EQ space.
    CLEAR ok_code.
    ok_code = sy-ucomm.
  ENDIF.




  CASE ok_code.
    WHEN space.
      PERFORM pf_on_action_enter.
    WHEN gc_ucomm_onli.
      PERFORM pf_on_action_onli.
  ENDCASE.


  PERFORM pf_change_rad.


START-OF-SELECTION.                                 "x
* Trigger the process engine
  PERFORM pf_start_report.
