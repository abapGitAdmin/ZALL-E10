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
REPORT zbc_ilias_flifht_half.
TYPES: BEGIN OF gt_tab,
         carrid   TYPE   scarr-carrid,
         carrname TYPE scarr-carrname,
         connid   TYPE    spfli-connid,
         cityfrom TYPE spfli-cityfrom,
         cityto   TYPE spfli-cityto,
         name     TYPE       scustom-name,
         fldate   TYPE sflight-fldate,
         price    TYPE sflight-price,
       END OF gt_tab.
DATA:
  gt_fliht TYPE TABLE OF gt_tab,
  gs_fliht TYPE gt_tab,
  go_alv   TYPE REF TO cl_salv_table.


START-OF-SELECTION.

  SELECT scarr~carrid scarr~carrname spfli~connid spfli~cityfrom
          sflight~fldate sflight~price spfli~cityto scustom~name



    INTO CORRESPONDING FIELDS OF TABLE gt_fliht

   FROM scarr INNER JOIN spfli
   ON  scarr~carrid = spfli~carrid

     INNER JOIN sflight
    ON  spfli~connid = sflight~connid

    INNER JOIN sbook
    ON sbook~carrid =  sflight~carrid  AND  sbook~connid = sflight~connid AND  sbook~fldate = sflight~fldate
    INNER JOIN scustom
    ON scustom~id = sbook~customid.


  IF sy-subrc = 0.

    cl_salv_table=>factory(

     IMPORTING
       r_salv_table = go_alv
       CHANGING
         t_table = gt_fliht
         ).
    go_alv->display( ).


  ELSE.
    MESSAGE 'keine Daten ' TYPE 'I' .

  ENDIF.
