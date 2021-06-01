*&---------------------------------------------------------------------*
*& Report  Z_AGC_ADD_SERVPROV_DEXPROC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT z_agc_add_servprov_dexproc.
***************************************************************************************************
* THIMEL.R, 20150827, Programm zum Hinzufügen von DA-Prozessen zum Serviceanbieter
***************************************************************************************************
TYPES: BEGIN OF ty_display_alv,
         servprov   TYPE serviceid,
         dexproc    TYPE e_dexproc,
         error_text TYPE text256,
         alv_color  TYPE lvc_t_scol,
       END OF ty_display_alv.

DATA: lt_servprov              TYPE TABLE OF eservprov,
      lt_servprov_own          TYPE TABLE OF eservprov,
      lt_dexproc               TYPE TABLE OF edexproc,
      ls_dexproct              TYPE          edexproct,
      lt_dexdefservprov        TYPE TABLE OF edexdefservprov,
      ls_edexbasicproc         TYPE          edexbasicproc,
      ls_edexbasicprocfor      TYPE          edexbasicprocfor,
      lv_basicproc             TYPE          edexproc-dexbasicproc,
      lv_dexdirection          TYPE          edexbasicproc-dexdirection,
      ls_dexdefservprov        TYPE          edexdefservprov,
      ls_dexcommformat         TYPE          edexcommformat,
      ls_dexcommformatt        TYPE          edexcommformatt,
      ls_dexcommformmail       TYPE          edexcommformmail,
      ls_dexcommmailaddr       TYPE          edexcommmailaddr,
      lt_edexdefservprov_work  TYPE TABLE OF edexdefservprov,
      ls_edexdefservprov_work  TYPE          edexdefservprov,
      ls_edexcommformmail_work TYPE          edexcommformmail,
      ls_edexcommmailaddr_from TYPE          edexcommmailaddr,
      ls_edexcommmailaddr_to   TYPE          edexcommmailaddr,
      ls_edexcommmailaddr_cc   TYPE          edexcommmailaddr,
      ls_edexcommmailaddr_bcc  TYPE          edexcommmailaddr,
      lr_table                 TYPE REF TO   cl_salv_table,
      lr_grid                  TYPE REF TO   cl_salv_form_layout_grid,
      lr_functions             TYPE REF TO   cl_salv_functions_list,
      lr_columns               TYPE REF TO   cl_salv_columns_table,
      lt_display_alv           TYPE TABLE OF ty_display_alv,
      lt_color_alv_green       TYPE          lvc_t_scol,
      lt_color_alv_red         TYPE          lvc_t_scol,
      ls_color_alv             TYPE          lvc_s_scol,
      lv_counter_dexproc       TYPE          n,
      lv_intcode               TYPE          intcode.

FIELD-SYMBOLS: <fs_servprov>     TYPE eservprov,
               <fs_servprov_own> TYPE eservprov,
               <fs_dexproc>      TYPE edexproc,
               <fs_display_alv>  TYPE ty_display_alv.

SELECT-OPTIONS: so_srvid FOR <fs_servprov>-serviceid,
                so_dxprc FOR <fs_dexproc>-dexproc.

PARAMETERS:     p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.
  ls_color_alv-color-int = 1.
  ls_color_alv-color-col = 5.

  ls_color_alv-fname = 'SERVPROV'.
  APPEND ls_color_alv TO lt_color_alv_green.
  ls_color_alv-fname = 'DEXPROC'.
  APPEND ls_color_alv TO lt_color_alv_green.
  ls_color_alv-fname = 'ERROR_TEXT'.
  APPEND ls_color_alv TO lt_color_alv_green.

  ls_color_alv-color-col = 6.

  ls_color_alv-fname = 'SERVPROV'.
  APPEND ls_color_alv TO lt_color_alv_red.
  ls_color_alv-fname = 'DEXPROC'.
  APPEND ls_color_alv TO lt_color_alv_red.
  ls_color_alv-fname = 'ERROR_TEXT'.
  APPEND ls_color_alv TO lt_color_alv_red.

  SELECT * FROM eservprov INTO TABLE lt_servprov WHERE serviceid IN so_srvid AND own_log_sys = abap_false.
  SELECT * FROM edexproc INTO TABLE lt_dexproc WHERE dexproc IN so_dxprc.
  SELECT * FROM eservprov INTO TABLE lt_servprov_own WHERE own_log_sys = abap_true.

  LOOP AT lt_servprov ASSIGNING <fs_servprov>.
    CLEAR: lv_counter_dexproc.

