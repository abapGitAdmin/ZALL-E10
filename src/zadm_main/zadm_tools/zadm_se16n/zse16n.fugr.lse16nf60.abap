*----------------------------------------------------------------------*
***INCLUDE LSE16NF60 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  own_variant_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM own_variant_delete.

data: ls_se16n_lt like se16n_lt.
data: ld_answer(1).

*.if no user entered, take current one
  if gs_se16n_lt-uname = space.
     gs_se16n_lt-uname = sy-uname.
  endif.

*.get variant
  select single * from se16n_lt into ls_se16n_lt
                  where name  = gs_se16n_lt-name
                    and tab   = gs_se16n_lt-tab
                    and uname = gs_se16n_lt-uname.
  if sy-subrc <> 0.
*....variant does not exist
     message e124(wusl) with gs_se16n_lt-name gs_se16n_lt-tab
                             gs_se16n_lt-uname.
  endif.

*.variant is user specific and belongs to another user
  if ls_se16n_lt-uspec = true and
     ls_se16n_lt-uname <> sy-uname.
     message e125(wusl) with gs_se16n_lt-name gs_se16n_lt-tab
                             gs_se16n_lt-uname.
  endif.

*.delete variant
  CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
            EXPORTING
              TEXTLINE1    = TEXT-v05
*             TEXTLINE2    = TEXT-v02
              TITEL        = TEXT-v06
            IMPORTING
              ANSWER       = LD_ANSWER
            EXCEPTIONS
              OTHERS       = 1.
  IF LD_ANSWER <> 'J'.
     EXIT.
  else.
*....delete old variant.............................................
     delete from se16n_lt
              where name  = ls_se16n_lt-name
                and tab   = ls_se16n_lt-tab
                and uname = ls_se16n_lt-uname.
     delete from se16n_ltd
              where guid = ls_se16n_lt-guid.
     message i126(wusl) with ls_se16n_lt-tab ls_se16n_lt-name
                                ls_se16n_lt-uname.
*....in case extract exists, delete it
     if not ls_se16n_lt-extract_id is initial.
       CALL METHOD cl_fagl_prot_services=>delete_data
         EXPORTING
           ed_guid      = ls_se16n_lt-extract_id
          EXCEPTIONS
            exc_db_error = 1
            others       = 2.
       IF sy-subrc <> 0.
*        Implement suitable error handling here
       ENDIF.
     endif.
  ENDIF.


ENDFORM.                    " own_variant_delete

*&---------------------------------------------------------------------*
*&      Form  layout_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM layout_delete.

  CALL SCREEN '0602' STARTING AT 36  9.

ENDFORM.                    " layout_delete

*&---------------------------------------------------------------------*
*&      Form  delete_variant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_variant using value(mode).

data: ls_se16n_lt  like se16n_lt.
data: ld_answer(1).

  select single * from se16n_lt into ls_se16n_lt
                  where name  = gs_se16n_lt-name
                    and tab   = gs_se16n_lt-tab
                    and uname = gs_se16n_lt-uname.

*.if variant does not yet exist, no problem
  check: sy-subrc = 0.

*.variant is user specific and belongs to another user
  if ls_se16n_lt-uspec = true and
     ls_se16n_lt-uname <> sy-uname.
     message i125(wusl) with gs_se16n_lt-name gs_se16n_lt-tab
                             gs_se16n_lt-uname.
     exit.
  endif.

*.Variant exists and is not user specific
  CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
            EXPORTING
              TEXTLINE1    = TEXT-v01
              TEXTLINE2    = TEXT-v02
              TITEL        = TEXT-v03
            IMPORTING
              ANSWER       = LD_ANSWER
            EXCEPTIONS
              OTHERS       = 1.
  IF LD_ANSWER <> 'J'.
     EXIT.
  else.
*....delete old variant.............................................
     delete from se16n_lt
                  where name  = gs_se16n_lt-name
                    and tab   = gs_se16n_lt-tab
                    and uname = gs_se16n_lt-uname.
     delete from se16n_ltd
                  where guid = ls_se16n_lt-guid.
  endif.


ENDFORM.                    " delete_variant
*&---------------------------------------------------------------------*
*&      Form  own_variant_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM own_variant_f4.

