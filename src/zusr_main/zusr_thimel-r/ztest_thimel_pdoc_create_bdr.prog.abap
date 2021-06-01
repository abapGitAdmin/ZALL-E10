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

REPORT  ztest_thimel_pdoc_create_bdr.

*INCLUDE Z_THIMEL_PDOC_CREATE_BDR_TOP.
**INCLUDE /idxgl/rp_pdoc_create_bdr_top.
*
*INCLUDE Z_THIMEL_PDOC_CREATE_BDR_SEL.
**INCLUDE /idxgl/rp_pdoc_create_bdr_sel.
*
*INCLUDE Z_THIMEL_PDOC_CREATE_BDR_FRM.
**INCLUDE /idxgl/rp_pdoc_create_bdr_frm.
*
*AT SELECTION-SCREEN OUTPUT.
** Set text fields no input
*  PERFORM pf_set_text_noinput.
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
*AT SELECTION-SCREEN ON p_ownsp.
*
*  IF 1 = 2.
*  ENDIF.
*
*START-OF-SELECTION.
** Trigger the process engine
*CALL SCREEN 1001.
*  "PERFORM pf_start_report.


DATA BUKRS TYPE BKPF-BUKRS.
DATA GJAHR TYPE char30.
DATA BELNR TYPE BKPF-BELNR.
*DATA AWREF TYPE ACCIT-AWREF.
*DATA AWORG TYPE ACCIT-AWORG.

CALL FUNCTION 'FI_BELNR_TO_AWREF'
  EXPORTING
    bukrs         = bukrs
    gjahr         = gjahr
    belnr         = belnr
* IMPORTING
*   AWREF         = AWREF
*   AWORG         = AWORG
          .
