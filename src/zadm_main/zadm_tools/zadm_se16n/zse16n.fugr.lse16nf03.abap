*----------------------------------------------------------------------*
***INCLUDE LSE16NF03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F4_TABNAME_EXTENDED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_tabname_extended .

  DATA: value_tab LIKE dd02v-tabname.
  DATA: ld_in_tab TYPE se16t_value.
  DATA: ld_abort(1).

  ld_in_tab = gd-tab.

  CALL FUNCTION 'SE16T_START'
    EXPORTING
*     I_AREA       =
      i_object     = ld_in_tab
      i_tabname_f4 = true
    IMPORTING
      e_abort      = ld_abort
    CHANGING
      e_tabname    = value_tab.

  IF ld_abort <> true.
    gd-tab = value_tab.
  ENDIF.

ENDFORM.
