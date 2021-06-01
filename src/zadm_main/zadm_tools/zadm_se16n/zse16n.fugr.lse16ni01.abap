*----------------------------------------------------------------------*
***INCLUDE LGTDISI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  TAKE_DATA_SEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TAKE_DATA_SEL INPUT.

   perform take_data_sel.

ENDMODULE.                 " TAKE_DATA_SEL  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_TAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_TAB INPUT.

   perform get_tab.

ENDMODULE.                 " GET_TAB  INPUT

*&---------------------------------------------------------------------*
*&      Module  FCODE_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_0100 INPUT.

  save_ok_code = ok_code.
  clear ok_code.

*.if enter is pressed and gd_add_column is filled, add it
  if gd_add_column <> space and
     save_ok_code  =  space.
    save_ok_code = 'ADD_COLUMN'.
  endif.

  case save_ok_code.
    when 'MARKALL'.
      loop at gt_selfields.
        gt_selfields-mark = true.
        modify gt_selfields.
      endloop.
    when 'MARKKEY'.
      loop at gt_selfields where key = true.
        gt_selfields-mark = true.
        modify gt_selfields.
      endloop.
    when 'REMARKALL'.
      loop at gt_selfields.
        clear gt_selfields-mark.
        modify gt_selfields.
      endloop.
*...start selection in batch
    when 'BATCH'.
      perform fill_tc_0100.                                   "1779629
      perform execute using space true space.
*...create extract in batch
    when 'BATCH_EXTR'.
      perform fill_tc_0100.
      perform extract_create.
*...save variant for batch processing
    when 'BATCH_VAR'.
      perform fill_tc_0100.                                   "1779629
      perform execute using space true true.
*...display change documents
    when 'CD_DISPLAY'.
      perform display_cd.
*...delete change documents
    when 'CD_DEL'.
      perform delete_cd.
*...client pressed
    when 'CLIENT'.
      if gd-read_clnt = space.
         read table gt_selfields index 1.
         check: sy-subrc = 0.
         clear: gt_selfields-low,
                gt_selfields-high,
                gt_selfields-push,
                gt_selfields-option.
         gt_selfields-sign = opt-i.
         modify gt_selfields index 1.
         delete gt_multi where fieldname = gt_selfields-fieldname.
      endif.
    when 'COLNARROW'.
      gd-colopt = true.
    when 'COLWIDE'.
      gd-colopt = space.
******************************field sorting************************
*...get column to the top
    WHEN 'ADD_COLUMN'.
      PERFORM sort_by_add_column.
*...special sorting: show fields with values at the top
    WHEN 'SORTUSED'.
      PERFORM sort_by_used_fields.
*...special sorting: show fields with values at the top
    WHEN 'UNSORTUSED'.
      PERFORM unsort_by_used_fields.
*...delete sorting information
    WHEN 'ERASEUSED'.
      PERFORM erase_used_fields.
*...set cursor down to next field with criteria filled
    WHEN 'CRITNEXT'.
       PERFORM crit_next using '0100'.
*...set cursor up to next field with criteria filled
    WHEN 'CRITPREV'.
       PERFORM crit_prev using '0100'.
*...export field sorting to file
    WHEN 'PARAM_EXPORT'.
       PERFORM param_export.
*...import field sorting from file
    WHEN 'PARAM_IMPORT'.
       PERFORM param_import.
*******************************************************************
*...delete input in all lines
    when 'DELETE_ALL'.
      loop at gt_selfields.
         clear: gt_selfields-low,
                gt_selfields-high,
                gt_selfields-push,
                gt_selfields-option,
                gt_selfields-setid.
         gt_selfields-sign = opt-i.
         modify gt_selfields index sy-tabix.
      endloop.
      refresh gt_multi.
