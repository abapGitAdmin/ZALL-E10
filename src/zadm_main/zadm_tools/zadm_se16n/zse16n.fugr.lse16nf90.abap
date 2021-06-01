*----------------------------------------------------------------------*
***INCLUDE LSE16NF90 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CALL_DRILLDOWN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0180   text
*----------------------------------------------------------------------*
FORM CALL_DRILLDOWN  USING  value(i_row)
                            value(i_col)
                            it_cols TYPE LVC_T_COL
                            value(i_value_call)
                            value(i_layout)
                            value(i_alv_direct)
                            value(i_kind).

  data: wa_fieldcat  type lvc_s_fcat.
  data: ld_tabix     like sy-tabix.
  data: ls_cols      type lvc_s_col.
  data: g_util_1     TYPE REF TO cl_fobu_input_util.
  data: ls_selfields like se16n_selfields.
  data: lt_multi     like se16n_selfields occurs 0 with header line.
  data: lt_selfields like se16n_selfields occurs 0 with header line.
  data: lt_or_selfields type SE16N_OR_T.
  data: ls_or_seltab type SE16N_OR_SELTAB.
  data: ls_seltab    like SE16N_SELTAB.
  data: LT_ROWS      TYPE LVC_T_ROW.
  data: LS_ROWS      TYPE LVC_S_ROW.
  data  LT_ROW_NO    TYPE LVC_T_ROID.
  DATA: ld_temp_row  type i.
  data: ld_fcat_tab  type tabname.

  field-symbols: <f>,
                 <wa_table> type any.

*******************************************************************
*.There are five possibilities for drilldown.
*.Three to call a new screen via RFC and two to remain in the screen
*.For the three RFC's there are two where the selection screen is
*.called and one wheer only the drilldown is offered
*.c_drilldown_line_fcode: RFC with selscreen for one line
*.c_drilldown_line_fcode_easy: RFC w/o selscreen but dd for one line
*.c_drilldown_all_fcode: RFC with selscreen for whole list
*.For the RFC's I need table GT_OR_SELFIELDS filled and adapted
*.c_drilldown_line_same_screen: DD in same screen for one line
*.c_drilldown_list_same_screen: DD in same screen for whole list
*.For same screen I need tables GT_SELFIELDS and GT_MULTI adapted
*................................................................
*.In case of DD w/o selscreen the adaption should take place after
*.the DD-Popup.
*******************************************************************

  case i_kind.
*...RFC with selscreen for one line
    when c_drilldown_line_fcode.
       lt_selfields[]    = gt_selfields[].
       lt_multi[]        = gt_multi[].
       lt_or_selfields[] = gt_or_selfields[].
*......adapt tables to fill criteria of chosen line into
*......selection table
       perform adapt_tables tables   lt_selfields
                                     lt_multi
                            using    i_row
                                     it_cols
                                     lt_rows
                                     true
                            changing lt_or_selfields.
       gt_or_selfields[] = lt_or_selfields[].
*......in case of partial select
       gt_or[]           = lt_or_selfields[].
*...RFC w/o selscreen for one line
    when c_drilldown_line_fcode_easy.
       lt_selfields[]    = gt_selfields[].
       lt_multi[]        = gt_multi[].
       lt_or_selfields[] = gt_or_selfields[].
       CALL FUNCTION 'SE16N_GET_DRILLDOWN_DATA'
           EXPORTING
             I_TAB              = gd-tab
           TABLES
             LT_SELFIELDS       = lt_selfields
           EXCEPTIONS
             canceled           = 2.
       check: sy-subrc <> 2.
*......adapt tables to fill criteria of chosen line into
*......selection table
       perform adapt_tables tables   lt_selfields
                                     lt_multi
                            using    i_row
                                     it_cols
                                     lt_rows
                                     true
                            changing lt_or_selfields.
       gt_or_selfields[] = lt_or_selfields[].
*......in case of partial select
       gt_or[]           = lt_or_selfields[].
*...RFC with selscreen for whole list
    when c_drilldown_all_fcode.
       lt_selfields[]    = gt_selfields[].
       lt_multi[]        = gt_multi[].
*...Same screen with drilldown for one line
    when c_drilldown_line_same_screen.
       perform store_navigation using true true.
       lt_selfields[]    = gt_selfields[].
       lt_multi[]        = gt_multi[].
       lt_or_selfields[] = gt_or_selfields[].
*......in case layout was changed, determine the fields
*......out of the layout definition GD-Variant
       if i_layout = true.
*........in case application has own fields, use dummy structure
         if not gd-fcat_table is initial.
            ld_fcat_tab = gd-fcat_table.
         else.
            ld_fcat_tab = gd-tab.
         endif.
         CALL FUNCTION 'SE16N_GET_GROUPING_FROM_LAYOUT'
           EXPORTING
             I_TAB                  = ld_fcat_tab
           TABLES
             LT_SELFIELDS           = lt_selfields
           EXCEPTIONS
             LAYOUT_NOT_FOUND       = 1
             OTHERS                 = 2.
