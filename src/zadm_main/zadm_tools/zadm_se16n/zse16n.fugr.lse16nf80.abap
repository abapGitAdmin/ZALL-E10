*----------------------------------------------------------------------*
***INCLUDE LSE16NF80 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CREATE_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_ROLE .

data: rc like sy-subrc.

*.check if the role has been changed and we need to save the former one
  if gs_role-mode = fc-change.
    if gd_save_role <> space and
     gd_save_role <> gd_role.
    perform check_if_save using    gd_save_role
                          changing rc.
    if rc = 1.
       perform save_role using gd_save_role
                               gd_save_txt.
      endif.
    endif.
  endif.
  perform refresh_role.

*.check if the role already exists
  select single * from se16n_role_def into gs_role_def
           where se16n_role = gd_role.
  if sy-subrc = 0.
     message I101(tswusl) with gd_role.
     exit.
  endif.

*.check if new role is already locked by someone else and lock it
  perform set_enqueue using    gd_role
                      changing rc.
  check: rc = 0.
*.if successful, release the lock on the old one
  if gd_save_role <> space and
     gd_save_role <> gd_role.
     perform set_dequeue using gd_save_role.
  endif.

*.create new role
  gd_save_role = gd_role.
  gd_save_txt  = gd_role_txt.
  clear: gs_role_table, gs_role_value, gs_user_role.
  gs_role_def-se16n_role = gd_role.

  append gs_role_table to gt_role_table.
  append gs_role_value to gt_role_value.
  append gs_user_role  to gt_user_role.

  gs_role-mode = fc-change.

ENDFORM.                    " CREATE_ROLE
*&---------------------------------------------------------------------*
*&      Form  CHANGE_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TRUE  text
*----------------------------------------------------------------------*
FORM CHANGE_ROLE  USING value(p_change).

data: rc like sy-subrc.

*.check if the role has been changed and we need to save the former one
  if gs_role-mode = fc-change.
    if ( gd_save_role <> space and
       gd_save_role <> gd_role ) or
*....role in change mode is changed to display mode
     ( gd_save_role = gd_role and
       p_change     = space and
       gs_role-mode = fc-change ).
    perform check_if_save using    gd_save_role
                          changing rc.
    if rc = 1.
       perform save_role using gd_save_role
                               gd_save_txt.
      endif.
    endif.
  endif.
  perform refresh_role.

*.check if the role already exists
  select single * from se16n_role_def into gs_role_def
           where se16n_role = gd_role.
  if sy-subrc <> 0.
     message I100(tswusl) with gd_role.
     exit.
  endif.

*.check if new role is already locked by someone else
  if p_change = true.
     perform set_enqueue using    gd_role
                         changing rc.
     check: rc = 0.
  endif.
*.if successful, release the lock on the old one
  if gd_save_role <> space and
     gd_save_role <> gd_role.
     perform set_dequeue using gd_save_role.
  endif.

*.read current data
  select single * from se16n_role_def_t into gs_role_def_t
           where spras      = sy-langu
             and se16n_role = gd_role.

  select * from se16n_user_role into corresponding fields of
                         table gt_user_role
      where se16n_role = gd_role.
  select * from se16n_role_table into corresponding fields of
                         table gt_role_table
      where se16n_role = gd_role.
  select * from se16n_role_value into corresponding fields of
                         table gt_role_value_temp
      where se16n_role = gd_role.

  refresh gt_role_value.
  loop at gt_role_value_temp into gs_role_value.
     move-corresponding gs_role_value to gt_multi.
     gt_multi-option = gs_role_value-sel_option.
     append gt_multi.
*.check if same field for table already exists -> only take first entry
     Read table gt_role_value with key tabname = gs_role_value-tabname
                                     Fieldname = gs_role_value-fieldname.
     If sy-subrc <> 0.
        Append gs_role_value to gt_role_value.
     Endif.
  endloop.

*.sort by primary key
  sort gt_role_value.
  sort gt_role_table.

  if p_change <> true.
     gd_role_display = true.
  else.
     gd_role_display = space.
  endif.
  gd_role_txt  = gs_role_def_t-SE16N_ROLE_TXT.
  gd_save_role = gd_role.
  gd_save_txt  = gs_role_def_t-SE16N_ROLE_TXT.

  if p_change = true.
    gs_role-mode = fc-change.
  else.
    gs_role-mode = fc-display.
  endif.

ENDFORM.                    " CHANGE_ROLE
*&---------------------------------------------------------------------*
*&      Form  REFRESH_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_ROLE .

  refresh: gt_role_table, gt_role_value, gt_user_role, gt_multi.
  clear: gd_role_changed.

ENDFORM.                    " REFRESH_ROLE
*&---------------------------------------------------------------------*
*&      Form  DELETE_ROLE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_ROLE_TABLE .

*.check that an action has been chosen
  if gs_role_def-se16n_role <> gd_role.
    message i206(wusl).
    exit.
  endif.

 delete gt_role_table where mark1 = true.

ENDFORM.                    " DELETE_ROLE_TABLE
*&---------------------------------------------------------------------*
*&      Form  INSERT_ROLE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ROLE_TABLE .

data: ld_tabix like sy-tabix.

*.check that an action has been chosen
  if gs_role_def-se16n_role <> gd_role.
    message i206(wusl).
    exit.
  endif.

  read table gt_role_table with key mark1 = true.
  if sy-subrc = 0.
    ld_tabix = sy-tabix.
    clear gs_role_table.
    insert gs_role_table into gt_role_table index ld_tabix.
  endif.

ENDFORM.                    " INSERT_ROLE_TABLE
*&---------------------------------------------------------------------*
*&      Form  INSERT_ROLE_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_ROLE_VALUE .

data: ld_tabix like sy-tabix.