* Serviceanbieter sperren um Update durchzuführen
    CALL FUNCTION 'ENQUEUE_E_EDMIDE_SERVPRO'
      EXPORTING
        mode_eservprov = 'E'
        mandt          = sy-mandt
        serviceid      = <fs_servprov>-serviceid
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      "Error
    ENDIF.

* Kommunikationsdatenermittlung initialisieren
    CLEAR: ls_edexdefservprov_work,
           ls_edexcommformmail_work,
           ls_edexcommmailaddr_from,
           ls_edexcommmailaddr_to,
           ls_edexcommmailaddr_cc,
           ls_edexcommmailaddr_bcc.

* Kommunikationsdaten des Serviceanbieter ermitteln
    SELECT * FROM edexdefservprov INTO TABLE lt_edexdefservprov_work
      WHERE dexservprov = <fs_servprov>-serviceid
      AND dexproc LIKE '%EXP%'
      AND datefrom LE sy-datum
      AND dateto GE sy-datum.

    LOOP AT lt_edexdefservprov_work INTO ls_edexdefservprov_work WHERE dexcommformid IS NOT INITIAL.
      lv_intcode = /adesso/cl_mdc_utility=>get_intcode_servprov( iv_serviceid = ls_edexdefservprov_work-dexservprovself ).
      IF lv_intcode <> '04'.
        SELECT SINGLE * FROM edexcommformmail INTO ls_edexcommformmail_work
          WHERE dexcommformid = ls_edexdefservprov_work-dexcommformid.
        IF NOT ls_edexcommformmail_work-dexcommfrom IS INITIAL.
          SELECT SINGLE * FROM edexcommmailaddr INTO ls_edexcommmailaddr_from
            WHERE dexcommaddrid = ls_edexcommformmail_work-dexcommfrom.
        ENDIF.
        IF NOT ls_edexcommformmail_work-dexcommto IS INITIAL.
          SELECT SINGLE * FROM edexcommmailaddr INTO ls_edexcommmailaddr_to
            WHERE dexcommaddrid = ls_edexcommformmail_work-dexcommto.
        ENDIF.
        IF NOT ls_edexcommformmail_work-dexcommcc IS INITIAL.
          SELECT SINGLE * FROM edexcommmailaddr INTO ls_edexcommmailaddr_cc
            WHERE dexcommaddrid = ls_edexcommformmail_work-dexcommcc.
        ENDIF.
        IF NOT ls_edexcommformmail_work-dexcommbcc IS INITIAL.
          SELECT SINGLE * FROM edexcommmailaddr INTO ls_edexcommmailaddr_bcc
            WHERE dexcommaddrid = ls_edexcommformmail_work-dexcommbcc.
        ENDIF.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
      <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
      <fs_display_alv>-error_text = 'Fehler beim Ermitteln der Email-Adresse zum Serviceanbieter.'.
      <fs_display_alv>-alv_color  = lt_color_alv_red.
      CONTINUE.
    ENDIF.


    LOOP AT lt_dexproc ASSIGNING <fs_dexproc> WHERE dexserviceuse = <fs_servprov>-service.
      lv_counter_dexproc = lv_counter_dexproc + 1.
      CLEAR: ls_dexdefservprov, ls_dexcommformat, ls_dexcommformatt, ls_dexcommformmail, ls_dexcommmailaddr.

      ls_dexdefservprov-dexproc     = <fs_dexproc>-dexproc.
      ls_dexdefservprov-dexservprov = <fs_servprov>-serviceid.
      READ TABLE lt_servprov_own ASSIGNING <fs_servprov_own> WITH KEY service = <fs_dexproc>-dexserviceself.
      IF <fs_servprov_own> IS ASSIGNED.
        ls_dexdefservprov-dexservprovself = <fs_servprov_own>-serviceid.
      ELSE.
        APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
        <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
        <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
        <fs_display_alv>-error_text = 'Fehler beim Ermitteln des eigenen Serviceanbieters'.
        <fs_display_alv>-alv_color  = lt_color_alv_red.
        CONTINUE.
      ENDIF.

* Richtung des DA-Prozesses ermitteln
      CLEAR lv_dexdirection.
      SELECT SINGLE dexdirection FROM edexbasicproc INTO lv_dexdirection
        WHERE dexbasicproc = <fs_dexproc>-dexbasicproc.

