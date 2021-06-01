*&---------------------------------------------------------------------*
*& Report  /ADESSO/ISU_DRGSCEN_GEN_001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/isu_drgscen_gen_001.

TYPES: BEGIN OF ts_pod_data,
         int_ui          TYPE int_ui,
         dateto          TYPE dateto,
         ext_ui          TYPE ext_ui,
         euirole_dereg   TYPE euihead-euirole_dereg,
         anlage          TYPE anlage,
         vertrag         TYPE vertrag,
         einzdat         TYPE einzdat,
         auszdat         TYPE auszdat,
         sparte          TYPE sparte,
         anlart          TYPE anlart,
         service         TYPE sercode,
         vkonto          TYPE vkont_kk,
         service_key     TYPE service_key,
         scenario        TYPE e_deregscenario,
         error_no        TYPE cdfmnr,
         invoicing_party TYPE invoicing_party,
         servprov_mos    TYPE service_prov,
         servprov_mds    TYPE service_prov,
         text            TYPE string,
       END OF ts_pod_data,
       tt_pod_data TYPE STANDARD TABLE OF ts_pod_data,
       BEGIN OF ts_out,
         status   TYPE icon_d,
         ext_ui   TYPE ext_ui,
         anlage   TYPE anlage,
         vertrag  TYPE vertrag,
         scenario TYPE e_deregscenario,
         dateto   TYPE dateto,
         error_no TYPE cdfmnr,
         text     TYPE string,
       END OF ts_out,
       tt_out TYPE STANDARD TABLE OF ts_out.

DATA: lr_drgscen          TYPE REF TO cl_isu_ide_drgscen_ana_pod,
      lr_badi_data_access TYPE REF TO /idxgl/badi_data_access,
      lt_start_data       TYPE tt_pod_data,
      lt_analyse_data     TYPE tt_pod_data,
      lt_out              TYPE tt_out,
      ls_out              TYPE ts_out,
      ls_service          TYPE eservice,
      ls_ever             TYPE ever,
      lv_icon_alert       TYPE icon_d,
      lv_icon_red         TYPE icon_d,
      lv_icon_green       TYPE icon_d,
      lv_icon_inactive    TYPE icon_d,
      lv_counter          TYPE int4.

FIELD-SYMBOLS: <fs_pod_data>       TYPE ts_pod_data,
               <fs_scenario>       TYPE ederegscenario_ana,
               <fs_scenario_check> TYPE ederegscenario_ana,
               <fs_service>        TYPE ederegscenarioserv,
               <fs_contr>          TYPE ederegscenariocontr,
               <fs_out>            TYPE ts_out.



CONSTANTS: c_date_unendlich TYPE sy-datum VALUE '99991231'.

* Selektionsbildschirm ------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-001.
PARAMETERS: p_sel_ui RADIOBUTTON GROUP sel DEFAULT 'X' USER-COMMAND radio.
SELECTION-SCREEN BEGIN OF BLOCK sel_ui WITH FRAME TITLE TEXT-010.
SELECT-OPTIONS: s_ext_ui FOR <fs_pod_data>-ext_ui,
                s_serv   FOR <fs_pod_data>-service,
                s_anlart FOR <fs_pod_data>-anlart,
                s_date   FOR <fs_pod_data>-dateto DEFAULT sy-datum TO '99991231'.
SELECTION-SCREEN END OF BLOCK sel_ui.
PARAMETERS: p_sel_co RADIOBUTTON GROUP sel.
SELECTION-SCREEN BEGIN OF BLOCK sel_contr WITH FRAME TITLE TEXT-011.
SELECT-OPTIONS: s_contr FOR <fs_pod_data>-vertrag.
SELECTION-SCREEN END OF BLOCK sel_contr.
SELECTION-SCREEN END OF BLOCK sel.

SELECTION-SCREEN BEGIN OF BLOCK change WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_test RADIOBUTTON GROUP corr.
SELECTION-SCREEN COMMENT 5(79) TEXT-100 FOR FIELD p_test.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_f001 RADIOBUTTON GROUP corr.
SELECTION-SCREEN COMMENT 5(79) TEXT-101 FOR FIELD p_f001.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK change.

