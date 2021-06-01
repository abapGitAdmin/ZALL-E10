*----------------------------------------------------------------------*
***INCLUDE /adz/LMDC_DISPLAYF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LOAD_DATA_INTO_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM  load_data_into_grid .
  FIELD-SYMBOLS: <fs_msgrespstatus> TYPE /idxgc/s_msgsts_details,
                 <fs_amid>          TYPE /idxgc/s_amid_details.

***** Kopfdaten füllen ****************************************************************************
  gs_header-proc_id        = gs_proc_step_data-proc_id.
  SELECT SINGLE proc_descr FROM /idxgc/proct INTO gs_header-proc_descr WHERE proc_id = gs_proc_step_data-proc_id AND spras = sy-langu.
  gs_header-proc_ref       = gs_proc_step_data-proc_ref.
  gs_header-proc_type      = gs_proc_step_data-proc_type.
  gs_header-proc_date      = gs_proc_step_data-proc_date.
  gs_header-ext_ui         = gs_proc_step_data-ext_ui.
  gs_header-bu_partner     = gs_proc_step_data-bu_partner.
  gs_header-assoc_servprov = gs_proc_step_data-assoc_servprov.
  gs_header-own_servprov   = gs_proc_step_data-own_servprov.
  READ TABLE gs_proc_step_data_src_add-amid ASSIGNING <fs_amid> INDEX 1.
  IF sy-subrc = 0.
    gs_header-amid         = <fs_amid>-amid.
    SELECT SINGLE text FROM /idxgc/amidt INTO gs_header-amid_descr WHERE spras = sy-langu AND amid = <fs_amid>-amid.
  ENDIF.
  READ TABLE gs_proc_step_data_src_add-msgrespstatus ASSIGNING <fs_msgrespstatus> INDEX 1.
  IF sy-subrc = 0.
    gs_header-respstatus   = <fs_msgrespstatus>-respstatus.
  ENDIF.

***** Grid füllen *********************************************************************************
  PERFORM reload_alv_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM modify_fieldcatalog.
  DATA: ls_layout   TYPE lvc_s_layo.
  DATA: ls_fieldcat TYPE lvc_s_fcat.

* Bezeichnung
  ls_fieldcat-fieldname = 'FIELDNAME'.
  ls_fieldcat-coltext   = 'Bezeichnung'.
  ls_fieldcat-col_pos   = 1.
  ls_fieldcat-outputlen = 20.
  APPEND ls_fieldcat TO gt_fieldcat.

* Eigene Werte
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SRC_FIELD_VALUE'.
  ls_fieldcat-coltext   = 'Eigene Werte'.
  ls_fieldcat-col_pos   = 2.
  ls_fieldcat-outputlen = 20.
  APPEND ls_fieldcat TO gt_fieldcat.

* Empfangene Werte
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CMP_FIELD_VALUE'.
  ls_fieldcat-coltext   = 'Empfangene Werte'.
  ls_fieldcat-col_pos   = 3.
  ls_fieldcat-outputlen = 20.
  APPEND ls_fieldcat TO gt_fieldcat.

* Flag Autochange
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUTO_CHANGE'.
  ls_fieldcat-coltext   = 'Verbuchung'.
  ls_fieldcat-col_pos   = 4.
  ls_fieldcat-outputlen = 15.
  APPEND ls_fieldcat TO gt_fieldcat.

* EDIFACT
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'EDIFACT_NAME'.
  ls_fieldcat-coltext   = 'EDIFACT'.
  ls_fieldcat-col_pos   = 5.
  ls_fieldcat-outputlen = 35.
  APPEND ls_fieldcat TO gt_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_layout_and_display .

  gs_layout-grid_title = ' '.         " Überschrift
