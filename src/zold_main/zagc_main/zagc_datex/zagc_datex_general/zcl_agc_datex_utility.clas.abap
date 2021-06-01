class ZCL_AGC_DATEX_UTILITY definition
  public
  create public .

public section.

  class-methods DETERMINE_BMID
    importing
      !IS_MSGDATA type EIDESWTMSGDATA
      !IS_EIDESWTDOC type EIDESWTDOC
      !IS_PROC_HDR type /IDXGC/PROC_HDR optional
      !IV_PROC_STEP_TYPE type /IDXGC/DE_PROC_STEP_TYPE optional
    returning
      value(RS_BMID) type ZAGC_DET_BMID .
  class-methods DETERMINE_PROC_STEP_NO
    importing
      !IV_PROC_STEP_TYPE type /IDXGC/DE_PROC_STEP_TYPE
      !IV_BMID type /IDXGC/DE_BMID
      !IV_PROC_VERSION type /IDXGC/DE_PROCESS_VERSION
      !IV_PROC_ID type /IDXGC/DE_PROC_ID
    returning
      value(RV_PROC_STEP_NO) type /IDXGC/DE_PROC_STEP_NO .
  class-methods DELETE_OBSOLETE_MSGDATA
    importing
      !IV_BMID type /IDXGC/DE_BMID
    changing
      !CS_MSGDATA type EIDESWTMSGDATA
      !CT_MSG_EXT type ZIDE_EXTMSGDATA_T .
  class-methods MAP_ISU_DATA_TO_PDOC
    importing
      !IS_PDOC_HDR type EIDESWTDOC optional
      !IS_PDOC_ADD type EIDESWTDOCADDDATA optional
      !IT_MSG_HDR type TEIDESWTMSGDATA optional
      !IT_MSG_ADD type TEIDESWTMSGADDDATA optional
      !IT_MSG_COMMENTS type TEIDESWTMSGDATACO optional
      !IT_MSG_EXT type ZIDE_EXTMSGDATA_T optional
    exporting
      !ES_PDOC_DATA type /IDXGC/S_PDOC_DATA .
  class CL_ISU_IDE_SWITCHDOC definition load .
  class-methods CREATE_PDOC_FROM_MSG
    importing
      !IS_SWITCHDOCDATA type EIDESWTDOC
      !IS_SWTDOC_ADDDATA type ANY
      !IS_MSGDATA type EIDESWTMSGDATA
      !IS_SWTMSG_ADDDATA type ANY
      !IT_TMSGDATACOMMENT type TEIDESWTMSGDATACO
      !IV_NO_EVENT type KENNZX default ' '
      !IV_NO_COMMIT type KENNZX default ' '
      !IV_DATA_INCOMPLETE type KENNZX default ' '
      !IV_CREATE_NEW type KENNZX default ' '
      !IV_RESPONSE type KENNZX default ' '
      !IV_FIND_CREATE_STATUS type EIDESWTSTAT default CL_ISU_IDE_SWITCHDOC=>CO_STAT_ACTIVE
      !IV_ACTIVITY_STATUS type EIDESWTSTAT default CL_ISU_IDE_SWITCHDOC=>CO_STAT_OK
      !IV_FILL_PARTNER_ADDRESS type KENNZX default 'X'
      !IV_DELAY_EVENT type KENNZX default ' '
      !IV_RECEIVER type SERVICEID
    exporting
      !ER_SWITCHDOC type ref to CL_ISU_SWITCHDOC
      !EV_SWITCHNUM type EIDESWTNUM
      !EV_NEW_DOCUMENT type KENNZX
      !EV_MSGDATANUM type EIDESWTMDNUM
      !EV_CREATETYPE type EIDEMSGCREATETYPE
    exceptions
      GENERAL_FAULT
      FOREIGN_LOCK
      POD_MISSING
      NOT_AUTHORIZED .
  class-methods ASSIGN_MESSAGE_TO_PROCESS
    importing
      !IR_MESSAGE_DATA type ref to /IDXGC/IF_PROCESS_DATA_EXTERN
    exporting
      !EV_PROC_REF type /IDXGC/DE_PROC_REF
      !ES_PROCESS_STEP_ID type /IDXGC/S_PROC_STEP_ID
      !ES_EXCEPTION_DATA type /IDXGC/S_EXCP_DATA
      !ER_PROCESS_DATA type ref to /IDXGC/IF_PROCESS_DATA_EXTERN
    raising
      /IDXGC/CX_IDE_ERROR .
  class-methods GET_VALID_PROCESS_STEP_INIT
    importing
      !IS_MESSAGE_DATA type /IDXGC/S_PROC_DATA
      !IT_PROCESS_CONFIG type /IDXGC/T_PROC_CONFIG_ALL
    changing
      !CS_EXCEPTION_DATA type /IDXGC/S_EXCP_DATA
      !CT_PROCESS_DATA_VALID type /IDXGC/T_PROC_DATA
      !CT_PROCESS_DATA_WITH_RESERVE type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
  class-methods GET_VALID_PROCESS_STEP_NONINIT
    importing
      !IS_MESSAGE_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IT_PROCESS_CONFIG type /IDXGC/T_PROC_CONFIG_ALL
    changing
      !CS_EXCEPTION_DATA type /IDXGC/S_EXCP_DATA
      !CT_PROCESS_DATA_VALID type /IDXGC/T_PROC_DATA
      !CT_PROCESS_DATA_WITH_RESERVE type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
  class-methods TRIGGER_EVENT_MSGPROCESSED
    importing
      !IS_PROC_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
      !IV_BMID type /IDXGC/DE_BMID
      !IS_PROC_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_PROCESS_ERROR .
  class-methods DETERMINE_PROC_ID
    importing
      !IV_SWITCHTYPE type EIDESWTDOC-SWITCHTYPE
      !IV_SWTVIEW type EIDESWTDOC-SWTVIEW
    returning
      value(RS_PROC) type /IDXGC/PROC
    exceptions
      /IDXGC/CL_PROCESS_DOCUMENT .
  class-methods DETERMINE_PROC_VERSION
    importing
      !IV_PROC_ID type /IDXGC/PROC-PROC_ID
      !IV_PROC_DATE type /IDXGC/DE_PROC_DATE default SY-DATUM
      !IV_SWITCHNUM type EIDESWTNUM
    returning
      value(RV_PROCVERS) type /IDXGC/PROCVERS-PROC_VERSION .
  class-methods MAP_PDOC_TO_ISU_DATA
    importing
      !IS_PDOC_DATA type /IDXGC/S_PDOC_DATA
    exporting
      !ES_PDOC_HDR type EIDESWTDOC
      !ES_PDOC_ADD type EIDESWTDOCADDDATA
      !ET_MSG_HDR type TEIDESWTMSGDATA
      !ET_MSG_ADD type TEIDESWTMSGADDDATA
      !ET_MSG_COMMENTS type TEIDESWTMSGDATACO
      !ET_MSG_EXT type ZIDE_EXTMSGDATA_T .
  class-methods SEARCH_MSGDATA_BY_PARAM
    importing
      !IT_CATEGORY type IISU_RANGES optional
      !IT_DIRECTION type IISU_RANGES optional
      !IT_TRANSREASON type IISU_RANGES optional
      !IT_MSGSTATUS type IISU_RANGES optional
      !IT_MOVEOUTDATE type IISU_RANGES optional
      !IT_EXT_UI type IISU_RANGES optional
    returning
      value(ET_EIDESWTMSGDATA) type TEIDESWTMSGDATA .
  class-methods GET_PROC_DATE
    importing
      !IV_AMID type /IDXGC/DE_AMID optional
      !IS_DIVERSE_DETAILS type /IDXGC/S_DIVERSE_DETAILS optional
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA optional
    returning
      value(RV_PROC_DATE) type /IDXGC/DE_PROC_DATE .
  class-methods GET_PROCESS_STEP_DATA_ALL
    importing
      !IV_BMID type /IDXGC/DE_BMID
      !IS_MSGDATA type EIDESWTMSGDATA
      !IS_MSGDATA_SRC type EIDESWTMSGDATA optional
      !IS_EIDESWTDOC type EIDESWTDOC optional
    exporting
      !ES_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL .
  class-methods GET_STEP_DATA_AFTER_ZPI
    importing
      !IS_PROC_HDR type /IDXGC/S_PROC_HDR
      !IV_SWITCHNUM_ZPI type EIDESWTNUM
    changing
      !CS_PROC_STEP type /IDXGC/S_PROC_STEP_DATA .
  class-methods CHECK_EVER_FROM_ONLINE_SERVICE
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type DATS default SY-DATUM
    returning
      value(RV_ONLINE_SERVICE) type KENNZX .
  class-methods TRIGGER_EVENT_PROCESSED
    importing
      !IS_PROC_STEP_KEY type /IDXGC/S_PROC_STEP_KEY
      !IV_BMID type /IDXGC/DE_BMID
      !IS_PROC_DATA type /IDXGC/S_PROC_DATA optional
    raising
      /IDXGC/CX_IDE_ERROR .
  class-methods CHECK_DUMMY_POD
    importing
      !IV_EXT_UI type EXT_UI
    returning
      value(RV_DUMMY_POD) type KENNZX .
  class-methods GET_PRECEDING_MSG_DATA
    importing
      !IV_TRANSACTION_NO type /IDXGC/DE_TRANSACTION_NO
      !IV_DIRECTION type E_DEXDIRECTION
      !IV_ASSOC_SERVPROV type E_DEXSERVPROV
    exporting
      !EV_PROC_REF type /IDXGC/DE_PROC_REF
      !ES_BMID_REL type /IDXGC/BMID_REL
      !ES_PROC_STEP_DATA_ORIG type /IDXGC/S_PROC_STEP_DATA
    raising
      /IDXGC/CX_IDE_ERROR .
  class-methods GET_PRECEDING_STEP_DATA
    importing
      !IV_TRANSACTION_NO type /IDXGC/DE_TRANSACTION_NO
      !IV_DIRECTION type E_DEXDIRECTION
      !IV_ASSOC_SERVPROV type E_DEXSERVPROV
      !IV_PROC_ID_ERROR_PDOC type /IDXGC/DE_PROC_ID
    exporting
      !ES_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA
    raising
      /IDXGC/CX_PROCESS_ERROR .
  class-methods MAP_MSCONS_IDOC_OLD_TO_IDXGC
    importing
      !IT_IDOC_DATA type EDIDD_TT
    returning
      value(RT_IDOC_DATA) type EDIDD_TT .
  class-methods MAP_MSCONS_IDOC_IDXGC_TO_OLD
    importing
      !IT_IDOC_DATA type EDIDD_TT
    returning
      value(RT_IDOC_DATA) type EDIDD_TT .
  type-pools ABAP .
  class-methods CHECK_CL_PROCESS_IS_ENABLED
    importing
      !IV_PROC_ID type /IDXGC/DE_PROC_ID optional
      !IV_PROC_REF type /IDXGC/DE_PROC_REF optional
    returning
      value(RV_ENABLED) type ABAP_BOOL .
  class-methods GET_PROC_ID_FROM_PROC_REF
    importing
      !IV_PROC_REF type /IDXGC/DE_PROC_REF
    returning
      value(RV_PROC_ID) type /IDXGC/DE_PROC_ID .
  class-methods CHECK_ASSO_SERVPROV
    importing
      !IV_SERVPROV type SERVICE_PROV
    returning
      value(RV_ASSO_SERVPROV) type ABAP_BOOL .
  class-methods GET_NAME_FORMAT_CODE
    importing
      !IV_PARTNER type BU_PARTNER
    returning
      value(RV_NAME_FORMAT) type CHAR3 .
  class-methods PARSE_NAME_DATA
    importing
      !IV_STRING type CHAR70
    exporting
      !EV_STRING_1 type CHAR40
      !EV_STRING_2 type CHAR40 .
  class-methods CHECK_PARTNER_NAME_LENGTH
    importing
      !IS_MSGDATA type EIDESWTMSGDATA
    returning
      value(RV_WI_KZ) type KENNZX
    exceptions
      ERROR_OCCURED .
  class-methods GET_PARTNER_NAME_ADDR_DATA
    importing
      !IV_BU_PARTNER type BU_PARTNER
      !IV_KEYDATE type DATUM
      !IV_FLAG_ADDR_MRCONTACT type FLAG optional
    returning
      value(RS_NAME_ADDRESS) type /IDXGC/S_NAMEADDR_DETAILS
    raising
      /IDXGC/CX_UTILITY_ERROR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_DATEX_UTILITY IMPLEMENTATION.


  METHOD assign_message_to_process.

    "Kopie von der Standard-Datenaustauschklasse /IDXGC/CL_DATEX_PROC_PDOC
    "Einige Stellen sind rausgenommen, da diese hier nicht relevant oder zu fehlern führen würden.

    DATA:
      lr_previous                  TYPE REF TO /idxgc/cx_general,
      lx_root                      TYPE REF TO cx_root,
      lt_process_config            TYPE        /idxgc/t_proc_config_all,
      lt_process_config_init       TYPE        /idxgc/t_proc_config_all,
      lt_process_config_non_init   TYPE        /idxgc/t_proc_config_all,
      lt_proc_config_step_init     TYPE        /idxgc/t_proc_step_config_all,
      lt_proc_config_step_non_init TYPE        /idxgc/t_proc_step_config_all,
      lt_process_data_valid        TYPE        /idxgc/t_proc_data,
      lt_process_data_with_reserve TYPE        /idxgc/t_proc_data,

      ls_process_config            TYPE        /idxgc/s_proc_config_all,
      ls_message_step_data         TYPE        /idxgc/s_proc_step_data_all,
      ls_process_data_valid        TYPE        /idxgc/s_proc_data,
      ls_process_key_nonunique     TYPE        /idxgc/s_proc_key_all,

      lv_tlines                    TYPE        i.

    DATA: lr_badi_message TYPE REF TO /idxgc/message_processing.

    FIELD-SYMBOLS:
      <fs_message_step>        TYPE /idxgc/s_proc_step_data,
      <fs_process_config>      TYPE /idxgc/s_proc_config_all,
      <fs_process_step_config> TYPE /idxgc/s_proc_step_config_all.

    CLEAR: ev_proc_ref,
           es_process_step_id,
           es_exception_data.

    ls_message_step_data-proc = ir_message_data->gs_process_data-hdr.

* We do not need the loop over multiple steps (as we split the IDoc before mapping)
    READ TABLE ir_message_data->gs_process_data-steps ASSIGNING <fs_message_step> INDEX 1.

    ls_message_step_data-step = <fs_message_step>-step2.

    TRY.
        CALL METHOD /idxgc/cl_process_config=>/idxgc/if_process_config~get_process_for_bmid
          EXPORTING
            iv_bmid           = ls_message_step_data-bmid
            iv_process_date   = <fs_message_step>-msg_date
          IMPORTING
            et_process_config = lt_process_config.

      CATCH /idxgc/cx_general INTO lr_previous.

    ENDTRY.

* 2) Split out "Initial steps". As if only non-Initial then no need to
*    read process documents.
    LOOP AT lt_process_config ASSIGNING <fs_process_config>.
      REFRESH:
        lt_proc_config_step_init,
        lt_proc_config_step_non_init.

      CLEAR ls_process_config.

      ls_process_config-proc_config = <fs_process_config>-proc_config.

      LOOP AT <fs_process_config>-steps ASSIGNING <fs_process_step_config>.
*     If same message can occur twice in same process, then table will have
*     more than 1 entry. Should then be processed in both
        IF <fs_process_step_config>-category = /idxgc/if_constants=>gc_proc_step_cat_init.

          INSERT <fs_process_step_config> INTO TABLE lt_proc_config_step_init.

        ELSE.

          INSERT <fs_process_step_config> INTO TABLE lt_proc_config_step_non_init.

          IF <fs_process_step_config>-type = 'OTBND'. " Ausgehender Fluss
            INSERT <fs_process_step_config> INTO TABLE lt_proc_config_step_init.
          ENDIF.

        ENDIF.
      ENDLOOP.

      IF NOT lt_proc_config_step_init IS INITIAL.
        ls_process_config-steps = lt_proc_config_step_init.
        INSERT ls_process_config INTO TABLE lt_process_config_init.
      ENDIF.

      IF NOT lt_proc_config_step_non_init IS INITIAL.
        ls_process_config-steps = lt_proc_config_step_non_init.
        INSERT ls_process_config INTO TABLE lt_process_config_non_init.
      ENDIF.
    ENDLOOP.


* 3) If non-initial steps are possible, determine all potential process document(s)
    IF NOT lt_process_config_non_init IS INITIAL.
      CALL METHOD get_valid_process_step_noninit
        EXPORTING
          is_message_step_data         = ls_message_step_data
          it_process_config            = lt_process_config_non_init
        CHANGING
          cs_exception_data            = es_exception_data
          ct_process_data_valid        = lt_process_data_valid
          ct_process_data_with_reserve = lt_process_data_with_reserve.
    ENDIF.


* 4) For all processes with initial steps, determine if the process
*    can be started with this message
    IF NOT lt_process_config_init IS INITIAL AND
           ls_message_step_data-proc_ref IS INITIAL AND
           lt_process_data_valid IS INITIAL.
      CALL METHOD get_valid_process_step_init
        EXPORTING
          is_message_data              = ir_message_data->gs_process_data
          it_process_config            = lt_process_config_init
        CHANGING
          cs_exception_data            = es_exception_data
          ct_process_data_valid        = lt_process_data_valid
          ct_process_data_with_reserve = lt_process_data_with_reserve.
    ENDIF.



* 3.  If no possible process documents OR more than one possible process
*    document determined, then call BAdI where the decision should be
*    made to which process the message will be assigned.
    DESCRIBE TABLE lt_process_data_valid LINES lv_tlines.

    IF NOT lr_badi_message IS BOUND.
*   Get instance of (message specific) BAdI
      TRY.
          GET BADI lr_badi_message
            FILTERS
              iv_dexbasicproc = 'I_UTILREQ'.

        CATCH cx_badi_not_implemented
              cx_badi_multiply_implemented INTO lx_root.
      ENDTRY.
    ENDIF.

*KL: for some special cases, even unique message is determined via above logic, we still need to find
*if any other Pdoc exists and attach current message to that Pdoc...
    IF lr_badi_message IS BOUND.
      CALL BADI lr_badi_message->det_unique_process_for_msg
        EXPORTING
          it_process_data_with_reserve = lt_process_data_with_reserve
          is_message_data              = ir_message_data->gs_process_data
          iv_dexproc                   = 'ISUREQNBLF'
        CHANGING
          cs_exception_data            = es_exception_data
          ct_process_data_valid        = lt_process_data_valid.
    ELSE.
      IF lv_tlines = 0 OR
        lv_tlines > 1.
      ENDIF.
    ENDIF.

* 5. Write results
    DESCRIBE TABLE  lt_process_data_valid LINES lv_tlines.
    CASE lv_tlines.
*      remove this logic, since it will be hanlde in the Badi implementation.
*------------------------------------------------------------------------------*
*    WHEN 0.
*     No valid process document could be found and message should not start
*     a process. Thus generate exception
*      MESSAGE e002(/IDXGC/ide) INTO gv_mtext.
*      CALL METHOD /IDXGC/cx_ide_error=>raise_ide_exception_from_msg( ).
*------------------------------------------------------------------------------*

      WHEN 1.
*     Fill result parameters. Process data.
        READ TABLE lt_process_data_valid INTO ls_process_data_valid INDEX 1.

        IF sy-subrc = 0.
          TRY.
              CREATE OBJECT er_process_data
                TYPE
                /idxgc/cl_process_data
                EXPORTING
                  is_process_data = ls_process_data_valid.

            CATCH /idxgc/cx_general INTO lr_previous.
          ENDTRY.

          ev_proc_ref                = ls_process_data_valid-proc_ref.
          es_process_step_id-proc_id = ls_process_data_valid-proc_id.
        ENDIF.

      WHEN OTHERS.
*      remove this logic, since it will be hanlde in the Badi implementation.
*------------------------------------------------------------------------------*
*      MESSAGE e003(/IDXGC/ide) INTO gv_mtext.
*      CALL METHOD /IDXGC/cx_ide_error=>raise_ide_exception_from_msg( ).
*------------------------------------------------------------------------------*

*    when it cannot determine a unique valid process, then it will call
*    a Badi implementation
*    The badi has been get from the previous step that determine the unique process
*    by using badi
*------------------------------------------------------------------------------*
        IF lr_badi_message IS BOUND.
          CALL BADI lr_badi_message->handle_nonunique_process
            EXPORTING
              it_proc_data       = lt_process_data_valid
              it_process_config  = lt_process_config
              is_message_data    = ir_message_data->gs_process_data
            CHANGING
              cs_exception_data  = es_exception_data
              cs_process_key_all = ls_process_key_nonunique
              cr_process_data    = er_process_data.

          ev_proc_ref                     = ls_process_key_nonunique-proc_ref.
          es_process_step_id-proc_id      = ls_process_key_nonunique-proc_id.

        ENDIF.
    ENDCASE.

    IF <fs_process_step_config> IS ASSIGNED.
      IF NOT <fs_process_step_config> IS INITIAL AND es_process_step_id IS INITIAL.
        es_process_step_id-proc_id      = <fs_process_step_config>-proc_id.
        es_process_step_id-proc_version = <fs_process_step_config>-proc_version.
        es_process_step_id-proc_step_no = <fs_process_step_config>-proc_step_no.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_asso_servprov.

    CASE sy-mandt.
      WHEN zif_agc_datex_co=>gc_mandt_110.
        IF iv_servprov = zif_agc_datex_co=>gc_service_id_n100001 OR
           iv_servprov = zif_agc_datex_co=>gc_service_id_n200001 OR
           iv_servprov = zif_agc_datex_co=>gc_service_id_n300001 OR
           iv_servprov = zif_agc_datex_co=>gc_service_id_n800001 OR
           iv_servprov = zif_agc_datex_co=>gc_service_id_n900001.
          rv_asso_servprov = abap_true.
        ENDIF.
      WHEN zif_agc_datex_co=>gc_mandt_210.
        IF iv_servprov = zif_agc_datex_co=>gc_service_id_l100014 OR
           iv_servprov = zif_agc_datex_co=>gc_service_id_l200001 OR
           iv_servprov = zif_agc_datex_co=>gc_service_id_l300001 OR
           iv_servprov = zif_agc_datex_co=>gc_service_id_l800001 OR
           iv_servprov = zif_agc_datex_co=>gc_service_id_l900001.
          rv_asso_servprov = abap_true.
        ENDIF.
      WHEN OTHERS.
        CLEAR rv_asso_servprov.
    ENDCASE.

  ENDMETHOD.


  METHOD check_cl_process_is_enabled.
    DATA: lt_act_proc_id TYPE TABLE OF zagc_act_proc_id.

    IF iv_proc_id IS SUPPLIED.
      SELECT * FROM zagc_act_proc_id INTO TABLE lt_act_proc_id WHERE proc_id = iv_proc_id.
      IF sy-subrc = 0.
        rv_enabled = abap_true.
      ENDIF.
    ELSEIF iv_proc_ref IS SUPPLIED.
      rv_enabled = check_cl_process_is_enabled( iv_proc_id = zcl_agc_datex_utility=>get_proc_id_from_proc_ref( iv_proc_ref = iv_proc_ref ) ).
    ENDIF.

  ENDMETHOD.


  METHOD check_dummy_pod.

    CALL FUNCTION 'Z_LW_CHECK_KOMM_EXT_UI'
      EXPORTING
        x_ext_ui = iv_ext_ui
      EXCEPTIONS
        no_komm  = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
      MOVE abap_true TO rv_dummy_pod.
    ENDIF.

  ENDMETHOD.


  METHOD check_ever_from_online_service.

    DATA: lv_anlage TYPE anlage,
          ls_ever   TYPE ever.

    TRY.
        lv_anlage = zcl_agc_masterdata=>get_anlage( iv_int_ui = iv_int_ui iv_keydate = iv_keydate ).
        ls_ever = zcl_agc_masterdata=>get_ever( iv_anlage = lv_anlage iv_keydate = iv_keydate ).

        IF ls_ever-zos_order_guid IS NOT INITIAL AND ls_ever-loevm = abap_false.
          rv_online_service = abap_true.
        ENDIF.
      CATCH zcx_agc_masterdata.
    ENDTRY.

  ENDMETHOD.


  METHOD check_partner_name_length.
*--------------------------------------------------------------------*
* Methode zur Prüfung der Länge von Namensfeldern in UTILMD-Nachricht
* nach Vorgabe aus dem Konzept "ITBM - Datenhaltung Geschäftspartner -
* 20160216 (01) OH (003)". Bei Überschreitung bestimmter Länge soll
* im Worfklow ein WI erzeugt werden.
*--------------------------------------------------------------------*
* 001   WOLF.A    01.03.2016    neu angelegt
*--------------------------------------------------------------------*

    DATA: lr_ctx           TYPE REF TO /idxgc/cl_pd_doc_context,
          lrx_error        TYPE REF TO /idxgc/cx_process_error,
          ls_step_key      TYPE        /idxgc/s_proc_step_key,
          ls_step_data_all TYPE        /idxgc/s_proc_step_data_all,
          lv_name_1        TYPE        char40,
          lv_name_2        TYPE        char40,
          lv_name_3        TYPE        char120,
          lv_name_4        TYPE        char120.

    FIELD-SYMBOLS: <fs_name_address> TYPE /idxgc/s_nameaddr_details.

    TRY.
        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = is_msgdata-switchnum ).

        ls_step_key-proc_ref      = is_msgdata-switchnum.
        ls_step_key-proc_step_ref = is_msgdata-msgdatanum.
        ls_step_data_all = lr_ctx->gr_process_data_extern->get_process_step_data( is_process_step_key = ls_step_key ).

        LOOP AT ls_step_data_all-name_address ASSIGNING <fs_name_address>.
          CASE <fs_name_address>-party_func_qual.
            WHEN /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
              "Person
              IF <fs_name_address>-name_format_code = zif_agc_datex_co=>gc_nad_name_format_z01.

                IF strlen( <fs_name_address>-first_name )     > 40 OR
                   strlen( <fs_name_address>-fam_comp_name1 ) > 40.
                  rv_wi_kz = abap_true.
                ENDIF.
              "Organisation
              ELSEIF <fs_name_address>-name_format_code = zif_agc_datex_co=>gc_nad_name_format_z02.

                zcl_agc_datex_utility=>parse_name_data( EXPORTING iv_string  = <fs_name_address>-fam_comp_name1
                                                        IMPORTING ev_string_1 = lv_name_1
                                                                  ev_string_2 = lv_name_2 ).

                CONCATENATE lv_name_2 <fs_name_address>-fam_comp_name2 INTO lv_name_3 SEPARATED BY space.

                CLEAR: lv_name_1, lv_name_2.

                zcl_agc_datex_utility=>parse_name_data( EXPORTING iv_string   = <fs_name_address>-name_add1
                                                        IMPORTING ev_string_1 = lv_name_1
                                                                  ev_string_2 = lv_name_2 ).

                CONCATENATE lv_name_2 <fs_name_address>-name_add2 INTO lv_name_4 SEPARATED BY space.

                IF strlen( lv_name_3 ) > 40 OR
                   strlen( lv_name_4 ) > 40.
                  rv_wi_kz = abap_true.
                ENDIF.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.

      CATCH /idxgc/cx_process_error INTO lrx_error.
        "WI erzeugen zwecks Überprüfung des Falls
        rv_wi_kz = abap_true.
    ENDTRY.
  ENDMETHOD.


  METHOD create_pdoc_from_msg.

    DATA: lv_proc_ref        TYPE        eideswtnum,

          lt_msgdata         TYPE        teideswtmsgdata,
          lt_msg_ext         TYPE        zide_extmsgdata_t,

          ls_pdoc_data       TYPE        /idxgc/s_pdoc_data,
          ls_proc_data       TYPE        /idxgc/s_proc_data,
          ls_proc_key        TYPE        /idxgc/s_proc_key,
          ls_process_step_id TYPE        /idxgc/s_proc_step_id,
          ls_process_key_all TYPE        /idxgc/s_proc_key_all,
          ls_proc_step_key   TYPE        /idxgc/s_proc_step_key,
          ls_eideswtdoc      TYPE        eideswtdoc,
          ls_steps           TYPE        /idxgc/s_proc_step_data,
          ls_bmid            TYPE        zagc_det_bmid,
          ls_proc            TYPE        /idxgc/proc,

          lr_process_data    TYPE REF TO /idxgc/if_process_data_extern,
          lr_proc_upd_data   TYPE REF TO /idxgc/if_process_data_extern,
          lr_proc_doc        TYPE REF TO /idxgc/if_process_document,
          lr_previous        TYPE REF TO /idxgc/cx_general,
          lr_badi_switchdoc2 TYPE REF TO isu_ide_switchdoc2.

    FIELD-SYMBOLS: <fs_proc_step_data> TYPE /idxgc/s_msg_data_all,
                   <fs_steps>          TYPE /idxgc/s_proc_step_data.

    "PDoc Daten erstellen
    APPEND is_msgdata TO lt_msgdata.

    IF is_msgdata-zz_guid_ext IS NOT INITIAL.
      SELECT * FROM zlw_extmsgdata INTO TABLE lt_msg_ext WHERE guiid = is_msgdata-zz_guid_ext.
    ENDIF.

    CALL METHOD zcl_agc_datex_utility=>map_isu_data_to_pdoc
      EXPORTING
        is_pdoc_hdr     = is_switchdocdata
        it_msg_hdr      = lt_msgdata
        it_msg_comments = it_tmsgdatacomment
        it_msg_ext      = lt_msg_ext
      IMPORTING
        es_pdoc_data    = ls_pdoc_data.

    READ TABLE ls_pdoc_data-msg_data ASSIGNING <fs_proc_step_data> INDEX 1.

    "Proc-ID ermitteln
    ls_proc = zcl_agc_datex_utility=>determine_proc_id( iv_switchtype = is_switchdocdata-switchtype iv_swtview = is_switchdocdata-swtview ).
    ls_pdoc_data-proc_id = ls_proc-proc_id.
    ls_proc_key-proc_id = ls_proc-proc_id.

    "Prozessversion ermitteln
    ls_pdoc_data-proc_version = zcl_agc_datex_utility=>determine_proc_version( iv_proc_id = ls_proc-proc_id iv_proc_date = sy-datum iv_switchnum = is_switchdocdata-switchnum ).

    "BMID ermitteln
    ls_bmid = zcl_agc_datex_utility=>determine_bmid( is_msgdata = is_msgdata is_eideswtdoc = is_switchdocdata iv_proc_step_type = /idxgc/if_constants_add=>gc_proc_step_typ_first ).
    IF <fs_proc_step_data> IS ASSIGNED.
      <fs_proc_step_data>-bmid = ls_bmid-bmid.

      "Prozessschritt ermitteln
      <fs_proc_step_data>-proc_step_no = zcl_agc_datex_utility=>determine_proc_step_no( iv_proc_step_type = /idxgc/if_constants_add=>gc_proc_step_typ_first
                                                                                        iv_bmid           = ls_bmid-bmid
                                                                                        iv_proc_version   = ls_pdoc_data-proc_version
                                                                                        iv_proc_id        = ls_pdoc_data-proc_id ).

    ENDIF.

    "Prozessdaten erstellen
    CALL METHOD /idxgc/cl_process_document=>/idxgc/if_process_document~map_pdoc_to_process_data
      EXPORTING
        is_pdoc_data = ls_pdoc_data
      IMPORTING
        es_proc_data = ls_proc_data.

    READ TABLE ls_proc_data-steps ASSIGNING <fs_steps> INDEX 1.

    TRY.
        "Sparte ermitteln falls nicht gefüllt
        IF ls_proc_data-spartyp IS INITIAL.
          IF ls_proc_data-int_ui IS NOT INITIAL.
            ls_proc_data-spartyp = zcl_agc_masterdata=>get_sparte( iv_int_ui = ls_proc_data-int_ui ).
          ELSE.
            ls_proc_data-spartyp = zcl_agc_masterdata=>get_sparte( iv_serviceid = <fs_steps>-own_servprov ).
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
    ENDTRY.

    TRY.
        "Partner füllen falls nicht gefüllt
        IF ls_proc_data-bu_partner IS INITIAL.
          IF <fs_steps>-ext_ui IS NOT INITIAL.
            ls_proc_data-bu_partner = zcl_agc_masterdata=>get_partner( iv_ext_ui = <fs_steps>-ext_ui ).
          ENDIF.
        ENDIF.
      CATCH zcx_agc_masterdata.
    ENDTRY.

    "Bei ORDERS zusätzliche Daten eintragen für spätere Identifikation (THIMEL.R, 20150825)
    IF <fs_steps>-bmid = /idxgc/if_constants_ide=>gc_bmid_cd011 AND <fs_steps>-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z14.
      <fs_steps>-direct = /idxgc/cl_parsing=>co_idoc_direction_outbound.
      <fs_steps>-mestyp = /idxgc/if_constants_ide=>gc_msgtp_orders.
    ENDIF.

    "Erweiterung für Wechselbeleg nach ZPI
    IF <fs_steps>-proc_ref IS NOT INITIAL. "Prozessreferenz schon bekannt -> Dies bedeutet, dass der Wechselbeleg aus einem anderem Wechselbeleg erzeugt wird (Bsp.: ZPI).
      CALL METHOD zcl_agc_datex_utility=>get_step_data_after_zpi
        EXPORTING
          is_proc_hdr      = ls_proc_data-hdr
          iv_switchnum_zpi = <fs_steps>-proc_ref
        CHANGING
          cs_proc_step     = <fs_steps>.

    ELSE. "kundeneigene Suche nach bestehenden Prozessdokumenten. Andere Möglichkeit wäre die Methode ASSIGN_MESSAGE_TO_PROCESS auszurufen. Aktuell erstmal eigene Lösung für MSCONS Z99
      IF is_msgdata-category = 'Z99' AND
        ( is_switchdocdata-switchtype = '03' OR is_switchdocdata-switchtype = '04' OR is_switchdocdata-switchtype = '86' OR is_switchdocdata-switchtype = '98' ) AND
        zcl_agc_masterdata=>is_netz( ) = abap_false.
        TRY.
            GET BADI lr_badi_switchdoc2.
          CATCH cx_badi_not_implemented.
        ENDTRY.

        IF lr_badi_switchdoc2 IS BOUND.
          CALL BADI lr_badi_switchdoc2->find_switchdoc
            EXPORTING
              x_switchdocdata   = is_switchdocdata
              x_category        = is_msgdata-category
              x_msgdata         = is_msgdata
              x_tmsgdatacomment = it_tmsgdatacomment
              x_swtdoc_adddata  = is_swtdoc_adddata
              x_swtmsg_adddata  = is_swtmsg_adddata
            RECEIVING
              y_eideswtdoc      = ls_eideswtdoc
            EXCEPTIONS
              foreign_lock      = 1
              general_fault     = 2
              not_found         = 3
              not_unique        = 4
              parameter_error   = 3
              OTHERS            = 6.
        ENDIF.

        ls_proc_key-proc_ref = ls_eideswtdoc-switchnum.

        TRY.
            CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_pdoc
              EXPORTING
                iv_process_ref = ls_proc_key-proc_ref
              IMPORTING
                es_proc_data   = ls_proc_data.
          CATCH /idxgc/cx_process_error .
        ENDTRY.
        CLEAR ls_eideswtdoc.
      ENDIF.
    ENDIF.

