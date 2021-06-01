class ZCL_AGC_PARS_IDOCMAP_MSCS_01 definition
  public
  inheriting from /IDXGC/CL_PARS_IDOCMAP_MSCS_01
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IS_IDOC_DATA type EDEX_IDOCDATA optional
      !IV_KEY_DATE type /IDXGC/DE_PARSER_DATEFROM optional
    raising
      /IDXGC/CX_IDE_ERROR .
protected section.

  methods DET_INBOUND_BASICPROC
    redefinition .
  methods TRIGGER_INBOUND_OLD_PROCESS
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_AGC_PARS_IDOCMAP_MSCS_01 IMPLEMENTATION.


  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        is_idoc_data = is_idoc_data
        iv_key_date  = iv_key_date.

* Set attribute in inbound process
    IF is_idoc_data-control-direct = /idxgc/cl_parser_idoc=>co_idoc_direction_inbound.
      me->mv_de_old_fm = zif_agc_datex_mscons_co=>gc_de_fm_mscons_1.
    ENDIF.
  ENDMETHOD.


METHOD det_inbound_basicproc.
**----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2014
**
** Usage:
** Determine old and new process and deliver
**  a.) If it is a new process, mv_dexbasicproc has value
**  b.) If it is an old process, mv_dexbasicproc is empty
**
*----------------------------------------------------------------------*
** Change History:
**
** Apr. 2014: Created
**----------------------------------------------------------------------*

  DATA: ls_segm_unb        TYPE        /idxgc/e1_unb_01,
        ls_segm_bgm        TYPE        /idxgc/e1_bgm_02,
        ls_segm_cci        TYPE        /idxgc/e1_cci_01,
        ls_segm_cci_16     TYPE        /idxgc/e1_cci_01,
        ls_segm_cci_ach    TYPE        /idxgc/e1_cci_01,
        ls_edex_proc       TYPE	       edexproc_db_data,
        lv_is_swtdoc_exist TYPE        flag,
        lx_previous        TYPE REF TO /idxgc/cx_general.

  FIELD-SYMBOLS: <fs_edidd> TYPE edidd.

*  "Auf der Netzseite werden alle MSCONS Nachrichten über die "alte" Verarbeitung verarbeitet.
*  TRY.
*      IF zcl_agc_masterdata=>is_netz( ) = abap_true.
*        CLEAR me->mv_dexbasicproc.
*        RETURN.
*      ENDIF.
*    CATCH zcx_agc_masterdata.
*  ENDTRY.

* Get IDOC segment value of BGM & IMD segments
  LOOP AT me->ms_split_idoc-data ASSIGNING <fs_edidd>
    WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_unb_01
       OR segnam = /idxgc/if_constants_ide=>gc_segmtp_bgm_02
       OR segnam = /idxgc/if_constants_ide=>gc_segmtp_cci_01.

    IF <fs_edidd>-segnam     = /idxgc/if_constants_ide=>gc_segmtp_unb_01.
      ls_segm_unb = <fs_edidd>-sdata.
    ELSEIF <fs_edidd>-segnam = /idxgc/if_constants_ide=>gc_segmtp_bgm_02.
      ls_segm_bgm = <fs_edidd>-sdata.
    ELSEIF <fs_edidd>-segnam = /idxgc/if_constants_ide=>gc_segmtp_cci_01.
      ls_segm_cci = <fs_edidd>-sdata.
      IF ls_segm_cci-class_type_code = /idxgc/if_constants_ide=>gc_cci_01_classtyp_code_16.
        ls_segm_cci_16 = <fs_edidd>-sdata.
      ENDIF.
      IF ls_segm_cci-class_type_code = /idxgc/if_constants_ide=>gc_cci_01_classtyp_code_ach.
        ls_segm_cci_ach = <fs_edidd>-sdata.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Check whether the message is an new message
  IF ls_segm_unb-application_reference = /idxgc/if_constants_ide=>gc_appl_ref_vl    AND
     ls_segm_bgm-document_name_code    = /idxgc/if_constants_ide=>gc_msg_category_7.

*   Check whether the message is an original message --> Original message processing
    IF ls_segm_bgm-message_function_code = /idxgc/if_constants_ide=>gc_msg_fun_9.

