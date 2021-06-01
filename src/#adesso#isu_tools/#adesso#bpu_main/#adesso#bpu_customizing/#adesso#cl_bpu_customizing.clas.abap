class /ADESSO/CL_BPU_CUSTOMIZING definition
  public
  final
  create public .

public section.

  class-methods GET_CCAT
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
    returning
      value(RV_CCAT) type EMMA_CCAT
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_CUST_GEN
    returning
      value(RS_CUST_GEN) type /ADESSO/BPU_S_GEN
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_CUST_SOP
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
    returning
      value(RT_CUST_SOP) type /ADESSO/BPU_T_SOP
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_CUST_TEXTS
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
    returning
      value(RS_CUST_TXT) type /ADESSO/BPU_S_TXT
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_CUST_DUE_DATE
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
    returning
      value(RS_CUST_DUED) type /ADESSO/BPU_S_DUED
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_EXEC_SOL_MET_TYPE
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
    returning
      value(RV_EXEC_SOL_MET_TYPE) type /ADESSO/BPU_EXEC_SOL_MET_TYPE
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_OBJ_GROUP_ID
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
    returning
      value(RV_OBJ_GROUP_ID) type /ADESSO/BPU_OBJ_GROUP_ID
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_OBJECTS_FOR_GROUP_ID
    importing
      !IV_OBJ_GROUP_ID type /ADESSO/BPU_OBJ_GROUP_ID
    returning
      value(RT_CUST_OBJ) type /ADESSO/BPU_T_OBJ
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_OBJECTS_FOR_RULE
    importing
      !IV_CCRULE type EMMA_CCRULE
    returning
      value(RT_CUST_RDP) type /ADESSO/BPU_T_RDP .
  class-methods GET_PRIO
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
    returning
      value(RV_PRIO) type EMMA_CPRIO
    raising
      /IDXGC/CX_GENERAL .
  class-methods GET_RULE
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
    returning
      value(RV_CCRULE) type EMMA_CCRULE
    raising
      /IDXGC/CX_GENERAL .
protected section.

  class-data GS_CUST_GEN type /ADESSO/BPU_S_GEN .
  class-data GT_CUST_CCAT type /ADESSO/BPU_T_CCAT .
  class-data GT_CUST_DUED type /ADESSO/BPU_T_DUED .
  class-data GT_CUST_ESM type /ADESSO/BPU_T_ESM .
  class-data GT_CUST_OBJ type /ADESSO/BPU_T_OBJ .
  class-data GT_CUST_PID type /ADESSO/BPU_T_PID .
  class-data GT_CUST_PRIO type /ADESSO/BPU_T_PRIO .
  class-data GT_CUST_RDP type /ADESSO/BPU_T_RDP .
  class-data GT_CUST_RULE type /ADESSO/BPU_T_RULE .
  class-data GT_CUST_SOP type /ADESSO/BPU_T_SOP .
  class-data GT_CUST_TXT type /ADESSO/BPU_T_TXT .
  class-data GV_MTEXT type STRING .
private section.

  class-methods GET_PROCESS_CUST_GENERIC
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_STEP_NO type /IDXGC/DE_PROC_STEP_NO optional
      !IV_CHECK_ID type EIDESWTCHECKID optional
      !IV_CHECK_RESULT type /IDXGC/DE_CHECK_RESULT optional
      !IT_TABLE type ANY TABLE
    exporting
      value(ES_RESULT) type ANY
    raising
      /IDXGC/CX_GENERAL .
ENDCLASS.



