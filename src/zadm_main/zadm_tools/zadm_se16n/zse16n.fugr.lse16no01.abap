*----------------------------------------------------------------------*
***INCLUDE LGTDISO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  refresh functab.
  if gd-tech_view <> true.
     perform exclude_function using 'MULTI_OR'.
     perform exclude_function using 'TSCUST'.
     perform exclude_function using 'TSRUN'.
     perform exclude_function using 'RKCOWUSL'.
     perform exclude_function using 'RKCOVIEW'.
     perform exclude_function using 'EXT_READ'.
     perform exclude_function using 'EXT_WRITE'.
  endif.
  if gd-display = true.
     perform exclude_function using 'VIEW'.
  endif.
  if gd-view <> true.
     perform exclude_function using 'VIEW'.
  endif.
  if gd-hana_active = true.
     perform exclude_function using 'MULTI_OR'.
  else.
     perform exclude_function using 'DOCU'.
  endif.
  SET PF-STATUS '0100' excluding functab.
  IF gd-emergency = true.
     SET TITLEBAR '102'.
  ELSE.
     SET TITLEBAR '100'.
  ENDIF.

*.set the icon for access to multi or input
  clear multi_or_icon.
  if not gt_multi_or_all[] is initial.
     multi_or_icon-icon_id = icon_display_more.
  else.
     multi_or_icon-icon_id = icon_enter_more.
  endif.
  multi_or_icon-quickinfo = text-tor.
  multi_or_icon-icon_text = text-to2.
  multi_or_icon-text      = text-to3.
*     multi_or_icon-icon_id   = icon_information.
*     multi_or_icon-icon_text = text-don.
*     multi_or_icon-quickinfo = text-don.
*     multi_or_icon-path      = space.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_TC_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FILL_TC_0100 OUTPUT.

  perform fill_tc_0100.

ENDMODULE.                             " FILL_TC_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LINECOUNT_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LINECOUNT_0100 OUTPUT.

data: ld_fieldname like dfies-lfieldname.

  DESCRIBE TABLE GT_SELFIELDS LINES LINECOUNT.
  SELFIELDS_TC-LINES = LINECOUNT.

*.only if tax audit, display text
  CALL FUNCTION 'CA_USER_EXISTS'
      EXPORTING
        i_user       = sy-uname
      EXCEPTIONS
        user_missing = 1.
  if sy-subrc <> 0.
     loop at screen.
        if screen-name = 'TXT_TAX_AUDIT'.
           screen-invisible = 1.
           modify screen.
        endif.
     endloop.
  else.
     loop at screen.
        if screen-name = 'EXT_F4'.
           screen-invisible = 1.
           modify screen.
        endif.
     endloop.
  endif.

*.if no text table -> no display of text table line
  if gd-txt_tab is initial.
     loop at screen.
        if screen-group4 = 'TTA'.
*          screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.in emergency mode restrict to necessary fields
  if gd-emergency = true.
     loop at screen.
        if screen-group3 = 'FOR'.
           screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.if no entity -> no display of field
  if gd-entity is initial.
     loop at screen.
        if screen-group4 = 'ENT'.
           screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
  endif.
*.if no ddlname -> no display of field
  if gd-ddlname is initial.
     loop at screen.
        if screen-group4 = 'DDL'.
           screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.if not client dependent, do not bother user with client choose
  if gd-clnt <> true or
     gd-no_clnt_anymore = true or
     gd-no_clnt_auth = true.
     loop at screen.
        if screen-group4 = 'CLT'.
           screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.hide fast data access
  if gd-fda_on <> true.
     loop at screen.
        if screen-group4 = 'FDA'.
           screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.if hana-mode, show new DB-Connection, otherwise not
  if gd-hana_active <> true.
    loop at screen.
       if screen-group3 = 'DBC'.
          screen-invisible = 1.
          screen-input     = 0.
          modify screen.
       endif.
    endloop.
  else.
*...only allow input via F4
    loop at screen.
       if screen-name = 'GD-OJKEY'.
          screen-input = 0.
*         modify screen.
       endif.
    endloop.
  endif.

*.if table is editable, allow to switch it off
  if gd-tabedit <> true.
     loop at screen.
        if screen-group4 = 'EDT'.
*          screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.deactivate jump to SE16T if not wanted
  if gd-se16t_off = true.
     loop at screen.
        if screen-group3 = '16T'.
           screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.if special call via SE16N_START with only one table
*.do not allow to change the name of the table
  if gd-single_tab = true.
     loop at screen.
        if screen-name = 'GD-TAB'.
           screen-input  = 0.
