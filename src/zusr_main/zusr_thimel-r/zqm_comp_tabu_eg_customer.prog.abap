*&---------------------------------------------------------------------*
*& Report  ZQM_COMP_TABU_EG_CUSTOMER
*&
*&---------------------------------------------------------------------*
*& Der Report vergleicht den Tabelleninhalt von E/G-Tabellen, wo eines
** der Schlüsselfelder im Kundennamensraum liegt.
*& Kleeberg, 14.06.2017
*&---------------------------------------------------------------------*
REPORT zqm_comp_tabu_eg_customer LINE-SIZE 255.


TABLES: dd02l, dd03l.
TABLES: trnspacet.

DATA: gt_dd02l TYPE STANDARD TABLE OF dd02l.
DATA: gs_dd02l TYPE dd02l.
DATA: gv_rel_name TYPE ddobjname.
DATA: gt_field_list TYPE ddfields.
DATA: gs_dfies TYPE dfies.

TYPES ty_tabname TYPE dd02l-tabname.
TYPES ty_tabtext TYPE dd02t-ddtext.

*FIELD-SYMBOLS <tabdata> TYPE ANY TABLE.

DATA: gv_anz_ds TYPE i.
DATA: gv_anz_tab TYPE i.
DATA: gv_anz_anzeige TYPE i.


DATA: BEGIN OF gs_ausgabe,
        tabname      TYPE dd02l-tabname,
        tabtext      TYPE dd02t-ddtext,
        anz_ds       TYPE i,
        anz_error    TYPE i,
        error_string TYPE string, "char300,
      END OF gs_ausgabe.
DATA: gt_ausgabe LIKE STANDARD TABLE OF gs_ausgabe.


*INCLUDE ZQM_COMPARE_TABU_tabhandler.


TYPES:
  BEGIN OF ty_header,
    tabname TYPE ty_tabname,
    tabtext TYPE ty_tabtext,
*    match_count TYPE i,
  END OF ty_header.

TYPES ty_header_tab TYPE TABLE OF ty_header.

TYPES:
  BEGIN OF ty_table.
        INCLUDE TYPE ty_header.
*TYPES: ref TYPE REF TO lcl_table_handler,
**           alv TYPE REF TO lcl_list_handler,
TYPES:       END OF ty_table.

TYPES ty_table_tab TYPE TABLE OF ty_table.
DATA gt_table TYPE ty_table_tab.

DATA: lt_zqm_key_value_eg TYPE STANDARD TABLE OF zqm_key_value_eg.


DATA: c_false TYPE c.

DATA: gs_extract_l TYPE disextract,
      gs_extract_s TYPE disextract.
DATA: gv_exnam_l  TYPE slis_extr,
      gv_bra_text TYPE tb038b-text.


DATA: lt_range_namespace TYPE i_isu_ranges,
      ls_range           TYPE isu_ranges.

DATA: gs_trnspacet TYPE trnspacet.







SELECT-OPTIONS: s_tab FOR dd02l-tabname,
                s_contf FOR dd02l-contflag DEFAULT 'E' TO 'G'.
*PARAMETERS: p_zmandt TYPE mandt OBLIGATORY DEFAULT sy-mandt.
PARAMETERS: p_anz_e TYPE i DEFAULT '1000'.

*SELECTION-SCREEN SKIP 1.
PARAMETERS: rfc_dest LIKE  rfcdes-rfcdest OBLIGATORY.

parameters: p_abh as CHECKBOX default 'X'.
parameters: p_unabh as CHECKBOX default 'X'.



SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN BEGIN OF BLOCK ext WITH FRAME TITLE text-ext.
PARAMETERS:        p_normal TYPE kennzx RADIOBUTTON GROUP extr
                                       DEFAULT 'X',
                   p_exsave TYPE kennzx RADIOBUTTON GROUP extr,
                   p_exload TYPE kennzx RADIOBUTTON GROUP extr.
PARAMETERS:        p_exnams TYPE slis_extr MODIF ID exs,
                   p_exbezs TYPE slis_exbz MODIF ID exs.

SELECTION-SCREEN END OF BLOCK ext.

