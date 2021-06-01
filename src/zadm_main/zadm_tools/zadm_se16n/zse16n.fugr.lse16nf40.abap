*----------------------------------------------------------------------*
***INCLUDE LGTDISF40 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_TEXT_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_TAB  text
*      <--P_LD_TXT_TAB  text
*----------------------------------------------------------------------*
FORM GET_TEXT_TABLE USING    value(I_TAB)
                    CHANGING value(LD_TXT_TAB).

*.T000 does not have a text table
  CHECK: i_tab <> 'T000'.

*..First get texttable of input table
   CALL FUNCTION 'DDUT_TEXTTABLE_GET'
     EXPORTING
       TABNAME          = i_tab
     IMPORTING
       TEXTTABLE        = ld_txt_tab.
*      CHECKFIELD       = ld_txt_field.

ENDFORM.                    " GET_TEXT_TABLE

*&---------------------------------------------------------------------*
*&      Form  SELECT_TEXT_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_SELTAB  text
*      -->P_LD_TXT_TAB  text
*----------------------------------------------------------------------*
FORM SELECT_TEXT_TABLE USING  value(LD_TXT_TAB)
                              value(ld_clnt_spez).

data: lt_where    type se16n_where_132   occurs 0 with header line.
data: lt_sel      like se16n_seltab      occurs 0 with header line.
data: lt_dd05m    like dd05m             occurs 0 with header line.
data: ls_dd05m    like dd05m.
DATA: LS_DD02V    LIKE DD02V.
DATA: LD_TEXT_POOL(1).
data: dref        type ref to data.
data: ld_txtfield type fieldname.
data: wa_fieldcat type lvc_s_fcat.
data: dy_fieldcat type lvc_s_fcat.
  DATA: lb_escape_char TYPE char1.
  FIELD-SYMBOLS: <fs>,
               <fs2>,
               <fs3>,
               <wa>  type any,
               <add> type any.

  check: ld_txt_tab <> space.

*.only do this if the JOIN was not done (e.g. because of CDS-Parameters)
*.and if it makes sense (if all fields are selected)
  check: gd-txt_join_active <> true.
  check: gd-txt_join_missing <> true.

*..runtime analysis
   perform progress using '3'.

*.get foreign key definition of text table
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      NAME                = ld_txt_tab
    IMPORTING
      DD02V_WA            = LS_DD02V
    TABLES
      DD05M_TAB           = lt_dd05m.
  IF LS_DD02V-TABCLASS = 'POOL'.
     LD_TEXT_POOL = TRUE.
  ELSE.
     CLEAR LD_TEXT_POOL.
  ENDIF.

  CLEAR: lb_escape_char.
  CREATE DATA dref TYPE (ld_txt_tab).
  assign dref->* to <add>.
  loop at <all_table> assigning <wa>.
     refresh: lt_sel.
     loop at gt_fieldcat into wa_fieldcat
                         where key = true.
*.......read foreign key
        LOOP AT LT_DD05M INTO LS_DD05M
                          WHERE CHECKTABLE = GD-TAB
                            AND FORTABLE   = LD_TXT_TAB
                            AND CHECKFIELD = WA_FIELDCAT-FIELDNAME.
*.........check if field exists -> otherwise dump in select
          READ TABLE GT_FIELDCAT_TXTTAB INTO DY_FIELDCAT
                           WITH KEY FIELDNAME = LS_DD05M-FORKEY.
*                          with key fieldname = wa_fieldcat-fieldname.
          CHECK: SY-SUBRC = 0.
          CLEAR LT_SEL.
*         lt_sel-field = wa_fieldcat-fieldname.
          LT_SEL-FIELD = LS_DD05M-FORKEY.
          ASSIGN COMPONENT wa_fieldcat-fieldname
                                 OF STRUCTURE <WA> TO <FS3>.
*.........field is longer than 132, truncate
          IF dy_fieldcat-outputlen > 132.
             dy_fieldcat-outputlen = 132.
          ENDIF.
*.........in case of non-CHAR-fields it is important to take the outputlen
*.........otherwise INT would lead to the dump
          LT_SEL-LOW(dy_fieldcat-outputlen) = <FS3>.
          APPEND LT_SEL.
*         Special handling for '+' or '*' entry
        IF lt_sel-low = '+' OR lt_sel-low = '*'.
          lb_escape_char = 'X'.
        ENDIF.
      ENDLOOP.
     ENDLOOP.
*....Add language for select on text table
     IF LD_TXT_TAB = 'T002T'.
        READ TABLE LT_SEL WITH KEY FIELD = 'SPRAS'.
        IF SY-SUBRC = 0.
           LT_SEL-LOW = SY-LANGU.
           MODIFY LT_SEL INDEX SY-TABIX.
        ENDIF.
     ELSE.
        READ TABLE GT_FIELDCAT_TXTTAB INTO DY_FIELDCAT
                           WITH KEY DATATYPE = 'LANG'
                                    KEY      = TRUE.
        IF SY-SUBRC = 0.
           LT_SEL-FIELD = DY_FIELDCAT-FIELDNAME.
           LT_SEL-LOW   = SY-LANGU.
           LT_SEL-HIGH  = SY-LANGU.
           APPEND LT_SEL.
        ENDIF.
     ENDIF.

     CALL FUNCTION 'SE16N_CREATE_SELTAB'
         EXPORTING
              I_POOL   = LD_TEXT_POOL
        i_escape_char = lb_escape_char
      TABLES
              LT_SEL   = lt_sel
              LT_WHERE = lt_where.

     if ld_clnt_spez = true.
        select single * from (ld_txt_tab)
                  client specified into <add>
                                   where (lt_where).
     else.
        select single * from (ld_txt_tab) into <add>
                                   where (lt_where).
     endif.

     check: sy-subrc = 0.
     loop at gt_txt_fields.
*.......do NOT overwrite fields from the primary table
        read table gt_fieldcat_tab
                  with key fieldname = gt_txt_fields-field
                               transporting no fields.
*.......table has field with the same name
        if sy-subrc = 0.
*.........get new fieldname
          read table gt_fieldcat_txt_double into gs_fieldcat_txt_double
                   with key org_fieldname = gt_txt_fields-field.
          check: sy-subrc = 0.
          ld_txtfield = gs_fieldcat_txt_double-new_fieldname.
        else.
          ld_txtfield = gt_txt_fields-field.
        endif.
        assign component gt_txt_fields-field
                         of structure <add> to <fs>.
        check: sy-subrc = 0.
        assign component ld_txtfield
                         of structure <wa> to <fs2>.
        check: sy-subrc = 0.
        <fs2> = <fs>.
     endloop.
  endloop.

ENDFORM.                    " SELECT_TEXT_TABLE