SELECTION-SCREEN BEGIN OF BLOCK out WITH FRAME TITLE TEXT-002.
PARAMETERS: p_all RADIOBUTTON GROUP radi,
            p_nok RADIOBUTTON GROUP radi.
SELECTION-SCREEN END OF BLOCK out.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF p_sel_ui = abap_true.
      IF screen-name = 'S_EXT_UI-LOW' OR screen-name = 'S_EXT_UI-HIGH' OR
         screen-name = 'S_SERV-LOW'   OR screen-name = 'S_SERV-HIGH'   OR
         screen-name = 'S_ANLART-LOW' OR screen-name = 'S_ANLART-HIGH' OR
         screen-name = 'S_DATE-LOW' OR screen-name = 'S_DATE-HIGH'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
      IF screen-name = 'S_CONTR-LOW' OR screen-name = 'S_CONTR-HIGH'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF p_sel_co = abap_true.
      IF screen-name = 'S_EXT_UI-LOW' OR screen-name = 'S_EXT_UI-HIGH' OR
         screen-name = 'S_SERV-LOW'   OR screen-name = 'S_SERV-HIGH'   OR
         screen-name = 'S_ANLART-LOW' OR screen-name = 'S_ANLART-HIGH' OR
         screen-name = 'S_DATE-LOW' OR screen-name = 'S_DATE-HIGH'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
      IF screen-name = 'S_CONTR-LOW' OR screen-name = 'S_CONTR-HIGH'.
        screen-input = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

INITIALIZATION.
  PERFORM set_icon USING 'ICON_ALERT' CHANGING lv_icon_alert.
  PERFORM set_icon USING 'ICON_LED_RED' CHANGING lv_icon_red.
  PERFORM set_icon USING 'ICON_LED_GREEN' CHANGING lv_icon_green.
  PERFORM set_icon USING 'ICON_LED_INACTIVE' CHANGING lv_icon_inactive.

START-OF-SELECTION.
***** MeLo / MaLo Konstrukte ergänzen *************************************************************

*>>> !!!!! ToDo: Das ist nicht wirklich richtig und sollte ohne Z-Objekte umgetzt werden
  SELECT * FROM euitrans WHERE ext_ui IN @s_ext_ui AND datefrom <= @sy-datum AND dateto >= @sy-datum INTO TABLE @DATA(lt_euitrans).
  LOOP AT lt_euitrans ASSIGNING FIELD-SYMBOL(<ls_euitrans>).
    DATA(lt_int_ui) = zcl_isu_utility=>get_all_related_int_ui( <ls_euitrans>-int_ui ).
    LOOP AT lt_int_ui ASSIGNING FIELD-SYMBOL(<lv_int_ui>).
      SELECT * FROM euitrans WHERE int_ui = @<lv_int_ui> AND datefrom <= @sy-datum AND dateto >= @sy-datum INTO TABLE @DATA(lt_euitrans_2).
      LOOP AT lt_euitrans_2 ASSIGNING FIELD-SYMBOL(<ls_euitrans_2>).
        APPEND INITIAL LINE TO s_ext_ui ASSIGNING FIELD-SYMBOL(<ls_ext_ui>).
        <ls_ext_ui>-sign   = 'I'.
        <ls_ext_ui>-option = 'EQ'.
        <ls_ext_ui>-low    = <ls_euitrans_2>-ext_ui.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
*<<< !!!!! ToDo

***** Relevante Anlagen / Zählpunkte ermitteln ****************************************************
  IF p_sel_ui = abap_true.
    SELECT et~int_ui et~ext_ui ei~anlage ea~service ea~sparte
      INTO CORRESPONDING FIELDS OF TABLE lt_start_data
      FROM euitrans AS et
      INNER JOIN euiinstln AS ei ON ei~int_ui EQ et~int_ui AND ei~dateto EQ c_date_unendlich
      INNER JOIN eanl AS ea ON ea~anlage EQ ei~anlage
        WHERE et~ext_ui IN s_ext_ui AND et~dateto EQ c_date_unendlich AND et~loevm EQ space
          AND ei~loevm EQ space AND ea~service IN s_serv AND ea~anlart IN s_anlart AND ea~loevm EQ space.
  ELSEIF p_sel_co = abap_true.
    SELECT ei~int_ui ev~anlage ev~vertrag ev~einzdat ev~auszdat ev~sparte ev~vkonto ev~invoicing_party
      INTO CORRESPONDING FIELDS OF TABLE lt_start_data
      FROM ever AS ev
      INNER JOIN euiinstln AS ei ON ei~anlage EQ ev~anlage AND ei~dateto EQ c_date_unendlich
        WHERE ev~vertrag IN s_contr AND ev~loevm EQ space AND ei~loevm EQ space.
  ENDIF.

  SORT lt_start_data BY int_ui.
  DELETE ADJACENT DUPLICATES FROM lt_start_data COMPARING ALL FIELDS.