data: lt_se16n_lt like se16n_lt occurs 0.
data: ls_se16n_lt like se16n_lt.
data: return_tab  like DDSHRETVAL occurs 0 with header line.
data: lt_where(72) occurs 0 with header line.
data: field        type string.
data: begin of value_tab occurs 0,
        count type char10, " type sytabix,
        name type se16n_lt_name,
        tab  type se16n_tab,
        uname type syuname,
        uspec like se16n_lt-uspec,
        extract_id type guid16,
        txt   like se16n_lt-txt,
      end of value_tab.
DATA: BEGIN OF dynpfields OCCURS 1.
      INCLUDE STRUCTURE dynpread.
DATA: END OF dynpfields.

*..read field tab
   CLEAR dynpfields.
   REFRESH dynpfields.
   if sy-dynnr = '0601' or
      sy-dynnr = '0602'.
      dynpfields-fieldname  = 'GS_SE16N_LT-TAB'.
   else.
      dynpfields-fieldname  = 'GD-TAB'.
   endif.
   APPEND dynpfields.
   CALL FUNCTION 'DYNP_VALUES_READ'
     EXPORTING
       DYNAME                         = 'SAPLSE16N'
       DYNUMB                         = sy-dynnr
       TRANSLATE_TO_UPPER             = true
     TABLES
       DYNPFIELDS                     = dynpfields.

   read table dynpfields index 1.
   gs_se16n_lt-tab = dynpfields-fieldvalue.

*..only show variants for extracts in case this is needed
   if gd_extract-read = true.
     field = |extract_id ne '0000000000000000'|.
     append field to lt_where.
   endif.

   if gs_se16n_lt-tab <> space.
      if gs_Se16n_lt-tab cs '*'.
         ls_se16n_lt-tab = gs_se16n_lt-tab.
         WHILE SY-SUBRC = 0.
            REPLACE '*' WITH '%' INTO ls_se16n_lt-tab.
         ENDWHILE.
         select * from se16n_lt appending corresponding fields
                                    of table value_tab
                          where   tab   like ls_se16n_lt-tab
                            and ( uname = sy-uname or
                                  uspec <> true )
                            and (lt_where).
      else.
         select * from se16n_lt appending corresponding fields
                                    of table value_tab
                          where   tab   = gs_se16n_lt-tab
                            and ( uname = sy-uname or
                                  uspec <> true )
                            and (lt_where).
      endif.
   else.
      select * from se16n_lt appending corresponding fields
                                    of table value_tab
                          where ( uname = sy-uname or
                                  uspec <> true )
                            and (lt_where).
   endif.

   loop at value_tab.
     value_tab-count = sy-tabix.
     modify value_tab index sy-tabix.
   endloop.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD               = 'COUNT'
      VALUE_ORG              = 'S'
    TABLES
      VALUE_TAB              = value_tab
*     FIELD_TAB              =
      RETURN_TAB             = return_tab
*     DYNPFLD_MAPPING        =
    EXCEPTIONS
      PARAMETER_ERROR        = 1
      NO_VALUES_FOUND        = 2
      OTHERS                 = 3.

  IF SY-SUBRC = 0.
     read table return_tab index 1.
*    read table value_tab index return_tab-recordpos.
     read table value_tab with key count = return_tab-fieldval.
     if sy-subrc = 0.
        gs_se16n_lt-tab   = value_tab-tab.
        gs_se16n_lt-name  = value_tab-name.
        gs_se16n_lt-uname = value_tab-uname.
        gs_se16n_lt-uspec = value_tab-uspec.
        gs_se16n_lt-extract_id   = value_tab-extract_id. "GRUBERSA
        gs_se16n_lt-txt   = value_tab-txt.
        CLEAR dynpfields.
        REFRESH dynpfields.
        dynpfields-fieldname  = 'GS_SE16N_LT-TAB'.
        dynpfields-fieldvalue = gs_se16n_lt-tab.
        APPEND dynpfields.
        case sy-dynnr.
          when '0600'.
             dynpfields-fieldname  = 'GS_SE16N_LT-USPEC'.
             dynpfields-fieldvalue = value_tab-uspec.
             APPEND dynpfields.
             dynpfields-fieldname  = 'GS_SE16N_LT-TXT'.
             dynpfields-fieldvalue = value_tab-txt.
             APPEND dynpfields.
             dynpfields-fieldname  = 'GS_SE16N_LT-UNAME'.
             dynpfields-fieldvalue = value_tab-uname.
             APPEND dynpfields.
          when '0601'.
             dynpfields-fieldname  = 'GS_SE16N_LT-UNAME'.
             dynpfields-fieldvalue = value_tab-uname.
             APPEND dynpfields.
          when '0602'.
             dynpfields-fieldname  = 'GS_SE16N_LT-UNAME'.
             dynpfields-fieldvalue = value_tab-uname.
             APPEND dynpfields.
        endcase.
        CALL FUNCTION 'DYNP_VALUES_UPDATE'
            EXPORTING
               dyname     = 'SAPLSE16N'
               dynumb     = sy-dynnr
            TABLES
               dynpfields = dynpfields.
     endif.
  ENDIF.