*.check that an action has been chosen
  if gs_role_def-se16n_role <> gd_role.
    message i206(wusl).
    exit.
  endif.

  read table gt_role_value with key mark2 = true.
  if sy-subrc = 0.
    ld_tabix = sy-tabix.
    clear gs_role_value.
    insert gs_role_value into gt_role_value index ld_tabix.
  endif.

ENDFORM.                    " INSERT_ROLE_VALUE
*&---------------------------------------------------------------------*
*&      Form  INSERT_USER_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_USER_ROLE .

data: ld_tabix like sy-tabix.

  read table gt_user_role with key mark3 = true.
  if sy-subrc = 0.
    ld_tabix = sy-tabix.
    clear gs_user_role.
    insert gs_user_role into gt_user_role index ld_tabix.
  endif.

ENDFORM.                    " INSERT_USER_ROLE
*&---------------------------------------------------------------------*
*&      Form  DELETE_ROLE_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_ROLE_VALUE .

*.check that an action has been chosen
  if gs_role_def-se16n_role <> gd_role.
    message i206(wusl).
    exit.
  endif.

 delete gt_role_value where mark2 = true.

ENDFORM.                    " DELETE_ROLE_VALUE
*&---------------------------------------------------------------------*
*&      Form  DELETE_USER_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_USER_ROLE .

 delete gt_user_role where mark3 = true.

ENDFORM.                    " DELETE_USER_ROLE
*&---------------------------------------------------------------------*
*&      Form  VALUE_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALUE_INPUT .

data: ld_line  like sy-tabix.
data: ls_dfies like dfies.
data: lt_multi like se16n_selfields occurs 0 with header line.
data: ls_multi like se16n_selfields.
data: ld_tab   type ddobjname.
data: ld_field like dfies-lfieldname.

*.check that an action has been chosen
  if gs_role_def-se16n_role <> gd_role.
    message i206(wusl).
    exit.
  endif.

*.get current line
  GET CURSOR LINE ld_line.
  ld_line = tab_role_value-CURRENT_LINE
            + ld_line - 1.
  IF ld_line = 0 OR ld_line < tab_role_value-CURRENT_LINE.
     EXIT.
  endif.
  read table gt_role_value into gs_role_value index ld_line.

*.get DDIC-Info for the current line
  ld_field = gs_role_value-fieldname.
  if gs_role_value-tabname = '*'.
    ld_tab = gs_role_value-dd_reftab.
  else.
    ld_tab = gs_role_value-tabname.
  endif.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      TABNAME              = ld_tab
*     FIELDNAME            = ' '
*     LANGU                = SY-LANGU
      LFIELDNAME           = ld_field
    IMPORTING
      DFIES_WA             = ls_dfies
    EXCEPTIONS
      NOT_FOUND            = 1
      INTERNAL_ERROR       = 2
      OTHERS               = 3.

  IF SY-SUBRC <> 0.
     exit.
  ENDIF.
  move-corresponding ls_dfies to gs_selfields.
*.Search for multi selection concerning this field
  loop at gt_multi where tabname   = gs_role_value-tabname
                     and fieldname = gs_selfields-fieldname.
     append gt_multi to lt_multi.
  endloop.

*.Now call popup to enter more values
  CALL FUNCTION 'SE16N_MULTI_FIELD_INPUT'
    EXPORTING
      LS_SELFIELDS          = gs_selfields
    TABLES
      LT_MULTI_SELECT       = lt_multi.
*.modify lt_multi if tab was '*'
  if gs_role_value-tabname = '*'.
    loop at lt_multi into ls_multi.
      ls_multi-tabname = '*'.
      modify lt_multi from ls_multi index sy-tabix.
    endloop.
  endif.

*.Now delete the old entries
  delete gt_multi where tabname   = gs_role_value-tabname
                    and fieldname = gs_selfields-fieldname.
  gs_role_value-push = true.
  modify gt_role_value from gs_role_value index ld_line.
  append lines of lt_multi to gt_multi.


ENDFORM.                    " VALUE_INPUT
*&---------------------------------------------------------------------*
*&      Form  F4_ROLE_TAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0240   text
*----------------------------------------------------------------------*
FORM F4_ROLE_TAB  USING VALUE(P_CALL).

data: eutype LIKE RSEDD0-DDOBJTYPE value 'T'.
data: ld_tab like RSEDD0-DDOBJNAME.

  case p_call.
     when 'T'.
        ld_tab = gs_role_table-tabname.
  endcase.
  call function 'RS_DD_F4_OBJECT'
       exporting
            objname            = ld_tab
            objtype            = eutype
            suppress_selection = 'X'
       importing
            selobjname         = ld_tab.
  case p_call.
     when 'T'.
        gs_role_table-tabname = ld_tab.
  endcase.

ENDFORM.                    " F4_ROLE_TAB
*&---------------------------------------------------------------------*
*&      Form  F4_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0248   text
*----------------------------------------------------------------------*
FORM F4_FIELD  USING VALUE(P_CALL)
                     VALUE(P_MULTI).

data: ld_tab   TYPE DDOBJNAME.
data: lt_dfies like dfies occurs 0 with header line.
data: begin of value_tab occurs 0,
        value like tsprim-field,
        text  like tsapplt-txt,
      end of value_tab.
data: retfield        like dfies-fieldname value 'VALUE'.
data: return_tab      like DDSHRETVAL occurs 0 with header line.
data: ls_role_table   type se16n_role_table_s.
data: ls_role_value   type se16n_role_value_s.
data: ld_multi_choice TYPE DDBOOL_D.
data: ld_field(40).
data: ld_visible_line like sy-tabix.
DATA: BEGIN OF dynpfields OCCURS 1.
        INCLUDE STRUCTURE dynpread.
DATA: END OF dynpfields.

