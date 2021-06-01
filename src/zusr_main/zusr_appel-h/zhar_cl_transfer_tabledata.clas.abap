CLASS zhar_cl_transfer_tabledata DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    types : begin of ty_buffer,
      keyfield type string,
      text     type string,
      data     type ref to data,
    end of ty_buffer.
    types tty_buffer type HASHED TABLE OF ty_buffer with UNIQUE key keyfield.

    METHODS constructor .
    METHODS transfer_tables_tofrom_file
      IMPORTING
        !iv_tabname      TYPE tabname
        !iv_addrestr     TYPE string OPTIONAL
        !it_rng_restr    TYPE ANY TABLE OPTIONAL
        !if_upload       TYPE flag DEFAULT ''
        !iv_col_map_file TYPE string OPTIONAL
        !iv_file_postfix TYPE string OPTIONAL
        !iv_target_dir   TYPE string
      EXCEPTIONS
        update_error .
    METHODS delete_table
      IMPORTING
        !iv_tabname   TYPE tabname
        !iv_addrestr  TYPE string OPTIONAL
        !it_rng_restr TYPE ANY TABLE OPTIONAL
      EXCEPTIONS
        delete_error .

    METHODS get_filename_for_xstring_cont
      IMPORTING
        !iv_filename_main          TYPE string
        !is_data                   TYPE any
        !iv_xstr_colname           TYPE string
      CHANGING
        !ct_message                TYPE bapiret2_tab
      RETURNING
        VALUE(ev_filename_xstring) TYPE string .
    METHODS download_xstring_to_files
      IMPORTING
        !iv_filename TYPE string
        !it_data     TYPE STANDARD TABLE
      CHANGING
        !ct_message  TYPE bapiret2_tab .
    METHODS upload_file_to_xstring
      IMPORTING
        !iv_filename_main TYPE string
        !iv_xstr_colname  TYPE string
      CHANGING
        !cs_data          TYPE any
        !ct_message       TYPE bapiret2_tab OPTIONAL .
    METHODS download_file
      IMPORTING
        !iv_filename  TYPE string
        !it_data      TYPE STANDARD TABLE
        !iv_delimiter TYPE char1 DEFAULT cl_abap_char_utilities=>horizontal_tab
      CHANGING
        !ct_message   TYPE bapiret2_tab .
    METHODS upload_file
      IMPORTING
        !iv_entity         TYPE char50 OPTIONAL
        !iv_filename       TYPE string
        !if_header         TYPE flag OPTIONAL
        !if_cols_by_header TYPE flag DEFAULT ' '
        !it_colmap         TYPE tty_buffer OPTIONAL
      EXPORTING
        !et_data           TYPE STANDARD TABLE
      CHANGING
        !ct_message        TYPE bapiret2_tab OPTIONAL .

    CLASS-METHODS convert_to_char
      IMPORTING
        !iv_value    TYPE any
        !if_convert  TYPE flag
      EXPORTING
        !ev_value    TYPE char4000
      CHANGING
        !ct_bapi_msg TYPE bapiret2_tab .

    CLASS-METHODS create_csv_table
      IMPORTING
        !it_data                   TYPE STANDARD TABLE
        !if_convert                TYPE flag
        !if_header                 TYPE flag
        !iv_delimiter              TYPE char1 DEFAULT cl_abap_char_utilities=>horizontal_tab
        !iv_header_escape_char_ext TYPE char1
        !iv_caption                TYPE string OPTIONAL
      EXPORTING
        !et_transfer               TYPE table_of_strings
      CHANGING
        !ct_bapi_msg               TYPE bapiret2_tab .

    METHODS read_column_map_file
      IMPORTING
        !iv_filename TYPE string
      EXPORTING
        !et_colmap   TYPE tty_buffer .

   CLASS-METHODS add_sy_to_bapi_msg
      CHANGING
        !ct_bapi_msg TYPE bapiret2_tab .

    CLASS-METHODS get_components_flat
      IMPORTING
        !is_data       TYPE any OPTIONAL
        !it_components TYPE cl_abap_structdescr=>component_table OPTIONAL
      CHANGING
        !ct_components TYPE cl_abap_structdescr=>component_table .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zhar_cl_transfer_tabledata IMPLEMENTATION.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_cl_transfer_tabledata=>ADD_SY_TO_BAPI_MSG
* +-------------------------------------------------------------------------------------------------+
* | [<-->] CT_BAPI_MSG                    TYPE        BAPIRET2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD add_sy_to_bapi_msg.

    DATA ls_bapi_msg TYPE bapiret2.

    ls_bapi_msg-id         = sy-msgid.
    ls_bapi_msg-type       = sy-msgty.
    ls_bapi_msg-number     = sy-msgno.
    ls_bapi_msg-message_v1 = sy-msgv1.
    ls_bapi_msg-message_v2 = sy-msgv2.
    ls_bapi_msg-message_v3 = sy-msgv3.
    ls_bapi_msg-message_v4 = sy-msgv4.

    APPEND ls_bapi_msg TO ct_bapi_msg.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_cl_transfer_tabledata=>CONVERT_TO_CHAR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_VALUE                       TYPE        ANY
* | [--->] IF_CONVERT                     TYPE        FLAG
* | [<---] EV_VALUE                       TYPE        CHAR4000
* | [<-->] CT_BAPI_MSG                    TYPE        BAPIRET2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD convert_to_char.

    DATA lv_field_type TYPE abap_typekind.
    DATA lv_dummy      TYPE string.

    CONSTANTS lc_fdwh_blank TYPE string VALUE ` `.

    CLEAR ev_value.

    DESCRIBE FIELD iv_value TYPE lv_field_type.

    CASE lv_field_type.
      WHEN cl_abap_datadescr=>typekind_packed.  "Packed
        IF if_convert EQ abap_false.
          ev_value = iv_value.
          SHIFT ev_value LEFT DELETING LEADING space.
        ELSE.
          WRITE iv_value TO ev_value.
          CATCH SYSTEM-EXCEPTIONS conversion_errors = 1.
            MESSAGE e029(z1mdg_dist) INTO lv_dummy WITH lv_field_type iv_value.
            CALL METHOD zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg
              CHANGING
                ct_bapi_msg = ct_bapi_msg.
          ENDCATCH.
        ENDIF.
      WHEN cl_abap_datadescr=>typekind_time.  "Time
        IF if_convert EQ abap_false.
          ev_value = iv_value.
        ELSE.
          ev_value(2)   = iv_value(2).
          ev_value+2(1) = ':'.
          ev_value+3(2) = iv_value+2(2).
          ev_value+5(1) = ':'.
          ev_value+6(2) = iv_value+4(2).
        ENDIF.
      WHEN cl_abap_datadescr=>typekind_date.  "Date
        IF if_convert EQ abap_false.
          ev_value = iv_value.
        ELSE.
          CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
            EXPORTING
              date_internal            = iv_value
            IMPORTING
              date_external            = ev_value
            EXCEPTIONS
              date_internal_is_invalid = 1
              OTHERS                   = 2.
          IF sy-subrc NE 0.
*       Typkonflikt
            MESSAGE e029(z1mdg_dist) INTO lv_dummy WITH lv_field_type iv_value.
            CALL METHOD zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg
              CHANGING
                ct_bapi_msg = ct_bapi_msg.
          ENDIF.
        ENDIF.
      WHEN cl_abap_datadescr=>typekind_float.  "Float
        IF if_convert EQ abap_false.
          WRITE iv_value TO ev_value USING NO EDIT MASK.
        ELSE.
          CALL FUNCTION 'FLTP_CHAR_CONVERSION'
            EXPORTING
              input  = iv_value
            IMPORTING
              flstr  = ev_value
            EXCEPTIONS
              OTHERS = 1.
          IF ( sy-subrc <> 0 ).
