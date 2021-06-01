*&---------------------------------------------------------------------*
*&  Include           /IDXGC/RP_PDOC_CREATE_BDR_FRM
*&---------------------------------------------------------------------*

*&-----------------------------------------------------------------------------*
*& Form  pf_set_text_noinput
*&-----------------------------------------------------------------------------*
*  Set text fields to noinput
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_set_text_noinput .
  DATA zaehler TYPE i.
* Aufgabe 2
  LOOP AT SCREEN.
    IF screen-group1 EQ gc_scr_grp_txt OR zaehler = 34.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
    zaehler = zaehler + 1.
  ENDLOOP.
ENDFORM.                    " PF_SET_TEXT_NOINPUT
*&-----------------------------------------------------------------------------*
*& Form  pf_on_action_enter
*&-----------------------------------------------------------------------------*
*  Event handling on Enter
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_on_action_enter .
  PERFORM pf_update_type_view.
ENDFORM.                    " PF_ON_ACTION_ENTER
*&-----------------------------------------------------------------------------*
*& Form  pf_update_type_view
*&-----------------------------------------------------------------------------*
*  Update process view and proces stype
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_update_type_view .
  IF p_pid IS NOT INITIAL.
    PERFORM pf_get_proc_id_config.
    p_pidt = gs_proc_config_all-proc_descr.
    p_pvw = gs_proc_config_all-proc_view.
    p_pty = gs_proc_config_all-proc_type.
  ELSE.
    CLEAR:
      gs_proc_config_all,
      p_pidt.
    PERFORM pf_get_type_view CHANGING p_pty p_pvw.
  ENDIF.

  PERFORM pf_set_type_view USING p_pty p_pvw.
ENDFORM.                    " PF_UPDATE_TYPE_VIEW
*&-----------------------------------------------------------------------------*
*& Form pf_get_type_view
*&-----------------------------------------------------------------------------*
*  Get process type and process view
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_get_type_view  CHANGING cv_pty
                                cv_pvw.
  DATA:
    ls_dynpfields TYPE dynpread,
    lt_dynpfields TYPE TABLE OF dynpread.

  ls_dynpfields-fieldname = gc_scr_name_p_pty.
  APPEND ls_dynpfields TO lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pvw.
  APPEND ls_dynpfields TO lt_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = lt_dynpfields.

  READ TABLE lt_dynpfields INTO ls_dynpfields
    WITH KEY fieldname = gc_scr_name_p_pty.
  IF sy-subrc EQ 0.
    cv_pty = ls_dynpfields-fieldvalue.
  ENDIF.

  READ TABLE lt_dynpfields INTO ls_dynpfields
    WITH KEY fieldname = gc_scr_name_p_pvw.
  IF sy-subrc EQ 0.
    cv_pvw = ls_dynpfields-fieldvalue.
  ENDIF.
ENDFORM.                    " PF_GET_TYPE_VIEW
*&-----------------------------------------------------------------------------*
*& Form pf_set_type_view
*&-----------------------------------------------------------------------------*
*  Set process type and process view
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_set_type_view  USING    iv_pty
                                iv_pvw.
  DATA:
    ls_dynpfields TYPE dynpread,
    lt_dynpfields TYPE TABLE OF dynpread.

  ls_dynpfields-fieldname = gc_scr_name_p_pty.
  ls_dynpfields-fieldvalue = iv_pty.
  APPEND ls_dynpfields TO lt_dynpfields.

  IF iv_pty IS NOT INITIAL.
    PERFORM pf_get_proc_type_desc USING iv_pty CHANGING p_ptyt.
  ELSE.
    CLEAR p_ptyt.
  ENDIF.

  ls_dynpfields-fieldname = gc_scr_name_p_ptyt.
  ls_dynpfields-fieldvalue = p_ptyt.
  APPEND ls_dynpfields TO lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pvw.
  ls_dynpfields-fieldvalue = iv_pvw.
  APPEND ls_dynpfields TO lt_dynpfields.

  IF iv_pvw IS NOT INITIAL.
    PERFORM pf_get_proc_view_desc USING iv_pvw CHANGING p_pvwt.
  ELSE.
    CLEAR p_pvwt.
  ENDIF.

  ls_dynpfields-fieldname = gc_scr_name_p_pvwt.
  ls_dynpfields-fieldvalue = p_pvwt.
  APPEND ls_dynpfields TO lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pid.
  ls_dynpfields-fieldvalue = p_pid.
  APPEND ls_dynpfields TO lt_dynpfields.

  ls_dynpfields-fieldname = gc_scr_name_p_pidt.
  ls_dynpfields-fieldvalue = p_pidt.
  APPEND ls_dynpfields TO lt_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-repid
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
                             OTHERS.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " PF_SET_TYPE_VIEW