*.get current line
  GET CURSOR LINE ld_line.
  ld_visible_line = ld_line.
  case p_call.
     when 'T'.
        get cursor field ld_field.
        check: ld_field = 'GS_ROLE_TABLE-FIELDNAME'.
        ld_line = tab_role_table-CURRENT_LINE
            + ld_line - 1.
        IF ld_line = 0 OR ld_line < tab_role_table-CURRENT_LINE.
          EXIT.
        endif.
        read table gt_role_table into gs_role_table index ld_line.
        ld_tab = gs_role_table-tabname.
*.......if user did not press enter after input - read the field
        if ld_tab = space.
           CLEAR dynpfields.
           REFRESH dynpfields.
           dynpfields-fieldname  = 'GS_ROLE_TABLE-TABNAME'.
           dynpfields-stepl      = ld_visible_line.
           APPEND dynpfields.
           CALL FUNCTION 'DYNP_VALUES_READ'
              EXPORTING
                dyname             = 'SAPLSE16N'
                dynumb             = sy-dynnr
                translate_to_upper = 'X'
              TABLES
                dynpfields         = dynpfields
              EXCEPTIONS
                 OTHERS             = 1.
           IF sy-subrc = 0.
              READ TABLE dynpfields INDEX 1.
              ls_role_table-tabname = dynpfields-fieldvalue.
              ld_tab = ls_role_table-tabname.
           ENDIF.
        else.
           ls_role_table = gs_role_table.
        endif.
     when 'V'.
        get cursor field ld_field.
        check: ld_field = 'GS_ROLE_VALUE-FIELDNAME'.
        ld_line = tab_role_value-CURRENT_LINE
            + ld_line - 1.
        IF ld_line = 0 OR ld_line < tab_role_value-CURRENT_LINE.
          EXIT.
        endif.
        read table gt_role_value into gs_role_value index ld_line.
        ld_tab = gs_role_value-tabname.
*.......if user did not press enter after input - read the field
        IF ld_tab = space.
          CLEAR dynpfields.
          REFRESH dynpfields.
          dynpfields-fieldname  = 'GS_ROLE_VALUE-TABNAME'.
          dynpfields-stepl      = ld_visible_line.
          APPEND dynpfields.
          CALL FUNCTION 'DYNP_VALUES_READ'
            EXPORTING
              dyname             = 'SAPLSE16N'
              dynumb             = sy-dynnr
              translate_to_upper = 'X'
            TABLES
              dynpfields         = dynpfields
            EXCEPTIONS
              OTHERS             = 1.
          IF sy-subrc = 0.
            READ TABLE dynpfields INDEX 1.
            ls_role_value-tabname = dynpfields-fieldvalue.
            ld_tab = ls_role_value-tabname.
          ENDIF.
        ELSE.
          ls_role_value = gs_role_value.
        ENDIF.
  endcase.
  case p_multi.
     when 'X'.
       ld_multi_choice = 'X'.
     when others.
       ld_multi_choice = space.
  endcase.

   CALL FUNCTION 'DDIF_FIELDINFO_GET'
     EXPORTING
       TABNAME           = ld_tab
     TABLES
       DFIES_TAB         = lt_dfies
     EXCEPTIONS
       NOT_FOUND         = 1
       OTHERS            = 2.

   check SY-SUBRC = 0.

  refresh value_tab.
  loop at lt_dfies.
     clear value_tab.
     value_tab-value = lt_dfies-fieldname.
     value_tab-text  = lt_dfies-scrtext_m.
     append value_tab.
  endloop.

* sort value_tab by text.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD         = retfield
            value_org        = 'S'
            multiple_choice  = ld_multi_choice
       TABLES
            VALUE_TAB        = value_tab
            return_tab       = return_tab
       EXCEPTIONS
            PARAMETER_ERROR  = 1
            NO_VALUES_FOUND  = 2
            OTHERS           = 3.

  IF sy-subrc = 0.
     read table return_tab index 1.
     case p_call.
       when 'T'.
          loop at return_tab.
             if sy-tabix = 1.  "First line
                gs_role_table-fieldname = return_tab-fieldval.
                modify gt_role_table from gs_role_table index ld_line.
             else.
                ls_role_table-fieldname = return_tab-fieldval.
                add 1 to ld_line.
                insert ls_role_table into gt_role_table index ld_line.
             endif.
          endloop.
       when 'V'.
          gs_role_value-fieldname = return_tab-fieldval.
          loop at return_tab.
             if sy-tabix = 1.  "First line
                gs_role_value-fieldname = return_tab-fieldval.
                modify gt_role_value from gs_role_value index ld_line.
             else.
                ls_role_value-fieldname = return_tab-fieldval.
                add 1 to ld_line.
                insert ls_role_value into gt_role_value index ld_line.
             endif.
          endloop.
     endcase.
  ENDIF.

ENDFORM.                    " F4_FIELD
*&---------------------------------------------------------------------*
*&      Form  SAVE_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_ROLE using p_role     type se16n_role
                     p_role_txt type kltxt.

data: lt_role_table like se16n_role_table occurs 0 with header line.
data: ls_role_table like se16n_role_table.
data: lt_role_value like se16n_role_value occurs 0 with header line.
data: ls_role_value like se16n_role_value.
data: lt_user_role  like se16n_user_role  occurs 0 with header line.
data: ls_user_role  like se16n_user_role.
data: ls_multi      like se16n_selfields.

*.check that an action has been chosen
  if gs_role_def-se16n_role <> gd_role.
    message i206(wusl).
    exit.
  endif.

*.main definition
  gs_role_def-crdate = sy-datlo.
  gs_role_def-cruser = sy-uname.
  gs_role_def-mandt = sy-mandt.

