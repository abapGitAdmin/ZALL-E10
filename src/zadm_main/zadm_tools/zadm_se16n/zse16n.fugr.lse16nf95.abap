*&---------------------------------------------------------------------*
*&  Include           LSE16NF95
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SELECT_STANDARD_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SELECT_STANDARD_NEW TABLES   LT_WHERE
                         USING    value(TAB)
                                  value(i_max_lines)
                                  value(i_line_det)
                                  value(i_display_all)
                                  value(i_clnt_spez)
                         changing value(subrc)
                                  value(abort).

  data: ld_enough(1).

*.refresh result table
  refresh <all_table>.

**.determine select string in case of DDL-Source
*  perform select_cds_string using    tab
*                            changing gd-cds_string
*                                     abort.
*  check abort <> true.

*.call central select routine
  perform select_central tables   lt_where
                         using    tab
                                  i_clnt_spez
                                  i_max_lines
                                  i_display_all
                                  i_line_det
                                  space   "i_partial
                         changing subrc
                                  ld_enough.




ENDFORM.                               " SELECT_STANDARD_NEW

*&---------------------------------------------------------------------*
*&      Form  PARTIAL_SELECT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM PARTIAL_SELECT_NEW TABLES   LT_SEL_SEL STRUCTURE se16n_seltab
                        USING    value(TAB)
                                 value(i_line_det)
                                 value(i_display_all)
                                 value(i_clnt_spez)
                                 value(i_max_lines)
                        changing value(subrc)
                                 value(p_enough)
                                 value(abort).

  data: lt_where(72) occurs 0 with header line.
  data: ld_abort(1).
  data: ld_join_active(1).

**.determine select string in case of DDL-Source
*  perform select_cds_string using    tab
*                            changing gd-cds_string
*                                     abort.
*  check: abort <> true.

  if gd-txt_join_active = true or
     gd-oj_join_active  = true.
    ld_join_active = true.
  endif.

  CALL FUNCTION 'SE16N_CREATE_SELTAB'
    EXPORTING
      i_pool          = gd-pool
      i_primary_table = true
      i_join_active   = ld_join_active
    TABLES
      LT_SEL          = lt_sel_sel
      LT_WHERE        = lt_where.

*.call central select routine
  perform select_central tables   lt_where
                         using    tab
                                  i_clnt_spez
                                  i_max_lines
                                  i_display_all
                                  i_line_det
                                  true   "i_partial
                         changing subrc
                                  p_enough.




ENDFORM.                               " SELECT_STANDARD_NEW
*&---------------------------------------------------------------------*
*&      Form  SELECT_CENTRAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_WHERE  text
*      -->P_I_CLNT_SPEZ  text
*      -->P_LD_MAX_LINES  text
*      -->P_TRUE  text
*      -->P_SPACE  text
*      <--P_LD_SUBRC  text
*----------------------------------------------------------------------*
FORM SELECT_CENTRAL  TABLES   LT_WHERE
                     USING    value(tab)
                              value(I_CLNT_SPEZ)
                              value(I_MAX_LINES)
                              value(i_display_all)
                              value(i_line_det)
                              value(i_partial)
                     CHANGING value(SUBRC)
                              value(p_enough).


  data: field      type string,
        field2     type string,
        t_field    type table of string,
        t_order_by type table of string,
        t_group_by type table of string.
  data: ls_having  type se16n_seltab.
  data: ld_and(1).
  data: ld_hint(1024)  type c.
  data: ld_cds_string  type string.
  data: ld_count(255)  type c.
  data: ld_count_lines like sy-tabix.
  data: ld_max_lines   like sy-tabix.
  data: ld_tabix       like sy-tabix.
  data: ld_dbcnt       type p length 16.
  DATA: xroot          TYPE REF TO CX_ROOT.
  DATA: ls_where       type se16n_where_132.
  data: ld_having(1).

*.create sorting order
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
      IF gd-txt_join_active = true or
         gd-oj_join_active  = true.
         concatenate 'a~' gt_order_by_fields-field
                into gt_order_by_fields-field.
      endif.
    else.
      IF gd-txt_join_active = true or
         gd-oj_join_active  = true.
         concatenate 'a~' gt_order_by_fields-field
                into gt_order_by_fields-field.
      endif.
    endif.
    append gt_order_by_fields-field to t_order_by.
  endloop.
