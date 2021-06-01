*----------------------------------------------------------------------*
***INCLUDE LGTDISF30 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_DATA_CHANGED  text
*----------------------------------------------------------------------*
FORM data_changed USING lt_changed_data type ref to
                                         cl_alv_changed_data_protocol.

data: ls_mod_cells type lvc_s_modi.
data: ls_ins_rows  type lvc_s_moce.
data: dref         type ref to data.
data: waref        type ref to data.
data: ld_lines     like sy-tabix.
data: ld_tabix     like sy-tabix.
data: ld_my_indx   like sy-tabix.
data: ld_old_id    like LVC_S_MODI-row_id.
data: ls_callback_events type se16n_events_type.
data: begin of ls_struc,
        tab(30),
        minus(1),
        field(30),
      end of ls_struc.
field-symbols: <value>.
field-symbols: <wa_save> type any.

data: ld_once(1).
data: ld_rc       like sy-subrc.
data: wa_fieldcat type lvc_s_fcat.
field-symbols: <key> type any,
               <f1>, <f2>, <f3>.

*.fill current line into key to lock the entry on the database
  define makro_fill_key_wa.
     loop at gt_fieldcat_key into wa_fieldcat.
        ASSIGN COMPONENT wa_fieldcat-fieldname
                            OF STRUCTURE &1 TO <F1>.
        IF SY-SUBRC <> 0. continue. ENDIF.
        ASSIGN COMPONENT wa_fieldcat-fieldname
                                 OF STRUCTURE &2 TO <F2>.
        IF SY-SUBRC <> 0. continue. ENDIF.
        <f2> = <f1>.
     endloop.
  end-of-definition.

************************************************************************
*.When I am here my global table <all_table_cell>
*.is not yet effected. After
*.this form the changes will be there, now I have got the old lines.
*-----------------------------------------------------------------------
*.Get the modified rows and store them in table gt_mod.
*.Get the inserted rows and store them in table gt_mod.
*.Table gt_mod contains pointer to the lines of <all_table_cell> and a
*.flag if the line has been modified or inserted.
*.Lateron the changed lines will be read from <all_table_cell> and be
*.inserted or modified on the database.
*-----------------------------------------------------------------------
*.If a line has been inserted I have to change the style of the key
*.fields to editable, otherwise I would get Insert Duprecs
************************************************************************
*.When a line has been inserted or modified, enqueue this entry by
*.locking the key.
************************************************************************

*.call exit to check changed data
  perform external_exit using c_ext_data_changed
                        changing gd-exit_done.
  if gd-exit_done = true.
     read table gt_callback_events into ls_callback_events
           with key callback_event = c_ext_data_changed.
     perform (ls_callback_events-callback_form)
           in program (ls_callback_events-callback_program) if found
               changing lt_changed_data.
  endif.

*.As the deleted will disappear from <all_table_cell> I have to store
*.the information in <del_table>
  loop at lt_changed_data->mt_deleted_rows into ls_ins_rows.
*....Store the deleted line
     read table <all_table_cell> index ls_ins_rows-row_id
                                                   assigning <wa_cell>.
     check: sy-subrc = 0.
*....Move all information into <del_table>
*....I only need the structure of <all_table>, not the content!
     CREATE DATA waref LIKE LINE OF <all_table>.
     assign waref->* to <wa>.
     DO gd_lines TIMES.
         ASSIGN COMPONENT SY-INDEX OF STRUCTURE <wa> TO <FS>.
         IF SY-SUBRC <> 0. EXIT. ENDIF.
         ASSIGN COMPONENT SY-INDEX OF STRUCTURE <wa_cell>
                                                     TO <FS_cell>.
         IF SY-SUBRC <> 0. EXIT. ENDIF.
         <FS> = <fs_cell>.
     ENDDO.
     append <wa> to <del_table>.
************************************************************************
*....Perhaps enqueue the deleted lines as well..........................
************************************************************************
  endloop.

*.Get the inserted lines
  loop at lt_changed_data->mt_inserted_rows into ls_ins_rows.
*....Change the key to input, because the key
*....needs to be changed, otherwise I would get an insert duprec
     loop at gt_cell into gs_cell.
        call method lt_changed_data->modify_style
             exporting i_row_id    = ls_ins_rows-row_id
                       i_fieldname = gs_cell-fieldname
                       i_style     = cl_gui_alv_grid=>mc_style_enabled.
     endloop.
*....gd-count contains my own unique number for every line.
*....It has been filled after the select with the number of found
*....lines. So every new line gets a higher number.
     add 1 to gd-count.
*....Put the index into the dummy field
     call method lt_changed_data->modify_cell
             exporting i_row_id    = ls_ins_rows-row_id
                       i_fieldname = c_line_index
                       i_value     = gd-count.
*....Save the inserted lines
     read table gt_mod with key indx = gd-count.
     if sy-subrc <> 0.
        clear gt_mod.
        gt_mod-indx = gd-count.
        gt_mod-type = type_ins.
        append gt_mod.
     endif.
  endloop.

*.Get ld_lines to decide whether the line has been inserted or changed
  if gd-edit = true.
     describe table <all_table_cell> lines ld_lines.
  else.
     describe table <all_table> lines ld_lines.
  endif.

  ld_old_id = 0.
  loop at lt_changed_data->mt_good_cells into ls_mod_cells.
*....if row_id is the same then I do not need to check again
*....as this is called for every cell
     check: ls_mod_cells-row_id <> ld_old_id.
*....In field c_line_index my own index of this line is stored
     call method lt_changed_data->get_cell_value
             exporting i_row_id    = ls_mod_cells-row_id
                       i_fieldname = c_line_index
             importing e_value     = ld_my_indx.
     read table gt_mod with key indx = ld_my_indx.
     if sy-subrc <> 0.
        clear gt_mod.
*.......Original index used by ALV. This is used to undo changes in
*.......case of enqueue locks.
        gt_mod-alv_indx = ls_mod_cells-row_id.
        gt_mod-indx     = ld_my_indx.
        if ld_my_indx > ld_lines.
           gt_mod-type = type_ins.
        else.
           gt_mod-type = type_mod.
        endif.
        append gt_mod.
     endif.
*....store row-id
     ld_old_id = ls_mod_cells-row_id.
  endloop.

*.Save the old information for change documents
  if gd-edit = true.
     clear ld_once.
     assign local copy of initial line of <key_table> to <key>.
     loop at gt_mod where type = type_mod
                      and used <> true.
        ld_tabix = sy-tabix.
        read table <all_table_cell>
                with key (c_line_index) = gt_mod-indx
                                                assigning <wa_save>.
        check: sy-subrc = 0.
