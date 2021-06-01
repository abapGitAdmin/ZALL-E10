class ZCL_AGC_APERAK_V23B_CL definition
  public
  inheriting from /IDEXGE/CL_APERAK_V22_CL
  create public .

public section.

  methods Z_ISU_APERAK_OUT
    importing
      !IR_APERAK_HANDLER type ref to ZCL_APERAK_HANDLER_001
    exporting
      !ES_IDOC_DATA type EDEX_IDOCDATA
    exceptions
      ERROR_OCCURRED .
protected section.

  constants GC_MSCOD_APERAK_004 type EDI_MESCOD value '004'. "#EC NOTEXT
  constants GC_ASSIGNED_CODE_APERAK_21A type CHAR6 value '2.1a'. "#EC NOTEXT
  data GS_CL_SEG_FTX_03 type /IDXGC/E1_FTX_03 .

  methods Z_GET_REFERENCE_NUMBER
    exceptions
      ERROR_OCCURRED .
  methods Z_FILL_CONTROL_DATA
    importing
      !IS_RECEIVER_DETAILS type /IDXGC/S_MARKPAR_DETAILS
    returning
      value(RS_IDOC_CONTROL) type EDIDC .
  methods Z_FILL_UNB
    importing
      !IS_SENDER_DETAILS type /IDXGC/S_MARKPAR_DETAILS
      !IS_RECEIVER_DETAILS type /IDXGC/S_MARKPAR_DETAILS .
  methods Z_FILL_UNH .
  methods Z_FILL_BGM .
  methods Z_FILL_DTM .
  methods Z_FILL_SG2_RFF
    importing
      !IV_REF_INTCH_CONTR type /IDXGC/DE_REF_INTCH_CONTR .
  methods Z_FILL_SG2_DTM
    importing
      !IV_REF_INTCH_DATE type /IDXGC/DE_REF_INTCH_DATE
      !IV_REF_INTCH_TIME type /IDXGC/DE_REF_INTCH_TIME .
  methods Z_FILL_SG3_NAD
    importing
      !IS_MARKETPARTNER_DETAILS type /IDXGC/S_MARKPAR_DETAILS .
  methods Z_FILL_SG4_ERC
    importing
      !IV_ERR_CODE type /IDXGC/DE_ERR_CODE .
  methods Z_FILL_SG4_FTX
    importing
      !IV_INFO_ABO_1 type ZAPRK_FTX
      !IV_INFO_ABO_2 type ZAPRK_FTX .
  methods Z_FILL_SG5_RFF
    importing
      !IS_ERROR_REF type /IDXGC/S_ERROR_REF_DETAILS .
  methods Z_FILL_SG5_FTX
    importing
      !IV_INFO_AAO_1 type ZAPRK_FTX
      !IV_INFO_AAO_2 type ZAPRK_FTX .
private section.
ENDCLASS.



CLASS ZCL_AGC_APERAK_V23B_CL IMPLEMENTATION.


  METHOD z_fill_bgm.
    CLEAR sis_cl_seg_bgm_02.

    sis_cl_seg_bgm_02-document_name_code  = /idxgc/if_constants_ide=>gc_msg_category_313.
    sis_cl_seg_bgm_02-document_identifier = siv_refno.

    append_idoc_seg( sis_cl_seg_bgm_02 ).
  ENDMETHOD.


  METHOD z_fill_control_data.
    rs_idoc_control-mestyp = /idxgc/if_constants_ide=>gc_msgtp_aperak.
    rs_idoc_control-rcvprn = is_receiver_details-serviceid.

    rs_idoc_control-sndprt = co_flag_notmarked.
    rs_idoc_control-rcvprt = 'SP'.
    rs_idoc_control-sndprn = co_flag_notmarked.

    rs_idoc_control-cimtyp = co_flag_notmarked.
    rs_idoc_control-sndpfc = co_flag_notmarked.
    rs_idoc_control-rcvpfc = co_flag_notmarked.