*........if canceled delete stored navigation
         IF SY-SUBRC <> 0.
            subtract 1 from gd_curr_level.
            gt_navigation[] = gt_navi_save[].
         endif.
         check: sy-subrc = 0.
*......layout has been changed in ALV-Menu
       elseif i_alv_direct = true.
         CALL FUNCTION 'SE16N_GET_GROUPING_FROM_LAYOUT'
            EXPORTING
              I_ALV_GRID            = alv_grid
           TABLES
             LT_SELFIELDS           = lt_selfields
           EXCEPTIONS
             LAYOUT_NOT_FOUND       = 1
             OTHERS                 = 2.
*........if canceled delete stored navigation
         IF SY-SUBRC <> 0.
            subtract 1 from gd_curr_level.
            gt_navigation[] = gt_navi_save[].
         endif.
         check: sy-subrc = 0.
*......else, manual drilldown with popup
       else.
         CALL FUNCTION 'SE16N_GET_DRILLDOWN_DATA'
           EXPORTING
             I_TAB              = gd-tab
           TABLES
             LT_SELFIELDS       = lt_selfields
           EXCEPTIONS
             canceled           = 2.
*........if canceled delete stored navigation
         if sy-subrc = 2.
            subtract 1 from gd_curr_level.
            gt_navigation[] = gt_navi_save[].
         endif.
         check: sy-subrc <> 2.
       endif.
*......get selected rows to allow multiple drilldown
       refresh lt_rows.
       CALL METHOD ALV_GRID->GET_SELECTED_ROWS
           IMPORTING
             ET_INDEX_ROWS = lt_rows
             ET_ROW_NO     = lt_row_no.
       describe table lt_rows lines sy-tabix.
*......if only one line selected, take standard logic
       if sy-tabix = 1.
          read table lt_rows into ls_rows index 1.
          ld_temp_row = ls_rows-index.
       elseif sy-tabix < 1.
          ld_temp_row = i_row.
       endif.
*......adapt tables to fill criteria of chosen line into
*......selection table
       perform adapt_tables tables   lt_selfields
                                     lt_multi
                            using    ld_temp_row
                                     it_cols
                                     lt_rows
                                     space
                            changing lt_or_selfields.
*...in case of same screen change global tables
*...gt_selfields and gt_multi are changed in SE16N_DRILLDOWN
*...gt_or_selfields is used in SE16N_DRILLDOWN to create
*...LT_WHERE
       gt_or_selfields[] = lt_or_selfields[].
*......in case of partial select
       gt_or[]           = lt_or_selfields[].
*...Same screen with drilldown for whole list
    when c_drilldown_list_same_screen.
       perform store_navigation using true true.
       lt_selfields[] = gt_selfields[].
       lt_multi[]     = gt_multi[].
*......in case layout was changed, determine the fields
*......out of the layout definition GD-Variant
       if i_layout = true.
*........in case application has own fields, use dummy structure
         if not gd-fcat_table is initial.
            ld_fcat_tab = gd-fcat_table.
         else.
            ld_fcat_tab = gd-tab.
         endif.
         CALL FUNCTION 'SE16N_GET_GROUPING_FROM_LAYOUT'
           EXPORTING
             I_TAB                  = ld_fcat_tab
           TABLES
             LT_SELFIELDS           = lt_selfields
           EXCEPTIONS
             LAYOUT_NOT_FOUND       = 1
             OTHERS                 = 2.
*........if canceled delete stored navigation
         IF SY-SUBRC <> 0.
            subtract 1 from gd_curr_level.
            gt_navigation[] = gt_navi_save[].
         endif.
         check: sy-subrc = 0.
*......layout has been changed in ALV-Menu
       elseif i_alv_direct = true.
         CALL FUNCTION 'SE16N_GET_GROUPING_FROM_LAYOUT'
            EXPORTING
              I_ALV_GRID            = alv_grid
           TABLES
             LT_SELFIELDS           = lt_selfields
           EXCEPTIONS
             LAYOUT_NOT_FOUND       = 1
             OTHERS                 = 2.
*........if canceled delete stored navigation
         IF SY-SUBRC <> 0.
            subtract 1 from gd_curr_level.
            gt_navigation[] = gt_navi_save[].
         endif.
         check: sy-subrc = 0.
*......else, manual drilldown with popup
       else.
*........no change of selection criteria necessary
         CALL FUNCTION 'SE16N_GET_DRILLDOWN_DATA'
           EXPORTING
             I_TAB              = gd-tab
           TABLES
             LT_SELFIELDS       = lt_selfields
           EXCEPTIONS
             canceled           = 2.
*........if canceled delete stored navigation
         if sy-subrc = 2.
            subtract 1 from gd_curr_level.
            gt_navigation[] = gt_navi_save[].
         endif.
         check: sy-subrc <> 2.
       endif.
  endcase.

