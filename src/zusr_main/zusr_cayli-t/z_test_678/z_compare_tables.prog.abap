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
REPORT Z_COMPARE_TABLES.

DATA: lt_files       TYPE filetable,
          lv_rc          TYPE i,
          lv_action      TYPE i,

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

    """""""""

    DATA: lt_files2       TYPE filetable,
          lv_rc2          TYPE i,
          lv_action2      TYPE i,

          lt_csv_records2 TYPE string_table.

  cl_gui_frontend_services=>file_open_dialog( EXPORTING  file_filter             = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
                                                           multiselection          = abap_true
                                                CHANGING   file_table              = lt_files2
                                                           rc                      = lv_rc2
                                                           user_action             = lv_action2
                                                EXCEPTIONS file_open_dialog_failed = 1
                                                           cntl_error              = 2
                                                           error_no_gui            = 3
                                                           not_supported_by_gui    = 4
                                                           OTHERS                  = 5 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


    IF lv_action2 <> cl_gui_frontend_services=>action_ok OR
       lines( lt_files2 ) <> 1.
      MESSAGE 'Fehler beim Auswählen der Datei' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    TRY.
        cl_gui_frontend_services=>gui_upload( EXPORTING
                                                filename = CONV #( lt_files2[ 1 ]-filename )
                                                filetype = 'ASC'
                                              CHANGING
                                                data_tab = lt_csv_records2 ).
      CATCH cx_root INTO DATA(e_text22).
        MESSAGE e_text2->get_text( ) TYPE 'E'.
    ENDTRY.

IF lt_csv_records = lt_csv_records2.

  WRITE 'gleich'.
  ELSE.
    WRITE 'ungleich'.

ENDIF.
