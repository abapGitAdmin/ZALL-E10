class ZCL_PRICAT_11_CL definition
  public
  inheriting from /IDEXGE/CL_PRICAT_10A_CL
  create public .

public section.

  constants AC_LIN_ITEM_NO_METER_POINT_OP type CHAR35 value '9990001000798' ##NO_TEXT.
  constants AC_BGM_Z32 type CHAR3 value 'Z32' ##NO_TEXT.
  constants AC_MESSAGE_DATE_VAL_PER_START type CHAR3 value '157' ##NO_TEXT.
  constants AC_PRICE_KEY_GROUP_Z06 type /IDXGL/DE_POS_PRICE_KEY_GROUP value 'Z06' ##NO_TEXT.
  constants AC_PRODUCT_ID_1 type CHAR3 value '1' ##NO_TEXT.

  methods CONSTRUCTOR .

  methods ISU_COMPR_PRICAT_IN
    redefinition .
  methods ISU_COMPR_PRICAT_OUT
    redefinition .
protected section.

  data AS_PRICE_LIST type ZIDEXGE_S_EQS_PLIST .

  methods ISU_COMPR_PRICAT_IN_Z32
    importing
      !IS_IDOC_CONTRL type EDIDC
      !IT_IDOC_DATA type EDIDD_TT
    exporting
      !ES_IDOC_STATUS type BDIDOCSTAT
    exceptions
      ERROR_OCCURRED .
  methods FILL_SG1_RFF
    exceptions
      ERROR_OCCURRED .
  methods FILL_MOS_SG36_IMD
    importing
      !IS_PRICES_LIST type ZIDEXGE_S_EQS_PLIST
    exceptions
      ERROR_OCCURRED .
  methods FILL_MOS_SG36_PIA
    importing
      !IS_COMPEN_PRICES type /IDEXGE/S_EQS_CPRICE
      !IS_PRICES_LIST type ZIDEXGE_S_EQS_PLIST
    exceptions
      ERROR_OCCURRED .
  methods FILL_MOS_SG40_PRI
    importing
      !IS_PRICES_LIST type ZIDEXGE_S_EQS_PLIST
    exceptions
      ERROR_OCCURRED .
  methods PROC_MOS_SG36_IMD
    importing
      !IS_SDATA type EDI_SDATA
    exceptions
      ERROR_OCCURRED .
  methods PROC_MOS_SG36_LIN
    importing
      !IS_SDATA type EDI_SDATA
    exceptions
      ERROR_OCCURRED .
  methods PROC_MOS_SG36_PRI
    importing
      !IS_SDATA type EDI_SDATA
    exceptions
      ERROR_OCCURRED .
  methods PROC_MOS_SG36_PIA
    importing
      !IS_SDATA type EDI_SDATA
    exceptions
      ERROR_OCCURRED .

  methods FILL_BGM
    redefinition .
  methods FILL_DTM
    redefinition .
  methods FILL_IDOC_CONTROL
    redefinition .
  methods FILL_SG36_LIN
    redefinition .
  methods FILL_UNB
    redefinition .
  methods PROC_DTM
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_PRICAT_11_CL IMPLEMENTATION.


  METHOD CONSTRUCTOR.
    super->constructor( ).
    siv_assigned_code_vdew  = '1.1'.
    siv_idoc_type           = zif_constants_idx=>ac_zidoctp_pricat_02.
  ENDMETHOD.


  METHOD fill_bgm.
    CLEAR sis_cl_seg_bgm2.
    sis_cl_seg_bgm2-name            = ac_bgm_z32. "Preisblatt Messstellenbetrie
    sis_cl_seg_bgm2-documentnumber  = siv_refno.             "global set in fill_unb
    sis_cl_seg_bgm2-documentfunc    = co_documentfunc_orig_msg. "9

    append_idoc_seg( sis_cl_seg_bgm2 ).
  ENDMETHOD.


  METHOD fill_dtm.
* Document Date
    CLEAR sis_cl_seg_dtm1.
    sis_cl_seg_dtm1-datumqualifier = co_message_dateq.         "137
    CONCATENATE sy-datum sy-uzeit(4) INTO sis_cl_seg_dtm1-datum.
    sis_cl_seg_dtm1-format         = co_dtm_due_date_format.   "203
    append_idoc_seg( sis_cl_seg_dtm1 ).

    IF NOT is_compen_prices-val_start_date IS INITIAL.
      CLEAR sis_cl_seg_dtm1.
      sis_cl_seg_dtm1-datumqualifier  = ac_message_date_val_per_start.
      sis_cl_seg_dtm1-datum           = is_compen_prices-val_start_date && '000000'.
      sis_cl_seg_dtm1-format          = co_dtm_ts_version.          "204
      append_idoc_seg( sis_cl_seg_dtm1 ).
    ENDIF.
  ENDMETHOD.


  method FILL_IDOC_CONTROL.
