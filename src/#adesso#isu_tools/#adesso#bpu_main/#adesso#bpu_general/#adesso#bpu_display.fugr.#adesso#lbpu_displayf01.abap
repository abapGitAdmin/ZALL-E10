CLASS lcl_gui_alv_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no.
ENDCLASS.
CLASS lcl_gui_alv_event_receiver IMPLEMENTATION.

  METHOD handle_hotspot_click .

    DATA: lv_row      TYPE char2,
          ls_cust_gen TYPE /adesso/bpu_s_gen.

    WRITE es_row_no-row_id TO lv_row.

    READ TABLE gt_object ASSIGNING FIELD-SYMBOL(<fs_object>) INDEX lv_row.

    TRY.
        ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).
        CALL METHOD (ls_cust_gen-obj_display_class)=>(<fs_object>-display_method)
          EXPORTING
            iv_object_id      = <fs_object>-id
            is_proc_step_data = gs_proc_step_data.
      CATCH /idxgc/cx_general.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDTRY.

  ENDMETHOD .
ENDCLASS.
FORM init_header_data.

  TYPES: typ_itab TYPE dd07t.

  DATA: itab       TYPE STANDARD TABLE OF typ_itab,
        wa_itab    LIKE LINE OF itab,
        lt_listdox TYPE vrm_values,
        wa_listbox LIKE LINE OF lt_listdox.

  FIELD-SYMBOLS: <fs_msgrespstatus> TYPE /idxgc/s_msgsts_details,
                 <fs_amid>          TYPE /idxgc/s_amid_details.


* Hole die zur Anzeige der Kopfdaten benötigten Daten aus dem ermittelten Prozessschrittdaten
  MOVE-CORRESPONDING gs_proc_step_data TO gs_header_proc.

  SELECT SINGLE swttypetxt FROM eideswttypest INTO gs_header_proc-proc_type_descr WHERE swttype = gs_proc_step_data-proc_type AND spras = sy-langu.

  SELECT SINGLE proc_descr FROM /idxgc/proct INTO gs_header_proc-proc_descr WHERE proc_id = gs_proc_step_data-proc_id AND spras = sy-langu.

  SELECT * FROM dd07t INTO TABLE itab WHERE ddlanguage = sy-langu AND domname = 'EMMA_CPRIO'.

  LOOP AT itab ASSIGNING FIELD-SYMBOL(<fs_tmp>).
    wa_listbox-key = <fs_tmp>-domvalue_l.
    wa_listbox-text = <fs_tmp>-ddtext.
    APPEND wa_listbox TO lt_listdox.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_LISTBOX_PRIO'
      values = lt_listdox.

  CLEAR: itab, lt_listdox.

  SELECT * FROM dd07t INTO TABLE itab WHERE ddlanguage = sy-langu AND domname = 'EMMA_CSTATUS'.

  LOOP AT itab ASSIGNING <fs_tmp>.
    wa_listbox-key = <fs_tmp>-domvalue_l.
    wa_listbox-text = <fs_tmp>-ddtext.
    APPEND wa_listbox TO lt_listdox.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_LISTBOX_STATUS'
      values = lt_listdox.

  gv_listbox_prio = gs_case-prio.
  gv_listbox_status = gs_case-status.

  MOVE-CORRESPONDING gs_case TO gs_header_emma.

  READ TABLE gs_proc_step_data_src_add-amid ASSIGNING <fs_amid> INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE text FROM /idxgc/amidt INTO gs_header_proc-amid_text WHERE spras = sy-langu AND amid = <fs_amid>-amid.
  ENDIF.

  READ TABLE gs_proc_step_data_src_add-msgrespstatus ASSIGNING <fs_msgrespstatus> INDEX 1.
  IF sy-subrc = 0.
    gs_header_proc-respstatus = <fs_msgrespstatus>-respstatus.
  ENDIF.

ENDFORM.
FORM init_case_desc.
  DATA: lt_text_stream TYPE STANDARD TABLE OF c.

  IF gr_case_desc IS INITIAL.
    gr_case_desc_container = NEW cl_gui_custom_container( container_name = 'CASE_DESC' ).
    gr_case_desc = NEW cl_gui_textedit( parent = gr_case_desc_container ).
    gr_case_desc->set_wordwrap_behavior( wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder wordwrap_to_linebreak_mode = 1 ).
    gr_case_desc->set_toolbar_mode( toolbar_mode = cl_gui_textedit=>false ).
    gr_case_desc->set_statusbar_mode( statusbar_mode = cl_gui_textedit=>false ).
    gr_case_desc->set_readonly_mode( readonly_mode = cl_gui_textedit=>true ).
  ENDIF.

  CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
    EXPORTING
      language    = sy-langu
    TABLES
      itf_text    = gt_tline
      text_stream = lt_text_stream.

  gr_case_desc->set_text_as_stream( text = lt_text_stream ).

