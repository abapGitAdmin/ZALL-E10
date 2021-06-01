class ZCL_AGC_MESSAGE_UTILMD_IN_01 definition
  public
  inheriting from /IDXGC/CL_MESSAGE_UTILMD_IN_01
  final
  create public .

public section.
protected section.

  methods DETERMINE_BMID
    redefinition .
  methods PREPARE_PROCESS_DATA
    redefinition .
  methods HANDLE_REFERENCE_RESP_REV
    redefinition .
private section.

  methods Z_CHANGE_NAMES
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
  methods Z_DELETE_UNNEEDED_DATA
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
  methods Z_INBOUND_DETERMINE_POD
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
  methods Z_INBOUND_DETERMINE_SERVPROV
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
  methods Z_INBOUND_FILL_REF_ID_ER901
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
  methods Z_FILL_ADD_DATES
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
ENDCLASS.



CLASS ZCL_AGC_MESSAGE_UTILMD_IN_01 IMPLEMENTATION.


    METHOD determine_bmid.
*----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2015
**
** Usage: For BMID determination
**  1) The old determination logic by Document Name Code and other criteria
**     will not be used anymore.
**  2) A central API /idxgc/badi_data_access->get_bmid which is based on
**     customizing /IDXGC/V_AMIDCON should be used for all scenarios now.
**
** Status: <Completed>
*----------------------------------------------------------------------*
** Change History:
**
** Apr. 2015: Redefined:
*      1) Call new functionality for determining BMID from AMID
*      2) Call new method for handling references in response and reversals
*      3) Put all logic into this method and
*         set all methods DETERMINE_BMID_* to obsolete
*----------------------------------------------------------------------*
      "Kopie aus dem Standard mit Anpassung für ZD0 Antwort

      DATA: lx_previous        TYPE REF TO /idxgc/cx_general,
            lr_msgref_mgr      TYPE REF TO /idxgc/if_msgref_mgr,
            lr_diverse         TYPE REF TO /idxgc/s_diverse_details,
            lv_transaction_ref TYPE        /idxgc/de_transaction_ref,
            ls_msgref          TYPE        /idxgc/t_msgref,
            lv_exception_code  TYPE        /idxgc/de_excp_code.

      DATA: ls_diverse  TYPE /idxgc/s_diverse_details,
            lv_proc_ref TYPE /idxgc/de_proc_ref.

      FIELD-SYMBOLS:
        <fs_process_step_data> TYPE /idxgc/s_proc_step_data.

      DATA: ls_proc_step_data   TYPE        /idxgc/s_proc_step_data,
            lr_badi_data_access TYPE REF TO /idxgc/badi_data_access.

* Get process step data
      READ TABLE cs_proc_data-steps ASSIGNING <fs_process_step_data> INDEX 1.

* Get BMID by the central API
      TRY.
          GET BADI lr_badi_data_access.

          CALL BADI lr_badi_data_access->get_bmid
            EXPORTING
              is_msg_data = cs_proc_data
            IMPORTING
              ev_bmid     = <fs_process_step_data>-bmid.

        CATCH cx_badi_not_implemented.
          MESSAGE e257(/idxgc/utility_add) WITH /idxgc/if_constants=>gc_badi_data_access INTO gv_mtext.
          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ).
        CATCH cx_badi_multiply_implemented.
          MESSAGE e258(/idxgc/utility_add) WITH /idxgc/if_constants=>gc_badi_data_access INTO gv_mtext.
          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ).
        CATCH /idxgc/cx_utility_error.
          RETURN.
      ENDTRY.

      IF <fs_process_step_data>-bmid = 'ZCH02'.
        RETURN.
      ELSE.
        TRY .
* Handle reference for response and reversal message
            CALL METHOD me->handle_reference_resp_rev
              CHANGING
                cs_process_step_data = <fs_process_step_data>.

* Handle reference related to a preceding ORDERS request messages for BDR process
            IF <fs_process_step_data>-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z14.  "BDR.

              READ TABLE <fs_process_step_data>-diverse INTO ls_diverse INDEX 1.
              IF ls_diverse-ref_to_request IS NOT INITIAL.
                CALL METHOD me->get_proc_ref_from_doc_ident
                  EXPORTING
                    iv_document_ident = ls_diverse-ref_to_request
                    iv_docname_code   = /idxgc/if_constants_ide=>gc_msg_category_z14
                    iv_message_type   = /idxgc/if_constants_ide=>gc_msgtp_orders
                    iv_export         = /idxgc/cl_parser_idoc=>co_idoc_direction_outbound
                  IMPORTING
                    ev_proc_ref       = lv_proc_ref.
                IF sy-subrc = 0.
                  <fs_process_step_data>-proc_ref = lv_proc_ref.
                ENDIF.
              ELSE.
                MESSAGE e026(/idxgc/ide_add) INTO gv_mtext.
                CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
              ENDIF.

            ENDIF.

* Check and get the preceding message data and set the process reference number for Information notification
            IF <fs_process_step_data>-docname_code = /idxgc/if_constants_ide=>gc_msg_category_e44.

              READ TABLE <fs_process_step_data>-diverse INTO ls_diverse INDEX 1.
              IF ls_diverse-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z26.   "ES200
*         Read the preceding message via reference number
                CALL METHOD /idxgc/cl_process_document=>/idxgc/if_process_document~get_preceding_step_data
                  EXPORTING
                    iv_transaction_no     = ls_diverse-refnr_transreq
                    iv_direction          = cl_isu_datex_process=>co_dexdirection_export
                    iv_assoc_servprov     = <fs_process_step_data>-assoc_servprov
                    iv_proc_id_error_pdoc = /idxgc/if_constants=>gc_proc_id_unsl
                  IMPORTING
                    es_proc_step_data     = ls_proc_step_data.

                <fs_process_step_data>-proc_ref = ls_proc_step_data-proc_ref.
              ENDIF.

            ENDIF.

          CATCH /idxgc/cx_ide_error /idxgc/cx_process_error INTO lx_previous.
            CASE lx_previous->exception_code.
              WHEN /idxgc/if_constants_add=>gc_excp_code_refnotexist.
