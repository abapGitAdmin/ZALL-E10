*----------------------------------------------------------------------*
***INCLUDE LSE16NF14.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OJKEY_SELECT_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OJKEY_SELECT_NEW .


  data: lt_add   like se16n_oj_add occurs 0.
  data: lt_addf  like se16n_oj_addf occurs 0.
  data: lt_dis   like se16n_oj_add_dis occurs 0.
  data: ls_grp    like se16n_output.
  data: ls_sum    like se16n_output.
  data: ls_add   like se16n_oj_add.
  data: ls_addf  like se16n_oj_addf.
  data: ls_dis   like se16n_oj_add_dis.
  data: ls_or_seltab type SE16N_OR_SELTAB.
  data: lt_buf_seltab like SE16N_SELTAB    occurs 0 with header line.
  data: lt_sel   like se16n_Seltab occurs 0 with header line.
  data: ls_sel   like se16n_Seltab.
  data: lt_grp_by    type se16n_output occurs 0.
  data: lt_sum_up    type se16n_output occurs 0.
  data: ld_field     like se16n_output.
  data: lt_skip_field like se16n_output occurs 0.
  data: ld_skip_field like se16n_output.
  data: ld_dbcnt_add  like sy-dbcnt.
  data: ld_count_name type fieldname.
  data: lt_where type se16n_where_132 occurs 0 with header line.
  data: descr   type ref to cl_abap_structdescr.
  data: descr_t type ref to cl_abap_tabledescr.
  data: cols    type cl_abap_structdescr=>component_table.
  data: col     like line of cols.
  data: begin of ls_ref,
          add_tab like se16n_oj_add-add_tab,
          dref    type ref to data,
          dref2   type ref to data,
        end of ls_ref.
  data: lt_ref like ls_ref occurs 0.
*.fields that need to be in <all_table>
  data: begin of ls_select,
          ref_tab   like se16n_oj_add-add_tab,
          field     type fieldname,
          org_field type fieldname,
        end of ls_select.
  data: lt_select like ls_select occurs 0.
  data: ld_dref   type ref to data.
  data: ld_skip(1).
  data: ld_name   like TFDIR-FUNCNAME.
  data: wa_fieldcat  type lvc_s_fcat.
  data: ld_countname type LVC_FNAME.
  data: ld_dbcnt     like sy-dbcnt.
  data: ld_view_name LIKE  DD25V-VIEWNAME.
  data: wa_index        like sy-tabix.
  data: ld_tabix        like sy-tabix.
  data: ld_addtab_index like sy-tabix.
  data: ld_add_lines    like sy-tabix.
  field-symbols: <l_wa>,
                 <append_table> type table.
  field-symbols: <fs>, <wa_add>, <fadd>, <s>, <wa_copy>, <wa_coll>,
                 <add_tab> type table,
                 <add_tab_collect> type table.

*..runtime analysis
  perform progress using '4'.

*..fill buffer for this outer join definition
  if gd-ojkey <> c_ojkey_generic_a and
     gd-ojkey <> c_ojkey_generic_b.
    select * from se16n_oj_add into table lt_add
             where oj_key   = gd-ojkey
               and prim_tab = gd-tab
             order by add_tab_order.
    select * from se16n_oj_addf into table lt_addf
             where oj_key   = gd-ojkey
               and prim_tab = gd-tab.
    select * from se16n_oj_add_dis into table lt_dis
             where oj_key   = gd-ojkey
               and prim_tab = gd-tab.
  else.
*.....global tables have been filled in create_fieldcat_standard
    lt_add[]  = gt_add[].
    lt_addf[] = gt_addf[].
    lt_dis[]  = gt_dis[].
*.....prepare additional selection criteria only once
    refresh: lt_buf_seltab.
    loop at gt_or_selfields into ls_or_seltab.
      append lines of ls_or_seltab-seltab to lt_buf_seltab.
    endloop.
    loop at gt_group_by_fields into ls_grp.
      delete lt_buf_seltab where field = ls_grp-field.
    endloop.
  endif.

*..create pointer for the field symbol tables
  loop at lt_add into ls_add.