ENDFORM.                    " own_variant_f4
*&---------------------------------------------------------------------*
*&      Form  layout_save
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM layout_save.


*.Send popup to get layout name and text
  CALL SCREEN '0600' STARTING AT 36  9.
*
ENDFORM.                    " layout_save
*&---------------------------------------------------------------------*
*&      Form  create_variant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM own_variant_create.

data: ls_se16n_lt  like se16n_lt.
data: ls_se16n_ltd like se16n_ltd.
DATA: LS2_SE16N_LTD LIKE SE16N_LTD.
data: lt_se16n_ltd like se16n_ltd occurs 0.
data: ld_timestamp type se16n_id.
data: ld_txt       type se16n_lt_name.
data: ld_count(3)  type n.
data: ld_answer(1).
field-symbols: <f>.

*.get unique timestamp
  do.
    GET TIME STAMP FIELD LD_TIMESTAMP.
    select single * from se16n_lt into ls_se16n_lt
                         where guid = ld_timestamp.
    if sy-subrc <> 0.
      exit.
    endif.
  enddo.

*.check if variant already exists.......................................
*.User specifc
  gs_se16n_lt-tab = gd-tab.
  if gs_se16n_lt-uname = space.
     gs_se16n_lt-uname = sy-uname.
  endif.
  select single * from se16n_lt into ls_se16n_lt
                  where name  = gs_se16n_lt-name
                    and tab   = gs_se16n_lt-tab
                    and uname = gs_se16n_lt-uname.

*.if variant does not yet exist, no problem
  if sy-subrc = 0.
*....variant is user specific and belongs to another user
     if ls_se16n_lt-uspec = true and
        ls_se16n_lt-uname <> sy-uname.
        message e125(wusl) with gs_se16n_lt-name gs_se16n_lt-tab
                             gs_se16n_lt-uname.
     endif.

*....Variant exists and is not user specific
     CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
            EXPORTING
              TEXTLINE1    = TEXT-v01
              TEXTLINE2    = TEXT-v02
              TITEL        = TEXT-v03
            IMPORTING
              ANSWER       = LD_ANSWER
            EXCEPTIONS
              OTHERS       = 1.
     IF LD_ANSWER <> 'J'.
        EXIT.
     else.
*....delete old variant.............................................
        delete from se16n_lt
                  where name  = gs_se16n_lt-name
                    and tab   = gs_se16n_lt-tab
                    and uname = gs_se16n_lt-uname.
        delete from se16n_ltd
                  where guid = ls_se16n_lt-guid.
     endif.
  endif.

*.Fill header data for variant..........................................
  clear ls_se16n_lt.
  ls_se16n_lt-name  = gs_se16n_lt-name.
  ls_se16n_lt-txt   = gs_se16n_lt-txt.
  ls_se16n_lt-uspec = gs_se16n_lt-uspec.
  ls_se16n_lt-guid  = ld_timestamp.
  ls_se16n_lt-tab   = gd-tab.
  ls_se16n_lt-uname = gs_se16n_lt-uname.

*.Fill general data for variant.........................................
  perform init_vari_fields.
  loop at gt_vari_fields.
     ls_Se16n_ltd-guid  = ld_timestamp.
     ls_se16n_ltd-field = gt_vari_fields-fieldname.
     ls_se16n_ltd-sign  = 'I'.
     ls_se16n_ltd-optio = 'EQ'.
     assign (gt_vari_fields-fieldname) to <f>.
     ls_se16n_ltd-low   = <f>.
     ls_se16n_ltd-high  = <f>.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.