*          screen-active = 0.
           modify screen.
        endif.
        if screen-name = 'EXT_F4'.
           screen-invisible = 1.
           screen-active    = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.change the order of the columns if wanted
  if gd-tech_first = true.
*...First of all get the current position of the columns, because they
*...could have been changed by the user.
    clear: tec_index, fld_index.
    LOOP AT SELFIELDS_TC-COLS INTO WA.
      IF WA-SCREEN-GROUP4 = 'TEC'.
         tec_index = wa-index.
      ENDIF.
      IF WA-SCREEN-GROUP4 = 'FLD'.
         fld_index = wa-index.
      ENDIF.
    endloop.
*...Now change the position of the columns
    LOOP AT SELFIELDS_TC-COLS INTO WA.
      IF WA-SCREEN-GROUP4 = 'TEC'.
         if tec_index < fld_index.
            WA-index = tec_index.
         else.
            wa-index = fld_index.
         endif.
         modify selfields_tc-cols from wa.
      ENDIF.
      IF WA-SCREEN-GROUP4 = 'FLD'.
         if fld_index > tec_index.
            WA-index = fld_index.
         else.
            wa-index = tec_index.
         endif.
         modify selfields_tc-cols from wa.
      ENDIF.
    endloop.
  else.
*...First of all get the current position of the columns, because they
*...could have been changed by the user.
    clear: tec_index, fld_index.
    LOOP AT SELFIELDS_TC-COLS INTO WA.
      IF WA-SCREEN-GROUP4 = 'TEC'.
         tec_index = wa-index.
      ENDIF.
      IF WA-SCREEN-GROUP4 = 'FLD'.
         fld_index = wa-index.
      ENDIF.
    endloop.
    LOOP AT SELFIELDS_TC-COLS INTO WA.
      IF WA-SCREEN-GROUP4 = 'TEC'.
         if fld_index > tec_index.
            WA-index = fld_index.
         else.
            wa-index = tec_index.
         endif.
         modify selfields_tc-cols from wa.
      ENDIF.
      IF WA-SCREEN-GROUP4 = 'FLD'.
         if tec_index < fld_index.
            WA-index = tec_index.
         else.
            wa-index = fld_index.
         endif.
         modify selfields_tc-cols from wa.
      ENDIF.
    endloop.
  endif.

*.try to condense the fields to make more columns visible
  if gd-colopt = true.
    LOOP AT SELFIELDS_TC-COLS INTO WA.
      case wa-screen-name.
        when 'GS_SELFIELDS-LOW'.
          wa-vislength = 15.
        when 'GS_SELFIELDS-HIGH'.
          wa-vislength = 15.
        when 'GS_SELFIELDS-SETID'.
          wa-vislength = 10.
        when 'GS_SELFIELDS-MARK'.
          wa-vislength = 3.
        when 'GS_SELFIELDS-SUM_UP'.
          wa-vislength = 3.
        when 'GS_SELFIELDS-GROUP_BY'.
          wa-vislength = 3.
        when 'GS_SELFIELDS-ORDER_BY'.
          wa-vislength = 3.
        when 'GS_SELFIELDS-TOPLOW'.
          wa-vislength = 5.
        when 'GS_SELFIELDS-SORTORDER'.
          wa-vislength = 3.
        when 'GS_SELFIELDS-AGGREGATE'.
          wa-vislength = 5.
        when 'GS_SELFIELDS-FIELDNAME'.
          wa-vislength = 12.
        when 'GS_SELFIELDS-CURR_ADD_UP'.
          wa-vislength = 3.
        when 'GS_SELFIELDS-QUAN_ADD_UP'.
          wa-vislength = 3.
        when 'GS_SELFIELDS-HAVING_VALUE'.
          wa-vislength = 15.
      endcase.
      modify selfields_tc-cols from wa.
    endloop.
  else.
    LOOP AT SELFIELDS_TC-COLS INTO WA.
      case wa-screen-name.
        when 'GS_SELFIELDS-LOW'.
          wa-vislength = 25.
        when 'GS_SELFIELDS-HIGH'.
          wa-vislength = 25.
        when 'GS_SELFIELDS-SETID'.
          wa-vislength = 15.
        when 'GS_SELFIELDS-MARK'.
          wa-vislength = 8.
        when 'GS_SELFIELDS-SUM_UP'.
          wa-vislength = 10.
        when 'GS_SELFIELDS-GROUP_BY'.
          wa-vislength = 12.
        when 'GS_SELFIELDS-ORDER_BY'.
          wa-vislength = 10.
        when 'GS_SELFIELDS-TOPLOW'.
          wa-vislength = 10.
        when 'GS_SELFIELDS-SORTORDER'.
          wa-vislength = 10.
        when 'GS_SELFIELDS-AGGREGATE'.
          wa-vislength = 12.
        when 'GS_SELFIELDS-FIELDNAME'.
          wa-vislength = 20.
        when 'GS_SELFIELDS-CURR_ADD_UP'.
          wa-vislength = 15.
        when 'GS_SELFIELDS-QUAN_ADD_UP'.
          wa-vislength = 15.
        when 'GS_SELFIELDS-HAVING_VALUE'.
          wa-vislength = 20.
      endcase.
      modify selfields_tc-cols from wa.
    endloop.
  endif.