* Erzeugen eines Prozessdokuments oder falls ein bestehende gefunden wird anhängen an PDoc
    TRY.

        CREATE OBJECT lr_process_data TYPE /idxgc/cl_process_data
          EXPORTING
            is_process_data = ls_proc_data.

        IF ls_proc_key-proc_ref IS INITIAL.

          CALL METHOD /idxgc/cl_process_document=>/idxgc/if_process_document~create_pdoc
            EXPORTING
              iv_no_event         = space
            IMPORTING
              es_process_key_all  = ls_process_key_all
              er_process_document = lr_proc_doc                   " Close/Dequeue in process engine should be done here
            CHANGING
              cr_process_data     = lr_process_data.

          ev_new_document = cl_isu_flag=>co_true.
        ELSE.
          CALL METHOD /idxgc/cl_process_document=>/idxgc/if_process_document~get_instance
            EXPORTING
              is_process_key      = ls_proc_key
              iv_message_data     = /idxgc/if_constants=>gc_true
              iv_skip_buffer      = abap_true
            RECEIVING
              rr_process_document = lr_proc_doc.

          CALL METHOD lr_proc_doc->update_pdoc
            EXPORTING
              ir_process_data    = lr_process_data
            IMPORTING
              es_process_key_all = ls_process_key_all.

          READ TABLE ls_process_key_all-steps
            INTO ls_proc_step_key INDEX 1.

          CALL METHOD lr_proc_doc->get_process_data
            RECEIVING
              rr_process_data = lr_proc_upd_data.

          TRY.
              CALL METHOD trigger_event_processed
                EXPORTING
                  is_proc_step_key = ls_proc_step_key
                  iv_bmid          = ls_bmid-bmid
                  is_proc_data     = lr_proc_upd_data->gs_process_data.
            CATCH /idxgc/cx_ide_error.
          ENDTRY.
        ENDIF.

      CATCH /idxgc/cx_general INTO lr_previous.
        IF lr_proc_doc IS BOUND.
          lr_proc_doc->close( ).
        ENDIF.
    ENDTRY.

    "Prozessdaten holen
    CALL METHOD lr_process_data->get_process_data
      EXPORTING
        iv_obsolete_steps = /idxgc/if_constants=>gc_false
      IMPORTING
        es_process_data   = ls_proc_data.

    READ TABLE ls_process_key_all-steps INTO ls_proc_step_key INDEX 1.

    ev_switchnum = ls_proc_data-proc_ref.
    ev_msgdatanum = ls_proc_step_key-proc_step_ref.

    IF lr_proc_doc IS BOUND.
      lr_proc_doc->close( ).
    ENDIF.

    IF er_switchdoc IS REQUESTED.
      "Erzeuge die Wechselbeleginstanz zur Rückgabe an die ursprüngliche Methode
      ls_eideswtdoc-switchnum = ev_switchnum.
      CALL METHOD cl_isu_switchdoc=>select_new
        EXPORTING
          x_switchdocdata       = ls_eideswtdoc
          x_wmode               = cl_isu_wmode=>co_change
          x_fastmode            = cl_isu_flag=>co_true
          x_call_find_switchdoc = cl_isu_flag=>co_false
        RECEIVING
          y_switchdoc           = er_switchdoc
        EXCEPTIONS
          not_found             = 1
          parameter_error       = 2
          not_unique            = 3
          general_fault         = 4
          foreign_lock          = 5
          not_authorized        = 6
          OTHERS                = 7.
      CASE sy-subrc.
        WHEN 0.
        WHEN 5.
          WAIT UP TO 1 SECONDS.
          CALL METHOD cl_isu_switchdoc=>select_new
            EXPORTING
              x_switchdocdata       = ls_eideswtdoc
              x_wmode               = cl_isu_wmode=>co_change
              x_fastmode            = cl_isu_flag=>co_true
              x_call_find_switchdoc = cl_isu_flag=>co_false
            RECEIVING
              y_switchdoc           = er_switchdoc
            EXCEPTIONS
              not_found             = 1
              parameter_error       = 2
              not_unique            = 3
              general_fault         = 4
              foreign_lock          = 5
              not_authorized        = 6
              OTHERS                = 7.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    RAISING general_fault.
          ENDIF.
        WHEN OTHERS.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  RAISING general_fault.
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD delete_obsolete_msgdata.
    DATA: lr_typedescr      TYPE REF TO cl_abap_typedescr,
          lr_structdescr    TYPE REF TO cl_abap_structdescr,
          ls_eideswtdoc     TYPE        eideswtdoc,
          lv_eideswtstatust TYPE        eideswtmstatust.

    FIELD-SYMBOLS: <fs_components> TYPE abap_compdescr,
                   <fs_msg_field>  TYPE any.

    IF iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd01 AND
       iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd02 AND
       iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd03 AND
       iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd11 AND
       iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd12 AND
       iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd13 AND
       iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd21 AND
       iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd22 AND
       iv_bmid <> zif_agc_datex_utilmd_co=>gc_bmid_zmd23.

      CLEAR ct_msg_ext.

      CALL METHOD cl_abap_tabledescr=>describe_by_name
        EXPORTING
          p_name         = 'EIDESWTMSGDATA'
        RECEIVING
          p_descr_ref    = lr_typedescr
        EXCEPTIONS
          type_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
      ENDIF.

      lr_structdescr ?= lr_typedescr.

* Entscheidung Zustimmung oder Ablehnung
      SELECT SINGLE * FROM eideswtmstatust
        INTO lv_eideswtstatust
       WHERE status = cs_msgdata-msgstatus
         AND spras = 'D'.

      IF lv_eideswtstatust-statustxt(4) = 'Able'.
        LOOP AT lr_structdescr->components ASSIGNING <fs_components>.
          ASSIGN COMPONENT <fs_components>-name OF STRUCTURE cs_msgdata TO <fs_msg_field>.
          IF <fs_components>-name <> 'TRANSREASON' AND
             <fs_components>-name <> 'MSGSTATUS' AND
             <fs_components>-name <> 'ZZ_DROPMSGSTATUS' AND
             <fs_components>-name <> 'ZZ_MOVEINPROC' AND
             <fs_components>-name <> 'ZZ_POSSEND' AND
             <fs_components>-name <> 'ZZ_NEXTPROCDATE' AND
             <fs_components>-name <> 'ZZ_CHANGEDATE' AND
             <fs_components>-name <> 'COMSUPPLIER' AND
             <fs_components>-name <> 'SWITCHNUM' AND
             <fs_components>-name <> 'MSGDATANUM' AND
             <fs_components>-name <> 'MSGDATE' AND
             <fs_components>-name <> 'MSGTIME' AND
             <fs_components>-name <> 'CATEGORY' AND
             <fs_components>-name <> 'DEXTASKID' AND
             <fs_components>-name <> 'DIRECTION' AND
             <fs_components>-name <> 'COMPARTNER'.
            CLEAR <fs_msg_field>.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT lr_structdescr->components ASSIGNING <fs_components>.
          ASSIGN COMPONENT <fs_components>-name OF STRUCTURE cs_msgdata TO <fs_msg_field>.
          IF <fs_components>-name <> 'MOVEINDATE' AND
             <fs_components>-name <> 'MOVEOUTDATE' AND
             <fs_components>-name <> 'ZZ_NEXTPROCDATE' AND
             <fs_components>-name <> 'ZZ_MOVEINPROC' AND
             <fs_components>-name <> 'ZZ_POSSEND' AND
             <fs_components>-name <> 'TRANSREASON' AND
             <fs_components>-name <> 'ZZ_TRANSREASON' AND
             <fs_components>-name <> 'MSGSTATUS' AND
             <fs_components>-name <> 'ZZ_DROPMSGSTATUS' AND
             <fs_components>-name <> 'COMSUPPLIER' AND
             <fs_components>-name <> 'SWITCHNUM' AND
             <fs_components>-name <> 'MSGDATANUM' AND
             <fs_components>-name <> 'MSGDATE' AND
             <fs_components>-name <> 'MSGTIME' AND
             <fs_components>-name <> 'CATEGORY' AND
             <fs_components>-name <> 'DEXTASKID' AND
             <fs_components>-name <> 'DIRECTION' AND
             <fs_components>-name <> 'COMPARTNER'.
            CLEAR <fs_msg_field>.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    "Einzelfallbehandlung für Nachrichten
    CASE iv_bmid.
      WHEN /idxgc/if_constants_ide=>gc_bmid_es200. "Informationsmeldung über existierende Zuordnung wird im Workflow auf Basis der ursprünglichen Anmeldung erzeugt.
        IF cs_msgdata-moveindate IS NOT INITIAL.
          CLEAR cs_msgdata-moveindate.
        ENDIF.
        IF cs_msgdata-moveoutdate IS NOT INITIAL.
          CLEAR cs_msgdata-moveoutdate.
        ENDIF.
      WHEN /idxgc/if_constants_ide=>gc_bmid_es301. "Abmeldeanfrage (THIMEL.R 20150311 Mantis 4742)
        "Bei befristeter Anmeldung MOVEOUTDATE löschen. Wird später neu berechnet.
        SELECT SINGLE * FROM eideswtdoc INTO ls_eideswtdoc WHERE switchnum = cs_msgdata-switchnum.
        IF ls_eideswtdoc-moveoutdate IS NOT INITIAL. " = befristete Anmeldung
          CLEAR cs_msgdata-moveoutdate.
        ENDIF.
      WHEN /idxgc/if_constants_ide=>gc_bmid_ee101. "Abmeldung NN (WOLF.A 20150317 Mantis 4723, 4780)
        CLEAR cs_msgdata-zz_possend.
        IF cs_msgdata-transreason = /idxgc/if_constants_ide=>gc_trans_reason_code_z33.  "Auszug Stilllegung (WOLF.A 20150324 Mantis 4675)
          CLEAR cs_msgdata-moveindate.
        ENDIF.
      WHEN /idxgc/if_constants_ide=>gc_bmid_es103. "Bestätigung der Anmeldung nur mit DTM+93 versenden wenn es eine befristete Anmeldung war
        IF cs_msgdata-zz_transreason IS INITIAL.
          CLEAR cs_msgdata-moveoutdate.
        ENDIF.
      WHEN /idxgc/if_constants_ide=>gc_bmid_er901 OR "Stornierungsmeldung (WOLF.A 20150323 Mantis 4805).
           /idxgc/if_constants_ide=>gc_bmid_er902 OR
           /idxgc/if_constants_ide=>gc_bmid_er903.
        IF cs_msgdata-moveindate IS NOT INITIAL.
          CLEAR cs_msgdata-moveindate.
        ENDIF.
        IF cs_msgdata-moveoutdate IS NOT INITIAL.
          CLEAR cs_msgdata-moveoutdate.
        ENDIF.
      WHEN zif_agc_datex_utilmd_co=>gc_bmid_zmd22 OR "Anwort auf Änderungsmeldung zur Zuordnungsliste
           zif_agc_datex_utilmd_co=>gc_bmid_zmd23.
        CLEAR cs_msgdata-zz_changedate. "Kein DTM+157 (M4912)
      WHEN zif_agc_datex_utilmd_co=>gc_bmid_ze101 OR
           zif_agc_datex_utilmd_co=>gc_bmid_ze102 OR
           zif_agc_datex_utilmd_co=>gc_bmid_ze103. "Stilllegung
        CLEAR cs_msgdata-moveindate.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD determine_bmid.

    DATA: lv_is_answer  TYPE abap_bool,
          lv_is_confirm TYPE abap_bool,
          lv_direction  TYPE e_dexdirection,
          ls_msgdata    TYPE eideswtmsgdata.

    ls_msgdata = is_msgdata.

    IF iv_proc_step_type = /idxgc/if_constants_add=>gc_proc_step_typ_first
    AND ls_msgdata-dextaskid IS INITIAL.
*     Erste Nachricht entspricht einer zu versendenden Nachricht
      lv_direction = if_isu_ide_switch_constants=>co_swtmsg_direction_out.
    ELSE.
      lv_direction = ls_msgdata-direction.
    ENDIF.

    IF ls_msgdata-msgstatus IS NOT INITIAL.
      MOVE abap_true TO lv_is_answer.
    ENDIF.

    IF ls_msgdata-msgstatus = /idxgc/if_constants_ide=>gc_respstatus_e15 OR
       ls_msgdata-msgstatus = /idxgc/if_constants_ide=>gc_respstatus_z01 OR
       ls_msgdata-msgstatus = /idxgc/if_constants_ide=>gc_respstatus_z43 OR
       ls_msgdata-msgstatus = /idxgc/if_constants_ide=>gc_respstatus_z44.

      MOVE abap_true TO lv_is_confirm.

    ENDIF.

    IF ls_msgdata-category  = /idxgc/if_constants_ide=>gc_msg_category_z14 AND
       lv_direction = /idxgc/if_constants_add=>gc_idoc_direction_outbound  AND
       is_eideswtdoc-swtview = /IDEXGG/CL_ISU_CO=>co_swtview_01.
      MOVE abap_true TO lv_is_answer.
      MOVE abap_true TO lv_is_confirm.
    ENDIF.

    SELECT SINGLE * FROM zagc_det_bmid INTO rs_bmid
      WHERE category = ls_msgdata-category AND
            transreason = ls_msgdata-transreason AND
            is_answer = lv_is_answer AND
            is_confirm = lv_is_confirm AND
            ( direction = lv_direction OR
              direction = space ).
    IF sy-subrc <> 0.
      SELECT SINGLE * FROM zagc_det_bmid INTO rs_bmid
        WHERE category = space AND
              transreason = ls_msgdata-transreason AND
              is_answer = lv_is_answer AND
              is_confirm = lv_is_confirm AND
            ( direction = lv_direction OR
              direction = space ).
      IF sy-subrc <> 0.
        SELECT SINGLE * FROM zagc_det_bmid INTO rs_bmid
          WHERE category = ls_msgdata-category AND
                transreason = space AND
                is_answer = lv_is_answer AND
                is_confirm = lv_is_confirm AND
              ( direction = lv_direction OR
                direction = space ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD determine_proc_id.

    DATA ls_proc TYPE /idxgc/proc.

    CLEAR ls_proc.

    SELECT SINGLE *   FROM /idxgc/proc INTO ls_proc
        WHERE proc_type = iv_switchtype
          AND   proc_view = iv_swtview
          AND   source    = /idxgc/if_constants=>gc_config_source_customer
          AND   active    = /idxgc/if_constants=>gc_true.
    IF sy-subrc NE 0.
      SELECT SINGLE * FROM /idxgc/proc INTO ls_proc
         WHERE proc_type = iv_switchtype
          AND proc_view   = iv_swtview
          AND active      = /idxgc/if_constants=>gc_true.
    ENDIF.
    IF sy-subrc EQ 0.
      rs_proc = ls_proc.
    ELSE.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD determine_proc_step_no.

    DATA: ls_prstep TYPE /idxgc/prstep.

    SELECT SINGLE * FROM /idxgc/prstep INTO ls_prstep
      WHERE type         = iv_proc_step_type
        AND bmid         = iv_bmid
        AND proc_version = iv_proc_version
        AND proc_id      = iv_proc_id
        AND active       = cl_isu_flag=>co_true
        AND source       = /idxgc/if_constants=>gc_config_source_customer.

    IF sy-subrc <> 0.
      SELECT SINGLE * FROM /idxgc/prstep INTO ls_prstep
        WHERE type         = iv_proc_step_type
          AND bmid         = iv_bmid
          AND proc_version = iv_proc_version
          AND proc_id      = iv_proc_id
          AND active       = cl_isu_flag=>co_true.
    ENDIF.

    rv_proc_step_no = ls_prstep-proc_step_no.


  ENDMETHOD.


  METHOD determine_proc_version.

    DATA:lt_procvers     TYPE TABLE OF /idxgc/procvers,
         lt_proc_version TYPE          /idxgc/t_proc_version,
         lv_proc_date    TYPE          sy-datum.

    FIELD-SYMBOLS: <fs_procvers> TYPE /idxgc/procvers.

    IF NOT iv_switchnum IS INITIAL.
      SELECT SINGLE proc_version FROM /idxgc/proc_hdr INTO rv_procvers
        WHERE proc_ref = iv_switchnum.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT * FROM /idxgc/procvers INTO CORRESPONDING FIELDS OF TABLE lt_procvers
        WHERE proc_id = iv_proc_id
          AND source = /idxgc/if_constants=>gc_config_source_customer
          AND valid_from LE iv_proc_date.

    IF sy-subrc <> 0.
      SELECT * FROM /idxgc/procvers INTO CORRESPONDING FIELDS OF TABLE lt_procvers
        WHERE proc_id = iv_proc_id
          AND valid_from LE iv_proc_date.

      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
    ENDIF.

    DELETE ADJACENT DUPLICATES FROM lt_procvers COMPARING proc_id proc_version source.

    SORT lt_procvers BY valid_from DESCENDING.

    READ TABLE lt_procvers ASSIGNING <fs_procvers> INDEX 1.

    rv_procvers = <fs_procvers>-proc_version.

  ENDMETHOD.


  METHOD get_name_format_code.

    DATA: lv_title TYPE zemd_title.

    SELECT SINGLE zemd_title FROM ekun INTO lv_title WHERE partner = iv_partner.

    CASE lv_title(1).
      WHEN 'P'.
        rv_name_format = /idxgc/if_constants_ide=>gc_name_format_code_person.
      WHEN 'F'.
        rv_name_format = /idxgc/if_constants_ide=>gc_name_format_code_company.
      WHEN OTHERS.
        rv_name_format = /idxgc/if_constants_ide=>gc_name_format_code_person. "sollte nicht vorkommen
    ENDCASE.
  ENDMETHOD.


  METHOD get_partner_name_addr_data.
***************************************************************************************************
* EXTHIMEL, 20160505, Eigene Methode zum ermitteln von Name und Adresse
*   Teilweise übernommen aus /IDXGC/CL_UTILITY_GENERIC=>GET_PARTNER_NAME_ADDR_DATA
***************************************************************************************************
    DATA: lr_utility       TYPE REF TO /idxgc/cl_utility_generic,
          lr_previous      TYPE REF TO cx_root,
          lt_partner       TYPE        bup_t_cent_uuidkey_api,
          lt_data_addr     TYPE        bup_t_addr_data_api,
          ls_bus000        TYPE        bus000,
          ls_ekun          TYPE        ekun,
          lv_partnerformat TYPE        /idxgc/de_name_format_code,
          lv_adr_kind      TYPE        bu_adrkind,
          lv_houseid       TYPE        /idxgc/de_houseid,
          lv_houseid_add   TYPE        /idxgc/de_houseid_add.

    FIELD-SYMBOLS: <fs_data_addr> TYPE bup_s_addr_data_api,
                   <fs_partner>   TYPE bup_s_cent_uuidkey_api.

***** Name holen **********************************************************************************
    CALL FUNCTION 'BUP_PARTNER_GET'
      EXPORTING
        i_partner         = iv_bu_partner
      IMPORTING
        e_but000          = ls_bus000
      EXCEPTIONS
        partner_not_found = 1
        wrong_parameters  = 2
        internal_error    = 3
        OTHERS            = 4.

    lv_partnerformat = zcl_agc_datex_utility=>get_name_format_code( iv_partner = iv_bu_partner ).

    CASE lv_partnerformat.
      WHEN /idxgc/if_constants_ide=>gc_name_format_code_person.
        rs_name_address-fam_comp_name1   = ls_bus000-name_org2.
        rs_name_address-first_name       = ls_bus000-name_org1.
      WHEN /idxgc/if_constants_ide=>gc_name_format_code_company.
        rs_name_address-fam_comp_name1   = ls_bus000-name_org1.
        rs_name_address-fam_comp_name2   = ls_bus000-name_org2.
    ENDCASE.

    rs_name_address-name_add1        = ls_bus000-name_org3.
    rs_name_address-name_add2        = ls_bus000-name_org4.
    rs_name_address-name_format_code = lv_partnerformat.
    rs_name_address-bpkind           = ls_bus000-type.

    IF lv_partnerformat = /idxgc/if_constants_ide=>gc_name_format_code_person.
      CALL FUNCTION 'ISU_DB_EKUN_SINGLE'
        EXPORTING
          x_partner    = iv_bu_partner
          x_actual     = 'X'
          x_requested  = 'X'
        IMPORTING
          y_ekun       = ls_ekun
        EXCEPTIONS
          not_found    = 1
          system_error = 2
          OTHERS       = 3.
      IF sy-subrc = 0.
        IF ls_ekun-zemd_title_aca1 IS NOT INITIAL.
          rs_name_address-ad_title_ext = ls_ekun-zemd_title_aca1.
        ELSEIF ls_bus000-title = 'HD' OR ls_bus000-title = 'FD'.
          rs_name_address-ad_title_ext = 'DR'.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR:  rs_name_address-ad_title_ext.
    ENDIF.

***** Adresse zur Ablesekarte holen (wenn nicht vorhanden wird die Standard-Adresse genommen) *****
    IF iv_flag_addr_mrcontact = abap_true.
      lv_adr_kind = zif_agc_datex_co=>gc_adr_kind_mread_card.
    ELSE.
      lv_adr_kind = zif_agc_datex_co=>gc_adr_kind_default.
    ENDIF.
    APPEND INITIAL LINE TO lt_partner ASSIGNING <fs_partner>.
    <fs_partner>-partner = iv_bu_partner.
    cl_bup_address_api=>read_by_partner_and_usage( EXPORTING it_partner = lt_partner iv_adr_kind = lv_adr_kind IMPORTING et_data_addr = lt_data_addr ).
    TRY.
        ASSIGN lt_data_addr[ 1 ] TO <fs_data_addr>.
      CATCH cx_sy_itab_line_not_found INTO lr_previous.
        CALL METHOD /idxgc/cx_utility_error=>raise_util_exception_from_msg( ir_previous = lr_previous ).
    ENDTRY.

***** Adresse auf PDoc-Struktur mappen ************************************************************
    lv_houseid      = <fs_data_addr>-location-house_num1.
    lv_houseid_add  = <fs_data_addr>-location-house_num2.

    CALL METHOD lr_utility->concat_houseid_compl
      EXPORTING
        iv_housenum      = lv_houseid
        iv_house_sup     = lv_houseid_add
      IMPORTING
        ev_houseid_compl = rs_name_address-houseid_compl.

    rs_name_address-district    = <fs_data_addr>-location-city2.
    rs_name_address-cityname    = <fs_data_addr>-location-city1.

    IF <fs_data_addr>-location-post_code3 IS NOT INITIAL .
      rs_name_address-postalcode  = <fs_data_addr>-location-post_code3.
      IF <fs_data_addr>-location-po_box IS NOT INITIAL.
        rs_name_address-poboxid     = <fs_data_addr>-location-po_box.
      ELSEIF <fs_data_addr>-location-street IS NOT INITIAL.
        rs_name_address-streetname  = <fs_data_addr>-location-street.
      ENDIF.
    ELSEIF <fs_data_addr>-location-post_code2 IS NOT INITIAL.
      rs_name_address-postalcode  = <fs_data_addr>-location-post_code2.
      IF <fs_data_addr>-location-po_box IS NOT INITIAL.
        rs_name_address-poboxid   = <fs_data_addr>-location-po_box.
      ENDIF.
    ELSEIF <fs_data_addr>-location-post_code1 IS NOT INITIAL.
      rs_name_address-postalcode  = <fs_data_addr>-location-post_code1.
      IF <fs_data_addr>-location-street IS NOT INITIAL.
        rs_name_address-streetname  = <fs_data_addr>-location-street.
      ENDIF.
    ENDIF.

    rs_name_address-countrycode = <fs_data_addr>-location-country.
  ENDMETHOD.


  METHOD get_preceding_msg_data.
***************************************************************************************************
* THIMEL.R 20150330 Einführung CL
*   Kopiert aus /IDXGC/CL_MESSAGE_UTILMD_IN->GET_PRECEDING_MSG_DATA
*   Methode /idxgc/cl_process_document=>/idxgc/if_process_document~get_preceding_step_data durch
*     enthaltenes Coding ersetzt und angepasst
***************************************************************************************************

*++++ Eigene Variablen ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    DATA: lt_activities   TYPE /idxgc/t_activity_data,
          lv_mtext        TYPE string,
          lv_flag_obsolet TYPE flag.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    DATA: ls_proc_step_data TYPE        /idxgc/s_proc_step_data,
          lx_previous       TYPE REF TO /idxgc/cx_general.

* INITIALIZATION
    CLEAR: ev_proc_ref, es_bmid_rel.

    TRY.
*     Read the preceding message via cs_proc_step_data-UTILMD_DIVERSE-REFNR_TRANSREQ

***** Kopiert aus /idxgc/cl_process_document=>/idxgc/if_process_document~get_preceding_step_data **
        DATA:lv_pdoc           TYPE        /idxgc/de_proc_ref,
             lv_tlines         TYPE        i,
             ls_proc_hdr       TYPE        /idxgc/s_proc_hdr,
             ls_diverse_data   TYPE        /idxgc/prst_div,
*++++        ls_proc_step_data TYPE        /idxgc/s_proc_step_data,
             lt_diverse_data   TYPE        /idxgc/t_prst_div,
             lt_proc_step_data TYPE        /idxgc/t_proc_step_data,
*++++        lx_previous       TYPE REF TO /idxgc/cx_general,
             lr_ctx            TYPE REF TO /idxgc/cl_pd_doc_context,
             lv_exp_code       TYPE        /idxgc/de_excp_code.

*First to get process step refernce via transaction number
        TRY .
            CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_diverse_from_transaction
              EXPORTING
                iv_transaction_no = iv_transaction_no
                iv_direction      = iv_direction
                iv_assoc_servprov = iv_assoc_servprov
              IMPORTING
                et_diverse_data   = lt_diverse_data.
          CATCH /idxgc/cx_utility_error INTO lx_previous.

        ENDTRY.

        LOOP AT lt_diverse_data INTO ls_diverse_data.
*Then to get the context instance
          TRY.
              lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no   = ls_diverse_data-proc_ref
                                                               iv_bufref    = /idxgc/if_constants=>gc_true
                                                               iv_wmode     = cl_isu_wmode=>co_display ).

            CATCH /idxgc/cx_process_error INTO lx_previous.
              CONTINUE.
          ENDTRY.

          CALL METHOD lr_ctx->get_header_data
            IMPORTING
              es_proc_hdr = ls_proc_hdr.
* Error PDocs are not relevant
          IF ls_proc_hdr-proc_id = /idxgc/if_constants=>gc_proc_id_unsl. "++++ iv_proc_id_error_pdoc.
            CONTINUE.
          ENDIF.

*++++ Evtl. ist eine ZPI gelaufen, dann gibt es noch einen WB mit gleicher Referenz +++++++++++++++
          REFRESH: lt_activities.
          lv_flag_obsolet = abap_false.
          lr_ctx->gr_process_log->get_activities( IMPORTING et_activities = lt_activities ).
          LOOP AT lt_activities TRANSPORTING NO FIELDS WHERE activity = 'Z02'.
            LOOP AT lt_activities TRANSPORTING NO FIELDS WHERE activity = '501'.
              lv_flag_obsolet = abap_true.
            ENDLOOP.
          ENDLOOP.
          IF lv_flag_obsolet = abap_true.
            CONTINUE.
          ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

