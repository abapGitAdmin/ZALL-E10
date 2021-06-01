CLASS ycl_frst_excel_upload_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES yif_frst_excel_upload_app .

    METHODS constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mo_data_dao TYPE REF TO yif_frst_excel_data_dao.
    DATA mo_ex_dao  TYPE REF TO yif_frst_excel_upload_dao.

    METHODS map_data IMPORTING is_data            TYPE any
                     RETURNING VALUE(es_data_set) TYPE yft_rst_e_data.
ENDCLASS.



CLASS ycl_frst_excel_upload_app IMPLEMENTATION.


  METHOD constructor.
    mo_data_dao = NEW ycl_frst_excel_data_dao( ).
    mo_ex_dao = NEW ycl_frst_excel_upload_dao( ).

  ENDMETHOD.


  METHOD yif_frst_excel_upload_app~create_stream.
    TRY.

        FIELD-SYMBOLS : <gt_data>  TYPE STANDARD TABLE.


        DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet.
        DATA(lv_file_id) = cl_system_uuid=>create_uuid_x16_static( ).


        TRY .
            lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                                    document_name = iv_slug
                                    xdocument     = is_media_resource-value ) .
          CATCH cx_fdt_excel_core.
            "Implement suitable error handling here
        ENDTRY .

        "Get List of Worksheets
        lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
          IMPORTING
            worksheet_names = DATA(lt_worksheets) ).

        IF NOT lt_worksheets IS INITIAL.
          READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

          DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                                   lv_woksheetname ).
          "now you have excel work sheet data in dyanmic internal table
          ASSIGN lo_data_ref->* TO <gt_data>.

          LOOP AT <gt_data> ASSIGNING FIELD-SYMBOL(<fs_data>).
            DATA(data_set) = me->map_data( <fs_data> ).
            AT FIRST.

*           Überprüfung ob die Struktur Richtig ist.
              CONTINUE.
            ENDAT.

            data_set-file_id = lv_file_id.
            data_set-entity = sy-tabix - 1.

            mo_data_dao->create( data_set ).

          ENDLOOP.
        ENDIF.

        DATA ls_excel TYPE yft_rst_e_upld.

        ls_excel-file_id  = lv_file_id.
        ls_excel-uname    = sy-uname.
        ls_excel-filename = iv_slug.
        ls_excel-creation_date   = sy-datum.
        ls_excel-creation_time   = sy-uzeit.

        mo_ex_dao->create( ls_excel ).

      CATCH cx_root INTO DATA(lcx_exception).
        DATA(lv_message) = lcx_exception->get_longtext( ).
        io_message_container->add_message_text_only(
            iv_msg_type = 'E'
            iv_msg_text = CONV #( lv_message ) ).
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            previous          = lcx_exception
            message_container = io_message_container.
    ENDTRY.
  ENDMETHOD.

  METHOD map_data.

    FIELD-SYMBOLS <lv_field> TYPE any.

    DO 10 TIMES.
      ASSIGN COMPONENT sy-index OF STRUCTURE is_data TO <lv_field> .
      CASE sy-index.
        WHEN 1.
          es_data_set-settelment_date = <lv_field>.
        WHEN 2.
          es_data_set-company_code = <lv_field>.
        WHEN 3.
          es_data_set-description = <lv_field>.
        WHEN 4.
          es_data_set-type = <lv_field>.
        WHEN 5.
          es_data_set-currency = <lv_field>.
        WHEN 6.
          es_data_set-cost_center = <lv_field>.
        WHEN 7.
          es_data_set-contact = <lv_field>.
        WHEN 8.
          es_data_set-vendor = <lv_field>.
        WHEN 9.
          es_data_set-order_number = <lv_field>.
        WHEN 10.
          es_data_set-ar_comment = <lv_field>.
      ENDCASE.

    ENDDO.

    RETURN.

  ENDMETHOD.
ENDCLASS.
