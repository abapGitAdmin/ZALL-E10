class ZCL_PRICAT_11_IDXGL definition
  public
  inheriting from ZCL_PRICAT_11_CL
  create public .

public section.

  methods ISU_COMPR_PRICAT_IN
    redefinition .
protected section.

  methods Z_ISU_COMPR_PRICAT_IN
    importing
      !IS_IDOC_CONTRL type EDIDC
      !IT_IDOC_DATA type EDIDD_TT
    exporting
      !ES_IDOC_STATUS type BDIDOCSTAT
    exceptions
      ERROR_OCCURRED .

  methods ISU_COMPR_PRICAT_IN_Z32
    redefinition .
  methods PROC_BGM
    redefinition .
  methods PROC_DTM
    redefinition .
  methods PROC_MOS_SG36_IMD
    redefinition .
  methods PROC_MOS_SG36_LIN
    redefinition .
  methods PROC_MOS_SG36_PIA
    redefinition .
  methods PROC_MOS_SG36_PRI
    redefinition .
  methods PROC_SG17_PGI
    redefinition .
  methods PROC_SG2_LOC
    redefinition .
  methods PROC_SG2_NAD
    redefinition .
  methods PROC_SG40_PRI
    redefinition .
  methods PROC_SG6_CUX
    redefinition .
  methods PROC_UNB
    redefinition .
  methods PROC_SG40_DTM
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_PRICAT_11_IDXGL IMPLEMENTATION.


  METHOD isu_compr_pricat_in.
    DATA: ls_bgm TYPE /idxgc/e1_bgm_02.
    FIELD-SYMBOLS: <ls_idoc_data> LIKE LINE OF it_idoc_data.

    READ TABLE it_idoc_data ASSIGNING <ls_idoc_data> WITH KEY segnam = /idxgc/if_constants_ide=>gc_segmtp_bgm_02.
    IF sy-subrc <> 0.
      RAISE error_occurred.
    ENDIF.


    ls_bgm = <ls_idoc_data>-sdata.

    IF ls_bgm-document_name_code = ac_bgm_z32. "Preisblatt Messstellenbetrieb
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
      CALL METHOD z_isu_compr_pricat_in
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
        WHEN /idxgc/if_constants_ide=>gc_segmtp_una_01.
          CALL METHOD me->proc_una( sis_idoc_line-sdata ).

        WHEN /idxgc/if_constants_ide=>gc_segmtp_unb_01.
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

        WHEN /idxgc/if_constants_ide=>gc_segmtp_bgm_02.
          CALL METHOD me->proc_bgm( sis_idoc_line-sdata ).

*     Set observation month
        WHEN /idxgc/if_constants_ide=>gc_segmtp_dtm_01.
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
        WHEN /idxgc/if_constants_ide=>gc_segmtp_nad_03.
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
        WHEN /idxgc/if_constants_ide=>gc_segmtp_cux_01.
          CALL METHOD me->proc_sg6_cux
            EXPORTING
              is_sdata = sis_idoc_line-sdata.

*      Set product group
        WHEN '/IDXGL/E1_PGI_01'.
          CALL METHOD me->proc_sg17_pgi
            EXPORTING
              is_sdata = sis_idoc_line-sdata.

