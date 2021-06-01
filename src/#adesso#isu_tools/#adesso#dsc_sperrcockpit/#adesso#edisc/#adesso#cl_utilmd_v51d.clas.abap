class /ADESSO/CL_UTILMD_V51D definition
  public
  inheriting from /IDEXGE/CL_UTILMD_V51D_CL
  create public .

public section.

  data GS_S_R_VIEW type ZSEND_EMPF_VIEW_TYP .
  data GS_SWTMSGPOD type EIDESWTMSGPOD .
  data GS_EIDESWTDOC type EIDESWTDOC .
  data GV_RECIEVER type SERVICE_PROV .

  methods ISU_UTILMD_IN_ANALYZE
    redefinition .
  methods ISU_UTILMD_OUT_BUILD
    redefinition .
protected section.

  data GR_UTILITY type ref to ZDMS_CL_IDEXGE_UTILITY .

  methods FILL_STREET_CS_CUST
    importing
      !X_PO_FLAG type CHAR1
      !X_STREET type AD_STREET
      !X_HOUSENR type EIDESWTMDHOUSENR
      !X_HOUSENREXT type EIDESWTMDHOUSENREXT
      !X_CITY type AD_CITY1
      !X_EADRDAT type EADRDAT
    changing
      !Y_NAD type /IDXGC/E1_NAD_04 .
  methods FILL_SG8_SEQ_CUST
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_MSGDATANUM_REQ type EIDESWTMDNUM optional .
  methods KORREKTUR_OUTBOUND
    importing
      !IX_SWTMSGPOD type EIDESWTMSGPOD
      !X_SWITCHNUM type EIDESWTNUM
    exporting
      !EX_SWTMSGPOD type EIDESWTMSGPOD .
  methods FILL_SG12_NAD_CS_VY
    importing
      !IS_SWTMSGPOD type EIDESWTMSGPOD
      !IV_SENDER type SERVICEID
      !IV_RECEIVER type SERVICEID
      !IV_SWITCH_MSGCAT type EIDESWTMDCAT
    exceptions
      ERROR_OCCURRED .
  methods GET_VIEW_SEND_RECIEVER
    importing
      !X_SENDER type EIDESWTMDCOMPARTNER
      !X_RECIEVER type EIDESWTMDCOMPARTNER
      !X_CATEGORY type EIDESWTMDCAT
      !X_MSGSTATUS type EIDESWTMDSTATUS
      !X_TRANSREASON type EIDESWTMDTRAN
    exporting
      !X_SEND_EMPF_VIEW type ZSEND_EMPF_VIEW_TYP .
  methods FILL_SG8_ABLEHNUNG
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_DEVICE_DATA type T_V_EGER optional
      !X_INSTALLATION type BAPIISUPODINSTLN_T optional
      !X_MSGDATANUM_REQ type EIDESWTMDNUM optional .
  methods FILL_SG8_Z01
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_DEVICE_DATA type T_V_EGER optional
      !X_INSTALLATION type BAPIISUPODINSTLN_T optional .
  methods FILL_SG8_Z02
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_DEVICE_DATA type T_V_EGER optional .
  methods FILL_SG8_Z03
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_DEVICE_DATA type T_V_EGER optional .
  methods FILL_SG8_Z04
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_DEVICE_DATA type T_V_EGER optional .
  methods FILL_SG8_Z05
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_DEVICE_DATA type T_V_EGER optional .
  methods FILL_SG8_Z06
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_DEVICE_DATA type T_V_EGER optional .
  methods FILL_SG9_QTY_CS_Z09
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD .
  methods GET_LASTPROFIL
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
    exporting
      !Y_SWTMSGPOD type EIDESWTMSGPOD .
  methods FILL_SG12_NAD_CS_A
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_SENDER type SERVICEID
      !X_RECEIVER type SERVICEID
    exceptions
      ERROR_OCCURRED .
  methods FILL_SG4_DTM_CS_SAVE
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
      !X_SWITCH_MSGCAT type EIDESWTMDCAT .
  methods FILL_SG7_CCI_CAV_CUST
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD .
  methods FILL_SG6_RFF_CS_CUST
    importing
      !X_SWTMSGPOD type EIDESWTMSGPOD
    exceptions
      ERROR_OCCURRED .

  methods FILL_BGM_CS
    redefinition .
  methods FILL_BGM_INV
    redefinition .
  methods FILL_BGM_MD
    redefinition .
  methods FILL_SG12_NAD_CS
    redefinition .
  methods FILL_SG12_NAD_CS_OS
    redefinition .
  methods FILL_SG2_NAD
    redefinition .
  methods FILL_SG4_AGR
    redefinition .
  methods FILL_SG4_AGR_INV
    redefinition .
  methods FILL_SG4_DTM_CS
    redefinition .
  methods FILL_SG4_DTM_CS_BILS
    redefinition .
  methods FILL_SG4_DTM_CS_MRD
    redefinition .
  methods FILL_SG4_FTX_CS
    redefinition .
  methods FILL_SG4_IDE_CS
    redefinition .
  methods FILL_SG4_TAX
    redefinition .
  methods FILL_SG5_LOC_CS_A
    redefinition .
  methods FILL_SG5_LOC_CS_B
    redefinition .
  methods FILL_SG5_LOC_CS_C
    redefinition .
  methods FILL_SG5_LOC_CS_D_NEW
    redefinition .
  methods FILL_SG6_RFF_CS_B
    redefinition .
  methods FILL_SG6_RFF_CS_IDEXGG
    redefinition .
  methods FILL_SG7_CAV_CS_C
    redefinition .
  methods FILL_SG7_CAV_CS_D
    redefinition .
  methods FILL_SG7_CCI_CS_C
    redefinition .
  methods FILL_SG7_CCI_CS_D
    redefinition .
  methods FILL_SG8_PIA_CS
    redefinition .
  methods FILL_UNH
    redefinition .
  methods PROC_BGM_PODA
    redefinition .
  methods PROC_SG10_CCI_CAV_CS
    redefinition .
  methods PROC_SG12_NAD_CS
    redefinition .
  methods PROC_SG4_DTM_CS
    redefinition .
  methods PROC_SG4_STS_CS
    redefinition .
  methods PROC_SG6_RFF_CS
    redefinition .
  methods PROC_SG7_CCI_CAV_CS
    redefinition .
  methods PROC_SG8_PIA_CS
    redefinition .
  methods PROC_SG9_QTY_CS
    redefinition .
  methods SET_SEG_REVERSAL
    redefinition .
private section.
ENDCLASS.



CLASS /ADESSO/CL_UTILMD_V51D IMPLEMENTATION.


  method FILL_BGM_CS.
  DATA:
*   Service category (e.g. 01 - Distribution / 02 - Supply / etc.)
    lv_servcat_sender   TYPE intcode,
    lv_servcat_receiver TYPE intcode.

  CLEAR sis_cl_seg_bgm_02.

  y_switch_msgcat = x_swtmsgpod-msgdata-category.

* Message category E35 is given when new supplier and old supplier
* communicates with each other for termination.
  IF x_swtmsgpod-msgdata-category =
        if_isu_ide_switch_constants=>co_swtmdcat_drop.

*   Determine service category for sender of the message
    CALL FUNCTION 'ISU_GET_SERVICETYPE_PROVIDER'
      EXPORTING
        x_service_prov = x_sender
      IMPORTING
        y_service_type = lv_servcat_sender
      EXCEPTIONS
        general_fault  = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
    ENDIF.

*   Determine service category for receiver of the message
    CALL FUNCTION 'ISU_GET_SERVICETYPE_PROVIDER'
      EXPORTING
        x_service_prov = x_receiver
      IMPORTING
        y_service_type = lv_servcat_receiver
      EXCEPTIONS
        general_fault  = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
    ENDIF.

    IF  ( lv_servcat_sender   = co_servrole_supplier )
    AND ( lv_servcat_receiver = co_servrole_supplier ).
      y_switch_msgcat =
          if_isu_ide_switch_constants=>co_swtmdcat_supl_drop.
    ENDIF.

  ENDIF.

  sis_cl_seg_bgm_02-document_name_code = y_switch_msgcat.
  sis_cl_seg_bgm_02-document_identifier = x_ref_nr.
  sis_cl_seg_bgm_02-message_function_code = cl_isu_datex_co=>co_bgm_vdew_msg_doc_func_orig.

  append_idoc_seg( sis_cl_seg_bgm_02 ).

  endmethod.


  METHOD fill_bgm_inv.
*CALL METHOD SUPER->FILL_BGM_INV
*  EXPORTING
*    IV_REF_NR =
*    .
    CLEAR: sis_cl_seg_bgm_02.

    sis_cl_seg_bgm_02-document_name_code = co_bgm_inv.
    sis_cl_seg_bgm_02-document_identifier = iv_ref_nr.
    sis_cl_seg_bgm_02-message_function_code = cl_isu_datex_co=>co_bgm_vdew_msg_doc_func_orig.

    append_idoc_seg( sis_cl_seg_bgm_02 ).
  ENDMETHOD.


  METHOD fill_bgm_md.

    CLEAR sis_cl_seg_bgm_02.

    sis_cl_seg_bgm_02-document_name_code       = cl_isu_datex_co=>co_vdew_changedoc.
    sis_cl_seg_bgm_02-document_identifier      = p_ref_nr.
    sis_cl_seg_bgm_02-message_function_code    = cl_isu_datex_co=>co_bgm_vdew_msg_doc_func_orig.

    append_idoc_seg( sis_cl_seg_bgm_02 ).

  ENDMETHOD.


  method FILL_SG12_NAD_CS.

  data: l_intcode type intcode.

  data: wa_eadrdat type eadrdat. " Used for retrieve Country key and PO box.

  data: lv_po_flag type char1.

  data: lv_service_prov   type service_prov,
        lv_help_exernalid type dunsnr,
        lv_mpid_13        type char13,
        wa_eservprov      type eservprov.

*<Legal Change for V42a>
  data: lv_bu_partner     type bu_partner,
        lv_title_aca1     type ad_title1t,
*        lv_title_aca2     TYPE ad_title2t,
*        lv_title_royl     TYPE ad_titlest,
*        lv_name_last      TYPE bu_namep_l,
*        lv_title_aca      TYPE char40,
        ls_swtdoc         type eideswtdoc,
        ls_but000         type but000.
*<Legal Change for V42a>

* Set PO box as higher priority
  lv_po_flag = co_flag_marked.

*  CLEAR sis_cl_seg_nad_02.´
  data: lv_housenrext type eideswtmdhousenrext.
  clear sis_cl_seg_nad_04.

*<Legal Change for V42a>
*Get switch document
  call function 'ISU_DB_EIDESWTDOC_SINGLE'
    exporting
      x_switchnum  = x_swtmsgpod-msgdata-switchnum
    importing
      y_eideswtdoc = ls_swtdoc
    exceptions
      not_found    = 1
      others       = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      raising error_occurred.
  endif.
*<Legal Change for V42a>

  check x_swtmsgpod-msgdata-category <> 'E44' and
     x_swtmsgpod-msgdata-transreason <> 'Z26'.

* Bei Abmeldeanfrage darf kein NAD gesetzt werden

  if gs_s_r_view-send_view = '01' and
     gs_s_r_view-reciever_view = '03' and
     ( gs_s_r_view-transreason = 'E01' or
       gs_s_r_view-msgstatus is initial ) or                 "Abmeldanfrage Netz -> Lief/Alt
    ( gs_s_r_view-send_view = '01' and
      gs_s_r_view-reciever_view = '03' and
      gs_s_r_view-msgstatus is not initial ).                "Antwort auf Abmeldung Netz -> Lief/Alt
    exit.
  endif.

  if not x_swtmsgpod-int_ui is initial.
    call function 'ISU_ADDRESS_PROVIDE'
      exporting
        x_address_type             = 'Z'
        x_int_ui                   = x_swtmsgpod-int_ui
      importing
        y_eadrdat                  = wa_eadrdat
      exceptions
        not_found                  = 1
        parameter_error            = 2
        object_not_given           = 3
        address_inconsistency      = 4
        installation_inconsistency = 5
        others                     = 6.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

  endif.

*  * settlunit responsible

*   partner name = business partner
*    sis_cl_seg_nad_02-party_function_code_qualifier = cl_isu_datex_co=>co_nad_vdew_name.
  sis_cl_seg_nad_04-party_function_code_qualifier = cl_isu_datex_co=>co_nad_vdew_name.

*  <Legal Change for V42a>
* get business partner
  lv_bu_partner = ls_swtdoc-partner.
*  get business partner information
  if lv_bu_partner is not initial.
    call function 'BUP_BUT000_SELECT_SINGLE'
      exporting
        i_partner      = lv_bu_partner
      importing
        e_but000       = ls_but000
      exceptions
        not_found      = 1
        internal_error = 2
        others         = 3.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              raising error_occurred.
    endif.
  endif.

*  get academic title 1
  if ls_but000-title_aca1 is not initial.
    call function 'ADDR_TSAD2_READ'
      exporting
        title_key     = ls_but000-title_aca1
      importing
        title_text    = lv_title_aca1
      exceptions
        key_not_found = 1
        others        = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              raising error_occurred.
    endif.
  endif.

*    sis_cl_seg_nad_02-party_name_1 = x_swtmsgpod-msgdata-name_l.
  sis_cl_seg_nad_04-party_name_1 = x_swtmsgpod-msgdata-name_l.
  if strlen( x_swtmsgpod-msgdata-name_l ) > 35.
*      sis_cl_seg_nad_02-party_name_2 = x_swtmsgpod-msgdata-name_l+35. "2nd name
    sis_cl_seg_nad_04-party_name_4 = x_swtmsgpod-msgdata-name_l+35. "2nd name
  endif.

*    sis_cl_seg_nad_02-party_name_3 = x_swtmsgpod-msgdata-name_f. "1st name
  sis_cl_seg_nad_04-party_name_3 = x_swtmsgpod-msgdata-name_f. "1st name

  if strlen( x_swtmsgpod-msgdata-name_f ) > 35.
*      sis_cl_seg_nad_02-party_name_4 = x_swtmsgpod-msgdata-name_f+35.
    sis_cl_seg_nad_04-party_name_4 = x_swtmsgpod-msgdata-name_f+35.
  endif.

  if ( not lv_title_aca1 is initial ).
*    OR ( NOT lv_title_aca2 IS INITIAL ).
*      CLEAR lv_title_aca.
*      CONCATENATE lv_title_aca1 lv_title_aca2 INTO lv_title_aca
*        SEPARATED BY space.
*      sis_cl_seg_nad_02-partnername5 = lv_title_aca.

    sis_cl_seg_nad_04-party_name_5 = lv_title_aca1.
  endif.


*   Street Information
  call method me->fill_street_cs_cust
    exporting
      x_po_flag    = lv_po_flag
      x_street     = x_swtmsgpod-msgdata-street_bu
      x_housenr    = x_swtmsgpod-msgdata-housenr_bu
      x_housenrext = x_swtmsgpod-msgdata-housenrext_bu
      x_city       = x_swtmsgpod-msgdata-city_bu
      x_eadrdat    = wa_eadrdat
    changing
      y_nad        = sis_cl_seg_nad_04.

*    sis_cl_seg_nad_02-postal_identification_code = x_swtmsgpod-msgdata-postcode_bu.
*
*    sis_cl_seg_nad_02-party_name_format_code =
*              cl_isu_datex_co=>co_nad_vdew_partner_format_1.
*
*    sis_cl_seg_nad_02-country_identifier = wa_eadrdat-country.
*
*    append_idoc_seg( sis_cl_seg_nad_02 ).

  sis_cl_seg_nad_04-postal_identification_code = x_swtmsgpod-msgdata-postcode_bu.

*  sis_cl_seg_nad_04-party_name_format_code =
*            cl_isu_datex_co=>co_nad_vdew_partner_format_1.
  sis_cl_seg_nad_04-party_name_format_code =
          'Z01'.

  sis_cl_seg_nad_04-country_identifier = wa_eadrdat-country.

  append_idoc_seg( sis_cl_seg_nad_04 ).

*   delivery adress
*    clear sis_cl_seg_nad_02.
  clear sis_cl_seg_nad_04.

*    sis_cl_seg_nad_02-party_function_code_qualifier = cl_isu_datex_co=>co_nad_vdew_premise.
  sis_cl_seg_nad_04-party_function_code_qualifier = cl_isu_datex_co=>co_nad_vdew_dp.

  lv_housenrext = wa_eadrdat-house_num2.

  call method me->fill_street_cs_cust
    exporting
      x_po_flag    = lv_po_flag
      x_street     = wa_eadrdat-street
      x_housenr    = wa_eadrdat-house_num1
      x_housenrext = lv_housenrext
      x_city       = wa_eadrdat-city1
      x_eadrdat    = wa_eadrdat
    changing
      y_nad        = sis_cl_seg_nad_04.

*    sis_cl_seg_nad_02-postal_identification_code = x_swtmsgpod-msgdata-postcode.
*    sis_cl_seg_nad_02-country_identifier = wa_eadrdat-country.
*    append_idoc_seg( sis_cl_seg_nad_02 ).

  sis_cl_seg_nad_04-postal_identification_code = wa_eadrdat-post_code1.
  sis_cl_seg_nad_04-country_identifier = wa_eadrdat-country.
  append_idoc_seg( sis_cl_seg_nad_04 ).

  data: lv_nsp_number   type i,
*        ls_swtdoc       TYPE eideswtdoc,
        ls_new_supplier type eideserprov_new,
        lt_new_supplier type /idexge/tt_serprov_new.

*  if sis_cl_seg_bgm_01-document_name_code = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp and
*     sis_cl_seg_sts_01-status_reason_descr_code_1 = if_isu_ide_switch_constants=>co_transreason_supplier_comp.

  if sis_cl_seg_bgm_02-document_name_code = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp and
     sis_cl_seg_sts_01-status_reason_descr_code_1 = if_isu_ide_switch_constants=>co_transreason_supplier_comp.


* Competiting suppliers
*    sis_cl_seg_nad_02-party_function_code_qualifier = co_nad_old_supplier.
    sis_cl_seg_nad_04-party_function_code_qualifier = co_nad_old_supplier.

    if not x_swtmsgpod-int_ui is initial and
     ( not x_swtmsgpod-msgdata-switchnum is initial ) and
     ( not x_swtmsgpod-msgdata-moveindate is initial ).

* Get switch document information
*      CALL FUNCTION 'ISU_DB_EIDESWTDOC_SINGLE'
*        EXPORTING
*          x_switchnum  = x_swtmsgpod-msgdata-switchnum
*        IMPORTING
*          y_eideswtdoc = ls_swtdoc
*        EXCEPTIONS
*          not_found    = 1
*          OTHERS       = 2.
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                RAISING error_occurred.
*      ENDIF.

* Get all the new suppliers
      call method /idexge/cl_isu_supplier_comp=>find_new_supplier
        exporting
          iv_int_ui       = x_swtmsgpod-int_ui
          iv_moveindate   = x_swtmsgpod-msgdata-moveindate
        importing
          et_new_supplier = lt_new_supplier.

      describe table lt_new_supplier lines lv_nsp_number.
*   Unreal Suppliers Competition
      if lv_nsp_number = 1.
        read table lt_new_supplier into ls_new_supplier index 1.

        if ls_new_supplier = x_receiver.
* Send Suppliers Competition Information to new supplier, old supplier is competitor
          lv_service_prov = ls_swtdoc-service_prov_old.
*          sis_cl_seg_nad_02-partner = ls_swtdoc-service_prov_old.
        else.
* Send Suppliers Competition Information to old supplier, new supplier is competitor
          lv_service_prov = ls_new_supplier.
*          sis_cl_seg_nad_02-partner = ls_new_supplier.
        endif.

* get MP-ID
        call function 'ISU_DB_ESERVPROV_SINGLE'
          exporting
            x_serviceid = lv_service_prov
          importing
            y_eservprov = wa_eservprov
          exceptions
            not_found   = 1
            others      = 2.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                              raising error_occurred.
        endif.
* get Codelistagency
        if not wa_eservprov-externalid is initial.
          call function 'ISU_DATEX_IDENT_CODELIST'
            exporting
              x_ext_idtyp     = wa_eservprov-externalidtyp
              x_idoc_control  = sis_idoc_control
            importing
*              y_extcodelistid = sis_cl_seg_nad_02-code_list_resp_agency_code1
              y_extcodelistid = sis_cl_seg_nad_04-code_list_resp_agency_code_1
            exceptions
              not_supported   = 1
              error_occured   = 2
              others          = 3.
          if sy-subrc <> 0.
            message id sy-msgid type sy-msgty number sy-msgno
                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                                raising error_occurred.
          endif.
        endif.

* MP-ID must be no longer than 13 characters
        lv_help_exernalid    = wa_eservprov-externalid.
        shift lv_help_exernalid left deleting leading space.
        lv_mpid_13           = lv_help_exernalid.

* set MP-ID as partner
*        sis_cl_seg_nad_02-party_identifier = lv_mpid_13.
** append IDoc segment
*        append_idoc_seg( sis_cl_seg_nad_02 ).

        sis_cl_seg_nad_04-party_identifier = lv_mpid_13.
        append_idoc_seg( sis_cl_seg_nad_04 ).
      endif.

*   Real Suppliers Competition: NAD segment is repeated if more than two competing suppliers
      if lv_nsp_number > 1.
        loop at lt_new_supplier into ls_new_supplier.
          if ls_new_supplier <> ls_swtdoc-service_prov_new.
* get MP-ID
            call function 'ISU_DB_ESERVPROV_SINGLE'
              exporting
                x_serviceid = ls_new_supplier
              importing
                y_eservprov = wa_eservprov
              exceptions
                not_found   = 1
                others      = 2.
            if sy-subrc <> 0.
              message id sy-msgid type sy-msgty number sy-msgno
                      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                                  raising error_occurred.
            endif.
* get Codelistagency
            if not wa_eservprov-externalid is initial.
              call function 'ISU_DATEX_IDENT_CODELIST'
                exporting
                  x_ext_idtyp     = wa_eservprov-externalidtyp
                  x_idoc_control  = sis_idoc_control
                importing
*                  y_extcodelistid = sis_cl_seg_nad_02-code_list_resp_agency_code1
                  y_extcodelistid = sis_cl_seg_nad_04-code_list_resp_agency_code_1
                exceptions
                  not_supported   = 1
                  error_occured   = 2
                  others          = 3.
              if sy-subrc <> 0.
                message id sy-msgid type sy-msgty number sy-msgno
                        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                                    raising error_occurred.
              endif.
            endif.

* MP-ID must be no longer than 13 characters
            lv_help_exernalid    = wa_eservprov-externalid.
            shift lv_help_exernalid left deleting leading space.
            lv_mpid_13           = lv_help_exernalid.
* set MP-ID as partner

*            sis_cl_seg_nad_02-party_identifier = lv_mpid_13.
            sis_cl_seg_nad_04-party_identifier = lv_mpid_13.

*            sis_cl_seg_nad_02-partner = ls_new_supplier.
*            append_idoc_seg( sis_cl_seg_nad_02 ).
            append_idoc_seg( sis_cl_seg_nad_04 ).
          endif.
        endloop.
      endif.
    endif.
  endif.


  endmethod.


  METHOD fill_sg12_nad_cs_a.
    DATA: l_intcode TYPE intcode.

    DATA: wa_eadrdat TYPE eadrdat. " Used for retrieve Country key and PO box.

    DATA: lv_po_flag TYPE char1.

    DATA: lv_service_prov   TYPE service_prov,
          lv_help_exernalid TYPE dunsnr,
          lv_mpid_13        TYPE char13,
          wa_eservprov      TYPE eservprov.

    DATA: lv_bu_partner TYPE bu_partner,
          lv_title_aca1 TYPE ad_title1t,
          ls_swtdoc     TYPE eideswtdoc,
          ls_but000     TYPE but000.

* Set PO box as higher priority
    lv_po_flag = co_flag_marked.

    CLEAR sis_cl_seg_nad_04.


    IF NOT gs_s_r_view-transreason = 'ZC9'.         "*20130327 Nagel-Daniel
*Get switch document
      CALL FUNCTION 'ISU_DB_EIDESWTDOC_SINGLE'
        EXPORTING
          x_switchnum  = x_swtmsgpod-msgdata-switchnum
        IMPORTING
          y_eideswtdoc = ls_swtdoc
        EXCEPTIONS
          not_found    = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING error_occurred.
      ENDIF.

      IF NOT x_swtmsgpod-int_ui IS INITIAL.
        CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
          EXPORTING
            x_address_type             = 'Z'
            x_int_ui                   = x_swtmsgpod-int_ui
          IMPORTING
            y_eadrdat                  = wa_eadrdat
          EXCEPTIONS
            not_found                  = 1
            parameter_error            = 2
            object_not_given           = 3
            address_inconsistency      = 4
            installation_inconsistency = 5
            OTHERS                     = 6.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

*   partner name = business partner
      sis_cl_seg_nad_04-party_function_code_qualifier = cl_isu_datex_co=>co_nad_vdew_name.

*   get business partner
      lv_bu_partner = ls_swtdoc-partner.
*   get business partner information
      IF lv_bu_partner IS NOT INITIAL.
        CALL FUNCTION 'BUP_BUT000_SELECT_SINGLE'
          EXPORTING
            i_partner      = lv_bu_partner
          IMPORTING
            e_but000       = ls_but000
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  RAISING error_occurred.
        ENDIF.
      ENDIF.

*   get academic title 1
      IF ls_but000-title_aca1 IS NOT INITIAL.
        CALL FUNCTION 'ADDR_TSAD2_READ'
          EXPORTING
            title_key     = ls_but000-title_aca1
          IMPORTING
            title_text    = lv_title_aca1
          EXCEPTIONS
            key_not_found = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  RAISING error_occurred.
        ENDIF.
      ENDIF.

      sis_cl_seg_nad_04-party_name_1 = ls_but000-name_last.
      IF strlen( ls_but000-name_last ) > 35.
        sis_cl_seg_nad_04-party_name_4 = ls_but000-name_last+35.    "2nd name
      ENDIF.

      sis_cl_seg_nad_04-party_name_3 = ls_but000-name_first.      "1st name
      IF strlen( ls_but000-name_first ) > 35.
        sis_cl_seg_nad_04-party_name_4 = ls_but000-name_first+35.
      ENDIF.

      IF ( NOT lv_title_aca1 IS INITIAL ).
        sis_cl_seg_nad_04-party_name_5 = lv_title_aca1.
      ENDIF.

      sis_cl_seg_nad_04-party_name_format_code = 'Z01'.

      append_idoc_seg( sis_cl_seg_nad_04 ).
    ENDIF.


* beteiligter Markpartner: neuer Lief
    CLEAR sis_cl_seg_nad_04.
    sis_cl_seg_nad_04-party_function_code_qualifier = 'VY'.



    wa_eservprov-externalid = x_swtmsgpod-msgdata-/idexge/extid_s.    "E44/Z26 -> LFa; E44/ZC9 -> LFn

    CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE_EXT_ID'
      EXPORTING
        x_externalid = wa_eservprov-externalid
        x_langu      = sy-langu
      IMPORTING
        y_eservprov  = wa_eservprov
*       Y_SP_NAME    =
      EXCEPTIONS
        not_found    = 1
        not_unique   = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                          RAISING error_occurred.
    ENDIF.

    CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
      EXPORTING
        x_eservprov     = wa_eservprov
        x_idoc_control  = sis_idoc_control
      IMPORTING
        y_extcodelistid = sis_cl_seg_nad_04-code_list_resp_agency_code_1
      EXCEPTIONS
        not_supported   = 1
        error_occured   = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING error_occurred.
    ENDIF.

* MP-ID must be no longer than 13 characters
    lv_help_exernalid    = wa_eservprov-externalid.
    SHIFT lv_help_exernalid LEFT DELETING LEADING space.
    lv_mpid_13           = lv_help_exernalid.

* set MP-ID as partner
    sis_cl_seg_nad_04-party_identifier = lv_mpid_13.

* append IDoc segment
    append_idoc_seg( sis_cl_seg_nad_04 ).
  ENDMETHOD.


  METHOD fill_sg12_nad_cs_os.

    DATA: ls_swtdoc    TYPE eideswtdoc,
          ls_eservprov TYPE eservprov.

    DATA: lv_sp_externalid TYPE dunsnr,
          lv_mpid_13       TYPE char13.

*  CLEAR sis_cl_seg_nad_02.
    CLEAR sis_cl_seg_nad_04.

    IF  ( iv_switch_msgcat EQ co_bgm_vdew_enroll )  "E01
    AND ( is_swtmsgpod-msgdata-transreason EQ if_isu_ide_switch_constants=>co_transreason_movein_out )  "E01
    AND ( is_swtmsgpod-msgdata-msgstatus EQ co_sts_refuse_forced_drop )  "Z35
      OR ( iv_switch_msgcat EQ 'E44' )  "E01 oder E44
     AND ( is_swtmsgpod-msgdata-transreason EQ if_isu_ide_switch_constants=>co_transreason_supplier_comp ).  "Z26

      CALL FUNCTION 'ISU_DB_EIDESWTDOC_SINGLE'
        EXPORTING
          x_switchnum  = is_swtmsgpod-msgdata-switchnum
        IMPORTING
          y_eideswtdoc = ls_swtdoc
        EXCEPTIONS
          not_found    = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

      CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
        EXPORTING
          x_serviceid = ls_swtdoc-service_prov_old
        IMPORTING
          y_eservprov = ls_eservprov
        EXCEPTIONS
          not_found   = 1
          OTHERS      = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

      CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
        EXPORTING
          x_ext_idtyp     = ls_eservprov-externalidtyp
          x_idoc_control  = sis_idoc_control
        IMPORTING
*         y_extcodelistid = sis_cl_seg_nad_02-code_list_resp_agency_code1
          y_extcodelistid = sis_cl_seg_nad_04-code_list_resp_agency_code_1
        EXCEPTIONS
          not_supported   = 1
          error_occured   = 2
          OTHERS          = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

*    check not sis_cl_seg_nad_02-code_list_resp_agency_code1 is initial.
      CHECK NOT sis_cl_seg_nad_04-code_list_resp_agency_code_1 IS INITIAL.

*    sis_cl_seg_nad_02-party_function_code_qualifier = co_nad_old_supplier.  "OS
      sis_cl_seg_nad_04-party_function_code_qualifier = co_nad_other.  "VY

*   MP-ID must be no longer than 13 characters
      lv_sp_externalid = ls_eservprov-externalid.
      SHIFT lv_sp_externalid LEFT DELETING LEADING space.
      lv_mpid_13 = lv_sp_externalid.

      sis_cl_seg_nad_04-party_identifier = lv_mpid_13.
      append_idoc_seg( sis_cl_seg_nad_04 ).
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg12_nad_cs_vy.
    DATA: ls_swtdoc    TYPE eideswtdoc,
          ls_eservprov TYPE eservprov.

    DATA: lv_sp_externalid TYPE dunsnr,
          lv_mpid_13       TYPE char13.

    CLEAR sis_cl_seg_nad_04.

    DATA: lv_serviceid TYPE serviceid.
    IF   iv_switch_msgcat EQ 'E35'  "Kündigung
    AND  ( is_swtmsgpod-msgdata-transreason EQ if_isu_ide_switch_constants=>co_transreason_movein_out OR
      is_swtmsgpod-msgdata-transreason EQ if_isu_ide_switch_constants=>co_transreason_switch )  "E03
      AND  is_swtmsgpod-msgdata-msgstatus EQ 'Z34' .  "Z34 Mehrfachkündigung

      lv_serviceid = is_swtmsgpod-msgdata-/idexge/extid_s.

      CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
        EXPORTING
          x_serviceid = lv_serviceid
        IMPORTING
          y_eservprov = ls_eservprov
        EXCEPTIONS
          not_found   = 1
          OTHERS      = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

      CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
        EXPORTING
          x_ext_idtyp     = ls_eservprov-externalidtyp
          x_idoc_control  = sis_idoc_control
        IMPORTING
          y_extcodelistid = sis_cl_seg_nad_04-code_list_resp_agency_code_1
        EXCEPTIONS
          not_supported   = 1
          error_occured   = 2
          OTHERS          = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

      CHECK NOT sis_cl_seg_nad_04-code_list_resp_agency_code_1 IS INITIAL.

      sis_cl_seg_nad_04-party_function_code_qualifier = 'VY' .

*   MP-ID must be no longer than 13 characters
      lv_sp_externalid = ls_eservprov-externalid.
      SHIFT lv_sp_externalid LEFT DELETING LEADING space.
      lv_mpid_13 = lv_sp_externalid.

      sis_cl_seg_nad_04-party_identifier = lv_mpid_13.
      append_idoc_seg( sis_cl_seg_nad_04 ).

    ENDIF.

  ENDMETHOD.


  method FILL_SG2_NAD.
  DATA: lv_sp_ext_id  TYPE dunsnr,
        lv_ext_idityp TYPE e_edmideextnumtyp,
        lv_mpid_13    TYPE char13.

  CLEAR sis_cl_seg_nad_01.

  CALL METHOD /idexge/isu_datex_idoc_build=>get_sprovider_adress_infos
    EXPORTING
      x_serviceid   = iv_provider
    IMPORTING
      y_partner     = lv_sp_ext_id
      y_ext_idtyp   = lv_ext_idityp    "ERP2007 Support of codelist ID
    EXCEPTIONS
      general_fault = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error_occurred.
  ELSE.
* Support of codelist of external Service Provider ID
    CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
      EXPORTING
        x_ext_idtyp     = lv_ext_idityp
        x_idoc_control  = sis_idoc_control
      IMPORTING
        y_extcodelistid = sis_cl_seg_nad_03-code_list_resp_agency_code_1
      EXCEPTIONS
        not_supported   = 1
        error_occured   = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
* error handling - copy error from previous module
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING error_occurred.
    ENDIF.
*    sis_cl_seg_nad_01-party_function_code_qualifier = iv_action.
** field length of transmitted MP-ID must not be longer than 13 char
*    SHIFT lv_sp_ext_id LEFT DELETING LEADING space.
*    lv_mpid_13 = lv_sp_ext_id.
*    sis_cl_seg_nad_01-party_identifier = lv_mpid_13.
*  ENDIF.
*  append_idoc_seg( sis_cl_seg_nad_01 ).

    sis_cl_seg_nad_03-party_function_code_qualifier = iv_action.
