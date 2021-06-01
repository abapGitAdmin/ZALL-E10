*----------------------------------------------------------------------*
***INCLUDE LGTDISF10 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILL_TC_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_TC_0100.

data: ld_tab     type gtdis_tab.
data: ld_struc   like dcobjdef-name.
data: lt_dfies   like dfies occurs 0 with header line.
data: ls_dd02v   type dd02v.
data: ld_txt_tab type DD08V-TABNAME.
data: ld_fb      like TFDIR-FUNCNAME.
data: bit5       type x value '10'.
data: bit2       type x value '02'.
data: ls_X030L   like X030L.
data: ls_tvdir   like tvdir.
data: ls_tddat   like tddat.
data: l_objs     like objs.
data: lt_dd27p   like dd27p occurs 0 with header line.
data: ld_view    like DD25V-VIEWNAME.
data: ld_dummy_line(10).
statics: sd_parid(1) value ' '.

*..get parameter id's, but only once per call of transaction
   if sd_parid <> true.
      GET PARAMETER ID 'SE16N_TECHNAMES'   FIELD gd-tech_names.
      GET PARAMETER ID 'SE16N_CWIDTH'      FIELD gd-cwidth_opt_off.
      GET PARAMETER ID 'SE16N_SCROLL'      FIELD gd-scroll.
      GET PARAMETER ID 'SE16N_NO_CONVEXIT' FIELD gd-no_convexit.
      GET PARAMETER ID 'SE16N_TECH_FIRST'  FIELD gd-tech_first.
      GET PARAMETER ID 'SE16N_TECH_VIEW'   FIELD gd-tech_view.
      GET PARAMETER ID 'SE16N_LSAVE'       FIELD gd-layout_save.
      GET PARAMETER ID 'SE16N_CDS_NO_SYS'  FIELD gd-cds_no_sys.
      GET PARAMETER ID 'SE16N_DOUBLE_CLICK' FIELD gd-double_click.
      GET PARAMETER ID 'SE16N_COUNT_LINES' FIELD gd-count_lines.
      GET PARAMETER ID 'SE16N_NARROW_COLUMNS' FIELD gd-colopt.
      GET PARAMETER ID 'SE16N_SORTFIELD'   FIELD gd-sortfield.
      GET PARAMETER ID 'SE16N_ADDFIELDS'   FIELD gd-add_fields_cust.
      GET PARAMETER ID 'SE16N_LGET'        FIELD gd-layout_get.
      GET PARAMETER ID 'SE16N_MAXLINES'    FIELD ld_dummy_line.
      GET PARAMETER ID 'SE16N_LAYOUT_DOCKING' FIELD gd-show_layouts.
      GET PARAMETER ID 'SE16N_TEMPERATURE' FIELD gd-temperature.
      if ld_dummy_line > 0.
         gd-max_lines = ld_dummy_line.
      endif.
      sd_parid = true.
   endif.

*..if initial call, set cursor to table (and not to DBCON)
   if gd-tab = space.
     set cursor field 'GD-TAB'.
   endif.

*..Only if tab changed
   check: gd-tab <> gd-tab_save.

   if gd-drilldown is initial.
      clear gd-ojkey.
   endif.
   clear gd-txt_tab.
   clear: gd-no_txt.
   clear: gd-read_clnt, gd-clnt.
   clear: gd-edit, gd-tabedit.
   clear: gd-view.
   clear: gd-formula_name.
   gd-tab_save = gd-tab.
   ld_struc    = gd-Tab.
   gd-uname    = sy-uname.

*..clear extract structure
   clear gd_extract.

*.check if user is a developer, otherwise do not allow client specific
*.display debug should be enough
  authority-check object c_s_Develop
*                    id 'ACTVT'    field '01'
                     id 'ACTVT'    field '03'
                     id 'OBJTYPE'  field 'DEBUG'
                     id 'DEVCLASS' dummy
                     id 'OBJNAME'  dummy
                     id 'P_GROUP'  dummy.
  if sy-subrc <> 0.
     gd-no_clnt_auth = true.
  else.
     clear gd-no_clnt_auth.
  endif.

*..check if table is allowed at all
  SELECT * FROM  DD02L
         WHERE  TABNAME     = GD-TAB
         AND    AS4LOCAL    = 'A'.
     EXIT.
  ENDSELECT.
  IF SY-SUBRC       = 0 AND
     DD02L-MAINFLAG = 'N'.
    MESSAGE I408(MO) WITH GD-TAB.
    CLEAR GD-TAB.
    EXIT.
  ENDIF.

*..Get text from table
   CALL FUNCTION 'DDIF_TABL_GET'
     EXPORTING
       NAME                = gd-tab
*      STATE               = 'A'
       LANGU               = sy-langu
     IMPORTING
*      GOTSTATE            =
       DD02V_WA            = ls_dd02v
     EXCEPTIONS
       ILLEGAL_INPUT       = 1
       OTHERS              = 2.

   IF SY-SUBRC = 0.
      gd_tabl_text = ls_dd02v-ddtext.
   else.
      clear gd_tabl_text.
   ENDIF.
*..get text of View-hierarchies with explicite texts
   if sy-subrc = 0 and
     ls_dd02v-tabclass = 'VIEW'.
     ld_view = gd-tab.
     CALL FUNCTION 'DD_VIEW_GET'
       EXPORTING
         view_name            = ld_view
         WITHTEXT             = 'X'
       TABLES
         DD27P_TAB_A          = lt_dd27p
       EXCEPTIONS
         ACCESS_FAILURE       = 1
         OTHERS               = 2.
     IF sy-subrc <> 0.
* Implement suitable error handling here
     ENDIF.
   endif.

   if gd-drilldown is initial.
     refresh gt_selfields.
     refresh gt_multi.
   endif.
   refresh gt_multi_or_all.
   refresh gt_multi_or.
   refresh gt_or_mul_all.
   refresh gt_or_mul.

   CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
           TABNAME     = LD_struc
      IMPORTING
           X030L_WA    = ls_X030L
      TABLES
           DFIES_TAB   = LT_DFIES
      EXCEPTIONS
           NOT_FOUND   = 1
           OTHERS      = 2.

   check: sy-subrc = 0.

*..table is changeable
   if ls_x030l-flagbyte z bit5.
      gd-edit    = true.
      gd-tabedit = true.
   endif.
*..no maintenance if view exists
   if gd-view = true.
     clear: gd-edit, gd-tabedit.
   endif.
*..no maintenance if only display mode
   if gd-display = true.
     clear: gd-edit, gd-tabedit.
   endif.

*.If table is part of a maintenance view, show push button to jump there
  SELECT SINGLE * FROM TVDIR into ls_tvdir
                             WHERE TABNAME = gd-tab.
  IF SY-SUBRC = 0.
     gd-view = true.
*....look if view is a DDIC-View or a generated one. If it is a
*....DDIC-View I can show it as well
     SELECT * FROM  DD02L
         WHERE  TABNAME     = gd-tab
         AND    AS4LOCAL    = 'A'.
       EXIT.
     ENDSELECT.
     if dd02l-tabclass = 'VIEW'.
        clear gd-ddic_view.
     else.
        gd-ddic_view = true.
     endif.
     MESSAGE S418(mo) WITH gd-tab.
     clear: gd-edit, gd-tabedit.
  ENDIF.

*..check if any kind of maintenance view exists
   select * from objs into l_objs
            where tabname    = gd-tab
              and objecttype = 'V'.
      exit.
   endselect.
   if sy-subrc = 0.
*      if not dd02l-mainflag is initial.
       message s418(mo) with gd-tab.
       clear: gd-edit, gd-tabedit.
*      endif.
   endif.

*..Check if there is a corresponding text table
   perform get_text_table using    gd-tab
                          changing ld_txt_tab.
   if not ld_txt_tab is initial.
      gd-txt_tab = ld_txt_tab.
   endif.

*..do central authority checks independent on where we are
   perform authority_check using gd-tab
                                 'S'
                           changing gd-edit.

*..table is client dependent
   if ls_x030l-flagbyte o bit2.
      gd-clnt = true.
*.....if new table is entered set cursor to first input line
      set cursor field 'GS_SELFIELDS-LOW' line 2.
   else.
*.....if new table is entered set cursor to first input line
      set cursor field 'GS_SELFIELDS-LOW' line 1.
      clear gd-clnt.
   endif.
*..reset table control if the former table was scrolled down
   selfields_tc-top_line     = 1.
   selfields_tc-current_line = 1.

*.if drilldown call gt_selfields is already filled
  if gd-drilldown = space.
   loop at lt_dfies.
*.....the first line is the client (when client dependent)
*     if sy-tabix = 1.
*        if lt_dfies-datatype = 'CLNT'.
*           gd-clnt = true.
*        else.
*           clear gd-clnt.
*        endif.
*     endif.
      clear gt_selfields.
      move-corresponding lt_dfies to gt_selfields.
      if gd-clnt           = true and
         sy-tabix          = 1    and
         lt_dfies-datatype = 'CLNT'.
         gt_selfields-client = true.
      endif.
*.....in case of views with explicite texts, FIELDTEXT might be empty
      if lt_dfies-fieldtext is initial.
        read table lt_dd27p with key viewfield = lt_dfies-fieldname.
        if sy-subrc = 0.
           lt_dfies-fieldtext = lt_dd27p-ddtext.
        endif.
      endif.
      if gt_selfields-scrtext_m is initial.
         gt_selfields-scrtext_m = lt_dfies-fieldtext.
      endif.
*.....multi_or uses Scrtext_l, take care it is filled
      if gt_selfields-scrtext_l is initial.
         gt_selfields-scrtext_l = gt_selfields-scrtext_m.
      endif.
      gt_selfields-mark = true.
      if lt_dfies-keyflag = true.
         gt_selfields-key = true.
      endif.
*.....default sign is inclusive
      gt_selfields-sign = opt-i.

*.....check if user is not allowed for this column
      loop at gt_se16n_role_table into gs_se16n_role_table
          where ( tabname = gd-tab or
                  tabname = '*' )
            and fieldname = gt_selfields-fieldname.
      endloop.
      if sy-subrc <> 0.
        append gt_selfields.
      endif.
*.....get offset for table size
      gd-offset = lt_dfies-offset.
   endloop.

*..check number of lines requested for the table size
   perform check_max_lines using space.

   if not ld_txt_tab is initial.
      gd-txt_tab = ld_txt_tab.
      ld_struc   = ld_txt_tab.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
              TABNAME     = LD_struc
         TABLES
              DFIES_TAB   = LT_DFIES
         EXCEPTIONS
              NOT_FOUND   = 1
              OTHERS      = 2.

       check: sy-subrc = 0.

       loop at lt_dfies where keyflag <> true.
        clear gt_selfields.
        move-corresponding lt_dfies to gt_selfields.
        if gt_selfields-scrtext_m is initial.
           gt_selfields-scrtext_m = lt_dfies-fieldtext.
        endif.
        gt_selfields-mark = true.
        gt_selfields-input = '0'.
*.......check if user is not allowed for some fields
        loop at gt_se16n_role_table into gs_se16n_role_table
            where ( tabname = gd-txt_tab or
                    tabname = '*' )
              and fieldname = gt_selfields-fieldname.
        endloop.
        if sy-subrc <> 0.
           append gt_selfields.
        endif.
       endloop.
   endif.
  endif.

*.in case the caller uses SE16N_START directly, there is the
*.possibility to change the selection fields (inputable)
  if gd-exit_fb_selfields <> space.
     ld_fb = gd-exit_fb_selfields.
     CALL FUNCTION 'RH_FUNCTION_EXIST'
       EXPORTING
         NAME                     = ld_fb
       EXCEPTIONS
         FUNCTION_NOT_FOUND       = 1
         OTHERS                   = 2.
     IF SY-SUBRC = 0.
        call function gd-exit_fb_selfields
          exporting
                i_tab        = gd-tab
          tables
                it_selfields = gt_selfields.
     ENDIF.
  endif.

*.check if exit is active.................................
  if gd-add_fields_cust = true.
     clear: gd-add_field_text,
            gd-add_field_reftab,
            gd-add_field_reffld,
            gd-add_field.
     refresh: gt_cb_events.
     perform read_exit_data using c_event_add_fields.
     if gd-add_fields = true.
*.......call exit for selection screen
        perform check_exit using c_event_add_fields
                                 c_add_info_add_sscr
                                 gd-tab
                           changing gd_dref.
     endif.
  endif.

*.get display variant default...........................................
  clear gd-variant.
  clear gd-varianttext.
  perform fill_variant changing gs_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
      EXPORTING
           I_SAVE         = gd_save
       CHANGING
            CS_VARIANT    = GS_VARIANT
       EXCEPTIONS
            WRONG_INPUT   = 1
            NOT_FOUND     = 2
            PROGRAM_ERROR = 3
            OTHERS        = 4.

*.no variant defined
  if sy-subrc <> 0.
  else.
      gd-variant     = gs_variant-variant.
      gd-varianttext = gs_variant-text.
  endif.

*.in case of hana-mode, no edit at all
  if gd-hana_active = true.
     clear: gd-edit, gd-tabedit.
  endif.
*>>> THIMEL-R, 20170119, Editierfunktion aktivieren
    gd-edit    = abap_true.
    gd-tabedit = abap_true.
    gd-sapedit = abap_true.
*<<< THIMEL-R, 20170119
ENDFORM.                    " FILL_TC_0100
*&---------------------------------------------------------------------*
*&      Form  delete_duplicates
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_OR_SELFIELDS  text
*----------------------------------------------------------------------*
FORM delete_duplicates  TABLES P_IT_OR_SELFIELDS TYPE SE16N_OR_T.

DATA: LS_OR_SELTAB    TYPE SE16N_SELTAB.
DATA: LD_TABIX        LIKE SY-TABIX.
FIELD-SYMBOLS: <F_OR> TYPE SE16N_OR_SELTAB.

   LOOP AT P_IT_OR_SELFIELDS ASSIGNING <F_OR>.
      Sort <F_OR>-SELTAB.
      Delete adjacent duplicates from <F_OR>-SELTAB.
   Endloop.
   refresh: gt_or_selfields.
   gt_or_selfields[] = P_IT_OR_SELFIELDS[].

ENDFORM.                    " delete_duplicates

*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_EXTERN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_SELFIELDS  text
*      <--P_GS_SELFIELDS_LOW  text
*----------------------------------------------------------------------*
FORM CONVERT_TO_EXTERN USING    p_currency type sycurr
                       CHANGING P_Struc structure se16n_selfields
                                p_value like se16n_selfields-low.

DATA: g_util_1 TYPE REF TO cl_fobu_input_util.
data: ls_struc type dfies.

  move-corresponding p_struc to ls_struc.

  if ls_struc-rollname <> space.
*    ls_struc-datatype <> 'DATS'.
    CREATE OBJECT g_util_1
      EXPORTING typename = ls_struc-rollname
                currency = p_currency.
  else.
* note 1823707: replace function call 'SMAN_IF_CONVERT_TO_EXTERN'
* by g_util_1 ... like before in IF case above
    CREATE OBJECT g_util_1
      EXPORTING tabname   = ls_struc-tabname
                fieldname = ls_struc-fieldname
                currency  = p_currency.
  ENDIF.
*....convert to external view, no check table checked
  CALL METHOD g_util_1->output_convert
    EXPORTING
      field_value_int = p_value
    IMPORTING
      field_value_ext = p_value.
ENDFORM.                    " CONVERT_TO_EXTERN

*&---------------------------------------------------------------------*
*&      Form  TAKE_DATA_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TAKE_DATA_SEL.

data: ls_dummy    like se16n_selfields.
data: ld_currency type sycurr.

   READ TABLE GT_SELFIELDS INDEX SELFIELDS_TC-CURRENT_LINE.
*..check that either group or from-to is filled
   if ( gs_selfields-low <> space or
        gs_selfields-high <> space ) and
      gs_selfields-setid <> space.
      message e144(wusl).
   endif.

   gd_save_low  = gs_selfields-low.
   gd_save_high = gs_selfields-high.
*.. When do I have to use INTLEN, when OUTPUTLEN ?
   IF GS_SELFIELDS-LOW <> SPACE and
      GS_SELFIELDS-NO_INPUT_CONVERSION = space.
*.....check if input length is 45 or more
      perform check_input_length using true
                                 changing gs_Selfields-low
                                          gd_length_changed.
*.....as the screen field is upper case sensitive I have to convert
*.....all other fields
      if gt_selfields-lowercase <> true.
         translate gs_Selfields-low to upper case.  "#EC TRANSLANG
      endif.
*.....in case of currency reference, try to get it
      if gt_selfields-reffield <> space and
         gt_selfields-reftable = gt_selfields-tabname.
        read table gt_selfields into ls_dummy
             with key tabname   = gt_selfields-reftable
                      fieldname = gt_selfields-reffield.
        if sy-subrc = 0.
           ld_currency = ls_dummy-low.
        endif.
      endif.
      perform convert_to_intern using    ld_currency
                                changing gt_selfields
                                         gs_selfields-low.
   ENDIF.
   IF GS_SELFIELDS-HIGH <> SPACE and
      GS_SELFIELDS-NO_INPUT_CONVERSION = space.
*.....check if input length is 45 or more
      perform check_input_length using true
                                 changing gs_Selfields-high
                                          gd_length_changed.
*.....as the screen field is upper case sensitive I have to convert
*.....all other fields
      if gt_selfields-lowercase <> true.
         translate gs_Selfields-high to upper case. "#EC TRANSLANG
      endif.
*.....in case of currency reference, try to get it
      if gt_selfields-reffield <> space and
         gt_selfields-reftable = gt_selfields-tabname.
        read table gt_selfields into ls_dummy
             with key tabname   = gt_selfields-reftable
                      fieldname = gt_selfields-reffield.
        if sy-subrc = 0.
           ld_currency = ls_dummy-low.
        endif.
      endif.
      perform convert_to_intern using    ld_currency
                                changing gt_selfields
                                         gs_selfields-high.
   ENDIF.

*..Convert Having-Value the same as low value
   IF GS_SELFIELDS-HAVING_VALUE <> SPACE  and
      GS_SELFIELDS-NO_INPUT_CONVERSION = space.
*.....check if input length is 45 or more
      perform check_input_length using true
                                 changing gs_Selfields-having_value
                                          gd_length_changed.
*.....in case of currency reference, try to get it
      if gt_selfields-reffield <> space and
         gt_selfields-reftable = gt_selfields-tabname.
        read table gt_selfields into ls_dummy
             with key tabname   = gt_selfields-reftable
                      fieldname = gt_selfields-reffield.
        if sy-subrc = 0.
           ld_currency = ls_dummy-low.
        endif.
      endif.
      perform convert_to_intern using    ld_currency
                                changing gt_selfields
                                         gs_selfields-having_value.
   ENDIF.

*..check if low-value greater than high value
*..to only allow CHAR is the easiest solution. Another option would
*..be the coding of the documentation for CREATE DATA - TYPE abap_type
   if gs_selfields-low > gs_selfields-high and
      ( gs_selfields-high <> space         or
        gt_selfields-option = opt-bt       or
        gt_selfields-option = opt-nb )     and
*        gt_selfields-option = opt-nb       or
*        gt_selfields-option = opt-np       or
*        gt_selfields-option = opt-cp )     and
      ( gs_selfields-datatype = 'CHAR' or
        gs_selfields-datatype = 'DATS' or
        gs_selfields-datatype = 'DATN' or
        gs_selfields-datatype = 'LANG' or
        gs_selfields-datatype = 'CUKY' or
        gs_selfields-datatype = 'CLNT' or
        gs_selfields-datatype = 'NUMC' or
        gs_selfields-datatype = 'TIMN' or
*        gs_selfields-datatype = 'CURR' or
        gs_selfields-datatype = 'TIMS' ).
      gs_selfields-low  = gd_save_low.
      gs_selfields-high = gd_save_high.
      message e650(db).
   endif.

*..check the possibility for aggregation
   if GS_SELFIELDS-AGGREGATE <> space.
       if gs_selfields-datatype = 'LCHR' or
          gs_selfields-datatype = 'LRAW'.
          message e146(wusl) with gs_selfields-datatype.
       endif.
   endif.
   case GS_SELFIELDS-AGGREGATE.
     when c_maxf.
     when c_minf.
     when c_avgf.
       if gs_selfields-datatype <> 'DEC' and
*         gs_selfields-datatype <> 'NUMC' and "AVG does not work
          gs_selfields-datatype <> 'CURR' and
          gs_selfields-datatype <> 'QUAN' and
          gs_selfields-datatype(3) <> 'INT'.
         message e145(wusl).
       endif.
   endcase.

*..check that either totalling or grouping is activated
   if gs_selfields-group_by <> space and
      gs_selfields-sum_up   <> space.
      message e147(wusl).
   endif.

*..check that aggregation is only done alone
   if ( gs_selfields-group_by <> space or
        gs_selfields-sum_up   <> space ) and
        gs_selfields-aggregate <> space.
      message e147(wusl).
   endif.

   GT_SELFIELDS-QUAN_ADD_UP = GS_SELFIELDS-QUAN_ADD_UP.
   GT_SELFIELDS-CURR_ADD_UP = GS_SELFIELDS-CURR_ADD_UP.
   GT_SELFIELDS-SUM_UP      = GS_SELFIELDS-SUM_UP.
   GT_SELFIELDS-GROUP_BY    = GS_SELFIELDS-GROUP_BY.
   GT_SELFIELDS-ORDER_BY    = GS_SELFIELDS-ORDER_BY.
   GT_SELFIELDS-TOPLOW      = GS_SELFIELDS-TOPLOW.
   GT_SELFIELDS-SORTORDER   = GS_SELFIELDS-SORTORDER.
*..fill gt_selfields-setid
   if gs_selfields-setid <> space.
      perform check_setid.
   else.
      clear gt_selfields-setid.
   endif.
*   GT_SELFIELDS-SETID       = GS_SELFIELDS-SETID.
   GT_SELFIELDS-AGGREGATE   = GS_SELFIELDS-AGGREGATE.
   GT_SELFIELDS-MARK = GS_SELFIELDS-MARK.
   GT_SELFIELDS-LOW  = GS_SELFIELDS-LOW.
   GT_SELFIELDS-HIGH = GS_SELFIELDS-HIGH.
   GT_SELFIELDS-HAVING_VALUE = GS_SELFIELDS-HAVING_VALUE.
   GT_SELFIELDS-NO_INPUT_CONVERSION = GS_SELFIELDS-NO_INPUT_CONVERSION.
   if gt_selfields-sign = space.
      gt_selfields-sign = opt-i.
   endif.

   MODIFY GT_SELFIELDS INDEX SELFIELDS_TC-CURRENT_LINE.

ENDFORM.                    " TAKE_DATA_SEL

*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_INTERN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_SELFIELDS  text
*      <--P_GS_SELFIELDS_LOW  text
*----------------------------------------------------------------------*
FORM convert_to_intern USING    p_currency type sycurr
                       CHANGING P_struc structure se16n_selfields
                                P_value like se16n_selfields-low.

DATA: g_util_1 TYPE REF TO cl_fobu_input_util.
data: ls_struc type dfies.

  move-corresponding p_struc to ls_struc.

  if ls_struc-rollname <> space.
*    ls_struc-datatype <> 'DATS'.
    CREATE OBJECT g_util_1
      EXPORTING typename = ls_struc-rollname
                currency = p_currency.
  else.
* note 1823707: replace function call 'SMAN_IF_CONVERT_TO_INTERN'
* by g_util_q like before in IF case
    CREATE OBJECT g_util_1
      EXPORTING tabname   = ls_struc-tabname
                fieldname = ls_struc-fieldname
                currency  = p_currency.
  ENDIF.
*....convert to internal view, no check table checked
  CALL METHOD g_util_1->input_convert
    EXPORTING
      field_value_ext   = p_value
    IMPORTING
      field_value_int_c = p_value.
ENDFORM.                    " convert_to_intern

*&---------------------------------------------------------------------*
*&      Form  GET_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_TAB.

data: ld_objtype(1).

*.do not check in case of extended F4
  check: ok_code <> 'F4_EXT'.

  check: gd-tab <> space.

   CALL FUNCTION 'INTERN_DD_TABL_TYPE'
        EXPORTING
             OBJNAME              = gd-tab
*            OBJSTATE             = 'M'
        IMPORTING
             OBJTYPE              = ld_objtype
        EXCEPTIONS
             OTHERS               = 1.

   IF SY-SUBRC = 0.
      if ld_objtype <> 'T' and ld_objtype <> 'V'.
*     if ld_objtype <> 'T'.
         message e001(wusl) with gd-tab ld_objtype.
      endif.
   else.
*.....table does not exist in Dictionary
      message e007(e2) with gd-tab.
   ENDIF.

*.do not allow cluster or pool tables with dbcon
  if gd-dbcon <> space.
     select single tabclass from dd02l into lld_pool
                     where tabname = gd-tab.
     if sy-subrc = 0 and
        ( lld_pool = 'POOL' or
          lld_pool = 'CLUSTER' ).
        clear gd-dbcon.
        message i149(wusl).
     endif.
  endif.

*.check if table exists at all in HANA
  check: gd-tab <> space.
  check: gd-dbcon <> space.
  check: gd-tab ns '*'.

  perform check_hana_table.

ENDFORM.                    " GET_TAB

*&---------------------------------------------------------------------*
*&      Form  EXECUTE_WUSL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXECUTE using value(ld_line_det)
                   value(batch_run)
                   value(variant_save).

data: lt_selfields    like SE16N_SELTAB occurs 0 with header line.
data: lt_output       like se16n_output occurs 0 with header line.
data: lt_curr_add_up  like se16n_output occurs 0 with header line.
data: lt_quan_add_up  like se16n_output occurs 0 with header line.
data: lt_sum_up       like se16n_output occurs 0 with header line.
data: ls_having       like se16n_seltab.
data: lt_having       like se16n_seltab occurs 0 with header line.
data: lt_group_by     like se16n_output occurs 0 with header line.
data: lt_order_by     like se16n_output occurs 0 with header line.
data: lt_toplow       like se16n_seltab occurs 0 with header line.
data: lt_layout_fields type se16n_output_t.
data: ls_layout_fields type se16n_output.
data: ls_selfields    like se16n_selfields.
data: ld_tabix        like sy-tabix.
data: ld_value like se16n_oj_addf-value.
data: ld_one_missing(1).
data: lt_sortorder    like se16n_seltab occurs 0 with header line.
data: lt_values       like rgsb4        occurs 0 with header line.
data: lt_aggregate    like SE16N_SELTAB occurs 0 with header line.
data: lt_or_selfields type SE16N_OR_T.
data: ls_or_selfields type SE16N_OR_SELTAB.
DATA: g_util_1        TYPE REF TO cl_fobu_input_util.

*.check if table is a view or not
  clear gd_exit.
  perform check_tab changing gd_exit.
  if gd_exit = true.
     exit.
  endif.

*.only check layout in case any kind of grouping is used
  LOOP AT gt_selfields INTO ls_selfields
          WHERE group_by  = true
             OR sum_up    = true
             OR order_by  = true
             OR aggregate <> space.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
*.if user has a default layout, check if grouping fields fit to this
*.otherwise the display may look strange
  if gd-hana_active = true and
     not gs_variant-variant is initial and
     ld_line_det is initial and
     batch_run is initial.
     CALL FUNCTION 'SE16N_GET_LAYOUT_FIELDS'
       EXPORTING
*        I_ALV_GRID               =
         I_TABNAME                = gd-tab
       CHANGING
         IS_DISVARIANT            = gs_variant
*        IT_DEFAULT_FCAT          =
         ET_LAYOUT_FIELDS         = lt_layout_fields
       EXCEPTIONS
         LAYOUT_NOT_FOUND         = 1
         FIELDCAT_NOT_FOUND       = 2
         OTHERS                   = 3.

     IF SY-SUBRC = 0.
