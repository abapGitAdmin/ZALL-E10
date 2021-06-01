FUNCTION ZSE16N_START.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_TAB) TYPE  SE16N_TAB OPTIONAL
*"     VALUE(I_DISPLAY) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_EXIT_SELFIELD_FB) TYPE  FUNCNAME DEFAULT SPACE
*"     VALUE(I_SINGLE_TABLE) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_HANA) TYPE  CHAR1 DEFAULT SPACE
*"--------------------------------------------------------------------
data: ld_dynnr like sy-dynnr value '0100'.

  if not i_tab is initial.
     gd-tab = i_tab.
  else.
     get parameter id 'DTB' field gd-tab.
  endif.

  if i_single_table = true.
     gd-single_tab = true.
  endif.

  if i_hana = true.
     gd-hana_active = true.
  endif.

*.in display mode do not allow maintenance
  gd-display = i_display.

*.if exit fb set, take this to determine the selection fields
*.the interface of this function has to look like
*.    exporting i_tab        type se16n_tab
*.    tables    it_selfields structure se16n_selfields
*.set the field INPUT = 0 in it_selfields to switch the field off
  gd-exit_fb_selfields = i_exit_selfield_fb.

*.Initialize the possible entry fields, depending on select option
  perform init_sel_opt.

  call screen ld_dynnr.

ENDFUNCTION.
