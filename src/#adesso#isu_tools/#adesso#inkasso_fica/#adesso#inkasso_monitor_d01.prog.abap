*----------------------------------------------------------------------*
***INCLUDE /ADESSO/INKASSO_MONITOR_D01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_9002
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM check_input_9002 .

  DATA: ls_wo_igrd TYPE /adesso/wo_igrd.

  CALL FUNCTION 'FKK_DB_TFK048A_SINGLE'
    EXPORTING
      i_abgrd           = /adesso/wo_mon-abgrd
    EXCEPTIONS
      not_found         = 1
      initial_parameter = 2
      OTHERS            = 3.

  IF sy-subrc <> 0.
    MESSAGE e815(>3) WITH /adesso/wo_mon-abgrd.
  ELSE.
    CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
      EXPORTING
        i_abgrd = /adesso/wo_mon-abgrd
      IMPORTING
        e_txt50 = /adesso/wo_req-txgrd
      EXCEPTIONS
        OTHERS  = 1.

    IF sy-subrc NE 0.
      CLEAR /adesso/wo_req-txgrd.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM /adesso/wo_igrd
        INTO ls_wo_igrd
        WHERE woigd = /adesso/wo_mon-woigd.

  IF sy-subrc <> 0.
    MESSAGE e012(/adesso/inkmon) WITH /adesso/wo_mon-woigd.
  ELSE.
    SELECT SINGLE woigdt FROM /adesso/wo_igrdt
           INTO /adesso/wo_req-txigd
           WHERE spras = sy-langu
           AND   woigd = /adesso/wo_mon-woigd.

    IF sy-subrc NE 0.
      CLEAR /adesso/wo_req-txigd.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_2_9002
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM check_input_2_9002 .

*  SELECT SINGLE * FROM /adesso/wo_igrd
*        INTO ls_wo_igrd
*        WHERE woigd = /adesso/wo_mon-woigd.
*
*  IF sy-subrc <> 0.
*    MESSAGE e012(/adesso/inkmon) WITH /adesso/wo_mon-woigd.
*  ELSE.
*    SELECT SINGLE woigdt FROM /adesso/wo_igrdt
*           INTO /adesso/wo_req-txigd
*           WHERE spras = sy-langu
*           AND   woigd = /adesso/wo_mon-woigd.
*
*    IF sy-subrc NE 0.
*      CLEAR /adesso/wo_req-txigd.
*    ENDIF.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_9003
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM check_input_9003 .

  DATA: ls_wo_igrd TYPE /adesso/wo_igrd.

  CALL FUNCTION 'FKK_DB_TFK048A_SINGLE'
    EXPORTING
      i_abgrd           = /adesso/wo_mon-abgrd
    EXCEPTIONS
      not_found         = 1
      initial_parameter = 2
      OTHERS            = 3.

  IF sy-subrc <> 0.
    MESSAGE e815(>3) WITH /adesso/wo_mon-abgrd.
  ELSE.
    CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
      EXPORTING
        i_abgrd = /adesso/wo_mon-abgrd
      IMPORTING
        e_txt50 = /adesso/wo_req-txgrd
      EXCEPTIONS
        OTHERS  = 1.

    IF sy-subrc NE 0.
      CLEAR /adesso/wo_req-txgrd.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM /adesso/wo_igrd
        INTO ls_wo_igrd
        WHERE woigd = /adesso/wo_mon-woigd.

  IF sy-subrc <> 0.
    MESSAGE e012(/adesso/inkmon) WITH /adesso/wo_mon-woigd.
  ELSE.
    SELECT SINGLE woigdt FROM /adesso/wo_igrdt
           INTO /adesso/wo_req-txigd
           WHERE spras = sy-langu
           AND   woigd = /adesso/wo_mon-woigd.

    IF sy-subrc NE 0.
      CLEAR /adesso/wo_req-txigd.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_9004