*.......enqueue the entry on the database to avoid double changes. It is
*.......not necessary to enqueue inserted lines, because another user
*.......will not get them.
        makro_fill_key_wa <wa_save> <key>.
        append <key> to <key_table>.
        perform enqueue_table using <key>
                              changing ld_rc.
        if ld_Rc <> 0.
*..........Entry is locked -> undo changes. Send message only once
           if ld_once <> true.
              MESSAGE i115(wusl) WITH <key>.
              ld_once = true.
           endif.
           loop at gt_fieldcat into wa_fieldcat.
              ASSIGN COMPONENT wa_fieldcat-fieldname
                             OF STRUCTURE <wa_save> TO <F3>.
              call method lt_changed_data->modify_cell
                exporting i_row_id    = gt_mod-alv_indx
                          i_fieldname = wa_fieldcat-fieldname
                          i_value     = <f3>.
           endloop.
           delete gt_mod index ld_tabix.
*.......Entry can be changed -> save old entry
        else.
           append <wa_save> to <all_table_save>.
           gt_mod-save = sy-tabix.
           gt_mod-used = true.
           modify gt_mod index ld_tabix.
        endif.
     endloop.
  endif.

ENDFORM.                    " DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  SAVE_CHANGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_CHANGES.

data: begin of ls_err,
        del_tab type se16n_tab,
        del_error(1),
        mod_tab type se16n_tab,
        mod_error(1),
        ins_tab type se16n_tab,
        ins_error(1),
      end of ls_err.
data: ld_text(50).
data: del_error(1).
data: ins_error(1).
data: mod_error(1).
*data: ls_gtdiscd       like gtdiscd.
data: waref            type ref to data.
data: txtref           type ref to data.
data: tabref           type ref to data.
data: tabref_del       type ref to data.
data: tabref_ins       type ref to data.
data: tabref_mod       type ref to data.
data: ld_timestamp     type se16n_id.
data: ls_se16n_cd_key  like se16n_cd_key.
data: ls_se16n_cd_data like se16n_cd_data.
data: lt_se16n_cd_data like se16n_cd_data occurs 0.
data: ld_pos           type se16n_pos.
data: wa_fieldcat      type lvc_s_fcat.
DATA: LD_TABIX LIKE SY-TABIX.
data: ld_txtfield      type fieldname.
DATA: LT_FIELDS        LIKE SVAL OCCURS 0 WITH HEADER LINE.
DATA: LD_rcode(1).

TYPES: BEGIN OF ls_indx_type,
         guid TYPE indx_srtfd,
       END OF ls_indx_type.
DATA: ls_indx TYPE ls_indx_type.
DATA: wa_indx TYPE se16n_cd_data2.

FIELD-SYMBOLS: <INDX>.
data: ld_all_txt(1)    value 'X'.
data: lt_seltab        like se16n_seltab occurs 0 with header line.
*data: lt_where(72)                       occurs 0 with header line.
data: lt_where type se16n_where_132      occurs 0 with header line.

field-symbols: <ld_wa>, <f1>, <f2>.
field-symbols: <f3>, <f4>.
field-symbols: <key_wa>  type any.
field-symbols: <txt_wa>  type any.
field-symbols: <wa_save> type any.
field-symbols: <tab_wa>  type any.
field-symbols: <all_table_d> type table.
field-symbols: <all_table_i> type table.
field-symbols: <all_table_m> type table.

field-symbols: <value> type x,
               <input> type x.

*.to make sure that unauthorised changes are documented, save the change
  do.
    GET TIME STAMP FIELD LD_TIMESTAMP.
    select single * from se16n_cd_key into ls_se16n_cd_key
                         where id = ld_timestamp.
    if sy-subrc <> 0.
      exit.
    endif.
  enddo.
*.Now we have got a unique key -> prepare change documents
  clear ld_pos.
  clear: ls_se16n_cd_key.
  refresh: lt_se16n_cd_data.
  get time.
  ls_se16n_cd_key-id    = ld_timestamp.
  ls_se16n_cd_key-uname = sy-uname.
  ls_se16n_cd_key-tab   = gd-tab.
  ls_se16n_cd_key-sdate = sy-datlo.
  ls_se16n_cd_key-stime = sy-timlo.
  if gd-read_clnt = true.
     ls_se16n_cd_key-clntdep = true.
  else.
     ls_se16n_cd_key-clntdep = false.
  endif.

*.get obligatory description text
  if gd-emergency = true.
    LT_FIELDS-TABNAME   = 'SE16N_CD_KEY'.
    LT_FIELDS-FIELDNAME = 'REASON'.
    APPEND LT_FIELDS.
    CALL FUNCTION 'POPUP_GET_VALUES'
       EXPORTING
              POPUP_TITLE = text-em1
       IMPORTING
              RETURNCODE  = LD_RCODE
       TABLES
              FIELDS      = LT_FIELDS
       EXCEPTIONS
              OTHERS      = 1.
    CHECK: SY-SUBRC = 0.
    CHECK: LD_RCODE = space.
    READ TABLE LT_FIELDS INDEX 1.
    ls_se16n_cd_key-reason = lt_fields-value.
  endif.

*.change documents for non casting fields
  create data tabref_del type table of (gd-tab).
  assign tabref_del->* to <all_table_d>.
  create data tabref_ins type table of (gd-tab).
  assign tabref_ins->* to <all_table_i>.
  create data tabref_mod type table of (gd-tab).
  assign tabref_mod->* to <all_table_m>.

************************************************************************
**** MAKROS to save coding *********************************************
************************************************************************

*.......................................................................
*.write change documents (data).........................................
*.input1 --> counting number
*.input2 --> line of output table
*.input3 --> type of change (insert, modify, delete)
*.input4 --> table name
  define makro_write_cd.
     add 1 to &1.
     clear ls_se16n_cd_data.
     ls_se16n_cd_data-id          = ld_timestamp.
     ls_se16n_cd_data-pos         = &1.
     ls_se16n_cd_data-change_type = &3.
     ls_se16n_cd_data-tab         = &4.
*....Unicode-Change <x>
     CATCH SYSTEM-EXCEPTIONS ASSIGN_CASTING_ILLEGAL_CAST = 1.
        ASSIGN &2 TO <INPUT> CASTING.
     ENDCATCH.
     IF SY-SUBRC = 0.
        ASSIGN LS_SE16N_CD_DATA-VALUE TO <VALUE> CASTING.
        <VALUE>                      = <INPUT>.
*       ls_se16n_cd_data-value       = &2.
        LS_SE16N_CD_DATA-LENGTH      = STRLEN( LS_SE16N_CD_DATA-VALUE ).
        APPEND LS_SE16N_CD_DATA TO LT_SE16N_CD_DATA.
     ELSE.
