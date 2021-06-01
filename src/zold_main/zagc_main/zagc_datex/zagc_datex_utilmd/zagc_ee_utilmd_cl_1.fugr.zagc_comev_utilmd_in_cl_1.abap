*******************************************************************************
FUNCTION zagc_comev_utilmd_in_cl_1 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(INPUT_METHOD) LIKE  BDWFAP_PAR-INPUTMETHD
*"     VALUE(MASS_PROCESSING) LIKE  BDWFAP_PAR-MASS_PROC
*"  EXPORTING
*"     VALUE(WORKFLOW_RESULT) LIKE  BDWFAP_PAR-RESULT
*"     REFERENCE(APPLICATION_VARIABLE) LIKE  BDWFAP_PAR-APPL_VAR
*"     VALUE(IN_UPDATE_TASK) LIKE  BDWFAP_PAR-UPDATETASK
*"     VALUE(CALL_TRANSACTION_DONE) LIKE  BDWFAP_PAR-CALLTRANS
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      WRONG_FUNCTION_CALLED
*"----------------------------------------------------------------------
*This function module was copied from /IDEXGE/ISU_COMEV_UTILMD_IN_1

*Changes are backuped with old code commented
*---------------------------------------------------------------------
* THIMEL.R 20150210 Einführung CL
*   Kopiert aus /IDEXGE/COMEV_UTILMD_IN_CL_1 und angepasst für
*     Bestandslistenversand. Es wurden nur nötige Daten übernommen.
**********************************************************************

  INCLUDE eedmmsg01.

  TYPE-POOLS: abap.

  DATA: ls_e1_nad_03           TYPE        /idxgc/e1_nad_03,
        lv_receiver_identifier TYPE        dunsnr,
        lv_receiver_cla        TYPE        /idxgc/de_codelist_agency,
        lv_sender_identifier   TYPE        dunsnr,
        lv_sender_cla          TYPE        /idxgc/de_codelist_agency,

        lr_aperak_handler      TYPE REF TO zcl_aperak_handler_001,
        lt_idoc_data           TYPE        edidd_tt,
        lv_err_code            TYPE        /idxgc/de_err_code.

  FIELD-SYMBOLS: <fs_idoc_data> TYPE edidd.


  READ TABLE idoc_contrl INDEX 1.                          "#EC .., bzw

*$*$ initialization
  PERFORM init_ev.

  PERFORM idoc_open_ev TABLES idoc_contrl
                           idoc_data
                    USING  idoc_contrl-idoctp                  "idoc_type
                           '/IDXGC/UTILMD'                     "message type
                           'ZAGC_COMEV_UTILMD_IN_CL_1'.        "func module

  DO." exit mechanism for error handling!
    PERFORM get_segments_bgm_2_ev.
    exit_err_ev.

    READ TABLE gt_sgm_bgm_2_ev INTO g_sgm_bgm_2_ev INDEX 1.
    PERFORM get_bgm_2_ev.

    LOOP AT idoc_data ASSIGNING <fs_idoc_data>
      WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_nad_03.
      CLEAR ls_e1_nad_03.
      ls_e1_nad_03 = <fs_idoc_data>-sdata.
      IF ls_e1_nad_03-party_function_code_qualifier = /idxgc/if_constants_ide=>gc_nad_01_qual_mr.
        lv_receiver_identifier = ls_e1_nad_03-party_identifier.
        lv_receiver_cla = ls_e1_nad_03-code_list_resp_agency_code_1.
      ELSEIF ls_e1_nad_03-party_function_code_qualifier = /idxgc/if_constants_ide=>gc_nad_01_qual_ms.
        lv_sender_identifier = ls_e1_nad_03-party_identifier.
        lv_sender_cla = ls_e1_nad_03-code_list_resp_agency_code_1.
      ENDIF.
    ENDLOOP.

***** E06: Zuordnungslisten ***********************************************************************
    IF g_bgm_2_ev-document_name_code = /idxgc/if_constants_ide=>gc_msg_category_e06.

      "APERAK Handler für die APERAK Prüfungen instanzieren
      CREATE OBJECT lr_aperak_handler
        EXPORTING
          iv_sender_party_identifier   = lv_receiver_identifier
          iv_sender_codelist_agency    = lv_receiver_cla
          iv_receiver_party_identifier = lv_sender_identifier
          iv_receiver_codelist_agency  = lv_sender_cla
        EXCEPTIONS
          no_service_provider          = 1
          error_occurred               = 2
          OTHERS                       = 3.
      IF sy-subrc = 1.
        CALL METHOD gr_proc_ev->add_status_appl
          EXPORTING
            im_msgty = 'E'
            im_msgno = 100
            im_msgid = 'ZAGC_DATEX_GENERAL'.
        IF 1 = 2. MESSAGE e100(zagc_datex_general). ENDIF.
        EXIT.
      ELSEIF sy-subrc <> 0.
        CALL METHOD gr_proc_ev->add_status_appl
          EXPORTING
            im_msgty = 'E'
            im_msgno = 100
            im_msgid = 'ZAGC_DATEX_GENERAL'.
        IF 1 = 2. MESSAGE e100(zagc_datex_general). ENDIF.
        EXIT.
      ENDIF.

      APPEND LINES OF idoc_data TO lt_idoc_data.
      lv_err_code = lr_aperak_handler->execute_checks_utilmd_idoc_002( it_idoc_data = lt_idoc_data ).

      CALL FUNCTION 'ZISU_EVUIT_EXCH_BESTND_IMPORT'
        EXPORTING
          i_docnum = idoc_contrl-docnum.

      "Aperak verschicken, falls Fehler eingetragen sind.
      IF lr_aperak_handler->get_num_errors( ) > 0.
        CALL METHOD lr_aperak_handler->send_001
          EXCEPTIONS
            error_occurred   = 1
            no_dexproc_found = 2
            OTHERS           = 3.
        IF sy-subrc <> 0.
          CALL METHOD gr_proc_ev->add_status_appl
            EXPORTING
              im_msgty = 'E'
              im_msgno = 101
              im_msgid = 'ZAGC_DATEX_GENERAL'.
          IF 1 = 2. MESSAGE e101(zagc_datex_general). ENDIF.
          EXIT.
        ELSE.
* Eigentlich bedeutet IDoc "grün", dass Verarbeitung in Ordnung
*        CALL METHOD gr_proc_ev->add_status_appl
*          EXPORTING
*            im_msgty = 'S'
*            im_msgno = 009
*            im_msgid = 'ZISU_IDE'.
*        IF 1 = 2. MESSAGE s009(zisu_ide). ENDIF.
        ENDIF.
      ENDIF.

***** Keine weiteren Prozesse unterstützt *********************************************************
    ELSE.
      CALL METHOD gr_proc_ev->add_status_appl
        EXPORTING
          im_msgty = 'E'
          im_msgno = 001
          im_msgid = 'ZAGC_DATEX_GENERAL'.
      IF 1 = 2. MESSAGE e001(zagc_datex_general). ENDIF.
      EXIT.
    ENDIF.

    EXIT.
  ENDDO." exit mechanism for errorhandling!

*$*$ close processing
  PERFORM idoc_close_ev TABLES idoc_status
                               return_variables
                      CHANGING in_update_task
                               call_transaction_done
                               workflow_result
                               application_variable.
ENDFUNCTION.