*...delete input in one line
    when 'DELETE'.
      GET CURSOR LINE ld_line.
      ld_line = selfields_tc-CURRENT_LINE
                + ld_line - 1.
      IF ld_line = 0 OR ld_line < selfields_tc-CURRENT_LINE.
        EXIT.
      endif.
      read table gt_selfields index ld_line.
      check: sy-subrc = 0.
      clear: gt_selfields-low,
             gt_selfields-high,
             gt_selfields-push,
             gt_selfields-option,
             gt_selfields-setid.
      gt_selfields-sign = opt-i.
      modify gt_selfields index ld_line.
      delete gt_multi where fieldname = gt_selfields-fieldname.
*...delete input in all SE16H-fields
    when 'DEL_H_ALL'.
      loop at gt_selfields.
         clear: gt_selfields-sum_up,
                gt_selfields-group_by,
                gt_selfields-order_by,
                gt_selfields-toplow,
                gt_selfields-sortorder,
                gt_selfields-aggregate,
                gt_selfields-having_option,
                gt_selfields-having_value.
         modify gt_selfields index sy-tabix.
      endloop.
*...documentation
    when 'DOCU'.
      perform show_docu using '1636416'.
*...Execute
    when 'EXEC'.
*.....Perhaps the table did change without Return
      perform fill_tc_0100.
      perform execute using space space space.
*...start formula maintenance
    WHEN 'FORMULA'.
      PERFORM formula_maintain.
*...read extract
    when 'EXTR_READ'.
      perform show_extract.
*...extended search help on table
    when 'F4_EXT'.
      perform f4_tabname_extended.
*...having option
    when 'HAVING_OPTION'.
      perform f4_having_option.
*...delete layout variant of first screen
    when 'L_DEL'.
      gs_se16n_lt-tab = gd-tab.
      perform layout_delete.
*...get layout variant of first screen
    when 'L_GET'.
      gs_se16n_lt-tab = gd-tab.
      perform layout_get.
*...save layout variant of first screen
    when 'L_SAVE'.
      gs_se16n_lt-uname = sy-uname.
      perform layout_save.
*...Select only number of entries
    when 'LINES'.
      perform fill_tc_0100.                                   "1779629
      perform execute using true space space.
*...Select only number of entries (batch)
    when 'LINES_BAT'.
      perform fill_tc_0100.                                   "1779629
      perform execute using true true space.
*...Save SE38-variant for number of entries
    when 'LINES_VAR'.
      perform fill_tc_0100.                                   "1779629
      perform execute using true true true.
*...multiple selection
    when 'MORE'.
      GET CURSOR LINE ld_line.
      ld_line = selfields_tc-CURRENT_LINE
                + ld_line - 1.
      IF ld_line = 0 OR ld_line < selfields_tc-CURRENT_LINE.
        EXIT.
      endif.
      perform show_multi_select using ld_line.
*...multi input of combined or-select-statements
    when 'MULTI_OR'.
      perform multi_or.
*...technical view
    when 'NOTECHVIEW'.
      gd-tech_view = false.
*...definition of outer joins
    when 'OJKEY'.
      perform ojkey.
*...change select option
    when 'OPTION'.
      perform set_sel_option using space.
*...Double-Click-Navigation
    when 'PICK'.
      perform pick_navigation.
*...save technical settings
    when 'SAVE_FLAGS'.
      perform save_flags.
*...set technical settings
    when 'SET_FLAGS'.
      perform set_tech_flags.
*...technical view
    when 'TECHVIEW'.
      gd-tech_view = true.
*...search for fieldname
    when 'SUCH'.
      perform search_fieldname.
*...search for fieldname
    when 'SUCHFROM'.
      perform search_fieldname.
*...jump to view maintenance
    when 'VIEW'.
      perform view_maint.
*...where used list for table
    when 'WUSLTABL'.
      perform wusl_table.
    when '&F03'.
      set screen 0.
      leave screen.
    when '&F15'.
      perform end.
      set screen 0.
      leave screen.
    when c_zebra.
      gd-zebra = true.
    when c_no_zebra.
      clear gd-zebra.
    when c_no_buffer.
      clear gd-buffer.
    when c_sap_no_edit.
      clear gd-edit.
      clear gd-sapedit.
    when c_sap_edit.
      perform fill_sap_edit.
    when c_sap_fda.
      if gd-fda_on = true.
        clear gd-fda_on.
      else.
        gd-fda_on = true.
      endif.
    when c_sap_no_check.
      gd-checkkey = true.
    when c_sap_picture.
      perform fill_picture.