CLASS /ADESSO/CL_BPU_CUSTOMIZING IMPLEMENTATION.


  METHOD get_ccat.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    DATA: ls_cust_ccat TYPE /adesso/bpu_s_ccat.

    IF gt_cust_ccat IS INITIAL.
      SELECT * FROM /adesso/bpu_ccat INTO TABLE gt_cust_ccat.
    ENDIF.

    get_process_cust_generic( EXPORTING iv_proc_id      = iv_proc_id
                                        iv_proc_version = iv_proc_version
                                        iv_proc_step_no = iv_proc_step_no
                                        iv_check_id     = iv_check_id
                                        iv_check_result = iv_check_result
                                        it_table        = gt_cust_ccat
                              IMPORTING es_result       = ls_cust_ccat ).

    rv_ccat = ls_cust_ccat-ccat.

  ENDMETHOD.


  METHOD GET_CUST_DUE_DATE.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    DATA: ls_cust_dued TYPE /adesso/bpu_s_dued.

    IF gt_cust_dued IS INITIAL.
      SELECT * FROM /adesso/bpu_dued INTO TABLE gt_cust_dued.
    ENDIF.

    get_process_cust_generic( EXPORTING iv_proc_id      = iv_proc_id
                                        iv_proc_version = iv_proc_version
                                        iv_proc_step_no = iv_proc_step_no
                                        iv_check_id     = iv_check_id
                                        iv_check_result = iv_check_result
                                        it_table        = gt_cust_dued
                              IMPORTING es_result       = rs_cust_dued ).

  ENDMETHOD.


  METHOD get_cust_gen.
***************************************************************************************************
* THIMEL-R, 20170612, BPEM für Utilities
***************************************************************************************************
    IF gs_cust_gen IS INITIAL.
      SELECT SINGLE * FROM /adesso/bpu_gen INTO gs_cust_gen WHERE bparea = /adesso/if_bpu_co=>gc_bparea_eide.
      IF sy-subrc <> 0.
        MESSAGE e001(/adesso/bpu_cust) WITH '/ADESSO/BPU_GEN' INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDIF.
    rs_cust_gen = gs_cust_gen.
  ENDMETHOD.


  METHOD get_cust_sop.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
