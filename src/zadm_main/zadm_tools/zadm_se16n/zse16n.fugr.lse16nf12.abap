*----------------------------------------------------------------------*
***INCLUDE LSE16NF12.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_INPUT_LENGTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_INPUT_LENGTH using    value(p_message)
                        changing p_input type se16n_value
                                 value(p_changed).

data: ld_length like sy-tabix.
data: p_dummy   type se16n_value.

  clear p_changed.
  ld_length = strlen( p_input ).
  if ld_length > 45.
     p_dummy = p_input(44).
     p_dummy+44(1) = '*'.
     clear p_input.
     p_input = p_dummy.
     if p_message = true.
        message i450(wusl).
     endif.
     p_changed = true.
  endif.

ENDFORM.                    " CHECK_INPUT_LENGTH
*&---------------------------------------------------------------------*
*& Form ADD_LINES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ADD_LINES using value(P_APPEND).

data: ls_multi_opt    like se16n_selfields.
data: ls_multi_optold like se16n_selfields.
data: ld_different_opt(1).

*.....check if there is no free line anymore -> add them
  loop at gt_multi_select
              where low    = space
                and high   = space
                and option = space.
  endloop.
  if sy-subrc <> 0 or
     p_append = true.
*....check if always the same option has been used
     clear ld_different_opt.
     loop at gt_multi_select into ls_multi_opt.
        if ls_multi_optold-option <> ls_multi_opt-option and
           sy-tabix <> 1.
           ld_different_opt = true.
        endif.
        ls_multi_optold = ls_multi_opt.
     endloop.
*....default is the last entry
     gt_multi_select = ls_multi_opt.
     clear: gt_multi_select-low,
            gt_multi_select-high.
*....if different options have been used, clear it
*    if ld_different_opt = true.
       clear: gt_multi_select-sign,
              gt_multi_select-option.
*    endif.
     do new_lines times.
        append gt_multi_select.
     enddo.
  endif.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_add_column
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_add_column .

  DATA: ld_tab   TYPE ddobjname.
  DATA: lt_dfies LIKE dfies OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF value_tab OCCURS 0,
          value TYPE fieldname,
          text  TYPE scrtext_m,
        END OF value_tab.
  DATA: retfield        LIKE dfies-fieldname VALUE 'VALUE'.
  DATA: return_tab      LIKE ddshretval OCCURS 0 WITH HEADER LINE.
  DATA: ld_multi_choice TYPE ddbool_d.

  CHECK: gd-tab <> space.

  ld_tab = gd-tab.
  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname   = ld_tab
    TABLES
      dfies_tab = lt_dfies
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  CHECK sy-subrc = 0.

  REFRESH value_tab.
  LOOP AT lt_dfies.
    CLEAR value_tab.
    value_tab-value = lt_dfies-fieldname.
    value_tab-text  = lt_dfies-scrtext_m.
    APPEND value_tab.
  ENDLOOP.

* sort value_tab by text.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = retfield
      value_org       = 'S'
      multiple_choice = ld_multi_choice
    TABLES
      value_tab       = value_tab
      return_tab      = return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc = 0.
    READ TABLE return_tab INDEX 1.
    gd_add_column = return_tab-fieldval.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_column
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_column .

  DATA: ls_layout       TYPE lvc_s_layo.
  DATA: lt_fieldcatalog TYPE lvc_t_fcat.
  DATA: ls_fieldcatalog TYPE lvc_s_fcat.
  DATA: lt_filter       TYPE lvc_t_filt.
  DATA: lt_sort         TYPE lvc_t_sort.

  CHECK: gd_add_column <> space.

  CALL METHOD alv_grid->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = lt_fieldcatalog.
  CALL METHOD alv_grid->get_frontend_layout
    IMPORTING
      es_layout = ls_layout.
  CALL METHOD alv_grid->get_filter_criteria
    IMPORTING
      et_filter = lt_filter.
  CALL METHOD alv_grid->get_sort_criteria
    IMPORTING
      et_sort = lt_sort.

  READ TABLE lt_fieldcatalog INTO ls_fieldcatalog
  WITH KEY fieldname = gd_add_column.
  IF sy-subrc = 0.

    ls_fieldcatalog-col_pos = 1.
    MODIFY lt_fieldcatalog FROM ls_fieldcatalog INDEX sy-tabix.

    CALL METHOD alv_grid->set_frontend_fieldcatalog
      EXPORTING
        it_fieldcatalog = lt_fieldcatalog.
    CALL METHOD alv_grid->set_frontend_layout
      EXPORTING
        is_layout = ls_layout.
    CALL METHOD alv_grid->set_filter_criteria
      EXPORTING
        it_filter = lt_filter.
    CALL METHOD alv_grid->set_sort_criteria
      EXPORTING
        it_sort = lt_sort.

    CALL METHOD alv_grid->refresh_table_display.
  ELSE.
    MESSAGE s567(gg) WITH gd_add_column gd-tab.
  ENDIF.
  CLEAR gd_add_column.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form sort_by_used_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sort_by_used_fields .

  DATA: ls_selfields TYPE se16n_selfields.

  LOOP AT gt_selfields INTO ls_selfields.