*&-----------------------------------------------------------------------------*
*& Form pf_get_proc_type_desc
*&-----------------------------------------------------------------------------*
*  Get process type description
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_get_proc_type_desc  USING    iv_proc_type
                            CHANGING cv_proc_type_descr.
  TRY.
      CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_proc_type_desc
        EXPORTING
          iv_proc_type       = iv_proc_type
        IMPORTING
          ev_proc_type_descr = cv_proc_type_descr.

    CATCH /idxgc/cx_config_error INTO gx_previous.
      gv_mtext = gx_previous->get_text( ).
      MESSAGE gv_mtext TYPE /idxgc/if_constants=>gc_message_type_success DISPLAY LIKE /idxgc/if_constants=>gc_message_type_error.
  ENDTRY.

ENDFORM.                    " PF_GET_PROC_TYPE_DESC
*&-----------------------------------------------------------------------------*
*& Form pf_get_proc_view_desc
*&-----------------------------------------------------------------------------*
*  Get process view description
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_get_proc_view_desc  USING    iv_proc_view
                            CHANGING cv_proc_view_descr.
  TRY.
      CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access_add~get_proc_veiw_desc
        EXPORTING
          iv_proc_view       = iv_proc_view
        IMPORTING
          ev_proc_view_descr = cv_proc_view_descr.

    CATCH /idxgc/cx_config_error INTO gx_previous.
      gv_mtext = gx_previous->get_text( ).
      MESSAGE gv_mtext TYPE /idxgc/if_constants=>gc_message_type_success DISPLAY LIKE /idxgc/if_constants=>gc_message_type_error.
  ENDTRY.
ENDFORM.                    " PF_GET_PROC_VIEW_DESC
*&-----------------------------------------------------------------------------*
*& Form pf_get_proc_id_config
*&-----------------------------------------------------------------------------*
*  Get process configuration by using process ID
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_get_proc_id_config .
  TRY.
      CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config
        EXPORTING
          iv_process_id     = p_pid
          iv_steps          = /idxgc/if_constants=>gc_true
        IMPORTING
          es_process_config = gs_proc_config_all.

    CATCH /idxgc/cx_config_error INTO gx_previous.
      gv_mtext = gx_previous->get_text( ).
      MESSAGE gv_mtext TYPE /idxgc/if_constants=>gc_message_type_error.
  ENDTRY.
