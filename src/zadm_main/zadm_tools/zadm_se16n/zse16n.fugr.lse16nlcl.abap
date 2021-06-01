*&---------------------------------------------------------------------*
*&  Include           LSE16NLCL                                        *
*&---------------------------------------------------------------------*

*.Local class for handling of change in edit fields
  class lcl_event_receiver definition.
    public section.
      data: ucomm type sy-ucomm.

    methods handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
            IMPORTING e_object e_interactive.

    methods handle_CONTEXT_MENU_REQUEST
        FOR EVENT CONTEXT_MENU_REQUEST OF cl_gui_alv_grid
            IMPORTING E_OBJECT.


    methods handle_double_click
      for event double_click of cl_gui_alv_grid
      importing e_row e_column es_row_no.

    methods handle_data_changed
      for event data_changed of cl_gui_alv_grid
      importing er_data_changed.

    methods handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
            IMPORTING e_ucomm.

    methods handle_hotspot_click
        for event HOTSPOT_CLICK of cl_gui_alv_grid
        IMPORTING E_ROW_ID E_COLUMN_ID ES_ROW_NO.

    methods handle_after_user_command
        for event after_user_command of cl_gui_alv_grid
        importing e_ucomm
                  e_not_processed
                  e_saved.

    private section.
  endclass.


*......................................................................*
  class lcl_event_receiver implementation.

*.Own functions
  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.
    data: ld_tabix    like sy-tabix.
    type-pools: icon.

*.append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.
*.append an icon to show booking table
    CLEAR ls_toolbar.
    MOVE 'DETAIL' TO ls_toolbar-function.

    MOVE icon_overview TO ls_toolbar-icon.
    MOVE 'Detailansicht'(111) TO ls_toolbar-quickinfo.
    MOVE 'Detail'(112) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

*...icon to hide empty columns
    CLEAR ls_toolbar.
    MOVE 'EMPTY' TO ls_toolbar-function.
    MOVE ICON_EMPTY_HANDLING_UNIT TO ls_toolbar-icon.
    MOVE 'Leere Spalten aus/einblenden'(113) TO ls_toolbar-quickinfo.
    MOVE '' TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.

*...drilldown icons
    if not gt_selfields[] is initial and
       not gt_group_by_fields[] is initial and
       gd-hana_active      = true.
       CLEAR ls_toolbar.
       MOVE 3 TO ls_toolbar-butn_type.
       APPEND ls_toolbar TO e_object->mt_toolbar.
*......for line
       CLEAR ls_toolbar.
       MOVE c_drilldown_line_same_screen TO ls_toolbar-function.
       MOVE icon_next_hierarchy_level TO ls_toolbar-icon.
       MOVE 'Neue Gruppierungsstufen/Zeile'(210) TO ls_toolbar-quickinfo.
       MOVE 'Aufriss/Zeile'(212) TO ls_toolbar-text.
       MOVE ' ' TO ls_toolbar-disabled.
       APPEND ls_toolbar TO e_object->mt_toolbar.
*......for whole list
       CLEAR ls_toolbar.
       MOVE c_drilldown_list_same_screen TO ls_toolbar-function.
       MOVE icon_next_hierarchy_level TO ls_toolbar-icon.
       MOVE 'Neue Gruppierungsstufen/Liste'(211) TO ls_toolbar-quickinfo.
       MOVE 'Aufriss/Liste'(213) TO ls_toolbar-text.
       MOVE ' ' TO ls_toolbar-disabled.
       APPEND ls_toolbar TO e_object->mt_toolbar.
*......navigation back
       CLEAR ls_toolbar.
       MOVE c_navigate_back TO ls_toolbar-function.
       MOVE icon_previous_object TO ls_toolbar-icon.
       MOVE 'Voriger Aufriss'(224) TO ls_toolbar-quickinfo.
       MOVE '' TO ls_toolbar-text.
       if gt_navigation[] is initial or
          gd_curr_level = 1.
          MOVE 'X' TO ls_toolbar-disabled.
       else.
          MOVE ' ' TO ls_toolbar-disabled.
       endif.
       APPEND ls_toolbar TO e_object->mt_toolbar.