*...Group-by select**********************************************
  if not gt_sum_up_fields[] is initial or
     not gt_group_by_fields[] is initial or
     not gt_aggregate_fields[] is initial.
*......new group-by select
    loop at gt_group_by_fields.
      IF gd-txt_join_active = true or
         gd-oj_join_active  = true.
         concatenate 'a~' gt_group_by_fields-field
                into gt_group_by_fields-field.
      endif.
      append gt_group_by_fields-field to t_group_by.
      append gt_group_by_fields-field to t_field.
    endloop.
*...join needs the fields also in grouping
*.add fields for join on text table
    IF gd-txt_join_active = true.
      loop at gt_txt_fields into field.
        concatenate 'b~' field into field.
        append field to t_group_by.
      endloop.
    ENDIF.
*.add fields for join on other tables
    IF gd-oj_join_active = true.
      loop at gt_fieldcat_oj_2 into gs_fieldcat_oj_2.
        read table gt_table_letter into gs_table_letter
            with key tabname = gs_fieldcat_oj_2-ref_tab.
*.......aggregation has been activated
        if gs_fieldcat_oj_2-aggregate <> space.
           continue.  " will be done later
        else.
          read table gt_fieldcat_grp into gs_fieldcat_grp
            with key tabname   = gs_fieldcat_oj_2-ref_tab
                     fieldname = gs_fieldcat_oj_2-org_field.
*.......summarize if currency or quantity
        if gs_fieldcat_grp-datatype = 'CURR' or
           gs_fieldcat_grp-datatype = 'QUAN'.
          field = |SUM( { gs_table_letter-letter }~{ gs_fieldcat_oj_2-org_field } ) as { gs_fieldcat_oj_2-org_field }|.
          append field to t_field.
*.......if not, group it
        else.
          field = |{ gs_table_letter-letter }~{ gs_fieldcat_oj_2-org_field }|.
          append field to t_group_by.
          endif.
        endif.
      endloop.
    ENDIF.

    loop at gt_sum_up_fields.
      IF gd-txt_join_active = true or
         gd-oj_join_active  = true.
         concatenate 'a~' gt_sum_up_fields-field
                into field2.
      else.
         field2 = gt_sum_up_fields-field.
      endif.
      field = |SUM( { field2 } ) as { gt_sum_up_fields-field } |.
      append field to t_field.
    endloop.
    loop at gt_aggregate_fields.
      concatenate gt_aggregate_fields-low '(' into field.
      IF gd-txt_join_active = true or
         gd-oj_join_active  = true.
         concatenate 'a~' gt_aggregate_fields-field into
                     field2.
      else.
         field2 = gt_aggregate_fields-field.
      endif.
      concatenate field field2 ') as'
                   gt_aggregate_fields-field into field
                   separated by space.
      append field to t_field.
    endloop.
    field = |COUNT( * ) as { c_line_index }|.
    append field to t_field.
*...with grouping allow having clause
    if gd-min_count_dd <> true.
       if gd-min_count > 0.
         ld_having = true.
       endif.
    else.
       clear ld_having.
    endif.
*...if no grouping select all fields
  else.
    IF gd-txt_join_active = true or
       gd-oj_join_active  = true.
       field = 'a~*'.
    else.
       field = '*'.
    endif.
    append field to t_field.
  endif.

*********************************************************************
*..check for EXIT to influence Hint
*.call exit for DB-Hint and fill gd-hint and gd-hint_value
  clear: gd-hint, gd-hint_field, gd-hint_value.
  perform check_exit using c_event_db_hint
                           space
                           gd-tab
                     changing gd_dref.
  if gd-hint <> space.
    ld_hint = gd-hint.
    REPLACE gd-hint_field IN ld_hint WITH gd-hint_value.
*  if tab = 'V_GLPOS_N_CT'.
*    CONCATENATE 'dbsl_add_stmt with parameters ('
*           ' ''placeholder''   = ( ''$$rldnr$$'' , ''%RLDNR%'' ),'
*           ' ''request_flags'' = ''ANALYZE_MODEL'', '
*           ' ''request_flags'' = ''OLAP_PARALLEL_AGGREGATION'' '
*           ')' INTO ld_hint.
*    REPLACE '%RLDNR%' IN ld_hint WITH '0L'.
  else.
    if not gt_sum_up_fields[] is initial.
      case gd-fda.
        when space.
          ld_hint = |dbsl_add_stmt with parameters (              | &&
                    |'request_flags'='analyze_model',             | &&
                    |'request_flags'='olap_parallel_aggregation') |.
        when '1'.
          ld_hint = |dbsl_add_stmt with parameters (              | &&
                    |'request_flags'='analyze_model',             | &&
                    |'request_flags'='olap_parallel_aggregation') | &&
                    |&prefer_join_with_fda 1&|.
        when '2'.
          ld_hint = |dbsl_add_stmt with parameters (              | &&
                    |'request_flags'='analyze_model',             | &&
                    |'request_flags'='olap_parallel_aggregation') | &&
                    |&prefer_join_with_fda 0&|.
      endcase.
    endif.
  endif.
