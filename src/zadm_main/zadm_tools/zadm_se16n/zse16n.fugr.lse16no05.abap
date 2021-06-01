*----------------------------------------------------------------------*
***INCLUDE LSE16NO05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_2000 OUTPUT.

   SET PF-STATUS '2000'.
   SET TITLEBAR '202'.

  DESCRIBE TABLE GT_SELFIELDS_DD LINES LINECOUNT_DD.
  DD_TC-LINES = LINECOUNT_DD.

ENDMODULE.                 " STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DD_SHOW_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DD_SHOW_LINES OUTPUT.

  move-corresponding gt_selfields_dd to gs_selfields_dd.

ENDMODULE.                 " DD_SHOW_LINES  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DD_CHANGE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DD_CHANGE_SCREEN OUTPUT.

  IF DD_TC-CURRENT_LINE > LINECOUNT_DD.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*...only show totalling for value fields
  loop at screen.
    if screen-name = 'GS_SELFIELDS_DD-SUM_UP'.
        if gt_selfields_dd-datatype = 'QUAN' or
           gt_selfields_dd-datatype = 'CURR' or
           gt_selfields_dd-datatype = 'INT1' or
           gt_selfields_dd-datatype = 'INT2' or
           gt_selfields_dd-datatype = 'INT4'.
           screen-input = 1.
           screen-active = 1.
        else.
           screen-input = 0.
           screen-active = 0.
        endif.
        modify screen.
    endif.
  endloop.

*.do not allow fields from text tables and client
  IF gs_selfields_dd-datatype = 'CLNT' or
     gs_selfields_dd-tabname  <> gd_dd_tab.
    LOOP AT SCREEN.
      SCREEN-INPUT = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " DD_CHANGE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DD_GET_LOOPLINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DD_GET_LOOPLINES OUTPUT.

  looplines_dd = sy-loopc.

ENDMODULE.                 " DD_GET_LOOPLINES  OUTPUT
