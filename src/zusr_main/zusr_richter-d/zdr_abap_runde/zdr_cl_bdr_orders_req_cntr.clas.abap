class ZDR_CL_BDR_ORDERS_REQ_CNTR definition
  public
  inheriting from /IDXGC/CL_BDR_ORDERS_REQ_CNTR
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_BDR_ORDERS_HDR type /IDXGC/S_BDR_ORDERS_HDR
      !IT_UI_BDR_ORDERS_REQ type ZDR_T_UI_BDR_ORDERS_REQ .

  methods CREATE_ALV_GRID
    redefinition .
protected section.

  methods BUILD_FIELDCAT
    redefinition .
private section.

  data GT_UI_BDR_ORDERS_REQ type ZDR_T_UI_BDR_ORDERS_REQ .
ENDCLASS.



CLASS ZDR_CL_BDR_ORDERS_REQ_CNTR IMPLEMENTATION.


method build_fieldcat.

  field-symbols: <fieldcat>   type lvc_s_fcat.

  call function 'LVC_FIELDCATALOG_MERGE'
    exporting
      i_structure_name = co_orders_ui_req
    changing
      ct_fieldcat      = et_fieldcat.

  loop at et_fieldcat assigning <fieldcat>.
    <fieldcat>-valexi = co_valexi_exclam.  "Deactivate domain value check
    <fieldcat>-col_opt = 'A'.
    <fieldcat>-edit = cl_isu_flag=>co_true.
    <fieldcat>-f4availabl = cl_isu_flag=>co_false.

    if gs_bdr_hdr-docname_code = zdr_if_constants_ide=>gc_msg_category_z30.
      "TODO
    endif.

    if <fieldcat>-fieldname = co_fieldname_proc_id or
       <fieldcat>-fieldname = co_fieldname_proc_type or
       <fieldcat>-fieldname = co_fieldname_proc_view or
       <fieldcat>-fieldname = co_fieldname_sender or
       <fieldcat>-fieldname = co_fieldname_receiver or
       <fieldcat>-fieldname = co_fieldname_docname_code.
*   always hide the fields of process data request
      <fieldcat>-tech = cl_isu_flag=>co_true.
    endif.

    if <fieldcat>-fieldname = co_fieldname_ext_ui.
      clear <fieldcat>-col_opt.
      <fieldcat>-lowercase = cl_isu_flag=>co_true.
      <fieldcat>-tech = cl_isu_flag=>co_false.
      <fieldcat>-f4availabl = cl_isu_flag=>co_true.
    endif.

    if <fieldcat>-fieldname = co_fieldname_supply_direct.
      <fieldcat>-tech = cl_isu_flag=>co_false.
    endif.

    if <fieldcat>-fieldname = co_fieldname_proc_ref or
       <fieldcat>-fieldname = co_fieldname_status_text.
      <fieldcat>-edit = cl_isu_flag=>co_false.
      <fieldcat>-tech = cl_isu_flag=>co_false.
    endif.

    if <fieldcat>-fieldname = co_fieldname_async.
      <fieldcat>-tech = cl_isu_flag=>co_false.
      <fieldcat>-checkbox = cl_isu_flag=>co_true.
    endif.

  endloop.

  if gr_badi_bdr is bound.
    call badi gr_badi_bdr->adjust_screen_fields
      exporting
        is_bdr_hdr        = gs_bdr_hdr
        is_structure_name = co_orders_ui_req
      changing
        ct_fieldcat       = et_fieldcat.
  endif.
endmethod.


  method constructor.
    super->constructor(
      is_bdr_orders_hdr = is_bdr_orders_hdr
    ).

    gt_ui_bdr_orders_req = it_ui_bdr_orders_req.

    co_orders_ui_req = 'ZDR_S_UI_BDR_ORDERS_REQ'.
  endmethod.


  method create_alv_grid.

    data: lt_fieldcat type lvc_t_fcat.
    data: ls_variant  type disvariant.
    data: ls_layout   type lvc_s_layo.
    data: lt_exclude  type ui_functions.

    field-symbols: <fs_orders_req> type zdr_s_ui_bdr_orders_req.

    call function 'LVC_VARIANT_DEFAULT_GET'
      exporting
        i_save     = 'A'
      changing
        cs_variant = ls_variant
      exceptions
        others     = 1.

    if sy-subrc <> 0.
      ls_variant-report = co_rp_name.
    endif.

    ls_layout-smalltitle = cl_isu_flag=>co_true.
    ls_layout-stylefname = 'CELLSTTYLE'.

    if me->grid_container is initial.
      create object me->grid_container
        exporting
          container_name = co_orders_container.

      if me->alv_grid is initial.
        create object me->alv_grid
          exporting
            i_parent = me->grid_container.

        call method me->build_fieldcat
          importing
            et_fieldcat = lt_fieldcat.

        me->gt_fieldcat = lt_fieldcat.

        call method me->exclude_grid_functions
          changing
            ct_ui_functions_exclude = lt_exclude.

* display the input screen of request data
        call method me->alv_grid->set_table_for_first_display
          exporting
*            i_structure_name     = co_orders_ui_req
            is_variant           = ls_variant
            i_default            = cl_isu_flag=>co_true
            i_save               = 'A'
            is_layout            = ls_layout
            it_toolbar_excluding = lt_exclude
          changing
            it_outtab            = me->gt_ui_bdr_orders_req
            it_fieldcatalog      = lt_fieldcat.

* set layout
        call method me->alv_grid->set_frontend_layout
          exporting
            is_layout = ls_layout.

* register edit event
        call method me->alv_grid->register_edit_event
          exporting
            i_event_id = cl_gui_alv_grid=>mc_evt_modified
          exceptions
            error      = 1
            others     = 2.

* allow edit
        call method me->alv_grid->set_ready_for_input
          exporting
            i_ready_for_input = 1.

* set handler
        set handler
            me->on_double_click
            me->on_data_changed
            for me->alv_grid.
      endif.
    else.
      call method me->alv_grid->refresh_table_display.
    endif.
  endmethod.
ENDCLASS.