DATA ls_edk13 TYPE edk13.
*  DATA ls_edp13 TYPE edp13.
*  DATA ls_mescod TYPE /idxgc/t_mescod.

  CLEAR es_idoc_control.
  es_idoc_control-rcvprn = iv_receiver.
  es_idoc_control-rcvprt = /idxgc/if_constants_ide=>gc_partner_type_sp.
  es_idoc_control-mestyp = /idxgc/if_constants_ide=>gc_msgtp_pricat.
*  TRY.
*    ls_mescod = /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_mescod(
*                iv_key_date = sy-datum
*                iv_mestyp   = es_idoc_control-mestyp ).
*    CATCH /idxgc/cx_config_error.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                 RAISING error_occurred.
*  ENDTRY.
*  siv_assigned_code_vdew = ls_mescod-assocode.
  es_idoc_control-mescod = '001'. "ls_mescod-mescod.
  ls_edk13-rcvprn = iv_receiver.
  ls_edk13-rcvprt = /idxgc/if_constants_ide=>gc_partner_type_sp.
  ls_edk13-mestyp = /idxgc/if_constants_ide=>gc_msgtp_pricat.
  ls_edk13-mescod = es_idoc_control-mescod.

* check out the EDI partner profile customizing first.
*  CALL FUNCTION 'EDI_PARTNER_APPL_READ_OUT'
*    EXPORTING
*      rec_edk13 = ls_edk13
*    IMPORTING
*      rec_edp13 = ls_edp13
*    EXCEPTIONS
*      OTHERS    = 1.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*            RAISING error_occurred.
*  ENDIF.
  es_idoc_control-idoctp = siv_idoc_type.
  es_idoc_control-cimtyp = abap_false. "ls_edp13-cimtyp.
  es_idoc_control-sndpfc = abap_false.
  es_idoc_control-sndprn = abap_false.
  es_idoc_control-sndprt = abap_false.
  es_idoc_control-rcvpfc = abap_false.
  endmethod.


  METHOD fill_mos_sg36_imd.
    DATA: lv_price_class_desc     TYPE zmosb_class_txt-price_class_desc,
          lv_price_class_desc_add TYPE zmosb_pc_add_txt-price_class_add_desc.

    CLEAR sis_cl_seg_imd1.

    IF is_prices_list-price_class = 'Z26' OR is_prices_list-price_class = 'Z27'. "Wandler oder Steuergerät
      sis_cl_seg_imd1-formatcode = 'X'. "Code und Text
    ELSE.
      sis_cl_seg_imd1-formatcode = 'C'. " Code
    ENDIF.

    sis_cl_seg_imd1-characode       = is_prices_list-price_class.
*    sis_cl_seg_imd1-charaagencycode = '293'.

    IF is_prices_list-price_class = 'Z26'. "Wandler
      sis_cl_seg_imd1-descode = is_prices_list-price_class_add.
    ENDIF.

    IF  sis_cl_seg_imd1-formatcode EQ 'X'.
      SELECT SINGLE price_class_desc FROM zmosb_class_txt INTO lv_price_class_desc
        WHERE price_class     = is_prices_list-price_class.

      SELECT SINGLE price_class_add_desc FROM zmosb_pc_add_txt INTO lv_price_class_desc_add
        WHERE price_class     = is_prices_list-price_class
          AND price_class_add = is_prices_list-price_class_add.


      IF lv_price_class_desc_add IS INITIAL.
        sis_cl_seg_imd1-itemdes1 = lv_price_class_desc.
      ELSE.
        sis_cl_seg_imd1-itemdes1 = lv_price_class_desc && ',' && | | && lv_price_class_desc_add .
      ENDIF.
    ENDIF.
    append_idoc_seg( sis_cl_seg_imd1 ).

  ENDMETHOD.


  METHOD fill_mos_sg36_pia.
    sis_cl_seg_pia1-product_id    = ac_product_id_1.
    sis_cl_seg_pia1-item_number_1 = is_compen_prices-price_catalogue_id && '-' &&
                                    is_compen_prices-pricat_version && '-' &&
                                    is_prices_list-price_class.

    IF NOT is_prices_list-price_class_add IS INITIAL.
      sis_cl_seg_pia1-item_number_1 = sis_cl_seg_pia1-item_number_1 && '-' && is_prices_list-price_class_add.
    ENDIF.

    sis_cl_seg_pia1-item_number_type_1 = ac_price_key_group_z06. " Preisschlüsselstamm

    append_idoc_seg( sis_cl_seg_pia1 ).
  ENDMETHOD.


  METHOD fill_mos_sg40_pri.
    IF NOT is_prices_list-price_curr IS INITIAL.
      CLEAR sis_cl_seg_pri1.
      sis_cl_seg_pri1-price_qualifier = co_pri_calculated. "CAL
      sis_cl_seg_pri1-price           = is_prices_list-price.
      SHIFT sis_cl_seg_pri1-price LEFT DELETING LEADING space.
      sis_cl_seg_pri1-measure_unit    = 'ANN'.

      append_idoc_seg( sis_cl_seg_pri1 ).
    ENDIF.
  ENDMETHOD.


  METHOD FILL_SG1_RFF.