*..check for BADI's to influence the count(*)
*.call exit for change of count(*) logic for external views
  if i_line_det = true.
     clear: gd-count.
     perform check_exit using c_event_db_count
                              space
                              gd-tab
                        changing gd_dref.
     if gd-hint_count <> space.
        refresh t_field.
        ld_count = gd-hint_count.
        field = |SUM( { ld_count } ) as { ld_count } |.
        append field to t_field.
     endif.
  endif.

*  if tab = 'V_GLPOS_N_CT'.
*     refresh t_field.
*     ld_count = 'COUNTER'.
*     field = |SUM( { ld_count } ) as { ld_count } |.
*     append field to t_field.
*  endif.
*********************************************************************

*.add fields for join on text table
  IF gd-txt_join_active = true.
     loop at gt_txt_fields into field.
*......check if this fieldname also occurs in the main table
       read table gt_fieldcat_txt_double
            into gs_fieldcat_txt_double
            with key org_fieldname = field.
       if sy-subrc = 0.
          field2 = |b~{ field } as { gs_fieldcat_txt_double-new_fieldname }|.
*          concatenate 'b~' field ' AS '
*          gs_fieldcat_txt_double-new_fieldname into field.
          append field2 to t_field.
       else.
          concatenate 'b~' field into field.
          append field to t_field.
       endif.
     endloop.
  ENDIF.

*.add fields for outer joins
  if gd-oj_join_active  = true.
    loop at gt_fieldcat_oj_2 into gs_fieldcat_oj_2.
      read table gt_table_letter into gs_table_letter
            with key tabname = gs_fieldcat_oj_2-ref_tab.
*.......aggregation has been activated
      if gs_fieldcat_oj_2-aggregate <> space.
         field = |{ gs_fieldcat_oj_2-aggregate }( { gs_table_letter-letter }~{ gs_fieldcat_oj_2-org_field } ) as { gs_fieldcat_oj_2-org_field }|.
         append field to t_field.
      else.
         read table gt_fieldcat_grp into gs_fieldcat_grp
            with key tabname   = gs_fieldcat_oj_2-ref_tab
                     fieldname = gs_fieldcat_oj_2-org_field.
*.....summarizing has already been done before
      if gs_fieldcat_grp-datatype = 'CURR' or
         gs_fieldcat_grp-datatype = 'QUAN'.
        continue.
      endif.
      if gs_fieldcat_oj_2-field <> gs_fieldcat_oj_2-org_field.
         field = |{ gs_table_letter-letter }~{ gs_fieldcat_oj_2-org_field } as { gs_fieldcat_oj_2-field }|.
         append field to t_field.
      else.
         field = |{ gs_table_letter-letter }~{ gs_fieldcat_oj_2-org_field }|.
         append field to t_field.
         endif.
      endif.
    endloop.
  endif.

*.For new SQL-Syntax, I need kommas between all fields
  DESCRIBE TABLE t_field LINES ld_tabix.
  IF ld_tabix > 1.
    LOOP AT t_field INTO FIELD.
      CASE sy-tabix.
*.....last line
      WHEN ld_tabix.
*.....all others
      WHEN OTHERS.
        CONCATENATE field ',' INTO field.
        MODIFY t_field FROM field INDEX sy-tabix.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE t_group_by LINES ld_tabix.
  IF ld_tabix > 1.
    LOOP AT t_group_by INTO FIELD.
      CASE sy-tabix.
*.....last line
      WHEN ld_tabix.
*.....all others
      WHEN OTHERS.
        CONCATENATE field ',' INTO field.
        MODIFY t_group_by FROM field INDEX sy-tabix.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE t_order_by LINES ld_tabix.
  IF ld_tabix > 1.
    LOOP AT t_order_by INTO FIELD.
      CASE sy-tabix.
