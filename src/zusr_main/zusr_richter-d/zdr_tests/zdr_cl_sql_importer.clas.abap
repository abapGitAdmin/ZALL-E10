class ZDR_CL_SQL_IMPORTER definition
  public
  final
  create public .

public section.

  class-methods PERFORMANCER .
  class-methods PERFORMANCER_V2 .
  class-methods PERFORMANCER_V3 .
  methods CONSTRUCTOR
    importing
      !SEPERATOR type CHAR01 default ','
      !DELETE_DATACATALOG type ABAP_BOOL .
  class-methods CLEAR_DATABASE
    importing
      !IV_DATABASE_TABNAME type DD02L-TABNAME .
  class-methods GENERATE_DATABASE
    importing
      !IV_DATABASE_TABNAME type DD02L-TABNAME
      !IV_CLEAR_TAB type ABAP_BOOL .
  class-methods IMPORT_CSV_TO_DATABASE
    importing
      !IV_DATABASE_TABNAME type DD02L-TABNAME
      !IV_SEPERATOR type CHAR01
      !IV_CLEAR_TAB type ABAP_BOOL
      !IV_HEADER type ABAP_BOOL .
  methods DUBLICATE_ITAB
    importing
      !COUNTER type I default 1
    changing
      !ITABFILM type /ADO/T_SQL_FILM optional
      !ITABMEDICAL type /ADO/T_SQL_MEDICAL optional
      !ITABFOOD type /ADO/T_SQL_FOOD optional
      !ITAB991 type /ADO/T_SQL_911 optional
      !ITABSALEREC type /ADO/T_SQL_SALEREC optional
      !ITABPOLLUTION type /ADO/T_SQL_POLLUTION optional .
protected section.
private section.

  data SEPERATOR type CHAR01 value ',' ##NO_TEXT.
  data DELETE_DATACATALOG type ABAP_BOOL value ' ' ##NO_TEXT.
  constants GC_DATACAT_TABNAME type DD02L-TABNAME value '/ADO/SQL_DATACAT' ##NO_TEXT.
ENDCLASS.



CLASS ZDR_CL_SQL_IMPORTER IMPLEMENTATION.


METHOD CLEAR_DATABASE.
  TRY.
      DELETE FROM (iv_database_tabname).
    CATCH cx_sy_open_sql_db.
      MESSAGE 'Fehler beim Löschen des Inhalts der Datenbank!' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.
ENDMETHOD.


  method CONSTRUCTOR.

    me->seperator = SEPERATOR.
    me->delete_datacatalog = DELETE_DATACATALOG.

  endmethod.


  METHOD DUBLICATE_ITAB.

    if itabmedical is INITIAL.

      " cases machen falls erneut gebraucht.

      ENDIF.



    DATA itabcopy TYPE /ADO/T_SQL_SALEREC.
    DATA wacopy LIKE LINE OF itabcopy.

    itabcopy = ITABSALEREC.

    DATA lv_counter TYPE i VALUE '0000001'.
    DATA: idtemp TYPE char07.

    DO counter - 1 TIMES.

      LOOP AT itabcopy INTO wacopy.
        lv_counter = lv_counter + 1.
        idtemp = lv_counter.
        idtemp = |{ idtemp  WIDTH = 7 ALPHA = IN }|.
        wacopy-idsalerec = idtemp.
        APPEND wacopy TO itabsalerec.
      ENDLOOP.
    ENDDO.


  ENDMETHOD.


METHOD GENERATE_DATABASE.
  DATA: lr_istruc TYPE REF TO data,
        lr_itab   TYPE REF TO data.

  FIELD-SYMBOLS: <istruc>      TYPE any,
                 <itab>        TYPE STANDARD TABLE.

