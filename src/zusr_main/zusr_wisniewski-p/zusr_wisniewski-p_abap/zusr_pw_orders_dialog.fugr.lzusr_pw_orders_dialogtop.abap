FUNCTION-POOL ZUSR_PW_ORDERS_DIALOG.         "MESSAGE-ID ..


DATA:
      gr_orders_req_cntr TYPE REF TO /idxgl/cl_bdr_orders_req_cntr.

DATA: gv_okcode  TYPE cua_code,
      gv_doctype TYPE /idxgc/de_docname_code.
