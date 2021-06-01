*&---------------------------------------------------------------------*
*& Report  ZAD_ENET_IMPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT /adesso/enet_import.

************************************************************************
* Typen:
************************************************************************
TYPES:
  BEGIN OF ts_daten_aus_datei,
    zeile TYPE string,       " %ANPASSEN% Zeilenbreite
  END OF ts_daten_aus_datei,

  tv_zeile    TYPE ts_daten_aus_datei,      " %ANPASSEN% Zeilenbreite
  tt_file_tab TYPE TABLE OF localfile.
DATA gv_cust TYPE /adesso/inv_cust.

************************************************************************
* Parameter:
************************************************************************
SELECTION-SCREEN: BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001. " %ANPASSEN% text-001

PARAMETERS:
  " Server oder Arbeitsplatz?
  p_work   TYPE check_box RADIOBUTTON GROUP in,  " Datei vom Arbeitsplatz laden
  p_serv   TYPE check_box RADIOBUTTON GROUP in,  " Datei vom Server laden
  p_mult   TYPE check_box,
  " Eingabedatei
  p_in_dat TYPE localfile OBLIGATORY,
  p_pcksz  TYPE i DEFAULT 1000.
SELECTION-SCREEN: END OF BLOCK b01.

************************************************************************
* AT SELECTION-SCREEN
************************************************************************
INITIALIZATION.
  FIELD-SYMBOLS <var>.
  DATA gv_type TYPE typ.
  SELECT  * FROM /adesso/inv_cust INTO gv_cust WHERE report = sy-repid.
    DESCRIBE  FIELD <var> TYPE gv_type.
    ASSIGN (gv_cust-field) TO <var>.
    IF sy-subrc = 0.
      <var> = gv_cust-value.
    ENDIF.
  ENDSELECT.
  " Auswahldialog für IN File
  " Wird aufgerufen wenn F4 oder der Button an dem Feld gedrückt wird
  DATA gt_files TYPE tt_file_tab.
  DATA gv_count TYPE i.
  DATA:gv_max_proz_c(200) TYPE c,
       gv_max_proz        TYPE i,
       gv_akt_proz        TYPE i.

  DATA: BEGIN OF status,
          btn_txt(75),
          curval(6)       TYPE n,
          maxval(6)       TYPE n,
          stat,
          text_1(75),
          text_2(6),
          text_3(75),
          title(75),
          winid(4),
          m_typ,
          popup_event(10),
          rwnid(4).
  DATA: END OF status.


  status-title  = 'Enet_upload'.

  DATA: popup_event_cancel(6) VALUE 'CANCEL'.
  DATA: stat_4 VALUE '3'.
  DATA: lv_wert(15) TYPE c.

* CLEAR status.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_in_dat.
  PERFORM dateiauswahl USING 'Eingabedatei auswählen:'      "#EC NOTEXT
                    CHANGING p_in_dat gt_files.

************************************************************************
* START-OF-SELECTION:
************************************************************************
START-OF-SELECTION.
  PERFORM start_of_selection.

************************************************************************
* Form:
************************************************************************