*...only the first time
    IF ls_selfields-sortused IS INITIAL.
      ls_selfields-sortused = sy-tabix.
    ENDIF.
    IF ls_selfields-group_by  <> space OR
       ls_selfields-sum_up    <> space OR
       ls_selfields-order_by  <> space OR
       ls_selfields-aggregate <> space OR
       NOT ls_selfields-low    IS INITIAL OR
       NOT ls_selfields-high   IS INITIAL OR
       NOT ls_selfields-option IS INITIAL.
      ls_selfields-entry = 1.
    ENDIF.
    IF ls_selfields-datatype = 'CLNT'.
      ls_selfields-entry = 2.
    ENDIF.
    MODIFY gt_selfields FROM ls_selfields INDEX sy-tabix.
  ENDLOOP.
  SORT gt_selfields STABLE BY entry DESCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form unsort_by_used_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM unsort_by_used_fields .

  DATA: ls_selfields TYPE se16n_selfields.

*.check if the table is really sorted
  READ TABLE gt_selfields INTO ls_selfields WITH KEY sortused = 1.
  IF sy-subrc = 0.
    SORT gt_selfields BY sortused ASCENDING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form sort_by_add_column
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sort_by_add_column .

  DATA: ls_selfields TYPE se16n_selfields.

  CHECK: gd_add_column <> space.

  LOOP AT gt_selfields INTO ls_selfields.
*...only the first time
    IF ls_selfields-sortused IS INITIAL.
      ls_selfields-sortused = sy-tabix.
    ENDIF.
    IF ls_selfields-fieldname = gd_add_column.
      ls_selfields-entry = 1.
    ENDIF.
    IF ls_selfields-datatype = 'CLNT'.
      ls_selfields-entry = 2.
    ENDIF.
    MODIFY gt_selfields FROM ls_selfields INDEX sy-tabix.
  ENDLOOP.
  SORT gt_selfields STABLE BY entry DESCENDING.
  CLEAR gd_add_column.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form param_export
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM param_export .

  DATA:
    ld_high(1),
    ld_filename   TYPE string,
    ld_path       TYPE string,
    lt_filetable  TYPE filetable,
    ld_file       TYPE LINE OF filetable,
    ld_rc         TYPE i,
    ld_useraction TYPE i,
    ld_filelength TYPE i.
  DATA: tab_field(100) TYPE c,
        index          TYPE i,
        l_index        TYPE i.
  TYPES: BEGIN OF type_data,
           line(500),
         END OF type_data.
  DATA: lt_data TYPE TABLE OF type_data.
  DATA: ls_data TYPE type_data.
  DATA: ld_tabix LIKE sy-tabix.
  DATA: ld_table TYPE tabname.
  DATA: ls_selfields TYPE se16n_selfields.

  FIELD-SYMBOLS:
    <filename>.

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

*.fill table
  ls_data-line = gd-tab.
  APPEND ls_data TO lt_data.
  LOOP AT gt_selfields INTO ls_selfields
                       WHERE entry = 1.
    ls_data-line = ls_selfields-fieldname.
    APPEND ls_data TO lt_data.
  ENDLOOP.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename = ld_filename
    CHANGING
      data_tab = lt_data
    EXCEPTIONS
      OTHERS   = 1.

