class /ADESSO/CL_MDC_PRSTP_CHECK_002 definition
  public
  inheriting from /IDXGC/CL_PROCESS_STEP_NEXTSTP
  create public .

public section.
protected section.

  methods ENHANCE_STEP_DATA
    redefinition .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_PRSTP_CHECK_002 IMPLEMENTATION.


  METHOD enhance_step_data.
***************************************************************************************************
* THIMEL.R, 20150908, Einführung SDÄ auf Common Layer
*   Richtigen Quellschritt auswählen und MTD_CODE_RESULT übernehmen
***************************************************************************************************
    DATA: ls_process_data_src TYPE /idxgc/s_proc_data.

    FIELD-SYMBOLS: <fs_proc_step_data> TYPE /idxgc/s_proc_step_data.

    ls_process_data_src = is_process_data_src.
    IF lines( ls_process_data_src-steps ) > 1.
      DELETE ls_process_data_src-steps WHERE proc_step_no = me->gs_process_step_config-proc_step_src.
    ENDIF.

    CALL METHOD super->enhance_step_data
      EXPORTING
        iv_copy_complete_source = abap_true
        is_process_data_src     = ls_process_data_src
      CHANGING
        cs_process_step_data    = cs_process_step_data.

    READ TABLE is_process_data_src-steps ASSIGNING <fs_proc_step_data> WITH KEY proc_step_no = me->gs_process_step_config-proc_step_src.
    IF <fs_proc_step_data> IS ASSIGNED.
      cs_process_step_data-mtd_code_result = <fs_proc_step_data>-mtd_code_result.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