*         First we need to determine the possible transaction reference numbers from
*         the message data. Here we assume that the inbound message contains only one transaction:
                READ TABLE <fs_process_step_data>-diverse REFERENCE INTO lr_diverse INDEX 1.
                IF sy-subrc EQ 0.
                  IF lr_diverse->refnr_transreq IS NOT INITIAL.       "response
                    lv_transaction_ref = lr_diverse->refnr_transreq.
                  ELSEIF lr_diverse->refnr_transrev IS NOT INITIAL.   "reversal
                    lv_transaction_ref = lr_diverse->refnr_transrev.
                  ELSEIF lr_diverse->ref_to_request IS NOT INITIAL.   "information referring to a request?
                    lv_transaction_ref = lr_diverse->ref_to_request.
                  ELSE.
                    CLEAR lv_transaction_ref.
                  ENDIF.

                  IF lv_transaction_ref IS NOT INITIAL.

                    CALL METHOD /idxgc/cl_msgref_mgr=>get_instance
                      RECEIVING
                        rv_instance = lr_msgref_mgr.

                    CALL METHOD lr_msgref_mgr->get_data
                      EXPORTING
                        iv_transaction_ref = lv_transaction_ref
                      IMPORTING
                        es_msgref          = ls_msgref.
                    IF ls_msgref IS INITIAL.
*               Reference does not exist, trigger Z28-APERAK:
                      <fs_process_step_data>-bmid = /idxgc/if_constants_ide=>gc_bmid_cx100.
                      RETURN.
                    ELSE.
*               Reference exists
*               => In case of response to message of category E03 processing shall be finished without any further action
*               => Propagate exception with special exception code
*               Reason: In this case the original UTILMD message might not have been sent by a PDoc although
*                       the inbound processing in the receiver's system has triggered a PDoc
*                       (example: device replacement or installation was triggered directly by the corresponding transaction)
                      IF <fs_process_step_data>-docname_code EQ /idxgc/if_constants_ide=>gc_msg_category_e03
                          AND <fs_process_step_data>-msgrespstatus IS NOT INITIAL.
                        lv_exception_code = /idxgc/if_constants_add=>gc_excp_code_finish_proc.
                      ELSE.
                        CLEAR lv_exception_code.
                      ENDIF.
                      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
                        EXPORTING
                          ir_previous       = lx_previous
                          is_textid         = lx_previous->if_t100_message~t100key
                          ir_data           = lx_previous->data
                          iv_exception_code = lv_exception_code.
                    ENDIF.
                  ELSE.
*             No transaction reference having been given by imnbound essage
*             => Propagate exception
                    CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
                      EXPORTING
                        ir_previous = lx_previous
                        is_textid   = lx_previous->if_t100_message~t100key
                        ir_data     = lx_previous->data.
                  ENDIF.
                ELSE.
*           Inbound message doesn't have any DIVERSE data => error
*           Really should not happen here
                  MESSAGE e023(/idxgc/ide_add) WITH <fs_process_step_data>-docname_code INTO gv_mtext.
                  CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
                    EXPORTING
                      ir_previous       = lx_previous
                      iv_exception_code = lx_previous->exception_code.
                ENDIF.

              WHEN OTHERS.
                MESSAGE e023(/idxgc/ide_add) WITH <fs_process_step_data>-docname_code INTO gv_mtext.
                CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
                  EXPORTING
                    ir_previous       = lx_previous
                    iv_exception_code = lx_previous->exception_code.

            ENDCASE.
        ENDTRY.
      ENDIF.
    ENDMETHOD.


METHOD handle_reference_resp_rev.
*----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2015
**
** Usage: Handle reference for response and reversal message.
**
**
** Status: <Completed>
*----------------------------------------------------------------------*
** Change History:
**
** Apr. 2015: Created.
* 1) Check the existence of the reference for response and reversal message
* 2) Exception with code 'RefNotExist' raised in case of rerefence not found
* 3) Process reference will be taken over to current step or global variable
*----------------------------------------------------------------------*
* Maxim Schmidt, 03.02.2016, Mantis 5240 Kopie aus dem Standard
*----------------------------------------------------------------------*

  DATA: lv_response_msg  TYPE boolean,
        lv_reversal_msg  TYPE boolean,
        ls_diverse       TYPE /idxgc/s_diverse_details,
        ls_msgrespstatus TYPE /idxgc/s_msgsts_details.

  DATA:
    lv_transaction_no	TYPE /idxgc/de_transaction_no,
    lv_direction      TYPE e_dexdirection,
    lv_assoc_servprov	TYPE e_dexservprov.

  DATA: ls_proc_step_data TYPE        /idxgc/s_proc_step_data,
        lx_previous       TYPE REF TO /idxgc/cx_general.

* Get deverse data
  READ TABLE cs_process_step_data-diverse INTO ls_diverse INDEX 1.

* Response message
  IF cs_process_step_data-msgrespstatus IS NOT INITIAL.
*   Special case: confirmation of registration for new installation of a
*   feeding installation looks like a response but does not refer to a request;
*   At the moment this process is not supported
    READ TABLE cs_process_step_data-amid WITH KEY amid = /idxgc/if_constants_ide=>gc_amid_11079 TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    lv_response_msg = abap_true.
  ELSEIF ls_diverse-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_e05.
* Reversal message
    lv_reversal_msg = abap_true.
  ENDIF.

  IF lv_response_msg <> abap_true AND lv_reversal_msg <> abap_true.
    RETURN.
  ENDIF.

  IF lv_response_msg = abap_true.
    lv_transaction_no = ls_diverse-refnr_transreq.
    lv_direction      = cl_isu_datex_process=>co_dexdirection_export.
    lv_assoc_servprov = cs_process_step_data-assoc_servprov.
  ENDIF.
  IF lv_reversal_msg = abap_true.
    lv_transaction_no = ls_diverse-refnr_transrev.
    lv_direction      = cl_isu_datex_process=>co_dexdirection_import.
    lv_assoc_servprov = cs_process_step_data-assoc_servprov.
  ENDIF.

  TRY .
