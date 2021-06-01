************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT zz_alv_tree.

DATA: ls_sflight TYPE sflight,
      lt_sflight TYPE TABLE OF sflight INITIAL SIZE 0,
      it_fcat    TYPE lvc_t_fcat,
      is_fcat    TYPE lvc_s_fcat.

DATA: g_alv_tree         TYPE REF TO cl_gui_alv_tree,
      g_custom_container TYPE REF TO cl_gui_custom_container,
      o_alvgrid          TYPE REF TO cl_gui_alv_grid,
      go_tree_toolbar    TYPE REF TO cl_gui_toolbar,
      g_drag_behaviour   TYPE REF TO cl_dragdrop,
      g_drop_behaviour   TYPE REF TO cl_dragdrop,
      o_dial             TYPE REF TO cl_gui_dialogbox_container.
DATA: gt_sflight      TYPE TABLE OF sflight INITIAL SIZE 0,      "Output-Table
      gt_fieldcatalog TYPE lvc_t_fcat,
      g_top_key       TYPE lvc_nkey,
      ok_code         LIKE sy-ucomm,
      save_ok         LIKE sy-ucomm,           "OK-Code
      g_max           TYPE i VALUE 255.


CLASS lcl_dragdropobj DEFINITION.
  PUBLIC SECTION.
    DATA: cp_sflight_root     TYPE sflight,
          cp_sflights         TYPE TABLE OF sflight,
          cp_node_text_root   TYPE lvc_value,
          cp_node_texts       TYPE salv_t_value,
          lt_selected_carrids TYPE lvc_t_nkey,
          lt_selected_leafs   TYPE lvc_t_nkey.
ENDCLASS.

CLASS lcl_navigate_tree DEFINITION FINAL. "INHERITING FROM cl_gui_container.
  PUBLIC SECTION.


    CLASS-METHODS :
*     Hide standard tool bar button in chapter tree
      hide_toolbar_chapter_tree CHANGING xt_exculde TYPE  ui_functions,

      add_button,

      change_chapter_node.

    CLASS-METHODS : handle_close FOR EVENT close OF cl_gui_dialogbox_container
      IMPORTING sender. "triggers when user clicks

ENDCLASS.

CLASS lcl_navigate_tree IMPLEMENTATION.


  METHOD   handle_close.
    CALL METHOD sender->set_visible
      EXPORTING
        visible = space.

  ENDMETHOD.
  METHOD hide_toolbar_chapter_tree.


    DATA: ls_func TYPE ui_func.
    ls_func =  '&CALC'.
    APPEND ls_func TO xt_exculde.
    CLEAR ls_func.
    ls_func = '&PRINT_PREV'.
    APPEND ls_func TO xt_exculde.
    CLEAR ls_func.
  ENDMETHOD.

  METHOD add_button.

    CALL METHOD g_alv_tree->get_toolbar_object
      IMPORTING
        er_toolbar = go_tree_toolbar.
    CHECK NOT   go_tree_toolbar IS INITIAL. "could happen if you do not use the

* Add button for refresh
    CALL METHOD go_tree_toolbar->add_button
      EXPORTING
        fcode     = 'REF'
        icon      = icon_refresh
        butn_type = cntb_btype_button
        text      = space
        quickinfo = TEXT-098.

  ENDMETHOD.


  METHOD change_chapter_node.


  ENDMETHOD.
ENDCLASS.

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.

    METHODS: on_function_selected
                FOR EVENT function_selected OF cl_gui_toolbar
      IMPORTING fcode.
*    METHODS:
*      on_drag
*      FOR EVENT on_drag
*                  OF cl_gui_alv_tree
*        IMPORTING sender node_key drag_drop_object,
*      on_drop
*      FOR EVENT on_drop
*                  OF cl_gui_alv_tree
*        IMPORTING drag_drop_object.
ENDCLASS.
*---------------------------------------------------------------------*
*       CLASS lcl_toolbar_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.


  METHOD on_function_selected.
    DATA go_navigate_tree TYPE REF TO lcl_navigate_tree.
    DATA: lv_index   TYPE sy-index.
    DATA: lt_selected_nodes TYPE lvc_t_nkey,
          ls_selected_node  TYPE lvc_nkey,
          lv_error          TYPE char1,
          test              TYPE REF TO cl_alv_tree_base.


    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF..


    DATA: c_lvc_fname         TYPE lvc_fname VALUE 'C_SPL_NODE_DESC'.
    DATA: c_lvc_nkey              TYPE lvc_nkey.

* Determine which line is selected
    CALL METHOD g_alv_tree->get_selected_nodes
      CHANGING
        ct_selected_nodes = lt_selected_nodes.

    CALL METHOD cl_gui_cfw=>flush.

    READ TABLE lt_selected_nodes INTO ls_selected_node INDEX 1.
