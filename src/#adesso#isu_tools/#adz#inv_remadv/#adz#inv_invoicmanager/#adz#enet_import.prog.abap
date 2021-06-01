*&---------------------------------------------------------------------*
*& Report  ZAD_ENET_IMPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT /adz/enet_import.

************************************************************************
* Typen und Data:
************************************************************************
TYPES:
  BEGIN OF ts_daten_aus_datei,
    zeile TYPE string,       " %ANPASSEN% Zeilenbreite
  END OF ts_daten_aus_datei,

  tv_zeile    TYPE ts_daten_aus_datei,      " %ANPASSEN% Zeilenbreite
  tt_file_tab TYPE TABLE OF localfile.
DATA gv_cust TYPE /adz/inv_cust.
DATA: lv_directory(200),
      lv_sysid TYPE sy-sysid.
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

DATA: gf_unix_folder TYPE /sapdmc/ls_filename.
DATA: popup_event_cancel(6) VALUE 'CANCEL'.
DATA: stat_4 VALUE '3'.
DATA: lv_wert(15) TYPE c.
DATA: gv_type TYPE typ.

************************************************************************
* Parameter:
************************************************************************

SELECTION-SCREEN: BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001. " %ANPASSEN% text-001

PARAMETERS:
  " Server oder Arbeitsplatz?
  p_in_dat TYPE localfile OBLIGATORY,
  p_pcksz  TYPE i DEFAULT 1000.
SELECTION-SCREEN: END OF BLOCK b01.


************************************************************************
* AT SELECTION-SCREEN
************************************************************************


INITIALIZATION.
  FIELD-SYMBOLS <var>.

  SELECT  * FROM /adz/inv_cust INTO gv_cust WHERE report = sy-repid.
    DESCRIBE  FIELD <var> TYPE gv_type.
    ASSIGN (gv_cust-field) TO <var>.
    IF sy-subrc = 0.
      <var> = gv_cust-value.
    ENDIF.
  ENDSELECT.

  status-title  = 'Enet_upload'.
  lv_sysid = sy-sysid.
  TRANSLATE lv_sysid TO LOWER CASE.
  p_in_dat = '/rkudat/rkustd/' &&  sy-mandt  && '/' && lv_sysid && '/adesso/invm/enet' .


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_in_dat.
  PERFORM dateiauswahl USING 'Eingabedatei auswählen:'      "#EC NOTEXT
                    CHANGING p_in_dat.



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
  DATA: lt_files      TYPE TABLE OF file_info,
        ls_file_info  TYPE file_info,
        lv_dat_string TYPE string,
        lv_dirname    TYPE eps2filnam,
        lt_dir_list   TYPE TABLE OF eps2fili,
        ls_dir_list   TYPE eps2fili,
        lv_tabix      TYPE i,
        lv_count      TYPE i.

  " Einlesen der Datei, Server oder Arbeitsplatz
  "*********************************************
  CLEAR lv_dauer.
  GET RUN TIME FIELD lv_dauer.     "Messung wird gestartet

  REFRESH lt_daten_aus_datei.


  lv_dat_string  = p_in_dat.

  SELECT SINGLE value FROM /adz/inv_cust INTO gv_max_proz_c WHERE report = 'GLOBAL' AND field = 'GV_MAX_PROZ'.
  IF gv_max_proz_c IS INITIAL.
    gv_max_proz_c = '5'.
  ENDIF.
  gv_max_proz = gv_max_proz_c.

  lv_dirname = p_in_dat.
  CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
    EXPORTING
      iv_dir_name            = lv_dirname