*  Struktur zur Laufzeit erzeugen
  CREATE DATA lr_istruc TYPE (iv_database_tabname).
  ASSIGN lr_istruc->* TO <istruc>.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  interne Tabelle zur Laufzeit erzeugen
  CREATE DATA lr_itab TYPE TABLE OF (iv_database_tabname).
  ASSIGN lr_itab->* TO <itab>.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SELECT *
    FROM /ado/sql_psid AS a JOIN /ado/sql_star AS b
    ON a~psid_id IS NOT NULL AND b~star_id IS NOT NULL
    INTO CORRESPONDING FIELDS OF TABLE @<itab>.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  Inhalt der Datenbanktabelle vorher löschen falls erwünscht
  IF iv_clear_tab = abap_true.
    TRY.
        DELETE FROM (iv_database_tabname).
      CATCH cx_sy_open_sql_db.
        MESSAGE 'Fehler beim Löschen des Inhalts der Datenbank!' TYPE 'E'.
    ENDTRY.
  ENDIF.

*  interne Tabelle auf die Datenbank schreiben
  TRY.
      INSERT (iv_database_tabname) FROM TABLE <itab>.
    CATCH cx_sy_open_sql_db.
      MESSAGE 'Fehler beim Schreiben auf die Datenbank!' TYPE 'E'.
  ENDTRY.
ENDMETHOD.


METHOD import_csv_to_database.
  DATA: lt_file_table  TYPE filetable,
        lv_rc          TYPE i,
        lv_user_action TYPE i.

  DATA: lt_csv_records       TYPE string_table,
        lt_header_components TYPE string_table,
        lt_row_components    TYPE string_table,
        lv_row_width         TYPE i,
        lv_component_value   TYPE string.

  DATA: lr_istruc TYPE REF TO data,
        lr_itab   TYPE REF TO data.

  FIELD-SYMBOLS: <row_string>  TYPE string,
                 <istruc>      TYPE any,
                 <itab>        TYPE STANDARD TABLE,
                 <istruc_comp> TYPE data.

