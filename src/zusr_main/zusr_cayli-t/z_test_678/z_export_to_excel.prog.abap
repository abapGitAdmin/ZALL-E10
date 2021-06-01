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
REPORT Z_EXPORT_TO_EXCEL.


*data: begin of itab occurs 0,
*      vbeln like vbap-vbeln,
*      posnr like vbap-posnr,
*      end of itab.
*
*data:  itab1 type TRUXS_T_TEXT_DATA.
*  select vbeln
*         posnr
*         up to 10 rows
*         from vbap
*         into table itab.


*
**DATA lt_movies2 TYPE /ado/sql_film.
*
*SELECT * FROM /ado/sql_movies INTO TABLE @DATA(lt_movies).
*
*CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
* EXPORTING
*   I_FIELD_SEPERATOR          = ';'
*  TABLES
*    I_TAB_SAP_DATA             = lt_movies
* CHANGING
*   I_TAB_CONVERTED_DATA       =  lt_movies
* EXCEPTIONS
*   CONVERSION_FAILED          = 1
*   OTHERS                     = 2
*          .
*IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
*
**   CALL FUNCTION 'GUI_DOWNLOAD'
**    EXPORTING
**      filename = 'C:\TEMP\abc.csv'
**    TABLES
**      data_tab = lt_movies
**    EXCEPTIONS
**      OTHERS   = 1.








































PARAMETERS: p_tab TYPE dd02l-tabname,
            p_sep TYPE c DEFAULT ';'.

DATA: lv_action   TYPE i,
      lv_filename TYPE string,
      lv_fullpath TYPE string,
      lv_path     TYPE string.

DATA: lt_csv_records       TYPE string_table,
      lv_row_string        TYPE string,
      lt_header_components TYPE string_table,
      lt_row_components    TYPE string_table,
      lv_row_width         TYPE i,
      lv_component_name    TYPE string,
      lv_component_value   TYPE string.

DATA: lr_istruc TYPE REF TO data,
      lr_itab   TYPE REF TO data.

FIELD-SYMBOLS: <ls_istruc>      TYPE any,
               <lt_itab>        TYPE STANDARD TABLE,
              " <lt_itab2>        TYPE STANDARD TABLE,
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

* Save-Dialog
cl_gui_frontend_services=>file_save_dialog( EXPORTING
                                              default_file_name = 'Unbenannt.csv'
                                              default_extension = 'csv'
                                              file_filter       = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
                                            CHANGING
                                              filename          = lv_filename
                                              path              = lv_path
                                              fullpath          = lv_fullpath
                                              user_action       = lv_action ).
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

* fehlerhafte Benutzereingabe
IF lv_action <> cl_gui_frontend_services=>action_ok.
  MESSAGE 'Fehler beim Auswählen der Datei!' TYPE 'S' DISPLAY LIKE 'E'.
  RETURN.
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

SELECT * FROM (p_tab) INTO TABLE <lt_itab> ORDER BY PRIMARY KEY.
  """""


*****SELECT * FROM ztc_db_large INTO TABLE @DATA(lt_itab) ORDER BY PRIMARY KEY.
DATA lt_itab2 TYPE TABLE OF ztc_db_large.

DATA ls_struct TYPE ztc_db_large.

  do 100000 TIMES.

   DATA(counter) = sy-index + 900000.
   MOVE-CORRESPONDING <lt_itab>[ counter ] to ls_struct.
   APPEND ls_struct to lt_itab2.


    ENDDO.

"""""
LOOP AT lt_itab2 INTO <ls_istruc>.
  DO.
    ASSIGN COMPONENT sy-index OF STRUCTURE <ls_istruc> TO <lv_istruc_comp>.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    if sy-index = 1.
      lv_row_string = <lv_istruc_comp>.
    else.
      lv_row_string = |{ lv_row_string  }{ p_sep }{ <lv_istruc_comp> }|.
    endif.
  ENDDO.

  APPEND lv_row_string TO lt_csv_records.
  CLEAR lv_row_string.
ENDLOOP.

* Datei lokal speichern
  cl_gui_frontend_services=>gui_download( EXPORTING
                                            filename     = lv_fullpath
                                            filetype     = 'ASC'
                                          CHANGING
                                            data_tab     = lt_csv_records ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