*......check if all fields of the layout are used by user
       clear ld_one_missing.
       loop at lt_layout_fields into ls_layout_fields.
         read table gt_selfields into ls_selfields
             with key fieldname = ls_layout_fields-field.
*........field is not used by user and would be empty
         if ls_selfields-group_by <> true and
            ls_selfields-sum_up   <> true and
            ls_selfields-order_by <> true and
             ls_selfields-aggregate = space.
            ld_one_missing = true.
         endif.
       endloop.
       if ld_one_missing = true.
         message i148(wusl) with gs_variant-variant.
       endif.
     ENDIF.
    ENDIF.
  endif.

*.if outer join is used, check that all fields from primary table
*.are included in grouping, otherwise there will be no result
  if not gd-ojkey is initial.
*....check if grouping is used, if not all fields will be read
     loop at gt_selfields into ls_selfields
               where group_by = true.
        exit.
     endloop.
     if sy-subrc = 0.
       select value from se16n_oj_addf into ld_value
                   where oj_key   = gd-ojkey
                     and prim_tab = gd-tab
                     and method   = c_meth-reference
                     and ( ref_tab = gd-tab or
                           ref_tab = space ).
         read table gt_selfields into ls_selfields
              with key fieldname = ld_value.
*........add grouping if missing
         if sy-subrc = 0 and
            ls_selfields-group_by <> true.
            ls_selfields-group_by = true.
            modify gt_selfields from ls_selfields index sy-tabix.
         endif.
       endselect.
     endif.
  endif.

  loop at gt_selfields where ( not low  is initial or
                               not high is initial or
                               not option is initial ) and
                               setid is initial.
*....very special case: selection for date 'initial' with input space
     IF ( GT_SELFIELDS-DATATYPE = 'DATS' OR
          GT_SELFIELDS-DATATYPE = 'DATN' ) AND
        GT_SELFIELDS-OPTION   <> SPACE AND
        GT_SELFIELDS-LOW      = SPACE  AND
        GT_SELFIELDS-HIGH     = SPACE.
        DATA: LD_DATE LIKE SY-DATUM.
*.......fill date with initial date
        GT_SELFIELDS-LOW = LD_DATE.
     ENDIF.
     IF ( GT_SELFIELDS-DATATYPE = 'DATS' OR
          GT_SELFIELDS-DATATYPE = 'DATN' ) AND
        GT_SELFIELDS-LOW      = SPACE  AND
        GT_SELFIELDS-HIGH     <> SPACE.
*.......fill date with initial date
        GT_SELFIELDS-LOW = LD_DATE.
     ENDIF.
*....very special case: selection for time 'initial' with input space
     IF GT_SELFIELDS-DATATYPE = 'TIMS' OR
        GT_SELFIELDS-DATATYPE = 'TIMN'.
        DATA: LD_TIMS LIKE SY-TIMLO.
        IF GT_SELFIELDS-OPTION <> SPACE AND
           GT_SELFIELDS-LOW    = SPACE.
*..........fill time with initial time
           GT_SELFIELDS-LOW = LD_TIMS.
        ENDIF.
        IF GT_SELFIELDS-HIGH <> SPACE AND
           GT_SELFIELDS-LOW   = SPACE.
*..........fill time with initial time
           GT_SELFIELDS-LOW = LD_TIMS.
        ENDIF.
     ENDIF.
*....special logic to check whether a RAW-Field needs to be
*....selected with EQ Space
     if gt_selfields-datatype = 'RAW' and
        gt_selfields-option  <> space and
        gt_selfields-low      = space.
        CREATE OBJECT g_util_1
             EXPORTING tabname   = gt_selfields-tabname
                       fieldname = gt_selfields-fieldname.
        CALL METHOD g_util_1->input_convert
             EXPORTING
                       field_value_ext   = space
             IMPORTING
                       field_value_int_c = gt_selfields-low.
     endif.
     clear lt_selfields.
     lt_selfields-field  = gt_selfields-fieldname.
     lt_selfields-low    = gt_selfields-low.
     lt_selfields-high   = gt_selfields-high.
     lt_selfields-sign   = gt_selfields-sign.
     lt_selfields-option = gt_selfields-option.
     append lt_selfields.
*....Search for multiple input
     loop at gt_multi where fieldname = lt_selfields-field
                        and ( not low  is initial or
                              not high is initial or
                              not option is initial ).
        clear lt_selfields.
*....very special case: selection for date 'initial' with input space
        IF ( GT_MULTI-DATATYPE = 'DATS' OR
             GT_MULTI-DATATYPE = 'DATN' ) AND
           GT_MULTI-OPTION   <> SPACE AND
           GT_MULTI-LOW      = SPACE  AND
           GT_MULTI-HIGH     = SPACE.
*..........fill date with initial date
           GT_MULTI-LOW = LD_DATE.
        ENDIF.
        IF ( GT_SELFIELDS-DATATYPE = 'DATS' OR
             GT_SELFIELDS-DATATYPE = 'DATN' ) AND
           GT_SELFIELDS-LOW      = SPACE  AND
           GT_SELFIELDS-HIGH     <> SPACE.
*.......fill date with initial date
           GT_SELFIELDS-LOW = LD_DATE.
        ENDIF.
*....very special case: selection for time 'initial' with input space
        IF GT_MULTI-DATATYPE = 'TIMS' OR
           GT_MULTI-DATATYPE = 'TIMN'.
           IF GT_MULTI-OPTION <> SPACE AND
              GT_MULTI-LOW    = SPACE.
*..........fill time with initial time
              GT_MULTI-LOW = LD_TIMS.
           ENDIF.
           IF GT_MULTI-HIGH <> SPACE AND
              GT_MULTI-LOW   = SPACE.
*..........fill time with initial time
              GT_MULTI-LOW = LD_TIMS.
           ENDIF.
        ENDIF.
*.......special logic to check whether a RAW-Field needs to be
*.......selected with EQ Space
        if gt_selfields-datatype = 'RAW' and
           gt_multi-option      <> space and
           gt_multi-low          = space.
           CREATE OBJECT g_util_1
             EXPORTING tabname   = gt_selfields-tabname
                       fieldname = gt_selfields-fieldname.
           CALL METHOD g_util_1->input_convert
             EXPORTING
                       field_value_ext   = space
             IMPORTING
                       field_value_int_c = gt_multi-low.
        endif.
        lt_selfields-field  = gt_selfields-fieldname.
        if gt_multi-low = c_space and
           gt_multi-option <> space.
           if gt_multi-datatype = 'DATS' OR
              gt_multi-datatype = 'DATN'.
              lt_selfields-low    = ld_date.
           else.
              lt_selfields-low    = space.
           endif.
           lt_selfields-option = gt_multi-option.
           lt_selfields-sign   = gt_multi-sign.
        else.
           lt_selfields-low   = gt_multi-low.
           lt_selfields-high  = gt_multi-high.
           lt_selfields-option = gt_multi-option.
           lt_selfields-sign   = gt_multi-sign.
        endif.
        append lt_selfields.
     endloop.
  endloop.
*.get the values of the defined sets
  loop at gt_selfields where not setid is initial.
*....dissolve set
     CALL FUNCTION 'G_SET_GET_ALL_VALUES'
       EXPORTING
         SETNR                       = gt_selfields-setid
       TABLES
         SET_VALUES                  = lt_values
       EXCEPTIONS
         SET_NOT_FOUND               = 1
         OTHERS                      = 2.
     IF SY-SUBRC = 0.
*....fill set values into selfields
       loop at lt_values.
         clear lt_selfields.
         lt_selfields-field  = gt_selfields-fieldname.
         lt_selfields-low    = lt_values-from.
         lt_selfields-high   = lt_values-to.
         lt_selfields-sign   = gt_selfields-sign.
         lt_selfields-option = gt_selfields-option.
         append lt_selfields.
       endloop.
*....if set does not exist, send message
     else.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
       exit.
     endif.
  endloop.

  loop at gt_selfields where mark = true.
     lt_output-field = gt_selfields-fieldname.
     append lt_output.
  endloop.
  loop at gt_selfields where curr_add_up = true.
     lt_curr_add_up-field = gt_selfields-fieldname.
     append lt_curr_add_up.
  endloop.
  loop at gt_selfields where quan_add_up = true.
     lt_quan_add_up-field = gt_selfields-fieldname.
     append lt_quan_add_up.
  endloop.
  loop at gt_selfields where sum_up = true.
     lt_sum_up = gt_selfields-fieldname.
     append lt_sum_up.
     if gt_selfields-having_value <> space.
       ls_having-field = gt_selfields-fieldname.
       ls_having-low = gt_selfields-having_value.
       if gt_selfields-having_option = space.
         ls_having-option = 'EQ'.
       else.
         ls_having-option = gt_selfields-having_option.
       endif.
       append ls_having to lt_having.
     endif.
  endloop.
*..........................................................
*.if user selected grouping for several fields, goes back,
*.deletes all grouping and wants to display all fields, only the
*.client will be displayed as it was added automatically.
*.Decide whether the client was really manually selected.
*.If not, delete it.
*..........................................................
*.check if there is at least one field other than CLNT
  loop at gt_selfields where group_by  = true
                         and datatype <> 'CLNT'.
     exit.
  endloop.
*.only the client is in grouping
  if sy-subrc <> 0.
*...if client is explicitely wished, leave it
    if gd-read_clnt = true.
*...client was probably added automatically, delete it
    else.
       loop at gt_selfields where group_by = true.
          gt_selfields-group_by = space.
          modify gt_selfields index sy-tabix.
       endloop.
    endif.
  endif.
  loop at gt_selfields where group_by = true.
     lt_group_by = gt_selfields-fieldname.
     append lt_group_by.
  endloop.
*.if grouping is selected, add client as otherwise e.g. text tables
*.cannot be read
  if sy-subrc = 0.
    read table gt_selfields with key datatype = 'CLNT'.
    if sy-subrc = 0.
       gt_selfields-group_by = true.
       modify gt_selfields index sy-tabix.
       lt_group_by = gt_selfields-fieldname.
       collect lt_group_by.
    endif.
  endif.
  loop at gt_selfields where order_by = true.
     ld_tabix = sy-tabix.
     lt_order_by = gt_selfields-fieldname.
     append lt_order_by.
*....check that every order by field is also part of group by
*....but only if no aggregation
     if gt_selfields-aggregate = space and
        gt_selfields-sum_up    = space.
        lt_group_by = gt_selfields-fieldname.
        collect lt_group_by.
        gt_selfields-group_by = true.
        modify gt_selfields index ld_tabix.
     endif.
  endloop.
  loop at gt_selfields where toplow <> space.
     lt_toplow-field = gt_selfields-fieldname.
     lt_toplow-low   = gt_selfields-toplow.
     append lt_toplow.
  endloop.
  loop at gt_selfields where sortorder <> space.
     lt_sortorder-field = gt_selfields-fieldname.
     lt_sortorder-low   = gt_selfields-sortorder.
     append lt_sortorder.
  endloop.
  loop at gt_selfields where aggregate <> space.
     lt_aggregate-field = gt_selfields-fieldname.
     lt_aggregate-low   = gt_selfields-aggregate.
     append lt_aggregate.
  endloop.

*.multi tupel input
  ls_or_selfields-pos = 0.
  append lines of lt_selfields to ls_or_selfields-seltab.
  append ls_or_selfields to lt_or_selfields.
  refresh lt_selfields.

  loop at gt_multi_or_all into gs_multi_or_all.
     refresh: lt_selfields, ls_or_selfields-seltab.
     loop at gs_multi_or_all-selfields into gs_multi_or
                      where ( not low  is initial or
                              not high is initial or
                              not option is initial ).
*....very special case: selection for date 'initial' with input space
        IF gs_multi_or-DATATYPE = 'DATS' AND
           gs_multi_or-OPTION   <> SPACE AND
           gs_multi_or-LOW      = SPACE  AND
           gs_multi_or-HIGH     = SPACE.
*.......fill date with initial date
           gs_multi_or-LOW = LD_DATE.
        ENDIF.
        clear lt_selfields.
        lt_selfields-field  = gs_multi_or-fieldname.
        lt_selfields-low    = gs_multi_or-low.
        lt_selfields-high   = gs_multi_or-high.
        lt_selfields-sign   = gs_multi_or-sign.
        lt_selfields-option = gs_multi_or-option.
        append lt_selfields.
*.......Search for multiple input
        loop at gt_or_mul_all into gs_or_mul_all
                           where pos = gs_multi_or_all-pos.
           loop at gs_or_mul_all-selfields into gs_or_mul
                      where fieldname = lt_selfields-field
                        and ( not low  is initial or
                              not high is initial or
                              not option is initial ).
              clear lt_selfields.
              lt_selfields-field  = gs_multi_or-fieldname.
              if gs_or_mul-low = c_space and
                 gs_or_mul-option <> space.
                 lt_selfields-low  = space.
                 lt_selfields-high = space.
                 lt_selfields-sign   = gs_or_mul-sign.
                 lt_selfields-option = gs_or_mul-option.
              else.
                 lt_selfields-low    = gs_or_mul-low.
                 lt_selfields-high   = gs_or_mul-high.
                 lt_selfields-sign   = gs_or_mul-sign.
                 lt_selfields-option = gs_or_mul-option.
              endif.
              append lt_selfields.
           endloop.
        endloop.
     endloop.
     if sy-subrc = 0.
        ls_or_selfields-pos = gs_multi_or_all-pos.
        append lines of lt_selfields to ls_or_selfields-seltab.
        append ls_or_selfields to lt_or_selfields.
     endif.
  endloop.

  if batch_run = true.
     perform batch_run tables lt_selfields
                              lt_or_selfields
                              lt_output
                              lt_curr_add_up
                              lt_quan_add_up
                              lt_sum_up
                              lt_group_by
                              lt_order_by
                              lt_toplow
                              lt_sortorder
                              lt_aggregate
                              lt_having
                       using  ld_line_det
                              variant_save.
  else.
*>>> THIMEL-R, 20170119, Editierfunktion aktivieren
    gd-edit    = abap_true.
    gd-tabedit = abap_true.
    gd-sapedit = abap_true.
*<<< THIMEL-R, 20170119
     CALL FUNCTION 'SE16N_INTERFACE'
          EXPORTING
            I_TAB            = gd-tab
            I_EDIT           = gd-edit
            i_sapedit        = gd-sapedit
            i_no_txt         = gd-no_txt
            i_max_lines      = gd-max_lines
            i_line_det       = ld_line_det
            i_clnt_spez      = gd-read_clnt
            i_clnt_dep       = gd-clnt
            i_variant        = gd-variant
            i_checkkey       = gd-checkkey
            i_tech_names     = gd-tech_names
            i_cwidth_opt_off = gd-cwidth_opt_off
            i_scroll         = gd-scroll
            i_no_convexit    = gd-no_convexit
            i_layout_get     = gd-layout_get
            i_add_field      = gd-add_field
            i_add_fields_on  = gd-add_fields_on
            i_hana_active    = gd-hana_active
            i_dbcon          = gd-dbcon
            i_ojkey          = gd-ojkey
            i_formula_name   = gd-formula_name
            i_temperature    = gd-temperature
            i_extract_read   = gd_extract-read
            i_extract_write  = gd_extract-write
            i_extract_name   = gd_extract-name
            i_extract_uname  = gd_extract-uname
            i_mincnt         = gd-min_count
            i_fda            = gd-fda
          TABLES
            IT_OR_SELFIELDS       = lt_or_selfields
            IT_OUTPUT_FIELDS      = lt_output
            IT_ADD_UP_CURR_FIELDS = lt_curr_add_up
            IT_ADD_UP_QUAN_FIELDS = lt_quan_add_up
            it_sum_up_fields      = lt_sum_up
            it_having_fields      = lt_having
            it_group_by_fields    = lt_group_by
            it_order_by_fields    = lt_order_by
            it_toplow_fields      = lt_toplow
            it_sortorder_fields   = lt_sortorder
            IT_AGGREGATE_FIELDS   = lt_aggregate.
  endif.

ENDFORM.                    " EXECUTE_WUSL

*&---------------------------------------------------------------------*
*&      Form  FIELD_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0092   text
*----------------------------------------------------------------------*
FORM FIELD_F4 USING value(ld_low).

data: selval       like help_info-fldvalue.
data: valmin       like gs_Selfields-low.
data: valmax       like gs_Selfields-high.
data: return_tab   like ddshretval occurs 0 with header line.
data: ld_curr_line like sy-tabix.
data: begin of f4_dummy,
        tab   like t811c-tab,
        minus(1),
        field like t811k-field,
      end of f4_dummy.

FIELD-SYMBOLS: <selval>.

  get cursor line ld_curr_line.
  ld_curr_line = ld_curr_line + selfields_tc-top_line - 1.
  read table gt_selfields index ld_curr_line.
  check: sy-subrc = 0.

  valmin = gs_selfields-low.
  valmax = gs_selfields-high.

  if ld_low = true.
     assign gs_selfields-low to <selval>.
  else.
     assign gs_selfields-high to <selval>.
  endif.

*----- pass dynp* fields with dummy "X" to trigger ext. F4 help
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
       EXPORTING
            tabname           = gt_selfields-tabname
            fieldname         = gt_Selfields-fieldname
            value             = selval
            selection_screen  = 'X'
            dynpprog          = 'X'
            dynpnr            = 'X'
            dynprofield       = 'X'
       TABLES
            return_tab        = return_tab
       EXCEPTIONS
            FIELD_NOT_FOUND   = 1
            NO_HELP_FOR_FIELD = 2
            INCONSISTENT_HELP = 3
            NO_VALUES_FOUND   = 4
            OTHERS            = 5.
  if sy-subrc = 0.
     clear f4_dummy.
     f4_dummy-tab   = gt_selfields-tabname.
     f4_dummy-minus = '-'.
     f4_dummy-field = gt_Selfields-fieldname.
     condense f4_dummy no-gaps.
     READ TABLE return_tab WITH KEY retfield  = f4_dummy.
     IF sy-subrc = 0.
        <selval> = return_tab-fieldval.
     else.
*.......in some cases the search help does not give back the expected
*.......retfield -> try to read with fieldname
        READ TABLE RETURN_TAB
                WITH KEY FIELDNAME = GT_SELFIELDS-FIELDNAME.
        IF SY-SUBRC = 0.
           <SELVAL> = RETURN_TAB-FIELDVAL.
        ELSE.
           GS_SELFIELDS-LOW  = VALMIN.
           GS_SELFIELDS-HIGH = VALMAX.
        ENDIF.
     ENDIF.
   else.
     gs_selfields-low  = valmin.
     gs_selfields-high = valmax.
   endif.

ENDFORM.                    " FIELD_F4
*&---------------------------------------------------------------------*
*&      Form  FILL_SAP_EDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_SAP_EDIT.

data: ld_subrc1 like sy-subrc.
data: ld_subrc2 like sy-subrc.
data: ld_subrc3 like sy-subrc.
data: ld_on(1)  value ' '.
data: ld_pos         like se16n_edit-pos.
data: ld_sap_edit    type se16n_sap_edit.
data: ld_system_type like sy-sysid.

   check: gd-hana_active <> true.

   call function 'TR_SYS_PARAMS'
           importing
                systemtype = ld_system_type.

   if ld_system_type <> 'SAP'.
*....this function is only allowed for special purposes
     if ld_on <> true.
        exit.
     endif.

*....check against table SE16N_EDIT if &SAP_EDIT is allowed
     select max( pos ) from se16n_edit into (ld_pos).
     if sy-subrc = 0 and not ld_pos is initial.
*.......now get the corresponding entry
        select single se16n_sap_edit from se16n_edit
                        into ld_sap_edit
                    where pos = ld_pos.
        if sy-subrc = 0 and ld_sap_edit <> true.
          message i103(wusl).
          exit.
        endif.
*....not yet an entry in SE16N_EDIT -> do not allow
     else.
        message i103(wusl).
        exit.
     endif.
   endif.

*..only for developers
   authority-check object c_s_Develop
                     id 'ACTVT'    field '01'
                     id 'OBJTYPE'  field 'DEBUG'
                     id 'DEVCLASS' DUMMY
                     id 'OBJNAME'  DUMMY
                     id 'P_GROUP'  DUMMY.
   ld_subrc1 = sy-subrc.
   authority-check object c_s_Develop
                     id 'ACTVT'    field '02'
                     id 'OBJTYPE'  field 'DEBUG'
                     id 'DEVCLASS' DUMMY
                     id 'OBJNAME'  DUMMY
                     id 'P_GROUP'  DUMMY.
   ld_subrc2 = sy-subrc.
   authority-check object c_s_Develop
                     id 'ACTVT'    field '03'
                     id 'OBJTYPE'  field 'DEBUG'
                     id 'DEVCLASS' DUMMY
                     id 'OBJNAME'  DUMMY
                     id 'P_GROUP'  DUMMY.
   ld_subrc3 = sy-subrc.
   if ld_subrc1 = 0 and
      ld_subrc2 = 0 and
      ld_subrc3 = 0.
      gd-edit    = true.
      gd-sapedit = true.
      message s111(wusl).
   else.
      message i103(wusl).
   endif.

*..check if table is allowed or not
   perform check_table_change using gd-tab.

ENDFORM.                    " FILL_SAP_EDIT

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_EDIT  text
*----------------------------------------------------------------------*
FORM AUTHORITY_CHECK USING    i_tab type se16n_tab
                              value(i_caller)
                     CHANGING value(I_EDIT).

data: ls_tddat like tddat.
data: ls_dd02l like dd02l.
data: ld_view_name LIKE  DD25V-VIEWNAME.
data: ld_subrc1 like sy-subrc.
data: ld_subrc2 like sy-subrc.
data: ld_subrc3 like sy-subrc.
data: ld_exit(1).
DATA: SYSEDIT, SYSCLIENTEDIT, SYSCLIINDEPEDIT.
data: ld_no_auth(1).
data: lt_se16n_user_role like se16n_user_role occurs 0.
data: ls_se16n_user_role like se16n_user_role.
data: ls_soex            type txw_c_soex.
data: ls_audit_e         type se16n_role_aud_e.

  gd-auth = auth-show.
  clear ld_exit.

*.check if tax auditor
  CALL FUNCTION 'CA_USER_EXISTS'
      EXPORTING
        i_user       = sy-uname
      EXCEPTIONS
        user_missing = 1.
  IF sy-subrc = 0.
*....never allow changes
    CLEAR: i_edit, gd-tabedit, gd-EDIT, gd-sapedit.
*....check if the table is part of Z3, then allow
    SELECT SINGLE src_struct FROM txw_c_soex
         INTO CORRESPONDING FIELDS OF ls_soex
         WHERE src_struct = i_tab.
    IF sy-subrc <> 0.
*......check if table is part of the additional tables
      SELECT SINGLE tabname FROM se16n_role_aud_e
           INTO CORRESPONDING FIELDS OF ls_audit_e
           WHERE tabname = i_tab.
      IF sy-subrc <> 0.
        SET PARAMETER ID 'DTB' FIELD space.
        PERFORM set_param USING 'DTB' space.
        CALL FUNCTION 'DB_COMMIT'.
        MESSAGE e419(mo) RAISING NO_PERMISSION.
      ENDIF.
    ENDIF.
    gd-tax_audit = true.
  ELSE.
     gd-tax_audit = space.
*.If special sap_edit check special authority
  if i_edit = true and gd-sapedit = true.
     authority-check object c_s_Develop
                     id 'ACTVT'    field '01'
                     id 'OBJTYPE'  field 'DEBUG'
                     id 'DEVCLASS' DUMMY
                     id 'OBJNAME'  DUMMY
                     id 'P_GROUP'  DUMMY.
     ld_subrc1 = sy-subrc.
     authority-check object c_s_Develop
                     id 'ACTVT'    field '02'
                     id 'OBJTYPE'  field 'DEBUG'
                     id 'DEVCLASS' DUMMY
                     id 'OBJNAME'  DUMMY
                     id 'P_GROUP'  DUMMY.
     ld_subrc2 = sy-subrc.
     authority-check object c_s_Develop
                     id 'ACTVT'    field '03'
                     id 'OBJTYPE'  field 'DEBUG'
                     id 'DEVCLASS' DUMMY
                     id 'OBJNAME'  DUMMY
                     id 'P_GROUP'  DUMMY.
     ld_subrc3 = sy-subrc.
*....check if table is allowed or not
     perform check_table_change using i_tab.
     if ld_subrc1 <> 0 or
        ld_subrc2 <> 0 or
        ld_subrc3 <> 0.
        clear: i_edit, gd-tabedit, gd-edit, gd-sapedit.
        message i103(wusl).
     else.
*.......in this case allow everything, because it could be done by debug
        ld_exit = true.
     endif.
  endif.

******************************************************************
  select single * from dd02l into ls_dd02l
                             where tabname = i_tab.

  SELECT SINGLE * FROM TDDAT into ls_tddat
                             WHERE TABNAME = i_tab.
  IF SY-SUBRC <> 0  OR  ls_TDDAT-CCLASS = SPACE.
    ls_TDDAT-CCLASS = '&NC&'.             " 'non classified table'
  ENDIF.

* Anzeigeberechtigung
*  AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
*           ID 'DICBERCLS' FIELD ls_TDDAT-CCLASS
*           ID 'ACTVT' FIELD '03'.
*. new authority check on object S_TABU_NAM...
  ld_view_name = i_tab.
  CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
    EXPORTING
      VIEW_ACTION                          = 'S'  "S=Show
      VIEW_NAME                            = ld_view_name
*     check_action_alternative             = 'X' "note 1538831
*     NO_WARNING_FOR_CLIENTINDEP           = ' '
* CHANGING
*     ORG_CRIT_INST                        =
    EXCEPTIONS
      INVALID_ACTION                       = 1
      NO_AUTHORITY                         = 2
      NO_CLIENTINDEPENDENT_AUTHORITY       = 3
      TABLE_NOT_FOUND                      = 4
      NO_LINEDEPENDENT_AUTHORITY           = 5
      OTHERS                               = 6.
  IF SY-SUBRC NE 0 and
     sy-subrc ne 4.
    set parameter id 'DTB' field space.
    MESSAGE E419(mo) RAISING NO_PERMISSION.
  ENDIF.
*..text table
  if not gd-txt_tab is initial.
     ld_view_name = gd-txt_tab.
     CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
       EXPORTING
         VIEW_ACTION                          = 'S' "S=Show
         VIEW_NAME                            = ld_view_name
*        check_action_alternative             = 'X' "note 1538831
       EXCEPTIONS
         INVALID_ACTION                       = 1
         NO_AUTHORITY                         = 2
         NO_CLIENTINDEPENDENT_AUTHORITY       = 3
         TABLE_NOT_FOUND                      = 4
         NO_LINEDEPENDENT_AUTHORITY           = 5
         OTHERS                               = 6.
     IF sy-subrc <> 0 and
        sy-subrc <> 4.
       " No display authorization for requested data
       MESSAGE E419(mo) RAISING NO_PERMISSION.
     ENDIF.
  endif.

  check: ld_exit <> true.

  if gd-sapedit <> true.
     if i_edit = true.
*.......check if system is changeable
        CALL FUNCTION 'TR_SYS_PARAMS'
            IMPORTING
               SYSTEMEDIT         = SYSEDIT
               SYSTEM_CLIENT_EDIT = SYSCLIENTEDIT
               SYS_CLIINDDEP_EDIT = SYSCLIINDEPEDIT.
        IF SYSEDIT = 'N' AND ls_DD02L-CLIDEP IS INITIAL.