*Call method GET_PROC_STEP_DATA to get existing step data via process step reference.
          TRY.
              CALL METHOD lr_ctx->get_proc_step_data
                EXPORTING
                  iv_proc_step_ref  = ls_diverse_data-proc_step_ref
                IMPORTING
                  es_proc_step_data = ls_proc_step_data.
            CATCH /idxgc/cx_process_error INTO lx_previous.
              CONTINUE.
          ENDTRY.

          APPEND ls_proc_step_data TO lt_proc_step_data.
        ENDLOOP.

        SORT lt_proc_step_data BY proc_ref proc_step_timestamp.
        DELETE ADJACENT DUPLICATES FROM lt_proc_step_data COMPARING proc_ref.

        DESCRIBE TABLE lt_proc_step_data LINES lv_tlines.
        IF lv_tlines = 1.
          READ TABLE lt_proc_step_data INTO ls_proc_step_data INDEX 1.
*++++     es_proc_step_data = ls_proc_step_data.
        ELSE.
* If can't find preceding message via process reference, pass a special exception
* code with 'RefNotExist' when raise exception, it will be used outside to check
* if it is the new process 'CX100'.
          IF lv_tlines = 0.
            lv_exp_code = /idxgc/if_constants_add=>gc_excp_code_refnotexist. "'RefNotExist'
          ENDIF.

          MESSAGE e091(/idxgc/utility_add) INTO lv_mtext.
          CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
            EXPORTING
              ir_previous       = lx_previous
              iv_exception_code = lv_exp_code.
        ENDIF.

***************************************************************************************************


        es_proc_step_data_orig = ls_proc_step_data.

*     Set the preceding process reference number
        ev_proc_ref = ls_proc_step_data-proc_ref.

*     Get the relationship amongst different BMIDs
        CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_bmid_relation
          EXPORTING
            iv_bmid     = ls_proc_step_data-bmid
          IMPORTING
            es_bmid_rel = es_bmid_rel.

      CATCH /idxgc/cx_process_error INTO lx_previous.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
          EXPORTING
            ir_previous       = lx_previous
            iv_exception_code = lx_previous->exception_code.

      CATCH /idxgc/cx_config_error INTO lx_previous.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
          EXPORTING
            ir_previous = lx_previous.

    ENDTRY.


  ENDMETHOD.


  METHOD get_preceding_step_data.
*----------------------------------------------------------------------*
**
** Author: SAP Custom Development, 2012
**
** Usage: Get preceding process step data via transaction number
** Remark: a message can be assigned to a regular PDoc and to an error PDoc;
** therefore we can get more than one Process reference for a transaction
** number
*
** Status: <Completed>
*----------------------------------------------------------------------*

** Change History:
*
** Jun. 2012: Complete
** Sep. 2014: Changed   In case can't find original message via reference,
**                      pass a special exception code when raise exception.
**
*----------------------------------------------------------------------*
* Maxim Schmidt, 03.02.2016, Mantis 5240 Kopie aus dem Standard
*----------------------------------------------------------------------*

    DATA:lv_pdoc           TYPE        /idxgc/de_proc_ref,
         lv_tlines         TYPE        i,
         ls_proc_hdr       TYPE        /idxgc/s_proc_hdr,
         ls_diverse_data   TYPE        /idxgc/prst_div,
         ls_proc_step_data TYPE        /idxgc/s_proc_step_data,
         lt_diverse_data   TYPE        /idxgc/t_prst_div,
         lt_proc_step_data TYPE        /idxgc/t_proc_step_data,
         lx_previous       TYPE REF TO /idxgc/cx_general,
         lr_ctx            TYPE REF TO /idxgc/cl_pd_doc_context,
         lv_exp_code       TYPE        /idxgc/de_excp_code.

*++++ Eigene Variablen ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    DATA: lt_activities   TYPE /idxgc/t_activity_data,
          lv_mtext        TYPE string,
          lv_flag_obsolet TYPE flag.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

*First to get process step refernce via transaction number
    TRY .
        CALL METHOD /idxgc/cl_utility_service=>/idxgc/if_utility_service~get_diverse_from_transaction
          EXPORTING
            iv_transaction_no = iv_transaction_no
            iv_direction      = iv_direction
            iv_assoc_servprov = iv_assoc_servprov
          IMPORTING
            et_diverse_data   = lt_diverse_data.
      CATCH /idxgc/cx_utility_error INTO lx_previous.

    ENDTRY.

    LOOP AT lt_diverse_data INTO ls_diverse_data.
*Then to get the context instance
      TRY.
          lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no   = ls_diverse_data-proc_ref
                                                           iv_bufref    = /idxgc/if_constants=>gc_true
                                                           iv_wmode     = cl_isu_wmode=>co_display ).

        CATCH /idxgc/cx_process_error INTO lx_previous.
          CONTINUE.
      ENDTRY.

      CALL METHOD lr_ctx->get_header_data
        IMPORTING
          es_proc_hdr = ls_proc_hdr.
* Error PDocs are not relevant
      IF ls_proc_hdr-proc_id = iv_proc_id_error_pdoc.
        CONTINUE.
      ENDIF.


*++++ Evtl. ist eine ZPI gelaufen, dann gibt es noch einen WB mit gleicher Referenz +++++++++++++++
      REFRESH: lt_activities.
      lv_flag_obsolet = abap_false.
      lr_ctx->gr_process_log->get_activities( IMPORTING et_activities = lt_activities ).
      LOOP AT lt_activities TRANSPORTING NO FIELDS WHERE activity = 'Z02'.
        LOOP AT lt_activities TRANSPORTING NO FIELDS WHERE activity = '501'.
          lv_flag_obsolet = abap_true.
        ENDLOOP.
      ENDLOOP.
      IF lv_flag_obsolet = abap_true.
        CONTINUE.
      ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

*Call method GET_PROC_STEP_DATA to get existing step data via process step reference.
      TRY.
          CALL METHOD lr_ctx->get_proc_step_data
            EXPORTING
              iv_proc_step_ref  = ls_diverse_data-proc_step_ref
            IMPORTING
              es_proc_step_data = ls_proc_step_data.
        CATCH /idxgc/cx_process_error INTO lx_previous.
          CONTINUE.
      ENDTRY.

      APPEND ls_proc_step_data TO lt_proc_step_data.
    ENDLOOP.

    SORT lt_proc_step_data BY proc_ref proc_step_timestamp.
    DELETE ADJACENT DUPLICATES FROM lt_proc_step_data COMPARING proc_ref.

    DESCRIBE TABLE lt_proc_step_data LINES lv_tlines.
    IF lv_tlines = 1.
      READ TABLE lt_proc_step_data INTO ls_proc_step_data INDEX 1.
      es_proc_step_data = ls_proc_step_data.
    ELSE.
* If can't find preceding message via process reference, pass a special exception
* code with 'RefNotExist' when raise exception, it will be used outside to check
* if it is the new process 'CX100'.
      IF lv_tlines = 0.
        lv_exp_code = /idxgc/if_constants_add=>gc_excp_code_refnotexist. "'RefNotExist'
      ENDIF.

      MESSAGE e091(/idxgc/utility_add) INTO lv_mtext.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
        EXPORTING
          ir_previous       = lx_previous
          iv_exception_code = lv_exp_code.
    ENDIF.

  ENDMETHOD.


  METHOD get_process_step_data_all.

    DATA: ls_eideswtdoc             TYPE        eideswtdoc,
          ls_pdoc_data              TYPE        /idxgc/s_pdoc_data,
          ls_pdoc_data_src          TYPE        /idxgc/s_pdoc_data,
          ls_proc_data              TYPE        /idxgc/s_proc_data,
          ls_proc_data_src          TYPE        /idxgc/s_proc_data,
          ls_proc_step_data_src_all TYPE        /idxgc/s_proc_step_data_all,
          lt_msgdata                TYPE        teideswtmsgdata,
          lr_dp_out                 TYPE REF TO zcl_agc_dp_out_utilmd_006,
          ls_steps                  TYPE        /idxgc/s_proc_step_data,
          ls_msgdata_src            TYPE        eideswtmsgdata.

    ls_msgdata_src = is_msgdata_src.

    IF is_eideswtdoc IS INITIAL.
*   Wechselbelegkopf lesen
      CALL METHOD zcl_isuswitchd=>select_wb
        EXPORTING
          im_switchnum  = is_msgdata-switchnum
        IMPORTING
          ex_eideswtdoc = ls_eideswtdoc.
    ENDIF.

*   PDoc- und Process-Daten ermittlen
    APPEND is_msgdata TO lt_msgdata.

    CALL METHOD zcl_agc_datex_utility=>map_isu_data_to_pdoc
      EXPORTING
        it_msg_hdr   = lt_msgdata
        is_pdoc_hdr  = ls_eideswtdoc
      IMPORTING
        es_pdoc_data = ls_pdoc_data.

    CALL METHOD /idxgc/cl_process_document=>/idxgc/if_process_document~map_pdoc_to_process_data
      EXPORTING
        is_pdoc_data = ls_pdoc_data
      IMPORTING
        es_proc_data = ls_proc_data.

*   Das Gleiche auch mit IS_MSGDATA_SRC durchführen
    IF ls_msgdata_src IS INITIAL.
      ls_msgdata_src = is_msgdata.
    ENDIF.

    FREE lt_msgdata.

    APPEND ls_msgdata_src TO lt_msgdata.

    CALL METHOD zcl_agc_datex_utility=>map_isu_data_to_pdoc
      EXPORTING
        it_msg_hdr   = lt_msgdata
        is_pdoc_hdr  = ls_eideswtdoc
      IMPORTING
        es_pdoc_data = ls_pdoc_data_src.

    CALL METHOD /idxgc/cl_process_document=>/idxgc/if_process_document~map_pdoc_to_process_data
      EXPORTING
        is_pdoc_data = ls_pdoc_data
      IMPORTING
        es_proc_data = ls_proc_data_src.


*   Datenbeschaffungsklasse instanziieren
    MOVE ls_proc_data_src-hdr TO ls_proc_step_data_src_all-proc.
    READ TABLE ls_proc_data_src-steps INTO ls_steps INDEX 1.
    MOVE-CORRESPONDING ls_steps TO ls_proc_step_data_src_all-step.

    CREATE OBJECT lr_dp_out
      EXPORTING
        is_process_data_src = ls_proc_step_data_src_all.

*   Prozessschrittdaten ermitteln
    CLEAR ls_steps.
    READ TABLE ls_proc_data-steps INTO ls_steps INDEX 1.
    MOVE-CORRESPONDING ls_steps TO es_proc_step_data-step.

    es_proc_step_data-bmid = iv_bmid.
    es_proc_step_data-proc = ls_proc_data-hdr.

    TRY.
        CALL METHOD lr_dp_out->/idxgc/if_dp_out~process_data_provision
          CHANGING
            cs_process_step_data = es_proc_step_data.
      CATCH /idxgc/cx_process_error .
    ENDTRY.

  ENDMETHOD.


  METHOD GET_PROC_DATE.
***************************************************************************************************
* Bestimmung des Prozessdatums (eines Schlüsseldatums) aus den Prozessschrittdaten.
*--------------------------------------------------------------------------------------------------
* 20150126 THIMEL.R Übernahme der Logik teilweise aus der Klassenmethode
*    ZCL_APERAK_HANDLER_001=>GET_PROC_DATE_UTILMD_MSGD_001
***************************************************************************************************
    FIELD-SYMBOLS:
      <fs_amid_details> TYPE /idxgc/s_amid_details.

    DATA:
      ls_diverse_details TYPE /idxgc/s_diverse_details,
      lv_amid            TYPE /idxgc/de_amid.

***** Diverse Struktur und AMID ermitteln *********************************************************
    IF iv_amid IS INITIAL.
      READ TABLE is_proc_step_data-amid ASSIGNING <fs_amid_details> INDEX 1.
      IF sy-subrc = 0.
        lv_amid = <fs_amid_details>-amid.
      ENDIF.
    ELSE.
      lv_amid = iv_amid.
    ENDIF.
    IF is_diverse_details IS INITIAL.
      READ TABLE is_proc_step_data-diverse INTO ls_diverse_details INDEX 1.
    ELSE.
      ls_diverse_details = is_diverse_details.
    ENDIF.

***** Datum ermitteln *****************************************************************************
    CASE lv_amid.

*---- Anmeldung NN, Informationsmeldung (ZC9) -----------------------------------------------------
      WHEN zif_agc_datex_utilmd_co=>gc_amid_11001
        OR zif_agc_datex_utilmd_co=>gc_amid_11002
        OR zif_agc_datex_utilmd_co=>gc_amid_11013
        OR zif_agc_datex_utilmd_co=>gc_amid_11014
        OR zif_agc_datex_utilmd_co=>gc_amid_11038.

        rv_proc_date = ls_diverse_details-contr_start_date. "92, Vertragsbeginn

*---- Änderungsmeldung (Z46,Z47) ------------------------------------------------------------------
      WHEN zif_agc_datex_utilmd_co=>gc_amid_11025
        OR zif_agc_datex_utilmd_co=>gc_amid_11026
        OR zif_agc_datex_utilmd_co=>gc_amid_11027
        OR zif_agc_datex_utilmd_co=>gc_amid_11028
        OR zif_agc_datex_utilmd_co=>gc_amid_11029
        OR zif_agc_datex_utilmd_co=>gc_amid_11030
        OR zif_agc_datex_utilmd_co=>gc_amid_11033
        OR zif_agc_datex_utilmd_co=>gc_amid_11034.

        rv_proc_date = ls_diverse_details-validstart_date. "157, Änderung zum

*---- Änderungsmeldung (ZD0) ----------------------------------------------------------------------
      WHEN zif_agc_datex_utilmd_co=>gc_amid_11020
        OR zif_agc_datex_utilmd_co=>gc_amid_11021.

        IF ls_diverse_details-contr_start_date IS NOT INITIAL.
          rv_proc_date = ls_diverse_details-contr_start_date. "92, Vertragsbeginn
        ELSEIF is_proc_step_data-validity_ym IS NOT INITIAL.
          rv_proc_date = is_proc_step_data-validity_ym. "DTM+157 nicht SG4-DTM+157 (in diesem Fall)
        ELSE.
          rv_proc_date = sy-datum.
        ENDIF.

*---- Abmeldung NN --------------------------------------------------------------------------------
      WHEN zif_agc_datex_utilmd_co=>gc_amid_11004
        OR zif_agc_datex_utilmd_co=>gc_amid_11005.

        IF ls_diverse_details-msgtransreason = /idxgc/if_constants_ide=>gc_trans_reason_code_zc9.
          rv_proc_date = ls_diverse_details-contr_start_date. "92, Vertragsbeginn
        ELSE.
          rv_proc_date = ls_diverse_details-contr_end_date. "93, Vertragsende
        ENDIF.

*---- Abmeldung Stilllegung, Abmeldeanfrage des NB, Informationsmeldung zur Beendigung der Zuo. ---
      WHEN zif_agc_datex_utilmd_co=>gc_amid_11007
        OR zif_agc_datex_utilmd_co=>gc_amid_11008
        OR zif_agc_datex_utilmd_co=>gc_amid_11010
        OR zif_agc_datex_utilmd_co=>gc_amid_11011
        OR zif_agc_datex_utilmd_co=>gc_amid_11037.

        rv_proc_date = ls_diverse_details-contr_end_date. "93, Vertragsende

*---- Kündigung -----------------------------------------------------------------------------------
      WHEN zif_agc_datex_utilmd_co=>gc_amid_11016
        OR zif_agc_datex_utilmd_co=>gc_amid_11017.

        IF ls_diverse_details-contr_end_date IS NOT INITIAL.
          rv_proc_date = ls_diverse_details-contr_end_date. "93, Vertragsende
        ELSE.
          rv_proc_date = ls_diverse_details-endnextposs_from. "471, Ende zum (nächstmöglicher Termin)
        ENDIF.

*---- Alle Ablehnungen (Kein Datum), Informationsmeldung(Z26), Stornierung, Rest ------------------
      WHEN OTHERS.

        rv_proc_date = sy-datum.

    ENDCASE.

  ENDMETHOD.


  METHOD get_proc_id_from_proc_ref.
    SELECT SINGLE proc_id FROM /idxgc/proc_hdr INTO rv_proc_id WHERE proc_ref = iv_proc_ref.
  ENDMETHOD.


  METHOD get_step_data_after_zpi.

    DATA: lr_ctx_zpi           TYPE REF TO /idxgc/cl_pd_doc_context,
          ls_step_data_zpi     TYPE        /idxgc/s_proc_step_data,
          ls_proc_hdr_data_zpi TYPE        /idxgc/s_proc_hdr.

    FIELD-SYMBOLS: <fs_pod>       TYPE /idxgc/s_pod_info_details,
                   <fs_pod_quant> TYPE /idxgc/s_pod_quant_details,
                   <fs_time_ser>  TYPE /idxgc/s_timeser_details,
                   <fs_mdev>      TYPE /idxgc/s_meterdev_details,
                   <fs_reg_code>  TYPE /idxgc/s_reg_code_details,
                   <fs_charges>   TYPE /idxgc/s_charges_details,
                   <fs_mpart_add> TYPE /idxgc/s_marpaadd_details.

    TRY.
        CALL METHOD /idxgc/cl_pd_doc_context=>get_instance
          EXPORTING
            iv_pdoc_no = iv_switchnum_zpi
            iv_wmode   = cl_isu_wmode=>co_display
          RECEIVING
            rr_ctx     = lr_ctx_zpi.

        IF lr_ctx_zpi IS BOUND.

          lr_ctx_zpi->get_header_data( IMPORTING es_proc_hdr = ls_proc_hdr_data_zpi ).

          CALL METHOD lr_ctx_zpi->get_proc_step_data
            EXPORTING
              iv_proc_step_ref  = cs_proc_step-proc_step_ref
              iv_proc_step_no   = cs_proc_step-proc_step_no
            IMPORTING
              es_proc_step_data = ls_step_data_zpi.
        ENDIF.

        CHECK ls_step_data_zpi IS NOT INITIAL.

        ls_step_data_zpi-proc_ref = cs_proc_step-proc_ref.
        ls_step_data_zpi-proc_step_ref = cs_proc_step-proc_step_ref.
        ls_step_data_zpi-proc_step_status = cs_proc_step-proc_step_status.
        ls_step_data_zpi-status_timestamp = cs_proc_step-status_timestamp.
        ls_step_data_zpi-proc_step_no = cs_proc_step-proc_step_no.

        cs_proc_step = ls_step_data_zpi.

        IF ls_proc_hdr_data_zpi-int_ui IS INITIAL. "Nochmal Prüfung ob es auch wirklich eine ZPI war

          cs_proc_step-ext_ui = zcl_agc_masterdata=>get_ext_ui( iv_int_ui = is_proc_hdr-int_ui iv_keydate = is_proc_hdr-proc_date ).

          LOOP AT cs_proc_step-pod ASSIGNING <fs_pod> WHERE ext_ui = ls_step_data_zpi-ext_ui.
            <fs_pod>-ext_ui = cs_proc_step-ext_ui.
          ENDLOOP.
          LOOP AT cs_proc_step-pod_quant ASSIGNING <fs_pod_quant>.
            <fs_pod_quant>-ext_ui = cs_proc_step-ext_ui.
          ENDLOOP.
          LOOP AT cs_proc_step-time_series ASSIGNING <fs_time_ser>.
            <fs_time_ser>-ext_ui = cs_proc_step-ext_ui.
          ENDLOOP.
          LOOP AT cs_proc_step-meter_dev ASSIGNING <fs_mdev>.
            <fs_mdev>-ext_ui = cs_proc_step-ext_ui.
          ENDLOOP.
          LOOP AT cs_proc_step-reg_code_data ASSIGNING <fs_reg_code>.
            <fs_reg_code>-ext_ui = cs_proc_step-ext_ui.
          ENDLOOP.
          LOOP AT cs_proc_step-charges ASSIGNING <fs_charges>.
            <fs_charges>-ext_ui = cs_proc_step-ext_ui.
          ENDLOOP.
          LOOP AT cs_proc_step-marketpartner_add ASSIGNING <fs_mpart_add>.
            <fs_mpart_add>-ext_ui = cs_proc_step-ext_ui.
          ENDLOOP.

        ENDIF.
      CATCH /idxgc/cx_process_error.
    ENDTRY.
  ENDMETHOD.


  METHOD get_valid_process_step_init.

    "Kopie von der Standard-Datenaustauschklasse /IDXGC/CL_DATEX_PROC_PDOC

    DATA:
      ls_proc_step_id       TYPE /idxgc/s_proc_step_id,
      ls_process_data_valid TYPE /idxgc/s_proc_data,
      ls_proc_data          TYPE /idxgc/s_proc_data,

      ls_validate_result    TYPE /idxgc/s_validate_result.

    FIELD-SYMBOLS:
      <fs_process_config>          TYPE /idxgc/s_proc_config_all,
      <fs_process_step>            TYPE /idxgc/s_proc_step_config_all,
      <fs_proc_step_data>          TYPE /idxgc/s_proc_step_data,
      <fs_process_data_valid_step> TYPE /idxgc/s_proc_step_data.


    LOOP AT it_process_config ASSIGNING <fs_process_config>.
*   Now need to check if this message should CREATE a process
*   document (i.e. it is the first message in a process)
      LOOP AT <fs_process_config>-steps ASSIGNING <fs_process_step>.
        ls_proc_step_id-proc_id      = <fs_process_config>-proc_id.
        ls_proc_step_id-proc_version = <fs_process_config>-proc_version.
        ls_proc_step_id-proc_step_no = <fs_process_step>-proc_step_no.

*--------------------------------------------------------------------*
*enhance the step number/step status & current message data to process data before checking lanchable
*as when checking if current process step is executable, we need to distinguish if inbound step is trigger
*from other process or from COMPR (for COMPR, the process data already contains the inbound message)
        ls_proc_data = is_message_data.
*there will be only one entry from inbound mapping for each process data
        READ TABLE ls_proc_data-steps[] ASSIGNING <fs_proc_step_data> INDEX 1.
        IF sy-subrc EQ 0.
          <fs_proc_step_data>-proc_step_no     = <fs_process_step>-proc_step_no.
          <fs_proc_step_data>-proc_step_status = if_isu_ide_switch_constants=>co_swtmsg_status_new.
        ENDIF.
*--------------------------------------------------------------------*
*       This entry is valid. Add to table of valid entries.
        ls_process_data_valid = is_message_data.

*       Add header information
        ls_process_data_valid-proc_id   = <fs_process_config>-proc_id.
        ls_process_data_valid-proc_type = <fs_process_config>-proc_type.
        ls_process_data_valid-spartyp   = <fs_process_config>-spartyp.

*       Enhance original message with step information.
*       MN: Changed to LOOP to cope with multiple steps within single inbound
*           This is required within "mass" report type inbound messages where
*           each record in the report should be created as a process step data
*           Thus here we only judge if a single entry is "launchable" and if so
*           assume that ALL steps in the inbound message are launchable.
        LOOP AT ls_process_data_valid-steps ASSIGNING <fs_process_data_valid_step>.
          <fs_process_data_valid_step>-proc_step_no = <fs_process_step>-proc_step_no.
        ENDLOOP.
*>>>>20121219 Zerec
        ls_validate_result-executable = /idxgc/if_constants=>gc_execute_ok.
*<<<<20121219 Zerec

        IF ls_validate_result-executable = /idxgc/if_constants=>gc_execute_ok.
*         Now add this entry to our list of ALL potential processes/Steps
          INSERT ls_process_data_valid INTO TABLE ct_process_data_valid.

        ELSEIF ls_validate_result-executable = /idxgc/if_constants=>gc_execute_with_reserve.
          INSERT ls_process_data_valid INTO TABLE ct_process_data_with_reserve.
        ENDIF.

        CLEAR:
          ls_proc_step_id,
          ls_process_data_valid,
          ls_validate_result.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  METHOD get_valid_process_step_noninit.

    "Kopie von der Standard-Datenaustauschklasse /IDXGC/CL_DATEX_PROC_PDOC

    DATA:
      lr_previous              TYPE REF TO /idxgc/cx_general,
      lr_process               TYPE REF TO /idxgc/if_process,
      lr_process_data          TYPE REF TO /idxgc/if_process_data_extern,
      lr_process_data_pdoc     TYPE REF TO /idxgc/if_process_data_pdoc,
      lr_process_step_data     TYPE REF TO /idxgc/if_process_data_step,

      lt_proc_data             TYPE        /idxgc/t_proc_data,
      lt_process_status        TYPE        /idxgc/t_proc_status,
      lt_process_status_config TYPE        /idxgc/t_proc_stat_config,
      lt_process_id            TYPE        /idxgc/t_proc_id,
      lt_int_ui                TYPE        int_ui_table,
      lt_sel_process_id        TYPE        isu00_range_tab,
      lt_sel_int_ui            TYPE        isu00_range_tab,
      lt_sel_active_status     TYPE        isu00_range_tab,

      ls_proc_step_data_all    TYPE        /idxgc/s_proc_step_data_all,
      ls_process_data_valid    TYPE        /idxgc/s_proc_data,
      ls_message_step_key      TYPE        /idxgc/s_proc_step_key,

      ls_validate_result       TYPE        /idxgc/s_validate_result,
      lv_process_status        TYPE        /idxgc/de_proc_status,
      lv_found_proc_id         TYPE        /idxgc/de_boolean_flag.

    DATA: ls_process_data_back TYPE /idxgc/s_proc_data.
    DATA lv_suppress_search TYPE abap_bool. "für Geschäftsdatenanfrage

    FIELD-SYMBOLS:
      <fs_process_config>        TYPE /idxgc/s_proc_config_all,
      <fs_process_step>          TYPE /idxgc/s_proc_step_config_all,
      <fs_proc_data>             TYPE /idxgc/s_proc_data,
      <fs_process_status_config> TYPE /idxgc/s_proc_stat_config.

*   Select all PDocs for the given PoD and has a status which is still
*   possible to process
    TRY.
        CALL METHOD /idxgc/cl_process_config=>/idxgc/if_process_config~get_all_process_status
          EXPORTING
*           iv_status_active       = /IDXGC/if_constants=>gc_true
            iv_status_complete     = /idxgc/if_constants=>gc_false
            iv_status_not_relevant = /idxgc/if_constants=>gc_false
          IMPORTING
            et_process_status      = lt_process_status_config.
*            et_process_step_status

      CATCH /idxgc/cx_config_error INTO lr_previous.
*      MESSAGE e009(/idxgc/ide) INTO gv_mtext.
*      CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
*        EXPORTING
*          ir_previous = lr_previous.
    ENDTRY.

*   Build table of process status to look for
    LOOP AT lt_process_status_config ASSIGNING <fs_process_status_config>.
      lv_process_status = <fs_process_status_config>-status.
      INSERT lv_process_status INTO TABLE lt_process_status.
    ENDLOOP.

*   Build table of Process_IDs to look for
    LOOP AT it_process_config ASSIGNING <fs_process_config>.
      INSERT <fs_process_config>-proc_id INTO TABLE lt_process_id.
    ENDLOOP.

*   Build table of int_ui to look for
    INSERT is_message_step_data-int_ui INTO TABLE lt_int_ui.

    lt_sel_active_status = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( lt_process_status ).
    lt_sel_process_id    = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( lt_process_id ).
    lt_sel_int_ui        = /idxgc/cl_utility_service=>/idxgc/if_utility_service~build_range_table( lt_int_ui ).

* Für Geschäftsdatenanfrage immer einen neuen WB/PDoc erstellen und keinen bestehenden suchen
    READ TABLE it_process_config ASSIGNING <fs_process_config> INDEX 1.
    IF sy-subrc = 0.
      IF <fs_process_config>-proc_type = if_isu_ide_switch_constants=>co_swttype_bdr AND "22
         <fs_process_config>-proc_view = if_isu_ide_switch_constants=>co_swtview_new_supplier. "02

        READ TABLE <fs_process_config>-steps ASSIGNING <fs_process_step> WITH KEY type = 'WFSND'. "nur beim Versand neuer Anfrage
        IF sy-subrc = 0.
          lv_suppress_search = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_suppress_search = abap_false.
      TRY.
          CALL METHOD /idxgc/cl_process_document_db=>/idxgc/if_process_document_db~select_pdoc_mass
            EXPORTING
              iv_division_cat       = is_message_step_data-spartyp
              it_sel_process_status = lt_sel_active_status
              it_sel_process_id     = lt_sel_process_id
              it_sel_int_ui         = lt_sel_int_ui
            IMPORTING
              et_proc_data          = lt_proc_data.
        CATCH /idxgc/cx_process_error INTO lr_previous. "#EC NO_HANDLER
*          It could be that no process documents are found.
*          As this is not always an execptional situation it will be ignored.
      ENDTRY.
    ENDIF.

*--------------------------------------------------------------------*
*filter the process data via process date
    IF is_message_step_data-proc_date     IS NOT INITIAL AND
       is_message_step_data-msgrespstatus IS INITIAL.
      DELETE lt_proc_data WHERE proc_date NE is_message_step_data-proc_date.
    ENDIF.
*--------------------------------------------------------------------*
* Have now found all PDocs that are "possible". Attempt to determine which is the
* correct one.
    LOOP AT it_process_config ASSIGNING <fs_process_config>.
      LOOP AT lt_proc_data ASSIGNING <fs_proc_data>
                       WHERE proc_id = <fs_process_config>-proc_id.
*     Found match. So this process document has the correct process id
*     and is active. Now need to determine if the current message
*     is executable in this process document.

*     Instantiate this process
        TRY.
            CALL METHOD /idxgc/cl_process=>/idxgc/if_process~get_instance
              EXPORTING
                iv_process_ref = <fs_proc_data>-proc_ref
*               ir_process_document =
                iv_edit_mode   = cl_isu_wmode=>co_display
              RECEIVING
                rr_process     = lr_process.

          CATCH /idxgc/cx_process_error INTO lr_previous.
*          MESSAGE e011(/idxgc/ide) INTO gv_mtext.
*          CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
*            EXPORTING
*              ir_previous = lr_previous.
        ENDTRY.

*--------------------------------------------------------------------*
        lr_process_data          = lr_process->get_process_data( ).
*     me->gs_process_data_back = lr_process_data->get_process_data( ).

        CALL METHOD lr_process_data->get_process_data
          IMPORTING
            es_process_data = ls_process_data_back.

*--------------------------------------------------------------------*
*     Is one of the steps executable in this process?
        LOOP AT <fs_process_config>-steps ASSIGNING <fs_process_step>.
*       Generate ID
          ls_message_step_key-proc_id      = <fs_process_config>-proc_id.
          ls_message_step_key-proc_step_no = <fs_process_step>-proc_step_no.