*.text table for main definition
  gs_role_def_t-spras          = sy-langu.
  gs_role_def_t-se16n_role     = p_role.
  gs_role_def_t-se16n_role_txt = p_role_txt.
  gs_role_def_t-mandt = sy-mandt.

*.Definition of table and column restriction
  loop at gt_role_table into gs_role_table.
     move-corresponding gs_role_table to ls_role_table.
     ls_role_table-se16n_role = p_role.
     ls_role_table-mandt = sy-mandt.
     append ls_role_table to lt_role_table.
  endloop.

*.Definition of value restrictions
  sort gt_role_value by tabname fieldname.
  loop at gt_role_value into gs_role_value.
     move-corresponding gs_role_value to ls_role_value.
     ls_role_value-se16n_role = p_role.
     ls_role_value-pos        = 1.
     ls_role_value-mandt      = sy-mandt.
*....if there is no input in gt_multi the line will not be saved !
     loop at gt_multi into ls_multi
            where tabname   = ls_role_value-tabname
              and fieldname = ls_role_value-fieldname.
        ls_role_value-sign       = ls_multi-sign.
        ls_role_value-sel_option = ls_multi-option.
        ls_role_value-low        = ls_multi-low.
        ls_role_value-high       = ls_multi-high.
        append ls_role_value to lt_role_value.
        add 1 to ls_role_value-pos.
     endloop.
  endloop.

*Definition of user assignment
  loop at gt_user_role into gs_user_role.
     move-corresponding gs_user_role to ls_user_role.
     ls_user_role-se16n_role = p_role.
     append ls_user_role to lt_user_role.
  endloop.

  perform se16n_role_write_change_doc tables lt_role_table lt_role_value
                                      using gs_role_def gs_role_def_t.

*.delete old data otherwise deleted lines will not be correct
  delete from se16n_role_table where se16n_role = p_role.
  delete from se16n_role_value where se16n_role = p_role.
  delete from se16n_user_role  where se16n_role = p_role.
  commit work.

*.now insert new lines
  modify se16n_role_def   from gs_role_def.
  modify se16n_role_def_t from gs_role_def_t.
  modify se16n_role_table from table lt_role_table.
  modify se16n_role_value from table lt_role_value.
  modify se16n_user_role  from table lt_user_role.
  commit work.

  message i200(wusl) with p_role.

*.clear global variable that a change has been done
  clear gd_role_changed.

ENDFORM.                    " SAVE_ROLE

FORM SE16N_ROLE_READ_ORIG_FOR_CD tables ct_role_def_t structure se16n_cd_se16n_role_def_t
                                        ct_role_table structure se16n_cd_se16n_role_table
                                        ct_role_value structure se16n_cd_se16n_role_value
                                 using uv_role type se16n_role
                                 changing cs_role_def type se16n_role_def
                                          cv_object_change_indicator like cdhdr-change_ind.

  select single * from se16n_role_def
    into cs_role_def
    where se16n_role = uv_role.
* role is updated or inserted
  if sy-subrc = 0.
    cv_object_change_indicator = 'U'.
  else.
    cv_object_change_indicator = 'I'.
  endif.

  select * from se16n_role_def_t into corresponding fields of table ct_role_def_t
    where se16n_role = uv_role.
  sort ct_role_def_t by spras se16n_role.

  select * from se16n_role_table into corresponding fields of table ct_role_table
    where se16n_role = uv_role.
  sort ct_role_table by se16n_role tabname fieldname.

  select * from se16n_role_value into corresponding fields of table ct_role_value
    where se16n_role = uv_role.
  sort ct_role_value by se16n_role tabname fieldname pos.

ENDFORM.

FORM SE16N_ROLE_WRITE_CHANGE_DOC tables ut_se16n_role_table structure se16n_role_table
                                        ut_se16n_role_value structure se16n_role_value
                                 using us_se16n_role_def type se16n_role_def
                                       us_se16n_role_def_t type se16n_role_def_t.

  data: lv_objectid like cdhdr-objectid.
  data: lv_object_change_indicator like cdhdr-change_ind.
  data: ls_se16n_role_def_o type se16n_role_def.
  data: lt_se16n_role_def_t_x type table of se16n_cd_se16n_role_def_t.
  data: lt_se16n_role_def_t_y type table of se16n_cd_se16n_role_def_t.
  data: lt_se16n_role_table_x type table of se16n_cd_se16n_role_table.
  data: lt_se16n_role_table_y type table of se16n_cd_se16n_role_table.
  data: lt_se16n_role_value_x type table of se16n_cd_se16n_role_value.
  data: lt_se16n_role_value_y type table of se16n_cd_se16n_role_value.
  field-symbols <ls_se16n_cd_se16n_role_def_t> type se16n_cd_se16n_role_def_t.

* read the original data first
* tables are to be sorted by (db) key
  perform se16n_role_read_orig_for_cd tables lt_se16n_role_def_t_y
                                             lt_se16n_role_table_y
                                             lt_se16n_role_value_y
                                      using  us_se16n_role_def-se16n_role
                                      changing ls_se16n_role_def_o
                                               lv_object_change_indicator.


* only select affected languages as original
* currently only one line - cd is able to process more lines
  delete lt_se16n_role_def_t_y where spras <> us_se16n_role_def_t-spras.
  append initial line to lt_se16n_role_def_t_x assigning <ls_se16n_cd_se16n_role_def_t>.
  move-corresponding us_se16n_role_def_t to <ls_se16n_cd_se16n_role_def_t>.

  move-corresponding ut_se16n_role_table[] to lt_se16n_role_table_x.
  sort lt_se16n_role_table_x by se16n_role tabname fieldname.

  move-corresponding ut_se16n_role_value[] to lt_se16n_role_value_x.
  sort lt_se16n_role_value_x by se16n_role tabname fieldname pos.