*.call drilldown
  if i_kind = c_drilldown_line_same_screen or
     i_kind = c_drilldown_list_same_screen.
     CALL FUNCTION 'SE16N_DRILLDOWN'
      EXPORTING
        I_TAB              = gd-tab
        I_DISPLAY          = gd-display
        I_EXIT_SELFIELD_FB = gd-exit_fb_selfields
        I_SINGLE_TABLE     = space
        I_HANA_ACTIVE      = gd-hana_active
        I_DBCON            = gd-dbcon
        I_OJKEY            = gd-ojkey
        I_FORMULA_NAME     = gd-formula_name
        I_VALUE_CALL       = i_value_call
        I_VARIANT          = gd-variant
        I_MAX_LINES        = gd-max_lines
        I_DOUBLE_CLICK     = gd-double_click
        I_KIND_OF_CALL     = i_kind
        IT_COLS            = it_cols
        I_ROW              = i_row
    TABLES
        LT_MULTI           = lt_multi
        LT_SELFIELDS       = lt_selfields
      EXCEPTIONS
        others             = 4.
  else.
     CALL FUNCTION 'SE16N_DRILLDOWN' STARTING NEW TASK 'DRILLDOWN'
      EXPORTING
        I_TAB              = gd-tab
        I_DISPLAY          = gd-display
        I_EXIT_SELFIELD_FB = gd-exit_fb_selfields
        I_SINGLE_TABLE     = 'X'
        I_HANA_ACTIVE      = gd-hana_active
        I_DBCON            = gd-dbcon
        I_OJKEY            = gd-ojkey
        I_FORMULA_NAME     = gd-formula_name
        I_VALUE_CALL       = i_value_call
        I_VARIANT          = gd-variant
        I_MAX_LINES        = gd-max_lines
        I_DOUBLE_CLICK     = gd-double_click
        I_KIND_OF_CALL     = i_kind
        IT_COLS            = it_cols
        I_ROW              = i_row
    TABLES
        LT_MULTI           = lt_multi
        LT_SELFIELDS       = lt_selfields
      EXCEPTIONS
        others             = 4.
  endif.

ENDFORM.                    " CALL_DRILLDOWN
*&---------------------------------------------------------------------*
*&      Form  GD_DOUBLE_CLICK_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GD_DOUBLE_CLICK_F4 .

DATA: BEGIN OF VALUE_TAB OCCURS 0,
        VALUE LIKE TSPRIM-METHOD,
        TEXT  LIKE TSAPPLT-TXT,
      END OF VALUE_TAB.
DATA: RETFIELD   LIKE DFIES-FIELDNAME VALUE 'VALUE'.
DATA: RETURN_TAB LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE.
DATA: LS_TSVAR   LIKE TSVARFBT.

  REFRESH VALUE_TAB.
  CLEAR VALUE_TAB.
  VALUE_TAB-VALUE = space.
  VALUE_TAB-TEXT  = TEXT-dc1.
  APPEND VALUE_TAB.
  CLEAR VALUE_TAB.
  VALUE_TAB-VALUE = c_drilldown_line_fcode.
  VALUE_TAB-TEXT  = TEXT-d01.
  APPEND VALUE_TAB.
  CLEAR VALUE_TAB.
  VALUE_TAB-VALUE = c_drilldown_line_fcode_easy.
  VALUE_TAB-TEXT  = TEXT-d03.
  APPEND VALUE_TAB.
  CLEAR VALUE_TAB.
  VALUE_TAB-VALUE = c_drilldown_all_fcode.
  VALUE_TAB-TEXT  = TEXT-d02.
  APPEND VALUE_TAB.
  CLEAR VALUE_TAB.
  VALUE_TAB-VALUE = c_drilldown_line_same_screen.
  VALUE_TAB-TEXT  = TEXT-212.
  APPEND VALUE_TAB.
  CLEAR VALUE_TAB.
  VALUE_TAB-VALUE = c_drilldown_list_same_screen.
  VALUE_TAB-TEXT  = TEXT-213.
  APPEND VALUE_TAB.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD         = RETFIELD
            VALUE_ORG        = 'S'
       TABLES
            VALUE_TAB        = VALUE_TAB
*           FIELD_TAB        = dfies_tab
            RETURN_TAB       = RETURN_TAB
       EXCEPTIONS
            PARAMETER_ERROR  = 1
            NO_VALUES_FOUND  = 2
            OTHERS           = 3.

  IF SY-SUBRC = 0.
     READ TABLE RETURN_TAB INDEX 1.
     GD-DOUBLE_CLICK = RETURN_TAB-FIELDVAL.
  ENDIF.

ENDFORM.                    " GD_DOUBLE_CLICK_F4
*&---------------------------------------------------------------------*
*&      Form  MAP_SORT_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_ORDER_BY_FIELDS  text
*      -->P_IT_SORTORDFER_FIELDS  text
*----------------------------------------------------------------------*
FORM MAP_SORT_ORDER  TABLES   IT_ORDER_BY_FIELDS STRUCTURE SE16N_OUTPUT
                              IT_SORTORDER_FIELDS STRUCTURE SE16N_SELTAB.

data: lt_order_by  like se16n_seltab occurs 0.
data: ls_sortorder like se16n_seltab.
data: ls_order_by  like se16n_seltab.
data: is_order_by  like se16n_output.
data: ld_sort(3)   type n.
data: ld_tabix     like sy-tabix.

