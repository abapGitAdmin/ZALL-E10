FUNCTION SE16N_UT_GET_SELECT_CRITERIA.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_TAB) TYPE  SE16N_TAB OPTIONAL
*"     VALUE(I_CLNT_DEP) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_TITLE_TEXT) TYPE  SY-TITLE OPTIONAL
*"     VALUE(I_KEY_FIELD_BY_CALLER) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_DISPLAY) TYPE  CHAR1 OPTIONAL
*"  CHANGING
*"     VALUE(ET_OR_SELFIELDS) TYPE  SE16N_OR_T OPTIONAL
*"     VALUE(ET_MULTI_OR_ALL) TYPE  SE16N_SELFIELDS_T_OUT OPTIONAL
*"     VALUE(ET_OR_MUL_ALL) TYPE  SE16N_SELFIELDS_T_OUT OPTIONAL
*"     VALUE(IT_SELFIELDS) TYPE  SE16N_SELFIELDS_T_IN OPTIONAL
*"----------------------------------------------------------------------


   gd-tab                = i_tab.
   gd-clnt_dep           = i_clnt_dep.
   gd_111_display        = i_display.
   gd-ut_sel_screen_call = true.
   if i_title_text is initial.
     gd-ext_gui_title = i_tab.
   else.
     gd-ext_gui_title      = i_title_text.
   endif.

*..fill global tables for several calls
   gt_or_mul_all[]   = et_or_mul_all[].
   gt_multi_or_all[] = et_multi_or_all[].

   perform init_sel_opt.

   refresh gt_selfields.
*..fill table gt_selfields according input table
   perform ut_fill_tc using I_KEY_FIELD_BY_CALLER
                      changing it_selfields.

*..show popup with input --> this fills GT_MULTI_OR_ALL with low/high
*..and GT_OR_MUL_ALL with multi selection
   perform ut_show_selection_screen.

*..send screen with popup
   call screen 111 starting at 5 5 ending at 140 30.

*..fill data into exporting tables
   perform ut_fill_exporting_tables changing et_or_selfields
                                             et_or_mul_all
                                             et_multi_or_all.

ENDFUNCTION.
