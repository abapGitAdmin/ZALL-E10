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

REPORT zdr_performancer.

DATA: lv_test_number TYPE i,
      lv_test_count  TYPE i VALUE 5.

DATA: lt_file_table  TYPE filetable,
      lv_rc          TYPE i,
      lv_user_action TYPE i.

DATA: lv_prg_name      TYPE sy-repid VALUE 'ZDR_TMP_REPORT',
      lv_sql_statement TYPE string,
      lv_cds_statement TYPE string,
      lt_sql_stmt_tab  TYPE string_table,
      it_src           TYPE STANDARD TABLE OF char1024,
      lv_msg           TYPE string,
      lv_line          TYPE string,
      lv_word          TYPE string,
      lv_off           TYPE string.


*lv_test_number = 1.
*WRITE |Test-{ lv_test_number }| TO lv_formatted_text.
*cl_demo_output=>write_text( lv_formatted_text ).
*CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*  EXPORTING
*    percentage = ( lv_test_number * 100 ) DIV lv_test_count
*    text       = |Test { lv_test_number } von { lv_test_count }|.
*
*SKIP.
*WRITE |Selektiere ... TODO|.
*
** SQL-Statement
*GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
*SELECT * FROM /ado/sql_all INTO TABLE lt_itab UP TO 80000 ROWS.
*GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
*lv_seconds = ( lv_endtime - lv_starttime ).
*
*WRITE / |SQL-Statement: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.
*
** CDS-View
*GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
*GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
*lv_seconds = ( lv_endtime - lv_starttime ).
*
*WRITE 50 |CDS-View: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.
*SKIP.
*ULINE.
*
*************************************************************************


* eine Datei auswählen
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

* fehlerhafte Benutzereingabe
IF lv_user_action <> cl_gui_frontend_services=>action_ok OR
   lines( lt_file_table ) <> 1.
  MESSAGE 'Fehler beim Auswählen der Datei. Bitte wähle genau eine Datei aus!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

* Datei in interne String-Tabelle hochladen
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

DATA(lv_sql_stmt_count) = lines( lt_sql_stmt_tab ).

CLEAR it_src.
APPEND |REPORT { lv_prg_name }.| TO it_src.
APPEND |DATA: lv_starttime TYPE i,| TO it_src.
APPEND |      lv_endtime   TYPE i,| TO it_src.
APPEND |      lv_seconds   TYPE i.| TO it_src.
APPEND |DATA: lt_itab      TYPE STANDARD TABLE OF /ado/sql_all.| TO it_src.

DO lv_sql_stmt_count TIMES.
  SPLIT lt_sql_stmt_tab[ sy-index ] AT 'vs' INTO lv_sql_statement lv_cds_statement.
  lv_test_count = lines( lt_sql_stmt_tab ).
  lv_test_number = sy-index.
  APPEND |CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'| TO it_src.
  APPEND |  EXPORTING| TO it_src.
  APPEND |    percentage = ( { lv_test_number } * 100 ) DIV { lv_test_count }| TO it_src.
  APPEND |    text       = 'Test { lv_test_number } von { lv_test_count }'.| TO it_src.
  APPEND |WRITE '{ lt_sql_stmt_tab[ sy-index ] }'.| TO it_src.
  APPEND |SKIP.| TO it_src.

* SQL-Statement
  APPEND |GET RUN TIME FIELD lv_starttime.| TO it_src.
  APPEND |{ lv_sql_statement }| TO it_src.
  APPEND |GET RUN TIME FIELD lv_endtime.| TO it_src.
  APPEND |lv_seconds = ( lv_endtime - lv_starttime ).| TO it_src.

  APPEND |WRITE: / 'SQL-Statement: ', lv_seconds, 'µs'.| TO it_src.

* CDS-View
  APPEND |GET RUN TIME FIELD lv_starttime.| TO it_src.
  APPEND |{ lv_cds_statement }| TO it_src.
  APPEND |GET RUN TIME FIELD lv_endtime.| TO it_src.
  APPEND |lv_seconds = ( lv_endtime - lv_starttime ).| TO it_src.

  APPEND |WRITE: 50 'CDS-View: ', lv_seconds, 'µs'.| TO it_src.
  APPEND |SKIP.| TO it_src.
  APPEND |ULINE.| TO it_src.
ENDDO.

INSERT REPORT lv_prg_name FROM it_src.
GENERATE REPORT lv_prg_name MESSAGE lv_msg LINE lv_line WORD lv_word OFFSET lv_off.
SUBMIT (lv_prg_name) USING SELECTION-SCREEN '1000'.
