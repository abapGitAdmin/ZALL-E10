*&---------------------------------------------------------------------*
*& Report  /ADZ/HMV_IDOC_STATUS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /adz/hmv_idoc_status.

TABLES: edextask.

"--------------------------------------------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_datum FOR edextask-dexaedat DEFAULT '20000101' TO sy-datum OBLIGATORY.
SELECT-OPTIONS: so_taski FOR edextask-dextaskid.
SELECTION-SCREEN SKIP.
PARAMETERS: p_updm  AS CHECKBOX.
PARAMETERS: p_updd  AS CHECKBOX.
PARAMETERS: p_updms AS CHECKBOX.             "Nuss 09.2018

SELECTION-SCREEN BEGIN OF BLOCK bla WITH FRAME TITLE TEXT-018.
PARAMETERS  p_shoalv RADIOBUTTON GROUP aaw.
PARAMETERS: p_stat   RADIOBUTTON GROUP aaw.
PARAMETERS  p_noshow RADIOBUTTON GROUP aaw.
SELECTION-SCREEN END OF BLOCK bla.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-002.
SELECT-OPTIONS: so_serv  FOR edextask-dexservprovself,
                so_serve FOR edextask-dexservprov,
                so_intui FOR edextask-int_ui.
SELECTION-SCREEN END OF BLOCK bl2.
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-017.
PARAMETERS  p_maxpar TYPE i.
SELECTION-SCREEN END OF BLOCK bl3.
"--------------------------------------------------------------------------------------------------------
DATA ok_code LIKE sy-ucomm.

**************************************************************************
* START-OF-SELECTION
**************************************************************************
START-OF-SELECTION.
  DATA(ls_const) = /adz/cl_hmv_constants=>get_constants( iv_repid = sy-repid  iv_slset = sy-slset ).
  DATA ls_sel_params  TYPE /adz/hmv_s_idoc_sel_params.
  ls_sel_params-p_maxpar       = p_maxpar.
  ls_sel_params-p_noshow       = p_noshow.
  ls_sel_params-p_shoalv       = p_shoalv.
  ls_sel_params-p_statistics   = p_stat.
  ls_sel_params-p_upd_dfk      = p_updd.
  ls_sel_params-p_upd_memi     = p_updm.
  ls_sel_params-p_upd_msb      = p_updms.
  ls_sel_params-so_datum       = so_datum[].
  ls_sel_params-so_intui       = so_intui[].
  ls_sel_params-so_serv        = so_serv[].
  ls_sel_params-so_serve       = so_serve[].
  ls_sel_params-so_taskid      = so_taski[].
  "ls_sel_params-so_taski       = t_sel_taski_part[].

  DATA(lo_controller) = NEW /adz/cl_hmv_controller_idocsta( ls_const ).
  " daten von DB lesen
  lo_controller->read_data( is_sel_params = ls_sel_params ).
  DATA(lrt_data)  = lo_controller->get_data( ).

  " Aus Struktur ls_stats Referenz auf Tabelle formen
  DATA(ls_stats)  = lo_controller->get_statitics( ).
  DATA lt_stats  LIKE STANDARD TABLE OF ls_stats.
  DATA lrt_stats  TYPE REF TO data.
  lt_stats  = VALUE #( ( ls_stats ) ).
  lrt_stats = REF #( lt_stats ).

  IF sy-batch <> 'X'.
    DATA(go_gui)  = NEW  /adz/cl_hmv_gui_idoc_status( is_const =  ls_const ).

    IF ls_sel_params-p_shoalv EQ abap_true OR ls_sel_params-p_statistics EQ abap_true.
      " nochn Grid ausgeben
      go_gui->display_data(
         EXPORTING  if_event_handler  = lo_controller->get_gui_event_handler(  )
                    ib_statistic_flag = ls_sel_params-p_statistics
         CHANGING   crt_data  = lrt_data
                    crt_stats = lrt_stats  ).
    ENDIF.
    CALL SCREEN 100.
  ENDIF.

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
  SET TITLEBAR  'STANDARD_TITEL'  WITH go_gui->mv_titel_param1.
ENDMODULE.