*......change documents cannot be stored, use different way
       if ls_se16n_cd_data-tab = gd-tab.
         case &3.
           when type_del.
             append &2 to <all_table_d>.
           when type_ins.
             append &2 to <all_table_i>.
           when type_mod.
             append &2 to <all_table_m>.
         endcase.
       endif.
     ENDIF.
  end-of-definition.

*.......................................................................
*.<wa_cell> contains also fields of text table (and tech fields).
*.I do not need all fields, so convert <wa_cell> into <tab_wa>
*.input1 --> <wa_cell>
*.input2 --> <tab_wa>.
  define makro_fill_tab_wa.
     loop at gt_fieldcat_tab into wa_fieldcat.
        ASSIGN COMPONENT wa_fieldcat-fieldname
                            OF STRUCTURE &1 TO <F3>.
        IF SY-SUBRC <> 0. continue. ENDIF.
        ASSIGN COMPONENT wa_fieldcat-fieldname
                                 OF STRUCTURE &2 TO <F4>.
        IF SY-SUBRC <> 0. continue. ENDIF.
        <f4> = <f3>.
     endloop.
  end-of-definition.

*.......................................................................
*.fill workarea for text table out of workarea of output table + langu..
*.input1 --> <wa_cell>
*.input2 --> <txt_wa>
  define makro_fill_txt_wa.
     loop at gt_fieldcat_txttab into wa_fieldcat.
*........check if txt table has a field with same name like main table
        read table gt_fieldcat_tab
                  with key fieldname = wa_fieldcat-fieldname
                               transporting no fields.
*.......table has field with the same name
        if sy-subrc = 0.
*.........get new fieldname
          read table gt_fieldcat_txt_double into gs_fieldcat_txt_double
                   with key org_fieldname = wa_fieldcat-fieldname.
          if sy-subrc = 0.
             ld_txtfield = gs_fieldcat_txt_double-new_fieldname.
*.........regular key fields are double, but not renamed!
          else.
             ld_txtfield = wa_fieldcat-fieldname.
          endif.
        else.
          ld_txtfield = wa_fieldcat-fieldname.
        endif.
*.......Fill language with current one
        if wa_fieldcat-datatype = 'LANG'.
*..........very special case, T002T has two language fields
           if gd-txt_tab            = 'T002T' and
              wa_fieldcat-fieldname = 'SPRSL'.
*.............fill SPRAS from table into SPRSL of txt-table
              ASSIGN COMPONENT 'SPRAS'
                               OF STRUCTURE &1 TO <F3>.
              IF SY-SUBRC <> 0. continue. ENDIF.
              ASSIGN COMPONENT wa_fieldcat-fieldname
                                    OF STRUCTURE &2 TO <F4>.
              IF SY-SUBRC <> 0. continue. ENDIF.
              <f4> = <f3>.
           else.
           ASSIGN COMPONENT wa_fieldcat-fieldname
                               OF STRUCTURE &2 TO <F4>.
           <f4> = sy-langu.
           endif.
        else.
           ASSIGN COMPONENT ld_txtfield
                               OF STRUCTURE &1 TO <F3>.
           IF SY-SUBRC <> 0. continue. ENDIF.
           ASSIGN COMPONENT wa_fieldcat-fieldname
                                    OF STRUCTURE &2 TO <F4>.
           IF SY-SUBRC <> 0. continue. ENDIF.
           <f4> = <f3>.
        endif.
     endloop.
  end-of-definition.

*.If I want to delete ALL dependent text-table-entries, I need to
*.create a where-statement
  define makro_fill_txt_where.
     refresh: lt_seltab.
     loop at gt_fieldcat_txttab into wa_fieldcat
                         where key = true.
*.......Fill selection table with key fields (except language)
        if wa_fieldcat-datatype <> 'LANG'.
           ASSIGN COMPONENT wa_fieldcat-fieldname
                            OF STRUCTURE <txt_wa> TO <F3>.
           IF SY-SUBRC <> 0. continue. ENDIF.
           clear lt_seltab.
           lt_seltab-field = wa_fieldcat-fieldname.
           lt_seltab-sign = 'I'.
           lt_seltab-option = 'EQ'.
           lt_seltab-low = <f3>.
           append lt_seltab.
        else.
*..........very special case, T002T has two language fields
           if gd-txt_tab = 'T002T' and
              wa_fieldcat-fieldname = 'SPRSL'.
              ASSIGN COMPONENT wa_fieldcat-fieldname
                            OF STRUCTURE <txt_wa> TO <F3>.
              IF SY-SUBRC <> 0. continue. ENDIF.
              clear lt_seltab.
              lt_seltab-field  = wa_fieldcat-fieldname.
              lt_seltab-sign   = 'I'.
              lt_seltab-option = 'EQ'.
              lt_seltab-low    = <f3>.
              append lt_seltab.
           endif.
        endif.
     endloop.
     CALL FUNCTION 'SE16N_CREATE_SELTAB'
         TABLES
            LT_SEL         = lt_seltab
            LT_WHERE       = lt_where.
  end-of-definition.
************************************************************************
*  End of makros *******************************************************
************************************************************************

************************************************************************
*.In case of text table active, the field symbols contain more fields
*.than necessary for the primary table update. But the database func-
*.tions are able to handle this. The not known fields will be ignored.
************************************************************************
  clear: mod_error, ins_error, del_error, ls_err.
  clear: gd_ins_nr, gd_mod_nr, gd_del_nr.

*.create field-symbol for text-table-update
  if gd-txt_tab <> space.
     create data txtref type (gd-txt_tab).
     assign txtref->* to <txt_wa>.
  endif.
*.create field-symbol for table-update
  create data tabref type (gd-tab).
  assign tabref->* to <tab_wa>.

*.First handle the deleted lines
  loop at <del_table> assigning <ld_wa>.
     LD_TABIX = SY-TABIX.
     ASSIGN COMPONENT C_LINE_INDEX OF STRUCTURE <LD_WA> TO <INDX>.
     DELETE GT_MOD WHERE INDX = <INDX>.
     IF SY-SUBRC = 0.
        DELETE <DEL_TABLE> INDEX LD_TABIX.
        CONTINUE.
     ENDIF.
     if gd-no_txt <> true and gd-txt_tab <> space.
        makro_fill_txt_wa <ld_wa> <txt_wa>.
     endif.