*     FILE_MASK              = ' '
* IMPORTING
*     DIR_NAME               =
*     FILE_COUNTER           =
*     ERROR_COUNTER          =
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

  LOOP AT lt_dir_list INTO ls_dir_list.
    lv_datei = ls_dir_list-name.
    IF lv_datei(2) = 'nn'.
      APPEND lv_datei TO gt_files.
    ENDIF.
  ENDLOOP.

  lv_count = lines( gt_files ).

  LOOP AT gt_files INTO ls_files.

    REFRESH lt_daten_aus_datei.
    PERFORM datei_lesen_server USING ls_files
                            CHANGING lt_daten_aus_datei.
    PERFORM datei_bearbeiten USING lt_daten_aus_datei ls_files p_pcksz.
  ENDLOOP.


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
               CHANGING cv_folder TYPE localfile.

  lv_directory = p_in_dat.
  IF lv_directory IS INITIAL.
    lv_sysid = sy-sysid.
    TRANSLATE lv_sysid TO LOWER CASE.
    p_in_dat = '/rkudat/rkustd/' &&  sy-mandt  && '/' && lv_sysid && '/adesso/invm/enet' .
  ENDIF.
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory  = lv_directory
      filemask   = '.csv' "GF_FILEMASK
    IMPORTING
      serverfile = gf_unix_folder
*   EXCEPTIONS
*     CANCELED_BY_USER       = 1
*     OTHERS     = 2
    .

  cv_folder = gf_unix_folder.

ENDFORM." dateiauswahl

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
    WRITE: / '@02@', 'Fehler beim Öffnen der Datei', lv_str_dateiname, 'vom Server'. "#EC NOTEXT
    WRITE: / '@02@', lv_osmsg, sy-uline.                    "#EC NOTEXT
    RETURN.
  ENDIF.

* Sätze einlesen und in interne Tabelle schreiben
  WHILE sy-subrc EQ 0.
    CLEAR ls_daten_aus_datei.
    READ DATASET lv_str_dateiname INTO ls_daten_aus_datei-zeile.
    APPEND ls_daten_aus_datei TO ct_daten_aus_datei.
  ENDWHILE.

  CLOSE DATASET lv_str_dateiname.
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
  DATA lv_length TYPE i.

  TRANSLATE uv_filename TO UPPER CASE.
  "Strom und Gas bearbeiten
  DATA(lv_tabname) = SWITCH tabname( uv_filename(3)
     WHEN 'NNS' THEN  '/ADZ/EC_ENET'
     WHEN 'NNG' THEN  '/ADESSO/C_ENET_G' ).
  IF lv_tabname IS NOT INITIAL.
    SELECT SINGLE tabelle FROM (lv_tabname) INTO lv_tabelle WHERE datei = uv_filename+21.
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
        REPLACE ALL OCCURRENCES OF REGEX '\s' IN lv_string WITH ''.
        REPLACE ALL OCCURRENCES OF 'ß' IN lv_string WITH 'ss'.
        REPLACE ALL OCCURRENCES OF '-' IN lv_string WITH '_'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_string WITH '_'.
        REPLACE ALL OCCURRENCES OF '#' IN lv_string WITH '_'.
        "Dateien auf dem Sap Filesystem wird am ende der Zeile ein # angehängt. Dies ist in Feldnamen nicht erlaubt
        REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf(1) IN lv_string WITH space.
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
                  WRITE: / 'Feld' && ls_component2-name && 'ist nicht in der Tabelle ' && lv_tabelle && 'vorhanden'.
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
          REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf(1) IN lv_string WITH space.
          "  ASSIGN COMPONENT 'A' OF STRUCTURE <enet_line> TO <a>.
          SEARCH lv_string FOR ';'.
          IF sy-subrc = 0.

            lv_string_temp = lv_string(sy-fdpos).

            ASSIGN COMPONENT sy-index OF STRUCTURE <enet_line> TO <enet_work>.
            IF sy-subrc <> 0.
              READ TABLE lt_component2 INTO ls_component2 INDEX sy-index.
              WRITE: / 'Feld' && ls_component2-name && 'ist nicht in der Tabelle ' && lv_tabelle && 'vorhanden'.
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
                FIELD-SYMBOLS <fs_tab> .
                LOOP AT <lt_tab> ASSIGNING <fs_tab> .
                  CLEAR sy-subrc.
                  TRY.
                      INSERT INTO (lv_tabelle) VALUES <fs_tab>.
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
            ENDIF.
            EXIT.
          ENDIF.


        ENDDO.

      ENDIF.
    ENDLOOP.
    COMMIT WORK.

  ENDIF.

ENDFORM.                    "datei_bearbeite