*     Set price
        WHEN /idxgc/if_constants_ide=>gc_segmtp_lin_01.
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

        WHEN /idxgc/if_constants_ide=>gc_segmtp_pia_01.
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

        WHEN /idxgc/if_constants_ide=>gc_segmtp_imd_01.
          CALL METHOD me->proc_mos_sg36_imd
            EXPORTING
              is_sdata = sis_idoc_line-sdata.

        WHEN /idxgc/if_constants_ide=>gc_segmtp_pri_01.
          CALL METHOD me->proc_mos_sg36_pri
            EXPORTING
              is_sdata = sis_idoc_line-sdata.

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


  METHOD proc_bgm.

    DATA ls_bgm TYPE /idxgc/e1_bgm_02.

    ls_bgm = is_sdata.
    sis_cl_seg_bgm2-name = ls_bgm-document_name_code.
    sis_cl_seg_bgm2-codelist = ls_bgm-code_list_identification_code.
    sis_cl_seg_bgm2-codelistagency = ls_bgm-code_list_resp_agency_code.
    sis_cl_seg_bgm2-fullname = ls_bgm-document_name.
    sis_cl_seg_bgm2-documentnumber = ls_bgm-document_identifier.
    sis_cl_seg_bgm2-version = ls_bgm-version_identifier.
    sis_cl_seg_bgm2-revision = ls_bgm-revision_identifier.
    sis_cl_seg_bgm2-documentfunc = ls_bgm-message_function_code.
    sis_cl_seg_bgm2-responsetype = ls_bgm-response_type_code.

  ENDMETHOD.


METHOD proc_dtm.
  DATA:
    lv_msgv1 TYPE symsgv,
    lv_msgv2 TYPE symsgv.

  DATA ls_dtm TYPE /idxgc/e1_dtm_01.

  CLEAR sis_cl_seg_dtm1.
  CLEAR ls_dtm.
  ls_dtm = is_sdata.

* Set idoc data DTM to
  CASE ls_dtm-date_time_period_fc_qualifier.
    WHEN co_message_dateq.           "137: document date
*   Currently no handling

    WHEN co_message_date_obersv_month. "492: observation month
      sis_energy_prices-obs_month = ls_dtm-date_time_period_value.

      CONDENSE ls_dtm-date_time_period_value NO-GAPS.
      IF ls_dtm-date_time_period_format_code = co_dtm_settle_mon.       "610: yyyymm
        sis_energy_prices-obs_month = ls_dtm-date_time_period_value(6).
      ELSE.
        lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_dtm_01.
        lv_msgv2 = ls_dtm-date_time_period_format_code.

        IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.   "#EC *
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

      sis_energy_prices-val_start_date = ls_dtm-date_time_period_value(8).

      CONDENSE ls_dtm-date_time_period_value NO-GAPS.
      IF ls_dtm-date_time_period_format_code <> co_dtm_ts_version. "204

        lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_dtm_01.
        lv_msgv2 = ls_dtm-date_time_period_format_code.

        IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.   "#EC *
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
      lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_dtm_01.
      lv_msgv2 = ls_dtm-date_time_period_fc_qualifier.

      IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.     "#EC *
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
   DATA: ls_imd   TYPE /idxgc/e1_imd_01,
         lv_msgv1 TYPE symsgv,
         lv_msgv2 TYPE symsgv.

   ls_imd = is_sdata.

   as_price_list-price_class     = ls_imd-item_characteristic_code.
   as_price_list-price_class_add = ls_imd-item_description_code.

   IF as_price_list-price_class_add IS INITIAL.  "NLI scheint verwirrt, in welches Feld es wohl gehört
     as_price_list-price_class_add = ls_imd-code_list_ident_code_1.
   ENDIF.


   as_price_list-format_code  = ls_imd-description_format_code.
   as_price_list-product_desc = ls_imd-item_description_1.

