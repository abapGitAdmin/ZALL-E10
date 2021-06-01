*----------------------------------------------------------------------*
***INCLUDE LZFG_AUFGABE001.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ZMODULE_PBO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE zmodule_pbo OUTPUT.
  CASE gv_doctype.
* Z30: Änderung des Bilanzierungsverfahren
    WHEN 'Z30'.
        SET PF-STATUS '100'.
      SET TITLEBAR '0100' WITH TEXT-001.
* Z34: Reklamation von Lastgängen
    WHEN 'Z34'.
        SET PF-STATUS '200'.
      SET TITLEBAR '0100' WITH TEXT-002.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  Z_PAI_MODULE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE z_pai_module INPUT.

*  DATA: gv_okcode TYPE sy-ucomm.
*  gv_okcode = sy-ucomm.
*  CASE gv_okcode.
*    WHEN 'SEND'.
*      CASE gv_doctype.
*        WHEN 'Z30'.
*          MESSAGE 'Senden nicht möglich. Programm noch nicht fertig.' TYPE 'I'.
*        WHEN 'Z34'.
*          SET SCREEN 0.
*          LEAVE SCREEN.
*      ENDCASE.
*    WHEN 'BACK' OR 'CANCEL'.
*      SET SCREEN 0.
*      LEAVE SCREEN.
*    WHEN 'EXIT'.
*      LEAVE PROGRAM.
*  ENDCASE.
*gv_okcode = sy-ucomm.
gr_clao_bdr_cntr->pai( EXPORTING  iv_okcode      = gv_okcode
                             EXCEPTIONS error_occurred = 1
                                        OTHERS         = 2 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  cl_gui_cfw=>flush( ).
ENDMODULE.
