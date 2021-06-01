class /ADZ/CL_INV_GUI_SALV_COMMON definition
  public
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_REPID type REPID
      !IV_VARI type SLIS_VARI optional .
  methods INIT_DISPLAY
    importing
      !IF_EVENT_HANDLER type ref to /ADZ/IF_INV_SALV_TABLE_EVT_HLR
    changing
      !CRT_DATA type ref to DATA .
  methods SET_SCREEN_STATUS
    importing
      !IV_PFSTATUS type SYPFKEY .
  methods DISPLAY .
  methods EXCLUDE_FUNCTIONS
    importing
      !IT_FUNCNAMES type STRINGTAB .
  methods ON_LINK_CLICK
    for event LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
  PROTECTED SECTION.
    DATA mv_repid TYPE  repid.
    DATA mv_vari  TYPE  slis_vari.
    DATA mrt_data TYPE  REF TO data.
    DATA mo_salv_table TYPE REF TO cl_salv_table.
  PRIVATE SECTION.
    Methods :
      set_column_definition
        CHANGING crt_salv_table TYPE  REF TO cl_salv_table
        .
ENDCLASS.



CLASS /ADZ/CL_INV_GUI_SALV_COMMON IMPLEMENTATION.


  METHOD CONSTRUCTOR.
    mv_repid = iv_repid.
    mv_vari  = iv_vari.
  ENDMETHOD.


  Method DISPLAY.
     mo_salv_table->display( ).
  ENDMETHOD.


  METHOD EXCLUDE_FUNCTIONS.
* Welche Buttons sollen angezeigt werden


    DATA lt_usergroups TYPE TABLE OF usgroups.
    DATA lt_inv_usr TYPE TABLE OF /adz/inv_usr.
    DATA ls_inv_usr TYPE /adz/inv_usr.
    DATA lt_inv_func TYPE TABLE OF /adz/inv_func.
    DATA lv_allow_all TYPE c.
    CLEAR lt_inv_func.
    CALL FUNCTION 'SUSR_USER_GROUP_GROUPS_GET'
      EXPORTING
        bname      = sy-uname
*       WITH_TEXT  = ' '
      TABLES
        usergroups = lt_usergroups.

    IF lt_usergroups IS NOT INITIAL.
      SELECT * FROM /adz/inv_usr INTO TABLE lt_inv_usr FOR ALL ENTRIES IN lt_usergroups WHERE gruppe = lt_usergroups-usergroup.
      LOOP AT lt_inv_usr INTO ls_inv_usr.
        SELECT * FROM /adz/inv_func APPENDING TABLE lt_inv_func WHERE functions = ls_inv_usr-functions.
        IF ls_inv_usr-functions = 9.
          lv_allow_all = 'X'.
        ENDIF.
      ENDLOOP.
    ENDIF.

    DATA(lr_functions) = mo_salv_table->get_functions( ).
    IF lv_allow_all = 'X'.
      lr_functions->set_all( 'X' ).
    ELSE.
      LOOP AT it_funcnames INTO DATA(lv_funcname).
        IF NOT ( line_exists( lt_inv_func[ function = lv_funcname ] ) ).
          " !!!!  nicht möglich bei cl_salv_table pf_status funktionen zu entfernen
          if 1 < 0.
            lr_functions->remove_function( CONV SALV_DE_FUNCTION( lv_funcname ) ).
          endif.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD INIT_DISPLAY.

    DATA:
      lr_table      TYPE REF TO cl_salv_table,
      lr_functions  TYPE REF TO cl_salv_functions_list,
      lr_selections TYPE REF TO cl_salv_selections,
      lr_settings   TYPE REF TO cl_salv_display_settings.
    FIELD-SYMBOLS <ct_data> TYPE ANY TABLE.
    "lr_columns    TYPE REF TO cl_salv_columns.

    TRY.
        ASSIGN crt_data->* TO <ct_data>.
        cl_salv_table=>factory(
                  IMPORTING r_salv_table  = lr_table
                  CHANGING  t_table       = <ct_data> ).
      CATCH cx_salv_msg.
    ENDTRY.
    DATA(lv_anz) = lines( <ct_data> ).
    DATA(lv_titeladd) = |Zeilen { lv_anz }|.
