*----------------------------------------------------------------------*
***INCLUDE LGTDISF20 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_TIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GD_START_TIME  text
*      <--P_GD_START_DATE  text
*----------------------------------------------------------------------*
FORM GET_TIME CHANGING TIME like sy-timlo
                       DATE like sy-datlo.

  get time.
  date = sy-datlo.
  time = sy-timlo.

ENDFORM.                               " GET_TIME

*&---------------------------------------------------------------------*
*&      Form  CREATE_SELTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_WHERE  text
*      -->P_IT_SELFIELDS  text
*----------------------------------------------------------------------*
FORM CREATE_SELTAB TABLES LT_WHERE
                          LT_SEL   STRUCTURE SE16N_SELTAB
                          lt_or
                   changing lt_and type se16n_and_t.

data: ld_join_active(1).

  if gd-txt_join_active = true or
     gd-oj_join_active  = true.
    ld_join_active = true.
  endif.

  if not lt_sel[] is initial.
    CALL FUNCTION 'SE16N_CREATE_SELTAB'
        EXPORTING
             i_pool   = gd-pool
             i_primary_table = true
             i_join_active   = ld_join_active
        TABLES
             LT_SEL   = lt_sel
             LT_WHERE = lt_where.
  elseif not lt_and[] is initial.
    CALL FUNCTION 'SE16N_CREATE_AND_SELTAB'
       EXPORTING
         i_pool       = gd-pool
         i_join_active = ld_join_active
       TABLES
         et_where     = lt_where
       CHANGING
         it_and_seltab = lt_and.
  else.
    CALL FUNCTION 'SE16N_CREATE_OR_SELTAB'
      EXPORTING
        i_pool             = gd-pool
        i_join_active      = ld_join_active
      TABLES
        IT_OR_SELTAB       = lt_or
        ET_WHERE           = lt_where.
  endif.

*.Store the selection criteria for refresh-button
  refresh gt_where.
  gt_where[] = lt_where[].

ENDFORM.                               " CREATE_SELTAB

*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDCAT_STANDARD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_OUTPUT_FIELDS  text
*      -->P_I_TAB  text
*----------------------------------------------------------------------*
FORM CREATE_FIELDCAT_STANDARD TABLES LT_OUTPUT STRUCTURE se16n_output
                              USING  value(LD_TAB)
                                     value(i_edit)
                                     value(i_tech_names)
                                     value(i_no_txt)
                                     value(i_clnt_spez)
                                     value(i_clnt_dep)
                                     value(ld_txt_tab).

  data: wa_fieldcat  type lvc_s_fcat.
  data: dy_fieldcat  type lvc_s_fcat.
  DATA: LT_DFIES     LIKE DFIES OCCURS 0 WITH HEADER LINE.
  data: ld_struc     LIKE DCOBJDEF-NAME.
  data: ld_lines     like sy-tabix.
  data: ld_tabix     like sy-tabix.
  data: ld_count     like sy-tabix.
  DATA: LD_99(1).
  data: ld_all_out(1).
  data: ld_buf(1).
  data: ld_curr_add(1).
  data: ld_quan_add(1).
  data: ldtab        type ref to data.
  data: ldkey        type ref to data.
  data: ldtab_del    type ref to data.
  data: ldtab_save   type ref to data.
  data: ldtab_cell   type ref to data.
  data: ls_dd04v_wa  like dd04v.
  data: lt_default_fieldcat type slis_t_fieldcat_alv,
        lt_variant_fieldcat type slis_t_fieldcat_alv,
        lt_sort          type  slis_t_sortinfo_alv,
        lt_filter        type  slis_t_filter_alv,
        i_layout         type  slis_layout_alv.
data: ld_tabname type DDOBJNAME.
data: ld_lfield  like dfies-lfieldname.
data: ls_dfies   like dfies.
data: lt_add    like se16n_oj_add occurs 0.
data: ls_add    like se16n_oj_add.
data: lt_addf   like se16n_oj_addf occurs 0.
data: ls_addf   like se16n_oj_addf.
data: ls_grp    like se16n_output.
data: ls_sum    like se16n_output.
data: ls_dis    like se16n_oj_add_dis.
data: lt_dis    like se16n_oj_add_dis occurs 0.
data: lt_disbuf like se16n_oj_add_dis occurs 0.
data: ls_varin  like se16n_oj_var_in.
data: ld_fieldname like dfies-lfieldname.
data: ld_oj_tab type tabname.
data: ld_len1   like sy-tabix.
data: ld_len2   like sy-tabix.
data: ld_view   like DD25V-VIEWNAME.
data: ls_dd02v  type dd02v.
data: lt_dd27p  like dd27p occurs 0 with header line.
data: ld_suffix type c.
constants: c_variable(10)  value 'VARIABLE',
           c_constant(10)  value 'CONSTANT',
           c_reference(10) value 'REFERENCE'.

*..Now fill the fieldcat, depending on the fields the user wants to see
  ld_struc = ld_tab.

*.If no output fields are given, take all -> otherwise nonsens
  describe table lt_output lines ld_lines.
  if ld_lines < 1.
     ld_all_out = true.
  endif.

  If sy-batch = true AND gd-variant IS NOT INITIAL.
    PERFORM fill_variant CHANGING gs_variant.
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
     EXPORTING
       I_STRUCTURE_NAME             = gd-tab
      CHANGING
        ct_fieldcat                  = lt_default_fieldcat
     EXCEPTIONS
       INCONSISTENT_INTERFACE       = 1
       PROGRAM_ERROR                = 2
       OTHERS                       = 3.
    IF sy-subrc = 0.
      CALL FUNCTION 'REUSE_ALV_VARIANT_SELECT'
          EXPORTING
            I_DIALOG            = 'N'
            I_USER_SPECIFIC     = 'X'
            IT_DEFAULT_FIELDCAT = lt_default_fieldcat
            I_LAYOUT            = i_layout
          IMPORTING
            ET_FIELDCAT         = lt_variant_fieldcat
            ET_SORT             = lt_sort
            ET_FILTER           = lt_filter
          CHANGING
            CS_VARIANT          = gs_variant
          EXCEPTIONS
            WRONG_INPUT         = 1
            FC_NOT_COMPLETE     = 2
            NOT_FOUND           = 3
            PROGRAM_ERROR       = 4
            OTHERS              = 5.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
            TABNAME   = LD_struc
       TABLES
            DFIES_TAB = LT_DFIES
       EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.

  check: sy-subrc = 0.

*.in case of views, some texts are not read by FIELDINFO_GET
  CALL FUNCTION 'DDIF_TABL_GET'
     EXPORTING
       NAME                = gd-tab
*      STATE               = 'A'
       LANGU               = sy-langu
     IMPORTING
*      GOTSTATE            =
       DD02V_WA            = ls_dd02v
     EXCEPTIONS
       ILLEGAL_INPUT       = 1
       OTHERS              = 2.
  if sy-subrc = 0 and
     ls_dd02v-tabclass = 'VIEW'.
     ld_view = gd-tab.
     CALL FUNCTION 'DD_VIEW_GET'
       EXPORTING
         view_name            = ld_view
         WITHTEXT             = 'X'
       TABLES
         DD27P_TAB_A          = lt_dd27p
       EXCEPTIONS
         ACCESS_FAILURE       = 1
         OTHERS               = 2.
     IF sy-subrc <> 0.
* Implement suitable error handling here
     ENDIF.
  endif.

  clear gd-keylen.
  CLEAR LD_99.
  refresh gt_fieldcat.
  loop at lt_dfies.
    ld_tabix = sy-tabix.
*...If sy-batch, I use ALV_Standard, only 99 columns are allowed
    if sy-batch = true.
      if gs_variant-variant IS NOT INITIAL.
        READ TABLE lt_variant_fieldcat with key fieldname = lt_dfies-fieldname
                                                no_out = ' '
                                        transporting no fields.
        IF sy-subrc = 0.
          add 1 TO ld_count.
        ELSE.
          CONTINUE.
        ENDIF.
        if ld_count > 98.
          ld_99 = true.
          exit.
        endif.
      else.
        if ld_all_out = true.
          add 1 to ld_count.
       else.
          read table lt_output with key field = lt_dfies-fieldname.
          if sy-subrc = 0.
             add 1 to ld_count.
          endif.
       endif.
       if ld_count > 98.
          ld_99 = true.
          exit.
        endif.
      endif.
    endif.
*    if sy-batch = true and
*       SY-TABIX > 98.  "98, because additional pos-field will be added
*       LD_99 = TRUE.
*       exit.
*    endif.
    clear wa_fieldcat.
*........Field should be displayed
    read table lt_output with key field = lt_dfies-fieldname.
    if sy-subrc = 0.
      wa_fieldcat-fieldname = lt_output-field.
      wa_fieldcat-ref_table = ld_tab.
      wa_fieldcat-ref_field = lt_output-field.
*........Field should not be displayed first
    else.
      if ld_all_out <> true.
         wa_fieldcat-no_out = true.
      endif.
      wa_fieldcat-fieldname = lt_dfies-fieldname.
      wa_fieldcat-ref_table = ld_tab.
      wa_fieldcat-ref_field = lt_dfies-fieldname.
    endif.
*..in case of group-by select do not use all fields
    if ( not gt_sum_up_fields[] is initial or
         not gt_group_by_fields[] is initial or
         not gt_aggregate_fields[] is initial ).
        read table gt_sum_up_fields with key
                 field = lt_dfies-fieldname.
        if sy-subrc <> 0.
            read table gt_group_by_fields with key
                  field = lt_dfies-fieldname.
            if sy-subrc <> 0.
               read table gt_aggregate_fields with key
                     field = lt_dfies-fieldname.
               if sy-subrc <> 0.
                  wa_fieldcat-no_out = true.
*...as a technical field, the fields would not be visible to
*..to the user in the layout dialog
*                 wa_fieldcat-tech   = true.
               endif.
            endif.
        endif.
    endif.
*...if selection is not client dependent, do not show client. But only
*...if table is really client dependent
    if i_clnt_spez       <> true  and
       ld_tabix          = 1      and
       lt_dfies-datatype = 'CLNT' and
       i_clnt_dep        = true.
          wa_fieldcat-no_out = true.
    endif.
    if lt_dfies-keyflag = true.
      wa_fieldcat-key     = true.
      wa_fieldcat-key_sel = true.
      if gd-edit = true.
        wa_fieldcat-edit    = true.
      else.
        wa_fieldcat-edit    = space.
      endif.
      gs_cell-fieldname = wa_fieldcat-fieldname.
      gs_cell-style     = cl_gui_alv_grid=>mc_style_disabled.
*           gs_cell-style     = cl_gui_alv_grid=>mc_style_enabled.
      insert gs_cell into table gt_cell.
    else.
*.....Offset of first non-key-field is the length of the key
      if gd-keylen is initial.
         gd-keylen = lt_dfies-offset.
      endif.
      if gd-edit = true.
        wa_fieldcat-edit    = true.
      else.
        wa_fieldcat-edit    = space.
      endif.
    endif.
*..columns with foreign key should be visible
   IF NOT LT_DFIES-CHECKTABLE = SPACE.
     WA_FIELDCAT-EMPHASIZE = 'C3'.
   ENDIF.

*...add foreign key for quan and curr only if table is the same
    if lt_dfies-reftable = ld_tab.
       case lt_dfies-datatype.
         when 'CURR'.
           wa_fieldcat-cfieldname = lt_dfies-reffield.
*..........in case of batch and variant, add reffield, note 2796176
           if sy-batch = true and gs_variant-variant is not initial.
*.............check if reffield is part of variant
              READ TABLE lt_variant_fieldcat
                        with key fieldname = lt_dfies-reffield
                                 no_out    = ' '
                        transporting no fields.
*.............no, it is not
              IF sy-subrc <> 0.
*................add it
                 read table lt_dfies into ls_dfies with key
                         fieldname = lt_dfies-reffield.
                 clear dy_fieldcat.
                 dy_fieldcat-fieldname = lt_dfies-reffield.
                 dy_fieldcat-ref_table = ld_tab.
                 dy_fieldcat-ref_field = lt_dfies-reffield.
                 dy_fieldcat-no_out    = true.
                 dy_fieldcat-edit      = space.
                 collect dy_fieldcat into gt_fieldcat.
                 add 1 TO ld_count.
              endif.
           endif.
         when 'QUAN'.
           wa_fieldcat-qfieldname = lt_dfies-reffield.
*..........in case of batch and variant, add reffield, note 2796176
           if sy-batch = true and gs_variant-variant is not initial.
*.............check if reffield is part of variant
              READ TABLE lt_variant_fieldcat
                        with key fieldname = lt_dfies-reffield
                                 no_out    = ' '
                        transporting no fields.
*.............no, it is not
              IF sy-subrc <> 0.
*................add it
                 read table lt_dfies into ls_dfies with key
                         fieldname = lt_dfies-reffield.
                 clear dy_fieldcat.
                 dy_fieldcat-fieldname = lt_dfies-reffield.
                 dy_fieldcat-ref_table = ld_tab.
                 dy_fieldcat-ref_field = lt_dfies-reffield.
                 dy_fieldcat-no_out    = true.
                 dy_fieldcat-edit      = space.
                 collect dy_fieldcat into gt_fieldcat.
                 add 1 TO ld_count.
              endif.
           endif.
       endcase.
    endif.

*...if column does not have a text, use fieldtext
    if lt_dfies-reptext   is initial and
       lt_dfies-scrtext_s is initial and
       lt_dfies-scrtext_m is initial and
       lt_dfies-scrtext_l is initial.
*......if the table is a view with tables with direct type input even
*......fieldtext could be empty
       if lt_dfies-fieldtext is initial.
          read table lt_dd27p with key viewfield = lt_dfies-fieldname.
          if sy-subrc = 0.
             lt_dfies-fieldtext = lt_dd27p-ddtext.
          else.
             lt_dfies-fieldtext = wa_fieldcat-fieldname.
          endif.
       endif.
       wa_fieldcat-coltext = lt_dfies-fieldtext.
    endif.
    if i_tech_names = true.
       wa_fieldcat-reptext   =
       wa_fieldcat-scrtext_s =
       wa_fieldcat-scrtext_m =
       wa_fieldcat-scrtext_l =
       wa_fieldcat-coltext   = wa_fieldcat-fieldname.
    endif.
    wa_fieldcat-convexit = lt_dfies-convexit.
