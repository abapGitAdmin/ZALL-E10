*&---------------------------------------------------------------------*
*&  Include           ZUSER_COMMAND
*&---------------------------------------------------------------------*

MODULE Zuser_command_0100 INPUT.
CASE sy-ucomm.

  WHEN 'BACK' or 'EXIT' or 'CANCEL' .
    SET SCREEN 0.
ENDCASE.
ENDMODULE.
