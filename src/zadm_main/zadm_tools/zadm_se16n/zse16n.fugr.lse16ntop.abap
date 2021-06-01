FUNCTION-POOL SE16N.                        "MESSAGE-ID ..

tables: gtdiscd, varid, varit, dd02l, dd06l.

type-pools: slis.

*.global data
data: begin of gd,
        tab         type se16n_tab,
        txt_tab     type se16n_tab,
        variant     type SLIS_VARI,
        variant_old type SLIS_VARI,
        varianttext type SLIS_VARBZ,
        clnt(1),                     "table itself is client dependent
        no_clnt_anymore(1) value 'X',"do not allow clnt anymore
        drilldown(1),                "drilldown call
        read_clnt(1),                "user wants to select client dep.
        tech_names(1),               "technical names as column head
        entity       TYPE viewname,  "name of entity of table
        ddlname      TYPE ddlname,   "name of DDL of table
        dy_tab1      TYPE se16n_tab, "dummy for DDL-Replacement
        dy_tab2      TYPE se16n_tab, "dummy for DDL-Replacement
        dy_entity    TYPE viewname,  "dummy for DDL-Replacement
        dy_ddlname   TYPE ddlname,   "dummy for DDL-Replacement
        entity_switch(1),            "replace table with entity name
        ut_sel_screen_call(1),       "call of selscreen via UT
        cwidth_opt_off(1),           "column width optimization off
        no_txt(1),
        txt_join_active(1),          "text table is selected via JOIN
        txt_join_missing(1),         "Join not possible
        txt_pool(1),                 "Text table is pool table
        offset type DOFFSET,         "width of table
        single_tab(1),               "table name may not be changed
        count_lines(1),              "count number of displayed lines
        scroll(1),                   "roll key columns
        no_convexit(1),              "do not use convexit for output
        tech_first(1),               "tech column is first one
        colopt(1),                   "column width smaller
        hana_active(1),              "HANA mode is active
        ext_call(1),                 "external call via Interface
        formula_name type gtb_formula_name, "name of formula
        show_layouts(1),             "activate layout docking
        fcat_table type tabname,     "table name for fcat creation
        layout_group type SLIS_LOGGR,"additional grouping for layouts
        exit_done(1),                "exit was executed
        ext_gui_title like sy-title, "GUI-Titel der Ausgabeliste
        ext_top_cont_name type scrfname value 'EXT_TOP_OF_PAGE',
        ext_top_dock type ref to cl_gui_docking_container,
        ext_top_cont type ref to cl_gui_custom_container,
        ext_dd       type ref to cl_dd_document,
        double_click like sy-ucomm,  "defined action for double click
        select_type(2),              "Differentiates the select
        dbcon TYPE DBCON_NAME,       "Name of alternate DB-Connection
        oj_dbcon TYPE DBCON_NAME,    "Name of alternate DB-Connection for OJ
        ojkey like se16n_oj_keyt-oj_key, "Name of Outer Join Definition
        oj_string_filled(1),         "Outer-Join String filled
        oj_join_active(1),           "Outer-Join-Join active
        new_oj_join(1) value 'X',    "New logic activated
        temperature type DATA_TEMPERATURE, "temp for HDB
        hint type string,            "string for HDB-Hint
        hint_field type string,      "field for the DB-Hint
        hint_value type string,      "value of the hint field
        hint_count type string,      "field for count(*)
        having_clause type string,   "string for having-clause
        clnt_spez(1),
        clnt_dep(1),
        layout_save(1),              "automatically save layout
        layout_get(1),               "automatically get layout
        cds_no_sys(1),               "do not display system-parameters
        pool(1),                     "table is pooltable
        cds_string type string,      "select string for DDL
        cds_save_string type string, "save select string for DDL
        cds_join_string type string, "for join on text-table
        cds_filled(1),               "CDS-String is done
        buffer(1)  value ' ',        "use ALV-Buffer
        zebra(1)   value ' ',        "write ALV in zebra
        fica_audit(1),               "special handling for audit
        tax_audit(1),                "tax audit active
        tab_save   type se16n_tab,
        checkkey(1) value space,     "no check key check
        sapedit(1) value space,      "special edit for SAP
        edit(1)    value space,      "user wants to edit the table
        tabedit(1) value space,      "table itself is editable
        emergency(1) value space,    "emergency edit mode
        display(1) value space,      "only display mode
        se16t_off(1) value space,    "no jump to extended table search
        no_clnt_auth(1) value space, "no authority for client dependent
        view(1)    value space,      "view exists for table
        ddic_view(1) value space,    "DDIC-view exists for table
        tech_view(1) value space,    "technical view on table control
        sortfield(1) value space,    "additional sort field in fieldcat
        exit_fb_selfields type funcname,"Name des Exit-FB's
        add_fields(1)      value space, "Entry for exit available
        add_fields_on(1)   value 'X',   "really use the exit
        add_fields_cust(1) value space, "add field is activated
        add_field(40)      value space, "free field for exit
        add_field_text   type ddtext,   "text of additional field
        add_field_reftab type tabname,  "dtel of extra field
        add_field_reffld type fieldname,"dtel of extra field
        add_field_length type ddleng,   "length of extra field
        uname      like sy-uname,       "uname for authority
        auth(4)    value space,
        keylen     like sy-tabix,
        max_lines  like sy-tabix value 500,
        fda        type se16n_fda,      "Fast Data Access
        fda_on(1),                      "show FDA-Field
        min_count  like sy-tabix,       "Value for Having-Clause
        min_count_dd(1),
        number     type p length 16,
        partial(1),
        count      type p length 16,
        start_date like sy-datlo,
        start_time like sy-timlo,
        end_date   like sy-datlo,
        end_time   like sy-timlo,
        runtime    like swl_pm_cvh-duration,
        duration   like sy-tabix,
      end of gd.