*....<ld_wa> contains more fields than the table -> create <tab_wa>
     makro_fill_tab_wa <ld_wa> <tab_wa>.
     if gd-read_clnt = true.
        if gd-no_txt <> true and gd-txt_tab <> space.
           if ld_all_txt = true.
              makro_fill_txt_where.
              delete from (gd-txt_tab) client specified
                                       where (lt_where).
           else.
              delete (gd-txt_tab) client specified from <txt_wa>.
           endif.
           makro_write_cd ld_pos <txt_wa> type_del gd-txt_tab.
           if sy-subrc <> 0.
              del_error = true.
              ls_err-del_tab   = gd-txt_tab.
              ls_err-del_error = true.
           endif.
        endif.
        delete (gd-tab) client specified from <tab_wa>.
     else.
        if gd-no_txt <> true and gd-txt_tab <> space.
*..........at the moment only the current language will be deleted
           if ld_all_txt = true.
              makro_fill_txt_where.
              delete from (gd-txt_tab) where (lt_where).
           else.
              delete (gd-txt_tab) from <txt_wa>.
           endif.
           if sy-subrc <> 0.
*.............no error, because there must not be an entry
*             del_error = true.
*             ls_err-del_tab   = gd-txt_tab.
*             ls_err-del_error = true.
           else.
              makro_write_cd ld_pos <txt_wa> type_del gd-txt_tab.
           endif.
        endif.
        delete (gd-tab) from <tab_wa>.
     endif.
     if sy-subrc <> 0.
        del_error = true.
        ls_err-del_tab   = gd-tab.
        ls_err-del_error = true.
     endif.
     makro_write_cd ld_pos <tab_wa> type_del gd-tab.
*....call exit again with the info about old line
     PERFORM CHECK_EXIT USING C_EVENT_SAVE
                              C_ADD_INFO_DELETE
                              GD-TAB
                        CHANGING TABREF.
     add 1 to gd_del_nr.
  endloop.
  CREATE DATA waref LIKE LINE OF <all_table>.
  assign waref->* to <wa>.

*.Now divide the other changes into modified and inserted
  loop at gt_mod where type <> type_del.
     read table <all_table_cell>
                with key (c_line_index) = gt_mod-indx
                                                assigning <wa_cell>.
     check: sy-subrc = 0.
     makro_fill_tab_wa <wa_cell> <tab_wa>.
     check: sy-subrc = 0.
     case gt_mod-type.
       when type_mod.
*.........fill all necessary fields into text table
          if gd-no_txt <> true and gd-txt_tab <> space.
             makro_fill_txt_wa <wa_cell> <txt_wa>.
          endif.
          if gd-read_clnt = true.
*............Update text table if existent
             if gd-no_txt <> true and gd-txt_tab <> space.
                perform check_exit using c_event_save
                                         c_add_info_modify
                                         gd-txt_tab
                                changing txtref.
                MODIFY (GD-TXT_TAB) CLIENT SPECIFIED FROM <TXT_WA>.
*...............If line has been modified, store old one
                READ TABLE <ALL_TABLE_SAVE> INDEX GT_MOD-SAVE
                           ASSIGNING <WA_SAVE>.
                MAKRO_FILL_TXT_WA <WA_SAVE> <TXT_WA>.
                MAKRO_WRITE_CD LD_POS <TXT_WA> TYPE_MOD GD-TXT_TAB.
                IF SY-SUBRC <> 0.
                   MOD_ERROR = TRUE.
                   LS_ERR-MOD_TAB   = GD-TXT_TAB.
                   LS_ERR-MOD_ERROR = TRUE.
                ENDIF.
             ENDIF.
             perform check_exit using c_event_save
                                      c_add_info_modify
                                      gd-tab
                                changing tabref.
             UPDATE (GD-TAB) CLIENT SPECIFIED FROM <TAB_WA>.
          ELSE.
             IF GD-NO_TXT <> TRUE AND GD-TXT_TAB <> SPACE.
                perform check_exit using c_event_save
                                         c_add_info_modify
                                         gd-txt_tab
                                changing txtref.
                MODIFY (GD-TXT_TAB) FROM <TXT_WA>.
*...............If line has been modified, store old one
                read table <all_table_save> index gt_mod-save
                           assigning <wa_save>.
                makro_fill_txt_wa <wa_save> <txt_wa>.
                makro_write_cd ld_pos <txt_wa> type_mod gd-txt_tab.
                if sy-subrc <> 0.
                   mod_error = true.
                   ls_err-mod_tab   = gd-txt_tab.
                   ls_err-mod_error = true.
                endif.
             endif.
             perform check_exit using c_event_save
                                      c_add_info_modify
                                      gd-tab
                                changing tabref.
             update (gd-tab) from <tab_wa>.
          endif.
          if sy-subrc <> 0.
             mod_error = true.
             ls_err-mod_tab   = gd-tab.
             ls_err-mod_error = true.
          endif.
*.........If line has been modified, store old one
          READ TABLE <ALL_TABLE_SAVE> INDEX GT_MOD-SAVE
                           ASSIGNING <WA_SAVE>.
          MAKRO_FILL_TAB_WA <WA_SAVE> <TAB_WA>.
          makro_write_cd ld_pos <tab_wa> type_mod gd-tab.
*.........call exit again with the info about old line
          PERFORM CHECK_EXIT USING C_EVENT_SAVE
                                   C_ADD_INFO_MODOLD
                                   GD-TAB
                             CHANGING TABREF.
          add 1 to gd_mod_nr.
       when type_ins.
          if gd-no_txt <> true and gd-txt_tab <> space.
             makro_fill_txt_wa <wa_cell> <txt_wa>.
          endif.
          if gd-read_clnt = true.
             if gd-no_txt <> true and gd-txt_tab <> space.
                perform check_exit using c_event_save
                                         c_add_info_insert
                                         gd-txt_tab
                                changing txtref.
                insert (gd-txt_tab) client specified from <txt_wa>.
                makro_write_cd ld_pos <txt_wa> type_ins gd-txt_tab.
                if sy-subrc <> 0.
                   ins_error = true.
                   ls_err-ins_tab   = gd-txt_tab.
                   ls_err-ins_error = true.
                endif.
             endif.
             perform check_exit using c_event_save
                                      c_add_info_insert
                                      gd-tab
                                changing tabref.
             insert (gd-tab) client specified from <tab_wa>.
          else.
             if gd-no_txt <> true and gd-txt_tab <> space.
                perform check_exit using c_event_save
                                         c_add_info_insert
                                         gd-txt_tab
                                changing txtref.
                insert (gd-txt_tab) from <txt_wa>.
                makro_write_cd ld_pos <txt_wa> type_ins gd-txt_tab.
                if sy-subrc <> 0.
                   ins_error = true.
                   ls_err-ins_tab   = gd-txt_tab.
                   ls_err-ins_error = true.
                endif.
             endif.
             perform check_exit using c_event_save
                                      c_add_info_insert
                                      gd-tab
                                changing tabref.
             insert (gd-tab) from <tab_wa>.
          endif.
          if sy-subrc <> 0.
             ins_error = true.
             ls_err-ins_tab   = gd-tab.
             ls_err-ins_error = true.
          endif.
          makro_write_cd ld_pos <tab_wa> type_ins gd-tab.
          add 1 to gd_ins_nr.
     endcase.
  endloop.
