*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LINKASSO_FGF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMIZING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_customizing .

  IF gt_inkasso_cust IS INITIAL.
    SELECT * FROM /adesso/ink_cust INTO TABLE gt_inkasso_cust.
  ENDIF.

  IF gt_nfhf IS INITIAL.
    SELECT * FROM /adesso/nfhf INTO TABLE gt_nfhf.
  ENDIF.

  select single * from /adesso/inkbirth into gs_inkasso_birth.

ENDFORM.
