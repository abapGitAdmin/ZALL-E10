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
form pf_my_set_text_noinput .
  data: b type i value 0.

  loop at screen.
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
*    if screen-name = '%BBK1000_BLOCK_1000'.
*      b = 1.
*    elseif screen-name = '%BBK3033_BLOCK_1000'.
*      b = 0.
*    endif.
*    if b = 1.
*      screen-active = 0.
*      modify screen.
*    else.
*      screen-active = 1.
*      modify screen.
*    endif.

* Aufgabe: lösche den Inhalt der Eingabefelder und blende diese aus,
*          abhängig von den Radiobuttons
    if p_r34 = 'X'.
      clear: p_locid[], p_locid, p_ausfd, p_bilav.
      if screen-group1 = 'M30'.
        screen-input = 0.
      else.
        screen-input = 1.
      endif.
      modify screen.
    elseif p_r30 = 'X'.
      clear: p_belnr[], p_belnr.
      if screen-group1 = 'M34'.
        screen-input = 0.
*      elseif screen-name = 'IMP_LBL-LOW' OR screen-name = 'IMP_LBL-HIGH'.
*        screen-required = '2'. !!!ändert nichts
      else.
        screen-input = 1.
      endif.
      modify screen.
    endif.
  endloop.
endform.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_ON_ACTION_ONLI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form pf_my_on_action_onli .
*  PERFORM pf_valid_process_id.
  perform pf_my_valid_message_type.
  perform pf_my_update_type_view.
endform.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_ON_RAD_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form pf_my_on_rad_click .
* Aufgabe: Behandle falsche Eingaben in den Blöcken
*          "Daten für Selektion zu Z**". Erzeuge eine Fehlermeldung,
*          wenn alle Felder zum jeweiligen Anwendungsfall leer sind
*          und verhindere den Radiobutton-Click
*  if p_r34 = 'X' and
*   ( p_locid is initial or
*     p_ausfd is initial or
*     p_bilav is initial ).
*    p_r30 = 'X'.
*    clear p_r34.
*    message 'Keine Daten zur Selektion zu Z30 angegeben' type 'E'.
*  elseif p_r30 = 'X' and
*         p_belnr is initial .
*    p_r34 = 'X'.
*    clear p_r30.
*    message 'Keine Daten zur Selektion zu Z34 angegeben' type 'E' display like 'I'.
*  endif.
  perform pf_my_update_type_view.
endform.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_UPDATE_TYPE_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form pf_my_update_type_view .
  if p_pid is not initial.
    perform pf_get_proc_id_config.
    p_pidt = gs_proc_config_all-proc_descr.
    p_pvw = gs_proc_config_all-proc_view.
    p_pty = gs_proc_config_all-proc_type.
  else.
    clear:
      gs_proc_config_all,
      p_pidt.
    perform pf_my_get_type_view changing p_pty p_pvw.
  endif.

  perform pf_my_set_type_view using p_pty p_pvw.
endform.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_GET_TYPE_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_PTY  text
*      <--P_P_PVW  text
*----------------------------------------------------------------------*
form pf_my_get_type_view  changing cv_pty
                                   cv_pvw.
  data:
    ls_dynpfields type dynpread,
    lt_dynpfields type table of dynpread.

  ls_dynpfields-fieldname = gc_scr_name_p_pty.
  append ls_dynpfields to lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pvw.
  append ls_dynpfields to lt_dynpfields.

  call function 'DYNP_VALUES_READ'
    exporting
      dyname     = sy-repid
      dynumb     = sy-dynnr
    tables
      dynpfields = lt_dynpfields.

  read table lt_dynpfields into ls_dynpfields
    with key fieldname = gc_scr_name_p_pty.
  if sy-subrc eq 0.
    cv_pty = ls_dynpfields-fieldvalue.
  endif.

  read table lt_dynpfields into ls_dynpfields
    with key fieldname = gc_scr_name_p_pvw.
  if sy-subrc eq 0.
    cv_pvw = ls_dynpfields-fieldvalue.
  endif.