*.If anything to do
  if gd_ins_nr > 0 or
     gd_del_nr > 0 or
     gd_mod_nr > 0.
     if ins_error <> true and
        del_error <> true and
        mod_error <> true.
*.......Write own change-documents.....................................
        if not lt_se16n_cd_data[] is initial.
          insert se16n_cd_data from table lt_se16n_cd_data.
          if sy-subrc <> 0.
             message x121(wusl).
          endif.
*.......table cannot be stored in SE16N_CD_DATA due to its structure
*.......export the data to INDX
        else.
*.........Create INDX-KeyID GUID22
            CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_c22
                  RECEIVING
                    uuid = ls_indx-guid.
*...........INDX only allows upper case
            TRANSLATE ls_indx-guid TO UPPER CASE.
            wa_indx-id  = ld_timestamp.
            wa_indx-tab = gd-tab.
            if not <all_table_d>[] is initial.
               wa_indx-change_type = 'D'.
               EXPORT <all_table_d> TO DATABASE se16n_cd_data2(1D) FROM wa_indx ID ls_indx-guid.
            endif.
            if not <all_table_i>[] is initial.
               wa_indx-change_type = 'I'.
               EXPORT <all_table_i> TO DATABASE se16n_cd_data2(1I) FROM wa_indx ID ls_indx-guid.
            endif.
            if not <all_table_m>[] is initial.
               wa_indx-change_type = 'M'.
               EXPORT <all_table_m> TO DATABASE se16n_cd_data2(1M) FROM wa_indx ID ls_indx-guid.
            endif.
            ls_se16n_cd_key-indx_guid = ls_indx-guid.
        endif.
*.......now store the key
        insert se16n_cd_key from ls_se16n_cd_key.
        if sy-subrc <> 0.
           message x121(wusl).
        endif.
*.......Now do the changes.............................................
        commit work.
*.......Dequeue the locks..............................................
        loop at <key_table> assigning <key_wa>.
           perform dequeue_table using <key_wa>.
        endloop.
        refresh: gt_mod, <del_table>, <all_table_save>, <key_table>.
        call screen 300 starting at 5 5 ending at 50 10.
     else.
        rollback work.
*       refresh: gt_mod, <del_table>, <all_table_save>, <key_table>.
        if ls_err-del_error = true.
           clear ld_text.
           concatenate text-erd ls_err-del_tab into ld_text
                       separated by space.
           message i112(wusl) with ld_text.
        elseif ls_err-mod_error = true.
           clear ld_text.
           concatenate text-erm ls_err-mod_tab into ld_text
                       separated by space.
           message i112(wusl) with ld_text.
        elseif ls_err-ins_error = true.
           clear ld_text.
           concatenate text-eri ls_err-ins_tab into ld_text
                       separated by space.
           message i430(mo).
        endif.
     endif.
  endif.

ENDFORM.                    " SAVE_CHANGES
*&---------------------------------------------------------------------*
*&      Form  enqueue_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<KEY>  text
*----------------------------------------------------------------------*
FORM enqueue_table USING KEY
                   changing value(rc).

data: sperrdat like rstable-varkey.
FIELD-SYMBOLS: <FS1>, <FS2>.

  ASSIGN KEY TO <FS1> CASTING TYPE X.
  ASSIGN SPERRDAT TO <FS2> CASTING TYPE X.

  <FS2> = <FS1>.

     CALL FUNCTION 'ENQUEUE_E_TABLEE'
       EXPORTING
*        MODE_RSTABLE         = 'E'
         TABNAME              = gd-tab
         VARKEY               = sperrdat
*        X_TABNAME            = ' '
*        X_VARKEY             = ' '
*        _SCOPE               = '2'
*        _WAIT                = ' '
*        _COLLECT             = ' '
       EXCEPTIONS
         FOREIGN_LOCK         = 1
         SYSTEM_FAILURE       = 2
         OTHERS               = 3.

     rc = sy-subrc.

ENDFORM.                    " enqueue_table
*&---------------------------------------------------------------------*
*&      Form  dequeue_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<KEY_WA>  text
*----------------------------------------------------------------------*
FORM dequeue_table USING KEY.

data: sperrdat like rstable-varkey.
FIELD-SYMBOLS: <FS1>, <FS2>.

  ASSIGN KEY TO <FS1> CASTING TYPE X.
  ASSIGN SPERRDAT TO <FS2> CASTING TYPE X.

  <FS2> = <FS1>.

  CALL FUNCTION 'DEQUEUE_E_TABLEE'
    EXPORTING
*     MODE_RSTABLE       = 'E'
      TABNAME            = gd-tab
      VARKEY             = sperrdat.
*     X_TABNAME          = ' '
*     X_VARKEY           = ' '
*     _SCOPE             = '3'
*     _SYNCHRON          = ' '
*     _COLLECT           = ' '


ENDFORM.                    " dequeue_table
*&---------------------------------------------------------------------*
*&      Form  fill_gt_se16n_rf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_gt_se16n_rf .

data: ls_tstct like tstct.
data: ld_tabix like sy-tabix.

  refresh gt_se16n_rf.
  select * from se16n_rf into table gt_se16n_rf where tab = gd-tab.
  check: sy-subrc = 0.
  sort gt_se16n_rf by pos.
  loop at gt_se16n_rf where fcode_text = space.
     ld_tabix = sy-tabix.
     SELECT SINGLE * FROM  TSTCT into ls_tstct
              WHERE  SPRSL       = sy-langu
              AND    TCODE       = gt_se16n_rf-fcode.
     gt_se16n_rf-fcode_text = ls_tstct-ttext.
     modify gt_se16n_rf index ld_tabix.
  endloop.

ENDFORM.                    " fill_gt_se16n_rf
*&---------------------------------------------------------------------*
*&      Form  add_ctmenu
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*----------------------------------------------------------------------*
FORM add_ctmenu  USING menu type ref to cl_ctmenu.

  call method menu->ADD_SEPARATOR.

  if gd-hana_active <> true.
    loop at gt_se16n_rf.
      CALL METHOD menu->add_function
              EXPORTING fcode = gt_se16n_rf-fcode
                        text =  gt_se16n_Rf-fcode_text.
    endloop.
  endif.

