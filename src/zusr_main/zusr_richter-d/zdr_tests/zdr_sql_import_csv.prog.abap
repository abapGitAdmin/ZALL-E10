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
*&         $USER  $DATE
************************************************************************
*******
REPORT zdr_sql_import_csv.

PARAMETERS: p_tab TYPE dd02l-tabname,
            p_sep TYPE c DEFAULT ';',
            p_clr TYPE abap_bool DEFAULT abap_true.

DATA: lt_file_table  TYPE filetable,
      lv_rc          TYPE i,
      lv_user_action TYPE i.

DATA: lt_csv_records     TYPE string_table,
      lt_row_components  TYPE string_table,
      lv_row_width       TYPE i,
      lv_component_value TYPE string.

DATA: lr_istruc TYPE REF TO data,
      lr_itab   TYPE REF TO data.

FIELD-SYMBOLS: <lv_row_string>  TYPE string,
               <ls_istruc>      TYPE any,
               <lt_itab>        TYPE STANDARD TABLE,
               <lv_istruc_comp> TYPE data.

IF p_tab IS INITIAL.
  MESSAGE 'Bitte gib eine Datenbanktabelle an!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.
SELECT SINGLE * FROM dd02l WHERE tabname = @p_tab INTO @DATA(ls_dd021).
IF sy-subrc <> 0.
  MESSAGE 'Bitte wähle eine gültige Datenbanktabelle aus!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

* eine Datei auswählen
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

* fehlerhafte Benutzereingabe
IF lv_user_action <> cl_gui_frontend_services=>action_ok OR
   lines( lt_file_table ) <> 1.
  MESSAGE 'Fehler beim Auswählen der Datei. Bitte wähle genau eine Datei aus!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

* Datei in interne String-Tabelle hochladen
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

* Struktur zur Laufzeit erzeugen
CREATE DATA lr_istruc TYPE (p_tab).
ASSIGN lr_istruc->* TO <ls_istruc>.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

* interne Tabelle zur Laufzeit erzeugen
CREATE DATA lr_itab TYPE TABLE OF (p_tab).
ASSIGN lr_itab->* TO <lt_itab>.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

* Daten der eingelesenen String-Tabelle in die Spalten aufteilen und entsprechend in <lt_itab> zwischenspeichern
LOOP AT lt_csv_records ASSIGNING <lv_row_string>.
*  aufsplitten des Zeileninhalts
  SPLIT <lv_row_string> AT p_sep INTO TABLE lt_row_components.
  AT FIRST.
    lv_row_width = lines( lt_row_components ).
  ENDAT.
  IF lines( lt_row_components ) <> lv_row_width.
    MESSAGE 'Fehlerhaftes Format der CSV-Datei. Tabellenbreite nicht überall gleich!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

*  Index einfügen
  ASSIGN COMPONENT 1 OF STRUCTURE <ls_istruc> TO <lv_istruc_comp>.
  <lv_istruc_comp> = sy-tabix - 1.

*  Datensatz der CSV-Datei den Komponenten der Datenbanktabelle entsprechend zuteilen
  DO lv_row_width TIMES.
    ASSIGN COMPONENT ( sy-index + 1 ) OF STRUCTURE <ls_istruc> TO <lv_istruc_comp>.
    IF sy-subrc <> 0.
      MESSAGE 'Fehler beim Zuordnen der Komponenten der CSV zu den Feldern der Struktur! (evtl. Header oder CSV-Format falsch)' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    lv_component_value = lt_row_components[ sy-index ].
    IF lv_component_value CO ' ' OR
       lv_component_value = 'NA'.
      CLEAR <lv_istruc_comp>.
    ELSE.
      TRY.
*          IF p_tab = '/ADO/SQL_TEST' AND sy-index = 6.
*            lv_component_value = |{ lv_component_value+6(4) }{ lv_component_value+3(2) }{ lv_component_value+0(2) }{ lv_component_value+11(2) }{ lv_component_value+14(2) }|.
*          ENDIF.
          IF p_tab = '/ADO/SQL_911' AND sy-index = 6.
            lv_component_value = |{ lv_component_value+6(4) }{ lv_component_value+3(2) }{ lv_component_value+0(2) }{ lv_component_value+11(2) }{ lv_component_value+14(2) }|.
          ENDIF.
          <lv_istruc_comp> = lv_component_value.
        CATCH cx_sy_conversion_no_number.
          MESSAGE 'Fehlerhafte Typkonvertierung beim einlesen der CSV-Datei' TYPE 'S' DISPLAY LIKE 'E'.
          RETURN.
      ENDTRY.
    ENDIF.
  ENDDO.

*  Datensatz in der internen Tabelle zwischenspiechern
  APPEND <ls_istruc> TO <lt_itab>.
ENDLOOP.

* Inhalt der Datenbanktabelle vorher löschen falls erwünscht
IF p_clr = abap_true.
  TRY.
      DELETE FROM (p_tab).
    CATCH cx_sy_open_sql_db.
      MESSAGE 'Fehler beim Löschen des Inhalts der Datenbank!' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.
ENDIF.

* interne Tabelle auf die Datenbank schreiben
TRY.
    INSERT (p_tab) FROM TABLE <lt_itab>.
  CATCH cx_sy_open_sql_db.
    MESSAGE 'Fehler beim Schreiben auf die Datenbank! (etvl. ehlerhaftes Format der CSV-Datei, Key nicht eindeutig)' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
ENDTRY.

* SE16N aufrufen, um Inhalt der der Datenbanktabelle anzuzeigen
SET PARAMETER ID 'DTB' FIELD p_tab.
CALL TRANSACTION 'SE16N'.
