class ZCL_AGC_IM_BADI_BMID definition
  public
  inheriting from /IDXGC/CL_DEF_BADI_BMID
  final
  create public .

public section.

  methods /IDXGC/IF_BADI_BMID~DETERMINE_BMID
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_IM_BADI_BMID IMPLEMENTATION.


  METHOD /idxgc/if_badi_bmid~determine_bmid.
***************************************************************************************************
* 20150825 THIMEL.R FA 01.10.2015
*   Für den Prozess Stilllegung (Absender Netzbetreiber) wird im Standard keine BMID ermittelt.
*   Für die eigenen Sperr-/Entsperrprozesse muss eine BMID Ermittlung hinterlegt werden.
***************************************************************************************************

    CALL METHOD super->/idxgc/if_badi_bmid~determine_bmid
      EXPORTING
        is_msg_data = is_msg_data
      IMPORTING
        ev_bmid     = ev_bmid.

*ToDo: O.g. Prozess testen und ggf. hier noch BMID ermitteln.

*  lr_type_descr = cl_abap_typedescr=>describe_by_data( is_msg_data ).
*  lv_type = lr_type_descr->get_relative_name( ).
*
*  IF lv_type <> /idxgc/if_constants_add=>gc_type_proc_data.
*    MESSAGE e354(/idxgc/utility_add) WITH /idxgc/if_constants_add=>gc_type_proc_data INTO lv_msg.
*    /idxgc/cx_utility_error=>raise_util_exception_from_msg( ).
*  ELSE.
*    ls_proc_data = is_msg_data.
*  ENDIF.
*
*  READ TABLE cs_proc_data-steps ASSIGNING <fs_process_step_data> INDEX 1.
*
*    IF <fs_process_step_data>-bmid IS INITIAL AND <fs_process_step_data>-msgrespstatus IS INITIAL. "Keine BMID und Anfrage
*      READ TABLE <fs_process_step_data>-diverse INTO ls_diverse INDEX 1.
*      TRY.
*          CALL METHOD /idxgc/cl_utility_service_isu=>get_service_provider_from_id
*            EXPORTING
*              iv_serviceid  = <fs_process_step_data>-assoc_servprov
*            IMPORTING
*              es_agent_attr = ls_agent_attr_sender.
*          lv_intcode_sender = ls_agent_attr_sender-agent_cat.
*
*          CALL METHOD /idxgc/cl_utility_service_isu=>get_service_provider_from_id
*            EXPORTING
*              iv_serviceid  = <fs_process_step_data>-own_servprov
*            IMPORTING
*              es_agent_attr = ls_agent_attr_receiver.
*          lv_intcode_receiver = ls_agent_attr_receiver-agent_cat.
*        CATCH /idxgc/cx_utility_error INTO lx_previous.
*          CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~create_error_log_message( ).
*          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
*            EXPORTING
*              ir_previous = lx_previous.
*      ENDTRY.
*      CASE ls_diverse-msgtransreason.
*        WHEN zif_agc_datex_utilmd_co=>gc_trans_reason_code_z27.
*          IF lv_intcode_sender = /idxgc/if_constants=>gc_service_code_supplier AND
*             lv_intcode_receiver = /idxgc/if_constants=>gc_service_code_dso.
*            <fs_process_step_data>-bmid = /idxgc/if_constants_ide=>gc_bmid_ee101.
*          ENDIF.
*        WHEN zif_agc_datex_utilmd_co=>gc_trans_reason_code_z28.
*          IF lv_intcode_sender = /idxgc/if_constants=>gc_service_code_supplier AND
*             lv_intcode_receiver = /idxgc/if_constants=>gc_service_code_dso.
*            <fs_process_step_data>-bmid = /idxgc/if_constants_ide=>gc_bmid_es101.
*          ENDIF.
*        WHEN /idxgc/if_constants_ide=>gc_trans_reason_code_z33.
*          IF lv_intcode_sender = /idxgc/if_constants=>gc_service_code_dso AND
*             lv_intcode_receiver = /idxgc/if_constants=>gc_service_code_supplier.
*            <fs_process_step_data>-bmid = /idxgc/if_constants_ide=>gc_bmid_ee101.
*          ENDIF.
*      ENDCASE.
  ENDMETHOD.
ENDCLASS.