*     Read the preceding message via reference number
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      TRY.
          CALL METHOD /idxgc/cl_process_document=>/idxgc/if_process_document~get_preceding_step_data
            EXPORTING
              iv_transaction_no     = lv_transaction_no
              iv_direction          = lv_direction
              iv_assoc_servprov     = lv_assoc_servprov
              iv_proc_id_error_pdoc = /idxgc/if_constants=>gc_proc_id_unsl
            IMPORTING
              es_proc_step_data     = ls_proc_step_data.

        CATCH /idxgc/cx_process_error.

          CALL METHOD zcl_agc_datex_utility=>get_preceding_step_data
            EXPORTING
              iv_transaction_no     = lv_transaction_no
              iv_direction          = lv_direction
              iv_assoc_servprov     = lv_assoc_servprov
              iv_proc_id_error_pdoc = /idxgc/if_constants=>gc_proc_id_unsl
            IMPORTING
              es_proc_step_data     = ls_proc_step_data.

      ENDTRY.
* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*     Take over the process reference to current step in case of response
*     Fill step data into attributes in case of response
      IF lv_response_msg = abap_true.

        cs_process_step_data-proc_ref = ls_proc_step_data-proc_ref.

        CALL METHOD me->fill_orig_msg_data_into_attr
          EXPORTING
            is_proc_step_data_orig = ls_proc_step_data
            iv_scenario_id         = /idxgc/if_constants_add=>gc_scenario_id_response
          CHANGING
            cs_process_step_data   = cs_process_step_data.

      ENDIF.

*     Take over the process reference to global variable in case of reversal:
      IF lv_reversal_msg = abap_true.
        gv_procref_to_be_reversed = ls_proc_step_data-proc_ref.
      ENDIF.

    CATCH /idxgc/cx_process_error INTO lx_previous.
      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
        EXPORTING
          ir_previous       = lx_previous
          iv_exception_code = lx_previous->exception_code.

  ENDTRY.

ENDMETHOD.


  method PREPARE_PROCESS_DATA.
***************************************************************************************************
* Prozessdaten für Verarbeitung mit alten Workflow-Prozessen anpassen.
*-------------------------------------------------------------------------------------------------*
* THIMEL.R 20150817 Kopie aus Vorgängerklasse
***************************************************************************************************
*----------------------------------------------------------------------*
* Entwickler:
* Kürzel    Vorname         Nachname         Firma
* PK        Peter           Kalus            i.A. Adesso AG
*----------------------------------------------------------------------*
* PK20150907  5002: Stornoanfrage auf Abmeldungsanfrage geht nicht im Mandant 110 ein
*             Übergabe der Referenznummer einer Storno-Nachricht
*
*"----------------------------------------------------------------------
    DATA:
      ls_process_data TYPE /idxgc/s_proc_data.
    FIELD-SYMBOLS:
      <proc_step_data>   TYPE /idxgc/s_proc_step_data,
      <pod_info_details> TYPE /idxgc/s_pod_info_details.

***** Initialisierung *****************************************************************************
    ls_process_data = is_process_data.

***** Namen entsprechend der SWS Vorgaben ändern **************************************************
    z_change_names( CHANGING cs_proc_data = ls_process_data ).

***** Zählpunktidentifikation (EXT_UI, INT_UI und BU_PARTNER setzen) ******************************
    z_inbound_determine_pod( CHANGING cs_proc_data = ls_process_data ).

***** DISTRIBUTOR, SERVPROV_OLD, SERVPROV_NEW setzen **********************************************
    z_inbound_determine_servprov( CHANGING cs_proc_data = ls_process_data ).

***** Namen entsprechend der SWS Vorgaben ändern **************************************************
    z_fill_add_dates( CHANGING cs_proc_data = ls_process_data ).
* >>> PK20150907
***** DISTRIBUTOR, SERVPROV_OLD, SERVPROV_NEW setzen **********************************************
    z_inbound_fill_ref_id_er901( CHANGING cs_proc_data = ls_process_data ).
* <<< PK20150907
***** Unnötige Daten löschen **********************************************************************
    z_delete_unneeded_data( CHANGING cs_proc_data = ls_process_data ).

    CALL METHOD super->prepare_process_data
      EXPORTING
        is_process_data = ls_process_data
      IMPORTING
        et_process_data = et_process_data.
  endmethod.


  METHOD z_change_names.
***************************************************************************************************
* Namen entsprechend der SWS Vorgaben anpassen
*--------------------------------------------------------------------------------------------------
* THIMEL.R 20150817 Kopie aus Vorgängerklasse
***************************************************************************************************
    DATA:
      lr_exit_obj            TYPE REF TO if_ex_isu_ide_comm_swt,
      lt_eideswtmsgdata      TYPE        teideswtmsgdata,
      lt_msg_return          TYPE        ttinv_log_msgbody,
      ls_eideswtmsgpod       TYPE        eideswtmsgpod,
      ls_identdata           TYPE        ederegident_data,
      ls_pdoc_data           TYPE        /idxgc/s_pdoc_data,
      ls_euitrans            TYPE        euitrans,
      ls_diverse_details     TYPE        /idxgc/s_diverse_details,
      ls_nameaddr_details    TYPE        /idxgc/s_nameaddr_details,
      ls_nameaddr_details_dp TYPE        /idxgc/s_nameaddr_details,
      ls_meterdev_details    TYPE        /idxgc/s_meterdev_details,
      lv_amid                TYPE        /idxgc/de_amid,
      lv_ext_ui              TYPE        ext_ui,
      lv_ext_ui_parent       TYPE        ext_ui,
      lv_int_ui              TYPE        int_ui,
      lv_bu_partner          TYPE        bu_partner,
      lv_keydate             TYPE        dats,
      lv_complete_check      TYPE        flag.

    FIELD-SYMBOLS:
      <fs_proc_step_data>   TYPE /idxgc/s_proc_step_data,
      <fs_amid_details>     TYPE /idxgc/s_amid_details,
      <fs_pod_info_details> TYPE /idxgc/s_pod_info_details,

      <fs_nameaddr_details> TYPE /idxgc/s_nameaddr_details.