* Anpassung zur Formatumstellung
    rs_idoc_control-mescod = gc_mscod_aperak_004.
    rs_idoc_control-idoctp = /idxgc/if_constants_ide=>gc_idoctp_aperak_02.
  ENDMETHOD.


  METHOD z_fill_dtm.
    DATA: lv_time_utc TYPE tznutcdiff,
          lv_date     TYPE char35,
          lv_pre_sign TYPE char1.

    CLEAR sis_cl_seg_dtm_01.

* date of document
    sis_cl_seg_dtm_01-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_msg_date_time.
    sis_cl_seg_dtm_01-date_time_period_format_code         = cl_isu_datex_co=>co_dtm_vdew_date_time_format.
    CONCATENATE sy-datlo sy-timlo(4) INTO sis_cl_seg_dtm_01-date_time_period_value.

    append_idoc_seg( sis_cl_seg_dtm_01 ).
  ENDMETHOD.


  METHOD z_fill_sg2_dtm.
    CLEAR sis_cl_seg_dtm_03.

    sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_rff_vdew_ref_data_time.
    sis_cl_seg_dtm_03-date_time_period_format_code  = cl_isu_datex_co=>co_dtm_vdew_date_time_format.
    CONCATENATE iv_ref_intch_date iv_ref_intch_time(4) INTO sis_cl_seg_dtm_03-date_time_period_value.

    append_idoc_seg( sis_cl_seg_dtm_03 ).
  ENDMETHOD.


  METHOD Z_FILL_SG2_RFF.
    CLEAR SIS_CL_SEG_RFF_08.

    SIS_CL_SEG_RFF_08-REFERENCE_CODE_QUALIFIER = /idxgc/if_constants_ide=>gc_rff_qual_ace.
    SIS_CL_SEG_RFF_08-REFERENCE_IDENTIFIER = iv_ref_intch_contr.

    append_idoc_seg( SIS_CL_SEG_RFF_08 ).
  ENDMETHOD.


  METHOD z_fill_sg3_nad.
    DATA:
      lv_mp_ext_id TYPE dunsnr.

    CLEAR sis_cl_seg_nad_03.

    sis_cl_seg_nad_03-party_function_code_qualifier = is_marketpartner_details-party_func_qual.
    sis_cl_seg_nad_03-code_list_resp_agency_code_1 = is_marketpartner_details-codelist_agency.
    lv_mp_ext_id = is_marketpartner_details-party_identifier.
    SHIFT lv_mp_ext_id LEFT DELETING LEADING space.
    sis_cl_seg_nad_03-party_identifier = lv_mp_ext_id.

    append_idoc_seg( sis_cl_seg_nad_03 ).
  ENDMETHOD.


  METHOD z_fill_sg4_erc.
    CLEAR sis_cl_seg_erc_01.

    sis_cl_seg_erc_01-application_error_code = iv_err_code.

    append_idoc_seg( sis_cl_seg_erc_01 ).
  ENDMETHOD.


  METHOD z_fill_sg4_ftx.

    DATA: lv_info_abo TYPE /idxgc/e1_ftx_02-free_text_value_1.

    CLEAR lv_info_abo.
    CLEAR sis_cl_seg_ftx_02.

    sis_cl_seg_ftx_02-text_subject_code_qualifier = 'ABO'.

    CONCATENATE iv_info_abo_1
                iv_info_abo_2
                INTO lv_info_abo.

    sis_cl_seg_ftx_02-free_text_value_1 = lv_info_abo.


    append_idoc_seg( sis_cl_seg_ftx_02 ).

  ENDMETHOD.


  METHOD z_fill_sg5_ftx.
    DATA: lv_info_aao TYPE /idxgc/e1_ftx_03-free_text_value_1.

    CLEAR: gs_cl_seg_ftx_03, lv_info_aao.

    gs_cl_seg_ftx_03-text_subject_code_qualifier = 'AAO'.
    CONCATENATE iv_info_aao_1 iv_info_aao_2 INTO lv_info_aao.
    gs_cl_seg_ftx_03-free_text_value_1 = lv_info_aao.

    append_idoc_seg( gs_cl_seg_ftx_03 ).
  ENDMETHOD.


  METHOD z_fill_sg5_rff.

    CLEAR sis_cl_seg_rff_09.

    IF NOT is_error_ref-msg_refno IS INITIAL.
      sis_cl_seg_rff_09-reference_code_qualifier = /idxgc/if_constants_ide=>gc_rff_qual_acw.
      sis_cl_seg_rff_09-reference_identifier = is_error_ref-msg_refno.
      append_idoc_seg( sis_cl_seg_rff_09 ).
    ENDIF.

    IF NOT is_error_ref-document_ident IS INITIAL.
      sis_cl_seg_rff_09-reference_code_qualifier = /idxgc/if_constants_ide=>gc_rff_qual_ago.
      sis_cl_seg_rff_09-reference_identifier = is_error_ref-document_ident.
      append_idoc_seg( sis_cl_seg_rff_09 ).
    ENDIF.

    IF NOT is_error_ref-transaction_ref IS INITIAL.
      sis_cl_seg_rff_09-reference_code_qualifier = /idxgc/if_constants_ide=>gc_rff_qual_tn.
      sis_cl_seg_rff_09-reference_identifier = is_error_ref-transaction_ref.
      append_idoc_seg( sis_cl_seg_rff_09 ).
    ENDIF.
  ENDMETHOD.


  METHOD z_fill_unb.
    DATA:
      lv_sender_ext_id   TYPE dunsnr,
      lv_receiver_ext_id TYPE dunsnr.

    lv_sender_ext_id = is_sender_details-party_identifier.
    lv_receiver_ext_id = is_receiver_details-party_identifier.

    SHIFT lv_sender_ext_id LEFT DELETING LEADING space.
    SHIFT lv_receiver_ext_id LEFT DELETING LEADING space.

    sis_cl_seg_unb_01-interchange_sender_ident       =  lv_sender_ext_id.
    sis_cl_seg_unb_01-interchange_recipient_ident     =  lv_receiver_ext_id.

    IF is_sender_details-codelist_agency IS INITIAL OR
       is_sender_details-codelist_agency = co_codelist_agency_vdew.
      sis_cl_seg_unb_01-identification_code_qualifier1 = co_unb_codelist_agency_vdew.
    ELSEIF is_sender_details-codelist_agency = co_codelist_agency_gs1.
      sis_cl_seg_unb_01-identification_code_qualifier1 = co_unb_codelist_agency_gs1.
    ELSEIF is_sender_details-codelist_agency = co_codelist_agency_dvgw.
      sis_cl_seg_unb_01-identification_code_qualifier1 = co_unb_codelist_agency_dvgw.
    ELSEIF is_sender_details-codelist_agency = co_codelist_agency_easee.
      sis_cl_seg_unb_01-identification_code_qualifier1 = co_unb_codelist_agency_easee.
    ELSEIF is_sender_details-codelist_agency = co_codelist_agency_etso.
      sis_cl_seg_unb_01-identification_code_qualifier1 = co_unb_codelist_agency_etso.
    ENDIF.

    IF is_receiver_details-codelist_agency IS INITIAL OR
      is_receiver_details-codelist_agency = co_codelist_agency_vdew.
      sis_cl_seg_unb_01-identification_code_qualifier2 = co_unb_codelist_agency_vdew.
    ELSEIF is_receiver_details-codelist_agency = co_codelist_agency_gs1.
      sis_cl_seg_unb_01-identification_code_qualifier2 = co_unb_codelist_agency_gs1.
    ELSEIF is_receiver_details-codelist_agency = co_codelist_agency_dvgw.
      sis_cl_seg_unb_01-identification_code_qualifier2 = co_unb_codelist_agency_dvgw.
    ELSEIF is_receiver_details-codelist_agency = co_codelist_agency_easee.
      sis_cl_seg_unb_01-identification_code_qualifier2 = co_unb_codelist_agency_easee.
    ELSEIF is_receiver_details-codelist_agency = co_codelist_agency_etso.
      sis_cl_seg_unb_01-identification_code_qualifier2 = co_unb_codelist_agency_etso.
    ENDIF.

    sis_cl_seg_unb_01-syntax_identifier  = co_isu_syntax_ident.
    sis_cl_seg_unb_01-syntax_version_number = co_isu_syntax_version.
    WRITE sy-datum TO sis_cl_seg_unb_01-date YYMMDD.
    sis_cl_seg_unb_01-time       = sy-uzeit.
    sis_cl_seg_unb_01-interchange_control_reference       = siv_refno.

    append_idoc_seg( sis_cl_seg_unb_01 ).
  ENDMETHOD.


  METHOD z_fill_unh.
    CLEAR sis_cl_seg_unh_01.

    sis_cl_seg_unh_01-message_reference_number = siv_refno.
    sis_cl_seg_unh_01-message_type = co_aperak_identifier.
    sis_cl_seg_unh_01-message_version_number = cl_isu_datex_co=>co_unh_vdew_msg_vers_utilmd_d.
    sis_cl_seg_unh_01-message_release_number = co_message_release_07b.
    sis_cl_seg_unh_01-controlling_agency_coded_1 = cl_isu_datex_co=>co_unh_vdew_msg_contr_agency.
    sis_cl_seg_unh_01-association_assigned_code  = gc_assigned_code_aperak_21a. "Anpassung zur Formatumstellung

    append_idoc_seg( sis_cl_seg_unh_01 ).
  ENDMETHOD.


  METHOD z_get_reference_number.
    DATA: lv_ref_nr TYPE char40.

