interface YIF_FRST_EXCEL_UPLOAD_DAO
  public .
     METHODS get_excel
    IMPORTING
              iv_file_id         TYPE string
    RETURNING VALUE(rs_entry)    TYPE ycl_yfrst_excel_upload_mpc=>ts_excel.
*    RAISING   ycx_frst_db_read_failed.

  METHODS get_excels
    RETURNING VALUE(rt_entries)       TYPE yf_tt_rst_e_upload.

  METHODS update_message
    IMPORTING iv_file_id TYPE yf_rst_file_id
              iv_message_type TYPE symsgty
              iv_message_id TYPE symsgid
              iv_message_number TYPE symsgno.
*    RAISING ycx_frst_db_write_failed.

  METHODS create
    IMPORTING is_excel TYPE yft_rst_e_upld.
*    RAISING   ycx_frst_db_write_failed.
endinterface.
