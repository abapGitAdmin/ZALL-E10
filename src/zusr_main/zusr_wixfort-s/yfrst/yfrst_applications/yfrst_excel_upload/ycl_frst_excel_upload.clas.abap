class YCL_FRST_EXCEL_UPLOAD definition
  public
  final
  create public .

public section.
    INTERFACES YIF_FRST_EXCEL_UPLOAD.
    METHODS constructor.
protected section.
private section.
    DATA go_excel TYPE REF TO yif_frst_excel_upload_dao.
    DATA go_data  TYPE REF TO yif_frst_excel_data_dao.
ENDCLASS.



CLASS YCL_FRST_EXCEL_UPLOAD IMPLEMENTATION.

METHOD constructor.
    super->constructor( ).
    me->go_excel = NEW ycl_frst_excel_upload_dao( ).
    me->go_data = NEW ycl_frst_excel_data_dao( ).
ENDMETHOD.

METHOD yif_frst_excel_upload~extract_data.

    DATA(lt_excel_uploads) = me->go_excel->get_excels( ).
    Data ls_entry TYPE yft_rst_e_data.
    DATA lt_data TYPE TABLE OF yfs_rst_e_data.

    DATA lt_raw_table TYPE truxs_t_text_data.
    LOOP at lt_excel_uploads ASSIGNING FIELD-SYMBOL(<fs_excel>).


    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR        =
      i_line_header            =  'X'
      i_tab_raw_data           =  lt_raw_table
      i_filename               =  <fs_excel>-value
    TABLES
      i_tab_converted_data     =  lt_data
   EXCEPTIONS
      conversion_failed        = 1
      OTHERS                   = 2.

      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
        ls_entry-file_id = <fs_excel>-file_id.
        ls_entry-entity = sy-tabix.
        ls_entry-settelment_date = <fs_data>-settelment_date.
        ls_entry-company_code = <fs_data>-company_code.
        ls_entry-description = <fs_data>-description.
        ls_entry-type = <fs_data>-type.
        ls_entry-currency = <fs_data>-currency.
        ls_entry-cost_center = <fs_data>-cost_center.
        ls_entry-contact = <fs_data>-contact.
        ls_entry-vendor = <fs_data>-vendor.
        ls_entry-order_number = <fs_data>-order_number.
        ls_entry-ar_comment = <fs_data>-ar_comment.

        me->go_data->append( ls_entry ).
        CLEAR ls_entry.

      ENDLOOP.
        me->go_excel->update_message( iv_file_id = <fs_excel>-file_id
                                      iv_message_id = '1'
                                      iv_message_type = ''
                                      iv_message_number = ``).
    ENDLOOP.
ENDMETHOD.
ENDCLASS.