*.if users wants the technical view, display more fields
  if gd-tech_view <> true.
     LOOP AT SELFIELDS_TC-COLS INTO WA.
        IF WA-SCREEN-GROUP3 = 'TEC'.
           WA-INVISIBLE = 1.
           modify selfields_tc-cols from wa.
        ENDIF.
     endloop.
  else.
     LOOP AT SELFIELDS_TC-COLS INTO WA.
        IF WA-SCREEN-GROUP3 = 'TEC'.
           WA-INVISIBLE = 0.
           modify selfields_tc-cols from wa.
        ENDIF.
     endloop.
  endif.

*.if table has no CURR and QUAN-fields, do not show the totalling
  read table gt_selfields into lls_selfields
        with key datatype = 'CURR'.
  if sy-subrc <> 0.
     LOOP AT SELFIELDS_TC-COLS INTO WA.
        IF WA-SCREEN-GROUP4 = 'TCU'.
           WA-INVISIBLE = 1.
           modify selfields_tc-cols from wa.
        ENDIF.
     endloop.
  endif.
  read table gt_selfields into lls_selfields
        with key datatype = 'QUAN'.
  if sy-subrc <> 0.
     LOOP AT SELFIELDS_TC-COLS INTO WA.
        IF WA-SCREEN-GROUP4 = 'TQU'.
           WA-INVISIBLE = 1.
           modify selfields_tc-cols from wa.
        ENDIF.
     endloop.
  endif.

*.in case of no Hana-mode, do not show the columns at all
  if gd-hana_active <> true.
    LOOP AT SELFIELDS_TC-COLS INTO WA.
       IF WA-SCREEN-GROUP4 = 'HSU' or
          wa-screen-group4 = 'HGP' or
          wa-screen-group4 = 'HOR' or
          wa-screen-group4 = 'HAG' or
          wa-screen-group4 = 'HSE' or
          wa-screen-group4 = 'HAV'.
          WA-INVISIBLE = 1.
          modify selfields_tc-cols from wa.
       ENDIF.
    endloop.
  endif.

*..do not allow aggregation or summation for pool-tables
*..check if table is a pool-table. DD02L is filled upfront
   if dd02l-tabname = gd-tab and
      ( dd02l-tabclass = 'POOL' or
        dd02l-tabclass = 'CLUSTER' ).
      LOOP AT SELFIELDS_TC-COLS INTO WA.
         IF WA-SCREEN-GROUP4 = 'HAG' or
            WA-SCREEN-GROUP4 = 'HSU' or
            WA-SCREEN-GROUP4 = 'HGP' or
            WA-SCREEN-GROUP4 = 'HOR' or
            WA-SCREEN-GROUP4 = 'HAV'.
            WA-INVISIBLE = 1.
            modify selfields_tc-cols from wa.
         ENDIF.
      endloop.
   else.
     if gd-hana_active = true.
       LOOP AT SELFIELDS_TC-COLS INTO WA.
         IF WA-SCREEN-GROUP4 = 'HAG' or
            WA-SCREEN-GROUP4 = 'HSU' or
            WA-SCREEN-GROUP4 = 'HGP' or
            WA-SCREEN-GROUP4 = 'HOR' or
            WA-SCREEN-GROUP4 = 'HAV'.
            WA-INVISIBLE = 0.
            modify selfields_tc-cols from wa.
         ENDIF.
       endloop.
     endif.
   endif.

*.take care of exit-fields
  if gd-add_fields <> true.
    loop at screen.
       if screen-group2 = 'EXI'.
          screen-invisible = 1.
          screen-input     = 0.
          modify screen.
       endif.
    endloop.
  endif.
*.change length of input field according data element
  if gd-add_field_reftab <> space and
     gd-add_field_reffld <> space.
     ld_fieldname = gd-add_field_reffld.
     CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
         TABNAME              = gd-add_field_reftab
         LFIELDNAME           = ld_fieldname
       IMPORTING
         DFIES_WA             = gs_dfies
       EXCEPTIONS
         OTHERS               = 3.
     IF SY-SUBRC = 0.
       loop at screen.
         if screen-name = 'GD-ADD_FIELD'.
            screen-length = gs_dfies-leng.
            modify screen.
         endif.
       endloop.
     endif.
  else.
     loop at screen.
       if screen-name = 'GD-ADD_FIELD' or
          screen-name = 'GD-ADD_FIELD_TEXT'.
          screen-invisible = 1.
          screen-input     = 0.
          modify screen.
       endif.
     endloop.
  endif.

