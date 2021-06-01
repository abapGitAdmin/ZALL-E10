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
REPORT z_alv_reporting_sap.

CLASS demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.

  PRIVATE SECTION.
    CLASS-DATA scarr_tab TYPE TABLE OF scarr.

    CLASS-METHODS: handle_double_click
                    FOR EVENT double_click
                    OF cl_salv_events_table IMPORTING row column,
                    detail
                    IMPORTING carrid TYPE scarr-carrid,
                    browser
                    IMPORTING url TYPE csequence.

ENDCLASS.
CLASS demo IMPLEMENTATION.

  METHOD main.
    DATA: alv     TYPE REF TO cl_salv_table,
          events  TYPE REF TO cl_salv_events_table,
          columns TYPE REF TO cl_salv_columns,
          col_tab TYPE salv_t_column_ref.
    DATA it_top_of_page TYPE slis_t_listheader.


    DATA: ls_line     TYPE slis_listheader,
          lv_date(10) TYPE c,
          lv_time(8)  TYPE c,
          lv_sdt(2)   TYPE c,
          lv_min(2)   TYPE c,
          lv_sec(2)   TYPE c,
          lv_kopf(45) TYPE c.

    REFRESH it_top_of_page[].


    DATA: gv_save.

    FIELD-SYMBOLS <column> LIKE LINE OF col_tab.

    SELECT * FROM scarr INTO TABLE scarr_tab.

    TRY.
        cl_salv_table=>factory(
*          EXPORTING
*            list_display   = if_salv_c_bool_sap=>false " ALV wird im Listenmodus angezeigt
*            r_container    =                           " Abstracter Container fuer GUI Controls
*            container_name =
          IMPORTING
           r_salv_table   =  alv                     " Basisklasse einfache ALV Tabellen
          CHANGING
            t_table        = scarr_tab
        ).
*        CATCH cx_salv_msg. " ALV: Allg. Fehlerklasse  mit Meldung
        events = alv->get_event( ).
        SET HANDLER handle_double_click FOR events.
        columns = alv->get_columns( ).
        col_tab = columns->get( ).

**Die Kopfzeile ist zu ändern bzw. (ins Textfeld umwandeln)
*        lv_kopf = 'Auswertung Services zum Einzugsbeleg'.
*        lv_sdt = sy-uzeit+0(2).
*        lv_min = sy-uzeit+2(2).
*        lv_sec = sy-uzeit+4(2).
*
*        CONCATENATE lv_sdt ':' lv_min ':' lv_sec INTO lv_time.
*
*
*        CLEAR ls_line.
*        ls_line-typ  = 'H'.
*        ls_line-key  = ''.
*        ls_line-info = lv_kopf.
*        APPEND ls_line TO it_top_of_page.
*
** Kopfinfo: Typ S
*        CLEAR ls_line.
*        ls_line-typ  = 'S'.
*
*        ls_line-key  = 'Name:'.
*        ls_line-info = sy-uname.
*        APPEND ls_line TO it_top_of_page.
*
*        WRITE sy-datum TO lv_date.
*        ls_line-key  = 'Datum:'.
*        ls_line-info = lv_date.
*        APPEND ls_line TO it_top_of_page.
*
*        WRITE sy-datum TO lv_date.
*
*        ls_line-key  = 'Zeit:'.
*        ls_line-info = lv_time.
*        APPEND ls_line TO it_top_of_page.
*
*
*     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
*       EXPORTING
**            i_logo             = 'LOGO_SCHATTEN'  " <== LOGO ==
**            i_logo             = 'LOGO_TRANSPARENT_KLEIN'
*            it_list_commentary = it_top_of_page.


        LOOP AT col_tab ASSIGNING <column>.
          <column>-r_column->set_output_length( 40 ).

          IF <column>-columnname = 'CARRNAME' OR
             <column>-columnname = 'URL'.
            <column>-r_column->set_visible( 'X' ).
          ELSE.
            <column>-r_column->set_visible( ' ' ).
          ENDIF.
        ENDLOOP.

        alv->display( ).

      CATCH cx_salv_msg.
        MESSAGE 'ALV display not possible' TYPE 'I' DISPLAY LIKE 'E'.

    ENDTRY.
  ENDMETHOD.

  METHOD handle_double_click.
    FIELD-SYMBOLS <scarr> TYPE scarr.
    READ TABLE scarr_tab INDEX row ASSIGNING <scarr>.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    IF column = 'CARRNAME'.
      demo=>detail( <scarr>-carrid ).
    ELSEIF column = 'URL'.
      demo=>browser( <scarr>-url ).
    ENDIF.
  ENDMETHOD.

  METHOD detail.

    DATA: alv TYPE REF TO cl_salv_table,
          BEGIN OF alv_line,
            carrid   TYPE spfli-carrid,
            connid   TYPE spfli-connid,
            cityfrom TYPE spfli-cityfrom,
            cityto   TYPE spfli-cityto,
          END OF alv_line,
          alv_tab LIKE TABLE OF alv_line.
*
*    DATA: gt_layout TYPE slis_layout_alv.
*    DATA: gt_fieldcat TYPE slis_t_fieldcat_alv.
*    DATA: gt_events TYPE slis_t_event.
*    DATA: gv_repid LIKE sy-repid.
*    DATA:  gs_variant
*            TYPE  disvariant.


    SELECT carrid connid cityfrom cityto
      FROM spfli
      INTO CORRESPONDING FIELDS OF TABLE alv_tab
      WHERE carrid = carrid.

    IF sy-subrc <> 0.
      MESSAGE e007(sabapdocu).
    ENDIF.

    TRY.
        cl_salv_table=>factory(
*          EXPORTING
*            list_display   = if_salv_c_bool_sap=>false " ALV wird im Listenmodus angezeigt
*            r_container    =                           " Abstracter Container fuer GUI Controls
*            container_name =
          IMPORTING
            r_salv_table   = alv                      " Basisklasse einfache ALV Tabellen
          CHANGING
            t_table        = alv_tab
        ).
*        CATCH cx_salv_msg. " ALV: Allg. Fehlerklasse  mit Meldung

        alv->set_screen_popup(
          EXPORTING
            start_column = 1
            end_column   = 60
            start_line   = 1
            end_line     = 12
        ).

*        gv_repid = sy-repid.
*        gs_variant-report     = sy-repid.
*        gs_variant-username   = sy-uname.
*
*        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*          EXPORTING
*            i_callback_program     = gv_repid
**           i_callback_pf_status_set          =   'PF_STATUS_SET'
**           i_callback_user_command           =   'USER_COMMAND'
*            i_callback_top_of_page = 'TOP_OF_PAGE'
*            is_layout              = gt_layout
*            it_fieldcat            = gt_fieldcat
*            it_events              = gt_events
*            i_save                 = gv_save
*            is_variant             = gs_variant
*          TABLES
*            t_outtab               = alv_tab.


        alv->display( ).

      CATCH cx_salv_msg.
        MESSAGE 'ALV display not possible' TYPE 'I' DISPLAY LIKE 'E'.

    ENDTRY.
  ENDMETHOD.

  METHOD browser.
    CALL FUNCTION 'CALL_BROWSER'
      EXPORTING
        url = url.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  demo=>main( ).