* Query the function codes of the toolbar in your implementation.
    CASE fcode.

      WHEN 'REF'.

        call SCREEN 200.

        READ TABLE lt_selected_nodes INTO  DATA(lv_selected_node) INDEX 1.

        PERFORM build_fieldcat.

        CREATE OBJECT o_dial
          EXPORTING
            width   = 400
            height  = 100
            top     = 60
            left    = 60
            caption = 'SUCHEN / ERSETZEN'.

*        CREATE OBJECT go_navigate_tree.
*        SET HANDLER go_navigate_tree->handle_close FOR o_dial.
        SET HANDLER lcl_navigate_tree=>handle_close FOR o_dial.

data: suchtext type C LENGTH 132.
CALL FUNCTION 'C14C_POPUP_FOR_SEARCH'
 IMPORTING
   E_SEARCHTXT       = suchtext .

        CREATE OBJECT o_alvgrid
          EXPORTING
            i_parent = o_dial.

        CALL METHOD o_alvgrid->set_table_for_first_display
          CHANGING
            it_outtab       = lt_sflight
            it_fieldcatalog = it_fcat.


        IF sy-subrc <> 0.
*         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CALL METHOD o_alvgrid->refresh_table_display.

        REFRESH it_fcat.


*        IF sy-subrc IS INITIAL.


*      data : lv_nodetext type LVC_VALUE value 'TEXT' . "gs_chapter-c_spl_node_code.
*      CALL METHOD g_alv_tree->change_node
*        EXPORTING
*          i_node_key    = lv_selected_node
*          i_outtab_line = ' '
*          i_node_text   = lv_nodetext
*          i_u_node_text = abap_true. "'X'.
*        ENDIF.



    ENDCASE.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

END-OF-SELECTION.
  CALL SCREEN 100.
*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  SET PF-STATUS 'MAIN100'.
  SET TITLEBAR 'MAINTITLE'.
  IF g_alv_tree IS INITIAL.
    PERFORM init_tree.
    CALL METHOD cl_gui_cfw=>flush
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
  ENDIF.
ENDMODULE.                             " PBO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       process after input
*----------------------------------------------------------------------*
MODULE pai INPUT.
  save_ok = ok_code.
  CLEAR ok_code.
  CASE save_ok.
    WHEN 'EXIT' OR 'BACK' OR 'CANC'.
      PERFORM exit_program.
    WHEN OTHERS.
      CALL METHOD cl_gui_cfw=>dispatch.
  ENDCASE.
  CALL METHOD cl_gui_cfw=>flush.
ENDMODULE.                             " PAI  INPUT


*&---------------------------------------------------------------------*
*&      Form  init_tree
*&---------------------------------------------------------------------*
FORM init_tree.

  DATA go_navigate_tree TYPE REF TO lcl_navigate_tree.
  DATA: lt_chptool_exclude  TYPE ui_functions.
* create container for alv-tree
  DATA: l_tree_container_name(30) TYPE c.
  l_tree_container_name = 'CCONTAINER1'.
  CREATE OBJECT g_custom_container
    EXPORTING
      container_name = l_tree_container_name.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'(100).
  ENDIF.
* create tree control
  CREATE OBJECT g_alv_tree
    EXPORTING
      parent              = g_custom_container
      node_selection_mode = cl_gui_column_tree=>node_sel_mode_multiple
      item_selection      = ' '
      no_html_header      = 'X'
      no_toolbar          = ''.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.
  DATA l_hierarchy_header TYPE treev_hhdr.
  l_hierarchy_header-width = 35.
  PERFORM build_fieldcatalog.
* method call to hide tree(chapter) tool bar
  CREATE OBJECT go_navigate_tree.

  CALL METHOD go_navigate_tree->hide_toolbar_chapter_tree
    CHANGING
      xt_exculde = lt_chptool_exclude.

  CALL METHOD go_navigate_tree->add_button.

  CALL METHOD g_alv_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header  = l_hierarchy_header
      it_toolbar_excluding = lt_chptool_exclude
    CHANGING
      it_fieldcatalog      = gt_fieldcatalog
      it_outtab            = gt_sflight.

  PERFORM define_dnd_behaviour.
  PERFORM create_hierarchy.
  PERFORM register_events.
  CALL METHOD g_alv_tree->update_calculations.
  CALL METHOD g_alv_tree->frontend_update.
ENDFORM.                               " init_tree