*&---------------------------------------------------------------------*
FORM check_input_9004 .

  DATA: ls_wo_igrd TYPE /adesso/wo_igrd.

  SELECT SINGLE * FROM /adesso/wo_vks
         INTO  @DATA(ls_wo_vks)
         WHERE wovks = @/adesso/wo_mon-wovks.

  IF sy-subrc <> 0.
    MESSAGE e011(/adesso/inkmon) WITH /adesso/wo_mon-wovks.
  ELSE.
    SELECT SINGLE wovkt FROM /adesso/wo_vkst
           INTO  /adesso/wo_req-txvks
           WHERE spras = sy-langu
           AND   wovks = /adesso/wo_mon-wovks.

    IF sy-subrc NE 0.
      CLEAR /adesso/wo_req-txvks.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'FKK_DB_TFK048A_SINGLE'
    EXPORTING
      i_abgrd           = /adesso/wo_mon-abgrd
    EXCEPTIONS
      not_found         = 1
      initial_parameter = 2
      OTHERS            = 3.

  IF sy-subrc <> 0.
    MESSAGE e815(>3) WITH /adesso/wo_mon-abgrd.
  ELSE.
    CALL FUNCTION 'FKK_DB_TFK048AT_SINGLE'
      EXPORTING
        i_abgrd = /adesso/wo_mon-abgrd
      IMPORTING
        e_txt50 = /adesso/wo_req-txgrd
      EXCEPTIONS
        OTHERS  = 1.

    IF sy-subrc NE 0.
      CLEAR /adesso/wo_req-txgrd.
    ENDIF.
  ENDIF.

  SELECT SINGLE * FROM /adesso/wo_igrd
        INTO ls_wo_igrd
        WHERE woigd = /adesso/wo_mon-woigd.

  IF sy-subrc <> 0.
    MESSAGE e012(/adesso/inkmon) WITH /adesso/wo_mon-woigd.
  ELSE.
    SELECT SINGLE woigdt FROM /adesso/wo_igrdt
           INTO /adesso/wo_req-txigd
           WHERE spras = sy-langu
           AND   woigd = /adesso/wo_mon-woigd.

    IF sy-subrc NE 0.
      CLEAR /adesso/wo_req-txigd.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VALUE_REQUEST_WOIGD
*&---------------------------------------------------------------------*
FORM value_request_woigd  USING ff_dynnr.

*----------------------------------------------------------------------*
  DATA: lt_wo_igrd    LIKE /adesso/wo_igrd  OCCURS 0 WITH HEADER LINE,
        lt_dfies      LIKE dfies            OCCURS 0 WITH HEADER LINE,
        lt_value(100) TYPE c                OCCURS 0 WITH HEADER LINE,
        lt_return     TYPE ddshretval       OCCURS 0 WITH HEADER LINE,
        lt_dynpf      TYPE dynpread         OCCURS 0 WITH HEADER LINE,
        lt_dselc      TYPE dselc            OCCURS 0 WITH HEADER LINE,
        lf_retf       TYPE dfies-fieldname,
        lf_woigdt     TYPE /adesso/wo_woigdt.
*----------------------------------------------------------------------*

  SELECT * FROM /adesso/wo_igrd
         INTO TABLE lt_wo_igrd.

  IF sy-subrc <> 0.
    MESSAGE e012(/adesso/inkmon) WITH ' '.
  ENDIF.

  REFRESH: lt_value, lt_dfies, lt_return, lt_dynpf, lt_dselc.

  LOOP AT lt_wo_igrd.
* -------------------  fill value + text -----------------------------*
    lt_value = lt_wo_igrd-woigd.
    APPEND: lt_value.

    SELECT SINGLE woigdt FROM /adesso/wo_igrdt
           INTO lf_woigdt
           WHERE spras = sy-langu
           AND   woigd = lt_wo_igrd-woigd.

    IF sy-subrc =  0.
      lt_value = lf_woigdt.
      APPEND: lt_value.
    ELSE.
      CLEAR lt_value.
      APPEND: lt_value.
    ENDIF.
  ENDLOOP.
