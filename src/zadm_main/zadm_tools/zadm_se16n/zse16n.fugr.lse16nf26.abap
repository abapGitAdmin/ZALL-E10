*----------------------------------------------------------------------*
***INCLUDE LSE16NF26.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  RRI_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rri_search .

*.get data from current screen and call SE16S_RRI to find all tables
*.related to this item
  DATA: ls_sel_tab    TYPE rstisel.
  DATA: lt_sel_tab    TYPE  rsti_t_sel.
  DATA: lt_multi     LIKE se16n_selfields OCCURS 0 WITH HEADER LINE.
  DATA: lt_selfields LIKE se16n_selfields OCCURS 0 WITH HEADER LINE.
  DATA: lt_or_selfields TYPE se16n_or_t.
  DATA: ls_or_seltab TYPE se16n_or_seltab.
  DATA: ls_seltab    TYPE se16n_seltab.
  DATA: ls_selopt    TYPE rsdsselopt.
  DATA: ls_rows      TYPE lvc_s_row.
  DATA: ld_temp_row  TYPE i.
  DATA: lt_cols TYPE lvc_t_col.
  DATA: et_tables  TYPE se16s_search_area_t.
  DATA: ld_nr_of_tables LIKE sy-tabix.

  DATA: ld_abort(1).
  DATA: ld_row TYPE i.
  DATA: ld_col TYPE i.
  DATA: ld_value TYPE char200.
  DATA: ls_row_no TYPE lvc_s_roid.

  DATA: lt_rows  TYPE lvc_t_row,
        lt_cells TYPE lvc_t_cell.

  FIELD-SYMBOLS: <ls_cell> TYPE lvc_s_cell.

*.add table name
  CLEAR ls_sel_tab.
  ls_sel_tab-field   = '$tabname'.
  ls_sel_tab-sign    = 'I'.
  ls_sel_tab-option  = 'EQ'.
  ls_sel_tab-low     = gd-tab.
  APPEND ls_sel_tab TO lt_sel_tab.

* get selected rows
  alv_grid->get_selected_rows( IMPORTING et_index_rows = lt_rows ).

*.no rows selected
  IF lt_rows IS INITIAL.
*   no rows selected - check for cells
    alv_grid->get_selected_cells( IMPORTING et_cell = lt_cells ).
    IF NOT lt_cells IS INITIAL.
*     get selection conditions.
      LOOP AT lt_cells ASSIGNING <ls_cell>.
        ld_temp_row = <ls_cell>-row_id-index.
      ENDLOOP.
    ELSE.
*....try if at least cursor is in the list
      CALL METHOD alv_grid->get_current_cell
        IMPORTING
          e_row     = ld_row
          e_col     = ld_col
          es_row_no = ls_row_no
          e_value   = ld_value.
      IF ls_row_no-row_id <= 0.
*       ls_communication-stop = true.
        EXIT. " select everything
      ENDIF.
      CHECK: ls_row_no-row_id > 0.
      ld_temp_row = ls_row_no-row_id.
    ENDIF.
  ELSE.
    DESCRIBE TABLE lt_rows LINES sy-tabix.
*......if only one line selected, take standard logic
    IF sy-tabix = 1.
      READ TABLE lt_rows INTO ls_rows INDEX 1.
      ld_temp_row = ls_rows-index.
    ENDIF.
  ENDIF.

*.initialize internal tables
  lt_selfields[]    = gt_selfields[].
  lt_multi[]        = gt_multi[].
  lt_or_selfields[] = gt_or_selfields[].

*.get columns as needed for adapt
  CALL METHOD alv_grid->get_selected_columns
    IMPORTING
      et_index_columns = lt_cols.

*......adapt tables to fill criteria of chosen line into
*......selection table
  PERFORM adapt_tables TABLES   lt_selfields
                                lt_multi
                       USING    ld_temp_row
                                lt_cols
                                lt_rows
                                true
                       CHANGING lt_or_selfields.

  LOOP AT lt_or_selfields INTO ls_or_seltab.
    LOOP AT ls_or_seltab-seltab INTO ls_seltab.
      READ TABLE lt_selfields
                 WITH KEY fieldname = ls_seltab-field.
      IF sy-subrc = 0 AND lt_selfields-datatype = 'CLNT'.
*        skip client as selection criteria - not supported
        CONTINUE.
      ENDIF.
      CLEAR ls_sel_tab.
      ls_sel_tab-field   = ls_seltab-field.
      ls_sel_tab-sign    = ls_seltab-sign.
      ls_selopt-option   = ls_seltab-option.
      PERFORM get_option USING ls_seltab-sign
                               ls_seltab-option
                               ls_seltab-high
                               space
                               ls_seltab-field
                               gd-pool
                        CHANGING ls_selopt-option
                                 ls_seltab-low.
      ls_sel_tab-option  = ls_selopt-option.
      ls_sel_tab-low     = ls_seltab-low.
      ls_sel_tab-high    = ls_seltab-high.
      APPEND ls_sel_tab TO lt_sel_tab.
    ENDLOOP.
  ENDLOOP.

  CALL FUNCTION 'SE16S_RRI_CHOOSE_ENTITIES'
*   EXPORTING
*     I_TAB               =
    IMPORTING
      e_abort       = ld_abort
    CHANGING
      it_sel_tab    = lt_sel_tab
    EXCEPTIONS
      table_missing = 1
      OTHERS        = 2.

  IF sy-subrc <> 0 OR ld_abort = true.
    EXIT.
  ENDIF.

*.check that at least one entity has been chosen
  DESCRIBE TABLE lt_sel_tab LINES sy-tabix.
  CHECK: sy-tabix > 1.

  CALL FUNCTION 'SE16S_RRI_DET_AND_SEARCH'
    EXPORTING
      it_sel_tab    = lt_sel_tab
      i_noview      = 'X'
      i_parallel    = 'X'
      i_parallel_tasks = 10
      i_max_time       = 0
    IMPORTING
      e_nr_of_tables = ld_nr_of_tables
    CHANGING
      et_tables     = et_tables
    EXCEPTIONS
      no_tables_found = 1
      OTHERS          = 2.

  CHECK: NOT et_tables[] IS INITIAL.

  SORT et_tables BY entity_nr DESCENDING
                  count DESCENDING
                  tabname ASCENDING.

  CALL FUNCTION 'SE16S_RRI_DISPLAY_RESULT'
    STARTING NEW TASK 'PARTIAL'
    EXPORTING
      i_curr_nr_of_tables = ld_nr_of_tables
      i_only_hits         = 'X'
      i_max_tables        = ld_nr_of_tables
    CHANGING
      et_result_list = et_tables.

*  CALL FUNCTION 'SE16S_RRI_DET_SEARCH_DISPLAY'
*    STARTING NEW TASK 'SEARCH'
*    EXPORTING
*      it_sel_tab       = lt_sel_tab
*      i_noview         = 'X'
*      i_parallel       = 'X'
*      i_parallel_tasks = '10'
*      i_max_time       = 0
*      i_only_hits      = 'X'
**   IMPORTING
**     E_NR_OF_TABLES   =
*    CHANGING
*      et_tables        = et_tables
*    EXCEPTIONS
*      no_tables_found  = 1
*      OTHERS           = 2.
*
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.



ENDFORM.                    " RRI_SEARCH
