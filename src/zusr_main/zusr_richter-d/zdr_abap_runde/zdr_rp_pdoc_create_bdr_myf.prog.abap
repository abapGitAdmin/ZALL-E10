*&---------------------------------------------------------------------*
*&  Include           ZDR_RP_PDOC_CREATE_BDR_MYF
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PF_MY_SET_TEXT_NOINPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_my_set_text_noinput .
  DATA: b TYPE i VALUE 0.

  LOOP AT SCREEN.
* Übernommen aus pf_set_text_noinput
*    IF screen-group1 EQ gc_scr_grp_txt.
*      screen-input = 0.
*      MODIFY SCREEN.
*    ENDIF.

* Aufgabe: Modifiziere das Selektionsbild so, dass die Blöcke
*          "Daten für Selektion zu Z**" abhängig von den Radiobuttons
*          eingabefähig bzw. nicht eingabefähig sind blende alles
*          zwischen dem ersten und unserem Block auf dem Selektionsbild
*          aus
    IF screen-name = '%BBK1000_BLOCK_1000'.
      b = 1.
    ELSEIF screen-name = '%BBK3033_BLOCK_1000'.
      b = 0.
    ENDIF.
    IF b = 1.
      screen-active = 0.
      MODIFY SCREEN.
    ELSE.
      screen-active = 1.
      MODIFY SCREEN.
    ENDIF.

* Aufgabe: lösche den Inhalt der Eingabefelder und blende diese aus,
*          abhängig von den Radiobuttons
    IF p_r34 = 'X'.
      CLEAR: s_ext_ui[], s_ext_ui, p_edate, p_sproc.
      IF screen-group1 = 'M30'.
        screen-input = 0.
      ELSE.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ELSEIF p_r30 = 'X'.
      CLEAR: p_belnr[], p_belnr.
      IF screen-group1 = 'M34'.
        screen-input = 0.
      ELSE.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_ON_ACTION_ONLI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_my_on_action_onli .
*  PERFORM pf_valid_process_id.
  PERFORM pf_my_valid_message_type.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_VALID_MESSAGE_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_my_valid_message_type .
  IF p_r30 = 'X'.
    IF s_ext_ui IS INITIAL AND
       p_edate IS INITIAL AND
       p_sproc IS INITIAL .
      MESSAGE 'Keine Daten zur Selektion zu Z30 angegeben' TYPE 'E'.
    ENDIF.
  ELSEIF p_r34 = 'X'.
    IF p_belnr IS INITIAL .
      MESSAGE 'Keine Daten zur Selektion zu Z34 angegeben' TYPE 'E' DISPLAY LIKE 'I'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_START_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_my_start_report .
  DATA: ls_bdr_orders_hdr    TYPE /idxgc/s_bdr_orders_hdr,
        lt_ui_bdr_orders_req TYPE zdr_t_ui_bdr_orders_req.

* Populate import structure for function module
  ls_bdr_orders_hdr-proc_id     = '8020'. "p_pid.
  ls_bdr_orders_hdr-proc_type   = '22'. "p_pty.
  ls_bdr_orders_hdr-proc_view   = '4'. "p_pvw.
  ls_bdr_orders_hdr-sender      = 'AD_DO_S_LF'. "p_ownsp.
  ls_bdr_orders_hdr-receiver    = 'AD_DO_G_NB'."p_rcver.
  IF p_r30 IS NOT INITIAL.
    ls_bdr_orders_hdr-docname_code = zdr_if_constants_ide=>gc_msg_category_z30.
    PERFORM init_bdr_orders_req_z30 CHANGING lt_ui_bdr_orders_req.
  ELSEIF p_r34 IS NOT INITIAL.
    ls_bdr_orders_hdr-docname_code = zdr_if_constants_ide=>gc_msg_category_z34.
  ENDIF.

* Call FM for the Dialog for request ORDERS
  TRY .
      CALL FUNCTION 'ZDR_BDR_REQUEST_DIALOG'
        EXPORTING
          is_bdr_orders_hdr    = ls_bdr_orders_hdr
          it_ui_bdr_orders_req = lt_ui_bdr_orders_req.
    CATCH /idxgc/cx_process_error.
      MESSAGE ID sy-msgid TYPE  /idxgc/if_constants=>gc_message_type_success
      NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        DISPLAY LIKE /idxgc/if_constants=>gc_message_type_error.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  INIT_BDR_ORDERS_REQ_Z30
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_UI_BDR_ORDERS_REQ  text
*----------------------------------------------------------------------*
FORM init_bdr_orders_req_z30 CHANGING lt_ui_bdr_orders_req TYPE zdr_t_ui_bdr_orders_req.
  DATA: ls_ui_bdr_orders_req TYPE zdr_s_ui_bdr_orders_req.

  IF s_ext_ui IS INITIAL.
    ls_ui_bdr_orders_req-execution_date = p_edate.
    ls_ui_bdr_orders_req-settl_proc = p_sproc.
    APPEND ls_ui_bdr_orders_req TO lt_ui_bdr_orders_req.
  ELSE.
    SELECT *
        FROM euitrans
        INTO TABLE @DATA(lt_euitrans)
        WHERE ext_ui IN @s_ext_ui
          AND dateto   >= @p_edate
          AND datefrom <= @p_edate.

*    LOOP AT lt_euitrans ASSIGNING FIELD-SYMBOL(<ls_euitrans>).
*      MOVE-CORRESPONDING <ls_euitrans> TO ls_ui_bdr_orders_req.
*      APPEND ls_ui_bdr_orders_req TO lt_ui_bdr_orders_req.
*      lt_ui_bdr_orders_req = VALUE #( BASE lt_ui_bdr_orders_req
*                                      ( ls_ui_bdr_orders_req ) ).
*      MAPPING execution_date = p_edate
*                                                 settl_proc = p_sproc
*      lt_ui_bdr_orders_req = VALUE #(
*        BASE lt_ui_bdr_orders_req
*        ( CORRESPONDING #( <ls_euitrans> ) )
*        ( Value #( BASE CORRESPONDING #( <ls_euitrans> ) ( ) ) )
*      ).
*    ENDLOOP.
    lt_ui_bdr_orders_req = VALUE #( FOR <ls_euitrans> IN lt_euitrans ( VALUE #( BASE CORRESPONDING #( <ls_euitrans> ) execution_date = p_edate settl_proc = p_sproc ) ) ).
  ENDIF.
  CLEAR: ls_ui_bdr_orders_req.
ENDFORM.
