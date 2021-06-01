*&---------------------------------------------------------------------*
*& Report  /ADESSO/TOOL_MANAGER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT /adesso/tool_manager.

TYPES:
  BEGIN OF ts_dialog_alv,
    devclass TYPE packname,
    packname TYPE as4text,
    author   TYPE packauthor,
    sysid    TYPE sysid,
    trkorr   TYPE trkorr,
    trname   TYPE as4text,
  END OF ts_dialog_alv,
  tt_dialog_alv TYPE TABLE OF ts_dialog_alv.

DATA: lr_table      TYPE REF TO cl_salv_table,
      lr_grid       TYPE REF TO cl_salv_form_layout_grid,
      lr_label      TYPE REF TO cl_salv_form_label,
      lr_text       TYPE REF TO cl_salv_form_text,
      lr_functions  TYPE REF TO cl_salv_functions_list,
      lr_columns    TYPE REF TO cl_salv_columns_table,
      lt_tdevc      TYPE TABLE OF tdevc,
      lt_dialog_alv TYPE tt_dialog_alv,
      lt_e070       TYPE TABLE OF e070,
      lt_e071       TYPE TABLE OF e071,
      ls_e070       TYPE e070,
      ls_e07t       TYPE e07t,
      ls_tdevct     TYPE tdevct,
      ls_tadir      TYPE tadir.

