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
*&         Appel Harald  29.10.2019
************************************************************************
*******
REPORT /adz/copy_tables.

TYPES: BEGIN OF ty_tabinfo,
         mark            TYPE abap_bool,
         source_tab      TYPE tabname,
         source_tab_rows TYPE integer,
         target_tab      TYPE tabname,
         target_tab_rows TYPE integer,
         copied_rows     TYPE integer,
         copy_status     TYPE char30,
       END OF ty_tabinfo.

TYPES tt_tabinfo TYPE STANDARD TABLE OF ty_tabinfo.

SELECTION-SCREEN BEGIN OF BLOCK bla WITH FRAME TITLE TEXT-001.
PARAMETERS  p_srckrz TYPE tabname DEFAULT '/ADESSO/'.
PARAMETERS  p_tarkrz TYPE tabname DEFAULT '/ADZ/'.
PARAMETERS  p_srrest AS CHECKBOX DEFAULT abap_false.
PARAMETERS  p_tarest AS CHECKBOX DEFAULT abap_false.

SELECTION-SCREEN END OF BLOCK bla.
****************************************************************************
****************************************************************************
DATA gt_tabinfo  TYPE tt_tabinfo.

START-OF-SELECTION.


  PERFORM get_tabinfo
    USING
      p_srckrz
      p_tarkrz
      p_srrest
      p_tarest
    CHANGING
      gt_tabinfo.

  PERFORM output_alv CHANGING gt_tabinfo.

***************************************************************************
FORM output_alv
***************************************************************************
    CHANGING  ct_tabinfo  TYPE tt_tabinfo.

  DATA(mt_fieldcat) = value slis_t_fieldcat_alv(
    ( fieldname = 'MARK'            tabname  = 'IT_OUTPUT'  key  = 'X'  edit = 'X'  input = 'X'  checkbox = 'X'
         seltext_s = 'Copy'  seltext_m = 'Copy'  seltext_l = 'Copy' )
    ( fieldname = 'SOURCE_TAB'      tabname  = 'IT_OUTPUT'  key  = 'X'  seltext_s = 'Quelltab'  seltext_m = 'Quelltabelle'   outputlen = 20 )
    ( fieldname = 'SOURCE_TAB_ROWS' tabname  = 'IT_OUTPUT'  seltext_s = '#Z Quelle'  seltext_m = '#Zeilen Quelle'    outputlen = 10 )
    ( fieldname = 'TARGET_TAB'      tabname  = 'IT_OUTPUT'  seltext_s = 'Zieltab'    seltext_m = 'Zieltabelle'       outputlen = 20 )
    ( fieldname = 'TARGET_TAB_ROWS' tabname  = 'IT_OUTPUT'  seltext_s = '#Z Ziel'    seltext_m = '#Zeilen Ziel'      outputlen = 10 )
    ( fieldname = 'COPIED_ROWS'     tabname  = 'IT_OUTPUT'  seltext_s = '#Z kopiert' seltext_m = '#Zeilen kopiert'   outputlen = 10 )
    ( fieldname = 'COPY_STATUS'     tabname  = 'IT_OUTPUT'  seltext_s = 'KopStat'    seltext_m = 'Kopierstatus'  icon = 'X'  outputlen =  5 )
  ).

  DATA lt_events TYPE slis_t_event.
  PERFORM set_events CHANGING lt_events.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid " Reportnamen in Grossbuchstaben
      "is_layout          = s_layout
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      it_fieldcat              = mt_fieldcat
      it_events                = lt_events
    TABLES
      t_outtab                 = ct_tabinfo
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.

