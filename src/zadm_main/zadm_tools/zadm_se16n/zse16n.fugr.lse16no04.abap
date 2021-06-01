*----------------------------------------------------------------------*
***INCLUDE LSE16NO04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1000 OUTPUT.

   refresh functab.
   if gd_role_display = true.
     perform exclude_function using 'SAVE_ROLE'.
   endif.
   SET PF-STATUS '1000' excluding functab.
   SET TITLEBAR '900'.

ENDMODULE.                 " STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_TAB_ROLE_TABLE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_TAB_ROLE_TABLE OUTPUT.


  IF gs_role_table-tabname <> SPACE.
    gs_selfields-rollname = fc-tabname.
    gs_field = gs_role_table-tabname.
    perform convert_to_extern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_table-tabname = gs_field.
  ENDIF.
  IF gs_role_table-fieldname <> SPACE.
    gs_selfields-rollname = fc-fieldname.
    gs_field = gs_role_table-fieldname.
    perform convert_to_extern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_table-fieldname = gs_field.
  ENDIF.

ENDMODULE.                 " SHOW_TAB_ROLE_TABLE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_TAB_ROLE_TABLE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_TAB_ROLE_TABLE OUTPUT.

*.Do not show unused lines
  IF TAB_role_table-CURRENT_LINE > LINECOUNT_role_table.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF LINECOUNT_role_table = 0.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*.If display-mode set to display
  if gd_role_display = true.
     loop at screen.
        if screen-group1 = 'INP'.
           screen-input = 0.
           modify screen.
        endif.
     endloop.
  endif.
  loop at tab_role_table-cols into wa.
     if wa-screen-name = 'GS_ROLE_TABLE-NO_AUTHORITY'.
*       wa-screen-active    = 0.
       wa-invisible = 1.
       modify tab_role_table-cols from wa.
     endif.
  endloop.


ENDMODULE.                 " CHANGE_TAB_ROLE_TABLE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GET_LINECOUNT_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LINECOUNT_1000 OUTPUT.

  DESCRIBE TABLE GT_role_table LINES LINECOUNT_role_table.
  TAB_role_table-LINES = LINECOUNT_role_table.
  DESCRIBE TABLE GT_role_value LINES LINECOUNT_role_value.
  TAB_role_value-LINES = LINECOUNT_role_value.
  DESCRIBE TABLE GT_user_role  LINES LINECOUNT_user_role.
  TAB_user_role-LINES = LINECOUNT_user_role.
*.hide user role assignment
  TAB_USER_ROLE-invisible = 1.
  loop at screen.
    if screen-name = 'CREATE_USER_ROLE' or
       screen-name = 'DELETE_USER_ROLE' or
       screen-name = 'INSERT_USER_ROLE'.
       screen-invisible = 1.
       screen-active    = 0.
       modify screen.
    endif.
  endloop.

*.hide buttons as long as no action is chosen
  if gs_role-mode = fc-display or
     gs_role-mode = space.
    loop at screen.
      if screen-group1 = 'BUT'.
*        screen-active = 0.
        screen-input = 0.
        modify screen.
      endif.
    endloop.
  endif.

*.in display mode only allow display
  if gd_role_display_only = true.
    loop at screen.
      if screen-group4 = 'I02'.
*        screen-active = 0.
        screen-input = 0.
        modify screen.
      endif.
    endloop.
  endif.

ENDMODULE.                 " GET_LINECOUNT_1000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_TAB_ROLE_VALUE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_TAB_ROLE_VALUE OUTPUT.

  IF gs_role_value-tabname <> SPACE.
    gs_selfields-rollname = fc-tabname.
    gs_field = gs_role_value-tabname.
    perform convert_to_extern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_value-tabname = gs_field.
  ENDIF.
  IF gs_role_value-dd_reftab <> SPACE.
    gs_selfields-rollname = fc-tabname.
    gs_field = gs_role_value-dd_reftab.
    perform convert_to_extern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_value-dd_reftab = gs_field.
  ENDIF.
  IF gs_role_value-fieldname <> SPACE.
    gs_selfields-rollname = fc-fieldname.
    gs_field = gs_role_value-fieldname.
    perform convert_to_extern using    space
                              changing gs_selfields
                                       gs_field.
    gs_role_value-fieldname = gs_field.
  ENDIF.

ENDMODULE.                 " SHOW_TAB_ROLE_VALUE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_TAB_ROLE_VALUE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_TAB_ROLE_VALUE OUTPUT.

*.Do not show unused lines
  IF TAB_role_value-CURRENT_LINE > LINECOUNT_role_value.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF LINECOUNT_role_value = 0.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*.If display-mode set to display
  if gd_role_display = true.
     loop at screen.
        if screen-group1 = 'INP'.
           screen-input = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.check if there is an entry in gt_multi -> then set flag
  loop at gt_multi
      where tabname   = gs_role_value-tabname
        and fieldname = gs_role_value-fieldname.
  endloop.
  if sy-subrc = 0.
     gs_role_value-push = true.
  endif.
*.change the icon of the pushbutton
  if gs_role_value-push = true.
     perform icon_create using    'ICON_DISPLAY_MORE'
                         changing push
                                  gd_dummy_text.
  else.
     perform icon_create using    'ICON_ENTER_MORE'
                         changing push
                                  gd_dummy_text.
  endif.


ENDMODULE.                 " CHANGE_TAB_ROLE_VALUE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_TAB_USER_ROLE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_TAB_USER_ROLE OUTPUT.

*.Do not show unused lines
  IF TAB_user_role-CURRENT_LINE > LINECOUNT_user_role.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF LINECOUNT_user_role = 0.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*.If display-mode set to display
  if gd_role_display = true.
     loop at screen.
        if screen-group1 = 'INP'.
           screen-input = 0.
           modify screen.
        endif.
     endloop.
  endif.

ENDMODULE.                 " SHOW_TAB_USER_ROLE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_TAB_USER_ROLE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_TAB_USER_ROLE OUTPUT.

  IF gs_user_role-uname <> SPACE.
    gs_selfields-rollname = fc-uname.
    gs_field = gs_user_role-uname.
    perform convert_to_extern using    space
                              changing gs_selfields
                                       gs_field.
    gs_user_role-uname = gs_field.
  ENDIF.

ENDMODULE.                 " CHANGE_TAB_USER_ROLE  OUTPUT
