interface YIF_FRST_EXCEL_UPLOAD_APP
  public .

    METHODS create_stream
    IMPORTING
      io_message_container TYPE REF TO /iwbep/if_message_container
      iv_slug              TYPE string
      it_key_tab           TYPE /iwbep/t_mgw_name_value_pair
      is_media_resource    TYPE /iwbep/if_mgw_appl_types=>ty_s_media_resource
    EXPORTING
      er_entity            TYPE REF TO data
    RAISING
      /iwbep/cx_mgw_busi_exception.
endinterface.
