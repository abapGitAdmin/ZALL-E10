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
REPORT zdr_sql_test.

DATA: lt_itab1   TYPE TABLE OF /ado/sql_all,
      lt_itab2   TYPE TABLE OF /ado/sql_all_idz,
      ls_istruc1 TYPE /ado/sql_all,
      ls_istruc2 TYPE /ado/sql_all_idz.

FIELD-SYMBOLS: <comp1> TYPE any,
               <comp2> TYPE any.

SELECT *
  FROM /ado/sql_all
  UP TO 500000 ROWS
  INTO TABLE lt_itab1
  ORDER BY PRIMARY KEY.
SELECT *
  FROM /ado/sql_all_idz
  UP TO 500000 ROWS
  INTO TABLE lt_itab2
  ORDER BY PRIMARY KEY.

DO 500000 TIMES.
  MOVE-CORRESPONDING lt_itab1[ sy-index ] TO ls_istruc1.
  MOVE-CORRESPONDING lt_itab2[ sy-index ] TO ls_istruc2.
  DO.
    ASSIGN COMPONENT sy-index OF STRUCTURE ls_istruc1 TO <comp1>.
    ASSIGN COMPONENT sy-index OF STRUCTURE ls_istruc2 TO <comp2>.

    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    IF <comp1> <> <comp2>.
      WRITE: / |Falsch: { <comp1> } vs { <comp2> }, { sy-index }|.
    ELSE.
*      WRITE: /50 |Korrekt: { <comp1> } vs { <comp2> }, { sy-index }|.
    ENDIF.
  ENDDO.
ENDDO.

WRITE 'Fertig'.

*DATA: t0 TYPE i,
*      t1 TYPE i,
*      r  TYPE i.
*
*
*GET RUN TIME FIELD t0.
*
*SELECT *
*  FROM /ado/sql_all
*  INTO TABLE @DATA(lt_at_data)
*  UP TO 190 ROWS
*  BYPASSING BUFFER.
*
*GET RUN TIME FIELD t1.
*
*r = ( t1 - t0 ) / 1.
*WRITE / |Dauer: { r }µs (ca. { r / 1000000 }s)|.
*ULINE.
*
*GET RUN TIME FIELD t0.
*
*SELECT id_911,
*    id_actor,
*    id_movie,
*    id_psid,
*    id_salerec,
*    id_star,
*    latitude,
*    longitude,
*    description_of_emergency,
*    zip
**    title_of_emergency,
**    data_and_time_of_the_call,
**    township,
**    general_adress,
**    actor_name,
**    total_gross,
**    number_of_movies,
**    average_per_movie,
**    fst_movie,
**    gross,
**    yearx,
**    length,
**    title,
**    subject,
**    actor,
**    actress,
**    director,
**    popularity,
**    awards,
**    imagex,
**    participation,
**    xhours,
**    youngkids,
**    oldkids,
**    age,
**    education,
**    wage,
**    repwage,
**    hhours,
**    hage,
**    heducation,
**    hwage,
**    fincome,
**    tax,
**    meducation,
**    feducation,
**    unemp,
**    city,
**    experience,
**    college,
**    hcollege,
**    region,
**    country,
**    item_type,
**    sales_channel,
**    order_priority,
**    order_date,
**    order_id,
**    ship_date,
**    units_sold,
**    unit_price,
**    unit_cost,
**    total_revenue,
**    total_cost,
**    total_profit,
**    star_number,
**    gender,
**    ethnicity,
**    birth,
**    stark,
**    star1,
**    star2,
**    star3,
**    readk,
**    read1,
**    read2,
**    read3,
**    mathk,
**    math1,
**    math2,
**    math3,
**    lunchk,
**    lunch1,
**    lunch2,
**    lunch3,
**    schoolk,
**    school1,
**    school2,
**    school3,
**    degreek,
**    degree1,
**    degree2,
**    degree3,
**    ladderk,
**    ladder1,
**    ladder2,
**    ladder3,
**    experiencek,
**    experience1,
**    experience2,
**    experience3,
**    tethnicityk,
**    tethnicity1,
**    tethnicity2,
**    tethnicity3,
**    systemk,
**    system1,
**    system2,
**    system3,
**    schoolidk,
**    schoolid1,
**    schoolid2,
**    schoolid3
*  FROM /ado/sql_all
*  INTO TABLE @DATA(lt_at_data2)
*  UP TO 190 ROWS
*  BYPASSING BUFFER.
*
*GET RUN TIME FIELD t1.
*
*r = ( t1 - t0 ) / 1.
*WRITE / |Dauer: { r }µs (ca. { r / 1000000 }s)|.
*ULINE.