* get ref number
    CALL METHOD /idexge/isu_datex_idoc_build=>get_reference_nr
      EXPORTING
        x_name_nr_obj = /idexge/isu_datex_idoc_build=>co_isu_crefno
      IMPORTING
        y_ref_nr      = lv_ref_nr
      EXCEPTIONS
        general_fault = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING error_occurred.
    ENDIF.

    siv_refno = lv_ref_nr.
  ENDMETHOD.


  METHOD z_isu_aperak_out.
***************************************************************************************************
* THIMEL.R 20150707 Einführung CL
*   Logik übernommen aus Klassenmethode ZCL_ISU_APERAK_23->Z_ISU_APERAK_OUT und für neuen Basistyp
*     angepasst.
***************************************************************************************************
    DATA:
      ls_proc_step_data   TYPE /idxgc/s_proc_step_data,
      ls_sender_details   TYPE /idxgc/s_markpar_details,
      ls_receiver_details TYPE /idxgc/s_markpar_details,
      lv_ftx_abo_1        TYPE /idxgc/de_free_text_value,
      lv_ftx_abo_2        TYPE /idxgc/de_free_text_value,
      lv_ftx_aao_1        TYPE /idxgc/de_free_text_value,
      lv_ftx_aao_2        TYPE /idxgc/de_free_text_value.

    FIELD-SYMBOLS:
      <error_ref>   TYPE /idxgc/s_error_ref_details,
      <msgcomments> TYPE /idxgc/s_msgcom_details.