* Prüfen, ob der Prozess vorhanden ist.
      CALL METHOD cl_isu_datex_definition=>select_sp
        EXPORTING
          im_dexservprov     = ls_dexdefservprov-dexservprov
          im_dexproc         = ls_dexdefservprov-dexproc
          im_dexservprovself = ls_dexdefservprov-dexservprovself
        IMPORTING
          ext_dexdefservprov = lt_dexdefservprov
        EXCEPTIONS
          not_found          = 1
          OTHERS             = 2.
      IF sy-subrc = 1.
        CLEAR ls_edexbasicprocfor.
        SELECT SINGLE * FROM edexbasicprocfor INTO ls_edexbasicprocfor
          WHERE dexbasicproc = <fs_dexproc>-dexbasicproc
          AND dexformat LIKE 'IDXGC%'.

        ls_dexdefservprov-dexformat = ls_edexbasicprocfor-dexformat.
        ls_dexdefservprov-datefrom = '20150701'.
        ls_dexdefservprov-dateto = '99991231'.
        ls_dexdefservprov-dexnoduecontr = abap_true.
        ls_dexdefservprov-dexidocsend = 'EINZELN'.

        IF lv_dexdirection = '2'.
          CALL FUNCTION 'GUID_CREATE' IMPORTING ev_guid_22 = ls_dexdefservprov-dexcommformid.
          ls_dexcommformat-dexcommformid = ls_dexdefservprov-dexcommformid.
          ls_dexcommformat-dexcommtype = 'EMAIL'.
          ls_dexcommformat-dexcommform = 'UNEDI'.
        ENDIF.

        IF p_test IS INITIAL.
          INSERT edexdefservprov FROM ls_dexdefservprov.
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
            <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
            <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
            <fs_display_alv>-error_text = 'Fehler beim Schreiben in Tabelle EDEXDEFSERVPROV'.
            <fs_display_alv>-alv_color  = lt_color_alv_red.
            ROLLBACK WORK.
            CONTINUE.
          ENDIF.

          IF lv_dexdirection = '2'.
            INSERT edexcommformat FROM ls_dexcommformat.
            IF sy-subrc <> 0.
              APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
              <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
              <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
              <fs_display_alv>-error_text = 'Fehler beim Schreiben in Tabelle EDEXCOMMFORMAT'.
              <fs_display_alv>-alv_color  = lt_color_alv_red.
              ROLLBACK WORK.
              CONTINUE.
            ELSE.
              ls_dexcommformatt-dexcommformid = ls_dexdefservprov-dexcommformid.
              ls_dexcommformatt-spras         = 'DE'.
              SELECT SINGLE * FROM edexproct INTO ls_dexproct WHERE dexproc = <fs_dexproc>-dexproc AND spras = 'DE'.
              ls_dexcommformatt-dexcommformtext = ls_dexproct-dexproctxt.

              INSERT edexcommformatt FROM ls_dexcommformatt.
              IF sy-subrc NE 0.
                APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
                <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
                <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
                <fs_display_alv>-error_text = 'Fehler beim Schreiben in Tabelle EDEXCOMMFORMATT'.
                <fs_display_alv>-alv_color  = lt_color_alv_red.
                ROLLBACK WORK.
                CONTINUE.
              ELSE.

                IF NOT ls_edexcommmailaddr_from IS INITIAL.
                  CALL FUNCTION 'GUID_CREATE' IMPORTING ev_guid_22 = ls_dexcommformmail-dexcommfrom.
                  ls_dexcommmailaddr-dexcommaddrid = ls_dexcommformmail-dexcommfrom.
                  ls_dexcommmailaddr-lfdnr = '001'.
                  ls_dexcommmailaddr-dexcommemail = ls_edexcommmailaddr_from-dexcommemail.
                  INSERT edexcommmailaddr FROM ls_dexcommmailaddr.
                  IF sy-subrc NE 0.
                    APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
                    <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
                    <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
                    <fs_display_alv>-error_text = 'Fehler beim Schreiben in Tabelle EDEXCOMMMAILADDR'.
                    <fs_display_alv>-alv_color  = lt_color_alv_red.
                    ROLLBACK WORK.
                    CONTINUE.
                  ENDIF.
                ENDIF.

                IF NOT ls_edexcommmailaddr_to IS INITIAL.
                  CALL FUNCTION 'GUID_CREATE' IMPORTING ev_guid_22 = ls_dexcommformmail-dexcommto.
                  ls_dexcommmailaddr-dexcommaddrid = ls_dexcommformmail-dexcommto.
                  ls_dexcommmailaddr-lfdnr = '001'.
                  ls_dexcommmailaddr-dexcommemail = ls_edexcommmailaddr_to-dexcommemail.
                  INSERT edexcommmailaddr FROM ls_dexcommmailaddr.
                  IF sy-subrc NE 0.
                    APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
                    <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
                    <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
                    <fs_display_alv>-error_text = 'Fehler beim Schreiben in Tabelle EDEXCOMMMAILADDR'.
                    <fs_display_alv>-alv_color  = lt_color_alv_red.
                    ROLLBACK WORK.
                    CONTINUE.
                  ENDIF.
                ENDIF.

                IF NOT ls_edexcommmailaddr_cc IS INITIAL.
                  CALL FUNCTION 'GUID_CREATE' IMPORTING ev_guid_22 = ls_dexcommformmail-dexcommcc.
                  ls_dexcommmailaddr-dexcommaddrid = ls_dexcommformmail-dexcommcc.
                  ls_dexcommmailaddr-lfdnr = '001'.
                  ls_dexcommmailaddr-dexcommemail = ls_edexcommmailaddr_cc-dexcommemail.
                  INSERT edexcommmailaddr FROM ls_dexcommmailaddr.
                  IF sy-subrc NE 0.
                    APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
                    <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
                    <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
                    <fs_display_alv>-error_text = 'Fehler beim Schreiben in Tabelle EDEXCOMMMAILADDR'.
                    <fs_display_alv>-alv_color  = lt_color_alv_red.
                    ROLLBACK WORK.
                    CONTINUE.
                  ENDIF.
                ENDIF.

                IF NOT ls_edexcommmailaddr_bcc IS INITIAL.
                  CALL FUNCTION 'GUID_CREATE' IMPORTING ev_guid_22 = ls_dexcommformmail-dexcommbcc.
                  ls_dexcommmailaddr-dexcommaddrid = ls_dexcommformmail-dexcommbcc.
                  ls_dexcommmailaddr-lfdnr = '001'.
                  ls_dexcommmailaddr-dexcommemail = ls_edexcommmailaddr_bcc-dexcommemail.
                  INSERT edexcommmailaddr FROM ls_dexcommmailaddr.
                  IF sy-subrc NE 0.
                    APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
                    <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
                    <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
                    <fs_display_alv>-error_text = 'Fehler beim Schreiben in Tabelle EDEXCOMMMAILADDR'.
                    <fs_display_alv>-alv_color  = lt_color_alv_red.
                    ROLLBACK WORK.
                    CONTINUE.
                  ENDIF.
                ENDIF.

                IF ls_dexcommformmail-dexcommfrom IS NOT INITIAL OR
                  ls_dexcommformmail-dexcommto    IS NOT INITIAL OR
                  ls_dexcommformmail-dexcommcc    IS NOT INITIAL OR
                  ls_dexcommformmail-dexcommbcc   IS NOT INITIAL.

                  ls_dexcommformmail-dexcommformid = ls_dexdefservprov-dexcommformid.
                  INSERT edexcommformmail FROM ls_dexcommformmail.
                  IF sy-subrc NE 0.
                    APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
                    <fs_display_alv>-servprov   = <fs_servprov>-serviceid.
                    <fs_display_alv>-dexproc    = <fs_dexproc>-dexproc.
                    <fs_display_alv>-error_text = 'Fehler beim Schreiben in Tabelle EDEXCOMMFORMMAIL'.
                    <fs_display_alv>-alv_color  = lt_color_alv_red.
                    ROLLBACK WORK.
                    CONTINUE.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
