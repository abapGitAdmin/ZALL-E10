FUNCTION SE16N_CREATE_SELTAB.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_POOL) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_OLD_CALL) TYPE  CHAR1 DEFAULT SPACE
*"     REFERENCE(I_ESCAPE_CHAR) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_PRIMARY_TABLE) TYPE  CHAR1 DEFAULT SPACE
*"     VALUE(I_JOIN_ACTIVE) TYPE  CHAR1 DEFAULT SPACE
*"  TABLES
*"      LT_SEL STRUCTURE  SE16N_SELTAB
*"      LT_WHERE
*"----------------------------------------------------------------------
DATA: BEGIN OF LS_FIELD_INPUT,
        TABLE LIKE DFIES-TABNAME,
        MINUS(1),
        FIELD LIKE DFIES-FIELDNAME,
      END OF LS_FIELD_INPUT.
DATA: BEGIN OF LS_FIELD_INPUT_TO,
        TABLE LIKE DFIES-TABNAME,
        MINUS(1),
        FIELD LIKE DFIES-FIELDNAME,
      END OF LS_FIELD_INPUT_TO.
data: old_fieldname like lt_sel-field.
data: old_sign      like lt_sel-sign.
data: ld_blank(1) value ' '.
*data: ld_dummy(72).
data: ld_dummy type se16n_where_132.
data: and_occurs.
data: or_occurs.
DATA: LD_POS  LIKE SY-TABIX.
DATA: LD_POS1 LIKE SY-TABIX.
DATA: LD_POS2 LIKE SY-TABIX.
DATA: LD_LEN  LIKE SY-TABIX.
DATA: LD_BIT(1).
DATA: LD_TEMP LIKE LT_SEL-HIGH.
data: ld_sub1 like sy-subrc.
data: ld_sub2 like sy-subrc.
data: ld_#(1).
data: gd_new_call(1) value 'X'.
*.data for basis module
data: lt_FIELD_RANGES  TYPE RSDS_TRANGE.
data: ls_FIELD_RANGES  TYPE RSDS_RANGE.
data: lt_rsds_trange   type rsds_frange_t.
data: ls_rsds_trange   type rsds_frange.
data: lt_SELOPT        TYPE RSDS_SELOPT_T.
data: ls_SELOPT        TYPE RSDSSELOPT.
data: lt_WHERE_CLAUSES TYPE RSDS_TWHERE.
data: ls_WHERE_CLAUSES TYPE RSDS_WHERE.

FIELD-SYMBOLS: <FIELD_INPUT>, <FIELD_INPUT_HIGH>.

READ TABLE lt_sel INDEX 1.
CHECK: SY-SUBRC = 0.

REFRESH LT_WHERE.

*.WUSL needs the old logic
if i_old_call = true.
   clear gd_new_call.
endif.

if gd_new_call = true.
   ls_field_ranges-tablename = 'SE16N'.
   loop at lt_sel.
      clear ls_selopt.
*.....new fieldname
      if lt_sel-field <> old_fieldname and
         old_fieldname <> space.
         append ls_rsds_trange to ls_field_ranges-frange_t.
         refresh ls_rsds_trange-selopt_t.
      endif.
*.....this field is globally by intention to avoid side-effects
      if i_join_active = true.
         CONCATENATE 'a~' lt_sel-field
             into ls_rsds_trange-fieldname.
         CONDENSE ls_rsds_trange-fieldname NO-GAPS.
      else.
         ls_rsds_trange-fieldname = lt_sel-field.
      endif.
      ls_selopt-sign   = lt_sel-sign.
      if ls_selopt-sign = space.
         ls_selopt-sign = opt-i.
      endif.
*.....check if input length is 45 or more
      perform check_input_length using space
                                 changing lt_sel-low
                                          gd_length_changed.
      if gd_length_changed = true.
         lt_sel-option = 'CP'.
      endif.
*.....check if input length is 45 or more
      perform check_input_length using space
                                 changing lt_sel-high
                                          gd_length_changed.
      if gd_length_changed = true.
         lt_sel-option = 'CP'.
      endif.
      perform get_option using lt_sel-sign
                               lt_sel-option
                               lt_sel-high
                               I_ESCAPE_CHAR
                               lt_sel-field
                               i_pool
                         changing ls_selopt-option
                                  lt_sel-low.