endform.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_SET_TYPE_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_PTY  text
*      -->P_P_PVW  text
*----------------------------------------------------------------------*
form pf_my_set_type_view  using    iv_pty
                                   iv_pvw.
  data:
    ls_dynpfields type dynpread,
    lt_dynpfields type table of dynpread.

  ls_dynpfields-fieldname = gc_scr_name_p_ownsp.
  ls_dynpfields-fieldvalue = 'AD_DO_S_LF'.
  append ls_dynpfields to lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_rcver.
  ls_dynpfields-fieldvalue = 'AD_DO_G_NB'.
  append ls_dynpfields to lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pty.
  ls_dynpfields-fieldvalue = '22'. "iv_pty.
  append ls_dynpfields to lt_dynpfields.

  if iv_pty is not initial.
    perform pf_get_proc_type_desc using iv_pty changing p_ptyt.
  else.
    clear p_ptyt.
  endif.

  ls_dynpfields-fieldname = gc_scr_name_p_ptyt.
  ls_dynpfields-fieldvalue = p_ptyt.
  append ls_dynpfields to lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pvw.
  ls_dynpfields-fieldvalue = '4'. "iv_pvw.
  append ls_dynpfields to lt_dynpfields.

  if iv_pvw is not initial.
    perform pf_get_proc_view_desc using iv_pvw changing p_pvwt.
  else.
    clear p_pvwt.
  endif.

  ls_dynpfields-fieldname = gc_scr_name_p_pvwt.
  ls_dynpfields-fieldvalue = p_pvwt.
  append ls_dynpfields to lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pid.
  ls_dynpfields-fieldvalue = '8020'. "p_pid.
  append ls_dynpfields to lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pidt.
  ls_dynpfields-fieldvalue = p_pidt.
  append ls_dynpfields to lt_dynpfields.

  call function 'DYNP_VALUES_UPDATE'
    exporting
      dyname               = sy-repid
      dynumb               = sy-dynnr
    tables
      dynpfields           = lt_dynpfields
    exceptions
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
                             others.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
endform.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_START_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form pf_my_start_report .
  data: ls_bdr_orders_hdr type /idxgc/s_bdr_orders_hdr.

* Populate import structure for function module
  ls_bdr_orders_hdr-proc_id     = p_pid.
  ls_bdr_orders_hdr-proc_type   = p_pty.
  ls_bdr_orders_hdr-proc_view   = p_pvw.
  ls_bdr_orders_hdr-sender      = p_ownsp.
  ls_bdr_orders_hdr-receiver    = p_rcver.
*  IF p_z14 IS NOT INITIAL.
*    ls_bdr_orders_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z14.
*  ELSEIF p_z27 IS NOT INITIAL.
*    ls_bdr_orders_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z27.
*  ELSEIF p_z28 IS NOT INITIAL.
*    ls_bdr_orders_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z28.
*  ENDIF.
  if p_r30 is not initial.
    ls_bdr_orders_hdr-docname_code = zdr_if_constants_ide=>gc_msg_category_z30.
  elseif p_r34 is not initial.
    ls_bdr_orders_hdr-docname_code = zdr_if_constants_ide=>gc_msg_category_z34.
  endif.

* Call FM for the Dialog for request ORDERS
  try .
      call function 'ZDR_BDR_REQUEST_DIALOG'
        exporting
          is_bdr_orders_hdr = ls_bdr_orders_hdr.
    catch /idxgc/cx_process_error.
      message id sy-msgid type  /idxgc/if_constants=>gc_message_type_success
      number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        display like /idxgc/if_constants=>gc_message_type_error.
  endtry.

endform.
*&---------------------------------------------------------------------*
*&      Form  PF_MY_VALID_MESSAGE_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form pf_my_valid_message_type .
  if p_r30 = 'X'.
    if p_locid is initial or
       p_ausfd is initial or
       p_bilav is initial .
      message 'Keine Daten zur Selektion zu Z30 angegeben' type 'E'.
    endif.
  elseif p_r34 = 'X'.
    if p_belnr is initial .
      message 'Keine Daten zur Selektion zu Z34 angegeben' type 'E' display like 'I'.
    endif.
  endif.
endform.