*-----------------------------------------------------------------------
* Initialization
*-----------------------------------------------------------------------
INITIALIZATION.
  CALL FUNCTION 'REUSE_ALV_EXTRACT_AT_INIT'
    CHANGING
      cs_extract1 = gs_extract_l
      cs_extract2 = gs_extract_s.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_exnams.

  gs_extract_s-exname = p_exnams.
  gs_extract_s-report = sy-repid.
  CALL FUNCTION 'REUSE_ALV_EXTRACT_F4'
    EXPORTING
      is_extract = gs_extract_s
    IMPORTING
      es_extract = gs_extract_s
    EXCEPTIONS
      not_found  = 1
      no_report  = 2
      OTHERS     = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            DISPLAY LIKE 'E'.
  ELSE.
    p_exnams = gs_extract_s-exname.
    gv_exnam_l = gs_extract_s-exname.
  ENDIF.





START-OF-SELECTION.


  IF rfc_dest IS NOT INITIAL.
* Prüfen, ob Destination funktioniert und Fuba laufen wird
    CALL FUNCTION 'RFC_READ_R3_DESTINATION'
      EXPORTING
        destination             = rfc_dest
        authority_check         = c_false
      EXCEPTIONS
        authority_not-available = 1
        destination_not_exist   = 2
        information_failure     = 3
        internal                = 4
        OTHERS                  = 5.

    IF sy-subrc = 1.
      WRITE :/1(12) rfc_dest, 'FEHLER: Authorisierung fehlt !'.
      STOP. EXIT.
    ELSEIF sy-subrc = 2.
      WRITE :/1(12) rfc_dest, 'FEHLER: Destination existiert nicht !'.
      STOP. EXIT.
    ELSEIF sy-subrc = 3.
      WRITE :/1(12) rfc_dest, 'FEHLER: Informationsfehler !'.
      STOP. EXIT.
    ELSEIF sy-subrc = 4.
      WRITE :/1(12) rfc_dest, 'FEHLER: Interner Fehler !'.
      STOP. EXIT.
    ELSEIF sy-subrc = 5.
      WRITE :/1(12) rfc_dest, 'FEHLER: Andere Gründe !'.
      STOP. EXIT.
    ENDIF.

  ENDIF.






  FIELD-SYMBOLS <table> LIKE LINE OF gt_table.

  CLEAR ls_range.
  ls_range-sign    = 'I'.
  ls_range-option  = 'CP'.
  ls_range-low     = 'Z*'.
  COLLECT ls_range INTO lt_range_namespace.

  ls_range-sign    = 'I'.
  ls_range-option  = 'CP'.
  ls_range-low     = 'Y*'.
  COLLECT ls_range INTO lt_range_namespace.

  ls_range-sign    = 'I'.
  ls_range-option  = 'CP'.
  ls_range-low     = '/CONDET/*'.
  COLLECT ls_range INTO lt_range_namespace.

  SELECT * FROM trnspacet INTO gs_trnspacet
                          WHERE namespace NE space
                            AND changeuser NE 'SAP'.
    CLEAR ls_range.
    ls_range-sign    = 'I'.
    ls_range-option  = 'CP'.
*      ls_range-low     = te422-termschl.
    CONCATENATE gs_trnspacet-namespace '*' INTO ls_range-low.
    COLLECT ls_range INTO lt_range_namespace.
  ENDSELECT.




  IF NOT p_normal IS INITIAL OR
     NOT p_exsave IS INITIAL.


    PERFORM sel_daten.

  ENDIF.

  IF NOT p_normal IS INITIAL.

* ALV-Ausgabe
    PERFORM alv_ausgabe.



  ELSEIF NOT p_exsave IS INITIAL. "Extract speichern
    PERFORM save_extract.

  ELSEIF NOT p_exload IS INITIAL. "Extract hochladen und anzeigen
    PERFORM load_extract_and_display.

  ENDIF.
















*
*&---------------------------------------------------------------------*
*&      Form  SEL_DATEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sel_daten .

  FIELD-SYMBOLS <table> LIKE LINE OF gt_table.
*  FIELD-SYMBOLS <tabdata> TYPE ANY TABLE.
  FIELD-SYMBOLS  <tab>    TYPE table.
  FIELD-SYMBOLS  <help_tab>   TYPE table.

  DATA: ref_tab_eigen         TYPE REF TO data.


  DATA: ref_tab         TYPE REF TO data.