*.....last line
      WHEN ld_tabix.
*.....all others
      WHEN OTHERS.
        CONCATENATE field ',' INTO field.
        MODIFY t_order_by FROM field INDEX sy-tabix.
      ENDCASE.
    ENDLOOP.
  ENDIF.

*.create having-clause
  CLEAR gd-having_clause.
  IF ld_having = true.
    gd-having_clause = |count(*) GE @gd-min_count|.
  ENDIF.
*.check for additional having clause
  IF NOT gt_having_fields[] IS INITIAL AND
     gd-min_count_dd <> true.
    IF ld_having = true.
      ld_and = true.
    ENDIF.
    LOOP AT gt_having_fields INTO ls_having.
*......fieldname needs a~ in case of joins
      IF gd-txt_join_active = true OR
         gd-oj_join_active  = true.
        IF ld_and = true.
          FIELD = |AND SUM( a~{ ls_having-FIELD } ) { ls_having-option } '{ ls_having-low }'|.
        ELSE.
          FIELD = |SUM( a~{ ls_having-FIELD } ) { ls_having-option } '{ ls_having-low }'|.
        ENDIF.
        CONCATENATE gd-having_clause FIELD INTO gd-having_clause SEPARATED BY space.
      ELSE.
        IF ld_and = true.
          FIELD = |AND SUM( { ls_having-FIELD } ) { ls_having-option } '{ ls_having-low }'|.
        ELSE.
          FIELD = |SUM( { ls_having-FIELD } ) { ls_having-option } '{ ls_having-low }'|.
        ENDIF.
        CONCATENATE gd-having_clause FIELD INTO gd-having_clause SEPARATED BY space.
      ENDIF.
      ld_and = true.
    ENDLOOP.
    ld_having = true.
  ENDIF.
  CLEAR gd-min_count_dd.

*.set max lines to zero in case all should be read
  if i_display_all = true.
    ld_max_lines = 0.
  else.
    ld_max_lines = i_max_lines.
  endif.

*.in case of partial select, check how many lines already have been read
  if ld_max_lines > 0 and
     i_partial    = true.
     DESCRIBE TABLE <ALL_TABLE> LINES SY-TABIX.
     LD_MAX_LINES = LD_MAX_LINES - SY-TABIX.
     IF LD_MAX_LINES < 1.
        P_ENOUGH = TRUE.
        EXIT.
     ENDIF.
  endif.

*.catch system exceptions due to field overflow, wrong semantics...
  TRY.

*.client specific.................................................
  if i_clnt_spez = true.
*...data read restricted with max_lines...........................
    if i_line_det <> true.
      if gd-dbcon = space.
        if i_display_all = space.
          gd-select_type = 'A'.
        else.
          gd-select_type = 'C'.
        endif.
      else.
        if i_display_all = space.
          gd-select_type = 'K'.
        else.
          gd-select_type = 'M'.
        endif.
      endif.
*.....normal select into table....................................
      if i_partial <> true.
        if ld_having = true.
          SELECT (t_field) FROM (gd-cds_string)
            CLIENT SPECIFIED
            WHERE (lt_where)
            group by (t_group_by)
            having (gd-having_clause)
            order by (t_order_by)
            %_HINTS HDB @ld_hint
            INTO corresponding fields of TABLE @<all_table>
            connection (gd-dbcon)
            up to @ld_max_lines rows
            bypassing buffer.
        else.
          SELECT (t_field) FROM (gd-cds_string)
            CLIENT SPECIFIED
            WHERE (lt_where)
            group by (t_group_by)
            order by (t_order_by)
            %_HINTS HDB @ld_hint
            INTO corresponding fields of TABLE @<all_table>
            connection (gd-dbcon)
            up to @ld_max_lines rows
            bypassing buffer.
        endif.
*.....partial select with appending...............................
      else.
        if ld_having = true.
          SELECT (t_field) FROM (gd-cds_string)
            CLIENT SPECIFIED
            WHERE (lt_where)
            group by (t_group_by)
            having (gd-having_clause)
            order by (t_order_by)
            %_HINTS HDB @ld_hint
            appending corresponding fields of TABLE @<all_table>
            connection (gd-dbcon)
            up to @ld_max_lines rows
            bypassing buffer.
      else.
        SELECT (t_field) FROM (gd-cds_string)
            CLIENT SPECIFIED
            WHERE (lt_where)
            group by (t_group_by)
            order by (t_order_by)
            %_HINTS HDB @ld_hint
            appending corresponding fields of TABLE @<all_table>
            connection (gd-dbcon)
            up to @ld_max_lines rows
            bypassing buffer.
        endif.
      endif.
