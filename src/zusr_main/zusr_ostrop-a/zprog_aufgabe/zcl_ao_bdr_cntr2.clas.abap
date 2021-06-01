class ZCL_AO_BDR_CNTR2 definition
  public
  create public .

*"* public components of class ZCL_AO_BDR_CNTR2
*"* do not include other source files here!!!
public section.

  data GRID_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data ALV_GRID type ref to CL_GUI_ALV_GRID .
  data CO_ORDERS_CONTAINER type OBJECTNAME value 'ORDERS_CONTAINER' ##NO_TEXT.
  data CO_ORDERS_UI_REQ type TABNAME value '/IDXGC/S_UI_BDR_ORDERS_REQ' ##NO_TEXT.
  data CO_SEND type CUA_CODE value 'SEND' ##NO_TEXT.
  constants CO_NUMERIC type CHAR10 value '0123456789' ##NO_TEXT.
  constants CO_FIELDNAME_PROC_ID type FIELDNAME value 'PROC_ID' ##NO_TEXT.
  constants CO_FIELDNAME_PROC_TYPE type FIELDNAME value 'PROC_TYPE' ##NO_TEXT.
  constants CO_FIELDNAME_PROC_VIEW type FIELDNAME value 'PROC_VIEW' ##NO_TEXT.
  constants CO_FIELDNAME_SENDER type FIELDNAME value 'SENDER' ##NO_TEXT.
  constants CO_FIELDNAME_RECEIVER type FIELDNAME value 'RECEIVER' ##NO_TEXT.
  constants CO_FIELDNAME_EXT_UI type FIELDNAME value 'EXT_UI' ##NO_TEXT.
  constants CO_FIELDNAME_DOCNAME_CODE type FIELDNAME value 'DOCNAME_CODE' ##NO_TEXT.
  constants CO_FIELDNAME_POSTBOX type FIELDNAME value 'POSTBOX' ##NO_TEXT.
  constants CO_FIELDNAME_STREET type FIELDNAME value 'STREET' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSENR type FIELDNAME value 'HOUSENR' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSENREXT type FIELDNAME value 'HOUSENREXT' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSEID_COMPL type FIELDNAME value 'HOUSEID_COMPL' ##NO_TEXT.
  constants CO_FIELDNAME_CITY type FIELDNAME value 'CITY' ##NO_TEXT.
  constants CO_FIELDNAME_POSTCODE type FIELDNAME value 'POSTCODE' ##NO_TEXT.
  constants CO_FIELDNAME_BU_PARTNER type FIELDNAME value 'BU_PARTNER' ##NO_TEXT.
  constants CO_FIELDNAME_FC_NAME1 type FIELDNAME value 'FC_NAME1' ##NO_TEXT.
  constants CO_FIELDNAME_FC_NAME2 type FIELDNAME value 'FC_NAME2' ##NO_TEXT.
  constants CO_FIELDNAME_NAME1_F type FIELDNAME value 'NAME1_F' ##NO_TEXT.
  constants CO_FIELDNAME_NAME2_F type FIELDNAME value 'NAME2_F' ##NO_TEXT.
  constants CO_FIELDNAME_BP_TYPE type FIELDNAME value 'BP_TYPE' ##NO_TEXT.
  constants CO_FIELDNAME_POSTBOX_BP type FIELDNAME value 'POSTBOX_BP' ##NO_TEXT.
  constants CO_FIELDNAME_STREET_BP type FIELDNAME value 'STREET_BP' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSENR_BP type FIELDNAME value 'HOUSENR_BP' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSENREXT_BP type FIELDNAME value 'HOUSENREXT_BP' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSEID_COMPL_BP type FIELDNAME value 'HOUSEID_COMPL_BP' ##NO_TEXT.
  constants CO_FIELDNAME_CITY_BP type FIELDNAME value 'CITY_BP' ##NO_TEXT.
  constants CO_FIELDNAME_POSTCODE_BP type FIELDNAME value 'POSTCODE_BP' ##NO_TEXT.
  constants CO_FIELDNAME_POSTBOX_MP type FIELDNAME value 'POSTBOX_MP' ##NO_TEXT.
  constants CO_FIELDNAME_STREET_MP type FIELDNAME value 'STREET_MP' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSENR_MP type FIELDNAME value 'HOUSENR_MP' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSENREXT_MP type FIELDNAME value 'HOUSENREXT_MP' ##NO_TEXT.
  constants CO_FIELDNAME_HOUSEID_COMPL_MP type FIELDNAME value 'HOUSEID_COMPL_MP' ##NO_TEXT.
  constants CO_FIELDNAME_CITY_MP type FIELDNAME value 'CITY_MP' ##NO_TEXT.
  constants CO_FIELDNAME_POSTCODE_MP type FIELDNAME value 'POSTCODE_MP' ##NO_TEXT.
  constants CO_FIELDNAME_DATE_FROM type FIELDNAME value 'DATE_FROM' ##NO_TEXT.
  constants CO_FIELDNAME_TIME_FROM type FIELDNAME value 'TIME_FROM' ##NO_TEXT.
  constants CO_FIELDNAME_DATE_TO type FIELDNAME value 'DATE_TO' ##NO_TEXT.
  constants CO_FIELDNAME_TIME_TO type FIELDNAME value 'TIME_TO' ##NO_TEXT.
  constants CO_FIELDNAME_METERNR type FIELDNAME value 'METERNR' ##NO_TEXT.
  constants CO_FIELDNAME_SUPPLY_DIRECT type FIELDNAME value 'SUPPLY_DIRECT' ##NO_TEXT.
  constants CO_FIELDNAME_PROC_REF type FIELDNAME value 'PROC_REF' ##NO_TEXT.
  constants CO_FIELDNAME_STATUS_TEXT type FIELDNAME value 'STATUS_TEXT' ##NO_TEXT.
  constants CO_VALEXI_EXCLAM type VALEXI value '!' ##NO_TEXT.
  constants CO_RP_NAME type REPID value '/IDXGC/CL_BDR_ORDERS_REQ_CNTR=CP' ##NO_TEXT.
  constants CO_FIELDNAME_ASYNC type FIELDNAME value 'ASYNC' ##NO_TEXT.
  constants CO_FIELDNAME_DISTRICT type FIELDNAME value 'DISTRICT' ##NO_TEXT.
  constants CO_FIELDNAME_COUNTRY type FIELDNAME value 'COUNTRY' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD1 type FIELDNAME value 'ADDR_ADD1' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD2 type FIELDNAME value 'ADDR_ADD2' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD3 type FIELDNAME value 'ADDR_ADD3' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD4 type FIELDNAME value 'ADDR_ADD4' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD5 type FIELDNAME value 'ADDR_ADD5' ##NO_TEXT.
  constants CO_FIELDNAME_FIRST_NAME type FIELDNAME value 'FIRST_NAME' ##NO_TEXT.
  constants CO_FIELDNAME_NAME_ADD1 type FIELDNAME value 'NAME_ADD1' ##NO_TEXT.
  constants CO_FIELDNAME_NAME_ADD2 type FIELDNAME value 'NAME_ADD2' ##NO_TEXT.
  constants CO_FIELDNAME_AD_TITLE_EXT type FIELDNAME value 'AD_TITLE_EXT' ##NO_TEXT.
  constants CO_FIELDNAME_DISTRICT_MP type FIELDNAME value 'DISTRICT_MP' ##NO_TEXT.
  constants CO_FIELDNAME_COUNTRY_MP type FIELDNAME value 'COUNTRY_MP' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD1_MP type FIELDNAME value 'ADDR_ADD1_MP' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD2_MP type FIELDNAME value 'ADDR_ADD2_MP' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD3_MP type FIELDNAME value 'ADDR_ADD3_MP' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD4_MP type FIELDNAME value 'ADDR_ADD4_MP' ##NO_TEXT.
  constants CO_FIELDNAME_ADDR_ADD5_MP type FIELDNAME value 'ADDR_ADD5_MP' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !IS_BDR_ORDERS_HDR type /IDXGC/S_BDR_ORDERS_HDR
      !IT_BDR_ORDERS_NEWHDR type ZTT_AO_BDR_ORDERS_REQ
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods HANDLE_OK_CODE
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods CREATE_ALV_GRID
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods PAI
    importing
      !IV_OKCODE type CUA_CODE
    exceptions
      ERROR_OCCURRED .
