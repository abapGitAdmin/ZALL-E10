*----------------------------------------------------------------------*
***INCLUDE LSE16NI06 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1000 INPUT.

  save_ok_code = ok_code.
  clear ok_code.

  case save_ok_code.
*...icons for role handling
    when fc-create.
       perform create_role.
    when fc-change.
       perform change_role using true.
    when fc-display.
       perform change_role using space.
    when fc-delete.
       perform delete_role.
    when fc-copy.
       perform copy_role.
    when fc-save.
       perform save_role using gd_role
                               gd_role_txt.
    when fc-transport.
       perform transport_role.
*...icons for Role_Table
    when fc-del_rol_tab.
       perform delete_role_table.
    when fc-cre_rol_tab.
*......check that an action has been chosen
       if gs_role_def-se16n_role <> gd_role.
          message i206(wusl).
          exit.
       endif.
       clear gs_role_table.
       append gs_role_table to gt_role_table.
    when fc-ins_rol_tab.
       perform insert_role_table.
*...icons for Role_Value
    when fc-del_rol_val.
       perform delete_role_value.
    when fc-cre_rol_val.
*......check that an action has been chosen
       if gs_role_def-se16n_role <> gd_role.
          message i206(wusl).
          exit.
       endif.
       clear gs_role_value.
       append gs_role_value to gt_role_value.
    when fc-ins_rol_val.
       perform insert_role_value.
    when fc-push.
       perform value_input.
*...icons for User_Role
    when fc-del_use_rol.
       perform delete_user_role.
    when fc-cre_use_rol.
       clear gs_user_role.
       append gs_user_role to gt_user_role.
    when fc-ins_use_rol.
       perform insert_user_role.
*...special icons
    when 'MULTI_TAB'.
       perform f4_field using 'T' 'X'.
    when 'MULTI_VAL'.
       perform f4_field using 'V' 'X'.
*...change documents
    when fc-change_doc.
      if gd_role is not initial.
        submit rkse16n_role_cd_display and return
          with p_role = gd_role.
      endif.
*...normal navigation
    when fc-f03.
      perform end_1000.
    when fc-f15.
      perform end_1000.
  endcase.
  gd_save_txt = gd_role_txt.

ENDMODULE.                 " USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*&      Module  TAKE_DATA_ROLE_TABLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TAKE_DATA_ROLE_TABLE INPUT.

data: ld_field1 like dfies-lfieldname.

  READ TABLE GT_ROLE_TABLE INDEX TAB_ROLE_TABLE-CURRENT_LINE.
  IF gs_role_table-tabname <> SPACE.
    gs_selfields-rollname = fc-tabname.
    gs_field = gs_role_table-tabname.
    perform convert_to_intern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_table-tabname = gs_field.
  ENDIF.
  IF gs_role_table-fieldname <> SPACE.
    gs_selfields-rollname = fc-fieldname.
    gs_field = gs_role_table-fieldname.
    perform convert_to_intern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_table-fieldname = gs_field.
  ENDIF.
*.do the following checks:
*.1: Field is not '*'
*.2: Table and field exist or table = '*'
  if gs_role_table-fieldname = '*'.
     message e203(wusl) with 'text'.
  endif.
  if gs_role_table-tabname <> space and
     gs_role_table-tabname <> '*'   and
     gs_role_table-fieldname <> space.
     ld_field1 = gs_role_table-fieldname.
     CALL FUNCTION 'DDIF_NAMETAB_GET'
       EXPORTING
         TABNAME           = gs_role_table-tabname
         LFIELDNAME        = ld_field1
       EXCEPTIONS
         NOT_FOUND         = 1
         OTHERS            = 2.

     IF SY-SUBRC <> 0.
        message e204(wusl) with gs_role_table-tabname
                                gs_role_table-fieldname.
     ENDIF.
  endif.
  move-corresponding gs_role_table to gt_role_table.
  modify gt_role_table index tab_role_table-current_line.

  gd_role_changed = true.

ENDMODULE.                 " TAKE_DATA_ROLE_TABLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  TAKE_DATA_ROLE_VALUE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TAKE_DATA_ROLE_VALUE INPUT.

