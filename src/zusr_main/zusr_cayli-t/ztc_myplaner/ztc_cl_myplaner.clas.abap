class ZTC_CL_MYPLANER definition
  public
  final
  create public .

public section.

  data GS_MYPLANER type ZTC_T_MYPLANER .
  data O_TXT type ref to CL_GUI_TEXTEDIT .

  methods CONSTRUCTOR
    importing
      !IS_MYPLANER type ZTC_T_MYPLANER .
  methods INSERT_TABLE
    importing
      !P_TASK type ZTC_T_MYPLANER .
  methods SET_TASK .
  methods GET_TASK
    importing
      !TASK_VALUES type ZTC_T_MYPLANER .
  class-methods GET_THEMA
    importing
      !P_O_TXT type ref to CL_GUI_TEXTEDIT
    exporting
      !P_TEXT type CHAR100 .
  methods EXPORT_TO_EXCEL .
  methods IMPORT_FROM_EXCEL .
  methods COLOR_PRIO .
protected section.
private section.

  methods BUILD_ALV .
  methods SORT_DATE .
  methods SORT_PRIO .
  methods SORT_STATUS .
ENDCLASS.



CLASS ZTC_CL_MYPLANER IMPLEMENTATION.


  method BUILD_ALV.
  endmethod.


  method COLOR_PRIO.
  endmethod.


  method CONSTRUCTOR.

    gs_myplaner = is_myplaner.

    "metodenaufrufe












  endmethod.


  method EXPORT_TO_EXCEL.

    TRY.
* Testdaten lesen
    SELECT * FROM t001 INTO TABLE @DATA(it_t001).

    IF sy-subrc = 0.
* Header erzeugen
      DATA: it_columns TYPE if_fdt_doc_spreadsheet=>t_column.
      DATA: lv_head TYPE t001.
      DATA(o_desc) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( lv_head ) ).

      LOOP AT o_desc->get_components( ) ASSIGNING FIELD-SYMBOL(<c>).
        IF <c> IS ASSIGNED.
          IF <c>-type->kind = cl_abap_typedescr=>kind_elem.
            APPEND VALUE #( id           = sy-tabix
                            name         = <c>-name
                            display_name = <c>-name
                            is_result    = abap_true
                            type         = <c>-type ) TO it_columns.
          ENDIF.
        ENDIF.
      ENDLOOP.

* itab + header -> XML -> xstring
* Achtung: Speicherintensiv und rel. langsam! Es sollten keine großen Datenmengen verarbeitet werden.
      DATA(lv_bin_data) = cl_fdt_xl_spreadsheet=>if_fdt_doc_spreadsheet~create_document( columns      = it_columns " optional
                                                                                         itab         = REF #( it_t001 )
                                                                                         iv_call_type = if_fdt_doc_spreadsheet=>gc_call_dec_table ).
      IF xstrlen( lv_bin_data ) > 0.
        DATA: lv_action TYPE i.
        DATA: lv_filename TYPE string.
        DATA: lv_fullpath TYPE string.
        DATA: lv_path TYPE string.

* Save-Dialog
        cl_gui_frontend_services=>file_save_dialog( EXPORTING
                                                      default_file_name = 'MYPLANER.csv'
                                                      default_extension = 'csv'
                                                      file_filter       = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }| "|Excel-Datei (*.xlsx)\|*.xlsx\|{ cl_gui_frontend_services=>filetype_all }|
                                                    CHANGING
                                                      filename          = lv_filename
                                                      path              = lv_path
                                                      fullpath          = lv_fullpath
                                                      user_action       = lv_action ).

        IF lv_action EQ cl_gui_frontend_services=>action_ok.
* XSTRING -> SOLIX (RAW)
          DATA(it_raw_data) = cl_bcs_convert=>xstring_to_solix( EXPORTING iv_xstring = lv_bin_data ).

* Datei lokal speichern
          cl_gui_frontend_services=>gui_download( EXPORTING
                                                    filename     = lv_fullpath
                                                    filetype     = 'BIN'
                                                    bin_filesize = xstrlen( lv_bin_data )
                                                  CHANGING
                                                    data_tab     = it_raw_data ).


        ENDIF.
      ENDIF.
    ENDIF.
  CATCH cx_root INTO DATA(e_text).
    MESSAGE e_text->get_text( ) TYPE 'I'.
ENDTRY.
  endmethod.


  method GET_TASK.
      DATA gettext TYPE TABLE OF char100.
  DATA text_table TYPE char100.

  "gucken, ob das mit str nicht besser ist
  o_txt->get_text_as_stream(
     IMPORTING
       text   =   gettext
  ).

  IF gettext IS INITIAL.                                                                          " wie besser?
    DATA empty TYPE char100.
    empty = ' '.
    APPEND empty TO gettext.
  ENDIF.

  text_table = gettext[ 1 ].

  DATA itab TYPE TABLE OF ztc_t_myplaner.
  DATA wa TYPE ztc_t_myplaner.
  wa = task_values.
*  wa-id_planer = p_idpla.
*  wa-id_task = p_idpla.
*  wa-status = status.
*  wa-prioritaet = p_prio.
*  wa-beteiligte = p_usr.
*  wa-thema = text_table.

  APPEND wa TO itab.

  INSERT ztc_t_myplaner FROM TABLE itab.
  "PERFORM notif USING p_usr.
  endmethod.


  METHOD get_thema.
    DATA gettext TYPE TABLE OF char100.
    DATA text_table TYPE char100.

    p_o_txt->get_text_as_stream(
         IMPORTING
           text   =   gettext
      ).

    IF gettext IS INITIAL.                                                                          " wie besser?
      DATA empty TYPE char100.
      empty = ' '.
      APPEND empty TO gettext.
    ENDIF.

    p_text = gettext[ 1 ].

  ENDMETHOD.


  method IMPORT_FROM_EXCEL.

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
  endmethod.


  method INSERT_TABLE.
  INSERT ztc_t_myplaner FROM p_task.
  endmethod.


  method SET_TASK.

     SELECT SINGLE thema
    FROM ztc_t_myplaner
  INTO @DATA(thema_aus_db).



  DATA text TYPE TABLE OF char100.
  DATA wa LIKE LINE OF text.

  wa = thema_aus_db.

  APPEND wa TO text.

  o_txt->set_text_as_r3table(
    EXPORTING
      table           =   text
  ).

  endmethod.


  method SORT_DATE.
  endmethod.


  method SORT_PRIO.
  endmethod.


  method SORT_STATUS.
  endmethod.
ENDCLASS.
