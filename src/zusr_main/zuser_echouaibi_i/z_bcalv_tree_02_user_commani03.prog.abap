*----------------------------------------------------------------------*
***INCLUDE Z_BCALV_TREE_02_USER_COMMANI03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 100.
*    WHEN .
*    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
