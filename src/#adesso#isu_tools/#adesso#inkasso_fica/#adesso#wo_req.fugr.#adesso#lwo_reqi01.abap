*----------------------------------------------------------------------*
***INCLUDE /ADESSO/LWO_REQI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  save_okcode = okcode.
  CLEAR okcode.

  CASE save_okcode.
    WHEN 'ENTR'.
      PERFORM ucom_entr USING /adesso/wo_req
                        CHANGING gt_tc_fkkop.
    WHEN 'WOREQ'.
      PERFORM ucom_woreq USING /adesso/wo_req
                               gt_tc_fkkop
                               gt_i_text.
*    WHEN 'BACK'.
*      SET SCREEN 0.
*      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALUE_REQUEST_ABGRD  INPUT
*&---------------------------------------------------------------------*
*       search help for write-off reason abgrd
*----------------------------------------------------------------------*
MODULE value_request_abgrd INPUT.
  PERFORM value_request_abgrd CHANGING /adesso/wo_req-abgrd.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALUE_REQUEST_WOIGD  INPUT
*&---------------------------------------------------------------------*
*       search help for internal write-off reason woigd
*----------------------------------------------------------------------*
MODULE value_request_woigd INPUT.
  PERFORM value_request_woigd CHANGING /adesso/wo_req-woigd.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALUE_REQUEST_WOVKS  INPUT
*&---------------------------------------------------------------------*
*       search help for sell-off rate wovks
*----------------------------------------------------------------------*
MODULE value_request_wovks INPUT.
  PERFORM value_request_wovks CHANGING /adesso/wo_req-wovks.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  SELECTION_CHECK  INPUT
*&---------------------------------------------------------------------*
MODULE selection_check INPUT.
* ------ check businesspartner ----------------------------------------*
  PERFORM check_gpart USING /adesso/wo_req-gpart
                      CHANGING /adesso/wo_req-txtgp.
* ------ check contract account ---------------------------------------*
  PERFORM check_vkont USING    /adesso/wo_req-vkont
                      CHANGING /adesso/wo_req-txtvk.
* ------ check businesspartner and contract account -------------------*
  PERFORM check_gpart_vkont USING /adesso/wo_req-gpart
                                  /adesso/wo_req-vkont.
* ------ get businesspartner for contract account if necessary ---------*
  PERFORM get_gpart USING    /adesso/wo_req-vkont
                    CHANGING /adesso/wo_req-gpart
                             /adesso/wo_req-txtgp.
* ------ Check ABGRD and get the text belonging to it -----------------*
  PERFORM check_abgrd USING    /adesso/wo_req-abgrd
                      CHANGING /adesso/wo_req-txgrd.
* ------ WOIGD get the text belonging to it -----------------*
  PERFORM get_woigd_txt USING    /adesso/wo_req-woigd
                        CHANGING /adesso/wo_req-txigd.
* ------ WOVKS get the text belonging to it -----------------*
  PERFORM get_wovks_txt USING    /adesso/wo_req-wovks
                        CHANGING /adesso/wo_req-txvks.
* ------ check items vkont contract account ---------------------------------------*
  PERFORM check_items_vkont USING    /adesso/wo_req
                            CHANGING gt_tc_fkkop.
* ------ check vkont at collection agency ---------------------------------------*
  PERFORM check_vkont_dfkkcoll USING /adesso/wo_req.
* ------ check vkont in write-off-monitor ---------------------------------------*
  PERFORM check_vkont_womon USING /adesso/wo_req.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_CHECK_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_check_0100 INPUT.
  save_okcode = okcode.
  CLEAR okcode.
  PERFORM exit_code USING save_okcode /adesso/wo_req.
ENDMODULE.                             " EXIT_CHECK_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  COMMAND_EDITOR_0100  INPUT
*&---------------------------------------------------------------------*
MODULE command_editor_0100 INPUT.
  PERFORM get_editor_text.
ENDMODULE.
