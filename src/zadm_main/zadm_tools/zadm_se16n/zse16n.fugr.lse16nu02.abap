FUNCTION SE16N_INTERFACE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_TAB) TYPE  SE16N_TAB
*"     VALUE(I_EDIT) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_SAPEDIT) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_NO_TXT) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_MAX_LINES) TYPE  SYTABIX DEFAULT 500
*"     VALUE(I_LINE_DET) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_DISPLAY) TYPE  CHAR1 DEFAULT 'X'
*"     VALUE(I_CLNT_SPEZ) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_CLNT_DEP) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_VARIANT) TYPE  SLIS_VARI DEFAULT ' '
*"     VALUE(I_OLD_ALV) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_CHECKKEY) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_TECH_NAMES) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_CWIDTH_OPT_OFF) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_SCROLL) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_NO_CONVEXIT) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_LAYOUT_GET) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_ADD_FIELD) TYPE  CHAR40 OPTIONAL
*"     VALUE(I_ADD_FIELDS_ON) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_UNAME) TYPE  SY-UNAME OPTIONAL
*"     VALUE(I_HANA_ACTIVE) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_DBCON) TYPE  DBCON_NAME DEFAULT SPACE
*"     VALUE(I_OJKEY) TYPE  TSWAPPL DEFAULT SPACE
*"     VALUE(I_DISPLAY_ALL) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(I_TEMPERATURE) TYPE  DATA_TEMPERATURE DEFAULT SPACE
*"     VALUE(I_TEMPERATURE_COLD) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_SESSION_CONTROL) TYPE
*"EF TO CL_ABAP_SESSION_TEMPERATURE OPTIONAL
*"     VALUE(I_MINCNT) TYPE  SYTABIX OPTIONAL
*"     VALUE(I_FDA) TYPE  SE16N_FDA OPTIONAL
*"     VALUE(I_EXTRACT_READ) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_EXTRACT_WRITE) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_EXTRACT_NAME) TYPE  SE16N_LT_NAME DEFAULT SPACE
*"     VALUE(I_EXTRACT_UNAME) TYPE  SYUNAME DEFAULT SPACE
*"     VALUE(I_FORMULA_NAME) TYPE  GTB_FORMULA_NAME DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_LINE_NR) TYPE  SYTABIX
*"     VALUE(E_DREF)
*"     VALUE(ET_FIELDCAT) TYPE  LVC_T_FCAT
*"  TABLES
*"      IT_SELFIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_OUTPUT_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_OR_SELFIELDS TYPE  SE16N_OR_T OPTIONAL
*"      IT_CALLBACK_EVENTS TYPE  SE16N_EVENTS OPTIONAL
*"      IT_ADD_UP_CURR_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_ADD_UP_QUAN_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_SUM_UP_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_GROUP_BY_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_ORDER_BY_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_AGGREGATE_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_TOPLOW_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_SORTORDER_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_HAVING_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"  CHANGING
*"     VALUE(IT_AND_SELFIELDS) TYPE  SE16N_AND_T OPTIONAL
*"  EXCEPTIONS
*"      NO_VALUES
*"----------------------------------------------------------------------
data: lt_where   type se16n_where_132 occurs 0 with header line.
data: ld_subrc   like sy-subrc.
data: ld_txt_tab type DD08V-TABNAME.
data: ld_partial(1).
data: ld_tabclass like dd02l-tabclass.
data: ld_no_txt(1).
data: ld_abort(1).
data: ltx_table_data  type fagl_tx_prot_data.

*..If only line number -> no texts
   ld_no_txt = i_no_txt.
   if i_line_det = true.
      ld_no_txt = true.
   endif.
   gd-no_txt = i_no_txt.

   if i_hana_active             = true    or
      i_dbcon                  <> space   or
      i_extract_read            = true    or
      not it_sum_up_fields[]   is initial or
      not it_group_by_fields[] is initial.
      clear: i_edit, i_sapedit.
   endif.

*..clear CDS-View-String
   clear: gd-cds_string,
          gd-cds_filled.
   CLEAR: gd-txt_join_active,
          gd-txt_join_missing,
          gd-txt_pool,
          gd-cds_join_string.
   clear: gd-oj_join_active,
          gd-oj_string_filled.