*......navigation forth
       CLEAR ls_toolbar.
       MOVE c_navigate_next TO ls_toolbar-function.
       MOVE icon_next_object TO ls_toolbar-icon.
       MOVE 'Nächster Aufriss'(225) TO ls_toolbar-quickinfo.
       MOVE '' TO ls_toolbar-text.
       describe table gt_navigation lines ld_tabix.
       if gd_curr_level < ld_tabix.
          MOVE ' ' TO ls_toolbar-disabled.
       else.
          MOVE 'X' TO ls_toolbar-disabled.
       endif.
       APPEND ls_toolbar TO e_object->mt_toolbar.
*......documentation of drilldown
       CLEAR ls_toolbar.
       MOVE 3 TO ls_toolbar-butn_type.
       APPEND ls_toolbar TO e_object->mt_toolbar.
       CLEAR ls_toolbar.
       MOVE c_drilldown_docu TO ls_toolbar-function.
       MOVE ICON_INFORMATION TO ls_toolbar-icon.
       MOVE 'Dokumentation für Aufriss'(226) TO ls_toolbar-quickinfo.
       MOVE '' TO ls_toolbar-text.
       APPEND ls_toolbar TO e_object->mt_toolbar.
    endif.

  ENDMETHOD.

*.hotspot
  method handle_hotspot_click.
*....e_row_id is the number of the line
*....e_column_id is the name of the column
     perform hotspot_click using e_row_id
                                 e_column_id.
  endmethod.

*.context menu
  method handle_CONTEXT_MENU_REQUEST.
     perform add_ctmenu using e_object.
  endmethod.


*.User Command
  METHOD handle_user_command.
    data: ls_tsapplex type tsapplex.
    DATA: ld_row type i.
    DATA: ld_col type i.
    DATA: ld_value type char200.
    DATA: es_row_no type LVC_S_ROID.
    DATA: lt_cols TYPE LVC_T_COL.

    CALL METHOD alv_grid->GET_CURRENT_CELL
           IMPORTING
             E_ROW     = ld_row
             E_col     = ld_col
             Es_row_no = es_row_no
             E_value   = ld_value.

    CASE e_ucomm.
      WHEN 'DETAIL'.
        CALL METHOD cl_gui_cfw=>flush.
        check: es_row_no-row_id > 0.
        CALL FUNCTION 'SE16N_SHOW_GRID_LINE'
          EXPORTING
            I_ROW          = es_row_no-row_id
            I_COLUMN       = ld_col.
*.....hide empty columns
      WHEN 'EMPTY'.
        perform hide_empty_columns.
*.....new screen with value input for this line
      when c_drilldown_line_fcode.
        check: es_row_no-row_id > 0.
        CALL METHOD ALV_GRID->GET_SELECTED_COLUMNS
           IMPORTING
             ET_INDEX_COLUMNS = lt_cols.
        perform call_drilldown using es_row_no-row_id
                                     ld_col
                                     lt_cols
                                     true
                                     space
                                     space
                                     c_drilldown_line_fcode.
*.....new screen without value input for this line
      when c_drilldown_line_fcode_easy.
        check: es_row_no-row_id > 0.
        CALL METHOD ALV_GRID->GET_SELECTED_COLUMNS
           IMPORTING
             ET_INDEX_COLUMNS = lt_cols.
        perform call_drilldown using es_row_no-row_id
                                     ld_col
                                     lt_cols
                                     space
                                     space
                                     space
                                     c_drilldown_line_fcode_easy.
*.....same screen with new grouping for this line
      when c_drilldown_line_same_screen.
        check: es_row_no-row_id > 0.
        CALL METHOD ALV_GRID->GET_SELECTED_COLUMNS
           IMPORTING
             ET_INDEX_COLUMNS = lt_cols.
        gd-variant_old = gd-variant.
        clear gd-variant.
        perform call_drilldown using es_row_no-row_id
                                     ld_col
                                     lt_cols
                                     space
                                     space
                                     space
                                     c_drilldown_line_same_screen.
*.....same screen with new grouping for whole list
      when c_drilldown_list_same_screen.
        check: es_row_no-row_id > 0.
        gd-variant_old = gd-variant.
        clear gd-variant.
        perform call_drilldown using es_row_no-row_id
                                     ld_col
                                     lt_cols
                                     space
                                     space
                                     space
                                     c_drilldown_list_same_screen.
*.....new screen for whole list with value input
      when c_drilldown_all_fcode.
        check: es_row_no-row_id > 0.
        perform call_drilldown using es_row_no-row_id
                                     ld_col
                                     lt_cols
                                     true
                                     space
                                     space
                                     c_drilldown_all_fcode.
