*----------------------------------------------------------------------*
***INCLUDE /ADESSO/INKASSO_MONITOR_I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  CASE ok.
    WHEN 'ABR'.
      LEAVE TO SCREEN 0.
    WHEN 'SAV'.
      IF wa_out-freetext IS INITIAL.
        MESSAGE 'Bitte einen Freitext eingeben!' TYPE 'I' DISPLAY LIKE 'E'.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'DEL'.
      CLEAR wa_out-freetext.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_9001  INPUT
*&---------------------------------------------------------------------*
MODULE check_input_9001 INPUT.

  CHECK okcode NE 'CANC'.
  CALL FUNCTION 'FKK_DB_TFK050D_SINGLE'
    EXPORTING
      i_deagr          = /adesso/inkasso_items-rugrd
    EXCEPTIONS
      ruckgr_not_found = 1
      OTHERS           = 2.
  IF sy-subrc NE 0.
    MESSAGE e823(>3) WITH 'TFK050D' /adesso/inkasso_items-rugrd.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  CASE ok.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'WROFF'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9005  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9005 INPUT.

  CASE ok.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_9002  INPUT
*&---------------------------------------------------------------------*
MODULE check_input_9002 INPUT.

  CASE ok.
    WHEN 'CANC'.
    WHEN 'WROFF'.
      PERFORM check_input_9002.
      IF wa_out-freetext = space.
        MESSAGE e013(/adesso/inkmon).
      ENDIF.
    WHEN OTHERS.
      PERFORM check_input_9002.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_2_9002  INPUT
*&---------------------------------------------------------------------*
MODULE check_input_2_9002 INPUT.

  CHECK ok NE 'CANC'.

  PERFORM check_input_2_9002.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_9002  INPUT
*&---------------------------------------------------------------------*
MODULE check_input_9003 INPUT.

  CASE ok.
    WHEN 'CANC'.
    WHEN 'WROFF'.
      PERFORM check_input_9003.
      IF wa_out-freetext = space.
        MESSAGE e013(/adesso/inkmon).
      ENDIF.
    WHEN 'RCALL'.
      IF wa_out-freetext = space.
        MESSAGE e013(/adesso/inkmon).
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.



*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_9005  INPUT
*&---------------------------------------------------------------------*
MODULE check_input_9005 INPUT.


  CASE ok.
    WHEN 'CANC'.
    WHEN 'APPROVE'.
      PERFORM check_input_9004.
      IF wa_out-freetext = space.
*        MESSAGE e013(/adesso/inkmon).
      ENDIF.
    WHEN 'REVOKE'.
      IF wa_out-freetext = space.
        MESSAGE e013(/adesso/inkmon).
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9003  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9003 INPUT.

  CASE ok.

* Abbruch
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.

* Erneute Bearbeitung
    WHEN 'RCALL'.
      LEAVE TO SCREEN 0.

* Ausbuchung
    WHEN 'WROFF'.
      LEAVE TO SCREEN 0.

    when others.

  ENDCASE.


ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_9004  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_9004 INPUT.

  CASE ok.
    WHEN 'CANC'.
    WHEN 'SELL'.
      PERFORM check_input_9004.
      IF wa_out-freetext = space.
        MESSAGE e013(/adesso/inkmon).
      ENDIF.
    WHEN OTHERS.
      PERFORM check_input_9004.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9004  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_9004 INPUT.

  CASE ok.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'SELL'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALUE_REQUEST_ABGRD  INPUT
*&---------------------------------------------------------------------*
MODULE value_request_abgrd INPUT.
*----------------------------------------------------------------------*
  DATA: lt_tfk048a        LIKE tfk048a    OCCURS 0 WITH HEADER LINE,
        lf_txt50          LIKE tfk048at-abtxt,
        lt_field_tab      LIKE dfies      OCCURS 0 WITH HEADER LINE,
        lt_value_tab(100) TYPE c          OCCURS 0 WITH HEADER LINE,
        lf_retfield       TYPE dfies-fieldname,
        lt_dselc          TYPE dselc      OCCURS 0 WITH HEADER LINE,
        lt_return         TYPE ddshretval OCCURS 0 WITH HEADER LINE.

  CONSTANTS:                                             "HW1333033 PeV
    lc_pvalkey TYPE ddshpvkey VALUE 'FP04_ABGRD'.        "HW1333033 PeV
*----------------------------------------------------------------------*
  CALL FUNCTION 'FKK_DB_TFK048A_MULTIPLE'
    EXPORTING
      i_xwotr       = '1'
    TABLES
      t_tfk048a     = lt_tfk048a
    EXCEPTIONS
      input_error   = 1
      nothing_found = 2
      OTHERS        = 3.

  IF sy-subrc <> 0.
    MESSAGE s801(dh).
*   Keine Werte gefunden
    EXIT.
  ENDIF.

  REFRESH: lt_value_tab, lt_field_tab, lt_dselc.
  LOOP AT lt_tfk048a.