*  DATA: lv_test_mandt(10) TYPE c VALUE 'MANDT'.
*  DATA: lv_test_vertrag(10) TYPE c VALUE 'VERTRAG'.
  DATA: lv_string(255) TYPE c. "string.
  DATA: lv_string2 TYPE string.
  DATA: lv_where_string TYPE string.
  DATA: lv_ret_code TYPE sy-subrc.
  DATA: lv_write_string TYPE string.
  DATA: lv_where_string_rfc TYPE string.


  FIELD-SYMBOLS: <fs_line>  TYPE any,
                 <fv_value> TYPE any.
  FIELD-SYMBOLS: <fv_value_write> TYPE any.
  FIELD-SYMBOLS: <fv_value_rfc> TYPE any.

  FIELD-SYMBOLS: <fs_tab_line>  TYPE any.

  DATA: BEGIN OF ls_keytab,
          fieldname  TYPE dfies-fieldname,
          VALUE(100) TYPE c,
          datatype   TYPE dynptype,
        END OF ls_keytab.
  DATA: lt_keytab LIKE STANDARD TABLE OF ls_keytab.

  DATA: BEGIN OF ls_keytab_rfc,
          fieldname  TYPE dfies-fieldname,
          VALUE(100) TYPE c,
          datatype   TYPE dynptype,
        END OF ls_keytab_rfc.
  DATA: lt_keytab_rfc LIKE STANDARD TABLE OF ls_keytab_rfc.


  DATA: lv_tabname TYPE dfies-fieldname.

  DATA: lv_help_value(200) TYPE c.

*  data: lt_ZQM_KEY_VALUE_EG type STANDARD TABLE OF ZQM_KEY_VALUE_EG.

  DATA: lt_where_option TYPE TABLE OF rfc_db_opt,
        lt_fields       TYPE TABLE OF rfc_db_fld,
        lt_data         TYPE TABLE OF tab512. "ZTAB5536. "tab512.
  DATA: ls_fields TYPE  rfc_db_fld,
        ls_data   TYPE  ztab5536. "tab512.
  FIELD-SYMBOLS: <fs_ext_tab_line>  TYPE any.

  DATA: lv_help(10) TYPE c.
  DATA: lv_help_where_string TYPE string.

  DATA: lv_anz_error TYPE i.

*> neu
  DATA: lv_help_fieldname_string TYPE string.
  DATA: lv_help_read_table_string TYPE char200. "string.
  FIELD-SYMBOLS: <fv_string_read_line>  TYPE any.
  FIELD-SYMBOLS: <fv_string_fieldname>  TYPE any.

*< neu

  DATA: lt_where_option_eigen TYPE TABLE OF rfc_db_opt,
        lt_fields_eigen       TYPE TABLE OF rfc_db_fld,
        lt_data_eigen         TYPE TABLE OF tab512.
  DATA:        lt_data_rfc         TYPE TABLE OF tab512. "tab512.

  DATA: ls_fields_eigen TYPE  rfc_db_fld,
        ls_data_eigen   TYPE  tab512.

  FIELD-SYMBOLS  <tab_eigen>    TYPE table.
  FIELD-SYMBOLS: <fs_ext_tab_line_eigen>  TYPE any.

  DATA: lv_anz_ds_eigen TYPE i.

  DATA: lv_flag_error_read_table(1) TYPE c.




  SELECT tabname FROM dd02l INTO CORRESPONDING FIELDS OF TABLE gt_table
    WHERE tabname IN s_tab
     AND tabclass = 'TRANSP'
     AND contflag IN s_contf.

  IF sy-subrc <> 0.
    MESSAGE e034(mdg_idm_tools).
  ENDIF.


  LOOP AT gt_table ASSIGNING <table>.
    CLEAR gs_ausgabe.

* create internal table
    CREATE DATA ref_tab_eigen TYPE STANDARD TABLE OF (<table>-tabname).
    ASSIGN ref_tab_eigen->* TO <tab_eigen>.

    SELECT * FROM (<table>-tabname) INTO TABLE <tab_eigen>.


    SELECT SINGLE ddtext FROM dd02t
                INTO gs_ausgabe-tabtext
            WHERE tabname = <table>-tabname
              AND ddlanguage = sy-langu.


     move gs_ausgabe-tabtext to <table>-tabtext.


    CLEAR: gv_anz_ds.
    DESCRIBE TABLE  <tab_eigen> LINES gv_anz_ds.
    IF gv_anz_ds < 1.
      FREE ref_tab_eigen.
      FREE <tab_eigen>.
      CONTINUE.
    ENDIF.




    CLEAR: gv_rel_name.
    REFRESH: gt_field_list.
    MOVE <table>-tabname TO gv_rel_name.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = gv_rel_name
*       FIELDNAME      = ' '
*       langu          = sy-langu
*       LFIELDNAME     = ' '
        all_types      = 'X'
