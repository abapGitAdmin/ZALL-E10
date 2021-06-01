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
REPORT zhar_validate_table.

DATA :
  l_upd_active TYPE c LENGTH 1 VALUE '0',
  l_all_active TYPE c LENGTH 1 VALUE '0',
  l_ins_active TYPE c LENGTH 1 VALUE '0',
  l_list       TYPE vrm_values,
  l_line       TYPE vrm_value,
  l_cnt        TYPE i,
  l_len        TYPE i,
  lt_dd03p     TYPE STANDARD TABLE OF dd03p,
  ls_dd03p     TYPE dd03p,
  lrs_row      TYPE REF TO data,
  lv_fieldname TYPE string,
  lv_result    TYPE match_result.

FIELD-SYMBOLS : <ls_row> TYPE any,
                <pval>   TYPE any,
                <fs>     TYPE any.


"  SELECTION_TEXTS_MODIFY
PARAMETERS: p_tab   TYPE tabname DEFAULT '/adz/inv_cust',
            p_mode  TYPE char30    AS LISTBOX DEFAULT 'SHOW' VISIBLE LENGTH 15 USER-COMMAND mod,
            p_setc  TYPE string    VISIBLE LENGTH 100 MODIF ID  upd,
            p_where TYPE string    VISIBLE LENGTH 100 MODIF ID  all.
"p_incol TYPE string    VISIBLE LENGTH 100 MODIF ID  ins,
"p_inval TYPE string    VISIBLE LENGTH 100 MODIF ID  ins,
SELECTION-SCREEN SKIP 1.

PARAMETERS:
  p_col1  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col2  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col3  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col4  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col5  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col6  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col7  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col8  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col9  TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col10 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col11 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col12 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col13 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col14 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col15 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col16 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col17 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col18 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins,
  p_col19 TYPE string    VISIBLE LENGTH 50 MODIF ID  ins.
*---------------------------------------------------------
* EVENT INITIALISATION
*---------------------------------------------------------
INITIALIZATION.
  DATA : lv_state TYPE ddgotstate.

  l_line-key  = 'SHOW'.
  l_line-text = 'Select '.
  APPEND l_line TO l_list.
  l_line-key  = 'UPD'.
  l_line-text = 'Update '.
  APPEND l_line TO l_list.
  l_line-key  = 'DEL'.
  l_line-text = 'Delete '.
  APPEND l_line TO l_list.
  l_line-key  = 'INS'.
  l_line-text = 'Insert '.
  APPEND l_line TO l_list.

  CALL FUNCTION 'VRM_SET_VALUES' EXPORTING id = 'P_MODE' values = l_list.

AT SELECTION-SCREEN OUTPUT.
  l_upd_active =  0.
  l_all_active =  0.
  l_ins_active =  0.

  IF p_mode = 'UPD'.
    l_upd_active =  1.
    l_all_active =  1.
  ELSEIF p_mode = 'INS'.
    l_ins_active =  1.
  ENDIF.
  IF p_mode = 'DEL' OR p_mode = 'SHOW'.
    l_all_active =  1.
  ENDIF.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name      = p_tab
      state     = 'A'
      langu     = ' '
    IMPORTING
      gotstate  = lv_state
    TABLES
      dd03p_tab = lt_dd03p
    EXCEPTIONS
      OTHERS    = 1
      .


  LOOP AT SCREEN.
    IF screen-group1 = 'UPD'.
      screen-active = l_upd_active.
    ELSEIF screen-group1 = 'ALL'.
      screen-active = l_all_active .
    ELSEIF screen-group1 = 'INS'.
      IF l_ins_active = 0 OR lv_state = abap_false.
        screen-active = l_ins_active.

      ELSEIF screen-name(7) = '%_P_COL'.
        FIND FIRST OCCURRENCE OF REGEX '[1234567890]+' IN screen-name+7(2)  MATCH LENGTH l_len.
        l_cnt = screen-name+7(l_len).
        IF l_cnt <= lines( lt_dd03p ).
          lv_fieldname = |%_P_COL{ l_cnt }_%_APP_%-TEXT|.
          ASSIGN (lv_fieldname) TO <fs>.
          <fs> = lt_dd03p[ l_cnt ]-fieldname.
          screen-active = l_ins_active .
        ELSE.
          screen-active =   0.
          screen-name   =  'not used'.
        ENDIF.
      ELSEIF  screen-name(5) = 'P_COL'.
        FIND FIRST OCCURRENCE OF REGEX '[1234567890]+' IN screen-name+5(2)  MATCH LENGTH l_len.
        l_cnt = screen-name+5(l_len).
        IF l_cnt <= lines( lt_dd03p ).
          screen-active =  l_ins_active.
          IF lt_dd03p[ l_cnt ]-fieldname = 'MANDT'.
            ASSIGN (screen-name) TO <fs>.
            <fs> = sy-mandt.
          ENDIF.
        ELSE.
          screen-active =  0.
        ENDIF.
      ELSE.
        screen-active = l_ins_active .
      ENDIF.

    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.

  "-------------------------------------------------------------------------------------------------------

