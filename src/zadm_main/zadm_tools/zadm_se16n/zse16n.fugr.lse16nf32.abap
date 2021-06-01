*----------------------------------------------------------------------*
***INCLUDE LSE16NF32.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FORMULA_ADD_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM formula_add_fields .

  DATA: wa_fieldcat      TYPE lvc_s_fcat.
  DATA: ld_unit_count(2) TYPE n.
  DATA: ld_curr_count(2) TYPE n.
  DATA: ld_unit_text     TYPE fieldname.
  DATA: ld_curr_text     TYPE fieldname.

*.If Formula is active, add fields needed for Formula
  IF NOT gd-formula_name IS INITIAL.
    SELECT * FROM gtb_formula_def INTO TABLE gt_formula
      WHERE tab          = gd-tab
        AND formula_name = gd-formula_name
      ORDER BY pos.
    IF sy-subrc = 0.
*.....If there is more than one line, each line could have its own
*.....unit or currency --> count up to distinguish
      ld_unit_count = 0.
      ld_curr_count = 0.
      LOOP AT gt_formula INTO gs_formula.
        CLEAR wa_fieldcat.
        wa_fieldcat-fieldname = gs_formula-fieldname.
        wa_fieldcat-ref_table = gs_formula-ref_tab.
        wa_fieldcat-ref_field = gs_formula-ref_field.
        wa_fieldcat-coltext   = wa_fieldcat-fieldname.
        IF gs_formula-unit <> space OR
           gs_formula-ref_field_unit <> space.
          ADD 1 TO ld_unit_count.
          CONCATENATE ld_unit_count 'FORMULA_UNIT' INTO ld_unit_text.
          wa_fieldcat-qfieldname = ld_unit_text.
        ENDIF.
        IF gs_formula-waers <> space OR
           gs_formula-ref_field_waers <> space.
          ADD 1 TO ld_curr_count.
          CONCATENATE ld_curr_count 'FORMULA_CURR' INTO ld_curr_text.
          wa_fieldcat-cfieldname = ld_curr_text.
        ENDIF.
*.......check that field does not yet exist
        READ TABLE gt_fieldcat
                   WITH KEY fieldname = wa_fieldcat-fieldname
                   TRANSPORTING NO FIELDS.
        IF sy-subrc <> 0.
          COLLECT wa_fieldcat INTO gt_fieldcat.
        ELSE.
*.........if so, create new name
          CONCATENATE '1' wa_fieldcat-fieldname
                       INTO wa_fieldcat-fieldname.
          CONDENSE wa_fieldcat-fieldname.
          COLLECT wa_fieldcat INTO gt_fieldcat.
        ENDIF.
*.......if unit or currency field is filled, add additional column
*.......for reference
        IF gs_formula-unit <> space OR
           gs_formula-ref_field_unit <> space.
          CLEAR wa_fieldcat.
          wa_fieldcat-fieldname = ld_unit_text.
          wa_fieldcat-ref_table = 'GTB_S_FORMULA'.
          wa_fieldcat-ref_field = 'UNIT'.
          COLLECT wa_fieldcat INTO gt_fieldcat.
        ENDIF.
        IF gs_formula-waers <> space OR
           gs_formula-ref_field_waers <> space.
          CLEAR wa_fieldcat.
          wa_fieldcat-fieldname = ld_curr_text.
          wa_fieldcat-ref_table = 'GTB_S_FORMULA'.
          wa_fieldcat-ref_field = 'WAERS'.
          COLLECT wa_fieldcat INTO gt_fieldcat.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORMULA_CALCULATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM formula_calculate .

  CALL FUNCTION 'SE16N_FORMULA_CALCULATE'
    EXPORTING
      i_tab          = gd-tab
      i_formula_name = gd-formula_name
    TABLES
      i_table        = <all_table>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FORMULA_MAINTAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM formula_maintain .

  CALL FUNCTION 'GTB_FORMULA_DEFINE'
    EXPORTING
      i_tab     = gd-tab
      i_formula = gd-formula_name.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form FORMULA_F4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM formula_f4 .

  DATA: BEGIN OF value_tab OCCURS 0,
          value TYPE gtb_formula,
        END OF value_tab.
  DATA: retfield   LIKE dfies-fieldname VALUE 'VALUE'.
  DATA: return_tab LIKE ddshretval OCCURS 0 WITH HEADER LINE.
  DATA: ls_formula TYPE gtb_s_formula.
  DATA: BEGIN OF dynpfields OCCURS 1.
          INCLUDE STRUCTURE dynpread.
        DATA: END OF dynpfields.

*...read field tab
  CLEAR dynpfields.
  REFRESH dynpfields.
  dynpfields-fieldname  = 'GD-TAB'.
  APPEND dynpfields.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = 'SAPLSE16N'
      dynumb             = sy-dynnr
      translate_to_upper = true
    TABLES
      dynpfields         = dynpfields.
  READ TABLE dynpfields INDEX 1.
  gd-tab = dynpfields-fieldvalue.

*.get all possible Formulas for this table
  REFRESH value_tab.
  SELECT formula_name FROM gtb_formula_def
       INTO CORRESPONDING FIELDS OF ls_formula
                WHERE tab = gd-tab
                GROUP BY formula_name.
    CLEAR value_tab.
    value_tab-value = ls_formula-formula_name.
    APPEND value_tab.
  ENDSELECT.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = retfield
      value_org       = 'S'
    TABLES
      value_tab       = value_tab
*     FIELD_TAB       = dfies_tab
      return_tab      = return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc = 0.
    READ TABLE return_tab INDEX 1.
    gd-formula_name = return_tab-fieldval.
  ENDIF.

ENDFORM.
