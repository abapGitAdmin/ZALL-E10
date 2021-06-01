class ZCL_IM_BPM_BADI_EXCEPTI definition
  public
  inheriting from /ADESSO/CL_IM_BPM_BADI_EXCEPTI
  create public .

public section.
protected section.

  methods DET_CUST_TXT
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_IM_BPM_BADI_EXCEPTI IMPLEMENTATION.


  METHOD det_cust_txt.
    DATA: lr_proc_data        TYPE REF TO /idxgc/cl_process_data,
          ls_process_step_key TYPE        /idxgc/s_proc_step_key,
          ls_proc_data        TYPE        /idxgc/s_proc_data,
          ls_transreason      TYPE        /idxgc/trareas_t.

    FIELD-SYMBOLS: <fs_proc_step_data> LIKE LINE OF ls_proc_data-steps,
                   <fs_diverse>        TYPE         /idxgc/s_diverse_details.

    TRY.
        TRY.
            rv_bpm_txt = super->det_cust_txt( ir_proc_data = ir_proc_data is_exception_data = is_exception_data is_exception_config = is_exception_config ).
          CATCH /adesso/cx_bpm_general.
        ENDTRY.

        lr_proc_data ?= ir_proc_data.
        lr_proc_data->/idxgc/if_process_data_extern~get_process_data( IMPORTING es_process_data = ls_proc_data ).

        IF ( ls_proc_data-proc_id = /adesso/if_bpm_eide_co=>gc_proc_id_8030 OR
             ls_proc_data-proc_id = /adesso/if_bpm_eide_co=>gc_proc_id_8031 OR
             ls_proc_data-proc_id = /adesso/if_bpm_eide_co=>gc_proc_id_8032 OR
             ls_proc_data-proc_id = /adesso/if_bpm_eide_co=>gc_proc_id_8033 OR
             ls_proc_data-proc_id = /adesso/if_bpm_eide_co=>gc_proc_id_8034 ) AND
             is_exception_config-case_category = 'ZMD1'.

          READ TABLE ls_proc_data-steps ASSIGNING <fs_proc_step_data> WITH KEY proc_step_ref = is_exception_data-proc_step_ref.

          IF <fs_proc_step_data> IS ASSIGNED.
            READ TABLE <fs_proc_step_data>-diverse ASSIGNING <fs_diverse> INDEX 1.
            IF <fs_diverse> IS ASSIGNED.
              SELECT SINGLE * FROM /idxgc/trareas_t INTO ls_transreason WHERE msgtransreason = <fs_diverse>-msgtransreason AND
                                                                              spras = sy-langu .
              IF sy-subrc = 0.
                CONCATENATE <fs_diverse>-msgtransreason '-' ls_transreason-text INTO rv_bpm_txt SEPARATED BY space.
              ELSE.
                /adesso/cx_bpm_general=>raise_exception_from_msg( ).
              ENDIF.
            ELSE.
              /adesso/cx_bpm_general=>raise_exception_from_msg( ).
            ENDIF.
          ELSE.
            /adesso/cx_bpm_general=>raise_exception_from_msg( ).
          ENDIF.
        ELSEIF is_exception_config-case_category = 'ZIX9'.
          rv_bpm_txt = 'Eing. Änderung auf abgeschlossenen Prozess. Fall prüfen!'.
        ELSE.
          /adesso/cx_bpm_general=>raise_exception_from_msg( ).
        ENDIF.
      CATCH /idxgc/cx_process_error.
        /adesso/cx_bpm_general=>raise_exception_from_msg( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