*.Drilldown call - check that the screen 100 was processed
*.In case of external call (via SE16N_BATCH) the global tables
*.first have to be filled.
  if not gt_selfields[] is initial and
    not gt_group_by_fields[] is initial.
     if gd-ext_call <> true.
        CALL METHOD menu->add_function
             EXPORTING fcode = c_drilldown_line_fcode
                       text  = text-214. "Line-Drilldown
     endif.
     if gd-hana_active = true and
        gd-ext_call    <> true.
        CALL METHOD menu->add_function
             EXPORTING fcode = c_drilldown_line_fcode_easy
                       text  = text-215. "Line-Drilldown easy
     endif.
     if gd-ext_call <> true.
        CALL METHOD menu->add_function
             EXPORTING fcode = c_drilldown_all_fcode
                       text  = text-216. "Drilldown for whole list
     endif.
     if gd-hana_active = true.
        CALL METHOD menu->add_function
             EXPORTING fcode = c_drilldown_line_same_screen
                       text  = text-212. "Drilldown/Line same screen
        CALL METHOD menu->add_function
             EXPORTING fcode = c_drilldown_list_same_screen
                       text  = text-213. "Drilldown/List same screen
        CALL METHOD menu->add_function
             EXPORTING fcode = c_rri_search
                       text  = text-217. "Get related tables for RRI
     endif.
  endif.

ENDFORM.                    " add_ctmenu
*&---------------------------------------------------------------------*
*&      Form  call_fcode
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_ROW  text
*      -->P_LD_COL  text
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM call_fcode  USING value(LD_ROW)
                       value(LD_COL)
                       fcode like sy-ucomm.

data: ls_se16n_rf like se16n_rf.
data: ld_fcode_40(40).
field-symbols: <wa_table> type any.

  if gd-edit = true.
     read table <all_table_cell> index ld_row assigning <wa_table>.
  else.
     read table <all_table> index ld_row assigning <wa_table>.
  endif.
  check: sy-subrc = 0.
  read table gt_se16n_Rf into ls_se16n_rf with key fcode = fcode.
  check: sy-subrc = 0.
*.in case of special function, call this function
  if ls_se16n_rf-function <> space.
      call function ls_se16n_rf-function
         exporting  i_tab   = gd-tab
                    i_wa    = <wa_table>
                    i_fcode = fcode
         exceptions others  = 1.
      if sy-subrc <> 0.
         message i123(wusl) with fcode.
      endif.
  else.
     ld_fcode_40 = fcode.
     authority-check object 'S_TCODE' id 'TCD' field ld_fcode_40.
     if sy-subrc <> 0.
       message i401(ga2) with ld_fcode_40.
       exit.
     endif.
     call transaction fcode.
  endif.

ENDFORM.                    " call_fcode
*&---------------------------------------------------------------------*
*&      Form  CHECK_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1184   text
*      -->P_GD_TAB  text
*      <--P_<TAB_WA>  text
*----------------------------------------------------------------------*
FORM CHECK_EXIT  USING    VALUE(P_EXIT_POINT)
                          VALUE(P_ADD_INFO)
                          P_TAB
                 CHANGING P_ref.

data: ls_exit type se16n_exit.
data: ld_fieldname(30).
data: lt_fieldcat type lvc_t_fcat.

*...Possible events..............................
*.. SAVE
*................................................
*...Possible additional info.....................
*.. INSERT for event SAVE
*.. MODIFY for event SAVE
*.. DELETE for event SAVE
*................................................
*.special exit for audit purposes
  if gd-fica_audit = true.
    case p_exit_point.
      when c_event_fica_lock.
         select single * from se16n_exit into ls_exit
                       where tab            = '*'
                         and callback_event = c_event_fica_lock.
         check: sy-subrc = 0.
*...this form is called to lock the table entries that will be read
         perform (ls_exit-callback_form)
            in program (ls_exit-callback_program) if found
              using    p_exit_point
                       p_add_info
                       p_tab
                       gd-edit
                       gt_or_selfields.
      when c_event_save.
         select single * from se16n_exit into ls_exit
                       where tab            = '*'
                         and callback_event = c_event_fica_save.
         check: sy-subrc = 0.
         perform (ls_exit-callback_form)
            in program (ls_exit-callback_program) if found
              using    p_exit_point
                       p_add_info
                       p_tab
              changing p_ref.
    endcase.
    exit.
  endif.

*...check if current exit point is defined
  read table gt_cb_events into gs_cb_events
              with key callback_event = p_exit_point.
  if sy-subrc = 0.
    case p_exit_point.
*.....exit event during save of table changes
      when c_event_save.
        perform (gs_cb_events-callback_form)
            in program (gs_cb_events-callback_program) if found
              using    p_exit_point
                       p_add_info
                       p_tab
              changing p_ref.
*.....exit event for DB-Hint
      when c_event_db_hint.
        if gs_cb_events-callback_funct <> space.
           CALL FUNCTION 'RH_FUNCTION_EXIST'
             EXPORTING
               NAME               = gs_cb_events-callback_funct
             EXCEPTIONS
               FUNCTION_NOT_FOUND = 1
               OTHERS             = 2.
           IF SY-SUBRC <> 0.
*.............Funktionsbaustein & ist noch nicht vorhanden
              MESSAGE i110(FL) WITH gs_cb_events-callback_funct.
              exit.
           ENDIF.
           call function gs_cb_events-callback_funct
             EXPORTING
                i_exit_point          = p_exit_point
                i_tab                 = p_tab
*                i_add_info            = p_add_info
                it_or_selfields       = gt_or_selfields
             CHANGING
                i_hint                = gd-hint
                i_field               = gd-hint_field
                i_value               = gd-hint_value.
        endif.
*.....exit event for DB-Count
      when c_event_db_count.
        if gs_cb_events-callback_funct <> space.
           CALL FUNCTION 'RH_FUNCTION_EXIST'
             EXPORTING
               NAME               = gs_cb_events-callback_funct
             EXCEPTIONS
               FUNCTION_NOT_FOUND = 1
               OTHERS             = 2.
           IF SY-SUBRC <> 0.
*.............Funktionsbaustein & ist noch nicht vorhanden
              MESSAGE i110(FL) WITH gs_cb_events-callback_funct.
              exit.
           ENDIF.
           call function gs_cb_events-callback_funct
             EXPORTING
                i_exit_point          = p_exit_point
                i_tab                 = p_tab
*                i_add_info            = p_add_info
                it_or_selfields       = gt_or_selfields
             CHANGING
                i_count               = gd-hint_count.
        endif.