*.......System nicht änderbar für mandantenunabhängig und Repository
           gd-auth = auth-show.
           clear: i_edit, gd-tabedit, gd-edit.
        ENDIF.
        IF SYSCLIENTEDIT = '2' AND NOT ls_DD02L-CLIDEP IS INITIAL.
*.......Mandant nicht änderbar für clientabhängige
           gd-auth = auth-show.
           clear: i_edit, gd-tabedit, gd-edit.
        ENDIF.
       IF NOT SYSCLIINDEPEDIT IS INITIAL AND ls_DD02L-CLIDEP IS INITIAL.
*...Mandantenunabhängige Tabellen sind nicht änderbar, Tabelle is unabh.
          gd-auth = auth-show.
          clear: i_edit, gd-tabedit, gd-edit.
       ENDIF.

*......Änderungsberechtigung
*        AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
*              ID 'DICBERCLS' FIELD ls_TDDAT-CCLASS
*              ID 'ACTVT' FIELD '02'.
*        IF SY-SUBRC = 0.
*          gd-auth = auth-edit.
*        ELSE.
*          IF i_edit = true.
*            clear i_edit.
*            set parameter id 'DTB' field space.
*            MESSAGE E417(mo) RAISING NO_PERMISSION.
*          ENDIF.
*        ENDIF.

*.......new authority check on object S_TABU_NAM...
       ld_view_name = i_tab.
       CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
         EXPORTING
           VIEW_ACTION                          = 'U'  "U=Update
           VIEW_NAME                            = ld_view_name
*          check_action_alternative             = 'X' "note 1538831
           NO_WARNING_FOR_CLIENTINDEP           = 'X'
*        CHANGING
*          ORG_CRIT_INST                        =
         EXCEPTIONS
           INVALID_ACTION                       = 1
           NO_AUTHORITY                         = 2
           NO_CLIENTINDEPENDENT_AUTHORITY       = 3
           TABLE_NOT_FOUND                      = 4
           NO_LINEDEPENDENT_AUTHORITY           = 5
           OTHERS                               = 6.
       IF SY-SUBRC = 0.
          gd-auth = auth-edit.
       ELSE.
          if sy-subrc = 3.
             gd-auth = auth-show.
          endif.
          clear i_edit.
          clear gd-edit.
          clear gd-tabedit.
          set parameter id 'DTB' field space.
          if i_caller = 'S'.
             message i417(mo).
          else.
             MESSAGE E417(mo) RAISING NO_PERMISSION.
          endif.
       ENDIF.
*......text table
       if not gd-txt_tab is initial.
          ld_view_name = gd-txt_tab.
          CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
            EXPORTING
              VIEW_ACTION                          = 'U' "U=Update
              VIEW_NAME                            = ld_view_name
*             check_action_alternative             = 'X' "note 1538831
              NO_WARNING_FOR_CLIENTINDEP           = 'X'
            EXCEPTIONS
              INVALID_ACTION                       = 1
              NO_AUTHORITY                         = 2
              NO_CLIENTINDEPENDENT_AUTHORITY       = 3
              TABLE_NOT_FOUND                      = 4
              NO_LINEDEPENDENT_AUTHORITY           = 5
              OTHERS                               = 6.
          IF SY-SUBRC = 0.
             gd-auth = auth-edit.
          ELSE.
             if sy-subrc = 3.
                gd-auth = auth-show.
             endif.
             clear i_edit.
             clear gd-edit.
             clear gd-tabedit.
             set parameter id 'DTB' field space.
             if i_caller = 'S'.
                message i417(mo).
             else.
                MESSAGE E417(mo) RAISING NO_PERMISSION.
             endif.
          ENDIF.
        endif.

*        IF ls_DD02L-CLIDEP EQ SPACE.
**...... Mandantenunabhängig
*          AUTHORITY-CHECK OBJECT 'S_TABU_CLI'
*                    ID 'CLIIDMAINT' FIELD 'X'.
*          IF SY-SUBRC <> 0.
**.........Keine Berechtigung für mandantenunabhängige Änderungen
*            Gd-auth = auth-show.
*            IF i_edit = true.
*              clear i_edit.
*              set parameter id 'DTB' field space.
*              MESSAGE E417(mo) RAISING NO_PERMISSION.
*            ENDIF.
*          ENDIF.
*        ENDIF.
     endif.
  endif.
  ENDIF. " From Tax Audit user

*.get assignment of user to limitations
  perform role_get_roles tables lt_se16n_user_role.


ENDFORM.                    " AUTHORITY_CHECK

*&---------------------------------------------------------------------*
*&      Form  SHOW_MULTI_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_LINE  text
*----------------------------------------------------------------------*
FORM SHOW_MULTI_SELECT USING value(line).

data: lt_multi like se16n_selfields occurs 0 with header line.
data: ld_lines like sy-tabix.
data: ls_dummy    like se16n_selfields.
data: ld_currency type sycurr.

  read table gt_selfields index line.
  check sy-subrc = 0.

*.Fill the current line into multi popup as well
  if not gt_selfields-low is initial or
     not gt_selfields-high is initial or
     not gt_selfields-option is initial.
     move-corresponding gt_selfields to lt_multi.
     append lt_multi.
  endif.

*.Search for multi selection concerning this field
  loop at gt_multi where fieldname = gt_selfields-fieldname.
     append gt_multi to lt_multi.
  endloop.

*.in case of currency reference, try to get it
  if gt_selfields-reffield <> space and
     gt_selfields-reftable = gt_selfields-tabname.
    read table gt_selfields into ls_dummy
         with key tabname   = gt_selfields-reftable
                  fieldname = gt_selfields-reffield.
    if sy-subrc = 0.
       ld_currency = ls_dummy-low.
    endif.
  endif.

*.Now call popup to enter more values
  CALL FUNCTION 'SE16N_MULTI_FIELD_INPUT'
    EXPORTING
      LS_SELFIELDS          = gt_selfields
      ld_currency           = ld_currency
    TABLES
      LT_MULTI_SELECT       = lt_multi.

*.Now delete the old entries
  delete gt_multi where fieldname = gt_selfields-fieldname.

*.Now search for new ones and fill into buffer
  describe table lt_multi lines ld_lines.
  if ld_lines > 1.
     gt_selfields-push = true.
     read table lt_multi index 1.
     gt_selfields-low  = lt_multi-low.
     gt_selfields-high = lt_multi-high.
     gt_selfields-option = lt_multi-option.
     gt_selfields-sign   = lt_multi-sign.
     modify gt_selfields index line.
     delete lt_multi index 1.
     append lines of lt_multi to gt_multi.
  elseif ld_lines = 1.
     read table lt_multi index 1.
     clear gt_selfields-push.
     gt_selfields-low  = lt_multi-low.
     gt_selfields-high = lt_multi-high.
     gt_selfields-option = lt_multi-option.
     gt_selfields-sign   = lt_multi-sign.
     modify gt_selfields index line.
  else.
     clear gt_selfields-push.
*....user did delete all values!
     clear gt_selfields-low.
     clear gt_selfields-high.
     modify gt_selfields index line.
  endif.

ENDFORM.                    " SHOW_MULTI_SELECT

*&---------------------------------------------------------------------*
*&      Form  FIELD_F4_MULTI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TRUE  text
*----------------------------------------------------------------------*
FORM FIELD_F4_MULTI USING value(ld_low)
                          value(ld_multi).

data: selval       like help_info-fldvalue.
data: valmin       like gs_Selfields-low.
data: valmax       like gs_Selfields-high.
data: return_tab   like ddshretval occurs 0 with header line.
data: ld_curr_line like sy-tabix.
data: ld_tabix     like sy-tabix.
data: begin of f4_dummy,
        tab   like t811c-tab,
        minus(1),
        field like t811k-field,
      end of f4_dummy.

FIELD-SYMBOLS: <selval>.

  get cursor line ld_curr_line.
  ld_curr_line = ld_curr_line + multi_tc-top_line - 1.
  read table gt_multi_select index ld_curr_line.
  check: sy-subrc = 0.

  valmin = gs_multi_select-low.
  valmax = gs_multi_select-high.

  if ld_low = true.
     assign gs_multi_select-low to <selval>.
  else.
     assign gs_multi_select-high to <selval>.
  endif.

*----- pass dynp* fields with dummy "X" to trigger ext. F4 help
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
       EXPORTING
            tabname           = gt_multi_select-tabname
            fieldname         = gt_multi_select-fieldname
            value             = selval
            MULTIPLE_CHOICE   = ld_multi
            selection_screen  = 'X'
            dynpprog          = 'X'
            dynpnr            = 'X'
            dynprofield       = 'X'
       TABLES
            return_tab        = return_tab
       EXCEPTIONS
            FIELD_NOT_FOUND   = 1
            NO_HELP_FOR_FIELD = 2
            INCONSISTENT_HELP = 3
            NO_VALUES_FOUND   = 4
            OTHERS            = 5.
  if sy-subrc = 0.
     clear f4_dummy.
     f4_dummy-tab   = gt_multi_select-tabname.
     f4_dummy-minus = '-'.
     f4_dummy-field = gt_multi_select-fieldname.
     condense f4_dummy no-gaps.
     if ld_multi = true.
        loop at return_tab where retfield = f4_dummy.
           ld_tabix = sy-tabix.
           if ld_low <> true.
              read table gt_multi_select into gs_multi_select
                         index ld_curr_line.
           endif.
           <selval> = return_tab-fieldval.
*..........in case of multi-f4 PBO will be called afterwards, without
*..........doing PAI for the input fields --> input will not be
*..........converted to internal view
           IF <SELVAL> <> SPACE AND
              <SELVAL> <> C_SPACE.
             IF GS_MULTI_SEL-LOWERCASE <> TRUE.
              TRANSLATE GS_MULTI_SELECT-LOW TO UPPER CASE.  "#EC TRANSLANG
             ENDIF.
             PERFORM CONVERT_TO_INTERN USING    gd_currency
                                       CHANGING GT_MULTI_SELECT
                                         <SELVAL>.
           ENDIF.
*.................................................................
           if ld_tabix = 1 or
              ld_low <> true.
              modify gt_multi_select from gs_multi_select
                                   index ld_curr_line.
           else.
              insert gs_multi_select into gt_multi_select
                                   index ld_curr_line.
           endif.
           add 1 to ld_curr_line.
        endloop.
*.......in some cases retfield is not filled correctly by the search
*.......help   > react differently
        if sy-subrc <> 0.
         loop at return_tab where fieldname
                                        = gt_multi_select-fieldname.
           ld_tabix = sy-tabix.
           if ld_low <> true.
              read table gt_multi_select into gs_multi_select
                         index ld_curr_line.
           endif.
           <selval> = return_tab-fieldval.
*..........in case of multi-f4 PBO will be called afterwards, without
*..........doing PAI for the input fields   > input will not be
*..........converted to internal view
           IF <SELVAL> <> SPACE AND
              <SELVAL> <> C_SPACE.
             IF GS_MULTI_SEL-LOWERCASE <> TRUE.
              TRANSLATE GS_MULTI_SELECT-LOW TO UPPER CASE.  "#EC TRANSLANG
             ENDIF.
             PERFORM CONVERT_TO_INTERN USING    gd_currency
                                       CHANGING GT_MULTI_SELECT
                                         <SELVAL>.
           ENDIF.
*.................................................................
           if ld_tabix = 1 or
              ld_low <> true.
              modify gt_multi_select from gs_multi_select
                                   index ld_curr_line.
           else.
              insert gs_multi_select into gt_multi_select
                                   index ld_curr_line.
           endif.
           add 1 to ld_curr_line.
         endloop.
        endif.
     else.
        READ TABLE return_tab WITH KEY retfield  = f4_dummy.
        IF sy-subrc = 0.
           <selval> = return_tab-fieldval.
        else.
*..........in some cases the search help doesn't give back the expected
*..........retfield -> try to read with fieldname
           READ TABLE RETURN_TAB
                WITH KEY FIELDNAME = GT_SELFIELDS-FIELDNAME.
           IF SY-SUBRC = 0.
              <SELVAL> = RETURN_TAB-FIELDVAL.
           ELSE.
              gs_multi_select-low  = valmin.
              gs_multi_select-high = valmax.
           ENDIF.
        ENDIF.
     endif.
   else.
     gs_multi_select-low  = valmin.
     gs_multi_select-high = valmax.
   endif.

ENDFORM.                    " FIELD_F4_MULTI

*&---------------------------------------------------------------------*
*&      Form  ICON_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form icon_create using    ld_icon
                 changing value(push)
                          value(text).

data: ld_icon_name like ICON-NAME.
data: ld_info_text like icont-quickinfo.
data: ld_add_info  LIKE ICON-INTERNAL.
field-symbols: <icon>.

  ld_add_info = true.
  clear ld_info_text.
  clear ld_add_info.

     call function 'ICON_CREATE'
       exporting
            name                  = ld_icon
            info                  = ld_info_text
            add_stdinf            = ld_add_info
       importing
            result                = push
       exceptions
            icon_not_found        = 1
            outputfield_too_short = 2
            others                = 3.
     if sy-subrc <> 0.
        clear push.
     endif.

     ld_icon_name = ld_icon.
     CALL FUNCTION 'ICON_CHECK'
       EXPORTING
         ICON_NAME            = ld_icon_name
         LANGUAGE             = sy-langu
         BUTTON               = ' '
         STATUS               = ' '
         MESSAGE              = ' '
         FUNCTION             = ' '
         TEXTFIELD            = 'X'
         LOCKED               = ' '
       IMPORTING
         ICON_TEXT            = ld_info_text
*        ICON_SIZE            =
*        ICON_ID              =
       EXCEPTIONS
         ICON_NOT_FOUND       = 1
         OTHERS               = 2.

     IF SY-SUBRC = 0.
        text = ld_info_text.
     ENDIF.


endform.
*&---------------------------------------------------------------------*
*&      Form  SET_SEL_OPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SEL_OPTION using kind.

data: ld_curr_line like sy-tabix.
data: ls_selfield  TYPE slis_selfield.
data: lt_fieldcat  TYPE lvc_t_fcat.
data: wa_fieldcat  TYPE LINE OF lvc_t_fcat.
data: ls_outtab    type se16n_sel_option.
data: lt_outtab    type se16n_sel_option occurs 0 with header line.
data: icon_name(40).
data: ld_exit(1).
data: ld_high(1).

*.kind = space = first screen.
*.kind = 'M' = multi select screen

  if kind = 'M'.
     get cursor line ld_curr_line.
     ld_curr_line = ld_curr_line + multi_tc-top_line - 1.
     read table gt_multi_select index ld_curr_line.
     check: sy-subrc = 0.
  else.
     get cursor line ld_curr_line.
  ld_curr_line = ld_curr_line + selfields_tc-top_line - 1.
  read table gt_selfields index ld_curr_line.
  check: sy-subrc = 0.
  endif.

  clear ld_high.
*.If high-value is filled, only a view options are possible
*  loop at gt_multi where fieldname = gt_selfields-fieldname.
*     if not gt_multi-high is initial.
*        ld_high = true.
*        exit.
*     endif.
*  endloop.

*  if not gt_selfields-high is initial.
*     ld_high = true.
*  endif.

*.Makro for creation of ALV-output-table
  define makro_sel_output.
    ls_outtab-sign   = &1.
    ls_outtab-option = &2.
    perform get_icon_name using    ls_outtab-sign
                                   ls_outtab-option
                          changing icon_name.
    perform icon_create using    icon_name
                        changing ls_outtab-icon
                                 gd_dummy_text.
    ls_outtab-text   = gd_dummy_text.
    append ls_outtab to lt_outtab.
  end-of-definition.

  if ld_high = true.
     makro_sel_output opt-i opt-bt.
     makro_sel_output opt-i opt-nb.
     makro_sel_output opt-e opt-bt.
     makro_sel_output opt-e opt-nb.
  else.
     makro_sel_output opt-i opt-bt.
     makro_sel_output opt-i opt-cp.
     makro_sel_output opt-i opt-np.
     makro_sel_output opt-i opt-eq.
     makro_sel_output opt-i opt-nb.
     makro_sel_output opt-i opt-ne.
     makro_sel_output opt-i opt-gt.
     makro_sel_output opt-i opt-lt.
     makro_sel_output opt-i opt-ge.
     makro_sel_output opt-i opt-le.
     makro_sel_output opt-e opt-bt.
     makro_sel_output opt-e opt-cp.
     makro_sel_output opt-e opt-np.
     makro_sel_output opt-e opt-eq.
     makro_sel_output opt-e opt-nb.
     makro_sel_output opt-e opt-ne.
     makro_sel_output opt-e opt-gt.
     makro_sel_output opt-e opt-lt.
     makro_sel_output opt-e opt-ge.
     makro_sel_output opt-e opt-le.
  endif.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_BUFFER_ACTIVE              = ' '
      I_STRUCTURE_NAME             = 'SE16N_SEL_OPTION'
*     I_CLIENT_NEVER_DISPLAY       = 'X'
*     I_BYPASSING_BUFFER           =
    CHANGING
      CT_FIELDCAT                  = lt_fieldcat
    EXCEPTIONS
      INCONSISTENT_INTERFACE       = 1
      PROGRAM_ERROR                = 2
      OTHERS                       = 3.

  IF SY-SUBRC <> 0.
     exit.
  ENDIF.

  loop at lt_fieldcat into wa_fieldcat.
     case wa_fieldcat-fieldname.
       when 'SIGN'.
          wa_fieldcat-no_out = true.
       when 'OPTION'.
          wa_fieldcat-no_out = true.
       when 'ICON'.
          wa_fieldcat-outputlen = 2.
     endcase.
     modify lt_fieldcat from wa_fieldcat.
  endloop.

*.exclude select-options
  loop at gt_excl_selopt.

*...no selopt at all
    if gt_excl_selopt-sign   = '*' and
       gt_excl_selopt-option = '*'.
      return.

*...restrict by option
    elseif gt_excl_selopt-sign = '*'.
      delete lt_outtab where option = gt_excl_selopt-option.

*...restrict by sign
    elseif gt_excl_selopt-option = '*'.
      delete lt_outtab where sign = gt_excl_selopt-sign.

*...restrict by sign and option
    else.
      delete lt_outtab where sign   = gt_excl_selopt-sign and
                             option = gt_excl_selopt-option.
    endif.

  endloop.

*.Show popup with the options and give one back
  CALL FUNCTION 'LVC_SINGLE_ITEM_SELECTION'
    EXPORTING
      I_TITLE                       = text-opt
*     I_SCREEN_START_COLUMN         = 0
*     I_SCREEN_START_LINE           = 0
*     I_SCREEN_END_COLUMN           = 0
*     I_SCREEN_END_LINE             = 0
*     I_LINEMARK_FIELDNAME          =
      IT_FIELDCATALOG               = lt_fieldcat
*     I_CALLBACK_PROGRAM            =
*     I_CALLBACK_USER_COMMAND       =
*     IT_STATUS_EXCL                =
    IMPORTING
      ES_SELFIELD                   = ls_selfield
      E_EXIT                        = ld_exit
    TABLES
      T_OUTTAB                      = lt_outtab.

  if ld_exit <> true.
     READ TABLE lt_outtab INTO ls_outtab
              INDEX ls_selfield-tabindex.
     if sy-subrc = 0.
        if kind = space.
           gt_selfields-sign   = ls_outtab-sign.
           gt_selfields-option = ls_outtab-option.
*..........GT_sel_init contains info if low and/or high are allowed for
*..........the selected option
        read table gt_sel_init with key option = ls_outtab-option.
        if sy-subrc = 0.
           if gt_sel_init-high <> true.
              clear gt_selfields-high.
*                 loop at gt_multi where fieldname = gt_selfields-fieldname.
*                    clear gt_multi-high.
*                    modify gt_multi.
*                 endloop.
           endif.
        endif.
        modify gt_selfields index ld_curr_line.
        else.
           gt_multi_select-sign   = ls_outtab-sign.
           gt_multi_select-option = ls_outtab-option.
*..........GT_sel_init contains info if low and/or high are allowed for
*..........the selected option
           read table gt_sel_init with key option = ls_outtab-option.
           if sy-subrc = 0.
              if gt_sel_init-high <> true.
                 clear gt_multi_select-high.
              endif.
           endif.
           modify gt_multi_select index ld_curr_line.
        endif.
     endif.
  endif.

ENDFORM.                    " SET_SEL_OPTION

*&---------------------------------------------------------------------*
*&      Form  GET_ICON_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_SELFIELDS  text
*      <--P_ICON_NAME  text
*----------------------------------------------------------------------*
FORM GET_ICON_NAME USING    value(sign)
                            value(option)
                   CHANGING value(icon_name).

  case option.
    when opt-bt.
      icon_name = icons-bt.
    when opt-nb.
      icon_name = icons-nb.
    when opt-eq.
      icon_name = icons-eq.
    when opt-ne.
      icon_name = icons-ne.
    when opt-gt.
      icon_name = icons-gt.
    when opt-lt.
      icon_name = icons-lt.
    when opt-ge.
      icon_name = icons-ge.
    when opt-le.
      icon_name = icons-le.
    when opt-cp.
      icon_name = icons-cp.
    when opt-np.
      icon_name = icons-np.
  endcase.
  if sign = opt-i or
     sign = space.
    replace '#' with icons-green into icon_name.
  else.
    replace '#' with icons-red into icon_name.
  endif.

ENDFORM.                    " GET_ICON_NAME
*&---------------------------------------------------------------------*
*&      Form  init_sel_opt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_sel_opt.

*.for every possible select option either the low or(and) the high field
*.is inputable
  refresh gt_sel_init.
  define makro_init.
     clear gt_sel_init.
     gt_sel_init-option = &1.
     gt_sel_init-low    = &2.
     gt_sel_init-high   = &3.
     append gt_sel_init.
  end-of-definition.

  makro_init opt-eq true space.
  makro_init opt-ne true space.
  makro_init opt-bt true true.
  makro_init opt-nb true true.
  makro_init opt-gt true space.
  makro_init opt-lt true space.
  makro_init opt-ge true space.
  makro_init opt-le true space.

ENDFORM.                    " init_sel_opt
*&---------------------------------------------------------------------*
*&      Form  view_maint
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM view_maint.

DATA: BEGIN OF SLIST OCCURS 10.
        INCLUDE STRUCTURE VIMSELLIST.
DATA: END OF SLIST.
DATA: BEGIN OF ECODE OCCURS 10.
        INCLUDE STRUCTURE VIMEXCLFUN.
DATA: END OF ECODE.

      call function 'AUTHORITY_CHECK_TCODE'
            exporting
                 tcode  = 'SM30'
            exceptions
                 ok     = 0
                 not_ok = 1.
      if sy-subrc ne 0.
         message e059(eu) with 'SM30'.   " keine Berechtigung
      endif.
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
           EXPORTING
               ACTION                         = 'S'
*              corr_number                    = '          '
*              generate_maint_tool_if_missing = ' '
*              show_selection_popup           = ' '
               VIEW_NAME                      = gd-tab
               CHECK_DDIC_MAINFLAG            = 'X'        "n'1148568
           TABLES
               DBA_SELLIST                    =  SLIST
               EXCL_CUA_FUNCT                 =  ECODE
           EXCEPTIONS OTHERS.
      IF SY-SUBRC NE 0.
         MESSAGE E404(mo) WITH gd-tab.
  endif.

ENDFORM.                    " view_maint
*&---------------------------------------------------------------------*
*&      Form  delete_cd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_cd.

data: lt_se16n_cd_key  like se16n_cd_key  occurs 0 with header line.
data: lt_se16n_cd_data like se16n_cd_data occurs 0 with header line.
data: ld_lines like sy-tabix.
data: ld_datlo like sy-datlo.
data: ld_sdate like sy-datlo.
data: ld_edate like sy-datlo.
data: ld_answer(1).

   exit.

*..check if user really has strong authority
   authority-check object 'S_ADMI_FCD'
*                  id     'SYSTEMADMINISTRATIONSFUNKTION'
                   id     'S_ADMI_FCD'
                   field  'RSET'.
   if sy-subrc <> 0.
      MESSAGE i104(wusl).
      exit.
   ENDIF.

*..current day minus one week
   ld_datlo = sy-datlo - 7.
   CALL FUNCTION 'SE16N_GET_DATE_INTERVAL'
     EXPORTING
       I_SDATE        = ld_Datlo
       I_EDATE        = ld_Datlo
     IMPORTING
       E_SDATE        = ld_sdate
       E_EDATE        = ld_edate
     EXCEPTIONS
       CANCELED       = 1
       OTHERS         = 2.

   IF SY-SUBRC <> 0.
      exit.
   ENDIF.
   select * from se16n_cd_key into table lt_se16n_cd_key
                                 where sdate >= ld_sdate
                                   and sdate <= ld_edate.
   if sy-subrc = 0.
      select * from se16n_cd_data into table lt_se16n_cd_data
                  for all entries in lt_se16n_cd_key
                      where id = lt_se16n_cd_key-id.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
           EXPORTING
             DEFAULTOPTION        = 'Y'
             TEXTLINE1            = text-de1
             TITEL                = text-cdd
           IMPORTING
             ANSWER               = ld_answer.
      if ld_answer = 'Y' or
            ld_answer = 'J'.
            delete se16n_cd_key  from table lt_se16n_cd_key.
            ld_lines = sy-dbcnt.
            delete se16n_cd_data from table lt_se16n_cd_data.
            ld_lines = ld_lines + sy-dbcnt.
            commit work.
            CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
                 EXPORTING
                   DEFAULTOPTION        = 'Y'
                   TEXTLINE1            = text-anz
                   TEXTLINE2            = ld_lines
                   TITEL                = text-001.
      endif.
   else.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
              EXPORTING
                   DEFAULTOPTION        = 'Y'
                   TEXTLINE1            = text-not
*                  TEXTLINE2            = ld_lines
                   TITEL                = text-no2.
   endif.

ENDFORM.                    " delete_cd
*&---------------------------------------------------------------------*
*&      Form  batch_run
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM batch_run tables lt_selfields structure se16n_seltab
                      lt_or_selfields type SE16N_OR_T
                      lt_output    structure se16n_output
                      lt_curr_add_up structure se16n_output
                      lt_quan_add_up structure se16n_output
                      lt_sum_up      structure se16n_output
                      lt_group_by    structure se16n_output
                      lt_order_by    structure se16n_output
                      lt_toplow      structure se16n_seltab
                      lt_sortorder   structure se16n_seltab
                      lt_aggregate   structure se16n_seltab
                      lt_having      structure se16n_seltab
               using  value(line_det)
                      value(variant_save).

*tables: indx.
DATA: BEGIN OF itab_selpa OCCURS 0.
        INCLUDE STRUCTURE kaba00.
DATA: END OF itab_selpa.
DATA: BEGIN OF print_parameters.
        INCLUDE STRUCTURE pri_params.
DATA: END OF print_parameters.
DATA: BEGIN OF arc_parameters.
        INCLUDE STRUCTURE arc_params.
DATA: END OF arc_parameters.
DATA: pp_valid TYPE c.
DATA: BATCH_REPORT LIKE SY-REPID.
data: PAR_PNAME    LIKE  TBTCJOB-INTREPORT.
data: lt_hugo      type SE16N_OR_T.
data: begin of indxkey,
        fix(5) value 'SE16N',
        guid(15),
end of indxkey.
data: ld_guid type timestamp.

  if variant_save <> true.
     CALL FUNCTION 'GET_PRINT_PARAMETERS'
           EXPORTING
                line_count     = 65
                line_size      = 132
                no_dialog      = ' '
                mode           = 'CURRENT'
           IMPORTING
                out_parameters         = print_parameters
                out_archive_parameters = arc_parameters
                valid                  = pp_valid.
     IF pp_valid = space.               " exit on user request
        EXIT.
     ENDIF.
  endif.

