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
REPORT ztc_abfragen.
"/ado/sql_all
"ztc_db_medium


DATA: lv_t1          TYPE i,
      lv_t2          TYPE i,
      lv_time_result TYPE i.



DATA: lv_iteration  TYPE i VALUE 1,
      lv_repetition TYPE i VALUE 1.



DO lv_iteration TIMES.
  WRITE / | { sy-index }. Iteration |.

  GET RUN TIME FIELD lv_t1.

  DO lv_repetition TIMES.

    "Schwer1      ohne where   746472x37  18 sekunden          |        mit where    10 sekunden     411384x37
SELECT large~yearx,large~length, large~title, large~subject, large~actor, large~actress, large~director, large~popularity, large~awards,
CASE large~imagex WHEN 'NicholasCage.png' THEN 'Example.com' ELSE large~imagex END AS case_image, salerec~region, salerec~country, salerec~item_type,
salerec~sales_channel, salerec~order_priority ,salerec~order_date, medium~order_id, medium~ship_date, medium~unit_price,medium~unit_cost,medium~total_revenue,
medium~total_cost ,medium~total_profit, emerg~latitude ,emerg~longitude,emerg~description_of_emergency, emerg~zip, emerg~title_of_emergency,
emerg~data_and_time_of_the_call, emerg~township, emerg~general_adress,
MAX( medium~total_profit ) AS max_profit, AVG( emerg~latitude ) AS avg_latitude, MIN( medium~unit_price ) as min_unit_price,
SUM( CASE WHEN medium~unit_cost <= 200 THEN medium~unit_cost * 1000 END ) AS sum_cost, SUM( CASE WHEN medium~units_sold >= 100000000 THEN 10000000 ELSE 100000 END ) AS sum_sold,
MAX( CASE WHEN medium~unit_price >= 10000 THEN 111111 * 99 ELSE medium~unit_price END ) AS max_case_unit_price
FROM /ado/sql_all AS large
LEFT OUTER JOIN /ado/sql_salerec AS salerec ON salerec~id_salerec = large~id_actor
LEFT OUTER JOIN ztc_db_medium AS medium ON medium~id_salerec = salerec~id_salerec
LEFT OUTER JOIN /ado/sql_911 AS emerg ON emerg~id_911 = large~id_salerec
"WHERE medium~sales_channel = 'Online' AND emerg~latitude >= 401065
GROUP BY large~yearx,large~length, large~title, large~subject, large~actor, large~actress, large~director, large~popularity, large~awards, large~imagex,
         salerec~region, salerec~country, salerec~item_type,salerec~sales_channel, salerec~order_priority ,salerec~order_date,
         medium~order_id, medium~ship_date, medium~unit_price,medium~unit_cost,medium~total_revenue, medium~total_cost ,medium~total_profit,
         emerg~latitude ,emerg~longitude,emerg~description_of_emergency, emerg~zip, emerg~title_of_emergency, emerg~data_and_time_of_the_call, emerg~township, emerg~general_adress
ORDER BY emerg~township, avg_LATITUDE
INTO TABLE @DATA(lt_table2)
BYPASSING BUFFER
.

*******************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************



    " version 1 "Schwer2                  Ausgabewert: 983675x6 5 Sekunden
*    SELECT large~title AS k1, large~subject AS k2, large~actor AS k3, large~actress AS k4, large~director AS k5,
*    CASE large~imagex WHEN 'NicholasCage.png' THEN 'Example.com' ELSE large~imagex END AS k6
*    FROM /ado/sql_all AS large
*    LEFT OUTER JOIN /ado/sql_salerec AS salerec ON salerec~id_salerec = large~id_actor
*    WHERE large~yearx > '1950'
*    UNION ALL
*    SELECT medium~region AS k1, medium~item_type AS k2, emerg~description_of_emergency AS k3, emerg~title_of_emergency AS k4, emerg~township AS k5,
*    CASE emerg~general_adress WHEN 'SCHUYLKILL EXPY & WEADLEY RD OVERPASS' THEN 'Examplestreet' ELSE emerg~general_adress END AS k6
*    FROM ztc_db_medium AS medium
*    LEFT OUTER JOIN /ado/sql_911 AS emerg ON emerg~id_911 = medium~id_salerec
*    WHERE medium~unit_price > '10.00'
*    ORDER BY k1, k6
*    INTO TABLE @DATA(tabelle1)
*    BYPASSING BUFFER
*    .


*******************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************
*******************************************************************************************************************************************************************************