* Änderungen verbuchen:
          COMMIT WORK.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Serviceanbieter entsperren nach Update
    CALL FUNCTION 'DEQUEUE_E_EDMIDE_SERVPRO'
      EXPORTING
        mode_eservprov = 'E'
        mandt          = sy-mandt
        serviceid      = <fs_servprov>-serviceid.

    APPEND INITIAL LINE TO lt_display_alv ASSIGNING <fs_display_alv>.
    <fs_display_alv>-servprov = <fs_servprov>-serviceid.
    CONCATENATE lv_counter_dexproc 'DA-Prozesse erfolgreich angelegt.' INTO <fs_display_alv>-error_text SEPARATED BY space.
    <fs_display_alv>-alv_color = lt_color_alv_green.
  ENDLOOP.

  CREATE OBJECT lr_grid.
  lr_grid->create_label( text = 'Protokoll zum Einfügen der DA-Prozesse an den Serviceanbietern.' row = 1 column = 1 ).
  lr_grid->create_text( text = 'Zeilenfarbe ROT = Es ist ein Fehler aufgetreten.' row = 3 column = 1 ).
  lr_grid->create_text( text = 'Zeilenfarbe GRÜN = Anzahl der erfolgreich angelegten DA-Prozesse.' row = 4 column = 1 ).
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lr_table
    CHANGING
      t_table      = lt_display_alv.
  lr_columns = lr_table->get_columns( ).
  lr_columns->set_color_column( 'ALV_COLOR' ).

  CALL METHOD lr_table->get_functions
    RECEIVING
      value = lr_functions.
  lr_functions->set_all( ).

  lr_table->set_top_of_list( lr_grid ).
  lr_table->display( ).
