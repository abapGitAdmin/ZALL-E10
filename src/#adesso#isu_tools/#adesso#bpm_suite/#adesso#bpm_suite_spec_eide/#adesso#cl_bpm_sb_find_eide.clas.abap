class /ADESSO/CL_BPM_SB_FIND_EIDE definition
  public
  inheriting from /ADESSO/CL_BPM_FILL_CONT_EIDE
  create public .

public section.

  methods BUILD_RULE_CONTAINER
    returning
      value(RT_RETURN) type WLF_TT_EDIMESSAGE
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods DETERMINE_RULE
    importing
      !IV_EXCEPTIONCODE type /IDXGC/DE_EXCP_CODE
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods DETERMINE_ACTORS
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods DETERMINE_CONT_ELEMENTS
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods DETERMINE_CONT_ELEMENTS_DP
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods GET_ACTORS
    returning
      value(RT_ACTORS) type TSWHACTOR
    raising
      /ADESSO/CX_BPM_GENERAL .

  methods FILL_CONT
    redefinition .
  methods EXECUTE
    redefinition .
protected section.

  data AV_RULE type HROBJID .
  data AT_RULE_CONT type SWCONTTAB .
  data AT_ACTORS type TSWHACTOR .
  data AT_CONT_ELEMENTS type SWDTCNTELE .
  data AT_CONT_ELEMENTS_DP type /ADESSO/TT_BPM_RDP .
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPM_SB_FIND_EIDE IMPLEMENTATION.


  METHOD build_rule_container.

    DATA: ls_message LIKE LINE OF rt_return.

    FIELD-SYMBOLS: <fs_cont_element>    LIKE LINE OF at_cont_elements,
                   <fs_cont_element_dp> LIKE LINE OF at_cont_elements_dp.

    LOOP AT at_cont_elements ASSIGNING <fs_cont_element>.
      READ TABLE at_cont_elements_dp ASSIGNING <fs_cont_element_dp> WITH KEY object = <fs_cont_element>-editelem.
      IF <fs_cont_element_dp> IS ASSIGNED.

        CALL METHOD me->(<fs_cont_element_dp>-dp_method)
          EXPORTING
            iv_element = <fs_cont_element>-editelem
          RECEIVING
            rs_message = ls_message.

        IF ls_message IS NOT INITIAL.
          APPEND ls_message TO rt_return.
        ENDIF.
        UNASSIGN <fs_cont_element_dp>.
      ELSE.
        ls_message = get_message( iv_msgid = '/ADESSO/BPM_CONT' iv_msgno = '002' iv_msgty = 'W' iv_msgv1 = <fs_cont_element>-editelem ).
        APPEND ls_message TO rt_return.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD determine_actors.
    DATA: lv_act_object TYPE rhobjects-object.

    CONCATENATE 'AC' av_rule INTO lv_act_object.

    CALL FUNCTION 'RH_GET_ACTORS'
      EXPORTING
        act_object                = lv_act_object
      TABLES
        actor_container           = at_rule_cont
        actor_tab                 = at_actors
      EXCEPTIONS
        no_active_plvar           = 1
        no_actor_found            = 2
        exception_of_role_raised  = 3
        no_valid_agent_determined = 4
        no_container              = 5
        OTHERS                    = 6.
    IF sy-subrc <> 0.
      CLEAR at_actors.
    ENDIF.
  ENDMETHOD.


  METHOD determine_cont_elements.
    CALL METHOD cl_emma_case=>get_wftask_container
      EXPORTING
        iv_wftasktyp = 'AC'
        iv_wftaskid  = av_rule
      IMPORTING
        et_element   = at_cont_elements
      EXCEPTIONS
        system_error = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDIF.
  ENDMETHOD.


  METHOD determine_cont_elements_dp.
    DATA: lv_bparea TYPE emma_bparea.

    lv_bparea = /adesso/cl_bpm_utility=>det_bparea( iv_ccat = av_ccat ).

    SELECT * FROM /adesso/bpm_rdp INTO TABLE at_cont_elements_dp WHERE dpm_rule = av_rule AND
                                                                       bparea = lv_bparea.

  ENDMETHOD.


  METHOD determine_rule.
    DATA: lt_check_result TYPE /idxgc/t_check_details,
          lt_bpm_rule     TYPE TABLE OF /adesso/bpm_rule,
          ls_bpm_rule     LIKE LINE OF lt_bpm_rule.

    FIELD-SYMBOLS: <fs_check_result>    LIKE LINE OF lt_check_result,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.
    TRY.
        READ TABLE as_current_proc_step_data-check ASSIGNING <fs_check_result> WITH KEY exception_code = iv_exceptioncode.

        IF <fs_check_result> IS ASSIGNED.
          ls_bpm_rule = /adesso/cl_bpm_cust_spec_eide=>determine_rule( iv_proc_id = as_proc_hdr-proc_id
                                                                       iv_proc_version = as_proc_hdr-proc_version
                                                                       iv_proc_step_no = as_current_proc_step_data-proc_step_no
                                                                       iv_chkid = <fs_check_result>-check_id
                                                                       iv_excn_name = <fs_check_result>-check_result ).
        ELSE.
          READ TABLE as_current_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result> WITH KEY exception_code = iv_exceptioncode.
          IF <fs_mtd_code_result> IS ASSIGNED.
            ls_bpm_rule = /adesso/cl_bpm_cust_spec_eide=>determine_rule( iv_proc_id = as_proc_hdr-proc_id
                                                                 iv_proc_version = as_proc_hdr-proc_version
                                                                 iv_proc_step_no = as_current_proc_step_data-proc_step_no
                                                                 iv_chkid = /idxgc/if_constants=>gc_check_id_mtd
                                                                 iv_excn_name = <fs_mtd_code_result>-check_value ).
          ELSE.
            ls_bpm_rule = /adesso/cl_bpm_cust_spec_eide=>determine_rule( iv_proc_id = as_proc_hdr-proc_id
                                                                         iv_proc_version = as_proc_hdr-proc_version
                                                                         iv_proc_step_no = as_current_proc_step_data-proc_step_no
                                                                         iv_chkid = space
                                                                         iv_excn_name = space ).
          ENDIF.
        ENDIF.
      CATCH /adesso/cx_bpm_utility.
        CLEAR av_rule.
        /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDTRY.

    av_rule = ls_bpm_rule-bpm_rule.

  ENDMETHOD.


  METHOD execute.

    DATA: lt_return TYPE wlf_tt_edimessage.

    FIELD-SYMBOLS: <fs_return> LIKE LINE OF lt_return.

    TRY.

        me->determine_rule( iv_exceptioncode = av_exceptioncode ).

        me->determine_cont_elements( ).

        me->determine_cont_elements_dp( ).

        lt_return = me->build_rule_container( ).
        IF lines( lt_return ) > 0.
          LOOP AT lt_return ASSIGNING <fs_return>.
            TRY.
                ar_ctx->add_message_log( is_message = <fs_return> ).
              CATCH /idxgc/cx_process_error.
            ENDTRY.
          ENDLOOP.
        ENDIF.

        me->determine_actors( ).
      CATCH /adesso/cx_bpm_general /adesso/cx_bpm_utility.
        /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  method FILL_CONT.
    swc_set_element at_rule_cont iv_element iv_data.
  endmethod.


  METHOD get_actors.
    rt_actors = me->at_actors.
  ENDMETHOD.
ENDCLASS.
