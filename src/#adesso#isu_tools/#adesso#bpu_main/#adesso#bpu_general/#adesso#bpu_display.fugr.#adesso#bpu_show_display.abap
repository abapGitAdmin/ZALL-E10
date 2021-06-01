FUNCTION /adesso/bpu_show_display.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IV_CLEAR_CASE_DESCRIPTION) TYPE  BOOLEAN DEFAULT
*"       ABAP_FALSE
*"     REFERENCE(IV_CLEAR_CASE_MESSAGES) TYPE  BOOLEAN DEFAULT
*"       ABAP_FALSE
*"     REFERENCE(IV_CLEAR_CASE_OBJECTS) TYPE  BOOLEAN DEFAULT
*"       ABAP_FALSE
*"     REFERENCE(IV_CLEAR_HEADER_CASE) TYPE  BOOLEAN DEFAULT ABAP_FALSE
*"     REFERENCE(IV_CLEAR_HEADER_PROC) TYPE  BOOLEAN DEFAULT ABAP_FALSE
*"     REFERENCE(IV_SUB_REPID) TYPE  REPID OPTIONAL
*"     REFERENCE(IV_SUB_DYNNR) TYPE  DYNNR DEFAULT '9001'
*"     REFERENCE(IS_CHECK_LIST_RESULT) TYPE  /IDXGC/S_CHECK_LIST_RESULT
*"       OPTIONAL
*"     REFERENCE(IS_CASE) TYPE  EMMA_CASE OPTIONAL
*"     REFERENCE(IS_PROC_STEP_DATA) TYPE  /IDXGC/S_PROC_STEP_DATA_ALL
*"       OPTIONAL
*"     REFERENCE(IT_CASE_OBJECT) TYPE  /ADESSO/BPU_T_EMMA_CASE_OBJECT
*"       OPTIONAL
*"     REFERENCE(IT_TLINE) TYPE  TSFTEXT OPTIONAL
*"     REFERENCE(IT_CASE_MESSAGE) TYPE  EMMA_MSG_LINK_TAB OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  /ADESSO/BPU_T_RET_SHOW_DISP
*"----------------------------------------------------------------------
  DATA: lr_bpu_emma_case TYPE REF TO /adesso/cl_bpu_emma_case.

  CLEAR: gt_message, gt_tline, gt_object, gt_return, gs_proc_step_data, gs_case.

* Leere mögliche zuvor vom Benutzer getätigte Eingaben
  CLEAR: gv_endnextposs_from, gv_free_text_value, gv_frist_z12.

  IF is_check_list_result IS NOT INITIAL.
    TRY.
        lr_bpu_emma_case = /adesso/cl_bpu_emma_case=>get_instance( is_check_list_result = is_check_list_result ).
      CATCH /idxgc/cx_general.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        EXIT.
    ENDTRY.

    gs_case      = lr_bpu_emma_case->get_case( ).
    gt_object    = lr_bpu_emma_case->get_objects( ).
    TRY.
        gt_tline = lr_bpu_emma_case->get_description( ).
      CATCH /idxgc/cx_general.
        "Ohne Beschreibung anzeigen.
    ENDTRY.

    TRY.
        gt_message = lr_bpu_emma_case->get_messages( ).
      CATCH /idxgc/cx_general.
        "Ohne Beschreibung anzeigen.
    ENDTRY.

    gs_proc_step_data = lr_bpu_emma_case->get_proc_step_data( ).
  ENDIF.

  IF iv_clear_header_case = abap_true.
    CLEAR: gs_case.
  ENDIF.
  IF is_case IS NOT INITIAL.
    TRY.
        /adesso/cl_bpu_utility=>move_corresponding_ignore_init( EXPORTING is_struct_source = is_case
                                                                CHANGING  cs_struct_dest   = gs_case ).
      CATCH /idxgc/cx_general.
        "Keine neuen Daten übernehmen.
    ENDTRY.
  ENDIF.

  IF iv_clear_header_proc = abap_true.
    CLEAR: gs_proc_step_data.
  ENDIF.
  IF is_proc_step_data IS NOT INITIAL.
    TRY.
        /adesso/cl_bpu_utility=>move_corresponding_ignore_init( EXPORTING is_struct_source = is_proc_step_data
                                                                CHANGING  cs_struct_dest   = gs_proc_step_data ).
      CATCH /idxgc/cx_general.
        "Keine neuen Daten übernehmen.
    ENDTRY.
  ENDIF.

  IF iv_clear_case_description = abap_true.
    CLEAR: gt_tline.
  ENDIF.
  IF it_tline IS NOT INITIAL.
    APPEND LINES OF it_tline TO gt_tline.
  ENDIF.

  IF iv_clear_case_objects = abap_true.
    CLEAR: gt_object.
  ENDIF.
  IF it_case_object IS NOT INITIAL.
    APPEND LINES OF it_case_object TO gt_object.
  ENDIF.

  IF iv_clear_case_messages = abap_true.
    CLEAR: gt_message.
  ENDIF.

  IF it_case_message IS NOT INITIAL.
    APPEND LINES OF it_case_message TO gt_message.
  ENDIF.

  IF iv_sub_repid IS NOT INITIAL.
    gv_subreport = iv_sub_repid.
  ELSE.
    gv_subreport = sy-repid.
  ENDIF.

  IF iv_sub_dynnr IS NOT INITIAL.
    gv_subscreen_9000 = iv_sub_dynnr.
    CALL SCREEN '9000' STARTING AT 1 1.
    et_return = gt_return.
  ELSE.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.
ENDFUNCTION.
