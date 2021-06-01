class /ADESSO/CL_BPM_FIND_OBJ_EIDE definition
  public
  inheriting from /ADESSO/CL_BPM_FILL_CONT_EIDE
  create public .

public section.

  aliases GET_ACLASS
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_ACLASS .
  aliases GET_CCAT
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_CCAT .
  aliases GET_CUSTOMER_FLAG
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_CUSTOMER_FLAG .
  aliases GET_GRID
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_GRID .
  aliases GET_INSTLN_TYPE
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_INSTLN_TYPE .
  aliases GET_ISU_TASK
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_ISU_TASK .
  aliases GET_MANDT
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_MANDT .
  aliases GET_METMETHOD
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_METMETHOD .
  aliases GET_POD
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_POD .
  aliases GET_REGIOGROUP
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_REGIOGROUP .
  aliases GET_SYSID
    for /ADESSO/IF_BPM_FILL_CONTAINER~GET_SYSID .

  methods DETERMINE_AD_BPM_ID
    importing
      !IV_EXCEPTIONCODE type /IDXGC/DE_EXCP_CODE
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods DETERMINE_CONT_ELEMENTS_DP
    raising
      /ADESSO/CX_BPM_GENERAL .
  methods BUILD_BPM_CONTAINER
    returning
      value(RT_RETURN) type WLF_TT_EDIMESSAGE
    raising
      /ADESSO/CX_BPM_GENERAL .

  methods EXECUTE
    redefinition .
  methods FILL_CONT
    redefinition .
  methods GET_CLASS_ATTRIBUTE
    redefinition .
protected section.

  data AT_CONT_ELEMENTS_DP type /ADESSO/TT_BPM_OBJ .
  data AV_AD_BPM_ID type /ADESSO/AD_BPM_ID .
  data AT_BPM_CONT type EMMA_COBJ_T .
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPM_FIND_OBJ_EIDE IMPLEMENTATION.


  METHOD build_bpm_container.
    DATA: ls_message LIKE LINE OF rt_return.

    FIELD-SYMBOLS: <fs_cont_element_dp> LIKE LINE OF at_cont_elements_dp.

    LOOP AT at_cont_elements_dp ASSIGNING <fs_cont_element_dp>.
      CALL METHOD me->(<fs_cont_element_dp>-dp_method)
        EXPORTING
          iv_element = <fs_cont_element_dp>-object
        RECEIVING
          rs_message = ls_message.

      IF ls_message IS NOT INITIAL.
        APPEND ls_message TO rt_return.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD determine_ad_bpm_id.
    DATA: lt_check_result TYPE /idxgc/t_check_details,
          lt_bpm_pid      TYPE TABLE OF /adesso/bpm_pid,
          ls_bpm_pid      LIKE LINE OF lt_bpm_pid.

    FIELD-SYMBOLS: <fs_check_result>    LIKE LINE OF lt_check_result,
                   <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

    TRY.
        READ TABLE as_current_proc_step_data-check ASSIGNING <fs_check_result> WITH KEY exception_code = iv_exceptioncode.

        IF <fs_check_result> IS ASSIGNED.
          ls_bpm_pid = /adesso/cl_bpm_cust_spec_eide=>determine_bpm_id( iv_proc_id = as_proc_hdr-proc_id
                                                                        iv_proc_version = as_proc_hdr-proc_version
                                                                        iv_proc_step_no = as_current_proc_step_data-proc_step_no
                                                                        iv_chkid = <fs_check_result>-check_id
                                                                        iv_excn_name = <fs_check_result>-check_result ).
        ELSE.
          READ TABLE as_current_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result> WITH KEY exception_code = iv_exceptioncode.
          IF <fs_mtd_code_result> IS ASSIGNED.
            ls_bpm_pid = /adesso/cl_bpm_cust_spec_eide=>determine_bpm_id( iv_proc_id = as_proc_hdr-proc_id
                                                                          iv_proc_version = as_proc_hdr-proc_version
                                                                          iv_proc_step_no = as_current_proc_step_data-proc_step_no
                                                                          iv_chkid = /idxgc/if_constants=>gc_check_id_mtd
                                                                          iv_excn_name = <fs_mtd_code_result>-check_value ).
          ELSE.
            ls_bpm_pid = /adesso/cl_bpm_cust_spec_eide=>determine_bpm_id( iv_proc_id = as_proc_hdr-proc_id
                                                                          iv_proc_version = as_proc_hdr-proc_version
                                                                          iv_proc_step_no = as_current_proc_step_data-proc_step_no
                                                                          iv_chkid = space
                                                                          iv_excn_name = space ).
          ENDIF.
        ENDIF.
      CATCH /adesso/cx_bpm_utility.
        CLEAR av_ad_bpm_id.
        /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDTRY.

    av_ad_bpm_id = ls_bpm_pid-ad_bpm_id.

  ENDMETHOD.


  METHOD determine_cont_elements_dp.
    DATA: lv_bparea TYPE emma_bparea.

    lv_bparea = /adesso/cl_bpm_utility=>det_bparea( iv_ccat = av_ccat ).

    SELECT * FROM /adesso/bpm_obj INTO TABLE at_cont_elements_dp WHERE ad_bpm_id = av_ad_bpm_id AND
                                                                       bparea = lv_bparea.

  ENDMETHOD.


  METHOD execute.
    DATA: lt_return TYPE wlf_tt_edimessage.

    FIELD-SYMBOLS: <fs_return> LIKE LINE OF lt_return.

    TRY.
        me->determine_ad_bpm_id( iv_exceptioncode = av_exceptioncode ).

        me->determine_cont_elements_dp( ).

        lt_return = me->build_bpm_container( ).

        IF lines( lt_return ) > 0.
          LOOP AT lt_return ASSIGNING <fs_return>.
            TRY.
                ar_ctx->add_message_log( is_message = <fs_return> ).
              CATCH /idxgc/cx_process_error.
            ENDTRY.
          ENDLOOP.
        ENDIF.
      CATCH /adesso/cx_bpm_general /adesso/cx_bpm_utility.
        /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.


  METHOD fill_cont.
    DATA: ls_object     LIKE LINE OF at_bpm_cont,
          lv_id         TYPE swotobjid,
          lr_bor_object TYPE swc0_object.

    FIELD-SYMBOLS: <fs_cont_element_dp> LIKE LINE OF at_cont_elements_dp.

    READ TABLE at_cont_elements_dp ASSIGNING <fs_cont_element_dp> WITH KEY object = iv_element.

    IF <fs_cont_element_dp>-refobjtype IS NOT INITIAL.
      swc_create_object lr_bor_object <fs_cont_element_dp>-refobjtype iv_data.

      swc_get_object_key lr_bor_object lv_id.

      ls_object-celemname = iv_element.
      ls_object-refobjtype = <fs_cont_element_dp>-refobjtype.
      ls_object-id = lv_id.

    ELSE.

      ls_object-celemname = iv_element.
      ls_object-refstruct = <fs_cont_element_dp>-refstruct.
      ls_object-reffield =  <fs_cont_element_dp>-reffield.
      ls_object-id = iv_data.

    ENDIF.

    APPEND ls_object TO at_bpm_cont.

  ENDMETHOD.


  method GET_CLASS_ATTRIBUTE.
    FIELD-SYMBOLS: <ft_any> TYPE ANY TABLE.

    ASSIGN me->(iv_attribute) TO <ft_any>.

    IF <ft_any> IS ASSIGNED.
      et_attribute = <ft_any>.
    ELSE.
      /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDIF.
  endmethod.
ENDCLASS.