*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*  Hauptverarbeitung
*----------------------------------------------------------------------*
FORM start_of_selection.
  DATA lv_dauer   TYPE i.
  DATA lv_seconds TYPE p DECIMALS 2.


  DATA: lt_daten_aus_datei TYPE TABLE OF ts_daten_aus_datei,
        lv_datei           LIKE LINE OF gt_files,
        ls_files           TYPE LINE OF tt_file_tab.
  DATA lv_percentage TYPE p DECIMALS 2.
  " Einlesen der Datei, Server oder Arbeitsplatz
  "*********************************************
  CLEAR lv_dauer.
  GET RUN TIME FIELD lv_dauer.     "Messung wird gestartet

  REFRESH lt_daten_aus_datei.


  DATA: lt_files      TYPE TABLE OF file_info,
        ls_file_info  TYPE file_info,
        lv_dat_string TYPE string,
        lv_dirname    TYPE eps2filnam,
        lt_dir_list   TYPE TABLE OF eps2fili,
        ls_dir_list   TYPE eps2fili,
        lv_tabix      TYPE i,
        lv_count      TYPE i.
  lv_dat_string  = p_in_dat.

  SELECT SINGLE value FROM /adesso/inv_cust INTO gv_max_proz_c WHERE report = 'GLOBAL' AND field = 'GV_MAX_PROZ'.
  IF gv_max_proz_c IS INITIAL.
    gv_max_proz_c = '5'.
  ENDIF.
  gv_max_proz = gv_max_proz_c.

  IF p_serv = 'X'.
    lv_dirname = p_in_dat.
    CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
      EXPORTING
        iv_dir_name            = lv_dirname
*       FILE_MASK              = ' '
* IMPORTING
*       DIR_NAME               =
*       FILE_COUNTER           =
*       ERROR_COUNTER          =
      TABLES
        dir_list               = lt_dir_list
      EXCEPTIONS
        invalid_eps_subdir     = 1
        sapgparam_failed       = 2
        build_directory_failed = 3
        no_authorization       = 4
        read_directory_failed  = 5
        too_many_read_errors   = 6
        empty_directory_list   = 7
        OTHERS                 = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    LOOP AT lt_dir_list INTO ls_dir_list.
      lv_datei = ls_dir_list-name.
      IF lv_datei(2) = 'nn'.
        APPEND lv_datei TO gt_files.
      ENDIF.
    ENDLOOP.



  ELSE.
    cl_gui_frontend_services=>directory_list_files(
      EXPORTING
        directory                   = lv_dat_string
*      filter                      = '*.*'
*      files_only                  =
*      directories_only            =
      CHANGING
        file_table                  = lt_files
        count                       = lv_count
*    EXCEPTIONS
*      cntl_error                  = 1
*      directory_list_files_failed = 2
*      wrong_parameter             = 3
*      error_no_gui                = 4
*      not_supported_by_gui        = 5
*      others                      = 6
            ).

    LOOP AT lt_files INTO ls_file_info.
      lv_datei = ls_file_info-filename.
      IF lv_datei(2) = 'nn'.
        APPEND lv_datei TO gt_files.
      ENDIF.
    ENDLOOP.
  ENDIF.
  lv_count = lines( gt_files ).

  IF p_serv = 'X'." Server
    LOOP AT gt_files INTO ls_files.


      REFRESH lt_daten_aus_datei.
      PERFORM datei_lesen_server USING ls_files
                              CHANGING lt_daten_aus_datei.
      IF p_mult = ' '.
        PERFORM datei_bearbeiten USING lt_daten_aus_datei ls_files p_pcksz.
      ELSE.
        ADD 1 TO gv_akt_proz.
        WAIT UNTIL gv_akt_proz < gv_max_proz.
        CALL FUNCTION '/ADESSO/ENET_UPLOAD'
          STARTING NEW TASK ls_files
          DESTINATION IN GROUP DEFAULT
          PERFORMING ende_task ON END OF TASK
          EXPORTING
            files    = lt_daten_aus_datei
            filename = ls_files.

      ENDIF.
    ENDLOOP.
  ELSE." Arbeitsplatz
    LOOP AT gt_files INTO ls_files.
      lv_tabix = sy-tabix - 1.
      IF p_mult = ' '.
        PERFORM indicate_progress USING lv_tabix lv_count ls_files.
      ENDIF.
      lv_tabix = lv_tabix + 1.
      REFRESH lt_daten_aus_datei.
      PERFORM datei_lesen_local USING ls_files
                             CHANGING lt_daten_aus_datei.
      IF p_mult = ' '.
        PERFORM datei_bearbeiten USING lt_daten_aus_datei ls_files p_pcksz.
        PERFORM indicate_progress USING lv_tabix lv_count ls_files.
      ELSE.
        CLEAR lt_daten_aus_datei.
        ADD 1 TO gv_akt_proz.
        WAIT UNTIL gv_akt_proz < gv_max_proz.
        CALL FUNCTION '/ADESSO/ENET_UPLOAD'
          STARTING NEW TASK ls_files
          DESTINATION IN GROUP DEFAULT
          PERFORMING ende_task ON END OF TASK
          EXPORTING
            files    = lt_daten_aus_datei
            filename = ls_files.
      ENDIF.
    ENDLOOP.
    PERFORM status_end USING status.
  ENDIF.

  GET RUN TIME FIELD lv_dauer.     "Messung wird gestoppt
  lv_seconds = lv_dauer / 1000000. "Laufzeit Messstrecke in Sekunden
  WRITE : / lv_seconds, 'Sekunden Laufzeit' .

