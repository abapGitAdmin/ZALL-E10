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
REPORT zdr_fill_database.


DATA obj TYPE REF TO zdr_cl_sql_importer.
*CREATE OBJECT obj.

DATA itabfilm TYPE TABLE OF /ado/sql_film.

SELECT * FROM /ado/sql_film into TABLE itabfilm.







*CALL METHOD obj->dublicate_itab
*  CHANGING
*    itab = itabfilm.
