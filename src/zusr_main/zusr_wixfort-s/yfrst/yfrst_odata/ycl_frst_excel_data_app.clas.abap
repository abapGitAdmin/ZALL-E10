CLASS ycl_frst_excel_data_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor.

    INTERFACES yif_frst_excel_data_app.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA go_data_dao TYPE REF TO yif_frst_excel_data_dao.
ENDCLASS.



CLASS ycl_frst_excel_data_app IMPLEMENTATION.

  METHOD constructor.

    go_data_dao = NEW ycl_frst_excel_data_dao( ).
  ENDMETHOD.

  METHOD yif_frst_excel_data_app~delete.
*    DATA(lv_fiel_id) it_key_tab-.dfsf
*    me->go_data_dao->delete( lv_file_id ).
  ENDMETHOD.

  METHOD yif_frst_excel_data_app~get_entity.

*    me->go_data_dao->get_entity( iv_file_id = iv_file_id
*                                 iv_entity = iv_entity ).
  ENDMETHOD.

  METHOD yif_frst_excel_data_app~get_entityset.

    DATA(lt_entityset) = me->go_data_dao->get_entityset( ).
    APPEND LINES OF lt_entityset TO et_entityset.
  ENDMETHOD.

  METHOD yif_frst_excel_data_app~update.

*    me->go_data_dao->update( is_entry  ).
  ENDMETHOD.

ENDCLASS.