*.Fill data for variant.................................................
  ls_se16n_ltd-guid = ld_timestamp.
  loop at gt_selfields where ( not low  is initial or
                               not high is initial or
                               not option is initial ) and
                               setid is initial.
     ld_count = 1.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-counter = ld_count.
     ls_se16n_ltd-sign    = gt_selfields-sign.
     ls_se16n_ltd-optio   = gt_selfields-option.
     ls_se16n_ltd-low     = gt_selfields-low.
     ls_se16n_ltd-high    = gt_selfields-high.
     append ls_se16n_ltd to lt_se16n_ltd.
*....Search for multiple input
     loop at gt_multi where fieldname = gt_selfields-fieldname
                        and ( not low  is initial or
                              not high is initial ).
        add 1 to ld_count.
        ls_se16n_ltd-low     = gt_multi-low.
        ls_se16n_ltd-high    = gt_multi-high.
        ls_se16n_ltd-optio   = gt_multi-option.
        ls_se16n_ltd-sign    = gt_multi-sign.
        ls_se16n_ltd-counter = ld_count.
        append ls_se16n_ltd to lt_se16n_ltd.
     endloop.
  endloop.
*.fill setid into separat line
  loop at gt_selfields where not setid is initial.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
*....there must not be another entry for this fieldname
     ls_se16n_ltd-counter = 0.
     ls_se16n_ltd-sign    = gt_selfields-sign.
     ls_se16n_ltd-optio   = gt_selfields-option.
     ls_se16n_ltd-low     = gt_selfields-setid.
     ls_se16n_ltd-high    = c_setid_ltd.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.

*.Store the fields that are not output fields (perhaps than the others)
  ls_se16n_ltd-guid = ld_timestamp.
  LS_SE16N_LTD-COUNTER = 1.
  loop at gt_selfields where mark <> true.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_mark.
     ls_se16n_ltd-low     = space.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.

*.store the summation fields
  loop at gt_selfields where curr_add_up = true.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_curr.
     ls_se16n_ltd-low     = space.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
  loop at gt_selfields where quan_add_up = true.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_quan.
     ls_se16n_ltd-low     = space.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
*.store the summarization and group-by fields
  loop at gt_selfields where group_by = true.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_grup.
     ls_se16n_ltd-low     = space.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
  loop at gt_selfields where order_by = true.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_orde.
     ls_se16n_ltd-low     = space.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
  loop at gt_selfields where sum_up = true.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_summ.
     ls_se16n_ltd-low     = space.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
  loop at gt_selfields where having_option <> space.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_have.
     ls_se16n_ltd-low     = gt_selfields-having_option.
     ls_se16n_ltd-high    = gt_selfields-having_value.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
  loop at gt_selfields where toplow <> space.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_top.
     ls_se16n_ltd-low     = gt_selfields-toplow.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
  loop at gt_selfields where sortorder <> space.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_sor.
     ls_se16n_ltd-low     = gt_selfields-sortorder.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
  loop at gt_selfields where aggregate <> space.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_aggr.
     ls_se16n_ltd-low     = gt_selfields-aggregate.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.
  loop at gt_selfields where no_input_conversion <> space.
     ls_se16n_ltd-field   = gt_selfields-fieldname.
     ls_se16n_ltd-optio   = c_noco.
     ls_se16n_ltd-low     = gt_selfields-no_input_conversion.
     LD_COUNT = 0.
     LOOP AT LT_SE16N_LTD INTO LS2_SE16N_LTD
                    WHERE FIELD = GT_SELFIELDS-FIELDNAME.
         LD_COUNT = LS2_SE16N_LTD-COUNTER.
     ENDLOOP.
     ADD 1 TO LD_COUNT.
     LS_SE16N_LTD-COUNTER = LD_COUNT.
     append ls_se16n_ltd to lt_se16n_ltd.
  endloop.

*.Now post the variant on the database
  insert se16n_lt from ls_se16n_lt.
  if sy-subrc = 0.
     insert se16n_ltd from table lt_se16n_ltd.
     if sy-subrc = 0.
        commit work.
        message i116(wusl) with gs_se16n_lt-name.
     endif.
  endif.
  if sy-subrc <> 0.
     rollback work.
  endif.