" TODO: RFF+ACW

    " RFF+Z13: Prüfidentifikator
    CLEAR sis_cl_seg_rff_07.
    sis_cl_seg_rff_07-reference_code_qualifier = co_rff_refnr_z13.
    sis_cl_seg_rff_07-reference_identifier     = '27002'.
    append_idoc_seg( sis_cl_seg_rff_07 ).

  ENDMETHOD.


  METHOD fill_sg36_lin.
    CLEAR sis_cl_seg_lin1.
    sis_cl_seg_lin1-line_item_number = iv_item_number.
    SHIFT sis_cl_seg_lin1-line_item_number LEFT DELETING LEADING space.
    sis_cl_seg_lin1-item_number = ac_lin_item_no_meter_point_op. "9990001000798
    sis_cl_seg_lin1-item_number_type = co_lin_item_number_type. "Z01'
    append_idoc_seg( sis_cl_seg_lin1 ).
  ENDMETHOD.


METHOD fill_unb.
  DATA: lv_codelist_type TYPE e_edmideextcodelistid,
        ls_eservprov     TYPE eservprov,
        lv_mpid_13       TYPE char13.

  CLEAR:
     sis_cl_seg_unb1.

* Get reference number for the whole IDOC
  CALL FUNCTION 'ISU_NUMBER_GET'
    EXPORTING
      object                      = cl_isu_datex_idoc_build=>co_isu_crefno
    IMPORTING
      number                      = siv_refno
    EXCEPTIONS
      no_range_number_found       = 1
      number_not_in_intervall     = 2
      interval_not_found          = 3
      quantity_is_0               = 4
      interval_te009_inconsistent = 5
      number_invalid              = 6
      interval_overflow           = 7
      OTHERS                      = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING error_occurred.
  ENDIF.

* Get sender external ID and Codelist Type
  CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
    EXPORTING
      x_serviceid = is_compen_prices-sender
    IMPORTING
      y_eservprov = ls_eservprov
    EXCEPTIONS
      not_found   = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING error_occurred.
  ENDIF.

  IF NOT ls_eservprov-externalid IS INITIAL.
    CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
      EXPORTING
        x_ext_idtyp     = ls_eservprov-externalidtyp
        x_idoc_control  = is_idoc_control
      IMPORTING
        y_extcodelistid = lv_codelist_type
      EXCEPTIONS
        not_supported   = 1
        error_occured   = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
    ENDIF.
  ENDIF.

* field length of transmitted MP-ID must not be longer than 13 char
  SHIFT ls_eservprov-externalid LEFT DELETING LEADING space.
  lv_mpid_13                  = ls_eservprov-externalid.
  sis_cl_seg_unb1-sender      = lv_mpid_13.
*<<<
  sis_cl_seg_unb1-sender_type = lv_codelist_type.
*>>>
  IF sis_cl_seg_unb1-sender_type IS INITIAL OR
    sis_cl_seg_unb1-sender_type = co_codelist_agency_vdew.
    sis_cl_seg_unb1-sender_type = co_unb_codelist_agency_vdew.
  ELSEIF sis_cl_seg_unb1-sender_type = co_codelist_agency_gs1.
    sis_cl_seg_unb1-sender_type = co_unb_codelist_agency_gs1.
  ELSEIF sis_cl_seg_unb1-sender_type = co_codelist_agency_dvgw.
    sis_cl_seg_unb1-sender_type = co_unb_codelist_agency_dvgw.
  ELSEIF sis_cl_seg_unb1-sender_type = co_codelist_agency_easee.
    sis_cl_seg_unb1-sender_type = co_unb_codelist_agency_easee.
  ELSEIF sis_cl_seg_unb1-sender_type = co_codelist_agency_etso.
    sis_cl_seg_unb1-sender_type = co_unb_codelist_agency_etso.
* end add
  ENDIF.

