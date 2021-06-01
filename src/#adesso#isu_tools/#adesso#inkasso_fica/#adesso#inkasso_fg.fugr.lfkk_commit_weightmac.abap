*----------------------------------------------------------------------*
*   INCLUDE LFKK_COMMIT_WEIGHTMAC                                      *
*----------------------------------------------------------------------*

SET EXTENDED CHECK OFF.
* commit driving data
DATA: _mac_h_com_sy_tfill LIKE sy-tfill.
DATA: _mac_h_com_struct_length TYPE int4.
SET EXTENDED CHECK ON.

* add commit_weight for structs
DEFINE mac_commit_weight_struct_add.
  describe field &1 length _mac_h_com_struct_length in byte mode.
  call function 'FKK_COMMIT_WEIGHT_ADD'
    exporting
      i_add_value = _mac_h_com_struct_length.
END-OF-DEFINITION.

* add commit_weight for tables
DEFINE mac_commit_weight_table_add.
  describe table &1 lines _mac_h_com_sy_tfill.
  _mac_h_com_struct_length = ( _mac_h_com_sy_tfill * sy-tleng ).
  call function 'FKK_COMMIT_WEIGHT_ADD'
    exporting
      i_add_value = _mac_h_com_struct_length.
END-OF-DEFINITION.

* initialize commit_weight
DEFINE mac_commit_weight_init.
  call function 'FKK_COMMIT_WEIGHT_INIT'.
END-OF-DEFINITION.

* check if commit is necessary
DEFINE mac_commit_weight_check.
  call function 'FKK_COMMIT_WEIGHT_CHECK'
    importing
      e_comreq = &1.
END-OF-DEFINITION.