*.global variable for change of field length
data: gd_length_changed(1).

*.data for extract handling
data: begin of gd_extract,
         read(1),
         write(1),
         name type SE16N_LT_NAME,
         uname type sy-uname,
         id type guid_16,
      end of gd_extract.
data: gd_save_extract like gd_extract.

data: ex_code      like sy-ucomm.
data: save_ex_code like sy-ucomm.

*.table to exclude functions
DATA: BEGIN OF FUNCTAB OCCURS 10,
               FCODE LIKE SY-PFKEY,
      END OF FUNCTAB.

*.table to exclude functions for display mode
DATA: BEGIN OF DISTAB OCCURS 10,
               FCODE LIKE SY-PFKEY,
      END OF DISTAB.

*.Data for Formulas
DATA: gt_formula TYPE gtb_t_formula.
DATA: gs_formula TYPE gtb_s_formula.
FIELD-SYMBOLS: <gd_wa>.

*.display variant
data: gs_variant type DISVARIANT.
data: begin of gd_variant,
         report    type REPID      value 'SAPLSE16N',
         handle    type SLIS_HANDL,
         log_group type SLIS_LOGGR,
         username  type SLIS_USER,
         variant   type SLIS_VARI,
         text      type SLIS_VARBZ,
      end of gd_variant.
data: gd_save    type CHAR01 value 'A'.

data: begin of gd_ext_call,
        ext_call(1),
        hana_active(1),
        dbcon         type dbcon_name,
        ojkey         like se16n_oj_keyt-oj_key,
        show_layouts(1),
        fcat_table    type tabname,
        layout_group  type SLIS_LOGGR,
        ext_gui_title like sy-title,
      end of gd_ext_call.

*.data for column configuration
data: gd_add_column type fieldname.

*.data for ABAP-display
data: gd_abap_dock   type ref to cl_gui_docking_container.
data: gd_abap_text   type ref to cl_gui_textedit.
data: gd_abap_dock_active(1).

*.data for layout docking
data: gd_layout_dock   type ref to cl_gui_docking_container.
data: gd_layout_alv    type ref to cl_gui_alv_grid.
data: gt_variants      like ltvariant occurs 0.
types: begin of t_layouts.
          include structure ltvariant.
types:     style(3),
       end of t_layouts.