* Anzeige Eigenschaften holen und anpassen
    DATA(lr_display) = lr_table->get_display_settings( ).
    lr_display->set_list_header( |{ mv_repid } Zeilen:{ lv_anz }| ).


    DATA(lo_events) = lr_table->get_event( ).

    " Usercommands
    " SET HANDLER if_event_handler->on_added_function FOR lo_events.
    SET HANDLER me->on_link_click FOR lo_events.

* Selektionen holen und Design auf multiple Zeilenauswahl mit Button setzen
    lr_selections = lr_table->get_selections( ).
    lr_selections->set_selection_mode( 4 ).

    " Layout an Report haengen und speichermoeglichkeit einschalten
    DATA: key TYPE salv_s_layout_key.
    DATA(lr_layout) = lr_table->get_layout( ).
    key-report = mv_repid.
    lr_layout->set_key( key ).
    lr_layout->set_initial_layout( mv_vari ).
    " You can pass the folling values to the SET_SAVE_RESTRICTION method.
*RESTRICT_NONE
*RESTRICT_USER_DEPENDANT
*RESTRICT_USER_INDEPENDANT
    lr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
    lr_layout->set_default( abap_true ).

* Spalten aufbreiten
    "DATA(lr_columns) = lr_table->get_columns( ).
    mrt_data = crt_data.
    mo_salv_table = lr_table.
    set_column_definition( CHANGING crt_salv_table  = lr_table ).

  ENDMETHOD.


  METHOD ON_LINK_CLICK.
*
*   Get the value of the checkbox and set the value accordingly
*   Refersh the table
    FIELD-SYMBOLS <ct_data> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <ls_data> TYPE any.
    FIELD-SYMBOLS <lv_value> TYPE any.
    "lr_columns    TYPE REF TO cl_salv_columns.
    CHECK column EQ 'SEL'.

    ASSIGN mrt_data->* TO <ct_data>.
    READ TABLE <ct_data> ASSIGNING <ls_data> INDEX row.
    CHECK sy-subrc IS INITIAL.
    ASSIGN COMPONENT column OF STRUCTURE <ls_data> TO <lv_value>.
    IF sy-subrc EQ 0.
      IF <lv_value> EQ 'X'.
        <lv_value> = ''.
      ELSE.
        <lv_value> = 'X'.
      ENDIF.
    ENDIF.
    mo_salv_table->refresh( ).
  ENDMETHOD.                    "on_link_click


  METHOD SET_COLUMN_DEFINITION.
    DATA(lr_columns) = crt_salv_table->get_columns( ).
    DATA lr_col  TYPE REF TO cl_salv_column.
    DATA lr_coltab TYPE REF TO cl_salv_column_table.

    lr_columns->set_optimize( abap_true ).

    TRY.
        lr_col = lr_columns->get_column( 'XSELP' ).
        lr_col->set_technical( abap_true ).
      CATCH cx_salv_not_found.
      CATCH cx_sy_move_cast_error.
    ENDTRY.

    "lr_col = lr_columns->get_column( 'SEL' ).
    TRY.
        lr_coltab ?= lr_columns->get_column( 'SEL' ).
        lr_coltab->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
        lr_coltab->set_short_text(  'Selektion' ).
        lr_coltab->set_medium_text( 'Selektion' ).
        lr_coltab->set_long_text(   'Selektion' ).
        lr_coltab->set_key( abap_true ).