*>>> ToDo: TRY CATCH
  GET BADI lr_badi_data_access.
*<<< ToDo

***** Versorgungsszenarien prüfen *****************************************************************
  LOOP AT lt_start_data ASSIGNING <fs_pod_data>.

*>>> ToDo
    CALL BADI lr_badi_data_access->is_pod_malo
      EXPORTING
        iv_int_ui      = <fs_pod_data>-int_ui
      RECEIVING
        rv_pod_is_malo = DATA(lv_pod_is_malo).
    IF lv_pod_is_malo = abap_false.
      CONTINUE.
    ENDIF.
*<<< ToDo

*---- Ermitteln des Versorgunsszenarios zum INT_UI ------------------------------------------------
    CALL METHOD cl_isu_ide_drgscen_ana_pod=>create
      EXPORTING
        im_int_ui           = <fs_pod_data>-int_ui
        im_bypassing_buffer = space
        im_anamode          = '1'
      IMPORTING
        ex_ref              = lr_drgscen
      EXCEPTIONS
        general_fault       = 1
        OTHERS              = 2.
    IF sy-subrc <> 0.
      ls_out-status = lv_icon_red.
      ls_out-text   = 'Versorgungsszenario konnte nicht ermittelt werden'.
      APPEND ls_out TO lt_out.
      CONTINUE.
    ENDIF.

*---- Fehler ermitteln ----------------------------------------------------------------------------
    LOOP AT lr_drgscen->iscenario ASSIGNING <fs_scenario>.
      "Bei ZP-Auswahl: VSZ muss im angegebenen Zeitraum liegen.
      IF p_sel_ui = abap_true AND ( <fs_scenario>-datefrom > s_date-high OR <fs_scenario>-dateto < s_date-low ).
        CONTINUE.
      ENDIF.

      "Bei Vertrag: Nur ein VSZ zum ZP soll betrachtet werden.
      IF p_sel_co = abap_true.
        READ TABLE <fs_scenario>-icontr ASSIGNING <fs_contr> INDEX 1.
        IF <fs_contr> IS NOT ASSIGNED.
          CONTINUE.
        ELSEIF <fs_contr>-vertrag <> <fs_pod_data>-vertrag.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF <fs_scenario>-iserv IS NOT INITIAL OR <fs_scenario>-icontr IS NOT INITIAL. "Nur wenn am VSZ an der Anlage auch etwas steht.
        <fs_pod_data>-dateto = <fs_scenario>-dateto.
        <fs_pod_data>-scenario = <fs_scenario>-scenario.

        IF <fs_pod_data>-scenario IS INITIAL.

          "Fehler 001: Nur Vertrag, keine Services
          IF <fs_scenario>-icontr IS NOT INITIAL AND <fs_scenario>-iserv IS INITIAL.
            IF p_sel_ui = abap_true. "Nachlesen Vertrag
              READ TABLE <fs_scenario>-icontr ASSIGNING <fs_contr> INDEX 1.
              IF sy-subrc = 0.
                SELECT SINGLE * FROM ever INTO ls_ever WHERE vertrag = <fs_contr>-vertrag.
                <fs_pod_data>-vkonto          = ls_ever-vkonto.
                <fs_pod_data>-einzdat         = ls_ever-einzdat.
                <fs_pod_data>-auszdat         = ls_ever-auszdat.
                <fs_pod_data>-invoicing_party = ls_ever-invoicing_party.
              ENDIF.
            ENDIF.

            <fs_pod_data>-error_no = '001'.
            <fs_pod_data>-text    = 'Versorgungsszenario undefiniert, nur Vertrag und keine Services'.
            APPEND <fs_pod_data> TO lt_analyse_data.
            CONTINUE.
          ENDIF.

          "Weitere Fehler (900): Versorgungsszenario undefiniert auf Grund anderer Fehler
          <fs_pod_data>-error_no = '900'.
          LOOP AT <fs_scenario>-iserv ASSIGNING <fs_service>.
            AT FIRST.
              CONCATENATE <fs_pod_data>-text <fs_service>-serviceid INTO <fs_pod_data>-text SEPARATED BY space.
              CONTINUE.
            ENDAT.
            CONCATENATE <fs_pod_data>-text ',' <fs_service>-serviceid INTO <fs_pod_data>-text SEPARATED BY space.
          ENDLOOP.
          APPEND <fs_pod_data> TO lt_analyse_data.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      <fs_pod_data>-error_no = '800'.
      APPEND <fs_pod_data> TO lt_analyse_data.
    ENDIF.
    IF p_all = abap_true AND <fs_pod_data>-error_no IS INITIAL.
      <fs_pod_data>-error_no = '000'.
      APPEND <fs_pod_data> TO lt_analyse_data.
    ENDIF.
    DELETE lt_start_data.
  ENDLOOP.