*..first fill current order to guarantee stable sort in case no
*..sortorder is defined
   ld_sort = 100.
   loop at it_order_by_fields into is_order_by.
     ls_order_by-field = is_order_by-field.
     ls_order_by-high  = ld_sort.
     add 1 to ld_sort.
     append ls_order_by to lt_order_by.
   endloop.

*..now check if additional sort order is defined
   loop at it_sortorder_fields into ls_sortorder.
      read table lt_order_by into ls_order_by
                with key field = ls_sortorder-field.
      ld_tabix = sy-tabix.
      if sy-subrc = 0.
         ls_order_by-high = ls_sortorder-low.
         modify lt_order_by from ls_order_by index ld_tabix.
      endif.
   endloop.

*..now sort order by fields according sortorder
   sort lt_order_by by high ascending.

*..fill back the new order to used table
   refresh it_order_by_fields.
   loop at lt_order_by into ls_order_by.
     is_order_by-field = ls_order_by.
     append is_order_by to it_order_by_fields.
   endloop.

ENDFORM.                    " MAP_SORT_ORDER
*&---------------------------------------------------------------------*
*&      Form  ADAPT_TABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADAPT_TABLES tables CT_SELFIELDS STRUCTURE  SE16N_SELFIELDS
                         CT_MULTI     STRUCTURE  SE16N_SELFIELDS
                  using  value(i_row)
                         it_cols type lvc_t_col
                         it_rows type LVC_T_ROW
                         value(p_rfc)
                  changing CT_OR_SELFIELDS TYPE SE16N_OR_T.

  data: wa_fieldcat  type lvc_s_fcat.
  data: ld_tabix     like sy-tabix.
  data: ls_cols      type lvc_s_col.
  data: ld_curr_level(3) type n.
  data: g_util_1     TYPE REF TO cl_fobu_input_util.
  data: ls_selfields like se16n_selfields.
  data: ts_selfields like se16n_selfields.
  data: tt_selfields like se16n_selfields occurs 0 with header line.
  data: lt_multi     like se16n_selfields occurs 0 with header line.
  data: ls_multi     like se16n_selfields.
  data: lt_selfields like se16n_selfields occurs 0 with header line.
  data: ls_or_seltab type SE16N_OR_SELTAB.
  data: ls_seltab    like SE16N_SELTAB.
  data: is_rows      type lvc_s_row.
  data: lt_used      like se16n_output occurs 0 with header line.
  data: ls_used      like se16n_output.
  field-symbols: <f>,
                 <wa_table> type any.

*.check for multi-line-drilldown
  if not it_rows is initial.
*....get first line and process others later
     read table it_rows into is_rows index 1.
     if gd-edit = true.
       read table <all_table_cell> index is_rows-index assigning <wa_table>.
     else.
       read table <all_table> index is_rows-index assigning <wa_table>.
     endif.
     check: sy-subrc = 0.
  else.
*....read table <all_table> index i_row assigning <wa_table>.
*....If we are in edit-mode, only <all_table_cell> contains all lines
     if gd-edit = true.
       read table <all_table_cell> index i_row assigning <wa_table>.
     else.
       read table <all_table> index i_row assigning <wa_table>.
     endif.
     check: sy-subrc = 0.
  endif.

*.copy necessary data for drilldown
  lt_selfields[] = ct_selfields[].
  lt_multi[]     = ct_multi[].

*................................................................
*.get all fields currently used and the data from <wa_table>.
*.put this data into the global structures to be able to restart.
*.Fill GT_OR_SELFIELDS for the same-screen drilldown.
*.Fill GT_MULTI and GT_SELFIELDS for the new screen drilldown
*.As the different drilldowns can be mixed I have to fill all tables
*.everytime.
*................................................................
*.As the application could hide fields (like OBJNR) although they are
*.necessary, I can only trust in the grouping in gt_selfields from the
*.list before. This means read the navigation table and get the list
*.before
*................................................................
  if gd-hana_active = true.
*...RFC-Call does not fill navigation table, so take current selfields
    if p_rfc = true.
       tt_selfields[] = gt_selfields[].
    else.
       ld_curr_level = gd_curr_level - 1.
       read table gt_navigation into gs_navigation index ld_curr_level.
       tt_selfields[] = gs_navigation-selfields[].
    endif.
*...now adjust all necessary fields
    loop at tt_selfields into ts_selfields
                 where group_by = true
                   and datatype <> 'CLNT'.
      wa_fieldcat-fieldname = ts_selfields-fieldname.
      ld_tabix = sy-tabix.
*.....if columns are marked only use these
      if not it_cols is initial.
        read table it_cols into ls_cols
                 with key fieldname = wa_fieldcat-fieldname.
        check sy-subrc = 0.
      endif.
      assign component wa_fieldcat-fieldname
                  of structure <wa_table> to <f>.
*...check if this field was used as a criteria before.
*...do not use if summarization field
      loop at ct_or_selfields into ls_or_seltab.
        ld_tabix = sy-tabix.
*.......delete all lines that were defined before
        delete ls_or_seltab-seltab
               where field = wa_fieldcat-fieldname.
