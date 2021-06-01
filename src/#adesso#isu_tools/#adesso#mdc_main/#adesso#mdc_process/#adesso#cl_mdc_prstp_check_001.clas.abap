class /ADESSO/CL_MDC_PRSTP_CHECK_001 definition
  public
  inheriting from /IDXGC/CL_PROCESS_STEP_NEXTSTP
  create public .

public section.
protected section.

  methods ENHANCE_STEP_DATA
    redefinition .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_PRSTP_CHECK_001 IMPLEMENTATION.


  METHOD enhance_step_data.
***************************************************************************************************
* THIMEL-R, 20150908, Einführung SDÄ auf Common Layer
*   Übernahme von MTD_CODE_RESULT aus dem Quellschritt und alle restlichen Datan aus dem
*     zusätzlichen Quellschritt
* THIMEL-R, 20170622, SUPER-Aufruf ausgetauscht, da Funktion geändert
***************************************************************************************************
    DATA: ls_process_data_src TYPE /idxgc/s_proc_data,
          ls_proc_step_key    TYPE /idxgc/s_proc_step_key.

    FIELD-SYMBOLS: <fs_proc_step_data> TYPE /idxgc/s_proc_step_data.

    READ TABLE is_process_data_src-steps ASSIGNING <fs_proc_step_data> WITH KEY proc_step_no = me->gs_process_step_config-step_no_src_add.
    IF <fs_proc_step_data> IS ASSIGNED.
      ls_proc_step_key-proc_id       = me->gs_process_step_key-proc_id.
      ls_proc_step_key-proc_ref      = me->gs_process_step_key-proc_ref.
      ls_proc_step_key-proc_step_no  = <fs_proc_step_data>-proc_step_no.
      ls_proc_step_key-proc_step_ref = <fs_proc_step_data>-proc_step_ref.
      copy_step_data( EXPORTING is_process_step_key_src = ls_proc_step_key
                                is_process_data_src     = is_process_data_src
                      CHANGING  cs_process_step_data    = cs_process_step_data ).
    ENDIF.

    READ TABLE is_process_data_src-steps ASSIGNING <fs_proc_step_data> WITH KEY proc_step_no = me->gs_process_step_config-proc_step_src.
    IF <fs_proc_step_data> IS ASSIGNED.
      cs_process_step_data-mtd_code_result = <fs_proc_step_data>-mtd_code_result.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