*--------------------------------------------------------------------*
*update process data container for current inbound message
*this is because when determine step is exectubale or not, we need to distinguish
*this inbound step is triggered by other step(in case customizing pre-condition is met
*or this inbound step is triggered by COMPR
          lr_process_data       = lr_process->get_process_data( ).

*       Refresh process data container to ensure only the current step of current loop
*       is added to existi ng process data.
          lr_process_data_pdoc ?= lr_process_data.
          lr_process_data_pdoc->refresh( is_process_data = ls_process_data_back ).

          lr_process_step_data ?= lr_process_data.
          ls_proc_step_data_all = is_message_step_data.

          ls_proc_step_data_all-proc             = <fs_proc_data>-hdr.
          ls_proc_step_data_all-proc_step_no     = <fs_process_step>-proc_step_no.
          ls_proc_step_data_all-proc_step_status = if_isu_ide_switch_constants=>co_swtmsg_status_new.


          CALL METHOD lr_process_step_data->update_process_step_data
            EXPORTING
              is_process_step_data = ls_proc_step_data_all.
*--------------------------------------------------------------------*

          CLEAR ls_validate_result.
*Check if inbound process
          IF is_message_step_data-direction  = cl_isu_datex_process=>co_dexdirection_import.
            ls_validate_result-executable = /idxgc/if_constants=>gc_execute_ok.
          ELSE.
            ls_validate_result-executable = /idxgc/if_constants=>gc_execute_not_possible.
          ENDIF.
*>>>>20121219 Zerec
          ls_validate_result-executable = /idxgc/if_constants=>gc_execute_ok.
*<<<<20121219 Zerec

          IF ls_validate_result-executable = /idxgc/if_constants=>gc_execute_ok OR
             ls_validate_result-executable = /idxgc/if_constants=>gc_execute_with_reserve.

*         This entry is valid. Add to table of valid entries.
*          ls_process_data_valid = lr_process_data->get_process_data( ).

            CALL METHOD lr_process_data->get_process_data
              IMPORTING
                es_process_data = ls_process_data_valid.

*         Keep track that we have found an entry for this process id
            lv_found_proc_id = /idxgc/if_constants=>gc_true.

            IF ls_validate_result-executable = /idxgc/if_constants=>gc_execute_ok.
*           Now add this entry to our list of ALL potential processes/Steps
              INSERT ls_process_data_valid INTO TABLE ct_process_data_valid.

            ELSEIF ls_validate_result-executable = /idxgc/if_constants=>gc_execute_with_reserve.
              INSERT ls_process_data_valid INTO TABLE ct_process_data_with_reserve.
            ENDIF.

          ENDIF.

          CLEAR: ls_process_data_valid.
        ENDLOOP.

        CLEAR: lr_process.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD map_isu_data_to_pdoc.

***************************************************************************************************
* 27.01.2014 Kopiert aus /IDXGC/CL_PROCESS_DOCUMENT =>MAP_ISU_DATA_TO_PDOC
***************************************************************************************************
* 27.01.2014 René Thimel
*             - Erweiterungen für Z-Felder in EIDESWTMSGDATA vorgenommen.
***************************************************************************************************
    DATA:
      ls_msg                  TYPE          /idxgc/s_msg_data_all,
      ls_pdoc_add             TYPE          /idxgc/s_pdoc_hdr_add,
      ls_msg_addall           TYPE          /idxgc/s_msg_data_add_all,

* PDoc Struktur
      ls_diverse              TYPE          /idxgc/s_diverse_details,
      ls_markpar_add          TYPE          /idxgc/s_marpaadd_details,
      ls_msgsts               TYPE          /idxgc/s_msgsts_details,
      ls_name_address         TYPE          /idxgc/s_nameaddr_details,
      ls_non_meter_device     TYPE          /idxgc/s_nonmeter_details,
      ls_pod                  TYPE          /idxgc/s_pod_info_details,
      ls_pod_quant            TYPE          /idxgc/s_pod_quant_details,
      ls_rejreas              TYPE          /idxgc/s_rejres_details,
      ls_reg_code_data        TYPE          /idxgc/s_reg_code_details,
      ls_settl_terr           TYPE          /idxgc/s_setlter_details,
      ls_settl_unit           TYPE          /idxgc/s_setunit_details,
      ls_status_prod_plant    TYPE          /idxgc/s_sts_prod_details,
      ls_time_series          TYPE          /idxgc/s_timeser_details,
      ls_charges_details      TYPE          /idxgc/s_charges_details,
      ls_attributes           TYPE          /idxgc/s_attr_details,

* Hilfsvariablen
      lt_msgstatus            TYPE TABLE OF eideswtmdstatus,
      ls_eservprov            TYPE          eservprov,
      ls_euitrans             TYPE          euitrans,
      ls_meter_device         TYPE          /idxgc/s_meterdev_details,
      ls_msg_ext              TYPE          zlw_extmsgdata,
      lv_msgstatus            TYPE          eideswtmdstatus,
      lv_item_id              TYPE          /idxgc/de_item_id,
      lv_sparte               TYPE          sparte,
      lv_timeser_counter      TYPE          /idxgc/de_timeser_counter,
      lv_reg_code_temp        TYPE          kennziff,
      lv_dunsnr               TYPE          dunsnr,
      lv_mrperiod_length_temp TYPE          char3,
      lv_value                TYPE          dec10,
      lr_utility              TYPE REF TO   /idxgc/cl_utility_generic,
      lv_houseid              TYPE          /idxgc/de_houseid.

    FIELD-SYMBOLS:
      <fs_msg_hdr>         TYPE eideswtmsgdata,
      <fs_msg_add>         TYPE eideswtmsgadddata,
      <fs_msg_comment>     TYPE eideswtmsgdataco,
      <fs_msg_ext>         TYPE zlw_extmsgdata,
      <fs_any>             TYPE any,
      <fs_reg_code_data>   TYPE /idxgc/s_reg_code_details,
      <fs_msgcomment>      TYPE /idxgc/s_msgcom_details,
      <fs_charges_details> TYPE /idxgc/s_charges_details.

    CLEAR:
      es_pdoc_data.

*--------------------------------------------------------------------*
* 1. Map IS-U header data to pdoc header data structure
    IF NOT is_pdoc_hdr IS INITIAL.
      es_pdoc_data-hdr = is_pdoc_hdr.

      es_pdoc_data-zz_moveindate = is_pdoc_hdr-moveindate.
      es_pdoc_data-zz_moveoutdate = is_pdoc_hdr-moveoutdate.
      es_pdoc_data-zz_realmoveindate = is_pdoc_hdr-realmoveindate.
      es_pdoc_data-zz_realmoveoutdate = is_pdoc_hdr-realmoveoutdate.
      es_pdoc_data-zz_moveindoc = is_pdoc_hdr-zlw2_einzbeleg.

      es_pdoc_data-sup_direct_int = /idxgc/if_constants_add=>gc_sup_direct_supply.

    ENDIF.

* 2. Map generic add header data to pdoc header data structure
    IF NOT is_pdoc_add IS INITIAL.
      ASSIGN is_pdoc_add-adddata->* TO <fs_any>.
      MOVE-CORRESPONDING <fs_any> TO ls_pdoc_add.
      es_pdoc_data-hdr_add = ls_pdoc_add.
    ENDIF.

*--------------------------------------------------------------------*
* 3. Map generic message data to pdoc data structure
    IF NOT it_msg_hdr IS INITIAL.
      LOOP AT it_msg_hdr ASSIGNING <fs_msg_hdr>.

        CLEAR: ls_diverse, ls_pod, ls_msg.
        lv_item_id = sy-tabix.

*     3.1 Move IS-U message data to message data structure
        ls_msg-msg_isu_data        = <fs_msg_hdr>.
        ls_msg-proc_ref            = <fs_msg_hdr>-switchnum.
        ls_msg-proc_step_ref       = <fs_msg_hdr>-msgdatanum.
        ls_msg-dextaskid           = <fs_msg_hdr>-dextaskid.
        ls_msg-msg_date            = <fs_msg_hdr>-msgdate.
        ls_msg-msg_time            = <fs_msg_hdr>-msgtime.

        ls_msg-docname_code = <fs_msg_hdr>-category.
        ls_msg-document_ident = <fs_msg_hdr>-idrefnr.

*** Erweiterung für Z-Felder **********************************************************************
        CALL FUNCTION 'Z_LW_POD_DATA'
          EXPORTING
            x_ext_ui = <fs_msg_hdr>-ext_ui
          IMPORTING
            y_sparte = lv_sparte.

*UNH

*BGM

*DTM

*SG1,RFF

*SG2,NAD

*SG2,NAD>>SG3,CTA

*SG2,NAD>>SG3,CTA>>COM

*SG4,IDE
        ls_diverse-item_id                    = lv_item_id.
        ls_diverse-transaction_no             = <fs_msg_hdr>-idrefnr.                                " 24, Vorgangsnummer

*SG4,IDE>>IMD

*SG4,IDE>>DTM
*      ls_diverse-serv_start_date = ???.                                                           " 76, Datum zum geplanten Leistungsbeginn
*      ls_diverse-transf_date = ???.                                                               "294, Datum der Übergabe
*      ls_diverse-transf_time = ???.                                                               "294, Uhrzeit der Übergabe
        ls_diverse-contr_start_date           = <fs_msg_hdr>-moveindate.                             " 92, Vertragsbeginn
        ls_diverse-contr_end_date             = <fs_msg_hdr>-moveoutdate.                            " 93, Vertragsende
        ls_diverse-confcancdat_cust           = <fs_msg_hdr>-zz_cumoveoutdate.                       "Z05, Datum des bereits bestätigten Vertragsendes (Kunde)
        ls_diverse-confcancdat_supp           = <fs_msg_hdr>-zz_sumoveoutdate.                       "Z06, Datum des bereits bestätigten Vertragsendes (Lieferant)
        ls_diverse-validstart_date            = <fs_msg_hdr>-zz_changedate.                          "157, Gültigkeit, Beginndatum
        ls_diverse-endnextposs_from           = <fs_msg_hdr>-zz_possend.                             "471, Ende zum (nächstmöglichem Termin)
        ls_diverse-billyearstart              = <fs_msg_hdr>-zz_strtabrjahr.                         "155, Start des Abrechnungsjahrs bei RLM
        ls_diverse-nextmr_date                = <fs_msg_hdr>-zz_ablweek.                             "752, Nächste turnusmäßige Ablesung
        IF strlen( <fs_msg_hdr>-zz_ablweek ) = 4.
          ls_diverse-nextmr_period = /idxgc/if_constants_ide=>gc_dtm_format_code_106.
        ELSE.
          ls_diverse-nextmr_period = /idxgc/if_constants_ide=>gc_dtm_format_code_104.
        ENDIF.

        ls_diverse-initmr_year                = <fs_msg_hdr>-pland_mr_date.                          "Z09, Erstmalige Turnusablesung
        IF <fs_msg_hdr>-zz_turnusint IS NOT INITIAL.                                                 "672, Turnusintervall
          lv_mrperiod_length_temp = <fs_msg_hdr>-zz_turnusint.
          SHIFT lv_mrperiod_length_temp LEFT DELETING LEADING '0'.
          ls_diverse-mrperiod_length = lv_mrperiod_length_temp.
        ENDIF.
        ls_diverse-startsettldate             = <fs_msg_hdr>-zz_settlestart.                         "158, Bilanzierungsbeginn
        ls_diverse-endsettldate               = <fs_msg_hdr>-zz_settleend.                           "159, Bilanzierungsende
        ls_diverse-noticeper                  = <fs_msg_hdr>-zz_kuendfrist.                          "Z01, Kündigungsfrist des Vertrags
        LOOP AT it_msg_ext ASSIGNING <fs_msg_ext>                                                    "Z10, Kündigungstermin des Vertrags
          WHERE fieldname = 'ZZ_KUENDFRIST' AND guiid = <fs_msg_hdr>-zz_guid_ext.
          ls_diverse-notper_keydate           = <fs_msg_ext>-wert.
          ls_diverse-notper_keyday            = <fs_msg_ext>-wert2.
        ENDLOOP.
        ls_diverse-sos_date_in_proc           = <fs_msg_hdr>-zz_moveinproc.                          "Z07, Lieferbeginndatum in Bearbeitung
        ls_diverse-nextposs_procdat           = <fs_msg_hdr>-zz_nextprocdate.                        "Z08, Datum für nächste Bearbeitung

*SG4,IDE>>STS
        ls_diverse-msgtransreason             = <fs_msg_hdr>-transreason.                            "  7, Transaktionsgrund
        "Kein IDXGC Feld                                                                             "Z17, Transaktionsgrundergänzung für Lieferende bei befristeter Anmeldung
        IF NOT <fs_msg_hdr>-zz_sammelstatus IS INITIAL                                               "E01, Status der Antwort
        OR NOT <fs_msg_hdr>-msgstatus IS INITIAL.
          SPLIT <fs_msg_hdr>-zz_sammelstatus AT ';' INTO TABLE lt_msgstatus.
          APPEND <fs_msg_hdr>-msgstatus TO lt_msgstatus.
          DELETE ADJACENT DUPLICATES FROM lt_msgstatus.
          LOOP AT lt_msgstatus INTO lv_msgstatus.
            ls_msgsts-respstatus = lv_msgstatus.
            ls_msgsts-item_id  = lv_item_id.
            APPEND ls_msgsts TO ls_msg-msgrespstatus.
          ENDLOOP.
        ENDIF.

*SG4,IDE>>FTX
        "siehe Schritt 3.3

*SG4,IDE>>AGR
        ls_diverse-gridus_contrinfo           = <fs_msg_hdr>-zz_statusnenu.                          " 11, Netznutzungsvertrag
        ls_diverse-gridus_contrpay            = <fs_msg_hdr>-zz_zahler.                              "E03, Zahlung der Netznutzung

*SG4,IDE>>SG5,LOC
        ls_diverse-temp_mp                    = <fs_msg_hdr>-zz_tempms.                              "Z02, Temperaturmessstelle
        ls_diverse-temp_mp_prov               = <fs_msg_hdr>-temp_mp.                                "Z02, Temperaturmessstelle
        LOOP AT it_msg_ext INTO ls_msg_ext WHERE fieldname = 'ZZ_PROFILE'.
          ls_diverse-temp_mp_cla              = ls_msg_ext-wert9.
        ENDLOOP.
        ls_diverse-climatezone                = <fs_msg_hdr>-zz_klimazone.                           "Z03, Klimazone

        IF <fs_msg_hdr>-zz_eic_bg IS NOT INITIAL.                                                    "107, Bilanzierungsgebiet
          CLEAR: ls_settl_terr.
          ls_settl_terr-item_id = lv_item_id.
          ls_settl_terr-settlterr_ext = <fs_msg_hdr>-zz_eic_bg.
          "ls_settl_terr-settlterr_cla = .
          APPEND ls_settl_terr TO ls_msg-settl_terr.
        ENDIF.

        IF <fs_msg_hdr>-settlresp IS NOT INITIAL.                                                    "237, Bilanzkreis
          ls_settl_unit-item_id = lv_item_id.
          ls_settl_unit-settlunit_ext = <fs_msg_hdr>-settlresp.
          "ls_settl_unit-settlunit_cla = .
          ls_settl_unit-settlunit_prio = <fs_msg_hdr>-unit_prio.
          APPEND ls_settl_unit TO ls_msg-settl_unit.
        ENDIF.

        IF <fs_msg_hdr>-ext_ui IS NOT INITIAL.
          ls_pod-item_id = lv_item_id.                                                                 "172, Zählpunkt
          ls_pod-loc_func_qual = /idxgc/if_constants_ide=>gc_loc_qual_172.
          ls_pod-ext_ui = <fs_msg_hdr>-ext_ui.
          "transform to internal POD ID
          CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
            EXPORTING
              x_ext_ui     = ls_pod-ext_ui
            IMPORTING
              y_euitrans   = ls_euitrans
            EXCEPTIONS
              not_found    = 1
              system_error = 2
              OTHERS       = 3.
          IF sy-subrc = 0.
            ls_pod-int_ui = ls_euitrans-int_ui.
          ENDIF.

          IF <fs_msg_hdr>-zz_hierarchie IS NOT INITIAL.
            IF <fs_msg_hdr>-zz_hierarchie = 'C'.                                                         "Z01, Zählpunkttyp
              ls_pod-pod_type = zif_datex_co=>co_cci_chardesc_code_z31.
            ELSE.
              ls_pod-pod_type = /idxgc/if_constants_ide=>gc_cci_chardesc_code_z30.
            ENDIF.
          ENDIF.

          IF <fs_msg_hdr>-zz_spebenemess IS NOT INITIAL.                                               "./.->E04, Spannungsebene der Messung
            ls_pod-volt_level_meas = <fs_msg_hdr>-zz_spebenemess.
          ENDIF.

          IF <fs_msg_hdr>-zz_verlustfaktor IS NOT INITIAL.                                             "./.->Z16, Verlustfaktor Trafo
            ls_pod-lossfact_ext = <fs_msg_hdr>-zz_verlustfaktor.
          ENDIF.
          APPEND ls_pod TO ls_msg-pod.
        ENDIF.

        ls_diverse-contrlarea_ext = <fs_msg_hdr>-zz_regelzone.                                       "231, Regelzone

*SG4,IDE>>SG6,RFF
        "Immer das gleiche Feld.
        "ls_diverse-refnr_transreq = <fs_msg_hdr>-zz_idref                                           " TN, Referenz Vorgangsnummer
        "ls_diverse-refnr_transrev =                                                                 "ACW, Referenz auf zu stornierende Vorgangsnummer
        "ls_diverse-ref_to_request =                                                                 "AAV, Referenz auf vorangegangene Anfrage
        ls_diverse-pod_corrected = <fs_msg_hdr>-zz_ext_ui_new.                                       "AVE, Angabe der korrigierten ZPB

        IF <fs_msg_hdr>-zz_dropmsgstatus IS NOT INITIAL.
          CLEAR: ls_rejreas.                                                                           "Z07, Ablehnungsgrund des dritten Marktbeteiligten
          ls_rejreas-item_id = lv_item_id.
          ls_rejreas-respstatus = <fs_msg_hdr>-zz_dropmsgstatus.
          APPEND ls_rejreas TO ls_msg-rejreas_oldsuppl.
        ENDIF.

*SG4,IDE>>SG7,CCI
*SG4,IDE>>SG7,CCI>>CAV
        ls_diverse-prof_code_an = <fs_msg_hdr>-profile.                                              "Z02/Z03/Z04/Z05/Z12, ...
        LOOP AT it_msg_ext INTO ls_msg_ext WHERE fieldname = 'ZZ_PROFILE'.
          ls_diverse-profile_group = ls_msg_ext-wert.
          ls_diverse-prof_code_an = ls_msg_ext-wert2.
          ls_diverse-prof_code_an_cla = ls_msg_ext-wert3.
          ls_diverse-prof_code_sy = ls_msg_ext-wert4.
          ls_diverse-prof_code_sy_cla = ls_msg_ext-wert5.
        ENDLOOP.


        "ls_diverse-prof_code_an =. "Hier ist keine Unterscheidung zwischen E01 und Z10 mehr möglich.
        ls_diverse-meter_proc = <fs_msg_hdr>-metmethod.                                              "./.->E02, Zählverfahren

        IF lv_sparte = zif_datex_co=>co_spartype_strom.
          ls_diverse-volt_level_offt = <fs_msg_hdr>-zz_spebene.                                      "./.->E03, Spannungsebene der Lieferstelle
        ELSEIF lv_sparte = zif_datex_co=>co_spartype_gas.
          ls_diverse-press_level_offt = <fs_msg_hdr>-zz_spebene.                                     "./.->Y01, Druckebene der Entnahme
        ENDIF.

        ls_diverse-cons_distr_ext = <fs_msg_hdr>-zz_verbrauftlg.                                     "./.->E17, Verbrauchsaufteilung für temperaturabhängige Lieferstelle

        IF <fs_msg_hdr>-zz_haushaltsk = 'X'.                                                         "./.->Z15, Gruppenzuordnung (nach EnWG)
          ls_diverse-group_alloc_enwg = /idxgc/if_constants_ide=>gc_cci_chardesc_code_z15.
        ELSEIF <fs_msg_hdr>-zz_haushaltsk = 'N'.                                                                                        "./.->Z18, Gruppenzuordnung (nach EnWG)
          ls_diverse-group_alloc_enwg = /idxgc/if_constants_ide=>gc_cci_chardesc_code_z18.
        ENDIF.

*SG4,IDE>>SG8,SEQ
*---Z01, Zählpunktdaten---*
        CLEAR: ls_pod_quant, ls_time_series.
*SG4,IDE>>SG8,SEQ>>RFF
        ls_pod_quant-item_id = lv_item_id.
        ls_pod_quant-ext_ui = <fs_msg_hdr>-ext_ui.
        ls_time_series-item_id = lv_item_id.
        ls_time_series-ext_ui = <fs_msg_hdr>-ext_ui.

*SG4,IDE>>SG8,SEQ>>SG9,QTY
*SG4,IDE>>SG8,SEQ>>SG9,QTY>>STS
        IF <fs_msg_hdr>-zz_speverbrht IS NOT INITIAL.
          ls_pod_quant-quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_265.                   "265, Arbeit/Leistung für tagesparameterabhängige Lieferstelle (Veranschlagte Jahresmenge)
          ls_pod_quant-quantitiy_ext = <fs_msg_hdr>-zz_speverbrht.
          APPEND ls_pod_quant TO ls_msg-pod_quant.
        ENDIF.

        IF <fs_msg_hdr>-usagefactor IS NOT INITIAL.
          IF lv_sparte = zif_datex_co=>co_spartype_strom.
            ls_pod_quant-quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z08.                 "Z08, Arbeit/Leistung für tagesparameterabhängige Lieferstelle (Angepasste elektrische Arbeit)
            ls_pod_quant-quantitiy_ext = <fs_msg_hdr>-usagefactor.
            ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
            APPEND ls_pod_quant TO ls_msg-pod_quant.
          ELSEIF lv_sparte = zif_datex_co=>co_spartype_gas.
            ls_pod_quant-quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_y02.                 "Y02, TUM-Kundenwert
            ls_pod_quant-quantitiy_ext = round( val = <fs_msg_hdr>-usagefactor dec = 4 mode = cl_abap_math=>round_half_even ).
            SHIFT ls_pod_quant-quantitiy_ext LEFT DELETING LEADING space.
            ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
            APPEND ls_pod_quant TO ls_msg-pod_quant.
          ENDIF.
        ENDIF.

        IF <fs_msg_hdr>-progyearcons IS NOT INITIAL.
          ls_pod_quant-quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_31.                    " 31, Veranschlagte Jahresmenge gesamt
          WRITE <fs_msg_hdr>-progyearcons TO ls_pod_quant-quantitiy_ext NO-GROUPING LEFT-JUSTIFIED DECIMALS 0.
          SHIFT ls_pod_quant-quantitiy_ext LEFT DELETING LEADING space.
          lv_value = ls_pod_quant-quantitiy_ext DIV 1.
          ls_pod_quant-quantitiy_ext = lv_value.
          ls_pod_quant-measure_unit_ext = cl_isu_datex_co=>co_qty_vdew_kwh.
          APPEND ls_pod_quant TO ls_msg-pod_quant.
        ENDIF.

        IF <fs_msg_hdr>-maxdemand IS NOT INITIAL.
          ls_pod_quant-quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z03.                   "Z03, Bisher gemessene Maximalleistung
          ls_pod_quant-quantitiy_ext = <fs_msg_hdr>-maxdemand.
          APPEND ls_pod_quant TO ls_msg-pod_quant.
        ENDIF.

        IF <fs_msg_hdr>-zz_progyearcons IS NOT INITIAL.
          ls_pod_quant-quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z09.                   "Z09, Vorjahresverbauch vom Lieferant
          WRITE <fs_msg_hdr>-zz_progyearcons TO ls_pod_quant-quantitiy_ext NO-GROUPING LEFT-JUSTIFIED DECIMALS 0.
          SHIFT ls_pod_quant-quantitiy_ext LEFT DELETING LEADING space.
          lv_value = ls_pod_quant-quantitiy_ext DIV 1.
          ls_pod_quant-quantitiy_ext = lv_value.
*          ls_pod_quant-quantitiy_ext = <fs_msg_hdr>-zz_progyearcons.
          APPEND ls_pod_quant TO ls_msg-pod_quant.
        ENDIF.

*SG4,IDE>>SG8,SEQ>>SG10,CCI
*SG4,IDE>>SG8,SEQ>>SG10,CCI>>CAV
        IF <fs_msg_hdr>-zz_zeitreihentyp IS NOT INITIAL.
          lv_timeser_counter = 0.
          lv_timeser_counter = lv_timeser_counter + 1.                                               " 15, Summenzeitreihentyp
          ls_time_series-timeser_counter = lv_timeser_counter.
          ls_time_series-timseries_msgcat = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_z21.
          ls_time_series-time_series_type = <fs_msg_hdr>-zz_zeitreihentyp.
          APPEND ls_time_series TO ls_msg-time_series.
        ENDIF.

*SG4,IDE>>SG8,SEQ
*--- Z02, OBIS-Daten ---*
        CLEAR: ls_reg_code_data.
*SG4,IDE>>SG8,SEQ>>RFF
        ls_reg_code_data-item_id = lv_item_id.
        ls_reg_code_data-ext_ui = <fs_msg_hdr>-ext_ui.
        ls_reg_code_data-meternumber = <fs_msg_hdr>-meternr.
        ls_reg_code_data-ref_dev_type = 'MG'.

        LOOP AT it_msg_ext INTO ls_msg_ext WHERE fieldname = 'ZZ_OBISKENNZAHL'.
*SG4,IDE>>SG8,SEQ>>PIA
          ls_reg_code_data-reg_code = ls_msg_ext-wert.                                               "  5, OBIS-Kennzahl

*          ">>>Temporärer Speicher für zusätzliche Daten bis zum Patch(10.02.2014)
*          IF ls_msg_ext-wert7 IS NOT INITIAL OR ls_msg_ext-wert8 IS NOT INITIAL OR ls_msg_ext-wert9 IS NOT INITIAL OR ls_msg_ext-wert10 IS NOT INITIAL.
*            ls_reg_code_data-item_id = 9999999999.
*            APPEND ls_reg_code_data TO ls_msg-reg_code_data.
*          ENDIF.
*          ls_reg_code_data-item_id = lv_item_id.
*          "<<<Temporärer Speicher

*SG4,IDE>>SG8,SEQ>>SG10,CCI
*SG4,IDE>>SG8,SEQ>>SG10,CCI>>CAV
          ls_reg_code_data-int_positons = ls_msg_ext-wert4.                                          " 11, Vor- und Nachkommastellen des Zählwerks
          ls_reg_code_data-dec_places = ls_msg_ext-wert5.                                            " 11, Vor- und Nachkommastellen des Zählwerks
          ls_reg_code_data-reg_label = ls_msg_ext-wert3.                                             "./.->Z63, Lokale Kennzeichnung zu Kontrollzwecken
          IF ls_msg_ext-wert2 = 'ZNS'.                                                               "Z10, Schwachlastfähigkeit
            ls_reg_code_data-tarif_alloc = zif_datex_co=>co_cci_chardesc_code_z59.
          ELSEIF ls_msg_ext-wert2 = 'ZSF'.
            ls_reg_code_data-tarif_alloc = zif_datex_co=>co_cci_chardesc_code_z60.
          ENDIF.
          APPEND ls_reg_code_data TO ls_msg-reg_code_data.
        ENDLOOP.

*SG4,IDE>>SG8,SEQ
*--- Z12, Gemeinderabatt ---*
        ls_diverse-community_dscnt = <fs_msg_hdr>-/idexge/t_id.

*SG4,IDE>>SG8,SEQ
*--- Z03, Zähleinrichtungsdaten ---*
        "IF <fs_msg_hdr>-zz_hierarchie = 'C'.
        CLEAR: ls_meter_device.
*SG4,IDE>>SG8,SEQ>>RFF
        IF <fs_msg_hdr>-meternr IS NOT INITIAL.
          ls_meter_device-item_id = lv_item_id.
          ls_meter_device-ext_ui = <fs_msg_hdr>-ext_ui.
          ls_meter_device-mdev_id_count = lv_item_id.
*SG4,IDE>>SG8,SEQ>>SG10,CCI
*SG4,IDE>>SG8,SEQ>>SG10,CCI>>CAV
          ls_meter_device-metertype_code = <fs_msg_hdr>-zz_metertype.                                  "E13, Zählertyp, Zählertyp
          IF <fs_msg_hdr>-zz_zaehlertyp CP 'G*'.
            ls_meter_device-metersize_value = <fs_msg_hdr>-zz_zaehlertyp.                              "E13, Zählergröße(Gas)
          ELSE.
            ls_meter_device-metertype_value = <fs_msg_hdr>-zz_zaehlertyp.                                "E13, zusätzlicher Zählertyp
          ENDIF.
          ls_meter_device-meternumber = <fs_msg_hdr>-meternr.                                          "E13, Zählertyp, Identifikation/Nummer des Gerätes
          ls_meter_device-ratenumber_code = <fs_msg_hdr>-zz_tarifanz.                                  "E13, Zählertyp, Tarifanzahl
          ls_meter_device-energy_direction = <fs_msg_hdr>-zz_enrichtanz.                               "E13, Zählertyp, Energierichtung
          ls_meter_device-datalog_type = <fs_msg_hdr>-zz_messwerterf.                                  "./.->E12, Messwerterfassung
          APPEND ls_meter_device TO ls_msg-meter_dev.
        ENDIF.
        "ENDIF.
*SG4,IDE>>SG8,SEQ
*--- Z04, Wandlerdaten ---*
        CLEAR: ls_non_meter_device.
        ls_non_meter_device-device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z04.

*SG4,IDE>>SG8,SEQ>>RFF
        ls_non_meter_device-item_id = lv_item_id.
        ls_non_meter_device-meternumber = <fs_msg_hdr>-meternr.

*SG4,IDE>>SG8,SEQ>>SG10,CCI
*SG4,IDE>>SG8,SEQ>>SG10,CCI>>CAV
        LOOP AT it_msg_ext INTO ls_msg_ext
          WHERE fieldname = 'ZZ_WANDLER'
            AND ( wert2 = /idxgc/if_constants_ide=>gc_chara_value_code_miw
              OR  wert2 = /idxgc/if_constants_ide=>gc_chara_value_code_mpw
              OR  wert2 = /idxgc/if_constants_ide=>gc_chara_value_code_mbw
              OR  wert2 = /idxgc/if_constants_ide=>gc_chara_value_code_muw ).
          ls_non_meter_device-device_number = ls_msg_ext-wert.                                     "./.->Z25, Wandler, Identifikation/Nummer des Gerätes
          ls_non_meter_device-transform_type = ls_msg_ext-wert2.                                   "./.->Z25, Wandler, Wandlertyp
          ls_non_meter_device-transform_const = ls_msg_ext-wert3.                                  "./.->Z25, Wandler, Faktor
          ls_non_meter_device-meternumber = ls_msg_ext-wert6.
          APPEND ls_non_meter_device TO ls_msg-non_meter_dev.
        ENDLOOP.

*SG4,IDE>>SG8,SEQ
*--- Z05, Kommunikationseinrichtungsdaten ---*
        CLEAR: ls_non_meter_device.
        ls_non_meter_device-device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z05.
*SG4,IDE>>SG8,SEQ>>RFF
        ls_non_meter_device-item_id = lv_item_id.
*SG4,IDE>>SG8,SEQ>>SG10,CCI
*SG4,IDE>>SG8,SEQ>>SG10,CCI>>CAV
        LOOP AT it_msg_ext INTO ls_msg_ext WHERE fieldname = 'ZZ_KOMMEINR'.
          ls_non_meter_device-device_number = ls_msg_ext-wert.                                       "./.->Z26, Kommunikationseinrichtung, Identifikation/Nummer des Gerätes
          ls_non_meter_device-commequip_type = ls_msg_ext-wert2.                                     "./.->Z26, Kommunikationseinrichtung, Typ                                "./.->Z25, Wandler, Faktor
          ls_non_meter_device-meternumber = ls_msg_ext-wert6.
          APPEND ls_non_meter_device TO ls_msg-non_meter_dev.
        ENDLOOP.

*SG4,IDE>>SG8,SEQ
*--- Z06, Daten der technischen Steuereinrichtung ---*
        CLEAR: ls_non_meter_device.
        ls_non_meter_device-device_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z06.
*SG4,IDE>>SG8,SEQ>>RFF
        ls_non_meter_device-item_id = lv_item_id.
*SG4,IDE>>SG8,SEQ>>SG10,CCI
*SG4,IDE>>SG8,SEQ>>SG10,CCI>>CAV
        LOOP AT it_msg_ext INTO ls_msg_ext WHERE fieldname = 'ZZ_STEUEREINR'.
          ls_non_meter_device-device_number = ls_msg_ext-wert.                                       "./.->Z27, Technische Steuereinrichtung, Identifikation/Nummer des Gerätes
          ls_non_meter_device-contrunit_type = ls_msg_ext-wert2.                                     "./.->Z27, Technische Steuereinrichtung, Typ                                "./.->Z25, Wandler, Faktor
          ls_non_meter_device-meternumber = ls_msg_ext-wert6.
          APPEND ls_non_meter_device TO ls_msg-non_meter_dev.
        ENDLOOP.

*SG4,IDE>>SG8,SEQ
*--- Z07, Konzessionsabgabedaten ---*
        CLEAR: ls_charges_details.

        LOOP AT it_msg_ext INTO ls_msg_ext WHERE fieldname = 'ZZ_KONZABGABE'.
          READ TABLE ls_msg-charges ASSIGNING <fs_charges_details> WITH KEY reg_code = ls_msg_ext-wert ext_ui = ls_msg_ext-wert2.
          IF <fs_charges_details> IS ASSIGNED.
            <fs_charges_details>-franch_fee_cat = ls_msg_ext-wert7.
            <fs_charges_details>-franchise_fee = ls_msg_ext-wert9.
            <fs_charges_details>-fr_fee_amount_ex = ls_msg_ext-wert10.
            <fs_charges_details>-fr_fee_assign = ls_msg_ext-wert4.
          ELSE.
            ls_charges_details-charge_qual = zif_datex_co=>co_seq_action_code_z07.
            ls_charges_details-item_id = lv_item_id.
            ls_charges_details-reg_code = ls_msg_ext-wert.
            ls_charges_details-ext_ui = ls_msg_ext-wert2.
            ls_charges_details-franch_fee_cat = ls_msg_ext-wert7.
            ls_charges_details-franchise_fee = ls_msg_ext-wert9.
            ls_charges_details-fr_fee_amount_ex = ls_msg_ext-wert10.
            ls_charges_details-fr_fee_assign = ls_msg_ext-wert4.
            APPEND ls_charges_details TO ls_msg-charges.
            ADD 1 TO lv_item_id.
          ENDIF.
        ENDLOOP.

*SG4,IDE>>SG8,SEQ
*--- Z08, Berechnung der Tagesmitteltemperatur ---*

*SG4,IDE>>SG8,SEQ
*--- Z09, Mengenumwerterdaten ---*
        ls_non_meter_device-device_qual = zif_datex_co=>co_seq_action_code_z09.

*SG4,IDE>>SG8,SEQ>>RFF
        ls_non_meter_device-item_id = lv_item_id.
        ls_non_meter_device-meternumber = <fs_msg_hdr>-meternr.

*SG4,IDE>>SG8,SEQ>>SG10,CCI
*SG4,IDE>>SG8,SEQ>>SG10,CCI>>CAV
        LOOP AT it_msg_ext INTO ls_msg_ext
          WHERE fieldname = 'ZZ_WANDLER'
            AND ( wert2 = /idxgc/if_constants_ide=>gc_chara_value_code_dmu
              OR  wert2 = /idxgc/if_constants_ide=>gc_chara_value_code_tmu
              OR  wert2 = /idxgc/if_constants_ide=>gc_chara_value_code_zmu ).
          ls_non_meter_device-device_number = ls_msg_ext-wert.                                       "./.->Z64, Mengenumwerter, Identifikation/Nummer des Gerätes
          ls_non_meter_device-transform_type = ls_msg_ext-wert2.                                     "./.->Z64, Mengenumwerter, Wandlertyp
          ls_non_meter_device-meternumber = ls_msg_ext-wert6.
          APPEND ls_non_meter_device TO ls_msg-non_meter_dev.
        ENDLOOP.

*SG4,IDE>>SG8,SEQ
*--- Z10, Steuer-/Abgabeinformationen ---*
        CLEAR: ls_charges_details.
        lv_item_id = sy-tabix.

        LOOP AT it_msg_ext INTO ls_msg_ext WHERE fieldname = 'ZZ_STEUERN'.
          READ TABLE ls_msg-charges ASSIGNING <fs_charges_details> WITH KEY reg_code = ls_msg_ext-wert ext_ui = ls_msg_ext-wert2.
          IF <fs_charges_details> IS ASSIGNED.
            <fs_charges_details>-tax_info = ls_msg_ext-wert3.
          ELSE.
            ls_charges_details-charge_qual = /idxgc/if_constants_ide=>gc_seq_action_code_z10.
            ls_charges_details-item_id = lv_item_id.
            ls_charges_details-reg_code = ls_msg_ext-wert.
            ls_charges_details-ext_ui = ls_msg_ext-wert2.
            ls_charges_details-tax_info = ls_msg_ext-wert3.
            APPEND ls_charges_details TO ls_msg-charges.
            ADD 1 TO lv_item_id.
          ENDIF.
        ENDLOOP.

        lv_item_id = sy-tabix.

*SG4,IDE>>SG12,NAD
*--- UD, Letztverbraucher / Kunde ---*
        IF ( <fs_msg_hdr>-name_l IS NOT INITIAL OR <fs_msg_hdr>-name_f IS NOT INITIAL OR
             <fs_msg_hdr>-street_bu IS NOT INITIAL OR <fs_msg_hdr>-postcode_bu IS NOT INITIAL ).
          "AND <fs_msg_hdr>-zz_hierarchie = abap_true.
          CLEAR: ls_name_address.

          ls_name_address-item_id           = lv_item_id.
          ls_name_address-party_func_qual   = /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
          ls_name_address-ext_ui            = <fs_msg_hdr>-ext_ui.

          IF <fs_msg_hdr>-zz_namesformat = zif_agc_datex_co=>gc_nad_name_format_z01.
*>>> WOLF.A 20160223 FA 01.04.2016
            ls_name_address-fam_comp_name1    = <fs_msg_hdr>-name_f.
            ls_name_address-name_add1         = <fs_msg_hdr>-zz_name_f2.
            ls_name_address-first_name        = <fs_msg_hdr>-name_l.
            ls_name_address-name_add2         = <fs_msg_hdr>-zz_name_l2.
            ls_name_address-ad_title_ext      = <fs_msg_hdr>-/idexge/ptit_ac1.

*            ls_name_address-fam_comp_name1    = <fs_msg_hdr>-name_f.
*            ls_name_address-fam_comp_name2    = <fs_msg_hdr>-zz_name_f2.
*            ls_name_address-first_name1       = <fs_msg_hdr>-name_l.
*            ls_name_address-first_name2       = <fs_msg_hdr>-zz_name_l2.
*<<< WOLF.A 20160223 FA 01.04.2016
          ELSEIF <fs_msg_hdr>-zz_namesformat = zif_agc_datex_co=>gc_nad_name_format_z02.
            ls_name_address-fam_comp_name1    = <fs_msg_hdr>-name_l.
            ls_name_address-fam_comp_name2    = <fs_msg_hdr>-name_f.
            ls_name_address-name_add1         = <fs_msg_hdr>-zz_name_f2.  "WOLF.A 20160223 FA 01.04.2016
            ls_name_address-name_add2         = <fs_msg_hdr>-zz_name_l2.  "WOLF.A 20160223 FA 01.04.2016
          ENDIF.

          ls_name_address-name_format_code  = <fs_msg_hdr>-zz_namesformat.
          IF <fs_msg_hdr>-street_bu(8) = /idxgc/if_constants_ide=>gc_pobox_identcode.
            ls_name_address-poboxid = <fs_msg_hdr>-street_bu+8.
          ELSE.
            ls_name_address-streetname        = <fs_msg_hdr>-street_bu.
          ENDIF.
*>>> WOLF.A, 23.02.2016, FA 01.04.2016: Hausnummer und Zusatz zusammenführen
          TRY .
              IF lr_utility IS NOT BOUND.
                lr_utility = /idxgc/cl_utility_generic=>get_instance( ).
              ENDIF.
              CLEAR lv_houseid.
              lv_houseid = <fs_msg_hdr>-housenr.
              lr_utility->concat_houseid_compl( EXPORTING iv_housenum      = lv_houseid
                                                          iv_house_sup     = <fs_msg_hdr>-housenrext
                                                IMPORTING ev_houseid_compl = ls_name_address-houseid_compl ).
            CATCH /idxgc/cx_utility_error.
              "erstmal nichts tun
          ENDTRY.
*          ls_name_address-houseid           = <fs_msg_hdr>-housenr_bu.
*          ls_name_address-houseid_add       = <fs_msg_hdr>-housenrext_bu.
*<<< WOLF.A, 23.02.2016, FA 01.04.2016: Hausnummer und Zusatz zusammenführen
          ls_name_address-cityname          = <fs_msg_hdr>-city_bu.
          ls_name_address-postalcode        = <fs_msg_hdr>-postcode_bu.
          ls_name_address-countrycode       = <fs_msg_hdr>-zz_country_bu. "THIMEL.R 20150415 M4898 _ext entfernt

*SG4,IDE>>SG12,NAD>>RFF
          ls_diverse-cust_no_suppl = <fs_msg_hdr>-zz_partner_l.
          ls_diverse-cust_no_oldsuppl = <fs_msg_hdr>-zz_partner_la.

          APPEND ls_name_address TO ls_msg-name_address.
        ENDIF.

*SG4,IDE>>SG12,NAD
*--- EO, Letztverbraucher / Kunde ---*
        IF ( <fs_msg_hdr>-zz_namelstabwre IS NOT INITIAL OR <fs_msg_hdr>-zz_namefstabwre IS NOT INITIAL OR
             <fs_msg_hdr>-zz_strabwre IS NOT INITIAL OR <fs_msg_hdr>-zz_plzabwre IS NOT INITIAL ).
          "AND <fs_msg_hdr>-zz_hierarchie = abap_true.
          CLEAR: ls_name_address.

          ls_name_address-item_id           = lv_item_id.
          ls_name_address-party_func_qual   = /idxgc/if_constants_ide=>gc_nad_02_qual_eo.
          ls_name_address-ext_ui            = <fs_msg_hdr>-ext_ui.

          ls_name_address-fam_comp_name1    = <fs_msg_hdr>-zz_namelstabwre.
          ls_name_address-fam_comp_name2    = <fs_msg_hdr>-zz_namelst2abwre.
          ls_name_address-first_name1       = <fs_msg_hdr>-zz_namefstabwre.
          ls_name_address-first_name2       = <fs_msg_hdr>-zz_namefst2abwre.
          ls_name_address-name_format_code  = <fs_msg_hdr>-zz_namesformat.

          ls_name_address-streetname        = <fs_msg_hdr>-zz_strabwre.
          "Erweiterung für Postfach???
*>>> WOLF.A, 23.02.2016, FA 01.04.2016: Hausnummer und Zusatz zusammenführen
          TRY .
              IF lr_utility IS NOT BOUND.
                lr_utility = /idxgc/cl_utility_generic=>get_instance( ).
              ENDIF.
              CLEAR lv_houseid.
              lv_houseid = <fs_msg_hdr>-zz_hsnrergabwre.
              lr_utility->concat_houseid_compl( EXPORTING iv_housenum      = <fs_msg_hdr>-zz_hsnrabwre
                                                          iv_house_sup     = lv_houseid
                                                IMPORTING ev_houseid_compl = ls_name_address-houseid_compl ).
            CATCH /idxgc/cx_utility_error.
              "erstmal nichts tun
          ENDTRY.
*          ls_name_address-houseid           = <fs_msg_hdr>-zz_hsnrabwre.
*          ls_name_address-houseid_add       = <fs_msg_hdr>-zz_hsnrergabwre.
*<<< WOLF.A, 23.02.2016, FA 01.04.2016: Hausnummer und Zusatz zusammenführen
          ls_name_address-cityname          = <fs_msg_hdr>-zz_ortabwre.
          ls_name_address-postalcode        = <fs_msg_hdr>-zz_plzabwre.
          ls_name_address-countrycode       = <fs_msg_hdr>-zz_countryabwre. "THIMEL.R 20150415 M4898 _ext entfernt

          APPEND ls_name_address TO ls_msg-name_address.
        ENDIF.
*SG4,IDE>>SG12,NAD
*--- DEB, Messstellenbetreiber an dem Zählpunkt ---*
        IF <fs_msg_hdr>-zz_mosn IS NOT INITIAL.
          CLEAR: ls_markpar_add.

          ls_markpar_add-item_id = lv_item_id.
          ls_markpar_add-ext_ui = <fs_msg_hdr>-ext_ui.
          ls_markpar_add-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_deb.
          ls_markpar_add-party_identifier = <fs_msg_hdr>-zz_mosn.
*>>>THIMEL.R 20150331 Mantis 4802 Für SDÄ Daten übernehmen
          ls_markpar_add-codelist_agency = <fs_msg_hdr>-/idexge/mos_cdla.
          ls_markpar_add-mos_is_default = <fs_msg_hdr>-/idexge/bill_deb.
*<<<THIMEL.R 20150331 Mantis 4802

          APPEND ls_markpar_add TO ls_msg-marketpartner_add.
        ENDIF.


*SG4,IDE>>SG12,NAD
*--- DDE, Messstellenbetreiber an dem Zählpunkt ---*
        IF <fs_msg_hdr>-zz_mdsn IS NOT INITIAL.
          CLEAR: ls_markpar_add.

          ls_markpar_add-item_id = lv_item_id.
          ls_markpar_add-ext_ui = <fs_msg_hdr>-ext_ui.
          ls_markpar_add-party_func_qual = /idxgc/if_constants_ide=>gc_nad_02_qual_dde.
          ls_markpar_add-party_identifier = <fs_msg_hdr>-zz_mdsn.
*>>>THIMEL.R 20150331 Mantis 4802 Für SDÄ Daten übernehmen
          ls_markpar_add-codelist_agency = <fs_msg_hdr>-/idexge/mds_cdla.
          ls_markpar_add-mds_is_default = <fs_msg_hdr>-/idexge/bill_dde.
*<<<THIMEL.R 20150331 Mantis 4802

*        lv_dunsnr = <fs_msg_hdr>-zz_mdsn.
*        CALL FUNCTION 'ISU_DATEX_IDENT_SP_BY_CODELIST'
*          EXPORTING
*            x_ext_id      = lv_dunsnr
*          IMPORTING
*            y_eservprov   = ls_eservprov
*          EXCEPTIONS
*            not_found     = 1
*            not_unique    = 2
*            not_supported = 3
*            error_occured = 4.
*        IF sy-subrc = 0.
*          ls_markpar_add-serviceid = ls_eservprov-serviceid.
*        ENDIF.

          APPEND ls_markpar_add TO ls_msg-marketpartner_add.
        ENDIF.

*SG4,IDE>>SG12,NAD
*--- DP, Lieferanschrift ---*
        IF ( <fs_msg_hdr>-street IS NOT INITIAL OR <fs_msg_hdr>-postcode IS NOT INITIAL ).
          "AND <fs_msg_hdr>-zz_hierarchie = abap_true.
          CLEAR: ls_name_address.

          ls_name_address-item_id           = lv_item_id.
          ls_name_address-party_func_qual   = /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
          ls_name_address-ext_ui            = <fs_msg_hdr>-ext_ui.
          ls_name_address-streetname        = <fs_msg_hdr>-street.
*>>> WOLF.A, 23.02.2016, FA 01.04.2016: Hausnummer und Zusatz zusammenführen
          TRY .
              IF lr_utility IS NOT BOUND.
                lr_utility = /idxgc/cl_utility_generic=>get_instance( ).
              ENDIF.
              CLEAR lv_houseid.
              lv_houseid = <fs_msg_hdr>-housenr.
              lr_utility->concat_houseid_compl( EXPORTING iv_housenum      = lv_houseid
                                                          iv_house_sup     = <fs_msg_hdr>-housenrext
                                                IMPORTING ev_houseid_compl = ls_name_address-houseid_compl ).
            CATCH /idxgc/cx_utility_error.
              "erstmal nichts tun
          ENDTRY.
*          ls_name_address-houseid           = <fs_msg_hdr>-housenr. "THIMEL.R 20150325 Hausnummer und Zusatz getauscht (Mantis 4832)
*          ls_name_address-houseid_add       = <fs_msg_hdr>-housenrext. "THIMEL.R 20150325 Hausnummer und Zusatz getauscht (Mantis 4832)
*<<< WOLF.A, 23.02.2016, FA 01.04.2016: Hausnummer und Zusatz zusammenführen
          ls_name_address-cityname          = <fs_msg_hdr>-city .
          ls_name_address-postalcode        = <fs_msg_hdr>-postcode.
          ls_name_address-countrycode       = <fs_msg_hdr>-zz_country. "THIMEL.R 20150415 M4898 _ext entfernt

          APPEND ls_name_address TO ls_msg-name_address.
        ENDIF.

        APPEND ls_diverse TO ls_msg-diverse.

        "---------------------------------------------------------------------------
        "Mapping von Feldern für die es kein passendes Feld in den PDoc-Daten gibt
        "---------------------------------------------------------------------------
        ls_attributes-scenario_id = 'CUSTOMER_FIELDS'.

        IF <fs_msg_hdr>-zz_dexformat IS NOT INITIAL.
          ls_attributes-attr_type = 'ZZ_DEXFORMAT'.
          ls_attributes-sequence_num = lines( ls_msg-attribute ).
          ls_attributes-attr_id = <fs_msg_hdr>-zz_dexformat.
          APPEND ls_attributes TO ls_msg-attribute.
        ENDIF.


*     3.2 Move generic add message data to message data structure
        READ TABLE it_msg_add ASSIGNING <fs_msg_add>
          WITH TABLE KEY switchnum  = <fs_msg_hdr>-switchnum
                         msgdatanum = <fs_msg_hdr>-msgdatanum.

        IF sy-subrc EQ 0.
          ASSIGN <fs_msg_add>-adddata->* TO <fs_any>.
          MOVE-CORRESPONDING <fs_any> TO ls_msg_addall.
          ls_msg-msg_add_data_all = ls_msg_addall.
        ENDIF.

*     3.3 Move IS-U comments data to message data structure
        lv_item_id = 1.
        IF NOT it_msg_comments IS INITIAL.
          LOOP AT it_msg_comments ASSIGNING <fs_msg_comment> WHERE switchnum = <fs_msg_hdr>-switchnum.

            APPEND INITIAL LINE TO ls_msg-msgcomments ASSIGNING <fs_msgcomment>.
            <fs_msgcomment>-item_id         = lv_item_id.
            <fs_msgcomment>-commentnum      = <fs_msg_comment>-commentnum.
            <fs_msgcomment>-commentsubnum   = '001'.
            IF <fs_msg_comment>-commenttag IS INITIAL.
              <fs_msgcomment>-text_subj_qual = /idxgc/if_constants_ide=>gc_msg_comments_acb.
            ELSE.
              <fs_msgcomment>-text_subj_qual  = <fs_msg_comment>-commenttag.
            ENDIF.
            <fs_msgcomment>-free_text_value = <fs_msg_comment>-commenttxt.
          ENDLOOP.
        ENDIF.

        INSERT ls_msg INTO TABLE es_pdoc_data-msg_data.
      ENDLOOP.

*--------------------------------------------------------------------*
    ELSEIF it_msg_add IS NOT INITIAL. " if only add data shall be mapped
      LOOP AT it_msg_add ASSIGNING <fs_msg_add>.
        CLEAR ls_msg.

        ls_msg-switchnum  = <fs_msg_add>-switchnum.
        ls_msg-msgdatanum = <fs_msg_add>-msgdatanum.

        ASSIGN <fs_msg_add>-adddata->* TO <fs_any>.
        MOVE-CORRESPONDING <fs_any> TO ls_msg_addall.
        ls_msg-msg_add_data_all = ls_msg_addall.
        INSERT ls_msg INTO TABLE es_pdoc_data-msg_data.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD map_mscons_idoc_idxgc_to_old.

* Deklaration alter Basistyp /EVUIT/ISU_MSCONS_V22D
    DATA: ls_idexge_e1vdewunb_2 TYPE /idexge/e1vdewunb_2,
          ls_isidex_e1vdewunh_1 TYPE /isidex/e1vdewunh_1,
          ls_isidex_e1vdewbgm_1 TYPE /isidex/e1vdewbgm_1,
          ls_isidex_e1vdewdtm_1 TYPE /isidex/e1vdewdtm_1,
          ls_isidex_e1vdewrff_1 TYPE /isidex/e1vdewrff_1,
          ls_isidex_e1vdewdtm_2 TYPE /isidex/e1vdewdtm_2,
          ls_idexge_e1vdewnad_7 TYPE /idexge/e1vdewnad_7,
          ls_isidex_e1vdewcta_1 TYPE /isidex/e1vdewcta_1,
          ls_isidex_e1vdewcom_1 TYPE /isidex/e1vdewcom_1,
          ls_idexge_e1vdewloc_4 TYPE /idexge/e1vdewloc_4,
          ls_isidex_e1vdewdtm_3 TYPE /isidex/e1vdewdtm_3,
          ls_isidex_e1vdewrff_2 TYPE /isidex/e1vdewrff_2,
          ls_idexge_e1vdewcci_3 TYPE /idexge/e1vdewcci_3,
          ls_isidex_e1vdewlin_1 TYPE /isidex/e1vdewlin_1,
          ls_evuit_e1vdewpia_4  TYPE /evuit/e1vdewpia_4,
          ls_idexge_e1vdewqty_3 TYPE /idexge/e1vdewqty_3,
          ls_isidex_e1vdewdtm_4 TYPE /isidex/e1vdewdtm_4,
          ls_idexge_e1vdewsts_3 TYPE /idexge/e1vdewsts_3,
          ls_idexge_e1vdewcci_4 TYPE /idexge/e1vdewcci_4,
          ls_idexge_e1vdewmea_2 TYPE /idexge/e1vdewmea_2,
          ls_isidex_e1vdewdtm_5 TYPE /isidex/e1vdewdtm_5,
          ls_isidex_e1vdewuns_1 TYPE /isidex/e1vdewuns_1,
          ls_idexge_e1vdewnad_8 TYPE /idexge/e1vdewnad_8,
          ls_isidex_e1vdewunt_1 TYPE /isidex/e1vdewunt_1,
          ls_idexge_e1vdewunz_1 TYPE /idexge/e1vdewunz_1.

* Deklaration neuer Basistyp /IDXGC/MSCONS_02
    DATA:    ls_idxgc_e1_una_01 TYPE /idxgc/e1_una_01,
             ls_idxgc_e1_unb_01 TYPE /idxgc/e1_unb_01,
             ls_idxgc_e1_unh_01 TYPE /idxgc/e1_unh_01,
             ls_idxgc_e1_bgm_02 TYPE /idxgc/e1_bgm_02,
             ls_idxgc_e1_dtm_01 TYPE /idxgc/e1_dtm_01,
             ls_idxgc_e1_cux_01 TYPE /idxgc/e1_cux_01,
             ls_idxgc_e1_rff_07 TYPE /idxgc/e1_rff_07,
             ls_idxgc_e1_dtm_02 TYPE /idxgc/e1_dtm_02,
             ls_idxgc_e1_nad_03 TYPE /idxgc/e1_nad_03,
             ls_idxgc_e1_rff_08 TYPE /idxgc/e1_rff_08,
             ls_idxgc_e1_dtm_03 TYPE /idxgc/e1_dtm_03,
             ls_idxgc_e1_cta_03 TYPE /idxgc/e1_cta_03,
             ls_idxgc_e1_com_01 TYPE /idxgc/e1_com_01,
             ls_idxgc_e1_uns_01 TYPE /idxgc/e1_uns_01,
             ls_idxgc_e1_nad_04 TYPE /idxgc/e1_nad_04,
             ls_idxgc_e1_loc_02 TYPE /idxgc/e1_loc_02,
             ls_idxgc_e1_dtm_04 TYPE /idxgc/e1_dtm_04,
             ls_idxgc_e1_rff_09 TYPE /idxgc/e1_rff_09,
             ls_idxgc_e1_dtm_05 TYPE /idxgc/e1_dtm_05,
             ls_idxgc_e1_cci_01 TYPE /idxgc/e1_cci_01,
             ls_idxgc_e1_dtm_06 TYPE /idxgc/e1_dtm_06,
             ls_idxgc_e1_lin_01 TYPE /idxgc/e1_lin_01,
             ls_idxgc_e1_pia_01 TYPE /idxgc/e1_pia_01,
             ls_idxgc_e1_imd_01 TYPE /idxgc/e1_imd_01,
             ls_idxgc_e1_pri_01 TYPE /idxgc/e1_pri_01,
             ls_idxgc_e1_nad_05 TYPE /idxgc/e1_nad_05,
             ls_idxgc_e1_moa_01 TYPE /idxgc/e1_moa_01,
             ls_idxgc_e1_qty_01 TYPE /idxgc/e1_qty_01,
             ls_idxgc_e1_dtm_07 TYPE /idxgc/e1_dtm_07,
             ls_idxgc_e1_sts_01 TYPE /idxgc/e1_sts_01,
             ls_idxgc_e1_cci_02 TYPE /idxgc/e1_cci_02,
             ls_idxgc_e1_mea_02 TYPE /idxgc/e1_mea_02,
             ls_idxgc_e1_dtm_08 TYPE /idxgc/e1_dtm_08,
             ls_idxgc_e1_cnt_01 TYPE /idxgc/e1_cnt_01,
             ls_idxgc_e1_unt_01 TYPE /idxgc/e1_unt_01,
             ls_idxgc_e1_unz_01 TYPE /idxgc/e1_unz_01.

    FIELD-SYMBOLS:
      <fs_edidd_old>   TYPE edidd,
      <fs_edidd_idxgc> TYPE edidd.

    LOOP AT it_idoc_data ASSIGNING <fs_edidd_idxgc>.
      APPEND INITIAL LINE TO rt_idoc_data ASSIGNING <fs_edidd_old>.
      <fs_edidd_old>-mandt  = <fs_edidd_idxgc>-mandt.
      <fs_edidd_old>-docnum = <fs_edidd_idxgc>-docnum.
      <fs_edidd_old>-segnum = <fs_edidd_idxgc>-segnum.
*      <fs_edidd_old>-SEGNAM = <fs_edidd_idxgc>-SEGNAM.
      <fs_edidd_old>-psgnum = <fs_edidd_idxgc>-psgnum.
      <fs_edidd_old>-hlevel = <fs_edidd_idxgc>-hlevel.
      <fs_edidd_old>-dtint2 = <fs_edidd_idxgc>-dtint2.


      CASE <fs_edidd_idxgc>-segnam.
        WHEN '/IDXGC/E1_UNB_01'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWUNB_2'.
          "...sdata mapping und Elemente übertragen...
          ls_idxgc_e1_unb_01 = <fs_edidd_idxgc>-sdata.
*ls_idexge_e1vdewunb_2-ADDRESS_BACK.
*ls_idexge_e1vdewunb_2-ADDRESS_FORWARD.

          ls_idexge_e1vdewunb_2-syntax_ident = ls_idxgc_e1_unb_01-syntax_identifier.
          ls_idexge_e1vdewunb_2-syntax_version = ls_idxgc_e1_unb_01-syntax_version_number.
*ls_idxgc_e1_unb_01-SERV_CODE_LIST_DIREC_VERS_NO =
*ls_idxgc_e1_unb_01-CHARACTER_ENCODING_CODED =
          ls_idexge_e1vdewunb_2-sender = ls_idxgc_e1_unb_01-interchange_sender_ident.
          ls_idexge_e1vdewunb_2-sender_type = ls_idxgc_e1_unb_01-identification_code_qualifier1.
*ls_idxgc_e1_unb_01-INTERCHANGE_SENDER_INTERNAL_ID =
*ls_idxgc_e1_unb_01-INTERCHANGE_SENDER_INT_SUB_ID =
          ls_idexge_e1vdewunb_2-receiver = ls_idxgc_e1_unb_01-interchange_recipient_ident.
          ls_idexge_e1vdewunb_2-receiver_type = ls_idxgc_e1_unb_01-identification_code_qualifier2.
*ls_idxgc_e1_unb_01-INTERCHANGE_RECIP_INTERNAL_ID =
*ls_idxgc_e1_unb_01-INTERCHANGE_RECIP_INT_SUB_ID =
          ls_idexge_e1vdewunb_2-date_gen = ls_idxgc_e1_unb_01-date.
          ls_idexge_e1vdewunb_2-time_gen = ls_idxgc_e1_unb_01-time.
          ls_idexge_e1vdewunb_2-bulk_ref = ls_idxgc_e1_unb_01-interchange_control_reference.
          ls_idexge_e1vdewunb_2-receiver_ref = ls_idxgc_e1_unb_01-recipient_reference_passwort.
          ls_idexge_e1vdewunb_2-receiver_ref_type = ls_idxgc_e1_unb_01-recipient_ref_passwort_qual.
          ls_idexge_e1vdewunb_2-util_ref = ls_idxgc_e1_unb_01-application_reference.
          ls_idexge_e1vdewunb_2-proc_prio = ls_idxgc_e1_unb_01-processing_priority_code.
          ls_idexge_e1vdewunb_2-conf_request = ls_idxgc_e1_unb_01-acknowledgement_request.
          ls_idexge_e1vdewunb_2-exch_agree_ident = ls_idxgc_e1_unb_01-communication_agreement_id.
          ls_idexge_e1vdewunb_2-test_ident = ls_idxgc_e1_unb_01-test_indicator.

          <fs_edidd_old>-sdata = ls_idexge_e1vdewunb_2.

        WHEN '/IDXGC/E1_UNH_01'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWUNH_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_unh_01 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewunh_1-referencenumber = ls_idxgc_e1_unh_01-message_reference_number.
          ls_isidex_e1vdewunh_1-identifier = ls_idxgc_e1_unh_01-message_type.
          ls_isidex_e1vdewunh_1-versionnumber = ls_idxgc_e1_unh_01-message_version_number.
          ls_isidex_e1vdewunh_1-releasenumber = ls_idxgc_e1_unh_01-message_release_number.
          ls_isidex_e1vdewunh_1-controlagency = ls_idxgc_e1_unh_01-controlling_agency_coded_1.
          ls_isidex_e1vdewunh_1-assoccode = ls_idxgc_e1_unh_01-association_assigned_code.
          ls_isidex_e1vdewunh_1-accessref = ls_idxgc_e1_unh_01-common_access_reference.
          ls_isidex_e1vdewunh_1-transfernumber = ls_idxgc_e1_unh_01-sequence_of_transfers.
          ls_isidex_e1vdewunh_1-indicator = ls_idxgc_e1_unh_01-first_and_last_transfer.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewunh_1.

        WHEN '/IDXGC/E1_BGM_02'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWBGM_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_bgm_02 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewbgm_1-name = ls_idxgc_e1_bgm_02-document_name_code.
          ls_isidex_e1vdewbgm_1-codelist = ls_idxgc_e1_bgm_02-code_list_identification_code.
          ls_isidex_e1vdewbgm_1-codelistagency = ls_idxgc_e1_bgm_02-code_list_resp_agency_code.
          ls_isidex_e1vdewbgm_1-fullname = ls_idxgc_e1_bgm_02-document_name.
          ls_isidex_e1vdewbgm_1-documentnumber = ls_idxgc_e1_bgm_02-document_identifier.
          ls_isidex_e1vdewbgm_1-version = ls_idxgc_e1_bgm_02-version_identifier.
          ls_isidex_e1vdewbgm_1-revision = ls_idxgc_e1_bgm_02-revision_identifier.
          ls_isidex_e1vdewbgm_1-documentfunc = ls_idxgc_e1_bgm_02-message_function_code.
          ls_isidex_e1vdewbgm_1-responsetype = ls_idxgc_e1_bgm_02-response_type_code.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewbgm_1.

        WHEN '/IDXGC/E1_DTM_01'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWDTM_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_dtm_01 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewdtm_1-datumqualifier = ls_idxgc_e1_dtm_01-date_time_period_fc_qualifier.
          ls_isidex_e1vdewdtm_1-datum = ls_idxgc_e1_dtm_01-date_time_period_value.
          ls_isidex_e1vdewdtm_1-format = ls_idxgc_e1_dtm_01-date_time_period_format_code.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewdtm_1.

        WHEN '/IDXGC/E1_RFF_07'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWRFF_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_rff_07 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewrff_1-referencequalifier = ls_idxgc_e1_rff_07-reference_code_qualifier.
          ls_isidex_e1vdewrff_1-referencenumber = ls_idxgc_e1_rff_07-reference_identifier.
          ls_isidex_e1vdewrff_1-linenumber = ls_idxgc_e1_rff_07-document_line_identifier.
          ls_isidex_e1vdewrff_1-versionnumber = ls_idxgc_e1_rff_07-version_identifier.
          ls_isidex_e1vdewrff_1-revision = ls_idxgc_e1_rff_07-revision_identifier.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewrff_1.

        WHEN '/IDXGC/E1_DTM_02'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWDTM_2'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_dtm_02 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewdtm_2-datumqualifier = ls_idxgc_e1_dtm_02-date_time_period_fc_qualifier.
          ls_isidex_e1vdewdtm_2-datum = ls_idxgc_e1_dtm_02-date_time_period_value.
          ls_isidex_e1vdewdtm_2-format = ls_idxgc_e1_dtm_02-date_time_period_format_code.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewdtm_2.

        WHEN '/IDXGC/E1_NAD_03'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWNAD_7'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_nad_03 = <fs_edidd_idxgc>-sdata.

          ls_idexge_e1vdewnad_7-action = ls_idxgc_e1_nad_03-party_function_code_qualifier.
          ls_idexge_e1vdewnad_7-partner = ls_idxgc_e1_nad_03-party_identifier.
          ls_idexge_e1vdewnad_7-codelist = ls_idxgc_e1_nad_03-code_list_ident_code_1.
          ls_idexge_e1vdewnad_7-codelistagency = ls_idxgc_e1_nad_03-code_list_resp_agency_code_1.
          ls_idexge_e1vdewnad_7-nameaddress1 = ls_idxgc_e1_nad_03-name_and_address_description_1.
          ls_idexge_e1vdewnad_7-nameaddress2 = ls_idxgc_e1_nad_03-name_and_address_description_2.
          ls_idexge_e1vdewnad_7-nameaddress3 = ls_idxgc_e1_nad_03-name_and_address_description_3.
          ls_idexge_e1vdewnad_7-nameaddress4 = ls_idxgc_e1_nad_03-name_and_address_description_4.
          ls_idexge_e1vdewnad_7-nameaddress5 = ls_idxgc_e1_nad_03-name_and_address_description_5.
          ls_idexge_e1vdewnad_7-partnername1 = ls_idxgc_e1_nad_03-party_name_1.
          ls_idexge_e1vdewnad_7-partnername2 = ls_idxgc_e1_nad_03-party_name_2.
          ls_idexge_e1vdewnad_7-partnername3 = ls_idxgc_e1_nad_03-party_name_3.
          ls_idexge_e1vdewnad_7-partnername4 = ls_idxgc_e1_nad_03-party_name_4.
          ls_idexge_e1vdewnad_7-partnername5 = ls_idxgc_e1_nad_03-party_name_5.
          ls_idexge_e1vdewnad_7-partnerformat = ls_idxgc_e1_nad_03-party_name_format_code.
          ls_idexge_e1vdewnad_7-street1 = ls_idxgc_e1_nad_03-street_no_or_po_box_ident_1.
          ls_idexge_e1vdewnad_7-street2 = ls_idxgc_e1_nad_03-street_no_or_po_box_ident_2.
          ls_idexge_e1vdewnad_7-street3 = ls_idxgc_e1_nad_03-street_no_or_po_box_ident_3.
          ls_idexge_e1vdewnad_7-street4 = ls_idxgc_e1_nad_03-street_no_or_po_box_ident_4.
          ls_idexge_e1vdewnad_7-city = ls_idxgc_e1_nad_03-city_name.
          ls_idexge_e1vdewnad_7-region_id = ls_idxgc_e1_nad_03-country_subdivision_identifier.
          ls_idexge_e1vdewnad_7-region_code_list = ls_idxgc_e1_nad_03-code_list_ident_code_2.
          ls_idexge_e1vdewnad_7-region_codelist_agency = ls_idxgc_e1_nad_03-code_list_resp_agency_code_2.
          ls_idexge_e1vdewnad_7-region = ls_idxgc_e1_nad_03-country_subdivision_name.
          ls_idexge_e1vdewnad_7-zipcode = ls_idxgc_e1_nad_03-postal_identification_code.
          ls_idexge_e1vdewnad_7-country = ls_idxgc_e1_nad_03-country_identifier.

          <fs_edidd_old>-sdata = ls_idexge_e1vdewnad_7.

        WHEN '/IDXGC/E1_CTA_03'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWCTA_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_cta_03 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewcta_1-contactfunc = ls_idxgc_e1_cta_03-contact_function_code.
          ls_isidex_e1vdewcta_1-contactid = ls_idxgc_e1_cta_03-contact_identifier.
          ls_isidex_e1vdewcta_1-contactname = ls_idxgc_e1_cta_03-contact_name.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewcta_1.

        WHEN '/IDXGC/E1_COM_01'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWCOM_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_com_01 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewcom_1-commnumber = ls_idxgc_e1_com_01-communic_address_identifier.
          ls_isidex_e1vdewcom_1-commqualf = ls_idxgc_e1_com_01-communication_means_type_code.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewcom_1.

        WHEN '/IDXGC/E1_UNS_01'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWUNS_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_uns_01 = <fs_edidd_idxgc>-sdata.
          ls_isidex_e1vdewuns_1-section_id = ls_idxgc_e1_uns_01-section_identification.
          <fs_edidd_old>-sdata = ls_isidex_e1vdewuns_1.

        WHEN '/IDXGC/E1_NAD_04'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWNAD_8'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_nad_04 = <fs_edidd_idxgc>-sdata.

          ls_idexge_e1vdewnad_8-action = ls_idxgc_e1_nad_04-party_function_code_qualifier.

          <fs_edidd_old>-sdata = ls_idexge_e1vdewnad_8.


        WHEN '/IDXGC/E1_LOC_02'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWLOC_4'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_loc_02 = <fs_edidd_idxgc>-sdata.

          ls_idexge_e1vdewloc_4-place_qualifier = ls_idxgc_e1_loc_02-location_func_code_quali.
          ls_idexge_e1vdewloc_4-place_id = ls_idxgc_e1_loc_02-location_identifier.

          <fs_edidd_old>-sdata = ls_idexge_e1vdewloc_4.


        WHEN '/IDXGC/E1_DTM_04'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWDTM_3'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_dtm_04 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewdtm_3-datumqualifier = ls_idxgc_e1_dtm_04-date_time_period_fc_qualifier.
          ls_isidex_e1vdewdtm_3-datum = ls_idxgc_e1_dtm_04-date_time_period_value.
          ls_isidex_e1vdewdtm_3-format = ls_idxgc_e1_dtm_04-date_time_period_format_code.

          <fs_edidd_old>-sdata =  ls_isidex_e1vdewdtm_3.

        WHEN '/IDXGC/E1_RFF_09'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWRFF_2'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_rff_09 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewrff_2-referencequalifier = ls_idxgc_e1_rff_09-reference_code_qualifier.
          ls_isidex_e1vdewrff_2-referencenumber = ls_idxgc_e1_rff_09-reference_identifier.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewrff_2.

        WHEN '/IDXGC/E1_CCI_01'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWCCI_3'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_cci_01 = <fs_edidd_idxgc>-sdata.

          ls_idexge_e1vdewcci_3-property_class = ls_idxgc_e1_cci_01-class_type_code.
          ls_idexge_e1vdewcci_3-property_measure = ls_idxgc_e1_cci_01-measured_attribute_code.
          ls_idexge_e1vdewcci_3-measurement_significance = ls_idxgc_e1_cci_01-measurement_significance_code.
          ls_idexge_e1vdewcci_3-measurement_attribute_id = ls_idxgc_e1_cci_01-non_discr_measurement_name_cod.
          ls_idexge_e1vdewcci_3-characteristic_id = ls_idxgc_e1_cci_01-characteristic_descr_code. " Maxim Schmidt, 23.09.2015, Mantis 5078: GDA 20, Fehler in der MSCONS Verarbeitung Zwischenablesung

          <fs_edidd_old>-sdata = ls_idexge_e1vdewcci_3.

        WHEN '/IDXGC/E1_LIN_01'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWLIN_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_lin_01 = <fs_edidd_idxgc>-sdata.
          ls_isidex_e1vdewlin_1-line_item_number = ls_idxgc_e1_lin_01-line_item_identifier.
          <fs_edidd_old>-sdata = ls_isidex_e1vdewlin_1.

        WHEN '/IDXGC/E1_PIA_01'.
          <fs_edidd_old>-segnam = '/EVUIT/E1VDEWPIA_4'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_pia_01 = <fs_edidd_idxgc>-sdata.

          ls_evuit_e1vdewpia_4-product_id = ls_idxgc_e1_pia_01-product_ident_code_qualifier.
          ls_evuit_e1vdewpia_4-item_number_1 = ls_idxgc_e1_pia_01-item_identifier_1.
          ls_evuit_e1vdewpia_4-item_number_type_1 = ls_idxgc_e1_pia_01-item_type_ident_code_1.

          <fs_edidd_old>-sdata = ls_evuit_e1vdewpia_4.

        WHEN '/IDXGC/E1_QTY_01'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWQTY_3' .
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_qty_01 = <fs_edidd_idxgc>-sdata.

          ls_idexge_e1vdewqty_3-quantity_qualifier = ls_idxgc_e1_qty_01-quantity_type_code_qualifier.
          ls_idexge_e1vdewqty_3-quantity = ls_idxgc_e1_qty_01-quantity.
          ls_idexge_e1vdewqty_3-measure_unit_qualifier = ls_idxgc_e1_qty_01-measurement_unit_code.

          <fs_edidd_old>-sdata = ls_idexge_e1vdewqty_3.

        WHEN  '/IDXGC/E1_DTM_07'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWDTM_4'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_dtm_07 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewdtm_4-datumqualifier = ls_idxgc_e1_dtm_07-date_time_period_fc_qualifier.
          ls_isidex_e1vdewdtm_4-datum = ls_idxgc_e1_dtm_07-date_time_period_value.
          ls_isidex_e1vdewdtm_4-format = ls_idxgc_e1_dtm_07-date_time_period_format_code.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewdtm_4.

        WHEN '/IDXGC/E1_STS_01'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWSTS_3'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_sts_01 = <fs_edidd_idxgc>-sdata.

          ls_idexge_e1vdewsts_3-category = ls_idxgc_e1_sts_01-status_category_code_1.
          ls_idexge_e1vdewsts_3-category_code_list_id = ls_idxgc_e1_sts_01-code_list_ident_code_1.
          ls_idexge_e1vdewsts_3-category_agency = ls_idxgc_e1_sts_01-code_list_resp_agency_code_1.
          ls_idexge_e1vdewsts_3-status_description_code = ls_idxgc_e1_sts_01-status_description_code_1.
          ls_idexge_e1vdewsts_3-status_agency = ls_idxgc_e1_sts_01-code_list_ident_code_2.
          ls_idexge_e1vdewsts_3-status_description = ls_idxgc_e1_sts_01-status_description_1.
          ls_idexge_e1vdewsts_3-reason_1_description_code = ls_idxgc_e1_sts_01-status_reason_descr_code_1.

          <fs_edidd_old>-sdata = ls_idexge_e1vdewsts_3.


        WHEN '/IDXGC/E1_CCI_02'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWCCI_4'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_cci_02 = <fs_edidd_idxgc>-sdata.

          ls_idexge_e1vdewcci_4-property_class = ls_idxgc_e1_cci_02-property_class.
          ls_idexge_e1vdewcci_4-property_measure = ls_idxgc_e1_cci_02-property_measure.
          ls_idexge_e1vdewcci_4-measurement_significance = ls_idxgc_e1_cci_02-measurement_significance.
          ls_idexge_e1vdewcci_4-measurement_attribute_id = ls_idxgc_e1_cci_02-measurement_attribute_id.

          <fs_edidd_old>-sdata = ls_idexge_e1vdewcci_4.


*        WHEN '/IDEXGE/E1VDEWMEA_2'.
*          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_MEA_02'.
*          "...sdata mapping und Elemente übertragen...

        WHEN '/IDXGC/E1_DTM_08'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWDTM_5'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_dtm_08 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewdtm_5-datumqualifier = ls_idxgc_e1_dtm_08-date_time_period_fc_qualifier.
          ls_isidex_e1vdewdtm_5-datum = ls_idxgc_e1_dtm_08-date_time_period_value.
          ls_isidex_e1vdewdtm_5-format = ls_idxgc_e1_dtm_08-date_time_period_format_code.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewdtm_5.

        WHEN '/IDXGC/E1_UNT_01'.
          <fs_edidd_old>-segnam = '/ISIDEX/E1VDEWUNT_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_unt_01 = <fs_edidd_idxgc>-sdata.

          ls_isidex_e1vdewunt_1-numseg = ls_idxgc_e1_unt_01-number_of_segments_in_message.
          ls_isidex_e1vdewunt_1-refnum = ls_idxgc_e1_unt_01-message_reference_number.

          <fs_edidd_old>-sdata = ls_isidex_e1vdewunt_1.

        WHEN '/IDXGC/E1_UNZ_01'.
          <fs_edidd_old>-segnam = '/IDEXGE/E1VDEWUNZ_1'.
          "...sdata mapping und Elemente übertragen...

          ls_idxgc_e1_unz_01 = <fs_edidd_idxgc>-sdata.

          ls_idexge_e1vdewunz_1-dexcount = ls_idxgc_e1_unz_01-interchange_control_count.
          ls_idexge_e1vdewunz_1-bulk_ref = ls_idxgc_e1_unz_01-interchange_control_reference.

          <fs_edidd_old>-sdata = ls_idexge_e1vdewunz_1.


      ENDCASE.


    ENDLOOP.



  ENDMETHOD.


  METHOD map_mscons_idoc_old_to_idxgc.

* Deklaration alter Basistyp /EVUIT/ISU_MSCONS_V22D
    DATA: ls_idexge_e1vdewunb_2 TYPE /idexge/e1vdewunb_2,
          ls_isidex_e1vdewunh_1 TYPE /isidex/e1vdewunh_1,
          ls_isidex_e1vdewbgm_1 TYPE /isidex/e1vdewbgm_1,
          ls_isidex_e1vdewdtm_1 TYPE /isidex/e1vdewdtm_1,
          ls_isidex_e1vdewrff_1 TYPE /isidex/e1vdewrff_1,
          ls_isidex_e1vdewdtm_2 TYPE /isidex/e1vdewdtm_2,
          ls_idexge_e1vdewnad_7 TYPE /idexge/e1vdewnad_7,
          ls_isidex_e1vdewcta_1 TYPE /isidex/e1vdewcta_1,
          ls_isidex_e1vdewcom_1 TYPE /isidex/e1vdewcom_1,
          ls_idexge_e1vdewloc_4 TYPE /idexge/e1vdewloc_4,
          ls_isidex_e1vdewdtm_3 TYPE /isidex/e1vdewdtm_3,
          ls_isidex_e1vdewrff_2 TYPE /isidex/e1vdewrff_2,
          ls_idexge_e1vdewcci_3 TYPE /idexge/e1vdewcci_3,
          ls_isidex_e1vdewlin_1 TYPE /isidex/e1vdewlin_1,
          ls_evuit_e1vdewpia_4  TYPE /evuit/e1vdewpia_4,
          ls_idexge_e1vdewqty_3 TYPE /idexge/e1vdewqty_3,
          ls_isidex_e1vdewdtm_4 TYPE /isidex/e1vdewdtm_4,
          ls_idexge_e1vdewsts_3 TYPE /idexge/e1vdewsts_3,
          ls_idexge_e1vdewcci_4 TYPE /idexge/e1vdewcci_4,
          ls_idexge_e1vdewmea_2 TYPE /idexge/e1vdewmea_2,
          ls_isidex_e1vdewdtm_5 TYPE /isidex/e1vdewdtm_5,
          ls_isidex_e1vdewuns_1 TYPE /isidex/e1vdewuns_1,
          ls_idexge_e1vdewnad_8 TYPE /idexge/e1vdewnad_8,
          ls_isidex_e1vdewunt_1 TYPE /isidex/e1vdewunt_1,
          ls_idexge_e1vdewunz_1 TYPE /idexge/e1vdewunz_1.

* Deklaration neuer Basistyp /IDXGC/MSCONS_02
    DATA:    ls_idxgc_e1_una_01 TYPE /idxgc/e1_una_01,
             ls_idxgc_e1_unb_01 TYPE /idxgc/e1_unb_01,
             ls_idxgc_e1_unh_01 TYPE /idxgc/e1_unh_01,
             ls_idxgc_e1_bgm_02 TYPE /idxgc/e1_bgm_02,
             ls_idxgc_e1_dtm_01 TYPE /idxgc/e1_dtm_01,
             ls_idxgc_e1_cux_01 TYPE /idxgc/e1_cux_01,
             ls_idxgc_e1_rff_07 TYPE /idxgc/e1_rff_07,
             ls_idxgc_e1_dtm_02 TYPE /idxgc/e1_dtm_02,
             ls_idxgc_e1_nad_03 TYPE /idxgc/e1_nad_03,
             ls_idxgc_e1_rff_08 TYPE /idxgc/e1_rff_08,
             ls_idxgc_e1_dtm_03 TYPE /idxgc/e1_dtm_03,
             ls_idxgc_e1_cta_03 TYPE /idxgc/e1_cta_03,
             ls_idxgc_e1_com_01 TYPE /idxgc/e1_com_01,
             ls_idxgc_e1_uns_01 TYPE /idxgc/e1_uns_01,
             ls_idxgc_e1_nad_04 TYPE /idxgc/e1_nad_04,
             ls_idxgc_e1_loc_02 TYPE /idxgc/e1_loc_02,
             ls_idxgc_e1_dtm_04 TYPE /idxgc/e1_dtm_04,
             ls_idxgc_e1_rff_09 TYPE /idxgc/e1_rff_09,
             ls_idxgc_e1_dtm_05 TYPE /idxgc/e1_dtm_05,
             ls_idxgc_e1_cci_01 TYPE /idxgc/e1_cci_01,
             ls_idxgc_e1_dtm_06 TYPE /idxgc/e1_dtm_06,
             ls_idxgc_e1_lin_01 TYPE /idxgc/e1_lin_01,
             ls_idxgc_e1_pia_01 TYPE /idxgc/e1_pia_01,
             ls_idxgc_e1_imd_01 TYPE /idxgc/e1_imd_01,
             ls_idxgc_e1_pri_01 TYPE /idxgc/e1_pri_01,
             ls_idxgc_e1_nad_05 TYPE /idxgc/e1_nad_05,
             ls_idxgc_e1_moa_01 TYPE /idxgc/e1_moa_01,
             ls_idxgc_e1_qty_01 TYPE /idxgc/e1_qty_01,
             ls_idxgc_e1_dtm_07 TYPE /idxgc/e1_dtm_07,
             ls_idxgc_e1_sts_01 TYPE /idxgc/e1_sts_01,
             ls_idxgc_e1_cci_02 TYPE /idxgc/e1_cci_02,
             ls_idxgc_e1_mea_02 TYPE /idxgc/e1_mea_02,
             ls_idxgc_e1_dtm_08 TYPE /idxgc/e1_dtm_08,
             ls_idxgc_e1_cnt_01 TYPE /idxgc/e1_cnt_01,
             ls_idxgc_e1_unt_01 TYPE /idxgc/e1_unt_01,
             ls_idxgc_e1_unz_01 TYPE /idxgc/e1_unz_01.

    FIELD-SYMBOLS:
      <fs_edidd_old>   TYPE edidd,
      <fs_edidd_idxgc> TYPE edidd.

    LOOP AT it_idoc_data ASSIGNING <fs_edidd_old>.
      APPEND INITIAL LINE TO rt_idoc_data ASSIGNING <fs_edidd_idxgc>.
      <fs_edidd_idxgc>-mandt  = <fs_edidd_old>-mandt.
      <fs_edidd_idxgc>-docnum = <fs_edidd_old>-docnum.
      <fs_edidd_idxgc>-segnum = <fs_edidd_old>-segnum.
*      <fs_edidd_idxgc>-SEGNAM = <fs_edidd_old>-SEGNAM.
      <fs_edidd_idxgc>-psgnum = <fs_edidd_old>-psgnum.
      <fs_edidd_idxgc>-hlevel = <fs_edidd_old>-hlevel.
      <fs_edidd_idxgc>-dtint2 = <fs_edidd_old>-dtint2.

      CASE <fs_edidd_old>-segnam.
        WHEN '/IDEXGE/E1VDEWUNB_2'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_UNB_01'.
          "...sdata mapping und Elemente übertragen...
          ls_idexge_e1vdewunb_2 = <fs_edidd_old>-sdata.
*ls_idexge_e1vdewunb_2-ADDRESS_BACK.
*ls_idexge_e1vdewunb_2-ADDRESS_FORWARD.

          ls_idxgc_e1_unb_01-syntax_identifier = ls_idexge_e1vdewunb_2-syntax_ident.
          ls_idxgc_e1_unb_01-syntax_version_number = ls_idexge_e1vdewunb_2-syntax_version.
*ls_idxgc_e1_unb_01-SERV_CODE_LIST_DIREC_VERS_NO =
*ls_idxgc_e1_unb_01-CHARACTER_ENCODING_CODED =
          ls_idxgc_e1_unb_01-interchange_sender_ident = ls_idexge_e1vdewunb_2-sender.
          ls_idxgc_e1_unb_01-identification_code_qualifier1 = ls_idexge_e1vdewunb_2-sender_type.
*ls_idxgc_e1_unb_01-INTERCHANGE_SENDER_INTERNAL_ID =
*ls_idxgc_e1_unb_01-INTERCHANGE_SENDER_INT_SUB_ID =
          ls_idxgc_e1_unb_01-interchange_recipient_ident = ls_idexge_e1vdewunb_2-receiver.
          ls_idxgc_e1_unb_01-identification_code_qualifier2 = ls_idexge_e1vdewunb_2-receiver_type.
*ls_idxgc_e1_unb_01-INTERCHANGE_RECIP_INTERNAL_ID =
*ls_idxgc_e1_unb_01-INTERCHANGE_RECIP_INT_SUB_ID =
          ls_idxgc_e1_unb_01-date = ls_idexge_e1vdewunb_2-date_gen.
          ls_idxgc_e1_unb_01-time = ls_idexge_e1vdewunb_2-time_gen.
          ls_idxgc_e1_unb_01-interchange_control_reference = ls_idexge_e1vdewunb_2-bulk_ref.
          ls_idxgc_e1_unb_01-recipient_reference_passwort = ls_idexge_e1vdewunb_2-receiver_ref.
          ls_idxgc_e1_unb_01-recipient_ref_passwort_qual = ls_idexge_e1vdewunb_2-receiver_ref_type.
          ls_idxgc_e1_unb_01-application_reference = ls_idexge_e1vdewunb_2-util_ref.
          ls_idxgc_e1_unb_01-processing_priority_code = ls_idexge_e1vdewunb_2-proc_prio.
          ls_idxgc_e1_unb_01-acknowledgement_request = ls_idexge_e1vdewunb_2-conf_request.
          ls_idxgc_e1_unb_01-communication_agreement_id = ls_idexge_e1vdewunb_2-exch_agree_ident.
          ls_idxgc_e1_unb_01-test_indicator = ls_idexge_e1vdewunb_2-test_ident.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_unb_01.

        WHEN '/ISIDEX/E1VDEWUNH_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_UNH_01'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewunh_1 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_unh_01-message_reference_number = ls_isidex_e1vdewunh_1-referencenumber.
          ls_idxgc_e1_unh_01-message_type = ls_isidex_e1vdewunh_1-identifier.
          ls_idxgc_e1_unh_01-message_version_number = ls_isidex_e1vdewunh_1-versionnumber.
          ls_idxgc_e1_unh_01-message_release_number = ls_isidex_e1vdewunh_1-releasenumber.
          ls_idxgc_e1_unh_01-controlling_agency_coded_1 = ls_isidex_e1vdewunh_1-controlagency.
          ls_idxgc_e1_unh_01-association_assigned_code = ls_isidex_e1vdewunh_1-assoccode.
          ls_idxgc_e1_unh_01-common_access_reference = ls_isidex_e1vdewunh_1-accessref.
          ls_idxgc_e1_unh_01-sequence_of_transfers = ls_isidex_e1vdewunh_1-transfernumber.
          ls_idxgc_e1_unh_01-first_and_last_transfer = ls_isidex_e1vdewunh_1-indicator.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_unh_01.

        WHEN '/ISIDEX/E1VDEWBGM_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_BGM_02'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewbgm_1 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_bgm_02-document_name_code = ls_isidex_e1vdewbgm_1-name.
          ls_idxgc_e1_bgm_02-code_list_identification_code = ls_isidex_e1vdewbgm_1-codelist.
          ls_idxgc_e1_bgm_02-code_list_resp_agency_code = ls_isidex_e1vdewbgm_1-codelistagency.
          ls_idxgc_e1_bgm_02-document_name = ls_isidex_e1vdewbgm_1-fullname.
          ls_idxgc_e1_bgm_02-document_identifier = ls_isidex_e1vdewbgm_1-documentnumber.
          ls_idxgc_e1_bgm_02-version_identifier = ls_isidex_e1vdewbgm_1-version.
          ls_idxgc_e1_bgm_02-revision_identifier = ls_isidex_e1vdewbgm_1-revision.
          ls_idxgc_e1_bgm_02-message_function_code = ls_isidex_e1vdewbgm_1-documentfunc.
          ls_idxgc_e1_bgm_02-response_type_code = ls_isidex_e1vdewbgm_1-responsetype.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_bgm_02.

        WHEN '/ISIDEX/E1VDEWDTM_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_DTM_01'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewdtm_1 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_dtm_01-date_time_period_fc_qualifier =  ls_isidex_e1vdewdtm_1-datumqualifier.
          ls_idxgc_e1_dtm_01-date_time_period_value = ls_isidex_e1vdewdtm_1-datum.
          ls_idxgc_e1_dtm_01-date_time_period_format_code = ls_isidex_e1vdewdtm_1-format.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_dtm_01.

        WHEN '/ISIDEX/E1VDEWRFF_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_RFF_07'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewrff_1 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_rff_07-reference_code_qualifier = ls_isidex_e1vdewrff_1-referencequalifier.
          ls_idxgc_e1_rff_07-reference_identifier = ls_isidex_e1vdewrff_1-referencenumber.
          ls_idxgc_e1_rff_07-document_line_identifier = ls_isidex_e1vdewrff_1-linenumber.
          ls_idxgc_e1_rff_07-version_identifier = ls_isidex_e1vdewrff_1-versionnumber.
          ls_idxgc_e1_rff_07-revision_identifier = ls_isidex_e1vdewrff_1-revision.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_rff_07.

        WHEN '/ISIDEX/E1VDEWDTM_2'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_DTM_02'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewdtm_2 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_dtm_02-date_time_period_fc_qualifier = ls_isidex_e1vdewdtm_2-datumqualifier.
          ls_idxgc_e1_dtm_02-date_time_period_value = ls_isidex_e1vdewdtm_2-datum.
          ls_idxgc_e1_dtm_02-date_time_period_format_code = ls_isidex_e1vdewdtm_2-format.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_dtm_02.

        WHEN '/IDEXGE/E1VDEWNAD_7'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_NAD_03'.
          "...sdata mapping und Elemente übertragen...

          ls_idexge_e1vdewnad_7 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_nad_03-party_function_code_qualifier = ls_idexge_e1vdewnad_7-action.
          ls_idxgc_e1_nad_03-party_identifier = ls_idexge_e1vdewnad_7-partner.
          ls_idxgc_e1_nad_03-code_list_ident_code_1 = ls_idexge_e1vdewnad_7-codelist.
          ls_idxgc_e1_nad_03-code_list_resp_agency_code_1 = ls_idexge_e1vdewnad_7-codelistagency.
          ls_idxgc_e1_nad_03-name_and_address_description_1 = ls_idexge_e1vdewnad_7-nameaddress1.
          ls_idxgc_e1_nad_03-name_and_address_description_2 = ls_idexge_e1vdewnad_7-nameaddress2.
          ls_idxgc_e1_nad_03-name_and_address_description_3 = ls_idexge_e1vdewnad_7-nameaddress3.
          ls_idxgc_e1_nad_03-name_and_address_description_4 = ls_idexge_e1vdewnad_7-nameaddress4.
          ls_idxgc_e1_nad_03-name_and_address_description_5 = ls_idexge_e1vdewnad_7-nameaddress5.
          ls_idxgc_e1_nad_03-party_name_1 = ls_idexge_e1vdewnad_7-partnername1.
          ls_idxgc_e1_nad_03-party_name_2 = ls_idexge_e1vdewnad_7-partnername2.
          ls_idxgc_e1_nad_03-party_name_3 = ls_idexge_e1vdewnad_7-partnername3.
          ls_idxgc_e1_nad_03-party_name_4 = ls_idexge_e1vdewnad_7-partnername4.
          ls_idxgc_e1_nad_03-party_name_5 = ls_idexge_e1vdewnad_7-partnername5.
          ls_idxgc_e1_nad_03-party_name_format_code = ls_idexge_e1vdewnad_7-partnerformat.
          ls_idxgc_e1_nad_03-street_no_or_po_box_ident_1 = ls_idexge_e1vdewnad_7-street1.
          ls_idxgc_e1_nad_03-street_no_or_po_box_ident_2 = ls_idexge_e1vdewnad_7-street2.
          ls_idxgc_e1_nad_03-street_no_or_po_box_ident_3 = ls_idexge_e1vdewnad_7-street3.
          ls_idxgc_e1_nad_03-street_no_or_po_box_ident_4 = ls_idexge_e1vdewnad_7-street4.
          ls_idxgc_e1_nad_03-city_name = ls_idexge_e1vdewnad_7-city.
          ls_idxgc_e1_nad_03-country_subdivision_identifier = ls_idexge_e1vdewnad_7-region_id.
          ls_idxgc_e1_nad_03-code_list_ident_code_2 = ls_idexge_e1vdewnad_7-region_code_list.
          ls_idxgc_e1_nad_03-code_list_resp_agency_code_2 = ls_idexge_e1vdewnad_7-region_codelist_agency.
          ls_idxgc_e1_nad_03-country_subdivision_name = ls_idexge_e1vdewnad_7-region.
          ls_idxgc_e1_nad_03-postal_identification_code = ls_idexge_e1vdewnad_7-zipcode.
          ls_idxgc_e1_nad_03-country_identifier = ls_idexge_e1vdewnad_7-country.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_nad_03.

        WHEN '/ISIDEX/E1VDEWCTA_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_CTA_03'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewcta_1 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_cta_03-contact_function_code = ls_isidex_e1vdewcta_1-contactfunc.
          ls_idxgc_e1_cta_03-contact_identifier  = ls_isidex_e1vdewcta_1-contactid.
          ls_idxgc_e1_cta_03-contact_name = ls_isidex_e1vdewcta_1-contactname.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_cta_03.

        WHEN '/ISIDEX/E1VDEWCOM_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_COM_01'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewcom_1 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_com_01-communic_address_identifier = ls_isidex_e1vdewcom_1-commnumber.
          ls_idxgc_e1_com_01-communication_means_type_code = ls_isidex_e1vdewcom_1-commqualf.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_com_01.

        WHEN '/ISIDEX/E1VDEWUNS_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_UNS_01'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewuns_1 = <fs_edidd_old>-sdata.
          ls_idxgc_e1_uns_01-section_identification = ls_isidex_e1vdewuns_1-section_id.
          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_uns_01.

        WHEN '/IDEXGE/E1VDEWNAD_8'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_NAD_04'.
          "...sdata mapping und Elemente übertragen...

          ls_idexge_e1vdewnad_8 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_nad_04-party_function_code_qualifier = ls_idexge_e1vdewnad_8-action.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_nad_04.


        WHEN '/IDEXGE/E1VDEWLOC_4'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_LOC_02'.
          "...sdata mapping und Elemente übertragen...

          ls_idexge_e1vdewloc_4 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_loc_02-location_func_code_quali = ls_idexge_e1vdewloc_4-place_qualifier.
          ls_idxgc_e1_loc_02-location_identifier = ls_idexge_e1vdewloc_4-place_id.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_loc_02.


        WHEN '/ISIDEX/E1VDEWDTM_3'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_DTM_04'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewdtm_3 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_dtm_04-date_time_period_fc_qualifier = ls_isidex_e1vdewdtm_3-datumqualifier.
          ls_idxgc_e1_dtm_04-date_time_period_value = ls_isidex_e1vdewdtm_3-datum.
          ls_idxgc_e1_dtm_04-date_time_period_format_code = ls_isidex_e1vdewdtm_3-format.

          <fs_edidd_idxgc>-sdata =  ls_idxgc_e1_dtm_04.

        WHEN '/ISIDEX/E1VDEWRFF_2'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_RFF_09'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewrff_2 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_rff_09-reference_code_qualifier = ls_isidex_e1vdewrff_2-referencequalifier.
          ls_idxgc_e1_rff_09-reference_identifier = ls_isidex_e1vdewrff_2-referencenumber.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_rff_09.

        WHEN '/IDEXGE/E1VDEWCCI_3'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_CCI_01'.
          "...sdata mapping und Elemente übertragen...

          ls_idexge_e1vdewcci_3 = <fs_edidd_old>-sdata.
          ls_idxgc_e1_cci_01-class_type_code = ls_idexge_e1vdewcci_3-property_class.
          ls_idxgc_e1_cci_01-characteristic_descr_code = ls_idexge_e1vdewcci_3-characteristic_id. " Maxim Schmidt, 12.08.2015, FA 01.10.2015
          ls_idxgc_e1_cci_01-measured_attribute_code = ls_idexge_e1vdewcci_3-property_measure.
          ls_idxgc_e1_cci_01-measurement_significance_code = ls_idexge_e1vdewcci_3-measurement_significance.
          ls_idxgc_e1_cci_01-non_discr_measurement_name_cod = ls_idexge_e1vdewcci_3-measurement_attribute_id.
          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_cci_01.

        WHEN '/ISIDEX/E1VDEWLIN_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_LIN_01'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewlin_1 = <fs_edidd_old>-sdata.
          ls_idxgc_e1_lin_01-line_item_identifier = ls_isidex_e1vdewlin_1-line_item_number.
          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_lin_01.

        WHEN '/EVUIT/E1VDEWPIA_4'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_PIA_01'.
          "...sdata mapping und Elemente übertragen...

          ls_evuit_e1vdewpia_4 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_pia_01-product_ident_code_qualifier = ls_evuit_e1vdewpia_4-product_id.
          ls_idxgc_e1_pia_01-item_identifier_1 = ls_evuit_e1vdewpia_4-item_number_1.
          ls_idxgc_e1_pia_01-item_type_ident_code_1 = ls_evuit_e1vdewpia_4-item_number_type_1.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_pia_01.
        WHEN '/IDEXGE/E1VDEWQTY_3'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_QTY_01'.
          "...sdata mapping und Elemente übertragen...

          ls_idexge_e1vdewqty_3 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_qty_01-quantity_type_code_qualifier = ls_idexge_e1vdewqty_3-quantity_qualifier.
          ls_idxgc_e1_qty_01-quantity = ls_idexge_e1vdewqty_3-quantity.
          ls_idxgc_e1_qty_01-measurement_unit_code = ls_idexge_e1vdewqty_3-measure_unit_qualifier.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_qty_01.

        WHEN '/ISIDEX/E1VDEWDTM_4'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_DTM_07'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewdtm_4 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_dtm_07-date_time_period_fc_qualifier = ls_isidex_e1vdewdtm_4-datumqualifier.
          ls_idxgc_e1_dtm_07-date_time_period_value = ls_isidex_e1vdewdtm_4-datum.
          ls_idxgc_e1_dtm_07-date_time_period_format_code = ls_isidex_e1vdewdtm_4-format.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_dtm_07.

        WHEN '/IDEXGE/E1VDEWSTS_3'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_STS_01'.
          "...sdata mapping und Elemente übertragen...

          ls_idexge_e1vdewsts_3 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_sts_01-status_category_code_1 = ls_idexge_e1vdewsts_3-category.
          ls_idxgc_e1_sts_01-code_list_ident_code_1 = ls_idexge_e1vdewsts_3-category_code_list_id.
          ls_idxgc_e1_sts_01-code_list_resp_agency_code_1 = ls_idexge_e1vdewsts_3-category_agency.
          ls_idxgc_e1_sts_01-status_description_code_1 = ls_idexge_e1vdewsts_3-status_description_code.
          ls_idxgc_e1_sts_01-code_list_ident_code_2 = ls_idexge_e1vdewsts_3-status_agency.
          ls_idxgc_e1_sts_01-status_description_1 = ls_idexge_e1vdewsts_3-status_description.
          ls_idxgc_e1_sts_01-status_reason_descr_code_1 = ls_idexge_e1vdewsts_3-reason_1_description_code.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_sts_01.


        WHEN '/IDEXGE/E1VDEWCCI_4'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_CCI_02'.
          "...sdata mapping und Elemente übertragen...

          ls_idexge_e1vdewcci_4 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_cci_02-property_class = ls_idexge_e1vdewcci_4-property_class.
          ls_idxgc_e1_cci_02-property_measure = ls_idexge_e1vdewcci_4-property_measure.
          ls_idxgc_e1_cci_02-measurement_significance = ls_idexge_e1vdewcci_4-measurement_significance.
          ls_idxgc_e1_cci_02-measurement_attribute_id = ls_idexge_e1vdewcci_4-measurement_attribute_id.

          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_cci_02.


*        WHEN '/IDEXGE/E1VDEWMEA_2'.
*          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_MEA_02'.
*          "...sdata mapping und Elemente übertragen...

        WHEN '/ISIDEX/E1VDEWDTM_5'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_DTM_08'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewdtm_5 = <fs_edidd_old>-sdata.

          ls_idxgc_e1_dtm_08-date_time_period_fc_qualifier = ls_isidex_e1vdewdtm_5-datumqualifier.
          ls_idxgc_e1_dtm_08-date_time_period_value = ls_isidex_e1vdewdtm_5-datum.
          ls_idxgc_e1_dtm_08-date_time_period_format_code = ls_isidex_e1vdewdtm_5-format.
          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_dtm_08.

        WHEN '/ISIDEX/E1VDEWUNT_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_UNT_01'.
          "...sdata mapping und Elemente übertragen...

          ls_isidex_e1vdewunt_1 = <fs_edidd_old>-sdata.
          ls_idxgc_e1_unt_01-number_of_segments_in_message = ls_isidex_e1vdewunt_1-numseg.
          ls_idxgc_e1_unt_01-message_reference_number = ls_isidex_e1vdewunt_1-refnum.
          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_unt_01.

        WHEN '/IDEXGE/E1VDEWUNZ_1'.
          <fs_edidd_idxgc>-segnam = '/IDXGC/E1_UNZ_01'.
          "...sdata mapping und Elemente übertragen...

          ls_idexge_e1vdewunz_1 = <fs_edidd_old>-sdata.
          ls_idxgc_e1_unz_01-interchange_control_count = ls_idexge_e1vdewunz_1-dexcount.
          ls_idxgc_e1_unz_01-interchange_control_reference = ls_idexge_e1vdewunz_1-bulk_ref.
          <fs_edidd_idxgc>-sdata = ls_idxgc_e1_unz_01.


      ENDCASE.


    ENDLOOP.
  ENDMETHOD.


  METHOD map_pdoc_to_isu_data.

    DATA: lt_settl_unit       TYPE         /idxgc/t_setunit_details,
          lv_guid_ext         TYPE         guid_16,
          lv_sparte           TYPE         sparte,
          lv_count_w          TYPE         i VALUE 1,
          lv_count_k          TYPE         i VALUE 1,
          lv_count_s          TYPE         i VALUE 1,
          lv_sammelst_pattern TYPE         string,

          ls_msgdata          LIKE LINE OF et_msg_hdr,
          ls_ext_msgdata      LIKE LINE OF et_msg_ext,
          ls_msg_comment      TYPE         eideswtmsgdataco,
          ls_msg_add          TYPE         eideswtmsgadddata,
          ls_eedmsettlunit    TYPE         eedmsettlunit,

          lt_msg_ext   	      TYPE         zide_extmsgdata_t,

          lv_name_1           TYPE         char40,
          lv_name_2           TYPE         char40,
          lv_houseid          TYPE         ad_hsnm1,
          lv_houseid_add      TYPE         ad_hsnm1.



    FIELD-SYMBOLS: <fs_msg_hdr>          TYPE /idxgc/s_msg_data_all,
                   <fs_diverse_data>     TYPE /idxgc/s_diverse_details,
                   <fs_msgsts_details>   TYPE /idxgc/s_msgsts_details,
                   <fs_settl_terr>       TYPE /idxgc/s_setlter_details,
                   <fs_settl_unit>       TYPE /idxgc/s_setunit_details,
                   <fs_pod>              TYPE /idxgc/s_pod_info_details,
                   <fs_rejres>           TYPE /idxgc/s_rejres_details,
                   <fs_pod_quant>        TYPE /idxgc/s_pod_quant_details,
                   <fs_time_series>      TYPE /idxgc/s_timeser_details,
                   <fs_reg_code_data>    TYPE /idxgc/s_reg_code_details,
                   <fs_meter_device>     TYPE /idxgc/s_meterdev_details,
                   <fs_non_meter_device> TYPE /idxgc/s_nonmeter_details,
                   <fs_charges_details>  TYPE /idxgc/s_charges_details,
                   <fs_name_address>     TYPE /idxgc/s_nameaddr_details,
                   <fs_marktpartner_add> TYPE /idxgc/s_marpaadd_details,
                   <fs_amid>             TYPE /idxgc/s_amid_details,
                   <fs_msgcomment>       TYPE /idxgc/s_msgcom_details,
                   <fs_attributes>       TYPE /idxgc/s_attr_details,
                   <fs_ext_msgdata>      TYPE zlw_extmsgdata.

*-----------------------------------------------------------*
*1. Kopfdaten mappen
    IF is_pdoc_data-hdr IS NOT INITIAL AND
       es_pdoc_hdr IS REQUESTED.
      es_pdoc_hdr = is_pdoc_data-hdr.

      es_pdoc_hdr-moveindate = is_pdoc_data-zz_moveindate.
      es_pdoc_hdr-moveoutdate = is_pdoc_data-zz_moveoutdate.
      es_pdoc_hdr-realmoveindate = is_pdoc_data-zz_realmoveindate.
      es_pdoc_hdr-realmoveoutdate = is_pdoc_data-zz_realmoveoutdate.
      es_pdoc_hdr-zlw2_einzbeleg = is_pdoc_data-zz_moveindoc.

    ENDIF.

*2. Kopfdaten auf ADDDATA-Kopf mappen
    IF NOT is_pdoc_data-hdr_add IS INITIAL AND
           es_pdoc_add IS REQUESTED.
      CALL METHOD /idxgc/cl_process_document=>conv_any_to_eideswtdocadddata
        EXPORTING
          x_switchnum         = is_pdoc_data-switchnum
          x_adddata_any       = is_pdoc_data-hdr_add
        RECEIVING
          y_eideswtdocadddata = es_pdoc_add.
    ENDIF.
*-----------------------------------------------------------*

*-----------------------------------------------------------*
*3. Schrittdaten auf die IS-U Daten (EIDESWTMSGDATA usw.) mappen
    IF is_pdoc_data-msg_data IS NOT INITIAL AND
       ( et_msg_hdr IS REQUESTED OR
         et_msg_add IS REQUESTED OR
         et_msg_comments IS REQUESTED OR
         et_msg_ext IS REQUESTED ).

      LOOP AT is_pdoc_data-msg_data ASSIGNING <fs_msg_hdr>.
        AT FIRST.
          TRY.
              lv_sparte = zcl_agc_masterdata=>get_sparte( iv_serviceid = <fs_msg_hdr>-compartner ).
            CATCH zcx_agc_masterdata.
              "Erstmal nichts machen.
          ENDTRY.
        ENDAT.

        ls_msgdata = <fs_msg_hdr>-msg_isu_data.
        ls_msgdata-category = <fs_msg_hdr>-docname_code.

        CALL FUNCTION 'GUID_CREATE'
          IMPORTING
            ev_guid_16 = lv_guid_ext.

        ls_msgdata-zz_guid_ext = lv_guid_ext.

        "DIVERSE
        READ TABLE <fs_msg_hdr>-diverse ASSIGNING <fs_diverse_data> INDEX 1.
        IF <fs_diverse_data> IS ASSIGNED.
          ls_msgdata-idrefnr = <fs_diverse_data>-transaction_no.                                  "Transaktionsnummer

          ls_msgdata-moveindate = <fs_diverse_data>-contr_start_date.                             " 92, Vertragsbeginn
          ls_msgdata-moveoutdate = <fs_diverse_data>-contr_end_date.                              " 93, Vertragsende
          IF ls_msgdata-moveoutdate IS INITIAL.                                                   "Übernommen aus IN_ANALYSE (THIMEL.R, 17.03.2015)
            ls_msgdata-moveoutdate = <fs_diverse_data>-endnextposs_from.                          "471, Ende zum (nächstmöglichen Termin)
          ENDIF.
          ls_msgdata-zz_cumoveoutdate = <fs_diverse_data>-confcancdat_cust.                       "Z05, Datum des bereits bestätigten Vertragsendes (Kunde)
          ls_msgdata-zz_sumoveoutdate = <fs_diverse_data>-confcancdat_supp.                       "Z06, Datum des bereits bestätigten Vertragsendes (Lieferant)
          IF <fs_msg_hdr>-validity_ym IS NOT INITIAL.
            ls_msgdata-zz_changedate = <fs_msg_hdr>-validity_ym.                                  "157, Gültigkeit, Beginndatum
          ENDIF.
          IF <fs_diverse_data>-validstart_date IS NOT INITIAL.
            ls_msgdata-zz_changedate = <fs_diverse_data>-validstart_date.                         "157(SG4), Gültigkeit, Beginndatum
          ENDIF.
          ls_msgdata-zz_possend = <fs_diverse_data>-endnextposs_from.                             "471, Ende zum (nächstmöglichem Termin)
          ls_msgdata-zz_strtabrjahr = <fs_diverse_data>-billyearstart.                            "155, Start des Abrechnungsjahrs bei RLM
          ls_msgdata-zz_ablweek = <fs_diverse_data>-nextmr_date.                                  "752, Nächste turnusmäßige Ablesung                                                                           "Z09, Erstmalige Turnusablesung
          ls_msgdata-zz_turnusint = <fs_diverse_data>-mrperiod_length.                            "672, Turnusintervall
          ls_msgdata-zz_settlestart = <fs_diverse_data>-startsettldate.                           "158, Bilanzierungsbeginn
          ls_msgdata-zz_settleend = <fs_diverse_data>-endsettldate.                               "159, Bilanzierungsende
          ls_msgdata-zz_kuendfrist = <fs_diverse_data>-noticeper.                                 "Z01, Kündigungsfrist des Vertrags
          ls_msgdata-pland_mr_date = <fs_diverse_data>-initmr_year.                               "Z09 Erstmalige Turnusabrechnung

          IF <fs_diverse_data>-notper_keydate IS NOT INITIAL OR
            <fs_diverse_data>-notper_keyday IS NOT INITIAL.
            ls_ext_msgdata-guiid = lv_guid_ext.
            ls_ext_msgdata-fieldname = 'ZZ_KUENDFRIST'.
            ls_ext_msgdata-lfdnr = 1.
            ls_ext_msgdata-wert = <fs_diverse_data>-notper_keydate.
            ls_ext_msgdata-wert2 = <fs_diverse_data>-notper_keyday.
            APPEND ls_ext_msgdata TO et_msg_ext.
            CLEAR ls_ext_msgdata.
          ENDIF.

          ls_msgdata-zz_moveinproc = <fs_diverse_data>-sos_date_in_proc.                          "Lieferbeginndatum in Bearbeitung
          ls_msgdata-zz_nextprocdate = <fs_diverse_data>-nextposs_procdat.                        "Datum für nächste Bearbeitung
          ls_msgdata-transreason = <fs_diverse_data>-msgtransreason.                              "Transaktionsgrund
          ls_msgdata-zz_statusnenu = <fs_diverse_data>-gridus_contrinfo.                          "Netznutzungsvertrag
          ls_msgdata-zz_zahler = <fs_diverse_data>-gridus_contrpay.                               "Zahlung der Netznutzung
          ls_msgdata-zz_tempms = <fs_diverse_data>-temp_mp.                                       "Temperaturmessstelle
          ls_msgdata-temp_mp = <fs_diverse_data>-temp_mp_prov.                                    "Temperaturmessstelle
          ls_msgdata-zz_klimazone = <fs_diverse_data>-climatezone.                                "Klimazone
          ls_msgdata-zz_regelzone = <fs_diverse_data>-contrlarea_ext.                             "Regelzone
          ls_msgdata-zz_ext_ui_new = <fs_diverse_data>-pod_corrected.                             "Angabe der korrigierten ZPB
          ls_msgdata-zz_transreason = <fs_diverse_data>-dereg_reason.                             "Zweiter Transaktionsgrund (THIMEL.R 20150322)

          IF <fs_diverse_data>-prof_code_an IS NOT INITIAL.
            ls_msgdata-profile = <fs_diverse_data>-prof_code_an.                                    "Profil
          ELSEIF <fs_diverse_data>-prof_code_sy IS NOT INITIAL.
            ls_msgdata-profile = <fs_diverse_data>-prof_code_sy.                                    "Profil
          ENDIF.

          IF ls_msgdata-profile IS NOT INITIAL.
            ls_ext_msgdata-guiid = lv_guid_ext.
            ls_ext_msgdata-fieldname = 'ZZ_PROFILE'.
            ls_ext_msgdata-lfdnr = 1.
            ls_ext_msgdata-wert = <fs_diverse_data>-profile_group.
            IF <fs_diverse_data>-prof_code_an IS NOT INITIAL.
              ls_ext_msgdata-wert2 = <fs_diverse_data>-prof_code_an.                                    "Profil
              ls_ext_msgdata-wert3 = <fs_diverse_data>-prof_code_an_cla.
            ELSEIF <fs_diverse_data>-prof_code_sy IS NOT INITIAL.
              ls_ext_msgdata-wert4 = <fs_diverse_data>-prof_code_sy.                                    "Profil
              ls_ext_msgdata-wert5 = <fs_diverse_data>-prof_code_sy_cla.
            ENDIF.
            ls_ext_msgdata-wert9 = <fs_diverse_data>-temp_mp_cla.                                       "Temperaturmessstelle CLA (THIMEL.R 20150706 M4969)
            APPEND ls_ext_msgdata TO et_msg_ext.
            CLEAR ls_ext_msgdata.
          ENDIF.

          ls_msgdata-metmethod = <fs_diverse_data>-meter_proc.                                    "Zählverfahren

          IF lv_sparte = zif_datex_co=>co_spartype_strom.
            ls_msgdata-zz_spebene = <fs_diverse_data>-volt_level_offt.                            "Spannungsebene der Entnahme
          ELSEIF lv_sparte = zif_datex_co=>co_spartype_gas.
            ls_msgdata-zz_spebene = <fs_diverse_data>-press_level_offt.                           "Druckebene der Entnahme
          ENDIF.

          ls_msgdata-zz_verbrauftlg = <fs_diverse_data>-cons_distr_ext.                           "Verbruachsaufteilung für TLP Anlagen

          IF <fs_diverse_data>-group_alloc_enwg = /idxgc/if_constants_ide=>gc_cci_chardesc_code_z15.
            ls_msgdata-zz_haushaltsk = abap_true.                                                 "Haushaltskennzeichen
          ELSEIF <fs_diverse_data>-group_alloc_enwg = /idxgc/if_constants_ide=>gc_cci_chardesc_code_z18.
            ls_msgdata-zz_haushaltsk = abap_false.                                                "Haushaltskennzeichen
          ENDIF.

          ls_msgdata-zz_partner_l = <fs_diverse_data>-cust_no_suppl.
          ls_msgdata-zz_partner_la = <fs_diverse_data>-cust_no_oldsuppl.

          ls_msgdata-zz_idref = <fs_diverse_data>-refnr_transrev.                                 "Referenz bri Stornierungen

          ls_msgdata-/idexge/t_id = <fs_diverse_data>-community_dscnt.                            "Gemeinderabatt
        ENDIF.

        "MSGRESPSTATUS
        LOOP AT <fs_msg_hdr>-msgrespstatus ASSIGNING <fs_msgsts_details>.
          "Einen Nachrichtenstatus in das Feld in den Nachrichtendaten schreiben. Immer der aktuellste
          IF ls_msgdata-msgstatus <> <fs_msgsts_details>-respstatus.
            ls_msgdata-msgstatus = <fs_msgsts_details>-respstatus.
          ENDIF.
          "Sammelstatus setzen bzw. hinzufügen falls noch nicht enthalten
          IF ls_msgdata-zz_sammelstatus NS <fs_msgsts_details>-respstatus.
            IF ls_msgdata-zz_sammelstatus IS INITIAL.
              ls_msgdata-zz_sammelstatus = <fs_msgsts_details>-respstatus.
            ELSE.
              CONCATENATE ls_msgdata-zz_sammelstatus ';' <fs_msgsts_details>-respstatus INTO ls_msgdata-zz_sammelstatus.
            ENDIF.
          ENDIF.
        ENDLOOP.

        "SETTL_TERR
        READ TABLE <fs_msg_hdr>-settl_terr ASSIGNING <fs_settl_terr> INDEX 1.
        IF <fs_settl_terr> IS ASSIGNED.
          ls_msgdata-zz_eic_bg = <fs_settl_terr>-settlterr_ext.
        ENDIF.

        "SETTL_UNIT
        IF lines( <fs_msg_hdr>-settl_unit ) > 1.
          lt_settl_unit = <fs_msg_hdr>-settl_unit.
          SORT lt_settl_unit BY settlunit_prio DESCENDING.
          LOOP AT lt_settl_unit ASSIGNING <fs_settl_unit>.
            ls_ext_msgdata-guiid = lv_guid_ext.
            ls_ext_msgdata-fieldname = 'SETTLRESP'.
            ls_ext_msgdata-lfdnr = sy-tabix.
            ls_ext_msgdata-wert2 = <fs_settl_unit>-settlunit_ext.
            ls_ext_msgdata-wert = <fs_settl_unit>-settlunit_prio.
            APPEND ls_ext_msgdata TO et_msg_ext.
            CLEAR ls_ext_msgdata.

            "Siehe Mantis 1753, 3749, 4836 und IN_ANALYZE 60A für Hinweise zur Logik (THIMEL.R, 20150327)
            SELECT SINGLE * FROM eedmsettlunit INTO ls_eedmsettlunit
              WHERE settlsupplier = <fs_msg_hdr>-compartner AND datefrom <= <fs_diverse_data>-contr_start_date
                AND dateto >= <fs_diverse_data>-contr_start_date AND settlunitext = <fs_settl_unit>-settlunit_ext.
            IF sy-subrc = 0 OR ( <fs_settl_unit>-settlunit_prio = 1 AND ls_msgdata-settlresp IS INITIAL ).
              ls_msgdata-settlresp = <fs_settl_unit>-settlunit_ext.
              ls_msgdata-unit_prio = <fs_settl_unit>-settlunit_prio.
            ENDIF.
          ENDLOOP.
        ELSE.
          READ TABLE <fs_msg_hdr>-settl_unit ASSIGNING <fs_settl_unit> INDEX 1.
          IF <fs_settl_unit> IS ASSIGNED.
            ls_msgdata-settlresp = <fs_settl_unit>-settlunit_ext.
            ls_msgdata-unit_prio = <fs_settl_unit>-settlunit_prio.
          ENDIF.
        ENDIF.

*>>>THIMEL.R 20150420 M4899 Verarbeitung komplexer Nachrichten angepasst
        IF lines( <fs_msg_hdr>-pod ) > 1.
          ls_msgdata-zz_hierarchie = 'C'.

          READ TABLE <fs_msg_hdr>-pod ASSIGNING <fs_pod> WITH KEY pod_type = /idxgc/if_constants_ide=>gc_pod_type_z30.
          IF sy-subrc = 0.
            ls_msgdata-ext_ui = <fs_pod>-ext_ui.
            ls_msgdata-zz_spebenemess = <fs_pod>-volt_level_meas.
            ls_msgdata-zz_verlustfaktor = <fs_pod>-lossfact_ext.
          ENDIF.
        ELSE.
          CLEAR ls_msgdata-zz_hierarchie.

          READ TABLE <fs_msg_hdr>-pod ASSIGNING <fs_pod> INDEX 1.
          IF sy-subrc = 0.
            ls_msgdata-ext_ui = <fs_pod>-ext_ui.
            ls_msgdata-zz_spebenemess = <fs_pod>-volt_level_meas.
            ls_msgdata-zz_verlustfaktor = <fs_pod>-lossfact_ext.
          ENDIF.
        ENDIF.
*<<<THIMEL.R 20150420 M4899

        "REJREAS_OLDSUPPL
        READ TABLE <fs_msg_hdr>-rejreas_oldsuppl ASSIGNING <fs_rejres> INDEX 1.
        IF <fs_rejres> IS ASSIGNED.
          ls_msgdata-zz_dropmsgstatus = <fs_rejres>-respstatus.
        ENDIF.

        "POD_QUANT
        READ TABLE <fs_msg_hdr>-pod_quant ASSIGNING <fs_pod_quant> WITH KEY quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_265. "Arbeit/Leistung für tagesparameterabhängige Lieferstelle (Veranschlagte Jahresmenge)
        IF <fs_pod_quant> IS ASSIGNED.
          ls_msgdata-zz_speverbrht = <fs_pod_quant>-quantitiy_ext.
        ENDIF.
        UNASSIGN <fs_pod_quant>.

        IF lv_sparte = zif_datex_co=>co_spartype_strom.
          READ TABLE <fs_msg_hdr>-pod_quant ASSIGNING <fs_pod_quant> WITH KEY quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z08. "Arbeit/Leistung für tagesparameterabhängige Lieferstelle (Angepasste elektrische Arbeit)
          IF <fs_pod_quant> IS ASSIGNED.
            ls_msgdata-usagefactor = <fs_pod_quant>-quantitiy_ext.
          ENDIF.
        ELSEIF lv_sparte = zif_datex_co=>co_spartype_gas.
          READ TABLE <fs_msg_hdr>-pod_quant ASSIGNING <fs_pod_quant> WITH KEY quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_y02. "TUM-Kundenwert
          IF <fs_pod_quant> IS ASSIGNED.
            ls_msgdata-usagefactor = <fs_pod_quant>-quantitiy_ext.
          ENDIF.
        ENDIF.
        UNASSIGN <fs_pod_quant>.

        READ TABLE <fs_msg_hdr>-pod_quant ASSIGNING <fs_pod_quant> WITH KEY quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_31. "Veranschlagte Jahresmenge gesamt
        IF <fs_pod_quant> IS ASSIGNED.
          ls_msgdata-progyearcons = <fs_pod_quant>-quantitiy_ext.
        ENDIF.
        UNASSIGN <fs_pod_quant>.

        READ TABLE <fs_msg_hdr>-pod_quant ASSIGNING <fs_pod_quant> WITH KEY quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z03. "Bisher gemessene Maximalleistung
        IF <fs_pod_quant> IS ASSIGNED.
          ls_msgdata-maxdemand = <fs_pod_quant>-quantitiy_ext.
        ENDIF.
        UNASSIGN <fs_pod_quant>.

        READ TABLE <fs_msg_hdr>-pod_quant ASSIGNING <fs_pod_quant> WITH KEY quant_type_qual = /idxgc/if_constants_ide=>gc_qty_qual_z09. "Verjahresverbrauch vom Lieferanten
        IF <fs_pod_quant> IS ASSIGNED.
          ls_msgdata-zz_progyearcons = <fs_pod_quant>-quantitiy_ext.
        ENDIF.
        UNASSIGN <fs_pod_quant>.

        "TIME_SERIES
        READ TABLE <fs_msg_hdr>-time_series ASSIGNING <fs_time_series> WITH KEY timseries_msgcat = /idxgc/if_constants_ide=>gc_cci_01_chardesc_code_z21.
        IF <fs_time_series> IS ASSIGNED.
          ls_msgdata-zz_zeitreihentyp = <fs_time_series>-time_series_type.
        ENDIF.

        "REG_CODE_DATA
        LOOP AT <fs_msg_hdr>-reg_code_data ASSIGNING <fs_reg_code_data>.
          ls_ext_msgdata-fieldname = 'ZZ_OBISKENNZAHL'.
          ls_ext_msgdata-guiid = lv_guid_ext.
          ls_ext_msgdata-lfdnr = sy-tabix.
          ls_ext_msgdata-wert = <fs_reg_code_data>-reg_code.
          IF <fs_reg_code_data>-tarif_alloc = zif_datex_co=>co_cci_chardesc_code_z59.
            ls_ext_msgdata-wert2 = 'ZNS'.
          ELSEIF <fs_reg_code_data>-tarif_alloc = zif_datex_co=>co_cci_chardesc_code_z60.
            ls_ext_msgdata-wert2 = 'ZSF'.
          ENDIF.
          ls_ext_msgdata-wert3 = <fs_reg_code_data>-reg_label.
          ls_ext_msgdata-wert4 = <fs_reg_code_data>-int_positons.
          ls_ext_msgdata-wert5 = <fs_reg_code_data>-dec_places.
          ls_ext_msgdata-wert6 = <fs_reg_code_data>-meternumber.
          APPEND ls_ext_msgdata TO et_msg_ext.

          IF ls_msgdata-zz_obiskennzahl IS INITIAL.
            ls_msgdata-zz_obiskennzahl = <fs_reg_code_data>-reg_code.
          ELSE.
            CONCATENATE ls_msgdata-zz_obiskennzahl ';' <fs_reg_code_data>-reg_code INTO ls_msgdata-zz_obiskennzahl.
          ENDIF.

        ENDLOOP.
        CLEAR ls_ext_msgdata.

        "METER_DEVICE
        READ TABLE <fs_msg_hdr>-meter_dev ASSIGNING <fs_meter_device> INDEX 1.
        IF <fs_meter_device> IS ASSIGNED.
          ls_msgdata-zz_metertype = <fs_meter_device>-metertype_code.
          IF <fs_meter_device>-metersize_value IS NOT INITIAL.
            ls_msgdata-zz_zaehlertyp = <fs_meter_device>-metersize_value.
          ELSE.
            ls_msgdata-zz_zaehlertyp = <fs_meter_device>-metertype_value.
          ENDIF.
          ls_msgdata-meternr = <fs_meter_device>-meternumber.
          ls_msgdata-zz_tarifanz = <fs_meter_device>-ratenumber_code.
          ls_msgdata-zz_enrichtanz = <fs_meter_device>-energy_direction.
          ls_msgdata-zz_messwerterf = <fs_meter_device>-datalog_type.
        ENDIF.

        "NON_METER_DEVICE
        LOOP AT <fs_msg_hdr>-non_meter_dev ASSIGNING <fs_non_meter_device>.
          CASE <fs_non_meter_device>-device_qual.
            WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z04 OR
                  zif_datex_co=>co_seq_action_code_z09.
              ls_ext_msgdata-guiid = lv_guid_ext.
              ls_ext_msgdata-fieldname = 'ZZ_WANDLER'.
              ls_ext_msgdata-lfdnr = lv_count_w.
              ls_ext_msgdata-wert = <fs_non_meter_device>-device_number.
              ls_ext_msgdata-wert2 = <fs_non_meter_device>-transform_type.
              ls_ext_msgdata-wert3 = <fs_non_meter_device>-transform_const.
              ls_ext_msgdata-wert6 = <fs_non_meter_device>-meternumber.
              APPEND ls_ext_msgdata TO et_msg_ext.
              ADD 1 TO lv_count_w.
              CLEAR ls_ext_msgdata.
            WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z05.
              ls_ext_msgdata-guiid = lv_guid_ext.
              ls_ext_msgdata-fieldname = 'ZZ_KOMMEINR'.
              ls_ext_msgdata-lfdnr = lv_count_k.
              ls_ext_msgdata-wert = <fs_non_meter_device>-device_number.
              ls_ext_msgdata-wert2 = <fs_non_meter_device>-commequip_type.
              ls_ext_msgdata-wert6 = <fs_non_meter_device>-meternumber.
              APPEND ls_ext_msgdata TO et_msg_ext.
              ADD 1 TO lv_count_k.
              CLEAR ls_ext_msgdata.
            WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z06.
              ls_ext_msgdata-guiid = lv_guid_ext.
              ls_ext_msgdata-fieldname = 'ZZ_STEUEREINR'.
              ls_ext_msgdata-lfdnr = lv_count_s.
              ls_ext_msgdata-wert = <fs_non_meter_device>-device_number.
              ls_ext_msgdata-wert2 = <fs_non_meter_device>-contrunit_type.
              ls_ext_msgdata-wert6 = <fs_non_meter_device>-meternumber.
              APPEND ls_ext_msgdata TO et_msg_ext.
              ADD 1 TO lv_count_s.
              CLEAR ls_ext_msgdata.

          ENDCASE.
        ENDLOOP.

        "CHARGES_DETAILS
        "Wir gehen davon aus, dass es nur eine Konzessionsabgabe für alle ZW / OBIS-Kennzahlen gibt.

        LOOP AT <fs_msg_hdr>-charges ASSIGNING <fs_charges_details>.
          CASE <fs_charges_details>-charge_qual.
            WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z07.

              IF ls_msgdata-zz_konzabgabe IS INITIAL.
                ls_msgdata-zz_konzabgabe = <fs_charges_details>-franchise_fee.
                IF <fs_charges_details>-fr_fee_assign = 'Z08'.
                  ls_msgdata-zz_konz_betrag = <fs_charges_details>-fr_fee_amount_ex.
                ELSEIF <fs_charges_details>-fr_fee_assign = 'Z09'.
                  ls_msgdata-zz_konz_betrnt = <fs_charges_details>-fr_fee_amount_ex.
                ENDIF.

                READ TABLE et_msg_ext ASSIGNING <fs_ext_msgdata> WITH KEY wert = <fs_charges_details>-reg_code fieldname = 'ZZ_KONZABGABE' wert2 = <fs_charges_details>-ext_ui.
                IF <fs_ext_msgdata> IS ASSIGNED.
                  <fs_ext_msgdata>-wert7 = <fs_charges_details>-franch_fee_cat.
                  <fs_ext_msgdata>-wert9 = <fs_charges_details>-franchise_fee.
                  <fs_ext_msgdata>-wert10 = <fs_charges_details>-fr_fee_amount_ex.
                  <fs_ext_msgdata>-wert4 = <fs_charges_details>-fr_fee_assign.
                ELSE.
                  ls_ext_msgdata-fieldname = 'ZZ_KONZABGABE'.
                  ls_ext_msgdata-guiid = lv_guid_ext.
                  ls_ext_msgdata-lfdnr = lines( et_msg_ext ) + 1.
                  ls_ext_msgdata-wert = <fs_charges_details>-reg_code.
                  ls_ext_msgdata-wert2 = <fs_charges_details>-ext_ui.
                  ls_ext_msgdata-wert7 = <fs_charges_details>-franch_fee_cat.
                  ls_ext_msgdata-wert9 = <fs_charges_details>-franchise_fee.
                  ls_ext_msgdata-wert10 = <fs_charges_details>-fr_fee_amount_ex.
                  ls_ext_msgdata-wert4 = <fs_charges_details>-fr_fee_assign.
                  APPEND ls_ext_msgdata TO et_msg_ext.
                  CLEAR ls_ext_msgdata.
                ENDIF.
              ELSE.
                READ TABLE et_msg_ext ASSIGNING <fs_ext_msgdata> WITH KEY wert = <fs_charges_details>-reg_code fieldname = 'ZZ_KONZABGABE' wert2 = <fs_charges_details>-ext_ui.
                IF <fs_ext_msgdata> IS ASSIGNED.
                  <fs_ext_msgdata>-wert7 = <fs_charges_details>-franch_fee_cat.
                  <fs_ext_msgdata>-wert9 = <fs_charges_details>-franchise_fee.
                  <fs_ext_msgdata>-wert10 = <fs_charges_details>-fr_fee_amount_ex.
                  <fs_ext_msgdata>-wert4 = <fs_charges_details>-fr_fee_assign.
                ELSE.
                  ls_ext_msgdata-fieldname = 'ZZ_KONZABGABE'.
                  ls_ext_msgdata-guiid = lv_guid_ext.
                  ls_ext_msgdata-lfdnr = lines( et_msg_ext ) + 1.
                  ls_ext_msgdata-wert = <fs_charges_details>-reg_code.
                  ls_ext_msgdata-wert2 = <fs_charges_details>-ext_ui.
                  ls_ext_msgdata-wert7 = <fs_charges_details>-franch_fee_cat.
                  ls_ext_msgdata-wert9 = <fs_charges_details>-franchise_fee.
                  ls_ext_msgdata-wert10 = <fs_charges_details>-fr_fee_amount_ex.
                  ls_ext_msgdata-wert4 = <fs_charges_details>-fr_fee_assign.
                  APPEND ls_ext_msgdata TO et_msg_ext.
                  CLEAR ls_ext_msgdata.
                ENDIF.
              ENDIF.
            WHEN /idxgc/if_constants_ide=>gc_seq_action_code_z10.

              READ TABLE et_msg_ext ASSIGNING <fs_ext_msgdata> WITH KEY wert = <fs_charges_details>-reg_code fieldname = 'ZZ_STEUERN' wert2 = <fs_charges_details>-ext_ui.
              IF <fs_ext_msgdata> IS ASSIGNED.
                <fs_ext_msgdata>-wert2 = <fs_charges_details>-tax_info.
              ELSE.
                ls_ext_msgdata-fieldname = 'ZZ_STEUERN'.
                ls_ext_msgdata-guiid = lv_guid_ext.
                ls_ext_msgdata-lfdnr = lines( et_msg_ext ) + 1.
                ls_ext_msgdata-wert = <fs_charges_details>-reg_code.
                ls_ext_msgdata-wert2 = <fs_charges_details>-ext_ui.
                ls_ext_msgdata-wert3 = <fs_charges_details>-tax_info.
                APPEND ls_ext_msgdata TO et_msg_ext.
                CLEAR ls_ext_msgdata.
              ENDIF.
          ENDCASE.
        ENDLOOP.

        "NAME_ADDRESS
        LOOP AT <fs_msg_hdr>-name_address ASSIGNING <fs_name_address>.
          CASE <fs_name_address>-party_func_qual.
            WHEN /idxgc/if_constants_ide=>gc_nad_02_qual_ud.
              "Namen für den Letzverbrauchen drehen

              IF <fs_name_address>-name_format_code = zif_agc_datex_co=>gc_nad_name_format_z01.
*>>> Wolf.A., 23.02.2016, Mapping der Namensfelder entsprechend dem Konzept "ITBM - Datenhaltung Geschäftspartner - 20160216(01) angepasst.
                ls_msgdata-name_l = <fs_name_address>-first_name.
                ls_msgdata-zz_name_l2 = <fs_name_address>-name_add2.
                ls_msgdata-name_f = <fs_name_address>-fam_comp_name1.
                ls_msgdata-zz_name_f2 = <fs_name_address>-name_add1.
                IF <fs_name_address>-ad_title_ext CS 'DR' OR
                   <fs_name_address>-ad_title_ext CS 'Dr' OR
                   <fs_name_address>-ad_title_ext CS 'Doktor'.
                  ls_msgdata-/idexge/ptit_ac1 = 'DR'.
                ENDIF.

*                ls_msgdata-name_l = <fs_name_address>-first_name1.
*                ls_msgdata-zz_name_l2 = <fs_name_address>-first_name2.
*                ls_msgdata-name_f = <fs_name_address>-fam_comp_name1.
*                ls_msgdata-zz_name_f2 = <fs_name_address>-fam_comp_name2.
              ELSEIF <fs_name_address>-name_format_code = zif_agc_datex_co=>gc_nad_name_format_z02.
                IF zcl_agc_datex_utility=>check_asso_servprov( iv_servprov = <fs_msg_hdr>-compartner ) = abap_false.
                  zcl_agc_datex_utility=>parse_name_data( EXPORTING iv_string = <fs_name_address>-fam_comp_name1 IMPORTING ev_string_1 = lv_name_1 ev_string_2 = lv_name_2 ).
                  ls_msgdata-name_l = lv_name_1.
                  CONCATENATE lv_name_2 <fs_name_address>-fam_comp_name2 INTO ls_msgdata-name_f SEPARATED BY space.
                  zcl_agc_datex_utility=>parse_name_data( EXPORTING iv_string = <fs_name_address>-name_add1 IMPORTING ev_string_1 = lv_name_1 ev_string_2 = lv_name_2 ).
                  ls_msgdata-zz_name_l2 = lv_name_1.
                  CONCATENATE lv_name_2 <fs_name_address>-name_add2 INTO ls_msgdata-zz_name_f2 SEPARATED BY space.
                ELSE.
                  ls_msgdata-name_l = <fs_name_address>-fam_comp_name1.
                  ls_msgdata-name_f = <fs_name_address>-fam_comp_name2.
                  ls_msgdata-zz_name_f2 = <fs_name_address>-name_add1.
                  ls_msgdata-zz_name_l2 = <fs_name_address>-name_add2.
                ENDIF.
*                ls_msgdata-name_l = <fs_name_address>-fam_comp_name1.
*                ls_msgdata-name_f = <fs_name_address>-fam_comp_name2.
              ENDIF.
*<<< Wolf.A., 23.02.2016, Mapping der Namensfelder entsprechend dem Konzept "ITBM - Datenhaltung Geschäftspartner - 20160216(01) angepasst.

              ls_msgdata-zz_namesformat = <fs_name_address>-name_format_code.
              IF <fs_name_address>-poboxid IS NOT INITIAL.
                CONCATENATE 'Postfach' <fs_name_address>-poboxid INTO ls_msgdata-street_bu.
              ELSE.
                ls_msgdata-street_bu = <fs_name_address>-streetname.
              ENDIF.

              ls_msgdata-housenr_bu = <fs_name_address>-houseid.
              ls_msgdata-housenrext_bu = <fs_name_address>-houseid_add.
              ls_msgdata-city_bu = <fs_name_address>-cityname.
              ls_msgdata-postcode_bu = <fs_name_address>-postalcode.
              ls_msgdata-zz_country_bu = <fs_name_address>-countrycode. "THIMEL.R 20150415 M4898 _ext entfernt

            WHEN /idxgc/if_constants_ide=>gc_nad_02_qual_eo.
              ls_msgdata-zz_namelstabwre = <fs_name_address>-fam_comp_name1.
              ls_msgdata-zz_namelst2abwre = <fs_name_address>-fam_comp_name2.
              ls_msgdata-zz_namefstabwre = <fs_name_address>-first_name1.
              ls_msgdata-zz_namefst2abwre = <fs_name_address>-first_name2.
              ls_msgdata-zz_namesformat = <fs_name_address>-name_format_code.
              ls_msgdata-zz_strabwre = <fs_name_address>-streetname.
*>>> Wolf.A., 23.02.2016, FA 01.04.16
              TRY.
                  /adesso/cl_mdc_utility=>split_houseid_compl( EXPORTING iv_houseid_compl = <fs_name_address>-houseid_compl
                                                               IMPORTING ev_houseid       = lv_houseid
                                                                         ev_houseid_add   = lv_houseid_add ).
                  ls_msgdata-zz_hsnrabwre = lv_houseid.
                  ls_msgdata-zz_hsnrergabwre = lv_houseid_add.
                CATCH /adesso/cx_mdc_general.
                  "erstmal nichts tun
              ENDTRY.
*              ls_msgdata-zz_hsnrabwre = <fs_name_address>-houseid.
*              ls_msgdata-zz_hsnrergabwre = <fs_name_address>-houseid_add.
*<<< Wolf.A., 23.02.2016, FA 01.04.16
              ls_msgdata-zz_ortabwre = <fs_name_address>-cityname.
              ls_msgdata-zz_plzabwre = <fs_name_address>-postalcode.
              ls_msgdata-zz_countryabwre = <fs_name_address>-countrycode. "THIMEL.R 20150415 M4898 _ext entfernt

            WHEN /idxgc/if_constants_ide=>gc_nad_02_qual_dp.
              ls_msgdata-street = <fs_name_address>-streetname.
*>>> Wolf.A., 23.02.2016, FA 01.04.16
              TRY .
                  /adesso/cl_mdc_utility=>split_houseid_compl( EXPORTING iv_houseid_compl = <fs_name_address>-houseid_compl
                                                               IMPORTING ev_houseid       = lv_houseid
                                                                         ev_houseid_add   = lv_houseid_add ).
                  ls_msgdata-housenr = lv_houseid.
                  ls_msgdata-housenrext = lv_houseid_add.
                CATCH /adesso/cx_mdc_general.
                  "erstmal nichts tun
              ENDTRY.
*              ls_msgdata-housenr = <fs_name_address>-houseid.
*              ls_msgdata-housenrext = <fs_name_address>-houseid_add.
*<<< Wolf.A., 23.02.2016, FA 01.04.16
              ls_msgdata-city = <fs_name_address>-cityname.
              ls_msgdata-postcode = <fs_name_address>-postalcode.
              ls_msgdata-zz_country = <fs_name_address>-countrycode. "THIMEL.R 20150415 M4898 _ext entfernt
*>>> Maxim Schmidt, 19.04.2016, 5322: Test: SW2_EoG10 - neuer GP im Netz hat falsche Adresse
            WHEN /idxgc/if_constants_ide=>gc_nad_qual_z04.
              ls_msgdata-street_bu = <fs_name_address>-streetname.
              TRY .
                  /adesso/cl_mdc_utility=>split_houseid_compl( EXPORTING iv_houseid_compl = <fs_name_address>-houseid_compl
                                                               IMPORTING ev_houseid       = lv_houseid
                                                                         ev_houseid_add   = lv_houseid_add ).
                  ls_msgdata-housenr_bu = lv_houseid.
                  ls_msgdata-housenrext_bu = lv_houseid_add.
                CATCH /adesso/cx_mdc_general.
                  "erstmal nichts tun
              ENDTRY.
              ls_msgdata-city_bu = <fs_name_address>-cityname.
              ls_msgdata-postcode_bu = <fs_name_address>-postalcode.
              ls_msgdata-zz_country_bu = <fs_name_address>-countrycode.
*<<< Maxim Schmidt, 19.04.2016, 5322: Test: SW2_EoG10 - neuer GP im Netz hat falsche Adresse
          ENDCASE.
        ENDLOOP.

        "MARKTPARTNER_ADD
        LOOP AT <fs_msg_hdr>-marketpartner_add ASSIGNING <fs_marktpartner_add>.
          CASE <fs_marktpartner_add>-party_func_qual.
            WHEN /idxgc/if_constants_ide=>gc_nad_02_qual_deb.
              ls_msgdata-zz_mosn = <fs_marktpartner_add>-party_identifier.
              ls_msgdata-/idexge/mos_cdla = <fs_marktpartner_add>-codelist_agency.
              ls_msgdata-/idexge/bill_deb = <fs_marktpartner_add>-mos_is_default.
            WHEN /idxgc/if_constants_ide=>gc_nad_02_qual_dde.
              ls_msgdata-zz_mdsn = <fs_marktpartner_add>-party_identifier.
              ls_msgdata-/idexge/mds_cdla = <fs_marktpartner_add>-codelist_agency.
              ls_msgdata-/idexge/bill_dde = <fs_marktpartner_add>-mds_is_default.
          ENDCASE.
        ENDLOOP.

        "AMID
        LOOP AT <fs_msg_hdr>-amid ASSIGNING <fs_amid>.
          ls_msgdata-zz_checkidentifier = <fs_amid>-amid.
          EXIT.
        ENDLOOP.

        "---------------------------------------------------------------------------
        "Mapping von Feldern für die es kein passendes Feld in den PDoc-Daten gibt
        "---------------------------------------------------------------------------
        LOOP AT <fs_msg_hdr>-attribute ASSIGNING <fs_attributes>.
          IF <fs_attributes>-scenario_id = 'CUSTOMER_FIELDS'.
            CASE <fs_attributes>-attr_type.
              WHEN 'ZZ_DEXFORMAT'.
                ls_msgdata-zz_dexformat = <fs_attributes>-attr_id.
            ENDCASE.
          ENDIF.
        ENDLOOP.

        APPEND ls_msgdata TO et_msg_hdr.

        "COMMENTS
        LOOP AT <fs_msg_hdr>-msgcomments ASSIGNING <fs_msgcomment>.
          CLEAR ls_msg_comment.
          ls_msg_comment-mandt      = sy-mandt.
          ls_msg_comment-switchnum  = <fs_msg_hdr>-switchnum.
          IF <fs_msg_hdr>-msgdatanum <> /idxgc/if_constants=>gc_temp_indicator.
            ls_msg_comment-msgdatanum = <fs_msg_hdr>-msgdatanum.
          ENDIF.
          ls_msg_comment-commentnum = <fs_msgcomment>-commentnum.
          ls_msg_comment-commenttag = <fs_msgcomment>-text_subj_qual.
          ls_msg_comment-commenttxt = <fs_msgcomment>-free_text_value.
          APPEND ls_msg_comment TO et_msg_comments.
        ENDLOOP.

        CALL METHOD /idxgc/cl_process_document=>conv_any_to_eideswtmsgadddata2
          EXPORTING
            x_switchnum         = is_pdoc_data-switchnum
            x_msgdatanum        = <fs_msg_hdr>-msgdatanum
            x_adddata_any       = <fs_msg_hdr>-msg_add_data_all
          RECEIVING
            y_eideswtmsgadddata = ls_msg_add.

        INSERT ls_msg_add INTO TABLE et_msg_add.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD parse_name_data.
***************************************************************************************************
* WOLF.A, 20160223, Aufteilung eines Namensfelds in zwei Felder der Länge 40
***************************************************************************************************

    DATA: lt_match_result TYPE TABLE OF match_result,
          wa_match_result TYPE          match_result.

    IF strlen( iv_string ) > 40.
      IF iv_string+39(1) <> space AND iv_string+40(1) <> space.
        FIND ALL OCCURRENCES OF ` ` IN iv_string RESULTS lt_match_result.
        SORT lt_match_result BY offset DESCENDING.
        LOOP AT lt_match_result INTO wa_match_result WHERE offset < 40.
          ev_string_1 = iv_string(wa_match_result-offset).
          ev_string_2 = iv_string+wa_match_result-offset.
          EXIT.
        ENDLOOP.
      ELSEIF iv_string+39(1) <> space AND iv_string+40(1) = space.
        ev_string_1 = iv_string(40).
        ev_string_2 = iv_string+40.
      ELSEIF iv_string+39(1) = space AND iv_string+40(1) <> space.
        ev_string_1 = iv_string(40).
        ev_string_2 = iv_string+40.
      ELSE.
        ev_string_1 = iv_string(40).
        ev_string_2 = iv_string+40.
      ENDIF.
    ELSE.
      ev_string_1 = iv_string.
    ENDIF.
    SHIFT ev_string_2 LEFT DELETING LEADING space.
  ENDMETHOD.


  METHOD search_msgdata_by_param.

    SELECT * FROM eideswtmsgdata INTO TABLE et_eideswtmsgdata
      WHERE category IN it_category AND
            direction IN it_direction AND
            transreason IN it_transreason AND
            msgstatus IN it_msgstatus AND
            moveoutdate IN it_moveoutdate AND
            ext_ui IN it_ext_ui.

  ENDMETHOD.


  METHOD trigger_event_msgprocessed.

* Kopie von /IDXGC/CL_MESSAGE_UTILMD_IN

  DATA: lr_container            TYPE REF TO if_swf_ifs_parameter_container,
        ls_por                  TYPE sibflpor,
        lr_previous             TYPE REF TO cx_swf_evt_exception.

    ls_por-instid = is_proc_step_key-proc_ref." PDOC Number
    ls_por-typeid = /idxgc/if_constants_add=>gc_object_pdoc_bor."'/IDXGC/DOC'."Class name
    ls_por-catid  = /idxgc/if_constants_add=>gc_object_catid_bo. " type

* Get event container
    CALL METHOD cl_swf_evt_event=>get_event_container
      EXPORTING
        im_objcateg  = ls_por-catid
        im_objtype   = ls_por-typeid
        im_event     = /idxgc/if_constants_add=>gc_evt_messageprocessed "'PDOCMESSAGEPROCESSED'
      RECEIVING
        re_reference = lr_container.

* Set container element
    TRY.
        CALL METHOD lr_container->set
          EXPORTING
            name  = /idxgc/if_constants_add=>gc_proc_step_ref "'PROC_STEP_REF'
            value = is_proc_step_key-proc_step_ref. "PROC_STEP_REF.

        CALL METHOD lr_container->set
          EXPORTING
            name  = /idxgc/if_constants_add=>gc_bmid_event "'BMID'
            value = iv_bmid.

      CATCH cx_swf_cnt_cont_access_denied .             "#EC NO_HANDLER
      CATCH cx_swf_cnt_elem_access_denied .             "#EC NO_HANDLER
      CATCH cx_swf_cnt_elem_not_found .                 "#EC NO_HANDLER
      CATCH cx_swf_cnt_elem_type_conflict .             "#EC NO_HANDLER
      CATCH cx_swf_cnt_unit_type_conflict .             "#EC NO_HANDLER
      CATCH cx_swf_cnt_elem_def_invalid .               "#EC NO_HANDLER
      CATCH cx_swf_cnt_container .                      "#EC NO_HANDLER
    ENDTRY.

    TRY.
        CALL METHOD cl_swf_evt_event=>raise
          EXPORTING
            im_objcateg        = ls_por-catid
            im_objtype         = ls_por-typeid
            im_event           = /idxgc/if_constants_add=>gc_evt_messageprocessed "'PDOCMESSAGEPROCESSED'
            im_objkey          = ls_por-instid
            im_event_container = lr_container.
      CATCH cx_swf_evt_exception INTO lr_previous.
        CALL METHOD /idxgc/cx_process_error=>raise_exception_from_msg
          EXPORTING
            ir_previous = lr_previous.

    ENDTRY.

  ENDMETHOD.


  METHOD trigger_event_processed.
    ">>>SCHMIDT.C Kopie von /IDXGC/CL_MESSAGE_UTILMD_IN->TRIGGER_EVENT_PROCESSED
    DATA: lr_container      TYPE REF TO if_swf_ifs_parameter_container,
          ls_por            TYPE        sibflpor,
          ls_proc_step_data TYPE        /idxgc/s_proc_step_data,
          ls_attribute      TYPE        /idxgc/s_attr_details,
          lr_previous       TYPE REF TO cx_swf_evt_exception.

    ls_por-instid = is_proc_step_key-proc_ref." PDOC Number
    ls_por-typeid = /idxgc/if_constants_add=>gc_object_pdoc_bor."'/IDXGC/DOC'."Class name
    ls_por-catid  = /idxgc/if_constants_add=>gc_object_catid_bo. " type

* Get event container
    CALL METHOD cl_swf_evt_event=>get_event_container
      EXPORTING
        im_objcateg  = ls_por-catid
        im_objtype   = ls_por-typeid
        im_event     = /idxgc/if_constants_add=>gc_evt_messageprocessed "'PDOCMESSAGEPROCESSED'
      RECEIVING
        re_reference = lr_container.

    READ TABLE is_proc_data-steps WITH KEY proc_step_ref = is_proc_step_key-proc_step_ref
           INTO ls_proc_step_data.
    IF sy-subrc = 0.
      READ TABLE ls_proc_step_data-attribute WITH KEY scenario_id = /idxgc/if_constants_add=>gc_scenario_id_response
           INTO ls_attribute.
      IF sy-subrc = 0.
        IF ls_attribute-attr_id IS NOT INITIAL.
*       Set container element 'PROC_SEND_STEP_REF'
          TRY.
              CALL METHOD lr_container->set
                EXPORTING
                  name  = /idxgc/if_constants_add=>gc_proc_send_step_ref "'PROC_SEND_STEP_REF'
                  value = ls_attribute-attr_id.
            CATCH cx_swf_cnt_cont_access_denied .       "#EC NO_HANDLER
            CATCH cx_swf_cnt_elem_access_denied .       "#EC NO_HANDLER
            CATCH cx_swf_cnt_elem_not_found .           "#EC NO_HANDLER
            CATCH cx_swf_cnt_elem_type_conflict .       "#EC NO_HANDLER
            CATCH cx_swf_cnt_unit_type_conflict .       "#EC NO_HANDLER
            CATCH cx_swf_cnt_elem_def_invalid .         "#EC NO_HANDLER
            CATCH cx_swf_cnt_container .                "#EC NO_HANDLER
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.

* Set container element
    TRY.
        CALL METHOD lr_container->set
          EXPORTING
            name  = /idxgc/if_constants_add=>gc_proc_step_ref "'PROC_STEP_REF'
            value = is_proc_step_key-proc_step_ref. "PROC_STEP_REF.

        CALL METHOD lr_container->set
          EXPORTING
            name  = /idxgc/if_constants_add=>gc_bmid_event "'BMID'
            value = iv_bmid.

      CATCH cx_swf_cnt_cont_access_denied .             "#EC NO_HANDLER
      CATCH cx_swf_cnt_elem_access_denied .             "#EC NO_HANDLER
      CATCH cx_swf_cnt_elem_not_found .                 "#EC NO_HANDLER
      CATCH cx_swf_cnt_elem_type_conflict .             "#EC NO_HANDLER
      CATCH cx_swf_cnt_unit_type_conflict .             "#EC NO_HANDLER
      CATCH cx_swf_cnt_elem_def_invalid .               "#EC NO_HANDLER
      CATCH cx_swf_cnt_container .                      "#EC NO_HANDLER
    ENDTRY.

    TRY.
        CALL METHOD cl_swf_evt_event=>raise
          EXPORTING
            im_objcateg        = ls_por-catid
            im_objtype         = ls_por-typeid
            im_event           = /idxgc/if_constants_add=>gc_evt_messageprocessed "'PDOCMESSAGEPROCESSED'
            im_objkey          = ls_por-instid
            im_event_container = lr_container.
      CATCH cx_swf_evt_exception INTO lr_previous.
        CALL METHOD /idxgc/cx_ide_error=>raise_ide_exception_from_msg
          EXPORTING
            ir_previous = lr_previous.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
