interface YIF_FRST_EXCEL_DATA_DAO
  public .

  TYPES: tt_yft_rst_e_data TYPE TABLE OF yft_rst_e_data With Key file_id entity.
    METHODS create
    IMPORTING is_data_set TYPE  yft_rst_e_data.

    METHODS get_entity
    IMPORTING iv_file_id TYPE yf_rst_file_id
              iv_entity TYPE int2
    RETURNING VALUE(es_entity) TYPE yft_rst_e_data.

    METHODS get_entityset
*    IMPORTING iv_file_id TYPE yf_rst_file_id
    RETURNING VALUE(et_entityset) TYPE tt_yft_rst_e_data.

    METHODS update
    IMPORTING is_data_set TYPE  yft_rst_e_data.

    METHODS delete
    IMPORTING iv_file_id TYPE yf_rst_file_id.


endinterface.
