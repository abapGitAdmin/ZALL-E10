*----------------------------------------------------------------------*
***INCLUDE /ADESSO/INKASSO_MONITOR_STAO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'STATUS_9000'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'STATUS_9001'.
  SET TITLEBAR  '9001'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'STATUS_9001'.
  SET TITLEBAR  '9002'.
ENDMODULE.

*&------------------------------.---------------------------------------*
*&      Module  STATUS_9003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9003 OUTPUT.
  SET PF-STATUS 'STATUS_9000'.
  SET TITLEBAR  '9003'.
ENDMODULE.

*&------------------------------.---------------------------------------*
*&      Module  STATUS_9004  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9004 OUTPUT.
  SET PF-STATUS 'STATUS_9001'.
  SET TITLEBAR  '9004'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_9005  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9005 OUTPUT.
  SET PF-STATUS 'STATUS_9001'.

  IF sy-xcode = 'REVOKE'.                     "Revoke
    SET TITLEBAR  '9005_REVO'.
  ELSE.
    SET TITLEBAR  '9005_APPR'.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_9001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_9001 OUTPUT.
  /adesso/inkasso_items-rudat = sy-datlo.
  /adesso/inkasso_items-rugrd = '01'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_9002 OUTPUT.

  IF ok NE 'WEIT'.
    /adesso/wo_mon-abgrd = '01'.
    /adesso/wo_mon-woigd = 'I00'.
  ENDIF.

  CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
    EXPORTING
      i_abgrd = /adesso/wo_mon-abgrd
    IMPORTING
      e_txt50 = /adesso/wo_req-txgrd
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txgrd.
  ENDIF.


  SELECT SINGLE woigdt FROM /adesso/wo_igrdt
         INTO /adesso/wo_req-txigd
         WHERE spras = sy-langu
         AND   woigd = /adesso/wo_mon-woigd.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txigd.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_9003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_9003 OUTPUT.

  IF ok NE 'WEIT'.
    /adesso/wo_mon-abgrd = '01'.
    /adesso/wo_mon-woigd = 'I00'.
  ENDIF.

  CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
    EXPORTING
      i_abgrd = /adesso/wo_mon-abgrd
    IMPORTING
      e_txt50 = /adesso/wo_req-txgrd
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txgrd.
  ENDIF.


  SELECT SINGLE woigdt FROM /adesso/wo_igrdt
         INTO /adesso/wo_req-txigd
         WHERE spras = sy-langu
         AND   woigd = /adesso/wo_mon-woigd.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txigd.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_9004  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_9004 OUTPUT.

  IF ok NE 'WEIT'.
    /adesso/wo_mon-wovks = '00'.
    /adesso/wo_mon-abgrd = '09'.
    /adesso/wo_mon-woigd = 'I01'.
  ENDIF.

  SELECT SINGLE wovkt FROM /adesso/wo_vkst
         INTO /adesso/wo_req-txvks
         WHERE spras = sy-langu
         AND   wovks = /adesso/wo_mon-wovks.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txvks.
  ENDIF.

  CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
    EXPORTING
      i_abgrd = /adesso/wo_mon-abgrd
    IMPORTING
      e_txt50 = /adesso/wo_req-txgrd
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txgrd.
  ENDIF.

  SELECT SINGLE woigdt FROM /adesso/wo_igrdt
         INTO /adesso/wo_req-txigd
         WHERE spras = sy-langu
         AND   woigd = /adesso/wo_mon-woigd.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txigd.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_9005  OUTPUT
*&---------------------------------------------------------------------*
MODULE init_9005 OUTPUT.

  SELECT SINGLE wovkt FROM /adesso/wo_vkst
         INTO /adesso/wo_req-txvks
         WHERE spras = sy-langu
         AND   wovks = /adesso/wo_mon-wovks.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txvks.
  ENDIF.

  CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
    EXPORTING
      i_abgrd = /adesso/wo_mon-abgrd
    IMPORTING
      e_txt50 = /adesso/wo_req-txgrd
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txgrd.
  ENDIF.

  SELECT SINGLE woigdt FROM /adesso/wo_igrdt
         INTO /adesso/wo_req-txigd
         WHERE spras = sy-langu
         AND   woigd = /adesso/wo_mon-woigd.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-txigd.
  ENDIF.

  CALL FUNCTION 'FKK_DB_TFK050AT_SINGLE'
    EXPORTING
      i_agsta = /adesso/wo_mon-agsta
    IMPORTING
      e_txt50 = /adesso/wo_req-astxt
    EXCEPTIONS
      OTHERS  = 1.

  IF sy-subrc NE 0.
    CLEAR /adesso/wo_req-astxt.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SCREEN_INPUT_9005  OUTPUT
*&---------------------------------------------------------------------*
MODULE screen_input_9005 OUTPUT.

  IF /adesso/wo_mon-agsta = '20'.  "Interne Ausbuchung
    LOOP AT SCREEN.
      IF screen-group2 = 'WOF'.    "Keine Verkaufsquote
        screen-input   = '0'.
        screen-active  = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CASE sy-xcode.
    WHEN 'REVOKE'.                     "Revoke, keine Eingabe
      LOOP AT SCREEN.
        IF screen-group1 = 'REV'.
          screen-input  = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN 'APPROVE'.                    "Approve
  ENDCASE.

ENDMODULE.