*...only determine number of lines................................
    else.
      if gd-dbcon = space.
        gd-select_type = 'E'.
      else.
        gd-select_type = 'O'.
      endif.
      if ld_count = space.
        try.
          SELECT count(*) FROM (gd-cds_string)
            CLIENT SPECIFIED
            WHERE (lt_where)
            into @ld_dbcnt
            connection (gd-dbcon)
            bypassing buffer.
          CATCH CX_SY_OPEN_SQL_DB INTO xroot.
          message xroot type 'I'.
        endtry.
      else.
        SELECT (t_field) FROM (gd-cds_string)
           CLIENT SPECIFIED
            WHERE (lt_where)
            %_HINTS HDB @ld_hint
            into @ld_count_lines
            connection (gd-dbcon)
            bypassing buffer.
        endselect.
      endif.
    endif.
*.no client.......................................................
  else.
*...data read restricted with max_lines...........................
    if i_line_det <> true.
      if gd-dbcon = space.
        if i_display_all = space.
          gd-select_type = 'B'.
        else.
          gd-select_type = 'D'.
        endif.
      else.
        if i_display_all = space.
          gd-select_type = 'L'.
        else.
          gd-select_type = 'N'.
        endif.
      endif.
*.....normal select into table....................................
      if i_partial <> true.
        if ld_having = true.
          SELECT (t_field) FROM (gd-cds_string)
            WHERE (lt_where)
            group by (t_group_by)
            having (gd-having_clause)
            order by (t_order_by)
            %_HINTS HDB @ld_hint
            INTO corresponding fields of TABLE @<all_table>
            connection (gd-dbcon)
            up to @ld_max_lines rows
            bypassing buffer.
        else.
          SELECT (t_field) FROM (gd-cds_string)
            WHERE (lt_where)
            group by (t_group_by)
            order by (t_order_by)
            %_HINTS HDB @ld_hint
            INTO corresponding fields of TABLE @<all_table>
            connection (gd-dbcon)
            up to @ld_max_lines rows
            bypassing buffer.
        endif.
*.....partial select with appending...............................
      else.
        if ld_having = true.
          SELECT (t_field) FROM (gd-cds_string)
            WHERE (lt_where)
            group by (t_group_by)
            having (gd-having_clause)
            order by (t_order_by)
            %_HINTS HDB @ld_hint
            appending corresponding fields of TABLE @<all_table>
            connection (gd-dbcon)
            up to @ld_max_lines rows
            bypassing buffer.
      else.
        SELECT (t_field) FROM (gd-cds_string)
            WHERE (lt_where)
            group by (t_group_by)
            order by (t_order_by)
            %_HINTS HDB @ld_hint
            appending corresponding fields of TABLE @<all_table>
            connection (gd-dbcon)
            up to @ld_max_lines rows
            bypassing buffer.
        endif.
      endif.
*...only determine number of lines................................
    else.
      if gd-dbcon = space.
        gd-select_type = 'F'.
      else.
        gd-select_type = 'P'.
      endif.
      if ld_count = space.
        try.
          SELECT count(*) FROM (gd-cds_string)
            WHERE (lt_where)
            into @ld_dbcnt
            connection (gd-dbcon)
            bypassing buffer.
          CATCH CX_SY_OPEN_SQL_DB INTO xroot.
          message xroot type 'I'.
        endtry.
      else.
        SELECT (t_field) FROM (gd-cds_string)
           WHERE (lt_where)
           %_HINTS HDB @ld_hint
           into @ld_count_lines
           connection (gd-dbcon)
           bypassing buffer.
        endselect.
      endif.
    endif.
  endif.

