************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT zzemp_master.

DATA: gs_emp_master TYPE zzemp_master,
      gv_flag       TYPE flag.

DATA: r_m,
      r_f,
      r_u.



DATA: gv_id     TYPE vrm_id,
      gt_values TYPE vrm_values,
      gs_values LIKE LINE OF gt_values.

DATA: gv_init.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS: p_empid TYPE zzemp_master-empid.

SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.


  SELECT SINGLE * FROM zzemp_master INTO gs_emp_master WHERE empid = p_empid.

  IF sy-subrc <> 0.

    gs_emp_master-empid = p_empid.

    IF    gs_emp_master-gender = 'M'.
      r_m = abap_true.
    ELSEIF gs_emp_master-gender = 'F'.
      r_f = abap_true.
    ELSE.
      CLEAR:  gs_emp_master-gender.
    ENDIF.

  ENDIF.

  CALL SCREEN 0100.


MODULE status_0100 OUTPUT.

  SET PF-STATUS 'PF_STATUS'.
  SET TITLEBAR 'TITELBAR'.


  IF gv_init IS INITIAL.

* assign search help to the field
    PERFORM set_list_box.
    gv_init = abap_true.

  ENDIF.

ENDMODULE.


MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.

      SET SCREEN 0.

    WHEN 'SAVE'.
      PERFORM save.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.

MODULE ext INPUT.

  SET SCREEN 0.

ENDMODULE.

FORM save.

  IF gs_emp_master-createdby IS INITIAL.

    gs_emp_master-createdby = sy-uname.
    gs_emp_master-createdon = sy-datum.
    gs_emp_master-time      = sy-uzeit.

  ENDIF.

  IF r_m IS NOT INITIAL.
    gs_emp_master-gender = 'M'.
  ELSEIF r_f IS NOT INITIAL.
    gs_emp_master-gender = 'F'.
  ELSE.
    CLEAR:  gs_emp_master-gender.
  ENDIF.

  MODIFY zzemp_master FROM gs_emp_master.

  MESSAGE 'Data saved successfully' TYPE 'S'.

ENDFORM.

FORM set_list_box.

  CLEAR: gt_values[].

  gt_values = VALUE #( ( key = 'MR.' )
                       ( key = 'Mrs.' ) ).
  SORT gt_values BY key.

  DELETE ADJACENT DUPLICATES FROM gt_values COMPARING key.

  gv_id = 'GS_EMP_MASTER-TITLE'.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = gv_id
      values = gt_values.

  CLEAR: gs_values, gt_values[].

ENDFORM.
