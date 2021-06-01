FUNCTION /adesso/bpu_solve_multirule .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      AC_CONTAINER STRUCTURE  SWCONT
*"      ACTOR_TAB STRUCTURE  SWHACTOR
*"----------------------------------------------------------------------
  DATA: lr_bpu_data_provision TYPE REF TO /adesso/cl_bpu_data_provision,
        lv_casenr             TYPE emma_cnr,
        lt_actor              TYPE tswhactor,
        lt_actual_actor       TYPE tswhactor.

  FIELD-SYMBOLS: <fs_container> TYPE swcont.

  READ TABLE ac_container ASSIGNING <fs_container> WITH KEY element = 'IV_EMMA_CNR'.
  IF <fs_container> IS ASSIGNED.
    lv_casenr = <fs_container>-value.
    TRY.
        lr_bpu_data_provision = NEW /adesso/cl_bpu_data_provision( lv_casenr ).
        APPEND LINES OF actor_tab TO lt_actual_actor.
        lt_actor = lr_bpu_data_provision->get_actors( it_actual_actor = lt_actual_actor ).
      CATCH /idxgc/cx_general.
        "Bei Fehler ohne Bearbeiterzuordnung weiter.
    ENDTRY.
  ENDIF.

  SORT lt_actor.
  DELETE ADJACENT DUPLICATES FROM lt_actor.
  APPEND LINES OF lt_actor TO actor_tab.
ENDFUNCTION.
