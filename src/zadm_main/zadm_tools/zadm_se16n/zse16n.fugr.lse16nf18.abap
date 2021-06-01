*----------------------------------------------------------------------*
***INCLUDE LSE16NF04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_JOIN_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_TAB  text
*      <--P_GD_CDS_STRING  text
*----------------------------------------------------------------------*
FORM prepare_join_select  USING    VALUE(p_tab)
                          CHANGING ld_cds_string TYPE string.

  DATA: lt_add    LIKE se16n_oj_add OCCURS 0.
  DATA: ls_add    LIKE se16n_oj_add.
  DATA: lt_addf   LIKE se16n_oj_addf OCCURS 0.
  DATA: lt_addf2  LIKE se16n_oj_addf OCCURS 0.
  DATA: ls_addf   LIKE se16n_oj_addf.
  DATA: ls_addf2  LIKE se16n_oj_addf.
  DATA: ls_grp    LIKE se16n_output.
  DATA: ls_sum    LIKE se16n_output.
  DATA: ls_dis    LIKE se16n_oj_add_dis.
  DATA: lt_dis    LIKE se16n_oj_add_dis OCCURS 0.
  DATA: ld_letter_count TYPE sy-tabix.
  DATA: ld_line         TYPE sy-tabix.
  DATA: ld_count        TYPE sy-tabix.
  DATA: ld_save_string  TYPE string.
  DATA: ld_string       TYPE string.
  DATA: ld_letter(1).
  DATA: letter_one(1).
  DATA: letter_two(1).
  DATA: ld_error(1).

  CLEAR: gd-oj_string_filled, gd-oj_join_active.
  REFRESH: gt_table_letter.

  ld_save_string = ld_cds_string.

*.fill buffer which table has which join-letter
  gs_table_letter-tabname = gd-tab.
  gs_table_letter-letter  = 'A'.
  COLLECT gs_table_letter INTO gt_table_letter.

*.if text table exists, string could already contain a join
  IF gd-txt_join_active = true.
    ld_letter_count = 1. "start with 'C'
    gs_table_letter-tabname = gd-txt_tab.
    gs_table_letter-letter  = 'B'.
    COLLECT gs_table_letter INTO gt_table_letter.
  ELSE.
    ld_letter_count = 0. "start with 'B'
*...check for entity and ddl
    perform check_entity using    gd-tab
                         changing gd-dy_tab1.
    ld_cds_string = | { gd-dy_tab1 } AS a|.
  ENDIF.

*.each table gets a seperate letter for the join
  SELECT * FROM se16n_oj_add INTO TABLE lt_add
            WHERE oj_key   = gd-ojkey
              AND prim_tab = gd-tab
            ORDER BY add_tab_order.
  LOOP AT lt_add INTO ls_add.
*...if the same table occurs twice I cannot decide which letter it
*...belongs to, when doing the join
    READ TABLE gt_table_letter INTO gs_table_letter
           WITH KEY tabname = ls_add-add_tab.
    IF sy-subrc = 0.
      ld_error = true.
      EXIT.
    ENDIF.
    ADD 1 TO ld_letter_count.
    ld_letter = sy-abcde+ld_letter_count(1).
    gs_table_letter-tabname = ls_add-add_tab.
    gs_table_letter-letter  = ld_letter.
    COLLECT gs_table_letter INTO gt_table_letter.
*...check for entity and ddl
    perform check_entity using    ls_add-add_tab
                         changing gd-dy_tab1.
    IF ls_add-add_tab_ij = true.
      ld_string = | INNER JOIN { gd-dy_tab1 } AS { ld_letter }|.
    ELSE.
      ld_string = | LEFT OUTER JOIN { gd-dy_tab1 } AS { ld_letter }|.
    ENDIF.
    CONCATENATE ld_cds_string ld_string INTO ld_cds_string.

*...get all fields for this table for on-condition
    ld_line = 1.
    SELECT * FROM se16n_oj_addf INTO TABLE lt_addf
           WHERE oj_key   = gd-ojkey
             AND prim_tab = gd-tab
             AND add_tab  = ls_add-add_tab
             AND double_field = space.
    LOOP AT lt_addf INTO ls_addf.