* field length of transmitted MP-ID must not be longer than 13 char
    SHIFT lv_sp_ext_id LEFT DELETING LEADING space.
    lv_mpid_13 = lv_sp_ext_id.
    sis_cl_seg_nad_03-party_identifier = lv_mpid_13.
  ENDIF.
  append_idoc_seg( sis_cl_seg_nad_03 ).


  endmethod.


  METHOD fill_sg4_agr.
    CLEAR sis_cl_seg_agr_01.

    IF x_swtmsgpod-msgdata-category = cl_isu_datex_co=>co_bgm_vdew_enroll
      AND ( ( x_swtmsgpod-msgdata-transreason <> co_transreason_bs_cust_in AND
            x_swtmsgpod-msgdata-transreason <> co_transreason_bs_new_inst AND
            x_swtmsgpod-msgdata-transreason <> co_transreason_bs_cs_fail AND
            x_swtmsgpod-msgdata-transreason <> co_transreason_bs_temp_conn AND
            x_swtmsgpod-msgdata-transreason <>
                    if_isu_ide_switch_constants=>co_transreason_backupspl ) OR
            ( NOT x_swtmsgpod-msgdata-msgstatus IS INITIAL ) ).

      IF ( gs_s_r_view-send_view     = '02' AND
       gs_s_r_view-reciever_view = '01' AND
     ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
       x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz


* contract
        sis_cl_seg_agr_01-agreement_type_code_qualifier = cl_isu_datex_co=>co_agr_vdew_gu_contr.
        sis_cl_seg_agr_01-agreement_type_descr_code =
                            cl_isu_datex_co=>co_agr_vdew_gu_contr_02.

        append_idoc_seg( sis_cl_seg_agr_01 ).

      ENDIF.

* payment
      sis_cl_seg_agr_01-agreement_type_code_qualifier = cl_isu_datex_co=>co_agr_vdew_gu_pay.
      sis_cl_seg_agr_01-agreement_type_descr_code =
                          cl_isu_datex_co=>co_agr_vdew_gu_pay_supp.

      append_idoc_seg( sis_cl_seg_agr_01 ).
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg4_agr_inv.

    DATA: ls_swtmsgpod TYPE eideswtmsgpod.
    CLEAR sis_cl_seg_agr_01.

    IF ( gs_s_r_view-send_view = '02' AND
         gs_s_r_view-reciever_view = '01' AND
         gs_s_r_view-msgstatus IS INITIAL ) OR                    "Anmeldung Lief/Neu -> Netz
       ( gs_s_r_view-send_view = '01' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL ).                  "Antwort auf Anmeldung Netz -> Lief/Neu

      ls_swtmsgpod =  x_swtmsgpod.

      IF ls_swtmsgpod-msgdata-/idexge/gucontst IS INITIAL.
        ls_swtmsgpod-msgdata-/idexge/gucontst = 'E02'.
      ENDIF.

      IF ls_swtmsgpod-msgdata-/idexge/gucontst IS NOT INITIAL.

        sis_cl_seg_agr_01-agreement_type_code_qualifier = cl_isu_datex_co=>co_agr_vdew_gu_contr.
        sis_cl_seg_agr_01-agreement_type_descr_code =
                            cl_isu_datex_co=>co_agr_vdew_gu_contr_02.

        append_idoc_seg( sis_cl_seg_agr_01 ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg4_dtm_cs.

    DATA: lt_installation TYPE STANDARD TABLE OF bapiisupodinstln,
          ls_installation TYPE bapiisupodinstln,
          ls_eanl         TYPE eanl,
          ls_ever         TYPE ever,
          ls_ecancon      TYPE /isidex/ecancon,
          lv_period_value TYPE char10.
    CLEAR sis_cl_seg_dtm_03.

    IF NOT x_swtmsgpod-msgdata-moveindate IS INITIAL.
*    sis_cl_seg_dtm_02-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_start.
**    CONCATENATE x_swtmsgpod-msgdata-moveindate lv_time INTO sis_cl_seg_dtm_02-DATE_TIME_PERIOD_VALUE.
*    sis_cl_seg_dtm_02-date_time_period_value  = x_swtmsgpod-msgdata-moveindate.
*    sis_cl_seg_dtm_02-date_time_period_format_code = co_dtm_format.
*
*    append_idoc_seg( sis_cl_seg_dtm_02 ).

*      if     not ( gs_s_r_view-send_view = '01' and
*                   gs_s_r_view-reciever_view = '03' and
*                   gs_s_r_view-msgstatus is initial )
*         and not ( gs_s_r_view-send_view = '01' and
*                    gs_s_r_view-reciever_view = '02' )   "E44/Z26 Informationsmeldung NB->LF neu
*         and not ( gs_s_r_view-send_view = '03' and
*                    gs_s_r_view-reciever_view = '01' ).  "Abmeldeanfrage NB->LF und Antwort LF->NB
      IF     ( gs_s_r_view-send_view     = '01' AND
               gs_s_r_view-reciever_view = '02' AND
               gs_s_r_view-category      = 'E01' AND
               gs_s_r_view-msgstatus     IS NOT INITIAL )  "Antwort auf Anmeldung NETZ -> Lief/Neu
         OR  ( gs_s_r_view-send_view     = '01' AND
               gs_s_r_view-reciever_view = '03' AND
               x_swtmsgpod-msgdata-transreason = 'ZC9' )   "Antwort auf Abmeldung bei ZC9 Aufhebung einer zukünftigen Zuordnung
         OR  ( gs_s_r_view-send_view     = '02' AND
               gs_s_r_view-reciever_view = '01' AND
               gs_s_r_view-category      = 'E01')          "Anmeldung Lief Neu -> Netz
         OR  ( gs_s_r_view-send_view     = '03' AND
               gs_s_r_view-reciever_view = '01' AND
               gs_s_r_view-category      = 'E02' AND
               x_swtmsgpod-msgdata-transreason = 'ZC9')
         OR  ( gs_s_r_view-send_view     = '01' AND
               gs_s_r_view-reciever_view = '02' AND
             ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
               x_swtmsgpod-msgdata-transreason = 'Z38' ) )  "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
         OR ( gs_s_r_view-send_view     = '02' AND
              gs_s_r_view-reciever_view = '01' AND
            ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
              x_swtmsgpod-msgdata-transreason = 'Z38' ) ).   "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

        sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_start.
        sis_cl_seg_dtm_03-date_time_period_value  = x_swtmsgpod-msgdata-moveindate.
        sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.

        append_idoc_seg( sis_cl_seg_dtm_03 ).

        IF NOT sis_cl_seg_bgm_01-document_name_code = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp.
