*----------------------------------------------------------------------*
***INCLUDE LSE16NF92.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CREATE_SELFIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_OR_SELFIELDS  text
*----------------------------------------------------------------------*
FORM CREATE_SELFIELDS  TABLES IT_SELTAB           structure se16n_seltab
                              IT_SUM_UP_FIELDS    STRUCTURE SE16N_OUTPUT
                              IT_GROUP_BY_FIELDS  STRUCTURE SE16N_OUTPUT
                              IT_ORDER_BY_FIELDS  STRUCTURE SE16N_OUTPUT
                              IT_AGGREGATE_FIELDS STRUCTURE SE16N_SELTAB
                              IT_TOPLOW_FIELDS    STRUCTURE SE16N_SELTAB
                              IT_SORTORDER_FIELDS STRUCTURE SE16N_SELTAB
                              IT_HAVING_FIELDS    STRUCTURE SE16N_SELTAB
                       USING  value(p_tab)
                       changing it_or_selfields type se16n_or_t.

  data: lt_dfies        like dfies occurs 0 with header line.
  data: ls_or_selfields type SE16N_OR_SELTAB.
  data: ls_seltab       like se16n_seltab.
  data: ls_selfields    like se16n_selfields.
  data: ld_field_save   type fieldname.
  data: ls_multi        like se16n_selfields.
  data: ld_tabix        like sy-tabix.
  data: ls_aggregate_fields like SE16N_SELTAB.
  data: ls_toplow_fields    like SE16N_SELTAB.
  data: ls_sortorder_fields like SE16N_SELTAB.
  data: ls_having_fields    like SE16N_SELTAB.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME   = p_tab
    TABLES
      DFIES_TAB = LT_DFIES
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.

  check: sy-subrc = 0.
*..initially create gt_selfields
  loop at lt_dfies.
    clear gt_selfields.
    move-corresponding lt_dfies to gt_selfields.
    if gt_selfields-scrtext_m is initial.
      gt_selfields-scrtext_m = lt_dfies-fieldtext.
    endif.
    gt_selfields-mark = true.
    if lt_dfies-keyflag = true.
      gt_selfields-key = true.
    endif.
*.....default sign is inclusive
    gt_selfields-sign = opt-i.
*...add attributes of this field
    read table it_sum_up_fields with key field = lt_dfies-fieldname.
    if sy-subrc = 0.
       gt_selfields-sum_up = 'X'.
    endif.
    read table it_group_by_fields with key field = lt_dfies-fieldname.
    if sy-subrc = 0.
       gt_selfields-group_by = 'X'.
    endif.
    read table it_order_by_fields with key field = lt_dfies-fieldname.
    if sy-subrc = 0.
       gt_selfields-order_by = 'X'.
    endif.
    read table it_aggregate_fields into ls_aggregate_fields
         with key field = lt_dfies-fieldname.
    if sy-subrc = 0.
       gt_selfields-aggregate = ls_aggregate_fields-low.
    endif.
    read table it_toplow_fields into ls_toplow_fields
         with key field = lt_dfies-fieldname.
    if sy-subrc = 0.
       gt_selfields-toplow = ls_toplow_fields-low.
    endif.
    read table it_sortorder_fields into ls_sortorder_fields
         with key field = lt_dfies-fieldname.
    if sy-subrc = 0.
       gt_selfields-sortorder = ls_sortorder_fields-low.
    endif.
    append gt_selfields.
    read table it_having_fields into ls_having_fields
         with key field = lt_dfies-fieldname.
    if sy-subrc = 0.
       gt_selfields-having_option = ls_having_fields-option.
       gt_selfields-having_value  = ls_having_fields-low.
    endif.
    append gt_selfields.
  endloop.

*..fill given criteria in global tables
  clear ld_field_save.
  loop at it_seltab into ls_seltab.
*......first time field occurs, add to gt_selfields
    if ld_field_save <> ls_seltab-field.
*.........serch for this field in the global table
      read table gt_selfields into ls_selfields
        with key fieldname = ls_seltab-field.
      if sy-subrc = 0.
        ld_tabix = sy-tabix.
        ls_selfields-fieldname = ls_seltab-field.
        move-corresponding ls_seltab to ls_selfields.
        modify gt_selfields from ls_selfields index ld_tabix.
      endif.
