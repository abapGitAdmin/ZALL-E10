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
REPORT ZTC_PERFORMENCER_GUI_UPLOAD.

*TYPES : BEGIN OF ztc_minor,
*          mandant          TYPE string,
*          fluggesellschaft TYPE string,
*          flugnummer       TYPE string,
*          land_ab          TYPE string,
*          abflugstadt      TYPE string,
*          startflughafen   TYPE string,
*          land_an          TYPE string,
*          ankunftstadt     TYPE string,
*          zielflughafen    TYPE string,
*          flugdauer        TYPE string,
*          abflug           TYPE string,
*          ankunftszeit     TYPE string,
*          entfernung       TYPE string,
*          einheit          TYPE string,
*          charter          TYPE string,
*          tage             TYPE string,
*        END OF ztc_minor.

* Tabellentypen
TYPES: ty_it_csv TYPE STANDARD TABLE OF ztc_minor WITH DEFAULT KEY.

* Überschriften vorhanden

"PARAMETERS : pa_file LIKE rlgrap-filename DEFAULT 'C:\Users\cayli\Desktop\DATEN\film - Kopie Excel.xlsx'.


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
        DATA(it_strings) = VALUE string_table( ).

* eingelesene Datei zeilenweise als Stringdaten einlesen
        cl_gui_frontend_services=>gui_upload( EXPORTING
                                                filename = CONV #( it_files[ 1 ]-filename )
                                                filetype = 'ASC'             " Dateityp BIN, ASC, DAT
                                              CHANGING
                                                data_tab = it_strings ).           " Übergabetabelle für Datei-Inhalt

        cl_demo_output=>write_data( it_strings ).

* Wenn mit Header, dann ab Zeile 2, sonst gleich ab Zeile 1
        DATA(lv_startzeile) = 2.

* Je nach Vorhandensein des Headers prüfen, ob genug Zeilen in der Tabelle
        IF ( lines( it_strings ) > lv_startzeile - 1 ).
* Ausgabetabelle mit ausgesplitteten CSV-Daten
          DATA(it_csv) = VALUE ty_it_csv( ).

* Eingelesene Strings durchlaufen, Start bei Zeile 1 (mit Header) oder 2 (mit Header)
          LOOP AT it_strings ASSIGNING FIELD-SYMBOL(<z>) FROM lv_startzeile.
* neue Ausgabezeile
            DATA(lv_csv_line) = VALUE ztc_minor( ).

* String anhand des Separators aufsplitten
            SPLIT <z> AT ';' INTO TABLE DATA(it_columns).

* Wenn anzahl der Splitelemente == Anzahl Felder in der CSV-Struktur
            IF lines( it_columns ) = 16.
* gesplittete Daten in die neue CSV-Zeile übernehmen
              lv_csv_line-id = it_columns[ 1 ].
              lv_csv_line-yearx = it_columns[ 2 ].
*              lv_csv_line-flugnummer = it_columns[ 3 ].
*              lv_csv_line-land_ab = it_columns[ 4 ].
*              lv_csv_line-abflugstadt = it_columns[ 5 ].
*              lv_csv_line-startflughafen = it_columns[ 6 ].
*              lv_csv_line-land_an = it_columns[ 7 ].
*              lv_csv_line-ankunftstadt = it_columns[ 8 ].
*              lv_csv_line-zielflughafen = it_columns[ 9 ].
*              lv_csv_line-flugdauer = it_columns[ 10 ].
*              lv_csv_line-abflug = it_columns[ 11 ].
*              lv_csv_line-ankunftszeit = it_columns[ 12 ].
*              lv_csv_line-entfernung = it_columns[ 13 ].
*              lv_csv_line-einheit = it_columns[ 14 ].
*              lv_csv_line-charter = it_columns[ 15 ].
*              lv_csv_line-tage = it_columns[ 16 ].
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

WRITE ''.