*Scrolling..................................................
    WHEN 'PMM'.
      selfields_tc-top_line = 1.
    WHEN 'PM'.
      selfields_tc-top_line = selfields_tc-top_line - looplines.
      IF selfields_tc-top_line < 1.
        selfields_tc-top_line = 1.
      ENDIF.
    WHEN 'PP'.
      selfields_tc-top_line = selfields_tc-top_line + looplines.
      IF selfields_tc-top_line > linecount.
        selfields_tc-top_line = linecount - looplines + 1.
        IF selfields_tc-top_line < 1.
          selfields_tc-top_line = 1.
        ENDIF.
      ENDIF.
    WHEN 'PPP'.
      selfields_tc-top_line = linecount - looplines + 1.
      IF selfields_tc-top_line < 1.
        selfields_tc-top_line = 1.
      ENDIF.
*..................................................
  endcase.
  clear ok_code.

ENDMODULE.                 " FCODE_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_MIN_COUNT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_min_count INPUT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_FDA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_fda INPUT.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FORMULA_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE formula_f4 INPUT.

  PERFORM formula_f4.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_TAB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_TAB INPUT.

  perform f4_tab changing gd-tab.

ENDMODULE.                 " F4_TAB  INPUT

*&---------------------------------------------------------------------*
*&      Module  FIELD_F4_LOW  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FIELD_F4_LOW INPUT.

   perform field_f4 using true.

ENDMODULE.                 " FIELD_F4_LOW  INPUT

*&---------------------------------------------------------------------*
*&      Module  FIELD_F4_HIGH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FIELD_F4_HIGH INPUT.

   perform field_f4 using space.

ENDMODULE.                 " FIELD_F4_HIGH  INPUT

*&---------------------------------------------------------------------*
*&      Module  BACK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE BACK INPUT.

  case ok_code.
    when 'L_CANC'.
       set screen 0.
       leave screen.
    when '&F12' or '&F15'.
       perform end.
       if sy-dynnr = '0200'.
          call method g_custom_container->free.
          call method cl_gui_cfw=>flush.
       endif.
       set screen 0.
       leave screen.
  endcase.

ENDMODULE.                 " BACK  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_MAX_LINES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_MAX_LINES INPUT.

*..try to calculate table size and send error to avoid abort
   perform check_max_lines using true.


ENDMODULE.                 " GET_MAX_LINES  INPUT

*&---------------------------------------------------------------------*
*&      Module  TAKE_DATA_MULTI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TAKE_DATA_MULTI INPUT.

   READ TABLE GT_multi_select INDEX multi_TC-CURRENT_LINE.
   gd_save_low  = gs_multi_select-low.
   gd_save_high = gs_multi_select-high.
*.. When do I have to use INTLEN, when OUTPUTLEN ?
   IF GS_multi_select-LOW <> SPACE and
      GS_multi_select-LOW <> c_space.
*.....check if input length is 45 or more
      perform check_input_length using true
                                 changing gs_multi_select-low
                                          gd_length_changed.
*.....as the screen field is upper case sensitive I have to convert
*.....all other fields
      if gt_selfields-lowercase <> true.
         translate gs_multi_select-low to upper case.  "#EC TRANSLANG
      endif.
      perform convert_to_intern using    gd_currency
                                changing gt_multi_select
                                         gs_multi_select-low.
   ENDIF.
   IF GS_multi_select-HIGH <> SPACE and
      GS_multi_select-HIGH <> c_space.
*.....check if input length is 45 or more
      perform check_input_length using true
                                 changing gs_multi_select-high
                                          gd_length_changed.
*.....as the screen field is upper case sensitive I have to convert
*.....all other fields
      if gt_selfields-lowercase <> true.
         translate gs_multi_select-high to upper case. "#EC TRANSLANG
      endif.
      perform convert_to_intern using    gd_currency
                                changing gt_multi_select
                                         gs_multi_select-high.
   ENDIF.