* --- (Globale) Variablen initialisieren -------------------------------------------------------- *
    me->init_out( ).

* --- Daten aus Handler holen ------------------------------------------------------------------- *
    ls_proc_step_data = ir_aperak_handler->get_proc_step_data( ).
    ls_sender_details = ir_aperak_handler->get_sender_details( ).
    ls_receiver_details = ir_aperak_handler->get_receiver_details( ).

* --- Control-Daten ----------------------------------------------------------------------------- *
    es_idoc_data-control = z_fill_control_data( is_receiver_details = ls_receiver_details ).

**---------------- Get reference number for APERAK----------------------
    CALL METHOD z_get_reference_number
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
    ENDIF.

* --- Segmente ---------------------------------------------------------------------------------- *

*** UNA *******************************************************************************************
    fill_una( ).

*** UNA>>UNB **************************************************************************************
    z_fill_unb( is_sender_details = ls_sender_details is_receiver_details = ls_receiver_details ).

* UNA and UNB are service segments, they should not be included in the segment count
    CLEAR siv_seg_count.

*** UNA>>UNB>>UNH *********************************************************************************
    z_fill_unh( ).

*** UNA>>UNB>>BGM *********************************************************************************
    z_fill_bgm( ).

*** UNA>>UNB>>DTM *********************************************************************************
    z_fill_dtm( ).