*.do not show formulas for non-technical view
  IF gd-tech_view <> true.
    LOOP AT SCREEN.
      IF screen-group3 = 'FOR'.
        screen-invisible = 1.
        screen-input     = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*.CRIT_NEXT or CRIT_PREV has been used, set cursor
  if gd_cursor_line = 1.
     SET CURSOR FIELD 'GS_SELFIELDS-LOW' LINE 1.
     gd_cursor_line = 0.
  endif.

ENDMODULE.                             " GET_LINECOUNT_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SHOW_LINES_SEL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_LINES_SEL OUTPUT.

  MOVE-CORRESPONDING GT_SELFIELDS TO GS_SELFIELDS.

  IF GS_SELFIELDS-LOW <> SPACE and
     GS_SELFIELDS-NO_INPUT_CONVERSION = space.
*...in case of currency reference, try to get it
    if gt_selfields-reffield <> space and
       gt_selfields-reftable = gt_selfields-tabname.
      read table gt_selfields into gs_curr_dummy
             with key tabname   = gt_selfields-reftable
                      fieldname = gt_selfields-reffield.
      if sy-subrc = 0.
         gd_currency_pbo = gs_curr_dummy-low.
      endif.
    endif.
    perform convert_to_extern using    gd_currency_pbo
                              changing gt_selfields
                                       gs_selfields-low.
  ENDIF.
  IF GS_SELFIELDS-HIGH <> SPACE and
     GS_SELFIELDS-NO_INPUT_CONVERSION = space.
*...in case of currency reference, try to get it
    if gt_selfields-reffield <> space and
       gt_selfields-reftable = gt_selfields-tabname.
      read table gt_selfields into gs_curr_dummy
             with key tabname   = gt_selfields-reftable
                      fieldname = gt_selfields-reffield.
      if sy-subrc = 0.
         gd_currency_pbo = gs_curr_dummy-low.
      endif.
    endif.
    perform convert_to_extern using    gd_currency_pbo
                              changing gt_selfields
                                       gs_selfields-high.
  ENDIF.

*.convert having value
  IF GS_SELFIELDS-HAVING_VALUE <> SPACE and
     GS_SELFIELDS-NO_INPUT_CONVERSION = space.
*...in case of currency reference, try to get it
    if gt_selfields-reffield <> space and
       gt_selfields-reftable = gt_selfields-tabname.
      read table gt_selfields into gs_curr_dummy
             with key tabname   = gt_selfields-reftable
                      fieldname = gt_selfields-reffield.
      if sy-subrc = 0.
         gd_currency_pbo = gs_curr_dummy-low.
      endif.
    endif.
    perform convert_to_extern using    gd_currency_pbo
                              changing gt_selfields
                                       gs_selfields-having_value.
  ENDIF.
  clear gd_currency_pbo.

*..convert setid into shortname
  CALL FUNCTION 'G_SET_DECRYPT_SETID'
    EXPORTING
      SETID            = gs_selfields-setid
    IMPORTING
      SHORTNAME        = gs_selfields-setid.

ENDMODULE.                             " SHOW_LINES_SEL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHANGE_SCREEN_SEL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SCREEN_SEL OUTPUT.

*.change the icon of the pushbutton
  if gt_selfields-push = true.
     perform icon_create using    'ICON_DISPLAY_MORE'
                         changing push
                                  gd_dummy_text.
  else.
     perform icon_create using    'ICON_ENTER_MORE'
                         changing push
                                  gd_dummy_text.
  endif.

*.set icon for select option
  if not gt_selfields-option is initial.
     perform get_icon_name using    gt_selfields-sign
                                    gt_selfields-option
                           changing gd_icon_name.
     perform icon_create using    gd_icon_name
                         changing option
                                  gd_dummy_text.
  else.
     perform icon_create using    'ICON_SELECTION'
                         changing option
                                  gd_dummy_text.
  endif.

*.set icon for select option for having
  if not gt_selfields-having_option is initial.
     perform get_icon_name using    'I'
                                    gt_selfields-having_option
                           changing gd_icon_name.
     perform icon_create using    gd_icon_name
                         changing having_option
                                  gd_dummy_text.
  else.
     perform icon_create using    'ICON_SELECTION'
                         changing having_option
                                  gd_dummy_text.
  endif.