*.get a GUID to make every export unique (in case more than one batch
*.run at a time)
*.if the same GUID has already been created, do an endless loop
  do.
    GET TIME STAMP FIELD ld_guid.
    indxkey-guid = ld_guid.
    import lt_hugo from database indx(al) id indxkey.
    if sy-subrc <> 0.
       exit.
    endif.
    wait up to 1 seconds.
  enddo.
  export lt_or_selfields to database indx(al) id indxkey.

  clear itab_selpa.
  MOVE 'I_GUID' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = indxkey-guid.
  append itab_selpa.

  CLEAR itab_selpa.
  MOVE 'LT_OUT' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'S'      TO: itab_selpa-type.
  LOOP AT lt_output.
    itab_selpa-low = lt_output.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_CURR' TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'EQ'      TO: itab_selpa-option.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_curr_add_up.
    itab_selpa-low = lt_curr_add_up.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_QUAN' TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'EQ'      TO: itab_selpa-option.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_quan_add_up.
    itab_selpa-low = lt_quan_add_up.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_SUM'  TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'EQ'      TO: itab_selpa-option.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_sum_up.
    itab_selpa-low = lt_sum_up.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_GRP'  TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'EQ'      TO: itab_selpa-option.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_group_by.
    itab_selpa-low = lt_group_by.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_ORD'  TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'EQ'      TO: itab_selpa-option.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_order_by.
    itab_selpa-low = lt_order_by.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_TOP'  TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'EQ'      TO: itab_selpa-option.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_toplow.
    itab_selpa-low = lt_toplow-field.
    case lt_toplow-low.
      when 'ASC'.
        MOVE c_asc TO: itab_selpa-option.
      when 'DES'.
        MOVE c_des TO: itab_selpa-option.
    endcase.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_SOR'  TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'EQ'      TO: itab_selpa-option.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_sortorder.
    itab_selpa-low = lt_sortorder-field.
    move lt_sortorder-low TO: itab_selpa-option.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_HAV'  TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'EQ'      TO: itab_selpa-option.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_having.
    itab_selpa-low    = lt_having-field.
    itab_selpa-option = lt_having-option.
    itab_selpa-high   = lt_having-low.
    APPEND itab_selpa.
  ENDLOOP.

  CLEAR itab_selpa.
  MOVE 'LT_AGG'  TO: itab_selpa-field.
  MOVE 'I'       TO: itab_selpa-sign.
  MOVE 'S'       TO: itab_selpa-type.
  LOOP AT lt_aggregate.
    itab_selpa-low = lt_aggregate-field.
    case lt_aggregate-low.
      when 'MAX'.
        MOVE c_max TO: itab_selpa-option.
      when 'MIN'.
        MOVE c_min TO: itab_selpa-option.
      when 'AVG'.
        MOVE c_avg TO: itab_selpa-option.
    endcase.
    APPEND itab_selpa.
  ENDLOOP.

  clear itab_selpa.
  MOVE 'I_LINE' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = line_det.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_TAB' TO: itab_selpa-field.
  MOVE 'I'     TO: itab_selpa-sign.
  MOVE 'EQ'    TO: itab_selpa-option.
  MOVE 'P'     TO: itab_selpa-type.
  itab_selpa-low = gd-tab.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_NO_TXT' TO: itab_selpa-field.
  MOVE 'I'        TO: itab_selpa-sign.
  MOVE 'EQ'       TO: itab_selpa-option.
  MOVE 'P'        TO: itab_selpa-type.
  itab_selpa-low = gd-no_txt.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_MAX' TO: itab_selpa-field.
  MOVE 'I'     TO: itab_selpa-sign.
  MOVE 'EQ'    TO: itab_selpa-option.
  MOVE 'P'     TO: itab_selpa-type.
  write gd-max_lines to itab_selpa-low left-justified no-grouping.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_CLNT' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-read_clnt.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_VARI' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-variant.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_TECH' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-tech_names.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_CWID' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-cwidth_opt_off.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_ROLL' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-scroll.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_CONV' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-no_convexit.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_LGET' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-layout_get.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_ADD_F' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-add_field.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_ADD_ON' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-add_fields_on.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_UNAME' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = sy-uname.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_HANA'  TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-hana_active.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_DBCON' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-dbcon.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_OJKEY' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-ojkey.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_MINCNT' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  write gd-min_count to itab_selpa-low left-justified no-grouping.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_FDA'   TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd-fda.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_FORMUL' TO: itab_selpa-field.
  MOVE 'I'        TO: itab_selpa-sign.
  MOVE 'EQ'       TO: itab_selpa-option.
  MOVE 'P'        TO: itab_selpa-type.
  itab_selpa-low = gd-formula_name.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_EXREAD' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd_extract-read.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_EXWRIT' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd_extract-write.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_EXNAME' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd_extract-name.
  append itab_selpa.
  clear itab_selpa.
  MOVE 'I_EXUNAM' TO: itab_selpa-field.
  MOVE 'I'      TO: itab_selpa-sign.
  MOVE 'EQ'     TO: itab_selpa-option.
  MOVE 'P'      TO: itab_selpa-type.
  itab_selpa-low = gd_extract-uname.
  append itab_selpa.

  if variant_save <> true.
     CALL FUNCTION 'K_BATCH_REQUEST'
         EXPORTING
              par_dialg                 = true
              par_nsm37                 = ' '
*             par_pname                 = 'SE16N_BATCH_START'
*             par_pname                 = par_pname   "will be generated
              par_print                 = ' '
              par_pripa                 = print_parameters
              par_arcpa                 = arc_parameters
              par_rname                 = 'SE16N_BATCH'
*             par_rname                 = batch_report "Report to be run
              par_sdmsg                 = true
              par_abend                 = true
         TABLES
              tab_selpa                 = itab_selpa.
  else.
*.save a variant that can be used in SM36 to create job chains
     perform save_batch_variant tables itab_selpa.
  endif.

ENDFORM.                    " batch_run
*&---------------------------------------------------------------------*
*& Form f4_having_option
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_having_option .

DATA: ld_curr_line LIKE sy-tabix.
DATA: ls_selfield  TYPE slis_selfield.
DATA: lt_fieldcat  TYPE lvc_t_fcat.
DATA: wa_fieldcat  TYPE LINE OF lvc_t_fcat.
DATA: ls_outtab    TYPE se16n_sel_option.
DATA: lt_outtab    TYPE se16n_sel_option OCCURS 0 WITH HEADER LINE.
DATA: icon_name(40).
DATA: ld_exit(1).
DATA: ld_high(1).

  GET CURSOR LINE ld_curr_line.
  ld_curr_line = ld_curr_line + selfields_tc-top_line - 1.
  READ TABLE gt_selfields INDEX ld_curr_line.
  CHECK: sy-subrc = 0.

*.Makro for creation of ALV-output-table
  DEFINE makro_sel_output.
    ls_outtab-SIGN   = &1.
    ls_outtab-option = &2.
    PERFORM get_icon_name USING    ls_outtab-SIGN
          ls_outtab-option
    CHANGING icon_name.
    PERFORM icon_create USING    icon_name
    CHANGING ls_outtab-ICON
      gd_dummy_text.
    ls_outtab-TEXT   = gd_dummy_text.
    APPEND ls_outtab TO lt_outtab.
  END-OF-DEFINITION.

  makro_sel_output opt-I opt-EQ.
  makro_sel_output opt-I opt-NE.
  makro_sel_output opt-I opt-GT.
  makro_sel_output opt-I opt-LT.
  makro_sel_output opt-I opt-GE.
  makro_sel_output opt-I opt-LE.


  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
  EXPORTING
    I_BUFFER_ACTIVE              = ' '
    I_STRUCTURE_NAME             = 'SE16N_SEL_OPTION'
*     I_CLIENT_NEVER_DISPLAY       = 'X'
*     I_BYPASSING_BUFFER           =
  CHANGING
    CT_FIELDCAT                  = lt_fieldcat
  EXCEPTIONS
    INCONSISTENT_INTERFACE       = 1
    PROGRAM_ERROR                = 2
    OTHERS                       = 3.

  IF SY-SUBRC <> 0.
    EXIT.
  ENDIF.

  LOOP AT lt_fieldcat INTO wa_fieldcat.
    CASE wa_fieldcat-fieldname.
    WHEN 'SIGN'.
      wa_fieldcat-no_out = true.
    WHEN 'OPTION'.
      wa_fieldcat-no_out = true.
    WHEN 'ICON'.
      wa_fieldcat-outputlen = 2.
    ENDCASE.
    MODIFY lt_fieldcat FROM wa_fieldcat.
  ENDLOOP.

*.exclude select-options
  LOOP AT gt_excl_selopt.

*...no selopt at all
    IF gt_excl_selopt-SIGN   = '*' AND
    gt_excl_selopt-option = '*'.
      RETURN.

*...restrict by option
    ELSEIF gt_excl_selopt-SIGN = '*'.
      DELETE lt_outtab WHERE option = gt_excl_selopt-option.

*...restrict by sign
    ELSEIF gt_excl_selopt-option = '*'.
      DELETE lt_outtab WHERE SIGN = gt_excl_selopt-SIGN.

*...restrict by sign and option
    ELSE.
      DELETE lt_outtab WHERE SIGN   = gt_excl_selopt-SIGN AND
      option = gt_excl_selopt-option.
    ENDIF.

  ENDLOOP.

*.Show popup with the options and give one back
  CALL FUNCTION 'LVC_SINGLE_ITEM_SELECTION'
  EXPORTING
    I_TITLE                       = TEXT-opt
    IT_FIELDCATALOG               = lt_fieldcat
  IMPORTING
    ES_SELFIELD                   = ls_selfield
    E_EXIT                        = ld_exit
  TABLES
    T_OUTTAB                      = lt_outtab.

  IF ld_exit <> true.
    READ TABLE lt_outtab INTO ls_outtab
    INDEX ls_selfield-tabindex.
    IF sy-subrc = 0.
      gt_selfields-having_option = ls_outtab-option.
      MODIFY gt_selfields INDEX ld_curr_line.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  end
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM end.

data: ls_layout       type LVC_S_LAYO.
data: lt_fieldcatalog type lvc_t_fcat.
data: lt_filter       type LVC_T_FILT.
data: lt_sort         type LVC_T_SORT.

   IF gd-layout_save = true and
      sy-dynnr       = '0200'.
*..in case no variant is set, save a temporary one to hold the settings
*..in case of refresh or new run.
      if gs_variant-variant = space.
         gs_variant-variant = c_dummy_vari.
         gs_variant-text    = c_dummy_vari.
         CALL METHOD alv_grid->GET_FRONTEND_FIELDCATALOG
            IMPORTING
              ET_FIELDCATALOG = lt_fieldcatalog.
         CALL METHOD alv_grid->GET_FRONTEND_LAYOUT
            IMPORTING
              ES_LAYOUT = ls_layout.
         CALL METHOD alv_grid->GET_FILTER_CRITERIA
            IMPORTING
              ET_FILTER = lt_filter.
         CALL METHOD ALV_GRID->GET_SORT_CRITERIA
            IMPORTING
              ET_SORT = lt_sort.
         CALL METHOD alv_grid->SET_FRONTEND_FIELDCATALOG
           EXPORTING
             IT_FIELDCATALOG = lt_fieldcatalog.
         CALL METHOD alv_grid->SET_FRONTEND_LAYOUT
           EXPORTING
             IS_LAYOUT = ls_layout.
         CALL METHOD alv_grid->SET_FILTER_CRITERIA
            EXPORTING
              IT_FILTER = lt_filter.
         CALL METHOD ALV_GRID->SET_SORT_CRITERIA
            EXPORTING
              IT_SORT = lt_sort.
         CALL METHOD ALV_GRID->SET_VARIANT
             EXPORTING IS_variant = gs_variant
                       I_SAVE     = gd_save.
         CALL METHOD ALV_GRID->SAVE_VARIANT
             EXPORTING I_DIALOG = space.
         clear gs_variant-variant.
         clear gs_variant-text.
      endif.
   ENDIF.

*..Dequeue all locks on DB
   CALL FUNCTION 'DEQUEUE_ALL'.
*..clear all tables that have got changes
   refresh: gt_mod.
   if <all_table_save> is assigned.
      refresh <all_table_save>.
   endif.
   if <all_table> is assigned.
      refresh <all_table>.
   endif.
   if <del_table> is assigned.
      refresh <del_table>.
   endif.
   if <key_table> is assigned.
      refresh <key_table>.
   endif.
*..drilldown flags have to be reset
   clear: gd-drilldown.

*...clear ABAP-Display
   IF NOT gd_abap_dock IS INITIAL.
     CALL METHOD gd_abap_dock->set_visible
       EXPORTING
       visible = gd_abap_dock_active.
     CALL METHOD gd_abap_text->free.
     CALL METHOD gd_abap_dock->free.
     CLEAR gd_abap_dock.
     CLEAR gd_abap_text.
     CLEAR gd_abap_dock_active.
   ENDIF.

ENDFORM.                    " end
*&---------------------------------------------------------------------*
*&      Form  f4_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GD_TAB  text
*----------------------------------------------------------------------*
FORM f4_tab changing value(TAB).

data: eutype    LIKE RSEDD0-DDOBJTYPE value 'T'.
data: value_tab like dd02v-tabname.
data: variant(14).
DATA: SHOW_MODE LIKE SY-INPUT.
DATA: T_VARIANT(14).
DATA: BEGIN OF dynpfields OCCURS 1.
      INCLUDE STRUCTURE dynpread.
DATA: END OF dynpfields.
data: lt_tax_tab type table of tabname.
data: begin of tax_tab occurs 0,
        value type tabname,
        text  type as4text,
      end of tax_tab.
data: retfield        like dfies-fieldname value 'VALUE'.
data: return_tab      like DDSHRETVAL occurs 0 with header line.

*..no F4 in case of single-tab mode
   check: gd-single_tab <> true.

*.read DBCON if not yet in PAI
  if gd-hana_active = true and
     sy-dynnr <> '0601' and
     sy-dynnr <> '0602'.
    CLEAR dynpfields.
    REFRESH dynpfields.
    dynpfields-fieldname  = 'GD-DBCON'.
    APPEND dynpfields.
    CALL FUNCTION 'DYNP_VALUES_READ'
     EXPORTING
       DYNAME                         = 'SAPLSE16N'
       DYNUMB                         = sy-dynnr
       TRANSLATE_TO_UPPER             = true
     TABLES
       DYNPFIELDS                     = dynpfields.
    read table dynpfields index 1.
    gd-dbcon = dynpfields-fieldvalue.
*...read field tab
    CLEAR dynpfields.
    REFRESH dynpfields.
    if sy-dynnr = '0601' or
       sy-dynnr = '0602'.
       dynpfields-fieldname  = 'GS_SE16N_LT-TAB'.
    else.
       dynpfields-fieldname  = 'GD-TAB'.
    endif.
    APPEND dynpfields.
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME                         = 'SAPLSE16N'
        DYNUMB                         = sy-dynnr
        TRANSLATE_TO_UPPER             = true
      TABLES
        DYNPFIELDS                     = dynpfields.
    read table dynpfields index 1.
    gd-tab = dynpfields-fieldvalue.
  endif.

*.separate between DBCON-F4 and normal F4
  if gd-dbcon = space or
     ( sy-dynnr = '0601' or
       sy-dynnr = '0602' ).
*.check if tax auditor
  CALL FUNCTION 'CA_USER_EXISTS'
      EXPORTING
        i_user       = sy-uname
      EXCEPTIONS
        user_missing = 1.
*.if tax audit, only show allowed tables
    IF sy-subrc = 0.
      REFRESH tax_tab.
*.....DART field catalog
      SELECT DISTINCT C~src_struct AS VALUE,
                      tx~ddtext    AS TEXT
              APPENDING CORRESPONDING FIELDS OF TABLE @tax_tab
                FROM txw_c_soex AS C
              LEFT outer JOIN dd02t AS tx
                ON tx~tabname  = c~src_struct
                AND ddlanguage = @sy-langu
                AND as4local   = 'A'
                AND as4vers    = @space
              ORDER BY C~src_struct.
*.....additional tables
      SELECT DISTINCT C~tabname AS VALUE,
                      tx~ddtext AS TEXT
              APPENDING CORRESPONDING FIELDS OF TABLE @tax_tab
                FROM se16n_role_aud_e AS C
              LEFT outer JOIN dd02t AS tx
                ON tx~tabname  = c~tabname
                AND ddlanguage = @sy-langu
                AND as4local   = 'A'
                AND as4vers    = @space
              ORDER BY C~tabname.

      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
        EXPORTING
          RETFIELD         = retfield
          value_org        = 'S'
*           multiple_choice  = ld_multi_choice
        TABLES
          VALUE_TAB        = tax_tab
          return_tab       = return_tab
        EXCEPTIONS
          PARAMETER_ERROR  = 1
          NO_VALUES_FOUND  = 2
          OTHERS           = 3.

      IF SY-SUBRC = 0.
        READ TABLE return_tab INDEX 1.
        IF sy-subrc = 0.
          gd-tab = return_tab-fieldval.
          tab    = gd-tab.
        ENDIF.
      ENDIF.
   ELSE.
*..read field tab
   CLEAR dynpfields.
   REFRESH dynpfields.
   if sy-dynnr = '0601' or
      sy-dynnr = '0602'.
      dynpfields-fieldname  = 'GS_SE16N_LT-TAB'.
   else.
      dynpfields-fieldname  = 'GD-TAB'.
   endif.
   APPEND dynpfields.
   CALL FUNCTION 'DYNP_VALUES_READ'
     EXPORTING
*>>> THIMEL-R, 20200928, Auf Z umstellen, sonst gibt es einen Kurzdump
       DYNAME                         = 'SAPLZSE16N' "'SAPLSE16N'
*<<< THIMEL-R, 20200928
       DYNUMB                         = sy-dynnr
       TRANSLATE_TO_UPPER             = true
     TABLES
       DYNPFIELDS                     = dynpfields.

   read table dynpfields index 1.
   tab = dynpfields-fieldvalue.
   if tab = space.
      tab = '*'.
   endif.

  VALUE_TAB = TAB.
  CALL FUNCTION 'F4_DD_TABLES'
          EXPORTING
               OBJECT             = VALUE_TAB
               SUPPRESS_SELECTION = 'X'
               DISPLAY_ONLY       = SHOW_MODE
               VARIANT            = T_VARIANT
          IMPORTING
               RESULT             = VALUE_TAB.

  TAB = VALUE_TAB.
  endif.

*     CALL FUNCTION 'F4_DD_TABLES'
*          EXPORTING
*               object             = value_tab
*               suppress_selection = 'X'
*               display_only       = show_mode
*               variant            = variant
*          IMPORTING
*               result             = value_tab.
*
*  tab = value_tab.
  else.
    perform dbcon_f4 changing tab.
  endif.

ENDFORM.                    " f4_tab
*&---------------------------------------------------------------------*
*&      Form  check_tab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GD_EXIT  text
*----------------------------------------------------------------------*
FORM check_tab CHANGING value(P_EXIT).

  DATA: BEGIN OF SLIST OCCURS 10.
          INCLUDE STRUCTURE VIMSELLIST.
  DATA: END OF SLIST.
  DATA: BEGIN OF ECODE OCCURS 10.
          INCLUDE STRUCTURE VIMEXCLFUN.
  DATA: END OF ECODE,
        L_SUBRC LIKE SY-SUBRC.

  SELECT * FROM  DD02L
* Tabellenparameter
         WHERE  TABNAME     = gd-tab
         AND    AS4LOCAL    = 'A'.
    EXIT.
  ENDSELECT.

* IF SY-SUBRC = 0 AND NOT SUPPRESS_STRUCTURE_CHECK IS INITIAL.
  IF SY-SUBRC = 0.
* Structur fuer externe Anzeige
*   EXIT.
     IF DD02L-MAINFLAG = 'N'.
        MESSAGE E408(MO) WITH GD-TAB.
        EXIT.
     ENDIF.
  ENDIF.
  IF SY-SUBRC NE 0.
* Es koennte noch ein Tabellencluster oder pool sein
    SELECT        * FROM  DD06L
           WHERE  SQLTAB      = gd-tab
           AND    AS4LOCAL    = 'A'.
      EXIT.
    ENDSELECT.
    IF SY-SUBRC NE 0.
      MESSAGE E402(mo) WITH gd-tab.
    ELSE.
      CLEAR DD02L-MAINFLAG.            " Keine Pflege.
    ENDIF.
  ELSEIF DD02L-TABCLASS = 'INTTAB'.
    MESSAGE E403(mo) WITH gd-tab.
  ENDIF.

  IF DD02L-TABCLASS = 'VIEW'.
    IF DD02L-VIEWCLASS = 'P' or dd02l-viewclass = 'X'.
* Projektionsview or external view
    ELSE.
      CALL FUNCTION 'DB_EXISTS_VIEW'
           EXPORTING
                VIEWNAME = gd-tab
           IMPORTING
                SUBRC    = L_SUBRC.
      IF L_SUBRC NE 0.
* Kein Datenbankview
        IF DD02L-VIEWCLASS = 'C' .
          IF GD-DISPLAY = TRUE.
             MESSAGE I127(00).
          ELSE.
            if dd02l-mainflag is initial.
*           Teil eines Viewclusters, der nicht angezeigt werden kann
               message e404(mo) with gd-tab raising db_not_exists.
            else.
              call function 'AUTHORITY_CHECK_TCODE'
                exporting
                  tcode  = 'SM30'
                exceptions
                  ok     = 0
                  not_ok = 1.
              if sy-subrc ne 0.
                message e059(eu) with 'SM30'.   " keine Berechtigung
              endif.
              CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
               EXPORTING
                    ACTION                         = 'S'
*              corr_number                    = '          '
*              generate_maint_tool_if_missing = ' '
*              show_selection_popup           = ' '
                  VIEW_NAME                      = gd-tab
                  CHECK_DDIC_MAINFLAG            = 'X'        "n'1148568
               TABLES
                    DBA_SELLIST                    =  SLIST
                    EXCL_CUA_FUNCT                 =  ECODE
               EXCEPTIONS OTHERS.
             endif.
          ENDIF.
        ENDIF.
        IF SY-SUBRC NE 0.
          MESSAGE E404(mo) WITH gd-tab.
        ELSE.
          P_EXIT = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF DD02L-TABCLASS = 'CLUSTER'.
    CALL FUNCTION 'DB_EXISTS_TABLE'
         EXPORTING
              TABNAME = DD02L-SQLTAB
         IMPORTING
              SUBRC   = L_SUBRC.
    IF L_SUBRC NE 0.
* Keine Datenbanktabelle für den Cluster da
      CALL FUNCTION 'DB_EXISTS_VIEW'
           EXPORTING
                VIEWNAME = DD02L-SQLTAB
           IMPORTING
                SUBRC    = L_SUBRC.
      IF L_SUBRC <> 0.
        MESSAGE E401(mo) WITH DD02L-SQLTAB.
      ENDIF.
    ENDIF.
  ELSEIF NOT DD02L-TABCLASS = 'POOL'.
    CALL FUNCTION 'DB_EXISTS_TABLE'
         EXPORTING
              TABNAME = gd-tab
         IMPORTING
              SUBRC   = L_SUBRC.
    IF L_SUBRC NE 0.
* Keine Datenbanktabelle da
      CALL FUNCTION 'DB_EXISTS_VIEW'
           EXPORTING
                VIEWNAME = gd-tab
           IMPORTING
                SUBRC    = L_SUBRC.
      IF L_SUBRC <> 0.
        MESSAGE E405(mo) WITH gd-tab.
      ENDIF.
    ENDIF.
  ENDIF.
*  IF DD02L-MAINFLAG IS INITIAL AND P_ACTION = 'ANLE'.
** Tabellenpflege nicht erlaubt.
*    MESSAGE E416(mo) WITH gd-tab.
*  ENDIF.

ENDFORM.                    " check_tab
*&---------------------------------------------------------------------*
*&      Form  pick_navigation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pick_navigation .

data: ld_field(40).

  get cursor field ld_field.
  case ld_field.
    when 'GS_SELFIELDS-FIELDNAME' or
         'GS_SELFIELDS-ROLLNAME'.
       perform dtel_pick.
    when 'GS_SELFIELDS-LOW'.
       perform value_pick using 'L'.
    when 'GS_SELFIELDS-HIGH'.
       perform value_pick using 'H'.
    when 'GS_SELFIELDS-CONVEXIT'.
       perform conv_pick.
    when 'GD-TAB'.
       perform tab_pick using 1.
    when 'GD-TXT_TAB'.
       perform tab_pick using 2.
  endcase.

ENDFORM.                    " pick_navigation
*&---------------------------------------------------------------------*
*& Form value_pick
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM value_pick  USING    VALUE(p_kind).

  DATA: BEGIN OF lt_value OCCURS 0,
    VALUE(132),
  END OF lt_value.
  DATA: ls_value LIKE LINE OF lt_value.
  DATA: ld_line  TYPE sy-tabix.
  DATA: ls_selfields TYPE se16n_selfields.

  GET CURSOR LINE ld_line.
  ld_line = selfields_tc-CURRENT_LINE
  + ld_line - 1.
  IF ld_line = 0 OR ld_line < selfields_tc-CURRENT_LINE.
    EXIT.
  ENDIF.
  READ TABLE gt_selfields INTO ls_selfields INDEX ld_line.
  CHECK: sy-subrc = 0.

*.show input value converted and unconverted
  CASE p_kind.
  WHEN 'L'.
    CHECK: ls_selfields-low <> space.
*...internal display
    ls_value-VALUE = |{ TEXT-k03 } : { ls_selfields-low }|.
    APPEND ls_value TO lt_value.
*...external display
    IF LS_SELFIELDS-LOW <> SPACE AND
       LS_SELFIELDS-NO_INPUT_CONVERSION = space.
*...in case of currency reference, try to get it
      IF ls_selfields-reffield <> space AND
      ls_selfields-reftable = ls_selfields-tabname.
        READ TABLE gt_selfields INTO gs_curr_dummy
        WITH KEY tabname   = ls_selfields-reftable
                 fieldname = ls_selfields-reffield.
        IF sy-subrc = 0.
          gd_currency_pbo = gs_curr_dummy-low.
        ENDIF.
      ENDIF.
      PERFORM convert_to_extern USING    gd_currency_pbo
                                CHANGING ls_selfields
                                         ls_selfields-low.
    ENDIF.
    ls_value-VALUE = |{ TEXT-k02 } : { ls_selfields-low }|.
    APPEND ls_value TO lt_value.
  WHEN 'H'.
    CHECK: ls_selfields-high <> space.
*...internal display
    ls_value-VALUE = |{ TEXT-k03 } : { ls_selfields-high }|.
    APPEND ls_value TO lt_value.
*...external display
    IF LS_SELFIELDS-HIGH <> SPACE AND
       LS_SELFIELDS-NO_INPUT_CONVERSION = space.
*...in case of currency reference, try to get it
      IF ls_selfields-reffield <> space AND
      ls_selfields-reftable = ls_selfields-tabname.
        READ TABLE gt_selfields INTO gs_curr_dummy
        WITH KEY tabname   = ls_selfields-reftable
                 fieldname = ls_selfields-reffield.
        IF sy-subrc = 0.
          gd_currency_pbo = gs_curr_dummy-low.
        ENDIF.
      ENDIF.
      PERFORM convert_to_extern USING    gd_currency_pbo
                                CHANGING ls_selfields
                                         ls_selfields-high.
    ENDIF.
    ls_value-VALUE = |{ TEXT-k02 } : { ls_selfields-high }|.
    APPEND ls_value TO lt_value.
  ENDCASE.
  CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
  EXPORTING
    endpos_col         = 70
    endpos_row         = 20
    startpos_col       = 10
    startpos_row       = 10
    titletext          = TEXT-k01
  IMPORTING
    CHOISE             = ld_line
  TABLES
    valuetab           = lt_value
  EXCEPTIONS
    BREAK_OFF          = 1
    OTHERS             = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  dtel_pick
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dtel_pick .