* call change docs function module
  lv_objectid = us_se16n_role_def-se16n_role.
  CALL FUNCTION 'SE16N_ROLE_WRITE_DOCUMENT' IN UPDATE TASK
    EXPORTING
      OBJECTID                      = lv_objectid
      TCODE                         = sy-tcode
      UTIME                         = sy-uzeit
      UDATE                         = sy-datum
      USERNAME                      = sy-uname
*     PLANNED_CHANGE_NUMBER         = ' '
      OBJECT_CHANGE_INDICATOR       = lv_object_change_indicator
*     PLANNED_OR_REAL_CHANGES       = ' '
*     NO_CHANGE_POINTERS            = ' '
      N_SE16N_ROLE_DEF              = us_se16n_role_def
      O_SE16N_ROLE_DEF              = ls_se16n_role_def_o
      UPD_SE16N_ROLE_DEF            = lv_object_change_indicator
      UPD_SE16N_ROLE_DEF_T          = 'U'
      UPD_SE16N_ROLE_TABLE          = 'U'
      UPD_SE16N_ROLE_VALUE          = 'U'
    TABLES
      XSE16N_ROLE_DEF_T             = lt_se16n_role_def_t_x
      YSE16N_ROLE_DEF_T             = lt_se16n_role_def_t_y
      XSE16N_ROLE_TABLE             = lt_se16n_role_table_x
      YSE16N_ROLE_TABLE             = lt_se16n_role_table_y
      XSE16N_ROLE_VALUE             = lt_se16n_role_value_x
      YSE16N_ROLE_VALUE             = lt_se16n_role_value_y
            .

ENDFORM.

FORM SE16N_ROLE_CHANGE_DOC_DEL using uv_role type se16n_role.
* is to be called only when deleting the complete role - i.e. from
* the subroutine DELETE_ROLE
  data: lv_objectid like cdhdr-objectid.
  data: ls_se16n_role_def_o type se16n_role_def.
  data: lt_se16n_role_def_t_y type table of se16n_cd_se16n_role_def_t.
  data: lt_se16n_role_table_y type table of se16n_cd_se16n_role_table.
  data: lt_se16n_role_value_y type table of se16n_cd_se16n_role_value.

* only dummy variable here because forms do not have optional parameters
  data: lv_object_change_indicator like cdhdr-change_ind.

  perform se16n_role_read_orig_for_cd tables lt_se16n_role_def_t_y
                                             lt_se16n_role_table_y
                                             lt_se16n_role_value_y
                                      using  uv_role
                                      changing ls_se16n_role_def_o
                                               lv_object_change_indicator.
* call change docs function module
  lv_objectid = uv_role.
  CALL FUNCTION 'SE16N_ROLE_WRITE_DOCUMENT' IN UPDATE TASK
    EXPORTING
      OBJECTID                      = lv_objectid
      TCODE                         = sy-tcode
      UTIME                         = sy-uzeit
      UDATE                         = sy-datum
      USERNAME                      = sy-uname
*     PLANNED_CHANGE_NUMBER         = ' '
      OBJECT_CHANGE_INDICATOR       = 'D'
*     PLANNED_OR_REAL_CHANGES       = ' '
*     NO_CHANGE_POINTERS            = ' '
*      N_SE16N_ROLE_DEF             =
      O_SE16N_ROLE_DEF              = ls_se16n_role_def_o
      UPD_SE16N_ROLE_DEF            = 'D'
      UPD_SE16N_ROLE_DEF_T          = 'D'
      UPD_SE16N_ROLE_TABLE          = 'D'
      UPD_SE16N_ROLE_VALUE          = 'D'
    TABLES
*      XSE16N_ROLE_DEF_T             = lt_se16n_role_def_t_x
      YSE16N_ROLE_DEF_T             = lt_se16n_role_def_t_y
*      XSE16N_ROLE_TABLE             = lt_se16n_role_table_x
      YSE16N_ROLE_TABLE             = lt_se16n_role_table_y
*      XSE16N_ROLE_VALUE             = lt_se16n_role_value_x
      YSE16N_ROLE_VALUE             = lt_se16n_role_value_y
            .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DELETE_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_ROLE .

data: ld_answer type c.
data: ld_text(60).

  concatenate text-rd2 gd_role into ld_text.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR                    = text-rd1
      TEXT_QUESTION               = ld_text
      TEXT_BUTTON_1               = 'Ja'(r03)
      TEXT_BUTTON_2               = 'Nein'(r04)
      DISPLAY_CANCEL_BUTTON       = 'X'
    IMPORTING
      ANSWER                      = ld_answer
    EXCEPTIONS
      TEXT_NOT_FOUND              = 1
      OTHERS                      = 2.

  IF SY-SUBRC <> 0.
     exit.
  ENDIF.
  check: ld_answer = '1'.

  perform se16n_role_change_doc_del using gd_role.

*.delete old data otherwise deleted lines will not be correct
  delete from se16n_role_def   where se16n_role = gd_role.
  delete from se16n_role_def_t where se16n_role = gd_role.
  delete from se16n_role_table where se16n_role = gd_role.
  delete from se16n_role_value where se16n_role = gd_role.
  delete from se16n_user_role  where se16n_role = gd_role.
  commit work.
  message i201(wusl) with gd_role.

  perform refresh_role.
  clear: gd_save_role, gd_role, gd_role_txt, gd_save_txt, gs_role.

ENDFORM.                    " DELETE_ROLE
*&---------------------------------------------------------------------*
*&      Form  COPY_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COPY_ROLE .

DATA: BEGIN OF FIELDS OCCURS 2.
        INCLUDE STRUCTURE SVAL.
DATA: END OF FIELDS,
      RETURNCODE(1) TYPE C,
      POPUP_TITLE(30)     TYPE C.
data: ld_new_role type se16n_role.