*...check if user is not allowed for this column
    loop at gt_se16n_role_table into gs_se16n_role_table
          where ( tabname = gd-tab or
                  tabname = '*' )
            and fieldname = wa_fieldcat-fieldname.
    endloop.
    if sy-subrc <> 0.
       collect wa_fieldcat into gt_fieldcat.
    endif.
  endloop.
*.Save the key and the fields necessary for the table
  refresh: gt_fieldcat_key, gt_fieldcat_tab.
  loop at gt_fieldcat into wa_fieldcat.
     ld_tabix = sy-tabix.
     if wa_fieldcat-key = true.
        append wa_fieldcat to gt_fieldcat_key.
     endif.
     append wa_fieldcat to gt_fieldcat_tab.
*....in case of no check keys wanted
     if gd-checkkey = true.
        wa_fieldcat-checktable = '!'.
        modify gt_fieldcat from wa_fieldcat index ld_tabix.
     endif.
*....It is currently not possible to switch the convexit off. So fill
*....the conversion EMPTY into all convertable fields.
     if gd-no_convexit = true and
        wa_fieldcat-convexit <> space.
*.......this field will work in Basis 6.30!
        WA_FIELDCAT-NO_CONVEXT = 'X'.
        CLEAR WA_FIELDCAT-EDIT_MASK.
        WA_FIELDCAT-CONVEXIT = 'EMPTY'.
        MODIFY GT_FIELDCAT FROM WA_FIELDCAT INDEX LD_TABIX.
     endif.
  endloop.

*..If we have got a text table, fill text field
*..Now fill the fieldcat, depending on the fields the user wants to see
  IF I_NO_TXT <> TRUE AND
     LD_99    <> TRUE and
     ld_txt_tab <> space.
    ld_struc = ld_txt_tab.

    refresh: lt_dfies, gt_fieldcat_txttab, gt_fieldcat_txt_double.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING
            TABNAME   = LD_struc
       TABLES
            DFIES_TAB = LT_DFIES
       EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.

    if sy-subrc = 0.
     refresh gt_txt_fields.
     loop at lt_dfies.
       clear wa_fieldcat.
       if lt_dfies-keyflag <> true.
         gt_txt_fields-field = lt_dfies-fieldname.
         append gt_txt_fields.
*........Field should be displayed
         read table lt_output with key field = lt_dfies-fieldname.
         if sy-subrc = 0.
           wa_fieldcat-fieldname = lt_output-field.
           wa_fieldcat-ref_table = ld_txt_tab.
           wa_fieldcat-ref_field = lt_output-field.
*........Field should not be displayed first
         else.
           if ld_all_out <> true.
              wa_fieldcat-no_out = true.
           endif.
           wa_fieldcat-fieldname = lt_dfies-fieldname.
           wa_fieldcat-ref_table = ld_txt_tab.
           wa_fieldcat-ref_field = lt_dfies-fieldname.
         endif.
         if gd-edit = true.
           wa_fieldcat-edit    = true.
         else.
           wa_fieldcat-edit    = space.
         endif.
*........Only new fields
         read table gt_fieldcat into dy_fieldcat
                    with key fieldname = wa_fieldcat-fieldname.
         if sy-subrc <> 0.
            append wa_fieldcat to gt_fieldcat.
*........table has field with the same name!
         else.
*..........store relation between changed and orig field
           gs_fieldcat_txt_double-org_fieldname = wa_fieldcat-fieldname.
           concatenate '_' wa_fieldcat-fieldname into wa_fieldcat-fieldname.
           gs_fieldcat_txt_double-new_fieldname = wa_fieldcat-fieldname.
           append gs_fieldcat_txt_double to gt_fieldcat_txt_double.
           append wa_fieldcat to gt_fieldcat.
         endif.
       endif.
       move-corresponding lt_dfies to wa_fieldcat.
       if lt_dfies-keyflag = true.
          wa_fieldcat-key = true.
       else.
          wa_fieldcat-key = space.
       endif.
       append wa_fieldcat to gt_fieldcat_txttab.
     endloop.
    endif.
  endif.
************************************************************************

*..Outer Join Logic needs additional fields added to the output table
  if gd-ojkey <> space.
     refresh: gt_fieldcat_oj, gt_fieldcat_oj_2, gt_fieldcat_grp.
     clear: wa_fieldcat, gs_fieldcat_oj_2.
*....get all additional tables
     if gd-ojkey <> c_ojkey_generic_a and
        gd-ojkey <> c_ojkey_generic_b.
        select * from se16n_oj_add into table lt_add
                  where oj_key   = gd-ojkey
                    and prim_tab = gd-tab
                  order by ADD_TAB_ORDER.
*....for generic OJKEY fill table internally
     else.
*......this can only work if dbcon is filled and the other table
*......is on normal DB
*......In case of drilldown gd-j_dbcon could be filled
       if gd-dbcon <> space or
          gd-oj_dbcon <> space.
          clear ls_add.
          ls_add-oj_key        = gd-ojkey.
          ls_add-prim_tab      = gd-tab.
          ls_add-add_tab       = gd-tab.
          if gd-ojkey = c_ojkey_generic_b.
            if gd-dbcon <> space.
               ls_add-dbcon    = gd-dbcon.
               gd-oj_dbcon = gd-dbcon.
               clear gd-dbcon.
            else.
               ls_add-dbcon    = gd-oj_dbcon.
            endif.
          else.
            ls_add-dbcon       = space.
          endif.
          ls_add-add_tab_count = true.
          ls_add-add_tab_grp   = true.
          append ls_add to lt_add.
       endif.
       refresh gt_add.
       gt_add[] = lt_add[].
     endif.
     loop at lt_add into ls_add.
*.......get all fields that are needed for the select-conditions on the
*.......secondary tables. These fields could be from any of the tables
*.......in the OJKEY
       if gd-ojkey <> c_ojkey_generic_a and
          gd-ojkey <> c_ojkey_generic_b.
          select * from se16n_oj_addf into table lt_addf
                 where oj_key   = gd-ojkey
                   and prim_tab = gd-tab
                   and add_tab  = ls_add-add_tab
                   and double_field = space.
*......fill all fields that will be relevant for reference
       else.
          clear ls_addf.
          ls_addf-oj_key   = gd-ojkey.
          ls_addf-prim_tab = gd-tab.
          ls_addf-add_tab  = gd-tab.
*.........fill all fields that are grouping into reference
          loop at gt_group_by_fields into ls_grp.
            ls_addf-field   = ls_grp-field.
            ls_addf-method  = 'REFERENCE'.
            ls_addf-value   = ls_grp-field.
            ls_addf-ref_tab = gd-tab.
            append ls_addf to lt_addf.
          endloop.
          refresh gt_addf.
          gt_addf[] = lt_addf[].
       endif.
*............................................................
*...ls_addf contains the following information
*...primary table PRIM_TAB
*...secondary table ADD_TAB
*...name of field in secondary table FIELD
*...method to fill the field in secondary table METHOD
*...name of field in reference table VALUE
*...name of reference table REF_TAB
*............................................................
*..........always add selected add_tab-field
*           wa_fieldcat-fieldname = ls_addf-field.
*           wa_fieldcat-ref_table = ls_add-add_tab.
*           wa_fieldcat-ref_field = ls_addf-field.
*           read table gt_fieldcat
*                 with key fieldname = wa_fieldcat-fieldname
*                 transporting no fields.
*           if sy-subrc <> 0.
*              append wa_fieldcat to gt_fieldcat.
*              collect wa_fieldcat into gt_fieldcat_oj.
*           endif.
        loop at lt_addf into ls_addf.
           case ls_addf-method.
             when c_meth-reference.
*............table is stored in extra field in addf !
               if ls_addf-ref_tab <> space.
                 wa_fieldcat-fieldname = ls_addf-field.
*                 wa_fieldcat-ref_table = ls_addf-ref_tab.
*                 wa_fieldcat-ref_field = ls_addf-value.
                 wa_fieldcat-ref_table = ls_addf-add_tab.
                 wa_fieldcat-ref_field = ls_addf-field.
                 wa_fieldcat-tabname   = ls_add-add_tab.
                 read table gt_fieldcat
                       with key fieldname = wa_fieldcat-fieldname
                       transporting no fields.
                 if sy-subrc <> 0.
                    if i_tech_names = true.
                       wa_fieldcat-reptext   =
                       wa_fieldcat-scrtext_s =
                       wa_fieldcat-scrtext_m =
                       wa_fieldcat-scrtext_l =
                       wa_fieldcat-coltext   = wa_fieldcat-fieldname.
                    endif.
                    append wa_fieldcat to gt_fieldcat.
                    collect wa_fieldcat into gt_fieldcat_oj.
                 endif.
                 collect wa_fieldcat into gt_fieldcat_grp.
               endif.
             when c_meth-string.
               if ls_addf-ref_tab <> space.
                 wa_fieldcat-fieldname = ls_addf-field.
                 wa_fieldcat-ref_table = ls_addf-add_tab.
                 wa_fieldcat-ref_field = ls_addf-field.
*                 wa_fieldcat-ref_table = ls_addf-ref_tab.
*                 wa_fieldcat-ref_field = ls_addf-value.
                 wa_fieldcat-tabname   = ls_add-add_tab.
                 read table gt_fieldcat
                       with key fieldname = wa_fieldcat-fieldname
                       transporting no fields.
                 if sy-subrc <> 0.
                    if i_tech_names = true.
                       wa_fieldcat-reptext   =
                       wa_fieldcat-scrtext_s =
                       wa_fieldcat-scrtext_m =
                       wa_fieldcat-scrtext_l =
                       wa_fieldcat-coltext   = wa_fieldcat-fieldname.
                    endif.
                    append wa_fieldcat to gt_fieldcat.
                    collect wa_fieldcat into gt_fieldcat_oj.
                 endif.
                 collect wa_fieldcat into gt_fieldcat_grp.
               endif.
             when c_meth-variable.
*............always add selected add_tab-field
               wa_fieldcat-fieldname = ls_addf-field.
               wa_fieldcat-ref_table = ls_add-add_tab.
               wa_fieldcat-ref_field = ls_addf-field.
               wa_fieldcat-tabname   = ls_add-add_tab.
               read table gt_fieldcat
                     with key fieldname = wa_fieldcat-fieldname
                     transporting no fields.
               if sy-subrc <> 0.
                  if i_tech_names = true.
                     wa_fieldcat-reptext   =
                     wa_fieldcat-scrtext_s =
                     wa_fieldcat-scrtext_m =
                     wa_fieldcat-scrtext_l =
                     wa_fieldcat-coltext   = wa_fieldcat-fieldname.
                  endif.
                  append wa_fieldcat to gt_fieldcat.
                  collect wa_fieldcat into gt_fieldcat_oj.
               endif.
               collect wa_fieldcat into gt_fieldcat_grp.
*..............determine which fields are needed for the variables
               select * from se16n_oj_var_in into ls_varin
                  where vari_object = ls_addf-vari_object.
                 wa_fieldcat-fieldname = ls_varin-field.
                 wa_fieldcat-ref_table = ls_varin-ref_tab.
                 wa_fieldcat-ref_field = ls_varin-field.
                 wa_fieldcat-tabname   = ls_add-add_tab.
                 read table gt_fieldcat
                       with key fieldname = wa_fieldcat-fieldname
                       transporting no fields.
                 if sy-subrc <> 0.
                    if i_tech_names = true.
                       wa_fieldcat-reptext   =
                       wa_fieldcat-scrtext_s =
                       wa_fieldcat-scrtext_m =
                       wa_fieldcat-scrtext_l =
                       wa_fieldcat-coltext   = wa_fieldcat-fieldname.
                    endif.
                    append wa_fieldcat to gt_fieldcat.
                    collect wa_fieldcat into gt_fieldcat_oj.
                 endif.
*......only add field to grouping if it exists for this table
                 ld_fieldname = ls_varin-field.
                 CALL FUNCTION 'DDIF_FIELDINFO_GET'
                   EXPORTING
                     TABNAME              = ls_add-add_tab
                     LFIELDNAME           = ld_fieldname
                   EXCEPTIONS
                     NOT_FOUND            = 1
                     INTERNAL_ERROR       = 2
                     OTHERS               = 3.
                 IF SY-SUBRC = 0.
                    collect wa_fieldcat into gt_fieldcat_grp.
                 ENDIF.
               endselect.
             endcase.
        endloop.
*.......display fields
        if gd-ojkey <> c_ojkey_generic_a and
           gd-ojkey <> c_ojkey_generic_b.
           select * from se16n_oj_add_dis into table lt_dis
                  where oj_key   = gd-ojkey
                    and prim_tab = gd-tab
                    and add_tab  = ls_add-add_tab.
*......fill all fields that will be relevant for reference
        else.
          clear ls_dis.
          ls_dis-oj_key   = gd-ojkey.
          ls_dis-prim_tab = gd-tab.
          ls_dis-add_tab  = gd-tab.
*.........fill all fields that are grouping in to reference
          loop at gt_sum_up_fields into ls_sum.
            ls_dis-fieldname = ls_sum-field.
            append ls_dis to lt_dis.
          endloop.
          refresh gt_dis.
          gt_dis[] = lt_dis[].
        endif.
        loop at lt_dis into ls_dis.
           wa_fieldcat-fieldname = ls_dis-fieldname.
           wa_fieldcat-ref_table = ls_add-add_tab.
           wa_fieldcat-ref_field = ls_dis-fieldname.
           wa_fieldcat-tabname   = ls_add-add_tab.
           collect wa_fieldcat into gt_fieldcat_grp.
           read table gt_fieldcat into dy_fieldcat
                   with key fieldname = wa_fieldcat-fieldname.
           if sy-subrc <> 0.
              if i_tech_names = true.
                 wa_fieldcat-reptext   =
                 wa_fieldcat-scrtext_s =
                 wa_fieldcat-scrtext_m =
                 wa_fieldcat-scrtext_l =
                 wa_fieldcat-coltext   = wa_fieldcat-fieldname.
              endif.
              append wa_fieldcat to gt_fieldcat.
              collect wa_fieldcat into gt_fieldcat_oj.
