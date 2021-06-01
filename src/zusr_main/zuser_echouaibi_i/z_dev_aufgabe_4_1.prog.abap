*&---------------------------------------------------------------------*
*& Modulpool         Z_DEV_AUFGABE_4_1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
PROGRAM z_dev_aufgabe_4_1.

START-OF-SELECTION.

  CALL SCREEN 100.

  DATA: benutzer TYPE z_dev_nr,
        passwort TYPE z_dev_nr.

  DATA: ok_code LIKE sy-ucomm.


MODULE status_0100 OUTPUT.

  SET PF-STATUS 'PF-STATUS'.
  SET TITLEBAR 'TITELBAR'.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'LOGON'.
      IF ( benutzer = 'ILIASS' ) AND
      ( passwort = '123456' ).
        LEAVE TO SCREEN 200.
      ENDIF.
  ENDCASE.
ENDMODULE. " USER_COMMAND_0100 INPUT


MODULE status_0200 OUTPUT.

  SET PF-STATUS 'PF-STATUS 200'.
  SET TITLEBAR 'TITELBAR 200'.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0200 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'BELEG'.
      LEAVE TO SCREEN 300.
  ENDCASE.
ENDMODULE. " USER_COMMAND_0200 INPUT

MODULE status_0300 OUTPUT.

  SET PF-STATUS 'PF-STATUS 300'.
  SET TITLEBAR 'TITELBAR 300'.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0300 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  CASE ok_code.
    WHEN 'EXIT' OR 'BACK' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'NEXT'.
      LEAVE TO SCREEN 200.
    WHEN 'ENDE'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE. " USER_COMMAND_0300 INPUT
