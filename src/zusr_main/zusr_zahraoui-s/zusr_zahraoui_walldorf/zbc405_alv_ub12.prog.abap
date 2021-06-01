*&---------------------------------------------------------------------*
*& Report ZBC405_ALV_UB5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbc405_alv_ub12.
TYPE-POOLS: col,icon.
TYPES: BEGIN OF gty_flight.
    INCLUDE TYPE sflight.
TYPES: color            TYPE c LENGTH 4,
       "6 Ampelsysmbol hinzufügen +daten struktur gt_sflight erneut werden
       light            TYPE c LENGTH 1, "lights ind. booking status
       it_field_colors  TYPE lvc_t_scol,
       " " for cepp highlighting
       "üb9
       changes_possible TYPE icon-id,
       END OF gty_flight,
       gtt_sflight TYPE TABLE OF gty_flight.
DATA:
  "ordenung der internen tabele einen typ
  gt_flights     TYPE gtt_sflight,
  gs_flight      TYPE gty_flight,

  ok_code        LIKE  sy-ucomm,
  go_alv         TYPE REF TO cl_gui_custom_alv_grid,
  go_cont        TYPE REF TO cl_gui_custom_container,
  "üb7
  gv_variant     TYPE disvariant,
  "üb11
  gs_print       TYPE lvc_s_prnt,
  "üb8
  gs_layout      TYPE lvc_s_layo,
  gs_field_color TYPE lvc_s_scol,
  " Üb9 fELDKATALOG
  gt_field_cat   TYPE lvc_t_fcat,
  gs_field_cat   TYPE lvc_s_fcat.



SELECT-OPTIONS:
so_car FOR gs_flight-carrid,
so_con FOR gs_flight-connid.

SELECTION-SCREEN SKIP.
PARAMETERS: pa_lv TYPE disvariant.