***** Ausgabe erstellen und ggf. Korrektur durchführen ********************************************
  CLEAR: lt_out.

  LOOP AT lt_analyse_data ASSIGNING <fs_pod_data>.
    CLEAR: ls_out.
    MOVE-CORRESPONDING <fs_pod_data> TO ls_out.
    CASE ls_out-error_no.
      WHEN '001'.
        IF p_f001 = abap_true.
          PERFORM process_scenario CHANGING <fs_pod_data>.
          IF <fs_pod_data>-error_no = '000'.
            ls_out-status = lv_icon_green.
            ls_out-text   = 'Korrektur durchgeführt: Versorgungsszenarios an MaLo und MeLo mit Standard MSB generiert'.
          ELSE.
            ls_out-status = lv_icon_red.
            ls_out-text   = 'Fehler: Versorgungsszenario konnte nicht generiert werden'.
          ENDIF.
        ELSE.
          ls_out-status = lv_icon_red.
          ls_out-text   = <fs_pod_data>-text.
        ENDIF.
      WHEN '800'.
        ls_out-status = lv_icon_inactive.
        CONCATENATE 'Kein Vertrag an der Anlage' <fs_pod_data>-text INTO ls_out-text SEPARATED BY space.
      WHEN '900'.
        ls_out-status = lv_icon_red.
        CONCATENATE 'Versorgungsszenario undefiniert, Services:' <fs_pod_data>-text INTO ls_out-text SEPARATED BY space.
      WHEN '000'.
        ls_out-status = lv_icon_green.
      WHEN OTHERS.
        ls_out-status = lv_icon_alert.
    ENDCASE.

    APPEND ls_out TO lt_out.
  ENDLOOP.

  IF lt_out IS INITIAL.
    CLEAR: ls_out.
    ls_out-status = lv_icon_inactive.
    ls_out-text   = 'Es konnten keine Daten ermittelt werden!'.
    APPEND ls_out TO lt_out.
  ENDIF.

***** Liste anzeigen ******************************************************************************
  PERFORM alv_list.

*&---------------------------------------------------------------------*
*&      Form  status_icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ICON       text
*      -->P_ICON_NAME  text
*----------------------------------------------------------------------*
FORM set_icon USING    p_icon_name TYPE iconname
              CHANGING p_icon      TYPE icon_d.
  SELECT SINGLE id FROM icon INTO p_icon WHERE name = p_icon_name.
ENDFORM.                    "status_icon

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
* implement the events for handling the events of cl_salv_table
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.

ENDCLASS.                    "lcl_handle_events DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.

  METHOD on_double_click.
    FIELD-SYMBOLS: <fs_out> TYPE ts_out.

    READ TABLE lt_out ASSIGNING <fs_out> INDEX row.

    SET PARAMETER ID: 'ANL' FIELD <fs_out>-anlage.

    CALL TRANSACTION 'ES32'.
  ENDMETHOD.                    "on_double_click

ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