*..check if low-value greater than high value
   if GS_multi_select-LOW > GS_multi_select-HIGH and
      ( gs_multi_select-high <> space         or
        gt_multi_select-option = opt-bt       or
        gt_multi_select-option = opt-nb )     and
*        gt_multi_select-option = opt-nb       or
*        gt_multi_select-option = opt-np       or
*        gt_multi_select-option = opt-cp )     and
      ( gs_multi_select-datatype = 'CHAR' or
        gs_multi_select-datatype = 'DATS' or
        gs_multi_select-datatype = 'DATN' or
        gs_multi_select-datatype = 'LANG' or
        gs_multi_select-datatype = 'CUKY' or
        gs_multi_select-datatype = 'CLNT' or
        gs_multi_select-datatype = 'NUMC' or
        gs_multi_select-datatype = 'TIMN' or
*        gs_multi_select-datatype = 'CURR' or
        gs_multi_select-datatype = 'TIMS' ).
      gs_multi_select-low  = gd_save_low.
      gs_multi_select-high = gd_save_high.
      message e650(db).
   endif.

*.call input check exit if wanted
  if not gd_chk_inp_func is initial.
      perform check_input_Exit using    gd_chk_inp_func
                               changing gt_multi_select
                                        gs_multi_select-low
                                        gs_multi_select-high
                                        ld_valid
                                        ls_mesg.
      if ld_valid <> 0.
         if not ls_mesg is initial.
            MESSAGE ID ls_mesg-txtnr TYPE ls_mesg-MSGTY
            NUMBER ls_mesg-txtnr
            WITH ls_mesg-MSGV1 ls_mesg-MSGV2 ls_mesg-MSGV3 ls_mesg-MSGV4.
         else.
            MESSAGE E149(GG).
*   Der Eingabewert ist nicht zulässig
         endif.
      endif.
   endif.

   GT_multi_select-LOW  = GS_multi_select-LOW.
   GT_multi_select-HIGH = GS_multi_select-HIGH.
   if gt_multi_select-sign = space.
      gt_multi_select-sign = opt-i.
   endif.

   MODIFY GT_multi_select INDEX multi_TC-CURRENT_LINE.

ENDMODULE.                 " TAKE_DATA_MULTI  INPUT

*&---------------------------------------------------------------------*
*&      Module  FIELD_F4_MULTI_LOW  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FIELD_F4_MULTI_LOW INPUT.

   perform field_f4_multi using true space.

ENDMODULE.                 " FIELD_F4_MULTI_LOW  INPUT
*&---------------------------------------------------------------------*
*&      Module  FIELD_F4_MULTI_HIGH INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FIELD_F4_MULTI_HIGH INPUT.

   perform field_f4_multi using space space.

ENDMODULE.                 " FIELD_F4_MULTI_HIGH INPUT

*&---------------------------------------------------------------------*
*&      Module  FCODE_0001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FCODE_0001 INPUT.

data: line_no like sy-tabix.

  save_fcode = fcode.
  clear fcode.

  case save_fcode.
    when 'APPEND'.
      read table gt_multi_select index 1.
*.....delete all has been pressed before -> gt_multi_select is empty
      if sy-subrc <> 0.
         move-corresponding gs_multi_sel to gt_multi_select.
         clear: gt_multi_select-low,
             gt_multi_select-high,
             gt_multi_select-option.
         gt_multi_select-sign = 'I'.
         do new_lines times.
         append gt_multi_select.
      enddo.
*.....do not delete the option in case already lines exist
      else.
        perform add_lines using true.
      endif.
    when 'ENTER'.
      perform add_lines using space.
    when 'DELE'.
        GET CURSOR LINE line_no.
        line_no = multi_tc-current_line  "First line
                  + line_no - 1.
        check: line_no > 0.
        delete gt_multi_select index line_no.
    when 'DELE_ALL'.
        clear gt_multi_select.
        refresh gt_multi_select.