*  ls_layout-sel_mode   = 'A'.        "<-- Markierungsspalte einblenden
  gs_layout-sel_mode   = 'B'.         "<-- Anwender darf nur eine Zeile markieren
  gs_layout-info_fname = 'ROWCOLOR'.  " Spaltenname für das Setzen der Zeilenfarbe
  gs_layout-ctab_fname = 'CELLCOLOR'. " Spaltenname für das Setzen der Zellenfarbe

  CALL METHOD gr_grid->set_table_for_first_display
    EXPORTING
      i_structure_name              = gc_tabname
      i_bypassing_buffer            = abap_true
      i_save                        = 'A'
      is_layout                     = gs_layout
    CHANGING
      it_outtab                     = gt_seltab
      it_fieldcatalog               = gt_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  RELOAD_ALV_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM reload_alv_grid .
  DATA: lr_dref             TYPE REF TO data,
        lr_dref_log         TYPE REF TO data,
        ls_mdc_in           TYPE /adz/mdc_in,
        ls_cellcolor        TYPE lvc_s_scol,
        lv_edifact_structur TYPE /idxgc/de_edifact_str,
        lv_dom_value        TYPE domvalue_l.

  FIELD-SYMBOLS: <fr_ref>             TYPE any,
                 <fr_ref_log>         TYPE any,
                 <fs_seltab>          TYPE ts_seltab,
                 <fs_mtd_code_result> TYPE /idxgc/s_mtd_code_details.

***** Daten neu lesen *****************************************************************************
  TRY.
      CREATE DATA lr_dref TYPE REF TO /idxgc/if_process_data_extern.
      ASSIGN lr_dref->* TO <fr_ref>.
      <fr_ref> = gr_ctx->gr_process_data_extern.

      CREATE DATA lr_dref_log TYPE REF TO /idxgc/if_process_log.
      ASSIGN lr_dref_log->* TO <fr_ref_log>.
      <fr_ref_log> = gr_ctx->gr_process_log.

      CALL METHOD /adz/cl_mdc_check_method=>update_step_data_from_system
        EXPORTING
          is_process_step_key = gs_proc_step_key
        CHANGING
          cr_data             = lr_dref
          cr_data_log         = lr_dref_log.
      CALL METHOD /adz/cl_mdc_check_method=>update_compare_result_select
        EXPORTING
          is_process_step_key = gs_proc_step_key
        CHANGING
          cr_data             = lr_dref
          cr_data_log         = lr_dref_log.

      gs_proc_step_data = gr_ctx->gr_process_data_extern->get_process_step_data( gs_proc_step_key ).
    CATCH /idxgc/cx_utility_error /idxgc/cx_process_error.
      "Zunächst keine Fehlerbehandlung
  ENDTRY.

***** interne Tabelle/ALV mit DATEN füllen ********************************************************
  CLEAR gt_seltab.
  LOOP AT gs_proc_step_data-mtd_code_result ASSIGNING <fs_mtd_code_result>.
    APPEND INITIAL LINE TO gt_seltab ASSIGNING <fs_seltab>.
    <fs_seltab>-fieldname        = <fs_mtd_code_result>-fieldname.
    PERFORM get_elem_description USING <fs_mtd_code_result> CHANGING <fs_seltab>-fieldname.
    <fs_seltab>-src_field_value  = <fs_mtd_code_result>-src_field_value.
    <fs_seltab>-cmp_field_value  = <fs_mtd_code_result>-cmp_field_value.
    <fs_seltab>-edifact_name     = <fs_mtd_code_result>-addinfo.

    lv_edifact_structur = <fs_mtd_code_result>-addinfo.
    TRY.
        ls_mdc_in = /adz/cl_mdc_customizing=>get_inbound_config_for_edifact( iv_edifact_structur = lv_edifact_structur iv_assoc_servprov = gs_proc_step_data-assoc_servprov ).
      CATCH /idxgc/cx_general.
        "Wenn kein Customizing vorhanden ist, dann wird immer manuell geändert
    ENDTRY.

*---> IR start
*    IF gs_header-respstatus IS INITIAL.