*     ls_selopt-option = lt_sel-option.
      ls_selopt-low    = lt_sel-low.
      ls_selopt-high   = lt_sel-high.
      append ls_selopt to ls_rsds_trange-selopt_t.
      old_fieldname = lt_sel-field.
   endloop.
   append ls_rsds_trange to ls_field_ranges-frange_t.
   append ls_field_ranges to lt_field_ranges.

   CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_WHERE'
     EXPORTING
       FIELD_RANGES        = lt_field_ranges
     IMPORTING
       WHERE_CLAUSES       = lt_where_clauses.
   read table lt_where_clauses into ls_where_clauses index 1.
   append lines of ls_where_clauses-where_tab to lt_where.
*..check if SE16N roles are active. If so adapt the where clause
*..to the values the user is allowed to see
   if i_primary_table = true.
     perform adapt_se16n_role tables lt_where
                              using  space
                                     i_join_active.
   endif.
else.
*..this is the old coding
clear: or_occurs.

*.sort lt_sel to get Inclusive and Exclusive for one field combined
sort lt_sel by field sign option.

LOOP AT lt_sel.
     if lt_sel-sign = space.
        lt_sel-sign = opt-i.
     endif.
*LOOP AT lt_sel WHERE ( not low  is initial or
*                             not high is initial ).
*....To allow '*'-entries in database selection convert them
     IF LT_SEL-OPTION <> OPT-EQ.
        SY-SUBRC = 0.
        WHILE SY-SUBRC = 0.
           REPLACE '*' WITH '%' INTO LT_SEL-HIGH.
        ENDWHILE.
     ENDIF.
*....prepare escape symbol logic -> will lead to problems in high value
*    LD_POS1 = STRLEN( LT_SEL-HIGH ).
*    LD_POS = 0.
*    LD_LEN = 1.
*    LD_TEMP = LT_SEL-HIGH.
*    CLEAR LT_SEL-HIGH.
*    DO LD_POS1 TIMES.
*       LD_BIT = LD_TEMP+LD_POS(LD_LEN).
*       IF LD_BIT = '_'.
*          CONCATENATE LT_SEL-HIGH '#_' INTO LT_SEL-HIGH.
*       ELSE.
*          CONCATENATE LT_SEL-HIGH LD_BIT INTO LT_SEL-HIGH.
*       ENDIF.
*       ADD 1 TO LD_POS.
*    ENDDO.
     IF LT_SEL-OPTION <> OPT-EQ.
        SY-SUBRC = 0.
        WHILE SY-SUBRC = 0.
           REPLACE '*' WITH '%' INTO LT_SEL-LOW.
        ENDWHILE.
     ENDIF.
*....in case only # is entered -> different logic
     clear ld_#.
     if lt_sel-low <> lt_sel-high and
        lt_sel-low <> space       and
        lt_sel-low cs '#'.
        ld_# = true.
     endif.
*....prepare escape symbol logic
     if lt_sel-low <> lt_sel-high and
        lt_sel-low <> space       and
        ld_#       <> true        and
        i_pool      = space.
        LD_POS1 = STRLEN( LT_SEL-LOW ).
        ld_pos2 = 0.
        LD_POS = 0.
        LD_LEN = 1.
        LD_TEMP = LT_SEL-LOW.
        CLEAR LT_SEL-LOW.
        DO LD_POS1 TIMES.
           LD_BIT = LD_TEMP+LD_POS(LD_LEN).
           IF LD_BIT = '_'.
              LT_SEL-LOW+LD_POS2(2) = '#_'.
              ADD 1 TO LD_POS2.
           ELSE.
              LT_SEL-LOW+LD_POS2(LD_LEN) = LD_BIT.
           ENDIF.
           ADD 1 TO LD_POS.
           ADD 1 TO LD_POS2.
        ENDDO.
     endif.
*....If the value contains ', it would dump, because the statement would
*....be invalid: HUGO = 'MYSTRING'S' and...
     search lt_sel-low for ''''.
     if sy-subrc = 0.
        perform change_sqm changing lt_sel-low.
     endif.
     search lt_sel-high for ''''.
     if sy-subrc = 0.
        perform change_sqm changing lt_sel-high.
     endif.

*....assign value of TO-field
     ASSIGN lt_sel-HIGH TO <FIELD_INPUT_HIGH>.
