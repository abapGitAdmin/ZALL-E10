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
REPORT ZBC_ILIAS_FLIFHT.
TYPES: BEGIN OF gt_tab,
  carrid TYPE   scarr-carrid,
  carrname type scarr-carrname,
  connid TYPE    spfli-connid,
  cityfrom TYPE spfli-cityfrom,
  cityto TYPE spfli-cityto,
  name TYPE       scustom-name,
  fldate TYPE sflight-fldate,
  price type sflight-price,
  END OF gt_tab.
  DATA:
        gt_fliht type TABLE OF gt_tab,
        gs_fliht TYPE gt_tab,
        go_alv TYPE REF TO cl_salv_table.


START-OF-SELECTION.

select scarr~carrid scarr~carrname spfli~connid spfli~cityfrom
  spfli~cityto
  scustom~name
*  SFLIGHT~fldate
*  SFLIGHT~price

  into TABLE gt_fliht

 from scarr INNER JOIN spfli
 on  scarr~carrid = spfli~carrid

   INNER JOIN scustom
  on  spfli~connid = scustom~id

  INNER JOIN sbook
  on scustom~id = sbook~CUSTOMID.

*  INNER JOIN sflight
*  on sbook~carrid =  sflight~carrid  and  sbook~connid = sflight~connid and  sbook~fldate = sflight~fldate.


 IF sy-subrc = 0.

 cl_salv_table=>factory(

  IMPORTING
    r_salv_table = go_alv
    CHANGING
      t_table = gt_fliht
      ).
  go_alv->display( ).


  else.
    MESSAGE 'keine Daten ' type 'I' .

 ENDIF.
