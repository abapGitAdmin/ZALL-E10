*----------------------------------------------------------------------*
***INCLUDE /IDXGC/LORDERS_DIALOGI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_0100 INPUT.



   IF gv_okcode = 'SEND' AND gv_doctype = ZTC_IF_CONSTANTS_IDE=>gc_msg_category_z30.
    MESSAGE ID 'ZTC_MSG_CLASS' TYPE 'I' NUMBER '002' DISPLAY LIKE 'I'.
    ELSEIF gv_okcode = 'SEND' AND gv_doctype = ZTC_IF_CONSTANTS_IDE=>gc_msg_category_z34.
      SET SCREEN 0.
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
