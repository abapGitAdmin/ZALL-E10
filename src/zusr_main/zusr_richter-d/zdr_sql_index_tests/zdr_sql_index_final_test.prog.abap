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
      lv_iter_counter        TYPE i,
      lv_prozent             TYPE i,
      lv_n_prozent           TYPE numc3,
      lv_test_counter        TYPE i VALUE 0,
      lv_number_tests        TYPE i VALUE 10,
      lv_test_env            TYPE string VALUE 'MaxDB / Row-Store'.

DATA: lv_iterations_per_test TYPE i.

lv_iterations_per_test = 1.

************************************************************************
WRITE / |Test: Select * WHERE order_id < '100477540' ({ lv_test_env })|.
SKIP.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
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
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab1 ) } from 1Mio Entries|.
WRITE / |no Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
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
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

ULINE.
************************************************************************

************************************************************************
WRITE / |Test: Select "6 0 columns" WHERE order_id < '100477540' ({ lv_test_env })|.
SKIP.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT city,
         experience,
         college,
         hcollege,
         region,
         country,
         item_type,
         sales_channel,
         order_priority,
         order_date,
         order_id,
         ship_date,
         units_sold,
         total_profit,
         star_number,
         gender, ethnicity,
         birth, stark,
         star1,
         star2,
         star3,
         readk,
         read1,
         read2,
         read3,
         mathk,
         math1,
         math2,
         math3,
         lunchk,
         lunch1,
         lunch2,
         lunch3,
         schoolk,
         school1,
         school2,
         school3,
         degreek,
         degree1,
         degree2,
         degree3,
         ladderk,
         ladder1,
         ladder2,
         ladder3,
         experiencek,
         experience1,
         experience2,
         experience3,
         tethnicityk,
         tethnicity1,
         tethnicity2,
         tethnicity3,
         systemk,
         system1,
         system2,
         system3,
         schoolidk,
         schoolid1,
         schoolid2,
         schoolid3
    FROM /ado/sql_all
    WHERE order_id < '100477540'
    INTO TABLE @DATA(lt_itab3)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab1 ) } from 1Mio Entries|.
WRITE / |no Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id,
         ship_date,
         stark,
         star1,
         star2,
         star3,
         readk,
         read1,
         read2,
         read3,
         mathk,
         math1,
         math2,
         math3,
         lunchk,
         lunch1,
         lunch2,
         lunch3,
         schoolk,
         school1
    FROM /ado/sql_all_idz
    WHERE order_id < '100477540'
    INTO TABLE @DATA(lt_itab4)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

ULINE.
************************************************************************

************************************************************************
WRITE / |Test: Select "2 columns" WHERE order_id < '100477540' ({ lv_test_env })|.
SKIP.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id,
         ship_date
    FROM /ado/sql_all
    WHERE order_id < '100477540'
    INTO TABLE @DATA(lt_itab5)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab3 ) } from 1Mio Entries|.
WRITE / |no Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id,
         ship_date
    FROM /ado/sql_all_idz
    WHERE order_id < '100477540'
    INTO TABLE @DATA(lt_itab6)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

ULINE.
************************************************************************

************************************************************************
WRITE / |Test: Select order_id WHERE order_id < '100477540' ({ lv_test_env })|.
SKIP.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id
    FROM /ado/sql_all
    WHERE order_id < '100477540'
    INTO TABLE @DATA(lt_itab7)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab5 ) } from 1Mio Entries|.
WRITE / |no Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id
    FROM /ado/sql_all_idz
    WHERE order_id < '100477540'
    INTO TABLE @DATA(lt_itab8)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

ULINE.
************************************************************************

************************************************************************
WRITE / |Test: Select * WHERE order_id = '100477540' ({ lv_test_env })|.
SKIP.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT *
    FROM /ado/sql_all
    WHERE order_id = '100477540'
    INTO TABLE @DATA(lt_itab9)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab7 ) } from 1Mio Entries|.
WRITE / |no Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT *
    FROM /ado/sql_all_idz
    WHERE order_id = '100477540'
    INTO TABLE @DATA(lt_itab10)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

ULINE.
************************************************************************

************************************************************************
WRITE / |Test: Select "20 columns" WHERE order_id = '100477540' ({ lv_test_env })|.
SKIP.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id,
         ship_date,
         stark,
         star1,
         star2,
         star3,
         readk,
         read1,
         read2,
         read3,
         mathk,
         math1,
         math2,
         math3,
         lunchk,
         lunch1,
         lunch2,
         lunch3,
         schoolk,
         school1
    FROM /ado/sql_all
    WHERE order_id = '100477540'
    INTO TABLE @DATA(lt_itab11)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab1 ) } from 1Mio Entries|.
WRITE / |no Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id,
         ship_date,
         stark,
         star1,
         star2,
         star3,
         readk,
         read1,
         read2,
         read3,
         mathk,
         math1,
         math2,
         math3,
         lunchk,
         lunch1,
         lunch2,
         lunch3,
         schoolk,
         school1
    FROM /ado/sql_all_idz
    WHERE order_id = '100477540'
    INTO TABLE @DATA(lt_itab12)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

ULINE.
************************************************************************

************************************************************************
WRITE / |Test: Select "2 columns" WHERE order_id = '100477540' ({ lv_test_env })|.
SKIP.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id,
         ship_date
    FROM /ado/sql_all
    WHERE order_id = '100477540'
    INTO TABLE @DATA(lt_itab13)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab9 ) } from 1Mio Entries|.
WRITE / |no Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id,
         ship_date
    FROM /ado/sql_all_idz
    WHERE order_id = '100477540'
    INTO TABLE @DATA(lt_itab14)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

ULINE.
************************************************************************

************************************************************************
WRITE / |Test: Select order_id WHERE order_id = '100477540' ({ lv_test_env })|.
SKIP.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id
    FROM /ado/sql_all
    WHERE order_id = '100477540'
    INTO TABLE @DATA(lt_itab15)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE / |Average time for { lv_iterations_per_test } iteration/s: Select { lines( lt_itab11 ) } from 1Mio Entries|.
WRITE / |no Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

CLEAR: lv_iter_counter, lv_seconds.
lv_iter_counter = 1.
DO lv_iterations_per_test + 1 TIMES.
  lv_n_prozent = ( sy-index + lv_test_counter * lv_number_tests * lv_iterations_per_test ) * 100 / ( lv_number_tests * lv_number_tests * lv_iterations_per_test ).
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id
    FROM /ado/sql_all_idz
    WHERE order_id = '100477540'
    INTO TABLE @DATA(lt_itab16)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt

  IF sy-index > 1.
    lv_seconds = ( ( lv_seconds * ( lv_iter_counter - 1 ) ) + ( lv_endtime - lv_starttime ) ) / lv_iter_counter.
    lv_iter_counter = lv_iter_counter + 1.
  ENDIF.
ENDDO.
lv_test_counter = lv_test_counter + 1.

WRITE 50 |Index: { lv_seconds }µs (ca. { lv_seconds / 1000000 }s)|.

ULINE.
************************************************************************