*  TODO: Fehlerhandling

 ENDMETHOD.


 METHOD proc_mos_sg36_lin.

   DATA: ls_lin   TYPE /idxgc/e1_lin_01,
         lv_msgv1 TYPE symsgv,
         lv_msgv2 TYPE symsgv.

   ls_lin = is_sdata.

   IF ls_lin-item_identifier <> ac_lin_item_no_meter_point_op OR  ls_lin-item_type_identification_code <> co_lin_item_number_type.
     lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_lin_01.

     IF ls_lin-item_identifier <> ac_lin_item_no_meter_point_op.
       lv_msgv2 = ls_lin-item_identifier.
     ENDIF.

     IF ls_lin-item_type_identification_code <> co_lin_item_number_type.
       lv_msgv2 = ls_lin-item_type_identification_code.
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
   as_price_list-item_id    = ls_lin-line_item_identifier.
   as_price_list-product_id = ls_lin-item_identifier.

 ENDMETHOD.


 METHOD proc_mos_sg36_pia.
   DATA: ls_pia   TYPE /idxgc/e1_pia_01,
         lv_msgv1 TYPE symsgv,
         lv_msgv2 TYPE symsgv.

   ls_pia = is_sdata.

   IF ls_pia-product_ident_code_qualifier <> ac_product_id_1 OR ls_pia-item_type_ident_code_1 <> ac_price_key_group_z06.
     lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_pia_01.

     IF ls_pia-product_ident_code_qualifier <> ac_product_id_1.
       lv_msgv2 = ls_pia-product_ident_code_qualifier.
     ENDIF.

     IF ls_pia-item_type_ident_code_1 <> ac_price_key_group_z06.
       lv_msgv2 = ls_pia-item_type_ident_code_1.
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

   as_price_list-pos_price_key_group = ls_pia-item_identifier_1.

 ENDMETHOD.


 METHOD proc_mos_sg36_pri.
   DATA: ls_pri   TYPE /idxgc/e1_pri_01,
         lv_msgv1 TYPE symsgv,
         lv_msgv2 TYPE symsgv.

   ls_pri = is_sdata.

   as_price_list-price          = ls_pri-price_amount.
   as_price_list-price_unit_ext = ls_pri-measurement_unit_code.

   APPEND as_price_list TO sis_energy_prices-price_list_z32.

*  TODO: Fehlerhandling

 ENDMETHOD.


METHOD proc_sg17_pgi.
  DATA ls_pgi TYPE /idxgl/e1_pgi_01.

  CLEAR sis_cl_seg_dtm1.
  ls_pgi = is_sdata.
  sis_energy_prices-prod_group = ls_pgi-product_grp_type_code.
ENDMETHOD.


METHOD proc_sg2_loc.

  DATA ls_loc TYPE /idxgc/e1_loc_02.

  CLEAR sis_cl_seg_loc3.

  ls_loc = is_sdata.

  sis_cl_seg_loc3-place_qualifier = ls_loc-location_func_code_quali. "  231
  sis_cl_seg_loc3-place_id = ls_loc-location_identifier. "  10YDE-RWENET---I
  sis_cl_seg_loc3-code_list_responsible_agency_1 = ls_loc-code_list_resp_agency_code_1."  305

  sis_cl_seg_loc3 = is_sdata.
  IF sis_cl_seg_loc3-place_qualifier = co_loc_contrl_area.   "231
    sis_energy_prices-ctrl_area_id = sis_cl_seg_loc3-place_id.
  ENDIF.
ENDMETHOD.


METHOD proc_sg2_nad.
  DATA: ls_mpid       TYPE /idexge/s_mpid_swt_key,
        ls_provider   TYPE eservprov,
        lv_ext_id     TYPE dunsnr,
        lv_codelistid TYPE e_edmideextcodelistid.

  DATA ls_nad TYPE /idxgc/e1_nad_03.

  CLEAR sis_cl_seg_nad7.
  CLEAR ls_nad.
  CLEAR ls_mpid.

  ls_nad = is_sdata.
  ls_mpid-codelistid = ls_nad-code_list_resp_agency_code_1.

* get Long External Number: l_externalid
  CASE ls_nad-party_function_code_qualifier.
    WHEN co_nad_sender.
      ls_mpid-l_externalid  = sis_cl_seg_unb1-sender.
    WHEN co_nad_receiver.
      ls_mpid-l_externalid  = sis_cl_seg_unb1-receiver.
  ENDCASE.

* get internal and external MP-ID
  CALL METHOD /idexge/cl_mpid_access=>select_db_mpid
    CHANGING
      cs_mpid   = ls_mpid
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
               RAISING error_occurred.
  ENDIF.

  lv_ext_id = ls_mpid-externalid.
  lv_codelistid = ls_mpid-codelistid.

