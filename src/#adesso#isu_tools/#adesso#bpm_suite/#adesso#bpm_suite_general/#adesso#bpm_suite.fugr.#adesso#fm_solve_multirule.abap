FUNCTION /ADESSO/FM_SOLVE_MULTIRULE .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      AC_CONTAINER STRUCTURE  SWCONT
*"      ACTOR_TAB STRUCTURE  SWHACTOR
*"----------------------------------------------------------------------

  DATA: lr_bpm_multi_rule TYPE REF TO /adesso/bpm_badi_multirule,
        lv_bparea         TYPE emma_bparea,
        lt_actors         TYPE tswhactor,
        lv_ccat           TYPE emma_ccat,
        lt_cnt_mr         TYPE swconttab.

  swc_get_element ac_container 'CCAT' lv_ccat.
  APPEND LINES OF ac_container TO lt_cnt_mr.

  TRY .
      lv_bparea = /adesso/cl_bpm_utility=>det_bparea( iv_ccat = lv_ccat ).

      GET BADI lr_bpm_multi_rule
        FILTERS
          business_process_area = lv_bparea.

      IF lr_bpm_multi_rule IS BOUND.
        lt_actors = lr_bpm_multi_rule->imp->solve_rule( it_container_multirule = lt_cnt_mr ).

      ENDIF.
    CATCH cx_badi_not_implemented /adesso/cx_bpm_utility.
      CLEAR lt_actors.
  ENDTRY.

  DELETE ADJACENT DUPLICATES FROM lt_actors.

  APPEND LINES OF lt_actors TO actor_tab.

ENDFUNCTION.
