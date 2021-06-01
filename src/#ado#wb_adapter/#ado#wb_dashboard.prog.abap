*&---------------------------------------------------------------------*
*& Report /ADO/WB_DASHBOARD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /ado/wb_dashboard.

"Dynprofelder und Radiobuttons
DATA:
  radio_lkwh TYPE abap_bool,
  radio_rev  TYPE abap_bool,
  radio_or   TYPE abap_bool,
  radio_cs   TYPE abap_bool,
  dyn_jahr   TYPE string.

DATA:
  ok_code                  LIKE sy-ucomm,
  lt_operator              TYPE TABLE OF /ado/wb_op,
  ls_operator              TYPE /ado/wb_op,
  lt_chargestation         TYPE TABLE OF /ado/wb_cs,
  ls_chargestation         TYPE /ado/wb_cs,
  lt_wb_rev_cs             TYPE TABLE OF /ado/wb_rev_cs,
  ls_wb_rev_cs             TYPE /ado/wb_rev_cs,
  lt_wb_rev_or             TYPE TABLE OF /ado/wb_rev_or,
  ls_wb_rev_or             TYPE TABLE OF /ado/wb_rev_or,
  lt_wb_lkwh_cs            TYPE TABLE OF /ado/wb_lkwh_cs,
  ls_wb_lkwh_cs            TYPE TABLE OF /ado/wb_lkwh_cs,
  lt_wb_lkwh_or            TYPE TABLE OF /ado/wb_lkwh_or,
  ls_wb_lkwh_or            TYPE TABLE OF /ado/wb_lkwh_or,
  lt_wb_user               TYPE TABLE OF /ado/wb_user,
  lt_wb_cs                 TYPE TABLE OF /ado/wb_cs,
  lt_wb_op                 TYPE TABLE OF /ado/wb_op,
  g_container_cs           TYPE scrfname VALUE 'CUSTOM_CONTROL_CS',
  g_container_or           TYPE scrfname VALUE 'CUSTOM_CONTROL_OR',
  g_container_final        TYPE scrfname VALUE 'CUSTOM_CONTROL_FINAL', "Container für das finale Ergebnis unten im Dynpro
  g_salv_cs                TYPE REF TO cl_salv_table, "ALV_GRID für Ladestation
  g_salv_or                TYPE REF TO cl_salv_table, "ALV_GRID für Operator
  g_salv_final             TYPE REF TO cl_salv_table, "ALV_GRID für die finale Ausgabe
  grid_finale              TYPE REF TO cl_gui_alv_grid, "ALV_GRID für das finale Ergebnis unten im Dynpro
  g_custom_container_cs    TYPE REF TO cl_gui_custom_container,
  g_custom_container_or    TYPE REF TO cl_gui_custom_container,
  g_custom_container_final TYPE REF TO cl_gui_custom_container. "muss am Ende im PAI befüllt werden


*---------------------------------------------------------------------*
*       HAUPTPROGRAMM                                                 *
*---------------------------------------------------------------------*

SELECT * FROM /ado/wb_op INTO TABLE lt_operator.
SELECT * FROM /ado/wb_cs INTO TABLE lt_chargestation.

CALL SCREEN 100.


*---------------------------------------------------------------------*
*       MODULE PBO OUTPUT                                             *
*---------------------------------------------------------------------*
MODULE wb_pbo OUTPUT.

  SET PF-STATUS 'STATUS_100'.
  SET TITLEBAR 'TITEL_100'.

  "check, ob der Container für die Liste mit den Ladestationen bereits vorhanden ist
  IF g_custom_container_cs IS INITIAL.

    g_custom_container_cs = NEW #( g_container_cs ).

    cl_salv_table=>factory(
      EXPORTING
        r_container = g_custom_container_cs
      IMPORTING
        r_salv_table = g_salv_cs
      CHANGING
        t_table = lt_chargestation
    ).

    PERFORM setup_salv CHANGING g_salv_cs.

    g_salv_cs->display( ).

  ENDIF.

  "check, ob der Container für die Liste mit den Operatoren bereits vorhanden ist
  IF g_custom_container_or IS INITIAL.

    g_custom_container_or = NEW #( g_container_or ).

    cl_salv_table=>factory(
      EXPORTING
        r_container = g_custom_container_or
      IMPORTING
        r_salv_table = g_salv_or
      CHANGING
        t_table = lt_operator
    ).

    PERFORM setup_salv CHANGING g_salv_or.

    g_salv_or->display( ).

  ENDIF.
ENDMODULE.

