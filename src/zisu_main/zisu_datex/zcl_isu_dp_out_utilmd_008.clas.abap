class ZCL_ISU_DP_OUT_UTILMD_008 definition
  public
  inheriting from /IDEXGE/CL_DP_OUT_UTILMD_008
  final
  create public .

public section.

  interfaces /ADESSO/IF_MDC_DP_OUT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ISU_DP_OUT_UTILMD_008 IMPLEMENTATION.


  method /ADESSO/IF_MDC_DP_OUT~CALL_METHOD.
***************************************************************************************************
* THIMEL.R 20150901 Einführung SDÄ auf Common Layer
*   Variablen setzen wie in /IDXGC/IF_DP_OUT~PROCESS_CONFIGURATION_STEPS
***************************************************************************************************
    siv_data_from_source = is_bmid_config-data_from_source.
    siv_data_from_add_source = is_bmid_config-data_add_source.
    IF is_bmid_config-data_from_source IS NOT INITIAL.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_source.
    ELSEIF is_bmid_config-data_add_source IS NOT INITIAL.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_data_from_add_source.
    ELSE.
      siv_data_processing_mode = /idxgc/if_constants_add=>gc_default_processing.
    ENDIF.

    siv_mandatory_data = is_bmid_config-mandatory.

    gs_process_step_data = cs_process_step_data.
    CALL METHOD me->(is_bmid_config-method).
    cs_process_step_data = gs_process_step_data.
  endmethod.


  METHOD /ADESSO/IF_MDC_DP_OUT~SET_PROCESS_STEP_DATA.
    gs_process_step_data = is_process_step_data.
    me->instantiate( ).
  ENDMETHOD.
ENDCLASS.
