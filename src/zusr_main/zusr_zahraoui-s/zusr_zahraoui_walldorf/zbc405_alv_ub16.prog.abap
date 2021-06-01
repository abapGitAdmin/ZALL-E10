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
REPORT zbc405_alv_ub16.

TYPES: BEGIN OF gt_yjoin,
         carrid    TYPE spfli-carrid,
         connid    TYPE spfli-connid,
         fldate    TYPE sflight-fldate,
         cityfrom  TYPE spfli-carrid,
         cityto    TYPE spfli-cityto,
         fltime    TYPE spfli-fltime,
         planetype TYPE saplane-planetype,
         seatsocc  TYPE sflight-seatsocc,
         seatsmax  TYPE sflight-seatsmax,
         op_speed TYPE saplane-op_speed,
         speed_unit TYPE saplane-speed_unit,
       END OF gt_yjoin.


DATA :
  gt_flights TYPE  TABLE OF gt_yjoin,

  gs_flight  TYPE gt_yjoin,
  go_alv     TYPE REF TO cl_salv_table.

SELECT-OPTIONS: so_car FOR gs_flight-carrid MEMORY ID car.

START-OF-SELECTION.


  SELECT spfli~carrid spfli~connid
         fldate
         cityfrom cityto fltime
         sflight~seatsmax seatsocc
         sflight~planetype op_speed speed_unit
  INTO CORRESPONDING FIELDS OF TABLE gt_flights
  FROM spfli
  INNER JOIN sflight
    ON spfli~carrid = sflight~carrid
    AND spfli~connid  = sflight~connid
  INNER JOIN saplane
    on  sflight~planetype = saplane~planetype
    WHERE spfli~carrid in so_car.

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