*.check that an action has been chosen, if not goto display
  if gs_role_def-se16n_role <> gd_role.
     perform change_role using space.
  endif.

  POPUP_TITLE       = 'Name der neuen Rolle'(100).

*.check if the role already exists
  select single * from se16n_role_def into gs_role_def
           where se16n_role = gd_role.
  if sy-subrc <> 0.
     message I002(tswusl).
     exit.
  endif.

  CLEAR FIELDS.
  FIELDS-TABNAME     = 'SE16N_ROLE_DEF'.
  FIELDS-FIELDNAME   = 'SE16N_ROLE'.
  FIELDS-VALUE       = gd_role.
  FIELDS-FIELD_ATTR  = '00'.            "eingabebereit
  APPEND FIELDS.

  CALL FUNCTION 'POPUP_GET_VALUES'
    EXPORTING
      POPUP_TITLE           = popup_title
    IMPORTING
      RETURNCODE            = returncode
    TABLES
      FIELDS                = fields
    EXCEPTIONS
      ERROR_IN_FIELDS       = 1
      OTHERS                = 2.

  IF SY-SUBRC <> 0.
     exit.
  else.
     if returncode = 'A'.
        exit.
     else.
        read table fields index 1.
        ld_new_role = fields-value.
     endif.
  ENDIF.
*.check if new role already exists
  select single * from se16n_role_def into gs_role_def
       where se16n_role = ld_new_role.
  if sy-subrc = 0.
     message i202(wusl) with ld_new_role.
     exit.
  endif.

*.first save current role
  if gd_role_display <> true.
    perform save_role using gd_save_role
                            gd_save_txt.
  endif.

*.read current data

*.get all languages
  select * from se16n_role_def_t into table gt_role_def_t
           where se16n_role = gd_role.
  select * from se16n_user_role into corresponding fields of
                     table gt_user_role
      where se16n_role = gd_role.
  select * from se16n_role_table into corresponding fields of
                     table gt_role_table
      where se16n_role = gd_role.
  select * from se16n_role_value into corresponding fields of
                     table gt_role_value_temp
      where se16n_role = gd_role.

  gs_role_def-se16n_role   = ld_new_role.
  loop at gt_role_def_t.
     gt_role_def_t-se16n_role = ld_new_role.
  endloop.
  loop at gt_role_table.
    gt_role_table-se16n_role = ld_new_role.
    modify gt_role_table index sy-tabix.
  endloop.
  loop at gt_role_value_temp.
    gt_role_value_temp-se16n_role = ld_new_role.
    modify gt_role_value_temp index sy-tabix.
  endloop.
  refresh: gt_role_value, gt_multi.
  loop at gt_role_value_temp into gs_role_value.
     move-corresponding gs_role_value to gt_multi.
     gt_multi-option = gs_role_value-sel_option.
     append gt_multi.
*.check if same field for table already exists -> only take first entry
     Read table gt_role_value with key tabname = gs_role_value-tabname
                                     Fieldname = gs_role_value-fieldname.
     If sy-subrc <> 0.
        Append gs_role_value to gt_role_value.
     Endif.
  endloop.

*.sort by primary key
  sort gt_role_value.
  loop at gt_user_role.
    gt_user_role-se16n_role = ld_new_role.
    modify gt_user_role index sy-tabix.
  endloop.
*.now post
  gd_role      = ld_new_role.
  gd_save_role = ld_new_role.
  gd_save_txt  = gs_role_def_t-SE16N_ROLE_TXT.
*.now save new role
  perform save_role using gd_role
                          gd_save_txt.

ENDFORM.                    " COPY_ROLE
*&---------------------------------------------------------------------*
*&      Form  END_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM end_1000 .

  DATA: rc LIKE sy-subrc.

  IF gd_role_changed = true.
*.check if the role has been changed and we need to save the former one
    IF gd_save_role <> space.
      PERFORM check_if_save USING    gd_save_role
      CHANGING rc.
      CASE rc.
*.....save before exit
      WHEN 1.
        PERFORM save_role USING gd_save_role
              gd_save_txt.
        SET SCREEN 0.
        LEAVE SCREEN.
*.....don't save before exit
      WHEN 2.
        SET SCREEN 0.
        LEAVE SCREEN.
*.....do not exit
      WHEN 4.
      ENDCASE.
    ENDIF.
  ELSE.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXIT_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM exit_1000 .

  DATA: ld_answer TYPE C.
  DATA: ld_text(60).

  WRITE TEXT-r05 TO ld_text.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
    TITLEBAR                    = TEXT-r05
    TEXT_QUESTION               = ld_text
    TEXT_BUTTON_1               = 'Ja'(r03)
    TEXT_BUTTON_2               = 'Nein'(r04)
    DISPLAY_CANCEL_BUTTON       = 'X'
  IMPORTING
    ANSWER                      = ld_answer
  EXCEPTIONS
    TEXT_NOT_FOUND              = 1
    OTHERS                      = 2.

  IF SY-SUBRC <> 0.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
  CASE ld_answer.
*.....abort
  WHEN 'A'.
*.....no
  WHEN '2'.
*.....yes
  WHEN '1'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TRANSPORT_ROLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TRANSPORT_ROLE .

data: ld_answer(1).
data: ld_appl(1).
data: ld_offset like sy-tabix.
data: lt_dfies  like dfies occurs 0 with header line.
data: IKO200    LIKE KO200,
      IORDER    LIKE E070-TRKORR,
      ITASK     LIKE E070-TRKORR,
      IE071K    LIKE E071K OCCURS 0 WITH HEADER LINE,
      IE071     LIKE E071  OCCURS 0 WITH HEADER LINE.