**................field already exists - add tab in front
           else.
*.............field could have been added by this add_tab due
*.............to method variable. In that case do not create
*.............new field
            if dy_fieldcat-tabname <> ls_add-add_tab.
              clear wa_fieldcat-fieldname.
              ld_len1 = strlen( ls_add-add_tab ).
              ld_len2 = strlen( ls_dis-fieldname ).
*.............if length is short enough take this
              if ld_len1 + ld_len2 <= 30.
                 concatenate ls_add-add_tab '_' ls_dis-fieldname
                     into wa_fieldcat-fieldname.
                 condense wa_fieldcat-fieldname.
                 if i_tech_names = true.
                    wa_fieldcat-reptext   =
                    wa_fieldcat-scrtext_s =
                    wa_fieldcat-scrtext_m =
                    wa_fieldcat-scrtext_l =
                    wa_fieldcat-coltext   = wa_fieldcat-fieldname.
                 endif.
                 append wa_fieldcat to gt_fieldcat.
                 clear gs_fieldcat_oj_2.
                 gs_fieldcat_oj_2-field = wa_fieldcat-fieldname.
                 gs_fieldcat_oj_2-ref_tab   = ls_add-add_tab.
                 gs_fieldcat_oj_2-org_field = ls_dis-fieldname.
                 collect gs_fieldcat_oj_2 into gt_fieldcat_oj_2.
              else.
*.............try to add number at the end
                 ld_suffix = 1.
                 do.
                   clear wa_fieldcat-fieldname.
                   concatenate ls_dis-fieldname ld_suffix
                        into wa_fieldcat-fieldname.
                   condense wa_fieldcat-fieldname.
                   read table gt_fieldcat
                        with key fieldname = wa_fieldcat-fieldname
                        transporting no fields.
                   if sy-subrc <> 0.
                      if i_tech_names = true.
                         wa_fieldcat-reptext   =
                         wa_fieldcat-scrtext_s =
                         wa_fieldcat-scrtext_m =
                         wa_fieldcat-scrtext_l =
                         wa_fieldcat-coltext   = wa_fieldcat-fieldname.
                      endif.
                      append wa_fieldcat to gt_fieldcat.
                      clear gs_fieldcat_oj_2.
                      gs_fieldcat_oj_2-field  = wa_fieldcat-fieldname.
                      gs_fieldcat_oj_2-ref_tab   = ls_add-add_tab.
                      gs_fieldcat_oj_2-org_field = ls_dis-fieldname.
                      collect gs_fieldcat_oj_2 into gt_fieldcat_oj_2.
                      exit.
                   else.
                      add 1 to ld_suffix.
                      if ld_suffix > 8.
                         exit.
                      endif.
                   endif.
                 enddo.
              endif.
            elseif gd-tab = ls_add-add_tab.
*...........very special case, add_tab = gd-tab (for conistency checks)
*...........add same field with suffix
              ld_suffix = 1.
              do.
                clear wa_fieldcat-fieldname.
                concatenate ls_dis-fieldname ld_suffix
                     into wa_fieldcat-fieldname.
                condense wa_fieldcat-fieldname.
                read table gt_fieldcat
                     with key fieldname = wa_fieldcat-fieldname
                     transporting no fields.
                if sy-subrc <> 0.
                   if i_tech_names = true.
                      wa_fieldcat-reptext   =
                      wa_fieldcat-scrtext_s =
                      wa_fieldcat-scrtext_m =
                      wa_fieldcat-scrtext_l =
                      wa_fieldcat-coltext   = wa_fieldcat-fieldname.
                   endif.
                   append wa_fieldcat to gt_fieldcat.
                   clear gs_fieldcat_oj_2.
                   gs_fieldcat_oj_2-field   = wa_fieldcat-fieldname.
                   gs_fieldcat_oj_2-ref_tab   = ls_add-add_tab.
                   gs_fieldcat_oj_2-org_field = ls_dis-fieldname.
                   collect gs_fieldcat_oj_2 into gt_fieldcat_oj_2.
                   exit.
                else.
                   add 1 to ld_suffix.
                   if ld_suffix > 8.
                      exit.
                   endif.
                endif.
              enddo.
            endif.
           endif.
        endloop.
        append lines of lt_dis to lt_disbuf.
     endloop.
*....gt_fieldcat_oj_2 contains the logic which field is named how
     loop at gt_fieldcat_oj into wa_fieldcat.
        clear gs_fieldcat_oj_2.
        gs_fieldcat_oj_2-field     = wa_fieldcat-fieldname.
        gs_fieldcat_oj_2-ref_tab   = wa_fieldcat-tabname.
        gs_fieldcat_oj_2-org_field = wa_fieldcat-fieldname.
        collect gs_fieldcat_oj_2 into gt_fieldcat_oj_2.
     endloop.
*....get aggregation
     loop at gt_fieldcat_oj_2 into gs_fieldcat_oj_2.
        ld_tabix = sy-tabix.
        read table lt_disbuf into ls_dis
                with key add_tab   = gs_fieldcat_oj_2-ref_tab
                         fieldname = gs_fieldcat_oj_2-org_field.
        if sy-subrc = 0 and
           ls_dis-aggregate <> space.
           gs_fieldcat_oj_2-aggregate = ls_dis-aggregate.
           modify gt_fieldcat_oj_2 from gs_fieldcat_oj_2
                index ld_tabix.
        endif.
     endloop.
     refresh lt_disbuf.

*....enhance gt_fieldcat_grp by datatype for group by select
     loop at gt_fieldcat_grp into wa_fieldcat.
       ld_tabix = sy-tabix.
       ld_tabname = wa_fieldcat-ref_table.
       ld_lfield  = wa_fieldcat-fieldname.
       CALL FUNCTION 'DDIF_FIELDINFO_GET'
         EXPORTING
           TABNAME              = ld_tabname
           LFIELDNAME           = ld_lfield
         IMPORTING
           DFIES_WA             = ls_dfies
         EXCEPTIONS
           NOT_FOUND            = 1
           INTERNAL_ERROR       = 2
           OTHERS               = 3.
       IF SY-SUBRC = 0.
          wa_fieldcat-datatype = ls_dfies-datatype.
          modify gt_fieldcat_grp from wa_fieldcat index ld_tabix.
       ENDIF.
     endloop.
*....field TABNAME in GT_FIELDCAT is now not needed anymore, but avoids
*....correct download to textfile
     loop at gt_fieldcat into wa_fieldcat.
        clear wa_fieldcat-tabname.
        modify gt_fieldcat from wa_fieldcat.
     endloop.
  endif.

*..Special field to know which line is which line. When I delete a line
*..than it is not in <all_table> anymore, so I have to know which line
*..it has been.
  clear wa_fieldcat.
*.with group by use this field to store the number of merged lines
  if not gt_sum_up_fields[] is initial or
     not gt_group_by_fields[] is initial.
     wa_fieldcat-ref_table = 'SE16N_REF'.
     wa_fieldcat-ref_field = 'SE16N_LONG_LINES'.
  else.
     wa_fieldcat-tech      = true.
     wa_fieldcat-no_out    = true.
     wa_fieldcat-ref_table = 'SE16N_REF'.
     wa_fieldcat-ref_field = 'SE16N_LONG_LINES'.
  endif.
  wa_fieldcat-fieldname = c_line_index.
  if i_tech_names = true.
     wa_fieldcat-reptext   =
     wa_fieldcat-scrtext_s =
     wa_fieldcat-scrtext_m =
     wa_fieldcat-scrtext_l =
     wa_fieldcat-coltext   = wa_fieldcat-fieldname.
  endif.
  collect wa_fieldcat into gt_fieldcat.

*.......check if additional line-count fields are needed
  CALL FUNCTION 'DDIF_DTEL_GET'
    EXPORTING
      NAME                = 'SE16N_LONG_LINES'
*     STATE               = 'A'
      LANGU               = sy-langu
    IMPORTING
*     GOTSTATE            =
      DD04V_WA            = ls_dd04v_wa
*     TPARA_WA            =
    EXCEPTIONS
      ILLEGAL_INPUT       = 1
      OTHERS              = 2.

  IF SY-SUBRC <> 0.
     clear ls_dd04v_wa-reptext.
  ENDIF.

  loop at lt_add into ls_add.
     clear wa_fieldcat.
     if ls_add-add_tab_count = true.
        concatenate ls_add-add_tab '_' c_line_index
                into wa_fieldcat-fieldname.
        condense wa_fieldcat-fieldname.
        wa_fieldcat-ref_table = 'SE16N_REF'.
        wa_fieldcat-ref_field = 'SE16N_LONG_LINES'.
        if i_tech_names = true.
          wa_fieldcat-reptext   =
          wa_fieldcat-scrtext_s =
          wa_fieldcat-scrtext_m =
          wa_fieldcat-scrtext_l =
          wa_fieldcat-coltext   = wa_fieldcat-fieldname.
        else.
*.........add name of table to text to distinguish the columns
          concatenate ls_dd04v_wa-reptext ls_add-add_tab
               into wa_fieldcat-reptext separated by space.
        endif.
        append wa_fieldcat to gt_fieldcat.
     endif.
  endloop.

*..Special field to be able to count the number of displayed lines
  if gd-count_lines = true.
     clear wa_fieldcat.
     wa_fieldcat-tech      = true.
     wa_fieldcat-fieldname = c_count_index.
     wa_fieldcat-ref_table = 'SE16N_REF'.
     wa_fieldcat-ref_field = 'SE16N_LONG_LINES'.
     collect wa_fieldcat into gt_fieldcat.
  endif.
*..Additional sort field, but only if no edit activated
  if gd-sortfield = true and
     gd-edit      <> true.
     clear wa_fieldcat.
     wa_fieldcat-edit      = true.
     wa_fieldcat-fieldname = c_sort_index.
     wa_fieldcat-ref_table = 'T811S'.
     wa_fieldcat-ref_field = 'SORTFIELD'.
     collect wa_fieldcat into gt_fieldcat.
  endif.

*..Special field to summarize the value of CURR fields
  clear: ld_curr_add, ld_quan_add.
  if not gt_add_up_curr_fields[] is initial.
     ld_curr_add = true.
     clear wa_fieldcat.
     wa_fieldcat-fieldname = c_total_curr_value.
     wa_fieldcat-ref_table = 'SE16N_SELFIELDS'.
     wa_fieldcat-ref_field = 'CURR_ADD_UP_REF'.
     collect wa_fieldcat into gt_fieldcat.
  endif.
*..Special field to summarize the value of QUAN fields
  if not gt_add_up_quan_fields[] is initial.
     ld_quan_add = true.
     clear wa_fieldcat.
     wa_fieldcat-fieldname = c_total_quan_value.
     wa_fieldcat-ref_table = 'SE16N_SELFIELDS'.
     wa_fieldcat-ref_field = 'QUAN_ADD_UP_REF'.
     collect wa_fieldcat into gt_fieldcat.
  endif.

*.add fields for formula
  perform formula_add_fields.

*.adapt column position according grouping order
  if not gt_sortorder_fields[] is initial.
    loop at gt_sortorder_fields.
      read table gt_fieldcat into wa_fieldcat
            with key fieldname = gt_sortorder_fields-field.
      if sy-subrc = 0.
        ld_tabix = sy-tabix.
        wa_fieldcat-col_pos = gt_sortorder_fields-low.
        MODIFY GT_FIELDCAT FROM WA_FIELDCAT INDEX LD_TABIX.
      endif.
    endloop.
*...all other fields get the same col_pos to retain the order
    wa_fieldcat-col_pos = 98.
    modify gt_fieldcat from wa_fieldcat
           transporting col_pos where col_pos is initial.
  endif.

*..consider exit to add additional fields
  if gd-add_fields_on = true.
     perform check_exit using c_event_add_fields
                              c_add_info_add_fcat
                              gd-tab
                      changing gd_dref.
  endif.

*.exit for external caller
  if gd-ext_call = true.
     perform external_exit using c_ext_event_fcat
                           changing gd-exit_done.
  endif.

*..get the number of columns included in <all_table>. For the move from
*..<all_table> to <all_table_cell>.
  describe table gt_fieldcat lines gd_lines.

*.look in global buffer if the data ref's are already created
  read table gt_ref with key tab         = ld_tab
                             txt_tab     = ld_txt_tab
                             curr_add    = ld_curr_add
                             quan_add    = ld_quan_add
                             count_lines = gd-count_lines
                             sort_field  = gd-sortfield
                             add_field   = gd-add_field
                             ojkey       = gd-ojkey
                             formula     = gd-formula_name
                             sum_up      = gt_sum_up_fields[].
  if sy-subrc = 0.
     ld_buf = true.
  else.
     ld_buf = false.
     clear gt_ref.
     gt_ref-tab     = ld_tab.
     if i_no_txt <> true.
        gt_ref-txt_tab = ld_txt_tab.
     endif.
     gt_ref-curr_add    = ld_curr_add.
     gt_ref-quan_add    = ld_quan_add.
     gt_ref-count_lines = gd-count_lines.
     gt_ref-sort_field  = gd-sortfield.
     gt_ref-add_field   = gd-add_field.
     gt_ref-ojkey       = gd-ojkey.
     gt_ref-formula     = gd-formula_name.
     gt_ref-sum_up      = gt_sum_up_fields[].
  endif.

*..Now create the generic structure of <all_table*>
  if gd-edit = true.
    if ld_buf <> true or
       gt_ref-dcell is initial.
       call method cl_alv_table_create=>create_dynamic_table
                          exporting it_fieldcatalog = gt_fieldcat
                                    I_STYLE_TABLE   = true
                          importing ep_table        = ldtab_cell
                                    e_style_fname   = gd_style_fname
                          exceptions GENERATE_SUBPOOL_DIR_FULL = 9.
       if sy-subrc = 9.
          message i122(wusl).
          leave to transaction sy-tcode.
       endif.
       gt_ref-dcell = ldtab_cell.
    else.
       ldtab_cell = gt_ref-dcell.
    endif.
    assign ldtab_cell->* to <all_table_cell>.
    refresh <all_table_cell>.