* Get receiver external ID and Codelist Type
  CLEAR ls_eservprov.

  CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
    EXPORTING
      x_serviceid = is_compen_prices-receiver
    IMPORTING
      y_eservprov = ls_eservprov
    EXCEPTIONS
      not_found   = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING error_occurred.
  ENDIF.

  IF NOT ls_eservprov-externalid IS INITIAL.
    CALL FUNCTION 'ISU_DATEX_IDENT_CODELIST'
      EXPORTING
        x_ext_idtyp     = ls_eservprov-externalidtyp
        x_idoc_control  = is_idoc_control
      IMPORTING
        y_extcodelistid = lv_codelist_type
      EXCEPTIONS
        not_supported   = 1
        error_occured   = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
    ENDIF.
  ENDIF.

* field length of transmitted MP-ID must not be longer than 13 char
  SHIFT ls_eservprov-externalid LEFT DELETING LEADING space.
  lv_mpid_13                    = ls_eservprov-externalid.
  sis_cl_seg_unb1-receiver      = lv_mpid_13.
*>>>
  sis_cl_seg_unb1-receiver_type = lv_codelist_type.
*<<<
  IF sis_cl_seg_unb1-receiver_type IS INITIAL OR
    sis_cl_seg_unb1-receiver_type = co_codelist_agency_vdew.
    sis_cl_seg_unb1-receiver_type = co_unb_codelist_agency_vdew.
  ELSEIF sis_cl_seg_unb1-receiver_type = co_codelist_agency_gs1.
    sis_cl_seg_unb1-receiver_type = co_unb_codelist_agency_gs1.
  ELSEIF sis_cl_seg_unb1-receiver_type = co_codelist_agency_dvgw.
    sis_cl_seg_unb1-receiver_type = co_unb_codelist_agency_dvgw.
  ELSEIF sis_cl_seg_unb1-receiver_type = co_codelist_agency_easee.
    sis_cl_seg_unb1-receiver_type = co_unb_codelist_agency_easee.
  ELSEIF sis_cl_seg_unb1-receiver_type = co_codelist_agency_etso.
    sis_cl_seg_unb1-receiver_type = co_unb_codelist_agency_etso.
* end add
  ENDIF.

  sis_cl_seg_unb1-syntax_ident   = co_isu_syntax_ident.
  sis_cl_seg_unb1-syntax_version = co_isu_syntax_version.
  sis_cl_seg_unb1-date_gen       = sy-datum+2(6).
  sis_cl_seg_unb1-time_gen       = sy-uzeit.

* Set IDoc number:
  sis_cl_seg_unb1-bulk_ref = siv_refno.
  append_idoc_seg( sis_cl_seg_unb1 ).
* UNB segment should not be counterred.
  siv_seg_count = siv_seg_count - 1.
ENDMETHOD.


  METHOD isu_compr_pricat_in.
    DATA: ls_bgm TYPE /idxgc/e1vdewbgm_2.
    FIELD-SYMBOLS: <ls_idoc_data> LIKE LINE OF it_idoc_data.

    READ TABLE it_idoc_data ASSIGNING <ls_idoc_data> WITH KEY segnam = /idxgc/if_constants_ide=>gc_segmtp_bgm2.
    IF sy-subrc <> 0.
      RAISE error_occurred.
    ENDIF.


    ls_bgm = <ls_idoc_data>-sdata.

    IF ls_bgm-name = ac_bgm_z32. "Preisblatt Messstellenbetrieb
      CALL METHOD isu_compr_pricat_in_z32
        EXPORTING
          is_idoc_contrl = is_idoc_contrl
          it_idoc_data   = it_idoc_data
        IMPORTING
          es_idoc_status = es_idoc_status
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   RAISING error_occurred.
      ENDIF.
    ELSE.
      CALL METHOD super->isu_compr_pricat_in
        EXPORTING
          is_idoc_contrl = is_idoc_contrl
          it_idoc_data   = it_idoc_data
        IMPORTING
          es_idoc_status = es_idoc_status
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   RAISING error_occurred.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD isu_compr_pricat_in_z32.
    DATA: ls_price_list TYPE zidexge_s_eqs_plist.

    init_in( ).

* Process Idoc data
    LOOP AT it_idoc_data INTO sis_idoc_line.
      CASE sis_idoc_line-segnam.
        WHEN /idxgc/if_constants_ide=>gc_segmtp_una1.
          CALL METHOD me->proc_una( sis_idoc_line-sdata ).

        WHEN /idxgc/if_constants_ide=>gc_segmtp_unb1.
          CALL METHOD me->proc_unb
            EXPORTING
              is_sdata       = sis_idoc_line-sdata
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                       RAISING error_occurred.
          ENDIF.

        WHEN /idxgc/if_constants_ide=>gc_segmtp_bgm2.
          CALL METHOD me->proc_bgm( sis_idoc_line-sdata ).