data: gs_layouts       type t_layouts.
data: gt_layouts       type table of t_layouts.
data: gr_alv_grid      type ref to cl_gui_alv_grid.
data: gd_toggle_layout value 'X'.
data: gd_toggle_top    value 'X'.
data: gt_layt_fieldcat type lvc_t_fcat,
      gs_layt_fieldcat type lvc_s_fcat.
data: gt_layt_fcat     type SLIS_T_FIELDCAT_ALV.
constants: c_repid type progname value 'SAPLSE16N'.

data: begin of excltab occurs 0,
        fcode like sy-ucomm,
      end of excltab.

DATA: WA TYPE CXTAB_COLUMN.
data: fld_index like sy-index.
data: tec_index like sy-index.
data: lld_pool  like dd02l-tabclass.
data: lls_selfields like se16n_selfields.

*.global data for date-interval popup
data: begin of gdu,
        sdate type sy-datlo,
        edate type sy-datlo,
        fcode type sy-ucomm,
      end of gdu.

*.variabel for text of table
data: gd_tabl_text type AS4TEXT.

*.global data for display of multi selection screen
data: gt_se16n_rf     like se16n_rf occurs 0 with header line.
data: new_lines       like sy-tabix value 8.
data: gd_fieldname    like se16n_selfields-fieldname.
data: gd_scrtext_m    like se16n_selfields-scrtext_m.
data: gd_datatype     like se16n_selfields-datatype.
data: looplines1      like sy-loopc.
data: looplines_dd    like sy-loopc.
data: linecount1      like sy-tabix.
data: linecount_dd    like sy-tabix.
data: gd_lines_used   like sy-tabix.
data: gd_mf_display(1).
data: gd_chk_inp_func type funcname.
data: gt_multi_select like se16n_selfields occurs 0 with header line.
data: gs_multi_select like se16n_selfields.
data: gt_excl_selopt  type se16n_sel_option occurs 0 with header line.
data: gd_save_low     like gs_multi_select-low.
data: gd_save_high    like gs_multi_select-high.
data: fcode           like sy-ucomm,
      save_fcode      like sy-ucomm.
data: gs_se16n_exit   like se16n_exit.
controls: multi_tc    type tableview using screen 0001.

*.global table for variant fields
data: begin of gt_vari_fields occurs 0,
        fieldname type fieldname,
        selname(8),
      end of gt_vari_fields.
data: text_2(50).
data: gs_se16n_lt like se16n_lt.
constants: c_mark(2)       value 'MA'.
constants: c_quan(2)       value 'QA'.
constants: c_curr(2)       value 'CU'.
constants: c_summ(2)       value 'SU'.
constants: c_have(2)       value 'HV'.
constants: c_grup(2)       value 'GR'.
constants: c_aggr(2)       value 'AG'.
constants: c_noco(2)       value 'NC'.
constants: c_top(2)        value 'TO'.
constants: c_sor(2)        value 'SO'.
constants: c_asc(2)        value 'AS'.
constants: c_des(2)        value 'DE'.
constants: c_max(2)        value 'MX'.
constants: c_min(2)        value 'MI'.
constants: c_avg(2)        value 'AV'.
constants: c_maxf(3)       value 'MAX'.
constants: c_minf(3)       value 'MIN'.
constants: c_avgf(3)       value 'AVG'.
constants: c_orde(2)       value 'OR'.
constants: c_setid_ltd(9)  value '##SETID##'.
constants: gd_own_vari(30) value 'SE16N_BATCH'.
constants: begin of c_mode,
             delete(1) value 'D',
             change(1) value 'C',
           end of c_mode.