data: ld_field2 like DFIES-LFIELDNAME.

  READ TABLE GT_ROLE_VALUE INDEX TAB_ROLE_VALUE-CURRENT_LINE.
  IF gs_role_value-tabname <> SPACE.
    gs_selfields-rollname = fc-tabname.
    gs_field = gs_role_value-tabname.
    perform convert_to_intern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_value-tabname = gs_field.
  ENDIF.
  IF gs_role_value-dd_reftab <> SPACE.
    gs_selfields-rollname = fc-tabname.
    gs_field = gs_role_value-dd_reftab.
    perform convert_to_intern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_value-dd_reftab = gs_field.
    ld_field2 = gs_role_value-fieldname.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
       EXPORTING
         TABNAME           = gs_role_value-dd_reftab
         LFIELDNAME        = ld_field2
       EXCEPTIONS
         NOT_FOUND         = 1
         OTHERS            = 2.

    IF SY-SUBRC <> 0.
       message e204(wusl) with gs_role_value-dd_reftab
                               gs_role_value-fieldname.
    ENDIF.
  ENDIF.
  IF gs_role_value-fieldname <> SPACE.
    gs_selfields-rollname = fc-fieldname.
    gs_field = gs_role_value-fieldname.
    perform convert_to_intern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_value-fieldname = gs_field.
  ENDIF.
*.do the following checks:
*.1: Field is not '*'
*.2: Table and field exist or table = '*'
  if gs_role_value-fieldname = '*'.
     message e203(wusl) with 'text'.
  endif.
  if gs_role_value-tabname <> space and
     gs_role_value-tabname <> '*'   and
     gs_role_value-fieldname <> space.
     ld_field2 = gs_role_value-fieldname.
     CALL FUNCTION 'DDIF_NAMETAB_GET'
       EXPORTING
         TABNAME           = gs_role_value-tabname
         LFIELDNAME        = ld_field2
       EXCEPTIONS
         NOT_FOUND         = 1
         OTHERS            = 2.

     IF SY-SUBRC <> 0.
        message e204(wusl) with gs_role_value-tabname
                                gs_role_value-fieldname.
     ENDIF.
  endif.
  move-corresponding gs_role_value to gt_role_value.
  modify gt_role_value index tab_role_value-current_line.

  gd_role_changed = true.

ENDMODULE.                 " TAKE_DATA_ROLE_VALUE  INPUT
*&---------------------------------------------------------------------*
*&      Module  BACK_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE back_1000 INPUT.

  save_ok_code = ok_code.
  CLEAR ok_code.

  CASE save_ok_code.
  WHEN fc-f12.
    PERFORM exit_1000.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TAKE_DATA_USER_ROLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TAKE_DATA_USER_ROLE INPUT.

  READ TABLE GT_USER_ROLE INDEX TAB_USER_ROLE-CURRENT_LINE.
  IF gs_user_role-uname <> SPACE.
    gs_selfields-rollname = fc-uname.
    gs_field = gs_user_role-uname.
    perform convert_to_intern using    space
                              changing gs_selfields
                                       gs_field.
    gs_user_role-uname = gs_field.
  ENDIF.
  move-corresponding gs_user_role to gt_user_role.
  modify gt_user_role index tab_user_role-current_line.

ENDMODULE.                 " TAKE_DATA_USER_ROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_TAB_TABLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TAB_TABLE INPUT.

  perform f4_role_tab using 'T'.

ENDMODULE.                 " F4_TAB_TABLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_FIELD_TABLE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_FIELD_TABLE INPUT.

  perform f4_field using 'T' ' '.

ENDMODULE.                 " F4_FIELD_TABLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_TAB_VALUE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TAB_VALUE INPUT.

  perform f4_role_tab using 'V'.

ENDMODULE.                 " F4_TAB_VALUE  INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_FIELD_VALUE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_FIELD_VALUE INPUT.

  perform f4_field using 'V' ' '.

ENDMODULE.                 " F4_FIELD_VALUE  INPUT