*       GROUP_NAMES    = ' '
*       UCLEN          =
*       DO_NOT_WRITE   = ' '
*   IMPORTING
*       X030L_WA       =
*       DDOBJTYPE      =
*       DFIES_WA       =
*       LINES_DESCR    =
      TABLES
        dfies_tab      = gt_field_list
*       FIXED_VALUES   =
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.

    ENDIF.

    DELETE gt_field_list WHERE keyflag NE 'X'.

    LOOP AT gt_field_list INTO gs_dfies
               where datatype eq 'CLNT'.
    endloop.
    if sy-subrc eq 0. "Mandantenabhängige Tabelle
      if p_abh is initial.
        continue.
      endif.
    else. "Mandantenunabhängige Tabelle
      if p_unabh is initial.
        continue.
      endif.
   endif.



    ASSIGN <tab_eigen> TO <help_tab>.

*    DO gv_anz_ds TIMES.
    REFRESH lt_keytab.
    CLEAR: ls_keytab.

*    read table <tabdata> index sy-index assigning <fs_line>.
    READ TABLE <help_tab> INDEX 1 ASSIGNING <fs_line>.

    LOOP AT gt_field_list INTO gs_dfies.
      MOVE gs_dfies-tabname TO lv_tabname.
*      IF gs_dfies-datatype NE 'CHAR'.
*        CONTINUE.
*      ENDIF.


      ASSIGN COMPONENT gs_dfies-fieldname OF STRUCTURE <fs_line> TO <fv_value>.
      IF sy-subrc EQ 0.
        IF gs_dfies-datatype EQ 'CHAR'.
          ls_keytab-fieldname = gs_dfies-fieldname.
          ls_keytab-value = <fv_value>.
          ls_keytab-datatype = gs_dfies-datatype.
          APPEND ls_keytab TO lt_keytab.
        ENDIF.

** alle Keys (für RFC)
*        ls_keytab_rfc-fieldname = gs_dfies-fieldname.
*        ls_keytab_rfc-value = <fv_value>.
*        ls_keytab_rfc-datatype = gs_dfies-datatype.
*        APPEND ls_keytab_rfc TO lt_keytab_rfc.


      ENDIF.
    ENDLOOP.


*    REFRESH: lt_zqm_key_value_eg.
*    lt_zqm_key_value_eg[] = lt_keytab_rfc[].



* dynamischen where-string erzeugen für Source-System
    CLEAR lv_where_string.
    LOOP AT lt_keytab INTO ls_keytab.

      IF ls_keytab-datatype NE 'CHAR' AND sy-tabix NE 1.
        CONTINUE.
      ENDIF.

      CASE sy-tabix.
        WHEN 1.
          CONCATENATE ls_keytab-fieldname 'in' 'lt_range_namespace' INTO lv_where_string SEPARATED BY space.
        WHEN OTHERS.
          CONCATENATE lv_where_string 'or' ls_keytab-fieldname 'in' 'lt_range_namespace' INTO lv_where_string SEPARATED BY space.
      ENDCASE.
    ENDLOOP.



    CLEAR: gv_anz_ds, gv_anz_anzeige.
    CLEAR: gs_ausgabe.
    clear: lv_anz_error.
* jetzt prüfen, ob Datensatz im anderen System existiert
    TRY.
        CHECK lv_where_string IS NOT INITIAL.
        LOOP AT <help_tab> ASSIGNING <fs_tab_line>
                WHERE (lv_where_string).
*          WRITE: / <table>-tabname.


           gv_anz_ds = gv_anz_ds + 1.
*          gv_anz_anzeige = gv_anz_anzeige + 1.
*          CLEAR: lv_write_string.

          REFRESH lt_keytab_rfc.
          CLEAR: ls_keytab_rfc.
          LOOP AT gt_field_list INTO gs_dfies.
            MOVE gs_dfies-tabname TO lv_tabname.

            ASSIGN COMPONENT gs_dfies-fieldname OF STRUCTURE <fs_tab_line> TO <fv_value_rfc>.
            IF sy-subrc EQ 0.
* alle Keys (für RFC)
              ls_keytab_rfc-fieldname = gs_dfies-fieldname.
              ls_keytab_rfc-value = <fv_value_rfc>.
              ls_keytab_rfc-datatype = gs_dfies-datatype.
              APPEND ls_keytab_rfc TO lt_keytab_rfc.
            ENDIF.
          ENDLOOP.



