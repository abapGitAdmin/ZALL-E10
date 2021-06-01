class ZCL_RT_BDR_ORDERS_REQ_CNTR definition
  public
  inheriting from /IDXGL/CL_BDR_ORDERS_REQ_CNTR
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_BDR_ORDERS_HDR type /IDXGC/S_BDR_ORDERS_HDR optional
      !IT_BDR_ORDERS type ZTT_AO_BDR_ORDERS_REQ optional
    raising
      /IDXGC/CX_PROCESS_ERROR .

  methods CREATE_ALV_GRID
    redefinition .
protected section.
private section.

  data GT_ORDERS_DATA type ZTT_AO_BDR_ORDERS_REQ .
ENDCLASS.



CLASS ZCL_RT_BDR_ORDERS_REQ_CNTR IMPLEMENTATION.


  METHOD constructor.

    super->constructor( is_bdr_orders_hdr ).

    gt_orders_data = it_bdr_orders.

  ENDMETHOD.


METHOD CREATE_ALV_GRID.

  DATA: lt_fieldcat TYPE lvc_t_fcat.
  DATA: ls_variant  TYPE disvariant.
  DATA: ls_layout   TYPE lvc_s_layo.
  DATA: lt_exclude  TYPE ui_functions.


  FIELD-SYMBOLS:
        <fs_orders_req> TYPE /idxgc/s_ui_bdr_orders_req.

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
      APPEND INITIAL LINE TO me->gt_orders_req ASSIGNING <fs_orders_req>.
      <fs_orders_req>-bdr_hdr  = gs_bdr_hdr.
*      <fs_orders_req>-sender   = me->gv_sender.
*      <fs_orders_req>-receiver = me->gv_receiver.

      CREATE OBJECT me->alv_grid
        EXPORTING
          i_parent = me->grid_container.

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
          it_outtab            = me->gt_orders_req
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

ENDMETHOD.
ENDCLASS.
