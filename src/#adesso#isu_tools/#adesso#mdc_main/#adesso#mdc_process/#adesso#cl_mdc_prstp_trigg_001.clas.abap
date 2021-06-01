class /ADESSO/CL_MDC_PRSTP_TRIGG_001 definition
  public
  inheriting from /IDXGC/CL_PROCESS_STEP_TRIGGER
  create public .

public section.
protected section.

  methods DETERMINE_CHILD_PROCESS_DATA
    redefinition .
  methods ENHANCE_STEP_DATA
    redefinition .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_PRSTP_TRIGG_001 IMPLEMENTATION.


  METHOD determine_child_process_data.
***************************************************************************************************
* THIMEL.R, 20150919, Relevante Daten aus Quellschritt übernehmen
***************************************************************************************************
    FIELD-SYMBOLS: <fs_proc_step_data>     TYPE /idxgc/s_proc_step_data,
                   <fs_proc_step_data_src> TYPE /idxgc/s_proc_step_data.

    CALL METHOD super->determine_child_process_data
      EXPORTING
        is_process_step_data   = is_process_step_data
        is_process_data_source = is_process_data_source
      IMPORTING
        es_process_data_assoc  = es_process_data_assoc.

    READ TABLE es_process_data_assoc-steps ASSIGNING <fs_proc_step_data> INDEX 1.
    READ TABLE is_process_data_source-steps ASSIGNING <fs_proc_step_data_src> INDEX 1.

    <fs_proc_step_data>-own_servprov    = is_process_step_data-own_servprov.
    <fs_proc_step_data>-assoc_servprov  = is_process_step_data-assoc_servprov.
    <fs_proc_step_data>-bmid            = is_process_step_data-bmid.

    <fs_proc_step_data>-diverse         = <fs_proc_step_data_src>-diverse.
    <fs_proc_step_data>-mtd_code_result = <fs_proc_step_data_src>-mtd_code_result.
  ENDMETHOD.


  METHOD enhance_step_data.
***************************************************************************************************
* THIMEL-R, 20150919, Daten aus Quellschritt übernehmen. Sender, Empfänger und BMID setzen
***************************************************************************************************
    FIELD-SYMBOLS: <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
                   <fs_serviceprovider> TYPE /idxgc/s_servprov_details,
                   <fs_diverse>         TYPE /idxgc/s_diverse_details.

    CALL METHOD super->enhance_step_data
      EXPORTING
        iv_copy_complete_source   = abap_true
        is_process_data_src       = is_process_data_src
        it_process_data_assoc_src = it_process_data_assoc_src
      CHANGING
        cs_process_step_data      = cs_process_step_data.

    READ TABLE cs_process_step_data-serviceprovider ASSIGNING <fs_serviceprovider> INDEX 1.
    cs_process_step_data-assoc_servprov = <fs_serviceprovider>-service_id.
    cs_process_step_data-bmid           = <fs_serviceprovider>-contract_ref.

    READ TABLE cs_process_step_data-diverse ASSIGNING <fs_diverse> INDEX 1.
    <fs_diverse>-contr_start_date       = <fs_serviceprovider>-date_from.

    DELETE cs_process_step_data-serviceprovider INDEX 1.

    READ TABLE is_process_data_src-steps ASSIGNING <fs_proc_step_data> WITH KEY proc_step_no = me->gs_process_step_config-proc_step_src.
    IF <fs_proc_step_data> IS ASSIGNED.
      cs_process_step_data-mtd_code_result = <fs_proc_step_data>-mtd_code_result.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