*...When user changes a line I want to write change documents. There-
*...for I need to store the original line
    if ld_buf <> true or
       gt_ref-dsave is initial.
       call method cl_alv_table_create=>create_dynamic_table
                          exporting it_fieldcatalog = gt_fieldcat
                                    I_STYLE_TABLE   = true
                          importing ep_table        = ldtab_save
                          exceptions GENERATE_SUBPOOL_DIR_FULL = 9.
       if sy-subrc = 9.
          message i122(wusl).
          leave to transaction sy-tcode.
       endif.
       gt_ref-dsave = ldtab_save.
    else.
       ldtab_save = gt_ref-dsave.
    endif.
    assign ldtab_save->* to <all_table_save>.
    refresh <all_table_save>.
  endif.
  if ld_buf <> true or
     gt_ref-dall is initial.
     call method cl_alv_table_create=>create_dynamic_table
                           exporting it_fieldcatalog = gt_fieldcat
                           importing ep_table        = ldtab
                           exceptions GENERATE_SUBPOOL_DIR_FULL = 9.
       if sy-subrc = 9.
          message i122(wusl).
          leave to transaction sy-tcode.
       endif.
       gt_ref-dall = ldtab.
  else.
     ldtab = gt_ref-dall.
  endif.
  assign ldtab->* to <all_table>.
  refresh <all_table>.
  gd_dref = ldtab.

*..I need to store the deleted lines in a separat table
  if gd-edit = true.
    if ld_buf <> true or
       gt_ref-ddel is initial.
       call method cl_alv_table_create=>create_dynamic_table
                          exporting it_fieldcatalog = gt_fieldcat
                          importing ep_table        = ldtab_del
                          exceptions GENERATE_SUBPOOL_DIR_FULL = 9.
       if sy-subrc = 9.
          message i122(wusl).
          leave to transaction sy-tcode.
       endif.
       gt_ref-ddel = ldtab_del.
    else.
       ldtab_del = gt_ref-ddel.
    endif.
    assign ldtab_del->* to <del_table>.
    refresh <del_table>.
*...create structure of key, for database locks
    if ld_buf <> true or
       gt_ref-dkey is initial.
       call method cl_alv_table_create=>create_dynamic_table
                          exporting it_fieldcatalog = gt_fieldcat_key
                          importing ep_table        = ldkey
                          exceptions GENERATE_SUBPOOL_DIR_FULL = 9.
       if sy-subrc = 9.
          message i122(wusl).
          leave to transaction sy-tcode.
       endif.
       gt_ref-dkey = ldkey.
    else.
       ldkey = gt_ref-dkey.
    endif.
    assign ldkey->* to <key_table>.
    refresh <key_table>.
  endif.
  if ld_buf <> true.
     append gt_ref.
  endif.

*.very special exit for FI-CA. It is active if an entry in table
*.SE16N_EXIT exists
  DATA: LS_SE16N_EXIT TYPE SE16N_EXIT.

  IF GD-EDIT = TRUE.
    SELECT SINGLE * FROM SE16N_EXIT INTO LS_SE16N_EXIT
         WHERE TAB            = '*'
           AND CALLBACK_EVENT = C_EVENT_FICA_ACTIVE.
    IF SY-SUBRC = 0.
      GD-FICA_AUDIT = TRUE.
    ENDIF.

    IF GD-FICA_AUDIT = TRUE.
       PERFORM CHECK_EXIT USING C_EVENT_FICA_LOCK
                              SPACE
                              GD-TAB
                          CHANGING GD_DREF.
    ENDIF.
  ENDIF.

ENDFORM.                               " CREATE_FIELDCAT_STANDARD

*&---------------------------------------------------------------------*
*&      Form  SELECT_STANDARD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_WHERE  text
*      -->P_I_TAB  text
*      <--P_LD_SUBRC  text
*----------------------------------------------------------------------*
FORM SELECT_STANDARD TABLES   LT_WHERE
                     USING    value(TAB)
                              value(i_max_lines)
                              value(i_line_det)
                              value(i_display_all)
                              value(i_clnt_spez)
                     changing value(subrc)
                              value(abort).

  data: field      type string,
        t_field    type table of string,
        t_order_by type table of string,
        t_group_by type table of string.
  data: ld_hint(255) type c.

*.new centralized select
  PERFORM SELECT_STANDARD_NEW TABLES   LT_WHERE
                              USING    TAB
                                       i_max_lines
                                       i_line_det
                                       i_display_all
                                       i_clnt_spez
                              changing subrc
                                       abort.
  exit.

  refresh <all_table>.

***************************************************************
*.Four cases possible
*.1. normal select on normal database
*.2. group-by select on normal database
*.3. normal select on alternate database
*.4. group-by select on alternate database
***************************************************************

*.normal DB******************************************************
  if gd-dbcon = space.
    loop at gt_order_by_fields.
*.....in case special sorting is requested, add it.
      read table gt_toplow_fields
             with key field = gt_order_by_fields-field.
      if sy-subrc = 0.
         if gt_toplow_fields-low = 'ASC'.
            concatenate gt_toplow_fields-low 'ENDING'
                   into gt_toplow_fields-low.
         else.
            concatenate gt_toplow_fields-low 'CENDING'
                   into gt_toplow_fields-low.
         endif.
         concatenate gt_order_by_fields-field gt_toplow_fields-low
                   into gt_order_by_fields-field separated by space.
      endif.
      append gt_order_by_fields-field to t_order_by.
    endloop.
    if not gt_sum_up_fields[] is initial or
       not gt_group_by_fields[] is initial or
       not gt_aggregate_fields[] is initial.
*.....new group-by select
      loop at gt_group_by_fields.
        append gt_group_by_fields-field to t_group_by.
        append gt_group_by_fields-field to t_field.
      endloop.
      loop at gt_sum_up_fields.
        field =
  |SUM( { gt_sum_up_fields-field } ) as { gt_sum_up_fields-field } |.
        append field to t_field.
      endloop.
      loop at gt_aggregate_fields.
        concatenate gt_aggregate_fields-low '(' into field.
        concatenate field gt_aggregate_fields-field ') as'
                     gt_aggregate_fields-field into field
                     separated by space.
        append field to t_field.
      endloop.
      field = |COUNT( * ) as { c_line_index } |.
      append field to t_field.
*...if no grouping select all fields
    else.
      field = '*'.
      append field to t_field.
    endif.
      if i_line_det <> true.
        if i_display_all = space.
          if i_clnt_spez = true.
            gd-select_type = 'A'.
            SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED
                up to i_max_lines rows
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          else.
            gd-select_type = 'B'.
            SELECT (t_field) FROM (tab) up to i_max_lines rows
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          endif.
*.......If no display, select everything
        else.
          if i_clnt_spez = true.
            gd-select_type = 'C'.
            SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          else.
            gd-select_type = 'D'.
            SELECT (t_field) FROM (tab)
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          endif.
        endif.
        if gt_order_by_fields[] is initial.
           sort <all_table>.
        endif.
*.Only determine the number of found entries
      else.
        if i_clnt_spez = true.
          gd-select_type = 'E'.
          SELECT count(*) FROM (tab)
               CLIENT SPECIFIED
               bypassing buffer
               WHERE (lt_where).
        else.
          gd-select_type = 'F'.
          SELECT count(*) FROM (tab)
               bypassing buffer
               WHERE (lt_where).
        endif.
      endif.
*.alternate DB******************************************************
  else.
    loop at gt_order_by_fields.
*.....in case special sorting is requested, add it.
      read table gt_toplow_fields
             with key field = gt_order_by_fields-field.
      if sy-subrc = 0.
         if gt_toplow_fields-low = 'ASC'.
            concatenate gt_toplow_fields-low 'ENDING'
                   into gt_toplow_fields-low.
         else.
            concatenate gt_toplow_fields-low 'CENDING'
                   into gt_toplow_fields-low.
         endif.
         concatenate gt_order_by_fields-field gt_toplow_fields-low
                   into gt_order_by_fields-field separated by space.
      endif.
      append gt_order_by_fields-field to t_order_by.
    endloop.
*...Group-by select**********************************************
    if not gt_sum_up_fields[] is initial or
       not gt_group_by_fields[] is initial or
       not gt_aggregate_fields[] is initial.
*......new group-by select
      loop at gt_group_by_fields.
        append gt_group_by_fields-field to t_group_by.
        append gt_group_by_fields-field to t_field.
      endloop.
      loop at gt_sum_up_fields.
        field =
  |SUM( { gt_sum_up_fields-field } ) as { gt_sum_up_fields-field } |.
        append field to t_field.
      endloop.
      loop at gt_aggregate_fields.
        concatenate gt_aggregate_fields-low '(' into field.
        concatenate field gt_aggregate_fields-field ') as'
                     gt_aggregate_fields-field into field
                     separated by space.
        append field to t_field.
      endloop.
      field = |COUNT( * ) as { c_line_index } |.
      append field to t_field.
*...if no grouping select all fields
    else.
      field = '*'.
      append field to t_field.
    endif.
      if i_line_det <> true.
        if i_display_all = space.
          if i_clnt_spez = true.
            gd-select_type = 'K'.
*...........in case of summation use parallel aggregation
            if gt_sum_up_fields[] is initial.
              SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED connection (gd-dbcon)
                up to i_max_lines rows
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
            else.
              SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED connection (gd-dbcon)
                up to i_max_lines rows
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by)
                %_HINTS ADABAS 'dbsl_add_stmt with parameters ' &
                       '(''request_flags''=''ANALYZE_MODEL'', ' &
                       '''request_flags''=''OLAP_PARALLEL_AGGREGATION'')'.
            endif.
          else.
            gd-select_type = 'L'.
*...........in case of summation use parallel aggregation
            if gt_sum_up_fields[] is initial.
              SELECT (t_field) FROM (tab) connection (gd-dbcon)
                up to i_max_lines rows
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
            else.
              SELECT (t_field) FROM (tab) connection (gd-dbcon)
                up to i_max_lines rows
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by)
                %_HINTS ADABAS 'dbsl_add_stmt with parameters ' &
                       '(''request_flags''=''ANALYZE_MODEL'', ' &
                       '''request_flags''=''OLAP_PARALLEL_AGGREGATION'')'.
            endif.
          endif.
*.......If no display, select everything
        else.
          if i_clnt_spez = true.
            gd-select_type = 'M'.
            SELECT (t_field) FROM (tab)
                CLIENT SPECIFIED connection (gd-dbcon)
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          else.
            gd-select_type = 'N'.
            SELECT (t_field) FROM (tab) connection (gd-dbcon)
                INTO corresponding fields of TABLE <all_table>
                bypassing buffer
                WHERE (lt_where)
                group by (t_group_by)
                order by (t_order_by).
          endif.
        endif.
        if gt_order_by_fields[] is initial.
           sort <all_table>.
        endif.
*.Only determine the number of found entries
      else.
        if i_clnt_spez = true.
          gd-select_type = 'O'.
          SELECT count(*) FROM (tab)
                 CLIENT SPECIFIED connection (gd-dbcon)
                 bypassing buffer
                 WHERE (lt_where).
        else.
          gd-select_type = 'P'.
          SELECT count(*) FROM (tab) connection (gd-dbcon)
               bypassing buffer
               WHERE (lt_where).
        endif.
      endif.
  endif.

  gd-number = sy-dbcnt.
  gd-count  = gd-number.
  subrc     = sy-subrc.
  gt_field[]    = t_field[].

ENDFORM.                               " SELECT_STANDARD

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_STANDARD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_STANDARD using value(p_old_alv)
                            value(cwidth_opt_off).

data: lt_sort type SLIS_T_SORTINFO_ALV.
data: ls_sort type SLIS_SORTINFO_ALV.

*.runtime analysis
  perform progress using '5'.

*.Get the current time
  perform get_time changing gd-end_time
                            gd-end_date.
*.Now calcluate the runtime
  perform calculate_runtime.

*.fill variant structure
  perform fill_variant changing gs_variant.

*.get text of table i ncase of external call
  perform get_table_text.

*.fillglobal table with related tcodes
  perform fill_gt_se16n_rf.

*.check for external exit
  perform external_exit using c_ext_change_lines
                        changing gd-exit_done.
*.in batch this is done via top_of_page of SE16N
  if sy-batch <> true.
     perform external_exit using c_ext_top_of_page
                           changing gd-exit_done.
  endif.

*.in case summary of some fields is requested
  perform add_up_fields.

*.check authority for each value of each line
  perform value_check_on_line_level.

*.In Online use ALV-Grid, in batch I only can use standard ALV
  if sy-batch <> true and p_old_alv <> true.
*...create all objects
    perform create_alv_objects.

*...Now either create editable table or simply send table to the front
    perform set_table_for_display using cwidth_opt_off.

*...Finally show the screen with the results
    perform layout_docking_create.
    if gd-ext_call = true.
       call screen 220.
    else.
       call screen 200.
    endif.
  else.
     refresh: gt_fieldcat_alv.
     CALL FUNCTION 'LVC_TRANSFER_TO_SLIS'
          EXPORTING
               IT_FIELDCAT_LVC = gt_fieldcat
          IMPORTING
               ET_FIELDCAT_ALV = gt_fieldcat_alv.
     perform fill_gt_events.
     PERFORM FILL_single_event USING SLIS_EV_TOP_OF_PAGE
                                     'TOP_OF_PAGE'.
*....set parameters for printing
     if cwidth_opt_off = true.
        clear gs_layout_alv-COLWIDTH_OPTIMIZE.
     else.
        gs_layout_alv-COLWIDTH_OPTIMIZE = true.
     endif.
     GS_LAYOUT_alv-MIN_LINESIZE      = 132.
     GS_LAYOUT_ALV-LIST_APPEND       = ' '.
     if p_old_alv <> true.
        GS_PRINT-PRINT                  = 'X'.
     endif.
     GS_PRINT-NO_PRINT_LISTINFOS     = 'X'.
     GS_PRINT-NO_PRINT_SELINFOS      = 'X'.
*....set dummy variant if needed
     if gd-layout_get = true and
        gs_variant-variant = space.
        gs_variant-variant = c_dummy_vari.
        gs_variant-text    = c_dummy_vari.
     endif.