*       Typkonflikt
            MESSAGE e029(z1mdg_dist) INTO lv_dummy WITH lv_field_type iv_value.
            CALL METHOD zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg
              CHANGING
                ct_bapi_msg = ct_bapi_msg.
          ENDIF.
        ENDIF.
      WHEN  cl_abap_datadescr=>typekind_xstring. "xstring
        DATA: lv_xstring   TYPE xstring.
        DATA: lv_string    TYPE string.
        DATA  lv_outputlen TYPE i.
        DATA  lt_binary_tab   TYPE STANDARD TABLE OF x255.
        lv_xstring = iv_value. " Rawstring here
        IF lv_xstring IS INITIAL.
          CLEAR ev_value.
        ELSE.
          ev_value = 'X'.
*        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*          EXPORTING
*            buffer        = lv_xstring
*          IMPORTING
*            output_length = lv_outputlen
*          TABLES
*            binary_tab    = lt_binary_tab.
*
*        CALL FUNCTION 'SCMS_BINARY_TO_STRING'
*          EXPORTING
*            input_length = lv_outputlen
**           FIRST_LINE   = 0
**           LAST_LINE    = 0
**           MIMETYPE     = ' '
**           ENCODING     =
*          IMPORTING
*            text_buffer  = lv_string
**           OUTPUT_LENGTH       =
*          TABLES
*            binary_tab   = lt_binary_tab
*          EXCEPTIONS
*            failed       = 1
*            OTHERS       = 2.
*        IF sy-subrc <> 0.
*          MESSAGE 'error at xstring to string ' TYPE 'X'.
*        ENDIF.
*        MOVE lv_string TO ev_value.


*      CALL FUNCTION 'HR_KR_XSTRING_TO_STRING'
*        EXPORTING
*          in_xstring = lv_xstring
*        IMPORTING
*          out_string = lv_string.
*      MOVE lv_string TO ev_value.
*
*
*      DATA: lv_converter TYPE REF TO cl_abap_conv_in_ce.
*      DATA: lv_xstring   TYPE xstring.
*      DATA: lv_string    TYPE string.
*      lv_xstring = iv_value. " Rawstring here
*      lv_converter = cl_abap_conv_in_ce=>create(
*                   encoding                      = 'UTF-8'
**                   endian                        =
*                   replacement                   = '?'
*                   ignore_cerr                   = ABAP_TRUE
*                   input                         = lv_xstring
*               ).
*      TRY.
*        CALL METHOD lv_converter->read
**          EXPORTING
**            n                             = -1    " Anzahl einzulesender Einheiten
**            view                          =     " ABAP Sturkturview mit Offset und Länge
**          IMPORTING
**            data                          =     " Einzulesendes Datenobjekt
**            len                           =     " Anzahl konvertierter Einheiten
*          .
**          CATCH cx_sy_conversion_codepage.    "
**          CATCH cx_sy_codepage_converter_init.    "
**          CATCH cx_parameter_invalid_type.    "
**          CATCH cx_parameter_invalid_range.    "
*        ( IMPORTING data = lv_string ).
*
*        CATCH cx_sy_conversion_codepage.
**-- Should ignore errors in code conversions
*        CATCH cx_sy_codepage_converter_init.
**-- Should ignore errors in code conversions
*        CATCH cx_parameter_invalid_type.
*        CATCH cx_parameter_invalid_range.
*      ENDTRY.
*      move lv_string to ev_value.
        ENDIF.

      WHEN "cl_abap_datadescr=>typekind_xstring  OR "xstring
           cl_abap_datadescr=>typekind_table   OR "internal table
           cl_abap_datadescr=>typekind_oref    OR "object refrerence
           cl_abap_datadescr=>typekind_xstring OR "xstring
           cl_abap_datadescr=>typekind_struct2 OR "deep structure
           cl_abap_datadescr=>typekind_dref.      "data reference
        MESSAGE e028(z1mdg_dist) INTO lv_dummy WITH lv_field_type.
        CALL METHOD zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg
          CHANGING
            ct_bapi_msg = ct_bapi_msg.
      WHEN cl_abap_datadescr=>typekind_int  OR
           cl_abap_datadescr=>typekind_int1 OR
           cl_abap_datadescr=>typekind_int2 OR
           cl_abap_datadescr=>typekind_num.
        ev_value = iv_value.
        SHIFT ev_value LEFT DELETING LEADING space.
      WHEN OTHERS.
*     no conversion required for all other datatypes
        MOVE iv_value TO ev_value.
    ENDCASE.

  ENDMETHOD.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_cl_transfer_tabledata=>CREATE_CSV_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_DATA                        TYPE        STANDARD TABLE
* | [--->] IF_CONVERT                     TYPE        FLAG
* | [--->] IF_HEADER                      TYPE        FLAG
* | [--->] IV_DELIMITER                   TYPE        CHAR1 (default =CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB)
* | [--->] IV_HEADER_ESCAPE_CHAR_EXT      TYPE        CHAR1
* | [--->] IV_CAPTION                     TYPE        STRING(optional)
* | [<---] ET_TRANSFER                    TYPE        TABLE_OF_STRINGS
* | [<-->] CT_BAPI_MSG                    TYPE        BAPIRET2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_csv_table.

    DATA lo_tabledescr   TYPE REF TO cl_abap_tabledescr.
    DATA lo_structdescr  TYPE REF TO cl_abap_structdescr.
    DATA lo_converter    TYPE REF TO cl_abap_conv_obj.

    DATA lt_components   TYPE abap_component_tab.
    DATA lt_string_table TYPE string_table.

    DATA ls_component    TYPE LINE OF abap_component_tab.
    DATA ls_transfer     TYPE string.
    DATA ls_message      TYPE bapiret2.

    DATA lv_char_value   TYPE char4000.
    DATA lv_c_line       TYPE string.
    DATA lv_data_c       TYPE string.
    DATA lr_data         TYPE REF TO data.

    FIELD-SYMBOLS <ls_data>    TYPE any.
    FIELD-SYMBOLS <lv_value>   TYPE any.

    CLEAR et_transfer.

* Tabellenbeschreibung besorgen
    CREATE DATA lr_data LIKE LINE OF it_data.
    ASSIGN lr_data->* TO <ls_data>.
    zhar_cl_transfer_tabledata=>get_components_flat(
      EXPORTING
        is_data       = <ls_data>    " zu untersuchenede Struktur
      CHANGING
        ct_components = lt_components    " Komponentenbeschreibungstabelle
    ).
    "lo_tabledescr  ?= cl_abap_tabledescr=>describe_by_data( it_data ).
    "lo_structdescr ?= lo_tabledescr->get_table_line_type( ).
    "lt_components   = lo_structdescr->get_components( ).

* Optionale Überschrift
    IF iv_caption IS NOT INITIAL.
      CLEAR ls_transfer.
      ls_transfer = iv_caption.
      APPEND ls_transfer TO et_transfer.
    ENDIF.

* Header aufbauen und einfügen
    IF if_header EQ abap_true.
      CLEAR ls_transfer.
* LOOP über einzelne Felder
      LOOP AT lt_components INTO ls_component.
        IF ls_transfer IS INITIAL.
          CONCATENATE iv_header_escape_char_ext ls_component-name INTO ls_transfer.
        ELSE.
          CONCATENATE ls_transfer ls_component-name INTO ls_transfer SEPARATED BY iv_delimiter.
        ENDIF.
      ENDLOOP.
      APPEND ls_transfer TO et_transfer.
    ENDIF.