*        loop at ls_or_seltab-seltab into ls_seltab
*                where field = wa_fieldcat-fieldname.
*          delete ls_or_seltab-seltab index sy-tabix.
*        endloop.
*.......Either field was used before and is now deleted
*.......or field was not used. In both cases
*.......add only the current selected one, but only if it is still
*.......in the grouping --> user could have removed fields again!
        read table lt_selfields into ls_selfields
                     with key fieldname = wa_fieldcat-fieldname.
        if ls_selfields-sum_up is initial and
           ls_selfields-aggregate is initial.
*..........take over field content in case of HANA only with grouping.
*..........without HANA always
           if not ls_selfields-group_by is initial or
              gd-hana_active <> true
              or 1 = 1.  "it is better to always take over the criteria
              clear: ls_seltab.
              ls_seltab-field = wa_fieldcat-fieldname.
              ls_seltab-sign  = 'I'.
              ls_seltab-option = 'EQ'.
              ls_seltab-low    = <f>.
              ls_used-field    = wa_fieldcat-fieldname.
              collect ls_used into lt_used.
              perform convert_field using    ls_selfields-rollname
                                             ls_selfields-tabname
                                             ls_selfields-fieldname
                                    changing ls_seltab-low.
              append ls_seltab to ls_or_seltab-seltab.
           endif.
        endif.
        modify ct_or_selfields from ls_or_seltab index ld_tabix.
      endloop.
*.....no criteria defined at all
      if sy-subrc <> 0.
         clear: ls_or_seltab, ls_seltab.
         read table lt_selfields into ls_selfields
                     with key fieldname = wa_fieldcat-fieldname.
         if ls_selfields-sum_up is initial and
            ls_selfields-aggregate is initial.
*..........take over field content in case of HANA only with grouping.
*..........without HANA always
           if not ls_selfields-group_by is initial or
              gd-hana_active <> true
              or 1 = 1.
              ls_seltab-field = wa_fieldcat-fieldname.
              ls_seltab-sign  = 'I'.
              ls_seltab-option = 'EQ'.
              ls_seltab-low    = <f>.
              ls_used-field    = wa_fieldcat-fieldname.
              collect ls_used into lt_used.
              perform convert_field using    ls_selfields-rollname
                                             ls_selfields-tabname
                                             ls_selfields-fieldname
                                    changing ls_seltab-low.
              append ls_seltab to ls_or_seltab-seltab.
              append ls_or_seltab to ct_or_selfields.
           endif.
         endif.
      endif.
**************************************************************
**************************************************************
      loop at lt_selfields into ls_selfields
              where ( not low    is initial or
                      not high   is initial or
                      not option is initial or
                      not setid  is initial )
                and ( sum_up    is initial and
                      aggregate is initial )
                and fieldname = wa_fieldcat-fieldname.
        ld_tabix = sy-tabix.
*.......field was used before, replace all input with only
*.......the current one
        clear: ls_selfields-low,
               ls_selfields-high,
               ls_selfields-option,
               ls_selfields-sign,
               ls_selfields-setid.
        if not <f> is initial and
           ( not ls_selfields-group_by is initial or
             gd-hana_active <> true ).
           ls_Selfields-low = <f>.
           perform convert_field using    ls_selfields-rollname
                                          ls_selfields-tabname
                                          ls_selfields-fieldname
                                 changing ls_selfields-low.
           modify lt_selfields from ls_selfields index ld_tabix.
        endif.
*.......delete multi_input if available
        delete lt_multi where fieldname = wa_fieldcat-fieldname.
      endloop.
*....field was not criteria before --> add it
      if sy-subrc <> 0.
        read table lt_selfields into ls_selfields
            with key fieldname = wa_fieldcat-fieldname
                     sum_up    = space
                     aggregate = space.
        if sy-subrc = 0 and
           ( ls_selfields-group_by = true or
             gd-hana_active <> true ).
          ld_tabix = sy-tabix.
          if not <f> is initial.
            ls_selfields-low = <f>.
            perform convert_field using    ls_selfields-rollname
                                           ls_selfields-tabname
                                           ls_selfields-fieldname
                                  changing ls_selfields-low.
            modify lt_selfields from ls_selfields index ld_tabix.
          endif.
        endif.
      endif.
    endloop.
  else.
    loop at gt_fieldcat into wa_fieldcat
          where no_out    <> 'X'
            and ref_table = gd-tab.
      ld_tabix = sy-tabix.
*.....if columns are marked only use these
      if not it_cols is initial.
        read table it_cols into ls_cols
                 with key fieldname = wa_fieldcat-fieldname.
        check sy-subrc = 0.
      endif.
      assign component wa_fieldcat-fieldname
                  of structure <wa_table> to <f>.
*...check if this field was used as a criteria before.
*...do not use if summarization field
      loop at ct_or_selfields into ls_or_seltab.
        ld_tabix = sy-tabix.
*.......delete all lines that were defined before
        loop at ls_or_seltab-seltab into ls_seltab
                where field = wa_fieldcat-fieldname.
          delete ls_or_seltab-seltab index sy-tabix.
        endloop.