* --------------------- fill field table ------------------------------*
  lt_dfies-tabname   = '/ADESSO/WO_IGRD'.
  lt_dfies-fieldname = 'WOIGD'.
  APPEND lt_dfies.
  lt_dfies-tabname   = '/ADESSO/WO_IGRDT'.
  lt_dfies-fieldname = 'WOIGDT'.
  APPEND lt_dfies.
  lf_retf = 'WOIGD'.

  lt_dselc-fldname   = 'WOIGDT'.
  lt_dselc-dyfldname = '/ADESSO/WO_REQ-TXIGD'.
  APPEND lt_dselc.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = lf_retf
      value_org       = 'C'
      dynpprog        = '/ADESSO/INKASSO_MONITOR'
      dynpnr          = ff_dynnr
      dynprofield     = '/ADESSO/WO_MON-WOIGD'
      display         = 'F'
    TABLES
      value_tab       = lt_value
      field_tab       = lt_dfies
      dynpfld_mapping = lt_dselc
    EXCEPTIONS
      parameter_error = 0
      no_values_found = 0.


*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield        = lf_retf
*      value_org       = 'C'
*      multiple_choice = 'X'
*      pvalkey         = lc_pvalkey                       "HW1333033 PeV
*      dynpprog        = '/ADESSO/INKASSO_MONITOR'
*      dynpnr          = ff_dynnr
*      dynprofield     = '/ADESSO/WO_MON-WOIGD'
**     display         = 'F'
*    TABLES
*      value_tab       = lt_value
*      field_tab       = lt_dfies
*      return_tab      = lt_return
*    EXCEPTIONS
*      parameter_error = 0
*      no_values_found = 0.
*
*  gt_return[] = lt_return[].
*  READ TABLE lt_return INDEX 1.
*  IF sy-subrc = 0.
*    LOOP AT lt_return.
*      IF sy-tabix = 1.
*        SELECT SINGLE woigdt FROM /adesso/wo_igrdt
*               INTO lf_woigdt
*               WHERE spras = sy-langu
*               AND   woigd = lt_return-fieldval.
*
*        lt_dynpf-fieldname  = '/ADESSO/WO_MON-WOIGD'.
*        lt_dynpf-fieldvalue = lt_return-fieldval.
*        APPEND lt_dynpf.
*        CLEAR lt_dynpf.
*
*        lt_dynpf-fieldname  = '/ADESSO/WO_REQ-TXIGD'.
*        lt_dynpf-fieldvalue = lf_woigdt.
*        APPEND lt_dynpf.
*        CLEAR lt_dynpf.
*      ELSE.
*        lt_dynpf-fieldname  = '/ADESSO/WO_MON-WOIGD_ADD'.
*        CONCATENATE lt_dynpf-fieldvalue
*                    lt_return-fieldval
*                    INTO lt_dynpf-fieldvalue
*                    SEPARATED BY space.
*      ENDIF.
*      APPEND lt_dynpf.
*    ENDLOOP.
*  ELSE.
*    lt_dynpf-fieldname  = '/ADESSO/WO_MON-WOIGD_ADD'.
*    lt_dynpf-fieldvalue = space.
*    APPEND lt_dynpf.
*  ENDIF.
*
**    CALL FUNCTION 'DYNP_VALUES_UPDATE'
*  CALL FUNCTION 'DYNP_UPDATE_FIELDS'
*    EXPORTING
*      dyname               = '/ADESSO/INKASSO_MONITOR'
*      dynumb               = ff_dynnr
*    TABLES
*      dynpfields           = lt_dynpf
*    EXCEPTIONS
*      invalid_abapworkarea = 1
*      invalid_dynprofield  = 2
*      invalid_dynproname   = 3
*      invalid_dynpronummer = 4
*      invalid_request      = 5
*      no_fielddescription  = 6
*      undefind_error       = 7
*      OTHERS               = 8.
*
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.

ENDFORM.
