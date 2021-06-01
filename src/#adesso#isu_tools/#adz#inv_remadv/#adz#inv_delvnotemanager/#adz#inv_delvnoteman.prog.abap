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
*INITIAL       APPEL-H  16.12.2019
************************************************************************
*******
REPORT /adz/inv_delvnoteman.

TABLES :
ext_ui_sh,
eservprov,
euitrans.


*----- Selection screen definition
TYPES : BEGIN OF ty_proc_data,
          proc_ref     TYPE /idxgc/de_proc_ref,
          proc_ref_num TYPE /idxgc/de_proc_ref_num,
          proc_id      TYPE /idxgc/de_proc_id,
          proc_date    TYPE /idxgc/de_proc_date,
          status       type  eideswtstat,
        END OF ty_proc_data.
DATA ls_proc TYPE ty_proc_data.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-a01.
SELECT-OPTIONS: "so_swtdo    FOR ls_proc-proc_ref       MEMORY ID /idxgc/par_proc_ref NO-DISPLAY, "l_swtdocnum,
              so_swtnm    FOR ls_proc-proc_ref_num      MEMORY ID /idxgc/par_proc_ref,
              so_prid     FOR ls_proc-proc_id   NO-DISPLAY DEFAULT 'DE_DELVNOTE_SUP', "new
              so_movin    FOR ls_proc-proc_date, "eideswtdoc-moveindate,
              so_statu    for ls_proc-status,
              "so_movou   FOR eideswtdoc-moveoutdate,
              so_extui    FOR ext_ui_sh-ext_ui,
*                so_group    FOR ls_proc_data-group_id.
              so_sendr    for eservprov-serviceid,
              so_recei    for eservprov-serviceid.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK perf WITH FRAME TITLE TEXT-005.
PARAMETERS: p_intbel AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK perf.

SELECTION-SCREEN BEGIN OF BLOCK vari WITH FRAME TITLE TEXT-004.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN END OF BLOCK vari.
*********************************************************************************
* INITILALZATION
*********************************************************************************
INITIALIZATION.
  p_vari = /adz/cl_inv_select_basic=>get_default_variant(  sy-repid  ).

*********************************************************************************
* Process on value request
*********************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  /adz/cl_inv_select_basic=>f4_for_variant(
    EXPORTING  iv_repid = sy-repid
    CHANGING   cv_vari  = p_vari  ).

END-OF-SELECTION.
  "--------------------------------------------------------------------------------------------------------
  DATA ok_code LIKE sy-ucomm.

**************************************************************************
* START-OF-SELECTION
**************************************************************************
START-OF-SELECTION.
  DATA ls_sel_params  TYPE /adz/inv_s_delvnoteman_selpar.

  " Struktur fuer Parameteruebergabe
  "ls_sel_params-so_swtdo       = so_swtdo[].
  ls_sel_params-so_swtnm       = so_swtnm[].
  ls_sel_params-so_prid        = so_prid[].
  ls_sel_params-so_movin       = so_movin[].
  ls_sel_params-so_extui       = so_extui[].
  ls_sel_params-so_sender      = so_sendr[].
  ls_sel_params-so_receiver    = so_recei[].
  ls_sel_params-so_status      = so_statu[].
  ls_sel_params-p_intbel       = p_intbel.

  DATA(lo_controller) = NEW /adz/cl_inv_controller_delvnma( ).
*  " daten von DB lesen
  lo_controller->read_data( is_sel_screen = ls_sel_params ).
  DATA(lrt_data)  = lo_controller->get_data( ).

  DATA(go_gui)  = NEW  /adz/cl_inv_gui_delvnoteman(
      iv_repid =  sy-repid
      iv_vari  =  p_vari  ).

  DATA(lr_data) = lo_controller->get_data( ).

  go_gui->display_data(
     EXPORTING  if_event_handler  = lo_controller->get_gui_event_handler(  )
     CHANGING   crt_data = lr_data ).

  CALL SCREEN 100.
**************************************************************************
* END-OF-SELECTION
**************************************************************************
END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Module  PAI_INVOICE_MANAGER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_actions INPUT.
  CASE ok_code.
    WHEN '&F03' OR 'E'.
      LEAVE TO SCREEN 0.
    WHEN '&F12' OR '&F15' OR 'ENDE' OR 'ECAN'.
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
*  SET PF-STATUS 'STANDARD_STATUS' EXCLUDING go_gui->mt_excl_functions.
  SET TITLEBAR  'STANDARD_TITEL'  WITH go_gui->mv_titel_param1.

ENDMODULE.