*.......Either field was used before and is now deleted
*.......or field was not used. In both cases
*.......add only the current selected one, but only if it is still
*.......in the grouping --> user could have removed fields again!
        read table lt_selfields into ls_selfields
                     with key fieldname = wa_fieldcat-fieldname.
        if ls_selfields-sum_up is initial and
           ls_selfields-aggregate is initial.
*..........take over field content in case of HANA only with grouping.
*..........without HANA always
           if not ls_selfields-group_by is initial or
              gd-hana_active <> true.
              clear: ls_seltab.
              ls_seltab-field = wa_fieldcat-fieldname.
              ls_seltab-sign  = 'I'.
              ls_seltab-option = 'EQ'.
              ls_seltab-low    = <f>.
              perform convert_field using    ls_selfields-rollname
                                             ls_selfields-tabname
                                             ls_selfields-fieldname
                                    changing ls_seltab-low.
              append ls_seltab to ls_or_seltab-seltab.
           endif.
        endif.
        modify ct_or_selfields from ls_or_seltab index ld_tabix.
      endloop.
*.....no criteria defined at all
      if sy-subrc <> 0.
         clear: ls_or_seltab, ls_seltab.
         read table lt_selfields into ls_selfields
                     with key fieldname = wa_fieldcat-fieldname.
         if ls_selfields-sum_up is initial and
            ls_selfields-aggregate is initial.
*..........take over field content in case of HANA only with grouping.
*..........without HANA always
           if not ls_selfields-group_by is initial or
              gd-hana_active <> true.
              ls_seltab-field = wa_fieldcat-fieldname.
              ls_seltab-sign  = 'I'.
              ls_seltab-option = 'EQ'.
              ls_seltab-low    = <f>.
              perform convert_field using    ls_selfields-rollname
                                             ls_selfields-tabname
                                             ls_selfields-fieldname
                                    changing ls_seltab-low.
              append ls_seltab to ls_or_seltab-seltab.
              append ls_or_seltab to ct_or_selfields.
           endif.
         endif.
      endif.
**************************************************************
**************************************************************
      loop at lt_selfields into ls_selfields
              where ( not low    is initial or
                      not high   is initial or
                      not option is initial or
                      not setid  is initial )
                and ( sum_up    is initial and
                      aggregate is initial )
                and fieldname = wa_fieldcat-fieldname.
        ld_tabix = sy-tabix.
*.......field was used before, replace all input with only
*.......the current one
        clear: ls_selfields-low,
               ls_selfields-high,
               ls_selfields-option,
               ls_selfields-sign,
               ls_selfields-setid.
        if not <f> is initial and
           ( not ls_selfields-group_by is initial or
             gd-hana_active <> true ).
           ls_Selfields-low = <f>.
           perform convert_field using    ls_selfields-rollname
                                          ls_selfields-tabname
                                          ls_selfields-fieldname
                                 changing ls_selfields-low.
           modify lt_selfields from ls_selfields index ld_tabix.
        endif.
*.......delete multi_input if available
        delete lt_multi where fieldname = wa_fieldcat-fieldname.
      endloop.
*....field was not criteria before --> add it
      if sy-subrc <> 0.
        read table lt_selfields into ls_selfields
            with key fieldname = wa_fieldcat-fieldname
                     sum_up    = space
                     aggregate = space.
        if sy-subrc = 0 and
           ( ls_selfields-group_by = true or
             gd-hana_active <> true ).
          ld_tabix = sy-tabix.
          if not <f> is initial.
            ls_selfields-low = <f>.
            perform convert_field using    ls_selfields-rollname
                                           ls_selfields-tabname
                                           ls_selfields-fieldname
                                  changing ls_selfields-low.
            modify lt_selfields from ls_selfields index ld_tabix.
          endif.
        endif.
      endif.
    endloop.
  endif.
*.table lt_used contains the fields that need to be filled for
*.multi-drilldown. Start at line 2
  loop at it_rows into is_rows from 2.
     if gd-edit = true.
       read table <all_table_cell> index is_rows-index assigning <wa_table>.
     else.
       read table <all_table> index is_rows-index assigning <wa_table>.
     endif.
     check: sy-subrc = 0.
     loop at lt_used into ls_used.
        assign component ls_used-field
                  of structure <wa_table> to <f>.
*.......fill gt_or
        loop at ct_or_selfields into ls_or_seltab.
           ld_tabix = sy-tabix.
           read table lt_selfields into ls_selfields
                     with key fieldname = ls_used-field.
           clear: ls_seltab.
           ls_seltab-field = ls_used-field.
           ls_seltab-sign  = 'I'.
           ls_seltab-option = 'EQ'.
           ls_seltab-low    = <f>.
           perform convert_field using    ls_selfields-rollname
                                          ls_selfields-tabname
                                          ls_selfields-fieldname
                                 changing ls_seltab-low.
*..........collect, because many fields can be equal
           collect ls_seltab into ls_or_seltab-seltab.
           modify ct_or_selfields from ls_or_seltab index ld_tabix.
        endloop.
*.......fill lt_multi
        read table lt_selfields into ls_selfields
                with key fieldname = ls_used-field.