*      sis_cl_seg_dtm_02-date_time_period_fc_qualifier = co_dtm_settl_begin.
**    CONCATENATE x_swtmsgpod-msgdata-moveindate lv_time INTO sis_cl_seg_dtm_02-DATE_TIME_PERIOD_VALUE.
*      sis_cl_seg_dtm_02-date_time_period_value = x_swtmsgpod-msgdata-moveindate.
*      sis_cl_seg_dtm_02-date_time_period_format_code = co_dtm_format.
*
*      append_idoc_seg( sis_cl_seg_dtm_02 ).

          IF NOT x_swtmsgpod-msgdata-startsettldate IS INITIAL.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_settl_begin.
            sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-startsettldate.
            sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.

            append_idoc_seg( sis_cl_seg_dtm_03 ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT x_swtmsgpod-msgdata-moveoutdate IS INITIAL.

*      sis_cl_seg_dtm_02-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_end.
**    CONCATENATE x_swtmsgpod-msgdata-moveoutdate lv_time INTO sis_cl_seg_dtm_02-DATE_TIME_PERIOD_VALUE.
*      sis_cl_seg_dtm_02-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
*      sis_cl_seg_dtm_02-date_time_period_format_code = co_dtm_format.
*      append_idoc_seg( sis_cl_seg_dtm_02 ).

      IF ( gs_s_r_view-send_view = '02' AND
           gs_s_r_view-reciever_view = '01' AND
           gs_s_r_view-msgstatus IS INITIAL ).                           "Anmeldung Lief/Neu -> Netz

*Nur senden wenn Auszugsdatum größer als Einzugsdatum (def Zeitraum)
        IF x_swtmsgpod-msgdata-moveindate < x_swtmsgpod-msgdata-moveoutdate.

          " - 93 - Versorgungsende
          sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_end.
          sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
          sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
          append_idoc_seg( sis_cl_seg_dtm_03 ).
        ENDIF.
      ELSE.

        IF ( gs_s_r_view-send_view = '01' AND
             gs_s_r_view-reciever_view = '02' AND
             gs_s_r_view-msgstatus IS NOT INITIAL ).                       "Antwort auf Anmeldung Netz -> Lief/Neu
        ELSE.

          IF NOT x_swtmsgpod-msgdata-moveoutdate IS INITIAL.

            IF     ( gs_s_r_view-send_view     = '02' AND
                       gs_s_r_view-reciever_view = '03' AND
                       gs_s_r_view-category      = 'E35' AND
                       gs_s_r_view-msgstatus IS INITIAL ) OR          "Kündigung E35 Lief/Neu -> Lief/Alt
                   ( gs_s_r_view-send_view     = '03' AND
                       gs_s_r_view-reciever_view = '02' AND
                       gs_s_r_view-category      = 'E35' AND
                       gs_s_r_view-msgstatus IS NOT INITIAL ).        "Antwort auf Kündigung E35 Lief/Alt -> Lief/Neu

              sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_next_pos_date.                        "471 nächstmöglichen Kündigungstermin Kündigungskondition
              sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
              sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
              append_idoc_seg( sis_cl_seg_dtm_03 ).

            ELSE.
              sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_end.
              sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
              sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
              append_idoc_seg( sis_cl_seg_dtm_03 ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF NOT x_swtmsgpod-msgdata-endsettldate IS INITIAL.
      sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_settl_end.
*    sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
      sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-endsettldate.
      sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
      append_idoc_seg( sis_cl_seg_dtm_03 ).
    ENDIF.                                             "+20130313 Bromisch

* Cacellation date of the contract
    DATA: lv_sender TYPE service_prov.

    IF  ( x_switch_msgcat = if_isu_ide_switch_constants=>co_swtmdcat_supl_drop )
    AND ( x_swtmsgpod-msgdata-msgstatus = co_sts_refuse_contract_exists ).

      lv_sender = sis_cl_seg_nad_01_sender-party_identifier.
      CALL METHOD /idexge/cl_workflow_task=>get_contract_data_for_pod
        EXPORTING
          iv_pod         = x_swtmsgpod-int_ui
          iv_serviceid   = lv_sender
          iv_moveoutdate = x_swtmsgpod-msgdata-moveoutdate
        IMPORTING
          es_ever        = ls_ever
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc = 0.

*Lieferbeginndatum in Bearbeitung
        IF x_swtmsgpod-msgdata-msgstatus = 'ZC5'.
          IF NOT x_swtmsgpod-msgdata-/idexge/sta_dat IS INITIAL.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z07'.
            sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-/idexge/sta_dat.
            sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
            append_idoc_seg( sis_cl_seg_dtm_03 ).
          ENDIF.

*Datum für nächste Bearbeitung
          IF NOT x_swtmsgpod-msgdata-/idexge/npro_dat IS INITIAL.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z08'.
            sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-/idexge/npro_dat.
            sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
            append_idoc_seg( sis_cl_seg_dtm_03 ).
          ENDIF.
        ENDIF.

*Kündigungsdatum der 1. Kündigung
        IF x_swtmsgpod-msgdata-msgstatus = 'Z34'.
          IF NOT x_swtmsgpod-msgdata-/idexge/kuenddat IS INITIAL.

            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z05'.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = x_swtmsgpod-msgdata-/idexge/kuenddat.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_format.
            append_idoc_seg( sis_cl_seg_dtm_03 ).
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.

*Lieferbeginndatum in Bearbeitung
    IF x_swtmsgpod-msgdata-msgstatus = 'ZC5'.
      IF NOT x_swtmsgpod-msgdata-/idexge/sta_dat IS INITIAL.
        sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z07'.
        sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-/idexge/sta_dat.
        sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
        append_idoc_seg( sis_cl_seg_dtm_03 ).
      ENDIF.

*Datum für nächste Bearbeitung
      IF NOT x_swtmsgpod-msgdata-/idexge/npro_dat IS INITIAL.
        sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z08'.
        sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-/idexge/npro_dat.
        sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
        append_idoc_seg( sis_cl_seg_dtm_03 ).
      ENDIF.
    ENDIF.

* New DTM rule for notice period
    IF  ( x_switch_msgcat = if_isu_ide_switch_constants=>co_swtmdcat_supl_drop )
    AND ( NOT x_swtmsgpod-msgdata-msgstatus  IS INITIAL )
    AND ( NOT x_swtmsgpod-msgdata-notic_perd IS INITIAL ).

*    sis_cl_seg_dtm_02-date_time_period_fc_qualifier = co_dtm_notice_period.
*    sis_cl_seg_dtm_02-date_time_period_value = x_swtmsgpod-msgdata-notic_perd.
*    sis_cl_seg_dtm_02-date_time_period_format_code = co_dtm_format_zzrb.
*    append_idoc_seg( sis_cl_seg_dtm_02 ).

      sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_notice_period.
      sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-notic_perd.
      sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format_zzrb.
      append_idoc_seg( sis_cl_seg_dtm_03 ).
    ENDIF.

    IF     ( gs_s_r_view-send_view     = '03' AND
             gs_s_r_view-reciever_view = '02' AND
             gs_s_r_view-category      = 'E35' AND
             NOT gs_s_r_view-msgstatus IS INITIAL ).          "Antwort auf Kündigung E35 Lief/Alt -> Lief/Neu

      IF  x_swtmsgpod-msgdata-msgstatus = 'Z12'.                                                     "Ablehnung wegen Kündigungskondition

*      sis_cl_seg_dtm_02-date_time_period_fc_qualifier = co_dtm_cancellation_date.
*      sis_cl_seg_dtm_02-date_time_period_value = ls_ever-kuenddat.
*      sis_cl_seg_dtm_02-date_time_period_format_code = co_dtm_format.
*      append_idoc_seg( sis_cl_seg_dtm_02 ).

        sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_cancellation_date.                   "157 nächstmöglichen Kündigungstermin Kündigungskondition
        sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-/idexge/nextcand.
        sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
        append_idoc_seg( sis_cl_seg_dtm_03 ).

* Anlagen zum Zählpunkt
        CALL FUNCTION 'BAPI_ISUPOD_GETINSTALLATION'
          EXPORTING
            pointofdelivery = x_swtmsgpod-ext_ui
            keydate         = sy-datum
          TABLES
            installation    = lt_installation
          EXCEPTIONS
            OTHERS          = 01.

        IF NOT lt_installation[] IS INITIAL.

          LOOP AT lt_installation INTO ls_installation.

*     Kündigungdkondition immmer im Liefervertrag gepflegt
            SELECT SINGLE * FROM eanl INTO ls_eanl WHERE anlage EQ ls_installation-installation
                                                     AND service = 'SLIF'.

            IF sy-subrc EQ 0.

              SELECT SINGLE * FROM ever INTO ls_ever WHERE anlage  EQ ls_installation-installation
                                                       AND auszdat EQ '99991231'.

              IF NOT ls_ever-canc_cond_id IS INITIAL.

                SELECT SINGLE * FROM /isidex/ecancon INTO ls_ecancon
                                                   WHERE canc_cond_id =  ls_ever-canc_cond_id.

                IF sy-subrc EQ 0.
                  CONCATENATE ls_ecancon-canc_period ls_ecancon-canc_period_unit ls_ecancon-con_min_dur_unit INTO lv_period_value.
                  TRANSLATE lv_period_value USING 'DT'.
                  TRANSLATE lv_period_value USING 'YJ'.


                  sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_notice_period.                     "Z01 - Kündigungsfrist des Liefervertrags
                  sis_cl_seg_dtm_03-date_time_period_value = lv_period_value+1(9).
                  sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format_zzrb.
                  append_idoc_seg( sis_cl_seg_dtm_03 ).
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD fill_sg4_dtm_cs_bils.
    DATA:
      lv_rlm_slp_flatrate TYPE char2,
      lv_check_keydate    TYPE d,     "Key Date = Move-In Date - 1 day
      lv_bill_start       TYPE d,     "Start of billing year
      ls_swtdoc           TYPE eideswtdoc,
      ls_erch             TYPE erch.

    DATA:
      lref_pod_scenario     TYPE REF TO cl_isu_ide_drgscen_ana_pod.

    DATA:
      ls_scenario      TYPE ederegscenario_ana,
      ls_scnr_contract TYPE ederegscenariocontr.


    CLEAR sis_cl_seg_dtm_02.


    lv_rlm_slp_flatrate = '02'.


* Only relevant to response to registration (betweeen DSO & SUPL)
* and request & response of basic & backup supply
    IF ( iv_switch_msgcat = if_isu_ide_switch_constants=>co_swtmdcat_enroll ) AND "E01
       ( ( NOT is_swtmsgpod-msgdata-msgstatus IS INITIAL ) OR
         ( is_swtmsgpod-msgdata-transreason = if_isu_ide_switch_constants=>co_transreason_backupspl OR "E04
           is_swtmsgpod-msgdata-transreason = co_sts_bs_cust_in  OR    "Z36
           is_swtmsgpod-msgdata-transreason = co_sts_bs_new_inst OR    "Z37
           is_swtmsgpod-msgdata-transreason = co_sts_bs_cs_fail  OR    "Z38
           is_swtmsgpod-msgdata-transreason = co_sts_bs_temp_conn ) ). "Z39

      CHECK lv_rlm_slp_flatrate EQ /idexge/cl_isu_idex_utility=>co_rlm_interval_read. "RLM

      "Create supply scenario analyzer for the PoD
      CALL METHOD cl_isu_ide_drgscen_ana_pod=>create
        EXPORTING
          im_int_ui     = is_swtmsgpod-int_ui
*         im_bypassing_buffer = SPACE
        IMPORTING
          ex_ref        = lref_pod_scenario
        EXCEPTIONS
          general_fault = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

      lv_check_keydate = is_swtmsgpod-msgdata-moveindate - 1.
      LOOP AT lref_pod_scenario->iscenario INTO ls_scenario
        WHERE datefrom <= lv_check_keydate
        AND   dateto   >= lv_check_keydate.
        EXIT.
      ENDLOOP.
      IF ls_scenario IS INITIAL.  "No (supply scenario) service found on key date
        lv_bill_start = is_swtmsgpod-msgdata-moveindate.
      ELSE. "Check if the end customer is going to be changed at the PoD

        "Identify the 'old' end customer (business partner) from billable contract of supply scenario
        READ TABLE ls_scenario-icontr INTO ls_scnr_contract
          WITH KEY own_service = co_flag_marked.

        "Identify the 'new' end customer (business partner) from switch doc
        CALL FUNCTION 'ISU_DB_EIDESWTDOC_SINGLE'
          EXPORTING
            x_switchnum  = is_swtmsgpod-msgdata-switchnum
          IMPORTING
            y_eideswtdoc = ls_swtdoc
          EXCEPTIONS
            not_found    = 1
            OTHERS       = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
        ENDIF.

        IF ls_scnr_contract-gpart <> ls_swtdoc-partner.
          lv_bill_start = is_swtmsgpod-msgdata-moveindate.
        ELSE.
          "Search the billing document for the latest billing period
          CALL FUNCTION 'ISU_DB_ERCH_SINGLE_PREVIOUS'
            EXPORTING
              x_vertrag    = ls_scnr_contract-vertrag
            IMPORTING
              y_erch       = ls_erch
            EXCEPTIONS
              not_found    = 1
              system_error = 2
              OTHERS       = 3.
          IF NOT ls_erch IS INITIAL.
            lv_bill_start = ls_erch-endabrpe.  "End of billing period
            lv_bill_start = lv_bill_start + 1.
          ELSE. "No billing doc was found
            lv_bill_start = is_swtmsgpod-msgdata-moveindate.
          ENDIF.
        ENDIF.
      ENDIF.

      sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_bill_begin.  " - 155 - Start Abrechnungsjahr
      sis_cl_seg_dtm_03-date_time_period_value          = lv_bill_start.      "start of billing year
      sis_cl_seg_dtm_03-date_time_period_format_code         = co_dtm_format.      "102 - CCYYMMDD
      append_idoc_seg( sis_cl_seg_dtm_03 ).

    ENDIF.
  ENDMETHOD.


  METHOD fill_sg4_dtm_cs_mrd.
    DATA:
      lv_lines            TYPE i,
      lv_mr_date          TYPE d,
      lv_rlm_slp_flatrate TYPE char2,
      lv_instln_service   TYPE sercode,
      ls_eservprov        TYPE eservprov,
      lt_instln_obj       TYPE isu_ref_installation_tab.

    DATA:
      lref_instln           TYPE REF TO cl_isu_installation.

    CLEAR sis_cl_seg_dtm_03.
* Installation (Return of BAPI Call)
    DATA:
      ls_installation TYPE bapiisupodinstln,
      lt_installation TYPE bapiisupodinstln_t.

* Messages (Return of BAPI Call)
    DATA:
      ls_bapi_return TYPE bapiret2,
      lt_bapi_return TYPE bapiret2tab.

    DATA: lv_process_date TYPE  eidemoveindate,
          ls_eanlh        TYPE eanlh,
          ls_te422        TYPE te422,
          ls_te420        TYPE te420,
          lv_periodew     TYPE  /idxgc/e1_dtm_03-date_time_period_value.

    lv_rlm_slp_flatrate = /idexge/cl_isu_idex_utility=>co_slp_stand_load_prof.

    IF iv_switch_msgcat = co_bgm_vdew_enroll. "E01

      IF lv_rlm_slp_flatrate = /idexge/cl_isu_idex_utility=>co_slp_stand_load_prof.  "SLP
        IF NOT is_swtmsgpod-int_ui IS INITIAL.
          "Get installation(s)
          CALL METHOD cl_isu_installation=>select_by_internal_pod
            EXPORTING
              x_int_ui         = is_swtmsgpod-int_ui
              x_keydate        = is_swtmsgpod-msgdata-moveindate
            RECEIVING
              installations    = lt_instln_obj
            EXCEPTIONS
              invalid_object   = 1
              object_not_found = 2
              OTHERS           = 3.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
          ENDIF.

          DESCRIBE TABLE lt_instln_obj LINES lv_lines.
          CASE lv_lines.
            WHEN 1.
              READ TABLE lt_instln_obj INTO lref_instln INDEX 1.

            WHEN OTHERS.
              CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
                EXPORTING
                  x_serviceid = iv_sender
                IMPORTING
                  y_eservprov = ls_eservprov
                EXCEPTIONS
                  not_found   = 1
                  OTHERS      = 2.
              IF sy-subrc <> 0.
                MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
              ENDIF.
              "Find the proper installation based on service type
              LOOP AT lt_instln_obj INTO lref_instln.
                CALL METHOD lref_instln->get_property
                  EXPORTING
                    x_property       = 'SERVICE'
                  IMPORTING
                    y_value          = lv_instln_service
                  EXCEPTIONS
                    invalid_object   = 1
                    invalid_property = 2
                    not_convertable  = 3
                    not_selected     = 4
                    OTHERS           = 5.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
                ENDIF.

                IF ls_eservprov-service EQ lv_instln_service.
                  EXIT.
                ENDIF.
              ENDLOOP.

          ENDCASE.

          "Get next meter reading date
          CALL METHOD lref_instln->get_next_meterread_date
            EXPORTING
              x_keydate       = is_swtmsgpod-msgdata-moveindate
            IMPORTING
              y_mr_date       = lv_mr_date
            EXCEPTIONS
              invalid_object  = 1
              keydate_invalid = 2
              not_found       = 3
              not_selected    = 4
              OTHERS          = 5.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
          ENDIF.

          sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_next_mr_date.  " - 752 - Geplante Turnusablesung
          sis_cl_seg_dtm_03-date_time_period_value          = lv_mr_date+4.
          sis_cl_seg_dtm_03-date_time_period_format_code       = co_dtm_exact_date.      "106 - MMDD
          append_idoc_seg( sis_cl_seg_dtm_03 ).
        ELSE.
          sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_next_mr_date.  " - 752 - Geplante Turnusablesung
          sis_cl_seg_dtm_03-date_time_period_value          = is_swtmsgpod-msgdata-pland_mr_date..
          sis_cl_seg_dtm_03-date_time_period_format_code       = co_dtm_exact_date.      "106 - MMDD
          append_idoc_seg( sis_cl_seg_dtm_03 ).
        ENDIF.
      ENDIF.  "SLP

      IF  ( gs_s_r_view-send_view = '02' AND
           gs_s_r_view-reciever_view = '01' AND
           gs_s_r_view-msgstatus IS INITIAL )                     "Anmeldung    Lief/Neu -> Netz
       OR ( gs_s_r_view-send_view = '01' AND
           gs_s_r_view-reciever_view = '02' AND
           gs_s_r_view-msgstatus IS NOT INITIAL )                 "Antwort auf Anmeldung Netz -> Lief/Neu
       OR ( gs_s_r_view-send_view     = '01' AND
            gs_s_r_view-reciever_view = '02' AND
          ( is_swtmsgpod-msgdata-transreason = 'Z37' OR
            is_swtmsgpod-msgdata-transreason = 'Z38' ) )           "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
       OR ( gs_s_r_view-send_view     = '02' AND
            gs_s_r_view-reciever_view = '01' AND
          ( is_swtmsgpod-msgdata-transreason = 'Z37' OR
            is_swtmsgpod-msgdata-transreason = 'Z38' ) ).          "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

        IF NOT is_swtmsgpod-msgdata-moveindate IS INITIAL.
          lv_process_date = is_swtmsgpod-msgdata-moveindate.
        ELSE.
          lv_process_date = is_swtmsgpod-msgdata-moveoutdate.
        ENDIF.


        IF is_swtmsgpod-int_ui IS INITIAL AND is_swtmsgpod-msgdata-msgstatus = 'E14'.

          sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_proc_period.  " - 672 - Turnusintervall
          sis_cl_seg_dtm_03-date_time_period_value          = is_swtmsgpod-msgdata-/idexge/mrperio.
          sis_cl_seg_dtm_03-date_time_period_format_code       = co_dtm_month.      "106 - MMDD
          append_idoc_seg( sis_cl_seg_dtm_03 ).

        ELSE.

          CALL FUNCTION 'BAPI_ISUPOD_GETINSTALLATION'
            EXPORTING
              pointofdelivery = is_swtmsgpod-ext_ui
              keydate         = lv_process_date
            TABLES
              installation    = lt_installation
              return          = lt_bapi_return.

          LOOP AT lt_installation INTO ls_installation.
            SELECT * FROM eanlh INTO ls_eanlh
                           WHERE anlage = ls_installation-installation
                             AND ab <= lv_process_date
                             AND bis >= lv_process_date.

              SELECT * FROM te422 INTO ls_te422
                                 WHERE termschl = ls_eanlh-ableinh.
                SELECT * FROM te420 INTO ls_te420
                                 WHERE termschl = ls_te422-portion.

                  CASE  ls_te420-periodew.
                    WHEN '1'.
                      lv_periodew = '1'.
                    WHEN '3'.
                      lv_periodew = '3'.
                    WHEN '6'.
                      lv_periodew = '6'.
                    WHEN '12'.
                      lv_periodew = '12'.
                  ENDCASE.

                  sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_proc_period.  " - 672 - Turnusintervall
                  sis_cl_seg_dtm_03-date_time_period_value          =  lv_periodew.
                  sis_cl_seg_dtm_03-date_time_period_format_code       = co_dtm_month.      "106 - MMDD
                  append_idoc_seg( sis_cl_seg_dtm_03 ).

                ENDSELECT.
              ENDSELECT.
            ENDSELECT.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.  "E01


  ENDMETHOD.


  METHOD fill_sg4_dtm_cs_save.
    CLEAR sis_cl_seg_dtm_03.

    IF ( gs_s_r_view-send_view = '01' AND
         gs_s_r_view-reciever_view = '03' AND
         gs_s_r_view-msgstatus IS NOT INITIAL ).  "Antwort auf Abmeldung Netz -> Lief/Alt

*darf nur 159 DTM kommen

    ELSE.
      IF NOT x_swtmsgpod-msgdata-moveindate IS INITIAL.
*    sis_cl_seg_dtm_02-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_start.
**    CONCATENATE x_swtmsgpod-msgdata-moveindate lv_time INTO sis_cl_seg_dtm_02-DATE_TIME_PERIOD_VALUE.
*    sis_cl_seg_dtm_02-date_time_period_value  = x_swtmsgpod-msgdata-moveindate.
*    sis_cl_seg_dtm_02-date_time_period_format_code = co_dtm_format.
*
*    append_idoc_seg( sis_cl_seg_dtm_02 ).


        IF     NOT ( gs_s_r_view-send_view = '01' AND
                     gs_s_r_view-reciever_view = '03' AND
                     gs_s_r_view-msgstatus IS INITIAL )
           AND NOT ( gs_s_r_view-send_view = '01' AND
                      gs_s_r_view-reciever_view = '02' )   "E44/Z26 Informationsmeldung NB->LF neu
           AND NOT ( gs_s_r_view-send_view = '03' AND
                      gs_s_r_view-reciever_view = '01' ).  "Abmeldeanfrage NB->LF und Antwort LF->NB

          " - 92 - Lieferbeginn
          sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_start.
          sis_cl_seg_dtm_03-date_time_period_value  = x_swtmsgpod-msgdata-moveindate.
          sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.

          append_idoc_seg( sis_cl_seg_dtm_03 ).

*<<< IDEX-GE: Suppliers Competition
          IF NOT sis_cl_seg_bgm_01-document_name_code = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp.
*>>> IDEX-GE: Suppliers Competition


            IF NOT x_swtmsgpod-msgdata-startsettldate IS INITIAL.
              " - 158 - Bilanzierungsbeginn
              sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_settl_begin.
              sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-startsettldate.
              sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.

              append_idoc_seg( sis_cl_seg_dtm_03 ).
            ENDIF.               "+20130313 Bromisch
          ENDIF.
        ENDIF.     "+20130320 Nagel-Daniel
      ENDIF.

      IF NOT x_swtmsgpod-msgdata-moveoutdate IS INITIAL.

**    CONCATENATE x_swtmsgpod-msgdata-moveoutdate lv_time INTO sis_cl_seg_dtm_02-DATE_TIME_PERIOD_VALUE.
*      sis_cl_seg_dtm_02-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
*      sis_cl_seg_dtm_02-date_time_period_format_code = co_dtm_format.
*      append_idoc_seg( sis_cl_seg_dtm_02 ).

        IF ( gs_s_r_view-send_view = '02' AND
             gs_s_r_view-reciever_view = '01' AND
             gs_s_r_view-msgstatus IS INITIAL ).                           "Anmeldung Lief/Neu -> Netz

*Nur senden wenn Auszugsdatum größer als Einzugsdatum (def Zeitraum)
          IF x_swtmsgpod-msgdata-moveindate < x_swtmsgpod-msgdata-moveoutdate.

            " - 93 - Versorgungsende
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_end.
            sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
            sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
            append_idoc_seg( sis_cl_seg_dtm_03 ).
          ENDIF.
        ELSE.
          IF ( gs_s_r_view-send_view = '01' AND
               gs_s_r_view-reciever_view = '02' AND
               gs_s_r_view-msgstatus IS NOT INITIAL ).                       "Antwort auf Anmeldung Netz -> Lief/Neu

*nicht senden

          ELSE.

            IF NOT x_swtmsgpod-msgdata-moveoutdate IS INITIAL.

              " - 93 - Versorgungsende
              sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_end.
              sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
              sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
              append_idoc_seg( sis_cl_seg_dtm_03 ).
            ENDIF.
          ENDIF.
*      if    ( gs_s_r_view-send_view = '01' and
*              gs_s_r_view-reciever_view = '03' and
*              gs_s_r_view-msgstatus is initial )
*         or ( gs_s_r_view-send_view = '03' and
*              gs_s_r_view-reciever_view = '01' ) .    "Abmeldeanfrage NB->LF und Antwort LF->NB
*        " - 93 - Versorgungsende
*        sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_end.
*        sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
*        sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
*        append_idoc_seg( sis_cl_seg_dtm_03 ).
*      endif.
        ENDIF.


*    sis_cl_seg_dtm_02-date_time_period_fc_qualifier = co_dtm_settl_end.
**    CONCATENATE x_swtmsgpod-msgdata-moveoutdate lv_time INTO sis_cl_seg_dtm_02-DATE_TIME_PERIOD_VALUE.
*    sis_cl_seg_dtm_02-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
*    sis_cl_seg_dtm_02-date_time_period_format_code = co_dtm_format.
*    append_idoc_seg( sis_cl_seg_dtm_02 ).
      ENDIF.
    ENDIF.

    IF NOT x_swtmsgpod-msgdata-endsettldate IS INITIAL.

      " - 159 - Bilanzierungsende
      sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_settl_end.
*    sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-moveoutdate.
      sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-endsettldate.
      sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
      append_idoc_seg( sis_cl_seg_dtm_03 ).
    ENDIF.                                             "+20130313 Bromisch

* Cacellation date of the contract
    DATA: lv_sender TYPE service_prov,
          ls_ever   TYPE ever.
    IF  ( x_switch_msgcat = if_isu_ide_switch_constants=>co_swtmdcat_supl_drop )
    AND ( x_swtmsgpod-msgdata-msgstatus = co_sts_refuse_contract_exists ).

      lv_sender = sis_cl_seg_nad_01_sender-party_identifier.
      CALL METHOD /idexge/cl_workflow_task=>get_contract_data_for_pod
        EXPORTING
          iv_pod         = x_swtmsgpod-int_ui
          iv_serviceid   = lv_sender
          iv_moveoutdate = x_swtmsgpod-msgdata-moveoutdate
        IMPORTING
          es_ever        = ls_ever
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc = 0.

*Lieferbeginndatum in Bearbeitung
        IF x_swtmsgpod-msgdata-msgstatus = 'ZC5'.
          IF NOT x_swtmsgpod-msgdata-/idexge/sta_dat IS INITIAL.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z07'.
            sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-/idexge/sta_dat.
            sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
            append_idoc_seg( sis_cl_seg_dtm_03 ).
          ENDIF.

*Datum für nächste Bearbeitung
          IF NOT x_swtmsgpod-msgdata-/idexge/npro_dat IS INITIAL.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z08'.
            sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-/idexge/npro_dat.
            sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
            append_idoc_seg( sis_cl_seg_dtm_03 ).
          ENDIF.
        ENDIF.

*Kündigungsdatum der 1. Kündigung
        IF x_swtmsgpod-msgdata-msgstatus = 'Z34'.
          IF NOT x_swtmsgpod-msgdata-/idexge/kuenddat IS INITIAL.

            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z05'.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = x_swtmsgpod-msgdata-/idexge/kuenddat.
            sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_format.
            append_idoc_seg( sis_cl_seg_dtm_03 ).
          ENDIF.
        ENDIF.

        " - 157 - Start der Änderung
        sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_cancellation_date.
        sis_cl_seg_dtm_03-date_time_period_value = ls_ever-kuenddat.
        sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format.
        append_idoc_seg( sis_cl_seg_dtm_03 ).

      ENDIF.
    ENDIF.

* New DTM rule for notice period
    IF  ( x_switch_msgcat = if_isu_ide_switch_constants=>co_swtmdcat_supl_drop )
    AND ( NOT x_swtmsgpod-msgdata-msgstatus  IS INITIAL )
    AND ( NOT x_swtmsgpod-msgdata-notic_perd IS INITIAL ).


      " - Z01 - Kündigungsfrist des Liefervertrags
      sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_notice_period.
      sis_cl_seg_dtm_03-date_time_period_value = x_swtmsgpod-msgdata-notic_perd.
      sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_format_zzrb.
      append_idoc_seg( sis_cl_seg_dtm_03 ).

    ENDIF.
  ENDMETHOD.


  METHOD fill_sg4_ftx_cs.
    DATA: wa_swtmsgdataco TYPE eideswtmsgdataco.

    CLEAR sis_cl_seg_ftx_02.

    LOOP AT x_swtmsgpod-msgdatacomment INTO wa_swtmsgdataco.
      sis_cl_seg_ftx_02-text_subject_code_qualifier = cl_isu_datex_co=>co_ftx_vdew_add_info.  "ACB

      CASE wa_swtmsgdataco-commentnum.
        WHEN cl_isu_datex_co=>co_ftx_num_1.
          sis_cl_seg_ftx_02-free_text_value_1 = wa_swtmsgdataco-commenttxt.
        WHEN cl_isu_datex_co=>co_ftx_num_2.
          sis_cl_seg_ftx_02-free_text_value_1 = wa_swtmsgdataco-commenttxt.
        WHEN cl_isu_datex_co=>co_ftx_num_3.
          sis_cl_seg_ftx_02-free_text_value_1 = wa_swtmsgdataco-commenttxt.
        WHEN cl_isu_datex_co=>co_ftx_num_4.
          sis_cl_seg_ftx_02-free_text_value_1 = wa_swtmsgdataco-commenttxt.
        WHEN cl_isu_datex_co=>co_ftx_num_5.
          sis_cl_seg_ftx_02-free_text_value_1 = wa_swtmsgdataco-commenttxt.
      ENDCASE.

      append_idoc_seg( sis_cl_seg_ftx_02 ).
    ENDLOOP.

  ENDMETHOD.


  METHOD fill_sg4_ide_cs.
    CLEAR sis_cl_seg_ide_02.

    sis_cl_seg_ide_02-object_type_code_qualifier = cl_isu_datex_co=>co_ide_vdew_qualifier_pod.
    sis_cl_seg_ide_02-object_identifier = x_swtmsgpod-msgdata-idrefnr.

    append_idoc_seg( sis_cl_seg_ide_02 ).
  ENDMETHOD.


  METHOD fill_sg4_tax.

    DATA:ls_frsgrp TYPE /idexge/t_frsgrp,
         lt_frsgrp TYPE /idexge/tt_frsgrp.

    CLEAR sis_cl_seg_tax_01.

    IF ( gs_s_r_view-send_view = '01' AND
         gs_s_r_view-reciever_view = '03' AND
         gs_s_r_view-msgstatus IS NOT INITIAL )                "Antwort auf Abmeldung Netz -> Lief/Alt
     OR ( gs_s_r_view-send_view = '03' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL ).               "Antwort auf Kündigung Lief/Alt -> Lief/Neu
*darf gar kein TAX kommen

    ELSE.

      sis_cl_seg_tax_01-duty_tax_fee_category_code = 'TA'.

      sis_cl_seg_tax_01-duty_tax_fee_funct_code_quali = co_tax_dtf_function_charge.
      sis_cl_seg_tax_01-duty_tax_fee_type_name_code   = co_tax_concession_fee.

      IF    ( gs_s_r_view-send_view = '01' AND
              gs_s_r_view-reciever_view = '02' AND
              gs_s_r_view-msgstatus IS INITIAL AND
            ( gs_swtmsgpod-msgdata-transreason = 'Z26' OR
              gs_swtmsgpod-msgdata-transreason = 'ZC8' OR
              gs_swtmsgpod-msgdata-transreason = 'ZC9' ) )     "E44/Z26 Informationsmeldung NB->LF neu
         OR ( gs_s_r_view-send_view = '01' AND
              gs_s_r_view-reciever_view = '03' AND
              gs_s_r_view-msgstatus IS INITIAL )
         OR ( gs_s_r_view-send_view = '02' AND
              gs_s_r_view-reciever_view = '03' AND
              gs_s_r_view-msgstatus IS  INITIAL )    "Kündigung Lief/Neu -> Lief/Alt
         OR ( gs_s_r_view-send_view = '03' AND
              gs_s_r_view-reciever_view = '01' ) .   "E02 Abmeldeanfrage NB->LF und Antwort LF->NB
      ELSE.

        append_idoc_seg( sis_cl_seg_tax_01 ).

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD fill_sg5_loc_cs_a.
    CLEAR sis_cl_seg_loc_02.

    sis_cl_seg_loc_02-location_func_code_quali = cl_isu_datex_co=>co_loc_vdew_pod.

    IF NOT x_swtmsgpod-ext_ui IS INITIAL.
      sis_cl_seg_loc_02-location_identifier = x_swtmsgpod-ext_ui.
    ELSE.
      sis_cl_seg_loc_02-location_identifier = x_swtmsgpod-msgdata-ext_ui.
    ENDIF.

    IF NOT sis_cl_seg_loc_02-location_identifier IS INITIAL.
      append_idoc_seg( sis_cl_seg_loc_02 ).
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg5_loc_cs_b.
    DATA:
      lf_settlunit_data   TYPE eedmsettlunit_db_data,
      l_dunsnr            TYPE dunsnr,
      l_edmsettlunit      TYPE e_edmsettlunit,
      lv_not_process      TYPE flag,
      lv_settlcoord       TYPE e_edmsettlcoord,
      lv_targ_market_area TYPE /idexgg/t_market_area,
      lv_key              TYPE char100,
      lv_result           TYPE char100.

    CLEAR sis_cl_seg_loc_02.

    IF ( p_swtmsgpod-int_ui IS INITIAL AND
*<<< IDEX-GE: Forced Deregistration
         p_swtmsgpod-msgdata-transreason EQ if_isu_ide_switch_constants=>co_transreason_force_moveout )
*<<< IDEX-GE SP05: Basic & Backup Supply
        OR ( ( p_swtmsgpod-msgdata-transreason EQ if_isu_ide_switch_constants=>co_transreason_backupspl
        OR p_swtmsgpod-msgdata-transreason EQ co_transreason_bs_cs_fail
        OR p_swtmsgpod-msgdata-transreason EQ co_transreason_bs_temp_conn ) AND
        ( p_swtmsgpod-msgdata-msgstatus IS INITIAL OR
          p_swtmsgpod-int_ui IS INITIAL ) ) .
*   Do not process following code if PoD is initial in case of backup supply
      lv_not_process = co_true.
    ENDIF.

    IF p_swtmsgpod-msgdata-category = 'E35'.
      lv_not_process = co_true.
    ENDIF.

    CHECK lv_not_process IS INITIAL.

    IF ( gs_s_r_view-send_view     = '02' AND
         gs_s_r_view-reciever_view = '01' AND
       ( gs_swtmsgpod-msgdata-transreason = 'Z37' OR
         gs_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

      IF NOT p_swtmsgpod-msgdata-targ_market_area IS INITIAL.
        lv_targ_market_area = p_swtmsgpod-msgdata-targ_market_area.
      ELSE.
        lv_targ_market_area = p_swtmsgpod-msgdata-settlresp.
      ENDIF.
    ENDIF.

*  if not p_swtmsgpod-msgdata-targ_market_area is initial.
    IF NOT lv_targ_market_area IS INITIAL.

      DATA:
        wa_servprov   TYPE eservprov.

*   Read the service type of the sender service provider
      CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
        EXPORTING
          x_serviceid = p_sender
        IMPORTING
          y_eservprov = wa_servprov
        EXCEPTIONS
          OTHERS      = 0.
*   No error handling, as error will be produced from call of
*   cl_isu_edm_ui_settlunit=>find_settlunit_extid if no settlement unit found

      CALL METHOD /idexgg/cl_isu_wf_methods=>get_settlcoord_tma_date
        EXPORTING
          x_market_area = p_swtmsgpod-msgdata-targ_market_area
          x_swtview     = p_swtview
          x_service     = wa_servprov-service
          x_date        = p_swtmsgpod-msgdata-moveindate
        IMPORTING
          y_settlcoord  = lv_settlcoord
        EXCEPTIONS
          OTHERS        = 0.

*   No error handling, as error will be produced from call of
*   cl_isu_edm_ui_settlunit=>find_settlunit_extid if no settlement unit found

    ENDIF.

    l_edmsettlunit = p_settlunit-settlunit.
    IF l_edmsettlunit IS INITIAL.
      l_dunsnr = p_swtmsgpod-msgdata-settlresp.
      CALL METHOD cl_isu_edm_ui_settlunit=>find_settlunit_extid
        EXPORTING
          im_settlview         = p_edmsettlview_out
          im_int_ui            = p_swtmsgpod-int_ui
          im_extid_supply      = l_dunsnr
*         im_service_supply    =
*         im_extid_responsible =
*         im_service_responsible =
*         im_settlunitext      =
          im_datefrom          = p_swtmsgpod-msgdata-moveindate
          im_no_dialog         = co_flag_marked
* Valid settlement unit should be found using the settlement co-ordinator
* of target market area (and not as in standard Settlement coordinator of
* Grid
          im_settlcoord        = lv_settlcoord
        IMPORTING
          ex_settlunit         = l_edmsettlunit
        EXCEPTIONS
          general_fault        = 1
          no_settlunit_found   = 2
          settlunit_not_unique = 3
          canceled             = 4
          OTHERS               = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING error_occurred.
      ENDIF.
    ENDIF.

* The external ID of settlement unit can be determined via CL_ISU_EDM_SETTLUNIT =>DB_SINGLE.
    CALL METHOD cl_isu_edm_settlunit=>db_single
      EXPORTING
        im_settlunit = l_edmsettlunit
      IMPORTING
        ex_db_data   = lf_settlunit_data
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
    ELSEIF lf_settlunit_data-head-settlunitext IS INITIAL.
      MESSAGE e000(eedmset) WITH lf_settlunit_data-head-settlunitext RAISING error_occurred.
    ENDIF.

    sis_cl_seg_loc_02-location_func_code_quali = co_loc_settl_unit.              " - 237 - Bilanzkreisbezeichnung
    sis_cl_seg_loc_02-location_identifier        = lf_settlunit_data-head-settlunitext.
    sis_cl_seg_loc_02-code_list_resp_agency_code_1 = co_loc_etso.
    " Start of Legal change 24th Nov 2009
    IF gv_divcat EQ /idexgg/cl_isu_co=>co_spartyp_gas
          AND /idexgg/cl_isu_cust_select=>select_db_settings_active( )
      = /idexgg/cl_isu_co=>co_idexgg_active.
      sis_cl_seg_loc_02-code_list_resp_agency_code_1 = gc_loc_tso. "#Z01#
    ENDIF.
    " End of Legal change 24th Nov 2009

    append_idoc_seg( sis_cl_seg_loc_02 ).

* data of settlement unit assigned to the PoD will be used later on.
    es_settlunit_data = lf_settlunit_data.

    sis_cl_seg_loc_02-location_func_code_quali = co_loc_contrl_area.              " - 231 - Regelzone

    CONCATENATE 'REGELZONE_STROM' '_' gv_reciever INTO lv_key.
    SELECT SINGLE value FROM zidex_param INTO lv_result WHERE param EQ lv_key.

    IF sy-subrc <> 0.
      RAISE error_occurred.
    ENDIF.

*  sis_cl_seg_loc_02-location_identifier        = gr_utility->gc_regelzone_strom.
    sis_cl_seg_loc_02-location_identifier        = lv_result.
    sis_cl_seg_loc_02-code_list_resp_agency_code_1 = co_loc_etso.
    IF NOT lv_result IS INITIAL.
      append_idoc_seg( sis_cl_seg_loc_02 ).
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg5_loc_cs_c.
    DATA:lv_key    TYPE char100,
         lv_result TYPE char100.

    CLEAR sis_cl_seg_loc_02.

    DATA: lv_div_category TYPE spartyp.
* Added in IDEX-GE SP05 - Grid External ID
* Grid Data
    DATA: lt_euigrid  TYPE ieuigrid,
          ls_euigrid  TYPE euigrid,
          ls_egrid    TYPE egrid,
          ls_euitrans TYPE euitrans.

    lv_div_category = iv_division_category.

* Determine the relevant division category
    IF lv_div_category IS INITIAL.
      CALL METHOD me->get_division_category_2
        EXPORTING
          x_switchdoc = is_swtmsgpod-msgdata-switchnum
        CHANGING
          y_divcat    = lv_div_category.
    ENDIF.

    CHECK lv_div_category = gc_divcat_electricity.

* Read data for PoD.
    IF NOT is_swtmsgpod-ext_ui IS INITIAL.
      CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
        EXPORTING
          x_ext_ui     = is_swtmsgpod-ext_ui
        IMPORTING
          y_euitrans   = ls_euitrans
        EXCEPTIONS
          not_found    = 1
          system_error = 2
          OTHERS       = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.
    ENDIF.

* Read Grid where PoD is allocated.
    IF NOT ls_euitrans-int_ui IS INITIAL.
      IF NOT is_swtmsgpod-msgdata-moveoutdate IS INITIAL.
        CALL FUNCTION 'ISU_DB_EUIGRID_SELECT'
          EXPORTING
            x_int_ui      = ls_euitrans-int_ui
            x_datefrom    = is_swtmsgpod-msgdata-moveoutdate
          IMPORTING
            y_euigrid     = lt_euigrid
          EXCEPTIONS
            not_found     = 1
            not_qualified = 2
            system_error  = 3
            OTHERS        = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
        ENDIF.
      ELSEIF NOT is_swtmsgpod-msgdata-moveindate IS INITIAL.
        CALL FUNCTION 'ISU_DB_EUIGRID_SELECT'
          EXPORTING
            x_int_ui      = ls_euitrans-int_ui
            x_datefrom    = is_swtmsgpod-msgdata-moveindate
          IMPORTING
            y_euigrid     = lt_euigrid
          EXCEPTIONS
            not_found     = 1
            not_qualified = 2
            system_error  = 3
            OTHERS        = 4.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
        ENDIF.
      ENDIF.
      READ TABLE lt_euigrid INTO ls_euigrid INDEX 1.

*   Get Grid External ID via Grid ID.
      CALL FUNCTION 'ISU_DB_EGRID_SINGLE'
        EXPORTING
          x_grid_id = ls_euigrid-grid_id
          x_langu   = sy-langu
        IMPORTING
          y_egrid   = ls_egrid
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

      IF ls_egrid-externalid IS INITIAL.
*      ls_egrid-externalid = gr_utility->gc_bilanzkreis_strom.

        CONCATENATE 'BILANZKREIS_STROM' '_' gv_reciever INTO lv_key.
        SELECT SINGLE value FROM zidex_param INTO lv_result WHERE param EQ lv_key.

        IF sy-subrc <> 0.
          RAISE error_occurred.
        ELSE.
          ls_egrid-externalid = lv_result.
        ENDIF.
        IF NOT ls_egrid-externalid IS INITIAL.
*   To be filled for electricity only
*      sis_cl_seg_loc_01-location_func_code_quali = co_loc_settl_area.   "107
*      sis_cl_seg_loc_01-location_identifier        = ls_egrid-externalid.
*      sis_cl_seg_loc_01-code_list_resp_agency_code_1 = gc_loc_tso.
*      append_idoc_seg( sis_cl_seg_loc_01 ).

          sis_cl_seg_loc_02-location_func_code_quali = co_loc_settl_area.   " - 107 - Bilanzierungsgebiet
          sis_cl_seg_loc_02-location_identifier        = ls_egrid-externalid.
          sis_cl_seg_loc_02-code_list_resp_agency_code_1 = gc_loc_tso.
          append_idoc_seg( sis_cl_seg_loc_02 ).
        ENDIF.
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD fill_sg5_loc_cs_d_new.
    DATA: wa_eextsynprof TYPE eextsynprof.

    CLEAR sis_cl_seg_loc_01.

* Begin of Legal change, UTILMD 4.2A
* Gas, only for SLP

    DATA:   lv_ext_ui           TYPE ext_ui,
            lv_instln_id        TYPE int_ui,
            lv_movein           TYPE eidemoveindate,
            lv_temp_mp_code     TYPE /idexgg/temp_mp_code,
            lv_rlm_slp_flatrate TYPE char2,
            lv_lines            TYPE i,
            lv_found            TYPE char01,
            lv_profile          TYPE char01,
            lv_instln_service   TYPE sercode,
            ls_eservprov        TYPE eservprov,
            lv_servtyp_sender   TYPE intcode,
            lv_servtyp_receiver TYPE intcode.

    DATA:
      lt_eanlh      TYPE TABLE OF eanlh,
      ls_eanlh      TYPE eanlh,
      ls_temp_area  TYPE /idexgg/tmp_area,
      ls_temp_def   TYPE /idexgg/tmp_def,
      lt_instln_obj TYPE isu_ref_installation_tab,
      ls_instln_obj TYPE REF TO cl_isu_installation.

    DATA: lv_key    TYPE char100,
          lv_result TYPE char100.

    IF ( gs_s_r_view-send_view = '01' AND
         gs_s_r_view-reciever_view = '03' AND
         gs_s_r_view-msgstatus IS NOT INITIAL ).  "Antwort auf Abmeldung Netz -> Lief/Alt

*darf gar kein DTM kommen
    ELSE.

      IF     ( gs_s_r_view-send_view     = '01' AND
               gs_s_r_view-reciever_view = '02' AND
               gs_s_r_view-category      = 'E01' AND
               gs_s_r_view-msgstatus     IS NOT INITIAL )  "Antwort auf Anmeldung NETZ -> Lief/Neu
         OR  ( gs_s_r_view-send_view     = '01' AND
               gs_s_r_view-reciever_view = '02' AND
             ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
               x_swtmsgpod-msgdata-transreason = 'Z38' ) )  "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
         OR ( gs_s_r_view-send_view     = '02' AND
              gs_s_r_view-reciever_view = '01' AND
            ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
              x_swtmsgpod-msgdata-transreason = 'Z38' ) ).   "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

        IF gv_divcat EQ /idexgg/cl_isu_co=>co_spartyp_gas
        AND /idexgg/cl_isu_cust_select=>select_db_settings_active( ) = /idexgg/cl_isu_co=>co_idexgg_active.

*   Determine service category for receiver of the message
          CALL FUNCTION 'ISU_GET_SERVICETYPE_PROVIDER'
            EXPORTING
              x_service_prov = iv_receiver
            IMPORTING
              y_service_type = lv_servtyp_receiver
            EXCEPTIONS
              general_fault  = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    RAISING error_occurred.
          ENDIF.

*   Determine service category for SENDER of the message
          CALL FUNCTION 'ISU_GET_SERVICETYPE_PROVIDER'
            EXPORTING
              x_service_prov = iv_sender
            IMPORTING
              y_service_type = lv_servtyp_sender
            EXCEPTIONS
              general_fault  = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    RAISING error_occurred.
          ENDIF.

* E01 Response from DSO to new supplier
          IF ( x_swtmsgpod-msgdata-category <> co_bgm_vdew_enroll ) OR
             ( lv_servtyp_receiver   <> co_servrole_supplier ) OR
             ( lv_servtyp_sender <> co_servrole_distrib ) OR
             ( lv_servtyp_receiver = x_swtmsgpod-msgdata-service_prov_old ) OR
             ( x_swtmsgpod-msgdata-msgstatus IS INITIAL ).
            RETURN.
          ENDIF.


* no temperature area found, skip the check
* Determine Measuring point based on temp. area;
* if nothing found, determine from EEXTSYNPROF.
          lv_movein =  x_swtmsgpod-msgdata-moveindate.
          IF NOT x_swtmsgpod-int_ui IS INITIAL.
            CALL METHOD /idexge/cl_isu_idex_utility=>check_rlm_slp_flatrate
              EXPORTING
                iv_pod_int_ui        = x_swtmsgpod-int_ui
                iv_keydate           = x_swtmsgpod-msgdata-moveindate
                iv_own_servprov      = iv_sender
                iv_check_flatrate    = co_flag_marked
              IMPORTING
                ev_rlm_slp_flatrate  = lv_rlm_slp_flatrate
              EXCEPTIONS
                intmeter_no_profile  = 1
                rlm_slp_not_relevant = 2
                error_occurred       = 3
                OTHERS               = 4.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error_occurred.
            ENDIF.
          ENDIF.

          IF lv_rlm_slp_flatrate = /idexge/cl_isu_idex_utility=>co_slp_stand_load_prof.  "SLP
            "Get installation(s)
            CALL METHOD cl_isu_installation=>select_by_internal_pod
              EXPORTING
                x_int_ui         = x_swtmsgpod-int_ui
                x_keydate        = x_swtmsgpod-msgdata-moveindate
              RECEIVING
                installations    = lt_instln_obj
              EXCEPTIONS
                invalid_object   = 1
                object_not_found = 2
                OTHERS           = 3.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error_occurred.
            ENDIF.

            DESCRIBE TABLE lt_instln_obj LINES lv_lines.
            CASE lv_lines.
              WHEN 1.
                READ TABLE lt_instln_obj INTO ls_instln_obj INDEX 1.

              WHEN OTHERS.
                CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
                  EXPORTING
                    x_serviceid = iv_sender
                  IMPORTING
                    y_eservprov = ls_eservprov
                  EXCEPTIONS
                    not_found   = 1
                    OTHERS      = 2.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    RAISING error_occurred.
                ENDIF.
                "Find the proper installation based on service type
                LOOP AT lt_instln_obj INTO ls_instln_obj.
                  CALL METHOD ls_instln_obj->get_property
                    EXPORTING
                      x_property       = 'SERVICE'
                    IMPORTING
                      y_value          = lv_instln_service
                    EXCEPTIONS
                      invalid_object   = 1
                      invalid_property = 2
                      not_convertable  = 3
                      not_selected     = 4
                      OTHERS           = 5.
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                      RAISING error_occurred.
                  ENDIF.

                  IF ls_eservprov-service EQ lv_instln_service.
                    lv_found = co_flag_marked.
                    EXIT.
                  ENDIF.
                ENDLOOP.
            ENDCASE.

            CALL METHOD ls_instln_obj->get_property
              EXPORTING
                x_property       = 'ANLAGE'
              IMPORTING
                y_value          = lv_instln_id
              EXCEPTIONS
                invalid_object   = 1
                invalid_property = 2
                not_convertable  = 3
                not_selected     = 4
                OTHERS           = 5.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error_occurred.
            ENDIF.

            SELECT * FROM eanlh
              INTO TABLE lt_eanlh
              WHERE anlage = lv_instln_id
              AND ab <= lv_movein
              AND bis >= lv_movein.
            IF sy-subrc = 0.
              READ TABLE lt_eanlh INTO ls_eanlh INDEX 1.
            ENDIF.

            IF NOT ls_eanlh-temp_area IS INITIAL.
              SELECT SINGLE * FROM /idexgg/tmp_area
                INTO ls_temp_area
                WHERE temp_area = ls_eanlh-temp_area.
              IF sy-subrc = 0.
                lv_temp_mp_code = ls_temp_area-temp_mp_code.
              ENDIF.
            ELSE.
              SELECT * FROM eextsynprof INTO wa_eextsynprof
              WHERE extsynprofid EQ x_swtmsgpod-msgdata-profile
              AND grid_id EQ x_swtmsgpod-msgdata-nwp_target
                AND dateto GE x_swtmsgpod-msgdata-moveindate.

                lv_temp_mp_code = wa_eextsynprof-temp_mp_code.
                lv_profile = co_flag_marked.
                EXIT.
              ENDSELECT.
            ENDIF.

            IF NOT lv_temp_mp_code IS INITIAL.
              SELECT SINGLE * FROM /idexgg/tmp_def
                INTO ls_temp_def
                WHERE temp_mp_code = lv_temp_mp_code.
            ENDIF.
            IF ls_temp_def IS INITIAL.
              MESSAGE e093(/idexgg/messages)
                WITH ls_eanlh-temp_area lv_temp_mp_code lv_movein
              RAISING error_occurred.
            ENDIF.

*
*      append_idoc_seg( sis_cl_seg_loc_01 ).

*   Now fill IDoc structure
            sis_cl_seg_loc_02-location_func_code_quali = co_loc_temp_mess_point.
            sis_cl_seg_loc_02-location_identifier        = ls_temp_def-temp_mp.
*  sis_cl_seg_loc_01-CODE_LIST_RESP_AGENCY_CODE_1 = co_loc_etso.
            sis_cl_seg_loc_02-code_list_ident_code_1 = ls_temp_def-code_list.
            sis_cl_seg_loc_02-code_list_resp_agency_code_1 = ls_temp_def-code_list_agency.
            IF lv_profile = co_flag_marked.
              sis_cl_seg_loc_02-code_list_ident_code_1 = wa_eextsynprof-code_list.
              sis_cl_seg_loc_02-code_list_resp_agency_code_1 = wa_eextsynprof-code_list_agency.
            ENDIF.
* no code list agency => allocate by supplier
            IF sis_cl_seg_loc_02-code_list_resp_agency_code_1 IS INITIAL.
              sis_cl_seg_loc_02-code_list_resp_agency_code_1 = /idexge/cl_utilmd_v42a=>co_cav_alloc_sup.
            ENDIF.

            append_idoc_seg( sis_cl_seg_loc_02 ).

* End of Legal change, UTILMD 4.2A
          ENDIF.

        ELSE.
* the temperature measurement point is currently stored in the table
* EEXTSYNPROF i.e. is only available for SLP customers...

          CONCATENATE 'KLIMAZONE' '_' gv_reciever INTO lv_key.
          SELECT SINGLE value FROM zidex_param INTO lv_result WHERE param EQ lv_key.

          IF sy-subrc <> 0.
            RAISE error_occurred.
          ENDIF.

          x_swtmsgpod-msgdata-temp_mp = lv_result.

          IF NOT lv_result IS INITIAL.
*   Now fill IDoc structure
            sis_cl_seg_loc_02-location_func_code_quali = co_loc_temp_mess_point.
            sis_cl_seg_loc_02-location_identifier        = x_swtmsgpod-msgdata-temp_mp.
*  sis_cl_seg_loc_01-CODE_LIST_RESP_AGENCY_CODE_1 = co_loc_etso.
            sis_cl_seg_loc_02-code_list_ident_code_1 = wa_eextsynprof-code_list.
            sis_cl_seg_loc_02-code_list_resp_agency_code_1 = wa_eextsynprof-code_list_agency.
* no code list agency => allocate by supplier
            IF sis_cl_seg_loc_02-code_list_resp_agency_code_1 IS INITIAL.
              sis_cl_seg_loc_02-code_list_resp_agency_code_1 = /idexge/cl_utilmd_v42a=>co_cav_alloc_sup.
            ENDIF.

            append_idoc_seg( sis_cl_seg_loc_02 ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD fill_sg6_rff_cs_b.
    DATA: it_swtmsgdata TYPE teideswtmsgdata,
          wa_swtmsgdata TYPE eideswtmsgdata,
          lv_ref_num    TYPE eideswtmdidrefnr.

*<Legal Change for V42a>
    DATA:lv_rlm_slp_flatrate TYPE char2,
         lv_key_date         TYPE eideswtdate.
*<Legal Change for V42a>

    CLEAR sis_cl_seg_rff_09.

* take over the reference only if it is a answer
    IF NOT x_swtmsgpod-msgdata-msgstatus IS INITIAL.
      IF x_swtmsgpod-msgdata-transreason = cl_isu_datex_co=>co_agr_vdew_full_supp.
        CALL FUNCTION 'ISU_DB_EIDESWTMSGDATA_SWTNUM'
          EXPORTING
            x_switchnum       = x_switchnum
          IMPORTING
            y_teideswtmsgdata = it_swtmsgdata
          EXCEPTIONS
            not_found         = 1
            OTHERS            = 2.

        IF sy-subrc <> 0.
          CLEAR: lv_ref_num.
        ENDIF.

        READ TABLE it_swtmsgdata
                       WITH KEY category = x_swtmsgpod-msgdata-category
                             transreason = x_swtmsgpod-msgdata-transreason
                       INTO wa_swtmsgdata.
        IF sy-subrc = 0.
          lv_ref_num = wa_swtmsgdata-idrefnr.
        ELSE.
          CLEAR: lv_ref_num.
        ENDIF.
      ELSE.
* get process related reference
        IF NOT x_msgdatanum_res IS INITIAL.

          CALL FUNCTION 'ISU_DB_EIDESWTMSGDATA_SWTNUM'
            EXPORTING
              x_switchnum       = x_switchnum
              x_msgdatanum      = x_msgdatanum_req
            IMPORTING
              y_teideswtmsgdata = it_swtmsgdata
            EXCEPTIONS
              not_found         = 1
              OTHERS            = 2.

          IF sy-subrc <> 0.
            CLEAR: lv_ref_num.
          ENDIF.

          READ TABLE it_swtmsgdata INTO wa_swtmsgdata INDEX 1.

          IF sy-subrc = 0.
            lv_ref_num = wa_swtmsgdata-idrefnr.
          ELSE.
            CLEAR: lv_ref_num.
          ENDIF.
        ENDIF.
      ENDIF.

      sis_cl_seg_rff_09-reference_code_qualifier = cl_isu_datex_co=>co_rff_vdew_reference.
      sis_cl_seg_rff_09-reference_identifier = lv_ref_num.
      append_idoc_seg( sis_cl_seg_rff_09 ).

    ELSEIF x_swtmsgpod-msgdata-transreason = cl_isu_datex_co=>co_agr_vdew_full_supp.
      CALL FUNCTION 'ISU_DB_EIDESWTMSGDATA_SWTNUM'
        EXPORTING
          x_switchnum       = x_switchnum
        IMPORTING
          y_teideswtmsgdata = it_swtmsgdata
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2.

      IF sy-subrc <> 0.
        CLEAR: lv_ref_num.
      ENDIF.
      LOOP AT it_swtmsgdata INTO wa_swtmsgdata
                           WHERE category = x_swtmsgpod-msgdata-category
                             AND transreason <> x_swtmsgpod-msgdata-transreason
                             AND direction = x_swtmsgpod-msgdata-direction
                             AND compartner = x_swtmsgpod-msgdata-compartner.


        sis_cl_seg_rff_09-reference_code_qualifier = gc_rff_ref_preceding_msg. "Reference number of a preceding message
        sis_cl_seg_rff_09-reference_identifier = wa_swtmsgdata-idrefnr.

        append_idoc_seg( sis_cl_seg_rff_09 ).

        EXIT.
      ENDLOOP.
*<Legal Change for V42a>
    ELSEIF x_swtmsgpod-msgdata-transreason = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp
       OR x_swtmsgpod-msgdata-transreason = if_isu_ide_switch_constants=>co_transreason_supplier_comp.
      CALL FUNCTION 'ISU_DB_EIDESWTMSGDATA_SWTNUM'
        EXPORTING
          x_switchnum       = x_switchnum
        IMPORTING
          y_teideswtmsgdata = it_swtmsgdata
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2.

      IF sy-subrc <> 0.
        CLEAR: lv_ref_num.
      ENDIF.
      LOOP AT it_swtmsgdata INTO wa_swtmsgdata
                           WHERE category = me->co_bgm_vdew_enroll.


        sis_cl_seg_rff_09-reference_code_qualifier = cl_isu_datex_co=>co_rff_vdew_reference. "Reference number of a preceding message
        sis_cl_seg_rff_09-reference_identifier = wa_swtmsgdata-idrefnr.
        append_idoc_seg( sis_cl_seg_rff_09 ).
        EXIT.
      ENDLOOP.
*<Legal Change for V42a>
    ENDIF.
  ENDMETHOD.


  METHOD fill_sg6_rff_cs_cust.
*RFF Segment Antwortstatus bei abgelehnter Abmeldeanfrage senden
    IF x_swtmsgpod-msgdata-/idexge/rej_res = 'Z12' AND
      ( gs_s_r_view-send_view     = '01' AND
        gs_s_r_view-reciever_view = '02' AND
        gs_s_r_view-category      = 'E01' AND
        gs_s_r_view-msgstatus     IS NOT INITIAL ).  "Antwort auf Anmeldung NETZ -> Lief/Neu.

      sis_cl_seg_rff_09-reference_code_qualifier = 'Z07'.
      sis_cl_seg_rff_09-reference_identifier = x_swtmsgpod-msgdata-/idexge/rej_res..

      append_idoc_seg( sis_cl_seg_rff_09 ).

    ENDIF.
  ENDMETHOD.


  METHOD fill_sg6_rff_cs_idexgg.
    CLEAR sis_cl_seg_rff_09.
    IF NOT x_swtmsgpod-msgdata-nwp_target IS INITIAL.
      sis_cl_seg_rff_09-reference_code_qualifier = /idexgg/cl_isu_co=>co_rff_g06.
      sis_cl_seg_rff_09-reference_identifier = x_swtmsgpod-msgdata-nwp_target.
      append_idoc_seg( sis_cl_seg_rff_09 ).

    ENDIF.
    IF NOT x_swtmsgpod-msgdata-targ_market_area IS INITIAL.
      sis_cl_seg_rff_09-reference_code_qualifier = /idexgg/cl_isu_co=>co_rff_g07.
      sis_cl_seg_rff_09-reference_identifier = x_swtmsgpod-msgdata-targ_market_area.
      append_idoc_seg( sis_cl_seg_rff_09 ).
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg7_cav_cs_c.
    CLEAR sis_cl_seg_cav_01.

    IF NOT x_swtmsgpod-msgdata-metmethod IS INITIAL   AND
       NOT x_swtmsgpod-msgdata-category  EQ cl_isu_datex_co=>co_bgm_vdew_drop  "E02   20130410 Nagel-Daniel
      .

      CASE x_swtmsgpod-msgdata-metmethod.
        WHEN cl_isu_datex_co=>co_cav_vdew_metmethod "E01
          OR cl_isu_datex_co=>co_cav_vdew_slp "E02
          OR co_cav_tlp_singl_measure   "E14
          OR co_cav_tlp_joint_measure   "E24
          OR co_cav_flat_rate_instaln.  "Z29

          sis_cl_seg_cav_01-charac_value_descr_code = x_swtmsgpod-msgdata-metmethod.
          append_idoc_seg( sis_cl_seg_cav_01 ).

        WHEN OTHERS.

      ENDCASE.

    ENDIF.

  ENDMETHOD.


  METHOD fill_sg7_cav_cs_d.
    DATA: lv_char1 TYPE char1.
    CLEAR sis_cl_seg_cav_01.

    IF NOT x_swtmsgpod-msgdata-metmethod IS INITIAL.

      CASE x_swtmsgpod-msgdata-metmethod.

        WHEN cl_isu_datex_co=>co_cav_vdew_slp. "E02

* profile
          sis_cl_seg_cav_01-charac_value_descr_code = x_swtmsgpod-msgdata-profile.

* handling for code list qualifier
          lv_char1 = sis_cl_seg_cav_01-charac_value_descr_code.

          IF lv_char1 = 'E'.
            sis_cl_seg_cav_01-code_list_resp_agency_code = /idexge/cl_utilmd_v42a=>co_cav_alloc_sup. "89
          ELSEIF lv_char1 <> 'E'.
            sis_cl_seg_cav_01-code_list_resp_agency_code = cl_isu_datex_co=>co_vdew.
          ENDIF.

          append_idoc_seg( sis_cl_seg_cav_01 ).

        WHEN OTHERS.

      ENDCASE.
    ENDIF.
  ENDMETHOD.


  METHOD fill_sg7_cci_cav_cust.
    DATA: lv_spartyp TYPE spartyp.                                        ">>>20130327 Nagel-Daniel  Sparte

* - Y01 - Druckebene der Entnahme
    CLEAR sis_cl_seg_cci_01.

    IF ( gs_s_r_view-send_view = '01' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL )                   "Antwort auf Anmeldung Netz -> Lief/Neu
    OR ( gs_s_r_view-send_view     = '01' AND
         gs_s_r_view-reciever_view = '02' AND
       ( gs_swtmsgpod-msgdata-transreason = 'Z37' OR
         gs_swtmsgpod-msgdata-transreason = 'Z38' ) )            "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
    OR ( gs_s_r_view-send_view     = '02' AND
         gs_s_r_view-reciever_view = '01' AND
       ( gs_swtmsgpod-msgdata-transreason = 'Z37' OR
         gs_swtmsgpod-msgdata-transreason = 'Z38' ) ).            "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

      IF NOT x_swtmsgpod-msgdata-/idexge/spartyp IS INITIAL.
        lv_spartyp = x_swtmsgpod-msgdata-/idexge/spartyp.
      ELSE.
        lv_spartyp = gc_divcat_electricity.
      ENDIF.                           "es wird Strom als Festwert gesetzt

      IF lv_spartyp = gc_divcat_electricity.                            ">>>20130327 Nagel-Daniel  Sparte
**    - E03 - Spannungsebene der Entnahme
        sis_cl_seg_cci_01-characteristic_descr_code = gc_cci_voltage_level.
        append_idoc_seg( sis_cl_seg_cci_01 ).

        sis_cl_seg_cav_01-charac_value_descr_code = 'E06'.              "es wird Niederspannung als Festwert gesetzt
        append_idoc_seg( sis_cl_seg_cav_01 ).
      ELSE.                                                             ">>>20130327 Nagel-Daniel  Sparte
**    - Y01 - Druckebene der Entnahme
        sis_cl_seg_cci_01-characteristic_descr_code = co_cci_press_level.
        append_idoc_seg( sis_cl_seg_cci_01 ).

        sis_cl_seg_cav_01-charac_value_descr_code = co_cci_press_gas_low.
        append_idoc_seg( sis_cl_seg_cav_01 ).
      ENDIF.                                                            ">>>20130327 Nagel-Daniel  Sparte

    ENDIF.
  ENDMETHOD.


  METHOD fill_sg7_cci_cs_c.
    CLEAR sis_cl_seg_cci_01.

    IF NOT x_swtmsgpod-msgdata-metmethod IS INITIAL   AND
       NOT x_swtmsgpod-msgdata-category  EQ cl_isu_datex_co=>co_bgm_vdew_drop  "E02
      .

      CASE x_swtmsgpod-msgdata-metmethod.
        WHEN cl_isu_datex_co=>co_cav_vdew_metmethod "E01
          OR cl_isu_datex_co=>co_cav_vdew_slp "E02
          OR co_cav_tlp_singl_measure   "E14
          OR co_cav_tlp_joint_measure   "E24
          OR co_cav_flat_rate_instaln.  "Z29

          sis_cl_seg_cci_01-characteristic_descr_code = cl_isu_datex_co=>co_cci_vdew_metmethod.
          append_idoc_seg( sis_cl_seg_cci_01 ).

        WHEN OTHERS.

      ENDCASE.

    ENDIF.
  ENDMETHOD.


  METHOD fill_sg7_cci_cs_d.
    DATA: lv_char1 TYPE char1.

    CLEAR sis_cl_seg_cci_01.

    IF NOT x_swtmsgpod-msgdata-metmethod IS INITIAL.

      CASE x_swtmsgpod-msgdata-metmethod.
        WHEN cl_isu_datex_co=>co_cav_vdew_slp. "E02
* E01
          sis_cl_seg_cci_01-characteristic_descr_code = cl_isu_datex_co=>co_cci_vdew_slp.
          lv_char1 = sis_cl_seg_cci_01-characteristic_descr_code.

* handling for responsible code list agency
* set already info for CAV analog CCI
          IF lv_char1 = 'E'.
            sis_cl_seg_cav_01-code_list_resp_agency_code = /idexge/cl_utilmd_v42a=>co_cav_alloc_sup. "89
          ELSEIF lv_char1 = 'Z'.
            sis_cl_seg_cav_01-code_list_resp_agency_code = cl_isu_datex_co=>co_vdew.
          ENDIF.
          append_idoc_seg( sis_cl_seg_cci_01 ).
        WHEN OTHERS.

      ENDCASE.
    ENDIF.
  ENDMETHOD.


  METHOD fill_sg8_ablehnung.
* Device Master Data
    DATA:
      ls_device_data TYPE v_eger,
      lv_meternr     TYPE eideswtmdmeternr.

* Register Data
    DATA:
      ls_register_data TYPE etdz,
      lt_register_data TYPE isu07_ietdz.

* Installation (Return of BAPI Call)
    DATA:
      ls_installation TYPE bapiisupodinstln,
      lt_installation TYPE bapiisupodinstln_t.

    DATA:
      lv_rlm_slp_flatrate TYPE char2,
      ls_easte            TYPE easte,
      add_perverbr        TYPE easte-perverbr,
      ls_swtmsgpod        TYPE  eideswtmsgpod,
      ls_eastl            TYPE eastl,
      lv_process_date     TYPE eidemoveindate.

    DATA: ls_eideswtmsgdata TYPE eideswtmsgdata,
          lv_progyearcons   TYPE char5.

*Nachrichtendaten nachlesen

    SELECT SINGLE * FROM eideswtmsgdata INTO ls_eideswtmsgdata
      WHERE msgdatanum = x_msgdatanum_req.

*-------Setzen Zählpunktdaten SEQ Z01

    IF NOT ls_eideswtmsgdata-ext_ui IS INITIAL.
* SEQ Z01 Zählpunktdaten setzen
      sis_cl_seg_seq_01-action_code = 'Z01'.
      sis_cl_seg_seq_01-sequence_position_identifier = '1'.
      append_idoc_seg( sis_cl_seg_seq_01 ).

* RFF - Referenz auf die Zählpunktbezeichnung
      sis_cl_seg_rff_10-reference_code_qualifier = 'AVE'.
      sis_cl_seg_rff_10-reference_identifier = ls_eideswtmsgdata-ext_ui.
      append_idoc_seg( sis_cl_seg_rff_10 ).
    ENDIF.
*------------------------------
*Vorjahresverbrauch addieren wenn mehrere zählende ZW
    LOOP AT x_device_data INTO ls_device_data.

      CALL FUNCTION 'ISU_DB_ETDZ_SELECT'
        EXPORTING
          x_equnr       = ls_device_data-equnr
          x_ab          = ls_device_data-ab
          x_bis         = ls_device_data-bis
        TABLES
          t_etdz        = lt_register_data
        EXCEPTIONS
          not_found     = 1
          system_error  = 2
          not_qualified = 3
          OTHERS        = 4.

*Vorverbrauch über Periodenverbrauch ermitteln
*Vorjahresverbrauch addieren wenn mehrere zählende ZW
      LOOP AT lt_register_data INTO ls_register_data.

*Ermitteln wann das Gerät eingebaut worden ist
        IF     x_swtmsgpod-msgdata-moveindate IS INITIAL AND
           NOT x_swtmsgpod-msgdata-moveoutdate IS INITIAL.
          SELECT * FROM eastl INTO ls_eastl
                            WHERE anlage = ls_installation-installation
                              AND logiknr = ls_device_data-logiknr
                              AND ab <= x_swtmsgpod-msgdata-moveoutdate
                              AND bis >= x_swtmsgpod-msgdata-moveoutdate.

          ENDSELECT.
        ELSEIF ( NOT x_swtmsgpod-msgdata-moveindate IS INITIAL AND
                 NOT x_swtmsgpod-msgdata-moveoutdate IS INITIAL ) OR
               ( NOT x_swtmsgpod-msgdata-moveindate IS INITIAL AND
                     x_swtmsgpod-msgdata-moveoutdate IS INITIAL ).
*Ermitteln eann das Gerät eingebaut worden ist
          SELECT * FROM eastl INTO ls_eastl
                            WHERE anlage = ls_installation-installation
                              AND logiknr = ls_device_data-logiknr
                              AND ab <= x_swtmsgpod-msgdata-moveindate
                              AND bis >= x_swtmsgpod-msgdata-moveindate.

          ENDSELECT.
        ENDIF.

        CALL FUNCTION 'ISU_DB_EASTE_SINGLE'
          EXPORTING
            x_logikzw = ls_register_data-logikzw
            x_ab      = ls_eastl-ab
            x_actual  = 'X'
          IMPORTING
            y_easte   = ls_easte
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        add_perverbr = ls_easte-perverbr + add_perverbr.

      ENDLOOP.
    ENDLOOP.

    IF add_perverbr IS INITIAL.
      lv_progyearcons = '1000'.
    ENDIF.

    SHIFT lv_progyearcons LEFT DELETING LEADING space.
*---------------------------------
    IF ( gs_s_r_view-send_view = '03' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL ).          "Antwort auf Kündigung Lief/Alt -> Lief/Neu

      IF  ls_eideswtmsgdata-progyearcons = '0'.
        lv_progyearcons = add_perverbr.
      ELSE.
        lv_progyearcons = ls_eideswtmsgdata-progyearcons.
      ENDIF.

      SHIFT lv_progyearcons LEFT DELETING LEADING space.

      sis_cl_seg_qty_01-quantity = lv_progyearcons.
*      translate  sis_cl_seg_qty_01-quantity using '.,'.
      sis_cl_seg_qty_01-quantity_type_code_qualifier = 'Z09'.   "Vorjahresverbrauch
      sis_cl_seg_qty_01-measurement_unit_code = cl_isu_datex_co=>co_qty_vdew_kwh.
      append_idoc_seg( sis_cl_seg_qty_01 ).
    ELSE.

      sis_cl_seg_qty_01-quantity = lv_progyearcons.
*    translate  sis_cl_seg_qty_01-quantity using '.,'.
      sis_cl_seg_qty_01-quantity_type_code_qualifier = '31'.   "Veranschlagte Jahresmenge gesamt
      sis_cl_seg_qty_01-measurement_unit_code = cl_isu_datex_co=>co_qty_vdew_kwh.
      append_idoc_seg( sis_cl_seg_qty_01 ).
    ENDIF.
*    endif.

*CCI-Zeitreihenart
    IF NOT ls_eideswtmsgdata-/idexge/cci_tsca IS INITIAL.
* CCI - 15 - Angabe des Zeitreihentyp / Struktur
      sis_cl_seg_cci_03-class_type_code = co_cci_class_structure.
      sis_cl_seg_cci_03-characteristic_descr_code  = ls_eideswtmsgdata-/idexge/cci_tsca.
      append_idoc_seg( sis_cl_seg_cci_03 ).
    ENDIF.
    IF NOT ls_eideswtmsgdata-/idexge/tstype IS INITIAL.
* CAV - SLS - Angabe des Zeitreihentyp
      sis_cl_seg_cav_02-charac_value_descr_code = ls_eideswtmsgdata-/idexge/tstype .
      append_idoc_seg( sis_cl_seg_cav_02 ).
      CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
    ENDIF.

*-----CCI CAV - Spannungsebene der Messung

    IF NOT ls_eideswtmsgdata-/idexge/meavolt IS INITIAL.
* CCI - E04 -  Spannungsebene der Messung
      sis_cl_seg_cci_03-characteristic_descr_code = 'E04'.
      append_idoc_seg( sis_cl_seg_cci_03 ).
* CAV - E06 -  Niederspannung)
      sis_cl_seg_cav_02-charac_value_descr_code = ls_eideswtmsgdata-/idexge/meavolt.
      append_idoc_seg( sis_cl_seg_cav_02 ).
      CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
    ENDIF.

    IF ( gs_s_r_view-send_view = '03' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL ).          "Antwort auf Kündigung Lief/Alt -> Lief/Neu

    ELSE.
*-------Setzen Zählpunktdaten SEQ Z02
*SEQ OBIS Daten Z02
      sis_cl_seg_seq_01-action_code = 'Z02'.
      sis_cl_seg_seq_01-sequence_position_identifier = '1'.
      append_idoc_seg( sis_cl_seg_seq_01 ).

* RFF - Referenz auf die Zählpunktsbezeichnung
      IF NOT ls_eideswtmsgdata-ext_ui IS INITIAL.
        sis_cl_seg_rff_10-reference_code_qualifier = 'AVE'.
        sis_cl_seg_rff_10-reference_identifier = ls_eideswtmsgdata-ext_ui.
        append_idoc_seg( sis_cl_seg_rff_10 ).
      ENDIF.

*RFF - Zählernummer setzen
      IF NOT ls_eideswtmsgdata-meternr IS INITIAL.
        sis_cl_seg_rff_10-reference_code_qualifier = 'MG'.
        sis_cl_seg_rff_10-reference_identifier = ls_eideswtmsgdata-meternr.
        append_idoc_seg( sis_cl_seg_rff_10 ).
      ENDIF.

* Pia - Zuordnung der OBIS
      IF NOT ls_eideswtmsgdata-zzobiskennzf IS INITIAL.
        sis_cl_seg_pia_02-item_type_ident_code_3 = 'MP'.
        sis_cl_seg_pia_02-code_list_ident_code_3 = ls_eideswtmsgdata-zzbetrag_konzessionsabgabe.

        sis_cl_seg_pia_02-product_ident_code_qualifier = '5'.
        sis_cl_seg_pia_02-item_identifier_1 = ls_eideswtmsgdata-zzobiskennzf.
        sis_cl_seg_pia_02-item_type_ident_code_1 = 'SRW'.

        append_idoc_seg( sis_cl_seg_pia_02 ).
      ENDIF.

* CCI - E09 - Betrag Konzessionsabgabe Z08 Betrag Konzessionsabgabe (Nicht- Schwachlast)
      IF  ls_eideswtmsgdata-/idexge/ff_ht <> '0'.
        sis_cl_seg_cci_03-characteristic_descr_code =  ls_eideswtmsgdata-/idexge/ff_ht .

        append_idoc_seg( sis_cl_seg_cci_03 ).

        sis_cl_seg_cav_02-charac_value_descr_code = 'Z14'.
        sis_cl_seg_cav_02-characteristic_value_descr_1 = '0.0011'.

        append_idoc_seg( sis_cl_seg_cav_02 ).

      ELSEIF ls_eideswtmsgdata-/idexge/ff_nt  <> '0'.
        sis_cl_seg_cci_03-characteristic_descr_code =  ls_eideswtmsgdata-/idexge/ff_nt.

        append_idoc_seg( sis_cl_seg_cci_03 ).

        sis_cl_seg_cav_02-charac_value_descr_code = 'Z14'.
        sis_cl_seg_cav_02-characteristic_value_descr_1 = '0.0011'.

        append_idoc_seg( sis_cl_seg_cav_02 ).
      ENDIF.

* CCI - 11 -  Niederspannung)
      sis_cl_seg_cci_03-class_type_code = '11'.
      sis_cl_seg_cci_03-characteristic_descr_code = 'Z33'.
      append_idoc_seg( sis_cl_seg_cci_03 ).
* CAV - E06 -  Niederspannung)
      sis_cl_seg_cav_02-characteristic_value_descr_1 =  ls_eideswtmsgdata-zz_stanzvor.
      sis_cl_seg_cav_02-characteristic_value_descr_2 =  ls_eideswtmsgdata-zz_stanznac.
      SHIFT sis_cl_seg_cav_02-characteristic_value_descr_1 LEFT DELETING LEADING '0'.
      SHIFT sis_cl_seg_cav_02-characteristic_value_descr_2 LEFT DELETING LEADING '0'.

      append_idoc_seg( sis_cl_seg_cav_02 ).
    ENDIF.
*-------Setzen Zählpunktdaten SEQ Z03

* SEQ Z03 Zähleinrichtungsdaten setzen
    IF NOT ls_eideswtmsgdata-meternr IS INITIAL.
      sis_cl_seg_seq_01-action_code = 'Z03'.
      sis_cl_seg_seq_01-sequence_position_identifier = '1'.
      SHIFT sis_cl_seg_seq_01-sequence_position_identifier LEFT DELETING LEADING space.
      append_idoc_seg( sis_cl_seg_seq_01 ).

      CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

* RFF - Referenz auf die Zählpunktbezeichnung
      sis_cl_seg_rff_10-reference_code_qualifier = 'AVE'.
      sis_cl_seg_rff_10-reference_identifier = ls_eideswtmsgdata-ext_ui.
      append_idoc_seg( sis_cl_seg_rff_10 ).
      CLEAR: sis_cl_seg_rff_10 .

* CCI - E13 - Zähleinrichtung setzen
      sis_cl_seg_cci_03-characteristic_descr_code = gc_cci_device_type.
      append_idoc_seg( sis_cl_seg_cci_03 ).
      CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

      IF NOT ls_eideswtmsgdata-meter_type IS INITIAL.
        sis_cl_seg_cav_02-charac_value_descr_code = ls_eideswtmsgdata-meter_type.
        append_idoc_seg( sis_cl_seg_cav_02 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
      ENDIF.

* CAV - Identifikation/Nummer des Gerätes - Z30
      IF NOT ls_eideswtmsgdata-meternr IS INITIAL.
        sis_cl_seg_cav_02-charac_value_descr_code = 'Z30'.
        sis_cl_seg_cav_02-characteristic_value_descr_1 = ls_eideswtmsgdata-meternr.
        append_idoc_seg( sis_cl_seg_cav_02 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
      ENDIF.

* CAV - Tarifanzahl - ETZ Eintarif / ZTZ Zweitarif / NTZ Mehrtarif
      IF NOT ls_eideswtmsgdata-/idexge/rate_num IS INITIAL.
        sis_cl_seg_cav_02-charac_value_descr_code =  ls_eideswtmsgdata-/idexge/rate_num.
        append_idoc_seg( sis_cl_seg_cav_02 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
      ENDIF.


* CAV - Energierichtung - ERZ Einrichtungszähler / ZRZ Zweirichtungszähler
      IF NOT ls_eideswtmsgdata-/idexge/engy_dir IS INITIAL.
        sis_cl_seg_cav_02-charac_value_descr_code = ls_eideswtmsgdata-/idexge/engy_dir.
        append_idoc_seg( sis_cl_seg_cav_02 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
      ENDIF.

* CAV -  Messwerterfassung Merkmalswert - AMR fernauslesbare Zähler / MMR manuell ausgelesene Zähler
      IF NOT ls_eideswtmsgdata-/idexge/mr_type IS INITIAL.

* CCI - E13 - Merkmal/Klassenidentifikation
        sis_cl_seg_cci_03-characteristic_descr_code = gc_cci_meter_read.
        append_idoc_seg( sis_cl_seg_cci_03 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

        sis_cl_seg_cav_02-charac_value_descr_code = ls_eideswtmsgdata-/idexge/mr_type.
        append_idoc_seg( sis_cl_seg_cav_02 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg8_pia_cs.

    DATA:
      lv_rlm_slp_flatrate TYPE char2,
      lv_serial_no        TYPE gernr. "Serial number

* Select Option: Serial Number
    DATA:
      ls_serialno_range TYPE isu_ranges,
      lt_serialno_range TYPE iisu_ranges.

* Select Option: Installation
    DATA:
      ls_install_range TYPE isu_ranges,
      lt_install_range TYPE iisu_ranges.

* Installation (Return of BAPI Call)
    DATA:
      ls_installation TYPE bapiisupodinstln,
      lt_installation TYPE bapiisupodinstln_t.

* Messages (Return of BAPI Call)
    DATA:
      ls_bapi_return TYPE bapiret2,
      lt_bapi_return TYPE bapiret2tab.

* Device Master Data
    DATA:
      ls_device_data TYPE v_eger,
      lt_device_data TYPE t_v_eger.

* Register Data
    DATA:
      ls_register_data TYPE etdz,
      lt_register_data TYPE isu07_ietdz.

    DATA:
      lv_line_count    TYPE i,
      ls_register_code TYPE tekennziff.

    CLEAR sis_cl_seg_pia_02.

* Only relevant to response to registration (betweeen DSO & SUPL)
* and request & response of basic & backup supply
    IF ( iv_switch_msgcat = if_isu_ide_switch_constants=>co_swtmdcat_enroll ) AND "E01
       ( ( NOT is_swtmsgpod-msgdata-msgstatus IS INITIAL ) OR
         ( is_swtmsgpod-msgdata-transreason = if_isu_ide_switch_constants=>co_transreason_backupspl OR "E04
           is_swtmsgpod-msgdata-transreason = co_sts_bs_cust_in  OR    "Z36
           is_swtmsgpod-msgdata-transreason = co_sts_bs_new_inst OR    "Z37
           is_swtmsgpod-msgdata-transreason = co_sts_bs_cs_fail  OR    "Z38
           is_swtmsgpod-msgdata-transreason = co_sts_bs_temp_conn ) ). "Z39

*--for flat rate installation, do not fill PIA OBIS key figure
      IF NOT is_swtmsgpod-int_ui IS INITIAL.
        CALL METHOD /idexge/cl_isu_idex_utility=>check_rlm_slp_flatrate
          EXPORTING
            iv_pod_int_ui        = is_swtmsgpod-int_ui
            iv_keydate           = is_swtmsgpod-msgdata-moveindate
            iv_own_servprov      = iv_sender
            iv_check_flatrate    = co_flag_marked
          IMPORTING
            ev_rlm_slp_flatrate  = lv_rlm_slp_flatrate
          EXCEPTIONS
            intmeter_no_profile  = 1
            rlm_slp_not_relevant = 2
            error_occurred       = 3
            OTHERS               = 4.
      ENDIF.

* Flat rate
      CHECK lv_rlm_slp_flatrate <> /idexge/cl_isu_idex_utility=>co_flat_rate_instal.
*--End

*   Meter Number of Switch Message
      IF NOT is_swtmsgpod-msgdata-meternr IS INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = is_swtmsgpod-msgdata-meternr
          IMPORTING
            output = lv_serial_no.

        ls_serialno_range-sign   = gc_sign_include.
        ls_serialno_range-option = gc_option_equal.
        ls_serialno_range-low    = lv_serial_no.
        APPEND ls_serialno_range TO lt_serialno_range.

      ELSE.
*     Identify installation from the PoD
        CALL FUNCTION 'BAPI_ISUPOD_GETINSTALLATION'
          EXPORTING
            pointofdelivery = is_swtmsgpod-ext_ui
            keydate         = is_swtmsgpod-msgdata-moveindate
          TABLES
            installation    = lt_installation
            return          = lt_bapi_return.
*     Check errors for BAPI Call
        LOOP AT lt_bapi_return INTO ls_bapi_return
                               WHERE type = co_msg_error
                                  OR type = co_msg_programming_error.
          MESSAGE ID ls_bapi_return-id
                TYPE ls_bapi_return-type
              NUMBER ls_bapi_return-number
                WITH ls_bapi_return-message_v1 ls_bapi_return-message_v2
                     ls_bapi_return-message_v3 ls_bapi_return-message_v4
             RAISING error_occurred.
        ENDLOOP.

        READ TABLE lt_installation INTO ls_installation INDEX 1.
        IF sy-subrc <> 0.
          RAISE error_occurred.
        ENDIF.

        ls_install_range-sign   = gc_sign_include.
        ls_install_range-option = gc_option_equal.
        ls_install_range-low    = ls_installation-installation.
        APPEND ls_install_range TO lt_install_range.
      ENDIF.

*   Get device master data based on Installation or Serial number
      CALL FUNCTION 'ISU_DB_EGER_SELECT_RANGE'
        EXPORTING
          x_keydate      = is_swtmsgpod-msgdata-moveindate
          x_read_egerr   = co_flag_marked
        TABLES
          xt_anlage      = lt_install_range
          xt_geraet      = lt_serialno_range
          yt_v_eger      = lt_device_data
        EXCEPTIONS
          not_found      = 1
          date_invalid   = 2
          system_error   = 3
          internal_error = 4
          OTHERS         = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error_occurred.
      ENDIF.

      READ TABLE lt_device_data INTO ls_device_data INDEX 1.
*   Get register data related to the device.
      CALL FUNCTION 'ISU_DB_ETDZ_SELECT'
        EXPORTING
          x_equnr       = ls_device_data-equnr
          x_ab          = ls_device_data-ab
          x_bis         = ls_device_data-bis
        TABLES
          t_etdz        = lt_register_data
        EXCEPTIONS
          not_found     = 1
          system_error  = 2
          not_qualified = 3
          OTHERS        = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

      DESCRIBE TABLE lt_register_data LINES lv_line_count.

      sis_cl_seg_pia_01-code_list_resp_agency_code_1 = gc_pia_de_inst_for_stand.   "174

      IF lv_line_count = 1.

        READ TABLE lt_register_data INTO ls_register_data INDEX 1.

        sis_cl_seg_pia_02-product_ident_code_qualifier  = gc_pia_prod_id.
        sis_cl_seg_pia_02-item_identifier_1      = ls_register_data-kennziff.
        sis_cl_seg_pia_02-item_type_ident_code_1 = gc_pia_edis.

        append_idoc_seg( sis_cl_seg_pia_02 ).

      ELSEIF lv_line_count > 1.

        LOOP AT lt_register_data INTO ls_register_data.
          sis_cl_seg_pia_02-product_ident_code_qualifier  = gc_pia_prod_id.
          sis_cl_seg_pia_02-item_identifier_1      = ls_register_data-kennziff.
          sis_cl_seg_pia_02-item_type_ident_code_1 = gc_pia_edis.

* 3rd repetition MP/ZSF/ZNS only filled for electricity
          IF gv_divcat = /idexgg/cl_isu_co=>co_spartyp_strom.
            CALL FUNCTION 'ISU_DB_TEKENNZIFF_SINGLE'
              EXPORTING
                im_spartyp    = ls_register_data-spartyp
                im_kennziff   = ls_register_data-kennziff
              IMPORTING
                ex_tekennziff = ls_register_code
              EXCEPTIONS
                not_found     = 1
                general_fault = 2
                OTHERS        = 3.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
            ENDIF.

            sis_cl_seg_pia_02-item_type_ident_code_3 = gc_pia_obis.

            IF ls_register_code-eusage = gc_pia_hp.
              sis_cl_seg_pia_02-code_list_ident_code_3 = gc_pia_zns.
            ELSEIF ls_register_code-eusage = gc_pia_lp.
              sis_cl_seg_pia_02-code_list_ident_code_3 = gc_pia_zsf.
            ENDIF.
          ENDIF.
          append_idoc_seg( sis_cl_seg_pia_02 ).
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg8_seq_cust.
    DATA: lv_serial_no      TYPE gernr, "Serial number
          lv_identifier     TYPE p,
          lv_geraet_install.

* Select Option: Serial Number
    DATA:
      ls_serialno_range TYPE isu_ranges,
      lt_serialno_range TYPE iisu_ranges.

* Installation (Return of BAPI Call)
    DATA:
      ls_installation TYPE bapiisupodinstln,
      lt_installation TYPE bapiisupodinstln_t.

* Select Option: Installation
    DATA:
      ls_install_range TYPE isu_ranges,
      lt_install_range TYPE iisu_ranges.

* Messages (Return of BAPI Call)
    DATA:
      ls_bapi_return TYPE bapiret2,
      lt_bapi_return TYPE bapiret2tab.

* Device Master Data
    DATA:
      ls_device_data TYPE v_eger,
      lt_device_data TYPE t_v_eger,
      lv_meternr     TYPE eideswtmdmeternr.

* Register Data
    DATA:
      ls_register_data TYPE etdz,
      lt_register_data TYPE isu07_ietdz.

* Device Type (defined by BDEW) for filling of UTILMD SG10-CAV C889-1131
    DATA:
      lv_bdew_devicetype  TYPE char17.

    DATA:
      lv_rlm_slp_flatrate TYPE char2,
      ls_easte            TYPE easte,
      add_perverbr        TYPE easte-perverbr,
      ls_swtmsgpod        TYPE  eideswtmsgpod,
      ls_eastl            TYPE eastl,
      lv_process_date     TYPE  eidemoveindate.

    CLEAR sis_cl_seg_seq_01.

    IF x_swtmsgpod-msgdata-zzcategory = 'E35' OR      "Kündigung Antwort
       x_swtmsgpod-msgdata-category = 'E35' OR        "Kündigung
       x_swtmsgpod-msgdata-category = 'E02'.         "Abmeldung
      lv_meternr = ''.
      lv_process_date = x_swtmsgpod-msgdata-moveoutdate.
    ELSE.
      lv_meternr = ''.
      lv_process_date = x_swtmsgpod-msgdata-moveindate.
    ENDIF.
*
*Gerätedaten ermitteln
    IF NOT lv_meternr IS INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = x_swtmsgpod-msgdata-meternr
        IMPORTING
          output = lv_serial_no.

      ls_serialno_range-sign   = gc_sign_include.
      ls_serialno_range-option = gc_option_equal.
      ls_serialno_range-low    = lv_serial_no.
      APPEND ls_serialno_range TO lt_serialno_range.

    ELSE.
*     Identify installation from the PoD
      CALL FUNCTION 'BAPI_ISUPOD_GETINSTALLATION'
        EXPORTING
          pointofdelivery = x_swtmsgpod-ext_ui
          keydate         = lv_process_date
        TABLES
          installation    = lt_installation
          return          = lt_bapi_return.
*     Check errors for BAPI Call
      LOOP AT lt_bapi_return INTO ls_bapi_return
                             WHERE type = co_msg_error
                                OR type = co_msg_programming_error.
*      message id ls_bapi_return-id
*            type ls_bapi_return-type
*          number ls_bapi_return-number
*            with ls_bapi_return-message_v1 ls_bapi_return-message_v2
*                 ls_bapi_return-message_v3 ls_bapi_return-message_v4
*         raising error_occurred.
      ENDLOOP.

      READ TABLE lt_installation INTO ls_installation INDEX 1.
      IF sy-subrc <> 0.
*      raise error_occurred.
      ENDIF.

      ls_install_range-sign   = gc_sign_include.
      ls_install_range-option = gc_option_equal.
      ls_install_range-low    = ls_installation-installation.
      APPEND ls_install_range TO lt_install_range.
    ENDIF.

*   Get device master data based on Installation or Serial number
    CALL FUNCTION 'ISU_DB_EGER_SELECT_RANGE'
      EXPORTING
        x_keydate      = x_swtmsgpod-msgdata-moveindate
        x_read_egerr   = co_flag_marked
      TABLES
        xt_anlage      = lt_install_range
        xt_geraet      = lt_serialno_range
        yt_v_eger      = lt_device_data
      EXCEPTIONS
        not_found      = 1
        date_invalid   = 2
        system_error   = 3
        internal_error = 4
        OTHERS         = 5.
    IF sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*            raising error_occurred.
    ENDIF.

    IF  x_swtmsgpod-msgdata-msgstatus = 'E15' OR
        x_swtmsgpod-msgdata-msgstatus = 'E43' OR
        x_swtmsgpod-msgdata-msgstatus = 'E44' OR
        x_swtmsgpod-msgdata-msgstatus = 'Z44' OR
        x_swtmsgpod-msgdata-msgstatus = 'Z01' OR
        x_swtmsgpod-msgdata-msgstatus = space.
      lv_geraet_install = 'X'.
    ELSE.
      IF NOT  lt_device_data[] IS INITIAL.
        lv_geraet_install = 'X'.
      ENDIF.
    ENDIF.

*---------------------------------------------------------------------
*-------Setzen Zählpunktdaten SEQ Z01 / Vorjahresverbrauch
*  if  x_swtmsgpod-msgdata-msgstatus = 'E15' or
*      x_swtmsgpod-msgdata-msgstatus = 'E43' or
*      x_swtmsgpod-msgdata-msgstatus = 'E44' or
*      x_swtmsgpod-msgdata-msgstatus = 'Z44' or
*      x_swtmsgpod-msgdata-msgstatus = 'Z01' or
*      x_swtmsgpod-msgdata-msgstatus = space.

*wenn Gerät installiert dann Gerätedaten verwenden
    IF NOT lv_geraet_install IS INITIAL.

      CALL METHOD me->fill_sg8_z01
        EXPORTING
          x_swtmsgpod    = x_swtmsgpod
          x_device_data  = lt_device_data
          x_installation = lt_installation.

*------Setzen OBIS Daten SEQ Z02

      CALL METHOD me->fill_sg8_z02
        EXPORTING
          x_swtmsgpod   = x_swtmsgpod
          x_device_data = lt_device_data.

*-------Setzen Zähleinrichtungsdaten SEQ Z03

      CALL METHOD me->fill_sg8_z03
        EXPORTING
          x_swtmsgpod   = x_swtmsgpod
          x_device_data = lt_device_data.

*--------Setzen Wandler/Mengenumwerter-Daten SEQ Z04

      CALL METHOD me->fill_sg8_z04
        EXPORTING
          x_swtmsgpod   = x_swtmsgpod
          x_device_data = lt_device_data.

*--------Setzen Kommunikationseinrichtungsdaten SEQ Z05

      CALL METHOD me->fill_sg8_z05
        EXPORTING
          x_swtmsgpod   = x_swtmsgpod
          x_device_data = lt_device_data.

*--------Setzen Daten der technischen Steuereinrichtung SEQ Z06

      CALL METHOD me->fill_sg8_z06
        EXPORTING
          x_swtmsgpod   = x_swtmsgpod
          x_device_data = lt_device_data.
    ELSE.



      CALL METHOD me->fill_sg8_ablehnung
        EXPORTING
          x_swtmsgpod      = x_swtmsgpod
          x_device_data    = lt_device_data
          x_installation   = lt_installation
          x_msgdatanum_req = x_msgdatanum_req.

    ENDIF.

  ENDMETHOD.


  METHOD fill_sg8_z01.
* Device Master Data
    DATA:
      ls_device_data TYPE v_eger,
      lv_meternr     TYPE eideswtmdmeternr.

* Register Data
    DATA:
      ls_register_data TYPE etdz,
      lt_register_data TYPE isu07_ietdz.

* Installation (Return of BAPI Call)
    DATA:
      ls_installation TYPE bapiisupodinstln,
      lt_installation TYPE bapiisupodinstln_t.

    DATA:
      lv_rlm_slp_flatrate TYPE char2,
      ls_easte            TYPE easte,
      add_perverbr        TYPE easte-perverbr,
      ls_swtmsgpod        TYPE  eideswtmsgpod,
      ls_eastl            TYPE eastl,
      lv_process_date     TYPE eidemoveindate.

*-------Setzen Zählpunktdaten SEQ Z01

    IF ( gs_s_r_view-send_view = '01' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL )                "Antwort auf Anmeldung Netz -> Lief/Neu
     OR ( gs_s_r_view-send_view = '03' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL )                 "Antwort auf Kündigung Lief/Alt -> Lief/Neu
     OR ( gs_s_r_view-send_view     = '01' AND
          gs_s_r_view-reciever_view = '02' AND
        ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
          x_swtmsgpod-msgdata-transreason = 'Z38' ) )           "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
     OR ( gs_s_r_view-send_view     = '02' AND
          gs_s_r_view-reciever_view = '01' AND
        ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
          x_swtmsgpod-msgdata-transreason = 'Z38' ) ).           "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

* SEQ Z01 Zählpunktdaten setzen
      sis_cl_seg_seq_01-action_code = 'Z01'.
      sis_cl_seg_seq_01-sequence_position_identifier = '1'.
      append_idoc_seg( sis_cl_seg_seq_01 ).

* RFF - Referenz auf die Zählpunktbezeichnung
      sis_cl_seg_rff_10-reference_code_qualifier = 'AVE'.
      sis_cl_seg_rff_10-reference_identifier = x_swtmsgpod-msgdata-ext_ui.
      append_idoc_seg( sis_cl_seg_rff_10 ).

      READ TABLE x_installation INTO ls_installation INDEX 1.

*Vorjahresverbrauch addieren wenn mehrere zählende ZW
      LOOP AT x_device_data INTO ls_device_data.

        CALL FUNCTION 'ISU_DB_ETDZ_SELECT'
          EXPORTING
            x_equnr       = ls_device_data-equnr
            x_ab          = ls_device_data-ab
            x_bis         = ls_device_data-bis
          TABLES
            t_etdz        = lt_register_data
          EXCEPTIONS
            not_found     = 1
            system_error  = 2
            not_qualified = 3
            OTHERS        = 4.

*Vorverbrauch über Periodenverbrauch ermitteln
*Vorjahresverbrauch addieren wenn mehrere zählende ZW
        LOOP AT lt_register_data INTO ls_register_data.

*Ermitteln wann das Gerät eingebaut worden ist
          IF     x_swtmsgpod-msgdata-moveindate IS INITIAL AND
             NOT x_swtmsgpod-msgdata-moveoutdate IS INITIAL.
            SELECT * FROM eastl INTO ls_eastl
                              WHERE anlage = ls_installation-installation
                                AND logiknr = ls_device_data-logiknr
                                AND ab <= x_swtmsgpod-msgdata-moveoutdate
                                AND bis >= x_swtmsgpod-msgdata-moveoutdate.

            ENDSELECT.
          ELSEIF ( NOT x_swtmsgpod-msgdata-moveindate IS INITIAL AND
                   NOT x_swtmsgpod-msgdata-moveoutdate IS INITIAL ) OR
                 ( NOT x_swtmsgpod-msgdata-moveindate IS INITIAL AND
                       x_swtmsgpod-msgdata-moveoutdate IS INITIAL ).
*Ermitteln eann das Gerät eingebaut worden ist
            SELECT * FROM eastl INTO ls_eastl
                              WHERE anlage = ls_installation-installation
                                AND logiknr = ls_device_data-logiknr
                                AND ab <= x_swtmsgpod-msgdata-moveindate
                                AND bis >= x_swtmsgpod-msgdata-moveindate.

            ENDSELECT.
          ENDIF.

          CALL FUNCTION 'ISU_DB_EASTE_SINGLE'
            EXPORTING
              x_logikzw = ls_register_data-logikzw
              x_ab      = ls_eastl-ab
              x_actual  = 'X'
            IMPORTING
              y_easte   = ls_easte
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.

          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

          add_perverbr = ls_easte-perverbr + add_perverbr.

        ENDLOOP.
      ENDLOOP.

      ls_swtmsgpod = x_swtmsgpod.
      ls_swtmsgpod-msgdata-progyearcons = add_perverbr.

      IF ( gs_s_r_view-send_view = '01' AND
           gs_s_r_view-reciever_view = '02' AND
           gs_s_r_view-msgstatus IS NOT INITIAL )                 "Antwort auf Anmeldung Netz -> Lief/Neu
      OR ( gs_s_r_view-send_view = '03' AND
           gs_s_r_view-reciever_view = '02' AND
           gs_s_r_view-msgstatus IS NOT INITIAL )                  "Antwort auf Kündigung Lief/Alt -> Lief/Neu
      OR ( gs_s_r_view-send_view     = '01' AND
          gs_s_r_view-reciever_view = '02' AND
         ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
           x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
      OR ( gs_s_r_view-send_view     = '02' AND
           gs_s_r_view-reciever_view = '01' AND
         ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
           x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

*-----QTY - Vorjahresverbrauch setzen
        CALL METHOD me->fill_sg9_qty_cs_z09
          EXPORTING
            x_swtmsgpod = ls_swtmsgpod.
      ENDIF.

*-----CCI CAV - Zeitreihentyp setzen

      IF ( gs_s_r_view-send_view = '01' AND
           gs_s_r_view-reciever_view = '02' AND
           gs_s_r_view-msgstatus IS NOT INITIAL )                  "Antwort auf Anmeldung Netz -> Lief/Neu
      OR ( gs_s_r_view-send_view     = '01' AND
           gs_s_r_view-reciever_view = '02' AND
         ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
           x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
      OR ( gs_s_r_view-send_view     = '02' AND
           gs_s_r_view-reciever_view = '01' AND
         ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
           x_swtmsgpod-msgdata-transreason = 'Z38' ) AND
           gs_s_r_view-msgstatus IS NOT INITIAL ).                 "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

        IF ( gs_s_r_view-send_view     = '02' AND
             gs_s_r_view-reciever_view = '01' AND
           ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
             x_swtmsgpod-msgdata-transreason = 'Z38' ) AND
             gs_s_r_view-msgstatus IS NOT INITIAL ).                 "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz
*nicht senden
        ELSE.
* CCI - 15 - Angabe des Zeitreihentyp / Struktur
          sis_cl_seg_cci_03-class_type_code = co_cci_class_structure.
          sis_cl_seg_cci_03-characteristic_descr_code  = 'Z21'.
          append_idoc_seg( sis_cl_seg_cci_03 ).
* CAV - SLS - Angabe des Zeitreihentyp
          sis_cl_seg_cav_02-charac_value_descr_code = 'SLS'.
          append_idoc_seg( sis_cl_seg_cav_02 ).
          CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
        ENDIF.
*-----CCI CAV - Spannungsebene der Messung

* CCI - E04 -  Spannungsebene der Messung
        sis_cl_seg_cci_03-characteristic_descr_code = 'E04'.
        append_idoc_seg( sis_cl_seg_cci_03 ).
* CAV - E06 -  Niederspannung)
        sis_cl_seg_cav_02-charac_value_descr_code = 'E06'.
        append_idoc_seg( sis_cl_seg_cav_02 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD fill_sg8_z02.
* Device Master Data
    DATA:
      ls_device_data      TYPE v_eger.

* Register Data
    DATA:
      ls_register_data TYPE etdz,
      lt_register_data TYPE isu07_ietdz,
      lv_lenght        TYPE p.

    LOOP AT x_device_data INTO ls_device_data.

      CALL FUNCTION 'ISU_DB_ETDZ_SELECT'
        EXPORTING
          x_equnr       = ls_device_data-equnr
          x_ab          = ls_device_data-ab
          x_bis         = ls_device_data-bis
        TABLES
          t_etdz        = lt_register_data
        EXCEPTIONS
          not_found     = 1
          system_error  = 2
          not_qualified = 3
          OTHERS        = 4.

      LOOP AT lt_register_data INTO ls_register_data .

        IF ( gs_s_r_view-send_view = '01' AND
             gs_s_r_view-reciever_view = '02' AND
             gs_s_r_view-msgstatus IS NOT INITIAL )                 "Antwort auf Anmeldung Netz -> Lief/Neu
        OR ( gs_s_r_view-send_view     = '01' AND
             gs_s_r_view-reciever_view = '02' AND
            ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
             x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
        OR ( gs_s_r_view-send_view     = '02' AND
             gs_s_r_view-reciever_view = '01' AND
           ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
             x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz


*SEQ OBIS Daten Z02
          sis_cl_seg_seq_01-action_code = 'Z02'.
          sis_cl_seg_seq_01-sequence_position_identifier = '1'.
          append_idoc_seg( sis_cl_seg_seq_01 ).

* RFF - Referenz auf die Zählpunktsbezeichnung
          sis_cl_seg_rff_10-reference_code_qualifier = 'AVE'.
          sis_cl_seg_rff_10-reference_identifier = x_swtmsgpod-msgdata-ext_ui.
          append_idoc_seg( sis_cl_seg_rff_10 ).

*RFF - Zählernummer setzen
          sis_cl_seg_rff_10-reference_code_qualifier = 'MG'.
          sis_cl_seg_rff_10-reference_identifier = ls_device_data-geraet.
          append_idoc_seg( sis_cl_seg_rff_10 ).

*PIA - Obis Kennziffer setzen

          DESCRIBE FIELD ls_register_data-kennziff LENGTH lv_lenght IN CHARACTER MODE.
          lv_lenght = lv_lenght - '1'.

*        bv  blindverbrauch (obsolet)
*        et  eintarif
*        ht  hochtarif
*        nt  niedrigtarif
*        nz  normalzeit (obsolet)
*        vb  verbrauchszählwerk (obsolet)
*        wv  wirkverbrauch (obsolet)

* Pia - Zuordnung der OBIS
          CASE ls_register_data-zwart.
            WHEN 'BV'.
              sis_cl_seg_pia_02-item_type_ident_code_3 = ''.
              sis_cl_seg_pia_02-code_list_ident_code_3 = ''.
            WHEN 'ET'.
              sis_cl_seg_pia_02-item_type_ident_code_3 = 'MP'.
              sis_cl_seg_pia_02-code_list_ident_code_3 = 'ZNS'.
            WHEN 'HT'.
              sis_cl_seg_pia_02-item_type_ident_code_3 = 'MP'.
              sis_cl_seg_pia_02-code_list_ident_code_3 = 'ZSF'.
            WHEN 'NT'.
              sis_cl_seg_pia_02-item_type_ident_code_3 = 'MP'.
              sis_cl_seg_pia_02-code_list_ident_code_3 = 'ZSF'.
            WHEN 'NZ'.
              sis_cl_seg_pia_02-item_type_ident_code_3 = 'MP'.
              sis_cl_seg_pia_02-code_list_ident_code_3 = 'ZNS'.
            WHEN 'VB'.
              sis_cl_seg_pia_02-item_type_ident_code_3 = ''.
              sis_cl_seg_pia_02-code_list_ident_code_3 = ''.
            WHEN 'VB'.
              sis_cl_seg_pia_02-item_type_ident_code_3 = ''.
              sis_cl_seg_pia_02-code_list_ident_code_3 = ''.
            WHEN 'WV'.
              sis_cl_seg_pia_02-item_type_ident_code_3 = ''.
              sis_cl_seg_pia_02-code_list_ident_code_3 = ''.
          ENDCASE.

          sis_cl_seg_pia_02-product_ident_code_qualifier = '5'.
          sis_cl_seg_pia_02-item_identifier_1 = ls_register_data-kennziff.
          sis_cl_seg_pia_02-item_type_ident_code_1 = 'SRW'.

          append_idoc_seg( sis_cl_seg_pia_02 ).

*CCI/CAV - Betrag Konzessionsabgabe

          IF  sis_cl_seg_tax_01-duty_tax_fee_category_code = 'TAS' OR
              sis_cl_seg_tax_01-duty_tax_fee_category_code = 'TSS' OR
              sis_cl_seg_tax_01-duty_tax_fee_category_code = 'TKS' OR
              sis_cl_seg_tax_01-duty_tax_fee_category_code = 'SAS' OR
              sis_cl_seg_tax_01-duty_tax_fee_category_code = 'KAS'.

            CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

* CCI - E09 - Betrag Konzessionsabgabe Z08 Betrag Konzessionsabgabe (Nicht- Schwachlast)
            IF sis_cl_seg_pia_02-code_list_ident_code_3 = 'ZNS'.
              sis_cl_seg_cci_03-characteristic_descr_code = 'Z08'.
            ELSEIF sis_cl_seg_pia_02-code_list_ident_code_3 = 'ZSF'.
              sis_cl_seg_cci_03-characteristic_descr_code = 'Z09'.
            ENDIF.
            append_idoc_seg( sis_cl_seg_cci_03 ).
* CAV - E06 -  Niederspannung)
            sis_cl_seg_cav_02-charac_value_descr_code = 'Z14'.
            sis_cl_seg_cav_02-characteristic_value_descr_1 = '0.0011'.
            append_idoc_seg( sis_cl_seg_cav_02 ).
          ENDIF.

*CCI/CAV - Vor- und Nachkommastellen bei Messwerten

* CCI - Z33 Vor- und Nachkommastellen des Zählwerkes
          IF NOT ls_register_data-stanzvor IS INITIAL AND
             NOT ls_register_data-stanznac IS INITIAL.

            CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

            sis_cl_seg_cci_03-class_type_code = '11'.
            sis_cl_seg_cci_03-characteristic_descr_code = 'Z33'.
            append_idoc_seg( sis_cl_seg_cci_03 ).
* CAV - E06 -  Niederspannung)
            sis_cl_seg_cav_02-characteristic_value_descr_1 =  ls_register_data-stanzvor.
            sis_cl_seg_cav_02-characteristic_value_descr_2 =  ls_register_data-stanznac.
            SHIFT sis_cl_seg_cav_02-characteristic_value_descr_1 LEFT DELETING LEADING '0'.
            SHIFT sis_cl_seg_cav_02-characteristic_value_descr_2 LEFT DELETING LEADING '0'.

            append_idoc_seg( sis_cl_seg_cav_02 ).
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD fill_sg8_z03.
* Device Master Data
    DATA:
      ls_device_data            TYPE v_eger,
      lv_meternr                TYPE eideswtmdmeternr,
      lv_identifier             TYPE p,
      lv_bdew_devicetype        TYPE zidex_value,
      lv_bdew_tarifanzahl       TYPE zidex_value,
      lv_bdew_energierichtung   TYPE zidex_value,
      lv_bdew_messwerterfassung TYPE zidex_value,
      lv_zwgruppe               TYPE zidex_value.

    CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

    IF ( gs_s_r_view-send_view = '01' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL )                "Antwort auf Anmeldung Netz -> Lief/Neu
    OR ( gs_s_r_view-send_view = '02' AND
         gs_s_r_view-reciever_view = '03' AND
         gs_s_r_view-msgstatus IS INITIAL )                     "Kündigung  Lief/Neu -> Lief/Alt
    OR ( gs_s_r_view-send_view = '03' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL )                 "Antwort auf Kündigung Lief/Alt -> Lief/Neu
    OR ( gs_s_r_view-send_view = '02' AND
         gs_s_r_view-reciever_view = '01' AND
         gs_s_r_view-msgstatus IS INITIAL )                      "Anmeldung  Lief/Neu -> Netz
    OR ( gs_s_r_view-send_view     = '01' AND
         gs_s_r_view-reciever_view = '02' AND
       ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
         x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
    OR ( gs_s_r_view-send_view     = '02' AND
         gs_s_r_view-reciever_view = '01' AND
       ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
         x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

      LOOP AT x_device_data INTO ls_device_data.

        IF  x_swtmsgpod-msgdata-meternr IS INITIAL.
          lv_meternr = ls_device_data-geraet.
        ELSE.
          lv_meternr = x_swtmsgpod-msgdata-meternr.
        ENDIF.

        ADD 1  TO lv_identifier.

* SEQ Z03 Zähleinrichtungsdaten setzen
        sis_cl_seg_seq_01-action_code = 'Z03'.
        sis_cl_seg_seq_01-sequence_position_identifier = lv_identifier.
        SHIFT sis_cl_seg_seq_01-sequence_position_identifier LEFT DELETING LEADING space.
        append_idoc_seg( sis_cl_seg_seq_01 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

* RFF - Referenz auf die Zählpunktbezeichnung
        sis_cl_seg_rff_10-reference_code_qualifier = 'AVE'.
        sis_cl_seg_rff_10-reference_identifier = x_swtmsgpod-msgdata-ext_ui.
        append_idoc_seg( sis_cl_seg_rff_10 ).

* CCI - E13 - Zähleinrichtung setzen
        sis_cl_seg_cci_03-characteristic_descr_code = gc_cci_device_type.
        append_idoc_seg( sis_cl_seg_cci_03 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

* alle CAV zu E13  setzen

* CAV - Zählertyp (Device Type)
        IF  ( gs_s_r_view-send_view = '01' AND
              gs_s_r_view-reciever_view = '02' AND
              gs_s_r_view-msgstatus IS NOT INITIAL )                  "Antwort auf Anmeldung Netz -> Lief/Neu
         OR ( gs_s_r_view-send_view     = '01' AND
              gs_s_r_view-reciever_view = '02' AND
            ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
              x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
         OR ( gs_s_r_view-send_view     = '02' AND
              gs_s_r_view-reciever_view = '01' AND
            ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
              x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

*   Call BADI /IDEXGE/DEVICETYPE_BADI for determination of device type,
*   which will be filled to idoc field SG10-CAV C889-1131 later on.

          lv_zwgruppe = ls_device_data-zwgruppe.

          zdms_cl_idexge_utility=>get_associate_value( EXPORTING  x_var_name     = 'GC_ZAEHLERTYP'
                                                                  x_value        =  lv_zwgruppe
                                                       IMPORTING  y_assoc_value  = lv_bdew_devicetype
                                                       EXCEPTIONS param_not_found = 1
                                                                  OTHERS         = 2 ).

          sis_cl_seg_cav_02-charac_value_descr_code = lv_bdew_devicetype.
          append_idoc_seg( sis_cl_seg_cav_02 ).
          CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.
        ENDIF.

* CAV - Identifikation/Nummer des Gerätes - Z30_
        sis_cl_seg_cav_02-charac_value_descr_code = 'Z30'.
        sis_cl_seg_cav_02-characteristic_value_descr_1 = lv_meternr.
        append_idoc_seg( sis_cl_seg_cav_02 ).
        CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

* CAV - Tarifanzahl - ETZ Eintarif / ZTZ Zweitarif / NTZ Mehrtarif
        IF ( gs_s_r_view-send_view = '01' AND
             gs_s_r_view-reciever_view = '02' AND
             gs_s_r_view-msgstatus IS NOT INITIAL )                  "Antwort auf Anmeldung Netz -> Lief/neu
        OR ( gs_s_r_view-send_view     = '01' AND
             gs_s_r_view-reciever_view = '02' AND
           ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
             x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
        OR ( gs_s_r_view-send_view     = '02' AND
             gs_s_r_view-reciever_view = '01' AND
           ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
             x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

          zdms_cl_idexge_utility=>get_associate_value( EXPORTING  x_var_name     = 'GC_TARIFANZAHL'
                                                                  x_value        =  lv_zwgruppe
                                                       IMPORTING  y_assoc_value  = lv_bdew_tarifanzahl
                                                       EXCEPTIONS param_not_found = 1
                                                                  OTHERS         = 2 ).

          sis_cl_seg_cav_02-charac_value_descr_code = lv_bdew_tarifanzahl.
          append_idoc_seg( sis_cl_seg_cav_02 ).
          CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

* CAV - Energierichtung - ERZ Einrichtungszähler / ZRZ Zweirichtungszähler

          zdms_cl_idexge_utility=>get_associate_value( EXPORTING  x_var_name     = 'GC_ENERGIERICHTUNG'
                                                                  x_value        =  lv_zwgruppe
                                                       IMPORTING  y_assoc_value  = lv_bdew_energierichtung
                                                       EXCEPTIONS param_not_found = 1
                                                                  OTHERS         = 2 ).

          sis_cl_seg_cav_02-charac_value_descr_code = lv_bdew_energierichtung.

          append_idoc_seg( sis_cl_seg_cav_02 ).
          CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

* CCI - E13 - Merkmal/Klassenidentifikation
          sis_cl_seg_cci_03-characteristic_descr_code = gc_cci_meter_read.
          append_idoc_seg( sis_cl_seg_cci_03 ).
          CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

* CAV -  Messwerterfassung Merkmalswert - AMR fernauslesbare Zähler / MMR manuell ausgelesene Zähler

          zdms_cl_idexge_utility=>get_associate_value( EXPORTING  x_var_name     = 'GC_MESSWERTERFASSUNG'
                                                                  x_value        =  lv_zwgruppe
                                                       IMPORTING  y_assoc_value  = lv_bdew_messwerterfassung
                                                       EXCEPTIONS param_not_found = 1
                                                                  OTHERS         = 2 ).

          sis_cl_seg_cav_02-charac_value_descr_code = lv_bdew_messwerterfassung.

          append_idoc_seg( sis_cl_seg_cav_02 ).
          CLEAR: sis_cl_seg_cci_03, sis_cl_seg_cav_02.

        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD fill_sg8_z04.
    IF ( gs_s_r_view-send_view = '01' AND
       gs_s_r_view-reciever_view = '02' AND
       gs_s_r_view-msgstatus IS NOT INITIAL )                "Antwort auf Anmeldung Netz -> Lief/Neu
  OR ( gs_s_r_view-send_view     = '01' AND
       gs_s_r_view-reciever_view = '02' AND
     ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
       x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
  OR ( gs_s_r_view-send_view     = '02' AND
       gs_s_r_view-reciever_view = '01' AND
     ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
       x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

    ENDIF.
  ENDMETHOD.


  METHOD fill_sg8_z05.
    IF ( gs_s_r_view-send_view = '01' AND
       gs_s_r_view-reciever_view = '02' AND
       gs_s_r_view-msgstatus IS NOT INITIAL )                "Antwort auf Anmeldung Netz -> Lief/Neu
  OR ( gs_s_r_view-send_view     = '01' AND
       gs_s_r_view-reciever_view = '02' AND
     ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
       x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
  OR ( gs_s_r_view-send_view     = '02' AND
       gs_s_r_view-reciever_view = '01' AND
     ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
       x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

    ENDIF.
  ENDMETHOD.


  METHOD fill_sg8_z06.
    IF ( gs_s_r_view-send_view = '01' AND
     gs_s_r_view-reciever_view = '02' AND
     gs_s_r_view-msgstatus IS NOT INITIAL )                "Antwort auf Anmeldung Netz -> Lief/Neu
OR ( gs_s_r_view-send_view     = '01' AND
     gs_s_r_view-reciever_view = '02' AND
   ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
     x_swtmsgpod-msgdata-transreason = 'Z38' ) )             "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
OR ( gs_s_r_view-send_view     = '02' AND
     gs_s_r_view-reciever_view = '01' AND
   ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
     x_swtmsgpod-msgdata-transreason = 'Z38' ) ).             "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

*    sis_cl_seg_seq_01-action_code = 'Z06'.
*    sis_cl_seg_seq_01-sequence_position_identifier = '1'.
*    append_idoc_seg( sis_cl_seg_seq_01 ).

    ENDIF.
  ENDMETHOD.


  METHOD fill_sg9_qty_cs_z09.
    DATA: lv_val1 TYPE eideswtmdprogyearcons VALUE 1,
          lv_val2 TYPE eideswtmdprogyearcons.

    CLEAR sis_cl_seg_qty_01.

    IF NOT x_swtmsgpod-msgdata-progyearcons IS INITIAL.

* handling for after comma points
      lv_val2 = x_swtmsgpod-msgdata-progyearcons.
      WRITE lv_val2 TO sis_cl_seg_qty_01-quantity NO-GROUPING LEFT-JUSTIFIED DECIMALS 0.
      IF sis_cl_seg_qty_01-quantity CA ','.
        REPLACE ',' WITH '.' INTO sis_cl_seg_qty_01-quantity.
      ENDIF.

      IF ( gs_s_r_view-send_view = '03' AND
           gs_s_r_view-reciever_view = '02' AND
           gs_s_r_view-msgstatus IS NOT INITIAL ).          "Antwort auf Kündigung Lief/Alt -> Lief/Neu

        sis_cl_seg_qty_01-quantity_type_code_qualifier = 'Z09'.   "Vorjahresverbrauch
        sis_cl_seg_qty_01-measurement_unit_code = cl_isu_datex_co=>co_qty_vdew_kwh.
        append_idoc_seg( sis_cl_seg_qty_01 ).

      ELSEIF ( gs_s_r_view-send_view = '01' AND
               gs_s_r_view-reciever_view = '02' AND
               gs_s_r_view-msgstatus IS NOT INITIAL )             "Antwort auf Anmeldung Netz -> Lief/Neu
          OR ( gs_s_r_view-send_view     = '01' AND
               gs_s_r_view-reciever_view = '02' AND
             ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
               x_swtmsgpod-msgdata-transreason = 'Z38' ) )        "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
          OR ( gs_s_r_view-send_view     = '02' AND
               gs_s_r_view-reciever_view = '01' AND
             ( x_swtmsgpod-msgdata-transreason = 'Z37' OR
               x_swtmsgpod-msgdata-transreason = 'Z38' ) ).       "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

        sis_cl_seg_qty_01-quantity_type_code_qualifier = '31'.   "Veranschlagte Jahresmenge gesamt
        sis_cl_seg_qty_01-measurement_unit_code = cl_isu_datex_co=>co_qty_vdew_kwh.
        append_idoc_seg( sis_cl_seg_qty_01 ).

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD fill_street_cs_cust.
    DATA: lv_house_number     TYPE  text35,
          lv_fill_housenumber TYPE c.
* end changes for V42a

    IF NOT x_po_flag IS INITIAL.

      IF x_eadrdat-po_box IS INITIAL.
        y_nad-street_no_or_po_box_ident_1 = x_street.
        IF strlen( x_street ) > 35 .
          y_nad-street_no_or_po_box_ident_2 = x_street+35.
        ENDIF.
* changes to V42a
*      y_nad-street3 = x_housenr.
*      y_nad-street4 = x_housenrext.
        lv_fill_housenumber = co_true.
* end changes for V42a
        y_nad-city_name    = x_city.
      ELSE.
        y_nad-street_no_or_po_box_ident_1 = text-001.
        y_nad-street_no_or_po_box_ident_2 = x_eadrdat-po_box.
        y_nad-city_name  = x_eadrdat-po_box_loc.
        CLEAR:
          y_nad-street_no_or_po_box_ident_3,
          y_nad-street_no_or_po_box_ident_4.
      ENDIF.

    ELSE.

      IF NOT x_street IS INITIAL.
        y_nad-street_no_or_po_box_ident_1  = x_street.
        IF strlen( x_street ) > 35 .
          y_nad-street_no_or_po_box_ident_2 = x_street+35.
        ENDIF.
* changes to V42a
*      y_nad-street3 = x_housenr.
*      y_nad-street4 = x_housenrext.
        lv_fill_housenumber = co_true.
* end changes for V42a
        y_nad-city_name    = x_city.
      ELSEIF NOT x_eadrdat-po_box IS INITIAL.
        y_nad-street_no_or_po_box_ident_1 = text-001.
        y_nad-street_no_or_po_box_ident_2 = x_eadrdat-po_box.
        y_nad-city_name    = x_eadrdat-po_box_loc.
        CLEAR:
          y_nad-street_no_or_po_box_ident_3,
          y_nad-street_no_or_po_box_ident_4.
      ENDIF.
    ENDIF.

* changes for V42a
* fill housenumber
    IF lv_fill_housenumber = co_true.
      lv_house_number = x_housenr.
      TRY.
          IF badi_address_out IS INITIAL.
            GET BADI badi_address_out.
          ENDIF.
          CALL BADI badi_address_out->map_sap_house_numb_to_message
            EXPORTING
              iv_mestyp_identifier        = co_message_type_utilmd
              iv_assocode                 = siv_assigned_code_vdew
              iv_house_number             = lv_house_number
              iv_house_number_suppl       = x_housenrext
            IMPORTING
              ev_mess_house_numb          = y_nad-street_no_or_po_box_ident_3
              ev_mess_house_numb_addition = y_nad-street_no_or_po_box_ident_4.

        CATCH cx_badi_not_implemented.                  "#EC NO_HANDLER
      ENDTRY.
    ENDIF.
* end changes for V42a

  ENDMETHOD.


  METHOD fill_unh.

    CLEAR sis_cl_seg_unh_01.

    sis_cl_seg_unh_01-message_reference_number = p_ref_nr.
    sis_cl_seg_unh_01-message_type                 = cl_isu_datex_co=>co_unh_vdew_msg_type_utilmd.
    sis_cl_seg_unh_01-message_version_number       = cl_isu_datex_co=>co_unh_vdew_msg_vers_utilmd_d.
    sis_cl_seg_unh_01-message_release_number       = '11A'.
    sis_cl_seg_unh_01-controlling_agency_coded_1   = cl_isu_datex_co=>co_unh_vdew_msg_contr_agency.
    sis_cl_seg_unh_01-association_assigned_code    = siv_assigned_code_vdew.

    append_idoc_seg( sis_cl_seg_unh_01 ).

  ENDMETHOD.


  METHOD get_lastprofil.
    DATA: ls_swtmsgpod TYPE eideswtmsgpod.
* Installation (Return of BAPI Call)
    DATA:
      ls_installation TYPE bapiisupodinstln,
      lt_installation TYPE bapiisupodinstln_t,
      wa_eanl         TYPE eanl,
      lv_value        TYPE zidex_value,
      lv_assoc_value  TYPE zidex_value.

* Messages (Return of BAPI Call)
    DATA:
      ls_bapi_return TYPE bapiret2,
      lt_bapi_return TYPE bapiret2tab.

    y_swtmsgpod = x_swtmsgpod.

    IF ( gs_s_r_view-send_view = '01' AND
         gs_s_r_view-reciever_view = '02' AND
         gs_s_r_view-msgstatus IS NOT INITIAL )                "Antwort auf Anmeldung Netz -> Lief/Neu
    OR ( gs_s_r_view-send_view = '02' AND
         gs_s_r_view-reciever_view = '01' AND
         gs_s_r_view-msgstatus IS INITIAL )                    "Anmeldung Lief/Neu -> Netz
    OR ( gs_s_r_view-send_view     = '01' AND
         gs_s_r_view-reciever_view = '02' AND
       ( gs_swtmsgpod-msgdata-transreason = 'Z37' OR
         gs_swtmsgpod-msgdata-transreason = 'Z38' ) )          "Anmeldung EoG Einzug und LW - Netz -> Lief/Neu  "20130410 Bromisch
    OR ( gs_s_r_view-send_view     = '02' AND
         gs_s_r_view-reciever_view = '01' AND
       ( gs_swtmsgpod-msgdata-transreason = 'Z37' OR
         gs_swtmsgpod-msgdata-transreason = 'Z38' ) ).           "Antwort auf Anmeldung EoG Einzug und LW - Lief/Neu -> Netz

*    if y_swtmsgpod-msgdata-metmethod is initial.
* wir haben nur SLP Anlagen und wenn nicht gesetzt dann setzen
      y_swtmsgpod-msgdata-metmethod = 'E02'.
*    endif.

      CASE y_swtmsgpod-msgdata-metmethod.

        WHEN cl_isu_datex_co=>co_cav_vdew_slp. "E02

*     Identify installation from the PoD
          CALL FUNCTION 'BAPI_ISUPOD_GETINSTALLATION'
            EXPORTING
              pointofdelivery = x_swtmsgpod-ext_ui
              keydate         = y_swtmsgpod-msgdata-moveindate
            TABLES
              installation    = lt_installation
              return          = lt_bapi_return.

          LOOP AT lt_installation INTO ls_installation.

            SELECT SINGLE * FROM eanl INTO wa_eanl
                                 WHERE anlage = ls_installation-installation.

            lv_value = wa_eanl-anlart.

            IF lv_value IS INITIAL.
              lv_value = '0002'.
            ENDIF.

            zdms_cl_idexge_utility=>get_associate_value( EXPORTING  x_var_name     = 'GC_LASTPROFIL'
                                                                    x_value        = lv_value
                                                         IMPORTING  y_assoc_value  = lv_assoc_value
                                                         EXCEPTIONS param_not_found = 1
                                                                    OTHERS         = 2 ).

            y_swtmsgpod-msgdata-profile =  lv_assoc_value.
*          call method zdms_cl_idexge_utility=>get_associate_value
*            exporting
*              x_var_name      = 'GC_LASTPROFIL'
*              x_value         = lv_value
*            importing
*              y_assoc_value   = lv_assoc_value
*            exceptions
*              param_not_found = 1
*              others          = 2.
*          if sy-subrc <> 0.
** Implement suitable error handling here
*          endif.
          ENDLOOP.
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD get_view_send_reciever.
    DATA: ls_eservprov_send     TYPE eservprov,
          ls_eservprov_reciever TYPE eservprov,
          ls_zsend_empf_view    TYPE zsend_empf_view,
          lv_msgstatus          TYPE regen-kennzx.

    IF NOT x_msgstatus IS INITIAL.
      lv_msgstatus = 'X'.
    ENDIF.

*Serviceart Sender ermitteln
    SELECT SINGLE * FROM eservprov INTO ls_eservprov_send
                WHERE serviceid = x_sender.

    SELECT SINGLE * FROM eservprov INTO ls_eservprov_reciever
                WHERE serviceid = x_reciever.

    SELECT SINGLE * FROM zsend_empf_view INTO ls_zsend_empf_view
                                WHERE send_sercode = ls_eservprov_send-service AND
                                      reciever_sercode = ls_eservprov_reciever-service AND
                                      category = x_category AND
                                      msgstatus = lv_msgstatus AND
                                      transreason = x_transreason.

    MOVE-CORRESPONDING ls_zsend_empf_view TO x_send_empf_view.

  ENDMETHOD.


  method ISU_UTILMD_IN_ANALYZE.

  data: lw_msg               type eideswtmsgpod,
        lw_swtmsgdata_all    type eideswtmsgdata.

  data: ls_sg4_ide           type edidd,
        lt_sg4_ide           type edidd_tt.

  data: lv_stop_processing   type char1,
        ls_msg_comment       type eideswtmsgdataco.

  data  ls_ide_1             type /idxgc/e1_ide_01.

* Process check
  call method check_process
    exporting
      it_idoc_data   = x_idoc_data-data
    importing
      ev_process_flg = lv_stop_processing
    exceptions
      error_occurred = 1
      others         = 2.

  if sy-subrc <> 0.

* Sending APERAK failed
    message id sy-msgid type sy-msgty number sy-msgno
               with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               raising error_occurred.
  endif.

  if lv_stop_processing is not initial.

* indicator to skip UTILMD processing in COMPR module
    ls_msg_comment-commentnum = 1.
    concatenate /idexge/cl_aperak_checks_cl=>gc_msgid_aperak
                /idexge/cl_aperak_checks_cl=>gc_msgno_aperak_err
                into ls_msg_comment-commenttag.
    insert ls_msg_comment into table lw_msg-msgdatacomment.
    insert lw_msg into table yt_swtmsgpod.
    return.
  endif.

* Initialize global variables
  me->init( ).
  clear gr_proc_in.

  lw_swtmsgdata_all-direction =
    if_isu_ide_switch_constants=>co_swtmsg_direction_in.
  lw_swtmsgdata_all-compartner = x_sender.

* Init object of idoc processing (has been created in event module)
  call method idoc_proc_get
    exporting
      p_docnum = x_idoc_data-control-docnum.

* Get una segment data
  call method proc_una.

  do." exit Mechanismus f¨¹r Fehlerhandling!
*   check if error occured
*    exit_err.
    if not g_error_in is initial. return. endif.

* Get UNH segment
    call method proc_unh_rew
      changing
        y_msg = lw_msg.

*   get BGM segment -> contains category of the message
    call method me->proc_bgm_cs
      importing
        y_category = lw_swtmsgdata_all-category.

    if sis_cl_seg_bgm_02-document_name_code = 'E35'.
      lw_swtmsgdata_all-zzcategory = sis_cl_seg_bgm_02-document_name_code.
    endif.

*   get msg data for each POD (transaction)
    call method me->get_segments_sg4_ide
      importing
        et_sg4_ide = lt_sg4_ide.
    if not g_error_in is initial. return. endif.

    loop at lt_sg4_ide into ls_sg4_ide.

      clear lw_msg.
      lw_msg-msgdata = lw_swtmsgdata_all.

*     Fill the new field for APERAK for each IDE segments
      ls_ide_1 = ls_sg4_ide-sdata.
      if ls_ide_1-object_type_code_qualifier
        = cl_isu_datex_co=>co_ide_vdew_qualifier_pod.
        lw_msg-msgdata-/idexge/t_id = ls_ide_1-object_identifier.
      endif.

      check g_error_in is initial.
      sis_cl_seg_ide_01 = ls_sg4_ide-sdata.

      if sis_cl_seg_ide_01-object_type_code_qualifier
        = cl_isu_datex_co=>co_ide_vdew_qualifier_pod.
        lw_msg-msgdata-idrefnr = sis_cl_seg_ide_01-object_identifier.
        lw_msg-msgdata-idrefnr = sis_cl_seg_ide_01-object_identifier.
      endif.

      call method me->proc_sg5_loc_cs
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          raising error_occurred.
      endif.

      call method me->proc_sg4_dtm_cs
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   raising error_occurred.
      endif.

      call method me->proc_sg4_sts_cs
        exporting
          x_sender       = x_sender
          x_receiver     = x_receiver
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          raising error_occurred.
      endif.

      call method me->proc_sg4_tax_cs
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
      endif.

      call method me->proc_sg4_ftx_cs
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          raising error_occurred.
      endif.

      call method me->proc_sg4_agr
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
      endif.

      call method me->proc_sg6_rff_cs
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          raising error_occurred.
      endif.

      call method me->proc_sg7_cci_cav_cs
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          raising error_occurred.
      endif.

      call method me->proc_sg8_seq_cs
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          raising error_occurred.
      endif.


      call method me->proc_sg12_nad_cs
        exporting
          x_segnum       = ls_sg4_ide-segnum
        changing
          y_msg          = lw_msg
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          raising error_occurred.
      endif.

*if no settlement data in IDoc
*          ( e.g. Request message in Backup Supply )
      if lw_msg-msgdata-settlresp is initial and
         lw_swtmsgdata_all-category
           = cl_isu_datex_co=>co_bgm_vdew_enroll.

        call method get_settl_from_int_ui_cs
          exporting
            is_swtmsgpod   = lw_msg
            iv_receiver    = x_receiver
          importing
            ev_settlresp   = lw_msg-msgdata-settlresp
          exceptions
            error_occurred = 1
            not_found      = 2
            others         = 3.
      endif.

      lw_msg-msgdata-zzliefalt = lw_msg-msgdata-compsupplier.

      append lw_msg to yt_swtmsgpod.

    endloop.                                                "ide_1
    exit.
  enddo." exit Mechanismus fuer Fehlerhandling!

*            setzen des Alten Lieferanten in den Nachrichten
*            daten zur Protokollierung in den Wechselbeleg-Aktivitäten
  lw_msg-msgdata-zzliefalt = lw_msg-msgdata-/idexge/extid_s.

* check error
  call method exit_err_exception
    exceptions
      error_occurred = 1
      others         = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
  endif.

  try.
      if gref_exit_utilmd_in is initial.
        get badi gref_exit_utilmd_in.
      endif.
      call badi gref_exit_utilmd_in->post_inbound_change
        exporting
          is_idoc_control = x_idoc_data-control
          it_idoc_data    = x_idoc_data-data[].
    catch cx_badi_not_implemented.                      "#EC NO_HANDLER
  endtry.

  endmethod.


  method ISU_UTILMD_OUT_BUILD.
  constants : co_swt_view_dist type eideswtview value '01'.

  data: lv_ref_nr          type char14,
        l_settlunit        type eedmuisettlunit,
        ls_settlunit       type eedmsettlunit,
        lt_settlunit       type t_eedmsettlunit,
        l_edmsettlview_out type e_edmsettlview,
        l_intcode          type intcode,
        lv_settlunit       type e_edmsettlunit,
        lv_swt_view        type eideswtview,
        lv_send_view       type char1,
        lv_rec_view        type char1.

  data: lv_value type char35,
        lv_flag  type char1.

  data: lv_gas_press_lvl type /idexgg/ext_druckstuf,
        lv_gas_quality   type /idexgg/gas_qual,
        lv_ext_ui        type ext_ui.


  data: l_swtmsgpod   type eideswtmsgpod.

  data:   ls_eideswtdoc type eideswtdoc,
          ls_eideswtmsgdata type eideswtmsgdata,
          ls_swtmsgpod type  eideswtmsgpod,
          lv_not_running type regen-kennzx.

  if x_swtmsgpod-msgdata-zzcategory is initial.
    call method me->get_view_send_reciever
      exporting
        x_sender         = x_sender
        x_reciever       = x_receiver
        x_category       = x_swtmsgpod-msgdata-category
        x_msgstatus      = x_swtmsgpod-msgdata-msgstatus
        x_transreason    = x_swtmsgpod-msgdata-transreason
      importing
        x_send_empf_view = gs_s_r_view.
  else.
    call method me->get_view_send_reciever
      exporting
        x_sender         = x_sender
        x_reciever       = x_receiver
        x_category       = x_swtmsgpod-msgdata-zzcategory
        x_msgstatus      = x_swtmsgpod-msgdata-msgstatus
        x_transreason    = x_swtmsgpod-msgdata-transreason
      importing
        x_send_empf_view = gs_s_r_view.
  endif.


* Switch Message Category
* which will be filled to NAME field of BGM idoc segment
* (probably NOT equivalent to X_SWTMSGPOD-MSGDATA-CATEGORY)
  data: lv_switch_msgcat    type eideswtmdcat.

* Data of settlement unit assigned to the PoD
  data: ls_settlunit_data   type eedmsettlunit_db_data.

  me->init_out( ).

  gs_swtmsgpod = x_swtmsgpod.
  l_swtmsgpod = x_swtmsgpod.

  if not x_swtmsgpod-msgdata-ext_ui is initial.
    lv_ext_ui =  x_swtmsgpod-msgdata-ext_ui.
  elseif not x_swtmsgpod-ext_ui is initial.
    lv_ext_ui =  x_swtmsgpod-msgdata-ext_ui.
  endif.

  if  x_swtmsgpod-int_ui is initial and
      not lv_ext_ui is initial and
      ( x_swtmsgpod-msgdata-transreason = 'Z37' or
        x_swtmsgpod-msgdata-transreason = 'Z38' ) and
      gr_utility->gc_mandt_role = 'LIEF'.

    select single int_ui from euitrans into l_swtmsgpod-int_ui
      where ext_ui = lv_ext_ui.

    l_swtmsgpod-ext_ui = lv_ext_ui.
    l_swtmsgpod-msgdata-ext_ui = lv_ext_ui.

    if  x_swtmsgpod-msgdata-msgstatus = 'E14'.
      select single * from eideswtmsgdata into ls_eideswtmsgdata
                           where switchnum = l_swtmsgpod-msgdata-switchnum
                             and msgdatanum = x_msgdatanum_req.

      if sy-subrc = 0.
        select single externalid from eservprov into l_swtmsgpod-msgdata-settlresp
          where serviceid = x_sender.
        endif.
      endif.
    endif.


    call method get_division_category_2
      exporting
        x_switchdoc = l_swtmsgpod-msgdata-switchnum
      changing
        y_divcat    = gv_divcat.

* init global variables
    me->init( ).
    clear gr_proc_in.

* get reference number
    call method get_reference_number
      importing
        xy_ref_nr      = lv_ref_nr
      exceptions
        error_occurred = 1
        others         = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    else.
      siv_refno = lv_ref_nr.
    endif.


* Breakpoint für SM50
    zdms_enwg_wf=>break_sm50( 'ISU_UTILMD_OUT_BUILD' ).

    select single * from eideswtdoc into ls_eideswtdoc
                    where switchnum = x_switchnum.

    gs_eideswtdoc = ls_eideswtdoc.

    if gr_utility->gc_mandt_role = 'NETZ'.
      gv_reciever = l_swtmsgpod-msgdata-compartner.
    elseif gr_utility->gc_mandt_role = 'LIEF'.
      if ls_eideswtdoc-swtview = '02'. "Neuer LF
        gv_reciever = ls_eideswtdoc-service_prov_new.
      elseif ls_eideswtdoc-swtview = '03'. "Alter LF
        gv_reciever = ls_eideswtdoc-service_prov_old.
      endif.
    endif.

    if gs_s_r_view-send_view = '01' and
       gs_s_r_view-reciever_view = '02' and
       ( gs_s_r_view-transreason = 'E01' or
       gs_s_r_view-transreason = 'E03' ).    "Antwort auf Anmeldung Netz -> Lief

*Nachrichtendaten zum Vergleich von der Datenbank nachlesen und
      select single * from eideswtmsgdata into ls_eideswtmsgdata
                           where switchnum = l_swtmsgpod-msgdata-switchnum
                             and msgdatanum = l_swtmsgpod-msgdata-msgdatanum.

      ls_swtmsgpod = l_swtmsgpod.
      ls_swtmsgpod-msgdata = ls_eideswtmsgdata.

      korrektur_outbound( exporting ix_swtmsgpod = ls_swtmsgpod
                                    x_switchnum  = x_switchnum
                          importing ex_swtmsgpod = l_swtmsgpod ).

    endif.


*Zählverfahren setzen
    if ( gs_s_r_view-send_view = '02' and
      gs_s_r_view-reciever_view = '01' and
      gs_s_r_view-msgstatus is initial ).                    "Anmeldung    Lief/Neu -> Netz
      l_swtmsgpod-msgdata-metmethod = 'E02'. "SLP
    endif.

*---------------------------Begin of filling IDoc Head--------------------
* UNA, /IDEXGE/E1VDEWUNA_1
    fill_una( ).

* UNB, /ISIDEX/E1VDEWUNB_1
    call method fill_unb
      exporting
        x_ref_nr       = lv_ref_nr
        x_sender       = x_sender
        x_receiver     = x_receiver
        y_idoc_data    = y_idoc_data
      exceptions
        error_occurred = 1
        others         = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.

* UNA and UNB are service segments, they should not be included in the segment count
    clear siv_seg_count.

* UNH,/ISIDEX/E1VDEWUNH_1
    call method fill_unh
      exporting
        p_ref_nr = lv_ref_nr.

* BGM, /ISIDEX/E1VDEWBGM_1
    call method fill_bgm_cs
      exporting
        x_swtmsgpod     = l_swtmsgpod
        x_ref_nr        = lv_ref_nr
        x_sender        = x_sender
        x_receiver      = x_receiver
      importing
        y_switch_msgcat = lv_switch_msgcat
      exceptions
        error_occurred  = 1
        others          = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              raising error_occurred.
    endif.

* DTM, /ISIDEX/E1VDEWDTM_1, date/time/period
    call method fill_dtm.
*---------------------------End of filling IDoc Head----------------------

* ERP2007 Support of codelist of external Service Provider ID
****** Set control data earlier than before
****** because we need it in the NAD segment creation
    call method fill_control_data
      exporting
        p_receiver     = x_receiver
      importing
        y_idoc_control = sis_idoc_control
      exceptions
        error_occurred = 1.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                 raising error_occurred.
    endif.

* SG2-NAD: /IDEXGE/E1VDEWNAD_7
* Service provider sender
    call method me->fill_sg2_nad
      exporting
        iv_provider    = x_sender
        iv_action      = co_nad_sender
      exceptions
        error_occurred = 1
        others         = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.
    sis_cl_seg_nad_01_sender = sis_cl_seg_nad_01.

* SG3-CTA-COM:
    call method me->fill_sg3_cta_com
      exporting
        iv_sender   = x_sender
        iv_receiver = x_receiver.

* SG2-NAD:/IDEXGE/E1VDEWNAD_7
* Service provider receiver
    call method me->fill_sg2_nad
      exporting
        iv_provider    = x_receiver
        iv_action      = co_nad_receiver
      exceptions
        error_occurred = 1
        others         = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.
    sis_cl_seg_nad_01_receiver = sis_cl_seg_nad_01.

* SG4-IDE: /ISIDEX/E1VDEWIDE_1
* identity
    call method fill_sg4_ide_cs
      exporting
        x_swtmsgpod = l_swtmsgpod.

* SG4-DTM: /ISIDEX/E1VDEWDTM_3,
* date/time/period
    call method fill_sg4_dtm_cs
      exporting
        x_swtmsgpod     = l_swtmsgpod
        x_switch_msgcat = lv_switch_msgcat.

*<<<<<<<ver4.2a
    call method me->fill_sg4_dtm_cs_mrd
      exporting
        is_swtmsgpod     = l_swtmsgpod
        iv_sender        = x_sender
        iv_receiver      = x_receiver
        iv_switch_msgcat = lv_switch_msgcat
      exceptions
        error_occurred   = 1
        others           = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.

    call method me->fill_sg4_dtm_cs_bils
      exporting
        is_swtmsgpod     = l_swtmsgpod
        iv_sender        = x_sender
        iv_receiver      = x_receiver
        iv_switch_msgcat = lv_switch_msgcat
      exceptions
        error_occurred   = 1
        others           = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.
*>>>>>>>ver4.2a

* DTM, /IDEXGE/E1VDEWSTS_3, status
    call method fill_sg4_sts_cs
      exporting
        x_swtmsgpod     = l_swtmsgpod
        x_switch_msgcat = lv_switch_msgcat
        x_receiver      = x_receiver.
* TAX, /ISIDEX/E1VDEWTAX_1, Duty/Tax/Fee Details
    call method fill_sg4_tax
      exporting
        p_ext_ui  = l_swtmsgpod-ext_ui
        p_keydate = l_swtmsgpod-msgdata-msgdate.

* FTX, /IDEXGE/E1VDEWFTX_3, free text
    call method fill_sg4_ftx_cs
      exporting
        x_swtmsgpod = l_swtmsgpod.

* AGR, /ISIDEX/E1VDEWAGR_1, agreement identification
    call method fill_sg4_agr
      exporting
        x_swtmsgpod = l_swtmsgpod.

* AGR, /ISIDEX/E1VDEWAGR_1, Netznutzungsvertrag
    call method fill_sg4_agr_inv
      exporting
        x_swtmsgpod = l_swtmsgpod.

* LOC, /IDEXGE/E1VDEWLOC_4, location       Zählpunktsbezeichnung
    call method fill_sg5_loc_cs_a
      exporting
        x_swtmsgpod = l_swtmsgpod.

* Find switch view.
    call method find_swt_view
      exporting
        p_switchnum    = x_switchnum
      importing
        p_swt_view     = lv_swt_view
      exceptions
        error_occurred = 1
        others         = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.

    if ( gs_s_r_view-send_view = '01' and
         gs_s_r_view-reciever_view = '02' and
         gs_s_r_view-msgstatus is initial and
       ( l_swtmsgpod-msgdata-transreason = 'Z26' or
         l_swtmsgpod-msgdata-transreason = 'ZC8' or
         l_swtmsgpod-msgdata-transreason = 'ZC9' ) )        "E44/Z26 Informationsmeldung NB->Lf neu
    or ( gs_s_r_view-send_view = '01' and
         gs_s_r_view-reciever_view = '03' and
         gs_s_r_view-msgstatus is initial )
    or ( gs_s_r_view-send_view = '03' and
         gs_s_r_view-reciever_view = '01' ).       "E02 Abmeldeanfrage NB->LF und Antwort LF->NB
    else.
*SG5
* LOC, /IDEXGE/E1VDEWLOC_4, settlmentunit
* The segment will filled and proccessed in some cases with different prerequisites
* 1 In case of a drop message
* 1a When the receiver is not a supplier, we will found the settlement unit for distributor
* 2. In case of enroll message
* 2a Check for Backup Supplier and Distributor-view
* 2b Any other Cases of enroll message and no Backup Supplier
* 1. Drop Message
      if l_swtmsgpod-msgdata-category = cl_isu_datex_co=>co_bgm_vdew_drop.

**  There is communication between suppliers in change of supplier only.
**  In this case, the settlement-area-relevant information are not required
**  in UTILMD messages.
        data:
          lv_servtyp_sender   type intcode,
          lv_servtyp_receiver type intcode.

*   Determine service category for the message-sending service provider
        call function 'ISU_GET_SERVICETYPE_PROVIDER'
          exporting
            x_service_prov = x_sender
          importing
            y_service_type = lv_servtyp_sender
          exceptions
            general_fault  = 1
            others         = 2.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
        endif.
*   Determine service category for the message-receiving service provider
        call function 'ISU_GET_SERVICETYPE_PROVIDER'
          exporting
            x_service_prov = x_receiver
          importing
            y_service_type = lv_servtyp_receiver
          exceptions
            general_fault  = 1
            others         = 2.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
        endif.

        if ( lv_servtyp_sender <> co_servrole_supplier or lv_servtyp_receiver <> co_servrole_supplier ) and
           ( l_swtmsgpod-msgdata-transreason <> if_isu_ide_switch_constants=>co_transreason_cancel ) and
           ( l_swtmsgpod-msgdata-msgstatus is initial ). "ver4.2a: LOC(237/107) not created in resp. to termination

          call method get_settlview_out
            exporting
              p_sender       = x_sender
              p_receiver     = x_receiver
            importing
              p_edmsettlview = l_edmsettlview_out
            exceptions
              error_occurred = 1
              others         = 2.
          if sy-subrc <> 0.
            message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
          endif.

          if ls_eideswtdoc-swtview <> '03'.

            call method get_settlview_for_pod
              exporting
                p_swtmsgpod        = l_swtmsgpod
                p_edmsettlview_out = l_edmsettlview_out
              importing
                p_settlview        = l_settlunit.

            call method fill_sg5_loc_cs_b                       "237 - Bilanzkreisbezeichnung & 231 - Regelzone
              exporting
                p_swtmsgpod        = l_swtmsgpod
                p_edmsettlview_out = l_edmsettlview_out
                p_settlunit        = l_settlunit
                p_swtview          = lv_swt_view
                p_sender           = x_sender
              importing
                es_settlunit_data  = ls_settlunit_data
              exceptions
                error_occurred     = 1
                others             = 2.
            if sy-subrc <> 0.
              message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
            endif.

            call method me->fill_sg5_loc_cs_c                       "107 - Bilanzierungsgebiet
              exporting
                is_swtmsgpod         = l_swtmsgpod
                iv_division_category = gv_divcat
              exceptions
                error_occurred       = 1
                others               = 2.
            if sy-subrc <> 0.
              message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
            endif.
          endif.
        endif. "+20130314 Bromisch´

* 2 ENROLL Message
      else.
*----------------

*   No processing for Reversal
        if l_swtmsgpod-msgdata-transreason <>
                    if_isu_ide_switch_constants=>co_transreason_cancel.

*   2a Check for Backup Supplier and Distributor View
          if l_swtmsgpod-msgdata-transreason eq if_isu_ide_switch_constants=>co_transreason_backupspl
            or l_swtmsgpod-msgdata-transreason eq co_transreason_bs_cust_in
            or l_swtmsgpod-msgdata-transreason eq co_transreason_bs_new_inst
            or l_swtmsgpod-msgdata-transreason eq co_transreason_bs_cs_fail
            or l_swtmsgpod-msgdata-transreason eq co_transreason_bs_temp_conn.
*     Only find settlement unit in the response at Backup Supplier side.
            if not sis_cl_seg_bgm_01-document_name_code = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp.
              call method get_settlview_out
                exporting
                  p_sender       = x_sender
                  p_receiver     = x_receiver
                importing
                  p_edmsettlview = l_edmsettlview_out
                exceptions
                  error_occurred = 1
                  others         = 2.
              if sy-subrc <> 0.
                message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
              endif.

*          determination of settlement unit via service provider agreement (IDEX-GG)
              call method get_settlunit_via_spa
                exporting
                  p_sender       = x_sender
                  p_receiver     = x_receiver
                  p_pod          = l_swtmsgpod-int_ui
                  p_switchdoc    = x_switchnum
                  p_date         = l_swtmsgpod-msgdata-msgdate
                  p_process      = cl_isu_ide_deregprocess=>if_deregprocess~co_deregproc_backupspl
                  p_structure    = /idexgg/cl_isu_co=>co_gas_dereg_structure
                  p_spartyp      = gv_divcat
                importing
                  p_settlunit    = lv_settlunit
                exceptions
                  error_occurred = 1
                  others         = 2.
              if sy-subrc <> 0.
                message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
              endif.

              if lv_settlunit is initial.
*           no settlement unit found - process the old coding
                call method get_settlview_for_pod
                  exporting
                    p_swtmsgpod        = l_swtmsgpod
                    p_edmsettlview_out = l_edmsettlview_out
                  importing
                    p_settlview        = l_settlunit.
              endif.

              call method fill_sg5_loc_cs_b           "237 - Bilanzkreisbezeichnung & 231 - Regelzone
                exporting
                  p_swtmsgpod        = l_swtmsgpod
                  p_edmsettlview_out = l_edmsettlview_out
                  p_settlunit        = l_settlunit
                  p_swtview          = lv_swt_view
                  p_sender           = x_sender
                importing
                  es_settlunit_data  = ls_settlunit_data
                exceptions
                  error_occurred     = 1
                  others             = 2.
              if sy-subrc <> 0.
                message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
              endif.

              call method me->fill_sg5_loc_cs_c      " 107 - Bilanzierungsgebiet
                exporting
                  is_swtmsgpod         = l_swtmsgpod
                  iv_division_category = gv_divcat
                exceptions
                  error_occurred       = 1
                  others               = 2.
              if sy-subrc <> 0.
                message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
              endif.
            endif.
*  --Begin to add for reversal registration
*      elseif l_swtmsgpod-msgdata-transreason EQ if_isu_ide_switch_constants=>CO_TRANSREASON_CANCEL.
*         g_loc_4-place_qualifier = co_loc_settl_unit.
*         g_loc_4-place_id        = l_swtmsgpod-msgdata-settlresp.
*         g_loc_4-code_list_responsible_agency_1 = co_loc_etso.
*         mac_seg_append co_sgm_loc_4 g_loc_4.
*  --End of add for reversal registration
          else.

            if l_swtmsgpod-msgdata-category <> 'E35'.

*   2b this is no drop message, so settlement unit will be send
              call method get_settlview_out
                exporting
                  p_sender       = x_sender
                  p_receiver     = x_receiver
                importing
                  p_edmsettlview = l_edmsettlview_out
                exceptions
                  error_occurred = 1
                  others         = 2.
              if sy-subrc <> 0.
                message id sy-msgid type sy-msgty number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
              endif.
              if l_swtmsgpod-msgdata-msgstatus is initial.
                " Request, get settlement unit from PoD.
                call method get_settlview_for_pod
                  exporting
                    p_swtmsgpod        = l_swtmsgpod
                    p_edmsettlview_out = l_edmsettlview_out
                  importing
                    p_settlview        = l_settlunit.
              else. " Response, get settlement unit from the receiver(supplier).
                call method cl_isu_edm_settlunit=>find_settlunit_supplier
                  exporting
                    x_servprov   = x_receiver
                    x_settlview  = l_edmsettlview_out
                    x_datefrom   = l_swtmsgpod-msgdata-moveindate
                    x_dateto     = l_swtmsgpod-msgdata-moveindate
                  importing
                    yt_settlunit = lt_settlunit
                  exceptions
                    not_found    = 1
                    others       = 2.
                if sy-subrc = 0.
                  read table lt_settlunit into ls_settlunit with key
                                                            settltransco = x_sender
                                                            spartyp = gv_divcat.
                  move-corresponding ls_settlunit to l_settlunit.
                else.
                  message id sy-msgid type sy-msgty number sy-msgno
                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.                                              .
                endif.

              endif.

              if gv_divcat eq /idexgg/cl_isu_co=>co_spartyp_gas
              and /idexgg/cl_isu_cust_select=>select_db_settings_active( ) = /idexgg/cl_isu_co=>co_idexgg_active.
*         For Gas we determine the external settlement ID from the market area and
*         not from the PoD
                call method fill_sg5_loc_cs_idexgg             "237 - Bilanzkreisbezeichnung
                  exporting
                    p_swtmsgpod        = l_swtmsgpod
                    p_edmsettlview_out = l_edmsettlview_out
                    p_settlunit        = l_settlunit
                    p_swtview          = lv_swt_view
                    p_sender           = x_sender
                    p_receiver         = x_receiver
                    p_divcat           = gv_divcat
                  exceptions
                    error_occurred     = 1
                    others             = 2.
                if sy-subrc <> 0.
                  message id sy-msgid type sy-msgty number sy-msgno
                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
                endif.

              elseif ( not sis_cl_seg_bgm_01-document_name_code = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp ).
                call method fill_sg5_loc_cs_b             "237 - Bilanzkreisbezeichnung & 231 - Regelzone
                  exporting
                    p_swtmsgpod        = l_swtmsgpod
                    p_edmsettlview_out = l_edmsettlview_out
                    p_settlunit        = l_settlunit
                    p_swtview          = lv_swt_view
                    p_sender           = x_sender
                  importing
                    es_settlunit_data  = ls_settlunit_data
                  exceptions
                    error_occurred     = 1
                    others             = 2.
                if sy-subrc <> 0.
                  message id sy-msgid type sy-msgty number sy-msgno
                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
                endif.
              endif.

*       for response to registration only
              if not l_swtmsgpod-msgdata-msgstatus is initial.
                call method me->fill_sg5_loc_cs_c                " - 107 - Bilanzierungsgebiet
                  exporting
                    is_swtmsgpod         = l_swtmsgpod
                    iv_division_category = gv_divcat
                  exceptions
                    error_occurred       = 1
                    others               = 2.
                if sy-subrc <> 0.
                  message id sy-msgid type sy-msgty number sy-msgno
                    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
                endif.
              endif.
            endif.  "+ 20130314 Bromisch Ende nur bei E35 senden
          endif.
        endif.    "IF trans.reason is not E05 (Reversal)
      endif.

* Add the temperature measurement point
      if not sis_cl_seg_bgm_01-document_name_code = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp.
*    CALL METHOD fill_sg5_loc_cs_d
*      CHANGING
*        x_swtmsgpod = l_swtmsgpod.

* Legal change UTILMD 4.2A
        call method fill_sg5_loc_cs_d_new             "Z02 / Z03 Temperaturmessstelle/Klimazone
          exporting
            iv_sender      = x_sender
            iv_receiver    = x_receiver
          changing
            x_swtmsgpod    = l_swtmsgpod
          exceptions
            error_occurred = 1
            others         = 2.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
        endif.
      endif.
    endif.

*SG6

    call method fill_sg6_rff_cs_b
      exporting
        x_sender         = x_sender
        x_swtmsgpod      = l_swtmsgpod
        x_msgdatanum_req = x_msgdatanum_req
        x_msgdatanum_res = x_msgdatanum_res
        x_switchnum      = x_switchnum
      exceptions
        error_occurred   = 1
        others           = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.

    call method fill_sg6_rff_cs_cust
      exporting
        x_swtmsgpod    = l_swtmsgpod
      exceptions
        error_occurred = 1
        others         = 2.

    if gv_divcat = /idexgg/cl_isu_co=>co_spartyp_gas
     and /idexgg/cl_isu_cust_select=>select_db_settings_active( ) = /idexgg/cl_isu_co=>co_idexgg_active.
      call method fill_sg6_rff_cs_idexgg
        exporting
          x_swtmsgpod      = l_swtmsgpod
          x_msgdatanum_req = x_msgdatanum_req
          x_msgdatanum_res = x_msgdatanum_res
          x_switchnum      = x_switchnum.
    endif.

* SG7
    if l_swtmsgpod-msgdata-profile is initial.
      call method get_lastprofil                                "Lastprofil ermitteln
        exporting
          x_swtmsgpod = l_swtmsgpod
        importing
          y_swtmsgpod = l_swtmsgpod.
    endif.

    if not l_swtmsgpod-msgdata-profile is initial.

* CCI, /IDEXGE/E1VDEWCCI_3, characteristics/class id
      call method fill_sg7_cci_cs_d                                 "Lastprofil
        exporting
          x_swtmsgpod = l_swtmsgpod.

      call method fill_sg7_cav_cs_d
        exporting
          x_swtmsgpod = l_swtmsgpod.

    endif.

* CCI, /IDEXGE/E1VDEWCCI_3, characteristics/class id               "Zählverfahren
    call method fill_sg7_cci_cs_c
      exporting
        x_swtmsgpod = l_swtmsgpod.

* CAV, /ISIDEX/E1VDEWCAV_1, characteristic value
    call method fill_sg7_cav_cs_c
      exporting
        x_swtmsgpod = l_swtmsgpod.

    call method fill_sg7_cci_cav_cust                             " - Y01 - Druckebene der Entnahme
      exporting
        x_swtmsgpod   = l_swtmsgpod.

    if l_swtmsgpod-msgdata-category = cl_isu_datex_co=>co_bgm_vdew_enroll.  "Gruppenzuordnung (nach EnWG) Z15/Z18
      call method fill_sg7_cci_cs_e
        exporting
          p_int_ui = l_swtmsgpod-int_ui
          p_date   = l_swtmsgpod-msgdata-moveindate.
    elseif l_swtmsgpod-msgdata-category = cl_isu_datex_co=>co_bgm_vdew_drop.
      if not ( gs_s_r_view-send_view = '03' and
               gs_s_r_view-reciever_view = '02' and
               gs_s_r_view-msgstatus is not initial ) and                  "Antwort auf Kündigung Lief/Alt -> Lief/Neu
         not ( gs_s_r_view-send_view = '03' and
               gs_s_r_view-reciever_view = '01' and
               gs_s_r_view-msgstatus is initial ) and                      "Abmeldung  Lief/Alt -> Netz
         not ( gs_s_r_view-send_view = '01' and
               gs_s_r_view-reciever_view = '03' and
               gs_s_r_view-msgstatus is not initial )                      "Antwort auf Abmeldung Netz -> Lief/Alt
        and  not ( gs_s_r_view-send_view = '01' and
                   gs_s_r_view-reciever_view = '03' and
                   gs_s_r_view-msgstatus is initial )
         and not ( gs_s_r_view-send_view = '03' and
                    gs_s_r_view-reciever_view = '01' ).                     "Abmeldeanfrage NB->LF und Antwort LF->NB
        call method fill_sg7_cci_cs_e
          exporting
            p_int_ui = l_swtmsgpod-int_ui
            p_date   = l_swtmsgpod-msgdata-moveoutdate.
      endif. "+21030315 Bromisch
    endif.

    call method fill_sg7_cci_cs_f                                       "Konzessionsabgabe HT
      exporting
        p_ext_ui  = l_swtmsgpod-ext_ui
        p_keydate = l_swtmsgpod-msgdata-msgdate
        p_type    = co_concession_fees_group_ht
      importing
        p_value   = lv_value
        p_flag    = lv_flag.

    call method fill_sg7_cav_cs_f
      exporting
        p_flag  = lv_flag
        p_value = lv_value.

    call method fill_sg7_cci_cs_f                                      "Konzessionsabgabe NT
      exporting
        p_ext_ui  = l_swtmsgpod-ext_ui
        p_keydate = l_swtmsgpod-msgdata-msgdate
        p_type    = co_concession_fees_group_nt
      importing
        p_value   = lv_value
        p_flag    = lv_flag.

    call method fill_sg7_cav_cs_f                                     "Konzessionsabgabe Pauschele Z14
      exporting
        p_flag  = lv_flag
        p_value = lv_value.

    if gv_divcat eq /idexgg/cl_isu_co=>co_spartyp_gas and
       /idexgg/cl_isu_cust_select=>select_db_settings_active( ) = /idexgg/cl_isu_co=>co_idexgg_active.
*   Add Gas pressure level and Gas quality
*   Should only be sent if Switch view is New Supplier or Distributor
      if lv_swt_view = if_isu_ide_switch_constants=>co_swtview_distributor or
         lv_swt_view = if_isu_ide_switch_constants=>co_swtview_new_supplier.

        call method fill_sg7_cci_cs_g
          exporting
            x_swtmsgpod     = l_swtmsgpod
          importing
            y_ext_press_lvl = lv_gas_press_lvl.

        call method fill_sg7_cav_cs_g
          exporting
            x_ext_press_lvl = lv_gas_press_lvl.

        call method fill_sg7_cci_cs_h
          exporting
            x_swtmsgpod   = l_swtmsgpod
          importing
            y_gas_quality = lv_gas_quality.

        call method fill_sg7_cav_cs_h
          exporting
            x_gas_quality = lv_gas_quality.
      endif.
    endif.

* SG8
* SEQ, /ISIDEX/E1VDEWSEQ_1, sequence details
    if not sis_cl_seg_bgm_01-document_name_code = if_isu_ide_switch_constants=>co_swtmdcat_supplier_comp.

*    CALL METHOD fill_sg8_seq.
      call method fill_sg8_seq_cust
        exporting
          x_swtmsgpod      = l_swtmsgpod
          x_msgdatanum_req = x_msgdatanum_req.
    endif.

* SG12
* NAD, /IDEXGE/E1VDEWNAD_8, name and address

    if     ( gs_s_r_view-send_view     = '03' and           "Abmeldung  Lief/Alt -> Netz
             gs_s_r_view-reciever_view = '01' and
             gs_s_r_view-msgstatus     is initial )
*          gs_s_r_view-category = 'E02' ).                "+20130321 Nagel-Daniel  Antw. auf Abme-Anfrage LF->NB
       or  ( gs_s_r_view-send_view     = '03' and           "+20130321 Nagel-Daniel  Antw. auf Abme-Anfrage LF->NB
             gs_s_r_view-reciever_view = '01' and
             gs_s_r_view-msgstatus     is not initial )
       or  ( gs_s_r_view-send_view     = '01' and           "+20130409 Bromisch Beendigung der Zuordnung  NB->LFa
             gs_s_r_view-reciever_view = '03' and
             gs_s_r_view-transreason   = 'ZC8' )
       or  ( gs_s_r_view-send_view     = '01' and           "+20130327 Nagel-Daniel  Info Aufh. zuk. Zuord  NB->LFa
             gs_s_r_view-reciever_view = '03' and
             gs_s_r_view-transreason   = 'ZC9' ).

* nicht senden

    else.
      call method fill_sg12_nad_cs
        exporting
          x_swtmsgpod    = l_swtmsgpod
          x_sender       = x_sender
          x_receiver     = x_receiver
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
      endif.
    endif.  "+20130313 Bromisch


    if    ( gs_s_r_view-send_view = '01' and
            gs_s_r_view-reciever_view = '03' and
            gs_s_r_view-msgstatus is initial ).                      "Abmeldeanfrage NB->LF/Alt


      if    ( gs_s_r_view-send_view = '01' and
              gs_s_r_view-reciever_view = '03' and
              gs_s_r_view-msgstatus is initial and
              l_swtmsgpod-msgdata-transreason = 'ZC8' ).             "Beendigung der Zuordnung NB->LF/Alt nicht senden
        lv_not_running = 'X'.
      endif.
      if lv_not_running is initial.

        call method fill_sg12_nad_cs_a
          exporting
            x_swtmsgpod    = l_swtmsgpod
            x_sender       = x_sender
            x_receiver     = x_receiver
          exceptions
            error_occurred = 1
            others         = 2.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
        endif.
      endif.
    endif.

    call method me->fill_sg12_nad_cs_os
      exporting
        is_swtmsgpod     = l_swtmsgpod
        iv_sender        = x_sender
        iv_receiver      = x_receiver
        iv_switch_msgcat = lv_switch_msgcat
      exceptions
        error_occurred   = 1
        others           = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.

    call method me->fill_sg12_nad_cs_vy
      exporting
        is_swtmsgpod     = l_swtmsgpod
        iv_sender        = x_sender
        iv_receiver      = x_receiver
        iv_switch_msgcat = lv_switch_msgcat
      exceptions
        error_occurred   = 1
        others           = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising error_occurred.
    endif.

**** UNT, /ISIDEX/E1VDEWUNT_1, message trailer
    fill_unt( ).

* UNZ, /ISIDEX/E1VDEWUNZ_1
    fill_unz( ).

** set idoc control data
*  CALL METHOD fill_control_data
*    EXPORTING
*      p_receiver = x_receiver.

* take over idoc control
    y_idoc_data-control = sis_idoc_control.

* take over idoc data
    y_idoc_data-data = sit_idoc_data.

* For reversal, delete the nonreleant segments:
    call method me->set_seg_reversal
      exporting
        iv_transreason = x_swtmsgpod-msgdata-transreason
      changing
        cs_idoc        = y_idoc_data
      exceptions
        error_occurred = 1
        others         = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                 raising error_occurred.
    endif.

    try.
        if gref_exit_utilmd_out is initial.
          get badi gref_exit_utilmd_out
            filters
              division = gv_divcat.
        endif.
        call badi gref_exit_utilmd_out->cos_overwrite_idoc_data
          exporting
            iv_sender         = x_sender
            iv_receiver       = x_receiver
            is_swtmsgpod      = l_swtmsgpod
            iv_msgdatanum_req = x_msgdatanum_req
            iv_msgdatanum_res = x_msgdatanum_res
          changing
            cs_idoc_data      = y_idoc_data.

      catch cx_badi_not_implemented.                    "#EC NO_HANDLER
    endtry.


  endmethod.


  METHOD korrektur_outbound.
    TYPE-POOLS: isu2a.

    DATA: pruef_nachr(255),
          pruef_system(255),
          ls_switchdoc      TYPE eideswtdoc,
          ls_but000         TYPE but000,
          ls_euitrans       TYPE euitrans.

    DATA: l_keydate         TYPE dats,
          l_sernr           TYPE gernr,
          ls_eadrdat        TYPE eadrdat,
          ls_eideswtmsgdata TYPE eideswtmsgdata,
          ls_eanlh          TYPE eanlh.

    DATA: ls_ever       TYPE ever,
          l_begend      TYPE erch-begend,
          l_begabrpe    TYPE erch-begabrpe,
          l_begnach     TYPE erch-begnach,
          l_abr         TYPE isu2a_abr,
          l_bbp_ierch   TYPE isu_ierch,
          ls_ettifn_h   TYPE ettifn,
          lt_ettifn     TYPE STANDARD TABLE OF ettifn,
          lt_ettifn_h   TYPE STANDARD TABLE OF ettifn,
          ls_ettifn     TYPE ettifn,
          ls_zmsgstatus TYPE zmsgstatus.

    DATA: lt_installation TYPE STANDARD TABLE OF bapiisupodinstln,
          ls_installation TYPE bapiisupodinstln,
          l_service       TYPE eanl-service,
          ls_eanl         TYPE eanl.

    DATA: str(4)       TYPE c,
          strasse(6)   TYPE c,
          l_strasse    TYPE ad_street,
          l_city       TYPE ad_city1,
          syst_strasse TYPE ad_street,
          syst_city    TYPE ad_city1.

    DATA: l_msgstatus          TYPE eideswtmdstatus.

    CLEAR: pruef_nachr, pruef_system.

* Breakpoint für SM50
    zdms_enwg_wf=>break_sm50( 'UTILMD_OUTBOUND_KORREKTUR' ).

    IF ( ix_swtmsgpod-msgdata-msgstatus EQ 'E15' OR "und nur Zustimmung ohne Korrektur aus dem WF.
         ix_swtmsgpod-msgdata-msgstatus EQ 'Z01' OR "oder bei Zustimmung mit Terminänderung
         ix_swtmsgpod-msgdata-msgstatus EQ 'Z12' OR "Ablehnung-Vertragsbindung handelt
         ix_swtmsgpod-msgdata-msgstatus EQ 'Z44').  "Zustimmung mit Korrektur von nicht bilanzierungsrel. Daten

      CHECK ix_swtmsgpod-msgdata-transreason <> 'E05'.

      ex_swtmsgpod = ix_swtmsgpod.
      l_msgstatus  = ix_swtmsgpod-msgdata-msgstatus.

*   Stichtag zum ermitteln Zählpunkt, Zähler ...
      IF NOT ix_swtmsgpod-msgdata-moveindate IS INITIAL.
        l_keydate = ix_swtmsgpod-msgdata-moveindate.
      ELSE.
        l_keydate = ix_swtmsgpod-msgdata-moveoutdate.
      ENDIF.

*---------------------------------------------------------------------------------------------------
*   Namen überprüfen

      CONCATENATE ix_swtmsgpod-msgdata-name_f ix_swtmsgpod-msgdata-name_l
                  INTO pruef_nachr.

      TRANSLATE pruef_nachr TO UPPER CASE.
      CONDENSE pruef_nachr NO-GAPS.

      SELECT SINGLE * FROM eideswtdoc INTO ls_switchdoc WHERE switchnum EQ x_switchnum.

      IF sy-subrc EQ 0.

        SELECT SINGLE * FROM but000 INTO ls_but000 WHERE partner EQ ls_switchdoc-partner.

        CASE ls_but000-type.

          WHEN '1'.                "natürliche Person
            CONCATENATE ls_but000-name_first ls_but000-name_last ls_but000-name_lst2
                        INTO pruef_system.
            CONDENSE pruef_system NO-GAPS.
            TRANSLATE pruef_system TO UPPER CASE.

            IF pruef_nachr NE pruef_system.
              ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
              ex_swtmsgpod-msgdata-name_f    = ls_but000-name_first.
              CONCATENATE ls_but000-name_last ls_but000-name_lst2
                          INTO ex_swtmsgpod-msgdata-name_l SEPARATED BY space.
            ENDIF.

          WHEN '2'.                "Organisation
            CONCATENATE ls_but000-name_org1 ls_but000-name_org2 ls_but000-name_org3 ls_but000-name_org4
                        INTO pruef_system.
            CONDENSE pruef_system NO-GAPS.
            TRANSLATE pruef_system TO UPPER CASE.

            IF pruef_nachr NE pruef_system.
              ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
              CONCATENATE ls_but000-name_org1 ls_but000-name_org2
                          INTO ex_swtmsgpod-msgdata-name_l.

              CONCATENATE ls_but000-name_org3 ls_but000-name_org4
                          INTO ex_swtmsgpod-msgdata-name_f SEPARATED BY space.
            ENDIF.

          WHEN '3'.                "Gruppe
            CONCATENATE ls_but000-name_grp1 ls_but000-name_grp2 INTO pruef_system.
            CONDENSE pruef_system NO-GAPS.
            TRANSLATE pruef_system TO UPPER CASE.

            IF pruef_nachr NE pruef_system.
              ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
              ex_swtmsgpod-msgdata-name_f    = ls_but000-name_grp1.
              ex_swtmsgpod-msgdata-name_l    = ls_but000-name_grp2.
            ENDIF.

        ENDCASE.

      ENDIF.


*---------------------------------------------------------------------------------------------------
* Gerät prüfen

*   Ermittlung meter number
      CLEAR l_sernr.
      CALL FUNCTION '/ISIDEX/ISU_SWD_METER_NUM'
        EXPORTING
          x_pod     = ls_switchdoc-pod
          x_swtview = ls_switchdoc-swtview
          x_swtdate = l_keydate
        IMPORTING
          y_sernr   = l_sernr
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      SHIFT l_sernr LEFT DELETING LEADING '0'.

      IF l_sernr NE ix_swtmsgpod-msgdata-meternr.
        ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
        ex_swtmsgpod-msgdata-meternr   = l_sernr.
      ENDIF.


*---------------------------------------------------------------------------------------------------
*Adresse prüfen

*   Ermittlung der Partneradresse
      IF NOT ls_switchdoc-partner IS INITIAL.
        CLEAR ls_eadrdat.
        CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
          EXPORTING
            x_address_type             = 'B'
            x_partner                  = ls_switchdoc-partner
          IMPORTING
            y_eadrdat                  = ls_eadrdat
          EXCEPTIONS
            not_found                  = 1
            parameter_error            = 2
            object_not_given           = 3
            address_inconsistency      = 4
            installation_inconsistency = 5
            OTHERS                     = 6.

        IF sy-subrc EQ 0.

          CLEAR: str, strasse, l_strasse, syst_strasse, syst_city.

          str          = 'str.'.
          strasse      = 'straße'.
          l_strasse    = ix_swtmsgpod-msgdata-street_bu.
          syst_strasse = ls_eadrdat-street.
          syst_city    = ls_eadrdat-city1.
          l_city       = ix_swtmsgpod-msgdata-city_bu.

          REPLACE str WITH strasse INTO l_strasse.
          REPLACE str WITH strasse INTO syst_strasse.

          TRANSLATE l_strasse    TO UPPER CASE.
          TRANSLATE syst_strasse TO UPPER CASE.
          TRANSLATE l_city       TO UPPER CASE.
          TRANSLATE syst_city    TO UPPER CASE.

          IF l_strasse NE syst_strasse.
            ex_swtmsgpod-msgdata-street_bu   = ls_eadrdat-street.
            ex_swtmsgpod-msgdata-msgstatus   = 'Z44'.                  "4.4A
          ENDIF.
          IF ls_eadrdat-house_num1 NE ix_swtmsgpod-msgdata-housenr_bu.
            ex_swtmsgpod-msgdata-housenr_bu  = ls_eadrdat-house_num1.
            ex_swtmsgpod-msgdata-msgstatus   = 'Z44'.                  "4.4A
          ENDIF.
          IF ls_eadrdat-post_code1 NE ix_swtmsgpod-msgdata-postcode_bu.
            ex_swtmsgpod-msgdata-postcode_bu = ls_eadrdat-post_code1.
            ex_swtmsgpod-msgdata-msgstatus   = 'Z44'.                  "4.4A
          ENDIF.
          IF syst_city NE l_city.
            ex_swtmsgpod-msgdata-city_bu     = ls_eadrdat-city1.
            ex_swtmsgpod-msgdata-msgstatus   = 'Z44'.                  "4.4A
          ENDIF.

        ENDIF.
      ENDIF.

*   Ermittlung der Adresse der Lieferstelle
      CLEAR ls_eadrdat.
      CALL FUNCTION 'ISU_ADDRESS_PROVIDE'
        EXPORTING
          x_address_type             = 'Z'
          x_int_ui                   = ls_switchdoc-pod
        IMPORTING
          y_eadrdat                  = ls_eadrdat
        EXCEPTIONS
          not_found                  = 1
          parameter_error            = 2
          object_not_given           = 3
          address_inconsistency      = 4
          installation_inconsistency = 5
          OTHERS                     = 6.

      IF sy-subrc EQ 0.
        CLEAR: str, strasse, l_strasse, syst_strasse, syst_city, l_city.

        str          = 'str.'.
        strasse      = 'straße'.
        l_strasse    = ix_swtmsgpod-msgdata-street.
        syst_strasse = ls_eadrdat-street.
        syst_city    = ls_eadrdat-city1.
        l_city       = ix_swtmsgpod-msgdata-city.

        REPLACE str WITH strasse INTO l_strasse.
        REPLACE str WITH strasse INTO syst_strasse.

        TRANSLATE l_strasse    TO UPPER CASE.
        TRANSLATE syst_strasse TO UPPER CASE.
        TRANSLATE l_city       TO UPPER CASE.
        TRANSLATE syst_city    TO UPPER CASE.

        IF l_strasse NE syst_strasse.
          ex_swtmsgpod-msgdata-street    = ls_eadrdat-street.
          ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
        ENDIF.
        IF ls_eadrdat-house_num1 NE ix_swtmsgpod-msgdata-housenr.
          ex_swtmsgpod-msgdata-housenr   = ls_eadrdat-house_num1.
          ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
        ENDIF.
        IF ls_eadrdat-post_code1 NE ix_swtmsgpod-msgdata-postcode.
          ex_swtmsgpod-msgdata-postcode  = ls_eadrdat-post_code1.
          ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
        ENDIF.
        IF syst_city NE l_city.
          ex_swtmsgpod-msgdata-city      = ls_eadrdat-city1.
          ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
        ENDIF.

      ENDIF.


*---------------------------------------------------------------------------------------------------
* Prüfen EXT_UI

      CALL FUNCTION 'ISU_DB_EUITRANS_INT_SINGLE'
        EXPORTING
          x_int_ui     = ls_switchdoc-pod
          x_keydate    = l_keydate
          x_keytime    = '000000'
        IMPORTING
          y_euitrans   = ls_euitrans
        EXCEPTIONS
          not_found    = 1
          system_error = 2
          OTHERS       = 3.

      IF sy-subrc EQ 1.
        CLEAR: ex_swtmsgpod-msgdata-ext_ui.
      ELSEIF sy-subrc NE 0.
      ELSE.
        IF ix_swtmsgpod-msgdata-ext_ui NE ls_euitrans-ext_ui.
          ex_swtmsgpod-msgdata-ext_ui    = ls_euitrans-ext_ui.
          ex_swtmsgpod-msgdata-msgstatus = 'Z44'.               "4.4A
        ENDIF.
      ENDIF.

* Prüfen ob es sich um eine Z01 Zustimmung mit Terminänderung oder um eine
*                           Z12 Ablehnung-Vertragsbindung handelt
* dann muss die Nachricht zwar korrigiert werden aber der MSGSTATUS
* darf nicht geändert werden
      IF l_msgstatus EQ 'Z01' OR l_msgstatus EQ 'Z12'.
        ex_swtmsgpod-msgdata-msgstatus = l_msgstatus.
      ENDIF.

**   Nachrichtendaten für Anzeige im Wechselbeleg anpassen
*    if ex_swtmsgpod-msgdata-msgstatus ne 'E15'.
*
**     Nachrichtendaten für späteren Update in Struktur lesen
*      select single * from eideswtmsgdata into ls_eideswtmsgdata
*                      where switchnum  eq ix_swtmsgpod-msgdata-switchnum
*                        and msgdatanum eq ix_swtmsgpod-msgdata-msgdatanum.
*
*      move-corresponding ex_swtmsgpod-msgdata to ls_eideswtmsgdata.
*      move-corresponding ex_swtmsgpod-msgdata to ls_zmsgstatus.
*      modify eideswtmsgdata from ls_eideswtmsgdata.
*      modify zmsgstatus from ls_zmsgstatus.
*      commit work.
*
*    endif.
    ENDIF.

*   Nachrichtendaten für Anzeige im Wechselbeleg anpassen

    IF NOT l_msgstatus IS INITIAL.
*     Nachrichtendaten für späteren Update in Struktur lesen
      SELECT SINGLE * FROM eideswtmsgdata INTO ls_eideswtmsgdata
                      WHERE switchnum  EQ ix_swtmsgpod-msgdata-switchnum
                        AND msgdatanum EQ ix_swtmsgpod-msgdata-msgdatanum.

      MOVE-CORRESPONDING ex_swtmsgpod-msgdata TO ls_zmsgstatus.
      MODIFY zmsgstatus FROM ls_zmsgstatus.
      COMMIT WORK.
    ENDIF.

  ENDMETHOD.


  METHOD proc_bgm_poda.
    DATA: ls_bgm TYPE edidd,
          lt_bgm TYPE edidd_tt.

    CALL METHOD me->get_segments_bgm
      IMPORTING
        et_bgm = lt_bgm.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_bgm INTO ls_bgm.
      CHECK g_error_in IS INITIAL.

      sis_cl_seg_bgm_02 = ls_bgm-sdata.

      IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

      IF sis_cl_seg_bgm_02-document_name_code <> co_bgm_tsi_activation.
        CALL METHOD invalid_value
          EXPORTING
            p_segment     = ls_bgm
            p_field_name  = 'NAME'                            "#EC NOTEXT
            p_field_value = sis_cl_seg_bgm_02-document_name_code.
        IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD proc_sg10_cci_cav_cs.
    DATA:
      ls_sg10_cci TYPE edidd,
      lt_sg10_cci TYPE edidd_tt.

    DATA:
      ls_sg10_cav TYPE edidd,
      lt_sg10_cav TYPE edidd_tt.

    DATA:
      ls_seg_cci4 TYPE /idxgc/e1_cci_03,
      ls_seg_cav2 TYPE /idxgc/e1_cav_02.


    lt_sg10_cci =
        gr_proc_in->get_segment(
                      im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cci_03 im_psgnum = iv_seq_segnum ).

* We need to judge the value (ls_seg_cci4-characteristic_id) in segment SG10 CCI,
* then find the meter information corresponding to the value and filled into the fields
    LOOP AT lt_sg10_cci INTO ls_sg10_cci.
      ls_seg_cci4 = ls_sg10_cci-sdata.
      CASE ls_seg_cci4-characteristic_descr_code.
        WHEN gc_cci_device_type.    " E13 Device Category
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          LOOP AT lt_sg10_cav INTO ls_sg10_cav.
            ls_seg_cav2 = ls_sg10_cav-sdata.
            CASE ls_seg_cav2-charac_value_descr_code.
              WHEN /idxgc/if_constants_ide=>gc_chara_value_code_ahz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_wsz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_laz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_ehz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_maz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_dkz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_bgz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_trz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_ugz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_mrg
                OR /idxgc/if_constants_ide=>gc_chara_value_code_iva
                .
                cs_swtmsgpod-msgdata-meter_type = ls_seg_cav2-charac_value_descr_code.
                cs_swtmsgpod-msgdata-schara = ls_seg_cav2-characteristic_value_descr_1.

              WHEN /idxgc/if_constants_ide=>gc_cav_chardesc_code_z30.
                IF ls_seg_cav2-characteristic_value_descr_2 IS NOT INITIAL.
                  CONCATENATE ls_seg_cav2-characteristic_value_descr_1 ls_seg_cav2-characteristic_value_descr_2 INTO cs_swtmsgpod-msgdata-meternr.
                ELSE.
                  cs_swtmsgpod-msgdata-meternr = ls_seg_cav2-characteristic_value_descr_1.
                ENDIF.

              WHEN /idxgc/if_constants_ide=>gc_chara_value_code_etz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_ztz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_ntz.
                cs_swtmsgpod-msgdata-/idexge/rate_num = ls_seg_cav2-charac_value_descr_code.

              WHEN /idxgc/if_constants_ide=>gc_chara_value_code_erz
                OR /idxgc/if_constants_ide=>gc_chara_value_code_zrz.
                cs_swtmsgpod-msgdata-/idexge/engy_dir = ls_seg_cav2-charac_value_descr_code.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.
        WHEN co_sts_extra_end.      " Z25 Transformer / volume converter
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
          IF sy-subrc = 0.
            ls_seg_cav2 = ls_sg10_cav-sdata.
            cs_swtmsgpod-msgdata-/idexge/convert = ls_seg_cav2-charac_value_descr_code.
            cs_swtmsgpod-msgdata-/idexge/con_fact = ls_seg_cav2-characteristic_value_descr_1.
          ENDIF.
        WHEN gc_cci_com_eqip.      " Z26 Communication equipment
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
          IF sy-subrc = 0.
            ls_seg_cav2 = ls_sg10_cav-sdata.
            cs_swtmsgpod-msgdata-/idexge/com_eqip = ls_seg_cav2-charac_value_descr_code.
          ENDIF.
        WHEN gc_cci_con_eqip.      " Z27 Technical controlling equipment
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
          IF sy-subrc = 0.
            ls_seg_cav2 = ls_sg10_cav-sdata.
            cs_swtmsgpod-msgdata-/idexge/con_eqip = ls_seg_cav2-charac_value_descr_code.
          ENDIF.
* SG10-CCI+E04: voltage level of measurement
        WHEN /idexge/cl_utilmd_v42=>gc_cci_measur_voltage.      " E04 measur voltage
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
          IF sy-subrc = 0.
            ls_seg_cav2 = ls_sg10_cav-sdata.
            cs_swtmsgpod-msgdata-/idexge/meavolt = ls_seg_cav2-charac_value_descr_code.
          ENDIF.
* SG10-CCI+Z08/Z09: amount franchise fee
        WHEN co_cci_concession_fees_ht.      " Z08
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
          IF sy-subrc = 0.
            ls_seg_cav2 = ls_sg10_cav-sdata.
            cs_swtmsgpod-msgdata-/idexge/ff_ht = ls_seg_cav2-characteristic_value_descr_1.
          ENDIF.
        WHEN co_cci_concession_fees_nt.      " Z09
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
          IF sy-subrc = 0.
            ls_seg_cav2 = ls_sg10_cav-sdata.
            cs_swtmsgpod-msgdata-/idexge/ff_nt = ls_seg_cav2-characteristic_value_descr_1.
          ENDIF.
        WHEN gc_cci_meter_read..             " E12
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
          IF sy-subrc = 0.
            ls_seg_cav2 = ls_sg10_cav-sdata.
            cs_swtmsgpod-msgdata-/idexge/mr_type = ls_seg_cav2-charac_value_descr_code.
          ENDIF.

        WHEN 'Z33'.             "Vorkommer und Nachkommer
          lt_sg10_cav =
          lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
          READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
          ls_seg_cav2 = ls_sg10_cav-sdata.

          cs_swtmsgpod-msgdata-zz_stanzvor = ls_seg_cav2-characteristic_value_descr_1.
          cs_swtmsgpod-msgdata-zz_stanznac = ls_seg_cav2-characteristic_value_descr_2.

        WHEN OTHERS.
* SG10-CCI+15: time series type
          IF ls_seg_cci4-class_type_code = co_cci_class_structure.
            cs_swtmsgpod-msgdata-/idexge/cci_tsca = ls_seg_cci4-characteristic_descr_code.
*          ev_tscategory = ls_seg_cci4-characteristic_descr_code.
            lt_sg10_cav =
              gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                                       im_psgnum = ls_sg10_cci-segnum ).
            READ TABLE lt_sg10_cav INTO ls_sg10_cav INDEX 1.
            IF sy-subrc = 0.
              ls_seg_cav2 = ls_sg10_cav-sdata.
              cs_swtmsgpod-msgdata-/idexge/tstype = ls_seg_cav2-charac_value_descr_code.
*            ev_tstype = ls_seg_cav2-charac_value_descr_code.
            ENDIF.
            IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


  METHOD proc_sg12_nad_cs.
    DATA: ls_sg12_nad TYPE edidd,
          lt_sg12_nad TYPE edidd_tt.

    DATA: lv_externalid     TYPE dunsnr,
          lv_codelistagency TYPE e_edmideextcodelistid,
          ls_eservprov      TYPE eservprov.

* change for V42a
    DATA: lt_sgm_unh_in      TYPE edidd_tt,
          ls_sgm_unh_in      TYPE edidd,
          lv_badi_housenr    TYPE c,
          lv_badi_housenr_bu TYPE c.
* end change for V42a

*<Legal Change for V42a>
    DATA:
      lv_title_aca1   TYPE ad_title1t.
*    lv_msgv1        TYPE symsgv.
*<Legal Change for V42a>

*<<< Legal Change for V44
    DATA: lt_sgm_rff_in TYPE edidd_tt,
          ls_sgm_rff_in TYPE edidd.
*>>> Legal Change for V44


*n>>IDE_1>>nad_8
*     get name and address of customer
    CALL METHOD me->get_segments_sg12_nad
      EXPORTING
        p_psgnum    = x_segnum
      IMPORTING
        et_sg12_nad = lt_sg12_nad.
    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_sg12_nad INTO ls_sg12_nad.
      sis_cl_seg_nad_04 = ls_sg12_nad-sdata.

      CALL METHOD check_zipcode
        EXPORTING
          zipcode       = sis_cl_seg_nad_04-postal_identification_code
        EXCEPTIONS
          error_occured = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.
*       ... = sis_cl_seg_nad_04-...
      CASE sis_cl_seg_nad_04-party_function_code_qualifier.
*<<< Legal Change for V44
*      WHEN cl_isu_datex_co=>co_nad_vdew_premise.
        WHEN cl_isu_datex_co=>co_nad_vdew_dp.                              "DP
*>>> Legal Change for V44
          CONCATENATE sis_cl_seg_nad_04-street_no_or_po_box_ident_1
                      sis_cl_seg_nad_04-street_no_or_po_box_ident_2
           INTO y_msg-msgdata-street.
          y_msg-msgdata-housenr    = sis_cl_seg_nad_04-street_no_or_po_box_ident_3.
          y_msg-msgdata-housenrext = sis_cl_seg_nad_04-street_no_or_po_box_ident_4.
* change for V42a
          lv_badi_housenr          = co_true.
* end change for V42a
          y_msg-msgdata-postcode   = sis_cl_seg_nad_04-postal_identification_code.
          y_msg-msgdata-city       = sis_cl_seg_nad_04-city_name.
          y_msg-msgdata-/idexge/pod_cntr = sis_cl_seg_nad_04-country_identifier.
        WHEN cl_isu_datex_co=>co_nad_vdew_name.
          CONCATENATE sis_cl_seg_nad_04-party_name_1 sis_cl_seg_nad_04-party_name_2
            INTO y_msg-msgdata-name_l.                        "2nd name
          CONCATENATE sis_cl_seg_nad_04-party_name_3 sis_cl_seg_nad_04-party_name_4
            INTO y_msg-msgdata-name_f.                        "1st name
*<Legal Change for V42a>
          IF NOT sis_cl_seg_nad_04-party_name_5 IS INITIAL.
            lv_title_aca1 = sis_cl_seg_nad_04-party_name_5.
*get academic title1 key
            SELECT SINGLE title_key
              INTO y_msg-msgdata-bp_title_aca1
              FROM tsad2
             WHERE title_text = lv_title_aca1.

            IF sy-subrc <> 0.
*            lv_msgv1 = lv_title_aca1.
*            CALL METHOD add_warning_status_appl_in
*              EXPORTING
*                p_msgno = 023
*                p_msgid = '/IDEXGE/INV_LIST'
*                p_msgv1 = lv_msgv1
*                p_msgv2 = space
*                p_msgv3 = space
*                p_msgv4 = space.
            ENDIF.

          ENDIF.
*<Legal Change for V42a>
          CONCATENATE sis_cl_seg_nad_04-street_no_or_po_box_ident_1
                      sis_cl_seg_nad_04-street_no_or_po_box_ident_2
           INTO y_msg-msgdata-street_bu.
          y_msg-msgdata-housenr_bu    = sis_cl_seg_nad_04-street_no_or_po_box_ident_3.
          y_msg-msgdata-housenrext_bu = sis_cl_seg_nad_04-street_no_or_po_box_ident_4.
* change for V42a
          lv_badi_housenr_bu          = co_true.
* end change for V42a
          y_msg-msgdata-postcode_bu   = sis_cl_seg_nad_04-postal_identification_code.
          y_msg-msgdata-city_bu       = sis_cl_seg_nad_04-city_name.
          y_msg-msgdata-/idexge/country = sis_cl_seg_nad_04-country_identifier.

*<<< Legal Change for V44
          lt_sgm_rff_in = gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_rff_03 ).
          READ TABLE lt_sgm_rff_in INTO ls_sgm_rff_in INDEX 1.
          IF sy-subrc = 0.
            sis_cl_seg_rff_03              = ls_sgm_rff_in-sdata.
            CASE sis_cl_seg_rff_03-reference_code_qualifier.
              WHEN co_rff_partner_id_supplier.
                y_msg-msgdata-/idexge/bp_extno = sis_cl_seg_rff_03-reference_identifier.

              WHEN co_rff_z01.
                y_msg-msgdata-/idexge/bpexno_r = sis_cl_seg_rff_03-reference_identifier.
              WHEN OTHERS.
            ENDCASE.
          ENDIF.
*>>> Legal Change for V44

        WHEN cl_isu_datex_co=>co_nad_vdew_bu_part.
          IF y_msg-msgdata-street_bu IS INITIAL.
            CONCATENATE sis_cl_seg_nad_04-street_no_or_po_box_ident_1
                        sis_cl_seg_nad_04-street_no_or_po_box_ident_2
             INTO y_msg-msgdata-street_bu.
            y_msg-msgdata-housenr_bu    = sis_cl_seg_nad_04-street_no_or_po_box_ident_3.
            y_msg-msgdata-housenrext_bu = sis_cl_seg_nad_04-street_no_or_po_box_ident_4.
* change for V42a
            lv_badi_housenr_bu          = co_true.
* end change for V42a
            y_msg-msgdata-postcode_bu   = sis_cl_seg_nad_04-postal_identification_code.
            y_msg-msgdata-city_bu       = sis_cl_seg_nad_04-city_name.
          ENDIF.
        WHEN co_nad_supplier_open_contr    OR "Lieferant (mit offenem Vertrag)
             co_nad_supplier_wo_open_contr OR "Lieferant (ohne offenen Vertrag)
             co_nad_mreader                OR "Z?hlerdatenerfasser
*           co_nad_old_supplier           OR "Vorlieferant
             co_nad_point_of_connect_owner.   "Netzanschlusseigent¡§1mer
*              do nothing, information will be ignored

        WHEN co_nad_old_supplier.
          lv_externalid  = sis_cl_seg_nad_04-party_identifier.
          lv_codelistagency = sis_cl_seg_nad_04-code_list_resp_agency_code_1.
* get compsupplier from MP-ID
          CALL FUNCTION 'ISU_DATEX_IDENT_SP_BY_CODELIST'
            EXPORTING
              x_ext_id        = lv_externalid
              x_extcodelistid = lv_codelistagency
              x_idoc_control  = sis_idoc_control
            IMPORTING
              y_eservprov     = ls_eservprov
            EXCEPTIONS
              not_found       = 1
              not_unique      = 2
              not_supported   = 3
              error_occured   = 4
              OTHERS          = 5.

          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
          ENDIF.

          IF y_msg-msgdata-msgstatus EQ co_sts_refuse_forced_drop.
            y_msg-msgdata-service_prov_old = ls_eservprov-serviceid.
          ELSE.
            IF y_msg-msgdata-compsupplier IS INITIAL.
              y_msg-msgdata-compsupplier = ls_eservprov-serviceid.
            ELSE.
              CONCATENATE y_msg-msgdata-compsupplier co_comma INTO y_msg-msgdata-compsupplier.
              CONCATENATE y_msg-msgdata-compsupplier ls_eservprov-serviceid
                    INTO y_msg-msgdata-compsupplier SEPARATED BY space.
            ENDIF.
          ENDIF.

        WHEN co_service_type_deb .

        WHEN 'VY' .
          lv_externalid  = sis_cl_seg_nad_04-party_identifier.
          lv_codelistagency = sis_cl_seg_nad_04-code_list_resp_agency_code_1.

          CALL FUNCTION 'ISU_DATEX_IDENT_SP_BY_CODELIST'
            EXPORTING
              x_ext_id        = lv_externalid
              x_extcodelistid = lv_codelistagency
              x_idoc_control  = sis_idoc_control
            IMPORTING
              y_eservprov     = ls_eservprov
            EXCEPTIONS
              not_found       = 1
              not_unique      = 2
              not_supported   = 3
              error_occured   = 4
              OTHERS          = 5.

          y_msg-msgdata-/idexge/extid_s = ls_eservprov-serviceid.
          y_msg-msgdata-compsupplier = lv_externalid.

        WHEN OTHERS.
          CALL METHOD invalid_value
            EXPORTING
              p_segment     = ls_sg12_nad
              p_field_name  = 'PARTY_FUNCTION_CODE_QUALIFIER'
              p_field_value = sis_cl_seg_nad_04-party_function_code_qualifier.
      ENDCASE.

* change for V42a
      IF lv_badi_housenr = co_true
        OR lv_badi_housenr_bu = co_true.
* get unh information
        IF sis_cl_seg_unh_01 IS INITIAL.
          lt_sgm_unh_in = gr_proc_in->get_segment( im_segnam = /idxgc/if_constants_ide=>gc_segmtp_unh_01 ).
          READ TABLE lt_sgm_unh_in INTO ls_sgm_unh_in INDEX 1.
          IF sy-subrc = 0.
            sis_cl_seg_unh_01              = ls_sgm_unh_in-sdata.
          ELSE.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.                     "#EC RAISE_OK
          ENDIF.
        ENDIF.

        IF lv_badi_housenr = co_true.
* mapping of house numbers from message to SAP can be changed
          TRY.
              IF badi_address_in IS INITIAL.
                GET BADI badi_address_in.
              ENDIF.
              CALL BADI badi_address_in->map_message_to_sap_house_numb
                EXPORTING
                  iv_mestyp_identifier        = sis_cl_seg_unh_01-message_type
                  iv_assocode                 = sis_cl_seg_unh_01-association_assigned_code
                  iv_mess_house_numb          = sis_cl_seg_nad_04-street_no_or_po_box_ident_3
                  iv_mess_house_numb_addition = sis_cl_seg_nad_04-street_no_or_po_box_ident_4
                CHANGING
                  cv_house_number             = y_msg-msgdata-housenr
                  cv_house_number_suppl_long  = y_msg-msgdata-housenrext.

            CATCH cx_badi_not_implemented.              "#EC NO_HANDLER
          ENDTRY.

        ELSEIF lv_badi_housenr_bu = co_true.
* mapping of house numbers from message to SAP can be changed
          TRY.
              IF badi_address_in IS INITIAL.
                GET BADI badi_address_in.
              ENDIF.
              CALL BADI badi_address_in->map_message_to_sap_house_numb
                EXPORTING
                  iv_mestyp_identifier        = sis_cl_seg_unh_01-message_type
                  iv_assocode                 = sis_cl_seg_unh_01-association_assigned_code
                  iv_mess_house_numb          = sis_cl_seg_nad_04-street_no_or_po_box_ident_3
                  iv_mess_house_numb_addition = sis_cl_seg_nad_04-street_no_or_po_box_ident_4
                CHANGING
                  cv_house_number             = y_msg-msgdata-housenr_bu
                  cv_house_number_suppl_long  = y_msg-msgdata-housenrext_bu.

            CATCH cx_badi_not_implemented.              "#EC NO_HANDLER
          ENDTRY.
        ENDIF.

      ENDIF.
* end change for V42a

    ENDLOOP.                                                  "nad_8


  ENDMETHOD.


  METHOD proc_sg4_dtm_cs.

    DATA: ls_sg4_dtm TYPE edidd,
          lt_sg4_dtm TYPE edidd_tt.

*n>>IDE_1>>DTM_3
    CALL METHOD me->get_segments_sg4_dtm
      EXPORTING
        iv_parent_segnum = x_segnum
      IMPORTING
        et_sg4_dtm       = lt_sg4_dtm.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_sg4_dtm INTO ls_sg4_dtm.
      CHECK g_error_in IS INITIAL.
      sis_cl_seg_dtm_03 = ls_sg4_dtm-sdata.

      IF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_start.  "92
* Start of supply
        y_msg-msgdata-moveindate = sis_cl_seg_dtm_03-date_time_period_value.
        CALL FUNCTION 'ISU_DATE_FORMAT_CHECK'
          EXPORTING
            x_date          = y_msg-msgdata-moveindate
          EXCEPTIONS
            wrong_format    = 1
            date_is_initial = 2
            system_error    = 3
            OTHERS          = 4.
        IF sy-subrc <> 0.
          CALL METHOD invalid_value
            EXPORTING
              p_segment     = ls_sg4_dtm
              p_field_name  = 'DATE_TIME_PERIOD_VALUE'
              p_field_value = sis_cl_seg_dtm_03-date_time_period_value.
        ENDIF.
      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = cl_isu_datex_co=>co_dtm_vdew_end OR  "93
             sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_next_pos_date.  "471
* End of supply
        y_msg-msgdata-moveoutdate = sis_cl_seg_dtm_03-date_time_period_value.
        CALL FUNCTION 'ISU_DATE_FORMAT_CHECK'
          EXPORTING
            x_date          = y_msg-msgdata-moveoutdate
          EXCEPTIONS
            wrong_format    = 1
            date_is_initial = 2
            system_error    = 3
            OTHERS          = 4.
        IF sy-subrc <> 0.
          CALL METHOD invalid_value
            EXPORTING
              p_segment     = ls_sg4_dtm
              p_field_name  = 'DATE_TIME_PERIOD_VALUE'
              p_field_value = sis_cl_seg_dtm_03-date_time_period_value.
        ENDIF.

        IF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_next_pos_date.  "471
          y_msg-msgdata-/idexge/nonfixed = co_true.
          y_msg-msgdata-/idexge/nextcand = y_msg-msgdata-moveoutdate.
        ENDIF.

      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_settl_begin.  "158
* Start of Settlement
        y_msg-msgdata-startsettldate = sis_cl_seg_dtm_03-date_time_period_value.
        CALL FUNCTION 'ISU_DATE_FORMAT_CHECK'
          EXPORTING
            x_date          = y_msg-msgdata-startsettldate
          EXCEPTIONS
            wrong_format    = 1
            date_is_initial = 2
            system_error    = 3
            OTHERS          = 4.
        IF sy-subrc <> 0.
          CALL METHOD invalid_value
            EXPORTING
              p_segment     = ls_sg4_dtm
              p_field_name  = 'DATE_TIME_PERIOD_VALUE'
              p_field_value = sis_cl_seg_dtm_03-date_time_period_value.
        ENDIF.
      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_settl_end.  "159
* End of Settlement
        y_msg-msgdata-endsettldate = sis_cl_seg_dtm_03-date_time_period_value.
        CALL FUNCTION 'ISU_DATE_FORMAT_CHECK'
          EXPORTING
            x_date          = y_msg-msgdata-endsettldate
          EXCEPTIONS
            wrong_format    = 1
            date_is_initial = 2
            system_error    = 3
            OTHERS          = 4.
        IF sy-subrc <> 0.
          CALL METHOD invalid_value
            EXPORTING
              p_segment     = ls_sg4_dtm
              p_field_name  = 'DATE_TIME_PERIOD_VALUE'
              p_field_value = sis_cl_seg_dtm_03-date_time_period_value.
        ENDIF.

      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_cancellation_date.  "157
* Don't process
        y_msg-msgdata-/idexge/nextcand = sis_cl_seg_dtm_03-date_time_period_value.

      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_notice_period.  "Z01

* IDEX-GE: Importing of Notice Period
        y_msg-msgdata-notic_perd = sis_cl_seg_dtm_03-date_time_period_value.

      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_next_mr_date. "752
        IF sis_cl_seg_dtm_03-date_time_period_format_code = co_dtm_exact_date.           "106 - MMDD
          y_msg-msgdata-pland_mr_date = sis_cl_seg_dtm_03-date_time_period_value.
        ENDIF.

      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_dtm_bill_begin.   "155
        y_msg-msgdata-bill_yr_start = sis_cl_seg_dtm_03-date_time_period_value.

      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = co_proc_period.   "672
        y_msg-msgdata-/idexge/mrperio = sis_cl_seg_dtm_03-date_time_period_value.
        IF y_msg-msgdata-/idexge/mrperio IS INITIAL.
          y_msg-msgdata-/idexge/mrperio = gc_month_12.     "12
          siv_mr_period_chg = co_true.
        ENDIF.

      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z07'.        "Z07
* End of Settlement
        y_msg-msgdata-/idexge/sta_dat = sis_cl_seg_dtm_03-date_time_period_value.
        CALL FUNCTION 'ISU_DATE_FORMAT_CHECK'
          EXPORTING
            x_date          = y_msg-msgdata-/idexge/sta_dat
          EXCEPTIONS
            wrong_format    = 1
            date_is_initial = 2
            system_error    = 3
            OTHERS          = 4.
        IF sy-subrc <> 0.
          CALL METHOD invalid_value
            EXPORTING
              p_segment     = ls_sg4_dtm
              p_field_name  = 'DATUM'
              p_field_value = sis_cl_seg_dtm_03-date_time_period_value.
        ENDIF.

      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z08'.        "Z08

* End of Settlement
        y_msg-msgdata-/idexge/npro_dat = sis_cl_seg_dtm_03-date_time_period_value.
        CALL FUNCTION 'ISU_DATE_FORMAT_CHECK'
          EXPORTING
            x_date          = y_msg-msgdata-/idexge/npro_dat
          EXCEPTIONS
            wrong_format    = 1
            date_is_initial = 2
            system_error    = 3
            OTHERS          = 4.
        IF sy-subrc <> 0.
          CALL METHOD invalid_value
            EXPORTING
              p_segment     = ls_sg4_dtm
              p_field_name  = 'DATUM'
              p_field_value = sis_cl_seg_dtm_03-date_time_period_value.
        ENDIF.


      ELSEIF sis_cl_seg_dtm_03-date_time_period_fc_qualifier = 'Z05'.        "Z05
        y_msg-msgdata-/idexge/kuenddat =  sis_cl_seg_dtm_03-date_time_period_value.
        CALL FUNCTION 'ISU_DATE_FORMAT_CHECK'
          EXPORTING
            x_date          = y_msg-msgdata-/idexge/kuenddat
          EXCEPTIONS
            wrong_format    = 1
            date_is_initial = 2
            system_error    = 3
            OTHERS          = 4.
        IF sy-subrc <> 0.
          CALL METHOD invalid_value
            EXPORTING
              p_segment     = ls_sg4_dtm
              p_field_name  = 'DATUM'
              p_field_value = sis_cl_seg_dtm_03-date_time_period_value.
        ENDIF.

      ELSE.
        CALL METHOD invalid_value
          EXPORTING
            p_segment     = ls_sg4_dtm
            p_field_name  = 'DATE_TIME_PERIOD_FC_QUALIFIER'
            p_field_value = sis_cl_seg_dtm_03-date_time_period_fc_qualifier.
      ENDIF.
    ENDLOOP.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
**<<IDE_2<<DTM_3

  ENDMETHOD.


  METHOD proc_sg4_sts_cs.
*n>>IDE_2>>sts_3
    DATA:lv_servtype_receiver TYPE intcode,
         lv_servtype_sender   TYPE intcode.

    DATA: ls_sg4_sts TYPE edidd,
          lt_sg4_sts TYPE edidd_tt.

    CALL METHOD me->get_segments_sg4_sts
      EXPORTING
        iv_parent_segnum = x_segnum
      IMPORTING
        et_sg4_sts       = lt_sg4_sts.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_sg4_sts INTO ls_sg4_sts.
      CHECK g_error_in IS INITIAL.
      sis_cl_seg_sts_01 = ls_sg4_sts-sdata.

      IF sis_cl_seg_sts_01-status_category_code_1 = cl_isu_datex_co=>co_sts_vdew_request.
        CASE sis_cl_seg_sts_01-status_reason_descr_code_1.
          WHEN co_sts_move_out_closure. "Z33
            y_msg-msgdata-transreason =
               if_isu_ide_switch_constants=>co_transreason_movein_out."E01
*>>>IDEX-GE SP05: Backup/Basic Supply
*        WHEN co_sts_backup_supply.
**             VDEW UTILMD mapping backupsupply Z03 (external) to E04 (internal)
*          y_msg-msgdata-transreason =
*             if_isu_ide_switch_constants=>co_transreason_backupspl.
          WHEN co_sts_bs_cust_in. "Z36
            y_msg-msgdata-transreason = co_transreason_bs_cust_in.
          WHEN co_sts_bs_new_inst. "Z37
            y_msg-msgdata-transreason = co_transreason_bs_new_inst.
          WHEN co_sts_bs_cs_fail. "Z38
            y_msg-msgdata-transreason = co_transreason_bs_cs_fail.
          WHEN co_sts_bs_temp_conn. "Z39
            y_msg-msgdata-transreason = co_transreason_bs_temp_conn.
*<<<IDEX-GE SP05: Backup/Basic Supply
*<<<IDEX-DE Business Data Request
          WHEN if_isu_ide_switch_constants=>co_transreason_bdr. "'Z40'
            y_msg-msgdata-transreason = if_isu_ide_switch_constants=>co_transreason_bdr.
*<<<IDEX-DE Business Data Request
          WHEN OTHERS.
            y_msg-msgdata-transreason =
               sis_cl_seg_sts_01-status_reason_descr_code_1.
        ENDCASE.

      ELSEIF sis_cl_seg_sts_01-status_category_code_1 = cl_isu_datex_co=>co_sts_vdew_response.
        CASE sis_cl_seg_sts_01-status_reason_descr_code_1.
**************** Change for Forced Deregistration **************
*            WHEN co_sts_refuse_mult_drop       OR  "Z34
*                 co_sts_refuse_forced_drop.        "Z35
          WHEN co_sts_refuse_mult_drop.                       "Z34.
****************************************************************
*>>> Start of add in UTILMD 4.2b
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_multi_drop."Z34
*<<< End of add in UTILMD 4.2b
          WHEN co_sts_agree_corr_date.           "Z01
            y_msg-msgdata-msgstatus =
                sis_cl_seg_sts_01-status_reason_descr_code_1.
          WHEN co_sts_agree_corr_settl       OR  "Z04
               co_sts_agree_corr_addr        OR  "Z05
               co_sts_agree_double_data.
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_ok_corrected.
*>>> Start of add in UTILMD 4.2b
          WHEN co_sts_refuse_cust_ident.        "Z06
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_bp_error. "Z06
*<<< End of add in UTILMD 4.2b
          WHEN co_sts_with_adjustment.          "Z31
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_address_unknown.
          WHEN co_sts_refuse_no_auth OR         "Z07
               co_sts_refuse_done_allready   OR "Z08
               co_sts_refuse_reason          OR "Z09
               co_sts_refuse_miss_date       OR "Z11
               co_sts_refuse_message_ident   .  "Z13
*<<< IDEXGE SP05: Answer Status Z30
*             co_sts_refuse_no_contract     OR "Z29
*             co_sts_refuse_no_backup.       "Z30
*             co_sts_refuse_no_contract     . "Z29
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_error.
*<<<IDEX-DE Business Data Request
*          if sis_cl_seg_sts_01-STATUS_REASON_DESCR_CODE_1 = co_sts_refuse_no_auth.
*            if
*          endif.
*<<<IDEX-DE Business Data Request
*>>> Start of add in UTILMD 4.2b
          WHEN co_sts_refuse_no_contract. "Z29
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_no_contr. "Z29
*<<< End of add in UTILMD 4.2b
          WHEN co_sts_refuse_no_backup.
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_no_backup.
*>>> IDEXGE SP05: Answer Status Z30
          WHEN co_sts_refuse_miss_reject     OR "Z10
*            no conversion is needed in accordance with usage of answer status Z12
*             co_sts_refuse_contract_exists OR "Z12
               co_sts_refuse_double_message  OR "Z14
               co_sts_missing_registration.     "Z32
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_supply_error.
          WHEN gc_sts_agree_settl_chng       OR "Z43
               gc_sts_agree_nonsettl_chng.      "Z44
            y_msg-msgdata-msgstatus =
               if_isu_ide_switch_constants=>co_swtmdstatus_ok_corrected.
          WHEN OTHERS.
            y_msg-msgdata-msgstatus = sis_cl_seg_sts_01-status_reason_descr_code_1.
        ENDCASE.
      ELSE.
        CALL METHOD invalid_value
          EXPORTING
            p_segment     = ls_sg4_sts
            p_field_name  = 'STATUS_CATEGORY_CODE_1'
            p_field_value = sis_cl_seg_sts_01-status_category_code_1.
      ENDIF.

      IF NOT g_error_in IS INITIAL. EXIT. ENDIF.
    ENDLOOP.

*     no STS-segment
    IF sy-subrc <> 0.

*       get service type for sender
      CALL METHOD get_service_type
        EXPORTING
          x_serviceid    = x_sender
        IMPORTING
          xy_servtype    = lv_servtype_sender
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

*       get service type for receiver
      CALL METHOD get_service_type
        EXPORTING
          x_serviceid    = x_receiver
        IMPORTING
          xy_servtype    = lv_servtype_receiver
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.

*       both must be supplier
      IF  lv_servtype_sender = co_servrole_supplier
      AND lv_servtype_receiver = co_servrole_supplier.

        y_msg-msgdata-transreason =
                 if_isu_ide_switch_constants=>co_transreason_switch.

      ENDIF.
    ENDIF.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

*     The Flag of Forced Deregistration
    DATA: lv_flag_forcdereg  TYPE boolean.

*     Check If Incoming Message is relevant to Forced Deregistration
    CALL METHOD /idexge/cl_isu_forcdereg_wf=>identify_forcdereg
      EXPORTING
        iv_sender      = x_sender
        iv_receiver    = x_receiver
        iv_msgcategory = y_msg-msgdata-category
        iv_transreason = y_msg-msgdata-transreason
        iv_msgstatus   = y_msg-msgdata-msgstatus
      IMPORTING
        ev_forcdereg   = lv_flag_forcdereg
      EXCEPTIONS
        OTHERS         = 1.
    IF ( sy-subrc = 0 ) AND ( NOT lv_flag_forcdereg IS INITIAL ).
*       In case of forced deregistration,
*       change the transaction reason to GE1 (Forced Deregistration)
*    y_msg-msgdata-transreason =
*        if_isu_ide_switch_constants=>co_transreason_force_moveout.
    ENDIF.

* >>> IDEX-GE: Forced Deregistration

**<<IDE_2<<sts_3

  ENDMETHOD.


  METHOD proc_sg6_rff_cs.
    DATA: ls_sg6_rff TYPE edidd,
          lt_sg6_rff TYPE edidd_tt.
    DATA: ls_sdata      TYPE edi_sdata.
    DATA:
      ls_msgdata_comm TYPE eideswtmsgdataco,
      lt_msgdata_comm TYPE teideswtmsgdataco.
    DATA:
        ls_msg  TYPE eideswtmsgpod.
*n>>IDE_1>>rff_9

    CALL METHOD me->get_segments_sg6_rff
      EXPORTING
        iv_parent_segnum = x_segnum
      IMPORTING
        et_sg6_rff       = lt_sg6_rff.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_sg6_rff INTO ls_sg6_rff.
      CHECK g_error_in IS INITIAL.
      sis_cl_seg_rff_09 = ls_sg6_rff-sdata.

      CASE sis_cl_seg_rff_09-reference_code_qualifier.

        WHEN cl_isu_datex_co=>co_rff_vdew_meter.
*           meter number
          y_msg-msgdata-meternr = sis_cl_seg_rff_09-reference_identifier.
* >>> IDEXGE-SP05 Inventory List
* For multiple devices in installation
          ls_msgdata_comm-commentnum = sy-tabix.
          ls_msgdata_comm-commenttag = co_commtag_dev.
          ls_msgdata_comm-commenttxt = sis_cl_seg_rff_09-reference_identifier.
          APPEND ls_msgdata_comm TO lt_msgdata_comm.
* <<< IDEXGE-SP05 Inventory List
        WHEN cl_isu_datex_co=>co_rff_vdew_reference   "TN
          OR gc_rff_ref_preceding_msg.     "Reference number of a preceding message

          ls_msg = y_msg.
          ls_msg-msgdata-idrefnr = sis_cl_seg_rff_09-reference_identifier.

*-->Reversal will use idrefnr to get the original MOVEIN AND OUT DATE
          CALL METHOD me->get_reversed_idoc
            CHANGING
              cs_msg         = ls_msg
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                       RAISING error_occurred.
          ENDIF.

          IF sis_cl_seg_rff_09-reference_code_qualifier = gc_rff_ref_preceding_msg.
            ls_msg-msgdata-idrefnr = y_msg-msgdata-idrefnr.
          ENDIF.

          y_msg = ls_msg.
          y_msg-msgdata-referencenumber = sis_cl_seg_rff_09-reference_identifier.
*<--End of reversal change

        WHEN /idexgg/cl_isu_co=>co_rff_g06.
* target network point
          IF /idexgg/cl_isu_cust_select=>select_db_settings_active( ) = /idexgg/cl_isu_co=>co_idexgg_active.
            y_msg-msgdata-nwp_target = sis_cl_seg_rff_09-reference_identifier.
          ENDIF.
        WHEN /idexgg/cl_isu_co=>co_rff_g07.
* target market area
          IF /idexgg/cl_isu_cust_select=>select_db_settings_active( ) = /idexgg/cl_isu_co=>co_idexgg_active.
            y_msg-msgdata-targ_market_area = sis_cl_seg_rff_09-reference_identifier.
          ENDIF.
*n>>IDE_1>>rff_9>>DTM_4
*
**<<IDE_1<<rff_9<<DTM_4
        WHEN 'Z07'.
          y_msg-msgdata-/idexge/rej_res = sis_cl_seg_rff_09-reference_identifier.

        WHEN OTHERS.
*           further references are not considered
      ENDCASE.

    ENDLOOP.

* >>> IDEXGE-SP05 Inventory List
    IF lines( lt_msgdata_comm ) > 1.
      y_msg-msgdatacomment = lt_msgdata_comm.
    ENDIF.
* <<< IDEXGE-SP05 Inventory List

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
**<<IDE_1<<rff_9

  ENDMETHOD.


  METHOD proc_sg7_cci_cav_cs.
    DATA: ls_sg7_cci TYPE edidd,
          lt_sg7_cci TYPE edidd_tt.

    DATA: ls_sg7_cav TYPE edidd,
          lt_sg7_cav TYPE edidd_tt.

    DATA: lv_resid_bp TYPE edi_sdata.

*n>>IDE_2>>cci_3
    CALL METHOD me->get_segments_sg7_cci
      EXPORTING
        iv_parent_segnum = x_segnum
      IMPORTING
        et_sg7_cci       = lt_sg7_cci.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_sg7_cci INTO ls_sg7_cci.
      CHECK g_error_in IS INITIAL.
      REFRESH lt_sg7_cav.
      sis_cl_seg_cci_01 = ls_sg7_cci-sdata.
*       ... = sis_cl_seg_cci_01- ...
      CASE sis_cl_seg_cci_01-characteristic_descr_code.
        WHEN cl_isu_datex_co=>co_cci_vdew_slp                 "E01 (SLP)
*>>>Add in UTILMD 4.2b
          OR cl_isu_datex_co=>co_cci_vdew_alp.                "Z10 (ALP)
*<<<Add in UTILMD 4.2b
*           standard profile assigned
*n>>IDE_1>>cci_3>>CAV_1
          CALL METHOD me->get_segments_sg7_cav
            EXPORTING
              iv_parent_segnum = ls_sg7_cci-segnum
            IMPORTING
              et_sg7_cav       = lt_sg7_cav.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

          LOOP AT lt_sg7_cav INTO ls_sg7_cav.

            sis_cl_seg_cav_01 = ls_sg7_cav-sdata.
*             ... = sis_cl_seg_cav_01- ...
            y_msg-msgdata-metmethod =
               cl_isu_datex_co=>co_cav_vdew_slp.
            y_msg-msgdata-/idexge/ext_prof =
               sis_cl_seg_cav_01-charac_value_descr_code.
            y_msg-msgdata-/idexge/clagprof =
               sis_cl_seg_cav_01-code_list_resp_agency_code.
            y_msg-msgdata-profile = sis_cl_seg_cav_01-charac_value_descr_code.

            IF NOT g_error_in IS INITIAL. EXIT. ENDIF.
          ENDLOOP.

          IF NOT g_error_in IS INITIAL. EXIT. ENDIF.
*>>>>>>>>>>>>>>>>>>>>Added by SP09
        WHEN co_cci_analytical_tlp.  "Z29 (TLP analytical)

          IF y_msg-msgdata-metmethod = cl_isu_datex_co=>co_cav_vdew_slp."another slp profile exists

            CALL METHOD me->get_segments_sg7_cav
              EXPORTING
                iv_parent_segnum = ls_sg7_cci-segnum
              IMPORTING
                et_sg7_cav       = lt_sg7_cav.

            IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

            LOOP AT lt_sg7_cav INTO ls_sg7_cav.

              sis_cl_seg_cav_01 = ls_sg7_cav-sdata.
*             ... = sis_cl_seg_cav_01- ...
              y_msg-msgdata-/idexge/ext_tlp = sis_cl_seg_cav_01-charac_value_descr_code.

              IF NOT g_error_in IS INITIAL. EXIT. ENDIF.
            ENDLOOP.
          ENDIF.

          IF NOT g_error_in IS INITIAL. EXIT. ENDIF.
*<<<<<<<<<<<<<<<<<<<<End added by SP09
**<<IDE_1<<cci_3<<CAV_1
        WHEN cl_isu_datex_co=>co_cci_vdew_metmethod.  "E02
*           metering method assigned
*n>>IDE_1>>cci_3>>CAV_1
          CALL METHOD me->get_segments_sg7_cav
            EXPORTING
              iv_parent_segnum = ls_sg7_cci-segnum
            IMPORTING
              et_sg7_cav       = lt_sg7_cav.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

          LOOP AT lt_sg7_cav INTO ls_sg7_cav.
            CHECK g_error_in IS INITIAL.
            sis_cl_seg_cav_01 = ls_sg7_cav-sdata.
*             ... = sis_cl_seg_cav_01- ...
            CASE sis_cl_seg_cav_01-charac_value_descr_code.
              WHEN cl_isu_datex_co=>co_cav_vdew_metmethod.
                y_msg-msgdata-metmethod =
                   sis_cl_seg_cav_01-charac_value_descr_code.
              WHEN cl_isu_datex_co=>co_cav_vdew_slp.
                y_msg-msgdata-metmethod =
                   sis_cl_seg_cav_01-charac_value_descr_code.
            ENDCASE.
          ENDLOOP.

          IF NOT g_error_in IS INITIAL. EXIT. ENDIF.
**<<IDE_1<<cci_3<<CAV_1
        WHEN co_cat_customer OR co_cat_nonresident_cust.  "Z15 or Z18
*           Haushaltskunde gem?? EnWG
          CALL METHOD set_cat_customer
            EXPORTING
              p_ext_ui              = y_msg-ext_ui
              p_msgdata_moveindate  = y_msg-msgdata-moveindate
              p_msgdata_moveoutdate = y_msg-msgdata-moveoutdate
            EXCEPTIONS
              error_occurred        = 1
              OTHERS                = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
          ENDIF.

*   Haushaltskunde in die Nachrichtenden schreiben
          lv_resid_bp = ls_sg7_cci-sdata.

          SHIFT lv_resid_bp LEFT DELETING LEADING space.

          y_msg-msgdata-zzhaushalt = lv_resid_bp.
          y_msg-msgdata-/idexge/resid_bp = lv_resid_bp+1(2).

********************Modification for Legal Change************
        WHEN co_zgv_customer.  "ZGV
          CALL METHOD set_customer_group
            EXPORTING
              p_pod_exgroup         = co_zgv_customer
              p_ext_ui              = y_msg-ext_ui
              p_msgdata_moveindate  = y_msg-msgdata-moveindate
              p_msgdata_moveoutdate = y_msg-msgdata-moveoutdate
            EXCEPTIONS
              error_occurred        = 1
              OTHERS                = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
          ENDIF.

        WHEN co_cat_customer_gabi. "Z17
          y_msg-msgdata-alloc_group = sis_cl_seg_cci_01-characteristic_descr_code.
*********************** UTILMD 4.1g2 ************************
**<<IDE_1<<cci_3<<CAV_1
        WHEN co_cci_press_level. "Y01
          CALL METHOD me->get_segments_sg7_cav
            EXPORTING
              iv_parent_segnum = ls_sg7_cci-segnum
            IMPORTING
              et_sg7_cav       = lt_sg7_cav.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

          LOOP AT lt_sg7_cav INTO ls_sg7_cav.
            sis_cl_seg_cav_01 = ls_sg7_cav-sdata.
            y_msg-msgdata-pressurelevel = sis_cl_seg_cav_01-charac_value_descr_code.
          ENDLOOP.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
*>>> Start of Add in UTILMD 4.2b
        WHEN co_cci_voltage_level. "E03
          CALL METHOD me->get_segments_sg7_cav
            EXPORTING
              iv_parent_segnum = ls_sg7_cci-segnum
            IMPORTING
              et_sg7_cav       = lt_sg7_cav.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

          LOOP AT lt_sg7_cav INTO ls_sg7_cav.
            sis_cl_seg_cav_01 = ls_sg7_cav-sdata.
            y_msg-msgdata-/idexge/vol_qual = sis_cl_seg_cav_01-charac_value_descr_code.
          ENDLOOP.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
        WHEN co_cci_measure_level. "E04
          CALL METHOD me->get_segments_sg7_cav
            EXPORTING
              iv_parent_segnum = ls_sg7_cci-segnum
            IMPORTING
              et_sg7_cav       = lt_sg7_cav.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

          LOOP AT lt_sg7_cav INTO ls_sg7_cav.
            sis_cl_seg_cav_01 = ls_sg7_cav-sdata.
            y_msg-msgdata-/idexge/meavolt = sis_cl_seg_cav_01-charac_value_descr_code.
          ENDLOOP.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
*<<< End of Add in UTILMD 4.2b
**<<IDE_1<<cci_3<<CAV_1
        WHEN co_cci_qual_gas. "Y02
          CALL METHOD me->get_segments_sg7_cav
            EXPORTING
              iv_parent_segnum = ls_sg7_cci-segnum
            IMPORTING
              et_sg7_cav       = lt_sg7_cav.

          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

          LOOP AT lt_sg7_cav INTO ls_sg7_cav.
            sis_cl_seg_cav_01 = ls_sg7_cav-sdata.
            y_msg-msgdata-gasquality = sis_cl_seg_cav_01-charac_value_descr_code.
            IF sis_cl_seg_cav_01-charac_value_descr_code = co_cci_qual_h_gas.
              y_msg-msgdata-gasquality = /idexgg/cl_isu_co=>co_gas_quality_high.
            ELSEIF sis_cl_seg_cav_01-charac_value_descr_code = co_cci_qual_l_gas .
              y_msg-msgdata-gasquality = /idexgg/cl_isu_co=>co_gas_quality_low.
            ELSEIF sis_cl_seg_cav_01-charac_value_descr_code = co_cci_qual_ll_gas .
              y_msg-msgdata-gasquality = /idexgg/cl_isu_co=>co_gas_quality_ll.
            ENDIF.
          ENDLOOP.

          IF NOT g_error_in IS INITIAL. EXIT. ENDIF.

*********************************************************************************************

*<<IDE_1<<cci_3<<CAV_1
        WHEN OTHERS.
*>>> Added in UTILMD 4.3 for Time Series Category
*SP12 move to SG10 CCI-CAV
*        IF sis_cl_seg_cci_01-class_type_code = co_cci_class_structure.
*          y_msg-msgdata-/idexge/cci_tsca = sis_cl_seg_cci_01-characteristic_descr_code.
*          CALL METHOD me->get_segments_sg7_cav
*            EXPORTING
*              iv_parent_segnum = ls_sg7_cci-segnum
*            IMPORTING
*              et_sg7_cav       = lt_sg7_cav.
*
*          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
*
*          LOOP AT lt_sg7_cav INTO ls_sg7_cav.
*            sis_cl_seg_cav_01 = ls_sg7_cav-sdata.
*            y_msg-msgdata-/idexge/tstype = sis_cl_seg_cav_01-charac_value_descr_code.
*          ENDLOOP.
*          IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
*        ENDIF.
*<<< Added in UTILMD 4.3 for Time Series Category
      ENDCASE.
*    exit_err.
    ENDLOOP.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.
**<<IDE_1<<cci_3
  ENDMETHOD.


  METHOD proc_sg8_pia_cs.
    DATA: ls_sg8_pia TYPE edidd,
          lt_sg8_pia TYPE edidd_tt.

    CALL METHOD me->get_segments_sg8_pia
      EXPORTING
        iv_parent_segnum = iv_parent_segnum
      IMPORTING
        et_sg8_pia       = lt_sg8_pia.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_sg8_pia  INTO ls_sg8_pia .
      CHECK g_error_in IS INITIAL.
      sis_cl_seg_pia_02 = ls_sg8_pia-sdata.
*         ... = sis_cl_seg_qty_01- ...
      CASE sis_cl_seg_pia_02-product_ident_code_qualifier.
        WHEN '5'.
          es_swt_msgpod-msgdata-zzobiskennzf =  sis_cl_seg_pia_02-item_identifier_1.
          es_swt_msgpod-msgdata-zzbetrag_konzessionsabgabe = sis_cl_seg_pia_02-code_list_ident_code_3.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD proc_sg9_qty_cs.

    DATA: ls_sg9_qty TYPE edidd,
          lt_sg9_qty TYPE edidd_tt.

    CALL METHOD me->get_segments_sg9_qty
      EXPORTING
        iv_parent_segnum = iv_parent_segnum
      IMPORTING
        et_sg9_qty       = lt_sg9_qty.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

    LOOP AT lt_sg9_qty INTO ls_sg9_qty.
      CHECK g_error_in IS INITIAL.
      sis_cl_seg_qty_01 = ls_sg9_qty-sdata.
*         ... = sis_cl_seg_qty_01- ...
      CASE sis_cl_seg_qty_01-quantity_type_code_qualifier.
        WHEN cl_isu_datex_co=>co_qty_vdew_yearcons.
          REPLACE ALL OCCURRENCES OF '#' IN sis_cl_seg_qty_01-quantity WITH '0'.
          CALL METHOD /idexge/cl_amount_convert_in=>convert_to_internal
            EXPORTING
              is_una        = sis_cl_seg_una_01
              iv_input      = sis_cl_seg_qty_01-quantity
            RECEIVING
              rv_output     = es_swt_msgpod-msgdata-progyearcons
            EXCEPTIONS
              convert_error = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.

          es_swt_msgpod-msgdata-consunit = sis_cl_seg_qty_01-measurement_unit_code.
*********************** UTILMD 4.1g2 *******************************
        WHEN co_qty_consid_demand.
          REPLACE ALL OCCURRENCES OF '#' IN sis_cl_seg_qty_01-quantity WITH '0'.
          CALL METHOD /idexge/cl_amount_convert_in=>convert_to_internal
            EXPORTING
              is_una        = sis_cl_seg_una_01
              iv_input      = sis_cl_seg_qty_01-quantity
            RECEIVING
              rv_output     = es_swt_msgpod-msgdata-maxdemand
            EXCEPTIONS
              convert_error = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.

          es_swt_msgpod-msgdata-capunit = sis_cl_seg_qty_01-measurement_unit_code.
          IF es_swt_msgpod-msgdata-capunit = cl_isu_datex_co=>co_qty_vdew_kw.
            es_swt_msgpod-msgdata-capunit = co_qty__kw.
          ENDIF.
        WHEN co_qty_cust_usage_factor.
          REPLACE ALL OCCURRENCES OF '#' IN sis_cl_seg_qty_01-quantity WITH '0'.
          CALL METHOD /idexge/cl_amount_convert_in=>convert_to_internal
            EXPORTING
              is_una        = sis_cl_seg_una_01
              iv_input      = sis_cl_seg_qty_01-quantity
            RECEIVING
              rv_output     = es_swt_msgpod-msgdata-usagefactor
            EXCEPTIONS
              convert_error = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.

          IF es_swt_msgpod-msgdata-consunit IS INITIAL.
            es_swt_msgpod-msgdata-consunit = sis_cl_seg_qty_01-measurement_unit_code.
          ENDIF.
*********************** End of UTILMD 4.1g2 ************************

        WHEN co_qty_settled_energy_amount. "'Z07' Mabis settled energy amount
          CALL METHOD /idexge/cl_amount_convert_in=>convert_to_internal
            EXPORTING
              is_una        = sis_cl_seg_una_01
              iv_input      = sis_cl_seg_qty_01-quantity
            RECEIVING
              rv_output     = es_swt_msgpod-msgdata-maxdemand
            EXCEPTIONS
              convert_error = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.
          es_swt_msgpod-msgdata-consunit = sis_cl_seg_qty_01-measurement_unit_code.
        WHEN co_qty_annual_consumption. "'265' annual consumption forecast for specific work for day parameter-dependent service location
          CALL METHOD /idexge/cl_amount_convert_in=>convert_to_internal
            EXPORTING
              is_una        = sis_cl_seg_una_01
              iv_input      = sis_cl_seg_qty_01-quantity
            RECEIVING
              rv_output     = es_swt_msgpod-msgdata-/idexge/progyrsp
            EXCEPTIONS
              convert_error = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.
          es_swt_msgpod-msgdata-consunit = sis_cl_seg_qty_01-measurement_unit_code.

        WHEN 'Z09'. " Z09 - Vorjahresverbrauch
          CALL METHOD /idexge/cl_amount_convert_in=>convert_to_internal
            EXPORTING
              is_una        = sis_cl_seg_una_01
              iv_input      = sis_cl_seg_qty_01-quantity
            RECEIVING
              rv_output     = es_swt_msgpod-msgdata-progyearcons
            EXCEPTIONS
              convert_error = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.

          es_swt_msgpod-msgdata-consunit = sis_cl_seg_qty_01-measurement_unit_code.
        WHEN OTHERS.
*     further references are not considered
      ENDCASE.
    ENDLOOP.

    IF NOT g_error_in IS INITIAL. RETURN. ENDIF.

  ENDMETHOD.


  METHOD set_seg_reversal.
    DATA:
      ls_sg5_loc  TYPE /idxgc/e1_loc_01,
      ls_sg12_nad TYPE /idxgc/e1_nad_02,
      ls_sg6_rff  TYPE /idxgc/e1_rff_02,
      ls_sg_unt   TYPE /idxgc/e1_unt_01,
      ls_edidd    TYPE edidd,
      lv_tabix    TYPE sytabix.

    CHECK iv_transreason = 'E05'.
* DELETE cs_idoc-data WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_dtm_01  "20130417_DND DEL
    DELETE cs_idoc-data WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_tax_01
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_dtm_03  "20130417_DND INS
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_agr_01
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_loc_01  "20130417_DND INS
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_loc_02  "20130417_DND INS
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_cci_01
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_01
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_seq_01
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_pia_01
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_qty_01
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_cci_02
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_cav_02
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_nad_04  "20130417_DND INS
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_rff_10  "20130422_DND INS
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_cci_03  "20130422_DND INS
                          OR  segnam = /idxgc/if_constants_ide=>gc_segmtp_pia_02  "20130422_DND INS
    .

** SG5-LOC can only have the value according to field: 5b
*  LOOP AT cs_idoc-data INTO ls_edidd
*                       WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_loc_01.
*    lv_tabix = sy-tabix.
*    ls_sg5_loc = ls_edidd-sdata.
*    IF ls_sg5_loc-location_func_code_quali <> cl_isu_datex_co=>co_loc_vdew_pod.
*      DELETE cs_idoc-data INDEX lv_tabix.
*    ENDIF.
*  ENDLOOP.
*
*  CLEAR:
*  ls_edidd,
*  lv_tabix.
*
** SG12-NAD can only have the value according to field: 4a
*  LOOP AT cs_idoc-data INTO ls_edidd
*                       WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_nad_02.
*    lv_tabix = sy-tabix.
*    ls_sg12_nad = ls_edidd-sdata.
*    IF ls_sg12_nad-party_function_code_qualifier <> cl_isu_datex_co=>co_nad_vdew_premise.
*      DELETE cs_idoc-data INDEX lv_tabix.
*    ENDIF.
*  ENDLOOP.
*
*  CLEAR:
*  ls_edidd,
*  lv_tabix.

* RFF can only contai the value according to field:
    LOOP AT cs_idoc-data INTO ls_edidd
                         WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_rff_02.
      lv_tabix = sy-tabix.
      ls_sg6_rff = ls_edidd-sdata.
      IF ls_sg6_rff-reference_code_qualifier <> cl_isu_datex_co=>co_rff_vdew_reference
         AND ls_sg6_rff-reference_code_qualifier <> gc_rff_ref_preceding_msg.
        DELETE cs_idoc-data INDEX lv_tabix.
      ENDIF.
    ENDLOOP.

    lv_tabix = lines( cs_idoc-data ) .
    lv_tabix = lv_tabix - 3.
    LOOP AT cs_idoc-data INTO ls_edidd
                         WHERE segnam = /idxgc/if_constants_ide=>gc_segmtp_unt_01.
      ls_sg_unt = ls_edidd-sdata.
      ls_sg_unt-number_of_segments_in_message = lv_tabix.
      ls_sg_unt-number_of_segments_in_message =  condense( ls_sg_unt-number_of_segments_in_message ) .
      ls_edidd-sdata = ls_sg_unt .
      lv_tabix = lv_tabix + 2.
      MODIFY cs_idoc-data INDEX lv_tabix
                          FROM ls_edidd.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