*.....check authority for read access on the secondary table
    ld_view_name = ls_add-add_tab.
    CALL FUNCTION 'VIEW_AUTHORITY_CHECK'
      EXPORTING
        VIEW_ACTION                    = 'S'  "S=Show
        VIEW_NAME                      = ld_view_name
      EXCEPTIONS
        INVALID_ACTION                 = 1
        NO_AUTHORITY                   = 2
        NO_CLIENTINDEPENDENT_AUTHORITY = 3
        TABLE_NOT_FOUND                = 4
        NO_LINEDEPENDENT_AUTHORITY     = 5
        OTHERS                         = 6.
    IF SY-SUBRC NE 0 and
       sy-subrc ne 4.
      MESSAGE I108(wusl) with ld_view_name.
      delete table lt_add from ls_add.
      continue.
    ENDIF.
*.....generate additional field for count(*)
    if ls_add-add_tab_count = true and
       ls_add-add_tab_grp   = true.
*.........create field type i
      col-name = c_line_index.
      col-type ?= cl_abap_elemdescr=>get_i( ).
*.........get structure of ddic-tab
      descr ?= cl_abap_structdescr=>describe_by_name( ls_add-add_tab ).
      cols = descr->get_components( ).
*.........add additional field
      append col to cols.
*.........create new table definition
      CALL METHOD CL_ABAP_STRUCTDESCR=>CREATE
        EXPORTING
          P_COMPONENTS = cols
          P_STRICT     = abap_false
        RECEIVING
          P_RESULT     = descr.
*          descr = cl_abap_structdescr=>create( cols ).
      descr_t = cl_abap_tabledescr=>create( p_line_type = descr ).
      create data ld_dref type handle descr_t.
      ls_ref-add_tab = ls_add-add_tab.
      ls_ref-dref    = ld_dref.
      create data ld_dref type handle descr_t.
      ls_ref-dref2   = ld_dref.
      append ls_ref to lt_ref.
*.....normal generation of pointers
    else.
      create data ld_dRef type standard table of (ls_add-add_tab).
      ls_ref-add_tab = ls_add-add_tab.
      ls_ref-dref    = ld_dref.
      create data ld_dRef type standard table of (ls_add-add_tab).
      ls_ref-dref2   = ld_dref.
      append ls_ref to lt_ref.
    endif.
  endloop.

  ld_addtab_index = 0.
  describe table lt_add lines ld_add_lines.
  assign local copy of <all_table> to <append_table>.
  refresh <append_table>.
*..every line needs outer join selects on all secondary tables
  do ld_add_lines times.
    add 1 to ld_addtab_index.
    loop at <all_table> assigning <wa>.
      wa_index = sy-tabix.
*.....read one table after the other
      read table lt_add into ls_add index ld_addtab_index.
      if sy-subrc <> 0.
        exit.
      endif.
      refresh lt_sel.
      refresh: lt_skip_field.
*........get selection crteria for this secondary table
      loop at lt_addf into ls_addf
             where add_tab = ls_add-add_tab.
        clear ls_sel.
        if ls_addf-field_sign = space.
          ls_addf-field_sign = 'I'.
        endif.
        if ls_addf-field_option = space.
          ls_addf-field_option = 'EQ'.
        endif.
        case ls_addf-method.
*...................................................................
*..currently if selection on primary table is only done with field A
*..but the select on the secondary table is done with A and B, then B
*..is taken as EQ Space. --> Check against primary selection
*..if field is really there! If not, skip it
*....................................................................
          when c_meth-reference.
*...............name of field that needs to be selected
            ls_sel-field = ls_addf-field.
*...............check if field needs to be derived by primary tab
*...............If yes, it could be that the field is not selected,
*...............because the user did use grouping, but did not select
*...............this field. Then it would be wrong to group the
*...............dependent table.
*...............In that case skip it from being grouped for add-tab
            if ls_addf-ref_tab = gd-tab.
              if not gt_group_by_fields is initial or
                 not gt_sum_up_fields  is initial.
                read table gt_group_by_fields
*..........................field from reference table (primary tab)
                      with key field = ls_addf-value.
                if sy-subrc <> 0.
                  read table gt_sum_up_fields
*..........................field from reference table (primary tab)
                     with key field = ls_addf-value.
                  if sy-subrc <> 0.
