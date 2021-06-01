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
*&         $USER  $DATE
************************************************************************
*******
REPORT zdr_sql_performancer_v2.

DATA: lv_starttime TYPE i,
      lv_endtime   TYPE i,
      lv_seconds   TYPE i,
      lv_counter   TYPE i.

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

DATA: lt_select_five TYPE TABLE OF ls_five_columns,
      lt_itab        TYPE STANDARD TABLE OF /ado/sql_test.

**********************************************************************
WRITE |SELECT *|.

CLEAR: lt_itab, lv_counter, lv_seconds.
lv_counter = 1.
DO 5 TIMES.
* SQL-Statement
  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT * FROM /ado/sql_test INTO TABLE lt_itab.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.
  lv_counter = lv_counter + 1.
ENDDO.

WRITE / |SQL-Statement: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.


CLEAR: lt_itab, lv_counter, lv_seconds.
lv_counter = 1.
DO 5 TIMES.
* CDS-View
  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT * FROM /ado/sql_select_test INTO TABLE @lt_itab.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.
  lv_counter = lv_counter + 1.
ENDDO.

WRITE 50 |CDS-View: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

SKIP.
ULINE.

************************************************************************
