*----------------------------------------------------------------------*
***INCLUDE Z_BCALV_TREE_02_USER_COMMANI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
MOVE-CORRESPONDING zdev_artikel TO ls_artikel.
  SELECT  SINGLE *
    FROM  zdev_artikel
    WHERE artikelnr = @zdev_artikel-artikelnr
    INTO  CORRESPONDING FIELDS OF @ls_artikel.
ENDMODULE.
