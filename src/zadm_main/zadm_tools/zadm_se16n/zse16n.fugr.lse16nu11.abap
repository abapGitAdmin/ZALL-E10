FUNCTION SE16N_CREATE_SELECTION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_TAB) TYPE  SE16N_TAB OPTIONAL
*"     VALUE(I_DBCON) TYPE  DBCON_NAME OPTIONAL
*"     VALUE(I_MAX_LINES) TYPE  SY-TABIX DEFAULT 9999999
*"     VALUE(I_EXEC_STATEMENT) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_COUNT_NAME) TYPE  FIELDNAME OPTIONAL
*"     VALUE(I_ONLY_EXECUTE) TYPE  CHAR1 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_DBCNT) TYPE  SY-DBCNT
*"  TABLES
*"      IT_SEL STRUCTURE  SE16N_SELTAB OPTIONAL
*"      IT_GROUP_BY_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_ORDER_BY_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_SUM_UP_FIELDS STRUCTURE  SE16N_OUTPUT OPTIONAL
*"      IT_AGGREGATE_FIELDS STRUCTURE  SE16N_SELTAB OPTIONAL
*"  CHANGING
*"     VALUE(ET_WHERE) TYPE  SE16N_WHERE_TYPE OPTIONAL
*"     VALUE(ET_GROUP_BY) TYPE  SE16N_WHERE_TYPE OPTIONAL
*"     VALUE(ET_ORDER_BY) TYPE  SE16N_WHERE_TYPE OPTIONAL
*"     VALUE(ET_SUM_UP) TYPE  SE16N_WHERE_TYPE OPTIONAL
*"     VALUE(ET_SELECT) TYPE  SE16N_WHERE_TYPE OPTIONAL
*"     VALUE(ET_RESULT) TYPE  TABLE OPTIONAL
*"----------------------------------------------------------------------

  data: lt_where   type se16n_where_132 occurs 0 with header line.
  data: ls_line    type se16n_where_line.
  data: field      type string,
        t_field    type table of string,
        t_order_by type table of string,
        t_group_by type table of string.
  data: ls_select  type se16n_where_line.

  CALL FUNCTION 'SE16N_CREATE_SELTAB'
    TABLES
      LT_SEL   = it_sel
      LT_WHERE = lt_where.

  loop at it_order_by_fields.
    append it_order_by_fields-field to t_order_by.
    ls_line-line = it_order_by_fields-field.
    append ls_line to et_order_by.
  endloop.
  loop at it_group_by_fields.
    append it_group_by_fields-field to t_group_by.
    append it_group_by_fields-field to t_field.
    ls_line-line = it_group_by_fields-field.
    append ls_line to et_group_by.
  endloop.
  loop at it_sum_up_fields.
    field =
 |SUM( { it_sum_up_fields-field } ) as { it_sum_up_fields-field } |.
    append field to t_field.
    ls_line-line = it_sum_up_fields-field.
    append ls_line to et_sum_up.
  endloop.
*.it_aggregate_fields is special as in field the fieldname is stored,
*.but the value of the aggregation is in field LOW!
  loop at it_aggregate_fields.
     concatenate it_aggregate_fields-low '(' into field.
     concatenate field it_aggregate_fields-field ') as'
                  it_aggregate_fields-field into field
                  separated by space.
     append field to t_field.
  endloop.
*.add count name
  if i_count_name <> space.
    field = |COUNT( * ) as { i_count_name } |.
    append field to t_field.
  endif.

  define fill_lt.
    ls_select-line = &1.
    append ls_select to et_select.
  end-of-definition.

*.due to performance reasons do not fill output tables
  if i_only_execute = space.
    loop at t_field into field.
    fill_lt field.
  endloop.
  ls_select-line = |FROM { i_tab }|.
  append ls_select to et_select.
  ls_select-line = |connection { i_dbcon }|.
  append ls_select-line to et_select.
  fill_lt 'up to'.
  write i_max_lines to ls_select-line LEFT-JUSTIFIED.
  append ls_select to et_select.
  fill_lt 'rows'.
  fill_lt 'into corresponding fields of table <target>'.
  fill_lt 'bypassing buffer'.
  if not lt_where[] is initial.
    fill_lt 'WHERE'.
  endif.
  loop at lt_where.
    ls_select-line = lt_where.
    append ls_select to et_select.
    append ls_select to et_where.
  endloop.
  if not t_group_by[] is initial.
    fill_lt 'group by'.
  endif.
  loop at t_group_by into field.
    fill_lt field.
  endloop.
  if not t_order_by[] is initial.
    fill_lt 'order by'.
  endif.
  loop at t_order_by into field.
    fill_lt field.
  endloop.
  endif.

  if i_exec_statement = true.
    if t_field[] is initial.
       field = '*'.
       append field to t_field.
    endif.
    if i_dbcon <> space.
      SELECT (t_field) FROM (i_tab) connection (i_dbcon)
      up to i_max_lines rows
      INTO corresponding fields of TABLE et_result
      bypassing buffer
      WHERE (lt_where)
      group by (t_group_by)
      order by (t_order_by).
    else.
      SELECT (t_field) FROM (i_tab)
      up to i_max_lines rows
      INTO corresponding fields of TABLE et_result
      bypassing buffer
      WHERE (lt_where)
      group by (t_group_by)
      order by (t_order_by).
    endif.
    e_dbcnt = sy-dbcnt.
  endif.

ENDFUNCTION.
