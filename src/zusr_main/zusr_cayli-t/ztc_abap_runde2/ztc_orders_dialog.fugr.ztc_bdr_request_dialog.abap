FUNCTION ztc_bdr_request_dialog.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_BDR_ORDERS_HDR_CUSTOM) TYPE  ZTC_S_BDR_ORDERS_HDR
*"     VALUE(IS_BDR_ORDERS_HDR_STANDARD) TYPE  /IDXGC/S_BDR_ORDERS_HDR
*"     REFERENCE(PRMT_UI_BDR_ORDERS_REQ) TYPE  ZTC_T_UI_BDR_ORDERS_REQ
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
*    CREATE OBJECT gr_orders_req_cntr
*      EXPORTING
*        is_bdr_orders_hdr = is_bdr_orders_hdr_standard.

"test Parameter !!!!! bearbeiten!!!
      gr_orders_req_cntr = NEW #( is_bdr_orders_hdr = is_bdr_orders_hdr_standard prmt_ui_bdr_orders_req = PRMT_UI_BDR_ORDERS_REQ ).



    CALL METHOD gr_orders_req_cntr->bdr_orders_hdr_custom
      IMPORTING
        is_bdr_orders_hdr_custom = is_bdr_orders_hdr_custom.






  ENDIF.

  gv_doctype = is_bdr_orders_hdr_standard-docname_code.

* create controller
  gr_orders_req_cntr->create_alv_grid( ).


  CALL SCREEN 100.

ENDFUNCTION.