*     Set observation month
        WHEN /idxgc/if_constants_ide=>gc_segmtp_dtm1.
          CALL METHOD me->proc_dtm
            EXPORTING
              is_sdata       = sis_idoc_line-sdata
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                       RAISING error_occurred.
          ENDIF.

*     Set observation month
        WHEN /idxgc/if_constants_ide=>gc_segmtp_nad7.
          CALL METHOD me->proc_sg2_nad
            EXPORTING
              is_sdata       = sis_idoc_line-sdata
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                       RAISING error_occurred.
          ENDIF.

*     Set the currency
        WHEN /idxgc/if_constants_ide=>gc_segmtp_cux1.
          CALL METHOD me->proc_sg6_cux
            EXPORTING
              is_sdata = sis_idoc_line-sdata.

*      Set product group
        WHEN /idxgc/if_constants_ide=>gc_segmtp_pgi1.
          CALL METHOD me->proc_sg17_pgi
            EXPORTING
              is_sdata = sis_idoc_line-sdata.

*     Set price
        WHEN /idxgc/if_constants_ide=>gc_segmtp_lin1.
          CALL METHOD me->proc_mos_sg36_lin
            EXPORTING
              is_sdata       = sis_idoc_line-sdata
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.

        WHEN /idxgc/if_constants_ide=>gc_segmtp_pia1.
          CALL METHOD me->proc_mos_sg36_pia
            EXPORTING
              is_sdata       = sis_idoc_line-sdata
            EXCEPTIONS
              error_occurred = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.

        WHEN /idxgc/if_constants_ide=>gc_segmtp_imd1.
          CALL METHOD me->proc_mos_sg36_imd
            EXPORTING
              is_sdata = sis_idoc_line-sdata.

        WHEN /idxgc/if_constants_ide=>gc_segmtp_pri1.
          CALL METHOD me->proc_mos_sg36_pri
            EXPORTING
              is_sdata = sis_idoc_line-sdata.

        WHEN /idxgc/if_constants_ide=>gc_segm_unt_01.

      ENDCASE.
    ENDLOOP.

*  CALL BADI method
*    TRY.
*        IF gref_badi_isu_pricat_in IS INITIAL.
*          GET BADI gref_badi_isu_pricat_in.
*        ENDIF.
*
*        CALL BADI gref_badi_isu_pricat_in->change_price_data
*          EXPORTING
*            is_idoc_contrl   = is_idoc_contrl
*            it_idoc_data     = it_idoc_data
*          CHANGING
*            cs_energy_prices = sis_energy_prices
*          EXCEPTIONS
*            error_occurred   = 1
*            OTHERS           = 2.
*        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                     RAISING error_occurred.
*        ENDIF.
*      CATCH cx_badi_not_implemented.                    "#EC NO_HANDLER
*    ENDTRY.


    DATA: lt_pricat_item TYPE TABLE OF zisu_pricat_item,
          ls_pricat_item LIKE LINE OF lt_pricat_item,
          ls_pricat_hdr  TYPE zisu_pricat_hdr,
          lv_seq_number  TYPE zisu_pricat_hdr-seq_number.

    FIELD-SYMBOLS: <ls_price_list_z32> LIKE LINE OF sis_energy_prices-price_list_z32.

    SELECT MAX( seq_number ) FROM zisu_pricat_hdr INTO lv_seq_number.
    lv_seq_number = lv_seq_number + 1.

    ls_pricat_hdr-seq_number     = lv_seq_number.
    ls_pricat_hdr-sender         = sis_energy_prices-sender.
    ls_pricat_hdr-receiver       = sis_energy_prices-receiver.
    ls_pricat_hdr-price_curr     = sis_energy_prices-currency.
    ls_pricat_hdr-val_start_date = sis_energy_prices-val_start_date.
    ls_pricat_hdr-ediref         = sis_cl_seg_bgm2-documentnumber.
    ls_pricat_hdr-idocno         = is_idoc_contrl-docnum.
    ls_pricat_hdr-erdat          = sy-datum.
    ls_pricat_hdr-ernam          = sy-uname.

    TRY.
        INSERT zisu_pricat_hdr FROM ls_pricat_hdr.
      CATCH cx_sy_open_sql_db.
        MESSAGE ID '00' TYPE 'E' NUMBER '001'
                        WITH 'Einfügen in Tabelle zisu_pricat_hdr fehlgeschlagen.'
                        RAISING error_occurred.
    ENDTRY.

    LOOP AT sis_energy_prices-price_list_z32 ASSIGNING <ls_price_list_z32>.
      ls_pricat_item-seq_number       = lv_seq_number.
      ls_pricat_item-price_key_root   = <ls_price_list_z32>-pos_price_key_group.
      ls_pricat_item-price_class      = <ls_price_list_z32>-price_class.
      ls_pricat_item-price_class_add  = <ls_price_list_z32>-price_class_add.
      ls_pricat_item-price            = <ls_price_list_z32>-price.
      APPEND ls_pricat_item TO lt_pricat_item.
    ENDLOOP.

    TRY.
        INSERT zisu_pricat_item FROM TABLE lt_pricat_item.
      CATCH cx_sy_open_sql_db.
        MESSAGE ID '00' TYPE 'E' NUMBER '001'
                        WITH 'Einfügen in Tabelle zisu_pricat_item fehlgeschlagen.'
                        RAISING error_occurred.
    ENDTRY.

