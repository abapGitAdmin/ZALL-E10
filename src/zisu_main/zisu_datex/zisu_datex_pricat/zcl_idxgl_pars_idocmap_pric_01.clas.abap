class ZCL_IDXGL_PARS_IDOCMAP_PRIC_01 definition
  public
  inheriting from /IDXGL/CL_PARS_IDOCMAP_PRIC_01
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_IDOC_DATA type EDEX_IDOCDATA optional
      !IV_KEY_DATE type /IDXGC/DE_PARSER_DATEFROM optional
    raising
      /IDXGC/CX_IDE_ERROR .

  methods /IDXGC/IF_PARSING~BUILD_IDOC_OUTBOUND
    redefinition .
  methods /IDXGC/IF_PARSING~PROCESS_IDOC_INBOUND
    redefinition .
protected section.

  constants GC_GL_FM_PRICAT_IN type FUNCNAME value 'ZISU_COMEV_PRICAT_IN_IDXGL' ##NO_TEXT.

  methods DET_INBOUND_BASICPROC
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_IDXGL_PARS_IDOCMAP_PRIC_01 IMPLEMENTATION.


  METHOD /idxgc/if_parsing~build_idoc_outbound.
    DATA: ls_step_data  TYPE /idxgc/s_proc_step_data.

    CALL METHOD super->/idxgc/if_parsing~build_idoc_outbound
      EXPORTING
        ir_message_data     = ir_message_data
        is_process_step_key = is_process_step_key
        iv_dexbasicproc     = iv_dexbasicproc
      IMPORTING
        es_idoc_data        = es_idoc_data
        et_error            = et_error.

    READ TABLE me->ms_process_data-steps INDEX 1 INTO ls_step_data.

    CALL METHOD zcl_datex_utility=>modify_externalid_outbound
      EXPORTING
        is_step_data = ls_step_data
      CHANGING
        cs_idoc_data = es_idoc_data.
  ENDMETHOD.


  METHOD /idxgc/if_parsing~process_idoc_inbound.
    CALL METHOD zcl_datex_utility=>modify_externalid_inbound
      CHANGING
        cs_idoc_data = me->ms_idoc_data.
**TRY.
    CALL METHOD super->/idxgc/if_parsing~process_idoc_inbound
      EXPORTING
        iv_input_method          = iv_input_method
        iv_mass_processing       = iv_mass_processing
      IMPORTING
        ev_workflow_result       = ev_workflow_result
        ev_application_variable  = ev_application_variable
        ev_in_update_task        = ev_in_update_task
        ev_call_transaction_done = ev_call_transaction_done
        et_idoc_status           = et_idoc_status
        et_idoc_contrl           = et_idoc_contrl
        et_return_variables      = et_return_variables
        et_serialization_info    = et_serialization_info.
** CATCH /idxgc/cx_ide_error .
**ENDTRY.
  ENDMETHOD.


  METHOD constructor.

    CALL METHOD super->constructor
      EXPORTING
        is_idoc_data = is_idoc_data
        iv_key_date  = iv_key_date.

    me->mv_de_old_fm = gc_gl_fm_pricat_in.

  ENDMETHOD.


  METHOD det_inbound_basicproc.
    DATA: ls_segm_rff     TYPE /idxgc/e1_rff_07,
          ls_segm_rff_tmp TYPE /idxgc/e1_rff_07.

    CALL METHOD super->det_inbound_basicproc.

* Get IDOC segment value of BGM & IMD segments
    LOOP AT me->ms_split_idoc-data ASSIGNING FIELD-SYMBOL(<fs_edidd>)
      WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_rff_07.

      ls_segm_rff_tmp = <fs_edidd>-sdata.

      if ls_segm_rff_tmp-reference_code_qualifier = /idxgc/if_constants_ide=>gc_rff_qual_z13.
        ls_segm_rff = <fs_edidd>-sdata.
      ENDIF.

    ENDLOOP.

    IF ls_segm_rff-reference_identifier   = '27001'. "Übertragung der regulierten Energiepreise
      CLEAR me->mv_dexbasicproc.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
