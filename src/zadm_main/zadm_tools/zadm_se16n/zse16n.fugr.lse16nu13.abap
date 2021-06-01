FUNCTION SE16N_GET_DRILLDOWN_DATA.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_TAB) TYPE  SE16N_TAB OPTIONAL
*"  TABLES
*"      LT_SELFIELDS STRUCTURE  SE16N_SELFIELDS
*"  EXCEPTIONS
*"      CANCELED
*"----------------------------------------------------------------------

data: lt_save_selfields like se16n_selfields occurs 0 with header line.
data: ld_ojkey type tswappl.

  clear gd_cancel.

*.save input in case of cancel
  lt_save_selfields[] = lt_selfields[].
  ld_ojkey            = gd-ojkey.

*.store inout into global table for display in popup
  gt_selfields_dd[] = lt_selfields[].
  gd_dd_tab         = i_tab.
*.call screen to enter the data
  call screen 2000 starting at 2 2 ending at 70 30.

  if gd_cancel = true.
     lt_selfields[] = lt_save_selfields[].
     gd-ojkey       = ld_ojkey.
     raise canceled.
  else.
     lt_selfields[] = gt_selfields_dd[].
  endif.

ENDFUNCTION.
