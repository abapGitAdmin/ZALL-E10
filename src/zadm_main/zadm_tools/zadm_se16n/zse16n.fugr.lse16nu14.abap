FUNCTION SE16N_EXTERNAL_CALL.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_TAB) TYPE  SE16N_TAB
*"     VALUE(I_VARIANT) TYPE  SLIS_VARI OPTIONAL
*"     VALUE(I_HANA_ACTIVE) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_DBCON) TYPE  DBCON_NAME OPTIONAL
*"     VALUE(I_OJKEY) TYPE  TSWAPPL OPTIONAL
*"     VALUE(I_MAX_LINES) TYPE  SYTABIX DEFAULT 5000
*"     VALUE(I_GUI_TITLE) TYPE  SYTITLE OPTIONAL
*"     VALUE(I_FCAT_STRUCTURE) TYPE  TABNAME OPTIONAL
*"     VALUE(I_LAYOUT_GROUP) TYPE  SLIS_LOGGR OPTIONAL
*"     VALUE(I_NO_LAYOUTS) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_DISPLAY_ALL) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_TEMPERATURE) TYPE  DATA_TEMPERATURE DEFAULT SPACE
*"     VALUE(I_TEMPERATURE_COLD) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_SESSION_CONTROL) TYPE
*"EF TO CL_ABAP_SESSION_TEMPERATURE OPTIONAL
*"     VALUE(I_EDIT) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_NO_CONVEXIT) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_CHECKKEY) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_FORMULA_NAME) TYPE  GTB_FORMULA_NAME DEFAULT SPACE
*"  TABLES
*"      IT_SELTAB STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_SUM_UP_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_GROUP_BY_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_ORDER_BY_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_AGGREGATE_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_TOPLOW_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_SORTORDER_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_CALLBACK_EVENTS TYPE  SE16N_EVENTS OPTIONAL
*"      IT_OUTPUT_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_HAVING_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"  EXCEPTIONS
*"      NO_VALUES
*"----------------------------------------------------------------------
data: it_or_selfields type se16n_or_t.

*..This function module converts the handed over IT_OR_SELFIELDS
*..into GT_SELFIELDS and GT_MULTI to be able to use the drilldown on
*..the result list.
   refresh: gt_selfields[], gt_multi[], gt_or_selfields[].

*..set global data
   gd-ext_call    = true.
   gd-tab         = i_tab.
   gd-hana_active = i_hana_active.
   gd-dbcon       = i_dbcon.
   gd-ojkey       = i_ojkey.
   gd_toggle_layout = true.
   if i_no_layouts = true.
      gd-show_layouts = space.
   else.
      gd-show_layouts  = true.
   endif.
   gd-fcat_table    = i_fcat_structure.
   gd-layout_group  = i_layout_group.
   GET PARAMETER ID 'SE16N_DOUBLE_CLICK' FIELD gd-double_click.

   if not i_gui_title is initial.
     gd-ext_gui_title = i_gui_title.
   else.
     gd-ext_gui_title = text-220.
   endif.
   perform create_selfields tables   it_seltab
                                     it_sum_up_fields
                                     it_group_by_fields
                                     it_order_by_fields
                                     it_aggregate_fields
                                     it_toplow_fields
                                     it_sortorder_fields
                                     it_having_fields
                            using    i_tab
                            changing it_or_selfields.

*..call SE16H finally
   CALL FUNCTION 'SE16N_INTERFACE'
          EXPORTING
            I_TAB            = i_tab
            i_variant        = i_variant
            i_hana_active    = i_hana_active
            i_max_lines      = i_max_lines
            i_dbcon          = i_dbcon
            i_ojkey          = i_ojkey
            i_display_all    = i_display_all
            i_temperature    = i_temperature
            i_session_control  = i_session_control
            i_temperature_cold = i_temperature_cold
            i_edit             = i_edit
            i_no_convexit      = i_no_convexit
            i_checkkey         = i_checkkey
            i_formula_name     = i_formula_name
          TABLES
            it_or_selfields       = it_or_selfields
            it_sum_up_fields      = it_sum_up_fields
            it_group_by_fields    = it_group_by_fields
            it_order_by_fields    = it_order_by_fields
            it_toplow_fields      = it_toplow_fields
            it_sortorder_fields   = it_sortorder_fields
            it_aggregate_fields   = it_aggregate_fields
            it_callback_events    = it_callback_events
            it_output_fields      = it_output_fields
            it_having_fields      = it_having_fields
         Exceptions
            no_values             = 1.
  if sy-subrc = 1.
     message e002(wusl) raising no_values.
  endif.

*.clear all global variables
  CLEAR gd_ext_call.
  MOVE-CORRESPONDING gd_ext_call TO gd.
  CLEAR gd_toggle_layout.
  if not gd-ext_top_cont is initial.
     CALL METHOD gd-ext_top_cont->free.
  endif.

ENDFUNCTION.