*    ls_fieldcat-input = 'X' ).
*    ls_fieldcat-checkbox = 'X' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_coltab ?= lr_columns->get_column( 'WAITING' ).
        lr_coltab->set_short_text(  'Wartend' ).
        lr_coltab->set_medium_text( 'In Warteschritt' ).
        lr_coltab->set_long_text(   'In Warteschritt' ).
        lr_coltab->set_output_length( '5' ).
        lr_coltab->set_cell_type( if_salv_c_cell_type=>checkbox ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_coltab ?= lr_columns->get_column( 'WAITING_TO' ).
        lr_coltab->set_short_text( 'Wartd bis' ).
        lr_coltab->set_medium_text( 'Warteschritt bis' ).
        lr_coltab->set_long_text(   'In Warteschritt bis' ).
        "lr_coltab->set_output_length( '5' ).
        "lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_coltab ?= lr_columns->get_column( 'MULTI_ERR' ).
        lr_coltab->set_medium_text( 'Mult.Fehler' ).
        lr_coltab->set_cell_type( if_salv_c_cell_type=>checkbox ).
        lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_coltab ?= lr_columns->get_column( 'MEMI' ).
        lr_coltab->set_medium_text( 'MEMI' ).
        lr_coltab->set_icon( 'X' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_coltab ?= lr_columns->get_column( 'LOCKED' ).
        lr_coltab->set_medium_text( 'Sperre' ).
        lr_coltab->set_icon( 'X' ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_coltab ?= lr_columns->get_column( 'TEXT_BEM' ).
        lr_coltab->set_medium_text( 'Bemerkung txt' ).
        lr_coltab->set_cell_type( if_salv_c_cell_type=>checkbox ).
      CATCH cx_salv_not_found.
    ENDTRY.

    TRY.
        lr_coltab ?= lr_columns->get_column( 'TEXT_VORHANDEN' ).
        lr_coltab->set_medium_text( 'Bemerkung' ).
        lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
      CATCH cx_salv_not_found.
    ENDTRY.

*
** stornobelnr
    lr_coltab ?= lr_columns->get_column( 'PROCESS' ).
    lr_coltab->set_short_text( 'Prozess' ).
    lr_coltab->set_long_text(   'Prozess' ).
    "  ls_fieldcat-ref_tabname = 'BELEGART' ).

    lr_coltab ?= lr_columns->get_column( 'INVOICE_STATUS_T' ).
    lr_coltab->set_medium_text( 'BelStatus' ).
    "  ls_fieldcat-reptext_ddic = 'X' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).

**Interne Nummer des Rechnungsbelegs/Avisbelegs
    lr_coltab ?= lr_columns->get_column( 'INT_INV_DOC_NO' ).
    lr_coltab->set_key( 'X' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
**Interne Bezeichnung des Rechnung-/Avisempfängers
    lr_coltab ?= lr_columns->get_column( 'INT_RECEIVER' ).
    lr_coltab->set_key( 'X' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_HEAD' ).
*
** Interne Bezeichnung des Rechnungs-/Avissenders
    lr_coltab ?= lr_columns->get_column( 'INT_SENDER' ).
    lr_coltab->set_key( 'X' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_HEAD' ).
*
**  * Interne Bezeichnung des Rechnungs-/Avissenders
    lr_coltab ?= lr_columns->get_column( 'CASENR' ).
    lr_coltab->set_key( 'X' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
    " ls_fieldcat-ref_tabname = 'EMMA_CASE' ).
*
** Interne Bezeichnung des Rechnungs-/Avissenders
    lr_coltab ?= lr_columns->get_column( 'CASETXT' ).
    lr_coltab->set_key( 'X' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
    " ls_fieldcat-ref_tabname = 'EMMA_CASE' ).

    lr_coltab ?= lr_columns->get_column( 'WORKITEM' ).
    lr_coltab->set_short_text(  'Workitem' ).
    lr_coltab->set_medium_text( 'Workitem vorhanden' ).
    lr_coltab->set_long_text(   'Workitem vorhanden' ).
    lr_coltab->set_output_length( '5' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
*
** Status der Rechnung/des Avises
*   lr_coltab ?= lr_columns->get_column( 'INVOICE_STATUS' ).
*  ls_fieldcat-tabname = 'IT_OUT' ).
*  "ls_fieldcat-key = 'X' ).
*  ls_fieldcat-ref_tabname = 'TINV_INV_HEAD' ).
*  APPEND ls_fieldcat TO et_fieldcat.
*
**  Eingangsdatum des Dokumentes
    lr_coltab ?= lr_columns->get_column( 'DATE_OF_RECEIPT' ).
    lr_coltab->set_key( 'X' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_HEAD' ).
*
** Externe Rechnungsnummer/Avisnummer
    lr_coltab ?= lr_columns->get_column( 'EXT_INVOICE_NO' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
*
**Belegart
    lr_coltab ?= lr_columns->get_column( 'BELEGART' ).
    lr_coltab->set_short_text( 'Art' ).
    lr_coltab->set_long_text(   'Rechnungsart' ).
    " ls_fieldcat-ref_tabname = 'BELEGART' ).

** Art des Belegs
    lr_coltab ?= lr_columns->get_column( 'DOC_TYPE' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
** stornobelnr
    lr_coltab ?= lr_columns->get_column( 'STORNOBELNR' ).
    lr_coltab->set_short_text( 'Storno' ).
    lr_coltab->set_long_text(   'Stornobeleg' ).
    "  ls_fieldcat-ref_tabname = 'BELEGART' ).

** Status des Belegs
    lr_coltab ?= lr_columns->get_column( 'INV_DOC_STATUS' ).
    "   ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
** REMADV-Nummer
    lr_coltab ?= lr_columns->get_column( 'REMADV' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
    lr_coltab->set_medium_text( 'REMADV-Nr.' ).
*
** REMADV-Datum
    lr_coltab ?= lr_columns->get_column( 'REMDATE' ).
    lr_coltab->set_medium_text( 'REMADV-Dat.' ).
*
** Differenzgrund bei Zahlungen
    lr_coltab ?= lr_columns->get_column( 'RSTGR' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_LINE_A' ).
*
** Differenzgrund bei Zahlungen
    lr_coltab ?= lr_columns->get_column( 'RSTVS' ).
    lr_coltab->set_short_text( 'RekVorschl' ).
    lr_coltab->set_medium_text( 'Reklamat. Vorschlag' ).
*
** Differenzgrund bei Zahlungen
    lr_coltab ?= lr_columns->get_column( 'RSTVS_TEXT' ).
    lr_coltab->set_short_text( 'RekVorsTxt' ).
    lr_coltab->set_medium_text( 'Rekl. Vorschlag Text' ).

** Langtext
    lr_coltab ?= lr_columns->get_column( 'FREE_TEXT1' ).
    " ls_fieldcat-ref_tabname = '/IDEXGE/REJ_NOTI' ).
*
** Fälligkeitsdatum
    lr_coltab ?= lr_columns->get_column( 'DATE_OF_PAYMENT' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
** DA-Gruppenreferenznummer
    lr_coltab ?= lr_columns->get_column( 'INV_BULK_REF' ).
    "ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
** Datum der Rechnung oder des Avises
    lr_coltab ?= lr_columns->get_column( 'INVOICE_DATE' ).
*    " ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
** Beginn des Zeitraums für den die Rechnung/das Avis gilt
    lr_coltab ?= lr_columns->get_column( 'INVPERIOD_START' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
** Ende des Zeitraums für den die Rechnung/das Avis gilt
    lr_coltab ?= lr_columns->get_column( 'INVPERIOD_END' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
    lr_coltab ?= lr_columns->get_column( 'MSC_START' ).
    lr_coltab->set_short_text( 'MSC Beginn' ).
    "  ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
    lr_coltab ?= lr_columns->get_column( 'MSC_END' ).
    lr_coltab->set_short_text( 'MSC Ende' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_DOC' ).
*
** Name 1/Nachname
    lr_coltab ?= lr_columns->get_column( 'MC_NAME1' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_EXTID' ).
*
** Name 2/Vorname
    lr_coltab ?= lr_columns->get_column( 'MC_NAME2' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_EXTID' ).

** Straßenname
    lr_coltab ?= lr_columns->get_column( 'MC_STREET' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_EXTID' ).
*
** Hausnummer
    lr_coltab ?= lr_columns->get_column( 'MC_HOUSE_NUM1' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_EXTID' ).
*
** Ortsname
    lr_coltab ?= lr_columns->get_column( 'MC_CITY1' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_EXTID' ).
*
** Postleitzahl des Orts
    lr_coltab ?= lr_columns->get_column( 'MC_POSTCODE' ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_EXTID' ).
*
** Externe Identifizierung eines Belegs (z.B. Zählpunkt)
    lr_coltab ?= lr_columns->get_column( 'EXT_IDENT' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
    " ls_fieldcat-ref_tabname = 'TINV_INV_EXTID' ).
*
** Anlage
    lr_coltab ?= lr_columns->get_column( 'ANLAGE' ).
    " ls_fieldcat-ref_tabname = 'EANLH' ).
*
** Anlage
    lr_coltab ?= lr_columns->get_column( 'VERTRAG' ).
    lr_coltab->set_short_text( 'Vertrag' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
    " ls_fieldcat-ref_tabname = 'VERTRAG' ).
*
*
** Abrechnungsklasse
    lr_coltab ?= lr_columns->get_column( 'AKLASSE' ).
    " ls_fieldcat-ref_tabname = 'EANLH' ).
*
** Tariftyp
    lr_coltab ?= lr_columns->get_column( 'TARIFTYP' ).
    " ls_fieldcat-ref_tabname = 'EANLH' ).
*
** Ableseeinheit
    lr_coltab ?= lr_columns->get_column( 'ABLEINH' ).
    " ls_fieldcat-ref_tabname = 'EANLH' ).
*
** Bruttobetrag in Transaktionswährung mit Vorzeichen
    DATA(lo_aggrs) = mo_salv_table->get_aggregations( ). "get aggregations

    TRY.
        lr_coltab ?= lr_columns->get_column( 'BETRW' ).
        lr_coltab->set_zero( '' ).
        "  ls_fieldcat-do_sum = 'X' ).
        lo_aggrs->add_aggregation(  "add aggregation
            EXPORTING
              columnname  = lr_coltab->get_columnname(  ) "aggregation column name
              aggregation = if_salv_c_aggregation=>total ). "aggregation type
        " ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B' ).
      CATCH cx_salv_not_found.
      CATCH cx_salv_data_error.
      CATCH cx_salv_existing.
    ENDTRY.

** Steuerbetrag in Transaktionswährung
    TRY.
        lr_coltab ?= lr_columns->get_column( 'TAXBW' ).
        lr_coltab->set_zero( '' ).
*    ls_fieldcat-do_sum = 'X' ).
        lo_aggrs->add_aggregation(  "add aggregation
            EXPORTING
              columnname  = lr_coltab->get_columnname(  ) "aggregation column name
              aggregation = if_salv_c_aggregation=>total ). "aggregation type
        " ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B' ).
      CATCH cx_salv_not_found.
      CATCH cx_salv_data_error.
      CATCH cx_salv_existing.
    ENDTRY.
*
    TRY.
** Steuerpfl. Betrag in Transaktionswährung (Steuerbasisbetrag)
        lr_coltab ?= lr_columns->get_column( 'SBASW' ).
        lr_coltab->set_zero( '' ).
*    ls_fieldcat-do_sum = 'X' ).
        lo_aggrs->add_aggregation(  "add aggregation
            EXPORTING
              columnname  = lr_coltab->get_columnname(  ) "aggregation column name
              aggregation = if_salv_c_aggregation=>total ). "aggregation type
        " ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B' ).
      CATCH cx_salv_not_found.
      CATCH cx_salv_data_error.
      CATCH cx_salv_existing.
    ENDTRY.
*
**Menge Wirkarbeit
    TRY.
        lr_coltab ?= lr_columns->get_column( 'QUANTITY' ).
        lr_coltab->set_zero( '' ).
*    ls_fieldcat-do_sum = 'X' ).
        lo_aggrs->add_aggregation(  "add aggregation
            EXPORTING
              columnname  = lr_coltab->get_columnname(  ) "aggregation column name
              aggregation = if_salv_c_aggregation=>total ). "aggregation type
        lr_coltab->set_short_text(  'WA in kWh' ).
        lr_coltab->set_medium_text( 'Wirkarbeit in kWh' ).
        lr_coltab->set_long_text(   'Wirkarbeit in kWh' ).
*    ls_fieldcat-ref_tabname = 'TINV_INV_LINE_B' ).
      CATCH cx_salv_not_found.
      CATCH cx_salv_data_error.
      CATCH cx_salv_existing.
    ENDTRY.


    " Semantikspalten ausblenden
    lr_coltab ?= lr_columns->get_column( 'CURRCODE' ).
    lr_coltab->set_visible( abap_false ).
    lr_coltab ?= lr_columns->get_column( 'UNIT' ).
    lr_coltab->set_visible( abap_false ).

*
** Fehlermeldung
**  IF p_err IS NOT INITIAL.
    lr_coltab ?= lr_columns->get_column( 'FEHLER' ).
    lr_coltab->set_short_text(  'Fehler' ).
    lr_coltab->set_medium_text( 'Fehlermeldung' ).
    lr_coltab->set_long_text(   'Fehlermeldung' ).
    lr_coltab->set_output_length( '120' ).
    lr_coltab->set_cell_type( if_salv_c_cell_type=>hotspot ).
**  ENDIF.
  ENDMETHOD.


  method SET_SCREEN_STATUS.
    " GUI STATUS : Knöpfe und Funktionstasten
    mo_salv_table->set_screen_status(
      EXPORTING
        report        = mv_repid
        pfstatus      = iv_pfstatus
        set_functions = cl_salv_table=>c_functions_all ).

  endmethod.
ENDCLASS.
