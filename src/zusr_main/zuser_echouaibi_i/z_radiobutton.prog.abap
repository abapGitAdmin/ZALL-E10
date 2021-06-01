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
REPORT z_radiobutton.

DATA: gref_salv TYPE REF TO cl_salv_table.

*SELECT @sy-datum AS dat, carrname,
*CASE carrid
*  WHEN 'AA' THEN 'du bist Amerikaner'
*  WHEN 'BA' THEN 'du bist Engländer'
*  ELSE 'LEER'
*END AS ALIASNAME  FROM scarr
*
*INTO TABLE @DATA(it_scarr).


* Interne Tabelle ausgeben.
*TRY.
*    CALL METHOD cl_salv_table=>factory
*      IMPORTING
*        r_salv_table = gref_salv
*      CHANGING
*        t_table      = it_scarr.
*  CATCH cx_salv_msg .
*ENDTRY.
*
*gref_salv->display( ).



*SELECT sc~carrid, sc~carrname, coalesce( sf~planetype, 'N/A' ) AS fleugzeugtip
SELECT sc~carrid, sc~carrname, sf~planetype
FROM scarr AS sc LEFT OUTER JOIN sflight AS sf
ON sc~carrid = sf~carrid
INTO TABLE @DATA(it_scarr).
DELETE ADJACENT DUPLICATES FROM it_scarr COMPARING carrid.

TRY.
    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = gref_salv
      CHANGING
        t_table      = it_scarr.
  CATCH cx_salv_msg .
ENDTRY.

gref_salv->display( ).



*data: var1 TYPE int8 VALUE 1.
*
*    select carrid, connid, customid,
*      case  CUSTTYPE
*      WHEN 'P' THEN 'PrivateKunde'
*      WHEN 'B' THEN 'GeschäftsKunde'
*      END as KundeStatus,
*      cast( BOOKID as INT8 ) * ( @var1 * 1 ) as Betrag
*      from sbook
*INTO TABLE @DATA(it_sbook).
*



*data: ten type p length 5 decimals 2 value '0.1'.
*SELECT net_amount * ( 1 + @ten ) as net
*FROM snwd_so
*where gross_amount - tax_amount > snwd_so~net_amount
*INTO TABLE @data(itab).
*
** Interne Tabelle ausgeben.
*TRY.
*    CALL METHOD cl_salv_table=>factory
*      IMPORTING
*        r_salv_table = gref_salv
*      CHANGING
*        t_table      = itab.
*  CATCH cx_salv_msg .
*ENDTRY.
*
*gref_salv->display( ).
