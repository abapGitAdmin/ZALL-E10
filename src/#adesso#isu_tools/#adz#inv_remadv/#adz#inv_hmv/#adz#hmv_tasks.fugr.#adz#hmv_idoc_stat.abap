FUNCTION /ADZ/HMV_IDOC_STAT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_CONST) TYPE  /ADZ/HMV_S_CONSTANTS
*"     VALUE(IS_SEL_PARAMS) TYPE  /ADZ/HMV_S_IDOC_SEL_PARAMS
*"  EXPORTING
*"     VALUE(ES_STATS) TYPE  /ADZ/HMV_IDOC
*"  TABLES
*"      ET_ALV_GRID_DATA STRUCTURE  /ADZ/HMV_S_MEMI_OUT
*"----------------------------------------------------------------------
  " Leider kann keine Klasse an den FuBa übergeben werden da dieser RFC-fähig sein muß
  DATA(lo_idoc_stat) = new /adz/cl_hmv_select_idocst_task(
      is_const     = is_const
      is_selparams = is_sel_params ).

  lo_idoc_stat->main(
      IMPORTING  et_alv_grid_data  = DATA(lt_alv_grid_data)
                 es_stats          = es_stats ).

  APPEND LINES OF lt_alv_grid_data TO et_alv_grid_data.

  "debug
*  STATICS lv_ctr TYPE i.
*  APPEND INITIAL LINE TO et_alv_grid_data ASSIGNING FIELD-SYMBOL(<lv_line>).
*  ADD 1 TO lv_ctr.
*  <lv_line>-opbel = lv_ctr.
*  data(lv_x) = lines( et_alv_grid_data ).
*  if lv_x > 1.
*    <lv_line>-opbel = |{ lv_x }-{ lv_ctr }|.
*  endif.
ENDFUNCTION.
