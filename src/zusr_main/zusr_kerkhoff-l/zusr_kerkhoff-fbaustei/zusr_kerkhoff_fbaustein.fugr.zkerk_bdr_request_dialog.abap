FUNCTION ZKERK_BDR_REQUEST_DIALOG.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_BDR_ORDERS_HDR) TYPE  /IDXGC/S_BDR_ORDERS_HDR
*"  RAISING
*"      /IDXGC/CX_PROCESS_ERROR
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------*
** Author: SAP Custom Development, July 2017
**
** Usage: Popup a dialog to input BDR request data
*-----------------------------------------------------------------------*
** Change History:
** Jul. 2017: Created
*-----------------------------------------------------------------------*

  IF gr_orders_req_cntr IS NOT BOUND.
   gr_orders_req_cntr = new ZCL_RT_BDR_ORDERS_REQ_CNTR2( is_bdr_orders_hdr = is_bdr_orders_hdr ).


  ENDIF.

  gv_doctype = is_bdr_orders_hdr-docname_code.

* create controller
  gr_orders_req_cntr->create_alv_grid( ).

  CALL SCREEN 100.

ENDFUNCTION.
