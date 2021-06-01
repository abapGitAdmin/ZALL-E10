FUNCTION zls_bdr_request_dialog.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_BDR_ORDERS_HDR) TYPE  /IDXGC/S_BDR_ORDERS_HDR
*"     VALUE(IS_ZLS_BDR_ORDERS) TYPE  ZLS_S_BDR_ORDERS
*"     VALUE(IT_ZLS_UI_BDR_ORDERS_REQ) TYPE  ZLS_T_UI_BDR_ORDERS_REQ
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
    CREATE OBJECT gr_orders_req_cntr
      EXPORTING
        is_bdr_orders_hdr        = is_bdr_orders_hdr.
        is_zls_bdr_orders        = is_zls_bdr_orders.
        it_zls_ui_bdr_orders_req = it_zls_ui_bdr_orders_req.
  ENDIF.

  gv_doctype = is_bdr_orders_hdr-docname_code.

* create controller
  gr_orders_req_cntr->create_alv_grid( ).

  CALL SCREEN 100.

ENDFUNCTION.