*     Check for meter readings due to device installation
      IF ( ls_segm_cci_ach-characteristic_descr_code = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_com   OR
           ls_segm_cci_ach-characteristic_descr_code = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_cmp   OR
           ls_segm_cci_ach-characteristic_descr_code = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_iom ) AND
           ls_segm_cci_16-characteristic_descr_code = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_smv.

*       Set the basic process to the new basic process
        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_msconspd.

*       Meter readings due to device installation --> Check ongoing device change replication
*       Check whether an ongoing switch doc exists if an active switch document already exist,
*       Then we shall dispatch the message to it.
        TRY.
            CALL METHOD me->check_swt_on_going
              IMPORTING
                ev_swtdoc_exist = lv_is_swtdoc_exist.
          CATCH /idxgc/cx_ide_error INTO lx_previous.
            MESSAGE e007(/idxgc/ide_add) INTO gv_mtext.
            CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lx_previous ).
        ENDTRY.

        IF lv_is_swtdoc_exist EQ abap_true.
*         ongoing switch document process; do not handle message with new basic process
          CLEAR me->mv_dexbasicproc.
        ENDIF.

*     Check for meter readings due to device removal
      ELSEIF ( ls_segm_cci_ach-characteristic_descr_code = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_com   OR
               ls_segm_cci_ach-characteristic_descr_code = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_cmp   OR
               ls_segm_cci_ach-characteristic_descr_code = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_rom ) AND
               ls_segm_cci_16-characteristic_descr_code = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_emv.

*       Meter readings due to device removal -> New basic process
*       Set the basic process to the new basic process
        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_msconspd.
      ENDIF.
    ENDIF.  "End of original message processing

**   Check whether the message is an reversal message -> Reversal message processing
*    IF ls_segm_bgm-message_function_code = /idxgc/if_constants_ide=>gc_msg_fun_1.
*      TRY.
*          CALL METHOD me->get_datex_original_msg
*            IMPORTING
*              es_edex_proc = ls_edex_proc.
*        CATCH /idxgc/cx_ide_error INTO lx_previous.
*          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
*            EXPORTING
*              ir_previous = lx_previous.
*      ENDTRY.
*
**     Check if new process or reversal process
*      IF ls_edex_proc-head-dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_msconspd.
**       Set the basic process to the new basic process
**       which is identical to the basic process of the reversal process
*        me->mv_dexbasicproc = /idxgc/if_constants_ide=>gc_basicproc_i_msconspd.
*      ENDIF.
*    ENDIF.  "End of reversal message processing

  ENDIF.

ENDMETHOD.


  METHOD trigger_inbound_old_process.
***************************************************************************************************
* THIMEL.R, 20151001, Ausnahme soll IDoc-Status auf Fehler setzen und kein ErrorIDoc erzeugen.
***************************************************************************************************
    FIELD-SYMBOLS: <fs_idoc_status> TYPE bdidocstat.
    TRY.
        CALL METHOD super->trigger_inbound_old_process
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
            et_serialization_info    = et_serialization_info
            et_task_data             = et_task_data.
      CATCH /idxgc/cx_ide_error.
        READ TABLE et_idoc_status TRANSPORTING NO FIELDS WITH KEY msgty = /idxgc/if_constants_ide=>gc_msgty_e.
        IF sy-subrc <> 0. "Nur wenn Fehler nicht schon protokolliert wurde.
          APPEND INITIAL LINE TO et_idoc_status ASSIGNING <fs_idoc_status>.
          <fs_idoc_status>-status = /idxgc/if_constants_ide=>gc_idoc_status_51.
          <fs_idoc_status>-docnum = me->ms_idoc_data-control-docnum.
          <fs_idoc_status>-msgty  = sy-msgty.
          <fs_idoc_status>-msgid  = sy-msgid.
          <fs_idoc_status>-msgno  = sy-msgno.
          <fs_idoc_status>-msgv1  = sy-msgv1.
          <fs_idoc_status>-msgv2  = sy-msgv2.
          <fs_idoc_status>-msgv3  = sy-msgv3.
          <fs_idoc_status>-msgv4  = sy-msgv4.
          <fs_idoc_status>-repid  = sy-repid.
          <fs_idoc_status>-routid = mv_de_old_fm.
          <fs_idoc_status>-uname  = sy-uname.
        ENDIF.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