*....in case of group-by select create a sorting table
     if gt_order_by_fields[] is initial.
       if not gt_group_by_fields[] is initial.
         ls_sort-down = space.
         ls_sort-up   = 'X'.
         loop at gt_group_by_fields.
*..........only if field does not yet exist
           read table lt_sort into ls_sort with key
                fieldname = gt_group_by_fields-field.
           if sy-subrc <> 0.
             add 1 to ls_sort-spos.
             ls_sort-fieldname = gt_group_by_fields-field.
             append ls_sort to lt_sort.
           endif.
         endloop.
       endif.
     endif.
     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
          EXPORTING
*             I_INTERFACE_CHECK        = ' '
              I_CALLBACK_PROGRAM       = 'SAPLSE16N'
*             I_CALLBACK_PF_STATUS_SET = ' '
*             I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
*             I_STRUCTURE_NAME         =
              i_save                   = gd_save
              IS_VARIANT               = gs_variant
              IT_EVENTS                = gt_events
              IS_LAYOUT                = gs_layout_alv
              it_sort                  = lt_sort
              IS_PRINT                 = gs_print
              IT_FIELDCAT              = gt_fieldcat_alv
          TABLES
               T_OUTTAB                = <all_table>
          EXCEPTIONS
              PROGRAM_ERROR            = 1
              OTHERS                   = 2.

    IF SY-SUBRC <> 0.
*......do nothing
    endif.

  endif.

ENDFORM.                               " DISPLAY_STANDARD

*&---------------------------------------------------------------------*
*&      Form  CALCULATE_RUNTIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALCULATE_RUNTIME.

  call function 'SWI_DURATION_DETERMINE'
       EXPORTING
            start_date = gd-start_date
            end_date   = gd-end_date
            start_time = gd-start_time
            end_time   = gd-end_time
       IMPORTING
            duration   = gd-duration.
  call function 'MONI_TIME_CONVERT'
       EXPORTING
            ld_duration        = gd-duration
       IMPORTING
            lt_output_duration = gd-runtime.

  if gd-runtime = space.
     write: '0' to gd-runtime.
  endif.

ENDFORM.                               " CALCULATE_RUNTIME

*&---------------------------------------------------------------------*
*&      Form  REFRESH_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_SCREEN.

data: ld_subrc   like sy-subrc.
data: ld_partial(1).
data: ld_abort(1).

*..the old changes cannot be done anymore, because the pointer are wrong
   perform end.

*..First get time for display of runtime
   perform get_time changing gd-start_time
                             gd-start_date.

*..runtime analysis
   perform progress using '2'.

   if gd-partial = true.
      perform scan_selfields using    gd-tab
                                      gd-max_lines
                                      space
                                      space
                                      gd-read_clnt
                             changing ld_subrc
                                      ld_partial
                                      ld_abort.
*.....in case of drilldown, it could be that the criteria are less
*.....and the partial select is not done anymore
      if ld_partial <> true.
*........do the select on database again
         perform select_standard tables   gt_where
                                 using    gd-tab
                                          gd-max_lines
                                          space
                                          space
                                          gd-read_clnt
                                 changing ld_subrc
                                          ld_abort.
      endif.
   else.
*.....do the select on database again
      perform select_standard tables   gt_where
                              using    gd-tab
                                       gd-max_lines
                                       space
                                       space
                                       gd-read_clnt
                              changing ld_subrc
                                       ld_abort.
   endif.

*..Select the texts
   if gd-no_txt <> true.
      perform select_text_table using gd-txt_tab
                                      gd-read_clnt.
   endif.

*..outer join selects
   if gd-ojkey <> space and
      gd-oj_join_active = space.
      perform ojkey_select_new.
   endif.

*..send new data to the screen
   if gd-edit = true.
      if <all_table_cell> is assigned.
         refresh <all_table_cell>.
      endif.
   endif.

*..formula handling
   IF gd-formula_name <> space.
     PERFORM formula_calculate.
   ENDIF.

*..check for external exit
   perform external_exit using c_ext_change_lines
                         changing gd-exit_done.

*..runtime analysis
   perform progress using '5'.

*..Get the current time
   perform get_time changing gd-end_time
                            gd-end_date.
*..Now calcluate the runtime
   perform calculate_runtime.

*..fill variant structure
   perform fill_variant changing gs_variant.

*..set_table_for_display needs to get cwidth_opt_off.
*..this is not available here. gs_layout-CWIDTH_OPT always contains
*..the opposite value, so convert space to X and X to space.
   TRANSLATE gs_layout-CWIDTH_OPT using 'X  X'.
   perform set_table_for_display using gs_layout-CWIDTH_OPT.

*..refresh layout docking if available
   perform layout_docking_create.

ENDFORM.                    " REFRESH_SCREEN

*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV_OBJECTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_ALV_OBJECTS.

*..First create a custom container in my screen container
  create object g_custom_container
          exporting container_name = g_container.
*..Now create an ALV-Grid in this container
  create object alv_grid
          exporting i_parent = g_custom_container.
*..Create the Event Receiver to handle Edit if necessary
  create object event_receiver.
*..Assign this Event Receiver to my ALV-Grid
  set handler event_receiver->handle_data_changed  for alv_grid.
  set handler event_receiver->handle_double_click  for alv_grid.
  SET HANDLER event_receiver->handle_toolbar       FOR alv_grid.
  SET HANDLER event_receiver->handle_user_command  FOR alv_grid.
  SET HANDLER event_receiver->handle_CONTEXT_MENU_REQUEST FOR alv_grid.
  SET HANDLER event_receiver->handle_hotspot_click FOR alv_grid.
  SET HANDLER event_receiver->handle_after_user_command FOR alv_grid.

*..Changes done in the list should be checked after Return
  call method alv_grid->register_edit_event
          exporting
              i_event_id = cl_gui_alv_grid=>mc_evt_enter.
*   call method alv_grid->set_ready_for_input
*          exporting i_ready_for_input = 1.

* activate BBS call
  if gd-hana_active = true.
  DATA: ls_reprep TYPE lvc_s_rprp.
    ls_reprep-s_rprp_id-tool = 'TR'.
    ls_reprep-s_rprp_id-appl = space.
    ls_reprep-s_rprp_id-subc = '1'.
    ls_reprep-s_rprp_id-onam = 'SE16H'.   "SY-TCODE ???
    ls_reprep-cb_repid = c_repid.
    ls_reprep-cb_frm_mod = 'RSTI_SEL_MODIFY'.
    alv_grid->activate_reprep_interface( ls_reprep ).
  ENDIF.

ENDFORM.                    " CREATE_ALV_OBJECTS
*&---------------------------------------------------------------------*
*&      Form  RSTI_SEL_MODIFY
*&---------------------------------------------------------------------*
*       Modify the selections send via the report-report interface
*----------------------------------------------------------------------*
FORM rsti_sel_modify TABLES lt_sel_tab
                            lt_field_tab
                      USING ls_communication
                                type kkblo_reprep_communication.    "#EC CALLED

  DATA: ls_sel_tab    TYPE rstisel.
  data: lt_multi     like se16n_selfields occurs 0 with header line.
  data: lt_selfields like se16n_selfields occurs 0 with header line.
  data: lt_or_selfields type SE16N_OR_T.
  data: ls_or_seltab type SE16N_OR_SELTAB.
  data: ls_seltab    type se16n_Seltab.
  data: LS_SELOPT    TYPE RSDSSELOPT.
  data: LS_ROWS      TYPE LVC_S_ROW.
  DATA: ld_temp_row  type i.
  data: lt_cols TYPE LVC_T_COL.

  DATA: ld_row type i.
  DATA: ld_col type i.
  DATA: ld_value type char200.
  DATA: ls_row_no type LVC_S_ROID.

  DATA: lt_rows TYPE lvc_t_row,
        lt_cells TYPE lvc_t_cell.

  FIELD-SYMBOLS: <ls_cell> TYPE lvc_s_cell.

*.delete all generic information
  refresh: lt_Sel_tab, lt_field_tab.

*.add table name
  CLEAR ls_sel_tab.
  ls_sel_tab-field   = '$tabname'.
  ls_sel_tab-sign    = 'I'.
  ls_sel_tab-option  = 'EQ'.
  ls_sel_tab-low     = gd-tab.
  APPEND ls_sel_tab TO lt_sel_tab.

* get selected rows
  alv_grid->get_selected_rows( importing et_index_rows = lt_rows ).

*.no rows selected
  IF lt_rows IS INITIAL.
*   no rows selected - check for cells
    alv_grid->get_selected_cells( IMPORTING et_cell = lt_cells ).
    IF NOT lt_cells IS INITIAL.
*     get selection conditions.
      LOOP AT lt_cells ASSIGNING <ls_cell>.
        ld_temp_row = <ls_cell>-row_id-index.
      ENDLOOP.
    ELSE.
*....try if at least cursor is in the list
     CALL METHOD alv_grid->GET_CURRENT_CELL
           IMPORTING
             E_ROW     = ld_row
             E_col     = ld_col
             Es_row_no = ls_row_no
             E_value   = ld_value.
     if ls_row_no-row_id <= 0.
*       ls_communication-stop = true.
       exit. " select everything
     endif.
     check: ls_row_no-row_id > 0.
     ld_temp_row = ls_row_no-row_id.
    ENDIF.
  else.
     describe table lt_rows lines sy-tabix.
*......if only one line selected, take standard logic
     if sy-tabix = 1.
        read table lt_rows into ls_rows index 1.
        ld_temp_row = ls_rows-index.
     endif.
  endif.

*.initialize internal tables
  lt_selfields[]    = gt_selfields[].
  lt_multi[]        = gt_multi[].
  lt_or_selfields[] = gt_or_selfields[].

*.get columns as needed for adapt
  CALL METHOD ALV_GRID->GET_SELECTED_COLUMNS
           IMPORTING
             ET_INDEX_COLUMNS = lt_cols.

*......adapt tables to fill criteria of chosen line into
*......selection table
  perform adapt_tables tables   lt_selfields
                                lt_multi
                       using    ld_temp_row
                                lt_cols
                                lt_rows
                                true
                       changing lt_or_selfields.

  loop at lt_or_Selfields into ls_or_Seltab.
    loop at ls_or_seltab-seltab into ls_Seltab.
       READ TABLE lt_selfields
                  WITH KEY fieldname = ls_seltab-field.
       IF sy-subrc = 0 AND lt_selfields-datatype = 'CLNT'.
*        skip client as selection criteria - not supported
         CONTINUE.
       ENDIF.
       CLEAR ls_sel_tab.
       ls_sel_tab-field   = ls_seltab-field.
       ls_sel_tab-sign    = ls_seltab-sign.
       ls_selopt-option   = ls_seltab-option.
       perform get_option using ls_seltab-sign
                                ls_seltab-option
                                ls_seltab-high
                                space
                                ls_seltab-field
                                gd-pool
                         changing ls_selopt-option
                                  ls_seltab-low.
       ls_sel_tab-option  = ls_selopt-option.
       ls_sel_tab-low     = ls_seltab-low.
       ls_sel_tab-high    = ls_seltab-high.
       APPEND ls_sel_tab TO lt_sel_tab.
    endloop.
  endloop.

ENDFORM.                    " RSTI_SEL_MODIFY
*&---------------------------------------------------------------------*
*&      Form  SET_TABLE_FOR_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_TABLE_FOR_DISPLAY using value(cwidth_opt_off).

  data: ld_tabix   like sy-tabix.
  data: ls_cell    type lvc_s_styl.
  data: waref      type ref to data.
  data: IT_TOOLBAR_EXCL type ui_functions.
  data: is_toolbar_excl type ui_func.
  data: lt_sort         type LVC_T_SORT.
  data: ls_sort         type LVC_S_SORT.
  data: ls_selfields    type se16n_selfields.
  data: ls_toplow_fields type se16n_seltab.

*..<all_table> is filled with the output data. Now I need to move this
*..to <all_table_cell> and fill the field line_index and the
*..Style table contains the information which field is inputable for
*..every line.

*.zebra design
  gs_layout-zebra = gd-zebra.

*.selection mode per field
  gs_layout-sel_mode = 'D'.

*.always optimise columns
  if cwidth_opt_off = true.
     clear gs_layout-cwidth_opt.
  else.
     gs_layout-CWIDTH_OPT = true.
  endif.

*.key column scrolling
  gs_layout-no_keyfix = gd-scroll.

*.count of lines
  if gd-count_lines = true.
     gs_layout-countfname = c_count_index.
  endif.

*.in case of group-by select create a sorting table
*  if not gt_order_by_fields[] is initial.
*     ls_sort-spos = 0.
*     loop at gt_order_by_fields.
*        add 1 to ls_sort-spos.
*        ls_sort-fieldname = gt_order_by_fields-field.
*        ls_sort-down = 'X'.
*        append ls_sort to lt_sort.
*     endloop.
*  endif.
  if gt_order_by_fields[] is initial.
   if not gt_group_by_fields[] is initial.
     ls_sort-down = space.
     ls_sort-up   = 'X'.
     loop at gt_group_by_fields.
*.......only if field does not yet exist
        read table lt_sort into ls_sort with key
               fieldname = gt_group_by_fields-field.
        if sy-subrc <> 0.
           add 1 to ls_sort-spos.
           ls_sort-fieldname = gt_group_by_fields-field.
           append ls_sort to lt_sort.
        endif.
     endloop.
   endif.
*.add wanted sorting to ALV to make the display nicer
  else.
    loop at gt_order_by_fields.
*.......only if field does not yet exist
        read table lt_sort into ls_sort with key
               fieldname = gt_order_by_fields-field.
        if sy-subrc <> 0.
           add 1 to ls_sort-spos.
           ls_sort-fieldname = gt_order_by_fields-field.
*..........in case of external call only gt_toplow is filled
           read table gt_toplow_fields into ls_toplow_fields
                with key field = gt_order_by_fields-field.
           if ls_toplow_fields-low = 'DES'.