ENDFORM.                    " PF_GET_PROC_ID_CONFIG
*&-----------------------------------------------------------------------------*
*& Form pf_set_proc_id
*&-----------------------------------------------------------------------------*
*  Set process ID
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_set_proc_id .
  DATA:
    lv_proc_type       TYPE /idxgc/de_proc_type,
    lv_proc_view       TYPE /idxgc/de_proc_view,
    lt_proc_config_all TYPE /idxgc/t_proc_config_all,
    ls_proc_config_all TYPE /idxgc/s_proc_config_all,
    lt_proc_config     TYPE TABLE OF /idxgc/s_proc_config,
    ls_proc_config     TYPE /idxgc/s_proc_config.

  CLEAR:
    ls_proc_config_all,
    ls_proc_config.

  REFRESH:
    lt_proc_config_all,
    lt_proc_config.

  TRY .
      CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config_mass
        EXPORTING
          iv_steps          = /idxgc/if_constants=>gc_false
        IMPORTING
          et_process_config = lt_proc_config_all.
    CATCH /idxgc/cx_config_error INTO gx_previous.
      gv_mtext = gx_previous->get_text( ).
      MESSAGE gv_mtext TYPE /idxgc/if_constants=>gc_message_type_error.
  ENDTRY.

  DELETE lt_proc_config_all WHERE proc_id IS INITIAL.
  SORT lt_proc_config_all BY proc_id.
  DELETE ADJACENT DUPLICATES FROM lt_proc_config_all COMPARING proc_id.

  LOOP AT lt_proc_config_all INTO ls_proc_config_all.
    MOVE-CORRESPONDING ls_proc_config_all TO ls_proc_config.
    APPEND ls_proc_config TO lt_proc_config.
  ENDLOOP.

*  PERFORM pf_get_type_view CHANGING lv_proc_type lv_proc_view.

  IF lv_proc_type IS INITIAL.
    IF lv_proc_view IS INITIAL.
      PERFORM pf_f4_proc_id USING lt_proc_config.
    ELSE.
      DELETE lt_proc_config WHERE proc_view NE lv_proc_view.
      PERFORM pf_f4_proc_id USING lt_proc_config.
    ENDIF.
  ELSE.
    IF lv_proc_view IS INITIAL.
      DELETE lt_proc_config WHERE proc_type NE lv_proc_type.
      PERFORM pf_f4_proc_id USING lt_proc_config.
    ELSE.
      DELETE lt_proc_config WHERE proc_type NE lv_proc_type OR proc_view NE lv_proc_view.
      PERFORM pf_f4_proc_id USING lt_proc_config.
    ENDIF.
  ENDIF.

  READ TABLE lt_proc_config INTO ls_proc_config WITH KEY proc_id = p_pid.
  IF sy-subrc EQ 0.
    p_pidt = ls_proc_config-proc_descr.
  ENDIF.
ENDFORM.                    " PF_SET_PROC_ID
*&-----------------------------------------------------------------------------*
*& Form  pf_f4_proc_id
*&-----------------------------------------------------------------------------*
*  F4 help for process ID
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_f4_proc_id  USING    it_proc_config TYPE STANDARD TABLE.
  DATA:
    lt_field  TYPE STANDARD TABLE OF dfies,
    ls_field  TYPE dfies,
    lt_return TYPE STANDARD TABLE OF ddshretval,
    ls_return TYPE ddshretval.

  ls_field-tabname = gc_tname_proc_config.
  ls_field-fieldname = gc_fname_proc_id.
  APPEND ls_field TO lt_field.
  ls_field-fieldname = gc_fname_proc_descr.
  APPEND ls_field TO lt_field.
  ls_field-fieldname = gc_fname_proc_type.
  APPEND ls_field TO lt_field.
  ls_field-fieldname = gc_fname_proc_view.
  APPEND ls_field TO lt_field.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = gc_fname_proc_id
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = gc_scr_name_p_pid
      value_org       = gc_value_org_s
    TABLES
      value_tab       = it_proc_config
      field_tab       = lt_field
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE lt_return INTO ls_return INDEX 1.
  IF sy-subrc EQ 0.
    p_pid = ls_return-fieldval.
  ENDIF.