*---------------------------------------------------------------------*
*       MODULE PAI INPUT                                              *
*---------------------------------------------------------------------*
MODULE wb_pai INPUT.

  DATA: lv_year TYPE char4.

  DATA: lt_selected_rows_cs TYPE salv_t_row, "für die im ALV-Grid ausgewähle Reihe chargestation/Ladestation
        lt_selected_rows_or TYPE salv_t_row. "für die im ALV-Grid ausgewähle Reihe Operator

  DATA: lr_functions TYPE REF TO cl_salv_functions_list.

  CASE ok_code.
    WHEN 'OPEN_CS'.
      SELECT * FROM /ado/wb_cs INTO TABLE lt_wb_cs.

      cl_salv_table=>factory( IMPORTING r_salv_table = g_salv_final
                              CHANGING t_table = lt_wb_cs ). "Dynpro wird aus der /ado/wb_lkwh_cs aufgebaut

      PERFORM setup_salv CHANGING g_salv_final.

      g_salv_final->set_screen_status( report = sy-repid
                                       pfstatus = 'ALV_STATUS'
                                       set_functions = g_salv_final->c_functions_all ).


      g_salv_final->set_screen_popup( start_column = 10
                                      end_column  = 250
                                      start_line  = 10
                                      end_line    = 30 ).

      g_salv_final->display( ).

    WHEN 'OPEN_OP'.
      SELECT * FROM /ado/wb_op INTO TABLE lt_wb_op.

      cl_salv_table=>factory( IMPORTING r_salv_table = g_salv_final
                              CHANGING t_table = lt_wb_op ). "Dynpro wird aus der /ado/wb_lkwh_cs aufgebaut

      PERFORM setup_salv CHANGING g_salv_final.

      g_salv_final->set_screen_status( report = sy-repid
                                       pfstatus = 'ALV_STATUS'
                                       set_functions = g_salv_final->c_functions_all ).


      g_salv_final->set_screen_popup( start_column = 10
                                      end_column  = 250
                                      start_line  = 10
                                      end_line    = 30 ).

      g_salv_final->display( ).

    WHEN 'OPEN_USER'.
      SELECT * FROM /ado/wb_user INTO TABLE lt_wb_user.

      cl_salv_table=>factory( IMPORTING r_salv_table = g_salv_final
                              CHANGING t_table = lt_wb_user ). "Dynpro wird aus der /ado/wb_lkwh_cs aufgebaut

      PERFORM setup_salv CHANGING g_salv_final.

      g_salv_final->set_screen_status( report = sy-repid
                                       pfstatus = 'ALV_STATUS'
                                       set_functions = g_salv_final->c_functions_all ).


      g_salv_final->set_screen_popup( start_column = 10
                                      end_column  = 250
                                      start_line  = 10
                                      end_line    = 30 ).

      g_salv_final->display( ).

    WHEN 'BUTTON_SHOW'.                           "wenn der Button "Statistik anzeigen" gedrückt wurde

      lv_year = CONV #( dyn_jahr ).

      "Check, ob loadedkWh oder revenue gewählt wurde
      IF radio_lkwh = abap_true. "LOADED KWH WURDE GEWÄHLT

        IF radio_cs = abap_true. "spezifische Ladestation wurde gewählt

          g_salv_cs->get_metadata( ). "besorgen der Daten in der jeweiligen Reihe (ALV)
          lt_selected_rows_cs = g_salv_cs->get_selections( )->get_selected_rows( ).
          IF lines( lt_selected_rows_cs ) = 1.
            ls_chargestation = lt_chargestation[ lt_selected_rows_cs[ 1 ] ].
            DATA(lv_cs_id_lkwh) = ls_chargestation-id.
            "nun muss die Methode der Klasse aufgerufen werden.... mit dem Jahr, der ID
            /ado/cl_wb_rest=>save_loadedkwh( EXPORTING iv_charging_station = lv_cs_id_lkwh
                                                       iv_year = lv_year
                                             IMPORTING et_wb_lkwh_cs = lt_wb_lkwh_cs ).

            g_custom_container_final = NEW #( g_container_final ).

            cl_salv_table=>factory( IMPORTING r_salv_table = g_salv_final
                                    CHANGING t_table = lt_wb_lkwh_cs ). "Dynpro wird aus der /ado/wb_lkwh_cs aufgebaut

            PERFORM setup_salv CHANGING g_salv_final.

            g_salv_final->set_screen_status( report = sy-repid
                                             pfstatus = 'ALV_STATUS'
                                             set_functions = g_salv_final->c_functions_all ).


            g_salv_final->set_screen_popup( start_column = 10
                                            end_column  = 250
                                            start_line  = 10
                                            end_line    = 30 ).

            g_salv_final->display( ).

          ELSE.
            MESSAGE 'Bitte eine Charging Station auswählen' TYPE 'W'.
          ENDIF.

        ELSEIF radio_or = abap_true. "spezifischer Operator wurde gewählt

          g_salv_or->get_metadata( ). "besorgen der Daten in der jeweiligen Reihe (ALV)
          lt_selected_rows_or = g_salv_or->get_selections( )->get_selected_rows( ).
          IF lines( lt_selected_rows_or ) = 1.
            ls_operator = lt_operator[ lt_selected_rows_or[ 1 ] ].
            DATA(lv_or_id_lkwh) = ls_operator-id.

            "nun muss die Methode der Klasse aufgerufen werden

            /ado/cl_wb_rest=>save_loadedkwh( EXPORTING iv_operator = lv_or_id_lkwh
                                                       iv_year = lv_year
                                             IMPORTING et_wb_lkwh_or = lt_wb_lkwh_or ).

            g_custom_container_final = NEW #( g_container_final ).

            cl_salv_table=>factory( IMPORTING r_salv_table = g_salv_final
                                    CHANGING t_table = lt_wb_lkwh_or ). "Dynpro wird aus der /ado/wb_lkwh_or aufgebaut

            PERFORM setup_salv CHANGING g_salv_final.

            g_salv_final->set_screen_status( report = sy-repid
                                             pfstatus = 'ALV_STATUS'
                                             set_functions = g_salv_final->c_functions_all ).

            g_salv_final->set_screen_popup( start_column = 10
                                            end_column  = 250
                                            start_line  = 10
                                            end_line    = 30 ).

            g_salv_final->display( ).

          ELSE.
            MESSAGE 'Bitte einen Operator auswählen' TYPE 'W'.
          ENDIF.
        ENDIF.