*.....navigation to former list
      when c_navigate_back.
        perform navigate using 'BACK'.
*.....navigation to next list
      when c_navigate_next.
        perform navigate using 'NEXT'.
*.....documentation of drilldown
      when c_drilldown_docu.
        perform show_docu using '1743309'.
*.....RRI-search Interface
      when c_rri_search.
        perform rri_search.
      when others.
        perform call_fcode using ld_row ld_col e_ucomm.
    endcase.
  endmethod.

*...Double click on line
    method handle_double_click.
      DATA: ld_row type i.
      DATA: ld_col type i.
      DATA: ld_value type char200.
      DATA: lt_cols TYPE LVC_T_COL.
*.....Call RKACSHOW-Callback one time
      call method cl_gui_control=>set_focus
                                      exporting control = alv_grid.
*.....at the moment do detail view on double click
      CALL METHOD cl_gui_cfw=>flush.
      check: es_row_no-row_id > 0.
      CALL METHOD alv_grid->GET_CURRENT_CELL
           IMPORTING
             E_ROW     = ld_row
             E_col     = ld_col
             Es_row_no = es_row_no
             E_value   = ld_value.

*.....check which action the user wants to do with double click
      case gd-double_click.
        when c_drilldown_line_fcode.
           if not gt_selfields[] is initial.
              CALL METHOD ALV_GRID->GET_SELECTED_COLUMNS
                IMPORTING
                  ET_INDEX_COLUMNS = lt_cols.
              perform call_drilldown using es_row_no-row_id
                                           ld_col
                                           lt_cols
                                           true
                                           space
                                           space
                                           c_drilldown_line.
           else.
             CALL FUNCTION 'SE16N_SHOW_GRID_LINE'
               EXPORTING
                 I_ROW          = es_row_no-row_id
                 I_COLUMN       = e_column.
           endif.
        when c_drilldown_line_fcode_easy.
           if not gt_selfields[] is initial and
              gd-hana_active = true.
              CALL METHOD ALV_GRID->GET_SELECTED_COLUMNS
                 IMPORTING
                   ET_INDEX_COLUMNS = lt_cols.
              perform call_drilldown using es_row_no-row_id
                                           ld_col
                                           lt_cols
                                           space
                                           space
                                           space
                                           c_drilldown_line.
           else.
             CALL FUNCTION 'SE16N_SHOW_GRID_LINE'
               EXPORTING
                 I_ROW          = es_row_no-row_id
                 I_COLUMN       = e_column.
           endif.
*.......same screen with new grouping for this line
        when c_drilldown_line_same_screen.
           if not gt_selfields[] is initial and
              gd-hana_active = true.
              CALL METHOD ALV_GRID->GET_SELECTED_COLUMNS
                 IMPORTING
                   ET_INDEX_COLUMNS = lt_cols.
              perform call_drilldown using es_row_no-row_id
                                           ld_col
                                           lt_cols
                                           space
                                           space
                                           space
                                         c_drilldown_line_same_screen.
           else.
             CALL FUNCTION 'SE16N_SHOW_GRID_LINE'
               EXPORTING
                 I_ROW          = es_row_no-row_id
                 I_COLUMN       = e_column.
           endif.
