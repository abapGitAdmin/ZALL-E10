CLASS zhar_cl_load_file DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  methods TRANSFER_TABLES_TOFROM_FILE
    importing
      !IV_TABNAME type TABNAME
      !IV_ADDRESTR type STRING optional
      !IT_RNG_RESTR type ANY TABLE optional
      !IF_UPLOAD type FLAG default ''
      !IV_COL_MAP_FILE type STRING optional
      !IV_FILE_POSTFIX type STRING optional
      !IV_TARGET_DIR type STRING
    exceptions
      UPDATE_ERROR .

  "! Tabellenzeilen löschen
  "!
  "! @exception DELETE_ERROR | Fehlerfall
  "! @parameter IV_TABNAME   | Tabellenname
  "! @parameter IV_ADDRESTR  | Restriktion als String
  "! @parameter IT_RNG_RESTR |
  methods DELETE_TABLE
    importing
      IV_TABNAME type TABNAME
      IV_ADDRESTR type STRING optional
      IT_RNG_RESTR type ANY TABLE optional
    exceptions
      DELETE_ERROR .
protected section.
private section.
ENDCLASS.



CLASS zhar_cl_load_file IMPLEMENTATION.


METHOD delete_table.
  DATA  lv_num          TYPE i.
  DATA  lv_addrestr     TYPE string.
  DATA  lv_rng_size     TYPE i.
  DATA  lr_rng_tab      TYPE REF TO data.
  DATA  lv_count        TYPE i.
  DATA  lv_count_all    TYPE i.
  CONSTANTS lc_rng_size_max TYPE I value 1000.

  FIELD-SYMBOLS <lt_rng_restr> TYPE ANY TABLE.
  FIELD-SYMBOLS <ls_rng_restr> TYPE ANY.

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
        SELECT COUNT(*) INTO lv_num FROM (iv_tabname) where (lv_addrestr).
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
    SELECT COUNT(*) INTO lv_num FROM (iv_tabname) where (iv_addrestr).
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
* | Instance Public Method Z1MDG_CL_LOAD_FILE->TRANSFER_TABLES_TOFROM_FILE
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
  DATA(lc_convert)      =  new zhar_cl_convert_util( ).
  DATA  lt_colmap        TYPE  zhar_t_buffer.

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
  replace ALL OCCURRENCES OF '/' in lv_filename with '_'.

  IF if_upload = 'X'.
    DATA lv_tabname TYPE usmd_entity.
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
ENDCLASS.