*   Zu jeder Sequenznummer immer das speziellste Customizing zurückgeben.
***************************************************************************************************
    DATA: lt_range_seqnr  TYPE isu_ranges_tab. "Tabelle für schon gefundene Sequenznummern.

    FIELD-SYMBOLS: <fs_cust_sop>    TYPE /adesso/bpu_s_sop,
                   <fs_range_seqnr> TYPE isu_ranges.

    IF gt_cust_sop IS INITIAL.
      SELECT * FROM /adesso/bpu_sop INTO TABLE gt_cust_sop.
    ENDIF.

    IF iv_proc_step_no IS NOT INITIAL.
      IF iv_check_id IS NOT INITIAL.
        IF iv_check_result IS NOT INITIAL.
          LOOP AT gt_cust_sop ASSIGNING <fs_cust_sop> WHERE proc_id = iv_proc_id AND proc_version = iv_proc_version AND
            proc_step_no = iv_proc_step_no AND check_id = iv_check_id AND check_result = iv_check_result.
            APPEND <fs_cust_sop> TO rt_cust_sop.
            APPEND INITIAL LINE TO lt_range_seqnr ASSIGNING <fs_range_seqnr>.
            <fs_range_seqnr>-sign   = 'E'.
            <fs_range_seqnr>-option = 'EQ'.
            <fs_range_seqnr>-low    = <fs_cust_sop>-seqnr.
          ENDLOOP.
        ENDIF.

        LOOP AT gt_cust_sop ASSIGNING <fs_cust_sop> WHERE proc_id = iv_proc_id AND proc_version = iv_proc_version AND
          proc_step_no = iv_proc_step_no AND check_id = iv_check_id AND check_result IS INITIAL AND seqnr IN lt_range_seqnr.
          APPEND <fs_cust_sop> TO rt_cust_sop.
          APPEND INITIAL LINE TO lt_range_seqnr ASSIGNING <fs_range_seqnr>.
          <fs_range_seqnr>-sign   = 'E'.
          <fs_range_seqnr>-option = 'EQ'.
          <fs_range_seqnr>-low    = <fs_cust_sop>-seqnr.
        ENDLOOP.
      ENDIF.

      LOOP AT gt_cust_sop ASSIGNING <fs_cust_sop> WHERE proc_id = iv_proc_id AND proc_version = iv_proc_version AND
        proc_step_no = iv_proc_step_no AND check_id IS INITIAL AND check_result IS INITIAL AND seqnr IN lt_range_seqnr.
        APPEND <fs_cust_sop> TO rt_cust_sop.
        APPEND INITIAL LINE TO lt_range_seqnr ASSIGNING <fs_range_seqnr>.
        <fs_range_seqnr>-sign   = 'E'.
        <fs_range_seqnr>-option = 'EQ'.
        <fs_range_seqnr>-low    = <fs_cust_sop>-seqnr.
      ENDLOOP.
    ENDIF.

    LOOP AT gt_cust_sop ASSIGNING <fs_cust_sop> WHERE proc_id = iv_proc_id AND proc_version = iv_proc_version AND
      proc_step_no IS INITIAL AND check_id IS INITIAL AND check_result IS INITIAL AND seqnr IN lt_range_seqnr.
      APPEND <fs_cust_sop> TO rt_cust_sop.
      APPEND INITIAL LINE TO lt_range_seqnr ASSIGNING <fs_range_seqnr>.
      <fs_range_seqnr>-sign   = 'E'.
      <fs_range_seqnr>-option = 'EQ'.
      <fs_range_seqnr>-low    = <fs_cust_sop>-seqnr.
    ENDLOOP.

  ENDMETHOD.


  METHOD GET_CUST_TEXTS.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    IF gt_cust_txt IS INITIAL.
      SELECT * FROM /adesso/bpu_txt INTO TABLE gt_cust_txt.
    ENDIF.

    get_process_cust_generic( EXPORTING iv_proc_id      = iv_proc_id
                                        iv_proc_version = iv_proc_version
                                        iv_proc_step_no = iv_proc_step_no
                                        iv_check_id     = iv_check_id
                                        iv_check_result = iv_check_result
                                        it_table        = gt_cust_txt
                              IMPORTING es_result       = rs_cust_txt ).

  ENDMETHOD.


  METHOD get_exec_sol_met_type.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    DATA: ls_cust_esm TYPE /adesso/bpu_esm.

    IF gt_cust_esm IS INITIAL.
      SELECT * FROM /adesso/bpu_esm INTO TABLE gt_cust_esm.
    ENDIF.

    get_process_cust_generic( EXPORTING iv_proc_id      = iv_proc_id
                                        iv_proc_version = iv_proc_version
                                        iv_proc_step_no = iv_proc_step_no
                                        iv_check_id     = iv_check_id
                                        iv_check_result = iv_check_result
                                        it_table        = gt_cust_esm
                              IMPORTING es_result       = ls_cust_esm ).

    rv_exec_sol_met_type = ls_cust_esm-exec_sol_met_type.
  ENDMETHOD.


  METHOD get_objects_for_group_id.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    IF gt_cust_obj IS INITIAL.
      SELECT * FROM /adesso/bpu_obj INTO TABLE gt_cust_obj WHERE bparea = /adesso/if_bpu_co=>gc_bparea_eide.
    ENDIF.

    LOOP AT gt_cust_obj ASSIGNING FIELD-SYMBOL(<fs_cust_obj>) WHERE obj_group_id = iv_obj_group_id.
      APPEND <fs_cust_obj> TO rt_cust_obj.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_objects_for_rule.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    IF gt_cust_rule IS INITIAL.
      SELECT * FROM /adesso/bpu_rdp INTO TABLE gt_cust_rdp WHERE bparea = /adesso/if_bpu_co=>gc_bparea_eide.
    ENDIF.

    LOOP AT gt_cust_rdp ASSIGNING FIELD-SYMBOL(<fs_cust_rdp>) WHERE ccrule = iv_ccrule.
      APPEND <fs_cust_rdp> TO rt_cust_rdp.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_obj_group_id.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    DATA: ls_cust_pid TYPE /adesso/bpu_s_pid.

    IF gt_cust_pid IS INITIAL.
      SELECT * FROM /adesso/bpu_pid INTO TABLE gt_cust_pid.
    ENDIF.

    get_process_cust_generic( EXPORTING iv_proc_id      = iv_proc_id
                                        iv_proc_version = iv_proc_version
                                        iv_proc_step_no = iv_proc_step_no
                                        iv_check_id     = iv_check_id
                                        iv_check_result = iv_check_result
                                        it_table        = gt_cust_pid
                              IMPORTING es_result       = ls_cust_pid ).

    rv_obj_group_id = ls_cust_pid-obj_group_id.

  ENDMETHOD.


  METHOD get_prio.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    DATA: ls_cust_prio TYPE /adesso/bpu_s_prio.

    IF gt_cust_prio IS INITIAL.
      SELECT * FROM /adesso/bpu_prio INTO TABLE gt_cust_prio.
    ENDIF.

    get_process_cust_generic( EXPORTING iv_proc_id      = iv_proc_id
                                        iv_proc_version = iv_proc_version
                                        iv_proc_step_no = iv_proc_step_no
                                        iv_check_id     = iv_check_id
                                        iv_check_result = iv_check_result
                                        it_table        = gt_cust_prio
                              IMPORTING es_result       = ls_cust_prio ).

    rv_prio = ls_cust_prio-prio.

  ENDMETHOD.


  METHOD get_process_cust_generic.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite Utilities