* Set Process IDOC status okay
    CALL METHOD me->set_idocstat_in
      CHANGING
        cs_idoc_stat = es_idoc_status.

  ENDMETHOD.


  method ISU_COMPR_PRICAT_OUT.
 DATA: badi_isu_pricat_out TYPE REF TO /idexge/eqs_pricat_out,
          ls_compen_prices    TYPE /idexge/s_eqs_cprice,
          lv_line_item_number TYPE sytabix.

    FIELD-SYMBOLS: <ls_price_list> TYPE zidexge_s_eqs_plist.

    ls_compen_prices-sender       = is_compen_prices-sender.
    ls_compen_prices-receiver     = is_compen_prices-receiver.
    ls_compen_prices-obs_month    = is_compen_prices-obs_month.
    ls_compen_prices-currency     = is_compen_prices-currency.
    ls_compen_prices-prod_group   = is_compen_prices-prod_group.
    ls_compen_prices-ctrl_area_id = is_compen_prices-ctrl_area_id.

    init_out( ).


* fill idoc control
    CALL METHOD me->fill_idoc_control
      EXPORTING
        iv_receiver     = is_compen_prices-receiver
      IMPORTING
        es_idoc_control = es_idoc_data-control
      EXCEPTIONS
        error_occurred  = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error_occurred.
    ENDIF.

* --- UNA service segment
    fill_una( ).

* --- UNB service segment
    CALL METHOD me->fill_unb
      EXPORTING
        is_compen_prices = ls_compen_prices
        is_idoc_control  = es_idoc_data-control
      EXCEPTIONS
        error_occurred   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error_occurred.
    ENDIF.

* --- unh header segment
    fill_unh( ).

* --- bgm header segment
    CALL METHOD me->fill_bgm
      EXPORTING
        is_compen_prices = ls_compen_prices
      EXCEPTIONS
        error_occurred   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                 RAISING error_occurred.
    ENDIF.


* --- dtm header segment
    CALL METHOD me->fill_dtm
      EXPORTING
        is_compen_prices = is_compen_prices
      EXCEPTIONS
        error_occurred   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                 RAISING error_occurred.
    ENDIF.

* RFF
    CALL METHOD me->fill_sg1_rff.

* --- SG2 nad segment for receiver
    CALL METHOD me->fill_sg2_nad
      EXPORTING
        iv_provider     = is_compen_prices-receiver
        is_idoc_control = es_idoc_data-control
        iv_action       = co_nad_receiver
      EXCEPTIONS
        error_occurred  = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error_occurred.
    ENDIF.


* --- SG2 nad segment for sender
    CALL METHOD me->fill_sg2_nad
      EXPORTING
        iv_provider     = is_compen_prices-sender
        is_idoc_control = es_idoc_data-control
        iv_action       = co_nad_sender
      EXCEPTIONS
        error_occurred  = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error_occurred.
    ENDIF.

* --- SG5 cta com segments
    CALL METHOD me->fill_sg4_cta_com
      EXPORTING
        iv_sender      = is_compen_prices-sender
        iv_receiver    = is_compen_prices-receiver
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error_occurred.
    ENDIF.


** --- SG2 LOC segment for settlement territory
*    CALL METHOD me->fill_sg2_loc
*      EXPORTING
*        is_compen_prices = is_compen_prices
*      EXCEPTIONS
*        error_occurred   = 1
*        OTHERS           = 2.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*                 RAISING error_occurred.
*    ENDIF.

    CALL METHOD me->fill_sg6_cux
      EXPORTING
        is_compen_prices = ls_compen_prices
      EXCEPTIONS
        error_occurred   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                 RAISING error_occurred.
    ENDIF.

    CALL METHOD me->fill_sg17_pgi
      EXPORTING
        is_compen_prices = ls_compen_prices
      EXCEPTIONS
        error_occurred   = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                 RAISING error_occurred.
    ENDIF.


    CLEAR lv_line_item_number.
    LOOP AT is_compen_prices-price_list_z32 ASSIGNING <ls_price_list>.
      lv_line_item_number = lv_line_item_number + 1.
