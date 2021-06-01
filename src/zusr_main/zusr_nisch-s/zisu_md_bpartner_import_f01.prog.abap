*&---------------------------------------------------------------------*
*&  Include           ZISU_MD_BPARTNER_IMPORT_F01
*&---------------------------------------------------------------------*
FORM initialization.

  sscrfields-functxt_01 = TEXT-001.

ENDFORM.

FORM run_application.

  NEW lcl_application( )->validate_file_path( ).

ENDFORM.

FORM download_template.

  lcl_application=>get_excel_template( ).

ENDFORM.

FORM file_value_request.

  DATA:
    lv_rc     TYPE i,
    lt_files  TYPE filetable,
    lv_action TYPE i.

  CLEAR: lt_files.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      file_filter             = |{ cl_gui_frontend_services=>filetype_excel }{ cl_gui_frontend_services=>filetype_all }|
    CHANGING
      file_table              = lt_files
      rc                      = lv_rc
      user_action             = lv_action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF lv_action = cl_gui_frontend_services=>action_ok.
    IF lines( lt_files ) > 0.
      p_file = lt_files[ 1 ]-filename.
    ENDIF.
  ENDIF.

ENDFORM.