protected section.
*"* protected components of class ZCL_AO_BDR_CNTR2
*"* do not include other source files here!!!

  data GR_BADI_BDR type ref to /IDXGC/BADI_BDR .
  data GV_OKCODE type CUA_CODE .
  class-data GV_MTEXT type STRING .
  data GS_BDR_HDR type /IDXGC/S_BDR_ORDERS_HDR .
  data GV_SENDER type E_DEXSERVPROVSELF .
  data GV_RECEIVER type E_DEXSERVPROV .
  data GT_FIELDCAT type LVC_T_FCAT .
  data GT_ORDERS_REQ type /IDXGC/T_UI_BDR_ORDERS_REQ .
  data GT_MESSAGE type TISU00_MESSAGE .
  class-data GS_PROC_CONFIG type /IDXGC/S_PROC_CONFIG_ALL .

  methods FREE_OBJECT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods PREPARE_PROCESS_DATA
    importing
      !IS_BDR_ORDERS_REQ type /IDXGC/S_UI_BDR_ORDERS_REQ
    changing
      !CS_PROCESS_DATA type /IDXGC/S_PROC_DATA
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods BUILD_FIELDCAT
    exporting
      !ET_FIELDCAT type LVC_T_FCAT
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods DISPLAY_ERROR
    raising
      /IDXGC/CX_PROCESS_ERROR .
  methods EXCLUDE_GRID_FUNCTIONS
    changing
      !CT_UI_FUNCTIONS_EXCLUDE type UI_FUNCTIONS .
  methods ON_DATA_CHANGED
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_ONF4
      !E_ONF4_BEFORE
      !E_ONF4_AFTER
      !E_UCOMM .
  methods ON_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW
      !E_COLUMN
      !ES_ROW_NO .
private section.
*"* private components of class ZCL_AO_BDR_CNTR2
*"* do not include other source files here!!!

  data GT_BDR_ORDERS_NEWHDR type ZTT_AO_BDR_ORDERS_REQ .
ENDCLASS.



CLASS ZCL_AO_BDR_CNTR2 IMPLEMENTATION.