*......add additional criteria to gt_multi
    else.
      clear ls_multi.
      ls_multi-tabname = p_tab.
      read table gt_selfields into ls_selfields
        with key fieldname = ls_seltab-field.
      if sy-subrc = 0.
        move-corresponding ls_selfields to ls_multi.
        move-corresponding ls_seltab to ls_multi.
        append ls_multi to gt_multi.
      endif.
    endif.
    ld_field_save = ls_seltab-field.
  endloop.

*..finally fill table it_or_selfields
  ls_or_selfields-pos = 0.
  append lines of it_seltab to ls_or_selfields-seltab.
  append ls_or_selfields to it_or_selfields.

ENDFORM.                    " CREATE_SELFIELDS
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING ROW_ID    type lvc_s_row
                          COLUMN_ID type lvc_s_col.

field-symbols: <wa>.

  check: row_id > 0.
*.fill global data for hotspot callback
  gs_ext_hotspot-row_id    = row_id.
  gs_ext_hotspot-column_id = column_id.

*.callback to application with information about line and field
*..check for external exit
   perform external_exit using c_ext_hotspot
                         changing gd-exit_done.

ENDFORM.                    " HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  EXTERNAL_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_EXT_EVENT_FCAT  text
*----------------------------------------------------------------------*
FORM EXTERNAL_EXIT  USING value(p_event)
                    changing value(p_done).

data: ls_callback_events type se16n_events_type.

*.check if event was handed over
  read table gt_callback_events into ls_callback_events
           with key callback_event = p_event.
  if sy-subrc = 0.
    p_done = true.
  else.
    p_done = space.
  endif.
  check: sy-subrc = 0.

*.depending on the event call back
  case p_event.
*...allow checking of changed data
    when c_ext_data_changed.
*.....this is done locally in Form DATA_CHANGED
*...allow excluding of toolbar functions
    when c_ext_toolbar_excl.
       perform (ls_callback_events-callback_form)
             in program (ls_callback_events-callback_program) if found
                 tables gt_toolbar_excl.
*...enhance fieldcatalog
    when c_ext_event_fcat.
       perform (ls_callback_events-callback_form)
             in program (ls_callback_events-callback_program) if found
                 tables gt_fieldcat
                        gt_selfields.
*...enhance layout fields
    when c_ext_layout_fcat.
       perform (ls_callback_events-callback_form)
             in program (ls_callback_events-callback_program) if found
                 tables gt_layout_fields
                        gt_selfields.
    when c_ext_top_of_page.
       if sy-batch <> true.
*........first create top of page container, to allow exit to fill it
         if gd-ext_top_dock is initial.
*..........create container on screen
           CREATE OBJECT gd-ext_top_dock
             EXPORTING
               side      = cl_gui_docking_container=>dock_at_top
*       RATIO     = 30
               extension = 100
               repid     = c_repid
               dynnr     = '220'.
*          create object gd-ext_top_cont
*              EXPORTING
*                container_name = gd-ext_top_cont_name.
*..........create HTML-Text-Document
           create object gd-ext_dd.
         endif.
         perform (ls_callback_events-callback_form)
             in program (ls_callback_events-callback_program) if found
                 tables gt_fieldcat
                        gt_selfields
                 changing gd_dref
                          gd-ext_dd.
         CALL METHOD GD-EXT_DD->DISPLAY_DOCUMENT
                 EXPORTING
*                  REUSE_CONTROL      =
*                  REUSE_REGISTRATION =
*                  CONTAINER          =
*                  PARENT             = gd-ext_top_cont
                   PARENT             = gd-ext_top_dock
                 EXCEPTIONS
                   HTML_DISPLAY_ERROR = 1
                   others             = 2.
       else.
         perform (ls_callback_events-callback_form)
             in program (ls_callback_events-callback_program) if found
                 tables gt_fieldcat
                        gt_selfields
                 changing gd_dref
                          gd-ext_dd.
       endif.
    when c_ext_change_lines.
       perform (ls_callback_events-callback_form)
             in program (ls_callback_events-callback_program) if found
                 tables gt_fieldcat
                        gt_selfields
                 changing gd_dref.
    when c_ext_hotspot.
       read table <all_table>
               assigning <g_wa> index gs_ext_hotspot-row_id.
       check: sy-subrc = 0.