***** Daten übernehmen / lesen ********************************************************************
    LOOP AT cs_proc_data-steps ASSIGNING <fs_proc_step_data> WHERE proc_step_ref CS /idxgc/if_constants=>gc_temp_indicator.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 4.
      MESSAGE e004(/idxgc/ide_add) INTO gv_mtext.
      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
    ENDIF.

***** Namen ändern ********************************************************************************
    LOOP AT <fs_proc_step_data>-name_address ASSIGNING <fs_nameaddr_details>.
*      CLEAR ls_nameaddr_details.
*      ls_nameaddr_details = <fs_nameaddr_details>.
*      IF <fs_nameaddr_details>-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
*        IF <fs_nameaddr_details>-name_format_code = zif_agc_datex_co=>gc_nad_name_format_z01.
*          <fs_nameaddr_details>-first_name1    = ls_nameaddr_details-fam_comp_name1.
*          <fs_nameaddr_details>-first_name2    = ls_nameaddr_details-fam_comp_name2.
*          <fs_nameaddr_details>-fam_comp_name1 = ls_nameaddr_details-first_name1.
*          <fs_nameaddr_details>-fam_comp_name2 = ls_nameaddr_details-first_name2.
*        ELSEIF <fs_nameaddr_details>-name_format_code = zif_agc_datex_co=>gc_nad_name_format_z02.
*          <fs_nameaddr_details>-fam_comp_name1 = ls_nameaddr_details-fam_comp_name1.
*          <fs_nameaddr_details>-first_name1    = ls_nameaddr_details-fam_comp_name2.
*          CLEAR: <fs_nameaddr_details>-fam_comp_name2, <fs_nameaddr_details>-first_name2.
*        ENDIF.
      IF <fs_nameaddr_details>-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_eo.
        IF <fs_nameaddr_details>-name_format_code = zif_agc_datex_co=>gc_nad_name_format_z01.
          <fs_nameaddr_details>-fam_comp_name1 = ls_nameaddr_details-fam_comp_name1.
          <fs_nameaddr_details>-first_name2    = ls_nameaddr_details-fam_comp_name2.
          <fs_nameaddr_details>-first_name1    = ls_nameaddr_details-first_name1.
          <fs_nameaddr_details>-fam_comp_name2 = ls_nameaddr_details-first_name2.
        ELSEIF <fs_nameaddr_details>-name_format_code = zif_agc_datex_co=>gc_nad_name_format_z02.
          <fs_nameaddr_details>-fam_comp_name1 = ls_nameaddr_details-fam_comp_name1.
          <fs_nameaddr_details>-first_name1    = ls_nameaddr_details-fam_comp_name2.
          CLEAR: <fs_nameaddr_details>-fam_comp_name2, <fs_nameaddr_details>-first_name2.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD z_delete_unneeded_data.
***************************************************************************************************
* Unnötige Daten werden aus den Schrittdaten des aktuellen Schritts gelöscht, da diese ggf.
*   Probleme in den Prozessen bereiten. Dies betrifft i.d.R. Daten, die Marktpartner ohne
*   Grund mitschicken.
*--------------------------------------------------------------------------------------------------
* THIMEL.R 20150817 Kopie aus Vorgängerklasse
***************************************************************************************************
    DATA: lv_amid TYPE /idxgc/de_amid.

    FIELD-SYMBOLS:
      <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
      <fs_amid_details>    TYPE /idxgc/s_amid_details,
      <fs_diverse_details> TYPE /idxgc/s_diverse_details.

***** Daten übernehmen / lesen ********************************************************************
    LOOP AT cs_proc_data-steps ASSIGNING <fs_proc_step_data> WHERE proc_step_ref CS /idxgc/if_constants=>gc_temp_indicator.
      READ TABLE <fs_proc_step_data>-amid ASSIGNING <fs_amid_details> INDEX 1.
      IF sy-subrc = 0.
        lv_amid = <fs_amid_details>-amid.
      ENDIF.
      EXIT.
    ENDLOOP.

***** Daten löschen *******************************************************************************
    CASE lv_amid.
      WHEN zif_agc_datex_utilmd_co=>gc_amid_11001.
        CLEAR:
          <fs_proc_step_data>-validity_ym,     "Mantis 4623, Darf nicht mitgeschickt werden.
          <fs_proc_step_data>-msg_timeoffset.  "Mantis 4623, Darf nicht mitgeschickt werden.
        LOOP AT <fs_proc_step_data>-diverse ASSIGNING <fs_diverse_details>.
          "Mantis 4624, ohne zweiten Transaktionsgrund keine befristete Anmeldung (DTM+93 wird entfernt)
          IF <fs_diverse_details>-dereg_reason IS INITIAL.
            CLEAR <fs_diverse_details>-contr_end_date.
          ELSE.
            IF <fs_diverse_details>-contr_end_date = '99991231'. "Mantis 4710, befristete Anmeldung mit Ende-Datum von 31.12.9999 ist keine befristete Anmeldung. Datum und zweiten Transaktionsgrund löschen!
              CLEAR:
                <fs_diverse_details>-contr_end_date,
                <fs_diverse_details>-dereg_reason,
                cs_proc_data-zz_moveoutdate,
                cs_proc_data-zz_realmoveoutdate.
            ENDIF.
          ENDIF.
        ENDLOOP.
    ENDCASE.

  ENDMETHOD.


  METHOD z_fill_add_dates.
***************************************************************************************************
* Für die Verarbeitung mit Wechselbelegen werden Einzugs- und Auszugsdatum benötigt.
*--------------------------------------------------------------------------------------------------
* THIMEL.R 20150817 Kopie aus Vorgängerklasse
***************************************************************************************************
    DATA: lv_amid TYPE /idxgc/de_amid.

    FIELD-SYMBOLS: <fs_proc_step_data>  TYPE /idxgc/s_proc_step_data,
                   <fs_amid_details>    TYPE /idxgc/s_amid_details,
                   <fs_diverse_details> TYPE /idxgc/s_diverse_details.

