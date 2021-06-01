*----------------------------------------------------------------------*
***INCLUDE /IDXGC/LORDERS_DIALOGI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_0100 INPUT.

  IF gv_okcode = 'SEND' AND gv_doctype = 'Z30'.
    MESSAGE ID 'ZLS_ABAP_RUNDE_MSG' TYPE 'E' NUMBER '003' DISPLAY LIKE 'I'.
  ELSEIF gv_okcode = 'SEND' AND gv_doctype = 'Z34'.
    LEAVE TO SCREEN 0.
  ENDIF.

  gr_orders_req_cntr->pai( EXPORTING  iv_okcode      = gv_okcode
                             EXCEPTIONS error_occurred = 1
                                        OTHERS         = 2 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  cl_gui_cfw=>flush( ).

ENDMODULE.                 " PAI_0100  INPUT