*......hand over whole pointer on table to allow exit to read
*......line itself
       perform (ls_callback_events-callback_form)
             in program (ls_callback_events-callback_program) if found
                 tables gt_selfields
                 using  gs_ext_hotspot-column_id
                        gs_ext_hotspot-row_id
                        gd_dref.
  endcase.

ENDFORM.                    " EXTERNAL_EXIT
*&---------------------------------------------------------------------*
*&      Form  EXT_SHOW_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXT_SHOW_SELECTION .

data: lt_selkrit   like se16n_seltab occurs 0.
data: ls_or_seltab type SE16N_OR_SELTAB.
data: ls_seltab    like se16n_seltab.
data: ls_selfields like se16n_selfields.
data: lt_fieldcat  type SLIS_T_FIELDCAT_ALV.
data: ls_fieldcat  type SLIS_FIELDCAT_ALV.

  loop at gt_or_selfields into ls_or_seltab.
    loop at ls_or_seltab-seltab into ls_seltab.
*.....get description text for this field
      read table gt_selfields into ls_selfields
          with key fieldname = ls_seltab-field.
      if sy-subrc = 0.
         ls_seltab-field = ls_selfields-scrtext_m.
      endif.
      append ls_seltab to lt_selkrit.
    endloop.
  endloop.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME             = 'SE16N_SELTAB'
    CHANGING
      CT_FIELDCAT                  = lt_fieldcat
    EXCEPTIONS
      INCONSISTENT_INTERFACE       = 1
      PROGRAM_ERROR                = 2
      OTHERS                       = 3.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
*.change sign and option to no out
  loop at lt_fieldcat into ls_fieldcat.
     case ls_fieldcat-fieldname.
       when 'SIGN' or 'OPTION'.
         ls_fieldcat-no_out    = true.
       when 'LOW'.
         ls_fieldcat-outputlen = 30.
         ls_fieldcat-reptext_ddic = text-low.
       when 'HIGH'.
         ls_fieldcat-outputlen = 30.
         ls_fieldcat-reptext_ddic = text-hgh.
     endcase.
     modify lt_fieldcat from ls_fieldcat index sy-tabix.
  endloop.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_STRUCTURE_NAME                  = 'SE16N_SELTAB'
      I_GRID_TITLE                      = text-sel
      I_SCREEN_START_COLUMN             = 5
      I_SCREEN_START_LINE               = 5
      I_SCREEN_END_COLUMN               = 125
      I_SCREEN_END_LINE                 = 20
      it_fieldcat                       = lt_fieldcat
    TABLES
      T_OUTTAB                          = lt_selkrit
    EXCEPTIONS
      PROGRAM_ERROR                     = 1
      OTHERS                            = 2.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " EXT_SHOW_SELECTION
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_DOCKING_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_3098   text
*----------------------------------------------------------------------*
FORM LAYOUT_DOCKING_CREATE.

data: ld_dynnr like sy-dynnr.

*...only in case of HANA
    check: gd-hana_active = true.

*...only in case this is wanted
    check: gd-show_layouts = true.

*...now decide which screen
    if gd-ext_call = true.
       ld_dynnr = '220'.
    else.
       ld_dynnr = '200'.
    endif.

*...Container already initialised
    IF NOT gd_layout_dock IS INITIAL.
      CALL METHOD gd_layout_alv->free.
      CALL METHOD gd_layout_dock->free.
      clear gd_layout_dock.
      clear gd_layout_alv.
    ENDIF.
    CREATE OBJECT gd_layout_dock
      EXPORTING
        side      = cl_gui_docking_container=>dock_at_right
*       RATIO     = 30
        extension = 300
        repid     = c_repid
        dynnr     = ld_dynnr.