FORM register_events.
  DATA: lt_events        TYPE cntl_simple_events,
        ls_event         TYPE cntl_simple_event,
        l_event_receiver TYPE REF TO lcl_event_receiver.

  CALL METHOD g_alv_tree->get_registered_events
    IMPORTING
      events = lt_events.


  ls_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  APPEND ls_event TO lt_events.
  ls_event-eventid = cl_gui_column_tree=>eventid_node_context_menu_req.
  APPEND ls_event TO lt_events.

  CALL METHOD g_alv_tree->set_registered_events
    EXPORTING
      events = lt_events.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.



  CREATE OBJECT l_event_receiver.
  SET HANDLER l_event_receiver->on_function_selected FOR go_tree_toolbar.
*  SET HANDLER l_event_receiver->on_drop FOR g_alv_tree.
*  SET HANDLER l_event_receiver->on_drag FOR g_alv_tree.
ENDFORM.                               " register_events
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       free object and leave program
*----------------------------------------------------------------------*
FORM exit_program.
  CALL METHOD g_custom_container->free.
  LEAVE PROGRAM.
ENDFORM.                               " exit_program
*--------------------------------------------------------------------
FORM build_fieldcatalog.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SFLIGHT'
    CHANGING
      ct_fieldcat      = gt_fieldcatalog.
ENDFORM.                               " build_fieldcatalog
*&---------------------------------------------------------------------*
*&      Form  create_hierarchy
*&---------------------------------------------------------------------*
FORM create_hierarchy.
  DATA:
    l_yyyymm         TYPE c LENGTH 8,            "year and month of sflight-fldate
    l_yyyymm_last(6) TYPE c,
    l_carrid         LIKE sflight-carrid,
    l_carrid_last    LIKE sflight-carrid.
  DATA: l_month_key   TYPE lvc_nkey,
        l_carrid_key  TYPE lvc_nkey,
        l_last_key    TYPE lvc_nkey,
        l_top_key     TYPE lvc_nkey,
        l_layout_node TYPE lvc_s_layn.
* Select data
  SELECT * FROM sflight INTO TABLE lt_sflight UP TO g_max ROWS.
* sort table according to conceived hierarchy
  SORT lt_sflight BY fldate+0(6) carrid fldate+6(2).

  PERFORM make_drop CHANGING l_layout_node.

  CALL METHOD g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = ''
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = TEXT-050
      is_node_layout   = l_layout_node
    IMPORTING
      e_new_node_key   = l_top_key.

  g_top_key = l_top_key.

  LOOP AT lt_sflight INTO ls_sflight.
    l_yyyymm = ls_sflight-fldate+0(6).
    l_carrid = ls_sflight-carrid.
    IF l_yyyymm <> l_yyyymm_last.      "on change of l_yyyymm
      l_yyyymm_last = l_yyyymm.
* month nodes
      PERFORM add_month USING l_yyyymm
                                                    l_top_key
                                                    cl_gui_column_tree=>relat_last_child
                             CHANGING l_month_key.
* The month changed, thus, there is no predecessor carrier
      CLEAR l_carrid_last.
    ENDIF.
* Carrier nodes:
    IF l_carrid <> l_carrid_last.      "on change of l_carrid
      l_carrid_last = l_carrid.
      PERFORM add_carrid_line USING    ls_sflight
                                                             l_month_key
                                                             cl_gui_column_tree=>relat_last_child
                              CHANGING l_carrid_key.
    ENDIF.
* Leaf:
    PERFORM add_complete_line USING  ls_sflight
                                     l_carrid_key
                            CHANGING l_last_key.
  ENDLOOP.

  CALL METHOD g_alv_tree->expand_node
    EXPORTING
      i_node_key = l_top_key.
ENDFORM.                               " create_hierarchy
*&---------------------------------------------------------------------*
*&      Form  add_month
*&---------------------------------------------------------------------*
FORM add_month  USING     p_yyyymm TYPE clike
                                             p_relat_key TYPE lvc_nkey
                                             p_relationship TYPE int4
                         CHANGING  p_node_key TYPE lvc_nkey.
  DATA: l_node_text   TYPE lvc_value,
        ls_sflight    TYPE sflight,
        l_month       TYPE c LENGTH 25,
        l_layout_node TYPE lvc_s_layn.
  IF p_yyyymm CO ' 0123456789'.
    p_yyyymm = p_yyyymm && '01'.
    CALL FUNCTION 'CONVERSION_EXIT_LDATE_OUTPUT'
      EXPORTING
        input  = p_yyyymm
      IMPORTING
        output = l_month.
    REPLACE REGEX `(\d\d\.\s)([[:alpha:]]*)(\s\d{4})` IN l_month WITH '$2'.
    l_node_text = p_yyyymm(4) && `/` && l_month.
  ELSE.
    l_node_text = p_yyyymm.
  ENDIF.

  PERFORM make_drag CHANGING l_layout_node.
* add node
  CALL METHOD g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = p_relationship
      i_node_text      = l_node_text
      is_outtab_line   = ls_sflight
      is_node_layout   = l_layout_node
    IMPORTING
      e_new_node_key   = p_node_key.
