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
REPORT zbc405_alv_ub18.

TYPES: BEGIN OF gt_yjoin,
         carrid    TYPE sflight-carrid,
         seatsocc  TYPE sflight-seatsocc,
         seatsmax  TYPE sflight-seatsmax,
         seatsmax_avg  TYPE sflight-seatsmax,
         seatsocc_avg   TYPE sflight-seatsocc,
         zahl TYPE i,
         zahl2 TYPE i,
       END OF gt_yjoin.


DATA :
  gt_flights TYPE  TABLE OF gt_yjoin,

  gs_flight  TYPE gt_yjoin,
  go_alv     TYPE REF TO cl_salv_table.

SELECT-OPTIONS: so_car FOR gs_flight-carrid .
SELECTION-SCREEN BEGIN OF BLOCK bb with FRAME TITLE t1.
  SELECT-OPTIONS:
    so_av_oc FOR gs_flight-seatsocc,
    so_av_mx FOR gs_flight-seatsmax.
  SELECTION-SCREEN END OF BLOCK bb.



START-OF-SELECTION.


  SELECT carrid
    count( DISTINCT connid ) as zahl
         sum( seatsmax ) as seatsmax
         sum( seatsocc ) as seatsocc
         avg( seatsmax ) as seatsmax_av
         avg( seatsocc ) as seatsocc_av
         count(*) as zahl1
  INTO   TABLE gt_flights
  FROM sflight
*  INNER JOIN sflight
*    ON spfli~carrid = sflight~carrid
*    AND spfli~connid  = sflight~connid
*  INNER JOIN saplane
*    on  sflight~planetype = saplane~planetype
    WHERE carrid in so_car
    GROUP BY  carrid connid
    HAVING  avg( seatsmax ) in so_av_mx and
         avg( seatsocc ) in so_av_oc .

    " alc create
    cl_salv_table=>factory(
*      EXPORTING
*        list_display   = if_salv_c_bool_sap=>false " ALV wird im Listenmodus angezeigt
*        r_container    =                           " Abstracter Container fuer GUI Controls
*        container_name =
      IMPORTING
        r_salv_table   =    go_alv                       " Basisklasse einfache ALV Tabellen
      CHANGING
        t_table        = gt_flights
    ).
*    CATCH cx_salv_msg.
   go_alv->display( ).
