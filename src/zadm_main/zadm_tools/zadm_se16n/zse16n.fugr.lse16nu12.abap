FUNCTION SE16N_DRILLDOWN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_TAB) TYPE  SE16N_TAB OPTIONAL
*"     VALUE(I_DISPLAY) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_EXIT_SELFIELD_FB) TYPE  FUNCNAME DEFAULT SPACE
*"     VALUE(I_SINGLE_TABLE) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_HANA_ACTIVE) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_DBCON) TYPE  DBCON_NAME OPTIONAL
*"     VALUE(I_OJKEY) TYPE  TSWAPPL OPTIONAL
*"     VALUE(I_VALUE_CALL) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_VARIANT) TYPE  SLIS_VARI DEFAULT SPACE
*"     VALUE(I_MAX_LINES) TYPE  SYTABIX DEFAULT 500
*"     VALUE(I_DOUBLE_CLICK) TYPE  SYUCOMM OPTIONAL
*"     VALUE(I_KIND_OF_CALL) TYPE  SYUCOMM OPTIONAL
*"     VALUE(IT_COLS) TYPE  LVC_T_COL OPTIONAL
*"     VALUE(I_ROW) TYPE  I OPTIONAL
*"     VALUE(I_FORMULA_NAME) TYPE  GTB_FORMULA_NAME DEFAULT SPACE
*"  TABLES
*"      LT_MULTI STRUCTURE  SE16N_SELFIELDS OPTIONAL
*"      LT_SELFIELDS STRUCTURE  SE16N_SELFIELDS OPTIONAL
*"----------------------------------------------------------------------
data: ld_dynnr like sy-dynnr value '0100'.
data: ls_field like se16n_output.
data: IT_OUTPUT_FIELDS like SE16N_OUTPUT occurs 0.
data: IT_OR_SELFIELDS  TYPE  SE16N_OR_T.
data: lt_Sel           like se16n_seltab occurs 0 with header line.
data: lt_where         type se16n_where_132 occurs 0 with header line.
DATA: LD_DATE          LIKE SY-DATUM.

  if not i_tab is initial.
     gd-tab       = i_tab.
     gd-drilldown = 'X'.
     gd-min_count_dd = true.
  else.
     get parameter id 'DTB' field gd-tab.
  endif.

  if i_single_table = true.
     gd-single_tab = true.
  endif.

  if i_hana_active = true.
     gd-hana_active = true.
  endif.

  gd-dbcon     = i_dbcon.
  gd-ojkey     = i_ojkey.
  gd-max_lines = i_max_lines.
  gd-variant   = i_variant.
  gd-double_click = i_double_click.
  gd-formula_name = i_formula_name.

*.in display mode do not allow maintenance
  gd-display = i_display.

*.if exit fb set, take this to determine the selection fields
*.the interface of this function has to look like
*.    exporting i_tab        type se16n_tab
*.    tables    it_selfields structure se16n_selfields
*.set the field INPUT = 0 in it_selfields to switch the field off
  gd-exit_fb_selfields = i_exit_selfield_fb.

*.Initialize the possible entry fields, depending on select option
  perform init_sel_opt.

*.fill selection criteria
  refresh: gt_selfields, gt_multi.
  gt_selfields[] = lt_selfields[].
  gt_multi[]     = lt_multi[].

*.call SE16N-screen again with all input possibilities
  if i_value_call = true.
     call screen ld_dynnr.
*.only ask for new drilldown attributes
  else.
     case i_kind_of_call.
*......do drilldown, but in the same screen
       when c_drilldown_list_same_screen or
            c_drilldown_line_same_screen.
         perform dd_same_screen.
*......we are in RFC from line, start selection
       when others.
         perform execute using space space space.
     endcase.
  endif.

ENDFUNCTION.