ENDFORM.                               " add_month
*-----------------------------------------------------------------------
FORM add_carrid_line USING     ps_sflight TYPE sflight
                                                  p_relat_key TYPE lvc_nkey
                                                  p_relationship TYPE int4
                     CHANGING  p_node_key TYPE lvc_nkey.
  DATA: l_node_text   TYPE lvc_value,
        ls_sflight    TYPE sflight,
        l_layout_node TYPE lvc_s_layn.

  l_node_text =  ps_sflight-carrid.
  CALL METHOD g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = p_relationship
      i_node_text      = l_node_text
      is_outtab_line   = ls_sflight
      is_node_layout   = l_layout_node
    IMPORTING
      e_new_node_key   = p_node_key.
ENDFORM.                               " add_carrid_line
*&---------------------------------------------------------------------*
*&      Form  add_complete_line
*&---------------------------------------------------------------------*
FORM add_complete_line USING   ps_sflight TYPE sflight
                               p_relat_key TYPE lvc_nkey
                     CHANGING  p_node_key TYPE lvc_nkey.
  DATA: l_node_text   TYPE lvc_value,
        l_layout_node TYPE lvc_s_layn.
  WRITE ps_sflight-fldate TO l_node_text MM/DD/YYYY.
  CALL METHOD g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      is_outtab_line   = ps_sflight
      i_node_text      = l_node_text
      is_node_layout   = l_layout_node
    IMPORTING
      e_new_node_key   = p_node_key.
ENDFORM.                               " add_complete_line

FORM define_dnd_behaviour.
  DATA: effect TYPE i.
  CREATE OBJECT g_drag_behaviour.
  effect = cl_dragdrop=>move.
  CALL METHOD g_drag_behaviour->add
    EXPORTING
      flavor     = 'default'                  "#EC NOTEXT
      dragsrc    = 'X'
      droptarget = ' '
      effect     = effect.
  CREATE OBJECT g_drop_behaviour.
  effect = cl_dragdrop=>move.
  CALL METHOD g_drop_behaviour->add
    EXPORTING
      flavor     = 'default'                  "#EC NOTEXT
      dragsrc    = ' '
      droptarget = 'X'
      effect     = effect.
ENDFORM.                    " DEFINE_DND_BEHAVIOUR

FORM delete_node.
  DATA: lt_selected_nodes TYPE lvc_t_nkey,
        l_selected_node   TYPE lvc_nkey.
  CALL METHOD g_alv_tree->get_selected_nodes
    CHANGING
      ct_selected_nodes = lt_selected_nodes.
  CALL METHOD cl_gui_cfw=>flush.
  READ TABLE lt_selected_nodes INTO l_selected_node INDEX 1.
  IF sy-subrc EQ 0.
    CALL METHOD g_alv_tree->delete_subtree
      EXPORTING
        i_node_key = l_selected_node.
    CALL METHOD g_alv_tree->frontend_update.
  ELSE. "sy-subrc EQ 0
    MESSAGE i000(0k) WITH 'Please select a node.'(900).
  ENDIF.
ENDFORM.

FORM make_drag CHANGING p_layout_node TYPE lvc_s_layn.
  DATA l_handle_line TYPE i.
  CALL METHOD g_drag_behaviour->get_handle
    IMPORTING
      handle = l_handle_line.
  p_layout_node-dragdropid = l_handle_line.
ENDFORM.

FORM make_drop CHANGING p_layout_node TYPE lvc_s_layn.
  DATA l_handle_line TYPE i.
  CALL METHOD g_drop_behaviour->get_handle
    IMPORTING
      handle = l_handle_line.
  p_layout_node-dragdropid = l_handle_line.
ENDFORM.

FORM build_fieldcat .

  is_fcat-col_pos = 1.

  is_fcat-fieldname = 'CARRID'.

  is_fcat-tabname = 'IT_FLIGHT'.

  is_fcat-scrtext_l = 'CARRID'.

  is_fcat-key = 'X'.

  APPEND is_fcat TO it_fcat.

  CLEAR is_fcat.


  is_fcat-col_pos = 1.

  is_fcat-fieldname = 'CONNID'.

  is_fcat-tabname = 'IT_FLIGHT'.

  is_fcat-key = 'X'.

  is_fcat-scrtext_l = 'CONNID'.

  APPEND is_fcat TO it_fcat.

  CLEAR is_fcat.


  is_fcat-col_pos = 3.

  is_fcat-fieldname = 'FLDATE'.

  is_fcat-tabname = 'IT_FLIGHT'.

  is_fcat-key = 'X'.

  is_fcat-scrtext_l = 'FLDATE'.

  APPEND is_fcat TO it_fcat.

  CLEAR is_fcat.
ENDFORM.