METHOD BUILD_FIELDCAT.

  FIELD-SYMBOLS: <fieldcat>   TYPE lvc_s_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = co_orders_ui_req
    CHANGING
      ct_fieldcat      = et_fieldcat.

  LOOP AT et_fieldcat ASSIGNING <fieldcat>.
    <fieldcat>-valexi = co_valexi_exclam.  "Deactivate domain value check
    <fieldcat>-col_opt = 'A'.
    <fieldcat>-edit = cl_isu_flag=>co_true.
    <fieldcat>-f4availabl = cl_isu_flag=>co_false.

    IF gs_bdr_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z14.
      CASE <fieldcat>-fieldname.
        WHEN co_fieldname_city
          OR co_fieldname_street
          OR co_fieldname_country.
          <fieldcat>-f4availabl = cl_isu_flag=>co_true.

        WHEN co_fieldname_date_from
          OR co_fieldname_time_from.
          CLEAR <fieldcat>-col_opt.
          <fieldcat>-tech = cl_isu_flag=>co_true.

        WHEN co_fieldname_date_to
          OR co_fieldname_time_to.
          CLEAR <fieldcat>-col_opt.
          <fieldcat>-tech = cl_isu_flag=>co_true.

        WHEN co_fieldname_meternr.
          <fieldcat>-tech = cl_isu_flag=>co_false.

        WHEN OTHERS.
      ENDCASE.

    ELSEIF ( gs_bdr_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z27 )
        OR ( gs_bdr_hdr-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z28 ).

      <fieldcat>-tech = cl_isu_flag=>co_true.

      IF <fieldcat>-fieldname = co_fieldname_date_from OR
         <fieldcat>-fieldname = co_fieldname_date_to.
        <fieldcat>-tech = cl_isu_flag=>co_false.
      ENDIF.

    ENDIF.

    IF <fieldcat>-fieldname = co_fieldname_proc_id OR
       <fieldcat>-fieldname = co_fieldname_proc_type OR
       <fieldcat>-fieldname = co_fieldname_proc_view OR
       <fieldcat>-fieldname = co_fieldname_sender OR
       <fieldcat>-fieldname = co_fieldname_receiver OR
       <fieldcat>-fieldname = co_fieldname_docname_code.
*   always hide the fields of process data request
      <fieldcat>-tech = cl_isu_flag=>co_true.
    ENDIF.

    IF <fieldcat>-fieldname = co_fieldname_ext_ui.
      CLEAR <fieldcat>-col_opt.
      <fieldcat>-lowercase = cl_isu_flag=>co_true.
      <fieldcat>-tech = cl_isu_flag=>co_false.
      <fieldcat>-f4availabl = cl_isu_flag=>co_true.
    ENDIF.

    IF <fieldcat>-fieldname = co_fieldname_supply_direct.
      <fieldcat>-tech = cl_isu_flag=>co_false.
    ENDIF.

    IF <fieldcat>-fieldname = co_fieldname_proc_ref OR
       <fieldcat>-fieldname = co_fieldname_status_text.
      <fieldcat>-edit = cl_isu_flag=>co_false.
      <fieldcat>-tech = cl_isu_flag=>co_false.
    ENDIF.

    IF <fieldcat>-fieldname = co_fieldname_async.
      <fieldcat>-tech = cl_isu_flag=>co_false.
      <fieldcat>-checkbox = cl_isu_flag=>co_true.
    ENDIF.

  ENDLOOP.

  IF gr_badi_bdr IS BOUND.
    CALL BADI gr_badi_bdr->adjust_screen_fields
      EXPORTING
        is_bdr_hdr        = gs_bdr_hdr
        is_structure_name = co_orders_ui_req
      CHANGING
        ct_fieldcat       = et_fieldcat.
  ENDIF.

ENDMETHOD.


METHOD constructor.

  DATA:
    lr_previous TYPE REF TO  /idxgc/cx_general,
    lr_root     TYPE REF TO cx_root.

  me->gt_bdr_orders_newhdr = it_bdr_orders_newhdr.

*-------------------------------------------------------------------------BEARBEITUNG----------------------------------------------------------------------------------------------------------
*    ls_bdr_req  TYPE zstruc_ao_final_bdr_req.
*

*
*  IF ltta_bdr_orders_newhdr-docname_code = 'Z30'. "/idxgc/if_constants_ide=>gc_msg_category_z30.
*    IF ltta_bdr_orders_newhdr-int_ui IS INITIAL.
*      ltta_bdr_orders_newhdr-execution_date = ltt_bdr_orders_newhdr-execution_date.
*      ltta_bdr_orders_newhdr-settl_proc = ltt_bdr_orders_newhdr-settl_proc.
*    ELSE.
*      "Für jeden Zählpunkt führe aus:
**      DO ltt_bdr_orders_newhdr-end_read_time - ltt_bdr_orders_newhdr-start_read_time TIMES. "LOOP OVER EXT_UI.
**        ls_bdr_req-execution_date = ltt_bdr_orders_newhdr-execution_date.
**        ls_bdr_req-settl_proc = ltt_bdr_orders_newhdr-settl_proc.
**        APPEND ls_bdr_req TO ltta_bdr_orders.
**      ENDDO. "ENDLOOP.
*
*      LOOP FROM ltt_bdr_orders_newhdr INTO ls_bdr_req.
*        SELECT SINGLE ext_ui FROM euitrans WHERE ls_bdr_req-int_ui = euitrans-int_ui INTO ls_bdr_req-ext_ui.
*        ls_bdr_req-execution_date = ltt_bdr_orders_newhdr-execution_date.
*        ls_bdr_req-settl_proc = ltt_bdr_orders_newhdr-settl_proc.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.
*----------------------------------------------------------------------------------------BEARBEITUNG------------------------------------------------------------------------------------------------------
* Process ID, sender & receiver shall not be initial
  IF is_bdr_orders_hdr-proc_id IS INITIAL OR
     is_bdr_orders_hdr-sender IS INITIAL OR
     is_bdr_orders_hdr-receiver IS INITIAL.
    MESSAGE e040(/idxgc/process_add) WITH TEXT-t01 INTO gv_mtext.
    /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
  ENDIF.