*.......only if the value is a new one
        if ls_selfields-low <> <f>.
           ls_Selfields-low = <f>.
           perform convert_field using    ls_selfields-rollname
                                          ls_selfields-tabname
                                          ls_selfields-fieldname
                                 changing ls_selfields-low.
           move-corresponding ls_selfields to ls_multi.
           collect ls_multi into lt_multi.
        endif.
     endloop.
  endloop.

*.or_selfields has to be sorted as the same field can occur several
*.times, but has to be one after the other
  loop at ct_or_selfields into ls_or_Seltab.
    ld_tabix = sy-tabix.
    sort ls_or_Seltab-seltab by field.
    modify ct_or_selfields from ls_or_seltab index ld_tabix.
  endloop.

  ct_selfields[] = lt_selfields[].
  ct_multi[]     = lt_multi[].

ENDFORM.                    " ADAPT_TABLES
*&---------------------------------------------------------------------*
*&      Form  DD_SAME_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DD_SAME_SCREEN .

data: ls_field like se16n_output.
data: lt_Sel           like se16n_seltab occurs 0 with header line.
data: lt_where         type se16n_where_132 occurs 0 with header line.
data: IT_OUTPUT_FIELDS like SE16N_OUTPUT occurs 0.
data: ld_abort(1).

   refresh: gt_group_by_fields, gt_sum_up_fields.
   loop at gt_selfields
            where ( group_by = true
               or sum_up   = true )
              and tabname = gd-tab.
      ls_field-field = gt_selfields-fieldname.
      if gt_selfields-group_by = true.
         collect ls_field into gt_group_by_fields.
      endif.
      if gt_selfields-sum_up = true.
         collect ls_field into gt_sum_up_fields.
      endif.
   endloop.
   perform create_fieldcat_standard tables   it_output_fields
                                     using   gd-tab
                                             gd-edit
                                             gd-tech_names
                                             gd-no_txt
                                             gd-clnt_spez
                                             gd-clnt_dep
                                             gd-txt_tab.

*.determine if JOIN-logic for text table is possible.
  IF gd-txt_tab <> space AND
     gd-no_txt  <> true.
     CLEAR: gd-txt_join_active,
            gd-txt_join_missing,
            gd-cds_join_string.
     PERFORM prepare_text_join CHANGING gd-cds_join_string.
  ENDIF.
*.determine select string in case of DDL-Source
  perform select_cds_string using    gd-tab
                            changing gd-cds_string
                                     ld_abort.

*..new logic for outer join
   if gd-new_oj_join = true and
      gd-ojkey       <> space and
      gd-cds_filled  <> true.
      perform prepare_join_select using    gd-tab
                                  changing gd-cds_string.
   endif.

*..Create selection table out of input selfields
*..gt_or_selfields contains all selection criteria
   refresh: lt_where.
   perform create_seltab tables lt_where
                                lt_sel
                                gt_or_selfields
                         changing gt_and_selfields.
   perform refresh_screen.
   CALL METHOD cl_gui_cfw=>set_new_ok_code
      EXPORTING
         new_code = 'HUGO'.

ENDFORM.                    " DD_SAME_SCREEN
*&---------------------------------------------------------------------*
*&      Form  CONVERT_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_SELFIELDS_ROLLNAME  text
*      <--P_LS_SELTAB_LOW  text
*----------------------------------------------------------------------*
FORM CONVERT_FIELD  USING    value(P_ROLLNAME)
                             value(P_TABNAME)
                             value(P_FIELDNAME)
                    CHANGING value(P_VALUE).

  data: g_util_1     TYPE REF TO cl_fobu_input_util.

  if p_rollname <> space.
*....convert in correct way
     CREATE OBJECT g_util_1
        EXPORTING
          typename = p_rollname.
  else.
    CREATE OBJECT g_util_1
      EXPORTING tabname   = p_tabname
                fieldname = p_fieldname.
  endif.

*....convert to external view, no check table checked
           CALL METHOD g_util_1->output_convert
                EXPORTING
                  field_value_int = p_value
                IMPORTING
                  field_value_ext = p_value.
*....convert to internal view, no check table checked
           CALL METHOD g_util_1->input_convert
                EXPORTING
                  field_value_ext   = p_value
                IMPORTING
                  field_value_int_c = p_value.

ENDFORM.                    " CONVERT_FIELD
*&---------------------------------------------------------------------*
*&      Form  STORE_NAVIGATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM STORE_NAVIGATION using value(p_add)
                            value(p_vari_old).

*..store global tables before change to allow navigation back and forth
  clear gs_navigation.
*.the following could happen. User goes back from list N to N-1 and now
*.does a new drilldown. In that case I need to delete all lists >= N.
  gt_navi_save[] = gt_navigation[].
  if p_add = true.
     delete gt_navigation from gd_curr_level.
  endif.
*.only store information about this list if not yet there
  read table gt_navigation into gs_navigation
              with key level = gd_curr_level.
  if sy-subrc <> 0.
    gs_navigation-level        = gd_curr_level.
    gs_navigation-selfields    = gt_selfields[].
    gs_navigation-multi        = gt_multi[].
    gs_navigation-or_selfields = gt_or_selfields[].
    if p_vari_old = true.
       gs_navigation-variant   = gd-variant_old.
    else.
       gs_navigation-variant   = gd-variant.
    endif.
    append gs_navigation to gt_navigation.
  endif.
