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

REPORT /ado/importer.

** Überschriften vorhanden
*PARAMETERS: p_head AS CHECKBOX DEFAULT ''.
* Separator / Trennzeichen
PARAMETERS: p_sep TYPE char1 DEFAULT ','.
* Tabelle vorher leeren
PARAMETERS: p_delete AS CHECKBOX.

PERFORM import_csv_to_datacatalog.

*&---------------------------------------------------------------------*
*&      Form  IMPORT_CSV_TO_DATACATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM import_csv_to_datacatalog .
  DATA: lt_files       TYPE filetable,
        lv_rc          TYPE i,
        lv_action      TYPE i,
        descr_ref      TYPE REF TO cl_abap_structdescr,
        lt_csv_records TYPE string_table.

  cl_gui_frontend_services=>file_open_dialog( EXPORTING  file_filter             = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
                                                         multiselection          = abap_true
                                              CHANGING   file_table              = lt_files
                                                         rc                      = lv_rc
                                                         user_action             = lv_action
                                              EXCEPTIONS file_open_dialog_failed = 1
                                                         cntl_error              = 2
                                                         error_no_gui            = 3
                                                         not_supported_by_gui    = 4
                                                         OTHERS                  = 5 ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  IF lv_action <> cl_gui_frontend_services=>action_ok OR
     lines( lt_files ) <> 1.
    MESSAGE 'Fehler beim Auswählen der Datei' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  TRY.
      cl_gui_frontend_services=>gui_upload( EXPORTING
                                              filename = CONV #( lt_files[ 1 ]-filename )
                                              filetype = 'ASC'
                                            CHANGING
                                              data_tab = lt_csv_records ).
    CATCH cx_root INTO DATA(e_text2).
      MESSAGE e_text2->get_text( ) TYPE 'E'.
  ENDTRY.

  IF p_delete = abap_true.
    DELETE FROM /ado/sql_datacat.
  ENDIF.

** zu viele SQL zugriffe + duplicate werden nicht abgefangen (sy-subrc = 4)!
** -> "insert from table" und vorher die tabelle mit select lesen!
*  DATA(lt_table) = VALUE /ado/sql_datacat(
*    FOR <>
*  )
  DATA(ls_datacat) = VALUE /ado/sql_datacat( ).
  LOOP AT lt_csv_records ASSIGNING FIELD-SYMBOL(<row>).

    AT FIRST.
      TRANSLATE <row> TO UPPER CASE.
      SPLIT <row> AT p_sep INTO TABLE DATA(lt_header).
      CONTINUE.
    ENDAT.

    SPLIT <row> AT p_sep INTO TABLE DATA(lt_columns).
    LOOP AT lt_columns ASSIGNING FIELD-SYMBOL(<example>) WHERE NOT table_line CO ' '.
*      ls_datacat-fieldname = lt_header[ sy-tabix ].
*      ls_datacat-exampledata = <example>.
    ENDLOOP.
  ENDLOOP.

*  INSERT /ado/sql_datacat FROM ls_datacat.

  SET PARAMETER ID 'DTB' FIELD '/ADO/SQL_DATACAT'.
  CALL TRANSACTION 'SE16N'.

ENDFORM.

FORM add_data_to_database.

  TRY.
      TABLES: ztc_table.
      DATA: lt_files  TYPE filetable,
            lv_rc     TYPE i,
            lv_action TYPE i.

      cl_gui_frontend_services=>file_open_dialog( EXPORTING
                                                    file_filter    = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
                                                    multiselection = abap_true
                                                  CHANGING
                                                    file_table     = lt_files
                                                    rc             = lv_rc
                                                    user_action    = lv_action ).

      IF lv_action = cl_gui_frontend_services=>action_ok AND
         lines( lt_files ) = 1.

        DATA(lt_csv_records) = VALUE string_table( ).
        cl_gui_frontend_services=>gui_upload( EXPORTING
                                                filename = CONV #( lt_files[ 1 ]-filename )
                                                filetype = 'DAT'
                                              CHANGING
                                                data_tab = lt_csv_records ).

        LOOP AT lt_csv_records ASSIGNING FIELD-SYMBOL(<row>).
          DATA(ls_datacat) = VALUE ztc_table( ).

          SPLIT <row> AT p_sep INTO TABLE DATA(lt_columns).

          DO.
            ASSIGN COMPONENT sy-index + 11 OF  STRUCTURE ls_datacat TO FIELD-SYMBOL(<fs_comp>).
            IF sy-index > ( lines( lt_columns )  ).
              EXIT.
            ENDIF.

            <fs_comp> =  lt_columns[ sy-index ].
          ENDDO.

          LOOP AT lt_csv_records INTO DATA(ls_data).
            "für jede weitere Excel Tabelle    ID MUSS berücksichtigt werden

            "für jede weitere Excel Tabelle

            "für Arzt
*          SPLIT ls_data AT ',' INTO ls_film-id ls_film-name ls_film-gender ls_film-dop ls_film-zipcode ls_film-employment_status ls_film-education ls_film-marital_status ls_film-children ls_film-ancestry ls_film-avg_commute ls_film-daily_internet_use
*          ls_film-military_service ls_film-disease.
*          APPEND ls_film TO lt_film.
            "für Arzt

            "für film
*          SPLIT ls_data AT ';' INTO ls_film-id ls_film-yearx ls_film-length ls_film-titel ls_film-subject ls_film-actor ls_film-actress ls_film-director ls_film-popularity ls_film-awards ls_film-imagex.
*          APPEND ls_film TO lt_film.
            "für film

          ENDLOOP.
          "
          INSERT ztc_table FROM ls_datacat.

        ENDLOOP.

        CALL TRANSACTION 'SE16N'.

      ENDIF.
    CATCH cx_root INTO DATA(e_text).
      MESSAGE e_text->get_text( ) TYPE 'I'.
  ENDTRY.

ENDFORM.