*.global data for display of selection screen
data: push(50).
data: option(50).
data: having_option(50).
data: ld_line         like sy-tabix.
DATA: gd_cursor_line  LIKE sy-tabix.
data: gd_111_display(1).
data: looplines       like sy-loopc.
data: linecount       like sy-tabix.
*.table for multi input in multi tupel input
data: gt_or_mul_all   type se16n_selfields_t_out.
data: gs_or_mul_all   type se16n_selfields_s_in.
*.table for display of one multi input multi tupel input
data: gt_or_mul       like se16n_selfields occurs 0 with header line.
data: gs_or_mul       like se16n_selfields.
*.table for normal multi input
data: gt_multi        like se16n_selfields occurs 0 with header line.
data: gt_selfields    like se16n_selfields occurs 0 with header line.
data: gs_multi_sel    like se16n_selfields.
data: gt_selfields_dd like se16n_selfields occurs 0 with header line.
data: gs_selfields_dd like se16n_selfields.
data: gd_dd_tab       type se16n_tab.
*.deep type to store the information to navigate
types: begin of ts_navigation,
          level(3)     type n,
          selfields    type SE16N_SELFIELDS_T_IN,
          multi        type SE16N_SELFIELDS_T_IN,
          or_selfields type SE16N_OR_T,
          variant      type slis_vari,
       end of ts_navigation.
data: gs_navigation    type ts_navigation.
data: gt_navigation    type table of ts_navigation.
data: gt_navi_save     type table of ts_navigation.
data: gd_curr_level(3) type n.
data: begin of gs_ext_hotspot,
        ROW_ID    type lvc_s_row,
        COLUMN_ID type lvc_s_col,
      end of gs_ext_hotspot.
field-symbols: <g_wa>.
data: gd_cancel(1).
*.buffer for multi tupel input
data: gt_multi_or_all_buf type se16n_selfields_t_out.
*.all multi tupel inputs
data: gt_multi_or_all type se16n_selfields_t_out.
*.structure for all multi tupel input
data: gs_multi_or_all type se16n_selfields_s_in.
*.table for display of one multi tupel input
data: gt_multi_or     like se16n_selfields occurs 0 with header line.
data: gs_curr_dummy   like se16n_selfields.
data: gd_currency     type sycurr.
data: gd_currency_pbo type sycurr.
*.structure for display of one multi tupel input
data: gs_multi_or     like se16n_selfields.
data: gd_multi_or_pos like sy-tabix.
data: gs_selfields    like se16n_selfields.
data: gd_valid(1).
data: gd_exit(1).
data: ok_code         like sy-ucomm,
      save_ok_code    like sy-ucomm,
      fcode_or        like sy-ucomm,
      save_fcode_or   like sy-ucomm.
*.dynamic icon for status to reach multi or input
data: multi_or_icon   type SMP_DYNTXT.
data: ld_valid(1).
data: ls_mesg like smesg.
controls: selfields_tc type tableview using screen 0100.
controls: dd_tc        type tableview using screen 2000.
controls: multi_or_tc  type tableview using screen 0111.
*.constant for special search for space-entry
*.if in multi field input the user wants to search for EQ 'A', 'B' AND
*.space, he has to enter 'A', 'B', '#'. Othwerwise it is not possible
constants: c_space(1) value '#'.

*.global table that contains the found lines
data: gt_sel like se16n_seltab occurs 0 with header line.
data: gt_or  type se16n_or_t.
*.global callback event table
data: gt_callback_events type se16n_events.
data: gs_callback_events type se16n_events_type.
data: gt_cb_events type se16n_exit occurs 0.
data: gs_cb_events type se16n_exit.
data: gs_dfies     type dfies.
data: gt_toolbar_excl type ui_functions.