* Daten in CSV konvertieren
* LOOP über Datentabelle
    LOOP AT it_data ASSIGNING <ls_data>.
      CLEAR ls_transfer.
** LOOP über einzelne Felder
      LOOP AT lt_components INTO ls_component.
        ASSIGN COMPONENT ls_component-name OF STRUCTURE <ls_data> TO <lv_value>.

        CALL METHOD convert_to_char
          EXPORTING
            iv_value    = <lv_value>
            if_convert  = if_convert
          IMPORTING
            ev_value    = lv_char_value
          CHANGING
            ct_bapi_msg = ct_bapi_msg.

        IF sy-tabix EQ 1.
          MOVE lv_char_value TO ls_transfer.
        ELSE.
          CONCATENATE ls_transfer lv_char_value INTO ls_transfer SEPARATED BY iv_delimiter.
        ENDIF.
      ENDLOOP.

      IF ls_transfer IS NOT INITIAL.
        APPEND ls_transfer TO et_transfer.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->DELETE_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TABNAME                     TYPE        TABNAME
* | [--->] IV_ADDRESTR                    TYPE        STRING(optional)
* | [--->] IT_RNG_RESTR                   TYPE        ANY TABLE(optional)
* | [EXC!] DELETE_ERROR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD delete_table.
    DATA  lv_num          TYPE i.
    DATA  lv_addrestr     TYPE string.
    DATA  lv_rng_size     TYPE i.
    DATA  lr_rng_tab      TYPE REF TO data.
    DATA  lv_count        TYPE i.
    DATA  lv_count_all    TYPE i.
    CONSTANTS lc_rng_size_max TYPE i VALUE 1000.

    FIELD-SYMBOLS <lt_rng_restr> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_rng_restr> TYPE any.

    DESCRIBE TABLE it_rng_restr LINES lv_rng_size.
    IF lv_rng_size > lc_rng_size_max.
      lv_addrestr = iv_addrestr.
      REPLACE ALL OCCURRENCES OF 'IT_RNG_RESTR' IN lv_addrestr WITH '<LT_RNG_RESTR>'.
      CREATE DATA lr_rng_tab LIKE it_rng_restr.
      ASSIGN lr_rng_tab->* TO <lt_rng_restr>.
      LOOP AT it_rng_restr ASSIGNING <ls_rng_restr>.
        lv_count     = lv_count + 1.
        lv_count_all = lv_count_all + 1.
        INSERT <ls_rng_restr> INTO TABLE <lt_rng_restr>.
        IF lv_count = lc_rng_size_max OR lv_count_all = lv_rng_size.
          SELECT COUNT(*) INTO lv_num FROM (iv_tabname) WHERE (lv_addrestr).
          IF lv_num EQ 0.
            WRITE : / 'no data in ', iv_tabname.
          ELSE.
            DELETE FROM (iv_tabname) WHERE (lv_addrestr).
            IF sy-subrc NE 0.
              WRITE : / 'error while deleting ', iv_tabname.
              ROLLBACK WORK.
              RAISE delete_error.
            ELSE.
              WRITE : / sy-dbcnt, 'rows deleted in ', iv_tabname.
            ENDIF.
          ENDIF.
          REFRESH <lt_rng_restr>.
          CLEAR lv_count.
        ENDIF.
      ENDLOOP.
    ELSE.
      SELECT COUNT(*) INTO lv_num FROM (iv_tabname) WHERE (iv_addrestr).
      IF lv_num EQ 0.
        WRITE : / 'no data in ', iv_tabname.
      ELSE.
        " delete directly from table
        DELETE FROM (iv_tabname) WHERE (iv_addrestr).
        IF sy-subrc NE 0.
          WRITE : / 'error while deleting ', iv_tabname.
          ROLLBACK WORK.
          RAISE delete_error.
        ELSE.
          WRITE : / sy-dbcnt, 'rows deleted in ', iv_tabname.
        ENDIF.
      ENDIF.
    ENDIF.
    COMMIT WORK.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->DOWNLOAD_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FILENAME                    TYPE        STRING
* | [--->] IT_DATA                        TYPE        STANDARD TABLE
* | [--->] IV_DELIMITER                   TYPE        CHAR1 (default =CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB)
* | [<-->] CT_MESSAGE                     TYPE        BAPIRET2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD download_file.

    DATA lt_transfer TYPE table_of_strings.
    DATA lt_comp     TYPE STANDARD TABLE OF string.

    DATA ls_message  TYPE bapiret2.

    DATA lv_lines    TYPE i.
    DATA lv_string   TYPE string.
    DATA lv_comp    TYPE string.
    DATA lv_comp2   TYPE string.

    CALL METHOD create_csv_table
      EXPORTING
        it_data                   = it_data
        if_convert                = abap_false
        if_header                 = abap_true
        iv_header_escape_char_ext = '*'
        iv_delimiter              = iv_delimiter
      IMPORTING
        et_transfer               = lt_transfer
      CHANGING
        ct_bapi_msg               = ct_message.

* Download data table
    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
*       BIN_FILESIZE            =
        filename                = iv_filename
        filetype                = 'ASC'
*       APPEND                  = 'X'
*       WRITE_FIELD_SEPARATOR   = 'X'
*       HEADER                  = '00'
*       TRUNC_TRAILING_BLANKS   = SPACE
*       WRITE_LF                = 'X'
*       COL_SELECT              = SPACE
*       COL_SELECT_MASK         = SPACE
*       DAT_MODE                = SPACE
*       CONFIRM_OVERWRITE       = SPACE
*       NO_AUTH_CHECK           = SPACE
        codepage                = '4110'
*       IGNORE_CERR             = ABAP_TRUE
*       REPLACEMENT             = '#'
        write_bom               = abap_true
*       TRUNC_TRAILING_BLANKS_EOL = 'X'
*       WK1_N_FORMAT            = SPACE
*       WK1_N_SIZE              = SPACE
*       WK1_T_FORMAT            = SPACE
*       WK1_T_SIZE              = SPACE
*       SHOW_TRANSFER_STATUS    = 'X'
*       FIELDNAMES              =
*       WRITE_LF_AFTER_LAST_LINE  = 'X'
*       VIRUS_SCAN_PROFILE      = '/SCET/GUI_DOWNLOAD'
*    IMPORTING
*       FILELENGTH              =
      CHANGING
        data_tab                = lt_transfer
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.

    IF sy-subrc NE 0.