*&---------------------------------------------------------------------*
*&      Form  alv_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM alv_list.
  DATA:
    lr_table            TYPE REF TO cl_salv_table,
    lr_columns          TYPE REF TO cl_salv_columns_table,
    lr_functions        TYPE REF TO cl_salv_functions_list,
    lr_display_settings TYPE REF TO cl_salv_display_settings,
    lr_events           TYPE REF TO cl_salv_events_table,
    lr_handle_events    TYPE REF TO lcl_handle_events,
    lt_columns          TYPE salv_t_column_ref.

* Erzeugen der ALV Instanz Fullscreen
  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = lr_table
        CHANGING
          t_table      = lt_out.
    CATCH cx_salv_msg .
  ENDTRY.

* Holen der Spaltenatribute - setzen optimale Breite
  lr_columns = lr_table->get_columns( ).
  lt_columns = lr_columns->get( ).
  lr_columns->set_optimize( ).

* Setzen des gesamten Menues
  lr_functions = lr_table->get_functions( ).
  lr_functions->set_all( ).

* register to the events
  lr_events = lr_table->get_event( ).
  CREATE OBJECT lr_handle_events.
  SET HANDLER lr_handle_events->on_double_click FOR lr_events.

* Display settings
  lr_display_settings = lr_table->get_display_settings( ).
  lr_display_settings->set_striped_pattern( abap_true ).

* Titel setting
  IF p_all = abap_true.
    lr_display_settings->set_list_header( 'Alle Versorgungsszenarios' ).
  ELSEIF p_nok = abap_true.
    lr_display_settings->set_list_header( 'Nur fehlerhafte Versorgungsszenarios' ).
  ENDIF.

* Ausgabe der Liste
  CALL METHOD lr_table->display.

ENDFORM.                    "alv_list
*&---------------------------------------------------------------------*
*&      Form  PROCESS_SCENARIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<FS_POD_DATA>  text
*----------------------------------------------------------------------*
FORM process_scenario CHANGING is_pod_data TYPE ts_pod_data.

  DATA: lr_badi_data_access    TYPE REF TO /idxgc/badi_data_access,
        lr_badi_data_access_gl TYPE REF TO /idxgl/badi_data_access,
        lt_servprov            TYPE iederegservprov,
        ls_servprov            TYPE eservprov,
        ls_euigrid             TYPE euigrid,
        ls_egridh              TYPE egridh,
        ls_fkkvkp              TYPE fkkvkp,
        lv_scenario            TYPE e_deregscenario.

  FIELD-SYMBOLS: <fs_servprov> TYPE ederegservprov.

***** Zusätzliche Daten ermitteln *****************************************************************

*---- MSB nachermitteln, falls nicht schon am Vertrag, VNB und Lieferant ermitteln ----------------
  SELECT SINGLE * FROM euigrid INTO ls_euigrid WHERE int_ui = is_pod_data-int_ui AND datefrom <= is_pod_data-einzdat AND dateto >= is_pod_data-einzdat.
  SELECT SINGLE * FROM egridh INTO ls_egridh WHERE grid_id = ls_euigrid-grid_id AND ab <= is_pod_data-einzdat AND bis >= is_pod_data-einzdat.
  IF ls_egridh-distributor IS INITIAL.
    RETURN.
  ENDIF.

  IF is_pod_data-servprov_mos IS INITIAL.
    GET BADI lr_badi_data_access FILTERS iv_proc_cluster = ''.

    TRY.
        CALL BADI lr_badi_data_access->get_default_sp
          EXPORTING
            iv_distributor = ls_egridh-distributor
            iv_valid_date  = sy-datum
          IMPORTING
            ev_default_mos = DATA(lv_default_mos).
      CATCH /idxgc/cx_utility_error.
        RETURN.
    ENDTRY.

    IF <fs_pod_data>-servprov_mos IS INITIAL.
      <fs_pod_data>-servprov_mos = lv_default_mos.
    ENDIF.
  ENDIF.

  APPEND INITIAL LINE TO lt_servprov ASSIGNING <fs_servprov>.
  <fs_servprov>-serviceid = is_pod_data-invoicing_party.
  APPEND INITIAL LINE TO lt_servprov ASSIGNING <fs_servprov>.
  <fs_servprov>-serviceid = is_pod_data-servprov_mos.
  APPEND INITIAL LINE TO lt_servprov ASSIGNING <fs_servprov>.
  <fs_servprov>-serviceid = ls_egridh-distributor.