constants: c_event_save        type SE16N_EVENT value 'SAVE'.
constants: c_event_db_count    type SE16N_EVENT value 'DB_COUNT'.
constants: c_event_db_hint     type SE16N_EVENT value 'DB_HINT'.
constants: c_event_add_up      type SE16N_EVENT value 'ADD_UP'.
constants: c_event_add_fields  type SE16N_EVENT value 'ADD_FIELDS'.
CONSTANTS: C_EVENT_FICA_ACTIVE TYPE SE16N_EVENT VALUE 'FICA_ACTIV'.
constants: c_event_fica_lock   type SE16N_EVENT value 'FICA_LOCK'.
constants: c_event_fica_save   type SE16N_EVENT value 'FICA_SAVE'.
constants: c_add_info_add_fcat type SE16N_EVENT value 'ADD_FCAT'.
constants: c_add_info_add_calc type SE16N_EVENT value 'ADD_CALC'.
constants: c_add_info_add_sscr type SE16N_EVENT value 'ADD_SELSCR'.
constants: c_ext_event_fcat    type se16n_event value 'EXT_ADD_FCAT'.
constants: c_ext_layout_fcat   type se16n_event value 'EXT_LAYOUT_FCAT'.
constants: c_ext_change_lines  type se16n_event value 'EXT_CHANGE_LINES'.
constants: c_ext_hotspot       type se16n_event value 'EXT_HANDLE_HOTSPOT'.
constants: c_ext_top_of_page   type se16n_event value 'EXT_TOP_OF_PAGE'.
constants: c_ext_toolbar_excl  type se16n_event value 'EXT_TOOLBAR_EXCL'.
constants: c_ext_data_changed  type se16n_event value 'EXT_DATA_CHANGED'.
constants: c_add_info_curr(30) value 'CURR'.
constants: c_add_info_quan(30) value 'QUAN'.
constants: c_add_info_modify(30) value 'MODIFY'.
CONSTANTS: C_ADD_INFO_MODOLD(30) VALUE 'MODOLD'.
constants: c_add_info_insert(30) value 'INSERT'.
constants: c_add_info_delete(30) value 'DELETE'.

*.global table that contains the add-up-fields
data: gt_add_up_curr_fields like se16n_output occurs 0 with header line.
data: gt_add_up_quan_fields like se16n_output occurs 0 with header line.

*.global table that contains the sum-up-fields
data: gt_sum_up_fields   like se16n_output occurs 0 with header line.
data: gt_group_by_fields like se16n_output occurs 0 with header line.
data: gt_order_by_fields like se16n_output occurs 0 with header line.
data: gt_having_fields    like se16n_seltab occurs 0 with header line.
data: gt_toplow_fields    like se16n_seltab occurs 0 with header line.
data: gt_sortorder_fields like se16n_seltab occurs 0 with header line.
data: gt_aggregate_fields like se16n_seltab occurs 0 with header line.
data: gt_or_selfields     TYPE  SE16N_OR_T.
data: gt_and_selfields    TYPE  SE16N_AND_T.

*.global tables for display of select statement
data: gt_field    type table of string.
data: gt_group    type table of string.
data: gt_order    type table of string.

*data: gt_where(72) occurs 0 with header line.
data: gt_where type se16n_where_132 occurs 0 with header line.
field-symbols: <all_table>       type table.
field-symbols: <del_table>       type table.
field-symbols: <key_table>       type table.
field-symbols: <all_table_cell>  type table.
field-symbols: <all_table_save>  type table.
field-symbols: <wa>              type any.
field-symbols: <cell>            type lvc_t_styl,
               <fs>              type any,
               <fs_cell>         type any,
               <wa_cell>         type any.

*.global data for changes in table entries
data: begin of gt_mod occurs 0,
         alv_indx like sy-tabix,
         indx     like sy-tabix,
         type(1),
         used(1),
         save like sy-tabix,
      end of gt_mod.
constants: type_mod(1) value 'M'.
constants: type_ins(1) value 'I'.
constants: type_del(1) value 'D'.
field-symbols: <mod_table>  type table.
field-symbols: <ins_table>  type table.

*.global data for ALV-Grid Display
data: begin of gt_txt_fields occurs 0,
        field(30),
      end of gt_txt_fields.
data: gs_layout          type lvc_s_layo.
data: gt_detail          like SE16N_SELFIELDS occurs 0 with header line.
data: gt_layout_fields   TYPE  SE16N_OUTPUT_T.
data: gt_fieldcat        type lvc_t_fcat.
data: gt_fieldcat_key    type lvc_t_fcat.
data: gt_fieldcat_tab    type lvc_t_fcat.
data: gt_fieldcat_empty  type lvc_t_fcat.
data: gt_fieldcat_txttab type lvc_t_fcat.
data: begin of gt_fieldcat_txt_double occurs 0,
        new_fieldname type fieldname,
        org_fieldname type fieldname,
      end of gt_fieldcat_txt_double.