*...in case of event handling repeat the current display setting
    CALL METHOD gd_layout_dock->set_visible
      EXPORTING
        visible = gd_toggle_layout.
*...create new ALV for layouts
    CREATE OBJECT gd_layout_alv
      EXPORTING
        i_parent = gd_layout_dock.
*.send layout to screen
  PERFORM layout_docking_display.

ENDFORM.                    " LAYOUT_DOCKING_CREATE
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_DOCKING_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LAYOUT_DOCKING_DISPLAY .

  DATA: lt_variants LIKE ltvariant OCCURS 1 WITH HEADER LINE.
  DATA: ls_variant  LIKE disvariant.
  DATA: ls_layouts  TYPE ltvariant.
  DATA: ls_layt_variant LIKE disvariant.
  DATA: ld_subrc    LIKE sy-subrc.
  DATA: l_layt_receiver TYPE REF TO lcl_layt_receiver.
  DATA: ls_layout   TYPE lvc_s_layo.
  DATA: ls_curr_var TYPE disvariant.
  DATA: lt_exclude  TYPE ui_functions,
        ls_exclude  TYPE ui_func.

  RANGES r_report    FOR sy-repid.
  RANGES r_handle    FOR ltdx-handle.
  RANGES r_log_group FOR ltdx-log_group.
  RANGES r_username  FOR ltdx-username.

  REFRESH: gt_variants, gt_layouts.

* initialize global parameters (including coding fieldcat)
  clear ls_variant.
*.the report is always se16n and then the table
  if not gd-layout_group is initial.
*....in case of SE16A allow several different layout groups
     concatenate gd_variant-report gd-tab gd-layout_group
           into ls_variant-report.
  else.
     concatenate gd_variant-report gd-tab into ls_variant-report.
  endif.
*.the handle defines if the texttable is on or not
  if gd-no_txt = true.
     ls_variant-handle = space.
  else.
     ls_variant-handle = true.
  endif.
*.the log group defines if it is client dependent
  ls_variant-log_group = gd-read_clnt.
*.User name
  ls_variant-username  = sy-uname.
  CLEAR ls_variant-variant.

*.get all variants for this report
  r_report-sign   = 'I'.
  r_report-option = 'EQ'.
  r_report-low    = ls_variant-report.
  APPEND r_report TO r_report.

  r_handle-sign   = 'I'.
  r_handle-option = 'EQ'.
  r_handle-low    = ls_variant-handle.
  APPEND r_handle TO r_handle.

  r_log_group-sign   = 'I'.
  r_log_group-option = 'EQ'.
  r_log_group-low    = ls_variant-log_group.
  APPEND r_log_group TO r_log_group.

*.limit the selection to current user
  r_username-sign   = 'I'.
  r_username-option = 'EQ'.
  r_username-low    = sy-uname.
  APPEND r_username TO r_username.
  r_username-sign   = 'I'.
  r_username-option = 'EQ'.
  r_username-low    = space.
  APPEND r_username TO r_username.

  CALL FUNCTION 'LT_VARIANTS_READ_FROM_LTDX'
*   EXPORTING
*     I_TOOL                = 'LT'
*     I_TEXT                = 'X'
    TABLES
      et_variants           = lt_variants
      it_ra_report          = r_report
      it_ra_handle          = r_handle
      it_ra_log_group       = r_log_group
      it_ra_username        = r_username
*     IT_RA_VARIANT         =
*     IT_RA_TYPE            =
*     IT_RA_INACTIVE        =
    EXCEPTIONS
      not_found             = 1
      OTHERS                = 2.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  APPEND LINES OF lt_variants TO gt_variants.
*.create fieldcatalog for output
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'LTVARIANT'
    CHANGING
      ct_fieldcat      = gt_layt_fcat.
*.transfer into oo
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = gt_layt_fcat
    IMPORTING
      et_fieldcat_lvc = gt_layt_fieldcat
    TABLES
      it_data         = gt_variants.

