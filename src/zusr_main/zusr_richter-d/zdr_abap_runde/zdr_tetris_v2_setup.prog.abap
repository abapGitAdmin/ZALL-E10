*&---------------------------------------------------------------------*
*&  Include           ZDR_TETRIS_V2_SETUP
*&---------------------------------------------------------------------*

data: ok_code     like sy-ucomm,
*      Ausgabe
      gt_field    type standard table of zdr_tetris_field,
      gs_row      type zdr_tetris_field,
*      ALV Zeugs
      gr_cont     type ref to cl_gui_custom_container,
      gr_alv_grid type ref to cl_gui_alv_grid,
      lt_fcat     type lvc_t_fcat,
      ls_layout   type lvc_s_layo,
*      Timer
      gr_timer    type ref to cl_gui_timer,
      game        type ref to lcl_event_handler.

class lcl_event_handler definition.
  public section.
    methods handle_timer for event finished of cl_gui_timer.
    methods refresh.
endclass.
class lcl_event_handler implementation.
  method handle_timer.
    perform table_update.

    me->refresh( ).
  endmethod.
  method refresh.
    gr_alv_grid->refresh_table_display( ).
    gr_timer->run( ).
  endmethod.
endclass.

*&---------------------------------------------------------------------*
*&      Form  CREAT_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form creat_fieldcat .
  data: ls_fcat    type lvc_s_fcat.

  ls_fcat-fieldname   = 'COL_00'.
  ls_fcat-ref_field   = 'COL_00'.
  ls_fcat-ref_table   = 'ZDR_TETRIS_FIELD'.
*  ls_fcat-key         = true.
  append ls_fcat to lt_fcat.
  clear ls_fcat.
  ls_fcat-fieldname   = 'COL_01'.
  ls_fcat-ref_field   = 'COL_01'.
  ls_fcat-ref_table   = 'ZDR_TETRIS_FIELD'.
*  ls_fcat-key         = true.
  append ls_fcat to lt_fcat.
  clear ls_fcat.
  ls_fcat-fieldname   = 'COL_02'.
  ls_fcat-ref_field   = 'COL_02'.
  ls_fcat-ref_table   = 'ZDR_TETRIS_FIELD'.
*  ls_fcat-key         = true.
  append ls_fcat to lt_fcat.
  clear ls_fcat.
  ls_fcat-fieldname   = 'COL_03'.
  ls_fcat-ref_field   = 'COL_03'.
  ls_fcat-ref_table   = 'ZDR_TETRIS_FIELD'.
*  ls_fcat-key         = true.
  append ls_fcat to lt_fcat.
  clear ls_fcat.

  gs_row-col_02 = 'X'.
  append gs_row to gt_field.
  append gs_row to gt_field.
  append gs_row to gt_field.
  append gs_row to gt_field.
*  clear gs_row.
endform.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_alv .
  create object gr_cont
    exporting
      container_name = 'CUCTR'.
  create object gr_alv_grid
    exporting
      i_parent = gr_cont.
  call method gr_alv_grid->set_table_for_first_display
    exporting
*      i_buffer_active               =
*      i_bypassing_buffer            =
*      i_consistency_check           =
      i_structure_name = 'ZDR_TETRIS_FIELD'
*      is_variant                    =
*      i_save                        =
*      i_default                     = 'X'
*      is_layout                     =
*      is_print                      =
*      it_special_groups             =
*      it_toolbar_excluding          =
*      it_hyperlink                  =
*      it_alv_graphics               =
*      it_except_qinfo               =
*      ir_salv_adapter               =
    changing
      it_outtab        = gt_field.
*      it_fieldcatalog               =
*      it_sort                       =
*      it_filter                     =
*    exceptions
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      others                        = 4
          .
  if sy-subrc <> 0.
*   Implement suitable error handling here
  endif.
endform.
*&---------------------------------------------------------------------*
*&      Form  CREATE_TIMER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_timer .
  if gr_timer is initial.
    create object gr_timer.
    create object game.
    set handler game->handle_timer for gr_timer.
    gr_timer->interval = 1.
    gr_timer->run( ).
  endif.
endform.