ENDFORM.                    " create_variant
*&---------------------------------------------------------------------*
*&      Form  init_vari_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_vari_fields.

  refresh gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-TAB'.
  gt_vari_fields-selname   = 'I_TAB'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-NO_TXT'.
  gt_vari_fields-selname   = 'I_NO_TXT'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-READ_CLNT'.
  gt_vari_fields-selname   = 'I_CLNT'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-EDIT'.
  gt_vari_fields-selname   = 'I_EDIT'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-VARIANT'.
  gt_vari_fields-selname   = 'I_VARI'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-MAX_LINES'.
  gt_vari_fields-selname   = 'I_MAX'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-TECH_NAMES'.
  gt_vari_fields-selname   = 'I_TECH'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-NO_CONVEXIT'.
  gt_vari_fields-selname   = 'I_CONV'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-SCROLL'.
  gt_vari_fields-selname   = 'I_SCROLL'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-TECH_VIEW'.
  gt_vari_fields-selname   = 'I_TVIEW'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-TECH_FIRST'.
  gt_vari_fields-selname   = 'I_TFIRST'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-HANA_ACTIVE'.
  gt_vari_fields-selname   = 'I_HACT'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-DBCON'.
  gt_vari_fields-selname   = 'I_DBCON'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-OJKEY'.
  gt_vari_fields-selname   = 'I_OJKEY'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-MIN_COUNT'.
  gt_vari_fields-selname   = 'I_MINCNT'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-FDA'.
  gt_vari_fields-selname   = 'I_FDA'.
  append gt_vari_fields.
  gt_vari_fields-fieldname = 'GD-FORMULA_NAME'.
  gt_vari_fields-selname   = 'I_FORMUL'.
  append gt_vari_fields.

ENDFORM.                    " init_vari_fields
*&---------------------------------------------------------------------*
*&      Form  get_own_variant
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM own_variant_get.

data: ls_se16n_lt   like se16n_lt.
data: ls_se16n_ltd  like se16n_ltd.
data: lt_se16n_ltd  like se16n_ltd occurs 0.
data: ld_save_field type fieldname.
data: ld_tabix      like sy-tabix.
data: ld_save_hana.
field-symbols: <f>.

*.if no user entered take current one
  if gs_se16n_lt-uname = space.
     gs_se16n_lt-uname = sy-uname.
  endif.

*.get header
  select single * from se16n_lt into ls_se16n_lt
                                where name  = gs_se16n_lt-name
                                  and tab   = gs_se16n_lt-tab
                                  and uname = gs_se16n_lt-uname.
  if sy-subrc <> 0.
     message e124(wusl) with gs_se16n_lt-name gs_se16n_lt-tab
                             gs_se16n_lt-uname.
  endif.

*.check if variant is user specific
  if ls_se16n_lt-uspec = true.
*...if user is not the same - send error
    if ls_se16n_lt-uname <> sy-uname.
      message e125(wusl) with gs_se16n_lt-name gs_se16n_lt-tab
                              ls_se16n_lt-uname.
    endif.
  endif.

*.first initialise
  clear: gd-tab_save.
  gd-tab = ls_se16n_lt-tab.
  perform fill_tc_0100.

*.get data
  select * from se16n_ltd into table lt_se16n_ltd
                          where guid = ls_se16n_lt-guid.
  check: sy-subrc = 0.

*.get the single fields
  perform init_vari_fields.

*.save if se16h or se16n
  ld_save_hana = gd-hana_active.
*.check if layout is for correct tcode
  read table gt_vari_fields with key fieldname = 'GD-HANA_ACTIVE'.
  read table lt_se16n_ltd into ls_se16n_ltd
                with key field = gt_vari_fields-fieldname.
  if sy-subrc = 0.
     if ld_save_hana <> LS_SE16N_LTD-LOW.
        message i134(wusl).
        exit.
     endif.
  else.
*...gd-hana_active is not in layout --> old from se16N
    if ld_save_hana = true.
       message i134(wusl).
       exit.
    endif.
  endif.

  loop at gt_vari_fields.
     read table lt_se16n_ltd into ls_se16n_ltd
                with key field = gt_vari_fields-fieldname.
     if sy-subrc = 0.
        assign (gt_vari_fields-fieldname) to <f>.