ENDFORM." start_of_selection

*&---------------------------------------------------------------------*
*& Form dateiauswahl
*&---------------------------------------------------------------------*
*  Dateiauswahl
*----------------------------------------------------------------------*
*  --> uv_titel  Fenstertitel
*  <-- cv_datei  Dateiname
*----------------------------------------------------------------------*
FORM dateiauswahl USING VALUE(uv_titel) TYPE string
               CHANGING cv_folder TYPE localfile ct_datei TYPE tt_file_tab.

  CLEAR ct_datei.
  " Daten für den OpenDialog
  DATA: lv_dateien TYPE filetable,
        ls_dateien TYPE file_table,
        lv_folder  TYPE string,
        lv_datei   LIKE LINE OF ct_datei,
        lv_rc      TYPE sy-subrc.

  cl_gui_frontend_services=>directory_browse(
    EXPORTING
      window_title            = uv_titel
    CHANGING
       selected_folder      = lv_folder
  EXCEPTIONS
    cntl_error           = 1
    error_no_gui         = 2
    not_supported_by_gui = 3
    OTHERS               = 4
        ).
  cv_folder = lv_folder.

ENDFORM." dateiauswahl

*&---------------------------------------------------------------------*
*& Form datei_lesen_arbeitsplatz
*&---------------------------------------------------------------------*
*  Öffnen und Einlesen der Datei vom Arbeitsplatz
*----------------------------------------------------------------------*
*  --> uv_filename    Dateiname
*  <-- ct_incomming   Daten aus der Datei
*----------------------------------------------------------------------*
FORM datei_lesen_local USING VALUE(uv_dateiname) TYPE localfile
                    CHANGING ct_daten_aus_datei TYPE STANDARD TABLE.

  DATA: lv_str_dateiname TYPE string. " Dateinamen als String

  lv_str_dateiname = p_in_dat && '\' && uv_dateiname. " Typecast char -> string



  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_str_dateiname
      filetype                = 'ASC'
    TABLES
      data_tab                = ct_daten_aus_datei
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM." datei_lesen_arbeitsplatz

*&---------------------------------------------------------------------*
*& Form datei_lesen_server
*&---------------------------------------------------------------------*
*  Öffnen und Einlesen der Datei vom Server
*----------------------------------------------------------------------*
*  --> uv_filename    Dateiname
*  <-- ct_incomming   Daten aus der Datei
*----------------------------------------------------------------------*
FORM datei_lesen_server USING VALUE(uv_dateiname) TYPE localfile
                     CHANGING ct_daten_aus_datei TYPE STANDARD TABLE.

  DATA: lv_str_dateiname   TYPE string, " Dateinamen als String
        ls_daten_aus_datei TYPE tv_zeile,
        lv_strlen          TYPE i,
        lv_trennzeichen    TYPE c,
        lv_osmsg(100).                    " Meldung für OpenDialog
  lv_strlen = strlen( p_in_dat ) - 1.
  IF uv_dateiname CS '\'.
    lv_trennzeichen = '\'.
  ELSE.
    lv_trennzeichen = '/'.
  ENDIF.
  IF p_in_dat+lv_strlen <> lv_trennzeichen.
    lv_str_dateiname = p_in_dat && lv_trennzeichen && uv_dateiname.
  ELSE.
    lv_str_dateiname = p_in_dat  && uv_dateiname.
  ENDIF.

  OPEN DATASET lv_str_dateiname FOR INPUT MESSAGE lv_osmsg IN TEXT MODE ENCODING NON-UNICODE.

  IF sy-subrc NE 0.
    WRITE: '@02@', 'Fehler beim Öffnen der Datei', lv_str_dateiname, 'vom Server'. "#EC NOTEXT
    WRITE: '@02@', lv_osmsg, sy-uline.                      "#EC NOTEXT
    RETURN.
  ENDIF.

