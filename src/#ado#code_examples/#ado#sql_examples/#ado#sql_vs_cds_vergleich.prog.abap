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
REPORT /ado/sql_vs_cds_vergleich.

DATA: lv_html      TYPE string,
      lv_starttime TYPE i,
      lv_endtime   TYPE i,
      lv_seconds   TYPE i.

DATA: lv_test_number TYPE i,
      lv_test_count  TYPE i VALUE 5.

DATA: lv_formatted_text TYPE c LENGTH 30,
      lt_itab           TYPE STANDARD TABLE OF /ado/sql_all.

DATA: lt_file_table  TYPE filetable,
      lv_rc          TYPE i,
      lv_user_action TYPE i.

TYPES: BEGIN OF ls_five_columns,
         address    TYPE c,
         city       TYPE c,
         gender     TYPE c,
         ship_date  TYPE c,
         total_cost TYPE c,
       END OF ls_five_columns.

DATA: lv_prg_name      TYPE sy-repid VALUE 'ZDR_TMP_REPORT',
      lv_sql_statement TYPE string,
      lt_sql_stmt_tab  TYPE string_table,
      it_src           TYPE STANDARD TABLE OF char1024,
      lv_msg           TYPE string,
      lv_line          TYPE string,
      lv_word          TYPE string,
      lt_select_five   TYPE TABLE OF ls_five_columns,
      lv_off           TYPE string.


lv_test_number = 1.
WRITE |Test-{ lv_test_number }| TO lv_formatted_text.
cl_demo_output=>write_text( lv_formatted_text ).
CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
  EXPORTING
    percentage = ( lv_test_number * 100 ) DIV lv_test_count
    text       = |Test { lv_test_number } von { lv_test_count }|.

SKIP.

**********************************************************************
WRITE |SELECT *|.
DATA(lv_counter) = 1.
DO 5 TIMES.
* SQL-Statement
  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT * FROM /ado/sql_all INTO TABLE lt_itab UP TO 80000 ROWS.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.
  lv_counter = lv_counter + 1.
ENDDO.

WRITE / |SQL-Statement: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.
CLEAR: lv_seconds, lt_itab.

lv_counter = 1.
DO 5 TIMES.
* CDS-View
  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT * FROM /ado/sql_select_all INTO TABLE @lt_itab UP TO 80000 ROWS.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.
  lv_counter = lv_counter + 1.
ENDDO.

WRITE 50 |CDS-View: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

SKIP.
CLEAR: lt_itab, lv_counter, lv_seconds.
ULINE.

************************************************************************
WRITE |SELECT five columns|.

lv_counter = 1.
DO 5 TIMES.
* SQL-Statement
  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT address, city, gender, ship_date, total_cost FROM /ado/sql_all INTO TABLE @lt_select_five UP TO 80000 ROWS.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.

  CLEAR lt_select_five.
  lv_counter = lv_counter + 1.
ENDDO.
WRITE / |SQL-Statement: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_seconds, lv_counter.
lv_counter = 1.
DO 5 TIMES.
* CDS-View
  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT * FROM /ado/sql_select_five INTO CORRESPONDING FIELDS OF TABLE @lt_select_five UP TO 80000 ROWS.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.

  CLEAR lt_select_five.
  lv_counter = lv_counter + 1.
ENDDO.
WRITE 50 |CDS-View: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.
SKIP.
ULINE.

************************************************************************
