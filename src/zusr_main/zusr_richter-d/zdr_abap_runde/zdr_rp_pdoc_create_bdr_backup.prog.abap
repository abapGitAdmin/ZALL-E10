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

report  zdr_rp_pdoc_create_bdr_backup.

INCLUDE ZDR_RP_CREATE_BDR_TOP_BACKUP.
*include zdr_rp_pdoc_create_bdr_top.
*INCLUDE /idxgl/rp_pdoc_create_bdr_top.

INCLUDE ZDR_RP_CREATE_BDR_SEL_BACKUP.
*include zdr_rp_pdoc_create_bdr_sel.
*INCLUDE /idxgl/rp_pdoc_create_bdr_sel.

INCLUDE ZDR_RP_CREATE_BDR_FRM_BACKUP.
*include zdr_rp_pdoc_create_bdr_frm.
*INCLUDE /idxgl/rp_pdoc_create_bdr_frm.

INCLUDE ZDR_RP_CREATE_BDR_MYF_BACKUP.
*include zdr_rp_pdoc_create_bdr_myf.

*load-of-program.
*  data i type i.
*  i = 0.

at selection-screen output.
* Set text fields no input
  perform pf_my_set_text_noinput.
*  perform pf_set_text_noinput.

*at selection-screen on block gb_hdr.
** Set OK_CODE
*  clear ok_code.
*  ok_code = sy-ucomm.
** Validate own service provider
*  if p_ownsp is not initial.
*    perform pf_valid_ownsp.
*  endif.

*at selection-screen on value-request for p_pid.
** Set value help for process ID
*  perform pf_set_proc_id.
** After process id is selected, update the process type and view
*  perform pf_update_type_view.

at selection-screen.
** Avoid user commond ONLI overwrite OK_CODE
*  if sy-ucomm eq space.
*    clear ok_code.
*    ok_code = sy-ucomm.
*  endif.

  case sy-ucomm. "ok_code.
*    when space.
*      perform pf_on_action_enter.
    when gc_ucomm_onli.
      perform pf_my_on_action_onli.
*      perform pf_on_action_onli.
*    when gc_ucomm_rad.
*      perform pf_my_on_rad_click.
  endcase.

start-of-selection.
* Trigger the process engine
  perform pf_my_start_report.
*  perform pf_start_report.