*.......set defaults
        gt_multi_select = gs_multi_sel.
        clear: gt_multi_select-low,
               gt_multi_select-high,
               gt_multi_select-option.
        gt_multi_select-sign = 'I'.
        do new_lines times.
           append gt_multi_select.
        enddo.
    when 'IMPORT'.
        perform import_from_textfile.
    when 'CLIPBOARD'.
        perform import_from_clipboard.
    when 'MULTI_F4'.
        perform multi_f4.
    when 'OPTION'.
        perform set_sel_option using 'M'.
    when 'PICK'.
        perform set_sel_option using 'M'.
    when '&F12'.
      set screen 0.
      leave screen.
    when 'TAKE'.
      set screen 0.
      leave screen.
*Scrolling..................................................
    WHEN 'PMM'.
      multi_tc-top_line = 1.
    WHEN 'PM'.
      multi_tc-top_line = multi_tc-top_line - looplines1.
      IF multi_tc-top_line < 1.
        multi_tc-top_line = 1.
      ENDIF.
    WHEN 'PP'.
      multi_tc-top_line = multi_tc-top_line + looplines1.
      IF multi_tc-top_line > linecount1.
        multi_tc-top_line = linecount1 - looplines1 + 1.
        IF multi_tc-top_line < 1.
          multi_tc-top_line = 1.
        ENDIF.
      ENDIF.
    WHEN 'PPP'.
      multi_tc-top_line = linecount1 - looplines1 + 1.
      IF multi_tc-top_line < 1.
        multi_tc-top_line = 1.
      ENDIF.
*..................................................
  endcase.

ENDMODULE.                 " FCODE_0001  INPUT
*&---------------------------------------------------------------------*
*&      Module  field_f4_low_or  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE field_f4_low_or INPUT.

  perform field_f4_or using true.

ENDMODULE.                 " field_f4_low_or  INPUT
*&---------------------------------------------------------------------*
*&      Module  field_f4_high_or  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE field_f4_high_or INPUT.

  perform field_f4_or using false.

ENDMODULE.                 " field_f4_high_or  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0111 INPUT.

  save_fcode_or = fcode_or.
  clear fcode_or.

  case save_fcode_or.
     when 'CANC'.
*.......reset all changes and take buffer values
        refresh gt_multi_or_all.
        gt_multi_or_all[] = gt_multi_or_all_buf[].
        set screen 0 .
        leave screen.
     when 'DELETE'.
        GET CURSOR LINE ld_line.
        ld_line = multi_or_tc-CURRENT_LINE
                  + ld_line - 1.
        IF ld_line = 0 OR ld_line < multi_or_tc-CURRENT_LINE.
          EXIT.
        endif.
        read table gt_multi_or index ld_line.
        clear: gt_multi_or-low,
               gt_multi_or-high,
               gt_multi_or-push,
               gt_multi_or-option.
        gt_multi_or-sign = opt-i.
        modify gt_multi_or index ld_line.
        read table gt_or_mul_all into gs_or_mul_all
                                 with key pos = gd_multi_or_pos.
        if sy-subrc = 0.
           ld_line = sy-tabix.
           delete gs_or_mul_all-selfields
                        where fieldname = gt_multi_or-fieldname.
           modify gt_or_mul_all from gs_or_mul_all index ld_line.
        endif.
     when 'DELETE_ALL'.
        loop at gt_multi_or.
           clear: gt_multi_or-low,
                  gt_multi_or-high,
                  gt_multi_or-push,
                  gt_multi_or-option.
           gt_multi_or-sign = opt-i.
           modify gt_multi_or index sy-tabix.
        endloop.
        delete gt_or_mul_all where pos = gd_multi_or_pos.
     when 'MORE'.
        perform show_multi_select_or.
     when 'NEXT'.
        add 1 to gd_multi_or_pos.
        perform next_multi_or using 'N'.
     when 'OPTION'.
        perform set_sel_option_or.
     when 'PREV'.
        if gd_multi_or_pos > 1.
           subtract 1 from gd_multi_or_pos.
           perform next_multi_or using 'P'.
        else.
           message i106(wusl).
        endif.
     when 'TAKE'.
        perform take_or.
        set screen 0.
        leave screen.