*..check if user is authorized to transport
   AUTHORITY-CHECK OBJECT 'S_TRANSPRT'
         ID 'TTYPE' FIELD 'TASK'
         ID 'ACTVT' FIELD '02'.
   if sy-subrc <> 0.
      MESSAGE I617(TK) WITH 'R3TR' 'TABU'.
      exit.
   endif.

*..ask customer if he really wants to transport
    call function 'POPUP_TO_CONFIRM'
         exporting
              titlebar       = 'Tabelleneinträge transportieren'(030)
              text_question  = 'Wollen Sie wirklich'(031)
         importing
              answer         = ld_answer
         exceptions
              text_not_found = 1
              others         = 2.

   check: ld_answer = '1'.
*..transport all tables that are necessary for this application
   define makro_fill_trans.
     clear iko200.
     IKO200-PGMID    = 'R3TR'.
     IKO200-OBJECT   = 'TABU'.
     IKO200-OBJFUNC  = 'K'.
     IKO200-OBJ_NAME = &1.
     clear ie071.
     IE071-PGMID    = 'R3TR'.
     IE071-OBJECT   = 'TABU'.
     IE071-OBJ_NAME = &1.
     IE071-OBJFUNC  = 'K'.
     APPEND IE071.
     CALL FUNCTION 'DDIF_NAMETAB_GET'
       EXPORTING
         TABNAME           = &1
       TABLES
         DFIES_TAB         = lt_dfies
       EXCEPTIONS
         OTHERS            = 1.
     check: sy-subrc = 0.
     clear ie071k.
     if &2 = '*'.
        ie071k-tabkey  = '*'.
     else.
        clear ld_appl.
        clear ld_offset.
        loop at lt_dfies where keyflag = true.
           if lt_dfies-rollname = 'SPRAS'.
              ie071k-tabkey+ld_offset(lt_dfies-leng)
                           = sy-langu.
              ld_offset = ld_offset + lt_dfies-leng.
           elseif lt_dfies-fieldname = 'MANDT'.
              ie071k-tabkey+ld_offset(lt_dfies-leng)
                           = sy-mandt.
              ld_offset = ld_offset + lt_dfies-leng.
           elseif lt_dfies-fieldname = 'SE16N_ROLE'.
              ie071k-tabkey+ld_offset(lt_dfies-leng)
                           = gd_role.
              ld_appl = true.
              ld_offset = ld_offset + lt_dfies-leng.
           else.
*.......add a * at the beginning of the next key-field
              if ld_appl = true.
                 ie071k-tabkey+ld_offset(1) = '*'.
                 clear ld_appl.
                 exit.
              endif.
           endif.
        endloop.
     endif.
     IE071K-PGMID      = 'R3TR'.
     IE071K-MASTERTYPE = 'TABU'.
     IE071K-OBJECT     = 'TABU'.
     IE071K-MASTERNAME = &1.
     IE071K-OBJNAME    = &1.
     APPEND IE071K.
   end-of-definition.

   refresh ie071.
   makro_fill_trans 'SE16N_ROLE_DEF'     '-'.
   makro_fill_trans 'SE16N_ROLE_DEF_T'   '-'.
   makro_fill_trans 'SE16N_ROLE_TABLE'   '-'.
   makro_fill_trans 'SE16N_ROLE_VALUE'   '-'.
   makro_fill_trans 'SE16N_USER_ROLE'    '-'.

   CALL FUNCTION 'TR_ORDER_CHOICE_CORRECTION'
           EXPORTING
                IV_CATEGORY            = 'CUST'
*               IV_CLI_DEP             = 'X'
           IMPORTING
                EV_ORDER               = IORDER
                EV_TASK                = ITASK
           EXCEPTIONS
                OTHERS                 = 3.
   IF SY-SUBRC <> 0.
      EXIT.
   ENDIF.
   CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
           EXPORTING
                WI_SIMULATION                  = ' '
                WI_SUPPRESS_KEY_CHECK          = ' '

                WI_TRKORR                      = ITASK
           TABLES
                WT_E071                        = IE071
                WT_E071K                       = IE071K
           EXCEPTIONS
                OTHERS                         = 68.
   IF SY-SUBRC <> 0.
       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   ENDIF.

*.If everything o.k., send message
  message s101(wusl).
ENDFORM.                    " TRANSPORT_ROLE

*&---------------------------------------------------------------------*
*&      Form  SET_ENQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GD_ROLE  text
*----------------------------------------------------------------------*
FORM SET_ENQUEUE  USING    p_role type se16n_role
                  changing value(rc).

data: begin of ls_key,
        mandt      type mandt,
        se16n_role type se16n_role,
      end of ls_key.
data: sperrdat like rstable-varkey.
constants: c_tabname type tabname value 'SE16N_ROLE_DEF'.
FIELD-SYMBOLS: <FS1>, <FS2>.

  ls_key-mandt      = sy-mandt.
  ls_key-se16n_role = p_role.

  ASSIGN LS_KEY   TO <FS1> CASTING TYPE X.
  ASSIGN SPERRDAT TO <FS2> CASTING TYPE X.

  <FS2> = <FS1>.

     CALL FUNCTION 'ENQUEUE_E_TABLEE'
       EXPORTING
*        MODE_RSTABLE         = 'E'
         TABNAME              = c_tabname
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
     if rc <> 0.
        MESSAGE i115(wusl) WITH ls_key.
     endif.

ENDFORM.                    " SET_ENQUEUE
*&---------------------------------------------------------------------*
*&      Form  SET_DEQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GD_ROLE  text
*----------------------------------------------------------------------*
FORM SET_DEQUEUE  USING  P_ROLE type se16n_role.

data: begin of ls_key,
        mandt      type mandt,
        se16n_role type se16n_role,
      end of ls_key.
