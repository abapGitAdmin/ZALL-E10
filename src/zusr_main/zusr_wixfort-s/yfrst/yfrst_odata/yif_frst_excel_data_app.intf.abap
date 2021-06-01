INTERFACE yif_frst_excel_data_app
  PUBLIC .
  TYPES: tt_yft_rst_e_data TYPE TABLE OF yft_rst_e_data WITH KEY file_id entity.
  METHODS get_entity IMPORTING
                               io_message_container TYPE REF TO /iwbep/if_message_container
                               it_key_tab  type /iwbep/t_mgw_name_value_pair
                     EXPORTING es_entity     TYPE ycl_yfrst_excel_upload_mpc=>ts_data.
  METHODS get_entityset IMPORTING
                                  io_message_container TYPE REF TO /iwbep/if_message_container
*                                  it_key_tab  type /iwbep/t_mgw_name_value_pair

                        EXPORTING et_entityset  TYPE ycl_yfrst_excel_upload_mpc=>tt_data.
  METHODS update IMPORTING
                   io_message_container TYPE REF TO /iwbep/if_message_container
                   is_data_set          type ref to /iwbep/if_mgw_entry_provider.
  METHODS delete IMPORTING
                   io_message_container TYPE REF TO /iwbep/if_message_container
                   it_key_tab  type /iwbep/t_mgw_name_value_pair.

ENDINTERFACE.