*.......same screen with new grouping for whole list
        when c_drilldown_list_same_screen.
           if not gt_selfields[] is initial and
              gd-hana_active = true.
              perform call_drilldown using es_row_no-row_id
                                           ld_col
                                           lt_cols
                                           space
                                           space
                                           space
                                         c_drilldown_list_same_screen.
           else.
             CALL FUNCTION 'SE16N_SHOW_GRID_LINE'
               EXPORTING
                 I_ROW          = es_row_no-row_id
                 I_COLUMN       = e_column.
           endif.
        when c_drilldown_all_fcode.
           if not gt_selfields[] is initial.
              perform call_drilldown using es_row_no-row_id
                                           ld_col
                                           lt_cols
                                           true
                                           space
                                           space
                                           c_drilldown_all.
           else.
             CALL FUNCTION 'SE16N_SHOW_GRID_LINE'
               EXPORTING
                 I_ROW          = es_row_no-row_id
                 I_COLUMN       = e_column.
           endif.
        when others.
          CALL FUNCTION 'SE16N_SHOW_GRID_LINE'
            EXPORTING
              I_ROW          = es_row_no-row_id
              I_COLUMN       = e_column.
      endcase.
    endmethod.

    method handle_data_changed.
      perform data_changed using er_data_changed.
    endmethod.

  method handle_after_user_command.

    data: ls_layout       type LVC_S_LAYO.
    data: lt_fieldcatalog type lvc_t_fcat.
    data: lt_filter       type LVC_T_FILT.
    data: ls_variant      type DISVARIANT.
    DATA: lt_cols         TYPE LVC_T_COL.
    data: LT_ROWS         TYPE LVC_T_ROW.
    data  LT_ROW_NO       TYPE LVC_T_ROID.
    DATA: ld_row          type i.
    DATA: ld_col          type i.
    DATA: ld_value        type char200.
    DATA: es_row_no       type LVC_S_ROID.

    check: gd-hana_active = true.
    check: gd-show_layouts = true.

    CALL METHOD alv_grid->GET_CURRENT_CELL
       IMPORTING
         E_ROW     = ld_row
         E_col     = ld_col
         Es_row_no = es_row_no
         E_value   = ld_value.

*...if user changes fieldcatalog I need to refresh the screen by
*...selecting new fields
    if e_not_processed <> 'X'.
      case e_ucomm.
        when '&COL0'.
*.........as the variant was changed do not restart with old one
          gd-variant_old = gd-variant.
          clear gd-variant.
          CALL METHOD ALV_GRID->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = lt_rows
               ET_ROW_NO     = lt_row_no.
*......If user did select lines I will do a drilldown for those lines
          if not lt_rows[] is initial.
             perform call_drilldown using es_row_no-row_id
                                          ld_col
                                          lt_cols
                                          space
                                          space
                                          true
                                          c_drilldown_line_same_screen.
*......if user did not select any line I will do a drilldown for the
*......whole list
          else.
             perform call_drilldown using es_row_no-row_id
                                          ld_col
                                          lt_cols
                                          space
                                          space
                                          true
                                          c_drilldown_list_same_screen.
          endif.
*.......user choses new layout in the ALV-Grid directly
        when '&LOAD'.
          CALL METHOD ALV_GRID->GET_VARIANT
            IMPORTING
              ES_VARIANT = ls_variant.
          gd-variant_old = gd-variant.
          GD-VARIANT = ls_variant-variant.
          CALL METHOD ALV_GRID->GET_SELECTED_ROWS
             IMPORTING
               ET_INDEX_ROWS = lt_rows
               ET_ROW_NO     = lt_row_no.
*...If user did select lines I will do a drilldown for those lines
          if not lt_rows[] is initial.
            perform call_drilldown using es_row_no-row_id
                                         ld_col
                                         lt_cols
                                         space
                                         true
                                         space
                                         c_drilldown_line_same_screen.
*...if user did not select any line I will do a drilldown for the
*...whole list
          else.
            perform call_drilldown using es_row_no-row_id
                                         ld_col
                                         lt_cols
                                         space
                                         true
                                         space
                                         c_drilldown_list_same_screen.
          endif.
*.......user saves or deletes a layout -> just refresh the layout-docking
        when '&SAVE' or '&MAINTAIN'.
          perform layout_docking_create.
      endcase.


    endif.

  endmethod.                    "after_user_command

  endclass.
*......................................................................

data: event_receiver type ref to lcl_event_receiver.

*********************************************************************
*&---------------------------------------------------------------------*
*&       Class lcl_layt_receiver
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_layt_receiver DEFINITION.

   public section.

   methods handle_hotspot
      for event hotspot_click of cl_gui_alv_grid
      importing  E_ROW_ID
                 E_COLUMN_ID
                 ES_ROW_NO.

   methods:
     handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

    handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.

    DATA: gd_ucomm        like sy-ucomm,
          lt_toolbar_buf  TYPE ttb_button.

