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
      lr_random2    TYPE REF TO cl_abap_random_int,
      lv_cond       TYPE string,
      lv_n_cond     TYPE i.

* Results
DATA: ls_result TYPE zdr_sql_test_db,
      lt_result TYPE TABLE OF zdr_sql_test_db.

* Randomgenerator erzeugen
lr_random = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )
                                        min = 100000000
                                        max = 144720685 ).
*                                        min = 1122
*                                        max = 10298 ).
*                                        max = 999999999 ).

* Initialisierung
lv_iterations = 50.

************************************************************************
DO lv_iterations + 1 TIMES.
  lv_n_prozent = sy-index * 100 / lv_iterations.
  lv_prozent = lv_n_prozent.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = lv_prozent
      text       = 'Bitte warten ...'.

  lv_cond = lr_random->get_next( ).

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  SELECT order_id
    FROM /ADO/SQL_ALL_IDZ
    WHERE order_id < @lv_cond
    INTO TABLE @DATA(lt_itab)
    BYPASSING BUFFER.
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  IF sy-index > 1.
    ls_result-tab_name = '/ADO/SQL_ALL_IDZ'.
    ls_result-row_count = '1'.
    ls_result-column_count = lines( lt_itab ).
    ls_result-time = lv_endtime - lv_starttime.
    APPEND ls_result TO lt_result.
  ENDIF.

ENDDO.

SORT lt_result BY tab_name row_count column_count.

*cl_demo_output=>write_data( value = lt_result
*                            name = '/ADO/SQL_ALL_IDZ' ).
*cl_demo_output=>display( ).

TRY.
    DELETE FROM zdr_sql_test_db.
  CATCH cx_sy_open_sql_db.
    MESSAGE 'Fehler beim Löschen des Inhalts der Datenbank!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
ENDTRY.

TRY.
    INSERT zdr_sql_test_db FROM TABLE lt_result.
  CATCH cx_sy_open_sql_db.
*    MESSAGE 'Fehler beim Schreiben auf die Datenbank! (etvl. Key nicht eindeutig)' TYPE 'S' DISPLAY LIKE 'E'.
*    RETURN.
ENDTRY.

SET PARAMETER ID 'DTB' FIELD 'ZDR_SQL_TEST_DB'.
CALL TRANSACTION 'SE16N'.