*.................add-tab-field should not be used for grouping
                    ld_field-field = ls_sel-field.
                    append ld_field to lt_skip_field.
*                          continue.
                  endif.
                endif.
              endif.
            endif.
*...............Take over value even if the field does not exist
*...............and is blank!
            assign component ls_addf-value
                    of structure <wa> to <fs>.
            ls_sel-option = ls_addf-field_option.
            ls_sel-sign   = ls_addf-field_sign.
            ls_sel-low    = <fs>.
            append ls_sel to lt_sel.
          when c_meth-string.
*...............name of field that needs to be selected
            ls_sel-field  = ls_addf-field.
            ls_sel-option = ls_addf-field_option.
            ls_sel-sign   = ls_addf-field_sign.
*...............assign value of needed field
            assign component ls_addf-value
                    of structure <wa> to <fs>.
            ls_sel-low
               = <fs>+ls_addf-field_offset(ls_addf-field_length).
            append ls_sel to lt_sel.
          when c_meth-constant.
*...............name of field that needs to be selected
            ls_sel-field  = ls_addf-field.
            ls_sel-option = ls_addf-field_option.
            ls_sel-sign   = ls_addf-field_sign.
*...............Input has to be converted ??
            ls_sel-low    = ls_addf-value.
            append ls_sel to lt_sel.
          when c_meth-systemvar.
*...............name of field that needs to be selected
            ls_sel-field  = ls_addf-field.
            ls_sel-option = ls_addf-field_option.
            ls_sel-sign   = ls_addf-field_sign.
*...............get value of system variable
            assign (ls_addf-value) to <s>.
            if sy-subrc = 0.
              ls_sel-low    = <s>.
              append ls_sel to lt_sel.
            endif.
          when c_meth-variable.
*...............name of field that needs to be selected
            ls_sel-field = ls_addf-field.
*...............call generic function to get needed field filled
            ld_name = ls_addf-vari_object.
*..Currently the field is directly changed in <wa>
*..It has to be investigated if this should be done or if the changes
*..should be given back in an exporting field??
*..But with this approach also complex fields could be filled that cannot
*..be determined out of an add_tab.
            CALL FUNCTION 'RH_FUNCTION_EXIST'
              EXPORTING
                NAME               = ld_name
              EXCEPTIONS
                FUNCTION_NOT_FOUND = 1
                OTHERS             = 2.
            check: sy-subrc = 0.
            CALL FUNCTION ls_addf-vari_object
              EXPORTING
                i_out_field = ls_addf-field
              CHANGING
                workarea    = <wa>
              EXCEPTIONS
                OTHERS      = 1.
            check: sy-subrc = 0.
*...............content of field needed is now available
            assign component ls_addf-field
                             of structure <wa> to <fs>.
            if sy-subrc = 0.
              ls_sel-option = ls_addf-field_option.
              ls_sel-sign   = ls_addf-field_sign.
              ls_sel-low    = <fs>.
              append ls_sel to lt_sel.
            endif.
        endcase.
      endloop.
*........create generic table
      read table lt_ref into ls_ref
                 with key add_tab = ls_add-add_tab.
      assign ls_ref-dref->* to <add_tab>.
*........in case of selected group-by fieldlist
*........gt_fieldcat_grp contains all fields of all tables
      clear ld_count_name.
      refresh: lt_grp_by, lt_sum_up.
      if ls_add-add_tab_grp = true.
        loop at gt_fieldcat_grp into gs_fieldcat_grp
               where tabname = ls_add-add_tab.
*.............only if field is used.
*......gs_fieldcat_grp-fieldname always contains the real fieldname
*......of this field in add_tab
          read table lt_skip_field into ld_skip_field
               with key field = gs_fieldcat_grp-fieldname.
          check: sy-subrc <> 0.
          ld_field-field = gs_fieldcat_grp-fieldname.
          if gs_fieldcat_grp-datatype = 'CURR' or
             gs_fieldcat_grp-datatype = 'QUAN'.
            append ld_field to lt_sum_up.
          else.
            append ld_field to lt_grp_by.
          endif.
        endloop.
        if ls_add-add_tab_count = true.
          ld_count_name = c_line_index.
        endif.
      endif.