ENDFORM.                    " PF_F4_PROC_ID
*&-----------------------------------------------------------------------------*
*& Form  pf_valid_ownsp
*&-----------------------------------------------------------------------------*
*  Validate own service provider
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_valid_ownsp .
  DATA:
    ls_eservprov TYPE v_eservprov,
    lv_msgv1     TYPE symsgv,
    lv_msgv4     TYPE symsgv.

  CALL FUNCTION 'ISU_DB_V_ESERVPROV_SINGLE'
    EXPORTING
      x_serviceid   = p_ownsp
    IMPORTING
      y_v_eservprov = ls_eservprov
    EXCEPTIONS
      not_found     = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    lv_msgv4 = sy-msgv4.
    lv_msgv1 = sy-msgv1.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH lv_msgv4 lv_msgv1.
  ELSE.
    IF ls_eservprov-own_log_sys NE gc_mark_x.
      MESSAGE e056(/idxgc/process_add) WITH p_ownsp.
    ENDIF.
  ENDIF.
ENDFORM.                    " PF_VALID_OWNSP
*&-----------------------------------------------------------------------------*
*& Form  pf_start_report
*&-----------------------------------------------------------------------------*
*  Start process report
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_start_report .
  DATA: ls_bdr_orders_hdr TYPE /idxgc/s_bdr_orders_hdr.

* Populate import structure for function module
  ls_bdr_orders_hdr-proc_id     = p_pid.
  ls_bdr_orders_hdr-proc_type   = p_pty.
  ls_bdr_orders_hdr-proc_view   = p_pvw.
  ls_bdr_orders_hdr-sender      = p_ownsp.
  ls_bdr_orders_hdr-receiver    = p_rcver.
  IF p_z14 IS NOT INITIAL.
    ls_bdr_orders_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z14.
  ELSEIF p_z27 IS NOT INITIAL.
    ls_bdr_orders_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z27.
  ELSEIF p_z28 IS NOT INITIAL.
    ls_bdr_orders_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z28.
  ENDIF.

* Call FM for the Dialog for request ORDERS
  TRY .
      CALL FUNCTION '/IDXGL/BDR_REQUEST_DIALOG'
        EXPORTING
          is_bdr_orders_hdr = ls_bdr_orders_hdr.
    CATCH /idxgc/cx_process_error.
*      MESSAGE ID sy-msgid TYPE  /idxgc/if_constants=>gc_message_type_success
*      NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*        DISPLAY LIKE /idxgc/if_constants=>gc_message_type_error.
  ENDTRY.

ENDFORM.                    " PF_START_REPORT
**********************************************************************
* Aufgabe 4
**********************************************************************
FORM pf_create_list.
  DATA: ls_bdr_orders_hdr    TYPE /idxgc/s_bdr_orders_hdr,
        ls_bdr_orders        TYPE zls_s_bdr_orders,
        lt_ui_bdr_orders_req TYPE zls_t_ui_bdr_orders_req.

  ls_bdr_orders_hdr-proc_id  = '8020'.
  ls_bdr_orders_hdr-sender   = 'todo'.
  ls_bdr_orders_hdr-receiver = 'todo'.

  IF r30 IS NOT INITIAL.
    ls_bdr_orders-marlok_id_start  = mid_lbl-low.
    ls_bdr_orders-marlok_id_end    = mid_lbl-high.
    ls_bdr_orders-audate           = p_audate.
    ls_bdr_orders-bilver           = p_bilver.
    ls_bdr_orders_hdr-docname_code = zls_if_constants_ide=>gc_zls_msg_category_z30.



  ELSEIF r34 IS NOT INITIAL.
    ls_bdr_orders-impnr_start      = imp_lbl-low.
    ls_bdr_orders-impnr_end        = imp_lbl-high.
    ls_bdr_orders_hdr-docname_code = zls_if_constants_ide=>gc_zls_msg_category_z34.
  ENDIF.

  TRY .
      CALL FUNCTION 'ZLS_BDR_REQUEST_DIALOG'
        EXPORTING
          is_bdr_orders_hdr        = ls_bdr_orders_hdr
          is_zls_bdr_orders        = ls_bdr_orders
          it_zls_ui_bdr_orders_req = lt_ui_bdr_orders_req.
    CATCH /idxgc/cx_process_error INTO DATA(lx_prerious). " Änderung
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      LEAVE SCREEN.
  ENDTRY.
