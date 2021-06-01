*&---------------------------------------------------------------------*
*& Report ZBC405_ALV_UB5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc405_alv_ub9.
TYPE-POOLS: col,icon.
TYPES: BEGIN OF gty_flight.
    INCLUDE TYPE sflight.
TYPES: color           TYPE c LENGTH 4,
       "6 Ampelsysmbol hinzufügen +daten struktur gt_sflight erneut werden
       light           TYPE c LENGTH 1, "lights ind. booking status
       it_field_colors TYPE lvc_t_scol,
       " " for cepp highlighting
       "üb9
         changes_possible TYPE icon-id,
       END OF gty_flight.
       "gtt_sflight TYPE TABLE OF gty_flight.
DATA:
  "ordenung der internen tabele einen typ
  gt_flights     TYPE TABLE OF gty_flight,
  gs_flight      TYPE gty_flight,

  ok_code        LIKE  sy-ucomm,
  go_alv         TYPE REF TO cl_gui_custom_alv_grid,
  go_cont        TYPE REF TO cl_gui_custom_container,
  "üb7
  gv_variant     TYPE disvariant,
  "üb8
  gs_layout      TYPE lvc_s_layo,
  gs_field_color TYPE lvc_s_scol,
  " Üb9 fELDKATALOG
  gt_field_cat TYPE lvc_t_fcat,
  gs_field_cat type lvc_s_fcat.



SELECT-OPTIONS:
so_car FOR gs_flight-carrid,
so_con FOR gs_flight-connid.

SELECTION-SCREEN SKIP.
PARAMETERS: pa_lv TYPE disvariant.

" so_con FOR gs_SFLIGHT-connid.


START-OF-SELECTION.

  SELECT * FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE gt_flights
    WHERE carrid IN so_car
    AND   connid IN so_con.

    LOOP AT gt_flights INTO gs_flight.
      " Moanat laufende setzen nur auf diese monat 4 für dajhr und 6 für monat
      IF gs_flight-fldate(6) = sy-datum(6).
        gs_flight-color = 'C' && col_negative && '01'.

      ENDIF.
      "6 amplefarbe rot ,gelb und grün wenn mleine buchung in eco class status setze für die Buchung
      IF gs_flight-seatsocc = 0.
        gs_flight-light = 1.
      ELSEIF gs_flight-seatsocc < 50.
        gs_flight-light = 2.
      ELSE.
        gs_flight-light = 3.
     ENDIF.
     "7 zellen farben
     IF gs_flight-planetype = '747-400'.
       gs_field_color-fname = col_positive.
       gs_field_color-color-col = col_positive.
       gs_field_color-color-int = 1.
       gs_field_color-color-inv = 0.
       gs_field_color-nokeycol = 'X'.
       APPEND gs_field_color TO gs_flight-it_field_colors.

     ENDIF.

     " wenn Flugdatum in der vergangenheit liegt-< space icn,ansonst ok:icon
     IF gs_flight-fldate < sy-datum.
       gs_flight-changes_possible = icon_space.
       ELSE.
         gs_flight-changes_possible = icon_okay.
     ENDIF.

MODIFY gt_flights FROM gs_flight
TRANSPORTING color light
 it_field_colors
 changes_possible.
    ENDLOOP.

    CALL SCREEN 100.

INCLUDE ZBC405_ALV_UB9_CLEAR_OK_CODO01.
*    INCLUDE zbc405_alv_ub8_clear_ok_codo01.
*INCLUDE zbc405_alv_ub5_clear_ok_codo01.
INCLUDE ZBC405_ALV_UB9_STATUS.
*    INCLUDE zbc405_alv_ub8_status_0100o011.
*INCLUDE zbc405_alv_ub5_status_0100o01.
INCLUDE ZALV_UB9CREATE_AND_TRANSFER.
*    INCLUDE zalv_ub8create_and_transfer.
*include zalv_ub6create_and_transfer.
INCLUDE ZBC405_ALV_UB9_USER_COMMAND.
*    INCLUDE zbc405_alv_ub8_user_commandi01.
*INCLUDE zbc405_alv_ub5_user_commandi01.
