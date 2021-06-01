*----------------------------------------------------------------------*
***INCLUDE LGTDISI02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FCODE_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_0200 INPUT.

  save_ok_code = ok_code.
  clear ok_code.

*.if enter is pressed and gd_add_column is filled, add it
  if gd_add_column <> space and
     save_ok_code  =  space.
    save_ok_code = 'ADD_COLUMN'.
  endif.

  case save_ok_code.
     when '&F03' or '&F12' or '&F15'.
        perform end.
        IF NOT gd_layout_dock IS INITIAL.
          CALL METHOD gd_layout_alv->free.
          CALL METHOD gd_layout_dock->free.
          clear gd_layout_dock.
          clear gd_layout_alv.
        ENDIF.
        call method g_custom_container->free.
        call method cl_gui_cfw=>flush.
        set screen 0.
        leave screen.
*....add one column to the left
     when 'ADD_COLUMN'.
        perform add_column.
*.....hide empty columns
      WHEN 'EMPTY'.
        perform hide_empty_columns.
*....export whole layout to PC
     when 'LAYOUT_EXPORT'.
        perform layout_export.
*....import whole layout from PC
     when 'LAYOUT_IMPORT'.
        perform layout_import.
     when 'REFRESH'.
        perform refresh_screen.
     when 'SAVE'.
*.......if gd_valid is not true, then there are errors in input. In
*.......this case only the valid changes are in GT_MOD. Now I could
*.......decide one time if I want to save the valid changes or
*.......nothing. This call is also necessary if after change no Return
*.......is pressed. I need to get the changes in my tables first
        call method alv_grid->check_changed_data
             importing  e_valid = gd_valid.
        if gd_valid = true.
           perform save_changes.
        else.
        endif.
     when 'SHOW_SEL'.
        perform show_selection.
     when 'SHOW_ABAP'.
        perform show_selection_abap.
     when 'EXT_SHOW'.
        perform ext_show_selection.
     when 'TOGGLE_LAY'.
        perform layout_docking_toggle.
     when 'TRANSPORT'.
        call method alv_grid->check_changed_data
             importing  e_valid = gd_valid.
        if gd_valid = true.
           perform transport_data.
        endif.
  endcase.

ENDMODULE.                 " FCODE_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_ADD_COLUMN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_add_column INPUT.

  PERFORM f4_add_column.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FCODE_0220  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_0220 INPUT.

  save_ok_code = ok_code.
  clear ok_code.

  case save_ok_code.
     when '&F03' or '&F12' or '&F15'.
        perform end.
        IF NOT gd_layout_dock IS INITIAL.
          CALL METHOD gd_layout_alv->free.
          CALL METHOD gd_layout_dock->free.
          clear gd_layout_dock.
          clear gd_layout_alv.
        ENDIF.
        call method g_custom_container->free.
        call method cl_gui_cfw=>flush.
        set screen 0.
        leave screen.
     when 'REFRESH'.
        perform refresh_screen.
     when 'SAVE'.
*.......if gd_valid is not true, then there are errors in input. In
*.......this case only the valid changes are in GT_MOD. Now I could
*.......decide one time if I want to save the valid changes or
*.......nothing. This call is also necessary if after change no Return
*.......is pressed. I need to get the changes in my tables first
        call method alv_grid->check_changed_data
             importing  e_valid = gd_valid.
        if gd_valid = true.
           perform save_changes.
        else.
        endif.
     when 'SHOW_SEL'.
        perform ext_show_selection.
     when 'TOGGLE_LAY'.
        perform layout_docking_toggle.
     when 'TOGGLE_TOP'.
        perform top_docking_toggle.
     when 'TRANSPORT'.
        call method alv_grid->check_changed_data
             importing  e_valid = gd_valid.
        if gd_valid = true.
           perform transport_data.
        endif.
  endcase.

ENDMODULE.                 " FCODE_0220  INPUT