ENDFORM.
*&-----------------------------------------------------------------------------*
*& Form  pf_on_action_onli
*&-----------------------------------------------------------------------------*
*  Event handling on execute
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_on_action_onli .
*  PERFORM pf_valid_process_id.
*  PERFORM pf_update_type_view.
ENDFORM.                    " PF_ON_ACTION_ONLI
*&-----------------------------------------------------------------------------*
*& Form  pf_valid_process_id
*&-----------------------------------------------------------------------------*
*  Validate process ID
*------------------------------------------------------------------------------*
*  Change History:
*  Jun. 2017: Created
*------------------------------------------------------------------------------*
FORM pf_valid_process_id.
  DATA: lt_process_id        TYPE /idxgc/t_proc_id.

  IF p_pid IS INITIAL.
    MESSAGE e040(/idxgc/process_add) WITH TEXT-t01.
  ELSE.
*   Determine real process id for alternative process id
    TRY.
        /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_proc_id_for_uid(
          EXPORTING
            iv_process_uid = /idxgc/if_constants_add=>gc_altprocid_bdr_sender
          IMPORTING
            et_process_id  = lt_process_id ).
      CATCH /idxgc/cx_config_error.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDTRY.

    IF lt_process_id IS NOT INITIAL.
      READ TABLE lt_process_id WITH KEY table_line = p_pid TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        MESSAGE e011(/idxgc/process_add) WITH p_pid.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " PF_VALID_PROCESS_ID

**********************************************************************
* Aufgabe 2
**********************************************************************
FORM pf_invisible.
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN
           '%BBK1000_BLOCK_1000'
        OR '%_P_OWNSP_%_APP_%-TEXT'
        OR 'P_OWNSP'
        OR '%_P_RCVER_%_APP_%-TEXT'
        OR 'P_RCVER'
        OR '%FT01014_1000'
        OR '%FT02004_1000'
        OR 'P_PVW'
        OR 'P_PVWT'
        OR '%FT03009_1000'
        OR 'P_PTY'
        OR 'P_PTYT'
        OR '%FT03009_1000'
        OR 'P_PID'
        OR 'P_PIDT'
        OR '%BBK2019_BLOCK_1000'
        OR 'P_Z14'
        OR '%FT04022_1000'
        OR 'P_Z27'
        OR '%FT05026_1000'
        OR 'P_Z28'
        OR '%FT06030_1000'.
        screen-active = 0.
        MODIFY SCREEN.
      WHEN OTHERS.
        screen-active = 1.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.
ENDFORM.

**********************************************************************
* Aufgabe 3
**********************************************************************
FORM pf_radio_switch.

  LOOP AT SCREEN.
    IF screen-name = 'IMP_LBL-LOW' OR screen-name = 'IMP_LBL-HIGH'.
      screen-required = '2'.
      MODIFY SCREEN.
    ELSEIF screen-name = 'P_AUDATE'.
*      TODO
*      screen-required = '2'.
*      MODIFY SCREEN.
    ENDIF.
    IF screen-group1 = 'M30'.
      IF r34 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    IF screen-group1 = 'M34'.
      IF r30 = 'X'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF r34 = 'X'.
    CLEAR: mid_lbl[],
           p_audate,
           p_bilver.
  ELSEIF r30 = 'X'.
    CLEAR: imp_lbl[].
  ENDIF.

ENDFORM.

FORM pf_check_parameters.
  IF r30 = 'X' AND ( mid_lbl[] IS INITIAL OR p_audate IS INITIAL OR p_bilver IS INITIAL ).
    MESSAGE ID 'ZLS_ABAP_RUNDE_MSG' TYPE 'E' NUMBER '001' DISPLAY LIKE 'I'.
  ELSEIF r34 = 'X' AND imp_lbl[] IS INITIAL.
    MESSAGE ID 'ZLS_ABAP_RUNDE_MSG' TYPE 'E' NUMBER '002' DISPLAY LIKE 'I'.
  ENDIF..
ENDFORM.
