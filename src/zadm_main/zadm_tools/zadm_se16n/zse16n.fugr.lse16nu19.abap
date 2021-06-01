FUNCTION se16n_create_and_seltab.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_POOL) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_JOIN_ACTIVE) TYPE  CHAR1 DEFAULT SPACE
*"  TABLES
*"      ET_WHERE
*"  CHANGING
*"     REFERENCE(IT_AND_SELTAB) TYPE  SE16N_AND_T
*"----------------------------------------------------------------------
  DATA: lt_and_selfields TYPE se16n_and_t.
  DATA: lt_or_seltab     TYPE se16n_or_t.
  DATA: ls_or_seltab TYPE se16n_or_seltab.
  DATA: lt_seltab    TYPE TABLE OF se16n_seltab.
  DATA: lt_where     TYPE se16n_where_132 OCCURS 0 WITH HEADER LINE.
  DATA: ld_multi(1).
  DATA: ld_multi_or(1).

*.Table it_and_seltab contains a counter and a deep table that contains
*.the selection criteria for this counter.

**.first check if every line really contains selections
*  LOOP AT it_and_seltab INTO ls_or_seltab.
*    IF ls_or_seltab-seltab[] IS INITIAL.
*      DELETE it_or_seltab INDEX sy-tabix.
*    ENDIF.
*  ENDLOOP.
  DESCRIBE TABLE it_and_seltab LINES sy-tabix.
  IF sy-tabix > 1.
    ld_multi = true.
    et_where = '('.
    APPEND et_where.
  ELSE.
    ld_multi = false.
  ENDIF.
  LOOP AT it_and_seltab INTO lt_or_seltab.
    IF sy-tabix > 1.
      et_where = ') AND ('.
      APPEND et_where.
    ENDIF.
    DESCRIBE TABLE lt_or_seltab LINES sy-tabix.
    IF sy-tabix > 1.
      ld_multi_or = true.
      et_where = '('.
      APPEND et_where.
    ELSE.
      ld_multi_or = false.
    ENDIF.
*...this is the former OR-clause
    LOOP AT lt_or_seltab INTO ls_or_seltab.
      IF sy-tabix > 1.
        et_where = ') OR ('.
        APPEND et_where.
      ENDIF.
      REFRESH: lt_seltab, lt_where.
      APPEND LINES OF ls_or_seltab-seltab TO lt_seltab.
      CALL FUNCTION 'SE16N_CREATE_SELTAB'
        EXPORTING
          i_pool          = i_pool
          i_primary_table = true
          i_join_active   = i_join_active
        TABLES
          lt_sel          = lt_seltab
          lt_where        = lt_where.
      APPEND LINES OF lt_where TO et_where.
    ENDLOOP.
    IF ld_multi_or = true.
      et_where = ')'.
      APPEND et_where.
    ENDIF.
  ENDLOOP.
  IF ld_multi = true.
    et_where = ')'.
    APPEND et_where.
  ENDIF.
*.if no restrictions were entered, add role definition
  IF et_where[] IS INITIAL.
    PERFORM adapt_se16n_role TABLES et_where
                             USING  true
                                    i_join_active.
  ENDIF.


ENDFUNCTION.
