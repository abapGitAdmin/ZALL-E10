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
REPORT zdr_sql_index_opensql_vs_cds.

DATA: lv_starttime           TYPE i,
      lv_endtime             TYPE i,
      lv_seconds             TYPE i,
      lv_number_tests        TYPE i,
      lv_counter             TYPE i,
      lv_iterations_per_test TYPE i,
      lv_n_prozent           TYPE numc3,
      lv_prozent             TYPE i.

DATA: lt_file_table  TYPE filetable,
      lv_rc          TYPE i,
      lv_user_action TYPE i.

DATA: lt_itab   TYPE STANDARD TABLE OF /ado/sql_select_all,
      ls_istruc TYPE /ado/sql_select_all.

lv_number_tests = 1.
lv_iterations_per_test = 2.

************************************************************************
DO lv_number_tests TIMES.
  WRITE / |Test: WHERE order_id (MaxDB / Row-Store)|.
  SKIP.

  CLEAR: lt_itab, lv_counter, lv_seconds.
  lv_counter = 1.
  DO lv_iterations_per_test + 1 TIMES.
    lv_n_prozent = ( sy-index + 0 * lv_number_tests * lv_iterations_per_test ) * 100 / ( 4 * lv_number_tests * lv_iterations_per_test ).
    lv_prozent = lv_n_prozent.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_prozent
        text       = 'Bitte warten ...'.

    GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
    SELECT *
      FROM /ado/sql_all
      WHERE order_id < '100477540'
      INTO TABLE @DATA(lt_itab1)
      BYPASSING BUFFER.
    GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

    IF sy-index > 1.
      lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.
      lv_counter = lv_counter + 1.
    ENDIF.
  ENDDO.

  WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab1 ) } from 1Mio Entries|.
  WRITE / |no Indext: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

  CLEAR: lt_itab, lv_counter, lv_seconds.
  lv_counter = 1.
  DO lv_iterations_per_test + 1 TIMES.
    lv_n_prozent = ( sy-index + 1 * lv_number_tests * lv_iterations_per_test ) * 100 / ( 4 * lv_number_tests * lv_iterations_per_test ).
    lv_prozent = lv_n_prozent.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_prozent
        text       = 'Bitte warten ...'.

    GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
    SELECT *
      FROM /ado/sql_all_idz
      WHERE order_id < '100477540'
      INTO TABLE @DATA(lt_itab2)
      BYPASSING BUFFER.
    GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

    IF sy-index > 1.
      lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.
      lv_counter = lv_counter + 1.
    ENDIF.
  ENDDO.

  WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

  ULINE.
ENDDO.
************************************************************************

************************************************************************
DO lv_number_tests TIMES.
  WRITE / |Test: WHERE star_number (MaxDB / Row-Store)|.
  SKIP.

  CLEAR: lt_itab, lv_counter, lv_seconds.
  lv_counter = 1.
  DO lv_iterations_per_test + 1 TIMES.
    lv_n_prozent = ( sy-index + 2 * lv_number_tests * lv_iterations_per_test ) * 100 / ( 4 * lv_number_tests * lv_iterations_per_test ).
    lv_prozent = lv_n_prozent.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_prozent
        text       = 'Bitte warten ...'.

    GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
    SELECT *
      FROM /ado/sql_all
      WHERE star_number < '1200'
      INTO TABLE @DATA(lt_itab3)
      BYPASSING BUFFER.
    GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

    IF sy-index > 1.
      lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.
      lv_counter = lv_counter + 1.
    ENDIF.
  ENDDO.

  WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab3 ) } from 1Mio Entries|.
  WRITE / |no Indext: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

  CLEAR: lt_itab, lv_counter, lv_seconds.
  lv_counter = 1.
  DO lv_iterations_per_test + 1 TIMES.
    lv_n_prozent = ( sy-index + 3 * lv_number_tests * lv_iterations_per_test ) * 100 / ( 4 * lv_number_tests * lv_iterations_per_test ).
    lv_prozent = lv_n_prozent.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_prozent
        text       = 'Bitte warten ...'.

    GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
    SELECT *
      FROM /ado/sql_all_idz
      WHERE star_number < '1200'
      INTO TABLE @DATA(lt_itab4)
      BYPASSING BUFFER.
    GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

    IF sy-index > 1.
      lv_seconds = ( ( lv_seconds * ( lv_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_counter.
      lv_counter = lv_counter + 1.
    ENDIF.
  ENDDO.

  WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

  ULINE.
ENDDO.
************************************************************************
