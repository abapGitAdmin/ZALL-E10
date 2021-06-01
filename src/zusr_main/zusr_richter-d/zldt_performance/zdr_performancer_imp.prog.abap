*&---------------------------------------------------------------------*
*&  Include           ZDR_IMPORT_CSV
*&---------------------------------------------------------------------*

TRY.
    DATA: lv_rc TYPE i.
    DATA: it_files TYPE filetable.
    DATA: lv_action TYPE i.

* FileOpen-Dialog aufrufen
    cl_gui_frontend_services=>file_open_dialog( EXPORTING
                                                  file_filter    = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
                                                  multiselection = abap_false
                                                CHANGING
                                                  file_table     = it_files
                                                  rc             = lv_rc
                                                  user_action    = lv_action ).

    IF lv_action = cl_gui_frontend_services=>action_ok.
* wenn mind. eine Dateie ausgewählt worden ist
      IF lines( it_files ) = 1.

* Tabelle für Einlesedaten
*        DATA(it_strings) = VALUE string_table( ).
        DATA it_strings TYPE TABLE OF string.

* eingelesene Datei zeilenweise als Stringdaten einlesen
        cl_gui_frontend_services=>gui_upload( EXPORTING
                                                filename = CONV #( it_files[ 1 ]-filename )
                                                filetype = 'ASC'             " Dateityp BIN, ASC, DAT
                                              CHANGING
                                                data_tab = it_strings ).           " Übergabetabelle für Datei-Inhalt

        cl_demo_output=>write_data( it_strings ).

* Wenn mit Header, dann ab Zeile 2, sonst gleich ab Zeile 1
        DATA(lv_startzeile) = COND i( WHEN p_head = abap_true THEN 2 ELSE 1 ).

* Je nach Vorhandensein des Headers prüfen, ob genug Zeilen in der Tabelle
        IF ( lines( it_strings ) > lv_startzeile - 1 ).
* Ausgabetabelle mit ausgesplitteten CSV-Daten
          DATA(it_csv) = VALUE ty_it_csv( ).

* Eingelesene Strings durchlaufen, Start bei Zeile 1 (mit Header) oder 2 (mit Header)
          LOOP AT it_strings ASSIGNING FIELD-SYMBOL(<z>) FROM lv_startzeile.
* neue Ausgabezeile
            DATA(lv_csv_line) = VALUE zldt_suprem( ).

* String anhand des Separators aufsplitten
            SPLIT <z> AT p_sep INTO TABLE DATA(it_columns).

* Wenn anzahl der Splitelemente == Anzahl Felder in der CSV-Struktur
            IF lines( it_columns ) = 3.
* gesplittete Daten in die neue CSV-Zeile übernehmen
              DO 3 TIMES.
                ASSIGN COMPONENT sy-index OF STRUCTURE lv_csv_line TO FIELD-SYMBOL(<fs_comp>).
                IF sy-subrc = 0.
                  <fs_comp> = it_columns[ sy-index ].
                ENDIF.
              ENDDO.
            ENDIF.

* neue CSV-Zeile an Ausgabetabelle anfügen
            APPEND lv_csv_line TO it_csv.
          ENDLOOP.

          cl_demo_output=>write_data( it_csv ).

* HTML-Code vom Demo-Output holen
          DATA(lv_html) = cl_demo_output=>get( ).
* Daten im Inline-Browser im SAP-Fenster anzeigen
          cl_abap_browser=>show_html( EXPORTING
                                        title        = 'Daten aus CSV'
                                        html_string  = lv_html
                                        container    = cl_gui_container=>default_screen ).

* cl_gui_container=>default_screen erzwingen
          WRITE: space.
        ENDIF.
      ENDIF.
    ENDIF.
  CATCH cx_root INTO DATA(e_text).
    MESSAGE e_text->get_text( ) TYPE 'I'.
ENDTRY.