*           read table gt_selfields into ls_selfields
*                with key fieldname = gt_order_by_fields-field.
*           if ls_selfields-toplow = 'DES'.
             ls_sort-down = true.
             ls_sort-up   = space.
           else.
             ls_sort-down = space.
             ls_sort-up   = true.
           endif.
           append ls_sort to lt_sort.
        endif.
     endloop.
*....if additional grouping fields exist, add them as well
     ls_sort-down = space.
     ls_sort-up   = 'X'.
     loop at gt_group_by_fields.
*.......only if field does not yet exist
        read table lt_sort into ls_sort with key
               fieldname = gt_group_by_fields-field.
        if sy-subrc <> 0.
           add 1 to ls_sort-spos.
           ls_sort-fieldname = gt_group_by_fields-field.
           append ls_sort to lt_sort.
        endif.
     endloop.
  endif.

*.exclude functions in case of sort field
  if gd-sortfield = true and
     gd-edit      <> true.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_APPEND_ROW.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_COPY.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_COPY_ROW.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_CUT.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_DELETE_ROW.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_INSERT_ROW.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_MOVE_ROW.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_PASTE.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_PASTE_NEW_ROW.
     append is_toolbar_excl to it_toolbar_excl.
     is_toolbar_excl = cl_gui_alv_grid=>MC_FC_LOC_UNDO.
     append is_toolbar_excl to it_toolbar_excl.
  endif.

*.call exit to exclude toolbar buttons
  perform external_exit using c_ext_toolbar_excl
                        changing gd-exit_done.
  if gd-exit_done = true.
     append lines of gt_toolbar_excl to it_toolbar_excl.
  endif.

*.set dummy variant if needed
  if gd-layout_get = true and
     gs_variant-variant = space.
     gs_variant-variant = c_dummy_vari.
     gs_variant-text    = c_dummy_vari.
  endif.

  if gd-edit = true.
    gs_layout-stylefname = gd_style_fname.
*.....create header line of <all_table_cell>
    CREATE DATA waref LIKE LINE OF <all_table_cell>.
    assign waref->* to <wa_cell>.
*.....move all data from <all_table> to <all_table_cell> by moving
*.....each field from <wa> to <wa_cell>
    loop at <all_table> assigning <wa>.
      ld_tabix = sy-tabix.
      clear <wa_cell>.
*........Number of columns
      DO gd_lines TIMES.
        ASSIGN COMPONENT SY-INDEX OF STRUCTURE <wa> TO <FS>.
        IF SY-SUBRC <> 0. EXIT. ENDIF.
        ASSIGN COMPONENT SY-INDEX OF STRUCTURE <wa_cell>
                                                    TO <FS_cell>.
        IF SY-SUBRC <> 0. EXIT. ENDIF.
        <FS_cell> = <fs>.
      ENDDO.
*........Now move the information about the structure (same for every
*........line). (The style of the key fields!)
      assign component gd_style_fname of structure <wa_cell>
                                                       to <cell>.
      insert lines of gt_cell into table <cell>.
*........Store the index of the line
      ASSIGN COMPONENT c_line_index OF STRUCTURE <wa> TO <FS>.
      ASSIGN COMPONENT c_line_index OF STRUCTURE
                                            <wa_cell> TO <FS_cell>.
      <fs>      = ld_tabix.
      <fs_cell> = ld_tabix.
*.....................................................................
      append <wa_cell> to <all_table_cell>.
    endloop.
    call method alv_grid->set_table_for_first_display
       exporting is_layout        = gs_layout
                 is_variant       = gs_variant
                 i_save           = gd_save
                 I_BUFFER_ACTIVE  = gd-buffer
                 it_toolbar_excluding = it_toolbar_excl
       changing  it_fieldcatalog  = gt_fieldcat
                 it_sort          = lt_sort
                 it_outtab        = <all_table_cell>.
  else.
    call method alv_grid->set_table_for_first_display
       exporting is_layout        = gs_layout
                 is_variant       = gs_variant
                 i_save           = gd_save
                 I_BUFFER_ACTIVE  = gd-buffer
                 it_toolbar_excluding = it_toolbar_excl
       changing  it_fieldcatalog  = gt_fieldcat
                 it_sort          = lt_sort
                 it_outtab        = <all_table>.
  endif.

  if gs_variant-variant = c_dummy_vari.
     clear gs_variant-variant.
     clear gs_variant-text.
  endif.

ENDFORM.                    " SET_TABLE_FOR_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LINE_NR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_LINE_NR.

   if sy-batch = true.
      new-line.
      write: at 1(70) sy-uline.
      new-line.
*.....Search table
      write: at 1(1) sy-vline.
      write: at 2 text-004 intensified on.
      write: at 31 gd-tab color col_heading.
      write: at 70(1) sy-vline.
      new-line.
*.....Number of found entries
      write: at 1(1) sy-vline.
      write: at 2 text-003 intensified on.
      write: at 31 gd-number color col_heading.
      write: at 70(1) sy-vline.
      new-line.
      write: at 1(70) sy-uline.
   else.
      call screen 0105 starting at 2 2 ending at 55 3.
   endif.

ENDFORM.                    " DISPLAY_LINE_NR
*&---------------------------------------------------------------------*
*&      Form  CHANGE_SQM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_SELFIELDS_LOW  text
*----------------------------------------------------------------------*
FORM CHANGE_SQM CHANGING value(p_string).