***** Daten übernehmen / lesen ********************************************************************
    LOOP AT cs_proc_data-steps ASSIGNING <fs_proc_step_data> WHERE proc_step_ref CS /idxgc/if_constants=>gc_temp_indicator.
      READ TABLE <fs_proc_step_data>-amid ASSIGNING <fs_amid_details> INDEX 1.
      IF sy-subrc = 0.
        lv_amid = <fs_amid_details>-amid.
      ENDIF.
      READ TABLE <fs_proc_step_data>-diverse ASSIGNING <fs_diverse_details> INDEX 1.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 4.
      MESSAGE e004(/idxgc/ide_add) INTO gv_mtext.
      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
    ENDIF.

***** MOVEOUTDATE, MOVEINDATE, REALMOVEOUTDATE, REALMOVEINDATE setzen **********************************************
    IF <fs_diverse_details> IS ASSIGNED.
      CASE lv_amid.
        WHEN zif_agc_datex_utilmd_co=>gc_amid_11001  "Anmeldung NN
          OR zif_agc_datex_utilmd_co=>gc_amid_11004  "Abmeldung NN
          OR zif_agc_datex_utilmd_co=>gc_amid_11007  "Abmeldung Stilllegung NN
          OR zif_agc_datex_utilmd_co=>gc_amid_11010  "Abmeldeanfrage des NB
          OR zif_agc_datex_utilmd_co=>gc_amid_11013  "Anmeldung EoG
          OR zif_agc_datex_utilmd_co=>gc_amid_11037. "Informationsmeldung zur Beendigung der Zuordnung
          cs_proc_data-zz_moveoutdate = <fs_diverse_details>-contr_end_date.
          cs_proc_data-zz_realmoveoutdate = <fs_diverse_details>-contr_end_date.
          cs_proc_data-zz_moveindate = <fs_diverse_details>-contr_start_date.
          cs_proc_data-zz_realmoveindate = <fs_diverse_details>-contr_start_date.
        WHEN zif_agc_datex_utilmd_co=>gc_amid_11016.  "Kündigung
          IF <fs_diverse_details>-contr_end_date IS NOT INITIAL.
            cs_proc_data-zz_moveoutdate = <fs_diverse_details>-contr_end_date.
            cs_proc_data-zz_realmoveoutdate = <fs_diverse_details>-contr_end_date.
          ELSE.
            cs_proc_data-zz_moveoutdate = <fs_diverse_details>-endnextposs_from.
            cs_proc_data-zz_realmoveoutdate = <fs_diverse_details>-endnextposs_from.
          ENDIF.
        WHEN zif_agc_datex_utilmd_co=>gc_amid_11030 "Stammdatenänderung Z46 / Z47
          OR zif_agc_datex_utilmd_co=>gc_amid_11025
          OR zif_agc_datex_utilmd_co=>gc_amid_11028
          OR zif_agc_datex_utilmd_co=>gc_amid_11033
          OR zif_agc_datex_utilmd_co=>gc_amid_11103
          OR zif_agc_datex_utilmd_co=>gc_amid_11104.
          cs_proc_data-zz_moveindate = <fs_diverse_details>-validstart_date.
          cs_proc_data-zz_realmoveindate = <fs_diverse_details>-validstart_date.
        WHEN zif_agc_datex_utilmd_co=>gc_amid_11020. "Stammdatenänderung ZD0
          cs_proc_data-zz_moveindate = <fs_proc_step_data>-validity_ym.
          cs_proc_data-zz_realmoveindate = <fs_proc_step_data>-validity_ym.
      ENDCASE.
    ENDIF.
  ENDMETHOD.


  METHOD z_inbound_determine_pod.
***************************************************************************************************
* Zählpunktidentifikation für alte Workflow-Prozesse
*--------------------------------------------------------------------------------------------------
* THIMEL.R 20150817 Kopie aus Vorgängerklasse
***************************************************************************************************
    DATA:
      lr_previous            TYPE REF TO   cx_root,
      lr_exit_obj            TYPE REF TO   if_ex_isu_ide_comm_swt,
      lt_eideswtmsgdata      TYPE          teideswtmsgdata,
      lt_msg_return          TYPE          ttinv_log_msgbody,
      lt_partner             TYPE TABLE OF bapiisupodpartner,
      ls_eideswtmsgpod       TYPE          eideswtmsgpod,
      ls_identdata           TYPE          ederegident_data,
      ls_pdoc_data           TYPE          /idxgc/s_pdoc_data,
      ls_euitrans            TYPE          euitrans,
      ls_diverse_details     TYPE          /idxgc/s_diverse_details,
      ls_nameaddr_details_ud TYPE          /idxgc/s_nameaddr_details,
      ls_nameaddr_details_dp TYPE          /idxgc/s_nameaddr_details,
      ls_meterdev_details    TYPE          /idxgc/s_meterdev_details,
      lv_amid                TYPE          /idxgc/de_amid,
      lv_ext_ui              TYPE          ext_ui,
      lv_ext_ui_parent       TYPE          ext_ui,
      lv_int_ui              TYPE          int_ui,
      lv_bu_partner          TYPE          bu_partner,
      lv_keydate             TYPE          dats,
      lv_complete_check      TYPE          flag.

    FIELD-SYMBOLS:
      <fs_proc_step_data>   TYPE /idxgc/s_proc_step_data,
      <fs_amid_details>     TYPE /idxgc/s_amid_details,
      <fs_pod_info_details> TYPE /idxgc/s_pod_info_details,
      <fs_partner>          TYPE bapiisupodpartner,
      <fs_nameaddr_details> TYPE /idxgc/s_nameaddr_details.

