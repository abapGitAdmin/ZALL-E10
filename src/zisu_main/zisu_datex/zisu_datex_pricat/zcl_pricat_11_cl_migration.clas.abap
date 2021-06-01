class ZCL_PRICAT_11_CL_MIGRATION definition
  public
  inheriting from ZCL_PRICAT_11_CL
  create public .

public section.

  methods ISU_COMPR_PRICAT_IN_MIGRATION
    importing
      !IS_IDOC_CONTRL type EDIDC
      !IT_IDOC_DATA type EDIDD_TT
    returning
      value(RT_IDXGL_PRI_SHEET) type /IDXGL/T_PRI_SHEET
    exceptions
      ERROR_OCCURRED .
protected section.

  methods PROC_DTM
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_PRICAT_11_CL_MIGRATION IMPLEMENTATION.


  METHOD isu_compr_pricat_in_migration.
    DATA: ls_price_list TYPE zidexge_s_eqs_plist.

    init_in( ).

* Process Idoc data
    LOOP AT it_idoc_data INTO sis_idoc_line.
      CASE sis_idoc_line-segnam.
        WHEN /idxgc/if_constants_ide=>gc_segmtp_una1.
          CALL METHOD me->proc_una( sis_idoc_line-sdata ).

        WHEN /idxgc/if_constants_ide=>gc_segmtp_rff_07.
          sis_cl_seg_rff_07 = sis_idoc_line-sdata.
          IF sis_cl_seg_rff_07-reference_code_qualifier = /idexge/cl_mscons_v21a=>co_ref_referencenumber.
            sis_energy_prices-previous_document_ident = sis_cl_seg_rff_07-reference_identifier.
          ENDIF.

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
          IF sy-sysid = 'X61'.
            sis_cl_seg_unb1-receiver(1)  = sis_cl_seg_unb1-receiver(1) = '6'.
            IF sis_cl_seg_unb1-sender = '9906490000009'.
              sis_cl_seg_unb1-sender(1) = '6'.
            ENDIF.
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

*    SELECT MAX( seq_number ) FROM zisu_pricat_hdr INTO lv_seq_number.
*    lv_seq_number = lv_seq_number + 1.

*    ls_pricat_hdr-seq_number     = lv_seq_number.
*    ls_pricat_hdr-sender         = sis_energy_prices-sender.
*    ls_pricat_hdr-receiver       = sis_energy_prices-receiver.
*    ls_pricat_hdr-price_curr     = sis_energy_prices-currency.
*    ls_pricat_hdr-val_start_date = sis_energy_prices-val_start_date.
*    ls_pricat_hdr-ediref         = sis_cl_seg_bgm2-documentnumber.
*    ls_pricat_hdr-idocno         = is_idoc_contrl-docnum.
*    ls_pricat_hdr-erdat          = sy-datum.
*    ls_pricat_hdr-ernam          = sy-uname.
**
*    TRY.
*        INSERT zisu_pricat_hdr FROM ls_pricat_hdr.
*      CATCH cx_sy_open_sql_db.
*        MESSAGE ID '00' TYPE 'E' NUMBER '001'
*                        WITH 'Einfügen in Tabelle zisu_pricat_hdr fehlgeschlagen.'
*                        RAISING error_occurred.
*    ENDTRY.

    LOOP AT sis_energy_prices-price_list_z32 ASSIGNING <ls_price_list_z32>.
      APPEND INITIAL LINE TO rt_idxgl_pri_sheet ASSIGNING FIELD-SYMBOL(<ls_idxgl_pri_sheet>).
      <ls_idxgl_pri_sheet>-sender                   = sis_energy_prices-sender.
      <ls_idxgl_pri_sheet>-receiver                 = sis_energy_prices-receiver.
      <ls_idxgl_pri_sheet>-val_start_date           = sis_energy_prices-val_start_date.
*<ls_idxgl_pri_sheet>-VAL_START_TIME
      <ls_idxgl_pri_sheet>-document_ident           = sis_cl_seg_bgm2-documentnumber.
      <ls_idxgl_pri_sheet>-item_id                  = <ls_price_list_z32>-item_id.
      <ls_idxgl_pri_sheet>-msg_date                 = sis_energy_prices-msg_date.
      <ls_idxgl_pri_sheet>-msg_time                 = sis_energy_prices-msg_time.
      <ls_idxgl_pri_sheet>-previous_document_ident  = sis_energy_prices-previous_document_ident.

      <ls_idxgl_pri_sheet>-currency                 = sis_energy_prices-currency.
      <ls_idxgl_pri_sheet>-docname_code             = sis_cl_seg_bgm2-name.
      <ls_idxgl_pri_sheet>-product_id               = <ls_price_list_z32>-product_id.
      <ls_idxgl_pri_sheet>-pos_price_key_group      = <ls_price_list_z32>-pos_price_key_group.
      <ls_idxgl_pri_sheet>-pos_format_code          = <ls_price_list_z32>-format_code.
      <ls_idxgl_pri_sheet>-price                    = <ls_price_list_z32>-price.
*      <ls_idxgl_pri_sheet>-price_unit               = <ls_price_list_z32>-price_unit_ext.
      <ls_idxgl_pri_sheet>-product_code             = <ls_price_list_z32>-price_class.
      <ls_idxgl_pri_sheet>-prod_desc_code           = <ls_price_list_z32>-price_class_add.
      <ls_idxgl_pri_sheet>-product_desc             = <ls_price_list_z32>-product_desc.

      DATA: lv_iso_unit TYPE t006-isocode,
            lv_sap_unit TYPE t006-msehi.

      lv_iso_unit =  <ls_price_list_z32>-price_unit_ext.
      CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
        EXPORTING
          iso_code  = lv_iso_unit
        IMPORTING
          sap_code  = lv_sap_unit
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_occurred.
      ENDIF.
      <ls_idxgl_pri_sheet>-price_unit = lv_sap_unit.
    ENDLOOP.

  ENDMETHOD.


  METHOD proc_dtm.
    CALL METHOD super->proc_dtm
      EXPORTING
        is_sdata       = is_sdata
      EXCEPTIONS
        error_occurred = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                 RAISING error_occurred.
    ENDIF.



    CLEAR sis_cl_seg_dtm1.
    sis_cl_seg_dtm1 = is_sdata.

    IF sis_cl_seg_dtm1-datumqualifier = co_message_dateq           "137: document date
      AND sis_cl_seg_dtm1-format = co_ldate_format.
      sis_energy_prices-msg_date = sis_cl_seg_dtm1-datum(8).
      sis_energy_prices-msg_time = sis_cl_seg_dtm1-datum+8(4).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
