FUNCTION-POOL ZDR_ORDERS_DIALOG.         "MESSAGE-ID ..


DATA:
      gr_orders_req_cntr TYPE REF TO zdr_cl_bdr_orders_req_cntr.

DATA: gv_okcode  TYPE cua_code,
      gv_doctype TYPE /idxgc/de_docname_code.