* Sätze einlesen und in interne Tabelle schreiben
  WHILE sy-subrc EQ 0.
    CLEAR ls_daten_aus_datei.
    READ DATASET lv_str_dateiname INTO ls_daten_aus_datei-zeile.
    APPEND ls_daten_aus_datei TO ct_daten_aus_datei.
  ENDWHILE.

  CLOSE DATASET uv_dateiname.
ENDFORM." datei_lesen_server

*&---------------------------------------------------------------------*
*&      Form  datei_bearbeite
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UT_DATEN_AUS_DATEI  text
*----------------------------------------------------------------------*
FORM datei_bearbeiten USING ut_daten_aus_datei TYPE STANDARD TABLE
                            uv_filename TYPE localfile
                            uv_pck_size TYPE i.

  DATA:
    ls_component   TYPE abap_componentdescr,
    lt_component   TYPE abap_component_tab,
    lr_strucdescr  TYPE REF TO cl_abap_structdescr,
    lr_data_struct TYPE REF TO data.

  DATA:
    ls_component2  TYPE abap_componentdescr,
    lt_component2  TYPE abap_component_tab,
    lr_strucdescr2 TYPE REF TO cl_abap_structdescr,
    lr_data_table2 TYPE REF TO data,
    lr_tabledescr2 TYPE REF TO cl_abap_tabledescr,
    lr_row_enet    TYPE REF TO data,
    lr_lttab       TYPE REF TO data.

  DATA: lt_felder TYPE TABLE OF string,
        lv_type   TYPE c.
  DATA lv_percentage TYPE i.
  DATA lv_p_tabix TYPE p DECIMALS 2.
  DATA lv_proc_text TYPE string.
  DATA lv_percentage1 TYPE i.
  DATA lv_tabelle TYPE string.
  DATA lv_dats TYPE ts_daten_aus_datei.
  DATA lv_string TYPE string.
  DATA lv_string_temp TYPE string.
  DATA lf_last_row    TYPE abap_bool.
  DATA lv_rows_finished TYPE i.
  DATA(lv_rows_end) = lines( ut_daten_aus_datei ).

  TRANSLATE uv_filename TO UPPER CASE.
  "Strom und Gas bearbeiten
  IF uv_filename(3) = 'NNS'.
    SELECT SINGLE tabelle FROM /adesso/ec_enet INTO lv_tabelle WHERE datei = uv_filename+21.
  ELSEIF uv_filename(3) = 'NNG'.
    SELECT SINGLE tabelle FROM /adesso/c_enet_g INTO lv_tabelle WHERE datei = uv_filename+21.
  ENDIF.
  IF lv_tabelle IS NOT INITIAL.

    FIELD-SYMBOLS <lt_tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS: <fs>, <tab>, <enet_tab> TYPE STANDARD TABLE, <enet_line>,  <line>, <enet_work> , <mandt>, <a>.
    SELECT COUNT(*) FROM dd02l WHERE tabname = lv_tabelle.
    IF sy-subrc <> 0.
      MESSAGE 'Tabelle' && lv_tabelle && 'nicht im System vorhanden' TYPE 'E'.
    ENDIF.

    ls_component-type ?= cl_abap_typedescr=>describe_by_name( lv_tabelle ).

    ls_component-name = 'A'.
    INSERT ls_component INTO TABLE lt_component.
    lr_strucdescr = cl_abap_structdescr=>create( lt_component ).
    CLEAR ls_component.
    CREATE DATA lr_data_struct TYPE HANDLE lr_strucdescr.
    ASSIGN lr_data_struct->* TO <fs>.
    ASSIGN COMPONENT 'A' OF STRUCTURE <fs> TO <tab>.
    CREATE DATA lr_lttab LIKE STANDARD TABLE OF <tab>.
    ASSIGN lr_lttab->* TO <lt_tab>.

    LOOP AT ut_daten_aus_datei INTO lv_dats.
      lv_string = lv_dats-zeile.
      lf_last_row = xsdbool( sy-tabix EQ lv_rows_end ).
      IF sy-tabix = 1.
        REPLACE ALL OCCURRENCES OF 'ß' IN lv_string WITH 'ss'.
        REPLACE ALL OCCURRENCES OF '-' IN lv_string WITH '_'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_string WITH '_'.
        CONDENSE lv_string.
        "Dateien auf dem Sap Filesystem wird am ende der Zeile ein # angehängt. Dies ist in Flednamen nicht erlaubt
        REPLACE ALL OCCURRENCES OF '#' IN lv_string WITH ''.
        CONDENSE lv_string.
        TRANSLATE lv_string TO UPPER CASE.
        DO 1000 TIMES.
          SEARCH lv_string FOR ';'.
          IF sy-subrc = 0.
            lv_string_temp = lv_string(sy-fdpos).
            SHIFT lv_string_temp LEFT DELETING LEADING 'XY'. "Reservierte Sap Felder haben xy vorangestellt
            APPEND lv_string_temp TO lt_felder.
            lv_string = lv_string+sy-fdpos.
            lv_string = lv_string+1.
          ELSE.
            lv_string_temp = lv_string.
            SHIFT lv_string_temp LEFT DELETING LEADING 'XY'. "Reservierte Sap Felder haben xy vorangestellt
            APPEND lv_string_temp TO lt_felder.
            EXIT.
          ENDIF.
        ENDDO.
        LOOP AT lt_felder INTO lv_string.
          CLEAR ls_component2.
          ls_component2-name =  lv_string .
          " lv_string = lv_tabelle && '-' && lv_string.
          TRY .
              FREE <fs>.
              IF lv_string = 'VNBG'  .
                lv_string = 'VNBG_NR'.
              ENDIF.
              ASSIGN COMPONENT lv_string OF STRUCTURE <tab> TO <fs>.
              IF sy-subrc <> 0.
                lv_string = 'XY' && lv_string.
                ASSIGN COMPONENT lv_string OF STRUCTURE <tab> TO <fs>.
                IF sy-subrc <> 0.
                  READ TABLE lt_component2 INTO ls_component2 INDEX sy-index.
                  WRITE: 'Feld' && ls_component2-name && 'Ist nicht in der Tabelle ' && lv_tabelle && 'vorhanden'.
                  "  PERFORM status_end USING status.
                  "  MESSAGE 'Feld' && ls_component2-name && 'Ist nicht in der Tabelle ' && lv_tabelle && 'vorhanden' TYPE 'E'.

                  lv_string = lv_string.
                ENDIF.
              ENDIF.
              ls_component2-type ?= cl_abap_typedescr=>describe_by_data( <fs> ).
            CATCH  cx_root.
          ENDTRY.
          INSERT ls_component2 INTO TABLE lt_component2.

        ENDLOOP.
        lr_strucdescr2 = cl_abap_structdescr=>create( lt_component2 ).
        CLEAR ls_component2.
        lv_string = lv_string.
        lr_tabledescr2 = cl_abap_tabledescr=>create( p_line_type = lr_strucdescr2 ).
        CREATE DATA lr_data_table2 TYPE HANDLE lr_tabledescr2.
        ASSIGN lr_data_table2->* TO <enet_tab>.

        CREATE DATA lr_row_enet LIKE LINE OF <enet_tab>.
        ASSIGN lr_row_enet->* TO <enet_line>.
        IF sy-subrc = 0.
          DELETE FROM (lv_tabelle).
        ENDIF.
        lv_rows_finished = 1.
      ELSE.
        IF  lines( ut_daten_aus_datei ) > 0 .
          lv_p_tabix = sy-tabix.
          lv_percentage =  ( lv_p_tabix / lines( ut_daten_aus_datei ) ) * 100 .
        ELSE.
          lv_percentage = 100.
        ENDIF.
        IF lv_percentage <> lv_percentage1.
          lv_percentage1 = lv_percentage.
          lv_percentage = lines( ut_daten_aus_datei ).
          lv_proc_text = sy-tabix && ' von ' &&  lv_percentage .
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              percentage = lv_percentage1
              text       = lv_proc_text.
        ENDIF.
        DO 1000 TIMES.

          "  ASSIGN COMPONENT 'A' OF STRUCTURE <enet_line> TO <a>.
          SEARCH lv_string FOR ';'.
          IF sy-subrc = 0.

            lv_string_temp = lv_string(sy-fdpos).

            ASSIGN COMPONENT sy-index OF STRUCTURE <enet_line> TO <enet_work>.
            IF sy-subrc <> 0.
              READ TABLE lt_component2 INTO ls_component2 INDEX sy-index.
              WRITE: 'Feld' && ls_component2-name && 'Ist nicht in der Tabelle ' && lv_tabelle && 'vorhanden'.
              "  PERFORM status_end USING status.
              "  MESSAGE 'Feld' && ls_component2-name && 'Ist nicht in der Tabelle ' && lv_tabelle && 'vorhanden' TYPE 'E'.
            ENDIF.
            DESCRIBE FIELD: <enet_work>       TYPE lv_type.
            IF lv_type = 'P' OR  lv_type = 'a' OR lv_type = 'e' OR lv_type = 'F'.
              REPLACE ',' WITH '.' INTO lv_string_temp.
            ELSEIF lv_type = 'D'.
              IF strlen( lv_string_temp ) > 6.
                lv_string_temp = lv_string_temp+6 && lv_string_temp+3(2) && lv_string_temp(2).
              ENDIF.
            ENDIF.
            TRY .
                <enet_work> = lv_string_temp.
              CATCH cx_root.
                WRITE : / lv_tabelle,';', sy-index ,';' ,lv_string_temp.
                EXIT.
            ENDTRY.
            lv_string = lv_string+sy-fdpos.
            lv_string = lv_string+1.
          ELSE.
            lv_string_temp = lv_string.
            ASSIGN COMPONENT sy-index OF STRUCTURE <enet_line> TO <enet_work>.
            DESCRIBE FIELD: <enet_work>       TYPE lv_type.
            IF lv_type = 'P' OR  lv_type = 'a' OR lv_type = 'e' OR lv_type = 'F'.
              REPLACE ',' WITH '.' INTO lv_string_temp.
            ELSEIF lv_type = 'D'.
              IF strlen( lv_string_temp ) > 6.
                lv_string_temp = lv_string_temp+6 && lv_string_temp+3(2) && lv_string_temp(2).
              ENDIF.
            ENDIF.
            TRY .
                <enet_work> = lv_string_temp.
              CATCH cx_root.
                WRITE : / lv_tabelle,';', sy-index, ';' ,lv_string_temp.
                EXIT.
            ENDTRY.

            MOVE-CORRESPONDING <enet_line> TO <tab>.

            ASSIGN COMPONENT 'MANDT' OF STRUCTURE <tab> TO <mandt>.
            <mandt> = sy-mandt.

            APPEND <tab> TO <lt_tab>.
            " Paket voll oder letzte Zeile erreicht
            IF  lines( <lt_tab> ) >= uv_pck_size OR  lf_last_row EQ abap_true.
              TRY.
                  INSERT (lv_tabelle) FROM TABLE <lt_tab>.
                CATCH cx_sy_open_sql_db INTO DATA(lv_exep).
                  sy-subrc = 4.
              ENDTRY.
              IF sy-subrc <> 0.
                " Error at Package Insert => Single Insert um Duplikate festzustellen
                DATA(lv_linenr_fail) = lv_rows_finished.
                LOOP AT <lt_tab> ASSIGNING <tab>.
                  clear sy-subrc.
                  TRY.
                      INSERT INTO (lv_tabelle) VALUES <tab>.
                    CATCH cx_sy_open_sql_db INTO DATA(lv_exep2).
                      sy-subrc = 4.
                  ENDTRY.
                  IF sy-subrc <> 0.
                    lv_linenr_fail = lv_rows_finished + sy-tabix.
                    WRITE : / lv_tabelle,' ;', lv_linenr_fail, ';' , 'Duplikative Einträge', ';Ladedatei;', uv_filename.
                  ENDIF.
                ENDLOOP.
              ENDIF.
              lv_rows_finished = lv_rows_finished + lines( <lt_tab> ).
              CLEAR <lt_tab>.