*..In batch or extern call, these are not filled before
   gd-tab         = i_tab.
   gd-max_lines   = i_max_lines.
   gd-variant     = i_variant.
   gd-edit        = i_edit.
   gd-sapedit     = i_sapedit.
   gd-checkkey    = i_checkkey.
   gd-scroll      = i_scroll.
   gd-no_convexit = i_no_convexit.
   gd-layout_get  = i_layout_get.
   gd-add_field   = i_add_field.
   gd-add_fields_on = i_add_fields_on.
   gd-dbcon         = i_dbcon.
   gd-ojkey         = i_ojkey.
   gd-min_count     = i_mincnt.
   gd-fda           = i_fda.
   gd-tech_names    = i_tech_names.
   gd-no_txt        = i_no_txt.
   gd-clnt_spez     = i_clnt_spez.
   gd-clnt_dep      = i_clnt_dep.
   gd-temperature   = i_temperature.
   gd-formula_name  = i_formula_name.
   gd_extract-read  = i_extract_read.
   gd_extract-write = i_extract_write.
   gd_extract-name  = i_extract_name.
   if i_extract_uname is initial.
     gd_extract-uname = sy-uname.
   else.
     gd_extract-uname = i_extract_uname.
   endif.
   if i_uname = space.
      gd-uname = sy-uname.
   else.
      gd-uname = i_uname.
   endif.

*..set data aging temperature
   perform set_temperature using i_session_control
                                 i_temperature_cold.

*..check for necessary entity switch
   perform check_entity_switch.

*..fill global event table
   refresh: gt_callback_events.
   gt_callback_events[] = it_callback_events[].
*.........................................................
   select * from se16n_exit into table gt_cb_events
               where tab = gd-tab.
*..special logic for some events, because of *-entries
   perform read_exit_data using c_event_add_fields.
*..be compatible to new exit logic
*..caller can either hand over it_callback_events
*..or table SE16N_EXIT is permanently filled with exit
*.........................................................
   loop at gt_callback_events into gs_callback_events.
      move-corresponding gs_callback_events to gs_cb_events.
      gs_cb_events-callback_funct = gs_callback_events-callback_function.
      gs_cb_events-tab = i_tab.
      append gs_cb_events to gt_cb_events.
   endloop.

*..refresh empty column store
   refresh gt_fieldcat_empty.

*..fill global add-up tables
   refresh: gt_add_up_curr_fields.
   gt_add_up_curr_fields[] = it_add_up_curr_fields[].
   refresh: gt_add_up_quan_fields.
   gt_add_up_quan_fields[] = it_add_up_quan_fields[].

*..Hana-mode tables
   refresh: gt_sum_up_fields.
   gt_sum_up_fields[] = it_sum_up_fields[].
   refresh: gt_having_fields.
   gt_having_fields[] = it_having_fields[].
*..map grouping order according sequence
   perform map_grouping_order tables it_group_by_fields
                                     it_sortorder_fields.
   refresh: gt_group_by_fields.
   gt_group_by_fields[] = it_group_by_fields[].
*..map sort order on sort table
   perform map_sort_order tables it_order_by_fields
                                 it_sortorder_fields.
   refresh: gt_order_by_fields.
   gt_order_by_fields[] = it_order_by_fields[].
   refresh: gt_toplow_fields.
   gt_toplow_fields[] = it_toplow_fields[].
   refresh: gt_sortorder_fields.
   gt_sortorder_fields[] = it_sortorder_fields[].
   refresh: gt_aggregate_fields.
   gt_aggregate_fields[] = it_aggregate_fields[].
   refresh: gt_or_selfields.
   gt_or_selfields[] = it_or_selfields[].
   refresh: gt_and_selfields.
   gt_and_selfields[] = it_and_selfields[].
   refresh: gt_navigation.
   gd_curr_level = 1.

*..check if table is a pool-table
   select single tabclass from dd02l into ld_tabclass
                     where tabname = i_tab.
   if sy-subrc = 0 and
      ld_tabclass = 'POOL'.
      gd-pool = true.
   else.
      clear gd-pool.
   endif.

*..If back to first screen, delete all modifcations
   clear: gt_mod.
   refresh: gt_mod.

*..Check the authority of the user
   perform authority_check using    i_tab
                                    'F'
                           changing i_edit.

*..First get time for display of runtime
   perform get_time changing gd-start_time
                             gd-start_date.

