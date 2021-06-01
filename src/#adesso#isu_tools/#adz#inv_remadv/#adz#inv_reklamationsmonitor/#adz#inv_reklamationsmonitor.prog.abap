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
*INIT         APPEL  01.11.2019
************************************************************************
*******
REPORT /adz/inv_reklamationsmonitor.

" Selectionsscreen fuer Invoic_Manager und Reklamationsmonitor
include /adz/inv_sel_screen_common.

DATA: ok_code LIKE sy-ucomm.
DATA go_gui TYPE REF TO /adz/cl_inv_gui_reklamon .

START-OF-SELECTION.
  DATA ls_sel_screen TYPE /adz/inv_s_sel_screen.
  PERFORM get_sel_screen CHANGING ls_sel_screen.


  DATA(lo_controller) = NEW /adz/cl_inv_controller_reklamo( ).
  " daten von DB lesen
  lo_controller->read_data( is_sel_screen = ls_sel_screen ).
  DATA(lr_data) = lo_controller->get_data( ).

  go_gui  = NEW /adz/cl_inv_gui_reklamon(
                    iv_invtyp = ls_sel_screen-p_invtp
                    iv_repid =  sy-repid
                    iv_vari  =  p_vari  ).
  lo_controller->/adz/if_inv_controller_basic~mo_gui = go_gui.

  go_gui->display_data(
     EXPORTING  if_event_handler  = lo_controller->get_gui_event_handler(  )
     CHANGING   crt_data = lr_data ).

  CALL SCREEN 100.
*&---------------------------------------------------------------------*
*&      Module  PAI_INVOICE_MANAGER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_actions INPUT.
  CASE ok_code.
    WHEN '&F03'.
      LEAVE TO SCREEN 0.
    WHEN '&F12' OR '&F15'.
      LEAVE PROGRAM.
    WHEN OTHERS.
      go_gui->execute_user_command( ok_code ).
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PBO_INVOICE_MANAGER  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_actions OUTPUT.
  DATA(lv_pf_status) = cond string(
    when ( go_gui->mv_invtyp eq /adz/cl_inv_select_reklamon=>mco_nn   ) then 'STANDARD_NEG_REMADV'
    when ( go_gui->mv_invtyp eq /adz/cl_inv_select_reklamon=>mco_memi ) then 'MEMI_NEG_REMADV'
    when ( go_gui->mv_invtyp eq /adz/cl_inv_select_reklamon=>mco_mgv  ) then 'MGV_NEG_REMADV'
    when ( go_gui->mv_invtyp eq /adz/cl_inv_select_reklamon=>mco_msb  ) then 'MSB_NEG_REMADV' ).

  SET PF-STATUS lv_pf_status EXCLUDING go_gui->mt_excl_functions.
  SET TITLEBAR  'STANDARD_TITEL'  WITH go_gui->mv_titel_param1.

ENDMODULE.