data: gs_fieldcat_txt_double like gt_fieldcat_txt_double.
data: gt_fieldcat_oj     type lvc_t_fcat.
data: gt_fieldcat_grp    type lvc_t_fcat.
data: gs_fieldcat_grp    type lvc_s_fcat.
data: begin of gt_fieldcat_oj_2 occurs 0,
        field         type fieldname,
        ref_tab       like se16n_oj_add-add_tab,
        org_field     type fieldname,
        datatype      type DYNPTYPE,
        aggregate     type se16n_aggr,
      end of gt_fieldcat_oj_2.
data: gs_fieldcat_oj_2   like gt_fieldcat_oj_2.
TYPES: BEGIN OF ty_table_letter,
         tabname   TYPE tabname,
         letter(1),
       END OF ty_table_letter.
DATA: gs_table_letter TYPE ty_table_letter.
DATA: gt_table_letter TYPE TABLE OF ty_table_letter.
data: gd_dref            type ref to data.
data: gd_lines           like sy-tabix.
data: g_container        type scrfname value 'RESULT_LIST',
      alv_grid           type ref to cl_gui_alv_grid,
      g_custom_container type ref to cl_gui_custom_container.
data: gt_cell            type lvc_t_styl.
data: gs_cell            type lvc_s_styl.
data: gd_style_fname     type LVC_FNAME.

*.data for sy-batch, ALV-Standard
data: gt_fieldcat_alv  type SLIS_T_FIELDCAT_ALV.
DATA: GS_LAYOUT_alv    TYPE SLIS_LAYOUT_ALV.
DATA: GT_EVENTS        TYPE SLIS_T_EVENT.
DATA: GS_PRINT         TYPE SLIS_PRINT_ALV.

DATA:  wa_line           TYPE slis_listheader.
DATA:  gd_alv_listheader TYPE slis_t_listheader.
DATA:  content           TYPE slis_listheader-info.

*.Display of the changed lines
data: gd_del_nr  like sy-tabix.
data: gd_ins_nr  like sy-tabix.
data: gd_mod_nr  like sy-tabix.

*.global buffer of already assigned dynamic tables
data: begin of gt_ref occurs 0,
        tab     type se16n_tab,
        txt_tab type se16n_tab,
        curr_add(1),
        quan_add(1),
        count_lines(1),
        sort_field(1),
        add_field(40),
        ojkey   type tswappl,
        formula type gtb_formula_name,
        sum_up  type SE16N_OUTPUT_T,
        dcell   type ref to data,
        dsave   type ref to data,
        ddel    type ref to data,
        dkey    type ref to data,
        dall    type ref to data,
      end of gt_ref.

*.global buffer for user-restrictions
data: gt_se16n_role_table like se16n_role_table occurs 0.
data: gs_se16n_role_table like se16n_role_table.

*.global table of inputable fields
data: begin of gt_sel_init occurs 0,
         option type se16n_option,
         low(1),
         high(1),
      end of gt_sel_init.

*.data used for role maintenance..........................
data: gd_role_display type char1.
data: gd_role_changed type char1.
data: gd_role_display_only type char1.
data: gd_role       like se16n_role_def_t-se16n_role.
data: gd_save_role  type se16n_role.
data: begin of gs_role,
        mode like sy-ucomm,
        modified(1),
      end of gs_role.
data: gd_role_txt   type kltxt.
data: gd_save_txt   type kltxt.
data: gs_role_def   type se16n_role_def.
data: gt_role_def   type se16n_role_def occurs 0 with header line.
data: gs_role_def_t type se16n_role_def_t.
data: gt_role_def_t type se16n_role_def_t occurs 0 with header line.
data: gs_role_txt   type se16n_role_def_t.
data: gt_role_txt   type se16n_role_def_t occurs 0 with header line.
data: gs_role_table type se16n_role_table_s.
data: gt_role_table type se16n_role_table_s occurs 0 with header line.
data: gs_role_value type se16n_role_value_s.
data: gt_role_value type se16n_role_value_s occurs 0 with header line.
data: gt_role_value_temp type se16n_role_value_s occurs 0 with header line.
data: gs_user_role  type se16n_user_role_s.
data: gt_user_role  type se16n_user_role_s occurs 0 with header line.
data: gs_field      type se16n_value.

