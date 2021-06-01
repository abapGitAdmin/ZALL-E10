*----------------------------------------------------------------------*
***INCLUDE LSE16NF16.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  UT_FILL_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ut_fill_tc USING    VALUE(p_key)
                CHANGING it_selfields TYPE se16n_selfields_t_in.

  DATA: ld_struc LIKE dcobjdef-name.
  DATA: ls_x030l LIKE x030l.
  DATA: lt_dfies LIKE dfies OCCURS 0 WITH HEADER LINE.
  DATA: bit2 TYPE x VALUE '02'.
  DATA: is_selfields TYPE se16n_selfields.

  ld_struc    = gd-tab.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname   = ld_struc
    IMPORTING
      x030l_wa  = ls_x030l
    TABLES
      dfies_tab = lt_dfies
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  CHECK: sy-subrc = 0.

*..table is client dependent
  IF ls_x030l-flagbyte O bit2.
    gd-clnt = true.
  ELSE.
    CLEAR gd-clnt.
  ENDIF.

*..if it_selfields is provided use the sorting of this table
  IF NOT it_selfields[] IS INITIAL.
    LOOP AT it_selfields INTO is_selfields.
      READ TABLE lt_dfies
              WITH KEY fieldname = is_selfields-fieldname.
      IF sy-subrc = 0.
        CLEAR gt_selfields.
        MOVE-CORRESPONDING lt_dfies TO gt_selfields.
        IF gd-clnt           = true AND
           sy-tabix          = 1    AND
           lt_dfies-datatype = 'CLNT'.
          gt_selfields-client = true.
        ENDIF.
        IF gt_selfields-scrtext_l IS INITIAL.
          gt_selfields-scrtext_l = lt_dfies-fieldtext.
        ENDIF.
        IF gt_selfields-scrtext_m IS INITIAL.
          gt_selfields-scrtext_m = lt_dfies-fieldtext.
        ENDIF.
        gt_selfields-mark = true.
*.......caller decides what is key field and what not
        IF p_key <> true.
          IF lt_dfies-keyflag = true.
            gt_selfields-key = true.
          ENDIF.
        ELSE.
          gt_selfields-key = is_selfields-key.
        ENDIF.
*.........default sign is inclusive
        gt_selfields-sign = opt-i.
        APPEND gt_selfields.
*.....field is not in DFIES --> may be a dummy line
      ELSE.
        MOVE-CORRESPONDING is_selfields TO gt_selfields.
        IF gt_selfields-scrtext_l IS INITIAL.
          gt_selfields-scrtext_l = is_selfields-fieldname.
        ENDIF.
        IF gt_selfields-scrtext_m IS INITIAL.
          gt_selfields-scrtext_m = is_selfields-fieldname.
        ENDIF.
        gt_selfields-mark = true.
        APPEND gt_selfields.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT lt_dfies.
      CLEAR gt_selfields.
      MOVE-CORRESPONDING lt_dfies TO gt_selfields.
      IF gd-clnt           = true AND
         sy-tabix          = 1    AND
         lt_dfies-datatype = 'CLNT'.
        gt_selfields-client = true.
      ENDIF.
      IF gt_selfields-scrtext_l IS INITIAL.
        gt_selfields-scrtext_l = lt_dfies-fieldtext.
      ENDIF.
      IF gt_selfields-scrtext_m IS INITIAL.
        gt_selfields-scrtext_m = lt_dfies-fieldtext.
      ENDIF.
      gt_selfields-mark = true.
      IF lt_dfies-keyflag = true.
        gt_selfields-key = true.
      ENDIF.
      gt_selfields-reftable = lt_dfies-reftable.
      gt_selfields-reffield = lt_dfies-reffield.
*......default sign is inclusive
      gt_selfields-sign = opt-i.
      APPEND gt_selfields.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " UT_FILL_TC
*&---------------------------------------------------------------------*
*&      Form  UT_SHOW_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ut_show_selection_screen .

*.this function fills global table gt_multi_or
  REFRESH gt_multi_or.
  LOOP AT gt_multi_or_all INTO gs_multi_or_all.
    IF gs_multi_or_all-pos = 1.
      LOOP AT gs_multi_or_all-selfields INTO gs_multi_or.
        READ TABLE gt_selfields
                  WITH KEY fieldname = gs_multi_or-fieldname.
        IF sy-subrc = 0.
          gs_multi_or-mark = gt_selfields-mark.
          gs_multi_or-reftable = gt_selfields-reftable.
          gs_multi_or-reffield = gt_selfields-reffield.
          gs_multi_or-datatype = gt_selfields-datatype.
        ENDIF.
        APPEND gs_multi_or TO gt_multi_or.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
*.first time, initialize
  IF sy-subrc <> 0.
    LOOP AT gt_selfields.
      MOVE-CORRESPONDING gt_selfields TO gs_multi_or.
      CLEAR: gs_multi_or-sign,
             gs_multi_or-option,
             gs_multi_or-low,
             gs_multi_or-high,
             gs_multi_or-push.
      APPEND gs_multi_or TO gt_multi_or.
    ENDLOOP.
  ENDIF.
  gd_multi_or_pos = 1.
  REFRESH gt_multi_or_all_buf.
  gt_multi_or_all_buf[] = gt_multi_or_all[].


