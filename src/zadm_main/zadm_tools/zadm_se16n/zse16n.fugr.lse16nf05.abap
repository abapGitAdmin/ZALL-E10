*----------------------------------------------------------------------*
***INCLUDE LSE16NF05.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form hide_empty_columns
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM hide_empty_columns .

  DATA: ls_layout       TYPE lvc_s_layo.
  DATA: lt_fieldcatalog TYPE lvc_t_fcat.
  DATA: lt_my_fcat      TYPE lvc_t_fcat.
  DATA: lt_filter       TYPE lvc_t_filt.
  DATA: lt_sort         TYPE lvc_t_sort.
  DATA: ls_fcat         TYPE lvc_s_fcat.
  DATA: ls_my_fcat      TYPE lvc_s_fcat.
  DATA: ld_tabix        TYPE sy-tabix.
  FIELD-SYMBOLS: <wa>, <f>.

*.This form reads the current layout,
*.checks the content of the result
*.hides all columns that are empty all over the list
*.applies the current layout with the newly hided columns

  CALL METHOD alv_grid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = lt_fieldcatalog.
  CALL METHOD alv_grid->get_frontend_layout
    IMPORTING
      es_layout = ls_layout.
  CALL METHOD alv_grid->get_filter_criteria
    IMPORTING
      et_filter = lt_filter.
  CALL METHOD alv_grid->get_sort_criteria
    IMPORTING
      et_sort = lt_sort.

  lt_my_fcat[] = lt_fieldcatalog[].

*.this can toggle between hide columns and show them again

*.columns are currently hided, show them again
  IF NOT gt_fieldcat_empty[] IS INITIAL.
    LOOP AT gt_fieldcat_empty INTO ls_my_fcat
           WHERE ref_table = gd-tab.
      READ TABLE lt_fieldcatalog INTO ls_fcat WITH KEY
            tabname   = ls_my_fcat-tabname
            fieldname = ls_my_fcat-fieldname.
      IF sy-subrc = 0.
        ls_fcat-no_out = ls_my_fcat-no_out.
        MODIFY lt_fieldcatalog FROM ls_fcat INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
    REFRESH gt_fieldcat_empty.
  ELSE.
*.lt_fieldcatalog contains fields from the table, text table,
*.joined tables and SE16N-Fields. Take care of REF_TABLE = tab
    LOOP AT <all_table> ASSIGNING <wa>.
      LOOP AT lt_my_fcat INTO ls_my_fcat
             WHERE ref_table = gd-tab
              AND  no_out    <> true.
        ld_tabix = sy-tabix.
        ASSIGN COMPONENT ls_my_fcat-fieldname OF STRUCTURE <wa> TO <f>.
*.....if column contains a value, delete it from the table
        IF NOT <f> IS INITIAL.
          DELETE lt_my_fcat INDEX ld_tabix.
        ENDIF.
      ENDLOOP.
*...if no column left anymore, skip checking as all columns are filled
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDLOOP.
*.remaining lines in lt_my_fcat contain columns without any value
    LOOP AT lt_my_fcat INTO ls_my_fcat
           WHERE ref_table = gd-tab
             AND no_out    <> true.
      ld_tabix = sy-tabix.
      READ TABLE lt_fieldcatalog INTO ls_fcat WITH KEY
            tabname   = ls_my_fcat-tabname
            fieldname = ls_my_fcat-fieldname.
      IF sy-subrc = 0.
*.......store current no_out according layout
        ls_my_fcat-no_out = ls_fcat-no_out.
        MODIFY lt_my_fcat FROM ls_my_fcat INDEX ld_tabix.
        ls_fcat-no_out = true.
        MODIFY lt_fieldcatalog FROM ls_fcat INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

*.store the columns that were hided
    gt_fieldcat_empty[] = lt_my_fcat[].
  ENDIF.

  CALL METHOD alv_grid->set_frontend_fieldcatalog
    EXPORTING
      it_fieldcatalog = lt_fieldcatalog.
  CALL METHOD alv_grid->set_frontend_layout
    EXPORTING
      is_layout = ls_layout.
  CALL METHOD alv_grid->set_filter_criteria
    EXPORTING
      it_filter = lt_filter.
  CALL METHOD alv_grid->set_sort_criteria
    EXPORTING
      it_sort = lt_sort.

  CALL METHOD alv_grid->refresh_table_display.

ENDFORM.