*  CALL FUNCTION 'GUI_DOWNLOAD'
*  EXPORTING
*    filename                        = ld_filename
*  TABLES
*    data_tab                        = lt_data
*  EXCEPTIONS
*    OTHERS                          = 1.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form param_import
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM param_import .

  DATA:
    ld_high(1),
    ld_filename   TYPE string,
    ld_path       TYPE string,
    lt_filetable  TYPE filetable,
    ld_file       TYPE LINE OF filetable,
    ld_rc         TYPE i,
    ld_useraction TYPE i,
    ld_filelength TYPE i.
  DATA: tab_field(100) TYPE c,
        index          TYPE i,
        l_index        TYPE i.
  TYPES: BEGIN OF type_data,
           line(500),
         END OF type_data.
  DATA: lt_data TYPE TABLE OF type_data.
  DATA: ls_data TYPE type_data.
  DATA: ld_tabix LIKE sy-tabix.
  DATA: ld_table TYPE tabname.

  FIELD-SYMBOLS:
    <filename>.

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

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename   = ld_filename
    IMPORTING
      filelength = ld_filelength
    CHANGING
      data_tab   = lt_data
*     isscanperformed         = SPACE
    EXCEPTIONS
      OTHERS     = 1.

*  CALL FUNCTION 'GUI_UPLOAD'
*  EXPORTING
*    FILENAME                      = LD_FILENAME
**     FILETYPE                      = 'ASC'
**     FILETYPE                      = 'BIN'
*    HAS_FIELD_SEPARATOR           = 'X'
**     HEADER_LENGTH                 = 0
*  IMPORTING
*    FILELENGTH                    = LD_FILELENGTH
**     HEADER                        =
*  TABLES
*    DATA_TAB                      = lt_data
*  EXCEPTIONS
*    OTHERS                        = 1.

  IF sy-subrc <> 0.
    MESSAGE s398(00) WITH
    'GUI_UPLOAD failed'                                     "#EC *
    'SUBRC =' sy-subrc ''.
    EXIT.
  ELSE.
    MESSAGE s398(00) WITH 'Upload ok:'                      "#EC *
    ld_filename 'Bytes:' ld_filelength.                     "#EC *
  ENDIF.

  CHECK sy-subrc = 0.

*.lt_data_tab has to look like
* first line is the table name
* followed by the order of fields that should be moved forward
  READ TABLE lt_data INTO ls_data INDEX 1.
  IF sy-subrc <> 0.
    MESSAGE s430(wusl).
    EXIT.
  ELSE.
    WRITE ls_data-line TO ld_table.
    CONDENSE ld_table.
    IF ld_table <> gd-tab AND
       ld_table <> '*'.
      MESSAGE s431(wusl) WITH ld_table gd-tab.
      EXIT.
    ENDIF.
  ENDIF.

*.now get the fields
  LOOP AT lt_data INTO ls_data FROM 2.
    CHECK: ls_data-line <> space.
    WRITE: ls_data-line TO gd_add_column.
    PERFORM sort_by_add_column.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form erase_used_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM erase_used_fields .

  DATA: ls_selfields TYPE se16n_selfields.

*.delete entry-field and undo sorting
  LOOP AT gt_selfields INTO ls_selfields.
    CLEAR ls_selfields-entry.
    MODIFY gt_selfields FROM ls_selfields INDEX sy-tabix.
  ENDLOOP.
  PERFORM unsort_by_used_fields .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form layout_export
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM layout_export .

  CALL FUNCTION 'SE16N_LAYOUT_EXPORT'
    EXPORTING
      i_alv_grid = alv_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form layout_import
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM layout_import .

  DATA: ld_subrc TYPE sy-subrc.

  CALL FUNCTION 'SE16N_LAYOUT_IMPORT'
    EXPORTING
      i_alv_grid              = alv_grid
      i_tab                   = gd-tab
    IMPORTING
      e_subrc                 = ld_subrc
    EXCEPTIONS
      fcat_does_not_fit_table = 1
      OTHERS                  = 2.

  CASE sy-subrc.
    WHEN 1.
      MESSAGE i432(wusl) WITH gd-tab.
  ENDCASE.

ENDFORM.
