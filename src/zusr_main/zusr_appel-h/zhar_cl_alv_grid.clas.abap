class ZHAR_CL_ALV_GRID definition public final.

public section.
  type-pools SLIS .

*"* public components of class ZCL_HAR_ALV_GRID
*"* do not include other source files here!!!
  class-data INSTANCE type ref to ZHAR_CL_ALV_GRID read-only .

  methods GET_LINE_STRUCT_NAME
    importing
      !I_TAB type STANDARD TABLE
    returning
      value(R_LINE_STRUCT_NAME) type TABNAME .
  methods SET_BG_COLOR_FOR_COLUMNS
    importing
      !I_STRUC_NAME type TABNAME
      !I_KEY_COLOR type LVC_COL optional
      !I_COLOR type LVC_COL
      !I_NAME_COLORDEF_COLUMN type STRING
    changing
      !C_OUTTAB type STANDARD TABLE .
  class-methods CLASS_CONSTRUCTOR .
  methods AUSGABE_ALV_CLASS
    importing
      !I_LAYOUTVAR type SLIS_VARI
      !I_REPID type SY-REPID
      !I_ALV_VARIANT type SLIS_LAYOUT_ALV
      !I_ALV_SORT type SLIS_T_SORTINFO_ALV
    changing
      !C_TAB_ERGEBNIS type STANDARD TABLE .
  methods AUSGABE_ALV_FUBA
    importing
      !I_TITLE type STRING optional
      !I_DSTICHTAG type DATS optional
      !I_FIELDCAT type SLIS_T_FIELDCAT_ALV optional
      !I_TECHNAMES type FLAG optional
      !I_STRUCTURE_NAME type TABNAME optional
      !I_ALV_REPID type SY-REPID optional
      !I_ALV_VARIANT type SLIS_VARI optional
      !I_ALV_SORT type SLIS_T_SORTINFO_ALV optional
      !I_ALV_LAYOUT type SLIS_LAYOUT_ALV optional
    changing
      !C_TAB_AUSGABE type STANDARD TABLE optional
      !CR_TAB_AUSGABE type ref to DATA optional .
  methods GET_FIELD_CATALOG_FROM_DDIC
    importing
      !I_TAB type ref to DATA
    returning
      value(R_FIELDCATALOG) type SLIS_T_FIELDCAT_ALV .
  methods JOIN_FIELDCATALOG
    importing
      !IR_TAB1 type ref to DATA
      !IR_TAB2 type ref to DATA
      !IV_FIELDNAME type STRING optional
      !IV_POS type INTEGER optional
    returning
      value(R_FIELDCATALOG) type SLIS_T_FIELDCAT_ALV .
  methods APPEND_COLUMN_COLOR_CELL
    importing
      !I_CELLCOL_NAME type STRING
    changing
      !CR_OUTTAB type ref to DATA
      !CT_FIELDCAT type SLIS_T_FIELDCAT_ALV .
  methods SET_BG_COLOR_FOR_STRUCTURE
    importing
      !IR_TABLE type ref to DATA optional
      !I_STRUC_NAME type TABNAME optional
      !I_KEY_COLOR type LVC_COL
      !I_COLOR type LVC_COL
    changing
      !CR_RESULT type ref to DATA
      !CT_FIELDCATALOG type SLIS_T_FIELDCAT_ALV
      !C_ALV_LAYOUT type SLIS_LAYOUT_ALV .
  PROTECTED SECTION.
*"* protected components of class ZCL_HAR_ALV_GRID
*"* do not include other source files here!!!
  PRIVATE SECTION.