*.get current fieldcatalog and make this line red
  CALL METHOD alv_grid->get_variant
    IMPORTING
      es_variant = ls_curr_var.
  LOOP AT gt_variants INTO ls_layouts.
    CHECK: ls_layouts-variant <> c_dummy_vari.
    CLEAR gs_layouts.
    MOVE-CORRESPONDING ls_layouts TO gs_layouts.
    IF gs_layouts-variant = ls_curr_var-variant.
      gs_layouts-style = 'C6'.
    ENDIF.
    APPEND gs_layouts TO gt_layouts.
  ENDLOOP.
*.layouteinstellungen
  ls_layout-info_fname = 'STYLE'.  "style of line

*.change fieldcatalog
  LOOP AT gt_layt_fieldcat INTO gs_layt_fieldcat.
    IF gs_layt_fieldcat-fieldname = 'VARIANT'  OR
       gs_layt_fieldcat-fieldname = 'TEXT'     OR
       gs_layt_fieldcat-fieldname = 'ERFDAT'   OR
       gs_layt_fieldcat-fieldname = 'ERFTIME'  OR
       gs_layt_fieldcat-fieldname = 'AEDAT'    OR
       gs_layt_fieldcat-fieldname = 'AETIME'   OR
       gs_layt_fieldcat-fieldname = 'AENAME'.
      gs_layt_fieldcat-no_out = space.
    ELSE.
      gs_layt_fieldcat-no_out = true.
    ENDIF.
    IF gs_layt_fieldcat-fieldname = 'VARIANT'.
      gs_layt_fieldcat-hotspot = true.
    ENDIF.
    MODIFY gt_layt_fieldcat FROM gs_layt_fieldcat INDEX sy-tabix.
  ENDLOOP.

*.exclude functions in toolbar that are not necessary
  ls_exclude = cl_gui_alv_grid=>mc_mb_sum.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_subtot.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_print_back.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_view.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_mb_export.
  APPEND ls_exclude TO lt_exclude.
* ls_exclude = cl_gui_alv_grid=>mc_fc_current_variant.
* append ls_exclude to lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_graph.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = '&&SEP00'.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = '&&SEP01'.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = '&&SEP02'.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = '&&SEP03'.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = '&&SEP04'.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = '&&SEP05'.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = '&&SEP06'.
  APPEND ls_exclude TO lt_exclude.
  ls_exclude = '&&SEP07'.
  APPEND ls_exclude TO lt_exclude.

  ls_layt_variant-report    = ls_variant-report.
  ls_layt_variant-handle    = ls_variant-handle.
  ls_layt_variant-log_group = ls_variant-log_group.
  ls_layt_variant-username  = sy-uname.

  CALL METHOD gd_layout_alv->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding = lt_exclude
      is_variant           = ls_layt_variant
      is_layout            = ls_layout
      i_save               = 'A'
    CHANGING
      it_outtab            = gt_layouts
      it_fieldcatalog      = gt_layt_fieldcat.

  CREATE OBJECT l_layt_receiver.
  SET HANDLER l_layt_receiver->handle_hotspot
                              FOR gd_layout_alv.
  SET HANDLER l_layt_receiver->handle_user_command
                              FOR gd_layout_alv.
  SET HANDLER l_layt_receiver->handle_toolbar
                              FOR gd_layout_alv.
  CALL METHOD gd_layout_alv->set_toolbar_interactive.

ENDFORM.                    " LAYOUT_DOCKING_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  TOGGLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0107   text
*----------------------------------------------------------------------*
FORM LAYOUT_DOCKING_TOGGLE.

  IF gd_toggle_layout = space.
    gd_toggle_layout = true.
  ELSE.
    gd_toggle_layout = space.
  ENDIF.
  CALL METHOD gd_layout_dock->set_visible
     EXPORTING
       visible = gd_toggle_layout.

ENDFORM.                    " TOGGLE
*&---------------------------------------------------------------------*
*&      Form  TOP_DOCKING_TOGGLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM top_docking_toggle .

  check: not gd-ext_top_dock is initial.

  IF gd_toggle_top = space.
    gd_toggle_top = true.
  ELSE.
    gd_toggle_top = space.
  ENDIF.
  CALL METHOD gd-ext_top_dock->set_visible
     EXPORTING
       visible = gd_toggle_top.

ENDFORM.