*.....exit event after totalling of lines
      when c_event_add_up.
        if gs_cb_events-callback_funct <> space.
           CALL FUNCTION 'RH_FUNCTION_EXIST'
             EXPORTING
               NAME               = gs_cb_events-callback_funct
             EXCEPTIONS
               FUNCTION_NOT_FOUND = 1
               OTHERS             = 2.
           IF SY-SUBRC <> 0.
*.............Funktionsbaustein & ist noch nicht vorhanden
              MESSAGE i110(FL) WITH gs_cb_events-callback_funct.
              exit.
           ENDIF.
           if p_add_info = c_add_info_curr.
              ld_fieldname = c_total_curr_value.
           elseif p_add_info = c_add_info_quan.
              ld_fieldname = c_total_quan_value.
           endif.
           call function gs_cb_events-callback_funct
             EXPORTING
                i_exit_point          = p_exit_point
                i_tab                 = p_tab
                i_add_info            = p_add_info
                i_fieldname           = ld_fieldname
                it_add_up_curr_fields = gt_add_up_curr_fields
                it_add_up_quan_fields = gt_add_up_quan_fields
             CHANGING
                i_tabref              = p_ref.
        elseif gs_cb_events-callback_form <> space.
           perform (gs_cb_events-callback_form)
             in program (gs_cb_events-callback_program) if found
               tables   gt_add_up_curr_fields
                        gt_add_up_quan_fields
               using    p_exit_point
                        p_add_info
                        p_tab
               changing p_ref.
        endif.
      when c_event_add_fields.
*.......only if really switched on by user
        if gs_cb_events-callback_funct <> space.
           CALL FUNCTION 'RH_FUNCTION_EXIST'
             EXPORTING
               NAME               = gs_cb_events-callback_funct
             EXCEPTIONS
               FUNCTION_NOT_FOUND = 1
               OTHERS             = 2.
           IF SY-SUBRC <> 0.
*.............Funktionsbaustein & ist noch nicht vorhanden
              MESSAGE i110(FL) WITH gs_cb_events-callback_funct.
              exit.
           ENDIF.
           case p_add_info.
             when c_add_info_add_sscr.
*..............first call of this function on selection screen
               call function gs_cb_events-callback_funct
                 EXPORTING
                    i_exit_point = p_exit_point
                    i_add_info   = p_add_info
                    i_tab        = p_tab
                 IMPORTING
                    E_DDTEXT     = gd-add_field_text
                    E_REF_FIELD  = gd-add_field_reffld
                    E_REF_TABLE  = gd-add_field_reftab.
             when c_add_info_add_fcat.
*..............second call of this function to determine which fields
*..............have to be added to the fieldcatalog
               call function gs_cb_events-callback_funct
                 EXPORTING
                    i_exit_point          = p_exit_point
                    i_add_info            = p_add_info
                    i_tab                 = p_tab
                    i_input               = gd-add_field

                 CHANGING
                    it_fieldcat           = lt_fieldcat.
               append lines of lt_fieldcat to gt_fieldcat.
             when c_add_info_add_calc.
*............third call to calculate the new fields
               call function gs_cb_events-callback_funct
                 EXPORTING
                    i_exit_point          = p_exit_point
                    i_add_info            = p_add_info
                    i_tab                 = p_tab
                    i_input               = gd-add_field
                 CHANGING
                    i_tabref              = p_ref.
           endcase.
        elseif gs_cb_events-callback_form <> space.
*..........not possible in this case due to two calls
        endif.
    endcase.
  endif.

*.......................................................
*..Example coding for extern caller
*.......................................................
*.In the callback routine the caller can change the content
*.of the current work area. Please note that the content of
*.the changed fields is NOT immediately visible in SE16N.
*.Only after refresh the data is visible.
*........................................................
*Report ZEXAMPLE.
*
*data: lt_events type se16n_events.
*data: ls_events type se16n_events_type.
*
*  ls_events-callback_program = sy-repid.
*  ls_events-callback_form = 'CALLBACK'.
*  ls_events-callback_event = 'SAVE'.
*  append ls_events to lt_events.
*
*CALL FUNCTION 'SE16N_INTERFACE'
*  EXPORTING
*    I_TAB                    = 'TABLE'
*    I_EDIT                   = 'X'
*  TABLES
*    IT_CALLBACK_EVENTS       = lt_events.
*
*FORM callback  USING    VALUE(P_EXIT_POINT)
*                        VALUE(P_ADD_INFO)
*                          P_TAB
*                 CHANGING p_tabref.
*
*field-symbols: <wa> type any.
*field-symbols: <field>.
*
*  assign p_tabref->* to <wa>.
*  assign component 'Your field' of structure <wa> to <field>.
*  <field> = 'Your text'.
*
*endform.

ENDFORM.                    " CHECK_EXIT
*&---------------------------------------------------------------------*
*&      Form  SUMMARIZE_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADD_UP_FIELDS .

field-symbols: <wa>, <f>, <total>.

*.Table GT_ADD_UP_*_FIELDS contains the fields that need to be
*.summarized
  if not gt_add_up_curr_fields[] is initial.
    loop at <all_table> assigning <wa>.
       assign component c_total_curr_value of structure <wa> to <total>.
       check: sy-subrc = 0.
*......now get every requested value
       loop at gt_add_up_curr_fields.
          assign component gt_add_up_curr_fields-field of structure
             <wa> to <f>.
          add <f> to <total>.
       endloop.
    endloop.
*...call exit to give the chance to do additional sum-ups
    perform check_exit using c_event_add_up
                             c_add_info_curr
                             gd-tab
                       changing gd_dref.
  endif.

  if not gt_add_up_quan_fields[] is initial.
    loop at <all_table> assigning <wa>.
       assign component c_total_quan_value of structure <wa> to <total>.
       check: sy-subrc = 0.
*......now get every requested value
       loop at gt_add_up_quan_fields.
          assign component gt_add_up_quan_fields-field of structure
             <wa> to <f>.
          add <f> to <total>.
       endloop.
    endloop.
*...call exit to give the chance to do additional sum-ups
    perform check_exit using c_event_add_up
                             c_add_info_quan
                             gd-tab
                       changing gd_dref.
  endif.

*.call exit to fill addditional fields
  perform check_exit using c_event_add_fields
                           c_add_info_add_calc
                           gd-tab
                     changing gd_dref.

ENDFORM.                    " SUMMARIZE_FIELDS
*&---------------------------------------------------------------------*
*&      Form  VALUE_CHECK_ON_LINE_LEVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALUE_CHECK_ON_LINE_LEVEL .