data: ld_line like sy-tabix.
constants: ld_radio(30) value 'RSRD1-DDTYPE'.
constants: ld_val(30)   value 'RSRD1-DDTYPE_VAL'.

   GET CURSOR LINE ld_line.
   ld_line = selfields_tc-CURRENT_LINE
             + ld_line - 1.
   IF ld_line = 0 OR ld_line < selfields_tc-CURRENT_LINE.
     EXIT.
   endif.
   read table gt_selfields index ld_line.
   check: sy-subrc = 0.
   perform bdc_call using 1
                          ld_radio
                          ld_val
                          gt_selfields-rollname.


ENDFORM.                    " dtel_pick
*&---------------------------------------------------------------------*
*&      Form  tab_pick
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1      text
*----------------------------------------------------------------------*
FORM tab_pick  USING  VALUE(kind).

constants: ld_radio(30) value 'RSRD1-TBMA'.
constants: ld_val(30)   value 'RSRD1-TBMA_VAL'.

  case kind.
*...Table
    when 1.
       check: gd-tab <> space.
       perform bdc_call using 2
                              ld_radio
                              ld_val
                              gd-tab.
*...Text table
    when 2.
       check: gd-txt_tab <> space.
       perform bdc_call using 2
                              ld_radio
                              ld_val
                              gd-txt_tab.
  endcase.

ENDFORM.                    " tab_pick
*&---------------------------------------------------------------------*
*&      Form  bdc_call
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_VAL  text
*      -->P_GT_SELFIELDS_FIELDNAME  text
*----------------------------------------------------------------------*
FORM bdc_call  USING    value(kind)
                        value(ld_radio)
                        value(LD_VAL)
                        value(FIELDNAME).

DATA: BEGIN OF BDCDATA OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF BDCDATA.
DATA: ld_dtelnm TYPE rsd_s_dtel-dtelnm.
DATA: ld_domanm TYPE rsd_s_dtel-domanm.
DATA: ld_tablnm TYPE rsd_tablnm.

constants: ld_tcode like sy-tcode value 'SE11'.

*..new navigation
   case kind.
     when 1.
       ld_dtelnm = fieldname.
       CALL FUNCTION 'RS_DD_DTEL_SHOW'
            EXPORTING
              objname = ld_dtelnm
            EXCEPTIONS
              OTHERS  = 4.
     when 2.
       ld_tablnm = fieldname.
       CALL FUNCTION 'RS_DD_FIEL_SHOW'
            EXPORTING
              objname = ld_tablnm
            EXCEPTIONS
              OTHERS  = 4.
   endcase.


*.Coding for basis 710
**..batch input on DDIC
*   refresh bdcdata.
**..Set program and screen
*   CLEAR BDCDATA.
*   BDCDATA-PROGRAM  = 'SAPLSD_ENTRY'.
*   BDCDATA-DYNPRO   = '1000'.
*   BDCDATA-DYNBEGIN = 'X'.
*   APPEND BDCDATA.
**..set the cursor to the wanted radiobutton
*   CLEAR BDCDATA.
*   BDCDATA-FNAM     = 'BDC_OKCODE'.
*   BDCDATA-FVAL     = '=CHANGE_RADIO'.
*   APPEND BDCDATA.
*   case kind.
**....data element
*     when 1.
*       CLEAR BDCDATA.
*       BDCDATA-FNAM     = 'BDC_CURSOR'.
*       BDCDATA-FVAL     = 'RSRD1-DDTYPE'.
*       APPEND BDCDATA.
**......clear table-radiobutton
*       CLEAR BDCDATA.
*       BDCDATA-FNAM     = 'RSRD1-TBMA'.
*       BDCDATA-FVAL     = ''.
*       APPEND BDCDATA.
**......set dataelement ad wanted type
*       CLEAR BDCDATA.
*       BDCDATA-FNAM     = 'RSRD1-DDTYPE'.
*       BDCDATA-FVAL     = 'X'.
*       APPEND BDCDATA.
*     when 2.
*       CLEAR BDCDATA.
*       BDCDATA-FNAM     = 'BDC_CURSOR'.
*       BDCDATA-FVAL     = 'RSRD1-TBMA_VAL'.
*       APPEND BDCDATA.
*       CLEAR BDCDATA.
*       BDCDATA-FNAM     = 'RSRD1-TBMA'.
*       BDCDATA-FVAL     = 'X'.
*       APPEND BDCDATA.
*       CLEAR BDCDATA.
*       BDCDATA-FNAM     = 'RSRD1-DDTYPE'.
*       BDCDATA-FVAL     = ''.
*       APPEND BDCDATA.
*   endcase.
**..clear all other possible radiobuttons
*   CLEAR BDCDATA.
*   BDCDATA-FNAM     = 'RSRD1-VIMA'.
*   BDCDATA-FVAL     = ''.
*   APPEND BDCDATA.
*   CLEAR BDCDATA.
*   BDCDATA-FNAM     = 'RSRD1-TYMA'.
*   BDCDATA-FVAL     = ''.
*   APPEND BDCDATA.
*   CLEAR BDCDATA.
*   BDCDATA-FNAM     = 'RSRD1-DOMA'.
*   BDCDATA-FVAL     = ''.
*   APPEND BDCDATA.
*   CLEAR BDCDATA.
*   BDCDATA-FNAM     = 'RSRD1-SHMA'.
*   BDCDATA-FVAL     = ''.
*   APPEND BDCDATA.
*   CLEAR BDCDATA.
*   BDCDATA-FNAM     = 'RSRD1-ENQU'.
*   BDCDATA-FVAL     = ''.
*   APPEND BDCDATA.
*   CLEAR BDCDATA.
**..fill the value into the correct field
*   CLEAR BDCDATA.
*   BDCDATA-FNAM     = ld_val.
*   BDCDATA-FVAL     = fieldname.
*   APPEND BDCDATA.
**..Press 'show'
*   CLEAR BDCDATA.
*   BDCDATA-FNAM     = 'BDC_OKCODE'.
*   BDCDATA-FVAL     = '=WB_DISPLAY'.
*   APPEND BDCDATA.
**..Start SE11 with Batchinput-data in Only-Error-Display-Mode
*   CALL TRANSACTION LD_TCODE USING BDCDATA mode 'E'.

ENDFORM.                    " bdc_call
*&---------------------------------------------------------------------*
*&      Form  conv_pick
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM conv_pick .

data: ld_line like sy-tabix.
data: ld_fb_name(30) value 'CONVERSION_EXIT_&*'.

   GET CURSOR LINE ld_line.
   ld_line = selfields_tc-CURRENT_LINE
             + ld_line - 1.
   IF ld_line = 0 OR ld_line < selfields_tc-CURRENT_LINE.
     EXIT.
   endif.
   read table gt_selfields index ld_line.
   check: sy-subrc = 0.
   check: gt_selfields-convexit <> space.
   replace '&' in ld_fb_name with gt_selfields-convexit.

   call function 'REPOSITORY_INFO_SYSTEM'
        exporting
              object_type        = 'FUNC'
              action             = 'S'
              object_name        = ld_fb_name
              suppress_selection = 'X'
              show_as_popup      = 'X'
               exceptions
                    cancel             = 1
                    wrong_type         = 2
                    others             = 3.
  if sy-subrc ne 0.
     case sy-subrc.
        when 1.
           message s004(e2).
*          Aktion wurde abgebrochen
        when others.
           message i008(e2) with 'SHOW_CONV_EXITS'
                                 sy-repid.
*          Interner Fehler & in & (Verantw. verständigen)
        endcase.
   endif.

ENDFORM.                    " conv_pick
*&---------------------------------------------------------------------*
*&      Form  include_function
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0011   text
*---------------------------------------------------------------------*
FORM EXCLUDE_FUNCTION USING
*---------------------------------------------------------------------*
  FUNCTION.
*---------------------------------------------------------------------*
*
  FUNCTAB-FCODE = FUNCTION.
  COLLECT FUNCTAB.

ENDFORM.

*---------------------------------------------------------------------*
FORM INCLUDE_FUNCTION USING
*---------------------------------------------------------------------*
  FUNCTION.
*---------------------------------------------------------------------*
*
  LOOP AT FUNCTAB WHERE FCODE = FUNCTION.
    DELETE FUNCTAB.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  wusl_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM wusl_table .

data: ld_line like sy-tabix.
data: ld_field(40).

*..first check authority for workbench
   CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
     EXPORTING
       tcode         = 'SE80'
     EXCEPTIONS
       OK            = 1
       NOT_OK        = 2
       OTHERS        = 3.
   IF sy-subrc > 1.
     message s328(42).
     exit.
   ENDIF.

   get cursor field ld_field.
   case ld_field.
     when 'GD-TAB'.
       check: gd-tab <> space.
       call function 'REPOSITORY_INFO_SYSTEM'
          exporting
              object_type        = 'TABL'
              action             = 'C'
              object_name        = gd-tab
*             suppress_selection = 'X'
*             show_as_popup      = 'X'
          exceptions
              cancel             = 1
              wrong_type         = 2
              others             = 3.
     when 'GD-TXT_TAB'.
       check: gd-txt_tab <> space.
       call function 'REPOSITORY_INFO_SYSTEM'
          exporting
              object_type        = 'TABL'
              action             = 'C'
              object_name        = gd-txt_tab
*             suppress_selection = 'X'
*             show_as_popup      = 'X'
          exceptions
              cancel             = 1
              wrong_type         = 2
              others             = 3.
    when 'GS_SELFIELDS-ROLLNAME'.
       GET CURSOR LINE ld_line.
       ld_line = selfields_tc-CURRENT_LINE
                 + ld_line - 1.
       IF ld_line = 0 OR ld_line < selfields_tc-CURRENT_LINE.
          EXIT.
       endif.
       read table gt_selfields index ld_line.
       check: sy-subrc = 0.
       check: gt_selfields-rollname <> space.
       call function 'REPOSITORY_INFO_SYSTEM'
          exporting
              object_type        = 'DTEL'
              action             = 'C'
              object_name        = gt_selfields-rollname
*             suppress_selection = 'X'
*             show_as_popup      = 'X'
          exceptions
              cancel             = 1
              wrong_type         = 2
              others             = 3.
    endcase.
    if sy-subrc ne 0.
       case sy-subrc.
          when 1.
             message s004(e2).
*            Aktion wurde abgebrochen
            when others.
               message i008(e2) with 'SHOW_CONV_EXITS'
                                 sy-repid.
*              Interner Fehler & in & (Verantw. verständigen)
       endcase.
    endif.

ENDFORM.                    " wusl_table
*&---------------------------------------------------------------------*
*&      Form  fill_picture
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_picture .

data: ld_system_type like sy-sysid.
data: lt_fields like sval occurs 0 with header line.
data: ld_return(1).
data: ld_url    type char255.

   call function 'TR_SYS_PARAMS'
           importing
                systemtype = ld_system_type.
   check: ld_system_type = 'SAP'.

   lt_fields-tabname   = 'SE16N_SELFIELDS'.
   lt_fields-fieldname = 'LOW'.
   lt_fields-value     = 'http://www.sap.com/'.
   append lt_fields.
   CALL FUNCTION 'POPUP_GET_VALUES_DB_CHECKED'
     EXPORTING
       CHECK_EXISTENCE       = ' '
       POPUP_TITLE           = text-url
*      START_COLUMN          = '5'
*      START_ROW             = '5'
     IMPORTING
       RETURNCODE            = ld_return
     TABLES
       FIELDS                = lt_fields
     EXCEPTIONS
       OTHERS                = 1.

   IF SY-SUBRC <> 0 or
      ld_return <> space.
      exit.
   ENDIF.
   read table lt_fields index 1.
   ld_url = lt_fields-value.

   CALL FUNCTION 'TSWUSL_DOCK_PICTURE'
     EXPORTING
       I_REPID       = sy-repid
       I_DYNNR       = '0200'
       I_SIZE        = 150
       I_URL         = ld_url.

endform.
*&---------------------------------------------------------------------*
*&      Form  multi_or
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM multi_or .

*.this function fills global table gt_multi_or
  refresh gt_multi_or.
  loop at gt_multi_or_all into gs_multi_or_all.
     if gs_multi_or_all-pos = 1.
        loop at gs_multi_or_all-selfields into gs_multi_or.
           read table gt_selfields
                     with key fieldname = gs_multi_or-fieldname.
           if sy-subrc = 0.
              gs_multi_or-mark = gt_selfields-mark.
           endif.
           append gs_multi_or to gt_multi_or.
        endloop.
     endif.
  endloop.
*.first time, initialize
  if sy-subrc <> 0.
     loop at gt_selfields.
        move-corresponding gt_selfields to gs_multi_or.
        clear: gs_multi_or-sign,
               gs_multi_or-option,
               gs_multi_or-low,
               gs_multi_or-high,
               gs_multi_or-push.
        append gs_multi_or to gt_multi_or.
     endloop.
  endif.
  gd_multi_or_pos = 1.
  refresh gt_multi_or_all_buf.
  gt_multi_or_all_buf[] = gt_multi_or_all[].
  call screen 111 starting at 5 5 ending at 140 30.

ENDFORM.                    " multi_or
*&---------------------------------------------------------------------*
*&      Form  take_data_or
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM take_data_or .

data: ls_dummy    like se16n_selfields.
data: ld_currency type sycurr.

   READ TABLE GT_multi_or INDEX multi_or_TC-CURRENT_LINE.

   gd_save_low  = gs_multi_or-low.
   gd_save_high = gs_multi_or-high.

*.. When do I have to use INTLEN, when OUTPUTLEN ?
   IF GS_multi_or-LOW <> SPACE.
*.....check if input length is 45 or more
      perform check_input_length using true
                                 changing gs_multi_or-low
                                          gd_length_changed.
*.....as the screen field is upper case sensitive I have to convert
*.....all other fields
      if gt_multi_or-lowercase <> true.
         translate gs_multi_or-low to upper case.  "#EC TRANSLANG
      endif.
*.....in case of currency reference, try to get it
      if gt_multi_or-reffield <> space and
         gt_multi_or-reftable = gt_multi_or-tabname.
        read table gt_multi_or into ls_dummy
             with key tabname   = gt_multi_or-reftable
                      fieldname = gt_multi_or-reffield.
        if sy-subrc = 0.
           ld_currency = ls_dummy-low.
        endif.
      endif.
      perform convert_to_intern using    ld_currency
                                changing gt_multi_or
                                         gs_multi_or-low.
   ENDIF.
   IF GS_multi_or-HIGH <> SPACE.
*.....check if input length is 45 or more
      perform check_input_length using true
                                 changing gs_multi_or-high
                                          gd_length_changed.
*.....as the screen field is upper case sensitive I have to convert
*.....all other fields
      if gt_multi_or-lowercase <> true.
         translate gs_multi_or-high to upper case. "#EC TRANSLANG
      endif.
*.....in case of currency reference, try to get it
      if gt_multi_or-reffield <> space and
         gt_multi_or-reftable = gt_multi_or-tabname.
        read table gt_multi_or into ls_dummy
             with key tabname   = gt_multi_or-reftable
                      fieldname = gt_multi_or-reffield.
        if sy-subrc = 0.
           ld_currency = ls_dummy-low.
        endif.
      endif.
      perform convert_to_intern using    ld_currency
                                changing gt_multi_or
                                         gs_multi_or-high.
   ENDIF.

*..check if low-value greater than high value
   if GS_multi_or-LOW > GS_multi_or-HIGH and
      ( gs_multi_or-high <> space         or
        gt_multi_or-option = opt-bt       or
        gt_multi_or-option = opt-nb )    and
*        gt_multi_or-option = opt-nb       or
*        gt_multi_or-option = opt-np       or
*        gt_multi_or-option = opt-cp )     and
      ( gs_multi_or-datatype = 'CHAR' or
        gs_multi_or-datatype = 'DATS' or
        gs_multi_or-datatype = 'DATN' or
        gs_multi_or-datatype = 'LANG' or
        gs_multi_or-datatype = 'CUKY' or
        gs_multi_or-datatype = 'CLNT' or
        gs_multi_or-datatype = 'NUMC' or
        gs_multi_or-datatype = 'TIMN' or
*        gs_multi_or-datatype = 'CURR' or
        gs_multi_or-datatype = 'TIMS' ).
      gs_multi_or-low  = gd_save_low.
      gs_multi_or-high = gd_save_high.
      message e650(db).
   endif.

   Gt_multi_or-MARK = GS_multi_or-MARK.
   Gt_multi_or-LOW  = GS_multi_or-LOW.
   Gt_multi_or-HIGH = GS_multi_or-HIGH.
   if gt_multi_or-sign = space.
      gt_multi_or-sign = opt-i.
   endif.

   MODIFY GT_multi_or INDEX multi_or_TC-CURRENT_LINE.

ENDFORM.                    " take_data_or
*&---------------------------------------------------------------------*
*&      Form  field_f4_or
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TRUE  text
*----------------------------------------------------------------------*
FORM FIELD_F4_or USING value(ld_low).

data: selval       like help_info-fldvalue.
data: valmin       like gs_Selfields-low.
data: valmax       like gs_Selfields-high.
data: return_tab   like ddshretval occurs 0 with header line.
data: ld_curr_line like sy-tabix.
data: begin of f4_dummy,
        tab   like t811c-tab,
        minus(1),
        field like t811k-field,
      end of f4_dummy.

FIELD-SYMBOLS: <selval>.

  get cursor line ld_curr_line.
  ld_curr_line = ld_curr_line + multi_or_tc-top_line - 1.
  read table gt_multi_or index ld_curr_line.
  check: sy-subrc = 0.

  valmin = gs_multi_or-low.
  valmax = gs_multi_or-high.

  if ld_low = true.
     assign gs_multi_or-low to <selval>.
  else.
     assign gs_multi_or-high to <selval>.
  endif.

*----- pass dynp* fields with dummy "X" to trigger ext. F4 help
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
       EXPORTING
            tabname           = gt_multi_or-tabname
            fieldname         = gt_multi_or-fieldname
            value             = selval
            selection_screen  = 'X'
            dynpprog          = 'X'
            dynpnr            = 'X'
            dynprofield       = 'X'
       TABLES
            return_tab        = return_tab
       EXCEPTIONS
            FIELD_NOT_FOUND   = 1
            NO_HELP_FOR_FIELD = 2
            INCONSISTENT_HELP = 3
            NO_VALUES_FOUND   = 4
            OTHERS            = 5.
  if sy-subrc = 0.
     clear f4_dummy.
     f4_dummy-tab   = gt_multi_or-tabname.
     f4_dummy-minus = '-'.
     f4_dummy-field = gt_multi_or-fieldname.
     condense f4_dummy no-gaps.
     READ TABLE return_tab WITH KEY retfield  = f4_dummy.
     IF sy-subrc = 0.
        <selval> = return_tab-fieldval.
     else.
        gs_multi_or-low  = valmin.
        gs_multi_or-high = valmax.
     ENDIF.
   else.
     gs_multi_or-low  = valmin.
     gs_multi_or-high = valmax.
   endif.


ENDFORM.                    " field_f4_or
*&---------------------------------------------------------------------*
*&      Form  next_multi_or
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM next_multi_or using value(kind).

data: ld_pos   like sy-tabix.
data: ld_subrc like sy-subrc.

*.save entered data
  if kind = 'N'.
     ld_pos = gd_multi_or_pos - 1.
  else.
     ld_pos = gd_multi_or_pos + 1.
  endif.
  delete gt_multi_or_all where pos = ld_pos.
  gs_multi_or_all-pos = ld_pos.
  gs_multi_or_all-selfields = gt_multi_or[].
  append gs_multi_or_all to gt_multi_or_all.

*.now fill next screen
  refresh gt_multi_or.
  ld_subrc = 4.
  loop at gt_multi_or_all into gs_multi_or_all.
     if gs_multi_or_all-pos = gd_multi_or_pos.
        ld_subrc = 0.
        loop at gs_multi_or_all-selfields into gs_multi_or.
           append gs_multi_or to gt_multi_or.
        endloop.
     endif.
  endloop.
*.first time, initialize
  if sy-subrc <> 0 or
     ld_subrc <> 0.
     loop at gt_selfields.
        move-corresponding gt_selfields to gs_multi_or.
        clear: gs_multi_or-sign,
               gs_multi_or-option,
               gs_multi_or-low,
               gs_multi_or-high,
               gs_multi_or-push.
        append gs_multi_or to gt_multi_or.
     endloop.
  endif.

ENDFORM.                    " next_multi_or
*&---------------------------------------------------------------------*
*&      Form  take_or
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM take_or .

*.save entered data
  delete gt_multi_or_all where pos = gd_multi_or_pos.
  gs_multi_or_all-pos = gd_multi_or_pos.
  gs_multi_or_all-selfields = gt_multi_or[].
  append gs_multi_or_all to gt_multi_or_all.

ENDFORM.                    " take_or
*&---------------------------------------------------------------------*
*&      Form  show_multi_select_or
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_multi_select_or .

data: lt_multi like se16n_selfields occurs 0 with header line.
data: ld_lines like sy-tabix.
data: ld_index like sy-tabix.
data: ls_dummy    like se16n_selfields.
data: ld_currency type sycurr.

   GET CURSOR LINE ld_line.
   ld_line = multi_or_tc-CURRENT_LINE + ld_line - 1.
   IF ld_line = 0 OR ld_line < multi_or_tc-CURRENT_LINE.
     EXIT.
   endif.

  read table gt_multi_or index ld_line.
  check sy-subrc = 0.

*.Fill the current line into multi popup as well
  if not gt_multi_or-low is initial or
     not gt_multi_or-high is initial or
     not gt_multi_or-option is initial.
     move-corresponding gt_multi_or to lt_multi.
     append lt_multi.
  endif.

*.Search for multi selection concerning this field
  refresh gs_or_mul_all-selfields.
  read table gt_or_mul_all into gs_or_mul_all
                  with key pos = gd_multi_or_pos.
  if sy-subrc = 0.
     loop at gs_or_mul_all-selfields into gs_or_mul
                     where fieldname = gt_multi_or-fieldname.
        append gs_or_mul to lt_multi.
     endloop.
  endif.

*.Now call popup to enter more values
*.Unfortenately the popup needs global information out of gt_selfields
  move-corresponding gt_multi_or to gt_selfields.

*.in case of currency reference, try to get it
  if gt_multi_or-reffield <> space and
     gt_multi_or-reftable = gt_multi_or-tabname.
    read table gt_multi_or into ls_dummy
         with key tabname   = gt_multi_or-reftable
                  fieldname = gt_multi_or-reffield.
    if sy-subrc = 0.
       ld_currency = ls_dummy-low.
    endif.
  endif.

  CALL FUNCTION 'SE16N_MULTI_FIELD_INPUT'
    EXPORTING
      LS_SELFIELDS          = gt_multi_or
      ld_currency           = ld_currency
    TABLES
      LT_MULTI_SELECT       = lt_multi.

*.Now delete the old entries
  read table gt_or_mul_all into gs_or_mul_all
                  with key pos = gd_multi_or_pos.
  if sy-subrc = 0.
     ld_index = sy-tabix.
     delete gs_or_mul_all-selfields
                              where fieldname = gt_multi_or-fieldname.
     modify gt_or_mul_all from gs_or_mul_all index ld_index.
  else.
     refresh gs_or_mul_all-selfields.
  endif.

*.Now search for new ones and fill into buffer
  describe table lt_multi lines ld_lines.
  if ld_lines > 1.
     gt_multi_or-push = true.
     read table lt_multi index 1.
     gt_multi_or-low  = lt_multi-low.
     gt_multi_or-high = lt_multi-high.
     gt_multi_or-option = lt_multi-option.
     gt_multi_or-sign   = lt_multi-sign.
     modify gt_multi_or index ld_line.
     delete lt_multi index 1.
     gs_or_mul_all-pos = gd_multi_or_pos.
     append lines of lt_multi to gs_or_mul_all-selfields.
     if ld_index = 0.
        append gs_or_mul_all to gt_or_mul_all.
     else.
        modify gt_or_mul_all from gs_or_mul_all index ld_index.
     endif.
  elseif ld_lines = 1.
     read table lt_multi index 1.
     clear gt_multi_or-push.
     gt_multi_or-low  = lt_multi-low.
     gt_multi_or-high = lt_multi-high.
     gt_multi_or-option = lt_multi-option.
     gt_multi_or-sign   = lt_multi-sign.
     modify gt_multi_or index ld_line.
  else.
     clear gt_multi_or-push.
     clear gt_multi_or-low.
     clear gt_multi_or-high.
     clear gt_multi_or-option.
     clear gt_multi_or-sign.
     modify gt_multi_or index ld_line.
  endif.

ENDFORM.                    " show_multi_select_or
*&---------------------------------------------------------------------*
*&      Form  set_sel_option_or
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_sel_option_or .

data: ld_curr_line like sy-tabix.
data: ls_selfield  TYPE slis_selfield.
data: lt_fieldcat  TYPE lvc_t_fcat.
data: wa_fieldcat  TYPE LINE OF lvc_t_fcat.
data: ls_outtab    type se16n_sel_option.
data: lt_outtab    type se16n_sel_option occurs 0 with header line.
data: icon_name(40).
data: ld_exit(1).
data: ld_high(1).

  get cursor line ld_curr_line.
  ld_curr_line = ld_curr_line + multi_or_tc-top_line - 1.
  read table gt_multi_or index ld_curr_line.
  check: sy-subrc = 0.

  clear ld_high.
*.If high-value is filled, only a view options are possible
  read table gt_or_mul_all into gs_or_mul_all
                           with key pos = gd_multi_or_pos.
  if sy-subrc = 0.
     loop at gs_or_mul_all-selfields into gs_or_mul
                           where fieldname = gt_multi_or-fieldname.
        if not gs_or_mul-high is initial.
           ld_high = true.
           exit.
        endif.
     endloop.
  endif.

  if not gt_multi_or-high is initial.
     ld_high = true.
  endif.
  clear ld_high.

*.Makro for creation of ALV-output-table
  define makro_sel_output.
    ls_outtab-sign   = &1.
    ls_outtab-option = &2.
    perform get_icon_name using    ls_outtab-sign
                                   ls_outtab-option
                          changing icon_name.
    perform icon_create using    icon_name
                        changing ls_outtab-icon
                                 gd_dummy_text.
    ls_outtab-text   = gd_dummy_text.
    append ls_outtab to lt_outtab.
  end-of-definition.

  if ld_high = true.
     makro_sel_output opt-i opt-bt.
     makro_sel_output opt-i opt-nb.
     makro_sel_output opt-e opt-bt.
     makro_sel_output opt-e opt-nb.
  else.
     makro_sel_output opt-i opt-bt.
     makro_sel_output opt-i opt-cp.
     makro_sel_output opt-i opt-np.
     makro_sel_output opt-i opt-eq.
     makro_sel_output opt-i opt-nb.
     makro_sel_output opt-i opt-ne.
     makro_sel_output opt-i opt-gt.
     makro_sel_output opt-i opt-lt.
     makro_sel_output opt-i opt-ge.
     makro_sel_output opt-i opt-le.
     makro_sel_output opt-e opt-bt.
     makro_sel_output opt-e opt-cp.
     makro_sel_output opt-e opt-np.
     makro_sel_output opt-e opt-eq.
     makro_sel_output opt-e opt-nb.
     makro_sel_output opt-e opt-ne.
     makro_sel_output opt-e opt-gt.
     makro_sel_output opt-e opt-lt.
     makro_sel_output opt-e opt-ge.
     makro_sel_output opt-e opt-le.
  endif.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_BUFFER_ACTIVE              = ' '
      I_STRUCTURE_NAME             = 'SE16N_SEL_OPTION'