*IR--->Das Feld auto_change in der Struktur /adz/s_mdc_in bzw. /adz/mdc_in fehlt /// in /adesso/mdc_in jedoch vorhanden
*      lv_dom_value = ls_mdc_in-auto_change.
*      CALL FUNCTION 'ISU_DOMVALUE_TEXT_GET'
*        EXPORTING
*          x_name  = '/ADZ/MDC_AUTO_CHANGE'
*          x_value = lv_dom_value
*        IMPORTING
*          y_text  = <fs_seltab>-auto_change.

*    ELSE.
*IR--->Das Feld auto_change_response in der Struktur /adz/s_mdc_in bzw. /adz/mdc_in fehlt /// in /adesso/mdc_in jedoch vorhanden
*      lv_dom_value = ls_mdc_in-auto_change_response.
*      CALL FUNCTION 'ISU_DOMVALUE_TEXT_GET'
*        EXPORTING
*          x_name  = '/ADZ/MDC_AUTO_CHANGE_RSP'
*          x_value = lv_dom_value
*        IMPORTING
*          y_text  = <fs_seltab>-auto_change.
*    ENDIF.


    <fs_seltab>-badi_name   = ls_mdc_in-badi_name.
    <fs_seltab>-rowcolor    = 'C500'.

    IF <fs_seltab>-src_field_value <> <fs_seltab>-cmp_field_value.
      ls_cellcolor-fname     = 'SRC_FIELD_VALUE'.
      ls_cellcolor-color-col = col_negative.
      APPEND ls_cellcolor TO <fs_seltab>-cellcolor.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_ELEMDESCRIPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_elem_description  USING    ps_mtd_code_result  TYPE /idxgc/s_mtd_code_details
                           CHANGING ps_fieldname        TYPE fieldname.

  CONSTANTS: lc_struct TYPE string VALUE '/IDXGC/S_PROC_STEP_DATA_ALL-'.

  DATA:  lv_valuedisc(100)   TYPE c.
  DATA:  ls_flddescr         TYPE dfies.
  DATA:  lo_elemdescr        TYPE REF TO cl_abap_elemdescr.
  DATA:  lo_typedescr        TYPE REF TO cl_abap_typedescr.
  DATA:  lo_structdescr      TYPE REF TO cl_abap_structdescr.
  DATA:  lo_tabledescr       TYPE REF TO cl_abap_tabledescr.
*DATA:  lo_datadescr        TYPE REF TO cl_abap_datadescr.

  CONCATENATE lc_struct ps_mtd_code_result-compname INTO lv_valuedisc.

  lo_typedescr ?= cl_abap_typedescr=>describe_by_name( lv_valuedisc ).

  CASE lo_typedescr->kind.
* Tabellentyp
    WHEN cl_abap_typedescr=>kind_table.

      lo_tabledescr  ?= cl_abap_typedescr=>describe_by_name( lv_valuedisc ).
      lo_structdescr ?= lo_tabledescr->get_table_line_type( ).
      lo_elemdescr   ?= lo_structdescr->get_component_type( ps_mtd_code_result-fieldname ).

* Struktur
    WHEN cl_abap_typedescr=>kind_struct.

      lo_structdescr ?= cl_abap_typedescr=>describe_by_name( lv_valuedisc ).
      lo_elemdescr   ?= lo_structdescr->get_component_type( ps_mtd_code_result-fieldname ).

* Elementarer Typ
    WHEN cl_abap_typedescr=>kind_elem.

      lo_elemdescr   ?= cl_abap_typedescr=>describe_by_name( ps_mtd_code_result-fieldname ).

  ENDCASE.


  IF lo_elemdescr IS NOT INITIAL.
    CALL METHOD lo_elemdescr->get_ddic_field
      RECEIVING
        p_flddescr   = ls_flddescr
      EXCEPTIONS
        not_found    = 1
        no_ddic_type = 2
        OTHERS       = 3.
    IF sy-subrc <> 0.
*      RAISE error_occurred.
    ELSE.
      MOVE ls_flddescr-fieldtext TO  ps_fieldname.
    ENDIF.
  ENDIF.

ENDFORM.