*.if not explicitely wished, the client is not inputable
  if gt_selfields-client = true and gd-read_clnt <> true.
     loop at screen.
        if screen-group1 = 'INP' or
           screen-group3 = 'ICN' or
           screen-name   = 'GS_SELFIELDS-MARK' or
           screen-name   = 'GS_SELFIELDS-NO_INPUT_CONVERSION' or
           screen-name   = 'OPTION'.
           screen-active = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.depending on the select option, not all fields are inputable
  read table gt_sel_init with key option = gt_selfields-option.
  if sy-subrc = 0.
     if gt_sel_init-high <> true.
        loop at screen.
           if screen-name = 'GS_SELFIELDS-HIGH'.
              screen-active = 0.
              modify screen.
           endif.
        endloop.
     endif.
     if gt_sel_init-low <> true.
        loop at screen.
           if screen-name = 'GS_SELFIELDS-LOW'.
              screen-active = 0.
              modify screen.
           endif.
        endloop.
     endif.
  endif.

  if gt_selfields-key = true.
    LOOP AT SCREEN.
      IF SCREEN-GROUP2 = 'TXT'.
        SCREEN-intensified = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  endif.

*.check for LCHR and do not allow input
  if gt_selfields-datatype = 'LCHR'.
     LOOP AT SCREEN.
       IF SCREEN-GROUP1 = 'INP'.
         SCREEN-input = 0.
       ENDIF.
       IF screen-group3 = 'OPT' or
          screen-group3 = 'ICN'.
         screen-input = 0.
         SCREEN-invisible = 1.
       endif.
       MODIFY SCREEN.
     ENDLOOP.
  endif.

*.In case of fields of text table, no input
  LOOP AT SCREEN.
    IF SCREEN-NAME = 'GS_SELFIELDS-LOW' or
       SCREEN-NAME = 'GS_SELFIELDS-HIGH'.
      SCREEN-LENGTH = GT_SELFIELDS-OUTPUTLEN.
      if gt_selfields-input = '0'.
         screen-input = 0.
      endif.
    endif.
    if screen-group3 = 'ICN'.
      if gt_selfields-input = '0'.
         screen-input = 0.
         SCREEN-invisible = 1.
      endif.
    endif.
    if screen-group3 = 'OPT'.
      if gt_selfields-input = '0'.
         screen-input = 0.
         SCREEN-invisible = 1.
      endif.
    endif.
*...do not allow input in any text table fields
    if screen-group1 = 'INP'.
      if gt_selfields-input = '0'.
         screen-input = 0.
      endif.
    endif.
    MODIFY SCREEN.
  ENDLOOP.
*.It is not possible to make it really visible how long a line is!!!
*data: wa type cxtab_column.
*  LOOP AT selfields_tc-COLS INTO WA.
*    IF WA-SCREEN-GROUP1 = 'INP'.
*      WA-vislength = GT_SELFIELDS-OUTPUTLEN.
*      WA-screen-length = GT_SELFIELDS-OUTPUTLEN.
*      modify selfields_tc-cols from wa.
*    endif.
*  endloop.

*.If no text, do not display text lines
  if gd-no_txt = true and gt_selfields-input = '0'.
     LOOP AT SCREEN.
        SCREEN-invisible = 1.
        modify screen.
     endloop.
  endif.

  loop at screen.
    if screen-name = 'GS_SELFIELDS-CURR_ADD_UP'.
        if gt_selfields-datatype = 'CURR'.
           screen-input = 1.
           screen-active = 1.
        else.
           screen-input = 0.
           screen-active = 0.
        endif.
        modify screen.
    endif.
    if screen-name = 'GS_SELFIELDS-QUAN_ADD_UP'.
        if gt_selfields-datatype = 'QUAN'.
           screen-input = 1.
           screen-active = 1.
        else.
           screen-input = 0.
           screen-active = 0.
        endif.
        modify screen.
    endif.
*...HANA, only show totalling for value fields
    if screen-name = 'GS_SELFIELDS-SUM_UP' or
       screen-name = 'GS_SELFIELDS-HAVING_VALUE' or
       screen-name = 'HAVING_OPTION'.
        if gt_selfields-datatype = 'QUAN' or
           gt_selfields-datatype = 'CURR' or
           gt_selfields-datatype = 'INT1' or
           gt_selfields-datatype = 'INT2' or
           gt_selfields-datatype = 'INT4'.
           screen-input = 1.
           screen-active = 1.
        else.
           screen-input = 0.
           screen-active = 0.
        endif.
        modify screen.
    endif.