* get service provider information according the code list id and
* external id
  CALL FUNCTION 'ISU_DATEX_IDENT_SP_BY_CODELIST'
    EXPORTING
      x_ext_id        = lv_ext_id
      x_extcodelistid = lv_codelistid
    IMPORTING
      y_eservprov     = ls_provider
    EXCEPTIONS
      not_found       = 1
      not_unique      = 2
      not_supported   = 3
      error_occured   = 4
      OTHERS          = 5.
* Error handling !!!!! this error should not happen because SP was
* already defined in the COMEV module
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
  ENDIF.

* fill sender and receiver information
  CASE ls_nad-party_function_code_qualifier.
    WHEN co_nad_sender.
      sis_energy_prices-sender   = ls_provider-serviceid.
    WHEN co_nad_receiver.
      sis_energy_prices-receiver = ls_provider-serviceid.
  ENDCASE.
ENDMETHOD.


METHOD proc_sg40_dtm.
  DATA:
    lv_msgv1 TYPE symsgv,
    lv_msgv2 TYPE symsgv,
    ls_dtm   TYPE /idxgc/e1_dtm_02.

  CLEAR ls_dtm.
  CLEAR sis_cl_seg_dtm2.

  ls_dtm = is_sdata.

  sis_cl_seg_dtm2-datumqualifier = ls_dtm-date_time_period_fc_qualifier.
  sis_cl_seg_dtm2-datum          = ls_dtm-date_time_period_value.
  sis_cl_seg_dtm2-format         = ls_dtm-date_time_period_format_code.

* Set idoc data DTM to
  CASE sis_cl_seg_dtm2-datumqualifier.
    WHEN co_dtm_proc_data_start.          "163 start date
      sis_prices_list-periodfrom-datefrom = sis_cl_seg_dtm2-datum(8).
      sis_prices_list-periodfrom-timefrom = sis_cl_seg_dtm2-datum+8(4).
      sis_prices_list-fromoffset          = sis_cl_seg_dtm2-datum+12(3).
    WHEN co_dtm_proc_data_end.            "164 end date
      sis_prices_list-periodto-dateto = sis_cl_seg_dtm2-datum(8).
      sis_prices_list-periodto-timeto = sis_cl_seg_dtm2-datum+8(4).
      sis_prices_list-tooffset        = sis_cl_seg_dtm2-datum+12(3).
      APPEND  sis_prices_list TO sis_energy_prices-price_list.
* DATUM qualifier error
    WHEN OTHERS.
      lv_msgv1 = /idxgc/if_constants_ide=>gc_segmtp_dtm_02.
      lv_msgv2 = sis_cl_seg_dtm2-datumqualifier.

      IF 1 = 2. MESSAGE e104(eccedi) WITH space. ENDIF.     "#EC *
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


METHOD proc_sg40_pri.

  DATA: ls_pri   TYPE /idxgc/e1_pri_01,
        lv_msgv1 TYPE symsgv,
        lv_msgv2 TYPE symsgv.

  ls_pri = is_sdata.

  CLEAR sis_cl_seg_pri1.
  sis_cl_seg_pri1-price_basis = ls_pri-unit_price_basis_quantity.
  sis_cl_seg_pri1-measure_unit = ls_pri-measurement_unit_code.
  sis_cl_seg_pri1-price = ls_pri-price_amount.
  sis_prices_list-price_basis = sis_cl_seg_pri1-price_basis.
  sis_prices_list-measure_unit = sis_cl_seg_pri1-measure_unit.

  CALL METHOD /idexge/cl_amount_convert_in=>convert_to_internal_n
    EXPORTING
      is_una        = sis_cl_seg_una1
      iv_input      = sis_cl_seg_pri1-price
    IMPORTING
      ev_output     = sis_prices_list-price
    EXCEPTIONS
      convert_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      RAISING error_occurred.
  ENDIF.

ENDMETHOD.