* --- SG36 LIN segment
      CALL METHOD me->fill_sg36_lin
        EXPORTING
          iv_item_number = lv_line_item_number.


      CALL METHOD me->fill_mos_sg36_pia
        EXPORTING
          is_compen_prices = is_compen_prices
          is_prices_list   = <ls_price_list>
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   RAISING error_occurred.
      ENDIF.

      CALL METHOD me->fill_mos_sg36_imd
        EXPORTING
          is_prices_list = <ls_price_list>
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   RAISING error_occurred.
      ENDIF.

* --- SG40 price list data
      CALL METHOD me->fill_mos_sg40_pri
        EXPORTING
          is_prices_list = <ls_price_list>
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   RAISING error_occurred.
      ENDIF.

*      ls_pricat_out-price_catalogue_id = <fs_price_list>-price_catalogue_id.
*      ls_pricat_out-pricat_version_id  = <fs_price_list>-PRICAT_VERSION.

          endloop.

* --- UNT tail segment
      fill_unt( ).

* --- UNZ service segment
      fill_unz( ).

      es_idoc_data-data = sit_idoc_data.

* Fill reference table (for APERAK/CONTRL)
      CALL METHOD me->set_msg_ref
        EXCEPTIONS
          error_occurred = 1
          OTHERS         = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   RAISING error_occurred.
      ENDIF.

*  CALL BADI method
      TRY.
          IF badi_isu_pricat_out IS INITIAL.
            GET BADI badi_isu_pricat_out.
          ENDIF.
          CALL BADI badi_isu_pricat_out->overwrite_idoc_data
            EXPORTING
              is_compen_prices = ls_compen_prices
            CHANGING
              cs_idoc_data     = es_idoc_data
            EXCEPTIONS
              error_occurred   = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING error_occurred.
          ENDIF.
        CATCH cx_badi_not_implemented.                  "#EC NO_HANDLER
      ENDTRY.
  endmethod.


 METHOD proc_dtm.
   DATA:
     lv_msgv1 TYPE symsgv,
     lv_msgv2 TYPE symsgv.

   CLEAR sis_cl_seg_dtm1.
   sis_cl_seg_dtm1 = is_sdata.

* Set idoc data DTM to
   CASE sis_cl_seg_dtm1-datumqualifier.
     WHEN co_message_dateq.           "137: document date
*   Currently no handling

     WHEN co_message_date_obersv_month. "492: observation month
       sis_energy_prices-obs_month = sis_cl_seg_dtm1-datum.

       CONDENSE sis_cl_seg_dtm1-datum NO-GAPS.
       IF sis_cl_seg_dtm1-format = co_dtm_settle_mon.       "610: yyyymm
         sis_energy_prices-obs_month = sis_cl_seg_dtm1-datum(6).
       ELSE.
         lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_dtm1.
         lv_msgv2 = sis_cl_seg_dtm3-format.

         IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.  "#EC *
         CALL METHOD me->error_handler
           EXPORTING
             p_msgty        = co_msg_error
             p_msgno        = '104'
             p_msgid        = 'ECCEDI'
             p_msgv1        = lv_msgv1
             p_msgv2        = lv_msgv2
             p_msgv3        = space
             p_msgv4        = space
             p_fuba         = siv_function_name
           EXCEPTIONS
             error_occurred = 1
             OTHERS         = 2.
         IF sy-subrc <> 0.
           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                      RAISING error_occurred.
         ENDIF.
       ENDIF.

     WHEN ac_message_date_val_per_start. "157: Gültigkeitsbeginn

       sis_energy_prices-val_start_date = sis_cl_seg_dtm1-datum(8).

       CONDENSE sis_cl_seg_dtm1-datum NO-GAPS.
       IF sis_cl_seg_dtm1-format <> co_dtm_ts_version. "204

         lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_dtm1.
         lv_msgv2 = sis_cl_seg_dtm3-format.

         IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.  "#EC *
         CALL METHOD me->error_handler
           EXPORTING
             p_msgty        = co_msg_error
             p_msgno        = '104'
             p_msgid        = 'ECCEDI'
             p_msgv1        = lv_msgv1
             p_msgv2        = lv_msgv2
             p_msgv3        = space
             p_msgv4        = space
             p_fuba         = siv_function_name
           EXCEPTIONS
             error_occurred = 1
             OTHERS         = 2.
         IF sy-subrc <> 0.
           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                      RAISING error_occurred.
         ENDIF.

       ENDIF.