*...HANA, do not show group by for total fields
    if screen-name = 'GS_SELFIELDS-GROUP_BY'.
        if ( gt_selfields-datatype <> 'QUAN' and
             gt_selfields-datatype <> 'CURR' ).
           screen-input = 1.
           screen-active = 1.
        else.
           screen-input = 0.
           screen-active = 0.
        endif.
*        modify screen.
    endif.
  endloop.

*.no conversion could lead to dumps for date, curr,...
  loop at screen.
    if screen-name = 'GS_SELFIELDS-NO_INPUT_CONVERSION'.
        if gt_selfields-datatype = 'CHAR' or
           gt_selfields-datatype = 'NUMC'.
           screen-input = 1.
           screen-active = 1.
        else.
           screen-input = 0.
           screen-active = 0.
        endif.
        modify screen.
    endif.
  endloop.

*.If table is a view, do not allow any input
  if gd-view = true and
     gd-ddic_view <> true.
     loop at screen.
        if screen-group1 = 'INP' or    "From-To-Value
           screen-group3 = 'ICN' or    "More-Icon
           screen-group3 = 'OPT' or    "Option-Icon
           screen-group3 = 'OUT'.      "Output-field
           screen-input = 0.
           modify screen.
        endif.
     endloop.
  endif.

  IF SELFIELDS_TC-CURRENT_LINE > LINECOUNT.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                             " CHANGE_SCREEN_SEL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOOPLINES_SEL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LOOPLINES_SEL OUTPUT.

  looplines = sy-loopc.

ENDMODULE.                             " GET_LOOPLINES_SEL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0001 OUTPUT.

  refresh distab.
  if gd_mf_display   = true or
     gd_role_display = true.
     perform exclude_display.
  endif.

  if gd_datatype = 'DATS' or
     gd_datatype = 'TIMS'.
     if gd_mf_display   = true or
        gd_role_display = true.
        set pf-status '0001' excluding distab.
     else.
        set pf-status '0001' excluding 'MULTI_F4'.
     endif.
  else.
     SET PF-STATUS '0001' excluding distab.
  endif.
   SET TITLEBAR '001'.

ENDMODULE.                 " STATUS_0001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LINECOUNT_0001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LINECOUNT_0001 OUTPUT.

  DESCRIBE TABLE GT_MULTI_SELECT LINES LINECOUNT1.
  MULTI_TC-LINES = LINECOUNT1.
  gd_lines_used = 0.
  loop at gt_multi_select where low    <> space
                             or high   <> space
                             or option <> space.
     add 1 to gd_lines_used.
  endloop.


ENDMODULE.                 " GET_LINECOUNT_0001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SHOW_LINES_MULTI  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_LINES_MULTI OUTPUT.

  MOVE-CORRESPONDING GT_multi_select TO GS_multi_select.

  IF GS_multi_select-LOW <> SPACE and
     GS_multi_select-LOW <> c_SPACE.
    perform convert_to_extern using    gd_currency
                              changing gt_multi_select
                                       gs_multi_select-low.
  ENDIF.
  IF GS_multi_select-HIGH <> SPACE and
     GS_multi_select-HIGH <> c_SPACE.
    perform convert_to_extern using    gd_currency
                              changing gt_multi_select
                                       gs_multi_select-high.
  ENDIF.

ENDMODULE.                 " SHOW_LINES_MULTI  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHANGE_SCREEN_MULTI  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SCREEN_MULTI OUTPUT.

  IF multi_TC-CURRENT_LINE > LINECOUNT1.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*.depending on the select option, not all fields are inputable
  read table gt_sel_init with key option = gt_multi_select-option.
  if sy-subrc = 0.
     if gt_sel_init-high <> true.
        loop at screen.
           if screen-name = 'GS_MULTI_SELECT-HIGH'.
              screen-active = 0.
              modify screen.
           endif.
        endloop.
     endif.
     if gt_sel_init-low <> true.
        loop at screen.
           if screen-name = 'GS_MULTI_SELECT-LOW'.
              screen-active = 0.
              modify screen.
           endif.
        endloop.
     endif.
  endif.

  if gt_multi_select-key = true.
    LOOP AT SCREEN.
      IF SCREEN-GROUP2 = 'TXT'.
        SCREEN-intensified = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  endif.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'INP'.
      SCREEN-LENGTH = GT_multi_select-OUTPUTLEN.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*.set icon for select option
  if not gs_multi_select-option is initial.
     perform get_icon_name using    gs_multi_select-sign
                                    gs_multi_select-option
                           changing gd_icon_name.
     perform icon_create using    gd_icon_name
                         changing option
                                  gd_dummy_text.
  else.
     perform icon_create using    'ICON_SELECTION'
                         changing option
                                  gd_dummy_text.
  endif.