* Instantiate BAdI for the BDR Process
  TRY.
      GET BADI gr_badi_bdr.

    CATCH cx_badi_not_implemented INTO lr_root.         "#EC NO_HANDLER
*     Ignore

    CATCH cx_badi_multiply_implemented INTO lr_root.
      MESSAGE e164(/idxgc/process) INTO gv_mtext WITH /idxgc/if_constants_add=>gc_badi_bdr.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
        EXPORTING
          ir_previous = lr_root.
  ENDTRY.


* Get process config
  TRY.
      CALL METHOD /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config
        EXPORTING
          iv_process_id     = is_bdr_orders_hdr-proc_id
          iv_steps          = /idxgc/if_constants=>gc_true
        IMPORTING
          es_process_config = gs_proc_config.

      IF gs_proc_config-steps IS INITIAL.
        MESSAGE e012(/idxgc/process) WITH is_bdr_orders_hdr-proc_id INTO gv_mtext.
        CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg( ).
      ENDIF.
    CATCH /idxgc/cx_config_error INTO lr_previous.
      CALL METHOD /idxgc/cx_process_error=>raise_proc_exception_from_msg
        EXPORTING
          ir_previous = lr_previous.
  ENDTRY.


  gs_bdr_hdr = is_bdr_orders_hdr.
  gv_sender = is_bdr_orders_hdr-sender.
  gv_receiver = is_bdr_orders_hdr-receiver.

ENDMETHOD.


METHOD CREATE_ALV_GRID.

  DATA: lt_fieldcat TYPE lvc_t_fcat.
  DATA: ls_variant  TYPE disvariant.
  DATA: ls_layout   TYPE lvc_s_layo.
  DATA: lt_exclude  TYPE ui_functions.


  FIELD-SYMBOLS:
        <fs_orders_req> TYPE /idxgc/s_ui_bdr_orders_req.

  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = 'A'
    CHANGING
      cs_variant = ls_variant
    EXCEPTIONS
      OTHERS     = 1.

  IF sy-subrc <> 0.
    ls_variant-report = co_rp_name.
  ENDIF.

  ls_layout-smalltitle = cl_isu_flag=>co_true.
  ls_layout-stylefname = 'CELLSTTYLE'.

  IF me->grid_container IS INITIAL.
    CREATE OBJECT me->grid_container
      EXPORTING
        container_name = co_orders_container.

    IF me->alv_grid IS INITIAL.
* append a initial line to the out alv grid
      APPEND INITIAL LINE TO me->gt_orders_req ASSIGNING <fs_orders_req>.
      <fs_orders_req>-bdr_hdr  = gs_bdr_hdr.
*      <fs_orders_req>-sender   = me->gv_sender.
*      <fs_orders_req>-receiver = me->gv_receiver.

      CREATE OBJECT me->alv_grid
        EXPORTING
          i_parent = me->grid_container.

      CALL METHOD me->build_fieldcat
        IMPORTING
          et_fieldcat = lt_fieldcat.

      me->gt_fieldcat = lt_fieldcat.

      CALL METHOD me->exclude_grid_functions
        CHANGING
          ct_ui_functions_exclude = lt_exclude.

* display the input screen of request data
      CALL METHOD me->alv_grid->set_table_for_first_display
        EXPORTING
          i_structure_name     = co_orders_ui_req
          is_variant           = ls_variant
          i_default            = cl_isu_flag=>co_true
          i_save               = 'A'
          is_layout            = ls_layout
          it_toolbar_excluding = lt_exclude
        CHANGING
          it_outtab            = me->gt_orders_req
          it_fieldcatalog      = lt_fieldcat.

* set layout
      CALL METHOD me->alv_grid->set_frontend_layout
        EXPORTING
          is_layout = ls_layout.

* register edit event
      CALL METHOD me->alv_grid->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified
        EXCEPTIONS
          error      = 1
          OTHERS     = 2.

* allow edit
      CALL METHOD me->alv_grid->set_ready_for_input
        EXPORTING
          i_ready_for_input = 1.

* set handler
      SET HANDLER
          me->on_double_click
          me->on_data_changed
          FOR me->alv_grid.

    ENDIF.

  ELSE.

    CALL METHOD me->alv_grid->refresh_table_display.

  ENDIF.

ENDMETHOD.


METHOD DISPLAY_ERROR.

  DATA: lref_error     TYPE REF TO cl_isu_error_log.

  FIELD-SYMBOLS:
        <fs_message>   TYPE isu00_message.