METHOD proc_sg6_cux.

  DATA ls_cux TYPE /idxgc/e1_cux_01.

  CLEAR sis_cl_seg_cux1.
  CLEAR ls_cux.
  ls_cux = is_sdata.
  sis_energy_prices-currency = ls_cux-currency_identification_code_1.
ENDMETHOD.


METHOD proc_unb.

  DATA ls_unb TYPE /idxgc/e1_unb_01.

  ls_unb = is_sdata.

  sis_cl_seg_unb1-syntax_ident   = ls_unb-syntax_identifier.
  sis_cl_seg_unb1-syntax_version = ls_unb-syntax_version_number.
  sis_cl_seg_unb1-sender = ls_unb-interchange_sender_ident.
  sis_cl_seg_unb1-sender_type = ls_unb-identification_code_qualifier1.
  sis_cl_seg_unb1-receiver = ls_unb-interchange_recipient_ident.
  sis_cl_seg_unb1-receiver_type = ls_unb-identification_code_qualifier2.
  sis_cl_seg_unb1-date_gen = ls_unb-date.
  sis_cl_seg_unb1-time_gen = ls_unb-time.
  sis_cl_seg_unb1-bulk_ref = ls_unb-interchange_control_reference.

ENDMETHOD.


METHOD z_isu_compr_pricat_in.

  init_in( ).

* Process Idoc data
  LOOP AT it_idoc_data INTO sis_idoc_line.
    CASE sis_idoc_line-segnam.
      WHEN /idxgc/if_constants_ide=>gc_segmtp_una_01.
        CALL METHOD me->proc_una( sis_idoc_line-sdata ).

      WHEN /idxgc/if_constants_ide=>gc_segmtp_unb_01.
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

*     Set observation month
      WHEN /idxgc/if_constants_ide=>gc_segmtp_dtm_01.
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
      WHEN /idxgc/if_constants_ide=>gc_segmtp_nad_03.
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

*     Set control area
      WHEN /idxgc/if_constants_ide=>gc_segmtp_loc_02.
        CALL METHOD me->proc_sg2_loc
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
      WHEN /idxgc/if_constants_ide=>gc_segmtp_cux_01.
        CALL METHOD me->proc_sg6_cux
          EXPORTING
            is_sdata = sis_idoc_line-sdata.

*      Set product group
      WHEN '/IDXGL/E1_PGI_01'.
        CALL METHOD me->proc_sg17_pgi
          EXPORTING
            is_sdata = sis_idoc_line-sdata.

*     Set price
      WHEN /idxgc/if_constants_ide=>gc_segmtp_lin_01.
        CALL METHOD me->proc_sg36_lin.

*     Set price
      WHEN /idxgc/if_constants_ide=>gc_segmtp_pri_01.
        CALL METHOD me->proc_sg40_pri
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

*     Set date start and end
      WHEN /idxgc/if_constants_ide=>gc_segmtp_dtm_02.
        CALL METHOD me->proc_sg40_dtm
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


      WHEN /idxgc/if_constants_ide=>gc_segm_unt_01.

    ENDCASE.
  ENDLOOP.

*  CALL BADI method
  TRY.
      IF gref_badi_isu_pricat_in IS INITIAL.
        GET BADI gref_badi_isu_pricat_in.
      ENDIF.

      CALL BADI gref_badi_isu_pricat_in->change_price_data
        EXPORTING
          is_idoc_contrl   = is_idoc_contrl
          it_idoc_data     = it_idoc_data
        CHANGING
          cs_energy_prices = sis_energy_prices
        EXCEPTIONS
          error_occurred   = 1
          OTHERS           = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                   RAISING error_occurred.
      ENDIF.
    CATCH cx_badi_not_implemented.                      "#EC NO_HANDLER
  ENDTRY.

* Set Process IDOC status okay
  CALL METHOD me->set_idocstat_in
    CHANGING
      cs_idoc_stat = es_idoc_status.

ENDMETHOD.
ENDCLASS.