*.depending on the select option, not all fields are inputable
  read table gt_sel_init with key option = gs_multi_select-option.
  if sy-subrc = 0.
     if gt_sel_init-high <> true.
        loop at screen.
           if screen-name = 'GS_MULTI_SELECT-HIGH'.
              screen-active = 0.
              modify screen.
           endif.
        endloop.
     endif.
     if gt_sel_init-low <> true.
        loop at screen.
           if screen-name = 'GS_MULTI_SELECT-LOW'.
              screen-active = 0.
              modify screen.
           endif.
        endloop.
     endif.
  endif.

*.in case this function is called by role maintenance take care
*.of display mode
  if gd_role_display = true or
     gd_mf_display   = true.
     loop at screen.
        screen-input = 0.
        modify screen.
     endloop.
  endif.
*  if gd_role <> space.
*     loop at screen.
*        if screen-name = 'OPTION'.
*           screen-input = 0.
*           modify screen.
*        endif.
*     endloop.
*  endif.

ENDMODULE.                 " CHANGE_SCREEN_MULTI  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  GET_LOOPLINES_MULTI  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_LOOPLINES_MULTI OUTPUT.

  looplines1 = sy-loopc.

ENDMODULE.                 " GET_LOOPLINES_MULTI  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0111 OUTPUT.

   refresh excltab.
   if gd-ut_sel_screen_call = true.
      excltab-fcode = 'PREV'.
      append excltab.
      excltab-fcode = 'NEXT'.
      append excltab.
   endif.
   SET PF-STATUS '0111' excluding excltab.
   if gd-ut_sel_screen_call = true.
      set titlebar '220' with gd-ext_gui_title.
      loop at screen.
         if screen-name = 'GD_MULTI_OR_POS' or
            screen-name = 'TXT1'.
           screen-invisible = 1.
           screen-input     = 0.
           modify screen.
        endif.
     endloop.
   else.
      SET TITLEBAR '111'.
   endif.

ENDMODULE.                 " STATUS_0111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  get_linecount_0111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_linecount_0111 OUTPUT.

  DESCRIBE TABLE GT_multi_or LINES LINECOUNT.
  multi_or_TC-LINES = LINECOUNT.

*.CRIT_NEXT or CRIT_PREV has been used, set cursor
  if gd_cursor_line = 1.
     SET CURSOR FIELD 'GS_MULTI_OR-LOW' LINE 1.
     gd_cursor_line = 0.
  endif.

ENDMODULE.                 " get_linecount_0111  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SHOW_LINES_or  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SHOW_LINES_or OUTPUT.

  MOVE-CORRESPONDING gt_multi_or TO GS_multi_or.

  IF GS_multi_or-LOW <> SPACE.
*...in case of currency reference, try to get it
    if gt_multi_or-reffield <> space and
       gt_multi_or-reftable = gt_multi_or-tabname.
       read table gt_multi_or into gs_curr_dummy
             with key tabname   = gt_multi_or-reftable
                      fieldname = gt_multi_or-reffield.
       if sy-subrc = 0.
          gd_currency_pbo = gs_curr_dummy-low.
       endif.
    endif.
    perform convert_to_extern using    gd_currency_pbo
                              changing gt_multi_or
                                       gs_multi_or-low.
  ENDIF.
  IF GS_multi_or-HIGH <> SPACE.
*...in case of currency reference, try to get it
    if gt_multi_or-reffield <> space and
       gt_multi_or-reftable = gt_multi_or-tabname.
       read table gt_multi_or into gs_curr_dummy
             with key tabname   = gt_multi_or-reftable
                      fieldname = gt_multi_or-reffield.
       if sy-subrc = 0.
          gd_currency_pbo = gs_curr_dummy-low.
       endif.
    endif.
    perform convert_to_extern using    gd_currency_pbo
                              changing gt_multi_or
                                       gs_multi_or-high.
  ENDIF.
  clear gd_currency_pbo.

ENDMODULE.                 " SHOW_LINES_or  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SCREEN_or  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHANGE_SCREEN_or OUTPUT.

*.change the icon of the pushbutton
  if gs_multi_or-push = true.
     perform icon_create using    'ICON_DISPLAY_MORE'
                         changing push
                                  gd_dummy_text.
  else.
     perform icon_create using    'ICON_ENTER_MORE'
                         changing push
                                  gd_dummy_text.
  endif.

*.set icon for select option
  if not gs_multi_or-option is initial.
     perform get_icon_name using    gs_multi_or-sign
                                    gs_multi_or-option
                           changing gd_icon_name.
     perform icon_create using    gd_icon_name
                         changing option
                                  gd_dummy_text.
  else.
     perform icon_create using    'ICON_SELECTION'
                         changing option
                                  gd_dummy_text.
  endif.

