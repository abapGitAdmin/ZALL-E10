*&---------------------------------------------------------------------*
*&  Include           ZISU_MD_BPARTNER_IMPORT_C01
*&---------------------------------------------------------------------*
CLASS lcl_application DEFINITION FINAL.

  PUBLIC SECTION.

    CLASS-METHODS get_excel_template
      RETURNING VALUE(rt_bpartner) TYPE tt_bpartner.

    METHODS validate_file_path.

ENDCLASS.

CLASS lcl_application IMPLEMENTATION.

  METHOD get_excel_template.

    DATA:
      lo_salv_table TYPE REF TO cl_salv_table,
      lt_bpartner   TYPE tt_bpartner,
      lv_xml        TYPE xstring.

***************************************************************************************************

    DATA:
      lo_typedescr   TYPE REF TO cl_abap_typedescr,
      lo_structdescr TYPE REF TO cl_abap_structdescr,
      lo_tabledescr  TYPE REF TO cl_abap_tabledescr,
      lr_data        TYPE REF TO data,
      ls_component   TYPE abap_componentdescr,
      lt_component   TYPE cl_abap_structdescr=>component_table.

    FIELD-SYMBOLS <table> TYPE ANY TABLE.

    SELECT db_field, dd03l~rollname FROM epdproda INNER JOIN dd03l
      ON tabname = epdproda~db_struct AND fieldname = epdproda~db_field
      WHERE prodid = 'Z_TEST_NISCH'
      AND evaltype = @cl_isu_prod_def=>co_evaltype_param
      INTO TABLE @DATA(lt_fields).

    LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<field>).

      CLEAR: ls_component.

      cl_abap_elemdescr=>describe_by_name(
        EXPORTING
          p_name         = <field>-rollname
        RECEIVING
          p_descr_ref    = lo_typedescr
        EXCEPTIONS
          type_not_found = 1
          OTHERS         = 2
       ).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      ls_component-name = <field>-db_field.
      ls_component-type ?= lo_typedescr.

      APPEND ls_component TO lt_component.

    ENDLOOP.

    IF lt_component IS NOT INITIAL.

      lo_structdescr = cl_abap_structdescr=>create( lt_component ).

      lo_tabledescr = cl_abap_tabledescr=>create(
        p_line_type  = lo_structdescr
        p_table_kind = cl_abap_tabledescr=>tablekind_std
        p_unique     = abap_false
      ).

      CREATE DATA lr_data TYPE HANDLE lo_tabledescr.
      ASSIGN lr_data->* TO <table>.

    ENDIF.

***************************************************************************************************

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = lo_salv_table
          CHANGING
            t_table      = <table>
        ).
      CATCH cx_salv_msg.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDTRY.

    IF lo_salv_table IS NOT INITIAL.

      lv_xml = lo_salv_table->to_xml( xml_type = if_salv_bs_xml=>c_type_xlsx ).

      CALL FUNCTION 'XML_EXPORT_DIALOG'
        EXPORTING
          i_xml                      = lv_xml
          i_default_extension        = cl_gui_frontend_services=>filetype_excel
          i_initial_directory        = ''
          i_default_file_name        = 'bpartner_template.xlsx' ##NO_TEXT
          i_mask                     = cl_gui_frontend_services=>filetype_excel
        EXCEPTIONS
          application_not_executable = 1
          OTHERS                     = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD validate_file_path.

    DATA:
      lv_file_path TYPE string,
      lv_result    TYPE abap_bool.

    cl_gui_frontend_services=>file_exist(
      EXPORTING
        file                 = lv_file_path
      RECEIVING
        result               = lv_result
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        wrong_parameter      = 3
        not_supported_by_gui = 4
        OTHERS               = 5
      ).

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF lv_result = abap_false.
      MESSAGE TEXT-002 TYPE 'E'.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
