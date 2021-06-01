FUNCTION se16n_layout_import.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_ALV_GRID) TYPE REF TO CL_GUI_ALV_GRID
*"     VALUE(I_TAB) TYPE  TABNAME OPTIONAL
*"     VALUE(I_ACTION) TYPE  CHAR1 DEFAULT 'E'
*"  EXPORTING
*"     REFERENCE(E_SUBRC) TYPE  SY-SUBRC
*"     REFERENCE(ET_FIELDCATALOG) TYPE  LVC_T_FCAT
*"     REFERENCE(ET_FILTER) TYPE  LVC_T_FILT
*"     REFERENCE(ET_SORT) TYPE  LVC_T_SORT
*"     REFERENCE(ES_LAYOUT) TYPE  LVC_S_LAYO
*"  EXCEPTIONS
*"      FCAT_DOES_NOT_FIT_TABLE
*"----------------------------------------------------------------------

  DATA: ls_fieldcatalog TYPE lvc_s_fcat.
  DATA: lt_dfies        TYPE TABLE OF dfies.
  DATA: ls_dfies        TYPE dfies.

  DATA: ld_high(1),
        ld_filename   TYPE string,
        ld_path       TYPE string,
        lt_filetable  TYPE filetable,
        ld_file       TYPE LINE OF filetable,
        ld_rc         TYPE i,
        ld_useraction TYPE i,
        ld_filelength TYPE i.

  DATA: ld_xml     TYPE string,
        ld_xml_zip TYPE xstring,
        ld_length  TYPE i,
        lt_data    TYPE TABLE OF x255.

  TYPES: BEGIN OF ty_deep,
           fieldcat TYPE lvc_t_fcat,
           filter   TYPE lvc_t_filt,
           sort     TYPE lvc_t_sort,
           layout   TYPE lvc_s_layo,
         END OF ty_deep.
  DATA: lt_deep TYPE TABLE OF ty_deep.
  DATA: ls_deep TYPE ty_deep.

*.ask user forr file
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
*     WINDOW_TITLE            =
      default_extension       = 'TXT'
      default_filename        = ld_filename
*     FILE_FILTER             = '*.TXT'
      initial_directory       = ld_path
*     MULTISELECTION          =
    CHANGING
      file_table              = lt_filetable
      rc                      = ld_rc
      user_action             = ld_useraction
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE s398(00) WITH
    'FILE_OPEN_DIALOG failed'                               "#EC NOTEXT
    'SUBRC =' sy-subrc ''.
    EXIT.
  ENDIF.
  CHECK ld_useraction = 0.
  CHECK ld_rc = 1.
  READ TABLE lt_filetable INTO ld_file INDEX 1.
  ld_filename = ld_file.

*.get file
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = ld_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = ld_length
*     header                  =
    CHANGING
      data_tab                = lt_data
*     isscanperformed         = SPACE
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
    e_subrc = sy-subrc.
    EXIT.
  ENDIF.

*.convert file back into zip
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = ld_length
*     FIRST_LINE   = 0
*     LAST_LINE    = 0
    IMPORTING
      buffer       = ld_xml_zip
    TABLES
      binary_tab   = lt_data
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
    e_subrc = sy-subrc.
    EXIT.
  ENDIF.

*.convert zip into string
  cl_abap_gzip=>decompress_text(
        EXPORTING gzip_in  = ld_xml_zip
        IMPORTING text_out = ld_xml ).

  REFRESH lt_deep.

*.convert string into original structure
  CALL TRANSFORMATION id
         SOURCE XML ld_xml
         RESULT model = lt_deep.

*.send new layout to screen
  LOOP AT lt_deep INTO ls_deep.
    APPEND LINES OF ls_deep-fieldcat TO et_fieldcatalog.
    APPEND LINES OF ls_deep-filter   TO et_filter.
    APPEND LINES OF ls_deep-sort     TO et_sort.
    MOVE-CORRESPONDING ls_deep-layout TO es_layout.
  ENDLOOP.

*.check that layout belongs to this table
  IF i_tab <> space.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = i_tab
      TABLES
        dfies_tab = lt_dfies
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.

    IF sy-subrc <> 0.
      e_subrc = sy-subrc.
      EXIT.
    ELSE.
*...fieldcatalog contains additional fields from e.g. SE16N
*...therefore check that DFIES is contained in fieldcat
      LOOP AT lt_dfies INTO ls_dfies.
        READ TABLE et_fieldcatalog TRANSPORTING NO FIELDS
             WITH KEY fieldname = ls_dfies-fieldname.
        IF sy-subrc <> 0.
          RAISE fcat_does_not_fit_table.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CASE i_action.
    WHEN 'E'.
*.bring fieldcatalog information to screen
      CALL METHOD i_alv_grid->set_frontend_fieldcatalog
        EXPORTING
          it_fieldcatalog = et_fieldcatalog.
      CALL METHOD i_alv_grid->set_frontend_layout
        EXPORTING
          is_layout = es_layout.
      CALL METHOD i_alv_grid->set_filter_criteria
        EXPORTING
          it_filter = et_filter.
      CALL METHOD i_alv_grid->set_sort_criteria
        EXPORTING
          it_sort = et_sort.

      CALL METHOD i_alv_grid->refresh_table_display.
    WHEN 'R'.
  ENDCASE.

ENDFUNCTION.