*..Check if there is a corresponding text table
   perform get_text_table using    i_tab
                          changing ld_txt_tab.
   gd-txt_tab = ld_txt_tab.

*..runtime analysis
   perform progress using '1'.

*..Now create a fieldcatalog of the table I have to display. After this
*..GT_FIELDCAT is filled and <ALL_TABLE> is created and defined
   perform create_fieldcat_standard tables   it_output_fields
                                    using    i_tab
                                             i_edit
                                             i_tech_names
                                             ld_no_txt
                                             i_clnt_spez
                                             i_clnt_dep
                                             ld_txt_tab.

*..delete adjacent duplicates out of selection table
   perform delete_duplicates tables it_or_selfields.

*..runtime analysis
   perform progress using '2'.

   if gd_extract-read is initial.

*..determine if JOIN-logic for text table is possible.
   IF gd-txt_tab <> space AND
      gd-no_txt  <> true  AND
      ld_no_txt  <> true.
      PERFORM prepare_text_join CHANGING gd-cds_join_string.
   ENDIF.
*..determine select string in case of DDL-Source
   perform select_cds_string using    i_tab
                            changing gd-cds_string
                                     ld_abort.
   if ld_abort = true.
     message e002(wusl) raising no_values.
   endif.

*..new logic for outer join
   if gd-new_oj_join = true and
      gd-ojkey       <> space and
      gd-cds_filled  <> true.
      perform prepare_join_select using    i_tab
                                  changing gd-cds_string.
   endif.

*..find out if too many selection criteria are used
*..if so, do the partial select
   clear ld_partial.
*..Check if no multi select took place.
*..Then no partial select is possible.
   describe table it_or_selfields lines sy-tabix.
   if sy-tabix = 1.
      gt_or[] = it_or_selfields[].
      perform scan_selfields using    i_tab
                                      i_max_lines
                                      i_line_det
                                      i_display_all
                                      i_clnt_spez
                             changing ld_subrc
                                      ld_partial
                                      ld_abort.
      if ld_abort = true.
        message e002(wusl) raising no_values.
      endif.
   endif.

*..if not, do the normal select
   if ld_partial <> true.
*.....Create selection table out of input selfields
      perform create_seltab tables lt_where
                                   it_selfields
                                   it_or_selfields
                            changing it_and_selfields.

*..Now do the select on one table with the created selection criteria
      perform select_standard tables   lt_where
                              using    i_tab
                                       i_max_lines
                                       i_line_det
                                       i_display_all
                                       i_clnt_spez
                              changing ld_subrc
                                       ld_abort.
      if ld_abort = true.
        message e002(wusl) raising no_values.
      endif.
   endif.

*..Give number of found entries back to caller
   if gd-number > 2147483647.
     e_line_nr = 2147483647.
   else.
     e_line_nr = gd-number.
   endif.
   perform progress using '6'.

*..If nothing has been found, exit
*..In case of edit -> Show empty table, because of insert
   if ld_subrc <> 0 and i_edit <> true and
      gd-number < 1.
      message e002(wusl) raising no_values.
   endif.

*..Select the texts
   if ld_no_txt <> true and
      gd-txt_pool = true.
      perform select_text_table using  ld_txt_tab
                                       i_clnt_spez.
   endif.

*..outer join selects
   if gd-ojkey <> space and
      gd-oj_join_active = space.
*     perform ojkey_select.
      perform ojkey_select_new.
   endif.

   else.  "read extract using variant
*.....Create selection table out of input selfields
     perform create_seltab tables lt_where
                                  it_selfields
                                  it_or_selfields
                           changing it_and_selfields.
     perform read_extract changing ltx_table_data.
   endif.

*..formula handling
   IF gd-formula_name <> space.
     PERFORM formula_calculate.
   ENDIF.

*..write extract if requested
   if gd_extract-write is not initial.
     perform write_extract changing ltx_table_data.
   endif.

*..Now display the results in a fullscreen ALV-Grid
   if i_line_det <> true.
      if i_display = true.
         perform display_standard using i_old_alv
                                        i_cwidth_opt_off.
      else.
         e_dref = gd_dref.
         et_fieldcat[] = gt_fieldcat[].
      endif.
   else.
      if i_display = true.
         perform display_line_nr.
      endif.
   endif.


ENDFUNCTION.