***** Daten übernehmen / lesen ********************************************************************
    LOOP AT cs_proc_data-steps ASSIGNING <fs_proc_step_data> WHERE proc_step_ref CS /idxgc/if_constants=>gc_temp_indicator.
      READ TABLE <fs_proc_step_data>-amid ASSIGNING <fs_amid_details> INDEX 1.
      IF sy-subrc = 0.
        lv_amid = <fs_amid_details>-amid.
      ENDIF.
      LOOP AT <fs_proc_step_data>-pod ASSIGNING <fs_pod_info_details>
        WHERE pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30 OR pod_type IS INITIAL.
        lv_ext_ui = <fs_pod_info_details>-ext_ui.
        lv_int_ui = <fs_pod_info_details>-int_ui.
        EXIT.
      ENDLOOP.
      READ TABLE <fs_proc_step_data>-diverse INTO ls_diverse_details INDEX 1.
      LOOP AT <fs_proc_step_data>-name_address ASSIGNING <fs_nameaddr_details>.
        IF <fs_nameaddr_details>-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
          ls_nameaddr_details_ud = <fs_nameaddr_details>.
        ELSEIF <fs_nameaddr_details>-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
          ls_nameaddr_details_dp = <fs_nameaddr_details>.
        ENDIF.
      ENDLOOP.
      READ TABLE <fs_proc_step_data>-meter_dev INTO ls_meterdev_details INDEX 1.
      EXIT.
    ENDLOOP.

***** ZPI BAdI aufrufen für einige Fälle **********************************************************
    "ZPI: Nur bei Anfragen, die nicht zwingend eine ZPB enthalten oder bei Sonderfällen
    IF ( lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11001 AND "Anmeldung (ZPB -> KANN-Feld)
       ls_diverse_details-msgtransreason <> zif_agc_datex_utilmd_co=>gc_trans_reason_code_z28 ) OR "nicht für Sperrprozess
       lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11016.      "Kündigung (ZPB -> KANN-Feld)


*---- Daten vorbereiten ---------------------------------------------------------------------------
      "Identifizierungsdaten holen
      TRY.
          CALL METHOD /idxgc/cl_process_document=>/idxgc/if_process_document~map_process_to_pdoc_data
            EXPORTING
              is_proc_data = cs_proc_data
            IMPORTING
              es_pdoc_data = ls_pdoc_data.
        CATCH /idxgc/cx_process_error INTO lr_previous.
          /idxgc/cx_ide_error=>raise_ide_exception_from_msg( ir_previous = lr_previous ).
      ENDTRY.
      zcl_agc_datex_utility=>map_pdoc_to_isu_data(
        EXPORTING is_pdoc_data    = ls_pdoc_data
        IMPORTING et_msg_hdr      = lt_eideswtmsgdata
                  et_msg_comments = ls_eideswtmsgpod-msgdatacomment ).
      READ TABLE lt_eideswtmsgdata INTO ls_eideswtmsgpod-msgdata INDEX 1.
      ls_eideswtmsgpod-int_ui = lv_int_ui.
      ls_eideswtmsgpod-ext_ui = lv_ext_ui.
      MOVE-CORRESPONDING ls_eideswtmsgpod-msgdata TO ls_identdata.
      ls_identdata-pod_ext_ui = lv_ext_ui. "THIMEL.R M4928 EXT_UI wird auch hier benötigt

      "Instanz BAdI zur ZPI
      CALL METHOD cl_exithandler=>get_instance
        EXPORTING
          exit_name                     = 'ISU_IDE_COMM_SWT'
          null_instance_accepted        = abap_false
        CHANGING
          instance                      = lr_exit_obj
        EXCEPTIONS
          no_reference                  = 1
          no_interface_reference        = 2
          no_exit_interface             = 3
          class_not_implement_interface = 4
          single_exit_multiply_active   = 5
          cast_error                    = 6
          exit_not_existing             = 7
          data_incons_in_exit_managem   = 8
          OTHERS                        = 9.
      IF sy-subrc <> 0.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
      ENDIF.

      "Flag für Partneridentifikation
      IF ( lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11001 ) AND "Anmeldung
         ( ls_diverse_details-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_e01 OR
           ls_diverse_details-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_e02 ).
        lv_complete_check = abap_false.
      ELSE.
        lv_complete_check = abap_true.
      ENDIF.

*---- ZPI durchführen -----------------------------------------------------------------------------
      "Falls ZP nicht identifiziert wird, dann erfolgt im Workflow eine ZPI.
      CALL METHOD lr_exit_obj->inbound_determine_pod
        EXPORTING
          x_identdata      = ls_identdata
          x_complete_check = lv_complete_check
          x_swtmsgpod      = ls_eideswtmsgpod
        IMPORTING
          y_pod_int_ui     = lv_int_ui
          y_bu_part_int_nr = lv_bu_partner
          yt_msg_return    = lt_msg_return
        EXCEPTIONS
          general_fault    = 1
          OTHERS           = 2.
      IF sy-subrc = 0 AND lt_msg_return IS INITIAL AND lv_int_ui IS NOT INITIAL. ">>>THIMEL.R 20150420 M4914 Wenn INT_UI initial, dann ZPI
        cs_proc_data-int_ui = lv_int_ui.
        <fs_proc_step_data>-ext_ui = lv_ext_ui.
        cs_proc_data-bu_partner = lv_bu_partner.
      ELSE. ">>>SCHMIDT.C 20150407 Zählpunktbezeichnung löschen, damit eine manuelle ZPI aus dem WB heraus möglich ist
        CLEAR cs_proc_data-int_ui.
        CLEAR <fs_proc_step_data>-ext_ui.
        CLEAR cs_proc_data-bu_partner.
      ENDIF.