*.react on possible dumps
  CATCH cx_sy_open_sql_db INTO xroot.
     MESSAGE xroot TYPE 'I'.
  CATCH cx_sy_dynamic_osql_semantics INTO xroot.
     MESSAGE xroot TYPE 'I'.
  CATCH cx_sy_dynamic_osql_syntax INTO xroot.
     MESSAGE xroot TYPE 'I'.
  ENDTRY.

  if i_partial <> true.
    if gt_order_by_fields[] is initial.
      sort <all_table>.
    endif.
    if ld_count = space.
      if i_line_det = true.
        gd-number = ld_dbcnt.
      else.
        gd-number = sy-dbcnt.
      endif.
    else.
       gd-number = ld_count_lines.
    endif.
    gd-count   = gd-number.
    subrc      = sy-subrc.
    gt_field[] = t_field[].
  else.
    if i_line_det = true.
      gd-number = gd-number + ld_dbcnt.
    else.
      gd-number = gd-number + sy-dbcnt.
    endif.
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
  endif.
*.store data for ABAP-Output
  gt_group[] = t_group_by[].
  gt_order[] = t_order_by[].

ENDFORM.                    " SELECT_CENTRAL
*&---------------------------------------------------------------------*
*& Form SELECT_CDS_STRING
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TAB
*&      <-- GD_CDS_STRING
*&---------------------------------------------------------------------*
FORM select_cds_string  USING    VALUE(tab)
                        CHANGING ld_cds_string TYPE string
                                 VALUE(abort).

  DATA: ld_done(1).

*.only once per call
  case gd-cds_filled.
    when 'T'.
*.....in this case, use the string to generate JOIN on text table
      IF gd-txt_join_active = true.
         ld_cds_string = gd-cds_join_string.
      ELSE.
         ld_cds_string = gd-cds_save_string.
      ENDIF.
    when true.
      clear gd-txt_join_active.
      ld_cds_string = gd-cds_save_string.
  endcase.
  check: gd-cds_filled = space.

  CALL FUNCTION 'SE16N_CDS_SELECT_PREPARE'
  EXPORTING
    i_tab                             = tab
*     I_TESTMODE                        = ' '
    i_cds_no_sys                      = gd-cds_no_sys
  IMPORTING
    E_DONE                            = ld_done
  CHANGING
    C_STRING                          = ld_cds_string
  EXCEPTIONS
    NO_DDL_SOURCE                     = 1
    NO_ROLLNAME_REFERENCE_FOUND       = 2
    NO_BATCH_POSSIBLE                 = 3
    ABORT_BY_USER                     = 4
    OTHERS                            = 5.

*.error occured, do nothing
  IF sy-subrc <> 0.
    ld_cds_string = tab.
    gd-cds_filled = true.
    clear gd-txt_join_active.
    IF sy-subrc = 4.
      abort = true.
    ENDIF.
  ELSE.
*...no DDL available, do nothing
    IF ld_done <> true.
      ld_cds_string = tab.
      gd-cds_filled = 'T'.
*.....in this case, use the string to generate JOIN on text table
      IF gd-txt_join_active = true.
         ld_cds_string = gd-cds_join_string.
      ENDIF.
*...DDL available, take string
    ELSE.
      gd-cds_filled = true.
      clear gd-txt_join_active.
    ENDIF.
  ENDIF.

*.only once per call
  gd-cds_save_string = ld_cds_string.

*.Reset runtime to not count the popup-time
  perform get_time changing gd-start_time
                            gd-start_date.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PREPARE_TEXT_JOIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LD_CDS_STRING  text
*----------------------------------------------------------------------*
FORM prepare_text_join  CHANGING ld_cds_string TYPE string.

  DATA: lt_where    TYPE se16n_where_132   OCCURS 0 WITH HEADER LINE.
  DATA: lt_sel      LIKE se16n_seltab      OCCURS 0 WITH HEADER LINE.
  DATA: lt_dd05m    LIKE dd05m             OCCURS 0 WITH HEADER LINE.
  DATA: ls_dd05m    LIKE dd05m.
  DATA: LS_DD02V    LIKE DD02V.
  DATA: LD_TEXT_POOL(1).
  DATA: ld_check_fields(1).
  DATA: ld_one_missing(1).
  DATA: ls_group       TYPE se16n_output.
  DATA: dref           TYPE REF TO DATA.
  DATA: ld_txtfield    TYPE fieldname.
  DATA: wa_fieldcat    TYPE lvc_s_fcat.
  DATA: dy_fieldcat    TYPE lvc_s_fcat.
  DATA: lb_escape_char TYPE char1.
  DATA: ld_line        TYPE sytabix.
  DATA: ld_on_cond     TYPE string.
  DATA: ld_save_string TYPE string.
  FIELD-SYMBOLS: <fs>,
  <fs2>,
  <fs3>,
  <wa>  TYPE ANY,
  <add> TYPE ANY.