***************************************************************************
FORM get_tabinfo
***************************************************************************
    USING  iv_src_prefix TYPE tabname
           iv_tar_prefix TYPE tabname
           if_show_src_rest TYPE abap_bool
           if_show_tar_rest TYPE abap_bool
    CHANGING  ct_tabinfo  TYPE tt_tabinfo.

  DATA lv_srcname  TYPE tabname.
  DATA ls_tabinfo  TYPE ty_tabinfo.
  DATA(lv_srctabpattern) = |{ iv_src_prefix }%|.
  DATA(lv_tartabpattern) = |{ iv_tar_prefix }%|.

  CLEAR ct_tabinfo.
  SELECT tabname FROM dd02l INTO TABLE @DATA(lt_src_tabnames)
     WHERE tabname LIKE @lv_srctabpattern
      AND tabclass = 'TRANSP'
      AND as4local = 'A'
      order by tabname.

  SELECT tabname FROM dd02l INTO TABLE @DATA(lt_tar_tabnames)
     WHERE tabname LIKE @lv_tartabpattern
      AND tabclass = 'TRANSP'
      AND as4local = 'A'
      order by tabname.

  " Gleichartige Namen finden.
  LOOP AT lt_tar_tabnames REFERENCE INTO DATA(lr_target).
    lv_srcname = lr_target->tabname.
    REPLACE FIRST OCCURRENCE OF iv_tar_prefix IN lv_srcname WITH iv_src_prefix.
    LOOP AT lt_src_tabnames REFERENCE INTO DATA(lr_source)
       WHERE tabname EQ lv_srcname.
      CLEAR ls_tabinfo.
      ls_tabinfo-source_tab = lr_source->tabname.
      ls_tabinfo-target_tab = lr_target->tabname.
      APPEND ls_tabinfo TO ct_tabinfo.
      " Gefundene Namen aus Tabellenlisten entfernen
      DELETE lt_src_tabnames.
      DELETE lt_tar_tabnames.
    ENDLOOP.
  ENDLOOP.
  IF if_show_src_rest EQ abap_true.
    LOOP AT lt_src_tabnames REFERENCE INTO lr_source.
      CLEAR ls_tabinfo.
      ls_tabinfo-source_tab = lr_source->tabname.
      APPEND ls_tabinfo TO ct_tabinfo.
    ENDLOOP.
  ENDIF.
  IF if_show_tar_rest EQ abap_true.
    LOOP AT lt_tar_tabnames REFERENCE INTO lr_target.
      CLEAR ls_tabinfo.
      ls_tabinfo-target_tab = lr_target->tabname.
      APPEND ls_tabinfo TO ct_tabinfo.
    ENDLOOP.
  ENDIF.

  " Tabellenzeilen zaehlen
  LOOP AT ct_tabinfo ASSIGNING FIELD-SYMBOL(<ls_tabinfo>).
    IF <ls_tabinfo>-source_tab IS NOT INITIAL.
      SELECT COUNT( * ) FROM (<ls_tabinfo>-source_tab) INTO <ls_tabinfo>-source_tab_rows.
    ENDIF.
    IF <ls_tabinfo>-target_tab IS NOT INITIAL.
      SELECT COUNT( * ) FROM (<ls_tabinfo>-target_tab) INTO <ls_tabinfo>-target_tab_rows.
    ENDIF.
  ENDLOOP.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.

  DATA rev_alv TYPE REF TO cl_gui_alv_grid.
  DATA lt_filtered TYPE slis_t_filtered_entries.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = rev_alv.

  CALL METHOD rev_alv->check_changed_data.

  rs_selfield-refresh    = 'X'.
  rs_selfield-row_stable = 'X'.
  rs_selfield-col_stable = 'X'.

  REFRESH lt_filtered.
  CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
    IMPORTING
      et_filtered_entries = lt_filtered
    EXCEPTIONS
      no_infos            = 1
      program_error       = 2
      OTHERS              = 3.
  IF r_ucomm  = 'SELECT_ALL'.
    PERFORM select_all USING lt_filtered.
  ELSEIF r_ucomm  = 'DESELECT'.
    PERFORM deselect_all.
  ELSEIF r_ucomm = 'COPY_TABS'.
    PERFORM copy_tables.
  ENDIF.
ENDFORM.
*-----------------------------------------------------------------------
*    FORM SET_EVENTS
*-----------------------------------------------------------------------
FORM set_events CHANGING r_event TYPE slis_t_event.
* FuBa für Eventhandling
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'                    "#EC *
    EXPORTING
      i_list_type     = 4
    IMPORTING
      et_events       = r_event
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.
  READ TABLE r_event WITH KEY name = slis_ev_top_of_page INTO DATA(s_event).
  IF sy-subrc = 0.
    MOVE slis_ev_top_of_page TO s_event-form.
    "MODIFY r_event FROM s_event INDEX sy-tabix.
  ENDIF.
ENDFORM..                    " SET_EVENTS
*-----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*-----------------------------------------------------------------------
FORM set_pf_status USING extab TYPE slis_t_extab.
  DATA(x) = 1.
  " Achtung Fehler werden nicht erkannt ! Danger ! Periculu !
  SET PF-STATUS 'STATUS_STANDARD' EXCLUDING extab.
  IF sy-subrc NE 0.
    MESSAGE 'PF-STATUS-Fehler' TYPE 'E'.
  ENDIF.