" so_con FOR gs_SFLIGHT-connid.
"Ub10
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.

    CLASS-METHODS:
      on_doubleclick FOR EVENT double_click
      OF cl_gui_alv_grid
                  " wir brauchen Zeile nummer wenn wir double click
        IMPORTING es_row_no,
      "üb11
      on_print_top FOR EVENT print_top_of_page
        OF  cl_gui_alv_grid,
      "frage 5
      on_print_tol FOR EVENT print_top_of_list
        OF cl_gui_alv_grid,
      " üb12
      on_toolbar FOR EVENT toolbar
      OF cl_gui_alv_grid
                  "parameter export
        IMPORTING e_object,
      "aufg2 üb12
      on_user_command FOR EVENT user_command
                    OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.

  METHOD on_doubleclick.

    " brauchen variable  für gesamte bcuhun
    DATA: lv_booki_gesamt   TYPE i,
          lv_booki_gesamt_c TYPE c LENGTH 10,
          lv_message_text   TYPE c LENGTH 60.


    READ TABLE gt_flights INTO gs_flight INDEX es_row_no-row_id.
    IF sy-subrc NE 0.
      MESSAGE i075(bc405_408).
      EXIT.
    ENDIF.
    lv_booki_gesamt = gs_flight-seatsocc + gs_flight-seatsocc_b + gs_flight-seatsocc_f.

    "Nachricht
    lv_booki_gesamt_c = lv_booki_gesamt.

    lv_message_text = 'gesamte aller buchnungen ist : '(m01) &&
                      lv_booki_gesamt_c.
    MESSAGE lv_message_text TYPE 'I'.
    "ondoubleclick

  ENDMETHOD.
  METHOD on_print_top.

    " variable von integer.
    DATA lv_pos TYPE i.
    " gesamte text mit der farbe col-heading

    FORMAT COLOR COL_HEADING.
    WRITE: / sy-datum.
    lv_pos = sy-linsz / 2 - 3. " läneg von page: 6chARS
    WRITE AT lv_pos sy-pagno.
    lv_pos = sy-linsz - 11."länege von benutzername:12 char
    WRITE: AT lv_pos sy-uname.
    ULINE.
  ENDMETHOD.

  METHOD on_print_tol.
    "fluggeseleschaften und die Verbindungen
    DATA: ls_so_car LIKE LINE OF so_car,
          ls_so_con LIKE LINE OF so_con.
    CONSTANTS: lc_end TYPE i VALUE 20.
    FORMAT COLOR COL_HEADING.
    WRITE:/ 'Selekteiren die Options:'(000), AT lc_end space.
    SKIP.
    WRITE:/ 'Fluglinie'(001), AT lc_end space.
    ULINE AT /(lc_end).
    FORMAT COLOR COL_NORMAL.
    LOOP AT  so_car INTO ls_so_car.
      WRITE:/ ls_so_car-sign,
               ls_so_car-option,
               ls_so_car-low,
               ls_so_car-high.

    ENDLOOP.
    SKIP.
    FORMAT COLOR COL_NEGATIVE.
    WRITE: / 'Verbindungen:'(002), AT lc_end space.
    ULINE AT /(lc_end).
    FORMAT COLOR COL_NORMAL.
    LOOP AT  so_con INTO ls_so_con.
      WRITE:/ ls_so_con-sign,
               ls_so_con-option,
               ls_so_con-low,
               ls_so_con-high.

    ENDLOOP.
    SKIP.

  ENDMETHOD.
  "toolbar erweietern
  " ubung 12

  METHOD on_toolbar.
    "arbetsbereich für funktionsattrib.
    DATA ls_button TYPE stb_button.

    "seperator:beiden button in drucktastenleiste
    "vom rest abzusetzen,seperatper mnurmi butn_type
    """""""warum3""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "vor der drucktaste instanzattri. hinzufügen
    ls_button-butn_type = 3.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.
    " button für die auslastung Econmomy in prozent füe flüge
    " entllerrenls_button
    "create  button "total percentage of auslastung markierte alle flüge"
    "vom rest abzusetzen,seperatper mnurmi butn_type
    """""""w clear""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    CLEAR ls_button.
    ls_button-function = 'PERCENTAGE'.
    ls_button-text = '%total'(tot).
    ls_button-quickinfo = 'Occupation total ta7t'."(z01).
    ls_button-butn_type = 0.
    INSERT ls_button INTO TABLE e_object->mt_toolbar.

    "erzeugung für markierte Flüege

    CLEAR ls_button.
    ls_button-function = 'PERCENTAGE_MARKED'.
    ls_button-text = '% markiert'(z02).
    ls_button-quickinfo = 'Auslastung ta7t'.
    ls_button-butn_type = 0.

    INSERT ls_button INTO TABLE e_object->mt_toolbar.
  ENDMETHOD.
  METHOD on_user_command.

    DATA: lv_occupi     TYPE i,
          lv_capa       TYPE i,
          lv_percentage TYPE p LENGTH 8 DECIMALS 1,
          lv_text       TYPE string.
    DATA: lt_row TYPE lvc_t_roid,
          ls_row TYPE lvc_s_roid.

    CASE e_ucomm.
      WHEN 'PERCENTAGE'.
        LOOP AT gt_flights INTO gs_flight.
          lv_occupi = lv_occupi + gs_flight-seatsocc.
          lv_capa = lv_capa + gs_flight-seatsmax.

        ENDLOOP.
        lv_percentage = lv_occupi / lv_capa * 100.
        MOVE lv_percentage TO lv_text.
        lv_text = 'Prozent von der belegten Sitze: '(3am)
         && ` ` && lv_text.
        MESSAGE lv_text TYPE 'I'.

      WHEN 'PERCENTAGE_MARKED' .
        " Angabe von Id Zeilen deswegen et_row_no
        go_alv->get_selected_rows(
          IMPORTING
*            et_index_rows =                  " Indizes der selektierten Zeilen
            et_row_no     =   lt_row              " Numerische IDs der selektierten Zeilen
        ).

        IF lines( lt_row ) > 0.
          LOOP AT lt_row INTO ls_row.
            " loop nur an interne und in wa vom typ t_rowid und s_row _id
            READ TABLE gt_flights INTO gs_flight INDEX ls_row-row_id.
            lv_occupi = lv_occupi + gs_flight-seatsocc.
            lv_capa = lv_capa + gs_flight-seatsmax.

          ENDLOOP.
          lv_percentage = lv_occupi / lv_capa * 100.
          MOVE lv_percentage TO lv_text.
          lv_text ='Prozent von der belegten Sitze: '(a3a)
         && ` ` && lv_text.
          MESSAGE lv_text TYPE 'I'.
        ELSE.
          MESSAGE 'Bitte markieren Sie mindestens 1 Zeile si samir'(wad) TYPE 'I'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  SELECT * FROM sflight INTO CORRESPONDING FIELDS OF TABLE gt_flights
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

  INCLUDE zbc405_alv_ub12_clear_ok.
*INCLUDE ZBC405_ALV_UB11_CLEAR_OK.
*INCLUDE ZBC405_ALV_UB100_CLEAR_OK.
*INCLUDE ZBC405_ALV_UB9_CLEAR_OK_CODO01.
*    INCLUDE zbc405_alv_ub8_clear_ok_codo01.
*INCLUDE zbc405_alv_ub5_clear_ok_codo01.
  INCLUDE zbc405_alv_ub12_status.
*INCLUDE ZBC405_ALV_UB11_STATUS.
*INCLUDE ZBC405_ALV_UB100_STATUS.
*INCLUDE ZBC405_ALV_UB9_STATUS.
*    INCLUDE zbc405_alv_ub8_status_0100o011.
*INCLUDE zbc405_alv_ub5_status_0100o01.
  INCLUDE zalv_ub12_create_and_transfer.
*INCLUDE ZALV_UB11_CREATE_AND_TRANSFER.
*INCLUDE ZALV_UB100_CREATE_AND_TRANSFER.
*INCLUDE ZALV_UB9CREATE_AND_TRANSFER.
*    INCLUDE zalv_ub8create_and_transfer.
*include zalv_ub6create_and_transfer.
  INCLUDE zbc405_alv_ub12_user_command.
*INCLUDE ZBC405_ALV_UB11_USER_COMMAND.
*INCLUDE ZBC405_ALV_UB100_USER_COMMAND.
*INCLUDE ZBC405_ALV_UB9_USER_COMMAND.
*    INCLUDE zbc405_alv_ub8_user_commandi01.
*INCLUDE zbc405_alv_ub5_user_commandi01.
