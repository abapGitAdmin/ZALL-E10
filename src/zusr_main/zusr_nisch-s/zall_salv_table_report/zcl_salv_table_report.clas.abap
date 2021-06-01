CLASS zcl_salv_table_report DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS close_table
      RAISING
        cx_salv_msg .
    METHODS constructor
      IMPORTING
        !io_container TYPE REF TO cl_gui_container OPTIONAL
        !ir_table     TYPE REF TO data
      RAISING
        cx_salv_msg .
    METHODS display_table .
    METHODS get_table
      RETURNING
        VALUE(ro_table) TYPE REF TO cl_salv_table .
    METHODS setup_table
      IMPORTING
        !io_event_handler TYPE REF TO zif_alv_event_handler_table OPTIONAL
      RAISING
        cx_salv_msg .
  PROTECTED SECTION.

    DATA ao_container TYPE REF TO cl_gui_container .
    DATA ao_table_descriptor TYPE REF TO cl_abap_tabledescr .
    DATA ao_event_handler TYPE REF TO zif_alv_event_handler_table .
    DATA ao_salv_table TYPE REF TO cl_salv_table .
    DATA ar_table TYPE REF TO data .
    DATA av_layout_key TYPE salv_s_layout_key .
    DATA av_mtext TYPE bapi_msg .

    METHODS raise_exception_from_message
      IMPORTING
        VALUE(is_symsg) TYPE symsg OPTIONAL
        !ir_previous    TYPE REF TO cx_root OPTIONAL
      RAISING
        cx_salv_msg .
    METHODS setup_individual_column
      IMPORTING
        !io_column TYPE REF TO cl_salv_column_table
      RAISING
        cx_salv_msg .
    METHODS setup_individual_columns
      IMPORTING
        !io_structure_descriptor TYPE REF TO cl_abap_structdescr
        !io_columns              TYPE REF TO cl_salv_columns_table
        !iv_prefix               TYPE string OPTIONAL
      RAISING
        cx_salv_msg .
    METHODS setup_columns
      RAISING
        cx_salv_msg .
    METHODS setup_event_handling
      RAISING
        cx_salv_msg .
    METHODS setup_filters
      RAISING
        cx_salv_msg .
    METHODS setup_functions
      RAISING
        cx_salv_msg .
    METHODS setup_header_footer
      RAISING
        cx_salv_msg .
    METHODS setup_layout
      RAISING
        cx_salv_msg .
    METHODS setup_selections
      RAISING
        cx_salv_msg .
    METHODS setup_sorting
      RAISING
        cx_salv_msg .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SALV_TABLE_REPORT IMPLEMENTATION.


  METHOD close_table.
    ao_salv_table->close_screen( ).

    IF ao_container IS BOUND.
      ao_container->free(
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3 ).
      IF sy-subrc <> 0.
        raise_exception_from_message( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    ar_table = ir_table.

    ASSIGN ar_table->* TO FIELD-SYMBOL(<table>).
    IF <table> IS NOT ASSIGNED.
      MESSAGE a117(sy) INTO av_mtext.
      raise_exception_from_message( ).
    ENDIF.

    ao_table_descriptor ?= cl_abap_typedescr=>describe_by_data_ref( ar_table ).

    " Die SAP arbeitet in der Factory mit dem schwachsinnigen IF ... IS SUPPLIED,
    " deshalb ist diese Fallunterscheidung erforderlich.
    IF io_container IS BOUND.
      ao_container = io_container.

      cl_salv_table=>factory(
          EXPORTING
            r_container    = io_container
          IMPORTING
            r_salv_table   = ao_salv_table
          CHANGING
            t_table        = <table> ).
    ELSE.
      cl_salv_table=>factory(
         IMPORTING
           r_salv_table   = ao_salv_table
         CHANGING
           t_table        = <table> ).
    ENDIF.

    av_layout_key = VALUE #( report = sy-cprog ).
  ENDMETHOD.


  METHOD display_table.
    ao_salv_table->display( ).
  ENDMETHOD.


  METHOD get_table.
    ro_table = ao_salv_table.
  ENDMETHOD.


  METHOD raise_exception_from_message.
    IF is_symsg IS INITIAL.
      is_symsg = CORRESPONDING #( sy ).
    ENDIF.

    RAISE EXCEPTION TYPE cx_salv_msg
      EXPORTING
        previous = ir_previous
        msgid    = is_symsg-msgid
        msgno    = is_symsg-msgno
        msgty    = is_symsg-msgty
        msgv1    = is_symsg-msgv1
        msgv2    = is_symsg-msgv2
        msgv3    = is_symsg-msgv3
        msgv4    = is_symsg-msgv4.
  ENDMETHOD.


  METHOD setup_columns.
    " Allgemeine Einstellungen
    DATA(lo_columns) = ao_salv_table->get_columns( ).
    lo_columns->set_optimize( ).
    lo_columns->set_key_fixation( ).

    " Einstellung der einzelnen Spalten
    CASE TYPE OF ao_table_descriptor->get_table_line_type( ).
      WHEN TYPE cl_abap_structdescr INTO DATA(lo_structure_descriptor).
        setup_individual_columns(
          io_structure_descriptor = lo_structure_descriptor
          io_columns              = lo_columns ).

      WHEN TYPE cl_abap_elemdescr INTO DATA(lo_element_descriptor).
        TRY.
            setup_individual_column( CAST cl_salv_column_table( lo_columns->get_column( 'TABLE_LINE' ) ) ).
          CATCH cx_salv_not_found.
        ENDTRY.

      WHEN OTHERS.
        " Andere Zeilentypen nicht berücksichtigen, sie sind für die ALV-Anzeige irrelevant
    ENDCASE.
  ENDMETHOD.


  METHOD setup_event_handling.
    " Gegebenenfalls von den Unterklassen zu implementieren
  ENDMETHOD.


  METHOD setup_filters.
    " Gegebenenfalls von den Unterklassen zu implementieren
  ENDMETHOD.


  METHOD setup_functions.
    DATA(lo_functions) = ao_salv_table->get_functions( ).
    lo_functions->set_all( ).
  ENDMETHOD.


  METHOD setup_header_footer.
    " Gegebenenfalls von den Unterklassen zu implementieren
  ENDMETHOD.


  METHOD setup_individual_column.
    " durch die Unterklassen zu redefinieren
  ENDMETHOD.


  METHOD setup_individual_columns.
    LOOP AT io_structure_descriptor->components ASSIGNING FIELD-SYMBOL(<component>).
      CASE TYPE OF io_structure_descriptor->get_component_type( <component>-name ).
        WHEN TYPE cl_abap_structdescr INTO DATA(lo_substructure_descriptor). " Substruktur
          setup_individual_columns(
            io_structure_descriptor = lo_substructure_descriptor
            io_columns              = io_columns
            iv_prefix               = |{ iv_prefix }{ <component>-name }-| ).

        WHEN TYPE cl_abap_elemdescr INTO DATA(lo_element_descriptor). " Elementares Datenfeld
          TRY.
              setup_individual_column( CAST cl_salv_column_table( io_columns->get_column( |{ iv_prefix }{ <component>-name }| ) ) ).
            CATCH cx_salv_not_found.
          ENDTRY.

        WHEN OTHERS.
          " Andere Komponentenarten ignorieren, sie werden im ALV nicht angezeigt
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


  METHOD setup_layout.
    DATA(lo_display) = ao_salv_table->get_display_settings( ).
    lo_display->set_fit_column_to_table_size( ).
    lo_display->set_striped_pattern( abap_true ).

    DATA(lo_layout) = ao_salv_table->get_layout( ).
    lo_layout->set_key( av_layout_key ).
    lo_layout->set_default( abap_true ).
    lo_layout->set_save_restriction( ).
  ENDMETHOD.


  METHOD setup_selections.
    " Gegebenenfalls von den Unterklassen zu implementieren
  ENDMETHOD.


  METHOD setup_sorting.
    " Gegebenenfalls von den Unterklassen zu implementieren
  ENDMETHOD.


  METHOD setup_table.
    setup_header_footer( ).
    setup_layout( ).
    setup_functions( ).
    setup_selections( ).
    setup_columns( ).
    setup_event_handling( ).
  ENDMETHOD.
ENDCLASS.