data: sperrdat like rstable-varkey.
constants: c_tabname type tabname value 'SE16N_ROLE_DEF'.
FIELD-SYMBOLS: <FS1>, <FS2>.

  ls_key-mandt      = sy-mandt.
  ls_key-se16n_role = p_role.

  ASSIGN LS_KEY   TO <FS1> CASTING TYPE X.
  ASSIGN SPERRDAT TO <FS2> CASTING TYPE X.

  <FS2> = <FS1>.

  CALL FUNCTION 'DEQUEUE_E_TABLEE'
    EXPORTING
*     MODE_RSTABLE       = 'E'
      TABNAME            = c_tabname
      VARKEY             = sperrdat.
*     X_TABNAME          = ' '
*     X_VARKEY           = ' '
*     _SCOPE             = '3'
*     _SYNCHRON          = ' '
*     _COLLECT           = ' '

ENDFORM.                    " SET_DEQUEUE
*&---------------------------------------------------------------------*
*&      Form  CHECK_IF_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RC  text
*----------------------------------------------------------------------*
FORM CHECK_IF_SAVE  using     value(p_role)
                    changing  value(RC).

data: ld_answer type c.
data: ld_text(60).

  concatenate text-r02 p_role into ld_text.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR                    = text-r01
      TEXT_QUESTION               = ld_text
      TEXT_BUTTON_1               = 'Ja'(r03)
      TEXT_BUTTON_2               = 'Nein'(r04)
      DISPLAY_CANCEL_BUTTON       = 'X'
    IMPORTING
      ANSWER                      = ld_answer
    EXCEPTIONS
      TEXT_NOT_FOUND              = 1
      OTHERS                      = 2.

  IF SY-SUBRC <> 0.
     rc = 4.
  ENDIF.
  case ld_answer.
*.....abort
      when 'A'.
        rc = 4.
*.....no
      when '2'.
        rc = 2.
*.....yes
      when '1'.
        rc = 1.
  endcase.

ENDFORM.                    " CHECK_IF_SAVE
*&---------------------------------------------------------------------*
*&      Form  ROLE_GET_ROLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_SE16N_USER_ROLE  text
*----------------------------------------------------------------------*
FORM ROLE_GET_ROLES
  TABLES LT_SE16N_USER_ROLE STRUCTURE SE16N_USER_ROLE.

data: lt_values          like usvalues occurs 0 with header line.
data: ls_values          like usvalues.
data: ls_values_role     like usvalues.
data: ls_se16n_user_role like se16n_user_role.

  refresh: lt_se16n_user_role.

  CALL FUNCTION 'SUSR_USER_AUTH_FOR_OBJ_GET'
    EXPORTING
*     NEW_BUFFERING             = 3
*     MANDANT                   = SY-MANDT
      USER_NAME                 = sy-uname
      SEL_OBJECT                = 'S_BRWS_CUS'
    TABLES
      VALUES                    = lt_values
    EXCEPTIONS
      USER_NAME_NOT_EXIST       = 1
      NOT_AUTHORIZED            = 2
      INTERNAL_ERROR            = 3
      OTHERS                    = 4.
  IF SY-SUBRC <> 0.
*. no roles assigned
  ENDIF.
  loop at lt_values into ls_values
          where field = 'BRWS_KEY'
            and von   = 'ROLE'.
     loop at lt_values into ls_values_role
          where auth  = ls_values-auth
            and field = 'BRWS_NAME'.
       ls_se16n_user_role-se16n_role = ls_values_role-von.
       ls_se16n_user_role-uname      = sy-uname.
       collect ls_se16n_user_role into lt_se16n_user_role.
     endloop.
  endloop.

*..fill buffer
  refresh gt_se16n_role_table.
  if not lt_se16n_user_role[] is initial.
     select * from se16n_role_table into table gt_se16n_role_table
        for all entries in lt_se16n_user_role
              where se16n_role = lt_se16n_user_role-se16n_role
                and ( tabname    = gd-tab or
                      tabname    = gd-txt_tab or
                      tabname    = '*' ).
  endif.

*.old coding
**.'*'-User is the generic one for all users
*  select * from se16n_user_role into table lt_se16n_user_role
*                where ( uname = gd-uname or
*                        uname = '*' ).
**.get the roles assigned to this user
*  if not lt_se16n_user_role[] is initial.
**....get the limitations
*     select * from se16n_role_table into table gt_se16n_role_table
*         for all entries in lt_se16n_user_role
*               where se16n_role = lt_se16n_user_role-se16n_role
*                 and ( tabname    = gd-tab or
*                       tabname    = gd-txt_tab or
*                       tabname    = '*' ).
*  endif.
*  if not gt_se16n_role_table[] is initial.
**...check against table SE16N_ROLE_TABLE if user is not allowed at all
*    read table gt_se16n_role_table into gs_se16n_role_table
*       with key tabname      = '*'
*                fieldname    = '*'
*                no_authority = true.
*    if sy-subrc = 0.
*       ld_no_auth = true.
*    endif.
**...check if the user is not authorized for this table
*    read table gt_se16n_role_table into gs_se16n_role_table
*       with key tabname      = gd-tab
*                fieldname    = '*'
*                no_authority = true.
*    if sy-subrc = 0.
*       ld_no_auth = true.
*    endif.
**...check if there is authority for this table (if any specific
**...entry for this table exists)
*    loop at gt_se16n_role_table into gs_se16n_role_table
*          where tabname    = gd-tab
*            and ( fieldname <> space and
*                  fieldname <> '*' ).
*      exit.
*    endloop.
*    if sy-subrc = 0.
**.......ok, process table
*       clear ld_no_auth.
*    endif.
*
**...user is not authorized
*    if ld_no_auth = true.
*       set parameter id 'DTB' field space.
*       MESSAGE e419(mo) RAISING NO_PERMISSION.
*    endif.
*  endif.

ENDFORM.                    " ROLE_GET_ROLES
