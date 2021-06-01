CLASS ycl_frst_excel_upload_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES yif_frst_excel_upload_dao .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_frst_excel_upload_dao IMPLEMENTATION.

    METHOD yif_frst_excel_upload_dao~get_excel.
        SELECT SINGLE *
        FROM yft_rst_e_upld INTO CORRESPONDING FIELDS OF @rs_entry
        WHERE file_id = @iv_file_id.
*        IF sy-subrc IS NOT INITIAL.
*      RAISE EXCEPTION TYPE ycx_frst_db_write_failed
*        EXPORTING
*          iv_msgv1 = |YFT_RST_UPLD|
*          iv_msgv2 = CONV #( is_file-accrual_report_id )
*          iv_msgv3 = CONV #( is_file-settlement_date )
*          iv_msgv4 = CONV #( is_file-file_id ).
*    ENDIF.
    ENDMETHOD.

    METHOD yif_frst_excel_upload_dao~get_excels.
        SELECT * FROM yft_rst_e_upld  INTO CORRESPONDING FIELDS OF TABLE  @rt_entries.
*        IF sy-subrc IS NOT INITIAL.
*      RAISE EXCEPTION TYPE ycx_frst_db_write_failed
*        EXPORTING
*          iv_msgv1 = |YFT_RST_UPLD|
*          iv_msgv2 = CONV #( is_file-accrual_report_id )
*          iv_msgv3 = CONV #( is_file-settlement_date )
*          iv_msgv4 = CONV #( is_file-file_id ).
*    ENDIF.
*
    ENDMETHOD.
*
    METHOD yif_frst_excel_upload_dao~update_message.

        UPDATE yft_rst_e_upld SET message_type   = iv_message_type
                                  message_id     = iv_message_id
                                  message_number = iv_message_number
                                  WHERE file_id = iv_file_id.
*
    ENDMETHOD.

    METHOD yif_frst_excel_upload_dao~create.
        INSERT INTO yft_rst_e_upld VALUES is_excel.
*        IF sy-subrc IS NOT INITIAL.
*      RAISE EXCEPTION TYPE ycx_frst_db_write_failed
*        EXPORTING
*          iv_msgv1 = |YFT_RST_UPLD|
*          iv_msgv2 = CONV #( is_file-accrual_report_id )
*          iv_msgv3 = CONV #( is_file-settlement_date )
*          iv_msgv4 = CONV #( is_file-file_id ).
*    ENDIF.
    ENDMETHOD.

ENDCLASS.
