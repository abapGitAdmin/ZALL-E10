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
REPORT /ado/sql_performancer.

TABLES sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK opt WITH FRAME TITLE TEXT-001.
PARAMETERS: p_tab  TYPE dd02l-tabname,
            r_shw RADIOBUTTON GROUP opt user-command radcom default 'X',
            r_clr RADIOBUTTON GROUP opt,
            r_imp RADIOBUTTON GROUP opt,
            r_gen RADIOBUTTON GROUP opt.
SELECTION-SCREEN END OF BLOCK opt.

SELECTION-SCREEN BEGIN OF BLOCK param WITH FRAME TITLE TEXT-002.
PARAMETERS: p_sep  TYPE c DEFAULT ',',
            p_head AS CHECKBOX DEFAULT abap_true,
            p_clr  AS CHECKBOX DEFAULT abap_false.
SELECTION-SCREEN END OF BLOCK param.

SELECTION-SCREEN BEGIN OF BLOCK perf WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN PUSHBUTTON 1(30) b_perf USER-COMMAND perf.
SELECTION-SCREEN END OF BLOCK perf.

INITIALIZATION.
  b_perf = 'HANA vs RowStore'.

AT SELECTION-SCREEN OUTPUT.
  PERFORM pf_handle_radiobutton.

AT SELECTION-SCREEN.
  CASE sscrfields.
    WHEN 'PERF'.
      PERFORM pf_start_performancer.
  ENDCASE.

START-OF-SELECTION.
  PERFORM pf_start_program.

*&---------------------------------------------------------------------*
*&      Form  PF_HANDLE_RADIOBUTTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_handle_radiobutton .
  LOOP AT SCREEN.
    IF r_shw IS NOT INITIAL.
      IF screen-name = '%_P_SEP_%_APP_%-TEXT' OR
         screen-name = 'P_SEP' OR
         screen-name = 'P_HEAD' OR
         screen-name = 'P_CLR'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF r_clr IS NOT INITIAL.
      IF screen-name = '%_P_SEP_%_APP_%-TEXT' OR
         screen-name = 'P_SEP' OR
         screen-name = 'P_HEAD' OR
         screen-name = 'P_CLR'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF r_imp IS NOT INITIAL.
      IF screen-name = '%_P_SEP_%_APP_%-TEXT' OR
         screen-name = 'P_SEP' OR
         screen-name = 'P_HEAD' OR
         screen-name = 'P_CLR'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF r_gen IS NOT INITIAL.
      IF screen-name = '%_P_SEP_%_APP_%-TEXT' OR
         screen-name = 'P_SEP' OR
         screen-name = 'P_HEAD'.
        screen-active = 0.
        MODIFY SCREEN.
      ELSEIF screen-name = 'P_CLR'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PF_START_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_start_program .
  IF p_tab IS INITIAL.
    MESSAGE 'Bitte gib eine Datenbanktabelle an!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  SELECT SINGLE * FROM dd02l WHERE tabname = @p_tab INTO @DATA(ls_dd021).
  IF sy-subrc <> 0.
    MESSAGE 'Bitte wähle eine gültige Datenbanktabelle aus!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF r_imp IS NOT INITIAL.
    CALL METHOD zdr_cl_sql_importer=>import_csv_to_database
      EXPORTING
        iv_database_tabname = p_tab
        iv_seperator        = p_sep
        iv_clear_tab        = p_clr
        iv_header           = p_head.

  ELSEIF r_gen IS NOT INITIAL.
    CALL METHOD zdr_cl_sql_importer=>generate_database
      EXPORTING
        iv_database_tabname = p_tab
        iv_clear_tab        = p_clr.

  ELSEIF r_clr IS NOT INITIAL.
    CALL METHOD zdr_cl_sql_importer=>clear_database
      EXPORTING
        iv_database_tabname = p_tab.
  ENDIF.

*  SE16N aufrufen, um Inhalt der der Datenbanktabelle anzuzeigen
  SET PARAMETER ID 'DTB' FIELD p_tab.
  CALL TRANSACTION 'SE16N'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PF_START_PERFORMANCER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_start_performancer .
  CALL METHOD zdr_cl_sql_importer=>performancer_v2.
ENDFORM.