*"* private components of class ZCL_HAR_ALV_GRID
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZHAR_CL_ALV_GRID IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HAR_ALV_GRID->APPEND_COLUMN_COLOR_CELL
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_CELLCOL_NAME                 TYPE        STRING
* | [<-->] CR_OUTTAB                      TYPE REF TO DATA
* | [<-->] CT_FIELDCAT                    TYPE        SLIS_T_FIELDCAT_ALV
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD append_column_color_cell.
*    DATA : lt_tmp_fc       TYPE slis_t_fieldcat_alv,
*           l_fc            LIKE LINE OF lt_tmp_fc,
*           " eine im DDIC vorhandene Struktur die eine Spalte zur Farbdefinition enthält
*           ls_with_cellcol TYPE z6ba_str_cellcol_def,
*           l_result        TYPE REF TO data.
*
*    FIELD-SYMBOLS:
*      <tab_source>  TYPE ANY TABLE,
*      <line_source> TYPE any,
*      <newline>     TYPE any,
*      <newtab>      TYPE STANDARD TABLE.
*
*
*    IF ct_fieldcat IS NOT INITIAL.
*      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
*        EXPORTING
*          i_structure_name   = 'Z6BA_STR_CELLCOL_DEF'
*          i_bypassing_buffer = 'X'
*        CHANGING
*          ct_fieldcat        = lt_tmp_fc.
*
*      " fieldcatalog erweitern
*      LOOP AT lt_tmp_fc INTO l_fc WHERE fieldname = 'CELLCOL'.
*        l_fc-fieldname = i_cellcol_name.
*        APPEND l_fc TO ct_fieldcat.
*        EXIT.
*      ENDLOOP.
*      IF l_fc IS INITIAL.
*        "message 'CELLCOL nicht gefunden' type 'X'.
*      ENDIF.
*    ENDIF.
*
*    IF cr_outtab IS NOT INITIAL.
*      " Tabelle erweitern
*      CALL METHOD z6co_cl_gen_tech=>add_field_to_table
*        EXPORTING
*          i_ref_old_tab   = cr_outtab         " Zu erweiterende Tabelle
*          "i_ref_add_tab   =                  " Tabelle mit Erweiterungsfeld
*          i_add_struc     = ls_with_cellcol      " Struktur mit Erweiterungsfeld
*          i_add_fieldname = i_cellcol_name        " Name des zu übertragenden Feldes, leer => erstes Feld
*        CHANGING
*          e_ref_newtab    = l_result.   " Ref. auf erweiterte Struktur
*
*      ASSIGN l_result->* TO <newtab>.
*
*      ASSIGN cr_outtab->*  TO <tab_source>.
*      LOOP AT <tab_source> ASSIGNING <line_source> .
*        APPEND INITIAL LINE TO <newtab> ASSIGNING <newline>.
*        MOVE-CORRESPONDING <line_source> TO <newline>.
*      ENDLOOP.
*      cr_outtab = l_result.
*    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HAR_ALV_GRID->AUSGABE_ALV_CLASS
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_LAYOUTVAR                    TYPE        SLIS_VARI
* | [--->] I_REPID                        TYPE        SY-REPID
* | [--->] I_ALV_VARIANT                  TYPE        SLIS_LAYOUT_ALV
* | [--->] I_ALV_SORT                     TYPE        SLIS_T_SORTINFO_ALV
* | [<-->] C_TAB_ERGEBNIS                 TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD ausgabe_alv_class.
    DATA:
      l_tab_fehlermeldungen TYPE TABLE OF bapiret2,
      l_ref_salv_table      TYPE REF TO cl_salv_table,
      l_ref_gui_functions   TYPE REF TO cl_salv_functions_list,
      l_ref_layout          TYPE REF TO cl_salv_layout,
      l_s_layout_key        TYPE salv_s_layout_key,
      l_ref_exception       TYPE REF TO cx_root,
      l_exceptiontext       TYPE string.
* Prüfen ob die Ergebnistabelle leer ist oder nicht...
    TRY.
        IF c_tab_ergebnis IS NOT INITIAL.
          " Wenn sie nicht leer ist, wird diese dem Objekt l_ref_salv_table zur Anzeige übergeben
          CALL METHOD cl_salv_table=>factory
            IMPORTING
              r_salv_table = l_ref_salv_table
            CHANGING
              t_table      = c_tab_ergebnis.
        ELSE.
          " Falls sie doch leer ist, wird die Fehlertabelleem dem Objekt l_ref_salv_table zur Anzeige übergeben
          CALL METHOD cl_salv_table=>factory
            IMPORTING
              r_salv_table = l_ref_salv_table
            CHANGING
              t_table      = l_tab_fehlermeldungen.
        ENDIF.
      CATCH cx_salv_msg INTO l_ref_exception.
        l_exceptiontext = l_ref_exception->get_text( ).
        MESSAGE l_exceptiontext TYPE 'E'.
    ENDTRY.