*.table control of first screen
*data: looplines       like sy-loopc.
data: linecount_role_table like sy-tabix.
data: linecount_role_value like sy-tabix.
data: linecount_user_role  like sy-tabix.
controls: tab_role_table type tableview using screen 1000.
controls: tab_role_value type tableview using screen 1000.
controls: tab_user_role  type tableview using screen 1000.
constants: begin of fc,
             f03         like sy-ucomm value '&F03',
             f12         like sy-ucomm value '&F12',
             f15         like sy-ucomm value '&F15',
             trans       like sy-ucomm value 'TRANS',
             cancel      like sy-ucomm value 'CANC',
             copy        like sy-ucomm value 'COPY',
             delete      like sy-ucomm value 'DELETE',
             create      like sy-ucomm value 'CREATE',
             change      like sy-ucomm value 'CHANGE',
             display     like sy-ucomm value 'DISPLAY',
             tabname     type rollname value 'TABNAME',
             fieldname   type rollname value 'FIELDNAME',
             uname       type rollname value 'UNAME',
             push        like sy-ucomm value 'MORE',
             save        like sy-ucomm value 'SAVE_ROLE',
             transport   like sy-ucomm value 'TRANSPORT',
             del_rol_tab like sy-ucomm value 'DELETE_ROLE_TABLE',
             cre_rol_tab like sy-ucomm value 'CREATE_ROLE_TABLE',
             ins_rol_tab like sy-ucomm value 'INSERT_ROLE_TABLE',
             del_rol_val like sy-ucomm value 'DELETE_ROLE_VALUE',
             cre_rol_val like sy-ucomm value 'CREATE_ROLE_VALUE',
             ins_rol_val like sy-ucomm value 'INSERT_ROLE_VALUE',
             del_use_rol like sy-ucomm value 'DELETE_USER_ROLE',
             cre_use_rol like sy-ucomm value 'CREATE_USER_ROLE',
             ins_use_rol like sy-ucomm value 'INSERT_USER_ROLE',
             change_doc  like sy-ucomm value 'CDOC',
           end of fc.

*.constants used very often
constants: true(1)  value 'X',
           false(1) value '-'.

*.constant for generic outer join
constants: c_ojkey_generic_a type tswappl value 'SAP_OJKEY_HANA_VS_ANYDB'.
constants: c_ojkey_generic_b type tswappl value 'SAP_OJKEY_ANYDB_VS_HANA'.
*.tables for generic outer join
data: gt_add    like se16n_oj_add occurs 0.
data: gt_addf   like se16n_oj_addf occurs 0.
data: gt_dis    like se16n_oj_add_dis occurs 0.

*.Dummy field in the output table
constants: c_line_index type LVC_FNAME value 'LINE_INDEX'.
constants: c_count_index type LVC_FNAME value 'COUNT_INDEX'.
constants: c_sort_index  type LVC_FNAME value 'SE16N_SORT_INDEX'.
constants: c_total_curr_value type LVC_FNAME value 'SE16N_TOTAL_CURR_VALUE'.
constants: c_total_quan_value type LVC_FNAME value 'SE16N_TOTAL_QUAN_VALUE'.

*.constant for edit-mode
constants: c_sap_edit(10) value '&SAP_EDIT'.
constants: c_sap_no_edit(15) value '&SAP_NO_EDIT'.
constants: c_emergency(15) value 'SE16N_EMERGENCY'.

*.constants for no check keys
constants: c_sap_no_check(15) value '&SAP_NO_CHECK'.

*.constants for docked picture
constants: c_sap_picture(15)  value '&SAP_PICTURE'.

*.constant for FDA-Field
constants: c_sap_fda(8)  value '&SAP_FDA'.

*.constant for no buffer of ALV
constants: c_no_buffer(15) value 'NO_BUFFER'.