*            INSERT INTO (lv_tabelle) VALUES <tab>.
*            if sy-subrc <> 0.
*              WRITE : / lv_tabelle,';', sy-tabix, ';' , 'Duplikative Einträge'.
*            endif.
*            COMMIT WORK.
            ENDIF.
            EXIT.
          ENDIF.


        ENDDO.

      ENDIF.
    ENDLOOP.
    COMMIT WORK.

*    LOOP AT <enet_tab> INTO <enet_line>.
*
*      MOVE-CORRESPONDING <enet_line> TO <tab>.
*
*      ASSIGN COMPONENT 'MANDT' OF STRUCTURE <tab> TO <mandt>.
*      <mandt> = sy-mandt.
*
*      INSERT INTO (lv_tabelle) VALUES <tab>.
*      COMMIT WORK.
*
*
*    ENDLOOP.


  ENDIF.


ENDFORM.                    "datei_bearbeite

FORM ende_task USING taskname.

  gv_count = gv_count + 1.
  IF gv_count = lines( gt_files ).
    WRITE 'Einlesen beendet'.
  ENDIF.

  SUBTRACT 1 FROM gv_max_proz.

ENDFORM.
FORM indicate_progress USING var_a var_b var_c.


  status-curval  = var_a.
  status-maxval  = var_b.
  status-winid  = 'ENET'.

  status-text_1 = 'Datei:' && var_c+21 .
  status-text_3 = ' wird bearbeitet.'.

  CALL FUNCTION 'PROGRESS_POPUP'
    EXPORTING
      btn_txt     = status-btn_txt
      curval      = status-curval
      maxval      = status-maxval
      stat        = status-stat
      text_1      = status-text_1
      text_2      = status-text_2
      text_3      = status-text_3
      title       = status-title
      winid       = status-winid
    IMPORTING
      m_typ       = status-m_typ
      popup_event = status-popup_event
      rwnid       = status-rwnid.

  IF status-popup_event =   popup_event_cancel.

    PERFORM status_end USING status.
    EXIT.
  ENDIF.
  status-stat =         stat_4.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM STATUS_END                                               *
*---------------------------------------------------------------------*
FORM status_end USING s STRUCTURE status.

  CALL FUNCTION 'GRAPH_DIALOG'
    EXPORTING
      close = 'X'
      kwdid = s-winid.

ENDFORM.
