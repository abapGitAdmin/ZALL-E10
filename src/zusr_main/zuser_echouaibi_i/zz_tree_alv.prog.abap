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
REPORT zz_tree_alv.

TYPE-POOLS : slis.

TYPES : BEGIN OF ty_scarr,
          carrid TYPE scarr-carrid,
        END OF ty_scarr.

TYPES : BEGIN OF ty_spfli,
          carrid TYPE spfli-carrid,
          connid TYPE spfli-connid,
        END OF ty_spfli.


TYPES : BEGIN OF ty_sflight,
          carrid TYPE sflight-carrid,
          connid TYPE sflight-connid,
          fldate TYPE sflight-fldate,
        END OF ty_sflight.



DATA : it_scarr   TYPE TABLE OF ty_scarr,
       wa_scarr   TYPE ty_scarr,

       it_spfli   TYPE TABLE OF ty_spfli,
       wa_spfli   TYPE ty_spfli,

       it_sflight TYPE TABLE OF ty_sflight,
       wa_sflight TYPE ty_sflight,

       it_node    TYPE TABLE OF snodetext,
       wa_node    TYPE snodetext.



START-OF-SELECTION.

  PERFORM data-fetch.

  PERFORM build_tree.

  PERFORM display_tree.

*-------------------------------------------------------------*

FORM data-fetch .

  SELECT carrid FROM scarr INTO TABLE it_scarr.

  IF it_scarr IS NOT INITIAL.

    SELECT carrid connid FROM spfli INTO TABLE it_spfli FOR ALL ENTRIES IN it_scarr WHERE carrid  = it_scarr-carrid.

    IF it_spfli IS NOT INITIAL.

      SELECT carrid connid fldate FROM sflight INTO TABLE it_sflight
        FOR ALL ENTRIES IN it_spfli WHERE carrid = it_spfli-carrid AND connid = it_spfli-connid.

    ENDIF.

  ENDIF.

  SORT : it_scarr BY carrid,

          it_spfli BY carrid connid,

          it_sflight BY carrid connid fldate.

ENDFORM.


FORM build_tree.

  CLEAR : wa_node, it_node.

  wa_node-type = 'T'.
  wa_node-name = 'Airline'.
  wa_node-tlevel = '01'.
  wa_node-nlength = '08'.
  wa_node-color = '05'.
  wa_node-text = 'CODE'.
  wa_node-tlength = '04'.
  wa_node-tcolor = '05'.

  APPEND wa_node TO it_node.

  CLEAR wa_node.


  LOOP AT it_scarr INTO wa_scarr.

    wa_node-type = 'P'.
    wa_node-name = 'CARRID'.
    wa_node-tlevel = '02'.
    wa_node-nlength = '08'.
    wa_node-color = '06'.
    wa_node-text = wa_scarr-carrid.
    wa_node-tlength = '04'.
    wa_node-tcolor = '06'.

    APPEND wa_node TO it_node.
    CLEAR wa_node.

    LOOP AT it_spfli INTO wa_spfli.

      wa_node-type = 'P'.
      wa_node-name = 'CONNID'.
      wa_node-tlevel = '03'.
      wa_node-nlength = '08'.
      wa_node-color = '04'.
      wa_node-text = wa_spfli-connid.
      wa_node-tlength = '04'.
      wa_node-tcolor = '04'.

      APPEND wa_node TO it_node.
      CLEAR wa_node.


      LOOP AT it_sflight INTO wa_sflight.

        wa_node-type = 'P'.
        wa_node-name = 'fldate'.
        wa_node-tlevel = '04'.
        wa_node-nlength = '06'.
        wa_node-color = '04'.
        wa_node-text = wa_sflight-fldate.
        wa_node-tlength = '10'.
        wa_node-tcolor = '04'.

        APPEND wa_node TO it_node.
        CLEAR wa_node.

      ENDLOOP.

    ENDLOOP.

  ENDLOOP.

ENDFORM.                    " build_tree


FORM display_tree .

  CALL FUNCTION 'RS_TREE_CONSTRUCT'
* EXPORTING
*   INSERT_ID                = '000000'
*   RELATIONSHIP             = ' '
*   LOG                      =
    TABLES
      nodetab = it_node.


  CALL FUNCTION 'RS_TREE_LIST_DISPLAY'
    EXPORTING
      callback_program = sy-cprog.

ENDFORM.                    " DISPLAY_TREE
