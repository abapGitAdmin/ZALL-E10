*----------------------------------------------------------------------*
***INCLUDE LGTDISI03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FCODE_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_0300 INPUT.

  case ok_code.
    when 'ENTER' or '&F12'.
      clear ok_code.
      set screen 0.
      leave screen.
  endcase.

ENDMODULE.                 " FCODE_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0005 INPUT.

   case gdu-fcode.
     when 'CANC'.
       clear gdu-fcode.
       set screen 0.
       leave screen.
     when 'TAKEDATE'.
       clear gdu-fcode.
       set screen 0.
       leave screen.
   endcase.

ENDMODULE.                 " USER_COMMAND_0005  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0700 INPUT.

   case ok_code.
     when 'CANC'.
*      clear ok_code.  "will be done later
       set screen 0.
       leave screen.
     when 'MARKALL'.
       perform set_gd_flags using true.
     when 'REMARKALL'.
       perform set_gd_flags using space.
     when 'TAKEDATE'.
*      clear ok_code.  "will be done later
       set screen 0.
       leave screen.
     when 'SAVE_FLAGS'.
       perform save_flags.
       clear ok_code.
   endcase.

ENDMODULE.                 " USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  DD_GET_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DD_GET_DATA INPUT.

   gt_selfields_dd-sum_up   = gs_selfields_dd-sum_up.
   gt_selfields_dd-group_by = gs_selfields_dd-group_by.
   modify gt_selfields_dd index dd_tc-current_line.

ENDMODULE.                 " DD_GET_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2000 INPUT.

  save_ok_code = ok_code.
  clear ok_code.

  case save_ok_code.
    when 'ENTER'.
    when 'TAKE'.
       set screen 0.
       leave screen.
    when 'SELECTALL'.
      loop at gt_selfields_dd.
        if gt_selfields_dd-datatype = 'QUAN' or
           gt_selfields_dd-datatype = 'CURR' or
           gt_selfields_dd-datatype = 'INT1' or
           gt_selfields_dd-datatype = 'INT2' or
           gt_selfields_dd-datatype = 'INT4' or
           gt_selfields_dd-datatype = 'CLNT' or
           gt_selfields_dd-tabname  <> gd_dd_tab.
        else.
           gt_selfields_dd-group_by = true.
           modify gt_selfields_dd index sy-tabix.
        endif.
      endloop.
    when 'DESELECT'.
      loop at gt_selfields_dd.
        if gt_selfields_dd-datatype = 'QUAN' or
           gt_selfields_dd-datatype = 'CURR' or
           gt_selfields_dd-datatype = 'INT1' or
           gt_selfields_dd-datatype = 'INT2' or
           gt_selfields_dd-datatype = 'INT4' or
           gt_selfields_dd-datatype = 'CLNT' or
           gt_selfields_dd-tabname  <> gd_dd_tab.
        else.
           clear gt_selfields_dd-group_by.
           modify gt_selfields_dd index sy-tabix.
        endif.
      endloop.
    WHEN 'SUCH'.
      perform search_dd_fieldname.
    WHEN 'SUCHFROM'.
      perform search_dd_fieldname.
*Scrolling..................................................
    WHEN 'PMM'.
      dd_tc-top_line = 1.
    WHEN 'PM'.
      dd_tc-top_line = dd_tc-top_line - looplines_dd.
      IF dd_tc-top_line < 1.
        dd_tc-top_line = 1.
      ENDIF.
    WHEN 'PP'.
      dd_tc-top_line = dd_tc-top_line + looplines_dd.
      IF dd_tc-top_line > linecount_dd.
        dd_tc-top_line = linecount_dd - looplines_dd + 1.
        IF dd_tc-top_line < 1.
          dd_tc-top_line = 1.
        ENDIF.
      ENDIF.
    WHEN 'PPP'.
      dd_tc-top_line = linecount_dd - looplines_dd + 1.
      IF dd_tc-top_line < 1.
        dd_tc-top_line = 1.
      ENDIF.
*..................................................
  endcase.

ENDMODULE.                 " USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*&      Module  DD_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DD_EXIT INPUT.

  save_ok_code = ok_code.
  CASE save_ok_code.
    WHEN '&F12'.
      gd_cancel = 'X'.
      CLEAR ok_code.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " DD_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  GD_DOUBLE_CLICK_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GD_DOUBLE_CLICK_F4 INPUT.

  perform gd_double_click_f4.

ENDMODULE.                 " GD_DOUBLE_CLICK_F4  INPUT