*     I_CLIENT_NEVER_DISPLAY       = 'X'
*     I_BYPASSING_BUFFER           =
    CHANGING
      CT_FIELDCAT                  = lt_fieldcat
    EXCEPTIONS
      INCONSISTENT_INTERFACE       = 1
      PROGRAM_ERROR                = 2
      OTHERS                       = 3.

  IF SY-SUBRC <> 0.
     exit.
  ENDIF.

  loop at lt_fieldcat into wa_fieldcat.
     case wa_fieldcat-fieldname.
       when 'SIGN'.
          wa_fieldcat-no_out = true.
       when 'OPTION'.
          wa_fieldcat-no_out = true.
       when 'ICON'.
          wa_fieldcat-outputlen = 2.
     endcase.
     modify lt_fieldcat from wa_fieldcat.
  endloop.

*.Show popup with the options and give one back
  CALL FUNCTION 'LVC_SINGLE_ITEM_SELECTION'
    EXPORTING
      I_TITLE                       = text-opt
*     I_SCREEN_START_COLUMN         = 0
*     I_SCREEN_START_LINE           = 0
*     I_SCREEN_END_COLUMN           = 0
*     I_SCREEN_END_LINE             = 0
*     I_LINEMARK_FIELDNAME          =
      IT_FIELDCATALOG               = lt_fieldcat
*     I_CALLBACK_PROGRAM            =
*     I_CALLBACK_USER_COMMAND       =
*     IT_STATUS_EXCL                =
    IMPORTING
      ES_SELFIELD                   = ls_selfield
      E_EXIT                        = ld_exit
    TABLES
      T_OUTTAB                      = lt_outtab.

  if ld_exit <> true.
     READ TABLE lt_outtab INTO ls_outtab
              INDEX ls_selfield-tabindex.
     if sy-subrc = 0.
        gt_multi_or-sign   = ls_outtab-sign.
        gt_multi_or-option = ls_outtab-option.
*.......GT_sel_init contains info if low and/or high are allowed for
*.......the selected option
        read table gt_sel_init with key option = ls_outtab-option.
        if sy-subrc = 0.
           if gt_sel_init-high <> true.
              clear gt_multi_or-high.
              read table gt_or_mul_all into gs_or_mul_all
                                       with key pos = gd_multi_or_pos.
              if sy-subrc = 0.
                 loop at gs_or_mul_all-selfields into gs_or_mul
                               where fieldname = gt_multi_or-fieldname.
                    clear gs_or_mul-high.
                    modify gs_or_mul_all-selfields from gs_or_mul.
                 endloop.
              endif.
           endif.
        endif.
        modify gt_multi_or index ld_curr_line.
     endif.
  endif.


ENDFORM.                    " set_sel_option_or
*&---------------------------------------------------------------------*
*&      Form  set_tech_flags
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_tech_flags .

data: ls_gd like gd.

*.if the user changes data and cancels, I need to have the old data
  ls_gd = gd.
  call screen 0700 starting at 10 5. " ending at 60 18.
  if ok_code = 'CANC'.
     gd = ls_gd.
  endif.
  clear ok_code.

ENDFORM.                    " set_tech_flags
*&---------------------------------------------------------------------*
*&      Form  save_flags
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_flags .

data: ld_dummy_line(10).

*..save all technical settings as user parameters
   perform set_param using 'SE16N_TECHNAMES'   gd-tech_names.
   perform set_param using 'SE16N_CWIDTH'      gd-cwidth_opt_off.
   perform set_param using 'SE16N_SCROLL'      gd-scroll.
   perform set_param using 'SE16N_NO_CONVEXIT' gd-no_convexit.
   perform set_param using 'SE16N_TECH_FIRST'  gd-tech_first.
   perform set_param using 'SE16N_TECH_VIEW'   gd-tech_view.
   perform set_param using 'SE16N_LSAVE'       gd-layout_save.
   perform set_param using 'SE16N_CDS_NO_SYS'  gd-cds_no_sys.
   perform set_param using 'SE16N_LGET'        gd-layout_get.
   write gd-max_lines to ld_dummy_line left-justified no-grouping.
   perform set_param using 'SE16N_MAXLINES'    ld_dummy_line.
   perform set_param using 'SE16N_DOUBLE_CLICK' gd-double_click.
   perform set_param using 'SE16N_COUNT_LINES' gd-count_lines.
   perform set_param using 'SE16N_NARROW_COLUMNS' gd-colopt.
   perform set_param using 'SE16N_SORTFIELD'   gd-sortfield.
   perform set_param using 'SE16N_ADDFIELDS'   gd-add_fields_cust.
   perform set_param using 'SE16N_LAYOUT_DOCKING' gd-show_layouts.
   perform set_param using 'SE16N_TEMPERATURE' gd-temperature.
   message i107(wusl).

ENDFORM.                    " save_flags
*&---------------------------------------------------------------------*
*&      Form  set_gd_flags
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0063   text
*----------------------------------------------------------------------*
FORM set_gd_flags  USING    VALUE(kind).

  if kind = true.
    gd-tech_names    = true.
    gd-scroll        = true.
    gd-no_convexit   = true.
    gd-tech_first    = true.
    gd-tech_view     = true.
    gd-layout_save   = true.
    gd-layout_get    = true.
    gd-cwidth_opt_off = true.
    gd-count_lines    = true.
    gd-sortfield      = true.
    gd-add_fields_cust = true.
    gd-show_layouts    = true.
    gd-cds_no_sys      = true.
  else.
    gd-tech_names    = space.
    gd-scroll        = space.
    gd-no_convexit   = space.
    gd-tech_first    = space.
    gd-tech_view     = space.
    gd-layout_save   = space.
    gd-layout_get    = space.
    gd-cwidth_opt_off = space.
    gd-count_lines    = space.
    gd-sortfield      = space.
    gd-add_fields_cust = space.
    gd-show_layouts    = space.
    gd-cds_no_sys      = space.
  endif.

ENDFORM.                    " set_gd_flags
*&---------------------------------------------------------------------*
*&      Form  set_param
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_5296   text
*      -->P_GD_TECH_NAMES  text
*----------------------------------------------------------------------*
FORM set_param  USING    VALUE(ID)
                         VALUE(val).

data: ld_id  LIKE  USR05-PARID.
data: ld_val LIKE  USR05-PARVA.

   ld_id  = id.
   ld_val = val.

   CALL FUNCTION 'SMAN_SET_USER_PARAMETER'
     EXPORTING
       PARAMETER_ID          = ld_id
       PARAMETER_VALUE       = ld_val
     EXCEPTIONS
       OTHERS                = 1.
   IF SY-SUBRC <> 0.
   ENDIF.

ENDFORM.                    " set_param
*&---------------------------------------------------------------------*
*&      Form  save_batch_variant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*----------------------------------------------------------------------*
FORM save_batch_variant tables itab_selpa structure kaba00.

DATA: BEGIN OF RSPARAMS_TAB OCCURS 10.
        INCLUDE STRUCTURE RSPARAMS.
DATA: END OF RSPARAMS_TAB.
DATA: BEGIN OF VARID_TAB.
        INCLUDE STRUCTURE VARID.
DATA: END OF VARID_TAB.
DATA: BEGIN OF VARIT_TAB OCCURS 2.
          INCLUDE STRUCTURE VARIT.
DATA: END OF VARIT_TAB.
data: returncode(1).
data: rc like sy-subrc.
data: lt_fields like sval occurs 0 with header line.

*.get the name of the variant the user wants to save
  lt_fields-tabname = 'VARID'.
  lt_fields-fieldname = 'VARIANT'.
  append lt_fields.
  lt_fields-tabname = 'VARIT'.
  lt_fields-fieldname = 'VTEXT'.
  append lt_fields.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
*     NO_VALUE_CHECK        = ' '
      POPUP_TITLE           = text-v04
*     START_COLUMN          = '5'
*     START_ROW             = '5'
    IMPORTING
      RETURNCODE            = returncode
    TABLES
      FIELDS                = lt_fields
    EXCEPTIONS
      ERROR_IN_FIELDS       = 1
      OTHERS                = 2.

  IF SY-SUBRC <> 0 or
     returncode = 'A'.
     exit.
  ENDIF.
  read table lt_fields index 1.
  varid-variant = lt_fields-value.
  read table lt_fields index 2.
  varit-vtext   = lt_fields-value.

  loop at itab_selpa.
     rsparams_tab-SELNAME = itab_selpa-field.
     rsparams_tab-KIND    = itab_selpa-type.
     rsparams_tab-SIGN    = itab_selpa-sign.
     rsparams_tab-OPTION  = itab_selpa-option.
     rsparams_tab-LOW     = itab_selpa-low.
     rsparams_tab-HIGH    = itab_selpa-high.
     append rsparams_tab.
  endloop.


*.fill VARID structure - Variantenkatalog, variant description
  varid_tab-mandt        = sy-mandt.
  varid_tab-report       = 'SE16N_BATCH'.
  varid_tab-variant      = varid-variant.
  varid_tab-flag1        = space.
  varid_tab-flag2        = space.
  varid_tab-transport    = space.
  varid_tab-environmnt   = 'A'.     "Variant for batch and online
  varid_tab-protected    = space.
  varid_tab-secu         = space.
  varid_tab-version      = '1'.
  varid_tab-ename        = sy-uname.
  varid_tab-edat         = sy-datum.
  varid_tab-etime        = sy-uzeit.
  varid_tab-aename       = space.
  varid_tab-aedat        = space.
  varid_tab-aetime       = space.
  varid_tab-mlangu       = sy-langu.

*.fill VARIT structure - Variantentexte; variant texts
  varit_tab-mandt      = sy-mandt.
  varit_tab-langu      = sy-langu.
  varit_tab-report     = varid_tab-report.
  varit_tab-variant    = varid-variant.
  varit_tab-vtext      = varit-vtext.
  APPEND varit_tab.

*.check variant
  CALL FUNCTION 'RS_VARIANT_EXISTS'
    EXPORTING
      report              = varid_tab-report
      variant             = varid_tab-variant
    IMPORTING
      r_c                 = rc
    EXCEPTIONS
      not_authorized      = 01
      no_report           = 02
      report_not_existent = 03
      report_not_supplied = 04.

  IF sy-subrc <> 0.
    rc = 8.
  ENDIF.

  IF rc = 0.                           " Variante existiert

    CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
         EXPORTING
              textline1    = text-v10
              textline2    = text-v11
              titel        = text-v12
*             START_COLUMN = 25
*             START_ROW    = 6
         IMPORTING
              answer       = returncode
         EXCEPTIONS
              OTHERS       = 1.
    IF returncode <> 'J'.
      EXIT.
    ENDIF.

    CALL FUNCTION 'RS_CHANGE_CREATED_VARIANT'
      EXPORTING
        curr_report               = varid_tab-report
        curr_variant              = varid_tab-variant
        vari_desc                 = varid_tab
      TABLES
        vari_contents             = rsparams_tab
        vari_text                 = varit_tab
      EXCEPTIONS
        illegal_report_or_variant = 01
        illegal_variantname       = 02
        not_authorized            = 03
        not_executed              = 04
        report_not_existent       = 05
        report_not_supplied       = 06
        variant_doesnt_exist      = 07
        variant_locked            = 08
        selections_no_match       = 09.
  ELSE.
    CALL FUNCTION 'RS_CREATE_VARIANT'
      EXPORTING
        curr_report               = varid_tab-report
        curr_variant              = varid_tab-variant
        vari_desc                 = varid_tab
      TABLES
        vari_contents             = rsparams_tab
        vari_text                 = varit_tab
      EXCEPTIONS
        illegal_report_or_variant = 01
        illegal_variantname       = 02
        not_authorized            = 03
        not_executed              = 04
        report_not_existent       = 05
        report_not_supplied       = 06
        variant_exists            = 07
        variant_locked            = 08.
  ENDIF.
  IF sy-subrc = 0.
    MESSAGE i138(ga) WITH varid_tab-variant.
  ELSEif sy-subrc = 2.
    message i635(db) with '&'.
  ENDIF.

endform.
*&---------------------------------------------------------------------*
*&      Form  import_from_textfile
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM import_from_textfile .

  DATA:
    ld_high(1),
    LD_FILENAME   TYPE STRING,
    LD_path       TYPE STRING,
    LT_FILETABLE  TYPE FILETABLE,
    LD_FILE       TYPE LINE OF FILETABLE,
    LD_RC         TYPE I,
    LD_USERACTION TYPE I,
    LD_FILELENGTH TYPE I.
data: trennzeichen(2) type c value '&&', "TRENNZEICHEN VALUE '&&',
      tab_field(100) type c,
      index         type i,
      l_index       type i.
data: begin of lt_data_tab occurs 0,
        zeile(500),
      end of lt_data_tab.
data: ld_tabix like sy-tabix.
data: ls_multi_select like se16n_selfields.

  FIELD-SYMBOLS:
    <FILENAME>.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
     EXPORTING
*      WINDOW_TITLE            =
       DEFAULT_EXTENSION       = 'TXT'
       DEFAULT_FILENAME        = LD_FILENAME
*       FILE_FILTER             = '*.TXT'
       INITIAL_DIRECTORY       = lD_PATH
*      MULTISELECTION          =
    CHANGING
       FILE_TABLE              = LT_FILETABLE
       RC                      = LD_RC
       USER_ACTION             = LD_USERACTION
     EXCEPTIONS
       FILE_OPEN_DIALOG_FAILED = 1
       CNTL_ERROR              = 2
       ERROR_NO_GUI            = 3
       NOT_SUPPORTED_BY_GUI    = 4
       OTHERS                  = 5.
  IF SY-SUBRC <> 0.
    MESSAGE S398(00) WITH
      'FILE_OPEN_DIALOG failed'                             "#EC NOTEXT
      'SUBRC =' SY-SUBRC ''.
    EXIT.
  ENDIF.
  CHECK LD_USERACTION = 0.
  CHECK LD_RC = 1.
  READ TABLE LT_FILETABLE INTO LD_FILE INDEX 1.
  LD_FILENAME = LD_FILE.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME                      = LD_FILENAME
*     FILETYPE                      = 'ASC'
*     FILETYPE                      = 'BIN'
      HAS_FIELD_SEPARATOR           = 'X'
*     HEADER_LENGTH                 = 0
    IMPORTING
      FILELENGTH                    = LD_FILELENGTH
*     HEADER                        =
    TABLES
      DATA_TAB                      = lt_data_tab
    EXCEPTIONS
      OTHERS                        = 1.
  IF SY-SUBRC <> 0.
    MESSAGE S398(00) WITH
      'GUI_UPLOAD failed'                                   "#EC *
      'SUBRC =' SY-SUBRC ''.
    EXIT.
  ELSE.
    MESSAGE S398(00) WITH 'Upload ok:'                      "#EC *
            LD_FILENAME 'Bytes:' LD_FILELENGTH.             "#EC *
  ENDIF.

  check sy-subrc = 0.

*.get the latest filled-line-option as default for the new lines
  ld_tabix = 0.
  loop at gt_multi_select
           where low    <> space
              or high   <> space
              or option <> space.
    add 1 to ld_tabix.
  endloop.
*  describe table gt_multi_select lines sy-tabix.
  if ld_tabix > 0.
    read table gt_multi_select into ls_multi_select index ld_tabix.
  else.
    ls_multi_select-option = gs_multi_sel-option.
  endif.

*.check if textfile may contain two columns
  ld_high = true.
  read table gt_sel_init with key option = gs_multi_sel-option.
  if sy-subrc         = 0 and
     gt_sel_init-high <> true.
     clear ld_high.
  endif.

*.delete unused lines
  DELETE gt_multi_select WHERE low IS INITIAL
                           AND high IS INITIAL
                           AND option IS INITIAL.

*.import always should refresh the old import!?!
*  refresh gt_multi_select.                                  "1712507
* use button "delete All Entries" instead
  MOVE-CORRESPONDING GS_MULTI_SEL TO GT_MULTI_SELECT.
  clear: gt_multi_select-low,
         gt_multi_select-high.
  GT_MULTI_SELECT-OPTION = ls_multi_select-option.
  if ls_multi_select-sign <> 'I' and
     ls_multi_select-sign <> space.
    gt_multi_select-sign = ls_multi_select-sign.
  else.
    gt_multi_select-sign = 'I'.
  endif.

  loop at lt_data_tab.
    clear tab_field.
    index = 1.
    while lt_data_tab-zeile ne space.
      perform split_text_at_sign using     trennzeichen
                                 changing  lt_data_tab-zeile
                                           tab_field.
      case index.
        when '1'.
          gt_multi_select-low = tab_field.
        when '2'.
          if ld_high = true.
             gt_multi_select-high = tab_field.
          endif.
      endcase.
      add 1 to index.
    endwhile.
    append gt_multi_select.
    clear: gt_multi_select-low,
           gt_multi_select-high.
  endloop.

*.do the PAI-Conversion of the input
  LOOP AT GT_MULTI_SELECT INTO GS_MULTI_SELECT.
     LD_TABIX = SY-TABIX.
     IF GS_MULTI_SELECT-LOW <> SPACE.
        PERFORM CONVERT_TO_INTERN USING    space
                                  CHANGING GS_MULTI_SELECT
                                           GS_MULTI_SELECT-LOW.
     ENDIF.
     IF GS_MULTI_SELECT-HIGH <> SPACE.
        PERFORM CONVERT_TO_INTERN USING    space
                                  CHANGING GS_MULTI_SELECT
                                           GS_MULTI_SELECT-HIGH.
     ENDIF.
     MODIFY GT_MULTI_SELECT FROM GS_MULTI_SELECT INDEX LD_TABIX.
  ENDLOOP.

ENDFORM.                    " import_from_textfile
*&---------------------------------------------------------------------*
*&      Form  split_text_at_sign
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TRENNZEICHEN  text
*      <--P_LT_DATA_TAB_ZEILE  text
*      <--P_TAB_FIELD  text
*----------------------------------------------------------------------*
form split_text_at_sign using    p_trennzeichen
                        changing p_data_tab-zeile
                                 p_tab_field.
  data: pos like sy-fdpos,
        dummy(500) type c.

  if p_data_tab-zeile cs p_trennzeichen.
    pos = sy-fdpos.
    if pos gt 0.
      move p_data_tab-zeile(pos) to p_tab_field.
      pos = pos + 2.
      move p_data_tab-zeile+pos to p_data_tab-zeile.
    else.
      p_tab_field = space.
      move p_data_tab-zeile+2 to p_data_tab-zeile.
    endif.
  else.
    p_tab_field = p_data_tab-zeile.
    clear p_data_tab-zeile.
  endif.

endform.                               " SPLIT_TEXT_AT_SIGN
*&---------------------------------------------------------------------*
*&      Form  multi_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM multi_f4 .

data: ld_low(1).
data: ld_field(60).

   get cursor field ld_field.
   if ld_field = 'GS_MULTI_SELECT-LOW'.
      ld_low = true.
   elseif ld_field = 'GS_MULTI_SELECT-HIGH'.
      clear ld_low.
   else.
      ld_low = true.
   endif.
   perform field_f4_multi using ld_low true.

ENDFORM.                    " multi_f4
*&---------------------------------------------------------------------*
*&      Form  scan_selfields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_SELFIELDS  text
*      -->P_I_TAB  text
*      -->P_I_MAX_LINES  text
*      -->P_I_LINE_DET  text
*      -->P_I_DISPLAY  text
*      -->P_I_CLNT_SPEZ  text
*      <--P_LD_SUBRC  text
*      <--P_LD_PARTIAL  text
*----------------------------------------------------------------------*
FORM scan_selfields USING    value(TAB)
                             value(i_max_lines)
                             value(i_line_det)
                             value(i_display_all)
                             value(i_clnt_spez)
                    changing value(subrc)
                             value(ld_partial)
                             value(ld_abort).

data: lt_where(72) occurs 0 with header line.
data: lt_sel      like se16n_seltab occurs 0 with header line.
data: lt_sel_all  like se16n_seltab occurs 0 with header line.
data: lt_sel_sel  like se16n_seltab occurs 0 with header line.
data: ls_or_seltab type SE16N_OR_SELTAB.
data: ld_tabix    like sy-tabix.
data: ld_tabix2   like sy-tabix.
data: ld_split    like sy-tabix.
DATA: ld_enough(1).
data: begin of lt_count occurs 0,
        field like se16n_seltab-field,
        count like sy-tabix,
        eq(1),
        neq(1),
      end of lt_count.
data: ld_selmax like t811flags-valmin.
constants: c_split like sy-tabix value 200.

  read table gt_or index 1 into ls_or_seltab.
  append lines of ls_or_seltab-seltab to lt_sel.

  describe table lt_sel lines ld_tabix.
*.more than xxx selection criteria -> try to split the select

*.get max threshold
  select single valmin from t811flags into ld_selmax
           where tab   = 'SE16H'
             and field = 'SELFIELDS_MAX'.
*.no value maintained
  if sy-subrc <> 0.
    if gd-hana_active = true.
       ld_selmax = 5000.
    else.
       ld_selmax = c_split.
    endif.
*.set default
  else.
    if ld_selmax is initial or
       ld_selmax <= 0.
       ld_selmax = c_split.
    endif.
  endif.

  if ld_tabix > ld_selmax.
    gt_sel[] = lt_sel[].
    loop at lt_sel.
      clear lt_count.
      read table lt_count with key field = lt_sel-field.
      if sy-subrc = 0.
        add 1 to lt_count-count.
        if ( lt_sel-sign   = 'I' and
             ( lt_sel-option = 'EQ' or
               lt_sel-option = 'BT' or
               lt_sel-option = space ) ).
          lt_count-eq = true.
        else.
          lt_count-neq = true.
        endif.
        modify lt_count index sy-tabix.
      else.
        lt_count-count = 1.
        if ( lt_sel-sign   = 'I' and
             ( lt_sel-option = 'EQ' or
               lt_sel-option = 'BT' or
               lt_sel-option = space ) ).
          lt_count-eq = true.
        else.
          lt_count-neq = true.
        endif.
        lt_count-field = lt_sel-field.
        append lt_count.
      endif.
    endloop.
    sort lt_count by count descending.
*...the first line contains the one with the most entries
    read table lt_count index 1.
*...if option is not always the same -> not possible
    if lt_count-neq = true.
      if sy-batch <> true.
         message i133(wusl).
      endif.
      clear ld_partial.
    else.
      ld_partial = true.
*.....selection criteria for all selects
      loop at lt_sel where field <> lt_count-field.
        ld_tabix2 = sy-tabix.
        append lt_sel to lt_sel_all.
        delete lt_sel index ld_tabix2.
      endloop.
      lt_sel_sel[] = lt_sel_all[].
*.....lt_sel now only contains the criteria to be splitted
      ld_split = 0.
      refresh <all_table>.
      refresh gt_where.
      clear gd-number.
      subrc = 4.
      loop at lt_sel.
        if ld_split = c_split.
          clear ld_enough.
          perform partial_select tables lt_sel_sel
                                 using  tab
                                        i_line_det
                                        i_display_all
                                        i_clnt_spez
                                        i_max_lines
                                 changing subrc
                                          ld_enough
                                          ld_abort.
          if ld_enough = true or
             ld_abort  = true.
             exit.
          endif.
          refresh lt_sel_sel.
          lt_sel_sel[] = lt_sel_all[].
          clear ld_split.
        endif.
        append lt_sel to lt_sel_sel.
        add 1 to ld_split.
      endloop.
*.....last ones
      if ld_enough <> true and
         ld_abort <> true.
         perform partial_select tables lt_sel_sel
                             using  tab
                                    i_line_det
                                    i_display_all
                                    i_clnt_spez
                                    i_max_lines
                             changing subrc
                                      ld_enough
                                      ld_abort.
      endif.
      if gt_order_by_fields[] is initial.
         sort <all_table>.
      endif.
    endif.
 else.
    clear ld_partial.
 endif.
 gd-partial = ld_partial.

ENDFORM.                    " scan_selfields

*&---------------------------------------------------------------------*
*&      Form  partial_select
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_SEL_SEL  text
*      -->P_I_LINE_DET  text
*      -->P_I_DISPLAY  text
*      -->P_I_CLNT_SPEZ  text
*      -->P_I_MAX_LINES  text
*      <--P_SUBRC  text
*----------------------------------------------------------------------*
FORM partial_select TABLES   LT_SEL_SEL STRUCTURE se16n_seltab
                    USING    value(tab)
                             value(I_LINE_DET)
                             value(I_DISPLAY_all)
                             value(I_CLNT_SPEZ)
                             value(I_MAX_LINES)
                    CHANGING value(SUBRC)
                             value(p_enough)
                             value(p_abort).


data: lt_where(72) occurs 0 with header line.
data: field      type string,
      t_field    type table of string,
      t_order_by type table of string,
      t_group_by type table of string.

*.new centralized select routine
  perform partial_select_new tables   lt_sel_sel
                             using    tab
                                      i_line_det
                                      i_display_all
                                      i_clnt_spez
                                      i_max_lines
                             changing subrc
                                      p_enough
                                      p_abort.
  exit.

          CALL FUNCTION 'SE16N_CREATE_SELTAB'
             EXPORTING
                  i_pool   = gd-pool
                  i_primary_table = true
             TABLES
                  LT_SEL   = lt_sel_sel
                  LT_WHERE = lt_where.

***************************************************************
*.Four cases possible
*.1. normal select on normal database
*.2. group-by select on normal database
*.3. normal select on alternate database
*.4. group-by select on alternate database
***************************************************************

*.normal DB******************************************************
  if gd-dbcon = space.
    loop at gt_order_by_fields.
*......in case special sorting is requested, add it.
       read table gt_toplow_fields
              with key field = gt_order_by_fields-field.
       if sy-subrc = 0.
          if gt_toplow_fields-low = 'ASC'.
            concatenate gt_toplow_fields-low 'ENDING'
                   into gt_toplow_fields-low.
          else.
            concatenate gt_toplow_fields-low 'CENDING'
                   into gt_toplow_fields-low.
          endif.
          concatenate gt_order_by_fields-field gt_toplow_fields-low
                    into gt_order_by_fields-field separated by space.
       endif.
       append gt_order_by_fields-field to t_order_by.
    endloop.
    if not gt_sum_up_fields[] is initial or
       not gt_group_by_fields[] is initial or
       not gt_aggregate_fields[] is initial.
*.....new group-by select
      loop at gt_group_by_fields.
         append gt_group_by_fields-field to t_group_by.
         append gt_group_by_fields-field to t_field.
      endloop.
      loop at gt_sum_up_fields.
         field =
   |SUM( { gt_sum_up_fields-field } ) as { gt_sum_up_fields-field } |.
         append field to t_field.
      endloop.
      loop at gt_aggregate_fields.
        concatenate gt_aggregate_fields-low '(' into field.
        concatenate field gt_aggregate_fields-field ') as'
                     gt_aggregate_fields-field into field
                     separated by space.
        append field to t_field.
      endloop.
      field = |COUNT( * ) as { c_line_index } |.
      append field to t_field.
*...if no grouping select all fields
    else.
      field = '*'.
      append field to t_field.
    endif.
      if i_line_det <> true.
*.......check if max number of lines is reached
        if i_max_lines > 0.
           DESCRIBE TABLE <ALL_TABLE> LINES SY-TABIX.
           I_MAX_LINES = I_MAX_LINES - SY-TABIX.
           IF I_MAX_LINES < 1.
              P_ENOUGH = TRUE.
              EXIT.
           ENDIF.
        endif.
        if i_display_all = space.
          if i_clnt_spez = true.
            gd-select_type = 'A'.
            SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED
                up to i_max_lines rows
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          else.
            gd-select_type = 'B'.
            SELECT (t_field) FROM (tab) up to i_max_lines rows
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          endif.
*.......If no display, select everything
        else.
          if i_clnt_spez = true.
            gd-select_type = 'C'.
            SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          else.
            gd-select_type = 'D'.
            SELECT (t_field) FROM (tab)
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          endif.
        endif.
