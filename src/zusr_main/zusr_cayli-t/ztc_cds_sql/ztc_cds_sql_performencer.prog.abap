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
REPORT ztc_cds_sql_performencer.


DATA lt_all TYPE TABLE OF ztc_db_large WITH DEFAULT KEY.
DATA ls_all LIKE LINE OF lt_all.

SELECT * FROM /ado/sql_plltion INTO TABLE @DATA(lt_pollution).
SELECT * FROM /ado/sql_salerec INTO TABLE @DATA(lt_salerec).
SELECT * FROM /ado/sql_911 INTO TABLE @DATA(lt_911).
SELECT * FROM /ado/sql_medical INTO TABLE @DATA(lt_medical).
SELECT * FROM /ado/sql_movies INTO TABLE @DATA(lt_movies).

DATA: lv_counter_pollution TYPE i,
      lv_counter_salerec TYPE i,
      lv_counter_911 type i,
      lv_counter_medical TYPE i,
      lv_counter_movies TYPE i.





DO 1000000 TIMES.


  lv_counter_pollution = sy-index mod lines( lt_pollution ).
  lv_counter_salerec = sy-index mod lines( lt_salerec ).
  lv_counter_911 = sy-index mod lines( lt_911 ).
  lv_counter_medical = sy-index mod lines( lt_medical ).
  lv_counter_movies = sy-index mod lines( lt_movies ).


  IF lv_counter_pollution <> 0.
     MOVE-CORRESPONDING lt_pollution[ lv_counter_pollution  ] to ls_all.
  ENDIF.


  IF lv_counter_salerec <> 0.
     MOVE-CORRESPONDING lt_salerec[ lv_counter_salerec  ] to ls_all.
  ENDIF.


  IF lv_counter_911 <> 0.
     MOVE-CORRESPONDING lt_911[ lv_counter_911 ] to ls_all.
  ENDIF.


  IF lv_counter_medical <> 0.
     MOVE-CORRESPONDING lt_medical[ lv_counter_medical   ] to ls_all..
  ENDIF.


  IF lv_counter_movies <> 0.
     MOVE-CORRESPONDING lt_movies[ lv_counter_movies  ] to ls_all.
  ENDIF.



*  MOVE-CORRESPONDING lt_pollution[ lv_counter_pollution  ] to ls_all.
*  MOVE-CORRESPONDING lt_salerec[ lv_counter_salerec  ] to ls_all.
*  MOVE-CORRESPONDING lt_911[ lv_counter_911 ] to ls_all.
*  MOVE-CORRESPONDING lt_medical[ lv_counter_medical   ] to ls_all.
*  MOVE-CORRESPONDING lt_movies[ lv_counter_movies  ] to ls_all.



  APPEND ls_all to lt_all.

ENDDO.
Write 'Debug'.
Insert ztc_db_large FROM TABLE lt_all.

Write 'Debug'.
