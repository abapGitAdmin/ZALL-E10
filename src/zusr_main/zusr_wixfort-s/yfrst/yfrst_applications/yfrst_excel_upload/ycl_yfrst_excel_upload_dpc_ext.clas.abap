CLASS ycl_yfrst_excel_upload_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM ycl_yfrst_excel_upload_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor.
    METHODS /iwbep/if_mgw_appl_srv_runtime~create_stream REDEFINITION .

  PROTECTED SECTION.

    METHODS dataset_get_entity
        REDEFINITION .
    METHODS dataset_get_entityset
        REDEFINITION .
    METHODS dataset_update_entity
        REDEFINITION .
    METHODS dataset_delete_entity
        REDEFINITION .
  PRIVATE SECTION.
    DATA go_excel_upload TYPE REF TO yif_frst_excel_upload_app.
    DATA go_excel_data   TYPE REF TO yif_frst_excel_data_app.
ENDCLASS.



CLASS ycl_yfrst_excel_upload_dpc_ext IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).
    me->go_excel_upload = NEW ycl_frst_excel_upload_app( ).
    me->go_excel_data = NEW ycl_frst_excel_data_app(  ).
  ENDMETHOD.

  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

    DATA(lo_message_container) = me->mo_context->get_message_container( ).
    go_excel_upload->create_stream(
        EXPORTING
            io_message_container = lo_message_container
            iv_slug = iv_slug
            it_key_tab = it_key_tab
            is_media_resource = is_media_resource ).
  ENDMETHOD.

  METHOD dataset_delete_entity.
    DATA(lo_message_container) = me->mo_context->get_message_container( ).
    go_excel_data->delete(
        EXPORTING
            io_message_container = lo_message_container
            it_key_tab = it_key_tab ).
  ENDMETHOD.


  METHOD dataset_get_entity.

    DATA(lo_message_container) = me->mo_context->get_message_container( ).
    go_excel_data->get_entity(
        EXPORTING
            io_message_container = lo_message_container
            it_key_tab = it_key_tab ).
  ENDMETHOD.


  METHOD dataset_get_entityset.

    DATA(lo_message_container) = me->mo_context->get_message_container( ).
    go_excel_data->get_entityset(
        EXPORTING
        io_message_container = lo_message_container
*         it_key_tab = it_key_tab
        IMPORTING et_entityset = et_entityset ).


  ENDMETHOD.


  METHOD dataset_update_entity.

    DATA(lo_message_container) = me->mo_context->get_message_container( ).
    go_excel_data->update(
        EXPORTING
            io_message_container = lo_message_container
            is_data_set = io_data_provider ).
  ENDMETHOD.
ENDCLASS.