*.....convert 'E' into similar 'I'
      IF ls_addf-field_sign = 'E'.
        CASE ls_addf-field_option.
          WHEN 'EQ'.
            ls_addf-field_option = 'NE'.
          WHEN 'GE'.
            ls_addf-field_option = 'LE'.
          WHEN 'LE'.
            ls_addf-field_option = 'GE'.
          WHEN 'GT'.
            ls_addf-field_option = 'LT'.
          WHEN 'LT'.
            ls_addf-field_option = 'GT'.
          WHEN 'NE'.
            ls_addf-field_option = 'EQ'.
        ENDCASE.
      ELSE.
        IF ls_addf-field_option = space.
          ls_addf-field_option = 'EQ'.
        ENDIF.
      ENDIF.
*.......add field-relation to String
      CASE ls_addf-method.
        WHEN c_meth-reference.
          READ TABLE gt_table_letter INTO gs_table_letter
                   WITH KEY tabname = ls_addf-ref_tab.
          letter_one = gs_table_letter-letter.
          READ TABLE gt_table_letter INTO gs_table_letter
                   WITH KEY tabname = ls_addf-add_tab.
          letter_two = gs_table_letter-letter.
          ld_string = | { letter_two }~{ ls_addf-field } { ls_addf-field_option } { letter_one }~{ ls_addf-value }|.
        WHEN c_meth-string.
*          ld_error = true.
          READ TABLE gt_table_letter INTO gs_table_letter
                   WITH KEY tabname = ls_addf-ref_tab.
          letter_one = gs_table_letter-letter.
          READ TABLE gt_table_letter INTO gs_table_letter
                   WITH KEY tabname = ls_addf-add_tab.
          letter_two = gs_table_letter-letter.
*.........substring-logic looks like SUBSTRING( arg, off, len ) EQ ...
*          ld_string = | { letter_one }~{ ls_addf-value }+{ ls_addf-field_offset }({ ls_addf-field_length }) = { letter_two }~{ ls_addf-field } |.
*.........SUBSTRING has a different logic than any other string operation!
          ADD 1 TO ls_addf-field_offset.
          ld_string = | SUBSTRING( { letter_one }~{ ls_addf-value }, { ls_addf-field_offset }, { ls_addf-field_length } ) = { letter_two }~{ ls_addf-field } |.
        WHEN c_meth-constant.
          READ TABLE gt_table_letter INTO gs_table_letter
                   WITH KEY tabname = ls_addf-add_tab.
          letter_two = gs_table_letter-letter.
          ld_string = | { letter_two }~{ ls_addf-field } { ls_addf-field_option } '{ ls_addf-value }'|.
        WHEN c_meth-systemvar.
          READ TABLE gt_table_letter INTO gs_table_letter
                   WITH KEY tabname = ls_addf-add_tab.
          letter_two = gs_table_letter-letter.
          ld_string = | { letter_two }~{ ls_addf-field } { ls_addf-field_option } @{ ls_addf-value }|.
        WHEN c_meth-variable.
          ld_error = true.
      ENDCASE.
      IF ld_line = 1.
        CONCATENATE ld_cds_string ' ON' ld_string INTO ld_cds_string.
      ELSE.
        CONCATENATE ld_cds_string ' AND' ld_string INTO ld_cds_string.
      ENDIF.
      ADD 1 TO ld_line.
    ENDLOOP.
*...get the constant ones that are used more than once
    REFRESH lt_addf.
    SELECT * FROM se16n_oj_addf INTO TABLE lt_addf2
           WHERE oj_key   = gd-ojkey
             AND prim_tab = gd-tab
             AND add_tab  = ls_add-add_tab
             AND double_field <> space.
    loop at lt_addf2 into ls_addf.
      ls_addf-field = ls_addf-double_field.
      append ls_addf to lt_addf.
    endloop.
*...Also get the fields grouped
    SELECT double_field FROM se16n_oj_addf
          INTO CORRESPONDING FIELDS OF TABLE lt_addf2
           WHERE oj_key   = gd-ojkey
             AND prim_tab = gd-tab
             AND add_tab  = ls_add-add_tab
             AND double_field <> space
           GROUP BY double_field.
*...now check if an OR-Clause is needed if one field occurs twice
    LOOP AT lt_addf2 INTO ls_addf2.
      ld_count = 0.
      LOOP AT lt_addf INTO ls_addf
        WHERE FIELD = ls_addf2-double_field.
        ADD 1 TO ld_count.