* display the error information in a pop up window
  IF me->gt_message IS NOT INITIAL.
    CREATE OBJECT lref_error.
    LOOP AT me->gt_message ASSIGNING <fs_message>.
      CALL METHOD lref_error->add_message
        EXPORTING
          x_msgid = <fs_message>-msgid
          x_msgno = <fs_message>-msgno
          x_msgty = <fs_message>-msgty
          x_msgv1 = <fs_message>-msgv1
          x_msgv2 = <fs_message>-msgv2
          x_msgv3 = <fs_message>-msgv3
          x_msgv4 = <fs_message>-msgv4
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDLOOP.

    CALL METHOD lref_error->display_messages
      EXPORTING
        x_single_in_status_line = space
      EXCEPTIONS
        OTHERS                  = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
* Close error object
    CALL METHOD lref_error->close.
  ENDIF.

ENDMETHOD.


METHOD EXCLUDE_GRID_FUNCTIONS.

  APPEND cl_gui_alv_grid=>mc_fc_maximum TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_minimum TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_subtot TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_sum TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_average TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_mb_sum TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_mb_subtot TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_graph TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_help TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_html TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_info TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_loc_cut TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_pc_file TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_print TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_loc_copy TO ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO  ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_loc_paste TO  ct_ui_functions_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_view_excel TO  ct_ui_functions_exclude.

  SORT ct_ui_functions_exclude.

  DELETE ADJACENT DUPLICATES FROM ct_ui_functions_exclude.

ENDMETHOD.


method FREE_OBJECT.
  me->grid_container->free( ).
  CLEAR me->grid_container.
endmethod.


METHOD HANDLE_OK_CODE.

  DATA:
        lt_cell               TYPE lvc_t_ceno,
        ls_cell               TYPE  lvc_s_ceno,
        lt_fieldnames         TYPE /idxgc/t_fieldnames,
        lv_fieldname          TYPE name_feld,
        ls_fieldcat           TYPE lvc_s_fcat,
        ls_proc_data          TYPE /idxgc/s_proc_data,
        lt_check_result       TYPE /idxgc/t_check_result_final,
        lr_process_log        TYPE REF TO /idxgc/if_process_log,
        lt_row                TYPE lvc_t_row,
        lv_error_flag         TYPE flag,
        lv_error_proc         TYPE flag,
        lv_index              TYPE i,
        ls_style              TYPE lvc_s_styl,
        lt_proc_log           TYPE /idxgc/t_pdoc_log,
        ls_proc_log           TYPE /idxgc/s_pdoc_log,
        lref_error            TYPE REF TO cl_isu_error_log,
        lv_lines              TYPE i,
        lv_object             TYPE swo_objtyp,
        lv_key                TYPE eidegenerickey,
        ls_obj                TYPE eideswtdoc_dialog_object.

  FIELD-SYMBOLS: <fs_row>        TYPE lvc_s_row,
                 <fs_orders_req> TYPE /idxgc/s_ui_bdr_orders_req,
                 <fs_fcat>       TYPE lvc_s_fcat.

  CASE gv_okcode.
    WHEN cl_isu_okcode=>co_back OR
         cl_isu_okcode=>co_canc.
      me->free_object( ).
      LEAVE TO SCREEN 0.

    WHEN cl_isu_okcode=>co_exit.
      me->free_object( ).
      LEAVE PROGRAM.

    WHEN cl_isu_okcode=>co_chck OR co_send.


      me->alv_grid->check_changed_data( ).

* check data
      CLEAR lv_error_flag.
      CLEAR lv_index.
      CREATE OBJECT lref_error.
      LOOP AT me->gt_orders_req ASSIGNING <fs_orders_req>.
        lv_index = lv_index + 1.

        IF <fs_orders_req>-proc_id IS INITIAL
        OR <fs_orders_req>-bdr_hdr IS INITIAL.
          <fs_orders_req>-bdr_hdr = gs_bdr_hdr.
        ENDIF.

        IF gr_badi_bdr IS BOUND.
          CLEAR: lt_fieldnames.
          CALL BADI gr_badi_bdr->check_orders_data_ui
            IMPORTING
              et_fieldnames      = lt_fieldnames
            CHANGING
              cs_bdr_orders_data = <fs_orders_req>
            EXCEPTIONS
              error_occurred     = 1
              OTHERS             = 2.
          IF sy-subrc <> 0.
            lv_error_flag = cl_isu_flag=>co_true.
            lref_error->add_message(  EXPORTING
                                        x_msgid = sy-msgid
                                        x_msgno = sy-msgno
                                        x_msgty = sy-msgty
                                        x_msgv1 = sy-msgv1
                                        x_msgv2 = sy-msgv2
                                        x_msgv3 = sy-msgv3
                                        x_msgv4 = sy-msgv4
                                      EXCEPTIONS
                                        OTHERS  = 1 ).


*           Get the colmn about the field
            LOOP AT lt_fieldnames INTO lv_fieldname.
              READ TABLE gt_fieldcat INTO ls_fieldcat WITH KEY fieldname = lv_fieldname.
              IF sy-subrc = 0.
                CLEAR: ls_cell.
                ls_cell-col_id = ls_fieldcat-col_pos.
                ls_cell-row_id = lv_index.
                APPEND ls_cell TO lt_cell.
              ENDIF.
            ENDLOOP.
            IF lt_fieldnames IS INITIAL.