*........check if ALL fields for the select are really in lt_sel
*         clear ld_skip.
*         loop at lt_addf into ls_addf
*                where add_tab = ls_add-add_tab.
*            read table lt_sel with key field = ls_addf-field.
*            if sy-subrc <> 0.
*               ld_skip = true.
*            endif.
*         endloop.
*         check: ld_skip <> true.
*........in case of generic OJKEY add additional criteria
      if gd-ojkey = c_ojkey_generic_a or
         gd-ojkey = c_ojkey_generic_b.
        append lines of lt_buf_seltab to lt_sel.
      endif.
*........do the select for this line
      CALL FUNCTION 'SE16N_CREATE_SELECTION'
        EXPORTING
          I_TAB              = ls_add-add_tab
          I_DBCON            = ls_add-dbcon
*         I_MAX_LINES        = 500
          I_EXEC_STATEMENT   = 'X'
          I_COUNT_NAME       = ld_count_name
          I_ONLY_EXECUTE     = 'X'
        IMPORTING
          E_DBCNT            = ld_dbcnt_add
        TABLES
          IT_SEL             = lt_sel
          it_group_by_fields = lt_grp_by
          it_sum_up_fields   = lt_sum_up
        CHANGING
          ET_RESULT          = <add_tab>.
      check: sy-subrc = 0.
      describe table <add_tab> lines sy-dbcnt.
*.....if there is no dependent line found, keep original line
*.....except it should be an inner join
      if sy-dbcnt = 0 and ls_add-add_tab_ij <> true.
        append <wa> to <append_table>.
      endif.
      check: sy-dbcnt > 0.
      ld_dbcnt = sy-dbcnt.
*........normal case 1:1 or 1:N relation
      if sy-dbcnt = 1.
        loop at <add_tab> assigning <wa_add>.
          loop at gt_fieldcat_oj_2 into gs_fieldcat_oj_2
               where ref_tab = ls_add-add_tab.
*...............field content in <all_table>
            assign component gs_fieldcat_oj_2-field
                          of structure <wa> to <fs>.
*...............field content in secondary table
            assign component gs_fieldcat_oj_2-org_field
                          of structure <wa_add> to <fadd>.
            <fs> = <fadd>.
          endloop.
*.............add sy-dbcnt to special field
          if ls_add-add_tab_count = true.
            concatenate ls_add-add_tab '_' c_line_index
                into ld_countname.
            condense ld_countname.
            assign component ld_countname
                            of structure <wa> to <fs>.
            if ls_add-add_tab_grp = true.
              assign component c_line_index
                           of structure <wa_add> to <fadd>.
              if sy-subrc = 0.
                <fs> = <fadd>.
              endif.
            else.
              <fs> = 1.
            endif.
          endif.
        endloop.
        append <wa> to <append_table>.
*........1:N-relation means I need to duplicate all source items
      elseif sy-dbcnt > 1.
        assign local copy of <wa> to <l_wa>.
        loop at <add_tab> assigning <wa_coll>.
          ld_tabix = sy-tabix.
          loop at gt_fieldcat_oj_2 into gs_fieldcat_oj_2
               where ref_tab = ls_add-add_tab.
*...............field content in <all_table>
            assign component gs_fieldcat_oj_2-field
                          of structure <l_wa> to <fs>.
*...............field content in secondary table
            assign component gs_fieldcat_oj_2-org_field
                          of structure <wa_coll> to <fadd>.
            <fs> = <fadd>.
          endloop.
*.............add sy-dbcnt to special field
          if ls_add-add_tab_count = true.
            concatenate ls_add-add_tab '_' c_line_index
                into ld_countname.
            condense ld_countname.
            assign component ld_countname
                           of structure <l_wa> to <fs>.
            if sy-subrc = 0.
              <fs> = ld_dbcnt_add.
            endif.
          endif.
*.......append each found line with copied source fields to new table
          append <l_wa> to <append_table>.
        endloop.
      endif.
      refresh <add_tab>.
      unassign <add_tab>.
    endloop.     "from <all_table>
*..refresh source table
    refresh <all_table>.
*..fill source table with all duplicated lines to get the right
*..sequence per ADD-TAB
    append lines of <append_table> to <all_table>.
    refresh <append_table>.
  enddo.

ENDFORM.                    " OJKEY_SELECT_NEW
