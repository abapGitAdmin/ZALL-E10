FUNCTION se16n_layout_export.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_ALV_GRID) TYPE REF TO CL_GUI_ALV_GRID
*"----------------------------------------------------------------------

  DATA: ls_layout       TYPE lvc_s_layo.
  DATA: lt_fieldcatalog TYPE lvc_t_fcat.
  DATA: ls_fieldcatalog TYPE lvc_s_fcat.
  DATA: lt_filter       TYPE lvc_t_filt.
  DATA: ls_filter       TYPE lvc_s_filt.
  DATA: lt_sort         TYPE lvc_t_sort.
  DATA: ls_sort         TYPE lvc_s_sort.

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

*.get current layout
  CALL METHOD i_alv_grid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = lt_fieldcatalog.
  CALL METHOD i_alv_grid->get_frontend_layout
    IMPORTING
      es_layout = ls_layout.
  CALL METHOD i_alv_grid->get_filter_criteria
    IMPORTING
      et_filter = lt_filter.
  CALL METHOD i_alv_grid->get_sort_criteria
    IMPORTING
      et_sort = lt_sort.

  APPEND LINES OF lt_fieldcatalog TO ls_deep-fieldcat.
  APPEND LINES OF lt_filter TO ls_deep-filter.
  APPEND LINES OF lt_sort TO ls_deep-sort.
  MOVE-CORRESPONDING ls_layout TO ls_deep-layout.
  APPEND ls_deep TO lt_deep.

* jetzt in XML umwandeln
  CALL TRANSFORMATION id
         SOURCE model = lt_deep
         RESULT XML ld_xml.

* komprimieren über GZIP
  cl_abap_gzip=>compress_text(
        EXPORTING text_in  = ld_xml
        IMPORTING gzip_out = ld_xml_zip ).

* jetzt in eine Tabelle für den Download umfüllen
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = ld_xml_zip
*     APPEND_TO_TABLE       = ' '
    IMPORTING
      output_length = ld_length
    TABLES
      binary_tab    = lt_data.

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

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename     = ld_filename
      filetype     = 'BIN'
      bin_filesize = ld_length
    CHANGING
      data_tab     = lt_data
    EXCEPTIONS
      OTHERS       = 1.

ENDFUNCTION.