***** Interne ZPB bestimmen / übernehmen für alle anderen Fälle ***********************************
    ELSEIF lv_int_ui IS NOT INITIAL.
      cs_proc_data-int_ui = lv_int_ui.
      <fs_proc_step_data>-ext_ui = lv_ext_ui.
    ELSEIF lv_ext_ui IS NOT INITIAL.
      lv_keydate = zcl_agc_datex_utility=>get_proc_date( iv_amid = lv_amid is_proc_step_data = <fs_proc_step_data> ).

      "Interne ZPB bestimmen
      CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
        EXPORTING
          x_ext_ui     = lv_ext_ui
          x_keydate    = lv_keydate
        IMPORTING
          y_euitrans   = ls_euitrans
        EXCEPTIONS
          not_found    = 1
          system_error = 2
          OTHERS       = 3.
      "Falls keine interne ZPB gefunden wurde, auf Child-ZP prüfen.
      IF sy-subrc <> 0.
        "Falls es sich um einen Child-ZP handelt, den Parent-ZP für die Bestimmung der internen ZPB nehmen.
        IF zcl_complex_pod=>is_child_pod( id_ext_ui = lv_ext_ui id_date = lv_keydate ) = abap_true.
          lv_ext_ui_parent = zcl_complex_pod=>get_parent_pod( id_ext_ui_child = lv_ext_ui id_date = lv_keydate ).
          CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
            EXPORTING
              x_ext_ui     = lv_ext_ui_parent
              x_keydate    = lv_keydate
            IMPORTING
              y_euitrans   = ls_euitrans
            EXCEPTIONS
              not_found    = 1
              system_error = 2
              OTHERS       = 3.
          IF sy-subrc <> 0.
            "Der Fehler sollten nie auftreten, da dieser bereits durch die APERAK Prüfung abgefangen werden sollte.
            CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
          ELSE.
            lv_int_ui = ls_euitrans-int_ui.
          ENDIF.
        ELSE.
          "Die ZPB muss nicht in allen Fällen schon im System bekannt sein
          IF lv_amid <> zif_agc_datex_utilmd_co=>gc_amid_11013 AND "EoG
             lv_amid <> zif_agc_datex_utilmd_co=>gc_amid_11002 AND "Bestätigung Anmeldung
             lv_amid <> zif_agc_datex_utilmd_co=>gc_amid_11003 AND "Ablehnung Anmeldung
             lv_amid <> zif_agc_datex_utilmd_co=>gc_amid_11017 AND "Zustimmung auf Kündigung
             lv_amid <> zif_agc_datex_utilmd_co=>gc_amid_11018 AND "Ablehnung auf Kündigung M4900
             lv_amid <> zif_agc_datex_utilmd_co=>gc_amid_11036.    "Informationsmeldung über exist. Zuordnung M4900

            CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
          ENDIF.
        ENDIF.
      ELSE.
        lv_int_ui = ls_euitrans-int_ui.
      ENDIF.

      cs_proc_data-int_ui = lv_int_ui.
      <fs_proc_step_data>-ext_ui = lv_ext_ui.
    ENDIF.

***** Geschäftspartner ermitteln für einige Fälle *************************************************
    IF cs_proc_data-bu_partner IS INITIAL.
      IF lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11004 OR "Abmeldung NN
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11007 OR "Abmeldung Stilllegung
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11010 OR "Abmeldungsanfrage (Partner)
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11025 OR "SDÄ nicht bil. rel.
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11026 OR "SDÄ nicht bil. rel.
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11027 OR "SDÄ nicht bil. rel.
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11028 OR "SDÄ nicht bil. rel.
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11030 OR "SDÄ bil. rel.
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11033 OR "SDÄ bil. rel.
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11103 OR "Netzbetreiberwechsel: Stammdaten zur Entnahmestelle
         lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11104 OR "Netzbetreiberwechsel: Aktualisierte Stammdaten zur Entnahmestelle
         ( lv_amid = zif_agc_datex_utilmd_co=>gc_amid_11001 AND ls_diverse_details-msgtransreason = zif_agc_datex_utilmd_co=>gc_trans_reason_code_z28 ). "Entsperrprozess
        IF lv_keydate IS INITIAL.
          lv_keydate = zcl_agc_datex_utility=>get_proc_date( iv_amid = lv_amid is_proc_step_data = <fs_proc_step_data> ).
        ENDIF.

        CALL FUNCTION 'BAPI_ISUPOD_GETPARTNER'
          EXPORTING
            keydate         = lv_keydate
            pointofdelivery = <fs_proc_step_data>-ext_ui
          TABLES
            partner         = lt_partner.

        IF lines( lt_partner ) = 1.
          READ TABLE lt_partner ASSIGNING <fs_partner> INDEX 1.
          cs_proc_data-bu_partner = <fs_partner>-partner.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD z_inbound_determine_servprov.
***************************************************************************************************
* Ermitteln in welche Felder die Serviceanbieter für die alten Workflow-Prozesse geschrieben werden
*   müssen und ändert die Prozessdaten entsprechend.
*--------------------------------------------------------------------------------------------------
* THIMEL.R 20150817 Kopie aus Vorgängerklasse
***************************************************************************************************
    DATA: lv_amid    TYPE /idxgc/de_amid,
          lv_keydate TYPE dats.

    FIELD-SYMBOLS: <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fs_amid_details>   TYPE /idxgc/s_amid_details.

***** Daten übernehmen / lesen ********************************************************************
    LOOP AT cs_proc_data-steps ASSIGNING <fs_proc_step_data> WHERE proc_step_ref CS /idxgc/if_constants=>gc_temp_indicator.
      READ TABLE <fs_proc_step_data>-amid ASSIGNING <fs_amid_details> INDEX 1.
      IF sy-subrc = 0.
        lv_amid = <fs_amid_details>-amid.
      ENDIF.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 4.
      MESSAGE e004(/idxgc/ide_add) INTO gv_mtext.
      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg.
    ENDIF.

