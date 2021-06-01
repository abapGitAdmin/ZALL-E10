function zdr_bdr_request_dialog.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_BDR_ORDERS_HDR) TYPE  /IDXGC/S_BDR_ORDERS_HDR
*"     REFERENCE(IT_UI_BDR_ORDERS_REQ) TYPE  ZDR_T_UI_BDR_ORDERS_REQ
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

  if gr_orders_req_cntr is not bound.
**   Möglichkeit 1
*    create object gr_orders_req_cntr
*      exporting
*        is_bdr_orders_hdr = is_bdr_orders_hdr.
**   Möglichkeit 2
*    create object gr_orders_req_cntr type zdr_cl_bdr_orders_req_cntr
*      exporting
*        is_bdr_orders_hdr = is_bdr_orders_hdr.
*   Möglichkeit 3
    gr_orders_req_cntr = new #(
      is_bdr_orders_hdr = is_bdr_orders_hdr
      it_ui_bdr_orders_req = it_ui_bdr_orders_req
    ).
  endif.

  gv_doctype = is_bdr_orders_hdr-docname_code.

* create controller
  gr_orders_req_cntr->create_alv_grid( ).

  call screen 100.

endfunction.