ENDFORM.                    " UT_SHOW_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&      Form  UT_FILL_EXPORTING_TABLES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ut_fill_exporting_tables
              CHANGING et_or_selfields TYPE se16n_or_t
                       et_or_mul_all   TYPE se16n_selfields_t_out
                       et_multi_or_all TYPE se16n_selfields_t_out.

  DATA: lt_selfields LIKE se16n_seltab OCCURS 0 WITH HEADER LINE.
  DATA: lt_or_selfields TYPE se16n_or_t.
  DATA: ls_or_selfields TYPE se16n_or_seltab.

  LOOP AT gt_multi_or_all INTO gs_multi_or_all.
    REFRESH: lt_selfields, ls_or_selfields-seltab.
    LOOP AT gs_multi_or_all-selfields INTO gs_multi_or
                     WHERE ( NOT low  IS INITIAL OR
                             NOT high IS INITIAL OR
                             NOT option IS INITIAL ).
      CLEAR lt_selfields.
      lt_selfields-field  = gs_multi_or-fieldname.
      lt_selfields-low    = gs_multi_or-low.
      lt_selfields-high   = gs_multi_or-high.
      lt_selfields-sign   = gs_multi_or-sign.
*.....default value
      if gs_multi_or-option = space.
         perform get_option using gs_multi_or-sign
                                  gs_multi_or-option
                                  gs_multi_or-high
                                  space
                                  gs_multi_or-fieldname
                                  space
                            changing gs_multi_or-option
                                     gs_multi_or-low.
      endif.
      lt_selfields-option = gs_multi_or-option.
      APPEND lt_selfields.
*.......Search for multiple input
      LOOP AT gt_or_mul_all INTO gs_or_mul_all
                         WHERE pos = gs_multi_or_all-pos.
        LOOP AT gs_or_mul_all-selfields INTO gs_or_mul
                   WHERE fieldname = lt_selfields-field
                     AND ( NOT low  IS INITIAL OR
                           NOT high IS INITIAL OR
                           NOT option IS INITIAL ).
          CLEAR lt_selfields.
          lt_selfields-field  = gs_multi_or-fieldname.
          IF gs_or_mul-low = c_space AND
             gs_or_mul-option <> space.
            lt_selfields-low  = space.
            lt_selfields-high = space.
            lt_selfields-sign   = gs_or_mul-sign.
            lt_selfields-option = gs_or_mul-option.
          ELSE.
            lt_selfields-low    = gs_or_mul-low.
            lt_selfields-high   = gs_or_mul-high.
            lt_selfields-sign   = gs_or_mul-sign.
*...........default value
            if gs_or_mul-option = space.
              perform get_option using gs_or_mul-sign
                                       gs_or_mul-option
                                       gs_or_mul-high
                                       space
                                       gs_or_mul-fieldname
                                       space
                                 changing gs_or_mul-option
                                          gs_or_mul-low.
            endif.
            lt_selfields-option = gs_or_mul-option.
          ENDIF.
          APPEND lt_selfields.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
    IF sy-subrc = 0.
      ls_or_selfields-pos = gs_multi_or_all-pos.
      APPEND LINES OF lt_selfields TO ls_or_selfields-seltab.
      APPEND ls_or_selfields TO lt_or_selfields.
    ENDIF.
  ENDLOOP.
  REFRESH et_or_selfields.
  et_or_selfields[] = lt_or_selfields[].
  et_or_mul_all[]   = gt_or_mul_all[].
  et_multi_or_all[] = gt_multi_or_all[].

ENDFORM.                    " UT_FILL_EXPORTING_TABLES
*&---------------------------------------------------------------------*
*&      Form  SEARCH_OR_FIELDNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM search_or_fieldname .

  DATA: ld_fieldname LIKE gt_selfields-fieldname.
  DATA: lt_fields LIKE sval OCCURS 0 WITH HEADER LINE.
  DATA: ld_rcode(1).
  DATA: ld_found(1).
  DATA: line_no LIKE sy-tabix.
  DATA: ld_tabix LIKE sy-tabix.
  STATICS: s_value TYPE spo_value.

  IF save_fcode_or = 'SUCH'.
    line_no = 1.
    lt_fields-tabname   = 'SE16N_SELFIELDS'.
    lt_fields-fieldname = 'FIELDNAME'.
    APPEND lt_fields.
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title = text-s01
      IMPORTING
        returncode  = ld_rcode
      TABLES
        fields      = lt_fields
      EXCEPTIONS
        OTHERS      = 1.
    CHECK: sy-subrc = 0.
    CHECK: ld_rcode = space.
    READ TABLE lt_fields INDEX 1.
    s_value = lt_fields-value.
  ELSE.
    GET CURSOR LINE line_no.
    IF line_no = 0. line_no = 1. ENDIF.
    line_no = multi_or_tc-current_line + line_no.
    IF line_no = 0. line_no = 1. ENDIF.
  ENDIF.
  CLEAR ld_found.
  CHECK: s_value <> space.
  LOOP AT gt_multi_or FROM line_no.
    TRANSLATE gt_multi_or-scrtext_l TO UPPER CASE.       "#EC TRANSLANG
    IF gt_multi_or-fieldname CS s_value OR
       gt_multi_or-scrtext_l CS s_value.
      ld_found = true.
      ld_tabix = sy-tabix.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF ld_found = true.
    multi_or_tc-top_line = ld_tabix.
  ELSE.
    MESSAGE s555(kz) WITH s_value text-s02.
  ENDIF.

ENDFORM.                    " SEARCH_OR_FIELDNAME