*             Get selected row
              APPEND INITIAL LINE TO lt_row ASSIGNING <fs_row>.
              <fs_row>-index = lv_index.
            ENDIF.

          ENDIF.
        ENDIF.

        IF <fs_orders_req>-sender NE me->gv_sender AND
           me->gv_sender IS NOT INITIAL.
          <fs_orders_req>-sender   = me->gv_sender.
        ENDIF.
        IF <fs_orders_req>-receiver NE me->gv_receiver AND
           me->gv_receiver IS NOT INITIAL.
          <fs_orders_req>-receiver = me->gv_receiver.
        ENDIF.

      ENDLOOP.
      me->alv_grid->refresh_table_display( ).

      IF lt_cell IS NOT INITIAL.
        CALL METHOD me->alv_grid->set_selected_cells_id
          EXPORTING
            it_cells = lt_cell.
      ELSEIF lt_row IS NOT INITIAL.
        CALL METHOD me->alv_grid->set_selected_rows( it_index_rows = lt_row ).
      ENDIF.

*     Display any errors that occurred.
      lref_error->display_messages( EXCEPTIONS
                                    OTHERS = 1 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      IF gv_okcode = co_send AND lv_error_flag IS INITIAL.
*       send orders request if no error
        LOOP AT me->gt_orders_req ASSIGNING <fs_orders_req> WHERE proc_ref IS INITIAL.

          CLEAR: ls_proc_data,
                 lt_check_result,
                 lr_process_log,
                 lv_error_proc.

*         Prepare the process data for process document creation
*        TRY.
          CALL METHOD me->prepare_process_data
            EXPORTING
              is_bdr_orders_req = <fs_orders_req>
            CHANGING
              cs_process_data   = ls_proc_data.
*           CATCH /idxgc/cx_process_error .
*          ENDTRY.

          TRY.
              CALL METHOD /idxgc/cl_process_trigger=>start_process
                  EXPORTING
                   iv_only_synchronous    = <fs_orders_req>-async
*                   iv_raise_trigger_event = /IDXGC/IF_CONSTANTS=>GC_FALSE
                   iv_no_commit           = /idxgc/if_constants=>gc_false
*                   iv_no_exception        = /IDXGC/IF_CONSTANTS=>GC_FALSE
                    iv_pdoc_display        = /idxgc/if_constants=>gc_false
                  IMPORTING
*                   ev_not_launchable      =
                    et_check_result_final  = lt_check_result
*                   et_process_key_all     =
                    er_process_log         = lr_process_log
                  CHANGING
                    cs_process_data        = ls_proc_data
                  .
            CATCH /idxgc/cx_process_error .
              lv_error_proc = cl_isu_flag=>co_true.
          ENDTRY.

*         Check the process log
          IF lr_process_log IS NOT INITIAL.
            LOOP AT lt_proc_log INTO ls_proc_log
                WHERE msgty = /idxgc/if_constants_ide=>gc_msgty_e.
              MESSAGE ID ls_proc_log-msgid TYPE ls_proc_log-msgty NUMBER ls_proc_log-msgno
                      WITH ls_proc_log-msgv1 ls_proc_log-msgv2 ls_proc_log-msgv3 ls_proc_log-msgv4
                      INTO <fs_orders_req>-status_text.
              lv_error_proc = cl_isu_flag=>co_true.
              EXIT.
            ENDLOOP.
          ENDIF.

          IF lv_error_proc IS INITIAL.
            IF ls_proc_data-proc_ref IS NOT INITIAL.
              <fs_orders_req>-proc_ref = ls_proc_data-proc_ref.
            ENDIF.

            MESSAGE s092(/idxgc/process) INTO <fs_orders_req>-status_text.

*           de-activate the edit mode for success records.
            LOOP AT me->gt_fieldcat ASSIGNING <fs_fcat>.
              ls_style-fieldname  = <fs_fcat>-fieldname.
              ls_style-style     = cl_gui_alv_grid=>mc_style_disabled.
              ls_style-maxlen    = 8.
              INSERT ls_style INTO TABLE <fs_orders_req>-cellsttyle.
            ENDLOOP.

          ELSE.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO <fs_orders_req>-status_text.
          ENDIF.

        ENDLOOP.

*       IF there is only one PDoc created, then open it immediatedly
        DESCRIBE TABLE me->gt_orders_req LINES lv_lines.
        IF lv_lines = 1.
          READ TABLE me->gt_orders_req ASSIGNING <fs_orders_req> INDEX 1.
          IF sy-subrc = 0.
            CHECK <fs_orders_req>-proc_ref IS NOT INITIAL.
            lv_object = /idxgc/if_constants=>gc_object_pdoc_bor.
            lv_key    = <fs_orders_req>-proc_ref.
            CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY_BOR'
              EXPORTING
                x_object      = lv_object
                x_key         = lv_key
                x_obj         = ls_obj
              EXCEPTIONS
                general_fault = 1
                OTHERS        = 2.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE /idxgc/if_constants=>gc_message_type_success
                      NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
        ENDIF.

        me->alv_grid->refresh_table_display( ).

      ENDIF.
  ENDCASE.

ENDMETHOD.


METHOD ON_DATA_CHANGED.

  TYPES: BEGIN OF tp_addr,
           addrnumber  TYPE adrc-addrnumber,
           housenr     TYPE adrc-house_num1,
           postcode    TYPE adrc-post_code1,
           street      TYPE adrc-mc_street,
           city        TYPE adrc-mc_city1,
         END OF tp_addr,

         BEGIN OF tp_iflot,
           adrnr    TYPE iloa-adrnr,
           iloan    TYPE iloa-iloan,
           tplnr    TYPE iloa-tplnr,
         END OF tp_iflot.

  DATA: ls_mod_cells          TYPE lvc_s_modi,
        lv_ext_ui             TYPE ext_ui,
        lt_partner            TYPE TABLE OF bapiisupodpartner,
        ls_partner            TYPE bapiisupodpartner.

  DATA: lv_anlage             TYPE euiinstln-anlage.
  DATA: ls_iflot              TYPE tp_iflot,
        ls_evbs               TYPE evbs,
        ls_eanl               TYPE eanl,
        ls_addrnumber         TYPE tp_addr.

* doing following process only for master data

  LOOP AT er_data_changed->mt_mod_cells INTO ls_mod_cells
                                       WHERE fieldname = co_fieldname_ext_ui
                                          OR fieldname = co_fieldname_bu_partner.
    CASE ls_mod_cells-fieldname.
      WHEN co_fieldname_ext_ui.

        CHECK ls_mod_cells-value IS NOT INITIAL.

*   get installation via external POD
        SELECT SINGLE euiinstln~anlage          "#EC *
          FROM euitrans
          JOIN euiinstln ON
           euitrans~int_ui   = euiinstln~int_ui
          INTO lv_anlage
         WHERE euitrans~ext_ui = ls_mod_cells-value
           AND euitrans~dateto >= euiinstln~datefrom
           AND euiinstln~dateto >= euitrans~datefrom.

        IF sy-subrc = 0.

*     get primise via installation
          SELECT SINGLE *
            FROM eanl
            INTO ls_eanl
           WHERE anlage = lv_anlage.

          IF sy-subrc = 0.

*       get connection object via primise
            SELECT SINGLE *
              FROM evbs
              INTO ls_evbs
             WHERE vstelle = ls_eanl-vstelle.

            IF sy-subrc = 0.

*         get addressnumber via connection object
              SELECT iloa~adrnr
                     iloa~iloan
                     iloa~tplnr
                UP TO 1 ROWS
                FROM iloa JOIN iflot
                  ON iloa~iloan = iflot~iloan
                 AND iloa~tplnr = iflot~tplnr
                INTO ls_iflot
               WHERE iflot~tplnr = ls_evbs-haus.
              ENDSELECT.

              IF sy-subrc = 0.

*           get address via addressnumber
                CLEAR: ls_addrnumber.
                SELECT addrnumber
                       house_num1
                       post_code1
                       mc_street
                       mc_city1
                  UP TO 1 ROWS
                  FROM adrc
                  INTO ls_addrnumber
                 WHERE addrnumber = ls_iflot-adrnr.
                ENDSELECT.

                CALL METHOD er_data_changed->modify_cell
                  EXPORTING
                    i_row_id    = ls_mod_cells-row_id
                    i_fieldname = co_fieldname_housenr
                    i_value     = ls_addrnumber-housenr.

                CALL METHOD er_data_changed->modify_cell
                  EXPORTING
                    i_row_id    = ls_mod_cells-row_id
                    i_fieldname = co_fieldname_postcode
                    i_value     = ls_addrnumber-postcode.

                CALL METHOD er_data_changed->modify_cell
                  EXPORTING
                    i_row_id    = ls_mod_cells-row_id
                    i_fieldname = co_fieldname_street
                    i_value     = ls_addrnumber-street.

                CALL METHOD er_data_changed->modify_cell
                  EXPORTING
                    i_row_id    = ls_mod_cells-row_id
                    i_fieldname = co_fieldname_city
                    i_value     = ls_addrnumber-city.

              ENDIF.
            ENDIF.
          ENDIF.

*     Call BAPI to get the business partness number by Pod
          lv_ext_ui = ls_mod_cells-value.

          CLEAR: lt_partner.

          CALL FUNCTION 'BAPI_ISUPOD_GETPARTNER'
            EXPORTING
              pointofdelivery       = lv_ext_ui
*         KEYDATE               = SY-DATUM
*         REFRESH_BUFFER        = ' '
            TABLES
              partner               = lt_partner
*         RETURN                =
              .
          READ TABLE lt_partner INTO ls_partner INDEX 1.
          IF sy-subrc = 0.
            CALL METHOD er_data_changed->modify_cell
              EXPORTING
                i_row_id    = ls_mod_cells-row_id
                i_fieldname = co_fieldname_bu_partner
                i_value     = ls_partner-partner.


          ENDIF.

        ENDIF.


    ENDCASE.
  ENDLOOP.



ENDMETHOD.


METHOD ON_DOUBLE_CLICK.

  DATA:
        lv_object         TYPE swo_objtyp,
        lv_key            TYPE eidegenerickey,
        ls_obj            TYPE eideswtdoc_dialog_object.

  FIELD-SYMBOLS: <fs_orders_req> TYPE /idxgc/s_ui_bdr_orders_req.

  READ TABLE me->gt_orders_req ASSIGNING <fs_orders_req> INDEX e_row-index.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CASE e_column-fieldname.
    WHEN /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_sender.
* display service provider
      CHECK <fs_orders_req>-sender IS NOT INITIAL.
      CALL METHOD cl_isu_serviceprovider=>servprov_display
        EXPORTING
          x_serviceid      = <fs_orders_req>-sender
        EXCEPTIONS
          wrong_input_data = 1
          OTHERS           = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE /idxgc/if_constants=>gc_message_type_success
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_receiver.
* display service provider
      CHECK <fs_orders_req>-receiver IS NOT INITIAL.
      CALL METHOD cl_isu_serviceprovider=>servprov_display
        EXPORTING
          x_serviceid      = <fs_orders_req>-receiver
        EXCEPTIONS
          wrong_input_data = 1
          OTHERS           = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE /idxgc/if_constants=>gc_message_type_success
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN /idxgc/cl_bdr_orders_req_cntr=>co_fieldname_proc_ref.     " process document
      CHECK <fs_orders_req>-proc_ref IS NOT INITIAL.
      lv_object = /idxgc/if_constants=>gc_object_pdoc_bor.
      lv_key    = <fs_orders_req>-proc_ref.
      CALL FUNCTION '/IDXGC/FM_PDOC_DISPLAY_BOR'
        EXPORTING
          x_object      = lv_object
          x_key         = lv_key
          x_obj         = ls_obj
        EXCEPTIONS
          general_fault = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE /idxgc/if_constants=>gc_message_type_success
                NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

  ENDCASE.

ENDMETHOD.


METHOD PAI.

  TRY .
      me->alv_grid->check_changed_data( ).
      me->gv_okcode = iv_okcode.
      me->handle_ok_code( ).
    CATCH /idxgc/cx_process_error.   "#EC NO_HANDLER
*   Ignore
  ENDTRY.

ENDMETHOD.


METHOD PREPARE_PROCESS_DATA.

  DATA:
        ls_proc_step        TYPE /idxgc/s_proc_step_data,
        ls_proc_step_config TYPE /idxgc/s_proc_step_config_all,
        ls_ord_item_add     TYPE /idxgc/s_ord_item_details.


* Set the process header data
  cs_process_data-proc_id         = is_bdr_orders_req-proc_id.
  cs_process_data-proc_type       = is_bdr_orders_req-proc_type.
  cs_process_data-proc_view       = is_bdr_orders_req-proc_view.
  cs_process_data-proc_date       = sy-datum.
  cs_process_data-bu_partner      = is_bdr_orders_req-bu_partner.
  cs_process_data-key_docname_code = is_bdr_orders_req-docname_code.

  IF is_bdr_orders_req-ext_ui IS NOT INITIAL.
    TRY.
        CALL METHOD /idxgc/cl_utility_service_isu=>get_intui_from_extui
          EXPORTING
            iv_ext_ui = is_bdr_orders_req-ext_ui
            iv_date   = sy-datum
          IMPORTING
            rv_int_ui = cs_process_data-int_ui.

        IF cs_process_data-int_ui IS NOT INITIAL.

          CALL METHOD /idxgc/cl_utility_service_isu=>get_divcat_from_intui
            EXPORTING
              iv_int_ui    = cs_process_data-int_ui
              iv_proc_date = sy-datum
            RECEIVING
              rv_divcat    = cs_process_data-spartyp.
        ENDIF.

      CATCH /idxgc/cx_utility_error .                   "#EC NO_HANDLER
*       Ignore this error
    ENDTRY.
  ENDIF.

* Prepare the process step data
  ls_proc_step-own_servprov = is_bdr_orders_req-sender.
  ls_proc_step-assoc_servprov = is_bdr_orders_req-receiver.
  ls_proc_step-ext_ui = is_bdr_orders_req-ext_ui.
  ls_proc_step-supply_direct  = is_bdr_orders_req-supply_direct.
  ls_proc_step-docname_code = is_bdr_orders_req-docname_code.

* Populate initial message date and time
  ls_proc_step-msg_date = sy-datum.
  ls_proc_step-msg_time = sy-uzeit.

* Get first step number
  READ TABLE gs_proc_config-steps INTO ls_proc_step_config
    WITH KEY category = /idxgc/if_constants_add=>gc_proc_step_cat_init
             source = /idxgc/if_constants_add=>gc_owner_type_cust.
  IF sy-subrc EQ 0.
    ls_proc_step-proc_step_no = ls_proc_step_config-proc_step_no.
  ELSE.
    READ TABLE gs_proc_config-steps INTO ls_proc_step_config
      WITH KEY category = /idxgc/if_constants_add=>gc_proc_step_cat_init
               source = /idxgc/if_constants_add=>gc_owner_type_sap.
    IF sy-subrc EQ 0.
      ls_proc_step-proc_step_no = ls_proc_step_config-proc_step_no.
    ENDIF.
  ENDIF.

* Get additional data of ORDERS/ORDRSP items in case of message category Z27 and Z28
  IF ( ls_proc_step-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z27 ) OR
     ( ls_proc_step-docname_code = /idxgc/if_constants_ide=>gc_msg_category_z28 ).
    ls_ord_item_add-item_id = 1.
    ls_ord_item_add-start_read_date = is_bdr_orders_req-date_from.
    ls_ord_item_add-end_read_date = is_bdr_orders_req-date_to.
    APPEND ls_ord_item_add TO ls_proc_step-ord_item_add.
  ENDIF.

  APPEND ls_proc_step TO cs_process_data-steps.

  IF gr_badi_bdr IS BOUND.
    CALL BADI gr_badi_bdr->enhance_step_data
      EXPORTING
        is_bdr_orders_data = is_bdr_orders_req
      CHANGING
        cs_proc_data       = cs_process_data.
  ENDIF.

ENDMETHOD.
ENDCLASS.