*  if pa_updte = 'X'.
*    set pf-status 'STANDARD_DIRECTUPD' excluding extab.
*  else.
*    if pa_showh = 'X'.
*      set pf-status 'STANDARD_DIRECTUPD' excluding extab.
*    else.
*      set pf-status 'STANDARD_STATUS' excluding extab.
*    endif.
*  endif.
ENDFORM.                    "status_standard
*&---------------------------------------------------------------------*
*&      Form SELECT_ALL
*&---------------------------------------------------------------------*
FORM select_all USING it_filtered TYPE slis_t_filtered_entries.
  LOOP AT gt_tabinfo ASSIGNING FIELD-SYMBOL(<ls_tabinfo>).
    READ TABLE it_filtered
      WITH KEY table_line = sy-tabix
      TRANSPORTING NO FIELDS.
    CHECK sy-subrc NE 0.
    IF <ls_tabinfo>-source_tab IS NOT INITIAL
    AND <ls_tabinfo>-target_tab IS NOT INITIAL
    AND <ls_tabinfo>-source_tab_rows > 0.
      <ls_tabinfo>-mark = 'X'.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  DESELECT_ALL
*&---------------------------------------------------------------------*
FORM deselect_all .
  LOOP AT gt_tabinfo ASSIGNING FIELD-SYMBOL(<ls_tabinfo>).
    <ls_tabinfo>-mark = ''.
  ENDLOOP.
ENDFORM.                    " DESELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  COPY_TABLES
*&---------------------------------------------------------------------*
FORM copy_tables.
  DATA lv_answer TYPE char1.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = 'Tabelleninhalte werden nun kopiert'
      textline2     = 'Sind sie sicher (J/N)'
      titel         = 'Bestätigung erforderlich'
    IMPORTING
      answer        = lv_answer.

  IF NOT lv_answer CA 'jJyY'.
    EXIT.
  ENDIF.

  DATA lr_src_data TYPE REF TO data.
  DATA lv_start  type i.
  DATA lv_end    type i.
  DATA lv_offset type i value 500000.
  FIELD-SYMBOLS <lt_src_data> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lt_src_data_tmp> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <ls_src_data> type any.

  LOOP AT gt_tabinfo ASSIGNING FIELD-SYMBOL(<ls_tabinfo>).
    CHECK <ls_tabinfo>-mark = 'X'.
    CHECK <ls_tabinfo>-source_tab IS NOT INITIAL
      AND <ls_tabinfo>-target_tab IS NOT INITIAL.

    CREATE DATA lr_src_data TYPE STANDARD TABLE OF (<ls_tabinfo>-source_tab).
    ASSIGN lr_src_data->* TO <lt_src_data>.
    " into table
    SELECT * FROM (<ls_tabinfo>-source_tab) INTO TABLE <lt_src_data>.
    IF lines( <lt_src_data> ) EQ 0.
      <ls_tabinfo>-copy_status = icon_led_inactive.
      CONTINUE.
    ENDIF.
    DATA(lv_lines) = lines( <lt_src_data> ).
    if lv_lines > lv_offset.
       CREATE DATA lr_src_data TYPE STANDARD TABLE OF (<ls_tabinfo>-source_tab).
       ASSIGN lr_src_data->* TO <lt_src_data_tmp>.
       lv_start = 1.
       while lv_start <= lv_lines.
         lv_end  = nmin( val1 = lv_start + lv_offset - 1  val2 =  lv_lines ).
         clear <lt_src_data_tmp>.
         loop at <lt_src_data> ASSIGNING <ls_src_data> from lv_start to lv_end.
            append <ls_src_data> to <lt_src_data_tmp>.
         ENDLOOP.
         MODIFY (<ls_tabinfo>-target_tab) FROM TABLE <lt_src_data_tmp>.
         lv_start = lv_end + 1.
       ENDWHILE.
    else.
        MODIFY (<ls_tabinfo>-target_tab) FROM TABLE <lt_src_data>.
    endif.
    commit work.
    IF sy-subrc NE 0.
      <ls_tabinfo>-copy_status = icon_led_red.
    ELSE.
      <ls_tabinfo>-copy_status = icon_led_green.
      <ls_tabinfo>-copied_rows = sy-dbcnt.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " DESELECT_ALL