*.Only determine the number of found entries
      else.
        if i_clnt_spez = true.
          gd-select_type = 'E'.
          SELECT count(*) FROM (tab)
               CLIENT SPECIFIED
               bypassing buffer
               WHERE (lt_where).
        else.
          gd-select_type = 'F'.
          SELECT count(*) FROM (tab)
               bypassing buffer
               WHERE (lt_where).
        endif.
      endif.
*.alternate DB******************************************************
  else.
    loop at gt_order_by_fields.
*......in case special sorting is requested, add it.
       read table gt_toplow_fields
              with key field = gt_order_by_fields-field.
       if sy-subrc = 0.
          if gt_toplow_fields-low = 'ASC'.
            concatenate gt_toplow_fields-low 'ENDING'
                   into gt_toplow_fields-low.
          else.
            concatenate gt_toplow_fields-low 'CENDING'
                   into gt_toplow_fields-low.
          endif.
          concatenate gt_order_by_fields-field gt_toplow_fields-low
                    into gt_order_by_fields-field separated by space.
       endif.
       append gt_order_by_fields-field to t_order_by.
    endloop.
*...Group-by select**********************************************
    if not gt_sum_up_fields[] is initial or
       not gt_group_by_fields[] is initial or
       not gt_aggregate_fields[] is initial.
*......new group-by select
      loop at gt_group_by_fields.
         append gt_group_by_fields-field to t_group_by.
         append gt_group_by_fields-field to t_field.
      endloop.
      loop at gt_sum_up_fields.
         field =
   |SUM( { gt_sum_up_fields-field } ) as { gt_sum_up_fields-field } |.
         append field to t_field.
      endloop.
      loop at gt_aggregate_fields.
        concatenate gt_aggregate_fields-low '(' into field.
        concatenate field gt_aggregate_fields-field ') as'
                     gt_aggregate_fields-field into field
                     separated by space.
        append field to t_field.
      endloop.
      field = |COUNT( * ) as { c_line_index } |.
      append field to t_field.
*...if no grouping select all fields
    else.
      field = '*'.
      append field to t_field.
    endif.
      if i_line_det <> true.
*.......check if max number of lines is reached
        if i_max_lines > 0.
           DESCRIBE TABLE <ALL_TABLE> LINES SY-TABIX.
           I_MAX_LINES = I_MAX_LINES - SY-TABIX.
           IF I_MAX_LINES < 1.
              P_ENOUGH = TRUE.
              EXIT.
           ENDIF.
        endif.
        if i_display_all = space.
          if i_clnt_spez = true.
            gd-select_type = 'K'.
*...........in case of summation use parallel aggregation
            if gt_sum_up_fields[] is initial.
              SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED connection (gd-dbcon)
                up to i_max_lines rows
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
            else.
              SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED connection (gd-dbcon)
                up to i_max_lines rows
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by)
                %_HINTS ADABAS 'dbsl_add_stmt with parameters ' &
                       '(''request_flags''=''ANALYZE_MODEL'', ' &
                       '''request_flags''=''OLAP_PARALLEL_AGGREGATION'')'.
            endif.
          else.
            gd-select_type = 'L'.
*...........in case of summation use parallel aggregation
            if gt_sum_up_fields[] is initial.
              SELECT (t_field) FROM (tab) connection (gd-dbcon)
                up to i_max_lines rows
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
            else.
              SELECT (t_field) FROM (tab) connection (gd-dbcon)
                up to i_max_lines rows
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by)
                %_HINTS ADABAS 'dbsl_add_stmt with parameters ' &
                       '(''request_flags''=''ANALYZE_MODEL'', ' &
                       '''request_flags''=''OLAP_PARALLEL_AGGREGATION'')'.
            endif.
          endif.
*.......If no display, select everything
        else.
          if i_clnt_spez = true.
            gd-select_type = 'M'.
            SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED connection (gd-dbcon)
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          else.
            gd-select_type = 'N'.
            SELECT (t_field) FROM (tab) connection (gd-dbcon)
                appending corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          endif.
        endif.
*.Only determine the number of found entries
          else.
            if i_clnt_spez = true.
              gd-select_type = 'O'.
              SELECT count(*) FROM (tab)
                CLIENT SPECIFIED connection (gd-dbcon)
               bypassing buffer
               WHERE (lt_where).
        else.
          gd-select_type = 'P'.
          SELECT count(*) FROM (tab) connection (gd-dbcon)
               bypassing buffer
               WHERE (lt_where).
        endif.
      endif.
  endif.
****************************************************************************
  gd-number = gd-number + sy-dbcnt.
  gt_field[] = t_field[].
  append lines of lt_where to gt_where.

  gd-count  = gd-number.
  if subrc = 4.
     subrc = sy-subrc.
  endif.
  if i_line_det <> true.
*.check if max number of lines is reached
     if gd-max_lines > 0 and
        GD-NUMBER    >= GD-MAX_LINES.
        P_ENOUGH = TRUE.
     ENDIF.
  endif.

endform.
*&---------------------------------------------------------------------*
*&      Form  search_fieldname
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_fieldname .

DATA: LD_FIELDNAME LIKE GT_SELFIELDS-FIELDNAME.
DATA: LT_FIELDS    LIKE SVAL OCCURS 0 WITH HEADER LINE.
DATA: LD_rcode(1).
data: ld_found(1).
data: line_no      like sy-tabix.
data: ld_tabix     like sy-tabix.
statics: s_value type SPO_VALUE.

 if save_ok_code = 'SUCH'.
    line_no = 1.
    LT_FIELDS-TABNAME   = 'SE16N_SELFIELDS'.
    LT_FIELDS-FIELDNAME = 'FIELDNAME'.
    APPEND LT_FIELDS.
    CALL FUNCTION 'POPUP_GET_VALUES'
       EXPORTING
              POPUP_TITLE = text-s01
       IMPORTING
              RETURNCODE  = LD_RCODE
       TABLES
              FIELDS      = LT_FIELDS
       EXCEPTIONS
              OTHERS      = 1.
    CHECK: SY-SUBRC = 0.
    CHECK: LD_RCODE = space.
    READ TABLE LT_FIELDS INDEX 1.
    s_value = lt_fields-value.
 else.
    GET CURSOR LINE line_no.
    IF line_no = 0. line_no = 1. ENDIF.
    line_no = selfields_tc-current_line + line_no.
    IF line_no = 0. line_no = 1. ENDIF.
 endif.
 clear ld_found.
 check: s_value <> space.
 loop at gt_selfields from line_no.
    translate gt_selfields-SCRTEXT_M to upper case.      "#EC TRANSLANG
    if gt_selfields-fieldname cs s_value or
       gt_selfields-SCRTEXT_M cs s_value.
       ld_found = true.
       ld_tabix = sy-tabix.
       exit.
    endif.
 endloop.
 IF ld_found = true.
    SELFIELDS_TC-TOP_LINE = ld_TABIX.
 else.
    message s555(kz) with s_value text-s02.
 ENDIF.


ENDFORM.                    " search_fieldname

*&---------------------------------------------------------------------*
*&      Form  import_from_clipboard
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM import_from_clipboard .

  data: ld_high(1).
  data: trennzeichen(2) type c value '&&', "TRENNZEICHEN VALUE '&&',
        index           type i,
        tab_field(100)  type c.
  data: ld_tabix        like sy-tabix.
  data: begin of lt_data_tab occurs 1,
      zeile(500) type c,
      end of lt_data_tab.
  data: file_table type filetable,
        rc type i,
        filedat type string.
  data: file_table_clip type standard table of file_table.
  data: ls_multi_select like se16n_selfields.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_IMPORT
        IMPORTING
          DATA                 = file_table_clip.
  lt_data_tab[] = file_table_clip[].

*.get the latest filled-line-option as default for the new lines
  clear ld_tabix.
  LOOP AT gt_multi_select
         WHERE low    <> space
            OR high   <> space
            OR option <> space.
    add 1 to ld_tabix.
  ENDLOOP.
*  describe table gt_multi_select lines sy-tabix.
  if ld_tabix > 0.
    read table gt_multi_select into ls_multi_select index ld_tabix.
  else.
    ls_multi_select-option = gs_multi_sel-option.
  endif.

*.check if textfile may contain two columns
  ld_high = true.
*  read table gt_sel_init with key option = gs_multi_sel-option.
  read table gt_sel_init with key option = ls_multi_select-option.
  if sy-subrc         = 0 and
     gt_sel_init-high <> true.
     clear ld_high.
  endif.

*.import always should refresh the old import -> like in SE16 !
*.do not refresh anymore -> in the future perhaps a second
*.icon or a set-parameter
*  refresh gt_multi_select.

*.delete unsued lines
  DELETE gt_multi_select WHERE low IS INITIAL
                           AND high IS INITIAL
                           AND option IS INITIAL.

  MOVE-CORRESPONDING GS_MULTI_SEL TO GT_MULTI_SELECT.
  clear: gt_multi_select-low,
         gt_multi_select-high.
  if ls_multi_select-sign <> 'I' and
     ls_multi_select-sign <> space.
    gt_multi_select-sign = ls_multi_select-sign.
  else.
    gt_multi_select-sign = 'I'.
  endif.
  if ls_multi_select-option <> space.
    gt_multi_select-option = ls_multi_select-option.
  endif.

  loop at lt_data_tab.
    clear tab_field.
    index = 1.
    while lt_data_tab-zeile ne space.
      perform split_text_at_sign using     trennzeichen
                                 changing  lt_data_tab-zeile
                                           tab_field.
      case index.
        when '1'.
*.........in case of datatype SSTRING, outputlen is 0
          if gt_multi_select-outputlen > 132 or
             gt_multi_select-outputlen = 0.
            gt_multi_select-low(132) = tab_field.
          else.
            gt_multi_select-low(gt_multi_select-outputlen)
                                         = tab_field.
          endif.
        when '2'.
          if ld_high = true.
             if gt_multi_select-outputlen > 132 or
                gt_multi_select-outputlen = 0.
                gt_multi_select-high(132) = tab_field.
             else.
                gt_multi_select-high(gt_multi_select-outputlen)
                                          = tab_field.
             endif.
          endif.
      endcase.
      add 1 to index.
    endwhile.
    append gt_multi_select.
    clear: gt_multi_select-low,
           gt_multi_select-high.
  endloop.

*.do the PAI-Conversion of the input
  LOOP AT GT_MULTI_SELECT INTO GS_MULTI_SELECT.
     LD_TABIX = SY-TABIX.
     IF GS_MULTI_SELECT-LOW <> SPACE.
        PERFORM CONVERT_TO_INTERN USING    space
                                  CHANGING GS_MULTI_SELECT
                                           GS_MULTI_SELECT-LOW.
     ENDIF.
     IF GS_MULTI_SELECT-HIGH <> SPACE.
        PERFORM CONVERT_TO_INTERN USING    space
                                  CHANGING GS_MULTI_SELECT
                                           GS_MULTI_SELECT-HIGH.
     ENDIF.
     MODIFY GT_MULTI_SELECT FROM GS_MULTI_SELECT INDEX LD_TABIX.
  ENDLOOP.

ENDFORM.                    " import_from_clipboard
*&---------------------------------------------------------------------*
*&      Form  get_option
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_SEL_SIGN  text
*      -->P_LT_SEL_OPTION  text
*      -->P_LT_SEL_LOW  text
*      -->P_LT_SEL_HIGH  text
*      <--P_LS_SELOPT_OPTION  text
*----------------------------------------------------------------------*
FORM get_option  USING    value(p_sign)
                          value(p_OPTION)
                          value(p_HIGH)
                          value(p_escape_char)
                          value(p_fieldname)
                          value(i_pool)
                 CHANGING value(r_OPTION)
                          value(p_LOW).

data: ld_low_cp(1),
      ld_high_cp(1).
data: ld_tab       TYPE  DDOBJNAME.
data: ld_FIELDNAME TYPE  DFIES-LFIELDNAME.

data: ls_dfies like dfies.

  if p_sign = space.
     p_sign = opt-i.
  endif.

*.in case pattern is used, this is only possible for
*.CHAR and NUMC. All others lead to problems
*.--> Note 1247226
*.Check if field is of Character-Type
  if not gd-tab is initial.
     ld_tab = gd-tab.
     ld_fieldname = p_fieldname.
     CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
         TABNAME              = ld_tab
         LFIELDNAME           = ld_fieldname
       IMPORTING
         DFIES_WA             = ls_dfies
       EXCEPTIONS
         NOT_FOUND            = 1
         INTERNAL_ERROR       = 2
         OTHERS               = 3.
     IF SY-SUBRC = 0.
*.......check if character type otherwise ignore pattern
        if not ( ls_dfies-inttype = 'C' or
                 ls_dfies-inttype = 'N' ).
           p_escape_char = 'X'.
        endif.
     ENDIF.
  endif.

  if ( p_low cs '*' or
     p_low cs '+') and ( p_escape_char <> 'X' ).
     ld_low_cp = true.
  endif.
*****************************************************************
*.CP and escape symbol would lead to short dump --> MO401
*.Example: Table TRWPR cannot be selected with FM_DOCUMENT_POST*
*.replace _ and % by + and try to get results
*****************************************************************
  If i_pool    = true and
     p_low     cs '_' and
     ld_low_cp = true.
     SY-SUBRC = 0.
     WHILE SY-SUBRC = 0.
        REPLACE '_' WITH '+' INTO p_low.
     ENDWHILE.
  Endif.
  If i_pool    = true and
     p_low     cs '%' and
     ld_low_cp = true.
     SY-SUBRC = 0.
     WHILE SY-SUBRC = 0.
        REPLACE '%' WITH '+' INTO p_low.
     ENDWHILE.
  Endif.

  if p_option = space.
     if p_high <> space and
        p_low <> p_high.
        r_option = opt-bt.
     endif.
*     if ld_low_cp = true.                                     "1686242
     if ld_low_cp = true and p_high is initial.                "1686242
        r_option = opt-cp.
     endif.
     if r_option = space.
        r_option = opt-eq.
     endif.
  else.
*....with the new logic according note 1398668 the user can decide
*....how '*' should be used --> always take the option
     r_option = p_option.
  endif.
  if r_option = space.
     r_option = opt-eq.
  endif.

ENDFORM.                    " get_option
*&---------------------------------------------------------------------*
*&      Form  check_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_input .

data: ld_tabix like sy-tabix.

  loop at gt_multi_select
                  where sign   = 'I'
                    and option = 'NE'
                    and not low is initial.
     add 1 to ld_tabix.
  endloop.
  if ld_tabix > 1.
     message i095(db).
  endif.

ENDFORM.                    " check_input
*&---------------------------------------------------------------------*
*&      Form  READ_EXIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_EXIT_DATA using value(p_event) .

data: lt_cb_events type se16n_exit occurs 0.
data: ls_cb_events type se16n_exit.

*....if event already exists - go out
     read table gt_cb_events with key
               callback_event = p_event transporting no fields.
     if sy-subrc = 0.
        exit.
     endif.

*....allow regular expressions in SE16N_EXIT
     gd-add_fields = false.

     select * from se16n_exit into ls_cb_events
                where callback_event = p_event.

       if matches( val = gd-tab regex = ls_cb_events-tab ).

         append ls_cb_events to gt_cb_events.
         gd-add_fields = true.
         exit.

       endif.

     endselect.
     exit.

***
*
**....to allow *-entry in SE16N_Exit use special logic
**....first try explicit select
*     select * from se16n_exit into table lt_cb_events
*                where tab            = gd-tab
*                  and callback_event = p_event.
**....explicit entry found
*     if sy-subrc = 0.
*        gd-add_fields = true.
*     else.
**.......try if *-entry is there
*        select * from se16n_exit into table lt_cb_events
*                where callback_event = p_event.
*        if sy-subrc = 0.
*          loop at lt_cb_events into ls_cb_events.
*            if ls_cb_events-tab cs '*'.
*              REPLACE '*' WITH '' INTO ls_cb_events-tab.
*              if gd-tab cs ls_cb_events-tab.
**................ok
*              else.
*                 delete lt_cb_events index sy-tabix.
*              endif.
*            else.
*               delete lt_cb_events index sy-tabix.
*            endif.
*          endloop.
*          if not lt_cb_events[] is initial.
*             gd-add_fields = true.
*          else.
*             gd-add_fields = space.
*          endif.
*        else.
*          gd-add_fields = space.
*        endif.
*     endif.
*     append lines of lt_cb_events to gt_cb_events.

ENDFORM.                    " READ_EXIT_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_TABLE_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_TAB  text
*      <--P_LD_CHANGE  text
*----------------------------------------------------------------------*
FORM CHECK_TABLE_CHANGE  USING value(P_TAB).

data: ld_tab type se16n_tab.
data: ld_var1(1).
data: ld_var2(1).
data: ld_var3(1).

  define makro_fill_tab.
     concatenate &1 &2 &3 &4 &5 &6 into ld_tab.
     if &7 = ld_tab.
        clear: gd-edit, gd-sapedit.
        message i103(wusl).
     endif.
  end-of-definition.

  ld_var1 = c_7 - 1.
  ld_var2 = c_9 - 1.
  ld_var3 = c_3 - 1.

  makro_fill_tab sy-abcde+19(1) ld_var1 ld_var2 ld_var3 space
                 space p_tab.
  makro_fill_tab sy-abcde+19(1) ld_var1 ld_var2 ld_var3 sy-abcde+8(1)
                 space p_tab.
  makro_fill_tab sy-abcde+19(1) ld_var1 ld_var2 ld_var3 sy-abcde+19(1)
                 space p_tab.
  makro_fill_tab sy-abcde+19(1) ld_var1 ld_var2 ld_var3 sy-abcde+21(1)
                 space p_tab.
  makro_fill_tab sy-abcde+19(1) ld_var1 ld_var2 ld_var3 sy-abcde+25(1)
                 space p_tab.
  makro_fill_tab sy-abcde+10(1) sy-abcde+14(1) sy-abcde+13(1)
                 sy-abcde+15(1) space space p_tab.
*.new 1
  makro_fill_tab sy-abcde+19(1) ld_var1 ld_var2 ld_var3 sy-abcde+8(1)
                 sy-abcde+0(1) p_tab.
*.new 2
  makro_fill_tab sy-abcde+19(1) ld_var1 ld_var2 ld_var3 sy-abcde+25(1)
                 sy-abcde+0(1) p_tab.

  if p_tab = c_cd_tab1 or
     p_tab = c_cd_tab2 or
     p_tab = c_cd_tab3 or
     p_tab = 'TRDIR'  ##NO_TEXT.
     clear: gd-edit, gd-sapedit.
     message i103(wusl).
  endif.

ENDFORM.                    " CHECK_TABLE_CHANGE
*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXCLUDE_DISPLAY .

  distab-fcode = 'APPEND'.
  append distab.
  distab-fcode = 'DELE'.
  append distab.
  distab-fcode = 'DELE_ALL'.
  append distab.
  distab-fcode = 'MULTI_F4'.
  append distab.
  distab-fcode = 'IMPORT'.
  append distab.
  distab-fcode = 'CLIPBOARD'.
  append distab.


ENDFORM.                    " EXCLUDE_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_MULTI_SELECT  text
*      <--P_GS_MULTI_SELECT_LOW  text
*      <--P_LD_VALID  text
*----------------------------------------------------------------------*
FORM CHECK_INPUT_EXIT  USING    value(p_exit_func)
                       CHANGING P_struc structure se16n_selfields
                                p_low   like se16n_selfields-low
                                p_high  like se16n_selfields-high
                                P_VALID
                                P_MESG  structure smesg.

  clear p_mesg.
  p_valid = 0.
  if p_exit_func <> space.
     CALL FUNCTION 'RH_FUNCTION_EXIST'
         EXPORTING
           NAME               = p_exit_func
         EXCEPTIONS
           FUNCTION_NOT_FOUND = 1
           OTHERS             = 2.
     IF SY-SUBRC <> 0.
*.......Funktionsbaustein & ist noch nicht vorhanden
        MESSAGE i110(FL) WITH p_exit_func.
        exit.
     ENDIF.
*....function module can validate the input value
*....p_struc contains sign, option and all DDIC-Info
*....p_valid should be 0 in case the input is fine
*....and it should be 4 in case the value is wrong
*....structure e_mesg can contain a specific message if wanted
     call function p_exit_func
       EXPORTING
         i_se16n_selfields = p_struc
         i_low             = p_low
         i_high            = p_high
       IMPORTING
         E_valid           = p_valid
         e_mesg            = p_mesg.
  endif.

ENDFORM.                    " CHECK_INPUT_EXIT
*&---------------------------------------------------------------------*
*&      Form  DBCON_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DBCON_F4 changing value(tab).

data: begin of lt_hana occurs 0,
        table_name   type tabname,
        table_type   like dd02l-tabclass,
*       record_count type SIN_CNTTXT,  " like sy-tabix,
      end of lt_hana.
data: begin of ls_m_tables,
        table_name type tabname,
        record_count like sy-tabix,
      end of ls_m_tables.
data: ld_tab   type tabname.
data: ld_tabix like sy-tabix.
data: ld_reset type c.
data: begin of lt_views occurs 0,
        cube_name type string,
      end of lt_views.
data: P_ERR         TYPE REF TO  CX_SY_NATIVE_SQL_ERROR.
data: lt_RETURN_TAB like DDSHRETVAL occurs 0 with header line.
data: ld_schema     type string.
data: lt_tables     TYPE table of tabname.
data: ls_tables     type tabname.
data: ld_dbcon_error(1).
constants: c_tables_get like tfdir-funcname value 'HDB_TABLE_GET_ALL'.
constants: c_views_get  like tfdir-funcname value 'HDB_VIEW_GET_ALL'.

constants: c_max like sy-tabix value '200'.

  check: gd-dbcon <> space.

*.check if service functions are available
  CALL FUNCTION 'RH_FUNCTION_EXIST'
    EXPORTING
      NAME                     = c_tables_get
    EXCEPTIONS
      FUNCTION_NOT_FOUND       = 1
      OTHERS                   = 2.

  IF SY-SUBRC = 0.
*....set dbcon if it differs from the customizing one
     PERFORM SET_CONNECTION IN PROGRAM SAPLHDB_SERVICE if found
       USING
         GD-DBCON
       CHANGING
         LD_DBCON_ERROR.
     refresh lt_tables.
     CALL FUNCTION c_tables_get
       EXPORTING
         I_ONLY_ERP_TABLES     = true
       IMPORTING
         ET_TABLE              = lt_tables
       EXCEPTIONS
         DBCON_NOT_EXIST       = 1
         DBCON_NO_USE          = 2
         DBCON_ERROR           = 3
         HDB_ERROR             = 4
         OTHERS                = 5.
     IF SY-SUBRC = 0.
        loop at lt_tables into ls_tables.
           lt_hana-table_type = text-ha1.
           lt_hana-table_name = ls_tables.
           append lt_hana.
        endloop.
     ENDIF.
     refresh lt_tables.
     CALL FUNCTION c_views_get
       EXPORTING
         I_ONLY_ERP_VIEWS      = true
       IMPORTING
         ET_VIEW               = lt_tables
       EXCEPTIONS
         DBCON_NOT_EXIST       = 1
         DBCON_NO_USE          = 2
         DBCON_ERROR           = 3
         HDB_ERROR             = 4
         OTHERS                = 5.
     IF SY-SUBRC = 0.
        loop at lt_tables into ls_tables.
           lt_hana-table_type = text-ha2.
           lt_hana-table_name = ls_tables.
           append lt_hana.
        endloop.
     ENDIF.
  ELSE.
*.use old logic
     perform get_dbcon_schema changing ld_schema.
     check: ld_schema <> space.

     exec sql.
       CONNECT TO :GD-DBCON
     endexec.

*....if gd-tab contains a normal value, do not take it
     if gd-tab <> space and
        gd-tab cs '*'.
        ld_tab = gd-tab.
        WHILE SY-SUBRC = 0.
           REPLACE '*' WITH '%' INTO ld_tab.
        ENDWHILE.
     else.
        ld_tab = '%'.
     endif.

*....first table definitions 'SYSTEM'
     TRY.
        exec sql.
          open dbcur for
          SELECT TABLE_NAME, RECORD_COUNT FROM M_TABLES
             WHERE TABLE_NAME like :ld_tab
               AND SCHEMA_NAME = :ld_schema
        endexec.
*            FETCH NEXT dbcur INTO :lt_hana-table_name
*FETCH NEXT dbcur INTO :ls_m_tables
        DO.
          EXEC SQL.
            FETCH NEXT dbcur INTO :ls_m_tables
          ENDEXEC.
          IF sy-subrc = 0.
            read table lt_hana with key
                   table_name = ls_m_tables-table_name.
            if sy-subrc <> 0.
               lt_hana-table_type   = text-ha1.
               lt_hana-table_name   = ls_m_tables-table_name.
*              lt_hana-record_count = ls_m_tables-record_count.
               append lt_hana.
            endif.
            describe table lt_hana lines ld_tabix.
            if ld_tabix > c_max.
              exit.
            endif.
          else.
            exit.
          ENDIF.
        ENDDO.
        EXEC SQL.
          CLOSE dbcur
        ENDEXEC.
        CATCH CX_SY_NATIVE_SQL_ERROR into p_err.
        MESSAGE i555(KZ) WITH P_ERR->SQLMSG RAISING ERROR.
     ENDTRY.
*....secondly view definitions
     clear lt_hana.
     TRY.
        exec sql.
         open dbcur for
         select name from sys.rs_views_
            where SCHEMA = :ld_schema
              and name like :ld_tab
        endexec.
        DO.
          EXEC SQL.
            FETCH NEXT dbcur INTO :lt_hana-table_name
          ENDEXEC.
          IF sy-subrc = 0.
            lt_hana-table_type = text-ha2.
            collect lt_hana.
            describe table lt_hana lines ld_tabix.
            if ld_tabix > c_max.
               exit.
            endif.
          else.
            exit.
          ENDIF.
        ENDDO.
        EXEC SQL.
         CLOSE dbcur
        ENDEXEC.
        CATCH CX_SY_NATIVE_SQL_ERROR into p_err.
           MESSAGE i555(KZ) WITH P_ERR->SQLMSG RAISING ERROR.
     ENDTRY.
     exec sql.
       disconnect :gd-dbcon
     endexec.
  endif.

  sort lt_hana by table_type table_name.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD               = 'TABLE_NAME'
      VALUE_ORG              = 'S'
    IMPORTING
      USER_RESET             = ld_reset
    TABLES
      VALUE_TAB              = lt_hana
      RETURN_TAB             = lt_return_tab
    EXCEPTIONS
      PARAMETER_ERROR        = 1
      NO_VALUES_FOUND        = 2
      OTHERS                 = 3.

  IF SY-SUBRC = 0.
     read table lt_return_tab index 1.
     if sy-subrc = 0.
        gd-tab = lt_return_tab-fieldval.
        tab    = gd-tab.
        perform check_hana_table.
     endif.
  ENDIF.


ENDFORM.                    " DBCON_F4
*&---------------------------------------------------------------------*
*&      Form  CHECK_HANA_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_HANA_TABLE .

data: ld_count type string.
data: ld_name  type string.
data: ld_no_tab(1).
data: P_ERR    TYPE REF TO  CX_SY_NATIVE_SQL_ERROR.
data: ld_1     type decfloat34.
data: ld_lines type c length 20.
data: ld_schema type string.
data: lr_object TYPE RANGE OF adbc_name.
data: ls_object like line of lr_object.
data: lt_tables TYPE table of tabname.
data: ld_exist(1).
data: ld_hdb_count(20) type n.
data: ld_dbcon_error(1).
constants: c_tables_get like tfdir-funcname value 'HDB_TABLE_GET_INFO'.
constants: c_views_get  like tfdir-funcname value 'HDB_VIEW_GET_ALL'.