START-OF-SELECTION.

  DATA :
    l_answer     TYPE c LENGTH 1,
    l_where      TYPE string,
    lr_tab       TYPE REF TO data,
    lr_tabline   TYPE REF TO data,
    l_alv_layout TYPE slis_layout_alv,
    l_sortinfo   TYPE slis_t_sortinfo_alv,
    l_alvvar     TYPE slis_vari.
  FIELD-SYMBOLS:
    <lt_tab> TYPE ANY TABLE,
    <ls_tab> TYPE any.

  try.
  IF p_mode = 'SHOW'.
    CREATE DATA lr_tab TYPE TABLE OF (p_tab).
    ASSIGN lr_tab->* TO <lt_tab>.
    CREATE DATA lr_tabline TYPE (p_tab).
    ASSIGN lr_tabline->* TO <ls_tab>.

    SELECT * FROM (p_tab) INTO TABLE <lt_tab> WHERE  (p_where).

    CALL METHOD zhar_cl_alv_grid=>instance->ausgabe_alv_fuba(
      EXPORTING
        i_title       = |{ p_tab }|
        i_dstichtag   = sy-datum
        i_alv_repid   = sy-repid
        i_technames   = 'X'
        i_alv_variant = l_alvvar    " variante
        i_alv_sort    = l_sortinfo  " u_alv_sort
        i_alv_layout  = l_alv_layout
      CHANGING
        c_tab_ausgabe = <lt_tab> ).

  ELSEIF p_mode = 'DEL'.
    SELECT COUNT(*) FROM (p_tab) INTO l_cnt WHERE  (p_where).
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = 'Bestätigung der Aufraeumens'
        text_question  = |{ l_cnt } Datensaetze entfernen ?|
        text_button_1  = 'Ja'
        text_button_2  = 'Nein'
        default_button = '1'
      IMPORTING
        answer         = l_answer
      EXCEPTIONS
        OTHERS         = 0.
    IF l_answer = '1'.
      DELETE FROM (p_tab) WHERE  (p_where).
      l_cnt = sy-dbcnt.
      IF sy-subrc NE 0.
        WRITE : 'Error in statment'.
      ELSE.
        WRITE : l_cnt, ' Datensaetze entfernt'.
      ENDIF.
    ENDIF.

  ELSEIF p_mode = 'UPD'.
    "sy-uname = 'SAPALL'.
    SELECT COUNT(*) FROM (p_tab) INTO l_cnt WHERE  (p_where).
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = 'Bestätigung der Aktualisierens'
        text_question  = |{ l_cnt } Datensaetze aktualisieren ?|
        text_button_1  = 'Ja'
        text_button_2  = 'Nein'
        default_button = '1'
      IMPORTING
        answer         = l_answer
      EXCEPTIONS
        OTHERS         = 0.
    IF l_answer = '1'.
      UPDATE (p_tab) SET (p_setc) WHERE  (p_where).
      l_cnt = sy-dbcnt.
      IF sy-subrc NE 0.
        WRITE : 'Error in statment'.
      ELSE.
        WRITE : l_cnt, ' Datensaetze aktualisiert'.
      ENDIF.
    ENDIF.

  ELSEIF p_mode = 'INS'.
    l_cnt = 1.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar       = 'Bestätigung der Einfügens'
        text_question  = |{ l_cnt } Datensatz einfügen ?|
        text_button_1  = 'Ja'
        text_button_2  = 'Nein'
        default_button = '1'
      IMPORTING
        answer         = l_answer
      EXCEPTIONS
        OTHERS         = 0.
    IF l_answer = '1'.
      CREATE DATA lrs_row TYPE (p_tab).
      ASSIGN lrs_row->* TO <ls_row>.
      LOOP AT lt_dd03p INTO ls_dd03p.
        l_cnt = sy-tabix.
        ASSIGN COMPONENT ls_dd03p-fieldname OF STRUCTURE <ls_row> TO <fs>.
        IF sy-subrc ne 0.
          MESSAGE |componente { ls_dd03p-fieldname } nicht gefunden.| TYPE 'E'.
        ENDIF.
        lv_fieldname = |P_COL{ l_cnt }|.
        ASSIGN (lv_fieldname) TO <pval>.
        <fs> = <pval>.
      ENDLOOP.

      INSERT INTO (p_tab) VALUES <ls_row>.
      l_cnt = sy-dbcnt.
      IF sy-subrc NE 0.
        WRITE : 'Error in statment'.
      ELSE.
        WRITE : l_cnt, ' Datensaetze eingefügt'.
      ENDIF.
    ENDIF.

  ENDIF.
  catch  cx_sy_dynamic_osql_semantics into data(lcx_dyn_sem).
    write : /'Ausnahme cx_sy_dynamic_osql_semantics: ', lcx_dyn_sem->get_text( ).
  catch  cx_root into data(lcx_root).
    write : /'Ausnahme cx_root: ', lcx_root->get_text( ).
  endtry.
