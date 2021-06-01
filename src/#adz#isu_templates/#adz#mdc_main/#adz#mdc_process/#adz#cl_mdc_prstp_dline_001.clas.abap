class /ADZ/CL_MDC_PRSTP_DLINE_001 definition
  public
  inheriting from /IDXGC/CL_PROCESS_STEP_DLINE
  create public .

public section.
protected section.

  methods CREATE_DEADLINE_PERIOD
    redefinition .
private section.
ENDCLASS.



CLASS /ADZ/CL_MDC_PRSTP_DLINE_001 IMPLEMENTATION.


  method CREATE_DEADLINE_PERIOD.

 DATA: ls_period_details     TYPE /idxgc/s_period_details,
*          ls_cust_in            TYPE /adz/s_mdc_in,
          lv_edifact_structur   TYPE /idxgc/de_edifact_str,
          lv_new_time           TYPE /idxgc/de_timecount,
          ls_pertype_config     TYPE /idxgc/s_pertype_config,
          lv_secs_offset        TYPE i,
          lv_period_end_tstmp   TYPE /idxgc/de_timestamp,
          ls_process_data_src   TYPE /idxgc/s_proc_data,
          lt_process_data_assoc TYPE /idxgc/t_proc_data,

          lx_previous           TYPE REF TO /idxgc/cx_general,
          lx_invalid            TYPE REF TO cx_dynamic_check.

    FIELD-SYMBOLS: <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details,
                   <ls_timestamp>       TYPE /idxgc/de_timestamp,
                   <lfs_proc_step_data> TYPE /idxgc/s_proc_step_data.

    TRY.

        ls_period_details = is_period_details.

        TRY.
            CALL METHOD me->gr_process->get_process_step_src_data
              EXPORTING
                is_process_step_key   = me->gs_process_step_key
              IMPORTING
                es_process_data       = ls_process_data_src
                et_process_data_assoc = lt_process_data_assoc.
          CATCH /idxgc/cx_process_error INTO lx_previous.
            MESSAGE e189(/idxgc/process) INTO gv_mtext
                                         WITH me->gs_process_step_key-proc_ref
                                              me->gs_process_step_key-proc_step_no.
        ENDTRY.

        LOOP AT ls_process_data_src-steps ASSIGNING <lfs_proc_step_data>
          WHERE proc_step_no = me->gs_process_step_config-proc_step_src.
          EXIT.
        ENDLOOP.

        IF <lfs_proc_step_data> IS NOT ASSIGNED.
          READ TABLE ls_process_data_src-steps ASSIGNING <lfs_proc_step_data> INDEX 1.
        ENDIF.

        IF <lfs_proc_step_data> IS ASSIGNED.
          LOOP AT <lfs_proc_step_data>-mtd_code_result ASSIGNING <fs_mtd_code_result>.
            CHECK <fs_mtd_code_result>-src_field_value <> <fs_mtd_code_result>-cmp_field_value.
            lv_edifact_structur = <fs_mtd_code_result>-addinfo.
*            TRY.
*                ls_cust_in = /adz/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur
*                                                                                         iv_keydate = cs_process_step_data-proc_date
*                                                                                         iv_assoc_servprov = cs_process_step_data-assoc_servprov ).

*                IF ls_cust_in-auto_change_delay IS NOT INITIAL.
*                  "Die längste Wartezeit suchen
*                  IF lv_new_time is INITIAL OR lv_new_time < ls_cust_in-auto_change_delay.
*                    lv_new_time = ls_cust_in-auto_change_delay.
*                  endif.
*                ENDIF.
*              CATCH /idxgc/cx_general.
*                "Kein Customizing bedeutet auch, dass nicht gewartet werden soll / muss
*            ENDTRY.
          ENDLOOP.
        ENDIF.

* Get period type configuration
        TRY.
            CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_period_type_config
              EXPORTING
                iv_period_type        = ls_period_details-period_type
                iv_swttype            = ls_period_details-proc_type
              RECEIVING
                rs_period_type_config = ls_pertype_config.

          CATCH /idxgc/cx_config_error INTO lx_previous.
            MESSAGE e047(/idxgc/utility) INTO gv_mtext.
            CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
              EXPORTING
                ir_previous = lx_previous.
        ENDTRY.

        ls_pertype_config-timecount = lv_new_time.

*--------------------------------------------------------------------*
* Calculate based on period type category
        CASE ls_pertype_config-period_type_cat.

          WHEN /idxgc/if_constants=>gc_typecat_rel_key.
            ASSIGN ls_period_details-key_timestamp TO <ls_timestamp>.

