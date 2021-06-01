************************************************************************
****
**           _                         ______           _          _
*   __ _  __| | ___  ___ ___  ___     |__  __|  __ _   | |__      |
*  / _` |/ _` |/ _ \/ __/ __|/ _ \       | |   / _` |  | |__ \    |
* | (_| | (_| |  __/\__ \__ \ (_) |      | |  | (_| |  | |  | |   |
*  \__,_|\__,_|\___||___/___/\___/       |_|   \__,_|  |_|  | |   |_|
************************************************************************
*******
*
*
*&
************************************************************************
*******
REPORT ztc_performencer.



DATA: lv_t1          TYPE i,
      lv_t2          TYPE i,
      lv_time_result TYPE i.



DATA: lv_iteration  TYPE i VALUE 1,
      lv_repetition TYPE i VALUE 1.



DO lv_iteration TIMES.
  WRITE / | { sy-index }. Iteration |.

  GET RUN TIME FIELD lv_t1.

  DO lv_repetition TIMES.

    " Version 2  Schwer2            Ausgabewert: 99365x10   1 sekunde           wieso Groub by
SELECT large~title as k1, large~subject as k2, large~actor as k3, large~actress as k4, large~DIRECTOR as k5,
CASE large~imagex WHEN 'NicholasCage.png' THEN 'Example.com' ELSE large~imagex END AS k6,
MIN( large~unit_price ) as k7,
MAX( salerec~total_profit ) AS k8,
AVG( large~latitude ) AS k9,
SUM( CASE WHEN large~unit_cost <= 200 THEN large~unit_cost * 1000 END ) AS k10
FROM /ado/sql_all as large
LEFT OUTER JOIN /ado/sql_salerec AS salerec ON salerec~id_salerec = large~id_actor
WHERE large~zip >= 19090
GROUP BY large~title, large~subject, large~actor, large~actress, large~DIRECTOR, large~imagex
UNION ALL
SELECT medium~region as k1, medium~item_type as k2, emerg~description_of_emergency as k3, emerg~title_of_emergency as k4, emerg~township as k5,
CASE emerg~GENERAL_ADRESS WHEN 'SCHUYLKILL EXPY & WEADLEY RD OVERPASS' THEN 'Examplestreet' ELSE emerg~GENERAL_ADRESS END as k6,
MIN( medium~UNIT_PRICE ) as k7,
MAX( medium~UNITS_SOLD ) as k8,
AVG( emerg~LATITUDE ) as k9,
SUM( CASE WHEN medium~total_profit <= 200 THEN medium~total_profit * 1000 END ) as k10
FROM ztc_db_medium as medium
LEFT OUTER JOIN /ado/sql_911 AS emerg ON emerg~id_911 = medium~id_salerec
WHERE emerg~latitude >= 401065
GROUP BY medium~region, medium~item_type, emerg~description_of_emergency, emerg~title_of_emergency, emerg~township, emerg~GENERAL_ADRESS
INTO TABLE @DATA(tabelle)
BYPASSING BUFFER
.



  ENDDO.

  GET RUN TIME FIELD lv_t2.

  lv_time_result =  ( lv_t2 - lv_t1 ) / lv_repetition.

  WRITE 50  |SQL-Query: { lv_time_result }µs (ca. { lv_time_result / 1000000 }s)|.


  CLEAR:  lv_time_result.

  GET RUN TIME FIELD lv_t1.

  DO lv_repetition TIMES.

*    SELECT *
*    FROM ZTC_CDS_JOIN
*    INTO TABLE @DATA(lt_table2)
*    BYPASSING BUFFER.




  ENDDO.

  GET RUN TIME FIELD lv_t2.

  lv_time_result = ( lv_t2 - lv_t1 ) / lv_repetition.

  WRITE 100 |CDS-Query: { lv_time_result }µs (ca. { lv_time_result / 1000000 }s)|.

  SKIP.
  ULINE.
ENDDO.

*IF lt_table = lt_table2.
*  WRITE: 'gleich'.
*ELSE.
*  WRITE: 'ungleich'.
*
*ENDIF.




WRITE 'Test'.























































*DATA lower TYPE TABLE OF string.
*DATA upper TYPE TABLE OF string.
*DATA value TYPE TABLE OF string.
*
*
*lower[ 1 ] = 'a'.
*lower[ 2 ] = 'b'.
*lower[ 3 ] = 'c'.
*lower[ 4 ] = 'd'.
*lower[ 5 ] = 'e'.
*
*upper[ 1 ] = 'A'.
*upper[ 2 ] = 'B'.
*upper[ 3 ] = 'C'.
*upper[ 4 ] = 'D'.
*upper[ 5 ] = 'E'.
*
*value[ 1 ] = '1'.
*value[ 2 ] = '2'.
*value[ 3 ] = '3'.
*value[ 4 ] = '4'.
*value[ 5 ] = '5'.
*
*
*DATA(pw) = lower[ 2 ] && upper[ 5 ] && value[ 3 ].
*
*write pw.
*





*DATA :
*  g_raw_data TYPE truxs_t_text_data,
*  gs_film    TYPE ztc_minor,
*  gt_film    TYPE TABLE OF ztc_minor,
*  gt_all     TYPE TABLE OF ztc_minor.
*
*DATA :
*  lv_subrc  LIKE sy-subrc,
*  lt_it_tab TYPE filetable.
*
*
*SELECTION-SCREEN BEGIN OF BLOCK block-1 WITH FRAME TITLE TEXT-001.
*
*PARAMETERS : pa_file LIKE rlgrap-filename DEFAULT 'C:\Users\cayli\Desktop\DATEN\film - Kopie Excel.xlsx'.
*
*
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS chekbox AS CHECKBOX .
*SELECTION-SCREEN COMMENT 2(50) TEXT-001 FOR FIELD chekbox.
*SELECTION-SCREEN END OF LINE.
*
*
*SELECTION-SCREEN END OF BLOCK block-1.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_file.
*
*
*
*  TRY.
*      cl_gui_frontend_services=>file_open_dialog( EXPORTING
*                                                    file_filter = |CSV (*.*)\|*.*\|CSV (*.*)\|*.csv\|CSV (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
*                                                    "file_filter = |CSV (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
*                                                  CHANGING
*                                                    file_table  = lt_it_tab
*                                                    rc          = lv_subrc ).
*
*
*
*      IF lines( lt_it_tab ) > 0.
** ersten Tabelleneintrag lesen
*        pa_file = lt_it_tab[ 1 ]-filename.
*
*      ENDIF.
*
*    CATCH cx_root INTO DATA(e_text).
*      MESSAGE e_text->get_text( ) TYPE 'I'.
*  ENDTRY.
*
*  "notwendig?
*  LOOP AT lt_it_tab INTO pa_file.
*  ENDLOOP.
*
*START-OF-SELECTION.
*
*  IF chekbox = 'X'.
*    DELETE FROM ztc_table.
*  ENDIF.
*
*  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*    EXPORTING
*      i_line_header        = abap_false
*      i_tab_raw_data       = g_raw_data
*      i_filename           = pa_file
*    TABLES
*      i_tab_converted_data = gt_film
*    EXCEPTIONS
*      conversion_failed    = 1
*      OTHERS               = 2.
*
*
*  "Move Corresponding values only
*  "insert ZLDT_TABLE FROM TABLE gt_film.
*  MOVE-CORRESPONDING gt_film to gt_all.
*
*  INSERT ztc_table FROM TABLE gt_all.
*  WRITE 'übertragen'.
*
*
*  CALL TRANSACTION 'SE16N'.
*
*
*
*END-OF-SELECTION.
*
*






















































  "Version 5
*TYPES: BEGIN OF ty_data,
*          year    TYPE string,
*          length TYPE string,
*          titel TYPE string,
*          Subject TYPE string,
*          Actor TYPE string,
*          Actress TYPE string,
*          Director TYPE string,
*          Popularity TYPE string,
*          Awards TYPE string,
*          Image TYPE string,
*       END OF ty_data.
*
*DATA: it_raw TYPE truxs_t_text_data.
*
*PARAMETERS: p_file TYPE RLGRAP-FILENAME OBLIGATORY DEFAULT 'C:\Users\cayli\Desktop\DATEN\film - Kopie.csv'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*  DATA: lv_rc TYPE i.
*  DATA: it_files TYPE filetable.
*  DATA: lv_action TYPE i.
*
** File-Tabelle leeren, da hier noch alte Einträge von vorherigen Aufrufen drin stehen können
*  CLEAR it_files.
*
** FileOpen-Dialog aufrufen
*  TRY.
*      cl_gui_frontend_services=>file_open_dialog( EXPORTING
*                                                    file_filter = |XLSX (*.xlsx)\|*.xlsx\|XLSX (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
*                                                  CHANGING
*                                                    file_table  = it_files
*                                                    rc          = lv_rc
*                                                    user_action = lv_action ).
*
*      IF lv_action = cl_gui_frontend_services=>action_ok.
** wenn Datei ausgewählt wurde
*        IF lines( it_files ) > 0.
** ersten Tabelleneintrag lesen
*          p_file = it_files[ 1 ]-filename.
*        ENDIF.
*      ENDIF.
*
*    CATCH cx_root INTO DATA(e_text).
*      MESSAGE e_text->get_text( ) TYPE 'I'.
*  ENDTRY.
*
*START-OF-SELECTION.
*
*  DATA: it_datatab TYPE STANDARD TABLE OF ztc_table.
*  DATA: it_datatab_kopie TYPE STANDARD TABLE OF ztc_table.
*
** Import von Excel-Daten in interne Tabelle über die Ole-Schnittstelle
** Format der Tabelle ist in ty_data definiert
** Unterstützte Dateiformate: *.csv (*.txt), *.xls, *.xlsx
** Das Format der Fließkommazahlen bei CSV muß dem Gebietsschema
** von Excel entsprechen: 1,23 (Dezimalseparator = ',')
*  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*    EXPORTING
*      i_field_seperator    = ';'                            " Trennzeichen für CSV-Datei
*      i_line_header        = abap_false                      " Überschrift in der Tabelle   Datensatz mit Kopf oder ohne  -->> später varieeren
*      i_tab_raw_data       = it_raw
*      i_filename           = p_file "CONV rlgrap-filename( p_file ) " i_filename -> nur 128 Zeichen für Dateinamenlänge erlaubt
*    TABLES
*      i_tab_converted_data = it_datatab
*    EXCEPTIONS
*      conversion_failed    = 1
*      OTHERS               = 2.
*
*
*
*
*
*
*
*
*"Wieso nur mit Field-Symbol||| und so umändern, dass ID bzw erste Spalete nicht alles aufnimmt. Sodass erste Spalte (Primary Key) nicht über 100 Charachter einnehmen MUSS.
*
**  IF sy-subrc = 0.
**   LOOP AT it_datatab ASSIGNING FIELD-SYMBOL(<fs>).
**       SPLIT <fs>-id at ';' into <fs>-id <fs>-yearx <fs>-length <fs>-titel <fs>-subject <fs>-actor <fs>-actress <fs>-Director <fs>-Popularity
**       <fs>-Awards <fs>-Imagex.
**
**
**
**
**    ENDLOOP.
**  ELSE.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**  ENDIF.
*
*
*  insert ZTC_TABLE FROM TABLE it_datatab.
*WRITE 'übertragen'.




  "ENDE Version 5_____________________________________________________________________________________________________________________________________________________



  "________________________________________________________________________________________________________________________________________________________

  "Frage hierzu (siehe Word Dokument)
*TYPES: BEGIN OF ty_data,
*          year    TYPE string,
*          length TYPE string,
*          titel TYPE string,
*          Subject TYPE string,
*          Actor TYPE string,
*          Actress TYPE string,
*          Director TYPE string,
*          Popularity TYPE string,
*          Awards TYPE string,
*          Image TYPE string,
*       END OF ty_data.
*
*DATA: it_raw TYPE truxs_t_text_data.
*
*PARAMETERS: p_file TYPE file_table-filename OBLIGATORY DEFAULT 'C:\Users\cayli\Desktop\DATEN\film - Kopie.csv'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*  DATA: lv_rc TYPE i.
*  DATA: it_files TYPE filetable.
*  DATA: lv_action TYPE i.
*
** File-Tabelle leeren, da hier noch alte Einträge von vorherigen Aufrufen drin stehen können
*  CLEAR it_files.
*
** FileOpen-Dialog aufrufen
*  TRY.
*      cl_gui_frontend_services=>file_open_dialog( EXPORTING
*                                                    file_filter = |CSV (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
*                                                  CHANGING
*                                                    file_table  = it_files
*                                                    rc          = lv_rc
*                                                    user_action = lv_action ).
*
*      IF lv_action = cl_gui_frontend_services=>action_ok.
** wenn Datei ausgewählt wurde
*        IF lines( it_files ) > 0.
** ersten Tabelleneintrag lesen
*          p_file = it_files[ 1 ]-filename.
*        ENDIF.
*      ENDIF.
*
*    CATCH cx_root INTO DATA(e_text).
*      MESSAGE e_text->get_text( ) TYPE 'I'.
*  ENDTRY.
*
*START-OF-SELECTION.
*
*  DATA: it_datatab TYPE STANDARD TABLE OF ztc_table.
*  DATA: it_datatab_kopie TYPE STANDARD TABLE OF ZTC_TABLE.
*
** Import von Excel-Daten in interne Tabelle über die Ole-Schnittstelle
** Format der Tabelle ist in ty_data definiert
** Unterstützte Dateiformate: *.csv (*.txt), *.xls, *.xlsx
** Das Format der Fließkommazahlen bei CSV muß dem Gebietsschema
** von Excel entsprechen: 1,23 (Dezimalseparator = ',')
*  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*    EXPORTING
*      i_field_seperator    = ';'                            " Trennzeichen für CSV-Datei
*      i_line_header        = abap_false                      " Überschrift in der Tabelle   Datensatz mit Kopf oder ohne  -->> später varieeren
*      i_tab_raw_data       = it_raw
*      i_filename           = CONV rlgrap-filename( p_file ) " i_filename -> nur 128 Zeichen für Dateinamenlänge erlaubt
*    TABLES
*      i_tab_converted_data = it_datatab
*    EXCEPTIONS
*      conversion_failed    = 1
*      OTHERS               = 2.
*
*
*
*
*
*
*
*
*"Wieso nur mit Field-Symbol||| und so umändern, dass ID bzw erste Spalete nicht alles aufnimmt. Sodass erste Spalte (Primary Key) nicht über 100 Charachter einnehmen MUSS.
*
**  IF sy-subrc = 0.
**    LOOP AT it_datatab ASSIGNING FIELD-SYMBOL(<fs_line>).
**       SPLIT <fs_line>-id at ';' into <fs_line>-id <fs_line>-yearx <fs_line>-length <fs_line>-titel <fs_line>-subject <fs_line>-actor <fs_line>-actress <fs_line>-Director <fs_line>-Popularity
**       <fs_line>-Awards <fs_line>-Imagex.
**
**
**
**    ENDLOOP.
**  ELSE.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**  ENDIF.
**
**
**  insert ZTC_TABLE FROM TABLE it_datatab.
**
**
**WRITE 'ok'.
*
*
*"wieso geht das so nicht, mit append nicht aber mit insert?
*  IF sy-subrc = 0.
*    LOOP AT it_datatab INTO data(wa).
*       SPLIT wa-id at ';' into wa-id wa-yearx wa-length wa-titel wa-subject wa-actor wa-actress wa-Director wa-Popularity
*       wa-Awards wa-Imagex.
*
*       INSERT wa INTO it_datatab.
*
*
*    ENDLOOP.
*  ELSE.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*
*  insert ZTC_TABLE FROM TABLE it_datatab.
*
*
*WRITE 'ok'.





*  IF sy-subrc = 0.
*    LOOP AT it_datatab ASSIGNING FIELD-SYMBOL(<fs_line>).
*       SPLIT <fs_line>-id at ';' into <fs_line>-id <fs_line>-yearX <fs_line>-length <fs_line>-titel <fs_line>-subject <fs_line>-actor <fs_line>-actress <fs_line>-Director <fs_line>-Popularity
*       <fs_line>-Awards <fs_line>-ImageX.
*
*    ENDLOOP.
*  ELSE.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.


*WRITE 'ok'.


  "4.Version
*
*TYPES: BEGIN OF ty_data,
*          yearX    TYPE char10,
*          length TYPE char10,
*          titel TYPE char10,
*          Subject TYPE char10,
*          Actor TYPE char10,
*          Actress TYPE char10,
*          Director TYPE char10,
*          Popularity TYPE char10,
*          Awards TYPE char10,
*          ImageX TYPE char10,
*       END OF ty_data.
*
*DATA: it_raw TYPE truxs_t_text_data.
*
*PARAMETERS: p_file TYPE file_table-filename OBLIGATORY DEFAULT 'C:\Users\cayli\Desktop\DATEN\film - Kopie - Kopie.csv'.        "'C:\Users\cayli\Desktop\DATEN\film - Kopie - Kopie.csv'. "'C:\Users\cayli\Desktop\DATEN\film - Kopie.csv'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*  DATA: lv_rc TYPE i.
*  DATA: it_files TYPE filetable.
*  DATA: lv_action TYPE i.
*
** File-Tabelle leeren, da hier noch alte Einträge von vorherigen Aufrufen drin stehen können
*  CLEAR it_files.
*
** FileOpen-Dialog aufrufen
*  TRY.
*      cl_gui_frontend_services=>file_open_dialog( EXPORTING
*                                                    file_filter = |CSV (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
*                                                  CHANGING
*                                                    file_table  = it_files
*                                                    rc          = lv_rc
*                                                    user_action = lv_action ).
*
*      IF lv_action = cl_gui_frontend_services=>action_ok.
** wenn Datei ausgewählt wurde
*        IF lines( it_files ) > 0.
** ersten Tabelleneintrag lesen
*          p_file = it_files[ 1 ]-filename.
*        ENDIF.
*      ENDIF.
*
*    CATCH cx_root INTO DATA(e_text).
*      MESSAGE e_text->get_text( ) TYPE 'I'.
*  ENDTRY.
*
*START-OF-SELECTION.
*
*  "DATA: it_datatab TYPE STANDARD TABLE OF ty_data.
*  DATA: it_datatab TYPE STANDARD TABLE OF ztc_table.
*  DATA: wa_datatab TYPE ty_data.
*
*
*
** Import von Excel-Daten in interne Tabelle über die Ole-Schnittstelle
** Format der Tabelle ist in ty_data definiert
** Unterstützte Dateiformate: *.csv (*.txt), *.xls, *.xlsx
** Das Format der Fließkommazahlen bei CSV muß dem Gebietsschema
** von Excel entsprechen: 1,23 (Dezimalseparator = ',')
*  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*    EXPORTING
*      i_field_seperator    = ';'                            " Trennzeichen für CSV-Datei
*      i_line_header        = abap_false                      " Überschrift in der Tabelle   Datensatz mit Kopf oder ohne  -->> später varieeren
*      i_tab_raw_data       = it_raw
*      i_filename           = CONV rlgrap-filename( p_file ) " i_filename -> nur 128 Zeichen für Dateinamenlänge erlaubt
*    TABLES
*      i_tab_converted_data = it_datatab
*    EXCEPTIONS
*      conversion_failed    = 1
*      OTHERS               = 2.
*
*
*
*
*"FIELD-SYMBOLS: <fs> TYPE ty_data.
*FIELD-SYMBOLS: <fs> TYPE ZTC_TABLE.
*
*
*  IF sy-subrc = 0.
*    LOOP AT it_datatab ASSIGNING <fs>.        "Warum mit wa nicht möglich?
*       SPLIT <fs>-yearX at ';' into <fs>-yearX <fs>-length <fs>-titel <fs>-subject <fs>-actor <fs>-actress <fs>-Director <fs>-Popularity
*       <fs>-Awards <fs>-ImageX.
*
*
*    ENDLOOP.
*  ELSE.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*
*
**INSERT  ZTC_TABLE FROM table it_datatab.
**COMMIT WORK.
**
*
*
*
*
*
*
*
*
* WRITE 'ok'.
*
*




























*"3.Version
*
*
*
*DATA: lt_file_table    TYPE filetable,
*       lv_rc            TYPE i,
*       lv_file          TYPE string,
*       lv_filename      TYPE   rlgrap-filename,
*       lt_intern        TYPE STANDARD TABLE OF alsmex_tabline,
*       ls_intern        TYPE alsmex_tabline,
*       lt_intern_zeilen TYPE STANDARD TABLE OF alsmex_tabline,
*       ls_intern_zeilen TYPE alsmex_tabline.
*
* "Open-Dialog (F4)
*  CALL METHOD cl_gui_frontend_services=>file_open_dialog
*    EXPORTING
*      window_title      = 'Datei auswählen'
*      file_filter       = '*'
*      initial_directory = 'C:\Users\cayli\Desktop\DATEN\film - Kopie.csv'
*      multiselection    = ' '
*    CHANGING
*      file_table        = lt_file_table
*      rc                = lv_rc
*    EXCEPTIONS
*      OTHERS            = 3.
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ELSE.
*
*      READ TABLE  lt_file_table INTO lv_file INDEX 1.
*      lv_filename = lv_file.
*    ENDIF.
*
*
*
*   "Upload der Excel-Datei
*    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
*     EXPORTING
*        filename                = lv_filename
*        i_begin_col             = 1
*        i_begin_row             = 1
*        i_end_col               = 30
*        i_end_row               = 56000
*      TABLES
*        intern                  = lt_intern
*      EXCEPTIONS
*        inconsistent_parameters = 1
*        upload_ole              = 2
*        OTHERS                  = 3.
*
*    IF sy-subrc <> 0.
*    ENDIF.
*
*    SORT lt_intern BY row  "Zeile
*                      col. "spalte.
*
*    lt_intern_zeilen = lt_intern.
*    DELETE ADJACENT DUPLICATES FROM lt_intern_zeilen COMPARING row.
*
*   "Schleife über alle Zeilen
*   LOOP AT lt_intern_zeilen INTO ls_intern_zeilen.
*
*     "Innerere Schleife über alle Spalten einer Zeile
*     LOOP AT lt_intern INTO ls_intern WHERE row = ls_intern_zeilen-row.
*       "Zuweisung der Excel-Werte an eine interne Struktur
*       WRITE: ls_intern-col,
*              ls_intern-row,
*              ls_intern-value.
*     ENDLOOP.
*
*   ENDLOOP.
*





*
*"2.version
*TYPES: BEGIN OF ty_data,
*         year    TYPE string,
*         length TYPE string,
*       END OF ty_data.
*
*DATA: it_raw TYPE truxs_t_text_data.
*
*PARAMETERS: p_file TYPE file_table-filename OBLIGATORY DEFAULT 'C:\Users\cayli\Desktop\DATEN\film - Kopie.csv'.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*  DATA: lv_rc TYPE i.
*  DATA: it_files TYPE filetable.
*  DATA: lv_action TYPE i.
*
** File-Tabelle leeren, da hier noch alte Einträge von vorherigen Aufrufen drin stehen können
*  CLEAR it_files.
*
** FileOpen-Dialog aufrufen
*  TRY.
*      cl_gui_frontend_services=>file_open_dialog( EXPORTING
*                                                    file_filter = |CSV (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|CSV (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
*                                                  CHANGING
*                                                    file_table  = it_files
*                                                    rc          = lv_rc
*                                                    user_action = lv_action ).
*
*      IF lv_action = cl_gui_frontend_services=>action_ok.
** wenn Datei ausgewählt wurde
*        IF lines( it_files ) > 0.
** ersten Tabelleneintrag lesen
*          p_file = it_files[ 1 ]-filename.
*        ENDIF.
*      ENDIF.
*
*    CATCH cx_root INTO DATA(e_text).
*      MESSAGE e_text->get_text( ) TYPE 'I'.
*  ENDTRY.
*
*START-OF-SELECTION.
*
*  DATA: it_datatab TYPE STANDARD TABLE OF ty_data.
*
** Import von Excel-Daten in interne Tabelle über die Ole-Schnittstelle
** Format der Tabelle ist in ty_data definiert
** Unterstützte Dateiformate: *.csv (*.txt), *.xls, *.xlsx
** Das Format der Fließkommazahlen bei CSV muß dem Gebietsschema
** von Excel entsprechen: 1,23 (Dezimalseparator = ',')
*  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*    EXPORTING
*      i_field_seperator    = ';'                            " Trennzeichen für CSV-Datei
*      i_line_header        = abap_false                      " Überschrift in der Tabelle   Datensatz mit Kopf oder ohne  -->> später varieeren
*      i_tab_raw_data       = it_raw
*      i_filename           = CONV rlgrap-filename( p_file ) " i_filename -> nur 128 Zeichen für Dateinamenlänge erlaubt
*    TABLES
*      i_tab_converted_data = it_datatab
*    EXCEPTIONS
*      conversion_failed    = 1
*      OTHERS               = 2.
*
*  IF sy-subrc = 0.
*    LOOP AT it_datatab ASSIGNING FIELD-SYMBOL(<fs_line>).
*      WRITE: / <fs_line>-year, <fs_line>-length.
*    ENDLOOP.
*  ELSE.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.




















*DATA data_tab TYPE TABLE OF string.
*DATA wa LIKE LINE OF data_tab.
*
*
*
*
*
*CALL METHOD cl_gui_frontend_services=>gui_upload
*  EXPORTING
*    filename                = 'C:\Users\cayli\Desktop\DATEN\film.csv'
*    filetype                = 'ASC'
*    has_field_separator     = SPACE
*    header_length           = 0
*    read_by_line            = 'X'
**    dat_mode                = SPACE
**    codepage                = SPACE
**    ignore_cerr             = ABAP_TRUE
**    replacement             = '#'
**    virus_scan_profile      =
**  IMPORTING
**    filelength              =
**    header                  =
*  CHANGING
*    data_tab                = data_tab
**    isscanperformed         = SPACE
**  EXCEPTIONS
**    file_open_error         = 1
**    file_read_error         = 2
**    no_batch                = 3
**    gui_refuse_filetransfer = 4
**    invalid_type            = 5
**    no_authority            = 6
**    unknown_error           = 7
**    bad_data_format         = 8
**    header_not_allowed      = 9
**    separator_not_allowed   = 10
**    header_too_long         = 11
**    unknown_dp_error        = 12
**    access_denied           = 13
**    dp_out_of_memory        = 14
**    disk_full               = 15
**    dp_timeout              = 16
**    not_supported_by_gui    = 17
**    error_no_gui            = 18
**    others                  = 19
*        .
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.
*
*
*LOOP AT data_tab INTO wa.
*  WRITE wa.
*ENDLOOP.


























































*FIELD-SYMBOLS: <fs2> TYPE string.
*
*CALL METHOD cl_gui_frontend_services=>gui_upload
*  EXPORTING
*    filename                = 'C:\Users\cayli\Desktop\DATEN\film.csv'
*    filetype                = 'ASC'
**   has_field_separator     = SPACE
**   header_length           = 0
**   read_by_line            = 'X'
**   dat_mode                = SPACE
**   codepage                = SPACE
**   ignore_cerr             = ABAP_TRUE
**   replacement             = '#'
**   virus_scan_profile      =
* "IMPORTING
**   filelength              =
*"    header                  = ls_header
*  CHANGING
*    data_tab                = data_tab
**   isscanperformed         = SPACE
*  EXCEPTIONS
*    file_open_error         = 1
*    file_read_error         = 2
*    no_batch                = 3
*    gui_refuse_filetransfer = 4
*    invalid_type            = 5
*    no_authority            = 6
*    unknown_error           = 7
*    bad_data_format         = 8
*    header_not_allowed      = 9
*    separator_not_allowed   = 10
*    header_too_long         = 11
*    unknown_dp_error        = 12
*    access_denied           = 13
*    dp_out_of_memory        = 14
*    disk_full               = 15
*    dp_timeout              = 16
*    not_supported_by_gui    = 17
*    error_no_gui            = 18
*    OTHERS                  = 19.
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.
*
*
**LOOP AT data_tab INTO <fs2>.
**  WRITE <fs2>.
**ENDLOOP.
*
*
**LOOP AT data_tab ASSIGNING FIELD-SYMBOL(<fs>).
**  WRITE <fs>.
**ENDLOOP.