* dynamischen where-string für RFC erzeugen (alle Key-Felder)
          CLEAR lv_where_string_rfc.
          LOOP AT lt_keytab_rfc INTO ls_keytab_rfc.
            IF ls_keytab_rfc-datatype NE 'CHAR'.
              CONDENSE ls_keytab_rfc-value.
            ENDIF.
            CONCATENATE '''' ls_keytab_rfc-value '''' INTO lv_help_value.
            CASE sy-tabix.
              WHEN 1.
                CONCATENATE ls_keytab_rfc-fieldname '=' lv_help_value INTO lv_where_string_rfc SEPARATED BY space.
              WHEN OTHERS.
                CONCATENATE lv_where_string_rfc 'and' ls_keytab_rfc-fieldname '=' lv_help_value INTO lv_where_string_rfc SEPARATED BY space.
            ENDCASE.
          ENDLOOP.


          MOVE <table>-tabname TO gs_ausgabe-tabname.
          MOVE <table>-tabtext TO gs_ausgabe-tabtext.
*          MOVE gv_anz_ds TO gs_ausgabe-anz_ds.

*          LOOP AT lt_keytab INTO ls_keytab.
*
*            IF ls_keytab-datatype NE 'CHAR'.
*              CONTINUE.
*            ENDIF.
*
*            ASSIGN COMPONENT ls_keytab-fieldname OF STRUCTURE <fs_tab_line> TO <fv_value_write>.
*            IF sy-subrc EQ 0.
**              WRITE:   ls_keytab-fieldname, '=',  <fv_value_write>.
*              CONCATENATE lv_write_string ls_keytab-fieldname '=' <fv_value_write> '|' INTO lv_write_string SEPARATED BY space.
*              CONDENSE lv_write_string.
*              MOVE lv_write_string TO gs_ausgabe-string_ds.
*              MOVE gv_anz_anzeige TO gs_ausgabe-anz_anzeige.
*            ENDIF.
**            CONCATENATE <table>-tabname '-' ls_keytab-fieldname  INTO lv_write_string.
**            WRITE lv_write_string.
*          ENDLOOP.
*
*          IF p_anz_e IS NOT INITIAL.
*            IF gv_anz_anzeige <= p_anz_e.
*              APPEND gs_ausgabe TO gt_ausgabe.
*            ELSE.
*              CLEAR: gs_ausgabe-string_ds.
*            ENDIF.
*          ELSE.
*            APPEND gs_ausgabe TO gt_ausgabe.
*          ENDIF.
*
*        ENDLOOP.
*        IF sy-subrc NE 0.
**           FREE ref_tab_eigen.
**           FREE <tab_eigen>.
**            EXIT.
*        ELSE.
*          CLEAR: gs_ausgabe-string_ds.
*          APPEND gs_ausgabe TO gt_ausgabe.
*
*        ENDIF.

          REFRESH: lt_zqm_key_value_eg.
          lt_zqm_key_value_eg[] = lt_keytab_rfc[].

          CLEAR: lv_ret_code.

          CALL FUNCTION 'Z_QM_DB_SINGLE_SELECT_TABLE_2'
            DESTINATION rfc_dest
            EXPORTING
              i_tabname          = <table>-tabname
              i_where_string     = lv_where_string_rfc
            IMPORTING
              e_ret_code         = lv_ret_code
            TABLES
              t_zqm_key_value_eg = lt_zqm_key_value_eg.

          IF lv_ret_code EQ 0.
*              WRITE: / 'Eintrag vorhanden:' COLOR 5, lv_where_string.
          ELSE.
*              WRITE: / lv_tabname,  'FEHLENDER EINTRAG (prüfen):' COLOR 6, lv_where_string.
            CLEAR gs_ausgabe-error_string.
            CONCATENATE 'FEHLENDER EINTRAG (prüfen):' lv_where_string_rfc INTO gs_ausgabe-error_string.
            gs_ausgabe-anz_error = gs_ausgabe-anz_error + 1.
            move gs_ausgabe-anz_error to gs_ausgabe-anz_ds.
            lv_anz_error = lv_anz_error + 1.
            IF p_anz_e IS NOT INITIAL.
              IF lv_anz_error <= p_anz_e.
                APPEND gs_ausgabe TO gt_ausgabe.
              ELSE.
                CLEAR: gs_ausgabe-error_string.
              ENDIF.
            ELSE.
              APPEND gs_ausgabe TO gt_ausgabe.
            ENDIF.

          ENDIF.


        ENDLOOP.
        IF sy-subrc NE 0.