* -------------------  fill value + text -----------------------------*
    lt_value_tab = lt_tfk048a-abgrd.
    APPEND: lt_value_tab.

    CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
      EXPORTING
        i_abgrd   = lt_tfk048a-abgrd
      IMPORTING
        e_txt50   = lf_txt50
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc =  0.
      lt_value_tab = lf_txt50.
      APPEND: lt_value_tab.
    ELSE.
      CLEAR lt_value_tab.
      APPEND: lt_value_tab.
    ENDIF.
  ENDLOOP.
* --------------------- fill field table ------------------------------*
  lt_field_tab-tabname = 'TFK048A'.
  lt_field_tab-fieldname = 'ABGRD'.
  APPEND lt_field_tab.
  lt_field_tab-tabname = 'TFK048AT'.
  lt_field_tab-fieldname = 'ABTXT'.
  APPEND lt_field_tab.
  lf_retfield = 'ABGRD'.

  lt_dselc-fldname   = 'ABTXT'.
  lt_dselc-dyfldname = '/ADESSO/WO_REQ-TXGRD'.
  APPEND lt_dselc.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = lf_retfield
      value_org       = 'C'
      pvalkey         = lc_pvalkey                       "HW1333033 PeV
      dynpprog        = '/ADESSO/INKASSO_MONITOR'
      dynpnr          = sy-dynnr
      dynprofield     = '/ADESSO/WO_MON-ABGRD'
      display         = 'F'
    TABLES
      value_tab       = lt_value_tab
      field_tab       = lt_field_tab
      dynpfld_mapping = lt_dselc
    EXCEPTIONS
      parameter_error = 0
      no_values_found = 0.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALUE_REQUEST_WOIGD  INPUT
*&---------------------------------------------------------------------*
MODULE value_request_woigd INPUT.

  PERFORM value_request_woigd USING sy-dynnr.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALUE_REQUEST_WOVKS  INPUT
*&---------------------------------------------------------------------*
MODULE value_request_wovks INPUT.

*----------------------------------------------------------------------*
  DATA: lt_wo_vks       LIKE /adesso/wo_vks OCCURS 0 WITH HEADER LINE,
        lt_dfies_vks    LIKE dfies          OCCURS 0 WITH HEADER LINE,
        lt_val_vks(100) TYPE c        OCCURS 0 WITH HEADER LINE,
        lf_retf_vks     TYPE dfies-fieldname,
        lt_dselc_vks    LIKE dselc    OCCURS 0 WITH HEADER LINE.
*----------------------------------------------------------------------*

  SELECT * FROM /adesso/wo_vks
         INTO TABLE lt_wo_vks.

  IF sy-subrc <> 0.
    MESSAGE e011(/adesso/inkmon) WITH ' '.
  ENDIF.

  REFRESH: lt_val_vks, lt_dfies_vks, lt_dselc_vks.

  LOOP AT lt_wo_vks.
* -------------------  fill value + text -----------------------------*
    lt_val_vks = lt_wo_vks-wovks.
    APPEND: lt_val_vks.

    SELECT SINGLE wovkt FROM /adesso/wo_vkst
           INTO  @DATA(lf_wovkt)
           WHERE spras = @sy-langu
           AND   wovks = @lt_wo_vks-wovks.

    IF sy-subrc =  0.
      lt_val_vks = lf_wovkt.
      APPEND: lt_val_vks.
    ELSE.
      CLEAR lt_val_vks.
      APPEND: lt_val_vks.
    ENDIF.
  ENDLOOP.
* --------------------- fill field table ------------------------------*
  lt_dfies_vks-tabname   = '/ADESSO/WO_VKS'.
  lt_dfies_vks-fieldname = 'WOVKS'.
  APPEND lt_dfies_vks.
  lt_dfies_vks-tabname   = '/ADESSO/WO_VKST'.
  lt_dfies_vks-fieldname = 'WOVKT'.
  APPEND lt_dfies_vks.

  lf_retf_vks = 'WOVKS'.

  lt_dselc_vks-fldname   = 'WOVKT'.
  lt_dselc_vks-dyfldname = '/ADESSO/WO_REQ-TXVKS'.
  APPEND lt_dselc_vks.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = lf_retf_vks
      value_org       = 'C'
      pvalkey         = lc_pvalkey                       "HW1333033 PeV
      dynpprog        = '/ADESSO/INKASSO_MONITOR'
      dynpnr          = sy-dynnr
      dynprofield     = '/ADESSO/WO_MON-WOVKS'
      display         = 'F'
    TABLES
      value_tab       = lt_val_vks
      field_tab       = lt_dfies_vks
      dynpfld_mapping = lt_dselc_vks
    EXCEPTIONS
      parameter_error = 0
      no_values_found = 0.

ENDMODULE.
