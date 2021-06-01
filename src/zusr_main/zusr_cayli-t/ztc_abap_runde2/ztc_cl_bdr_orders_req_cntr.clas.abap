class ZTC_CL_BDR_ORDERS_REQ_CNTR definition
  public
  inheriting from /IDXGC/CL_BDR_ORDERS_REQ_CNTR
  create public .

public section.

  data GV_GET_UI_BDR_ORDERS_REQ type ZTC_T_UI_BDR_ORDERS_REQ .

  methods BDR_ORDERS_HDR_CUSTOM
    exporting
      value(IS_BDR_ORDERS_HDR_CUSTOM) type ZTC_S_BDR_ORDERS_HDR .
  methods CONSTRUCTOR
    importing
      !IS_BDR_ORDERS_HDR type /IDXGC/S_BDR_ORDERS_HDR
      !PRMT_UI_BDR_ORDERS_REQ type ZTC_T_UI_BDR_ORDERS_REQ .

  methods CREATE_ALV_GRID
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZTC_CL_BDR_ORDERS_REQ_CNTR IMPLEMENTATION.


  method BDR_ORDERS_HDR_CUSTOM.

    DATA ls_bdr_ord_cus type ZTC_S_BDR_ORDERS_HDR.

*     ls_bdr_ord_cus-id_maloc_s = is_bdr_orders_hdr_custom-id_maloc_s.
*     ls_bdr_ord_cus-id_maloc_e = is_bdr_orders_hdr_custom-id_maloc_e.
*     ls_bdr_ord_cus-p_a_dat =  is_bdr_orders_hdr_custom-p_a_dat.
*     ls_bdr_ord_cus-p_bilver = is_bdr_orders_hdr_custom-p_bilver.
*     ls_bdr_ord_cus-im_blgnr_s = is_bdr_orders_hdr_custom-im_blgnr_s.
*     ls_bdr_ord_cus-im_blgnr_e = is_bdr_orders_hdr_custom-im_blgnr_e.

    is_bdr_orders_hdr_custom-id_maloc_s = ls_bdr_ord_cus-id_maloc_s.
    is_bdr_orders_hdr_custom-id_maloc_e = ls_bdr_ord_cus-id_maloc_e.
    is_bdr_orders_hdr_custom-p_a_dat = ls_bdr_ord_cus-p_a_dat.
    is_bdr_orders_hdr_custom-p_bilver = ls_bdr_ord_cus-p_bilver.
    is_bdr_orders_hdr_custom-im_blgnr_s = ls_bdr_ord_cus-im_blgnr_s.
    is_bdr_orders_hdr_custom-im_blgnr_e = ls_bdr_ord_cus-im_blgnr_e.


  endmethod.


  method CONSTRUCTOR.

    super->constructor( IS_BDR_ORDERS_HDR ).

    me->gv_get_ui_bdr_orders_req = PRMT_UI_BDR_ORDERS_REQ.


     data: gs_orders_req        type /idxgc/s_ui_bdr_orders_req,
          gs_ui_bdr_orders_req type ztc_s_ui_bdr_orders_req.
    loop at prmt_UI_BDR_ORDERS_REQ into gs_ui_bdr_orders_req.
      move-corresponding gs_ui_bdr_orders_req to gs_orders_req.
      append gs_orders_req to gt_orders_req.
    endloop.


  endmethod.


  method CREATE_ALV_GRID.

    "Editierbar.

DATA: lt_fieldcat TYPE lvc_t_fcat.
  DATA: ls_variant  TYPE disvariant.
  DATA: ls_layout   TYPE lvc_s_layo.
  DATA: lt_exclude  TYPE ui_functions.


  FIELD-SYMBOLS:
       " <fs_orders_req> TYPE /idxgc/s_ui_bdr_orders_req.
       <fs_orders_req> TYPE ZTC_s_UI_BDR_ORDERS_REQ.

  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = 'A'
    CHANGING
      cs_variant = ls_variant
    EXCEPTIONS
      OTHERS     = 1.

  IF sy-subrc <> 0.
    ls_variant-report = co_rp_name.
  ENDIF.

  ls_layout-smalltitle = cl_isu_flag=>co_true.
  ls_layout-stylefname = 'CELLSTTYLE'.

  IF me->grid_container IS INITIAL.
    CREATE OBJECT me->grid_container
      EXPORTING
        container_name = co_orders_container.

    IF me->alv_grid IS INITIAL.
* append a initial line to the out alv grid
      "APPEND INITIAL LINE TO me->gv_get_ui_bdr_orders_req ASSIGNING <fs_orders_req>.                                "meins
      "APPEND INITIAL LINE TO me->gt_orders_req ASSIGNING <fs_orders_req>.                                          orginal
      "<fs_orders_req>-bdr_hdr  = gs_bdr_hdr.                                                                       "auskommentiert
*      <fs_orders_req>-sender   = me->gv_sender.
*      <fs_orders_req>-receiver = me->gv_receiver.

      CREATE OBJECT me->alv_grid
        EXPORTING
          i_parent = me->grid_container.
      CO_ORDERS_UI_REQ = 'ztc_s_ui_bdr_orders_req'.
      CALL METHOD me->build_fieldcat
        IMPORTING
          et_fieldcat = lt_fieldcat.

      me->gt_fieldcat = lt_fieldcat.

      CALL METHOD me->exclude_grid_functions
        CHANGING
          ct_ui_functions_exclude = lt_exclude.

* display the input screen of request data
      CALL METHOD me->alv_grid->set_table_for_first_display
        EXPORTING
          i_structure_name     = co_orders_ui_req
          is_variant           = ls_variant
          i_default            = cl_isu_flag=>co_true
          i_save               = 'A'
          is_layout            = ls_layout
          it_toolbar_excluding = lt_exclude
        CHANGING
          it_outtab            = me->gv_get_ui_bdr_orders_req     "gt_orders_req
         it_fieldcatalog      = lt_fieldcat.

* set layout
      CALL METHOD me->alv_grid->set_frontend_layout
        EXPORTING
          is_layout = ls_layout.

* register edit event
      CALL METHOD me->alv_grid->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified
        EXCEPTIONS
          error      = 1
          OTHERS     = 2.

* allow edit
      CALL METHOD me->alv_grid->set_ready_for_input
        EXPORTING
          i_ready_for_input = 1.

* set handler
      SET HANDLER
          me->on_double_click
          me->on_data_changed
          FOR me->alv_grid.

    ENDIF.

  ELSE.

    CALL METHOD me->alv_grid->refresh_table_display.

  ENDIF.


  endmethod.
ENDCLASS.