* DATUM qualifier error
     WHEN OTHERS.
       lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_dtm1.
       lv_msgv2 = sis_cl_seg_dtm1-datumqualifier.

       IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.    "#EC *
       CALL METHOD me->error_handler
         EXPORTING
           p_msgty        = co_msg_error
           p_msgno        = '104'
           p_msgid        = 'ECCEDI'
           p_msgv1        = lv_msgv1
           p_msgv2        = lv_msgv2
           p_msgv3        = space
           p_msgv4        = space
           p_fuba         = siv_function_name
         EXCEPTIONS
           error_occurred = 1
           OTHERS         = 2.
       IF sy-subrc <> 0.
         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    RAISING error_occurred.
       ENDIF.

   ENDCASE.
 ENDMETHOD.


 METHOD proc_mos_sg36_imd.
   DATA: ls_imd   TYPE /idxgc/e1vdewimd_1,
         lv_msgv1 TYPE symsgv,
         lv_msgv2 TYPE symsgv.

   ls_imd = is_sdata.

   as_price_list-price_class     = ls_imd-characode.
   as_price_list-price_class_add = ls_imd-descode .

   as_price_list-format_code  = ls_imd-formatcode.
   as_price_list-product_desc = ls_imd-itemdes1.
*  TODO: Fehlerhandling

 ENDMETHOD.


 METHOD proc_mos_sg36_lin.
   DATA: ls_lin   TYPE /idxgc/e1vdewlin_1,
         lv_msgv1 TYPE symsgv,
         lv_msgv2 TYPE symsgv.

   ls_lin = is_sdata.

   IF ls_lin-item_number <> ac_lin_item_no_meter_point_op OR  ls_lin-item_number_type <> co_lin_item_number_type.
     lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_lin1.

     IF ls_lin-item_number <> ac_lin_item_no_meter_point_op.
       lv_msgv2 = ls_lin-item_number.
     ENDIF.

     IF ls_lin-item_number_type <> co_lin_item_number_type.
       lv_msgv2 = ls_lin-item_number_type.
     ENDIF.

     IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.      "#EC *
     CALL METHOD me->error_handler
       EXPORTING
         p_msgty        = co_msg_error
         p_msgno        = '104'
         p_msgid        = 'ECCEDI'
         p_msgv1        = lv_msgv1
         p_msgv2        = lv_msgv2
         p_msgv3        = space
         p_msgv4        = space
         p_fuba         = siv_function_name
       EXCEPTIONS
         error_occurred = 1
         OTHERS         = 2.
     IF sy-subrc <> 0.
       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  RAISING error_occurred.
     ENDIF.
   ENDIF.

   CLEAR as_price_list.
   as_price_list-item_id    = ls_lin-line_item_number.
   as_price_list-product_id = ls_lin-item_number.

 ENDMETHOD.


 METHOD proc_mos_sg36_pia.
   DATA: ls_pia   TYPE /idxgc/e1vdewpia_1,
         lv_msgv1 TYPE symsgv,
         lv_msgv2 TYPE symsgv.

   ls_pia = is_sdata.

   IF ls_pia-product_id <> ac_product_id_1 OR ls_pia-item_number_type_1 <> ac_price_key_group_z06.
     lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_lin1.

     IF ls_pia-product_id <> ac_product_id_1.
       lv_msgv2 = ls_pia-product_id.
     ENDIF.

     IF ls_pia-item_number_type_1 <> ac_price_key_group_z06.
       lv_msgv2 = ls_pia-item_number_type_1.
     ENDIF.

     IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.      "#EC *
     CALL METHOD me->error_handler
       EXPORTING
         p_msgty        = co_msg_error
         p_msgno        = '104'
         p_msgid        = 'ECCEDI'
         p_msgv1        = lv_msgv1
         p_msgv2        = lv_msgv2
         p_msgv3        = space
         p_msgv4        = space
         p_fuba         = siv_function_name
       EXCEPTIONS
         error_occurred = 1
         OTHERS         = 2.
     IF sy-subrc <> 0.
       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  RAISING error_occurred.
     ENDIF.
   ENDIF.

   as_price_list-pos_price_key_group = ls_pia-item_number_1.

 ENDMETHOD.


 METHOD proc_mos_sg36_pri.
   DATA: ls_pri   TYPE /idxgc/e1vdewpri_1,
         lv_msgv1 TYPE symsgv,
         lv_msgv2 TYPE symsgv.

   ls_pri = is_sdata.

   as_price_list-price          = ls_pri-price.
   as_price_list-price_unit_ext = ls_pri-measure_unit.

   APPEND as_price_list TO sis_energy_prices-price_list_z32.

*  TODO: Fehlerhandling

 ENDMETHOD.
ENDCLASS.
