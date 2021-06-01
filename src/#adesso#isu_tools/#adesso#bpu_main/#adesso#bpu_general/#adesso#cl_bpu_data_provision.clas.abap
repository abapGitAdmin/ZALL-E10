class /ADESSO/CL_BPU_DATA_PROVISION definition
  public
  create public .

public section.

  class-data GR_PROCESS_DATA type ref to /IDXGC/IF_PROCESS_DATA_EXTERN .

  methods CONSTRUCTOR
    importing
      !IV_CASENR type EMMA_CNR
    raising
      /IDXGC/CX_GENERAL .
  methods GET_CASE_OBJECTS
    importing
      !IT_ACTUAL_OBJECTS type EMMA_COBJ_T
    returning
      value(RT_OBJECTS) type EMMA_COBJ_T
    raising
      /IDXGC/CX_GENERAL .
  methods GET_ACTORS
    importing
      !IT_ACTUAL_ACTOR type TSWHACTOR optional
    returning
      value(RT_ACTOR) type TSWHACTOR
    raising
      /IDXGC/CX_GENERAL .
  methods GET_RULE_CONTAINER
    importing
      !IT_CUST_RDP type /ADESSO/BPU_T_RDP
    returning
      value(RT_CONTAINER) type SWCONTTAB
    raising
      /IDXGC/CX_GENERAL .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  data GS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL .
  data GS_PROC_STEP_DATA_SRC type /IDXGC/S_PROC_STEP_DATA .
  data GS_PROC_STEP_DATA_ADD_SRC type /IDXGC/S_PROC_STEP_DATA .
  data GR_CTX type ref to /IDXGC/CL_PD_DOC_CONTEXT .
  data GS_CURRENT_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA .
  data GV_EXCEPTION_CODE type /IDXGC/DE_EXCP_CODE .
  data GS_CASE type EMMA_CASE .
  class-data GV_MTEXT type STRING .
  class-data GT_SEOSUBCODF type /ADESSO/BPU_T_SEOSUBCODF .

  methods DET_CASE_OBJECT
    importing
      !IS_CUST_OBJ type /ADESSO/BPU_S_OBJ
      !IV_OBJECT_ID type DATA
    returning
      value(RS_OBJECT) type BAPI_EMMA_CASE_OBJECT
    raising
      /IDXGC/CX_GENERAL .
  methods GET_CCAT
    returning
      value(RV_OBJECT_ID) type EMMA_CCAT
    raising
      /IDXGC/CX_GENERAL .
  methods GET_CONTRACT
    returning
      value(RV_OBJECT_ID) type VERTRAG
    raising
      /IDXGC/CX_GENERAL .
  methods GET_GRID
    returning
      value(RV_OBJECT_ID) type GRID_ID
    raising
      /IDXGC/CX_GENERAL .
  methods GET_INSTLN
    returning
      value(RV_OBJECT_ID) type ANLAGE
    raising
      /IDXGC/CX_GENERAL .
  methods GET_ISU_TASK
    returning
      value(RV_OBJECT_ID) type E_DEXTASKID
    raising
      /IDXGC/CX_GENERAL .
  methods GET_MANDT
    returning
      value(RV_OBJECT_ID) type SYST_MANDT
    raising
      /IDXGC/CX_GENERAL .
  methods GET_METER_PROC
    returning
      value(RV_OBJECT_ID) type /IDXGC/DE_METER_PROC
    raising
      /IDXGC/CX_GENERAL .
  methods GET_INT_UI
    returning
      value(RV_OBJECT_ID) type INT_UI
    raising
      /IDXGC/CX_GENERAL .
  methods GET_SYSID
    returning
      value(RV_OBJECT_ID) type SYST_SYSID
    raising
      /IDXGC/CX_GENERAL .
  methods GET_TYPE_OF_RETURN_PARAMETER
    importing
      !IV_CMPNAME type SEOCMPNAME
    returning
      value(RV_TYPE) type RS38L_TYP
    raising
      /IDXGC/CX_GENERAL .
  PRIVATE SECTION.
ENDCLASS.