*.constants for drilldown
constants: c_drilldown_line(1)      value 'L'.
constants: c_drilldown_all(1)       value 'A'.
constants: c_drilldown_line_fcode like sy-ucomm value 'DD_LINE'.
constants: c_drilldown_line_fcode_easy
                                  like sy-ucomm value 'DD_LINE_EASY'.
constants: c_drilldown_line_same_screen like sy-ucomm
                                  value 'DD_LINE_SCREEN'.
constants: c_drilldown_list_same_screen like sy-ucomm
                                  value 'DD_LIST_SCREEN'.
constants: c_drilldown_all_fcode  like sy-ucomm value 'DD_ALL'.
constants: c_rri_search           like sy-ucomm value 'RRI_SEARCH'.
constants: c_navigate_back        like sy-ucomm value 'NAVPRE'.
constants: c_navigate_next        like sy-ucomm value 'NAVNEX'.
constants: c_drilldown_docu       like sy-ucomm value 'DDDOCU'.
constants: c_layout_docu          like sy-ucomm value 'LADOCU'.

*.constant for zebra pattern in ALV
constants: c_zebra(5) value 'ZEBRA'.
constants: c_no_zebra(8) value 'NO_ZEBRA'.

*.constants for dummy variant
constants: c_dummy_vari(10) value 'SE16N#####'.
constants: c_dummy_layo(10) value 'LAYOUT####'.
constants: c_dummy_text(40) value 'Technical Layout used by SAP'.

*.constants for OJ
constants: begin of c_meth,
             variable(10)  value 'VARIABLE',
             input(10)     value 'INPUT',
             constant(10)  value 'CONSTANT',
             reference(10) value 'REFERENCE',
             string(10)    value 'STRING',
             systemvar(10) value 'SYSTEMVAR',
           end of c_meth.

*.Further constants
constants: c_event_check_input type char30 value 'CHECK_INPUT'.
constants: c_s_develop(20) value 'S_DEVELOP'.
constants: c_cd_tab1(12)    value 'SE16N_CD_KEY'.
constants: c_cd_tab2(13)    value 'SE16N_CD_DATA'.
constants: c_cd_tab4(14)    value 'SE16N_CD_DATA2'.
constants: c_cd_tab3(10)    value 'SE16N_EDIT'.
constants: c_3(1)           value '3'.
constants: c_7(1)           value '7'.
constants: c_9(1)           value '9'.
constants: c_max_lines     like sy-tabix value 10000.
constants: c_max_size      like sy-tabix value 1500000000.

*.constants for limitation function
constants: c_limit_def_t type SE16N_ROLE_TYPE value 'T'.
constants: c_limit_def_v type SE16N_ROLE_TYPE value 'V'.

constants: begin of opt,
              i(1)  value 'I',
              e(1)  value 'E',
              bt(2) value 'BT',
              nb(2) value 'NB',
              eq(2) value 'EQ',
              ne(2) value 'NE',
              gt(2) value 'GT',
              ge(2) value 'GE',
              lt(2) value 'LT',
              le(2) value 'LE',
              cp(2) value 'CP',
              np(2) value 'NP',
              n(40) value 'NB,NE',
           end of opt.

constants: begin of auth,
              show(4) value 'SHOW',
              edit(4) value 'EDIT',
           end of auth.

constants: begin of icons,
              eq(50) value 'ICON_EQUAL_#',
              ne(50) value 'ICON_NOT_EQUAL_#',
              gt(50) value 'ICON_GREATER_#',
              lt(50) value 'ICON_LESS_#',
              ge(50) value 'ICON_GREATER_EQUAL_#',
              le(50) value 'ICON_LESS_EQUAL_#',
              bt(50) value 'ICON_INTERVAL_INCLUDE_#',
              nb(50) value 'ICON_INTERVAL_EXCLUDE_#',
              cp(50) value 'ICON_PATTERN_INCLUDE_#',
              np(50) value 'ICON_PATTERN_EXCLUDE_#',
              green(5) value 'GREEN',
              red(3)   value 'RED',
           end of icons.
data: gd_dummy_text like icont-quickinfo.
data: gd_icon_name  like icont-quickinfo.

include lse16nsdt.

include lse16nlcl.