*.current level is now one further, but only in case of drilldown
  if p_add = true.
     add 1 to gd_curr_level.
  endif.

ENDFORM.                    " STORE_NAVIGATION
*&---------------------------------------------------------------------*
*&      Form  NAVIGATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0384   text
*----------------------------------------------------------------------*
FORM NAVIGATE  USING    VALUE(p_kind).

*..gd_curr_level contains current list level
*..read table gt_navigation and check if requested list is there
   check: gd_curr_level > 0.
   case p_kind.
     when 'BACK'.
       perform store_navigation using space space.
       gd_curr_level = gd_curr_level - 1.
       read table gt_navigation into gs_navigation index gd_curr_level.
       if sy-subrc = 0.
*........having clause only for the first level
         if gd_curr_level > 1.
            gd-min_count_dd = true.
         endif.
         gt_selfields[]    = gs_navigation-selfields[].
         gt_multi[]        = gs_navigation-multi[].
         gt_or_selfields[] = gs_navigation-or_selfields[].
         gd-variant        = gs_navigation-variant.
         perform dd_same_screen.
       endif.
     when 'NEXT'.
       gd_curr_level = gd_curr_level + 1.
       read table gt_navigation into gs_navigation index gd_curr_level.
       if sy-subrc = 0.
*........having clause only for the first level
         if gd_curr_level > 1.
            gd-min_count_dd = true.
         endif.
         gt_selfields[]    = gs_navigation-selfields[].
         gt_multi[]        = gs_navigation-multi[].
         gt_or_selfields[] = gs_navigation-or_selfields[].
         gd-variant        = gs_navigation-variant.
         perform dd_same_screen.
       endif.
   endcase.


ENDFORM.                    " NAVIGATE
*&---------------------------------------------------------------------*
*&      Form  MAP_GROUPING_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_GROUP_BY_FIELDS  text
*      -->P_IT_SORTORDER_FIELDS  text
*----------------------------------------------------------------------*
FORM MAP_GROUPING_ORDER  TABLES
                      IT_GROUP_BY_FIELDS  STRUCTURE SE16N_OUTPUT
                      IT_GROUPORDER_FIELDS STRUCTURE SE16N_SELTAB.

data: lt_group_by  like se16n_seltab occurs 0.
data: ls_grouporder like se16n_seltab.
data: ls_group_by  like se16n_seltab.
data: is_group_by  like se16n_output.
data: ld_sort(3)   type n.
data: ld_tabix     like sy-tabix.
data: ld_clnt(1).

*..first fill current order to guarantee stable sort in case no
*..sortorder is defined
   ld_sort = 100.
   clear ld_clnt.
   loop at it_group_by_fields into is_group_by.
*....check for client
     read table gt_selfields with key fieldname = is_group_by-field.
     if gt_selfields-datatype = 'CLNT'.
       ld_clnt = true.
       continue.
     endif.
     ls_group_by-field = is_group_by-field.
     ls_group_by-high  = ld_sort.
     add 1 to ld_sort.
     append ls_group_by to lt_group_by.
   endloop.

*..now check if additional sort order is defined
   loop at it_grouporder_fields into ls_grouporder.
      read table lt_group_by into ls_group_by
                with key field = ls_grouporder-field.
      ld_tabix = sy-tabix.
      if sy-subrc = 0.
         ls_group_by-high = ls_grouporder-low.
         modify lt_group_by from ls_group_by index ld_tabix.
      endif.
   endloop.

*..now group order by fields according grouporder
   sort lt_group_by by high ascending.

*..fill back the new order to used table
   refresh it_group_by_fields.
*..add client again
   if ld_clnt = true.
     read table gt_selfields with key datatype = 'CLNT'.
     is_group_by-field = gt_selfields-fieldname.
     append is_group_by to it_group_by_fields.
   endif.
   loop at lt_group_by into ls_group_by.
     is_group_by-field = ls_group_by.
     append is_group_by to it_group_by_fields.
   endloop.

ENDFORM.                    " MAP_GROUPING_ORDER
*&---------------------------------------------------------------------*
*&      Form  SEARCH_DD_FIELDNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEARCH_DD_FIELDNAME .

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
    line_no = dd_tc-current_line + line_no.
    IF line_no = 0. line_no = 1. ENDIF.
 endif.
 clear ld_found.
 check: s_value <> space.
 loop at gt_selfields_dd from line_no.
    translate gt_selfields_dd-SCRTEXT_M to upper case. "#EC TRANSLANG
    if gt_selfields_dd-fieldname cs s_value or
       gt_selfields_dd-SCRTEXT_M cs s_value.
       ld_found = true.
       ld_tabix = sy-tabix.
       exit.
    endif.
 endloop.
 IF ld_found = true.
    DD_TC-TOP_LINE = ld_TABIX.
 else.
    message s555(kz) with s_value text-s02.
 ENDIF.

ENDFORM.                    " SEARCH_DD_FIELDNAME