*....I need the field left-justified, not right-justified
*    SHIFT <field_input_high> LEFT DELETING LEADING SPACE.
*....assign value of FROM-field
     ASSIGN lt_sel-LOW  TO <FIELD_INPUT>.
*....I need the field left-justified, not right-justified
*    SHIFT <field_input> LEFT DELETING LEADING SPACE.

*....Check if there is something to do with this line. I need space
*....values if explicitely wished.
     if lt_sel-option = space.
         check: ( NOT ( <FIELD_INPUT> IS INITIAL AND
                        <FIELD_INPUT_HIGH> IS INITIAL ) ).
     endif.
*    CHECK ( NOT ( <FIELD_INPUT> IS INITIAL OR
*                  <FIELD_INPUT> = SPACE ) AND
*            NOT ( <FIELD_INPUT_HIGH> IS INITIAL OR
*                  <FIELD_INPUT_HIGH> = SPACE ) )     or
*          ( NOT ( <FIELD_INPUT> IS INITIAL OR
*                  <FIELD_INPUT> = SPACE ) ).

*....Not first line
     IF NOT LT_WHERE IS INITIAL.
        if lt_sel-field = old_fieldname.
*..first of all I have to sort for every field by sign I and E and inside that by option
*..brackets have to be set after change of the SIGN
*..all options with I are concatenated with OR
*..all options with E are concatenated with AND
*..'I' and 'E' is concatenated with AND
           if lt_sel-sign <> old_sign.
              if or_occurs = true.
                 CONCATENATE LT_WHERE  ' ) AND' INTO LT_WHERE.
              else.
                 CONCATENATE LT_WHERE  ' AND' INTO LT_WHERE.
              endif.
              and_occurs = true.
              clear or_occurs.
           else.
              if lt_sel-sign = 'E'.
              CONCATENATE LT_WHERE  ' AND' INTO LT_WHERE.
           else.
              CONCATENATE LT_WHERE  ' OR' INTO LT_WHERE.
           endif.
           endif.
           if or_occurs <> true.
              if and_occurs = true.
                 APPEND LT_WHERE.
                 CLEAR  LT_WHERE.
                 clear and_occurs.
*                 lt_where(1) = '('.
*                 if lt_sel-sign = opt-e.
*                    concatenate lt_where 'NOT ' lt_where into lt_where.
*                 endif.
              else.
              ld_dummy(1) = '('.
              ld_dummy+2  = lt_where.
              clear lt_where.
              lt_where = ld_dummy.
                 APPEND LT_WHERE.
                 CLEAR  LT_WHERE.
                 if lt_sel-sign = opt-e.
                    concatenate 'NOT ' lt_where into lt_where.
                 endif.
                 or_occurs = true.
              endif.
           else.
              APPEND LT_WHERE.
              CLEAR  LT_WHERE.
           endif.
*.......New field
        else.
           if or_occurs = true.
              CONCATENATE LT_WHERE  ' ) AND' INTO LT_WHERE.
           else.
              CONCATENATE LT_WHERE  ' AND' INTO LT_WHERE.
           endif.
           APPEND LT_WHERE.
           CLEAR  LT_WHERE.
           if lt_sel-sign = opt-e.
              concatenate lt_where ' NOT ' into lt_where.
           endif.
           clear or_occurs.
        endif.
*....First line
     else.
        if lt_sel-sign = opt-e.
           concatenate lt_where 'NOT ' into lt_where.
*           append lt_where.
*           clear lt_where.
        endif.
     ENDIF.
*....From and To value is filled. Only BT and NB possible
     IF ( NOT ( <FIELD_INPUT> IS INITIAL OR
                <FIELD_INPUT> = SPACE ) AND
          NOT ( <FIELD_INPUT_HIGH> IS INITIAL OR
                <FIELD_INPUT_HIGH> = SPACE ) ).
*        CONCATENATE lt_sel-FIELDNAME ' BETWEEN '''
*........select with between, is able to handle '%'!!!
         if lt_sel-option = space.
            lt_sel-option = opt-bt.
         endif.