*...set cursor down to next field with criteria filled
    WHEN 'CRITNEXT'.
      PERFORM crit_next using '0111'.
*...set cursor up to next field with criteria filled
    WHEN 'CRITPREV'.
      PERFORM crit_prev using '0111'.
*...search for fieldname
     when 'SUCH'.
       perform search_or_fieldname.
*...search for fieldname
     when 'SUCHFROM'.
       perform search_or_fieldname.
*Scrolling..................................................
    WHEN 'PMM'.
      multi_or_tc-top_line = 1.
    WHEN 'PM'.
      multi_or_tc-top_line = multi_or_tc-top_line - looplines.
      IF multi_or_tc-top_line < 1.
        multi_or_tc-top_line = 1.
      ENDIF.
    WHEN 'PP'.
      multi_or_tc-top_line = multi_or_tc-top_line + looplines.
      IF multi_or_tc-top_line > linecount.
        multi_or_tc-top_line = linecount - looplines + 1.
        IF multi_or_tc-top_line < 1.
          multi_or_tc-top_line = 1.
        ENDIF.
      ENDIF.
    WHEN 'PPP'.
      multi_or_tc-top_line = linecount - looplines + 1.
      IF multi_or_tc-top_line < 1.
        multi_or_tc-top_line = 1.
      ENDIF.
*..................................................
  endcase.

ENDMODULE.                 " USER_COMMAND_0111  INPUT
*&---------------------------------------------------------------------*
*&      Module  back_0001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE back_0001 INPUT.

  save_fcode = fcode.
  clear fcode.
  case save_fcode.
    when '&F12'.
      set screen 0.
      leave screen.
  endcase.

ENDMODULE.                 " back_0001  INPUT
*&---------------------------------------------------------------------*
*&      Module  check_input  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input INPUT.

   perform check_input.

ENDMODULE.                 " check_input  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DBCON  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DBCON INPUT.

*.check DB-Connection Input
data: test_con_ref type ref to cl_sql_connection.
data: sqlerr_ref   type ref to cx_sql_exception.
constants: c_dbcon_check like tfdir-funcname value 'HDB_DBCON_CHECK'.

  check gd-dbcon <> space.

  CALL FUNCTION 'RH_FUNCTION_EXIST'
    EXPORTING
      NAME                     = c_dbcon_check
    EXCEPTIONS
      FUNCTION_NOT_FOUND       = 1
      OTHERS                   = 2.

  IF SY-SUBRC = 0.
    CALL FUNCTION c_dbcon_check
      CHANGING
        C_DBCON_NAME          = gd-dbcon
      EXCEPTIONS
        DBCON_NOT_EXIST       = 1
        DBCON_ERROR           = 2
        OTHERS                = 3.
    IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
        WITH gd-dbcon SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  else.
    try.
      test_con_ref =
      cl_sql_connection=>get_connection( con_name = gd-dbcon ).
      test_con_ref->close( ).
      test_con_ref =
      cl_sql_connection=>get_connection( con_name = gd-dbcon ).
      test_con_ref->close( ).
      catch cx_sql_exception into sqlerr_ref.
      message i555(kz)   with sqlerr_ref->SQL_MESSAGE.
      message e135(wusl) with gd-dbcon.
    endtry.
  endif.


ENDMODULE.                 " GET_DBCON  INPUT
*&---------------------------------------------------------------------*
*&      Module  OJKEY_F4  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE OJKEY_F4 INPUT.

  perform ojkey_f4.

ENDMODULE.                 " OJKEY_F4  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SETID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECK_SETID INPUT.

  perform check_setid.

ENDMODULE.                 " CHECK_SETID  INPUT
*&---------------------------------------------------------------------*
*&      Module  FIELD_F4_SETID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FIELD_F4_SETID INPUT.

  perform f4_setid.

ENDMODULE.                 " FIELD_F4_SETID  INPUT