***** DISTRIBUTOR, SERVPROV_OLD, SERVPROV_NEW setzen **********************************************
    CASE lv_amid.
      WHEN zif_agc_datex_utilmd_co=>gc_amid_11007  "Abmeldung Stilllegung NN
        OR zif_agc_datex_utilmd_co=>gc_amid_11010  "Abmeldeanfrage des NB
        OR zif_agc_datex_utilmd_co=>gc_amid_11037  "Informationsmeldung zur Beendigung der Zuordnung
        OR zif_agc_datex_utilmd_co=>gc_amid_11103  "Netzbetreiberwechsel: Stammdaten zur Entnahmestelle
        OR zif_agc_datex_utilmd_co=>gc_amid_11104. "Netzbetreiberwechsel: Aktualisierte Stammdaten zur Entnahmestelle

        cs_proc_data-distributor      = <fs_proc_step_data>-assoc_servprov.
        cs_proc_data-service_prov_old = <fs_proc_step_data>-own_servprov.
        cs_proc_data-service_prov_new = ''.

      WHEN zif_agc_datex_utilmd_co=>gc_amid_11013  "Anmeldung EOG
        OR zif_agc_datex_utilmd_co=>gc_amid_11035  "AW auf Geschäftsdatenanfrage
        OR zif_agc_datex_utilmd_co=>gc_amid_11036  "Informationsmeldung über exist. Zuordnung
        OR zif_agc_datex_utilmd_co=>gc_amid_11038. "Informationsmeldung zur Aufhebung einer zuk. Zuordnung

        cs_proc_data-distributor      = <fs_proc_step_data>-assoc_servprov.
        cs_proc_data-service_prov_old = ''.
        cs_proc_data-service_prov_new = <fs_proc_step_data>-own_servprov.

      WHEN zif_agc_datex_utilmd_co=>gc_amid_11001. "Anmeldung NN

        cs_proc_data-distributor      = <fs_proc_step_data>-own_servprov.
        cs_proc_data-service_prov_old = ''.
        cs_proc_data-service_prov_new = <fs_proc_step_data>-assoc_servprov.

      WHEN zif_agc_datex_utilmd_co=>gc_amid_11004. "Abmeldung NN

        cs_proc_data-distributor      = <fs_proc_step_data>-own_servprov.
        cs_proc_data-service_prov_old = <fs_proc_step_data>-assoc_servprov.
        cs_proc_data-service_prov_new = ''.

      WHEN zif_agc_datex_utilmd_co=>gc_amid_11016. "Kündigung beim alten Lieferanten

        lv_keydate = zcl_agc_datex_utility=>get_proc_date( iv_amid = lv_amid is_proc_step_data = <fs_proc_step_data> ).
        CALL FUNCTION 'ISU_IDE_DEREG_SPMETHD_DISTR'
          EXPORTING
            x_int_ui      = cs_proc_data-int_ui
            x_datefrom    = lv_keydate
          IMPORTING
            y_serviceid   = cs_proc_data-distributor
          EXCEPTIONS
            general_fault = 1
            OTHERS        = 2.
        cs_proc_data-service_prov_old = <fs_proc_step_data>-own_servprov.
        cs_proc_data-service_prov_new = <fs_proc_step_data>-assoc_servprov.

      WHEN zif_agc_datex_utilmd_co=>gc_amid_11020  "Änderungsmeldung zur Zuordnungsliste
        OR zif_agc_datex_utilmd_co=>gc_amid_11025  "Änderungsmeldung nicht bila. rel., LF >NB
        OR zif_agc_datex_utilmd_co=>gc_amid_11026  "Änderungsmeldung nicht bila. rel., MSB>NB
        OR zif_agc_datex_utilmd_co=>gc_amid_11027  "Änderungsmeldung nicht bila. rel., MDL>NB
        OR zif_agc_datex_utilmd_co=>gc_amid_11028  "Änderungsmeldung nicht bila. rel., NB >LF/MSB/MDL
        OR zif_agc_datex_utilmd_co=>gc_amid_11030  "Änderungsmeldung bila. rel., LF >NB
        OR zif_agc_datex_utilmd_co=>gc_amid_11033. "Änderungsmeldung bila. rel., NB >LF

        cs_proc_data-distributor      = ''.
        cs_proc_data-service_prov_old = <fs_proc_step_data>-assoc_servprov.
        cs_proc_data-service_prov_new = <fs_proc_step_data>-own_servprov.

    ENDCASE.

  ENDMETHOD.


  METHOD z_inbound_fill_ref_id_er901.
***************************************************************************************************
* Ermitteln in welche Felder die Serviceanbieter für die alten Workflow-Prozesse geschrieben werden
*   müssen und ändert die Prozessdaten entsprechend.
*--------------------------------------------------------------------------------------------------
* THIMEL.R 20150817 Kopie aus Vorgängerklasse
***************************************************************************************************
*----------------------------------------------------------------------*
* Entwickler:
* Kürzel    Vorname         Nachname         Firma
* PK        Peter           Kalus            i.A. Adesso AG
*----------------------------------------------------------------------*
* PK20150907  5002: Stornoanfrage auf Abmeldungsanfrage geht nicht im Mandant 110 ein
*             Referenznummer einer Storno-Nachricht setzen.
*             Teil-Coding-Übernahme aus
*             ZCL_AGC_MESSAGE_UTILMD_IN -> DETERMINE_BMID
*"----------------------------------------------------------------------
    DATA: lv_amid    TYPE /idxgc/de_amid,
          lv_keydate TYPE dats.

    FIELD-SYMBOLS: <fs_proc_step_data> TYPE /idxgc/s_proc_step_data,
                   <fs_amid_details>   TYPE /idxgc/s_amid_details.



***** Daten übernehmen / lesen ********************************************************************
    LOOP AT cs_proc_data-steps ASSIGNING <fs_proc_step_data> WHERE bmid = /idxgc/if_constants_ide=>gc_bmid_er901.
      "Bei SWS wird die Stornomeldung an den Prozess gehängt.
      IF gv_procref_to_be_reversed IS NOT INITIAL.
        <fs_proc_step_data>-proc_ref = gv_procref_to_be_reversed.
        "THIMEL.R 20150401 Mantis 4865 Referenz setzen auf den gleichen Prozess führt zu Fehlern im Protokoll
        CLEAR: gv_procref_to_be_reversed.
      ENDIF.
    ENDLOOP.
*

  ENDMETHOD.
ENDCLASS.