* Anpassung des Layouts. Dazu wird aus dem Objekt l_ref_salv_table die Referenz
* auf das Layout geholt...
    CALL METHOD l_ref_salv_table->get_layout
      RECEIVING
        value = l_ref_layout.

* Speichern des Programmnamens
    l_s_layout_key-report = i_repid.

* Setzen des Programmnamens als Schlüssel
    CALL METHOD l_ref_layout->set_key
      EXPORTING
        value = l_s_layout_key.

* Entfernen des Restriktion, sodass Layouts gespeichert werden können
    CALL METHOD l_ref_layout->set_save_restriction
      EXPORTING
        value = if_salv_c_layout=>restrict_none.

* Festlegen des Layouts welches zunächst verwendet werden soll
    IF i_layoutvar IS NOT INITIAL.
*   Setzen des Benutzerspezifischen, falls selektiert
      CALL METHOD l_ref_layout->set_initial_layout
        EXPORTING
          value = i_layoutvar.
    ELSE.
*   Setzen des Default-Layouts, falls selektiert
      CALL METHOD l_ref_layout->set_initial_layout
        EXPORTING
          value = 'DEFAULT'.
    ENDIF.

* Zum Schluss noch die Funktionstasten auf der Funktionsleiste aktivieren...
    "l_ref_gui_functions = l_ref_salv_table->get_functions( ).
    "l_ref_gui_functions->set_all( 'X' ).

    DATA:  l_columns TYPE REF TO cl_salv_columns_table.