ENDCLASS.               "lcl_layt_receiver
*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_layt_receiver
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_layt_receiver IMPLEMENTATION.

  method handle_hotspot.

    DATA: ld_row type i.
    DATA: ld_col type i.
    DATA: ld_value type char200.
    DATA: lt_cols TYPE LVC_T_COL.
    data: LT_ROWS      TYPE LVC_T_ROW.
    data  LT_ROW_NO    TYPE LVC_T_ROID.

    CALL METHOD alv_grid->GET_CURRENT_CELL
           IMPORTING
             E_ROW     = ld_row
             E_col     = ld_col
             E_value   = ld_value.

    read table gt_layouts into gs_layouts index es_row_no-row_id.
    check: sy-subrc = 0.
    gd-variant_old = gd-variant.
    GD-VARIANT     = gs_layouts-variant.

    check: es_row_no-row_id > 0.
    CALL METHOD ALV_GRID->GET_SELECTED_COLUMNS
           IMPORTING
             ET_INDEX_COLUMNS = lt_cols.
    CALL METHOD ALV_GRID->GET_SELECTED_ROWS
           IMPORTING
             ET_INDEX_ROWS = lt_rows
             ET_ROW_NO     = lt_row_no.
*...If user did select lines I will do a drilldown for those lines
    if not lt_rows[] is initial.
        perform call_drilldown using ld_row
                                     ld_col
                                     lt_cols
                                     space
                                     true
                                     space
                                     c_drilldown_line_same_screen.
*...if user did not select any line I will do a drilldown for the
*...whole list
    else.
        perform call_drilldown using ld_row
                                     ld_col
                                     lt_cols
                                     space
                                     true
                                     space
                                     c_drilldown_list_same_screen.
    endif.

  endmethod.

  METHOD handle_toolbar.

    DATA: ls_toolbar TYPE stb_button.

    DATA: lt_tbbutton TYPE  ttb_button,
          ls_tbbutton type  stb_button.

    FIELD-SYMBOLS <tbbutton> TYPE LINE OF ttb_button.

*...fill standard toolbar into buffer
    IF lt_toolbar_buf[] IS INITIAL.
      lt_toolbar_buf = e_object->mt_toolbar.
      delete lt_toolbar_buf
               where function = '&&SEP06'
                  or function = '&GRAPH'.
    ENDIF.

    refresh e_object->mt_toolbar.

*...depending on the caller fill different toolbar
    case gd_ucomm.
*.....first call - less functions
      when space or '&LESS_ICONS'.
        CLEAR ls_toolbar.
        ls_toolbar-icon      = icon_pdir_foreward.
        ls_toolbar-function  = '&MORE_ICONS'.
        ls_toolbar-quickinfo = text-122.
        ls_toolbar-butn_type = 0.
        APPEND ls_toolbar TO e_object->mt_toolbar.
        CLEAR ls_toolbar.
        ls_toolbar-function  = '&&SEP01'.
        ls_toolbar-butn_type = 3.
        APPEND ls_toolbar TO e_object->mt_toolbar.
      when '&MORE_ICONS'.
*.....user wants to see more functions
        CLEAR ls_toolbar.
        ls_toolbar-icon      = icon_pdir_foreward_switch.
        ls_toolbar-function  = '&LESS_ICONS'.
        ls_toolbar-quickinfo = text-123.
        ls_toolbar-butn_type = 0.
        APPEND ls_toolbar TO e_object->mt_toolbar.
        CLEAR ls_toolbar.
        ls_toolbar-function  = '&&SEP01'.
        ls_toolbar-butn_type = 3.
        APPEND ls_toolbar TO e_object->mt_toolbar.
        append lines of lt_toolbar_buf to e_object->mt_toolbar.
    endcase.
*......documentation of layout use
       CLEAR ls_toolbar.
       MOVE 3 TO ls_toolbar-butn_type.
       APPEND ls_toolbar TO e_object->mt_toolbar.
       CLEAR ls_toolbar.
       MOVE c_layout_docu TO ls_toolbar-function.
       MOVE ICON_INFORMATION TO ls_toolbar-icon.
       MOVE 'Dokumentation der Layouts'(227) TO ls_toolbar-quickinfo.
       MOVE '' TO ls_toolbar-text.
       APPEND ls_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD handle_user_command.

   clear gd_ucomm.
   case e_ucomm.
     when '&MORE_ICONS' or '&LESS_ICONS'.
       gd_ucomm = e_ucomm.
       CALL METHOD gd_layout_alv->set_toolbar_interactive.
*.....documentation of layout use
      when c_layout_docu.
        perform show_docu using '1775082'.
     when others.
   endcase.

  ENDMETHOD.

ENDCLASS.               "lcl_layt_receiver
