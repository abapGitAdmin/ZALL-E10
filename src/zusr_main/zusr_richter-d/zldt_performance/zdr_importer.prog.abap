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

REPORT zdr_importer.

* Überschriften vorhanden
PARAMETERS: p_head AS CHECKBOX DEFAULT ''.
* Separator / Trennzeichen
PARAMETERS: p_sep TYPE char1 DEFAULT ','.

TABLES: zdr_table.

TRY.
    DATA: lt_files     TYPE filetable,
          lv_rc        TYPE i,
          lv_action    TYPE i,
          lt_zdr_table TYPE TABLE OF zdr_table.
*          DATA(lt_csv) = VALUE zldt_suprem_type( ).
*          DATA(ls_csv) = VALUE zldt_suprem( ).

    cl_gui_frontend_services=>file_open_dialog( EXPORTING
                                                  file_filter    = |csv (*.csv)\|*.csv\|{ cl_gui_frontend_services=>filetype_all }|
                                                  multiselection = abap_true
                                                CHANGING
                                                  file_table     = lt_files
                                                  rc             = lv_rc
                                                  user_action    = lv_action ).

    IF lv_action = cl_gui_frontend_services=>action_ok AND
       lines( lt_files ) = 1.

      DATA(lt_data) = VALUE string_table( ).
      cl_gui_frontend_services=>gui_upload( EXPORTING
                                              filename = CONV #( lt_files[ 1 ]-filename )
                                              filetype = 'ASC'
                                            CHANGING
                                              data_tab = lt_data ).

**     Demo
*      cl_demo_output=>write_data( lt_data ).

      DELETE FROM zdr_table.
      DATA(lv_startzeile) = COND i( WHEN p_head = abap_true THEN 2 ELSE 1 ).
      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<zeile>) FROM lv_startzeile TO 50.
        DATA(ls_zdr_table) = VALUE zdr_table( ).

        <zeile> = |{ sy-tabix }{ p_sep }{ <zeile> }|.
        SPLIT <zeile> AT p_sep INTO TABLE DATA(lt_columns).
        DO.
          ASSIGN COMPONENT sy-index OF STRUCTURE ls_zdr_table TO FIELD-SYMBOL(<fs_comp>).
          IF sy-subrc <> 0 OR
             sy-index > lines( lt_columns ).
            EXIT.
          ENDIF.
          <fs_comp> = lt_columns[ sy-index ].
        ENDDO.

        INSERT zdr_table FROM ls_zdr_table.
      ENDLOOP.

      CALL TRANSACTION 'SE16N'.

**     Demo
*      cl_demo_output=>write_data( zdr_table ).
*      DATA(lv_html) = cl_demo_output=>get( ).
*      cl_abap_browser=>show_html( EXPORTING
*                                    title        = 'Daten aus CSV'
*                                    html_string  = lv_html
*                                    container    = cl_gui_container=>default_screen ).
*      WRITE: space.
    ENDIF.
  CATCH cx_root INTO DATA(e_text).
    MESSAGE e_text->get_text( ) TYPE 'I'.
ENDTRY.