*.check if the grouping contains all fields necessary for join!
*.if not, do not allow join as it would not lead to results.
*.save original string
  ld_save_string = ld_cds_string.

  if not gt_sum_up_fields[] is initial or
     not gt_group_by_fields[] is initial or
     not gt_aggregate_fields[] is initial.
    ld_check_fields = true.
  endif.

*..check for entity and ddl
  perform check_entity using    gd-tab
                       changing gd-dy_tab1.
  perform check_entity using    gd-txt_tab
                       changing gd-dy_tab2.

*.concatenate JOIN-Condition into string
  ld_cds_string = | { gd-dy_tab1 } AS a LEFT OUTER JOIN { gd-dy_tab2 } AS b|.

*.generate ON-condition
*.get foreign key definition of text table
  CALL FUNCTION 'DDIF_TABL_GET'
  EXPORTING
    NAME                = gd-txt_tab
  IMPORTING
    DD02V_WA            = LS_DD02V
  TABLES
    DD05M_TAB           = lt_dd05m.
*.Join is not possible with Pool or Cluster, switch to old logic
  IF LS_DD02V-TABCLASS = 'POOL' OR
     LS_DD02V-TABCLASS = 'CLUSTER'.
    LD_TEXT_POOL = TRUE.
    gd-txt_pool   = true.
    ld_cds_string = ld_save_string.
    EXIT.
  ELSE.
    CLEAR LD_TEXT_POOL.
  ENDIF.

  ld_line = 1.
  LOOP AT gt_fieldcat INTO wa_fieldcat
     WHERE KEY = true.
*....read foreign key
    LOOP AT LT_DD05M INTO LS_DD05M
      WHERE CHECKTABLE = GD-TAB
        AND FORTABLE     = GD-TXT_TAB
        AND CHECKFIELD   = WA_FIELDCAT-FIELDNAME.
*.......check if field exists -> otherwise dump in select
      READ TABLE GT_FIELDCAT_TXTTAB INTO DY_FIELDCAT
          WITH KEY FIELDNAME = LS_DD05M-FORKEY.
*.....client is not allowed in ON-Clause
      IF gd-clnt_spez <> true.
        CHECK: dy_fieldcat-DATATYPE  <> 'CLNT'.
      ENDIF.
      CHECK: SY-SUBRC = 0.
*.....check if field is selected
      IF ld_check_fields = true.
        READ TABLE gt_group_by_fields INTO ls_group
        WITH KEY FIELD = wa_fieldcat-fieldname.
        IF sy-subrc <> 0.
          ld_one_missing = true.
        ENDIF.
      ENDIF.
*.....special logic for T002/T002T due to several language fields
      IF gd-txt_tab = 'T002T'.
        CHECK: ls_dd05m-forkey = 'SPRSL'.
      ENDIF.
*.......add field-relation to String
      ld_on_cond = | a~{ wa_fieldcat-fieldname } = b~{ ls_dd05m-forkey }|.
      IF ld_line = 1.
        CONCATENATE ld_cds_string ' ON' ld_on_cond INTO ld_cds_string.
      ELSE.
        CONCATENATE ld_cds_string ' AND' ld_on_cond INTO ld_cds_string.
      ENDIF.
      ADD 1 TO ld_line.
    ENDLOOP.
  ENDLOOP.
*.add language
  IF gd-txt_tab = 'T002T'. "specialty as this table has two SPRAS-Fields
    ld_on_cond = | b~SPRAS = @sy-langu |.
    CONCATENATE ld_cds_string ' AND' ld_on_cond INTO ld_cds_string.
  ELSE.
    READ TABLE GT_FIELDCAT_TXTTAB INTO DY_FIELDCAT
       WITH KEY DATATYPE = 'LANG'
                KEY      = TRUE.
    IF SY-SUBRC = 0.
      ld_on_cond = | b~{ dy_fieldcat-fieldname } = @sy-langu |.
      CONCATENATE ld_cds_string ' AND' ld_on_cond INTO ld_cds_string.
    ENDIF.
  ENDIF.

*.check if it can be used or not
  IF ld_one_missing = true.
    gd-txt_join_missing = true.
    ld_cds_string = ld_save_string.
  ELSE.
    gd-txt_join_active = true.
  ENDIF.

ENDFORM.