CLASS /ADESSO/CL_BPU_DATA_PROVISION IMPLEMENTATION.


  METHOD constructor.
    DATA: lr_bpu_emma_case TYPE REF TO /adesso/cl_bpu_emma_case.

    lr_bpu_emma_case  = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
    gs_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
    gs_case           = lr_bpu_emma_case->get_case( ).
    gv_exception_code = lr_bpu_emma_case->get_exception_code( ).
  ENDMETHOD.


  METHOD det_case_object.
    DATA: ls_objid  TYPE swotobjid,
          ls_return TYPE swotreturn,
          lv_objhnd TYPE swo_objhnd.

    IF is_cust_obj-refobjtype IS NOT INITIAL.
      ls_objid-objtype = is_cust_obj-refobjtype.
      ls_objid-objkey  = iv_object_id.
      CALL FUNCTION 'SWO_CREATE'
        EXPORTING
          objtype = ls_objid-objtype
          objkey  = ls_objid-objkey
        IMPORTING
          object  = lv_objhnd
          return  = ls_return.
      IF ls_return-code = 0.
        CALL FUNCTION 'SWO_OBJECT_ID_GET'
          EXPORTING
            object = lv_objhnd
          IMPORTING
            return = ls_return
            objid  = ls_objid.
        IF ls_return-code <> 0.
          /idxgc/cx_general=>raise_exception_from_msg( ).
        ENDIF.
      ELSE.
        /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDIF.
      rs_object-celemname  = is_cust_obj-object.
      rs_object-refobjtype = is_cust_obj-refobjtype.
      rs_object-id         = ls_objid-objkey.
    ELSE.
      rs_object-celemname = is_cust_obj-object.
      rs_object-refstruct = is_cust_obj-refstruct.
      rs_object-reffield  = is_cust_obj-reffield.
      rs_object-id        = iv_object_id.
    ENDIF.
  ENDMETHOD.


  METHOD get_actors.
    DATA: lr_ctx             TYPE REF TO /idxgc/cl_pd_doc_context,
          lt_cust_rdp_group  TYPE TABLE OF /adesso/bpu_t_rdp,
          lt_cust_rdp        TYPE /adesso/bpu_t_rdp,
          lt_actor           TYPE tswhactor,
          lt_container       TYPE swconttab,
          lv_type            TYPE rs38l_typ,
          lv_object_id       TYPE REF TO data,
          lv_ccrule_previous TYPE emma_ccrule,
          lv_act_object      TYPE hrobjec_14.

    FIELD-SYMBOLS: <ft_cust_rdp> TYPE /adesso/bpu_t_rdp,
                   <fs_cust_rdp> TYPE /adesso/bpu_s_rdp.

    lt_cust_rdp = /adesso/cl_bpu_utility=>det_rules_and_methods( iv_casenr = gs_case-casenr ).
    SORT lt_cust_rdp BY ccrule.

    LOOP AT lt_cust_rdp ASSIGNING <fs_cust_rdp>.
      IF <fs_cust_rdp>-ccrule <> lv_ccrule_previous.
        APPEND INITIAL LINE TO lt_cust_rdp_group ASSIGNING <ft_cust_rdp>.
      ENDIF.
      APPEND <fs_cust_rdp> TO <ft_cust_rdp>.
    ENDLOOP.

    LOOP AT lt_cust_rdp_group ASSIGNING <ft_cust_rdp>.
      lt_container = get_rule_container( it_cust_rdp = <ft_cust_rdp> ).
      READ TABLE <ft_cust_rdp> ASSIGNING <fs_cust_rdp> INDEX 1.
      CONCATENATE 'AC' <fs_cust_rdp>-ccrule INTO lv_act_object.
      CLEAR: lt_actor.

      CALL FUNCTION 'RH_GET_ACTORS'
        EXPORTING
          act_object                = lv_act_object
        TABLES
          actor_container           = lt_container
          actor_tab                 = lt_actor
        EXCEPTIONS
          no_active_plvar           = 1
          no_actor_found            = 2
          exception_of_role_raised  = 3
          no_valid_agent_determined = 4
          no_container              = 5
          OTHERS                    = 6.
      IF sy-subrc <> 0.
        CLEAR lt_actor.
      ENDIF.

      APPEND LINES OF lt_actor TO rt_actor.
    ENDLOOP.

    APPEND LINES OF it_actual_actor TO rt_actor.

  ENDMETHOD.


  METHOD get_case_objects.
    DATA: lr_ctx       TYPE REF TO /idxgc/cl_pd_doc_context,
          lt_cust_obj  TYPE /adesso/bpu_t_obj,
          lv_type      TYPE rs38l_typ,
          lv_object_id TYPE REF TO data.

    FIELD-SYMBOLS: <fv_object_id> TYPE any.

    lt_cust_obj = /adesso/cl_bpu_utility=>det_case_objects_and_methods( iv_casenr = gs_case-casenr ).

    LOOP AT lt_cust_obj ASSIGNING FIELD-SYMBOL(<fs_cust_obj>).
      TRY.
          lv_type = get_type_of_return_parameter( iv_cmpname = <fs_cust_obj>-method ).
          CREATE DATA lv_object_id TYPE (lv_type).
          ASSIGN lv_object_id->* TO <fv_object_id>.
          CALL METHOD me->(<fs_cust_obj>-method) RECEIVING rv_object_id = <fv_object_id>.

          APPEND det_case_object( is_cust_obj = <fs_cust_obj> iv_object_id = <fv_object_id> ) TO rt_objects.

        CATCH cx_sy_dyn_call_illegal_method.
          MESSAGE e010(/adesso/bpu_general) WITH <fs_cust_obj>-method INTO gv_mtext.
          CALL METHOD /idxgc/cx_general=>raise_exception_from_msg( ).
        CATCH /idxgc/cx_general.
          MESSAGE e011(/adesso/bpu_general) WITH <fs_cust_obj>-object INTO gv_mtext.
          IF lr_ctx IS NOT BOUND.
            lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = gs_proc_step_data-proc_ref ).
          ENDIF.
          lr_ctx->gr_process_log->add_message_to_process_log(  ).
      ENDTRY.
    ENDLOOP.
    IF lr_ctx IS BOUND.
      lr_ctx->gr_process_log->save_process_log( ).
    ENDIF.

    LOOP AT it_actual_objects ASSIGNING FIELD-SYMBOL(<fs_object>).
      IF <fs_object>-hidden = abap_false.
        READ TABLE rt_objects TRANSPORTING NO FIELDS WITH KEY celemname = <fs_object>-celemname id = <fs_object>-id.
        IF sy-subrc <> 0.
          APPEND <fs_object> TO rt_objects.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_ccat.

    IF gs_case-ccat IS NOT INITIAL.
      rv_object_id = gs_case-ccat.
    ELSE.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  method GET_CONTRACT.

    rv_object_id = /adesso/cl_bpu_masterdata=>get_ever( iv_int_ui = gs_proc_step_data-int_ui iv_keydate = gs_proc_step_data-proc_date )-vertrag.

  endmethod.


  METHOD get_grid.
    DATA: ls_euigrid TYPE euigrid.

    CALL FUNCTION 'ISU_DB_EUIGRID_INT_SINGLE'
      EXPORTING
        x_int_ui     = gs_proc_step_data-int_ui
        x_keydate    = gs_proc_step_data-proc_date
      IMPORTING
        y_euigrid    = ls_euigrid
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    IF sy-subrc <> 0 OR ls_euigrid-grid_id IS INITIAL.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ELSE.
      rv_object_id = ls_euigrid-grid_id.
    ENDIF.
  ENDMETHOD.


  METHOD get_instln.

    rv_object_id = /adesso/cl_bpu_masterdata=>get_instln( iv_int_ui = gs_proc_step_data-int_ui iv_keydate = gs_proc_step_data-proc_date ).

  ENDMETHOD.


  METHOD get_int_ui.

    IF gs_proc_step_data-int_ui IS NOT INITIAL.
      rv_object_id = gs_proc_step_data-int_ui.
    ELSE.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_isu_task.
    DATA: lv_dextaskid TYPE e_dextaskid.

    IF gs_proc_step_data-dextaskid IS INITIAL.
      IF gs_proc_step_data_src-dextaskid IS INITIAL.
        IF gs_proc_step_data_add_src-dextaskid IS NOT INITIAL.
          lv_dextaskid = gs_proc_step_data_add_src-dextaskid.
        ENDIF.
      ELSE.
        lv_dextaskid = gs_proc_step_data_src-dextaskid.
      ENDIF.
    ELSE.
      lv_dextaskid = gs_proc_step_data-dextaskid.
    ENDIF.

    IF lv_dextaskid IS NOT INITIAL.
      rv_object_id = lv_dextaskid.
    ELSE.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_mandt.
    IF sy-mandt IS NOT INITIAL.
      rv_object_id = sy-mandt.
    ELSE.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_meter_proc.
    DATA: lv_metmethod TYPE /idxgc/de_meter_proc.

    FIELD-SYMBOLS: <fs_diverse> TYPE /idxgc/s_diverse_details.

    IF gs_proc_step_data-diverse IS INITIAL.
      IF gs_proc_step_data_src-diverse IS INITIAL.
        READ TABLE gs_proc_step_data_add_src-diverse ASSIGNING <fs_diverse> INDEX 1.
      ELSE.
        READ TABLE gs_proc_step_data_src-diverse ASSIGNING <fs_diverse> INDEX 1.
      ENDIF.
    ELSE.
      READ TABLE gs_proc_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
    ENDIF.

    IF <fs_diverse> IS ASSIGNED AND <fs_diverse>-meter_proc IS NOT INITIAL.
      rv_object_id = <fs_diverse>-meter_proc.
    ELSE.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_rule_container.
    DATA: lr_ctx       TYPE REF TO /idxgc/cl_pd_doc_context,
          lv_type      TYPE rs38l_typ,
          lv_object_id TYPE REF TO data.

    FIELD-SYMBOLS: <fv_object_id> TYPE any.

    LOOP AT it_cust_rdp ASSIGNING FIELD-SYMBOL(<fs_cust_rdp>).
      TRY.
          lv_type = get_type_of_return_parameter( iv_cmpname = <fs_cust_rdp>-method ).
          CREATE DATA lv_object_id TYPE (lv_type).
          ASSIGN lv_object_id->* TO <fv_object_id>.
          CALL METHOD me->(<fs_cust_rdp>-method) RECEIVING rv_object_id = <fv_object_id>.

          CALL FUNCTION 'SWC_ELEMENT_SET'
            EXPORTING
              element       = <fs_cust_rdp>-object
              field         = <fv_object_id>
            TABLES
              container     = rt_container
            EXCEPTIONS
              type_conflict = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
            MESSAGE e011(/adesso/bpu_general) WITH <fs_cust_rdp>-object INTO gv_mtext.
            CALL METHOD /idxgc/cx_general=>raise_exception_from_msg( ).
          ENDIF.

        CATCH cx_sy_dyn_call_illegal_method.
          MESSAGE e010(/adesso/bpu_general) WITH <fs_cust_rdp>-method INTO gv_mtext.
          CALL METHOD /idxgc/cx_general=>raise_exception_from_msg( ).
        CATCH /idxgc/cx_general.
          MESSAGE e011(/adesso/bpu_general) WITH <fs_cust_rdp>-object INTO gv_mtext.
          IF lr_ctx IS NOT BOUND.
            lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = gs_proc_step_data-proc_ref ).
          ENDIF.
          lr_ctx->gr_process_log->add_message_to_process_log(  ).
          CALL METHOD /idxgc/cx_general=>raise_exception_from_msg( ).
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_sysid.

    IF sy-sysid IS NOT INITIAL.
      rv_object_id = sy-sysid.
    ELSE.
      /idxgc/cx_general=>raise_exception_from_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_type_of_return_parameter.
    DATA: ls_cust_gen TYPE /adesso/bpu_s_gen.

    ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).

    IF gt_seosubcodf IS INITIAL.
      SELECT * FROM seosubcodf INTO TABLE gt_seosubcodf WHERE clsname = ls_cust_gen-data_prov_class AND sconame = 'RV_OBJECT_ID'.
    ENDIF.

    LOOP AT gt_seosubcodf ASSIGNING FIELD-SYMBOL(<fs_seosubcodf>) WHERE cmpname = iv_cmpname.
      rv_type = <fs_seosubcodf>-type.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