*.Handling for quotation marks
data: ld_len  like sy-tabix.
data: ld_beg  like sy-tabix.
data: ld_begc like sy-tabix.
data: ld_c    like se16n_seltab-low.
data: ld_c2   like se16n_seltab-low.

  ld_len  = strlen( p_string ).
  ld_beg  = 0.
  ld_begc = 0.
  while ld_beg < ld_len.
     write p_string+ld_beg(1) to ld_c.
     if ld_c = ''''.
        write '''''' to ld_c2+ld_begc(2).
        add 1 to ld_beg.
        add 2 to ld_begc.
     else.
        write ld_c to ld_c2+ld_begc(1).
        add 1 to ld_beg.
        add 1 to ld_begc.
     endif.
   endwhile.
   clear p_string.
   p_string = ld_c2.

ENDFORM.                    " CHANGE_SQM
*&---------------------------------------------------------------------*
*&      Form  fill_gt_events
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_gt_events.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
        EXPORTING
            I_LIST_TYPE     = 0
        IMPORTING
            ET_EVENTS       = GT_EVENTS
        EXCEPTIONS
            LIST_TYPE_WRONG = 1
            OTHERS          = 2.


ENDFORM.                    " fill_gt_events
*&---------------------------------------------------------------------*
*&      Form  FILL_single_event
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SLIS_EV_TOP_OF_PAGE  text
*      -->P_0660   text
*----------------------------------------------------------------------*
FORM FILL_SINGLE_EVENT USING    value(P_EVENT_NAME)
                                value(P_FORM_NAME).

DATA: HEAD_EVENTS TYPE SLIS_ALV_EVENT.

READ TABLE GT_EVENTS INTO HEAD_EVENTS WITH KEY NAME = P_EVENT_NAME.
IF SY-SUBRC = 0.
   HEAD_EVENTS-FORM = P_FORM_NAME.
   MODIFY GT_EVENTS FROM HEAD_EVENTS INDEX SY-TABIX.
ELSE.
   MESSAGE X220(KP) WITH P_EVENT_NAME SPACE SPACE SPACE.
ENDIF.

ENDFORM.                    " FILL_single_event

*&---------------------------------------------------------------------*
*&      Form  Top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
Form top_of_page.


clear: wa_line.
Refresh gd_alv_listheader.

*.check if external exit was done, if so skip generic one
  perform external_exit using c_ext_top_of_page
                        changing gd-exit_done.
  check: gd-exit_done <> true.

*  new-line.
*  write: at 1(70) sy-uline.
*  new-line.
**.Search table
*  write: at 1(1) sy-vline.
*  write: at 2 text-004 intensified on.
*  write: at 31 gd-tab color col_heading.
  wa_line-typ  = 'S'.
  wa_line-key  = text-004.
  wa_line-info = gd-tab.
  APPEND wa_line TO gd_alv_listheader.
  CLEAR: wa_line.
*  write: at 70(1) sy-vline.
*  new-line.
**.Number of found entries
*  write: at 1(1) sy-vline.
*  write: at 2 text-003 intensified on.
*  write: at 31 gd-number color col_heading.
  wa_line-typ  = 'S'.
  wa_line-key  = text-003.
  wa_line-info = gd-number.
  APPEND wa_line TO gd_alv_listheader.
  CLEAR: wa_line.
*  write: at 70(1) sy-vline.
*  new-line.
**. Maximum Number of found entries
*  write: at 1(1) sy-vline.
*  write: at 2 text-005 intensified on.
*  write: at 31 gd-max_lines color col_heading.
  wa_line-typ  = 'S'.
  wa_line-key  = text-005.
  wa_line-info = gd-max_lines.
  APPEND wa_line TO gd_alv_listheader.
  CLEAR: wa_line.
* write: at 70(1) sy-vline.
*  new-line.
**.runtime
*  write: at 1(1) sy-vline.
*  write: at 2 text-002 intensified on.
*  write: at 31 gd-runtime color col_heading.
  wa_line-typ  = 'S'.
  wa_line-key  = text-002.
  wa_line-info = gd-runtime.
  APPEND wa_line TO gd_alv_listheader.
  CLEAR: wa_line.
*  write: at 70(1) sy-vline.
*  new-line.
*  write: at 1(70) sy-uline.
*  new-line.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gd_alv_listheader[].

endform.
*&---------------------------------------------------------------------*
*&      Form  SHOW_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SHOW_SELECTION .

data: lt_output(72) occurs 0.
data: lt_dummy(72) occurs 0.
data: ls_output(72).
data: field type string.
data: lt_FIELDS like HELP_VALUE occurs 0 with header line.

define fill_lt.
  ls_output = &1.
  append ls_output to lt_output.
end-of-definition.

  fill_lt 'SELECT'.
  case gd-select_type.
    when 'A'.
      loop at gt_field into field.
        fill_lt field.
      endloop.
      if strlen( gd-cds_string ) > 70.
        ls_output = |FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'client specified'.
      fill_lt 'up to <max_lines> rows'.
      fill_lt 'into corresponding fields of table <target>'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
      if not gt_group_by_fields[] is initial.
         fill_lt 'group by'.
      endif.
      loop at gt_group_by_fields into field.
        fill_lt field.
      endloop.
      IF NOT gd-having_clause IS INITIAL.
        IF STRLEN( gd-having_clause ) > 70.
          fill_lt 'having'.
          SPLIT gd-having_clause AT space INTO TABLE lt_dummy.
          APPEND LINES OF lt_dummy TO lt_output.
        ELSE.
          fill_lt 'having'.
          ls_output = |{ gd-having_clause }|.
          APPEND ls_output TO lt_output.
        ENDIF.
      ENDIF.
      if not gt_order_by_fields[] is initial.
         fill_lt 'order by'.
      endif.
      loop at gt_order_by_fields into field.
        read table gt_toplow_fields
             with key field = field.
        if sy-subrc = 0.
            if gt_toplow_fields-low = 'ASC'.
              concatenate gt_toplow_fields-low 'ENDING'
                     into gt_toplow_fields-low.
            else.
              concatenate gt_toplow_fields-low 'CENDING'
                     into gt_toplow_fields-low.
            endif.
            concatenate field gt_toplow_fields-low
                   into field separated by space.
        endif.
        fill_lt field.
      endloop.
    when 'B'.
      loop at gt_field into field.
        fill_lt field.
      endloop.
      if strlen( gd-cds_string ) > 70.
        ls_output = |FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'up to <max_lines> rows'.
      fill_lt 'into corresponding fields of table <target>'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
      if not gt_group_by_fields[] is initial.
         fill_lt 'group by'.
      endif.
      loop at gt_group_by_fields into field.
        fill_lt field.
      endloop.
      IF NOT gd-having_clause IS INITIAL.
        IF STRLEN( gd-having_clause ) > 70.
          fill_lt 'having'.
          SPLIT gd-having_clause AT space INTO TABLE lt_dummy.
          APPEND LINES OF lt_dummy TO lt_output.
        ELSE.
          fill_lt 'having'.
          ls_output = |{ gd-having_clause }|.
          APPEND ls_output TO lt_output.
        ENDIF.
      ENDIF.
      if not gt_order_by_fields[] is initial.
         fill_lt 'order by'.
      endif.
      loop at gt_order_by_fields into field.
        read table gt_toplow_fields
             with key field = field.
        if sy-subrc = 0.
            if gt_toplow_fields-low = 'ASC'.
              concatenate gt_toplow_fields-low 'ENDING'
                     into gt_toplow_fields-low.
            else.
              concatenate gt_toplow_fields-low 'CENDING'
                     into gt_toplow_fields-low.
            endif.
            concatenate field gt_toplow_fields-low
                   into field separated by space.
        endif.
        fill_lt field.
      endloop.
    when 'E'.
      fill_lt 'count (*)'.
      if strlen( gd-cds_string ) > 70.
        ls_output = |FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'client specified'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
    when 'F'.
      fill_lt 'count (*)'.
      if strlen( gd-cds_string ) > 70.
        ls_output = |FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
    when 'G'.
      if strlen( gd-cds_string ) > 70.
        ls_output = |* FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |* FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'client specified'.
      fill_lt 'up to <max_lines> rows'.
      fill_lt 'into corresponding fields of table <target>'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
      if not gt_order_by_fields[] is initial.
         fill_lt 'order by'.
      endif.
      loop at gt_order_by_fields into field.
        read table gt_toplow_fields
             with key field = field.
        if sy-subrc = 0.
            if gt_toplow_fields-low = 'ASC'.
              concatenate gt_toplow_fields-low 'ENDING'
                     into gt_toplow_fields-low.
            else.
              concatenate gt_toplow_fields-low 'CENDING'
                     into gt_toplow_fields-low.
            endif.
            concatenate field gt_toplow_fields-low
                   into field separated by space.
        endif.
        fill_lt field.
      endloop.
    when 'H'.
      if strlen( gd-cds_string ) > 70.
        ls_output = |* FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |* FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'up to <max_lines> rows'.
      fill_lt 'into corresponding fields of table <target>'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
      if not gt_order_by_fields[] is initial.
         fill_lt 'order by'.
      endif.
      loop at gt_order_by_fields into field.
        read table gt_toplow_fields
             with key field = field.
        if sy-subrc = 0.
            if gt_toplow_fields-low = 'ASC'.
              concatenate gt_toplow_fields-low 'ENDING'
                     into gt_toplow_fields-low.
            else.
              concatenate gt_toplow_fields-low 'CENDING'
                     into gt_toplow_fields-low.
            endif.
            concatenate field gt_toplow_fields-low
                   into field separated by space.
        endif.
        fill_lt field.
      endloop.
    when 'K'.
      loop at gt_field into field.
        fill_lt field.
      endloop.
      if strlen( gd-cds_string ) > 70.
        ls_output = |FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'client specified'.
      ls_output = |connection { gd-dbcon }|.
      append ls_output to lt_output.
      fill_lt 'up to <max_lines> rows'.
      fill_lt 'into corresponding fields of table <target>'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
      if not gt_group_by_fields[] is initial.
         fill_lt 'group by'.
      endif.
      loop at gt_group_by_fields into field.
        fill_lt field.
      endloop.
      IF NOT gd-having_clause IS INITIAL.
        IF STRLEN( gd-having_clause ) > 70.
          fill_lt 'having'.
          SPLIT gd-having_clause AT space INTO TABLE lt_dummy.
          APPEND LINES OF lt_dummy TO lt_output.
        ELSE.
          fill_lt 'having'.
          ls_output = |{ gd-having_clause }|.
          APPEND ls_output TO lt_output.
        ENDIF.
      ENDIF.
      if not gt_order_by_fields[] is initial.
         fill_lt 'order by'.
      endif.
      loop at gt_order_by_fields into field.
        read table gt_toplow_fields
             with key field = field.
        if sy-subrc = 0.
            if gt_toplow_fields-low = 'ASC'.
              concatenate gt_toplow_fields-low 'ENDING'
                     into gt_toplow_fields-low.
            else.
              concatenate gt_toplow_fields-low 'CENDING'
                     into gt_toplow_fields-low.
            endif.
            concatenate field gt_toplow_fields-low
                   into field separated by space.
        endif.
        fill_lt field.
      endloop.
    when 'L'.
      loop at gt_field into field.
        fill_lt field.
      endloop.
      if strlen( gd-cds_string ) > 70.
        ls_output = |FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      ls_output = |connection { gd-dbcon }|.
      append ls_output to lt_output.
      fill_lt 'up to <max_lines> rows'.
      fill_lt 'into corresponding fields of table <target>'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
      if not gt_group_by_fields[] is initial.
         fill_lt 'group by'.
      endif.
      loop at gt_group_by_fields into field.
        fill_lt field.
      endloop.
      IF NOT gd-having_clause IS INITIAL.
        IF STRLEN( gd-having_clause ) > 70.
          fill_lt 'having'.
          SPLIT gd-having_clause AT space INTO TABLE lt_dummy.
          APPEND LINES OF lt_dummy TO lt_output.
        ELSE.
          fill_lt 'having'.
          ls_output = |{ gd-having_clause }|.
          APPEND ls_output TO lt_output.
        ENDIF.
      ENDIF.
      if not gt_order_by_fields[] is initial.
         fill_lt 'order by'.
      endif.
      loop at gt_order_by_fields into field.
        read table gt_toplow_fields
             with key field = field.
        if sy-subrc = 0.
            if gt_toplow_fields-low = 'ASC'.
              concatenate gt_toplow_fields-low 'ENDING'
                     into gt_toplow_fields-low.
            else.
              concatenate gt_toplow_fields-low 'CENDING'
                     into gt_toplow_fields-low.
            endif.
            concatenate field gt_toplow_fields-low
                   into field separated by space.
        endif.
        fill_lt field.
      endloop.
    when 'O'.
      fill_lt 'count (*)'.
      if strlen( gd-cds_string ) > 70.
        ls_output = |FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'client specified'.
      ls_output = |connection { gd-dbcon }|.
      append ls_output to lt_output.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
    when 'P'.
      fill_lt 'count (*)'.
      if strlen( gd-cds_string ) > 70.
        ls_output = |FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      ls_output = |connection { gd-dbcon }|.
      append ls_output to lt_output.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
    when 'Q'.
      if strlen( gd-cds_string ) > 70.
        ls_output = |* FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |* FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      fill_lt 'client specified'.
      ls_output = |connection { gd-dbcon }|.
      append ls_output to lt_output.
      fill_lt 'up to <max_lines> rows'.
      fill_lt 'into corresponding fields of table <target>'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
      IF NOT gd-having_clause IS INITIAL.
        IF STRLEN( gd-having_clause ) > 70.
          fill_lt 'having'.
          SPLIT gd-having_clause AT space INTO TABLE lt_dummy.
          APPEND LINES OF lt_dummy TO lt_output.
        ELSE.
          fill_lt 'having'.
          ls_output = |{ gd-having_clause }|.
          APPEND ls_output TO lt_output.
        ENDIF.
      ENDIF.
      if not gt_order_by_fields[] is initial.
         fill_lt 'order by'.
      endif.
      loop at gt_order_by_fields into field.
        read table gt_toplow_fields
             with key field = field.
        if sy-subrc = 0.
            if gt_toplow_fields-low = 'ASC'.
              concatenate gt_toplow_fields-low 'ENDING'
                     into gt_toplow_fields-low.
            else.
              concatenate gt_toplow_fields-low 'CENDING'
                     into gt_toplow_fields-low.
            endif.
            concatenate field gt_toplow_fields-low
                   into field separated by space.
        endif.
        fill_lt field.
      endloop.
    when 'R'.
      if strlen( gd-cds_string ) > 70.
        ls_output = |* FROM |.
        append ls_output to lt_output.
        split gd-cds_string at space into table lt_dummy.
        append lines of lt_dummy to lt_output.
      else.
        ls_output = |* FROM { gd-cds_string }|.
        append ls_output to lt_output.
      endif.
      ls_output = |connection { gd-dbcon }|.
      append ls_output to lt_output.
      fill_lt 'up to <max_lines> rows'.
      fill_lt 'into corresponding fields of table <target>'.
      fill_lt 'bypassing buffer'.
      if not gt_where[] is initial.
         fill_lt 'WHERE'.
      endif.
      append lines of gt_where to lt_output.
      IF NOT gd-having_clause IS INITIAL.
        IF STRLEN( gd-having_clause ) > 70.
          fill_lt 'having'.
          SPLIT gd-having_clause AT space INTO TABLE lt_dummy.
          APPEND LINES OF lt_dummy TO lt_output.
        ELSE.
          fill_lt 'having'.
          ls_output = |{ gd-having_clause }|.
          APPEND ls_output TO lt_output.
        ENDIF.
      ENDIF.
      if not gt_order_by_fields[] is initial.
         fill_lt 'order by'.
      endif.
      loop at gt_order_by_fields into field.
        read table gt_toplow_fields
             with key field = field.
        if sy-subrc = 0.
            if gt_toplow_fields-low = 'ASC'.
              concatenate gt_toplow_fields-low 'ENDING'
                     into gt_toplow_fields-low.
            else.
              concatenate gt_toplow_fields-low 'CENDING'
                     into gt_toplow_fields-low.
            endif.
            concatenate field gt_toplow_fields-low
                   into field separated by space.
        endif.
        fill_lt field.
      endloop.
  endcase.

  check: not lt_output[] is initial.

  lt_fields-tabname    = 'IDMX_DI_PSEPROFT'.
  lt_fields-fieldname  = 'DESCRIPTION'.
  lt_fields-selectflag = space.
  append lt_fields.

  CALL FUNCTION 'POPUP_TO_SHOW_DB_DATA_IN_TABLE'
    EXPORTING
      TITLE_TEXT              = text-sel
    TABLES
      FIELDS                  = lt_fields
      VALUETAB                = lt_output
    EXCEPTIONS
      FIELD_NOT_IN_DDIC       = 1
      OTHERS                  = 2.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.                    " SHOW_SELECTION
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_CD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_CD .


  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
    EXPORTING
      TCODE         = 'SE38'
    EXCEPTIONS
      OK            = 1
      NOT_OK        = 2
      OTHERS        = 3.

  IF SY-SUBRC > 1.
     MESSAGE i077(s#) with 'SE38'.
     exit.
  ENDIF.

  submit rkse16n_cd_display via selection-screen and return.

ENDFORM.                    " DISPLAY_CD
*&---------------------------------------------------------------------*
*&      Form  CHECK_SETID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_SETID .

data: ld_setid like sethier-setid.

*..input is done with external shortname. try to figure out
*..which setid the user may want to have
   check: gs_selfields-setid <> space.
*  READ TABLE GT_SELFIELDS INDEX SELFIELDS_TC-CURRENT_LINE.

   CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
     EXPORTING
*      CLIENT                         =
       SHORTNAME                      = gs_selfields-setid
*      OLD_SETID                      =
       TABNAME                        = gd-tab
       FIELDNAME                      = gt_selfields-fieldname
     IMPORTING
       NEW_SETID                      = ld_setid
     EXCEPTIONS
       NO_SET_FOUND                   = 1
       NO_SET_PICKED_FROM_POPUP       = 2
       WRONG_CLASS                    = 3
       WRONG_SUBCLASS                 = 4
       TABLE_FIELD_NOT_FOUND          = 5
       FIELDS_DONT_MATCH              = 6
       SET_IS_EMPTY                   = 7
       FORMULA_IN_SET                 = 8
       SET_IS_DYNAMIC                 = 9
       OTHERS                         = 10.

   IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ELSE.
*.....gt_selfields contains the setid, whereas gs_selfields
*.....contains the shortname
      gt_selfields-setid = ld_setid.
*      MODIFY GT_SELFIELDS INDEX SELFIELDS_TC-CURRENT_LINE.
   ENDIF.

ENDFORM.                    " CHECK_SETID
*&---------------------------------------------------------------------*
*&      Form  F4_SETID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F4_SETID .

data: ld_setid     like rgsbs-setnr.
data: ld_setname   type SETNAMENEW.
data: ld_curr_line like sy-tabix.

  get cursor line ld_curr_line.
  ld_curr_line = ld_curr_line + selfields_tc-top_line - 1.
  read table gt_selfields index ld_curr_line.
  check: sy-subrc = 0.

  CALL FUNCTION 'G_RW_SET_SELECT'
    EXPORTING
*     CLASS                      = ' '
      FIELD_NAME                 = gt_selfields-fieldname
      TABLE                      = gd-tab
    IMPORTING
      SETID                      = ld_setid
      SET_NAME                   = ld_setname
    EXCEPTIONS
      NO_SETS                    = 1
      NO_SET_PICKED              = 2
      OTHERS                     = 3.

  IF SY-SUBRC = 0.
*   gt_selfields-setid = ld_setid.
    gs_selfields-setid = ld_setname.
*   modify gt_selfields index ld_curr_line.
  ENDIF.

ENDFORM.                    " F4_SETID
*&---------------------------------------------------------------------*
*&      Form  SHOW_DOCU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SHOW_DOCU using value(p_note).

  DATA: l_sap_note_url TYPE text2048.
  data: ld_1(30).
  data: ld_2(60).

  ld_1 = |http://service.sap.com|.
  ld_2 = |/~form/handler?_APP=01100107900000000342&_EVENT=REDIR&_NNUM='|.

  CONCATENATE ld_1 ld_2 p_note
              INTO l_sap_note_url.
  CALL FUNCTION 'CALL_BROWSER'
       EXPORTING
            url    = l_sap_note_url
       EXCEPTIONS
            OTHERS = 0.


ENDFORM.                    " SHOW_DOCU
*&---------------------------------------------------------------------*
*& Form show_selection_abap
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_selection_abap .

*.This form prepares the select statement in a way that could easily
*.be used in ABAP

  DATA: lt_source   TYPE STANDARD TABLE OF abapsource.
  DATA: lt_source_n TYPE STANDARD TABLE OF abapsource.
  DATA: ls_source   TYPE string.
  DATA: ld_tabix    LIKE sy-tabix.
  DATA: lt_dummy(72) OCCURS 0.
  DATA: ls_dummy(72).
  DATA: lt_FIELDS   LIKE HELP_VALUE OCCURS 0 WITH HEADER LINE.
  DATA: ld_dynnr    LIKE sy-dynnr VALUE '200'.
  DATA: ls_fieldcat TYPE lvc_s_fcat.
  DATA: ld_text     TYPE ddtext.
  DATA: ld_text2    TYPE ddtext.

*.check toggle
  IF gd_abap_dock_active = true.
    CLEAR gd_abap_dock_active.
    IF NOT gd_abap_dock IS INITIAL.
      CALL METHOD gd_abap_dock->set_visible
        EXPORTING
        visible = gd_abap_dock_active.
      CALL METHOD gd_abap_text->free.
      CALL METHOD gd_abap_dock->free.
      CLEAR gd_abap_dock.
      CLEAR gd_abap_text.
    ENDIF.
    EXIT.
  ENDIF.

*  DATA sqlcode TYPE TABLE OF msqsqlcode.
*
*  CALL FUNCTION 'MSS_FORMAT_BODY'
*    EXPORTING
*      sql                   = gd-cds_string
**     MAX_LINE              = 80
*      use_dba_sql_formatter = 'X'
*    TABLES
*      sqlcode               = sqlcode.


*          SELECT (t_field) FROM (gd-cds_string)
*            WHERE (lt_where)
*            group by (t_group_by)
*            having (gd-having_clause)
*            order by (t_order_by)
*            %_HINTS HDB @ld_hint
*            INTO corresponding fields of TABLE @<all_table>
*            connection (gd-dbcon)
*            up to @ld_max_lines rows
*            bypassing buffer.

  ls_source = |*------------------------------------------------*|.
  APPEND ls_source TO lt_source.
  IF gd-ojkey <> space.
     ls_source = |*.Generated report for Join Definition { gd-ojkey }|.
     APPEND ls_source to lt_source.
     ls_source = |*------------------------------------------------*|.
     APPEND ls_source TO lt_source.
     SELECT SINGLE txt FROM se16n_oj_keyt INTO ld_text
                    WHERE langu    = sy-langu
                      AND oj_key   = gd-ojkey
                      AND prim_tab = gd-tab.
     IF sy-subrc = 0.
        ls_source = |*...{ ld_text }|.
        APPEND ls_source to lt_source.
     ENDIF.
  ENDIF.
  ls_source = |*------------------------------------------------*|.
  APPEND ls_source TO lt_source.
  WRITE sy-datlo TO ld_text.
  WRITE sy-timlo TO ld_text2.
  ls_source = |* Generated by { sy-uname } { ld_text }, { ld_text2 }|.
  APPEND ls_source TO lt_source.
  ls_source = |*------------------------------------------------*|.
  APPEND ls_source TO lt_source.
  ls_source = |Report ZSE16N_EXAMPLE.|.
  APPEND ls_source TO lt_source.
  APPEND space TO lt_source.

  ls_source = |  data: ld_lines like sy-tabix value '{ gd-max_lines }'.|.
  APPEND ls_source TO lt_source.

  IF NOT gt_sum_up_fields[] IS INITIAL OR
     NOT gt_group_by_fields[] IS INITIAL OR
     NOT gt_aggregate_fields[] IS INITIAL.
  ELSE.
     ls_source = |  DATA: lt_fieldcat        TYPE lvc_t_fcat.|.
     APPEND ls_source TO lt_source.
     ls_source = |  DATA: ls_fieldcat        TYPE lvc_s_fcat.|.
     APPEND ls_source TO lt_source.
     ls_source = |  DATA: ldtab              TYPE REF TO DATA.|.
     APPEND ls_source TO lt_source.
     ls_source = |  FIELD-symbols: <all_table> TYPE TABLE.|.
     APPEND ls_source TO lt_source.
  ENDIF.

  APPEND space TO lt_source.

  ls_source = |start-of-selection.|.
  APPEND ls_source TO lt_source.
  APPEND space TO lt_source.

  IF NOT gt_sum_up_fields[] IS INITIAL OR
     NOT gt_group_by_fields[] IS INITIAL OR
     NOT gt_aggregate_fields[] IS INITIAL.
  ELSE.
*.fill fieldcatalog to generate ALV-structure
  ls_source = |*.Get all fields needed in output structure|.
  APPEND ls_source TO lt_source.
  LOOP AT gt_fieldcat INTO ls_fieldcat WHERE no_out = space.
     ls_source = | ls_fieldcat-fieldname = '{ ls_fieldcat-fieldname }'.|.
     APPEND ls_source TO lt_source.
     ls_source = | ls_fieldcat-ref_field = '{ ls_fieldcat-ref_field }'.|.
     APPEND ls_source TO lt_source.
     ls_source = | ls_fieldcat-ref_table = '{ ls_fieldcat-ref_table }'.|.
     APPEND ls_source TO lt_source.
     ls_source = | APPEND ls_fieldcat to lt_fieldcat.|.
     APPEND ls_source TO lt_source.
  ENDLOOP.

  APPEND space TO lt_source.
  ls_source = |*.Create generic structure needed for the output|.
  APPEND ls_source TO lt_source.
  ls_source = |call method cl_alv_table_create=>create_dynamic_table|.
  APPEND ls_source TO lt_source.
  ls_source = |  exporting it_fieldcatalog = lt_fieldcat|.
  APPEND ls_source TO lt_source.
  ls_source = |  importing ep_table        = ldtab|.
  APPEND ls_source TO lt_source.
  ls_source = |  exceptions GENERATE_SUBPOOL_DIR_FULL = 9.|.
  APPEND ls_source TO lt_source.
  ls_source = |assign ldtab->* to <all_table>.|.
  APPEND ls_source TO lt_source.
  ENDIF.

  APPEND space TO lt_source.
  ls_source = |*.Adopt this select statement to your needs|.
  APPEND ls_source TO lt_source.

  ls_source = |SELECT|.
  APPEND ls_source TO lt_source.
*.field catalog
  LOOP AT gt_field INTO ls_source.
*...add 2 spaces to the left
    ls_source = |  { ls_source }|.
    APPEND ls_source TO lt_source.
  ENDLOOP.
*  APPEND LINES OF gt_field TO lt_source.
*.string for JOIN or regular table
  IF STRLEN( gd-cds_string ) > 70.
    SPLIT gd-cds_string AT space INTO TABLE lt_dummy.
*    APPEND LINES OF lt_dummy TO lt_source.
*.....try to format the joins in a readable way
    ls_dummy = |FROM|.
*...first line is space - add FROM
    MODIFY lt_dummy FROM ls_dummy INDEX 1.
    ld_tabix = 0.
    DO.
      ADD 1 TO ld_tabix.
      READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      CHECK: ls_dummy <> space.
       CASE ls_dummy.
         WHEN 'FROM'.
           ls_source = ls_dummy.
*..........now read the table
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now check if join
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           IF ls_dummy = 'AS'.
              CONCATENATE ls_source ls_dummy INTO ls_source
                   SEPARATED BY space.
*.............now the letter for the table
              ADD 1 TO ld_tabix.
              READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
              CONCATENATE ls_source ls_dummy INTO ls_source
                   SEPARATED BY space.
*.............add 2 spaces to the left
              ls_source = |  { ls_source }|.
              APPEND ls_source TO lt_source.
           ELSE.
*.............add 2 spaces to the left
              ls_source = |  { ls_source }|.
              APPEND ls_source TO lt_source.
           ENDIF.
         WHEN 'INNER'.
           ls_source = ls_dummy.
*..........now read the join
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now read the table
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now read the AS
           ADD 1 TO ld_tabix..
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now read the letter for the table
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........add 3 spaces to the left
           ls_source = |   { ls_source }|.
           APPEND ls_source TO lt_source.
         WHEN 'LEFT'.
           ls_source = ls_dummy.
*..........now read the outer
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now read the join
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now read the table
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now read the AS
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now read the letter for the table
           ADD 1 TO ld_tabix.
           READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
           CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........add 3 spaces to the left
           ls_source = |   { ls_source }|.
           APPEND ls_source TO lt_source.
         WHEN 'ON'.
           ls_source = ls_dummy.
           DO.
*..........check for brackets
             ADD 1 TO ld_tabix.
             READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
             IF ls_dummy(1) = ')' OR
                ls_dummy(1) = '('.
                CONCATENATE ls_source ls_dummy INTO ls_source
                   SEPARATED BY space.
             ELSE.
               SUBTRACT 1 FROM ld_tabix.
             ENDIF.
*..........now read the first field
             ADD 1 TO ld_tabix.
             READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
             IF ls_dummy(9) = 'SUBSTRING'.
                CONCATENATE ls_source ls_dummy INTO ls_source
                   SEPARATED BY space.
*...............read offset, length and bracket
                DO 4 TIMES.
             ADD 1 TO ld_tabix.
             READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
             CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
                ENDDO.
             ELSE.
                CONCATENATE ls_source ls_dummy INTO ls_source
                   SEPARATED BY space.
             ENDIF.
*..........now read the relation
             ADD 1 TO ld_tabix.
             READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
             CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........now read the second field
             ADD 1 TO ld_tabix.
             READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
             CONCATENATE ls_source ls_dummy INTO ls_source
                SEPARATED BY space.
*..........check for brackets
             ADD 1 TO ld_tabix.
             READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
             IF ls_dummy(1) = ')' OR
                ls_dummy(1) = '('.
                CONCATENATE ls_source ls_dummy INTO ls_source
                   SEPARATED BY space.
             ELSE.
               SUBTRACT 1 FROM ld_tabix.
             ENDIF.
*............add 4 spaces to the left
             ls_source = |    { ls_source }|.
             APPEND ls_source TO lt_source.
*..........check the next one
             ADD 1 TO ld_tabix.
             READ TABLE lt_dummy INTO ls_dummy INDEX ld_tabix.
             IF ls_dummy = 'AND' OR
                ls_dummy = 'OR'.
               ls_source = ls_dummy.
             ELSE.
               SUBTRACT 1 FROM ld_tabix.
               CLEAR ls_source.
               EXIT.
             ENDIF.
           ENDDO.
           CLEAR ls_source.
         WHEN OTHERS.
           ls_source = ls_dummy.
*..........add 2 spaces to the left
           ls_source = |  { ls_source }|.
           APPEND ls_source TO lt_source.
       ENDCASE.
    ENDDO.
  ELSE.
    ls_source = |  FROM { gd-cds_string }|.
    APPEND ls_source TO lt_source.
  ENDIF.

*.client specified
  IF gd-clnt_spez = true.
    ls_source = |  CLIENT SPECIFIED|.
    APPEND ls_source TO lt_source.
  ENDIF.

*.Where-Clause
  IF NOT gt_where[] IS INITIAL.
    ls_source = |  WHERE|.
    APPEND ls_source TO lt_source.
    LOOP AT gt_where INTO ls_source.
*.....add 2 spaces to the left
      ls_source = |  { ls_source }|.
      APPEND ls_source TO lt_source.
    ENDLOOP.
  ENDIF.

*.Grouping
  IF NOT gt_group[] IS INITIAL.
    ls_source = |  GROUP BY|.
    APPEND ls_source TO lt_source.
    LOOP AT gt_group INTO ls_source.
*.....add 3 spaces to the left
      ls_source = |   { ls_source }|.
      APPEND ls_source TO lt_source.
    ENDLOOP.
  ENDIF.

*.Having-Clause
  IF NOT gd-having_clause IS INITIAL.
    IF STRLEN( gd-having_clause ) > 70.
      ls_source = |  having|.
      APPEND ls_source TO lt_source.
      SPLIT gd-having_clause AT space INTO TABLE lt_dummy.
      APPEND LINES OF lt_dummy TO lt_source.
    ELSE.
      ls_source = |  having|.
      APPEND ls_source TO lt_source.
      ls_source = |  { gd-having_clause }|.
      APPEND ls_source TO lt_source.
    ENDIF.
  ENDIF.

*.Order by Clause
  IF NOT gt_order[] IS INITIAL.
    ls_source = |  ORDER BY|.
    APPEND ls_source TO lt_source.
    LOOP AT gt_order INTO ls_source.
*.....add 3 spaces to the left
      ls_source = |   { ls_source }|.
      APPEND ls_source TO lt_source.
    ENDLOOP.
  ENDIF.

*.target table
  IF NOT gt_sum_up_fields[] IS INITIAL OR
     NOT gt_group_by_fields[] IS INITIAL OR
     NOT gt_aggregate_fields[] IS INITIAL.
    ls_source = |  INTO TABLE @data(result)|.
  ELSE.
    ls_source = |  INTO corresponding FIELDS OF TABLE @<all_table>|.
  ENDIF.
  APPEND ls_source TO lt_source.
  IF gd-dbcon <> space.
    ls_source = |  connection { gd-dbcon }|.
    APPEND ls_source TO lt_source.
  ENDIF.

  ls_source = |  UP TO @ld_lines rows|.
  APPEND ls_source TO lt_source.
  ls_source = |  bypassing BUFFER.|.
  APPEND ls_source TO lt_source.
  APPEND space TO lt_source.

  IF NOT gt_sum_up_fields[] IS INITIAL OR
     NOT gt_group_by_fields[] IS INITIAL OR
     NOT gt_aggregate_fields[] IS INITIAL.
     ls_source = |cl_demo_output=>display( result ).|.
  ELSE.
     ls_source = |cl_demo_output=>display( <all_table> ).|.
  ENDIF.
  APPEND ls_source TO lt_source.

*.Do pretty print on internal table
  CALL FUNCTION 'PRETTY_PRINTER'
  EXPORTING
    inctoo                        = space
  TABLES
    ntext                         = lt_source_n
    otext                         = lt_source
  EXCEPTIONS
    ENQUEUE_TABLE_FULL            = 1
    INCLUDE_ENQUEUED              = 2
    INCLUDE_READERROR             = 3
    INCLUDE_WRITEERROR            = 4
    OTHERS                        = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

*.create docking at the left
*...Container already initialised
  IF NOT gd_abap_dock IS INITIAL.
    CALL METHOD gd_abap_text->free.
    CALL METHOD gd_abap_dock->free.
    CLEAR gd_abap_dock.
    CLEAR gd_abap_text.
  ENDIF.
  CREATE OBJECT gd_abap_dock
    EXPORTING
        side      = cl_gui_docking_container=>dock_at_left
*       RATIO     = 30
        extension = 600
        repid     = c_repid
        dynnr     = ld_dynnr.
    CREATE OBJECT gd_abap_text
      EXPORTING
        parent = gd_abap_dock.
  CALL METHOD gd_abap_text->set_text_as_r3table
    EXPORTING
      table            = lt_source_n
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  gd_abap_dock_active = true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_entity_switch
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_entity_switch .

*.this form checks for the occurence of a string method in the join
*.definition. In this case tables that have an entity need to be
*.replaced.

DATA: ls_addf TYPE se16n_oj_addf.

 IF gd-ojkey <> space.
   SELECT * FROM se16n_oj_addf INTO ls_addf
       UP TO 1 ROWS
     WHERE oj_key = gd-ojkey
       AND prim_tab = gd-tab
       AND METHOD   = c_meth-string.
   ENDSELECT.
   IF sy-subrc = 0.
      gd-entity_switch = true.
   ELSE.
      CLEAR gd-entity_switch.
   ENDIF.
 ELSE.
   CLEAR gd-entity_switch.
 ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_entity
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GD_TAB
*&      <-- GD_DY_TAB1
*&---------------------------------------------------------------------*
FORM check_entity  USING    VALUE(i_tab)
                   CHANGING VALUE(e_tab).

  IF gd-entity_switch = true.
     CALL FUNCTION 'SE16N_DDL_ENTITY_GET'
       EXPORTING
         i_tab           = i_tab
       IMPORTING
         E_ENTITY        = gd-dy_entity
         E_DDLNAME       = gd-dy_ddlname.
     IF gd-dy_entity <> space.
       e_tab = gd-dy_entity.
     ELSE.
       e_tab = i_tab.
     ENDIF.
  ELSE.
     e_tab = i_tab.
  ENDIF.

ENDFORM.
