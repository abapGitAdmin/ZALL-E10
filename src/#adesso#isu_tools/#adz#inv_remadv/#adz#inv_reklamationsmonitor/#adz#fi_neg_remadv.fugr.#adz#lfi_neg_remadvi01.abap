*----------------------------------------------------------------------*
***INCLUDE /ADZ/LFI_NEG_REMADVI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE ok.
    WHEN 'ABR'.
      LEAVE TO SCREEN 0.
    WHEN 'RW'.
      LEAVE TO SCREEN 0.
    WHEN 'SAV'.
      IF bemerkung IS INITIAL.
        MESSAGE 'Bitte eine Bemerkung eingeben!' TYPE 'I' DISPLAY LIKE 'E'.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'STATUS9000'.
  SET TITLEBAR 'Blubb'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_BEMERKUNG' ITSELF
CONTROLS: tc_bemerkung TYPE TABLEVIEW USING SCREEN 9000.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_BEMERKUNG'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_bemerkung_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_bemerkung LINES tc_bemerkung-lines.
ENDMODULE.
