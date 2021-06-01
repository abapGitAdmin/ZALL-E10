***************************************************************************************************
* Report  ZADM_CHECK_TLIBG_COMPLETENESS
* René Thimel, 17.01.2017
*--------------------------------------------------------------------------------------------------
* Logik aus RSTLIBG (Hinweis 783308)
* Vergleich TADIR und TLIBG durchführen und fehlende Einträge in TLIBG ausgeben.
***************************************************************************************************
REPORT zadm_check_tlibg_completeness.

TYPES: BEGIN OF ts_dialog_alv,
         pgmid      TYPE pgmid,
         object     TYPE trobjtype,
         obj_name   TYPE sobj_name,
         srcsystem  TYPE srcsystem,
         author     TYPE responsibl,
         genflag    TYPE genflag,
         devclass   TYPE devclass,
         created_on TYPE creationdt,
         error_text TYPE text256,
       END OF ts_dialog_alv,
       tt_dialog_alv TYPE TABLE OF ts_dialog_alv.

DATA: lr_table      TYPE REF TO cl_salv_table,
      lr_grid       TYPE REF TO cl_salv_form_layout_grid,
      lr_functions  TYPE REF TO cl_salv_functions_list,
      lr_columns    TYPE REF TO cl_salv_columns_table,
      lt_dialog_alv TYPE tt_dialog_alv,
      lt_tadir      TYPE TABLE OF tadir,
      ls_tlibg      TYPE tlibg,
      ls_trdir      TYPE trdir,
      ls_tfdir      TYPE tfdir,
      lv_area       TYPE rs38l_area, "für Funktionsgruppe
      lv_progname   TYPE progname.

FIELD-SYMBOLS: <ls_tadir>      TYPE tadir,
               <ls_dialog_alv> TYPE ts_dialog_alv.


SELECT-OPTIONS: s_pgmid FOR <ls_tadir>-pgmid DEFAULT 'R3TR',
                s_object FOR <ls_tadir>-object DEFAULT 'FUGR',
                s_objnam FOR <ls_tadir>-obj_name,
                s_srcsys FOR <ls_tadir>-srcsystem,
                s_dvclss FOR <ls_tadir>-devclass.


INITIALIZATION.
  "SAP-Objekte nicht prüfen
  s_srcsys-sign   = 'E'.
  s_srcsys-option = 'EQ'.
  s_srcsys-low    = 'SAP'.
  APPEND s_srcsys.


START-OF-SELECTION.

***** Auswertung **********************************************************************************
  SELECT * FROM tadir INTO TABLE lt_tadir
    WHERE pgmid IN s_pgmid AND object IN s_object AND obj_name IN s_objnam
      AND srcsystem IN s_srcsys AND devclass IN s_dvclss.
  IF sy-subrc <> 0.
    WRITE: 'Abbruch: TADIR ist leer.'.
    EXIT.
  ENDIF.

  LOOP AT lt_tadir ASSIGNING <ls_tadir>.
    SELECT SINGLE * FROM tlibg INTO ls_tlibg WHERE area = <ls_tadir>-obj_name.
    IF sy-subrc <> 0.
      "Eintrag nicht gefunden
      lv_area = <ls_tadir>-obj_name.
      CLEAR: lv_progname.
      CALL FUNCTION 'FUNCTION_INCLUDE_CONCATENATE'
        CHANGING
          program       = lv_progname
          complete_area = lv_area
        EXCEPTIONS
          OTHERS        = 1.
      IF sy-subrc <> 0.
        CONTINUE.
      ELSE.
        CONCATENATE 'SAPL' lv_area INTO lv_progname.
      ENDIF.

      IF lv_progname IS NOT INITIAL.
        SELECT SINGLE * FROM trdir INTO ls_trdir WHERE name = lv_progname.
        IF sy-subrc = 0.
          APPEND INITIAL LINE TO lt_dialog_alv ASSIGNING <ls_dialog_alv>.
          MOVE-CORRESPONDING <ls_tadir> TO <ls_dialog_alv>.
          <ls_dialog_alv>-error_text = 'Fehler: Programmname nicht ermittelt.'.
          CONTINUE.
        ELSE.
          "FuBas prüfen
          SELECT SINGLE * FROM tfdir INTO ls_tfdir WHERE pname = lv_progname.
          IF sy-subrc = 0.
            APPEND INITIAL LINE TO lt_dialog_alv ASSIGNING <ls_dialog_alv>.
            MOVE-CORRESPONDING <ls_tadir> TO <ls_dialog_alv>.
            <ls_dialog_alv>-error_text = 'Korrektur notwendig: Funktionsgruppe prüfen.'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.


***** Ausgabe *************************************************************************************
  CREATE OBJECT lr_grid.
  lr_grid->create_label( text = 'Vergleich TADIR mit TLIBG' row = 1 column = 1 ).

  cl_salv_table=>factory( IMPORTING r_salv_table = lr_table CHANGING t_table = lt_dialog_alv ).

  lr_functions = lr_table->get_functions( ).
  lr_functions->set_all( ).

  lr_columns = lr_table->get_columns( ).
  lr_columns->set_optimize( ).

  lr_table->set_top_of_list( lr_grid ).
  lr_table->display( ).