ENDFORM.
FORM init_messages.

  DATA: lt_catalog TYPE lvc_t_fcat,
        ls_layout  TYPE lvc_s_layo.

  FIELD-SYMBOLS: <fs_catalog> TYPE lvc_s_fcat.

  IF gr_process_log_container IS INITIAL.

    ls_layout-no_toolbar = abap_true.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = 'EMMA_CTXN_ALVMSG'
      CHANGING
        ct_fieldcat      = lt_catalog.

*   Aktiviere Spaltenoptimierung für alle Spalten
    LOOP AT lt_catalog ASSIGNING <fs_catalog>.
      <fs_catalog>-col_opt = abap_true.
    ENDLOOP.

    LOOP AT lt_catalog ASSIGNING <fs_catalog> WHERE fieldname = 'MSGV1' OR fieldname = 'MSGV2' OR fieldname = 'MSGV3' OR fieldname = 'MSGV4'.
      <fs_catalog>-no_out = abap_true.
    ENDLOOP.

    gr_process_log_container = NEW cl_gui_custom_container( container_name = 'PROC_LOG' ).
    gr_process_log = NEW cl_gui_alv_grid( i_parent = gr_process_log_container ).

    gr_process_log->set_table_for_first_display( EXPORTING i_structure_name = 'EMMA_CTXN_ALVMSG' is_layout = ls_layout
                                                 CHANGING it_fieldcatalog = lt_catalog it_outtab = gt_message ).

  ENDIF.

ENDFORM.
FORM init_obj_list.

  DATA: ls_layout        TYPE lvc_s_layo,
        lt_catalog       TYPE lvc_t_fcat,
        lr_click_handler TYPE REF TO lcl_gui_alv_event_receiver.

  FIELD-SYMBOLS: <fs_catalog> TYPE lvc_s_fcat.

  IF gr_obj_list_container IS INITIAL.

    gr_obj_list_container = NEW cl_gui_custom_container( container_name = 'OBJ_LIST' ).
    gr_obj_list           = NEW cl_gui_alv_grid( i_parent = gr_obj_list_container ).
    lr_click_handler      = NEW lcl_gui_alv_event_receiver( ).

    SET HANDLER lr_click_handler->handle_hotspot_click FOR gr_obj_list.

  ENDIF.

* Erstelle den Feldkatalog auf Grundlage der Struktur 'BAPI_EMMA_CASE_OBJECT'
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'BAPI_EMMA_CASE_OBJECT'
    CHANGING
      ct_fieldcat      = lt_catalog.

* Blende initial alle Spalten aus
  LOOP AT lt_catalog ASSIGNING <fs_catalog>.
    <fs_catalog>-no_out = abap_true.
  ENDLOOP.

* Blende die benötigten Spalten ein, aktiviere die Spaltenoptimierung
  LOOP AT lt_catalog ASSIGNING <fs_catalog> WHERE fieldname = 'CELEMNAME'.
    <fs_catalog>-no_out = ''.
    <fs_catalog>-col_opt = abap_true.
  ENDLOOP.

* Blende die benötigten Spalten ein, aktiviere die Spaltenoptimierung
  LOOP AT lt_catalog ASSIGNING <fs_catalog> WHERE fieldname = 'ID'.
    <fs_catalog>-no_out = ''.
    <fs_catalog>-col_opt = abap_true.
    <fs_catalog>-hotspot = abap_true.
  ENDLOOP.

* Blende die Toolbar des ALV-Grids aus
  ls_layout-no_toolbar = abap_true.

* Entferne nicht benötigte Objekte aus der Tabelle gt_emma_objs
  DELETE gt_object WHERE celemname = 'ExceptionCode' OR celemname = 'ProcStepNo'
    OR celemname = 'ProcStepRef' OR celemname = 'ProcessID'.

  gr_obj_list->set_table_for_first_display( EXPORTING i_structure_name = 'BAPI_EMMA_CASE_OBJECT' is_layout = ls_layout
                                            CHANGING it_fieldcatalog = lt_catalog it_outtab = gt_object ).

ENDFORM.