*** UNA>>UNB>>SG2-RFF *****************************************************************************
    z_fill_sg2_rff( iv_ref_intch_contr = ls_proc_step_data-ref_intch_contr ).

*** UNA>>UNB>>SG2-RFF>>DTM ************************************************************************
    z_fill_sg2_dtm( iv_ref_intch_date = ls_proc_step_data-ref_intch_date
                    iv_ref_intch_time = ls_proc_step_data-ref_intch_time ).

*** UNA>>UNB>>SG3-NAD *****************************************************************************
    z_fill_sg3_nad( is_marketpartner_details = ls_sender_details ).
    z_fill_sg3_nad( is_marketpartner_details = ls_receiver_details ).

* --- Fehler-Segmente --------------------------------------------------------------------------- *

    LOOP AT ls_proc_step_data-error_ref ASSIGNING <error_ref>.
*** UNA>>UNB>>SG4-ERC *****************************************************************************
      z_fill_sg4_erc( iv_err_code = <error_ref>-err_code ).

*** UNA>>UNB>>SG4-ERC>>FTX ************************************************************************
      LOOP AT ls_proc_step_data-msgcomments ASSIGNING <msgcomments>
        WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_ftx_qual_abo.
        IF <msgcomments>-commentnum = 1.
          lv_ftx_abo_1 = <msgcomments>-free_text_value.
        ELSEIF <msgcomments>-commentnum = 2.
          lv_ftx_abo_2 = <msgcomments>-free_text_value.
        ENDIF.
      ENDLOOP.
      IF lv_ftx_abo_1 IS NOT INITIAL.
        CALL METHOD z_fill_sg4_ftx
          EXPORTING
            iv_info_abo_1 = lv_ftx_abo_1
            iv_info_abo_2 = lv_ftx_abo_2.
      ENDIF.

*** UNA>>UNB>>SG4-ERC>>SG5-RFF ********************************************************************
      z_fill_sg5_rff( is_error_ref = <error_ref> ).

*** UNA>>UNB>>SG4-ERC>>SG5-RFF>>FTX ***************************************************************
      LOOP AT ls_proc_step_data-msgcomments ASSIGNING <msgcomments>
        WHERE text_subj_qual = /idxgc/if_constants_ide=>gc_ftx_qual_aao.
        IF <msgcomments>-commentnum = 1.
          lv_ftx_aao_1 = <msgcomments>-free_text_value.
        ELSEIF <msgcomments>-commentnum = 2.
          lv_ftx_aao_2 = <msgcomments>-free_text_value.
        ENDIF.
      ENDLOOP.
      IF lv_ftx_aao_1 IS NOT INITIAL.
        CALL METHOD z_fill_sg5_ftx
          EXPORTING
            iv_info_aao_1 = lv_ftx_aao_1
            iv_info_aao_2 = lv_ftx_aao_2.
      ENDIF.

    ENDLOOP.

*** UNA>>UNB>>UNT *********************************************************************************
    fill_unt( ).

*** UNA>>UNZ **************************************************************************************
    fill_unz( ).

    es_idoc_data-data    = sit_idoc_data.

  ENDMETHOD.
ENDCLASS.