* und  das ALV-Grid anzeigen.
    l_ref_salv_table->display( ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HAR_ALV_GRID->AUSGABE_ALV_FUBA
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_TITLE                        TYPE        STRING(optional)
* | [--->] I_DSTICHTAG                    TYPE        DATS(optional)
* | [--->] I_FIELDCAT                     TYPE        SLIS_T_FIELDCAT_ALV(optional)
* | [--->] I_TECHNAMES                    TYPE        FLAG(optional)
* | [--->] I_STRUCTURE_NAME               TYPE        TABNAME(optional)
* | [--->] I_ALV_REPID                    TYPE        SY-REPID(optional)
* | [--->] I_ALV_VARIANT                  TYPE        SLIS_VARI(optional)
* | [--->] I_ALV_SORT                     TYPE        SLIS_T_SORTINFO_ALV(optional)
* | [--->] I_ALV_LAYOUT                   TYPE        SLIS_LAYOUT_ALV(optional)
* | [<-->] C_TAB_AUSGABE                  TYPE        STANDARD TABLE(optional)
* | [<-->] CR_TAB_AUSGABE                 TYPE REF TO DATA(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD ausgabe_alv_fuba.

*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_DSTICHTAG) TYPE  DATS
*"     REFERENCE(I_STRUC_NAME) TYPE  TABNAME
*"     REFERENCE(I_ALV_REPID) TYPE  SY-REPID
*"     REFERENCE(I_ALV_VARIANT) TYPE  SLIS_VARI
*"     REFERENCE(I_ALV_SORT) TYPE  SLIS_T_SORTINFO_ALV
*"     REFERENCE(I_ALV_LAYOUT) TYPE  SLIS_LAYOUT_ALV
*"  CHANGING
*"     REFERENCE(C_TAB_AUSGABE) TYPE  STANDARD TABLE
*"----------------------------------------------------------------------

  DATA : l_title           TYPE lvc_title,
         l_stichtag(10)    TYPE c,
         l_str_alv_variant TYPE disvariant,
         l_alv_fieldcat    TYPE slis_t_fieldcat_alv,
         l_lines           TYPE string,
         l_line_struct     TYPE tabname,
         l_alv_repid       TYPE sy-repid,
         l_alv_sort        TYPE slis_t_sortinfo_alv,
         l_alv_layout        TYPE   slis_layout_alv,
         l_exc             TYPE REF TO cx_root,
         lr_out            TYPE REF TO data.
  FIELD-SYMBOLS:
    <ls_fieldcat> TYPE LINE OF slis_t_fieldcat_alv,
    <lt_out>      TYPE STANDARD TABLE,
    <lt_out_any>  TYPE ANY TABLE,
    <ls_out>      TYPE any.


*Titel zusammensetzen
  IF cr_tab_ausgabe IS SUPPLIED AND cr_tab_ausgabe IS NOT INITIAL.
    " Sorted table in standard table umformatieren
    ASSIGN cr_tab_ausgabe->* TO <lt_out_any>.
    CREATE DATA lr_out LIKE LINE OF <lt_out_any>.
    ASSIGN lr_out->* TO <ls_out>.
    CREATE DATA lr_out LIKE STANDARD TABLE OF <ls_out>.
    ASSIGN lr_out->* TO <lt_out>.
    APPEND LINES OF <lt_out_any> TO <lt_out>.

  ELSE.
    ASSIGN c_tab_ausgabe TO <lt_out>.
  ENDIF.

  l_lines = lines( <lt_out> ).
  IF ( i_title IS INITIAL ).
    WRITE i_dstichtag TO l_stichtag DD/MM/YYYY.
    CONCATENATE 'Auswertung vom ' l_stichtag '  Zeilenzahl ' l_lines
                INTO l_title SEPARATED BY space.
  ELSE.
    l_title = |{ i_title } Zeilenzahl { l_lines }|.
  ENDIF.

  IF i_fieldcat IS INITIAL.
    " Name der Zeilenstruktur
    l_line_struct = me->get_line_struct_name( <lt_out> ).

    " ---------> We fetch the meta data from the DDIC <------
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name   = l_line_struct
        i_bypassing_buffer = 'X'
      CHANGING
        ct_fieldcat        = l_alv_fieldcat.
    IF l_alv_fieldcat IS INITIAL.
      DATA ls_fieldcat    TYPE slis_fieldcat_alv.
      DATA lr_structdescr TYPE REF TO cl_abap_structdescr.
      DATA lt_components  TYPE cl_abap_structdescr=>component_table.
      DATA ls_component   TYPE cl_abap_structdescr=>component.
      DATA lr_tabdescr    TYPE REF TO cl_abap_structdescr.
      DATA lt_dfies    TYPE ddfields.
      DATA ls_dfies    TYPE dfies.
      "DATA ls_fieldcat TYPE lvc_s_fcat.

      CREATE DATA lr_out LIKE LINE OF <lt_out>.
      lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lr_out ).
      lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).
      LOOP AT lt_dfies  INTO    ls_dfies.
        CLEAR ls_fieldcat.
        MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.
        APPEND ls_fieldcat TO l_alv_fieldcat.
      ENDLOOP.

*      ASSIGN lr_out->* TO <ls_out>.
*      lr_structdescr ?= cl_abap_structdescr=>describe_by_data( <ls_out> ).
*      lt_components   = lr_structdescr->get_components( ).
*      LOOP AT lt_components INTO ls_component.
*        ls_fieldcat-fieldname = ls_component-name.
*        ls_fieldcat-outputlen = 10.
*        ls_fieldcat-seltext_l = ls_component-name.
*        ls_fieldcat-seltext_m = ls_component-name.
*        ls_fieldcat-seltext_s = ls_component-name.
*        ls_fieldcat-no_zero   = 'X'.
*        ls_fieldcat-hotspot   = 'X'.
*        APPEND ls_fieldcat TO l_alv_fieldcat.
*      ENDLOOP.
    ENDIF.
  ELSE.
    l_alv_fieldcat = i_fieldcat.
  ENDIF.
  IF i_technames = 'X'.
    LOOP AT l_alv_fieldcat ASSIGNING <ls_fieldcat>.
      <ls_fieldcat>-seltext_l = <ls_fieldcat>-fieldname.
      <ls_fieldcat>-seltext_m = <ls_fieldcat>-fieldname.
      <ls_fieldcat>-seltext_s = <ls_fieldcat>-fieldname.
      <ls_fieldcat>-ref_tabname = ''.
      <ls_fieldcat>-ref_fieldname = ''.
      <ls_fieldcat>-reptext_ddic  = ''.
    ENDLOOP.
  ENDIF.
  LOOP AT l_alv_fieldcat ASSIGNING <ls_fieldcat>.
    <ls_fieldcat>-no_convext = 'X'.
  ENDLOOP.