*.check if service functions are available
  CALL FUNCTION 'RH_FUNCTION_EXIST'
    EXPORTING
      NAME                     = c_tables_get
    EXCEPTIONS
      FUNCTION_NOT_FOUND       = 1
      OTHERS                   = 2.

  if sy-subrc <> 0.
     perform get_dbcon_schema changing ld_schema.
     exec sql.
       CONNECT TO :GD-DBCON
     endexec.

     clear ld_no_tab.
*....first try against table definition
     TRY.
       exec sql.
        SELECT RECORD_COUNT FROM M_TABLES
          INTO :LD_COUNT
          WHERE TABLE_NAME  = :GD-TAB
            AND SCHEMA_NAME = :ld_schema
       endexec.

       IF SY-SUBRC <> 0.
          ld_no_tab = true.
       else.
          ld_1 = ld_count.
          write ld_1 to ld_lines style 0.
          message s137(wusl) with gd-tab ld_lines.
       endif.
       CATCH CX_SY_NATIVE_SQL_ERROR into p_err.
        MESSAGE i555(KZ) WITH P_ERR->SQLMSG RAISING ERROR.
     ENDTRY.

*....second try against view definition
     if ld_no_tab = true.
       try.
         exec sql.
         select name from sys.rs_views_
           into :ld_name
           where SCHEMA = :ld_schema
             and NAME   = :gd-tab
         endexec.
         IF SY-SUBRC <> 0.
           message s136(wusl) with gd-dbcon gd-tab.
        ENDIF.
        CATCH CX_SY_NATIVE_SQL_ERROR into p_err.
         MESSAGE i555(KZ) WITH P_ERR->SQLMSG RAISING ERROR.
      ENDTRY.
    endif.

    exec sql.
      disconnect :gd-dbcon
    endexec.
*.check with service functions
  else.
*....set dbcon if it differs from the customizing one
     PERFORM SET_CONNECTION IN PROGRAM SAPLHDB_SERVICE if found
       USING
         GD-DBCON
       CHANGING
         LD_DBCON_ERROR.
*.check if table/view exists on HANA
     ls_object-sign   = 'I'.
     ls_object-option = 'EQ'.
     ls_object-low    = gd-tab.
     append ls_object to lr_object.
     refresh lt_tables.
     CALL FUNCTION c_tables_get
       EXPORTING
         I_TABNAME                    = gd-tab
       IMPORTING
         E_HDB_EXIST                  = ld_exist
         E_RECORD_COUNT               = ld_hdb_count
       EXCEPTIONS
         DBCON_NOT_EXIST              = 1
         DBCON_NO_USE                 = 2
         DBCON_ERROR                  = 3
         DDIC_ERROR                   = 4
         HDB_ERROR                    = 5
         OTHERS                       = 6.

     IF SY-SUBRC <> 0 or
        ld_exist <> true.
        CALL FUNCTION c_views_get
          EXPORTING
            IT_PRESELECTION       = lr_object
          IMPORTING
            ET_VIEW               = lt_tables
          EXCEPTIONS
            DBCON_NOT_EXIST       = 1
            DBCON_NO_USE          = 2
            DBCON_ERROR           = 3
            HDB_ERROR             = 4
            OTHERS                = 5.

        IF SY-SUBRC <> 0 or
           lt_tables[] is initial.
           message e136(wusl) with gd-dbcon gd-tab.
        ENDIF.
     else.
        ld_1 = ld_hdb_count.
        write ld_1 to ld_lines style 0.
        message s137(wusl) with gd-tab ld_lines.
     ENDIF.

  endif.

ENDFORM.                    " CHECK_HANA_TABLE
*&---------------------------------------------------------------------*
*&      Form  OJKEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OJKEY .

   check: gd-tab <> space.
   if gd-ojkey <> c_ojkey_generic_a and
      gd-ojkey <> c_ojkey_generic_b.
      CALL FUNCTION 'TSCUST_OUTER_JOIN'
        EXPORTING
          I_PRIM_TAB       = gd-tab
          I_OJKEY          = gd-ojkey.
   else.
      CALL FUNCTION 'TSCUST_OUTER_JOIN'
        EXPORTING
          I_PRIM_TAB       = gd-tab
          I_OJKEY          = space.
   endif.


ENDFORM.                    " OJKEY
*&---------------------------------------------------------------------*
*&      Form  OJKEY_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OJKEY_F4 .

data: begin of value_tab occurs 0,
        value like se16n_oj_key-oj_key,
        text  like se16n_oj_keyt-txt,
      end of value_tab.
data: retfield   like dfies-fieldname value 'VALUE'.
data: return_tab like DDSHRETVAL occurs 0 with header line.
data: ls_ojkey   like se16n_oj_keyt.
DATA: BEGIN OF dynpfields OCCURS 1.
      INCLUDE STRUCTURE dynpread.
DATA: END OF dynpfields.

*.read DBCON if not yet in PAI
  if gd-hana_active = true and
     sy-dynnr <> '0601' and
     sy-dynnr <> '0602' and
     sy-dynnr <> '2000'.
*...read field tab
    CLEAR dynpfields.
    REFRESH dynpfields.
    if sy-dynnr = '0601' or
       sy-dynnr = '0602'.
       dynpfields-fieldname  = 'GS_SE16N_LT-TAB'.
    else.
       dynpfields-fieldname  = 'GD-TAB'.
    endif.
    APPEND dynpfields.
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        DYNAME                         = 'SAPLSE16N'
        DYNUMB                         = sy-dynnr
        TRANSLATE_TO_UPPER             = true
      TABLES
        DYNPFIELDS                     = dynpfields.
    read table dynpfields index 1.
    gd-tab = dynpfields-fieldvalue.
*...get dbcon
    CLEAR dynpfields.
    REFRESH dynpfields.
    dynpfields-fieldname  = 'GD-DBCON'.
    APPEND dynpfields.
    CALL FUNCTION 'DYNP_VALUES_READ'
     EXPORTING
       DYNAME                         = 'SAPLSE16N'
       DYNUMB                         = sy-dynnr
       TRANSLATE_TO_UPPER             = true
     TABLES
       DYNPFIELDS                     = dynpfields.
    read table dynpfields index 1.
    gd-dbcon = dynpfields-fieldvalue.
  endif.

*.get all possible OJKEY's for this table
  refresh value_tab.
  select * from se16n_oj_key into corresponding fields of ls_ojkey
                where prim_tab = gd-tab.
     clear ls_ojkey-txt.
     select single txt from se16n_oj_keyt into ls_ojkey-txt
                where langu    = sy-langu
                  and oj_key   = ls_ojkey-oj_key
                  and prim_tab = gd-tab.
     clear value_tab.
     value_tab-value = ls_ojkey-oj_key.
     value_tab-text  = ls_ojkey-txt.
     append value_tab.
  endselect.

*.add generic consistency check, but only if DBCON is filled
  if gd-dbcon <> space and
     sy-dynnr = '0100' and
     CL_DB_SYS=>IS_IN_MEMORY_DB <> 'X'.  "only if not SoH
     clear value_tab.
     value_tab-value = c_ojkey_generic_a.
     value_tab-text  = text-p06.
     append value_tab.
     value_tab-value = c_ojkey_generic_b.
     value_tab-text  = text-p07.
     append value_tab.
  endif.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD         = retfield
            value_org        = 'S'
       TABLES
            VALUE_TAB        = value_tab
*           FIELD_TAB        = dfies_tab
            return_tab       = return_tab
       EXCEPTIONS
            PARAMETER_ERROR  = 1
            NO_VALUES_FOUND  = 2
            OTHERS           = 3.

  IF sy-subrc = 0.
     read table return_tab index 1.
     gd-ojkey = return_tab-fieldval.
  ENDIF.

ENDFORM.                    " OJKEY_F4
*&---------------------------------------------------------------------*
*&      Form  PROGRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_1  text
*----------------------------------------------------------------------*
FORM PROGRESS  USING value(p_place).

data: ld_text(45).

  case p_place.
*...creation of fieldcat
    when '1'.
      ld_text = text-p01.
*...select on database
    when '2'.
      ld_text = text-p02.
*...selection of texttable
    when '3'.
      ld_text = text-p03.
*...selection of outer joins
    when '4'.
      ld_text = text-p04.
*...list output
    when '5'.
      ld_text = text-p05.
*...number of hits
    when '6'.
      WRITE: gd-number to ld_text LEFT-JUSTIFIED.
      concatenate text-003 ':' ld_text into ld_text.
  endcase.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     PERCENTAGE       = 0
      TEXT             = ld_text.
            .
  IF sy-batch = true.
     MESSAGE i555(kz) WITH ld_text.
  ENDIF.

ENDFORM.                    " PROGRESS
*&---------------------------------------------------------------------*
*&      Form  OJ_GET_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_ADD  text
*      -->P_LS_ADDF_VALUE  text
*      <--P_LD_OJ_TAB  text
*----------------------------------------------------------------------*
FORM OJ_GET_TAB  TABLES   LT_ADD STRUCTURE se16n_oj_add
                 USING    value(P_FIELD)
                 CHANGING value(P_TAB).

data: ls_dfies like dfies.
data: ls_add   like se16n_oj_add.
data: ld_tab   type DDOBJNAME.

*.first try primary table
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME              = gd-tab
      LFIELDNAME           = p_field
    IMPORTING
      DFIES_WA             = ls_dfies
    EXCEPTIONS
      NOT_FOUND            = 1
      INTERNAL_ERROR       = 2
      OTHERS               = 3.

  IF SY-SUBRC = 0.
     p_tab = gd-tab.
  else.
*..try the secondary ones
     loop at lt_add into ls_add.
       ld_tab = ls_add-add_tab.
       CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
           TABNAME              = ld_tab
           LFIELDNAME           = p_field
         IMPORTING
           DFIES_WA             = ls_dfies
         EXCEPTIONS
           NOT_FOUND            = 1
           INTERNAL_ERROR       = 2
           OTHERS               = 3.
       if sy-subrc = 0.
          p_tab = ld_tab.
          exit.
       endif.
     endloop.
  ENDIF.

ENDFORM.                    " OJ_GET_TAB
*&---------------------------------------------------------------------*
*&      Form  OJKEY_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OJKEY_SELECT .

data: lt_add   like se16n_oj_add occurs 0.
data: lt_addf  like se16n_oj_addf occurs 0.
data: lt_dis   like se16n_oj_add_dis occurs 0.
data: ls_grp    like se16n_output.
data: ls_sum    like se16n_output.
data: ls_add   like se16n_oj_add.
data: ls_addf  like se16n_oj_addf.
data: ls_dis   like se16n_oj_add_dis.
data: ls_or_seltab type SE16N_OR_SELTAB.
data: lt_buf_seltab like SE16N_SELTAB    occurs 0 with header line.
data: lt_sel   like se16n_Seltab occurs 0 with header line.
data: ls_sel   like se16n_Seltab.
data: lt_grp_by    type se16n_output occurs 0.
data: lt_sum_up    type se16n_output occurs 0.
data: ld_field     like se16n_output.
data: lt_skip_field like se16n_output occurs 0.
data: ld_skip_field like se16n_output.
data: ld_dbcnt_add  like sy-dbcnt.
data: ld_count_name type fieldname.
data: lt_where type se16n_where_132 occurs 0 with header line.
data: descr   type ref to cl_abap_structdescr.
data: descr_t type ref to cl_abap_tabledescr.
data: cols    type cl_abap_structdescr=>component_table.
data: col     like line of cols.
data: begin of ls_ref,
        add_tab like se16n_oj_add-add_tab,
        dref    type ref to data,
        dref2   type ref to data,
      end of ls_ref.
data: lt_ref like ls_ref occurs 0.
*.fields that need to be in <all_table>
data: begin of ls_select,
        ref_tab   like se16n_oj_add-add_tab,
        field     type fieldname,
        org_field type fieldname,
      end of ls_select.
data: lt_select like ls_select occurs 0.
data: ld_dref   type ref to data.
data: ld_skip(1).
data: ld_name   like TFDIR-FUNCNAME.
data: wa_fieldcat  type lvc_s_fcat.
data: ld_countname type LVC_FNAME.
data: ld_dbcnt     like sy-dbcnt.
data: ld_view_name LIKE  DD25V-VIEWNAME.

field-symbols: <fs>, <wa_add>, <fadd>, <s>, <wa_copy>, <wa_coll>,
               <add_tab> type table,
               <add_tab_collect> type table.

*..runtime analysis
   perform progress using '4'.

*..fill buffer for this outer join definition
   if gd-ojkey <> c_ojkey_generic_a and
      gd-ojkey <> c_ojkey_generic_b.
      select * from se16n_oj_add into table lt_add
               where oj_key   = gd-ojkey
                 and prim_tab = gd-tab
               order by add_tab_order.
      select * from se16n_oj_addf into table lt_addf
               where oj_key   = gd-ojkey
                 and prim_tab = gd-tab.
      select * from se16n_oj_add_dis into table lt_dis
               where oj_key   = gd-ojkey
                 and prim_tab = gd-tab.
   else.
*.....global tables have been filled in create_fieldcat_standard
      lt_add[]  = gt_add[].
      lt_addf[] = gt_addf[].
      lt_dis[]  = gt_dis[].
*.....prepare additional selection criteria only once
      refresh: lt_buf_seltab.
      loop at gt_or_selfields into ls_or_seltab.
         append lines of ls_or_seltab-seltab to lt_buf_seltab.
      endloop.
      loop at gt_group_by_fields into ls_grp.
        delete lt_buf_seltab where field = ls_grp-field.
      endloop.
   endif.

*..create pointer for the field symbol tables
   loop at lt_add into ls_add.
*.....check authority for read access on the secondary table
      ld_view_name = ls_add-add_tab.
      CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
        EXPORTING
          VIEW_ACTION                          = 'S'  "S=Show
          VIEW_NAME                            = ld_view_name
        EXCEPTIONS
          INVALID_ACTION                       = 1
          NO_AUTHORITY                         = 2
          NO_CLIENTINDEPENDENT_AUTHORITY       = 3
          TABLE_NOT_FOUND                      = 4
          NO_LINEDEPENDENT_AUTHORITY           = 5
          OTHERS                               = 6.
      IF SY-SUBRC NE 0 and
         sy-subrc ne 4.
        MESSAGE I108(wusl) with ld_view_name.
        delete table lt_add from ls_add.
        continue.
      ENDIF.
*.....generate additional field for count(*)
      if ls_add-add_tab_count = true and
         ls_add-add_tab_grp   = true.
*.........create field type i
          col-name = c_line_index.
          col-type ?= cl_abap_elemdescr=>get_i( ).
*.........get structure of ddic-tab
          descr ?= cl_abap_structdescr=>describe_by_name( ls_add-add_tab ).
          cols = descr->get_components( ).
*.........add additional field
          append col to cols.
*.........create new table definition
          CALL METHOD CL_ABAP_STRUCTDESCR=>CREATE
            EXPORTING
              P_COMPONENTS = cols
              P_STRICT     = abap_false
            RECEIVING
              P_RESULT     = descr.
*          descr = cl_abap_structdescr=>create( cols ).
          descr_t = cl_abap_tabledescr=>create( p_line_type = descr ).
          create data ld_dref type handle descr_t.
          ls_ref-add_tab = ls_add-add_tab.
          ls_ref-dref    = ld_dref.
          create data ld_dref type handle descr_t.
          ls_ref-dref2   = ld_dref.
          append ls_ref to lt_ref.
*.....normal generation of pointers
      else.
        create data ld_dRef type standard table of (ls_add-add_tab).
        ls_ref-add_tab = ls_add-add_tab.
        ls_ref-dref    = ld_dref.
        create data ld_dRef type standard table of (ls_add-add_tab).
        ls_ref-dref2   = ld_dref.
        append ls_ref to lt_ref.
      endif.
   endloop.

*..every line needs outer join selects on all secondary tables
   loop at <all_table> assigning <wa>.
*.....loop over all secondary tables
      loop at lt_add into ls_add.
         refresh lt_sel.
         refresh: lt_skip_field.
*........get selection crteria for this secondary table
         loop at lt_addf into ls_addf
                where add_tab = ls_add-add_tab.
            clear ls_sel.
            if ls_addf-field_sign = space.
               ls_addf-field_sign = 'I'.
            endif.
            if ls_addf-field_option = space.
               ls_addf-field_option = 'EQ'.
            endif.
            case ls_addf-method.
*...................................................................
*..currently if selection on primary table is only done with field A
*..but the select on the secondary table is done with A and B, then B
*..is taken as EQ Space. --> Check against primary selection
*..if field is really there! If not, skip it
*....................................................................
              when c_meth-reference.
*...............name of field that needs to be selected
                ls_sel-field = ls_addf-field.
*...............check if field needs to be derived by primary tab
*...............If yes, it could be that the field is not selected,
*...............because the user did use grouping, but did not select
*...............this field. Then it would be wrong to group the
*...............dependent table.
*...............In that case skip it from being grouped for add-tab
                if ls_addf-ref_tab = gd-tab.
                   if not gt_group_by_fields is initial or
                      not gt_sum_up_fields  is initial.
                     read table gt_group_by_fields
*..........................field from reference table (primary tab)
                           with key field = ls_addf-value.
                     if sy-subrc <> 0.
                        read table gt_sum_up_fields
*..........................field from reference table (primary tab)
                           with key field = ls_addf-value.
                        if sy-subrc <> 0.
*.................add-tab-field should not be used for grouping
                          ld_field-field = ls_sel-field.
                          append ld_field to lt_skip_field.
*                          continue.
                        endif.
                     endif.
                   endif.
                endif.
*...............Take over value even if the field does not exist
*...............and is blank!
                assign component ls_addf-value
                        of structure <wa> to <fs>.
                ls_sel-option = ls_addf-field_option.
                ls_sel-sign   = ls_addf-field_sign.
                ls_sel-low    = <fs>.
                append ls_sel to lt_sel.
              when c_meth-string.
*...............name of field that needs to be selected
                ls_sel-field  = ls_addf-field.
                ls_sel-option = ls_addf-field_option.
                ls_sel-sign   = ls_addf-field_sign.
*...............assign value of needed field
                assign component ls_addf-value
                        of structure <wa> to <fs>.
                ls_sel-low
                   = <fs>+ls_addf-field_offset(ls_addf-field_length).
                append ls_sel to lt_sel.
              when c_meth-constant.
*...............name of field that needs to be selected
                ls_sel-field  = ls_addf-field.
                ls_sel-option = ls_addf-field_option.
                ls_sel-sign   = ls_addf-field_sign.
*...............Input has to be converted ??
                ls_sel-low    = ls_addf-value.
                append ls_sel to lt_sel.
              when c_meth-systemvar.
*...............name of field that needs to be selected
                ls_sel-field  = ls_addf-field.
                ls_sel-option = ls_addf-field_option.
                ls_sel-sign   = ls_addf-field_sign.
*...............get value of system variable
                assign (ls_addf-value) to <s>.
                if sy-subrc = 0.
                   ls_sel-low    = <s>.
                   append ls_sel to lt_sel.
                endif.
              when c_meth-variable.
*...............name of field that needs to be selected
                ls_sel-field = ls_addf-field.
*...............call generic function to get needed field filled
                ld_name = ls_addf-vari_object.
*..Currently the field is directly changed in <wa>
*..It has to be investigated if this should be done or if the changes
*..should be given back in an exporting field??
*..But with this approach also complex fields could be filled that cannot
*..be determined out of an add_tab.
                CALL FUNCTION 'RH_FUNCTION_EXIST'
                  EXPORTING
                    NAME                     = ld_name
                  EXCEPTIONS
                    FUNCTION_NOT_FOUND       = 1
                    OTHERS                   = 2.
                check: sy-subrc = 0.
                CALL FUNCTION ls_addf-vari_object
                  EXPORTING
                    i_out_field              = ls_addf-field
                  CHANGING
                    workarea                 = <wa>
                  EXCEPTIONS
                    OTHERS                   = 1.
                check: sy-subrc = 0.
*...............content of field needed is now available
                assign component ls_addf-field
                                 of structure <wa> to <fs>.
                if sy-subrc = 0.
                   ls_sel-option = ls_addf-field_option.
                   ls_sel-sign   = ls_addf-field_sign.
                   ls_sel-low    = <fs>.
                   append ls_sel to lt_sel.
                endif.
            endcase.
         endloop.
*........create generic table
         read table lt_ref into ls_ref
                    with key add_tab = ls_add-add_tab.
         assign ls_ref-dref->* to <add_tab>.
*........in case of selected group-by fieldlist
*........gt_fieldcat_grp contains all fields of all tables
         clear ld_count_name.
         refresh: lt_grp_by, lt_sum_up.
         if ls_add-add_tab_grp = true.
           loop at gt_fieldcat_grp into gs_fieldcat_grp
                  where tabname = ls_add-add_tab.
*.............only if field is used.
*......gs_fieldcat_grp-fieldname always contains the real fieldname
*......of this field in add_tab
              read table lt_skip_field into ld_skip_field
                   with key field = gs_fieldcat_grp-fieldname.
              check: sy-subrc <> 0.
              ld_field-field = gs_fieldcat_grp-fieldname.
              if gs_fieldcat_grp-datatype = 'CURR' or
                 gs_fieldcat_grp-datatype = 'QUAN'.
                 append ld_field to lt_sum_up.
              else.
                 append ld_field to lt_grp_by.
              endif.
           endloop.
           if ls_add-add_tab_count = true.
              ld_count_name = c_line_index.
           endif.
         endif.
*........check if ALL fields for the select are really in lt_sel
*         clear ld_skip.
*         loop at lt_addf into ls_addf
*                where add_tab = ls_add-add_tab.
*            read table lt_sel with key field = ls_addf-field.
*            if sy-subrc <> 0.
*               ld_skip = true.
*            endif.
*         endloop.
*         check: ld_skip <> true.
*........in case of generic OJKEY add additional criteria
         if gd-ojkey = c_ojkey_generic_a or
            gd-ojkey = c_ojkey_generic_b.
            append lines of lt_buf_seltab to lt_sel.
         endif.
*........do the select for this line
         CALL FUNCTION 'SE16N_CREATE_SELECTION'
           EXPORTING
             I_TAB                    = ls_add-add_tab
             I_DBCON                  = ls_add-dbcon
*            I_MAX_LINES              = 500
             I_EXEC_STATEMENT         = 'X'
             I_COUNT_NAME             = ld_count_name
             I_ONLY_EXECUTE           = 'X'
           IMPORTING
             E_DBCNT                  = ld_dbcnt_add
           TABLES
             IT_SEL                   = lt_sel
             it_group_by_fields       = lt_grp_by
             it_sum_up_fields         = lt_sum_up
           CHANGING
             ET_RESULT                = <add_tab>.
         check: sy-subrc = 0.
         describe table <add_tab> lines sy-dbcnt.
         check: sy-dbcnt > 0.
         ld_dbcnt = sy-dbcnt.
*........normal case 1:1 or 1:N relation
         if sy-dbcnt = 1.
            loop at <add_tab> assigning <wa_add>.
              loop at gt_fieldcat_oj_2 into gs_fieldcat_oj_2
                   where ref_tab = ls_add-add_tab.
*...............field content in <all_table>
                assign component gs_fieldcat_oj_2-field
                              of structure <wa> to <fs>.
*...............field content in secondary table
                assign component gs_fieldcat_oj_2-org_field
                              of structure <wa_add> to <fadd>.
                <fs> = <fadd>.
              endloop.
*.............add sy-dbcnt to special field
              if ls_add-add_tab_count = true.
                 concatenate ls_add-add_tab '_' c_line_index
                     into ld_countname.
                 condense ld_countname.
                assign component ld_countname
                                of structure <wa> to <fs>.
                if ls_add-add_tab_grp = true.
                   assign component c_line_index
                                of structure <wa_add> to <fadd>.
                   if sy-subrc = 0.
                      <fs> = <fadd>.
                   endif.
                else.
                   <fs> = 1.
                endif.
              endif.
            endloop.
*........1:N-relation means I need to collect the N-Data
         elseif sy-dbcnt > 1.
            assign ls_ref-dref2->* to <add_tab_collect>.
            assign local copy of
                   initial line of <add_tab_collect> to <wa_coll>.
            loop at <add_tab> assigning <wa_add>.
              loop at gt_fieldcat_oj_2 into gs_fieldcat_oj_2
                   where ref_tab = ls_add-add_tab.
*...............field content in <all_table>
                assign component gs_fieldcat_oj_2-org_field
                              of structure <wa_coll> to <fs>.
*...............field content in secondary table
                assign component gs_fieldcat_oj_2-org_field
                              of structure <wa_add> to <fadd>.
                <fs> = <fadd>.
              endloop.
              collect <wa_coll> into <add_tab_collect>.
            endloop.
*...........<add_tab_collect> now should contain only one line!
            loop at <add_tab_collect> assigning <wa_coll>.
              loop at gt_fieldcat_oj_2 into gs_fieldcat_oj_2
                   where ref_tab = ls_add-add_tab.
*...............field content in <all_table>
                assign component gs_fieldcat_oj_2-field
                              of structure <wa> to <fs>.
*...............field content in secondary table
                assign component gs_fieldcat_oj_2-org_field
                              of structure <wa_coll> to <fadd>.
                <fs> = <fadd>.
              endloop.
*.............add sy-dbcnt to special field
              if ls_add-add_tab_count = true.
                 concatenate ls_add-add_tab '_' c_line_index
                     into ld_countname.
                 condense ld_countname.
                 assign component ld_countname
                                of structure <wa> to <fs>.
                 if sy-subrc = 0.
                    <fs> = ld_dbcnt_add.
                 endif.
              endif.
            endloop.
            refresh <add_tab_collect>.
            unassign <add_tab_collect>.
         endif.
         refresh <add_tab>.
         unassign <add_tab>.
      endloop.  "from lt_add
   endloop.     "from <all_table>

ENDFORM.                    " OJKEY_SELECT
*&---------------------------------------------------------------------*
*&      Form  GET_DBCON_SCHEMA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LD_SCHEMA  text
*----------------------------------------------------------------------*
FORM GET_DBCON_SCHEMA  CHANGING value(ld_schema).

DATA lr_dbconn                TYPE REF TO cl_sql_connection.
DATA lo_sql                   TYPE REF TO cl_sql_statement.
DATA ld_statement             TYPE string.
DATA lo_result                TYPE REF TO cl_sql_result_set.
DATA lo_sql_error             TYPE REF TO cx_sql_exception.
DATA lt_schema                TYPE STANDARD TABLE OF string.
DATA lr_data                  TYPE REF TO data.

  TRY.

      lr_dbconn = cl_sql_connection=>get_connection( con_name = gd-dbcon ).

      CREATE OBJECT lo_sql
        EXPORTING
          con_ref = lr_dbconn.

      ld_statement = 'SELECT TOP 1 CURRENT_SCHEMA FROM m_tables'. "distinct( belnr )
      lo_result = lo_sql->execute_query( ld_statement ).

      GET REFERENCE OF lt_schema INTO lr_data.
      lo_result->set_param_table( lr_data ).

      lo_result->next_package( ).
      lo_result->close( ).

      LOOP AT lt_schema
        INTO  ld_schema.
      ENDLOOP.
    CATCH cx_sql_exception INTO lo_sql_error.
      MESSAGE s628(ke) WITH lo_sql_error->sql_message.
      EXIT.
  ENDTRY.

ENDFORM.                    " GET_DBCON_SCHEMA
