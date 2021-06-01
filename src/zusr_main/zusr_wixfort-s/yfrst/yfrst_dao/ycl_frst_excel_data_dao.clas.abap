CLASS ycl_frst_excel_data_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES yif_frst_excel_data_dao .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_frst_excel_data_dao IMPLEMENTATION.

  METHOD yif_frst_excel_data_dao~create.

    INSERT  yft_rst_e_data FROM is_data_set.
  ENDMETHOD.

  METHOD yif_frst_excel_data_dao~delete.
  ENDMETHOD.

  METHOD yif_frst_excel_data_dao~get_entity.

  SELECT SINGLE * FROM yft_rst_e_data WHERE file_id = @iv_file_id AND entity = @iv_entity
  INTO CORRESPONDING FIELDS OF @es_entity.

  RETURN.
  ENDMETHOD.


  METHOD yif_frst_excel_data_dao~get_entityset.
  SELECT * FROM yft_rst_e_data
  INTO CORRESPONDING FIELDS OF TABLE @et_entityset.

  RETURN.
  ENDMETHOD.

  METHOD yif_frst_excel_data_dao~update.

  UPDATE yft_rst_e_data FROM is_data_set.
  ENDMETHOD.



ENDCLASS.