*........I need two statements because of the blanks
         if lt_sel-option = opt-bt.
            CONCATENATE lt_where lt_sel-FIELD ' BETWEEN ''' into lt_where
                     separated by space.
         else.   "option = opt-nb.
            CONCATENATE lt_where lt_sel-FIELD ' NOT BETWEEN ''' into lt_where
                     separated by space.
         endif.
         concatenate lt_where
                     <FIELD_INPUT> '''' ' AND '''
                     <FIELD_INPUT_HIGH> '''' INTO LT_WHERE.
*....only From-value is filled
     ELSEIF NOT ( <FIELD_INPUT> IS INITIAL OR
                  <FIELD_INPUT> = SPACE ).
        if lt_sel-option = space.
           lt_sel-option = opt-eq.
        endif.
        search <field_input> for '%'.
        ld_sub1 = sy-subrc.
        SEARCH <FIELD_INPUT> FOR '#'.
        ld_sub2 = sy-subrc.
        if ld_# = true.
           ld_sub2 = 0.
        endif.
        if ld_sub1 = 0 or
           ld_sub2 = 0.
           if lt_sel-option = opt-eq.
              CONCATENATE lt_where lt_sel-FIELD ' LIKE '''
                    <FIELD_INPUT> '''' INTO LT_WHERE.
           else.   "option = opt-ne
              CONCATENATE lt_where lt_sel-FIELD ' NOT LIKE '''
                    <FIELD_INPUT> '''' INTO LT_WHERE.
           endif.
        else.
*          CONCATENATE lt_sel-FIELDNAME ' = '''
*..........I need two statements because of the blanks
           CONCATENATE lt_where lt_sel-FIELD lt_sel-option '''' into lt_where
                       separated by space.
           concatenate lt_where
                       <FIELD_INPUT> '''' INTO LT_WHERE.
        endif.
        if ld_# <> true.
           SEARCH <FIELD_INPUT> FOR '#'.
           IF SY-SUBRC = 0.
              CONCATENATE LT_WHERE 'escape ''#''' INTO LT_WHERE
                          SEPARATED BY SPACE.
           ENDIF.
        ENDIF.
*....only to-value is filled (space to xxx)
     ELSEIF NOT ( <FIELD_INPUT_HIGH> IS INITIAL OR
                  <FIELD_INPUT_HIGH> = SPACE ).
        if lt_sel-option = space.
           lt_sel-option = opt-bt.
        endif.
*.......select with between, is able to handle '%'!!!
*.......I need two statements because of the blanks
        if lt_sel-option = opt-bt.
           CONCATENATE lt_where lt_sel-FIELD ' BETWEEN ''' into lt_where
                    separated by space.
        else.   "option = opt-nb.
           CONCATENATE lt_where lt_sel-FIELD ' NOT BETWEEN ''' into lt_where
                    separated by space.
        endif.
        search <field_input> for '%'.
        if sy-subrc = 0.
        else.
           concatenate lt_where
                     space '''' ' AND '''
                     <FIELD_INPUT_HIGH> '''' INTO LT_WHERE.
        endif.
        if ld_# <> true.
           SEARCH <FIELD_INPUT_HIGH> FOR '#'.
           IF SY-SUBRC = 0.
              CONCATENATE LT_WHERE 'escape ''#''' INTO LT_WHERE
                          SEPARATED BY SPACE.
           ENDIF.
        ENDIF.
*....e.g search for equal space
     elseif <field_input> is initial       and
            <field_input_high> is initial and
            not lt_sel-option is initial.
        search <field_input> for '%'.
        if sy-subrc = 0.
           CONCATENATE lt_where lt_sel-FIELD ' LIKE '''
                    <FIELD_INPUT> '''' INTO LT_WHERE.
        else.
           if lt_sel-option = space.
              lt_sel-option = opt-eq.
           endif.
*..........I need two statements because of the blanks
           CONCATENATE lt_where lt_sel-FIELD lt_sel-option '''' into lt_where
                       separated by space.
           concatenate lt_where
                       <FIELD_INPUT> '''' INTO LT_WHERE.
        endif.
     ENDIF.
     old_fieldname = lt_sel-field.
     old_sign      = lt_sel-sign.
  ENDLOOP.
  IF NOT LT_WHERE IS INITIAL.
    if or_occurs = true.
      concatenate lt_where ' )' into lt_where.
    endif.
    APPEND LT_WHERE.
    CLEAR  LT_WHERE.
  ELSE.
*   p_full_tsc = true.
  ENDIF.

endif.





ENDFUNCTION.