*------------------------------------------------------------------------------------------------------------------------*
      ELSEIF radio_rev = abap_true. "REVENUE WURDE GEWÄHLT

        IF radio_cs = abap_true. "spezifische Ladestation wurde gewählt

          g_salv_cs->get_metadata( ). "besorgen der Daten in der jeweiligen Reihe (ALV)
          lt_selected_rows_cs = g_salv_cs->get_selections( )->get_selected_rows( ).
          IF lines( lt_selected_rows_cs ) = 1.
            ls_chargestation = lt_chargestation[ lt_selected_rows_cs[ 1 ] ].
            DATA(lv_cs_id_rev) = ls_chargestation-id.
            "nun muss die Methode der Klasse aufgerufen werden
            /ado/cl_wb_rest=>save_revenue( EXPORTING iv_charging_station = lv_cs_id_rev
                                                     iv_year = lv_year
                                           IMPORTING et_wb_rev_cs = lt_wb_rev_cs ).

            g_custom_container_final = NEW #( g_container_final ).

            cl_salv_table=>factory( IMPORTING r_salv_table = g_salv_final
                                    CHANGING t_table = lt_wb_rev_cs ). "Dynpro wird aus der /ado/wb_rev_cs aufgebaut

            PERFORM setup_salv CHANGING g_salv_final.

            g_salv_final->set_screen_status( report = sy-repid
                                             pfstatus = 'ALV_STATUS'
                                             set_functions = g_salv_final->c_functions_all ).

            g_salv_final->set_screen_popup( start_column = 10
                                            end_column  = 250
                                            start_line  = 10
                                            end_line    = 30 ).

            g_salv_final->display( ).

          ELSE.
            MESSAGE 'Bitte eine Charging Station auswählen' TYPE 'W'.
          ENDIF.

        ELSEIF radio_or = abap_true. "spezifischer Operator wurde gewählt
          g_salv_or->get_metadata( ). "besorgen der Daten in der jeweiligen Reihe (ALV)
          lt_selected_rows_or = g_salv_or->get_selections( )->get_selected_rows( ).
          IF lines( lt_selected_rows_or ) = 1.
            ls_operator = lt_operator[ lt_selected_rows_or[ 1 ] ].
            DATA(lv_or_id_rev) = ls_operator-id.
            "nun muss die Methode der Klasse aufgerufen werden
            /ado/cl_wb_rest=>save_revenue( EXPORTING iv_operator = lv_or_id_rev
                                                     iv_year = lv_year
                                           IMPORTING et_wb_rev_or = lt_wb_rev_or ).

            g_custom_container_final = NEW #( g_container_final ).

            cl_salv_table=>factory( IMPORTING r_salv_table = g_salv_final
                                    CHANGING t_table = lt_wb_rev_or ). "Dynpro wird aus der /ado/wb_rev_or aufgebaut

            PERFORM setup_salv CHANGING g_salv_final.

            g_salv_final->set_screen_status( report = sy-repid
                                             pfstatus = 'ALV_STATUS'
                                             set_functions = g_salv_final->c_functions_all ).


            g_salv_final->set_screen_popup( start_column = 10
                                            end_column  = 250
                                            start_line  = 10
                                            end_line    = 30 ).

            g_salv_final->display( ).

          ELSE.
            MESSAGE 'Bitte einen Operator auswählen' TYPE 'W'.
          ENDIF.
        ENDIF.
      ENDIF. "Schließen der LKWH REV RadioButtons

    WHEN 'BACK'.
*      LEAVE TO SCREEN 0.
      LEAVE PROGRAM.

    WHEN 'EXIT'.
      LEAVE PROGRAM.

    WHEN 'CANC'.
      LEAVE TO SCREEN 0.

  ENDCASE.
  CLEAR ok_code.
ENDMODULE.

INCLUDE /ado/wb_dashboard_f01.