*.if not explicitely wished, the client is not inputable
  if gs_multi_or-client = true and gd-read_clnt <> true.
     loop at screen.
        if screen-group1 = 'INP' or
           screen-group3 = 'ICN' or
           screen-name   = 'GS_MULTI_OR-MARK' or
           screen-name   = 'OPTION'.
           screen-active = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.depending on the select option, not all fields are inputable
  read table gt_sel_init with key option = gs_multi_or-option.
  if sy-subrc = 0.
     if gt_sel_init-high <> true.
        loop at screen.
           if screen-name = 'GS_MULTI_OR-HIGH'.
              screen-active = 0.
              modify screen.
           endif.
        endloop.
     endif.
     if gt_sel_init-low <> true.
        loop at screen.
           if screen-name = 'GS_MULTI_OR-LOW'.
              screen-active = 0.
              modify screen.
           endif.
        endloop.
     endif.
  endif.

  if gs_multi_or-key = true.
    LOOP AT SCREEN.
      IF SCREEN-GROUP2 = 'TXT'.
        SCREEN-intensified = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  endif.

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'INP'.
      SCREEN-LENGTH = gs_multi_or-OUTPUTLEN.
      if gs_multi_or-input = '0'.
         screen-input = 0.
      endif.
    endif.
    if screen-group3 = 'ICN' or
       screen-group3 = 'OPT'.
      if gs_multi_or-input = '0'.
         screen-input = 0.
         SCREEN-invisible = 1.
      endif.
    endif.
    MODIFY SCREEN.
  ENDLOOP.

*.check for LCHR and do not allow input
  if gt_multi_or-datatype = 'LCHR'.
     LOOP AT SCREEN.
       IF SCREEN-GROUP1 = 'INP'.
         SCREEN-input = 0.
       ENDIF.
       IF screen-group3 = 'OPT' or
          screen-group3 = 'ICN'.
         screen-input = 0.
         SCREEN-invisible = 1.
       endif.
       MODIFY SCREEN.
     ENDLOOP.
  endif.

*.If no text, do not display text lines
  if gd-no_txt = true and gs_multi_or-input = '0'.
     LOOP AT SCREEN.
        SCREEN-invisible = 1.
        modify screen.
     endloop.
  endif.

*.if users wants the technical view, display more fields
  if gd-tech_view <> true.
     LOOP AT multi_or_TC-COLS INTO WA.
        IF WA-SCREEN-GROUP3 = 'TEC'.
           WA-INVISIBLE = 1.
           modify multi_or_tc-cols from wa.
        ENDIF.
     endloop.
  else.
     LOOP AT multi_or_TC-COLS INTO WA.
        IF WA-SCREEN-GROUP3 = 'TEC'.
           WA-INVISIBLE = 0.
           modify multi_or_tc-cols from wa.
        ENDIF.
     endloop.
  endif.

*.If table is a view, do not allow any input
  if gd-view = true and
     gd-ddic_view <> true.
     loop at screen.
        if screen-group1 = 'INP' or    "From-To-Value
           screen-group3 = 'ICN' or    "More-Icon
           screen-group3 = 'OPT' or    "Option-Icon
           screen-group3 = 'OUT'.      "Output-field
           screen-input = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.If table is a view, do not allow any input
  if gd_111_display = true.
     loop at screen.
        if screen-group1 = 'INP' or    "From-To-Value
           screen-group3 = 'ICN' or    "More-Icon
           screen-group3 = 'OPT' or    "Option-Icon
           screen-group3 = 'OUT'.      "Output-field
           screen-input = 0.
           modify screen.
        endif.
     endloop.
  endif.

*.external call, do not show display-column
  if gd-ut_sel_screen_call = true.
    LOOP AT MULTI_OR_TC-COLS INTO WA.
       IF WA-SCREEN-NAME = 'GS_MULTI_OR-MARK'.
          WA-INVISIBLE = 1.
          modify multi_or_tc-cols from wa.
       ENDIF.
    endloop.
  endif.

  IF multi_or_TC-CURRENT_LINE > LINECOUNT.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.


ENDMODULE.                 " CHANGE_SCREEN_or  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TAKE_DATA_OR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TAKE_DATA_OR INPUT.

  perform take_data_or.

ENDMODULE.                 " TAKE_DATA_OR  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_CURSOR_0001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_CURSOR_0001 OUTPUT.

  set cursor field 'GS_MULTI_SELECT-LOW' line 1.

ENDMODULE.                 " SET_CURSOR_0001  OUTPUT
