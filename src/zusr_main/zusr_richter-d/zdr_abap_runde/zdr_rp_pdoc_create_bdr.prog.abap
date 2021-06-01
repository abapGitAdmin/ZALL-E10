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

include zdr_rp_pdoc_create_bdr_top.
*INCLUDE /idxgl/rp_pdoc_create_bdr_top.

include zdr_rp_pdoc_create_bdr_sel.
*INCLUDE /idxgl/rp_pdoc_create_bdr_sel.

include zdr_rp_pdoc_create_bdr_frm.
*INCLUDE /idxgl/rp_pdoc_create_bdr_frm.

include zdr_rp_pdoc_create_bdr_myf.

at selection-screen output.
* Set text fields no input
  perform pf_my_set_text_noinput.
*  perform pf_set_text_noinput.

at selection-screen.
  case sy-ucomm. "ok_code.
*    when space.
*      perform pf_on_action_enter.
    when gc_ucomm_onli.
      perform pf_my_on_action_onli.
*      perform pf_on_action_onli.
  endcase.

start-of-selection.
* Trigger the process engine
  perform pf_my_start_report.
*  perform pf_start_report.