*  eine Datei auswählen
  cl_gui_frontend_services=>file_open_dialog( EXPORTING  file_filter             = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
                                                         multiselection          = abap_true
                                              CHANGING   file_table              = lt_file_table
                                                         rc                      = lv_rc
                                                         user_action             = lv_user_action
                                              EXCEPTIONS file_open_dialog_failed = 1
                                                         cntl_error              = 2
                                                         error_no_gui            = 3
                                                         not_supported_by_gui    = 4
                                                         OTHERS                  = 5 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  fehlerhafte Benutzereingabe
  IF lv_user_action <> cl_gui_frontend_services=>action_ok OR
     lines( lt_file_table ) <> 1.
    MESSAGE 'Fehler beim Auswählen der Datei. Bitte wähle genau eine Datei aus!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  Datei in interne String-Tabelle hochladen
  cl_gui_frontend_services=>gui_upload( EXPORTING
                                          filename = CONV #( lt_file_table[ 1 ]-filename )
                                          filetype = 'ASC'
                                        CHANGING
                                          data_tab = lt_csv_records
                                        EXCEPTIONS
                                          file_open_error         = 1
                                          file_read_error         = 2
                                          OTHERS                  = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  Struktur zur Laufzeit erzeugen
  CREATE DATA lr_istruc TYPE (iv_database_tabname).
  ASSIGN lr_istruc->* TO <istruc>.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  interne Tabelle zur Laufzeit erzeugen
  CREATE DATA lr_itab TYPE TABLE OF (iv_database_tabname).
  ASSIGN lr_itab->* TO <itab>.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  Daten der eingelesenen String-Tabelle in die Spalten aufteilen und entsprechend in <itab> zwischenspeichern
  IF iv_database_tabname = gc_datacat_tabname.
    IF iv_header = abap_false.
      MESSAGE |Header wird fürs Eintragen in { gc_datacat_tabname } benötigt| TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
    LOOP AT lt_csv_records ASSIGNING <row_string>.
      DATA(row_id) = sy-tabix.
*      aufsplitten des Zeileninhalts
      AT FIRST.
        TRANSLATE <row_string> TO UPPER CASE.
        SPLIT <row_string> AT iv_seperator INTO TABLE lt_header_components.
        CONTINUE.
      ENDAT.
      SPLIT <row_string> AT iv_seperator INTO TABLE lt_row_components.
      IF lines( lt_header_components ) <> lines( lt_row_components ).
        MESSAGE 'Fehlerhaftes Format der CSV-Datei. Tabellenbreite nicht überall gleich!' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

*      Datensatz der CSV-Datei den Komponenten der Datenbanktabelle entsprechend zuteilen
      DO lines( lt_header_components ) TIMES.
        DATA(index) = sy-index.
        ASSIGN COMPONENT 'CSV_REF' OF STRUCTURE <istruc> TO <istruc_comp>.
        IF sy-subrc = 0.
          SPLIT lt_file_table[ 1 ]-filename AT '\' INTO TABLE DATA(doc_path_components).
          <istruc_comp> = doc_path_components[ lines( doc_path_components ) ].
        ENDIF.
        ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <istruc> TO <istruc_comp>.
        IF sy-subrc = 0.
          <istruc_comp> = row_id.
        ENDIF.
        ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <istruc> TO <istruc_comp>.
        IF sy-subrc = 0.
          <istruc_comp> = lt_header_components[ index ].
        ENDIF.
        ASSIGN COMPONENT 'EXAMPLEDATA' OF STRUCTURE <istruc> TO <istruc_comp>.
        IF sy-subrc = 0.
          <istruc_comp> = lt_row_components[ index ].
        ENDIF.

*        Datensatz in der internen Tabelle zwischenspiechern
        APPEND <istruc> TO <itab>.
      ENDDO.
    ENDLOOP.
  ELSE.
    LOOP AT lt_csv_records ASSIGNING <row_string>.
*      IF TODO.
*        REPLACE ALL OCCURRENCES OF SUBSTRING '"' IN <row_string> WITH ''.
*      ENDIF.

*      aufsplitten des Zeileninhalts
      SPLIT <row_string> AT iv_seperator INTO TABLE lt_row_components.
      AT FIRST.
        IF iv_header = abap_true.
          TRANSLATE <row_string> TO UPPER CASE.
          SPLIT <row_string> AT iv_seperator INTO TABLE lt_header_components.
          lv_row_width = lines( lt_header_components ).
          CONTINUE.
        ELSE.
          lv_row_width = lines( lt_row_components ).
        ENDIF.
      ENDAT.
      IF lines( lt_row_components ) <> lv_row_width.
        MESSAGE 'Fehlerhaftes Format der CSV-Datei. Tabellenbreite nicht überall gleich!' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

*      Datensatz der CSV-Datei den Komponenten der Datenbanktabelle entsprechend zuteilen
      ASSIGN COMPONENT 1 OF STRUCTURE <istruc> TO <istruc_comp>.
      <istruc_comp> = sy-tabix.
      DO lv_row_width TIMES.
        IF iv_header = abap_true.
          DATA(lv_component_name) = lt_header_components[ sy-index ].
          ASSIGN COMPONENT lv_component_name OF STRUCTURE <istruc> TO <istruc_comp>.
        ELSE.
          ASSIGN COMPONENT sy-index OF STRUCTURE <istruc> TO <istruc_comp>.
        ENDIF.
        IF sy-subrc <> 0.
          MESSAGE 'Fehler beim Zuordnen der Komponenten der CSV zu den Feldern der Struktur! (evtl. Header oder CSV-Format falsch)' TYPE 'S' DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.

        lv_component_value = lt_row_components[ sy-index ].
        IF lv_component_value CO ' ' OR
           lv_component_value = 'NA'.
          CLEAR <istruc_comp>.
        ELSE.
          TRY.
              <istruc_comp> = lv_component_value.
            CATCH cx_sy_conversion_no_number.
              MESSAGE 'Fehlerhafte Typkonvertierung beim einlesen der CSV-Datei' TYPE 'S' DISPLAY LIKE 'E'.
              RETURN.
          ENDTRY.
        ENDIF.
      ENDDO.

*      Datensatz in der internen Tabelle zwischenspiechern
      APPEND <istruc> TO <itab>.
    ENDLOOP.
  ENDIF.

*  Inhalt der Datenbanktabelle vorher löschen falls erwünscht
  IF iv_clear_tab = abap_true.
    TRY.
        DELETE FROM (iv_database_tabname).
      CATCH cx_sy_open_sql_db.
        MESSAGE 'Fehler beim Löschen des Inhalts der Datenbank!' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.
  ENDIF.

*  interne Tabelle auf die Datenbank schreiben
  TRY.
      INSERT (iv_database_tabname) FROM TABLE <itab>.
    CATCH cx_sy_open_sql_db.
      MESSAGE 'Fehler beim Schreiben auf die Datenbank! (etvl. ehlerhaftes Format der CSV-Datei, Key nicht eindeutig)' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.
ENDMETHOD.


METHOD performancer.
  DATA: lt_file_table  TYPE filetable,
        lv_rc          TYPE i,
        lv_user_action TYPE i.

  DATA: lv_html      TYPE string,
        lv_starttime TYPE i,
        lv_endtime   TYPE i,
        lv_seconds   TYPE i.

  DATA: lv_prg_name      TYPE sy-repid VALUE 'TMP_REPORT',
        lv_sql_statement TYPE string,
        lt_sql_stmt_tab  TYPE string_table,
        it_src           TYPE STANDARD TABLE OF char1024,
        lv_msg           TYPE string,
        lv_line          TYPE string,
        lv_word          TYPE string,
        lv_off           TYPE string.

*  eine Datei auswählen
  cl_gui_frontend_services=>file_open_dialog( EXPORTING  file_filter             = |txt (*.txt)\|*.txt\|{ cl_gui_frontend_services=>filetype_all }|
                                                         multiselection          = abap_true
                                              CHANGING   file_table              = lt_file_table
                                                         rc                      = lv_rc
                                                         user_action             = lv_user_action
                                              EXCEPTIONS file_open_dialog_failed = 1
                                                         cntl_error              = 2
                                                         error_no_gui            = 3
                                                         not_supported_by_gui    = 4
                                                         OTHERS                  = 5 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  fehlerhafte Benutzereingabe
  IF lv_user_action <> cl_gui_frontend_services=>action_ok OR
     lines( lt_file_table ) <> 1.
    MESSAGE 'Fehler beim Auswählen der Datei. Bitte wähle genau eine Datei aus!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  Datei in interne String-Tabelle hochladen
  cl_gui_frontend_services=>gui_upload( EXPORTING
                                          filename = CONV #( lt_file_table[ 1 ]-filename )
                                          filetype = 'ASC'
                                        CHANGING
                                          data_tab = lt_sql_stmt_tab
                                        EXCEPTIONS
                                          file_open_error         = 1
                                          file_read_error         = 2
                                          OTHERS                  = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA(lv_sql_stmt_count) = lines( lt_sql_stmt_tab ).
  DO lv_sql_stmt_count TIMES.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
          EXPORTING
            percentage = ( sy-index * 100 ) DIV lv_sql_stmt_count
            text       = |Bitte warten... { sy-index } von { lv_sql_stmt_count }|.

    CLEAR it_src.
    APPEND |REPORT { lv_prg_name }.| TO it_src.
    lv_sql_statement = lt_sql_stmt_tab[ sy-index ].
    APPEND lv_sql_statement TO it_src.
    INSERT REPORT lv_prg_name FROM it_src.
    GENERATE REPORT lv_prg_name MESSAGE lv_msg LINE lv_line WORD lv_word OFFSET lv_off.
    IF sy-subrc = 0.
      GET RUN TIME FIELD lv_starttime. " Startzeitpunkt

      SUBMIT (lv_prg_name) AND RETURN.

      GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
      lv_seconds = ( lv_endtime - lv_starttime ).

      IF sy-subrc = 0.
        cl_demo_output=>write_data( name = 'SQL-Statement'
                                    value = lv_sql_statement ).
        cl_demo_output=>write_data( name = 'Runtime'
                                    value = |{ lv_seconds }µs (ca. { lv_seconds / 1000000 }s)| ).
        cl_demo_output=>line( ).
      ENDIF.
    ELSE.
      WRITE: / 'Error during generation in line', lv_line,
             / lv_msg,
             / 'Word:', lv_word, 'at offset', lv_off.
    ENDIF.
  ENDDO.

  lv_html = cl_demo_output=>get( ).
  cl_abap_browser=>show_html( EXPORTING
                                title        = 'Daten aus CSV'
                                html_string  = lv_html
                                container    = cl_gui_container=>default_screen ).

  WRITE 0.
ENDMETHOD.


METHOD performancer_v2.
  DATA: lt_file_table  TYPE filetable,
        lv_rc          TYPE i,
        lv_user_action TYPE i.

  DATA: lv_html      TYPE string,
        lv_starttime TYPE i,
        lv_endtime   TYPE i,
        lv_seconds   TYPE i.

  DATA: lr_sql_con_ref   TYPE REF TO cl_sql_connection,
        lr_sql_stmt_ref  TYPE REF TO cl_sql_statement,
        lv_sql_statement TYPE string,
        lt_sql_stmt_tab  TYPE string_table.

  DATA: lt_itab TYPE STANDARD TABLE OF /ado/sql_all,
        lt_itab2 TYPE STANDARD TABLE OF /ado/sql_all.

*  eine Datei auswählen
  cl_gui_frontend_services=>file_open_dialog( EXPORTING  file_filter             = |txt (*.txt)\|*.txt\|{ cl_gui_frontend_services=>filetype_all }|
                                                         multiselection          = abap_true
                                              CHANGING   file_table              = lt_file_table
                                                         rc                      = lv_rc
                                                         user_action             = lv_user_action
                                              EXCEPTIONS file_open_dialog_failed = 1
                                                         cntl_error              = 2
                                                         error_no_gui            = 3
                                                         not_supported_by_gui    = 4
                                                         OTHERS                  = 5 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  fehlerhafte Benutzereingabe
  IF lv_user_action <> cl_gui_frontend_services=>action_ok OR
     lines( lt_file_table ) <> 1.
    MESSAGE 'Fehler beim Auswählen der Datei. Bitte wähle genau eine Datei aus!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  Datei in interne String-Tabelle hochladen
  cl_gui_frontend_services=>gui_upload( EXPORTING
                                          filename = CONV #( lt_file_table[ 1 ]-filename )
                                          filetype = 'ASC'
                                        CHANGING
                                          data_tab = lt_sql_stmt_tab
                                        EXCEPTIONS
                                          file_open_error         = 1
                                          file_read_error         = 2
                                          OTHERS                  = 3 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  lr_sql_con_ref = NEW cl_sql_connection( ).
  lr_sql_stmt_ref = NEW cl_sql_statement( con_ref = lr_sql_con_ref ).

  DATA(lv_sql_stmt_count) = lines( lt_sql_stmt_tab ).
  DO lv_sql_stmt_count TIMES.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = ( sy-index * 100 ) DIV lv_sql_stmt_count
        text       = |Bitte warten... { sy-index } von { lv_sql_stmt_count }|.

    lv_sql_statement = lt_sql_stmt_tab[ sy-index ].

    GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
    TRY.
        lr_sql_stmt_ref->execute_query( lv_sql_statement ).

      CATCH cx_root INTO DATA(e_text).
        WRITE: / e_text->get_text( ).
    ENDTRY.
    GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
    lv_seconds = ( lv_endtime - lv_starttime ).

    cl_demo_output=>write_data( name = 'SQL-Statement'
                                value = lv_sql_statement ).
    cl_demo_output=>write_data( name = 'Runtime'
                                value = |{ lv_seconds }µs (ca. { lv_seconds / 1000000 }s)| ).
    cl_demo_output=>line( ).
  ENDDO.

  lr_sql_con_ref->close( ).

  lv_html = cl_demo_output=>get( ).
  cl_abap_browser=>show_html( EXPORTING
                                title        = 'Daten aus CSV'
                                html_string  = lv_html
                                container    = cl_gui_container=>default_screen ).
ENDMETHOD.


METHOD PERFORMANCER_V3.
  DATA: lv_html      TYPE string,
        lv_starttime TYPE i,
        lv_endtime   TYPE i,
        lv_seconds   TYPE i.

  DATA: lv_test_number TYPE i,
        lv_test_count  TYPE i.

  lv_test_count = 1.
  lv_test_number = 1.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = ( lv_test_number * 100 ) DIV lv_test_count
      text       = |Test { lv_test_number } von { lv_test_count }|.

  GET RUN TIME FIELD lv_starttime. " Startzeitpunkt
  GET RUN TIME FIELD lv_endtime. " Endzeitpunkt
  lv_seconds = ( lv_endtime - lv_starttime ).

  WRITE: |Test { lv_test_number }|,
         'test'  .
ENDMETHOD.
ENDCLASS.