*Variantensteuerung
  " -> We store the ALV Repid as only key for the variant
  IF i_alv_repid IS NOT INITIAL.
    l_str_alv_variant-report  = i_alv_repid.
    l_alv_repid = i_alv_repid.
  ELSE.
    l_str_alv_variant-report  = sy-repid.
    l_alv_repid = sy-repid.
  ENDIF.

  IF i_alv_variant IS NOT INITIAL.
    l_str_alv_variant-variant = i_alv_variant.
  ELSE.
    " ->We get the userspecific default variant
    CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
      EXPORTING
        i_save     = 'A'  " Userspecific
      CHANGING
        cs_variant = l_str_alv_variant
      EXCEPTIONS
        not_found  = 2.

    IF sy-subrc <> 0. "    --> error

      " We restore the reportid as only key for the variant
      l_str_alv_variant-report  = i_alv_repid.
      l_str_alv_variant-variant = i_alv_variant.

    ENDIF.
  ENDIF.

  IF i_alv_sort IS NOT INITIAL.
    l_alv_sort = i_alv_sort.
  ENDIF.

  IF i_alv_layout IS NOT INITIAL.
    l_alv_layout = i_alv_layout.
  else.
    l_alv_layout-colwidth_optimize = 'X'.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = l_alv_repid
      i_background_id    = ' '
      i_structure_name   = i_structure_name
      is_layout          = l_alv_layout
      it_fieldcat        = l_alv_fieldcat
      i_default          = 'X'
      it_sort            = l_alv_sort
      i_grid_title       = l_title
      i_save             = 'A'
      is_variant         = l_str_alv_variant
    TABLES
      t_outtab           = <lt_out>.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HAR_ALV_GRID=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD class_constructor.
    CREATE OBJECT instance.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HAR_ALV_GRID->GET_FIELD_CATALOG_FROM_DDIC
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_TAB                          TYPE REF TO DATA
* | [<-()] R_FIELDCATALOG                 TYPE        SLIS_T_FIELDCAT_ALV
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_field_catalog_from_ddic.
    DATA l_line_struct  TYPE tabname.
    FIELD-SYMBOLS :  <tab> TYPE STANDARD TABLE.

    ASSIGN i_tab->* TO <tab>.
    l_line_struct = ZHAR_CL_ALV_GRID=>instance->get_line_struct_name( <tab> ).

    " ---------> We fetch the meta data from the DDIC <------
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name   = l_line_struct
        i_bypassing_buffer = 'X'
      CHANGING
        ct_fieldcat        = r_fieldcatalog.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HAR_ALV_GRID->GET_LINE_STRUCT_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_TAB                          TYPE        STANDARD TABLE
* | [<-()] R_LINE_STRUCT_NAME             TYPE        TABNAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_line_struct_name.
    DATA:   l_struct     TYPE REF TO cl_abap_structdescr,
            r_data       TYPE REF TO data,
            l_struc_name TYPE tabname.

