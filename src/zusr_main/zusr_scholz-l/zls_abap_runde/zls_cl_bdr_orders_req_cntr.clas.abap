class ZLS_CL_BDR_ORDERS_REQ_CNTR definition
  public
  inheriting from /IDXGC/CL_BDR_ORDERS_REQ_CNTR
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_BDR_ORDERS_HDR type /IDXGC/S_BDR_ORDERS_HDR
      !IT_UI_BDR_ORDERS_REQ type ZLS_T_UI_BDR_ORDERS_REQ
    raising
      /IDXGC/CX_PROCESS_ERROR .
protected section.
private section.

  data GT_UI_BDR_ORDERS_REQ type ZLS_T_UI_BDR_ORDERS_REQ .
ENDCLASS.



CLASS ZLS_CL_BDR_ORDERS_REQ_CNTR IMPLEMENTATION.


  method CONSTRUCTOR.
    super->constructor(
      is_bdr_orders_hdr = is_bdr_orders_hdr
    ).

  gt_ui_bdr_orders_req = it_ui_bdr_orders_req.


  endmethod.
ENDCLASS.