** Fehler beim Speichern der Datei &
      MESSAGE e003(zhar_tools) WITH iv_filename.
    ELSE.
      "WRITE: / text-003, iv_filename.
    ENDIF.

    SPLIT iv_filename AT '\' INTO TABLE lt_comp.
    LOOP AT lt_comp INTO lv_comp.
      " keine Aktion erforderlich
    ENDLOOP.
    lv_comp2 = ''.
    IF strlen( lv_comp ) > 50.
      lv_comp2 = lv_comp+50.
      lv_comp  = lv_comp(50).
    ENDIF.

    DESCRIBE TABLE lt_transfer LINES lv_lines.
    lv_string = lv_lines - 1.  " headerzeile abziehen
    MESSAGE i059(zhar_tools) WITH lv_comp lv_comp2 lv_string INTO lv_string.
    zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg( CHANGING ct_bapi_msg =  ct_message ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->DOWNLOAD_XSTRING_TO_FILES
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FILENAME                    TYPE        STRING
* | [--->] IT_DATA                        TYPE        STANDARD TABLE
* | [<-->] CT_MESSAGE                     TYPE        BAPIRET2_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD download_xstring_to_files.

    DATA lv_string       TYPE string.
    DATA lv_xstr_colname TYPE string.

    DATA lo_tabledescr   TYPE REF TO cl_abap_tabledescr.
    DATA lo_structdescr  TYPE REF TO cl_abap_structdescr.
    DATA lo_converter    TYPE REF TO cl_abap_conv_obj.

    DATA lt_components   TYPE abap_component_tab.
    DATA ls_component    TYPE LINE OF abap_component_tab.
    DATA lv_filename     TYPE string.
    DATA lt_result       TYPE string_table.

    FIELD-SYMBOLS <ls_data>    TYPE any.
    FIELD-SYMBOLS <lv_xstr>    TYPE any.


* Tabellenbeschreibung besorgen
    lo_tabledescr  ?= cl_abap_tabledescr=>describe_by_data( it_data ).
    lo_structdescr ?= lo_tabledescr->get_table_line_type( ).
    lt_components   = lo_structdescr->get_components( ).

    LOOP AT lt_components INTO ls_component WHERE type->type_kind = cl_abap_datadescr=>typekind_xstring.
      lv_xstr_colname = ls_component-name.
      LOOP AT it_data ASSIGNING <ls_data>.
        " fuer jede Zeile mit gefuelltem XString wird eine Datei erzeugt
        ASSIGN COMPONENT lv_xstr_colname OF STRUCTURE <ls_data> TO <lv_xstr>.
        IF <lv_xstr> IS INITIAL.
          CONTINUE.
        ENDIF.

        lv_filename = get_filename_for_xstring_cont(
          EXPORTING
            iv_filename_main    =   iv_filename   " Filename für Entitätstabelle
            is_data             =   <ls_data>     " Datensatz
            iv_xstr_colname     =   lv_xstr_colname   " Name der XString Spalte
          CHANGING
            ct_message          =   ct_message    " Fehlermeldungen
        ).

        DATA  lt_binary_tab   TYPE STANDARD TABLE OF x255.
        DATA  lv_outputlen    TYPE i.
        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer        = <lv_xstr>
          IMPORTING
            output_length = lv_outputlen
          TABLES
            binary_tab    = lt_binary_tab.

        CALL METHOD cl_gui_frontend_services=>gui_download
          EXPORTING
            filename         = lv_filename
            filetype         = 'BIN'
            bin_filesize     = lv_outputlen
          CHANGING
            data_tab         = lt_binary_tab
          EXCEPTIONS
            file_write_error = 1
            OTHERS           = 2.
        IF sy-subrc NE 0.
** Fehler beim Speichern der Datei &
          MESSAGE e003(zhar_tools) WITH lv_filename.
        ENDIF.

        CLEAR lt_result.
        SPLIT lv_filename AT '\' INTO TABLE lt_result.
        LOOP AT lt_result INTO lv_filename.
          " keine Aktion erforderlich
        ENDLOOP.
        lv_string = ''.
        IF strlen( lv_filename ) > 50.
          lv_string   = substring( val = lv_filename off = 50 ).
          lv_filename = substring( val = lv_filename len = 50 ).
        ENDIF.

        MESSAGE i107(zhar_tools) WITH lv_filename lv_string lv_outputlen INTO lv_string.
        zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg( CHANGING ct_bapi_msg = ct_message ).
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zhar_cl_transfer_tabledata=>GET_COMPONENTS_FLAT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_DATA                        TYPE        ANY(optional)
* | [--->] IT_COMPONENTS                  TYPE        CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE(optional)
* | [<-->] CT_COMPONENTS                  TYPE        CL_ABAP_STRUCTDESCR=>COMPONENT_TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_components_flat.
    DATA lr_structdescr     TYPE REF TO cl_abap_structdescr.
    DATA lr_typedescr       TYPE REF TO cl_abap_typedescr.
    DATA lr_tabledescr      TYPE REF TO cl_abap_tabledescr.
    DATA lr_datadescr       TYPE REF TO cl_abap_datadescr.
    DATA lr_refdescr        TYPE REF TO cl_abap_refdescr.
    DATA lt_components      TYPE abap_component_tab.
    DATA lt_components_sub  TYPE abap_component_tab.
    FIELD-SYMBOLS <ls_component>    TYPE LINE OF abap_component_tab.

    IF it_components IS SUPPLIED.
      lt_components = it_components.
    ELSE.
      lr_structdescr ?= cl_abap_datadescr=>describe_by_data( p_data = is_data  ).
      lt_components = lr_structdescr->get_components( ).
    ENDIF.

    LOOP AT lt_components ASSIGNING <ls_component>.
      lr_typedescr = <ls_component>-type.
      CASE lr_typedescr->kind.
        WHEN cl_abap_typedescr=>kind_table.
          lr_tabledescr ?= lr_typedescr.
          lr_datadescr = lr_tabledescr->get_table_line_type( ).
          lr_typedescr = lr_datadescr.
          "    PERFORM return_components USING lr_typedescr CHANGING ct_component.
        WHEN cl_abap_typedescr=>kind_struct.
          lr_structdescr ?= lr_typedescr.
          lt_components_sub = lr_structdescr->get_components( ).
          CALL METHOD get_components_flat
            EXPORTING
              it_components = lt_components_sub
            CHANGING
              ct_components = ct_components.    " Komponentenbeschreibungstabelle
        WHEN cl_abap_typedescr=>kind_elem.
          APPEND <ls_component> TO ct_components.
      ENDCASE.
    ENDLOOP.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->GET_FILENAME_FOR_XSTRING_CONT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FILENAME_MAIN               TYPE        STRING
* | [--->] IS_DATA                        TYPE        ANY
* | [--->] IV_XSTR_COLNAME                TYPE        STRING
* | [<-->] CT_MESSAGE                     TYPE        BAPIRET2_TAB
* | [<-()] EV_FILENAME_XSTRING            TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_filename_for_xstring_cont.
    FIELD-SYMBOLS  <lv_value>   TYPE any.
    FIELD-SYMBOLS  <lv_xstr>    TYPE any.

    DATA lo_structdescr  TYPE REF TO cl_abap_structdescr.
    DATA lt_components   TYPE abap_component_tab.
    DATA ls_component    TYPE LINE OF abap_component_tab.
    DATA lv_char_value   TYPE char4000.
    DATA lv_keystr       TYPE string.
    DATA lv_file_pref    TYPE string.
    DATA lv_file_suff    TYPE string.
    DATA lt_result       TYPE string_table.
    DATA lv_last         TYPE i.
    DATA lv_len          TYPE i.

    SPLIT iv_filename_main AT '.' INTO TABLE lt_result.
    lv_last = lines( lt_result ).
    IF lv_last = 1.
      lv_file_pref = iv_filename_main.
      lv_file_suff = ''.
    ELSE.
      LOOP AT lt_result INTO lv_file_suff FROM lv_last.
      ENDLOOP.
      lv_len = strlen( iv_filename_main ) - strlen( lv_file_suff ) - 1.
      lv_file_pref = substring( val = iv_filename_main len = lv_len ).
    ENDIF.

    lo_structdescr ?= cl_abap_structdescr=>describe_by_data( is_data ).
    lt_components   = lo_structdescr->get_components( ).

** key aus Inhalten der anderen Felder bestimmen
    LOOP AT lt_components INTO ls_component WHERE type->type_kind <> cl_abap_datadescr=>typekind_xstring.
      ASSIGN COMPONENT ls_component-name OF STRUCTURE is_data TO <lv_value>.
      CALL METHOD convert_to_char
        EXPORTING
          iv_value    = <lv_value>
          if_convert  = ' '
        IMPORTING
          ev_value    = lv_char_value
        CHANGING
          ct_bapi_msg = ct_message.

      IF sy-tabix EQ 1.
        MOVE lv_char_value TO lv_keystr.
      ELSE.
        CONCATENATE lv_keystr lv_char_value INTO lv_keystr SEPARATED BY '_'.
      ENDIF.
    ENDLOOP.
    ev_filename_xstring = |{ lv_file_pref }_{ iv_xstr_colname }_{ lv_keystr }.{ lv_file_suff }|.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->READ_COLUMN_MAP_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FILENAME                    TYPE        STRING
* | [<---] ET_COLMAP                      TYPE        TTY_BUFFER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD read_column_map_file.
    FIELD-SYMBOLS <lv_string>     TYPE string.
    FIELD-SYMBOLS <lv_field>      TYPE string.

    DATA  lt_string     TYPE string_table.
    DATA  lt_fields     TYPE string_table.
    DATA  lv_filestr    TYPE string.
    DATA  lv_len        TYPE i.
    DATA  lv_offs       TYPE i.
    DATA  ls_map        TYPE ty_buffer.
    DATA  lv_linetype   TYPE string.
    DATA  lv_entity     TYPE string.
    DATA  lv_field_src  TYPE string.
    DATA  lv_field_tar  TYPE string.
    DATA  lv_val_src    TYPE string.
    DATA  lv_val_tar    TYPE string.
    DATA  lv_val_func   TYPE string.
    DATA  lf_complete   TYPE flag.

    CLEAR et_colmap.

    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename        = iv_filename
        filetype        = 'ASC'
      CHANGING
        data_tab        = lt_string
      EXCEPTIONS
        file_open_error = 1
        file_read_error = 2
        OTHERS          = 19.
    IF sy-subrc NE 0.
*    CALL METHOD mo_log->add_message
*      EXPORTING
*        iv_msgty = 'E'
*        iv_msgid = sy-msgid
*        iv_msgno = sy-msgno
*        iv_msgv1 = sy-msgv1
*        iv_msgv2 = sy-msgv2
*        iv_msgv3 = sy-msgv3
*        iv_msgv4 = sy-msgv4.
      lv_len = strlen( iv_filename ).
      IF lv_len > 50.
        lv_offs = lv_len - 50.
        lv_filestr = substring( val = iv_filename off = lv_offs ).
      ELSE.
        lv_filestr = iv_filename.
      ENDIF.
      MESSAGE e099(z1mdg_tools) WITH lv_filestr.
      MESSAGE 'Abbruch' TYPE 'X'.

    ENDIF.
    LOOP AT lt_string ASSIGNING <lv_string>.
      IF <lv_string>+0(1) = '*'.
        " Kommentarzeile überspringen
        CONTINUE.
      ENDIF.
      SPLIT <lv_string> AT cl_abap_char_utilities=>horizontal_tab INTO TABLE lt_fields.
      IF lines( lt_fields ) < 4.
        MESSAGE 'Mapping zeile nicht im Format (NAME|VALUE|FUNC) <entitaet>  <alte spalte> <neue spalte>' TYPE 'X'.
      ELSE.
        lf_complete = ''.
        LOOP AT lt_fields ASSIGNING <lv_field>.
          IF lf_complete = 'X'.
            MESSAGE |Zeile zu lang:{ <lv_string> }| TYPE 'X'.
          ENDIF.

          IF sy-tabix = 1.
            lv_linetype = <lv_field>.
            IF lv_linetype <> 'NAME' AND lv_linetype <> 'VALUE' AND lv_linetype <> 'FUNC'.
              MESSAGE |Mapping zeile beginnt nicht mit NAME VALUE oder FUNC: { <lv_string> }| TYPE 'X'.
            ENDIF.
          ELSEIF sy-tabix = 2.
            lv_entity = <lv_field>.
          ELSEIF sy-tabix = 3.
            lv_field_src  = <lv_field>.
          ELSEIF sy-tabix = 4.
            IF lv_linetype = 'NAME'.
              lv_field_tar = <lv_field>.
              lf_complete = 'X'.
            ELSEIF lv_linetype = 'VALUE'.
              lv_val_src  = <lv_field>.
            ELSEIF lv_linetype = 'FUNC'.
              lv_val_func  = <lv_field>.
              lf_complete = 'X'.
            ENDIF.
          ELSEIF sy-tabix = 5.
            IF lv_linetype = 'VALUE'.
              lv_field_tar = <lv_field>.
            ENDIF.
          ELSEIF sy-tabix = 6.
            IF lv_linetype = 'VALUE'.
              lv_val_tar = <lv_field>.
              lf_complete = 'X'.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF lf_complete = ''.
          MESSAGE |Zeile zu kurz:{ <lv_string> }| TYPE 'X'.
        ENDIF.
        IF lv_linetype = 'NAME'.
          ls_map-keyfield  = 'NAME'  && '|' && lv_entity && '|' && lv_field_src.
          ls_map-text     = lv_field_tar.
        ELSEIF lv_linetype = 'VALUE'.
          ls_map-keyfield  = 'VALUE' && '|' && lv_entity && '|' && lv_field_src && '|' && lv_val_src.
          ls_map-text     = lv_field_tar && '|' && lv_val_tar.
        ELSEIF lv_linetype = 'FUNC'.
          ls_map-keyfield  = 'FUNC' && '|' && lv_entity && '|' && lv_field_src.
          ls_map-text      =  lv_val_func.
        ENDIF.
        INSERT ls_map INTO TABLE et_colmap.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->TRANSFER_TABLES_TOFROM_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TABNAME                     TYPE        TABNAME
* | [--->] IV_ADDRESTR                    TYPE        STRING(optional)
* | [--->] IT_RNG_RESTR                   TYPE        ANY TABLE(optional)
* | [--->] IF_UPLOAD                      TYPE        FLAG (default ='')
* | [--->] IV_COL_MAP_FILE                TYPE        STRING(optional)
* | [--->] IV_FILE_POSTFIX                TYPE        STRING(optional)
* | [--->] IV_TARGET_DIR                  TYPE        STRING
* | [EXC!] UPDATE_ERROR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD transfer_tables_tofrom_file.
    DATA(lc_convert)      =  NEW zhar_cl_transfer_tabledata( ).
    DATA  lt_colmap        TYPE  tty_buffer.

    DATA  lv_filename      TYPE string.
    DATA  lv_postfix       TYPE string.
    DATA  lv_targetdir     TYPE string.
    DATA  lv_len           TYPE i.
    DATA  lt_messages      TYPE bapiret2_tab.
    DATA  ls_message       TYPE bapiret2.
    DATA  lr_structdescr   TYPE REF TO cl_abap_structdescr.
    DATA  lv_dummy         TYPE string.
    DATA  lv_tabstr        TYPE string.
    DATA  lr_tabdata       TYPE REF TO data.
    DATA  lr_line_data     TYPE REF TO data.
    DATA  lv_rng_size      TYPE i.
    DATA  lr_rng_tab       TYPE REF TO data.
    DATA  lv_count         TYPE i.
    DATA  lv_count_all     TYPE i.
    CONSTANTS lc_rng_size_max TYPE i VALUE 1000.

    FIELD-SYMBOLS <lt_tabdata> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_tabdata> TYPE any.
    FIELD-SYMBOLS <lt_rng_restr> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_rng_restr> TYPE any.

    IF iv_file_postfix IS NOT INITIAL AND iv_file_postfix(1) NE '_'.
      lv_postfix = '_' && iv_file_postfix.
    ELSE.
      lv_postfix = iv_file_postfix.
    ENDIF.

    lv_targetdir = iv_target_dir.
    lv_len = strlen( iv_target_dir ) - 1.
    IF iv_target_dir+lv_len NE '\' AND iv_target_dir+lv_len NE '/'.
      lv_targetdir = lv_targetdir && '\'.
    ENDIF.

    IF if_upload = 'X' AND iv_col_map_file IS NOT INITIAL.
      lc_convert->read_column_map_file(
        EXPORTING
          iv_filename = iv_col_map_file
        IMPORTING
          et_colmap   = lt_colmap    " Hashtabelle für Zwischenspeicher gegen red. Zugriffe
      ).
    ENDIF.


    lr_structdescr ?= cl_abap_typedescr=>describe_by_name( iv_tabname ).
    CREATE DATA lr_line_data TYPE HANDLE lr_structdescr.
    ASSIGN lr_line_data->* TO <ls_tabdata>.
    CREATE DATA lr_tabdata LIKE TABLE OF <ls_tabdata>.
    ASSIGN lr_tabdata->* TO <lt_tabdata>.
    lv_filename = |{ lv_targetdir }{ iv_tabname }{ lv_postfix }.csv|.
    REPLACE ALL OCCURRENCES OF '/' IN lv_filename WITH '_'.

    IF if_upload = 'X'.
      DATA lv_tabname TYPE char50.
      lv_tabname = iv_tabname.
      lc_convert->upload_file(
        EXPORTING
          iv_entity         = lv_tabname
          iv_filename       = lv_filename
          if_header         = ''    " Headerzeile bitte entfernen
          if_cols_by_header = 'X'
          it_colmap         = lt_colmap
        IMPORTING
          et_data     = <lt_tabdata>
        CHANGING
          ct_message   = lt_messages    " Fehlermeldungen
      ).
      IF lt_messages IS NOT INITIAL.
        LOOP AT lt_messages INTO ls_message .
          MESSAGE ID ls_message-id TYPE ls_message-type NUMBER ls_message-number
             WITH ls_message-message_v1 ls_message-message_v2 ls_message-message_v3 ls_message-message_v4  INTO lv_dummy.
          WRITE / lv_dummy.
        ENDLOOP.
        RETURN.
      ENDIF.

      IF iv_addrestr IS NOT INITIAL.
        " Reduktion wegen zusätzlicher Selektionsrestr.
        DATA lr_table2  TYPE REF TO data.
        DATA lv_addrestr TYPE string.
        FIELD-SYMBOLS  <lt_target2> TYPE STANDARD TABLE.
        CREATE DATA lr_table2 LIKE  <lt_tabdata>.
        ASSIGN lr_table2->* TO <lt_target2>.

        lv_addrestr = iv_addrestr.
        IF lv_addrestr CS 'like'.
          REPLACE ALL OCCURRENCES OF 'like' IN lv_addrestr WITH 'CP' IGNORING CASE.
          REPLACE ALL OCCURRENCES OF '%'    IN lv_addrestr WITH '*' IGNORING CASE.
        ENDIF.
        LOOP AT <lt_tabdata> ASSIGNING <ls_tabdata> WHERE (lv_addrestr).
          APPEND <ls_tabdata> TO <lt_target2>.
        ENDLOOP.
        <lt_tabdata> = <lt_target2>.
      ENDIF.

      lv_tabstr = iv_tabname.
      MODIFY (iv_tabname) FROM TABLE <lt_tabdata>.
      IF sy-subrc NE 0.
        WRITE : /, 'error while updating ', lv_tabstr.
        ROLLBACK WORK.
        RAISE update_error.
      ELSE.
        WRITE : / sy-dbcnt, 'rows updated in ', lv_tabstr.
      ENDIF.

    ELSE.
      " dude do the download
      " read data directly from table
      DESCRIBE TABLE it_rng_restr LINES lv_rng_size.
      IF lv_rng_size > lc_rng_size_max.
        lv_addrestr = iv_addrestr.
        REPLACE ALL OCCURRENCES OF 'IT_RNG_RESTR' IN lv_addrestr WITH '<LT_RNG_RESTR>'.
        CREATE DATA lr_rng_tab LIKE it_rng_restr.
        ASSIGN lr_rng_tab->* TO <lt_rng_restr>.
        LOOP AT it_rng_restr ASSIGNING <ls_rng_restr>.
          lv_count     = lv_count + 1.
          lv_count_all = lv_count_all + 1.
          INSERT <ls_rng_restr> INTO TABLE <lt_rng_restr>.
          IF lv_count = lc_rng_size_max OR lv_count_all = lv_rng_size.
            SELECT * FROM (iv_tabname) APPENDING TABLE <lt_tabdata> WHERE (lv_addrestr).
            REFRESH <lt_rng_restr>.
            CLEAR lv_count.
          ENDIF.
        ENDLOOP.
      ELSE.
        SELECT * FROM (iv_tabname) INTO TABLE <lt_tabdata> WHERE (iv_addrestr).
      ENDIF.

      lc_convert->download_file(
        EXPORTING
          iv_filename  = lv_filename
          it_data      = <lt_tabdata>
          iv_delimiter = cl_abap_char_utilities=>horizontal_tab    " Einstelliges Kennzeichen
        CHANGING
          ct_message   = lt_messages    " Fehlermeldungen
      ).
      " Xstring in separaten binaeren Dateien auslagern
      lc_convert->download_xstring_to_files(
        EXPORTING
          iv_filename  = lv_filename
          it_data      = <lt_tabdata>
        CHANGING
          ct_message   = lt_messages    " Fehlermeldungen
      ).
      LOOP AT lt_messages INTO ls_message WHERE type CS 'EX'.
        MESSAGE ID ls_message-id TYPE ls_message-type NUMBER ls_message-number
           WITH ls_message-message_v1 ls_message-message_v2 ls_message-message_v3 ls_message-message_v4  INTO lv_dummy.
        WRITE / lv_dummy.
        DELETE lt_messages.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_messages INTO ls_message.
      MESSAGE ID ls_message-id TYPE ls_message-type NUMBER ls_message-number
         WITH ls_message-message_v1 ls_message-message_v2 ls_message-message_v3 ls_message-message_v4  INTO lv_dummy.
      WRITE / lv_dummy.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->UPLOAD_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY                      TYPE        CHAR50(optional)
* | [--->] IV_FILENAME                    TYPE        STRING
* | [--->] IF_HEADER                      TYPE        FLAG(optional)
* | [--->] IF_COLS_BY_HEADER              TYPE        FLAG (default =' ')
* | [--->] IT_COLMAP                      TYPE        TTY_BUFFER(optional)
* | [<---] ET_DATA                        TYPE        STANDARD TABLE
* | [<-->] CT_MESSAGE                     TYPE        BAPIRET2_TAB(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD upload_file.

    DATA  lv_dummy         TYPE string.
    DATA  lt_string        TYPE string_table.
    DATA  lt_fields        TYPE string_table.
    DATA  lv_filestr   TYPE string.
    DATA  lv_offs      TYPE i.

    FIELD-SYMBOLS <lv_field> TYPE any.
    FIELD-SYMBOLS <ls_data> TYPE any.
    FIELD-SYMBOLS <lv_comp> TYPE any.


    lv_offs = nmax( val1 = strlen( iv_filename ) val2 = 50 ) - 50 .
    lv_filestr = substring( val = iv_filename off = lv_offs ).


* TXT-Datei hochladen
    IF if_cols_by_header = 'X' OR it_colmap IS NOT INITIAL.
      CALL METHOD cl_gui_frontend_services=>gui_upload
        EXPORTING
          filename        = iv_filename
          filetype        = 'ASC'
        CHANGING
          data_tab        = lt_string
        EXCEPTIONS
          file_open_error = 1
          file_read_error = 2
          OTHERS          = 19.
    ELSE.
      CALL METHOD cl_gui_frontend_services=>gui_upload
        EXPORTING
          filename                = iv_filename
          filetype                = 'ASC'
          has_field_separator     = abap_true
*         header_length           = 0
*         read_by_line            = 'X'
*         dat_mode                = SPACE
*         codepage                = '4110'
*         ignore_cerr             = ABAP_TRUE
*         replacement             = '#'
*         virus_scan_profile      =
*   IMPORTING
*         filelength              =
*         header                  =
        CHANGING
          data_tab                = et_data
        EXCEPTIONS
          file_open_error         = 1
          file_read_error         = 2
          no_batch                = 3
          gui_refuse_filetransfer = 4
          invalid_type            = 5
          no_authority            = 6
          unknown_error           = 7
          bad_data_format         = 8
          header_not_allowed      = 9
          separator_not_allowed   = 10
          header_too_long         = 11
          unknown_dp_error        = 12
          access_denied           = 13
          dp_out_of_memory        = 14
          disk_full               = 15
          dp_timeout              = 16
          not_supported_by_gui    = 17
          error_no_gui            = 18
          OTHERS                  = 19.
    ENDIF.

    IF sy-subrc <> 0.
      IF ct_message IS SUPPLIED.
        zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg( CHANGING    ct_bapi_msg =  ct_message   ).
        "MESSAGE |problems with file { lv_filestr }| type  'E'   INTO lv_dummy.
        "zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg( CHANGING    ct_bapi_msg =  ct_message   ).
      ENDIF.
      RETURN.
    ENDIF.

    IF if_cols_by_header = 'X' OR it_colmap IS NOT INITIAL.
      DATA  lr_structdescr     TYPE REF TO cl_abap_structdescr.
      DATA  lt_components_out  TYPE     cl_abap_structdescr=>component_table.
      DATA  lt_components_file TYPE     cl_abap_structdescr=>component_table.
      DATA  lt_components_file_str TYPE     cl_abap_structdescr=>component_table.
      DATA  ls_comp            TYPE     abap_componentdescr.
      DATA  lf_xstring_exists  TYPE flag.
      "DATA  lv_xstring_colname TYPE string.
      "DATA  lv_xstring_colnr   TYPE i  VALUE 0.
      DATA  lr_data_file       TYPE REF TO data.
      DATA  lr_data_out        TYPE REF TO data.
      DATA  lv_field           TYPE string.
      DATA  lv_key             TYPE string.
      DATA  lv_field_tar       TYPE string.
      DATA  lv_value_tar       TYPE string.
      DATA  lv_len             TYPE i.
      DATA  lv_pos             TYPE i.

      FIELD-SYMBOLS <ls_comp>           TYPE abap_componentdescr.
      FIELD-SYMBOLS <lv_string>         TYPE string.
      FIELD-SYMBOLS <lv_value>          TYPE any.
      FIELD-SYMBOLS <lv_value_str>      TYPE any.
      FIELD-SYMBOLS <ls_data_file>      TYPE any.
      FIELD-SYMBOLS <ls_data_file_str>  TYPE any.
      FIELD-SYMBOLS <ls_data_out>       TYPE any.
      FIELD-SYMBOLS <ls_map>            TYPE ty_buffer.

      CREATE DATA lr_data_out LIKE LINE OF et_data.
      ASSIGN lr_data_out->* TO <ls_data_out>.
      lr_structdescr   ?= cl_abap_typedescr=>describe_by_data( <ls_data_out> ).
      lt_components_out = lr_structdescr->get_components( ).

      IF if_cols_by_header <> 'X'.
        CREATE DATA lr_data_file LIKE LINE OF et_data.
        ASSIGN lr_data_file->* TO <ls_data_file>.
        lt_components_file = lt_components_out.
      ENDIF.

      lf_xstring_exists = ''.
      LOOP AT lt_string ASSIGNING <lv_string>.
        IF <lv_string>+0(1) = '*'.
          IF <ls_data_file> IS ASSIGNED.
            CONTINUE.
          ENDIF.
          IF if_cols_by_header <> 'X'.
            CREATE DATA lr_data_file LIKE LINE OF et_data.
            ASSIGN lr_data_file->* TO <ls_data_file>.
          ELSE.
            SPLIT <lv_string>+1 AT cl_abap_char_utilities=>horizontal_tab INTO TABLE lt_fields.
            LOOP AT lt_fields INTO lv_field.
              IF it_colmap IS NOT INITIAL.
                " Spaltenname ändert sich
                lv_key = 'NAME' && '|' && iv_entity && '|' && lv_field.
                READ TABLE it_colmap ASSIGNING <ls_map> WITH TABLE KEY keyfield = lv_key.
                IF sy-subrc EQ 0.
                  lv_field = <ls_map>-text.
                ENDIF.
              ENDIF.
              READ TABLE lt_components_out INTO ls_comp WITH TABLE KEY name = lv_field.
              IF sy-subrc NE 0.
                MESSAGE w106(zhar_tools) WITH lv_field lv_filestr INTO lv_dummy.
                CLEAR ls_comp.
                ls_comp-name       = lv_field.
                ls_comp-type       ?= cl_abap_typedescr=>describe_by_name( 'string' ).
                "ls_comp-suffix     =
                "ls_comp-as_include = ' '.
              ENDIF.
              APPEND ls_comp TO lt_components_file.
              IF ls_comp-type->type_kind = cl_abap_datadescr=>typekind_xstring.
                " oha ein XString, das aendert einiges
                lf_xstring_exists = 'X'.
              ENDIF.
            ENDLOOP.
            lr_structdescr = cl_abap_structdescr=>create( lt_components_file ).
            " Referenz auf Struktur erzeugen
            CREATE DATA lr_data_file TYPE HANDLE lr_structdescr.
            ASSIGN lr_data_file->* TO <ls_data_file>.
          ENDIF.

        ELSE.
          IF <ls_data_file> IS NOT ASSIGNED.
            MESSAGE 'sorry no output structure defined' TYPE 'X'.
          ELSEIF <ls_data_file_str> IS NOT ASSIGNED.
            LOOP AT lt_components_file INTO ls_comp.
              ls_comp-type   ?= cl_abap_typedescr=>describe_by_name( 'string' ).
              APPEND ls_comp TO lt_components_file_str.
            ENDLOOP.
            lr_structdescr = cl_abap_structdescr=>create( lt_components_file_str ).
            " Referenz auf Struktur erzeugen
            CREATE DATA lr_data_file TYPE HANDLE lr_structdescr.
            ASSIGN lr_data_file->* TO <ls_data_file_str>.
          ENDIF.
          CLEAR <ls_data_file>.
          CLEAR <ls_data_file_str>.
          SPLIT <lv_string> AT cl_abap_char_utilities=>horizontal_tab INTO TABLE lt_fields.
          " Zeile aus Datei in Dateistruktur transformieren
          LOOP AT lt_fields ASSIGNING <lv_field>.
            ASSIGN COMPONENT sy-tabix OF STRUCTURE <ls_data_file> TO <lv_value>.
            ASSIGN COMPONENT sy-tabix OF STRUCTURE <ls_data_file_str> TO <lv_value_str>.
            IF lf_xstring_exists <> 'X' OR <lv_field> IS INITIAL.
              <lv_value> = <lv_field>.
              <lv_value_str> = <lv_field>.
            ELSE.
              READ TABLE lt_components_file INDEX sy-tabix ASSIGNING <ls_comp>.
              IF <ls_comp>-type->type_kind <> cl_abap_datadescr=>typekind_xstring .
                <lv_value> = <lv_field>.
                <lv_value_str> = <lv_field>.
              ELSE.
                " <lv_value> = 'X'.  " nur markierung setzen, Daten werden im Anschluss in upload_file_to_xstring geladen
                CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
                  EXPORTING
                    text   = 'X'
                  IMPORTING
                    buffer = <lv_value>
                  EXCEPTIONS
                    failed = 1
                    OTHERS = 2.
                IF sy-subrc <> 0.
                  MESSAGE 'problems at conversion string to xstring' TYPE 'X'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.
          IF lf_xstring_exists = 'X'.
            LOOP AT lt_components_file ASSIGNING <ls_comp> WHERE type->type_kind = cl_abap_datadescr=>typekind_xstring.
              upload_file_to_xstring(
                EXPORTING
                  iv_filename_main  =  iv_filename   " Filename für Entitätstabelle
                  iv_xstr_colname   =  <ls_comp>-name  " Name der XString Spalte
                CHANGING
                  cs_data           =  <ls_data_file>   " Datensatz
                  ct_message       =   ct_message  " Fehlermeldungen
              ).
            ENDLOOP.
          ENDIF.
          IF it_colmap IS NOT INITIAL.
            " Werte mappen
            LOOP AT lt_components_file ASSIGNING <ls_comp>.
              ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE <ls_data_file> TO <lv_value>.
              ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE <ls_data_file_str> TO <lv_value_str>.
              lv_key = 'FUNC' && '|' && iv_entity && '|' && <ls_comp>-name.
              READ TABLE it_colmap ASSIGNING <ls_map> WITH TABLE KEY keyfield = lv_key.
              IF sy-subrc EQ 0.
                CASE <ls_map>-text.
                  WHEN 'TO_UPPER'.
                    <lv_value> = to_upper( <lv_value> ).
                  WHEN 'TO_LOWER'.
                    <lv_value> = to_lower( <lv_value> ).
                  WHEN 'REMOVE_LEAD_ZEROS'.
                    lv_len = strlen( <lv_value> ).
                    lv_pos = 0.
                    WHILE lv_pos < lv_len.
                      IF <lv_value>+lv_pos(1) <> '0'.
                        <lv_value> = <lv_value>+lv_pos.
                        EXIT.
                      ENDIF.
                      ADD 1 TO lv_pos.
                      IF lv_pos = lv_len.
                        <lv_value> = ''.
                      ENDIF.
                    ENDWHILE.
                  WHEN OTHERS.
                    MESSAGE |unbekannte FUNC : { <ls_map>-text }| TYPE 'X'.
                ENDCASE.
                <lv_value_str> = <lv_value>.
              ENDIF.

              lv_key = 'VALUE' && '|' && iv_entity && '|' && <ls_comp>-name && '|' && <lv_value_str>.
              READ TABLE it_colmap ASSIGNING <ls_map> WITH TABLE KEY keyfield = lv_key.
              IF sy-subrc EQ 0.
                SPLIT <ls_map>-text AT '|' INTO lv_field_tar lv_value_tar.
                ASSIGN COMPONENT lv_field_tar OF STRUCTURE <ls_data_file> TO <lv_value>.
                IF sy-subrc EQ 0.
                  <lv_value> = lv_value_tar.
                ENDIF.
              ENDIF.

            ENDLOOP.
          ENDIF.
          CLEAR <ls_data_out>.
          " Dateistruktur in Ausgabestruktur kopieren
          MOVE-CORRESPONDING <ls_data_file> TO <ls_data_out>.
          INSERT <ls_data_out> INTO TABLE et_data.
        ENDIF.

      ENDLOOP.

    ENDIF.

* Kopfzeilen löschen
    IF if_header NE abap_true.
      LOOP AT et_data ASSIGNING <ls_data>.
        ASSIGN COMPONENT 1 OF STRUCTURE <ls_data> TO <lv_comp>.
        IF |{ <lv_comp>+0(1) }| eq '*'.
          DELETE et_data INDEX 1.
        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method zhar_cl_transfer_tabledata->UPLOAD_FILE_TO_XSTRING
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FILENAME_MAIN               TYPE        STRING
* | [--->] IV_XSTR_COLNAME                TYPE        STRING
* | [<-->] CS_DATA                        TYPE        ANY
* | [<-->] CT_MESSAGE                     TYPE        BAPIRET2_TAB(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD upload_file_to_xstring.
    DATA  lv_bin_filename      TYPE string.
    DATA  lt_binary_tab        TYPE STANDARD TABLE OF x255.
    DATA  lv_offs              TYPE i.
    DATA  lv_filestr           TYPE string.
    DATA  lv_filelen           TYPE i.
    DATA  lt_result            TYPE string_table.
    DATA  lv_dummy             TYPE string.
    FIELD-SYMBOLS <lv_xstr_col>   TYPE any.

    ASSIGN COMPONENT iv_xstr_colname OF STRUCTURE cs_data TO <lv_xstr_col>.
    IF <lv_xstr_col> IS INITIAL.
      RETURN.
    ENDIF.
    "separate binaerdatei einlesen
    lv_bin_filename = get_filename_for_xstring_cont(
      EXPORTING
        iv_filename_main    =  iv_filename_main    " Filename für Entitätstabelle
        is_data             =  cs_data             " Datensatz
        iv_xstr_colname     =  iv_xstr_colname     " Name der XString Spalte
      CHANGING
        ct_message          =  ct_message   " Fehlermeldungen
    ).

    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename        = lv_bin_filename
        filetype        = 'BIN'
        "IMPORTING
*       filelength      =
*       header          =
      IMPORTING
        filelength      = lv_filelen
      CHANGING
        data_tab        = lt_binary_tab
      EXCEPTIONS
        file_open_error = 1
        file_read_error = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      lv_offs = nmax( val1 = strlen( lv_bin_filename ) val2 = 50 ) - 50 .
      lv_filestr = substring( val = lv_bin_filename off = lv_offs ).

      IF ct_message IS SUPPLIED.
        zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg( CHANGING    ct_bapi_msg =  ct_message   ).
        "MESSAGE e099(zhar_tools) WITH lv_filestr INTO lv_dummy.
        "zhar_cl_transfer_tabledata=>add_sy_to_bapi_msg( CHANGING    ct_bapi_msg =  ct_message   ).
      ENDIF.
      RETURN.
    ENDIF.
    SPLIT lv_bin_filename AT '\' INTO TABLE lt_result.
    LOOP AT lt_result INTO lv_bin_filename.
    ENDLOOP.

    MESSAGE i108(zhar_tools) WITH  '#X#'  '#X#' INTO lv_dummy.
    REPLACE FIRST OCCURRENCE OF '#X#' IN lv_dummy WITH lv_bin_filename.
    REPLACE FIRST OCCURRENCE OF '#X#' IN lv_dummy WITH |{ lv_filelen }|.
    WRITE / lv_dummy.
    "zhar_cl_tools=>add_sy_to_bapi_msg( CHANGING ct_bapi_msg = ct_message ).

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_filelen
      IMPORTING
        buffer       = <lv_xstr_col>
      TABLES
        binary_tab   = lt_binary_tab
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE 'problems converting bin to xstring' TYPE 'X'.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