FIELD-SYMBOLS: <fs_dialog_alv> TYPE ts_dialog_alv.
*&---------------------------------------------------------------------*
*&       Selection Screen
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&       Start-Of-Selection
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT * FROM tdevc INTO TABLE lt_tdevc WHERE parentcl = '/ADESSO/ISU_TOOLS' OR parentcl = 'ZISU_TOOLS'.
  LOOP AT lt_tdevc ASSIGNING FIELD-SYMBOL(<fs_tdevc>).
    APPEND INITIAL LINE TO lt_dialog_alv ASSIGNING <fs_dialog_alv>.
    SELECT SINGLE * FROM tdevct INTO ls_tdevct WHERE devclass = <fs_tdevc>-devclass AND spras = sy-langu.
    SELECT SINGLE * FROM tadir INTO ls_tadir WHERE pgmid = 'R3TR' AND object = 'DEVC' AND obj_name = <fs_tdevc>-devclass.
    SELECT * FROM e071 INTO TABLE lt_e071 WHERE pgmid = ls_tadir-pgmid AND object = ls_tadir-object AND obj_name = ls_tadir-obj_name.
    SORT lt_e071 BY trkorr.
    DELETE ADJACENT DUPLICATES FROM lt_e071 COMPARING trkorr.
    CLEAR: lt_e070.
    LOOP AT lt_e071 ASSIGNING FIELD-SYMBOL(<fs_e071>).
      SELECT * FROM e070 APPENDING TABLE lt_e070 WHERE trkorr = <fs_e071>-trkorr.
    ENDLOOP.
    IF lines( lt_e070 ) > 0.
      SORT lt_e070 BY as4date DESCENDING as4time DESCENDING.
      ls_e070 = lt_e070[ 1 ].
      SELECT SINGLE * FROM e07t INTO ls_e07t WHERE trkorr = ls_e070-trkorr AND langu = sy-langu.
    ENDIF.
    <fs_dialog_alv>-sysid    = sy-sysid.
    <fs_dialog_alv>-devclass = <fs_tdevc>-devclass.
    <fs_dialog_alv>-packname = ls_tdevct-ctext.
    <fs_dialog_alv>-author   = ls_tadir-author.
    <fs_dialog_alv>-trkorr   = ls_e070-trkorr.
    <fs_dialog_alv>-trname   = ls_e07t-as4text.
  ENDLOOP.

  CREATE OBJECT lr_grid.
  lr_grid->create_label( text = 'Eigene Programme' row = 1 column = 1 ).
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lr_table
    CHANGING
      t_table      = lt_dialog_alv.

  CALL METHOD lr_table->get_functions
    RECEIVING
      value = lr_functions.
  lr_functions->set_all( ).

  lr_table->set_top_of_list( lr_grid ).
  lr_table->display( ).

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  WRITE_LOG
*&---------------------------------------------------------------------*
*       Die Daten wurden
*----------------------------------------------------------------------*
*FORM write_log
*  USING
*    iv_error_text.
*  DATA:
*    ls_roles     TYPE zisu_chgroles,
*    ls_active    TYPE zisu_chgroles,
*    ls_dialog    TYPE zisu_chgdialog,
*    lr_table     TYPE REF TO cl_salv_table,
*    lr_grid      TYPE REF TO cl_salv_form_layout_grid,
*    lr_label     TYPE REF TO cl_salv_form_label,
*    lr_text      TYPE REF TO cl_salv_form_text,
*    lr_functions TYPE REF TO cl_salv_functions_list,
*    lr_columns   TYPE REF TO cl_salv_columns_table.
*
*  IF p_test = abap_true.
*    CREATE OBJECT lr_grid.
*    lr_grid->create_label( text = 'TESTMODUS - Die folgenden Daten wurden zur Übernahme ermitteln, aber nicht gespeichert.' row = 1 column = 1 ).
*    IF r_roles = abap_true.
*      CALL METHOD cl_salv_table=>factory
*        IMPORTING
*          r_salv_table = lr_table
*        CHANGING
*          t_table      = gt_roles.
*    ELSEIF r_active = abap_true.
*      CALL METHOD cl_salv_table=>factory
*        IMPORTING
*          r_salv_table = lr_table
*        CHANGING
*          t_table      = gt_active.
*    ELSEIF r_dialog = abap_true.
*      CALL METHOD cl_salv_table=>factory
*        IMPORTING
*          r_salv_table = lr_table
*        CHANGING
*          t_table      = gt_dialog_alv.
*      IF r_table = abap_true.
*        lr_grid->create_text( text = 'Zeilenfarbe ROT = Es ist ein Fehler aufgetreten.' row = 3 column = 1 ).
*        lr_grid->create_text( text = 'Zeilenfarbe GRÜN = Die Ermittlung der Daten war erfolgreich.' row = 4 column = 1 ).
*      ENDIF.
*      lr_columns = lr_table->get_columns( ).
*      lr_columns->set_color_column( 'ALV_COLOR' ).
*    ENDIF.
*
*    CALL METHOD lr_table->get_functions
*      RECEIVING
*        value = lr_functions.
*    lr_functions->set_all( ).
*
*    lr_table->set_top_of_list( lr_grid ).
*    lr_table->display( ).
*  ELSE.
*    IF iv_error_text IS INITIAL.
*      CREATE OBJECT lr_grid.
*      lr_grid->create_label( text = 'Folgende Daten wurden übernommen. Die ursprünglichen Daten wurden gelöscht.' row = 1 column = 1 ).
*      IF r_roles = abap_true.
*        CALL METHOD cl_salv_table=>factory
*          IMPORTING
*            r_salv_table = lr_table
*          CHANGING
*            t_table      = gt_roles.
*      ELSEIF r_active = abap_true.
*        CALL METHOD cl_salv_table=>factory
*          IMPORTING
*            r_salv_table = lr_table
*          CHANGING
*            t_table      = gt_active.
*      ELSEIF r_dialog = abap_true.
*        CALL METHOD cl_salv_table=>factory
*          IMPORTING
*            r_salv_table = lr_table
*          CHANGING
*            t_table      = gt_dialog_alv.
*        IF r_table = abap_true.
*          lr_grid->create_text( text = 'Zeilenfarbe ROT = Es ist ein Fehler aufgetreten.' row = 3 column = 1 ).
*          lr_grid->create_text( text = 'Zeilenfarbe GRÜN = Die Ermittlung der Daten war erfolgreich.' row = 4 column = 1 ).
*        ENDIF.
*        lr_columns = lr_table->get_columns( ).
*        lr_columns->set_color_column( 'ALV_COLOR' ).
*      ENDIF.
*
*      CALL METHOD lr_table->get_functions
*        RECEIVING
*          value = lr_functions.
*      lr_functions->set_all( ).
*
*      lr_table->set_top_of_list( lr_grid ).
*      lr_table->display( ).
*    ELSE.
*      WRITE: 'Es ist ein Fehler aufgetreten.'.
*      SKIP.
*      WRITE: lv_error_text.
*    ENDIF.
*  ENDIF.
*ENDFORM.                    " WRITE_LOG