*--------------------------------------------------------------------*
          WHEN /idxgc/if_constants=>gc_typecat_rel_ref.
            ASSIGN ls_period_details-reference_timestamp TO <ls_timestamp>.

*--------------------------------------------------------------------*
*   Calculation relative to other period type
          WHEN /idxgc/if_constants=>gc_typecat_rel_par_d.    "Relevant to Period Type in Change of Supplier Process
            IF ls_pertype_config-par_period_type IS INITIAL.
              MESSAGE e076(/idxgc/utility) INTO gv_mtext.
              CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
            ENDIF.

            ls_period_details-swttime_type = ls_pertype_config-par_period_type.
            ls_period_details-proc_type    = ls_pertype_config-par_switch_type.

            TRY.
                CALL METHOD /idxgc/cl_period_framework=>/idxgc/if_period_framework~calculate_period_type_d
                  EXPORTING
                    is_period_details       = ls_period_details
                  RECEIVING
                    rv_period_end_timestamp = lv_period_end_tstmp.

              CATCH /idxgc/cx_utility_error INTO lx_previous.
                MESSAGE e055(/idxgc/utility) INTO gv_mtext.
                CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
                  EXPORTING
                    ir_previous = lx_previous.
            ENDTRY.

            IF lv_period_end_tstmp IS NOT INITIAL.
*        now we are at the deepest level with period type w/o high-level period type
              ASSIGN lv_period_end_tstmp TO <ls_timestamp>.
            ENDIF.

*--------------------------------------------------------------------*
          WHEN /idxgc/if_constants=>gc_typecat_rel_par_t.    "Relvant to Period type for Hour/Minute/Second
            IF ls_pertype_config-par_period_type IS INITIAL.
              MESSAGE e076(/idxgc/utility) INTO gv_mtext.
              CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
            ENDIF.

            ls_period_details-period_type = ls_pertype_config-par_period_type.
            TRY .
                CALL METHOD /idxgc/cl_period_framework=>/idxgc/if_period_framework~calculate_period_type_t
                  EXPORTING
                    is_period_details       = ls_period_details
                  RECEIVING
                    rv_period_end_timestamp = lv_period_end_tstmp.

                IF lv_period_end_tstmp IS NOT INITIAL.
*            now we are at the deepest level with period type w/o high-level period type
                  ASSIGN lv_period_end_tstmp TO <ls_timestamp>.
                ENDIF.

              CATCH /idxgc/cx_utility_error INTO lx_previous.
                MESSAGE e055(/idxgc/utility) INTO gv_mtext.
                CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
                  EXPORTING
                    ir_previous = lx_previous.
            ENDTRY.

          WHEN OTHERS.
*     invalid period type
            MESSAGE e126(/idxgc/utility) INTO gv_mtext WITH ls_pertype_config-period_type_cat.
            CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
        ENDCASE.

*--------------------------------------------------------------------*
        CASE ls_pertype_config-timeunit.
          WHEN /idxgc/if_constants=>gc_timeunit_hour.             " Hour
            lv_secs_offset = ls_pertype_config-timecount * 3600.

          WHEN /idxgc/if_constants=>gc_timeunit_minute.           " Minute
            lv_secs_offset = ls_pertype_config-timecount * 60.

          WHEN /idxgc/if_constants=>gc_timeunit_second.           " Second
            lv_secs_offset = ls_pertype_config-timecount.

          WHEN OTHERS.
*     invalid time unit
            MESSAGE e094(/idxgc/utility) INTO gv_mtext WITH ls_pertype_config-timeunit.
            CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg.
        ENDCASE.

*--------------------------------------------------------------------*
        IF <ls_timestamp> IS ASSIGNED.
          TRY.
              CALL METHOD cl_abap_tstmp=>add
                EXPORTING
                  tstmp   = <ls_timestamp>
                  secs    = lv_secs_offset
                RECEIVING
                  r_tstmp = cs_process_step_data-dline_timestamp.

            CATCH cx_parameter_invalid_range
                  cx_parameter_invalid_type INTO lx_invalid.

              MESSAGE e055(/idxgc/utility) INTO gv_mtext.
              CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
                EXPORTING
                  ir_previous = lx_invalid.
          ENDTRY.
        ENDIF.
      CATCH /idxgc/cx_process_error .
    ENDTRY.

  endmethod.
ENDCLASS.