*>>>!!!!! ToDo: Anpassung ÜNB -> Funktioniert aktuell nur für Strom und den einen ÜNB
  APPEND INITIAL LINE TO lt_servprov ASSIGNING <fs_servprov>.
  <fs_servprov>-serviceid = 'ÜNB_S_AMP'. "Aktuell nur
*<<<!!!!! ToDo: Anpassung ÜNB

  LOOP AT lt_servprov ASSIGNING <fs_servprov>.
    CALL FUNCTION 'ISU_DB_ESERVPROV_SINGLE'
      EXPORTING
        x_serviceid = <fs_servprov>-serviceid
      IMPORTING
        y_eservprov = ls_servprov
      EXCEPTIONS
        not_found   = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    MOVE-CORRESPONDING ls_servprov TO <fs_servprov>.
  ENDLOOP.

*---- Versorgungsszenario ermitteln ---------------------------------------------------------------
  CASE is_pod_data-sparte.
    WHEN '01'.
      lv_scenario = '910'.
    WHEN '02'.
      lv_scenario = '920'.
  ENDCASE.

*---- Geschäftpartner ermitteln -------------------------------------------------------------------
  SELECT SINGLE * FROM fkkvkp INTO ls_fkkvkp WHERE vkont = is_pod_data-vkonto.
  IF ls_fkkvkp-gpart IS INITIAL.
    RETURN.
  ENDIF.

***** Versorgungsszenario generieren **************************************************************
  CALL METHOD cl_isu_ide_drgscen_gen_pod=>process
    EXPORTING
      im_int_ui          = is_pod_data-int_ui
      im_scenario        = lv_scenario
      im_datefrom        = is_pod_data-einzdat
      im_services_dateto = is_pod_data-auszdat
      im_iserviceid      = lt_servprov
      im_gpart           = ls_fkkvkp-gpart
      im_only_services   = abap_true
      im_activity_create = '060'
      im_activity_stop   = '060'
      im_activity_cancel = '060'
      im_activity_change = '060'
      im_activity_shift  = '060'
      im_status_failed   = '02'
      im_status_done     = '01'
      im_no_dialog       = abap_true
      im_commit_log      = abap_true
    EXCEPTIONS
      OTHERS             = 1.
  IF sy-subrc = 0.
    is_pod_data-error_no = '000'.
  ENDIF.

*>>>ToDo: Umsetzung prüfen
*>>> ToDo: TRY CATCH
  GET BADI lr_badi_data_access_gl.
*<<< ToDo

  DATA(lt_int_ui) = zcl_isu_utility=>get_all_related_int_ui( is_pod_data-int_ui ).
  LOOP AT lt_int_ui ASSIGNING FIELD-SYMBOL(<lv_int_ui>).
    CALL BADI lr_badi_data_access_gl->is_pod_melo
      EXPORTING
        iv_int_ui      = <lv_int_ui>
      RECEIVING
        rv_pod_is_melo = DATA(lv_pod_is_melo).
    IF lv_pod_is_melo = abap_false.
      CONTINUE.
    ELSE.
      CASE is_pod_data-sparte.
        WHEN '01'.
          lv_scenario = '911'.

          CALL METHOD cl_isu_ide_drgscen_gen_pod=>process
            EXPORTING
              im_int_ui          = <lv_int_ui>
              im_scenario        = lv_scenario
              im_datefrom        = is_pod_data-einzdat
              im_services_dateto = is_pod_data-auszdat
              im_iserviceid      = lt_servprov
              im_gpart           = ls_fkkvkp-gpart
              im_only_services   = abap_true
              im_activity_create = '060'
              im_activity_stop   = '060'
              im_activity_cancel = '060'
              im_activity_change = '060'
              im_activity_shift  = '060'
              im_status_failed   = '02'
              im_status_done     = '01'
              im_no_dialog       = abap_true
              im_commit_log      = abap_true
              im_force_scen_gen  = abap_true
            EXCEPTIONS
              OTHERS             = 1.
          IF sy-subrc = 0.
            is_pod_data-error_no = '000'.
          ENDIF.
        WHEN '02'.
          "lv_scenario = '920'.
      ENDCASE.
    ENDIF.

  ENDLOOP.



*>>>ToDo

ENDFORM.