* Titel zusammensetzen

    "CREATE DATA l_str_objtab TYPE (u_str_upload_information-strucname).
    "ASSIGN l_str_objtab->* TO <l_str_objtab>.

    " alle Felder der Struktur in der Farbspaltenliste vermerken
    CREATE DATA r_data LIKE LINE OF i_tab.
    l_struct ?= cl_abap_structdescr=>describe_by_data_ref( r_data ).
    " l_struct->absolute_name = '\TYPE=Z6BA_PRODCONTROL_EIR_I_TAB'
    r_line_struct_name =  substring_after( val = l_struct->absolute_name sub = '=' ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HAR_ALV_GRID->JOIN_FIELDCATALOG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IR_TAB1                        TYPE REF TO DATA
* | [--->] IR_TAB2                        TYPE REF TO DATA
* | [--->] IV_FIELDNAME                   TYPE        STRING(optional)
* | [--->] IV_POS                         TYPE        INTEGER(optional)
* | [<-()] R_FIELDCATALOG                 TYPE        SLIS_T_FIELDCAT_ALV
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD join_fieldcatalog.

    DATA:  lt_fc_tab1 TYPE slis_t_fieldcat_alv,
           lt_fc_tab2 TYPE slis_t_fieldcat_alv,
           l_fc_line2 LIKE LINE OF lt_fc_tab2,
           l_found    TYPE flag,
           l_ctr      TYPE i.

    FIELD-SYMBOLS :  <fc_line1>  LIKE LINE OF lt_fc_tab1.
    FIELD-SYMBOLS :  <fc_line2>  LIKE LINE OF lt_fc_tab2.


    lt_fc_tab1   = ZHAR_CL_ALV_GRID=>instance->get_field_catalog_from_ddic( ir_tab1 ).
    lt_fc_tab2   = ZHAR_CL_ALV_GRID=>instance->get_field_catalog_from_ddic( ir_tab2 ).
    r_fieldcatalog = lt_fc_tab1.

    l_ctr = lines( lt_fc_tab1 ).
    LOOP AT lt_fc_tab2 INTO l_fc_line2.
      if iv_fieldname is not INITIAL and  l_fc_line2-fieldname <> iv_fieldname.
        CONTINUE.
      endif.
      l_found = ''.
      LOOP AT lt_fc_tab1 ASSIGNING  <fc_line1> WHERE fieldname = l_fc_line2-fieldname.
        l_found = 'X'.
      ENDLOOP.
      IF l_found = ''.
        ADD 1 TO l_ctr.
        if iv_pos is not INITIAL.
          l_fc_line2-col_pos = iv_pos.
          loop at r_fieldcatalog ASSIGNING <fc_line2>.
            if <fc_line2>-col_pos >= iv_pos.
              add 1 to <fc_line2>-col_pos.
            endif.
          endloop.
        else.
          l_fc_line2-col_pos = l_ctr.
        endif.
        APPEND l_fc_line2 TO r_fieldcatalog.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HAR_ALV_GRID->SET_BG_COLOR_FOR_COLUMNS
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_STRUC_NAME                   TYPE        TABNAME
* | [--->] I_KEY_COLOR                    TYPE        LVC_COL(optional)
* | [--->] I_COLOR                        TYPE        LVC_COL
* | [--->] I_NAME_COLORDEF_COLUMN         TYPE        STRING
* | [<-->] C_OUTTAB                       TYPE        STANDARD TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_bg_color_for_columns.
    TYPES : BEGIN OF t_fntab,
              fieldname TYPE fieldname,
            END OF t_fntab.

    DATA: lt_keyfields  TYPE TABLE OF t_fntab
          ,l_struct TYPE REF TO cl_abap_structdescr
          ,l_comp   TYPE abap_compdescr
          ,l_cellcol          TYPE lvc_s_scol
          ,l_tab_cellcol      TYPE lvc_t_scol
          ,l_tab_cellcol_old  TYPE lvc_t_scol
          ,l_keyf             TYPE flag.

    FIELD-SYMBOLS:  <l_out>         TYPE any,
                    <l_coldef_comp> TYPE any,
                    <dummy>         TYPE any.
    .

    "CREATE DATA l_str_objtab TYPE (u_str_upload_information-strucname).
    "ASSIGN l_str_objtab->* TO <l_str_objtab>.

    IF i_key_color IS SUPPLIED.
      SELECT  fieldname  FROM dd03l INTO TABLE lt_keyfields
        WHERE tabname = i_struc_name AND keyflag = 'X'.
    ENDIF.

    " alle Felder der Struktur in der Farbspaltenliste vermerken
    l_struct ?= cl_abap_typedescr=>describe_by_name( i_struc_name ).
    LOOP AT l_struct->components INTO l_comp.
      l_cellcol-fname = l_comp-name.
      l_keyf = ''.
      LOOP AT lt_keyfields ASSIGNING <dummy> WHERE fieldname = l_comp-name.
        l_keyf = 'X'.
        EXIT.
      ENDLOOP.
      IF l_keyf = 'X'.
        l_cellcol-color-col = i_key_color.
      ELSE.
        l_cellcol-color-col = i_color.
      ENDIF.
      APPEND l_cellcol TO l_tab_cellcol.
    ENDLOOP.

    LOOP AT c_outtab ASSIGNING <l_out>.
      ASSIGN COMPONENT i_name_colordef_column OF STRUCTURE <l_out> TO <l_coldef_comp>.
      IF sy-subrc NE 0.
        DATA msg TYPE string.
        CONCATENATE i_name_colordef_column 'in Ausgabetabelle nicht gefunden'
          INTO msg SEPARATED BY space.
        MESSAGE msg TYPE 'X'.
      ENDIF.
      IF sy-tabix = 1.
        l_tab_cellcol_old = <l_coldef_comp>.
        " falls schon was drin ist nicht vergessen.
        APPEND LINES OF l_tab_cellcol_old TO l_tab_cellcol.
      ENDIF.
      <l_coldef_comp> = l_tab_cellcol.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HAR_ALV_GRID->SET_BG_COLOR_FOR_STRUCTURE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IR_TABLE                       TYPE REF TO DATA(optional)
* | [--->] I_STRUC_NAME                   TYPE        TABNAME(optional)
* | [--->] I_KEY_COLOR                    TYPE        LVC_COL
* | [--->] I_COLOR                        TYPE        LVC_COL
* | [<-->] CR_RESULT                      TYPE REF TO DATA
* | [<-->] CT_FIELDCATALOG                TYPE        SLIS_T_FIELDCAT_ALV
* | [<-->] C_ALV_LAYOUT                   TYPE        SLIS_LAYOUT_ALV
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_bg_color_for_structure.

    DATA: l_columcolor TYPE string VALUE 'CELLCOL',
          l_struc_name TYPE tabname.

    FIELD-SYMBOLS:  <table>  TYPE ANY TABLE.


    FIELD-SYMBOLS : <result>  TYPE ANY TABLE.

    c_alv_layout-coltab_fieldname = l_columcolor.
    c_alv_layout-colwidth_optimize = 'X'.

    CALL METHOD ZHAR_CL_ALV_GRID=>instance->append_column_color_cell
      EXPORTING
        i_cellcol_name = l_columcolor
      CHANGING
        cr_outtab      = cr_result
        ct_fieldcat    = ct_fieldcatalog.

    ASSIGN cr_result->* TO <result>.
    IF i_struc_name IS INITIAL.
      ASSIGN ir_table->* TO <table>.
      l_struc_name = ZHAR_CL_ALV_GRID=>instance->get_line_struct_name( <table> ).
    ELSE.
      l_struc_name = i_struc_name.
    ENDIF.

    "l_corrdata_name  = 'Z6BA_CORR_UPL_NO'
    CALL METHOD ZHAR_CL_ALV_GRID=>instance->set_bg_color_for_columns(
      EXPORTING
        i_struc_name           = l_struc_name
        i_key_color            = i_key_color
        i_color                = i_color  " 1 blau 2 weiss 3 gelb  4 hellblau 5 gruen 6 rot 7 orange
        i_name_colordef_column = l_columcolor
      CHANGING
        c_outtab               = <result> ).

  ENDMETHOD.
ENDCLASS.

