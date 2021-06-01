FUNCTION SE16N_MULTI_FIELD_INPUT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(LS_SELFIELDS) LIKE  SE16N_SELFIELDS
*"  STRUCTURE  SE16N_SELFIELDS
*"     VALUE(LD_DISPLAY) TYPE  CHAR1 OPTIONAL
*"     VALUE(LD_CHECK_INPUT_FUNCNAME) TYPE  FUNCNAME OPTIONAL
*"     VALUE(LD_CURRENCY) TYPE  SYCURR OPTIONAL
*"  TABLES
*"      LT_MULTI_SELECT STRUCTURE  SE16N_SELFIELDS OPTIONAL
*"      LT_EXCLUDE_SELOPT STRUCTURE  SE16N_SEL_OPTION OPTIONAL
*"----------------------------------------------------------------------
data: ld_lines  like sy-tabix.
data: ls_dfies  like dfies.
data: ld_lfieldname   like dfies-lfieldname.
data: ld_sign         like se16n_selfields-sign.
data: ls_multi_select like se16n_selfields.

*.global variables for list output
  gd_fieldname = ls_selfields-fieldname.
  gd_scrtext_m = ls_selfields-scrtext_m.
  gd_datatype  = ls_selfields-datatype.
  gd_currency  = ld_currency.

*.in external call the DDIC-Info is not available
  if ls_selfields-intlen is initial.
     ld_lfieldname = ls_selfields-fieldname.
     if ls_selfields-sign <> space.
       ld_sign = ls_selfields-sign.
     else.
       ld_sign = 'I'.
     endif.
     CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
         TABNAME              = ls_selfields-tabname
         LFIELDNAME           = ld_lfieldname
       IMPORTING
         DFIES_WA             = ls_dfies
       EXCEPTIONS
         NOT_FOUND            = 1
         INTERNAL_ERROR       = 2
         OTHERS               = 3.
     IF SY-SUBRC = 0.
        move-corresponding ls_dfies to ls_selfields.
        ls_selfields-sign = ld_sign.
     ENDIF.
  endif.

*.SE16N anyway has gt_selfields filled. Other applications not,
*.but it is needed --> take new structure
  gs_multi_sel = ls_selfields.
  if gd-tab = space.
     gd-tab = ls_selfields-tabname.
  endif.

*.exit to check input data
  gd_chk_inp_func = ld_check_input_funcname.

*.display mode active ?
  gd_mf_display = ld_display.

*.exclude select-options
  gt_excl_selopt[] = lt_exclude_selopt[].

*.Initialize the possible entry fields, depending on select option
  if gt_sel_init[] is initial.
     perform init_sel_opt.
  endif.

  clear   gt_multi_select.
  refresh gt_multi_select.
  describe table lt_multi_select lines ld_lines.
*.Already input in there
  if ld_lines > 0.
*....add DDIC-Info if not available
     clear ls_dfies.
     move-corresponding ls_selfields to ls_dfies.
     loop at lt_multi_select where intlen is initial.
        move-corresponding lt_multi_select to ls_multi_select.
        move-corresponding ls_dfies to lt_multi_select.
        lt_multi_select-sign = ls_multi_select-sign.
        modify lt_multi_select.
     endloop.
     gt_multi_select[] = lt_multi_select[].
*....although there are already lines, open new lines as well
*....if no empty ones are available
     loop at gt_multi_select
           where low  = space
             and high = space
             and option = space.
     endloop.
     if sy-subrc <> 0.
        read table gt_multi_select index 1.
        clear: gt_multi_select-low,
               gt_multi_select-high,
               gt_multi_select-sign,
               gt_multi_select-option.
        do new_lines times.
           append gt_multi_select.
        enddo.
     endif.
*.not yet any input made
  else.
     move-corresponding ls_selfields to gt_multi_select.
     clear: gt_multi_select-low,
            gt_multi_select-high.
     do new_lines times.
        append gt_multi_select.
     enddo.
  endif.

  call screen 0001 starting at 2 2 ending at 78 15.

  case save_fcode.
*...Cancel, do not change the table
    when '&F12'.
*...Take new input
    when 'TAKE'.
       refresh lt_multi_select.
       loop at gt_multi_select where ( not ( low is initial ) or
                                       not ( high is initial ) ) or
                                       not option is initial.   "e.g. EQ space
          move-corresponding gt_multi_select to lt_multi_select.
          append lt_multi_select.
       endloop.
  endcase.
  clear gd_currency.

ENDFUNCTION.