*.....convert 'E' into similar 'I'
        IF ls_addf-field_sign = 'E'.
          CASE ls_addf-field_option.
          WHEN 'EQ'.
            ls_addf-field_option = 'NE'.
          WHEN 'GE'.
            ls_addf-field_option = 'LE'.
          WHEN 'LE'.
            ls_addf-field_option = 'GE'.
          WHEN 'GT'.
            ls_addf-field_option = 'LT'.
          WHEN 'LT'.
            ls_addf-field_option = 'GT'.
          WHEN 'NE'.
            ls_addf-field_option = 'EQ'.
          ENDCASE.
        ELSE.
          IF ls_addf-field_option = space.
            ls_addf-field_option = 'EQ'.
          ENDIF.
        ENDIF.
*.......add field-relation to String
        CASE ls_addf-METHOD.
        WHEN c_meth-REFERENCE.
          READ TABLE gt_table_letter INTO gs_table_letter
             WITH KEY tabname = ls_addf-ref_tab.
          letter_one = gs_table_letter-letter.
          READ TABLE gt_table_letter INTO gs_table_letter
             WITH KEY tabname = ls_addf-add_tab.
          letter_two = gs_table_letter-letter.
          ld_string = | { letter_two }~{ ls_addf-FIELD } { ls_addf-field_option } { letter_one }~{ ls_addf-VALUE }|.
        WHEN c_meth-string.
*          ld_error = true.
          READ TABLE gt_table_letter INTO gs_table_letter
             WITH KEY tabname = ls_addf-ref_tab.
          letter_one = gs_table_letter-letter.
          READ TABLE gt_table_letter INTO gs_table_letter
             WITH KEY tabname = ls_addf-add_tab.
          letter_two = gs_table_letter-letter.
*.........substring-logic looks like SUBSTRING( arg, off, len ) EQ ...
*          ld_string = | { letter_one }~{ ls_addf-value }+{ ls_addf-field_offset }({ ls_addf-field_length }) = { letter_two }~{ ls_addf-field } |.
*.........SUBSTRING has a different logic than any other string operation!
          ADD 1 TO ls_addf-field_offset.
          ld_string = | SUBSTRING( { letter_one }~{ ls_addf-VALUE }, { ls_addf-field_offset }, { ls_addf-field_length } ) = { letter_two }~{ ls_addf-FIELD } |.
        WHEN c_meth-constant.
          READ TABLE gt_table_letter INTO gs_table_letter
             WITH KEY tabname = ls_addf-add_tab.
          letter_two = gs_table_letter-letter.
          ld_string = | { letter_two }~{ ls_addf-FIELD } { ls_addf-field_option } '{ ls_addf-value }'|.
        WHEN c_meth-systemvar.
          READ TABLE gt_table_letter INTO gs_table_letter
             WITH KEY tabname = ls_addf-add_tab.
          letter_two = gs_table_letter-letter.
          ld_string = | { letter_two }~{ ls_addf-FIELD } { ls_addf-field_option } @{ ls_addf-VALUE }|.
        WHEN c_meth-variable.
          ld_error = true.
        ENDCASE.
        IF ld_line = 1.
          CONCATENATE ld_cds_string ' ON ( ' ld_string INTO ld_cds_string.
        ELSE.
          IF ld_count = 1.
             CONCATENATE ld_cds_string ' AND ( ' ld_string INTO ld_cds_string.
          ELSE.
            IF ls_addf-field_sign = 'E'.
              CONCATENATE ld_cds_string ' AND' ld_string INTO ld_cds_string.
            ELSE.
              CONCATENATE ld_cds_string ' OR' ld_string INTO ld_cds_string.
            ENDIF.
          ENDIF.
          ADD 1 TO ld_count.
        ENDIF.
        ADD 1 TO ld_line.
      ENDLOOP.
      CONCATENATE ld_cds_string ' )' INTO ld_cds_string.
    ENDLOOP.
  ENDLOOP.

*.some defintions cannot be used in Joins
  IF ld_error = true.
    ld_cds_string = ld_save_string.
  ELSE.
*    ld_cds_string = ld_save_string.
    gd-oj_string_filled = true.
    gd-oj_join_active   = true.
  ENDIF.

ENDFORM.