*           FREE ref_tab_eigen.
*           FREE <tab_eigen>.
*            EXIT.
        ELSE.
          MOVE gv_anz_ds TO gs_ausgabe-anz_ds.
          CLEAR: gs_ausgabe-error_string.
          APPEND gs_ausgabe TO gt_ausgabe.

        ENDIF.


      CATCH cx_root.
        " Bei Fehler nichts aendern

    ENDTRY.


*    ENDDO.

    FREE ref_tab_eigen.
    FREE <tab_eigen>.
    FREE  <help_tab>.



  ENDLOOP.










ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_AUSGABE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_ausgabe .


  DATA lr_output TYPE REF TO cl_salv_table.
  DATA lr_columns TYPE REF TO cl_salv_columns_table.
  DATA lr_column TYPE REF TO cl_salv_column_list.
  DATA lr_display_settings TYPE REF TO cl_salv_display_settings.
*  DATA lr_handler TYPE REF TO lcl_log_handler.
*  DATA lr_events TYPE REF TO cl_salv_events_table.
  DATA lr_functions TYPE REF TO cl_salv_functions_list.
  DATA lr_layout TYPE REF TO cl_salv_layout.
  DATA ls_key TYPE salv_s_layout_key.
  DATA ls_column_ref TYPE salv_s_column_ref.

* ALV-Ausgabe
* Erzeugen der ALV Instanz Fullscreen
  TRY.
      CALL METHOD cl_salv_table=>factory
*  EXPORTING
*    list_display   = IF_SALV_C_BOOL_SAP=>FALSE
*    r_container    =
*    container_name =
        IMPORTING
          r_salv_table = lr_output
        CHANGING
          t_table      = gt_ausgabe[].
    CATCH cx_salv_msg .
  ENDTRY.

* Setzen des gesamten Menues
  lr_functions = lr_output->get_functions( ).
  lr_functions->set_all( ).
  lr_functions->set_view_excel( abap_false ).

  lr_layout = lr_output->get_layout( ).
  ls_key-report = sy-repid.
  lr_layout->set_key( ls_key ).
  lr_layout->set_save_restriction( ).

  lr_columns = lr_output->get_columns( ).                      "Objekt holen

  lr_columns->set_optimize( ).                                 "Spaltenbreite optimieren


  TRY.


      lr_column ?= lr_columns->get_column( 'TABNAME' ).
      lr_column->set_long_text( 'Tabelle' ).

      lr_column ?= lr_columns->get_column( 'ANZ_DS' ).
      lr_column->set_long_text( 'Anz. DS mit Kundennamensraum' ).

      lr_column ?= lr_columns->get_column( 'ANZ_ERROR' ).
      lr_column->set_long_text( 'Anzahl fehlende DS' ).

      lr_column ?= lr_columns->get_column( 'ANZ_ERROR' ).
      lr_column->set_long_text( 'Anzahl fehlende DS' ).

      lr_column ?= lr_columns->get_column( 'ERROR_STRING' ).
      lr_column->set_long_text( 'Selektion' ).

      " Nur Langtext ausgeben
      LOOP AT lr_columns->get( ) INTO ls_column_ref.
        lr_column ?= ls_column_ref-r_column.
        lr_column->set_fixed_header_text( 'L' ).
      ENDLOOP.


    CATCH cx_salv_not_found.

  ENDTRY.


* Ausgabe der Liste
  CALL METHOD lr_output->display( ).


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SAVE_EXTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_extract .


  gs_extract_s-exname = p_exnams.
  gs_extract_s-text   = p_exbezs.
  gs_extract_s-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_EXTRACT_SAVE'
    EXPORTING
      is_extract         = gs_extract_s
    TABLES
      it_exp01           = gt_ausgabe
    EXCEPTIONS
      wrong_relid        = 1
      no_report          = 2
      no_exname          = 3
      no_extract_created = 4
      OTHERS             = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            DISPLAY LIKE 'E'.
  ELSE.
    WRITE: / 'Extract', p_exnams, 'wurde gesichert'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LOAD_EXTRACT_AND_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM load_extract_and_display .


  gs_extract_l-exname = p_exnams.
  CALL FUNCTION 'REUSE_ALV_EXTRACT_LOAD'
    EXPORTING
      is_extract         = gs_extract_l
    TABLES
      et_exp01           = gt_ausgabe
    EXCEPTIONS
      not_found          = 1
      wrong_relid        = 2
      no_report          = 3
      no_exname          = 4
      no_import_possible = 5
      OTHERS             = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            DISPLAY LIKE 'E'.
  ELSE.

    PERFORM alv_ausgabe.

  ENDIF.

ENDFORM.
