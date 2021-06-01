*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LWO_REQO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  SET_STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE set_status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_EDITOR_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE init_editor_0100 OUTPUT.

  IF stext_editor IS INITIAL.
*   create control container
    CREATE OBJECT seditor_container
      EXPORTING
        container_name              = 'STEXTEDITOR'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    IF sy-subrc NE 0.
      MESSAGE e802(bmen).
    ENDIF.

*   create calls constructor, which initializes, creats and links
*   a TextEdit Control
    CREATE OBJECT stext_editor
      EXPORTING
        parent                     = seditor_container
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
        wordwrap_to_linebreak_mode = cl_gui_textedit=>true
        wordwrap_position          = 80
      EXCEPTIONS
        OTHERS                     = 1.

    IF sy-subrc NE 0.
      MESSAGE e802(bmen).
    ENDIF.

*   Accessibility: Note 1445164 - Read description of Textedit Control
    DATA: lv_acc_string TYPE string.
    lv_acc_string = 'Long Text'(ac1).
    CALL METHOD stext_editor->set_accdescription
      EXPORTING
        accdescription = lv_acc_string
      EXCEPTIONS
        OTHERS         = 0.
  ENDIF.

  gt_editor_text[] = gt_i_text[].
*   fill with text
  CALL METHOD stext_editor->set_text_as_r3table
    EXPORTING
      table           = gt_editor_text
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.

  IF sy-subrc NE 0.
    MESSAGE e802(bmen).
  ENDIF.

*   finally flush
  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc NE 0.
    MESSAGE e802(bmen).
  ENDIF.

  CALL METHOD stext_editor->set_readonly_mode
    EXPORTING
      readonly_mode = cl_gui_textedit=>false
    EXCEPTIONS
      OTHERS        = 0.

ENDMODULE.                             " INIT_EDITOR_0110  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TC_FKKOP_CHANGE_TC_ATTR  OUTPUT
*&---------------------------------------------------------------------*
MODULE tc_fkkop_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_tc_fkkop LINES tc_fkkop-lines.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SET_HEADER_TC_0110  OUTPUT
*&---------------------------------------------------------------------*
MODULE set_header_tc_0110 OUTPUT.

  text = TEXT-tch.
  i = tc_fkkop-lines.
  WRITE i TO char(6).
  REPLACE '&1' WITH char(6) INTO text.
  WRITE tc_fkkop-top_line TO char(6).
  REPLACE '&2' WITH char(6) INTO text.
  CONDENSE text.

  /adesso/wo_req-tcheader = text.


ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  GET_CUSTOMIZING_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_customizing_0100 OUTPUT.

  SELECT SINGLE * FROM /adesso/wo_bgus
         INTO gs_bgus
         WHERE bname = sy-uname.

  IF sy-subrc = 0.
    SELECT single * FROM /adesso/wo_begr
           INTO  gs_begr
           WHERE begru = gs_bgus-begru.
  ELSE.
    MESSAGE TEXT-e01 TYPE 'E'.
  ENDIF.

  IF gt_cust IS INITIAL.
    SELECT * FROM /adesso/wo_cust INTO TABLE gt_cust.
  ENDIF.
ENDMODULE.