*.......in case no client specific select -> do not allow it
        IF GT_VARI_FIELDS-FIELDNAME = 'GD-READ_CLNT' AND
           GD-NO_CLNT_ANYMORE       = TRUE.
           CLEAR <F>.
        ELSE.
           <F> = LS_SE16N_LTD-LOW.
        ENDIF.
*.......this line has been used -> delete it
        delete lt_se16n_ltd index sy-tabix.
     endif.
  endloop.

  refresh: gt_multi.

  sort lt_se16n_ltd by guid field counter.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio <> c_mark
                         and optio <> c_quan
                         and optio <> c_curr
                         and optio <> c_summ
                         and optio <> c_have
                         and optio <> c_grup
                         and optio <> c_top
                         and optio <> c_sor
                         and optio <> c_orde
                         and optio <> c_aggr
                         and optio <> c_noco.
*....New field -> entry
     if ls_se16n_ltd-field <> ld_save_field.
        read table gt_selfields with key fieldname = ls_se16n_ltd-field.
        if sy-subrc = 0.
           IF GD-CLNT            = TRUE AND
              GD-NO_CLNT_ANYMORE = TRUE.
              CHECK: GT_SELFIELDS-DATATYPE <> 'CLNT'.
           ENDIF.
           gt_selfields-sign   = ls_se16n_ltd-sign.
           gt_selfields-option = ls_se16n_ltd-optio.
           if ls_se16n_ltd-high <> c_setid_ltd.
              gt_selfields-low    = ls_se16n_ltd-low.
              gt_selfields-high   = ls_se16n_ltd-high.
           else.
              gt_selfields-setid  = ls_se16n_ltd-low.
           endif.
           modify gt_selfields index sy-tabix.
        endif.
*....Same field again -> gt_multi-entry
     else.
*.......set pushbutton to more info
        read table gt_selfields with key fieldname = ls_se16n_ltd-field.
        if sy-subrc = 0.
           IF GD-CLNT            = TRUE AND
              GD-NO_CLNT_ANYMORE = TRUE.
              CHECK: GT_SELFIELDS-DATATYPE <> 'CLNT'.
           ENDIF.
           gt_selfields-push = true.
           modify gt_selfields index sy-tabix.
        ELSE.
           IF GD-CLNT            = TRUE AND
              GD-NO_CLNT_ANYMORE = TRUE.
              CHECK: GT_SELFIELDS-DATATYPE <> 'CLNT'.
           ENDIF.
        endif.
        gt_multi-fieldname = ls_se16n_ltd-field.
        gt_multi-sign      = ls_se16n_ltd-sign.
        gt_multi-option    = ls_se16n_ltd-optio.
        gt_multi-low       = ls_se16n_ltd-low.
        gt_multi-high      = ls_se16n_ltd-high.
        append gt_multi.
     endif.
     ld_save_field = ls_se16n_ltd-field.
  endloop.
*.Now get information about output fields
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_mark.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         clear gt_selfields-mark.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
*.Now get information about line summary fields
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_quan.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-quan_add_up = true.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_curr.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-curr_add_up = true.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
*.Now get information about group by and summary
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_summ.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-sum_up = true.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_have.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-having_option = ls_se16n_ltd-low.
         gt_selfields-having_value  = ls_se16n_ltd-high.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_grup.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-group_by = true.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_orde.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-order_by = true.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_top.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-toplow = ls_se16n_ltd-low.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_sor.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-sortorder = ls_se16n_ltd-low.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_aggr.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-aggregate = ls_se16n_ltd-low.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.
  loop at lt_se16n_ltd into ls_se16n_ltd
                       where optio = c_noco.
      read table gt_selfields with key fieldname = ls_se16n_ltd-field.
      if sy-subrc = 0.
         gt_selfields-no_input_conversion = ls_se16n_ltd-low.
         modify gt_selfields index sy-tabix.
      endif.
  endloop.

ENDFORM.                    " get_own_variant
*&---------------------------------------------------------------------*
*&      Form  layout_get
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM layout_get.

  CALL SCREEN '0601' STARTING AT 36  9.

ENDFORM.                    " layout_get
