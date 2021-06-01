FUNCTION SE16N_CREATE_OR_SELTAB.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_POOL) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_JOIN_ACTIVE) TYPE  CHAR1 DEFAULT SPACE
*"  TABLES
*"      IT_OR_SELTAB TYPE  SE16N_OR_T
*"      ET_WHERE
*"----------------------------------------------------------------------
data: ls_or_seltab type SE16N_OR_SELTAB.
data: lt_seltab    like SE16N_SELTAB    occurs 0 with header line.
data: lt_where     type SE16N_WHERE_132 occurs 0 with header line.
data: ld_multi(1).

*.Table it_or_seltab contains a counter and a deep table that contains
*.the selection criteria for this counter.

*.first check if every line really contains selections
  loop at it_or_seltab into ls_or_seltab.
     if ls_or_seltab-seltab[] is initial.
        delete it_or_seltab index sy-tabix.
     endif.
  endloop.
  describe table it_or_seltab lines sy-tabix.
  if sy-tabix > 1.
     ld_multi = true.
     et_where = '('.
     append et_where.
  else.
     ld_multi = false.
  endif.
  loop at it_or_seltab into ls_or_seltab.
     if sy-tabix > 1.
        et_where = ') or ('.
        append et_where.
     endif.
     refresh: lt_seltab, lt_where.
     append lines of ls_or_seltab-seltab to lt_seltab.
     CALL FUNCTION 'SE16N_CREATE_SELTAB'
       EXPORTING
         i_pool         = i_pool
         i_primary_table = true
         i_join_active   = i_join_active
       TABLES
         LT_SEL         = lt_seltab
         LT_WHERE       = lt_where.
     append lines of lt_where to et_where.
  endloop.
  if ld_multi = true.
     et_where = ')'.
     append et_where.
  endif.
*.if no restrictions were entered, add role definition
  if et_where[] is initial.
     perform adapt_se16n_role tables et_where
                              using  true
                                     i_join_active.
  endif.


ENDFUNCTION.