data: lt_se16n_user_role   like se16n_user_role occurs 0.
data: lt_se16n_value       like se16n_role_value occurs 0.
data: ls_se16n_value       like se16n_role_value.
data: ls_se16n_value_check like se16n_role_value.
data: ld_fieldname         like se16n_role_value-fieldname.
data: lt_selfields         like se16n_seltab occurs 0.
data: ls_selfields         like se16n_seltab.
data: lt_where(72)         occurs 0.
data: ld_tabix             like sy-tabix.
data: ld_count             like sy-tabix.
data: ld_auth(1).
data: ld_message(1).
field-symbols: <field>.


*.check if tax auditor
  CALL FUNCTION 'CA_USER_EXISTS'
  EXPORTING
    i_user       = sy-uname
  EXCEPTIONS
    user_missing = 1.
  IF sy-subrc = 0.
    CALL FUNCTION 'SE16N_TAX_AUDIT_CHECK'
    EXPORTING
      IT_FIELDCAT        = gt_fieldcat
      IT_OR_SELFIELDS    = gt_or_selfields
      I_TAB              = gd-tab
    CHANGING
      ID_DREF            = gd_dref.
  ENDIF.


*.this is now done in SE16N_CREATE_SELTAB directly
exit.

*.get assignment of user to limitations
  select * from se16n_user_role into table lt_se16n_user_role
                where ( uname = gd-uname or
                        uname = '*' ).
  check: sy-subrc = 0.
*.get the limitations
  select * from se16n_role_value into table lt_se16n_value
         for all entries in lt_se16n_user_role
               where se16n_role = lt_se16n_user_role-se16n_role
                 and tabname    = gd-tab.

*.only if there are restrictions
  check: sy-subrc = 0.

  sort lt_se16n_value.

  loop at lt_se16n_value into ls_se16n_value.
     ls_selfields-field  = ls_se16n_value-fieldname.
     ls_selfields-sign   = ls_se16n_value-sign.
     ls_selfields-option = ls_se16n_value-sel_option.
     ls_selfields-low    = ls_se16n_value-low.
     ls_selfields-high   = ls_se16n_value-high.
     append ls_selfields to lt_selfields.
  endloop.
  CALL FUNCTION 'SE16N_CREATE_SELTAB'
        EXPORTING
             i_pool   = gd-pool
        TABLES
             LT_SEL   = lt_selfields
             LT_WHERE = lt_where.
*.search with the defined criteria which lines are valid
*.the ones that fit the criteria are marked with 999
  loop at <all_table> assigning <wa>
     where (lt_where).
       assign component c_line_index
               of structure <wa> to <field>.
       <field> = 999.
  endloop.
  clear ld_message.
*.delete all lines that do NOT have 999 the remaining ones are valid
  loop at <all_table> assigning <wa>.
     ld_tabix = sy-tabix.
       assign component c_line_index
               of structure <wa> to <field>.
     if <field> <> 999.
        delete <all_table> index ld_tabix.
        add 1 to ld_count.
        ld_message = true.
     else.
        <field> = 0.
     endif.
  endloop.

*
*.send popup that certain lines have been excluded
  if ld_message = true.
     message s587(gr) with ld_count gd-number.
  endif.

ENDFORM.                    " VALUE_CHECK_ON_LINE_LEVEL
*&---------------------------------------------------------------------*
*&      Form  ADAPT_SE16N_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADAPT_SE16N_ROLE tables lt_where
                      using  value(ld_no_selections)
                             value(i_join_active).

data: ls_or_selfields      type SE16N_OR_SELTAB.
data: lt_se16n_user_role   like se16n_user_role occurs 0.
data: lt_se16n_value       like se16n_role_value occurs 0.
data: ls_se16n_value       like se16n_role_value.
data: ls_se16n_value_check like se16n_role_value.
data: ld_fieldname         like se16n_role_value-fieldname.
data: lt_selfields         like se16n_seltab occurs 0.
data: ls_selfields         like se16n_seltab.
data: lt_role_where(72)    occurs 0 with header line.
data: ls_where(72).
data: ld_tabix             like sy-tabix.
data: ld_count             like sy-tabix.
data: ld_auth(1).
data: ld_message(1).
field-symbols: <field>.

*.get assignment of user to limitations
  perform role_get_roles tables lt_se16n_user_role.
  check not lt_se16n_user_role[] is initial.

**.get assignment of user to limitations
*  select * from se16n_user_role into table lt_se16n_user_role
*                where ( uname = gd-uname or
*                        uname = '*' ).
*  check: sy-subrc = 0.
*.get the limitations
  select * from se16n_role_value into table lt_se16n_value
         for all entries in lt_se16n_user_role
               where se16n_role = lt_se16n_user_role-se16n_role
                 and ( tabname    = gd-tab or
                       tabname    = '*' ).

*.only if there are restrictions
  check: sy-subrc = 0.

  sort lt_se16n_value.

  loop at lt_se16n_value into ls_se16n_value.
*....check that field belongs to the table
data: ld_tab   type ddobjname.
data: ld_field like dfies-lfieldname.
     ld_tab   = gd-tab.
     ld_field = ls_se16n_value-fieldname.
     CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
         TABNAME              = ld_tab
*        FIELDNAME            = ' '
*        LANGU                = SY-LANGU
         LFIELDNAME           = ld_field
       EXCEPTIONS
         NOT_FOUND            = 1
         INTERNAL_ERROR       = 2
         OTHERS               = 3.
     check: sy-subrc = 0.
     ls_selfields-field  = ls_se16n_value-fieldname.
     ls_selfields-sign   = ls_se16n_value-sign.
     ls_selfields-option = ls_se16n_value-sel_option.
     ls_selfields-low    = ls_se16n_value-low.
     ls_selfields-high   = ls_se16n_value-high.
     append ls_selfields to lt_selfields.
  endloop.
  if sy-subrc = 0 and
    not lt_selfields[] is initial.
*.create selection table out of role-values
    CALL FUNCTION 'SE16N_CREATE_SELTAB'
      EXPORTING
         i_pool   = gd-pool
         i_join_active = i_join_active
      TABLES
         LT_SEL   = lt_selfields
         LT_WHERE = lt_role_where.
    if ld_no_selections = true.
      append lines of lt_role_where to lt_where.
    else.
      ls_where = '( '.
      insert ls_where into lt_where index 1.
      ls_where = ') and ('.
      append ls_where to lt_where.
      append lines of lt_role_where to lt_where.
      ls_where = ')'.
      append ls_where to lt_where.
    endif.
*...send message that selection criteria have been adapted
    message s223(wusl).
  endif.

ENDFORM.                    " ADAPT_SE16N_ROLE
