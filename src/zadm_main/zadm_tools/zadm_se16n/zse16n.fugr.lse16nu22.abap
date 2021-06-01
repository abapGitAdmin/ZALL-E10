FUNCTION se16n_formula_calculate.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_TAB) TYPE  GTB_TAB OPTIONAL
*"     VALUE(I_FORMULA_NAME) TYPE  GTB_FORMULA_NAME OPTIONAL
*"  TABLES
*"      I_TABLE
*"--------------------------------------------------------------------

  DATA: lt_formula TYPE gtb_t_formula.
  DATA: ls_formula TYPE gtb_s_formula.
  DATA: BEGIN OF ls_input,
          factor(32),
        END OF ls_input.
  DATA: lt_input LIKE ls_input OCCURS 0.
  DATA: wert     TYPE f.
  DATA: wert_i   TYPE p DECIMALS 2.
  DATA : prog(14)    VALUE 'SAPLSE16N',
         forme(15)   VALUE 'GET_EVAL_VALUES',
         formc(16)   VALUE 'GET_CHECK_VALUES',
         func(30),
         mess(80),
         position(2),
         unit        LIKE t006d-mssie,
         rc          LIKE sy-subrc.
  DATA: xroot        TYPE REF TO cx_root.
  DATA: ld_index     LIKE sy-index.
  DATA: ld_unit_count(2) TYPE n.
  DATA: ld_curr_count(2) TYPE n.
  DATA: ld_unit_text TYPE fieldname.
  DATA: ld_curr_text TYPE fieldname.
  DATA: ld_error(1).
  DATA: ld_dump(1).
  DATA: ld_xroot     TYPE REF TO cx_root.

  FIELD-SYMBOLS: <value>, <unit>, <waers>, <ref_field>.

  SELECT * FROM gtb_formula_def INTO TABLE lt_formula
    WHERE tab          = i_tab
      AND formula_name = i_formula_name
    ORDER BY pos.
  IF sy-subrc = 0.
    ld_unit_count = 0.
    ld_curr_count = 0.
    LOOP AT lt_formula INTO ls_formula.
      CONDENSE ls_formula-formula_line NO-GAPS.
      CALL FUNCTION 'CHECK_FORMULA'
        EXPORTING
          formula         = ls_formula-formula_line
          program         = prog
          routine         = formc
          unit_of_measure = unit
        IMPORTING
          funcname        = func
          message         = mess
          pos             = position
          subrc           = rc.
      IF rc IS INITIAL.
        IF ls_formula-unit <> space OR
           ls_formula-ref_field_unit <> space.
          ADD 1 TO ld_unit_count.
        ENDIF.
        IF ls_formula-waers <> space OR
           ls_formula-ref_field_waers <> space.
          ADD 1 TO ld_curr_count.
        ENDIF.
        LOOP AT i_table ASSIGNING <gd_wa>.
          ld_index = sy-tabix.
          ASSIGN COMPONENT ls_formula-fieldname OF STRUCTURE <gd_wa> TO <value>.
*.........check whether there is a reference to a unit field in the given structure
          IF ls_formula-ref_field_unit <> space.
            CONCATENATE ld_unit_count 'FORMULA_UNIT' INTO ld_unit_text.
            ASSIGN COMPONENT ld_unit_text OF STRUCTURE <gd_wa> TO <unit>.
*...........get content of reference field
            ASSIGN COMPONENT ls_formula-ref_field_unit
                  OF STRUCTURE <gd_wa> TO <ref_field>.
*...........if reference is empty, take default value
            IF sy-subrc <> 0 OR
               <ref_field> = space.
              <unit> = ls_formula-unit.
            ELSE.
              <unit> = <ref_field>.
            ENDIF.
          ELSE.
            IF ls_formula-unit <> space.
              CONCATENATE ld_unit_count 'FORMULA_UNIT' INTO ld_unit_text.
              ASSIGN COMPONENT ld_unit_text OF STRUCTURE <gd_wa> TO <unit>.
              <unit> = ls_formula-unit.
            ENDIF.
          ENDIF.
*.........reference to currency field
          IF ls_formula-ref_field_waers <> space.
            CONCATENATE ld_curr_count 'FORMULA_CURR' INTO ld_curr_text.
            ASSIGN COMPONENT ld_curr_text OF STRUCTURE <gd_wa> TO <waers>.
*...........get content of reference field
            ASSIGN COMPONENT ls_formula-ref_field_waers
                  OF STRUCTURE <gd_wa> TO <ref_field>.
*...........if reference is empty, take default value
            IF sy-subrc <> 0 OR
               <ref_field> = space.
              <waers> = ls_formula-waers.
            ELSE.
              <waers> = <ref_field>.
            ENDIF.
          ELSE.
            IF ls_formula-waers <> space.
              CONCATENATE ld_curr_count 'FORMULA_CURR' INTO ld_curr_text.
              ASSIGN COMPONENT ld_curr_text OF STRUCTURE <gd_wa> TO <waers>.
              <waers> = ls_formula-waers.
            ENDIF.
          ENDIF.
          TRY.
              CALL FUNCTION 'EVAL_FORMULA'
                EXPORTING
                  formula                 = ls_formula-formula_line
                  program                 = prog
                  routine                 = forme
                  unit_of_measure         = ls_formula-unit
                IMPORTING
                  value                   = wert
                EXCEPTIONS
                  division_by_zero        = 1
                  exp_error               = 2
                  invalid_expression      = 3
                  invalid_value           = 4
                  log_error               = 5
                  parameter_error         = 6
                  sqrt_error              = 7
                  units_not_valid         = 8
                  formula_table_not_valid = 9.
            CATCH cx_root INTO xroot.                    "#EC CATCH_ALL
              ld_xroot = xroot.
              ld_dump  = true.
*.............error in Formula
          ENDTRY.
          IF sy-subrc = 0.
            MOVE wert TO <value>.
*             MOVE wert TO wert_i.
*             move wert_i to <value>.
*            WRITE wert_i TO <value>.
            MODIFY i_table FROM <gd_wa> INDEX ld_index.
          ELSE.
            ld_error = true.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

*.if error occured, send message once
  IF ld_dump = true.
    MESSAGE ld_xroot TYPE 'I'.
  ENDIF.
  IF ld_error = true.
    MESSAGE i605(cawusl) WITH i_formula_name.
  ENDIF.

ENDFUNCTION.

FORM get_eval_values  USING    parm
CHANGING wert
subrc.

  FIELD-SYMBOLS: <f>.

  ASSIGN COMPONENT parm OF STRUCTURE <gd_wa> TO <f>.
  IF sy-subrc = 0.
    wert = <f>.
    subrc = 0.
  ELSE.
    wert = 1.
    subrc = 1.
  ENDIF.

ENDFORM.

FORM get_check_values USING parm
CHANGING subrc.
  subrc = 0.

ENDFORM.