**" Version 2  Schwer2            Ausgabewert: 99365x10   1 sekunde           wieso Groub by
*SELECT large~title as k1, large~subject as k2, large~actor as k3, large~actress as k4, large~DIRECTOR as k5,
*CASE large~imagex WHEN 'NicholasCage.png' THEN 'Example.com' ELSE large~imagex END AS k6,
*MIN( large~unit_price ) as k7,
*MAX( salerec~total_profit ) AS k8,
*AVG( large~latitude ) AS k9,
*SUM( CASE WHEN large~unit_cost <= 200 THEN large~unit_cost * 1000 END ) AS k10
*FROM /ADO/SQL_ALL as large
*LEFT OUTER JOIN /ado/sql_salerec AS salerec ON salerec~id_salerec = large~id_actor
*WHERE large~zip >= '19090'
*GROUP BY large~title, large~subject, large~actor, large~actress, large~DIRECTOR, large~imagex
*UNION ALL
*SELECT medium~region as k1, medium~item_type as k2, emerg~description_of_emergency as k3, emerg~title_of_emergency as k4, emerg~township as k5,
*CASE emerg~GENERAL_ADRESS WHEN 'SCHUYLKILL EXPY & WEADLEY RD OVERPASS' THEN 'Examplestreet' ELSE emerg~GENERAL_ADRESS END as k6,
*MIN( medium~UNIT_PRICE ) as k7,
*MAX( medium~UNITS_SOLD ) as k8,
*AVG( emerg~LATITUDE ) as k9,
*SUM( CASE WHEN medium~total_profit <= 200 THEN medium~total_profit * 1000 END ) as k10
*FROM ztc_db_medium as medium
*LEFT OUTER JOIN /ado/sql_911 AS emerg ON emerg~id_911 = medium~id_salerec
*WHERE emerg~latitude >= 401065
*GROUP BY medium~region, medium~item_type, emerg~description_of_emergency, emerg~title_of_emergency, emerg~township, emerg~GENERAL_ADRESS
*INTO TABLE @DATA(tabelle)
**BYPASSING BUFFER
*.


*SELECT *
* SELECT *
*FROM /ado/sql_all AS large
*LEFT OUTER JOIN /ado/sql_salerec AS salerec ON salerec~id_salerec = large~id_actor
*LEFT OUTER JOIN ztc_db_medium AS medium ON medium~id_salerec = salerec~id_salerec
*LEFT OUTER JOIN /ado/sql_911 AS emerg ON emerg~id_911 = large~id_salerec
*INTO TABLE @DATA(lt_sql)
*BYPASSING BUFFER
*.






  ENDDO.

  GET RUN TIME FIELD lv_t2.

  lv_time_result =  ( lv_t2 - lv_t1 ) / lv_repetition.

  WRITE 50  |SQL-Query: { lv_time_result }µs (ca. { lv_time_result / 1000000 }s)|.


  CLEAR:  lv_time_result.

  GET RUN TIME FIELD lv_t1.

  DO lv_repetition TIMES.


    "Schwer1      ohne where   746472x37  18 sekunden          |        mit where    10 sekunden     411384x37
*    SELECT *
*    FROM ztc_cds_join
*    ORDER BY township, avg_latitude
*    INTO TABLE @DATA(lt_cds)
*    BYPASSING BUFFER
*      .

***************************************************************************************************************************************************************************************
***************************************************************************************************************************************************************************************
***************************************************************************************************************************************************************************************
***************************************************************************************************************************************************************************************

    "Schwer2  version 1                 Ausgabewert: 983675x6 5 Sekunden
*    SELECT *
*    FROM ztc_cds_join
*    ORDER BY k1, k6
*    INTO TABLE @DATA(lt_cds)
*    BYPASSING BUFFER
*    .

***************************************************************************************************************************************************************************************
***************************************************************************************************************************************************************************************
***************************************************************************************************************************************************************************************
***************************************************************************************************************************************************************************************

*    " Version 2  Schwer2            Ausgabewert: 99365x10   1 sekunde           wieso Groub by
*    SELECT *
*    FROM ztc_cds_join
*    INTO TABLE @DATA(lt_CDS)
**    BYPASSING BUFFER
*    .

*    SELECT *
*    FROM ztc_cds_join
*    INTO TABLE @DATA(lt_cds)
*    BYPASSING BUFFER.




  ENDDO.

  GET RUN TIME FIELD lv_t2.

  lv_time_result = ( lv_t2 - lv_t1 ) / lv_repetition.

  WRITE 100 |CDS-Query: { lv_time_result }µs (ca. { lv_time_result / 1000000 }s)|.

  SKIP.
  ULINE.
ENDDO.

*IF lt_table = lt_table2.
*  WRITE: 'gleich'.
*ELSE.
*  WRITE: 'ungleich'.
*
*ENDIF.

WRITE ''.
