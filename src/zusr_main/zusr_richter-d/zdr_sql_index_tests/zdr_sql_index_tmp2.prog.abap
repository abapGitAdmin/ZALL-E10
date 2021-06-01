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

* Time
DATA: lv_starttime  TYPE i,
      lv_endtime    TYPE i,
      lv_seconds    TYPE i.

* Progress bar
DATA: lv_iterations TYPE i,
      lv_n_prozent  TYPE numc3,
      lv_prozent    TYPE i.

* Test
DATA: lr_random     TYPE REF TO cl_abap_random_int,
      lv_where      TYPE string,
      ls_istruc     TYPE /ADO/SQL_ALL,
      lt_itab       TYPE TABLE OF /ADO/SQL_ALL.

* Results
DATA: ls_result TYPE zdr_sql_test_db,
      lt_result TYPE TABLE OF zdr_sql_test_db.

* Randomgenerator erzeugen
lr_random = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )
                                        min = 100000000
                                        max = 144720685 ).
*                                        max = 999999999 ).

* Initialisierung
lv_iterations = 10.

************************************************************************
DO lv_iterations + 1 TIMES.
  lv_n_prozent = sy-index * 100 / lv_iterations.
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  lv_where = lr_random->get_next( ).

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id
    FROM /ADO/SQL_ALL
    WHERE order_id < @lv_where
    INTO TABLE @DATA(lt_itab1)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL'.
    ls_result-row_count = '1'.
    ls_result-column_count = lines( lt_itab1 ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT latitude, longitude
    FROM /ADO/SQL_ALL
    WHERE order_id < @lv_where
    INTO TABLE @DATA(lt_itab2)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL'.
    ls_result-row_count = '2'.
    ls_result-column_count = lines( lt_itab2 ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT latitude,
         longitude,
         description_of_emergency,
         zip
    FROM /ADO/SQL_ALL
    WHERE order_id < @lv_where
    INTO TABLE @DATA(lt_itab4)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL'.
    ls_result-row_count = '4'.
    ls_result-column_count = lines( lt_itab4 ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT latitude,
         longitude,
         description_of_emergency,
         zip,
         title_of_emergency,
         data_and_time_of_the_call,
         township,
         general_adress
    FROM /ADO/SQL_ALL
    WHERE order_id < @lv_where
    INTO TABLE @DATA(lt_itab8)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL'.
    ls_result-row_count = '8'.
    ls_result-column_count = lines( lt_itab8 ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT latitude,
         longitude,
         description_of_emergency,
         zip,
         title_of_emergency,
         data_and_time_of_the_call,
         township,
         general_adress,
         actor_name,
         total_gross,
         number_of_movies,
         average_per_movie,
         fst_movie,
         gross,
         yearx,
         length
    FROM /ADO/SQL_ALL
    WHERE order_id < @lv_where
    INTO TABLE @DATA(lt_itab16)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL'.
    ls_result-row_count = '16'.
    ls_result-column_count = lines( lt_itab16 ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT latitude,
         longitude,
         description_of_emergency,
         zip,
         title_of_emergency,
         data_and_time_of_the_call,
         township,
         general_adress,
         actor_name,
         total_gross,
         number_of_movies,
         average_per_movie,
         fst_movie,
         gross,
         yearx,
         length,
         title,
         subject,
         actor,
         actress,
         director,
         popularity,
         awards,
         imagex,
         participation,
         xhours,
         youngkids,
         oldkids,
         age,
         education,
         wage,
         repwage
    FROM /ADO/SQL_ALL
    WHERE order_id < @lv_where
    INTO TABLE @DATA(lt_itab32)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL'.
    ls_result-row_count = '32'.
    ls_result-column_count = lines( lt_itab32 ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT latitude,
         longitude,
         description_of_emergency,
         zip,
         title_of_emergency,
         data_and_time_of_the_call,
         township,
         general_adress,
         actor_name,
         total_gross,
         number_of_movies,
         average_per_movie,
         fst_movie,
         gross,
         yearx,
         length,
         title,
         subject,
         actor,
         actress,
         director,
         popularity,
         awards,
         imagex,
         participation,
         xhours,
         youngkids,
         oldkids,
         age,
         education,
         wage,
         repwage,
         hhours,
         hage,
         heducation,
         hwage,
         fincome,
         tax,
         meducation,
         feducation,
         unemp,
         city,
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
         unit_price,
         unit_cost,
         total_revenue,
         total_cost,
         total_profit,
         star_number,
         gender,
         ethnicity,
         birth,
         stark
    FROM /ADO/SQL_ALL
    WHERE order_id < @lv_where
    INTO TABLE @DATA(lt_itab64)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL'.
    ls_result-row_count = '64'.
    ls_result-column_count = lines( lt_itab64 ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT *
    FROM /ADO/SQL_ALL
    WHERE order_id < @lv_where
    INTO TABLE @DATA(lt_itab113)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL'.
    ls_result-row_count = '113'.
    ls_result-column_count = lines( lt_itab113 ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

ENDDO.

TRY.
    INSERT zdr_sql_test_db FROM TABLE lt_result.
  CATCH cx_sy_open_sql_db.
    MESSAGE 'Fehler beim Schreiben auf die Datenbank! (etvl. Key nicht eindeutig)' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
ENDTRY.

SET PARAMETER ID 'DTB' FIELD 'ZDR_SQL_TEST_DB'.
CALL TRANSACTION 'SE16N'.
************************************************************************
