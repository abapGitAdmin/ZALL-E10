FUNCTION request_dialog_aufg.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DOCTYPE) TYPE  ZPROC_DOCTYPE
*"     VALUE(LS_BDR_ORDERS_HDR) TYPE  /IDXGC/S_BDR_ORDERS_HDR
*"     VALUE(IT_BDR_ORDERS_NEWHDR) TYPE  ZTT_AO_BDR_ORDERS_REQ
*"  RAISING
*"      /IDXGC/CX_PROCESS_ERROR
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------*
** Author: OSTROP-A
*
** Change History:
** Oct. 2018: Created
*-----------------------------------------------------------------------*

  IF gr_clao_bdr_cntr IS NOT BOUND.
    CREATE OBJECT gr_clao_bdr_cntr
    EXPORTING is_bdr_orders_hdr = ls_bdr_orders_hdr it_bdr_orders_newhdr = it_bdr_orders_newhdr.
    "gr_clao_bdr_cntr = NEW #( is_bdr_orders_hdr = ls_bdr_orders_hdr it_bdr_orders_newhdr = it_bdr_orders_newhdr ).
  ENDIF.

  gv_doctype = ls_bdr_orders_hdr-docname_code.
*  gv_doctype = doctype.

  gr_clao_bdr_cntr->create_alv_grid( ).
  CALL SCREEN 0100.

ENDFUNCTION.
