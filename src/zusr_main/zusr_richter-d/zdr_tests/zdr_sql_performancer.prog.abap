************************************************************************
****
*            _
*   __ _  __| | ___  ___ ___  ___
*  / _` |/ _` |/ _ \/ __/ __|/ _ \
* | (_| | (_| |  __/\__ \__ \ (_) |
*  \__,_|\__,_|\___||___/___/\___/
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT zdr_sql_performancer.

DATA: lt_file_table  TYPE filetable,
      lv_rc          TYPE i,
      lv_user_action TYPE i.

DATA: lv_html      TYPE string,
      lv_starttime TYPE i,
      lv_endtime   TYPE i,
      lv_seconds   TYPE i.

DATA: lv_prg_name      TYPE sy-repid VALUE 'TMP_REPORT',
      lv_sql_statement TYPE string,
      lt_sql_stmt_tab  TYPE string_table,
      it_src           TYPE STANDARD TABLE OF char1024,
      lv_msg           TYPE string,
      lv_line          TYPE string,
      lv_word          TYPE string,
      lv_off           TYPE string.

*eine Datei auswählen
cl_gui_frontend_services=>file_open_dialog( EXPORTING  file_filter             = |txt (*.txt)\|*.txt\|{ cl_gui_frontend_services=>filetype_all }|
                                                       multiselection          = abap_true
                                            CHANGING   file_table              = lt_file_table
                                                       rc                      = lv_rc
                                                       user_action             = lv_user_action
                                            EXCEPTIONS file_open_dialog_failed = 1
                                                       cntl_error              = 2
                                                       error_no_gui            = 3
                                                       not_supported_by_gui    = 4
                                                       OTHERS                  = 5 ).
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

*fehlerhafte Benutzereingabe
IF lv_user_action <> cl_gui_frontend_services=>action_ok OR
   lines( lt_file_table ) <> 1.
  MESSAGE 'Fehler beim Auswählen der Datei. Bitte wähle genau eine Datei aus!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

*Datei in interne String-Tabelle hochladen
cl_gui_frontend_services=>gui_upload( EXPORTING
                                        filename = CONV #( lt_file_table[ 1 ]-filename )
                                        filetype = 'ASC'
                                      CHANGING
                                        data_tab = lt_sql_stmt_tab
                                      EXCEPTIONS
                                        file_open_error         = 1
                                        file_read_error         = 2
                                        OTHERS                  = 3 ).
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

DO lines( lt_sql_stmt_tab ) TIMES.
  CLEAR it_src.
  APPEND |REPORT { lv_prg_name }.| TO it_src.
  lv_sql_statement = lt_sql_stmt_tab[ sy-index ].
  APPEND lv_sql_statement TO it_src.
  INSERT REPORT lv_prg_name FROM it_src.
  GENERATE REPORT lv_prg_name MESSAGE lv_msg LINE lv_line WORD lv_word OFFSET lv_off.
  IF sy-subrc = 0.
    GET RUN TIME FIELD lv_starttime. " Startzeitpunkt

    SUBMIT (lv_prg_name) AND RETURN.

    GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
    lv_seconds = ( lv_endtime - lv_starttime ).

    IF sy-subrc = 0.
      cl_demo_output=>write_data( name = 'SQL-Statement'
                                  value = lv_sql_statement ).
      cl_demo_output=>write_data( name = 'Runtime'
                                  value = |{ lv_seconds }µs (ca. { lv_seconds / 1000000 }s)| ).
      cl_demo_output=>line( ).
    ENDIF.
  ELSE.
    WRITE: / 'Error during generation in line', lv_line,
           / lv_msg,
           / 'Word:', lv_word, 'at offset', lv_off.
  ENDIF.
ENDDO.

lv_html = cl_demo_output=>get( ).
cl_abap_browser=>show_html( EXPORTING
                              title        = 'Daten aus CSV'
                              html_string  = lv_html
                              container    = cl_gui_container=>default_screen ).

WRITE 0.