*   Generische Methode um in der übergebenen Tabelle zu suchen. Die Suchparameter werden immer
*     genereller. Prozess-ID und -Version müssen immer übereinstimmen, da über das Customizing
*     keine Einträge ohne diese Werte angelegt werden können.
***************************************************************************************************
    DATA: lv_where_clause TYPE string,
          lv_counter      TYPE int2.

    DO 4 TIMES.
      CASE sy-index.
        WHEN 1.
          IF iv_proc_step_no IS NOT INITIAL AND iv_check_id IS NOT INITIAL AND iv_check_result IS NOT INITIAL.
            lv_where_clause = 'proc_id = iv_proc_id AND proc_version = iv_proc_version AND proc_step_no = iv_proc_step_no AND check_id = iv_check_id AND check_result = iv_check_result'.
          ELSE.
            CONTINUE.
          ENDIF.
        WHEN 2.
          IF iv_proc_step_no IS NOT INITIAL AND iv_check_id IS NOT INITIAL.
            lv_where_clause = 'proc_id = iv_proc_id AND proc_version = iv_proc_version AND proc_step_no = iv_proc_step_no AND check_id = iv_check_id AND check_result IS INITIAL'.
          ELSE.
            CONTINUE.
          ENDIF.
        WHEN 3.
          IF iv_proc_step_no IS NOT INITIAL.
            lv_where_clause = 'proc_id = iv_proc_id AND proc_version = iv_proc_version AND proc_step_no = iv_proc_step_no AND check_id IS INITIAL AND check_result IS INITIAL'.
          ELSE.
            CONTINUE.
          ENDIF.
        WHEN 4.
          lv_where_clause = 'proc_id = iv_proc_id AND proc_version = iv_proc_version AND proc_step_no IS INITIAL AND check_id IS INITIAL AND check_result IS INITIAL'.
      ENDCASE.

      lv_counter = 0.
      LOOP AT it_table INTO es_result WHERE (lv_where_clause).
        lv_counter = lv_counter + 1.
      ENDLOOP.
      IF lv_counter = 1.
        RETURN.
      ELSEIF lv_counter > 1.
        MESSAGE e003(/adesso/bpu_cust) INTO gv_mtext.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
    ENDDO.
  ENDMETHOD.


  METHOD get_rule.
***************************************************************************************************
* THIMEL-R, 20170612, adesso BPEM Suite für Utilities
***************************************************************************************************
    DATA: ls_cust_rule TYPE /adesso/bpu_s_rule.

    IF gt_cust_rule IS INITIAL.
      SELECT * FROM /adesso/bpu_rule INTO TABLE gt_cust_rule.
    ENDIF.

    get_process_cust_generic( EXPORTING iv_proc_id      = iv_proc_id
                                        iv_proc_version = iv_proc_version
                                        iv_proc_step_no = iv_proc_step_no
                                        iv_check_id     = iv_check_id
                                        iv_check_result = iv_check_result
                                        it_table        = gt_cust_rule
                              IMPORTING es_result       = ls_cust_rule ).

    rv_ccrule = ls_cust_rule-ccrule.

  ENDMETHOD.
ENDCLASS.
