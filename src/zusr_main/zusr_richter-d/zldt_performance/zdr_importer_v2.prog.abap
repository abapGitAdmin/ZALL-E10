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

REPORT zdr_importer_v2.

* Überschriften vorhanden
PARAMETERS: p_head AS CHECKBOX DEFAULT ''.
* Separator / Trennzeichen
PARAMETERS: p_sep TYPE char1 DEFAULT ';'.

TABLES: zdr_dataengine.

TRY.
    DATA: lt_files     TYPE filetable,
          lv_rc        TYPE i,
          lv_action    TYPE i.

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

      DELETE FROM zdr_dataengine.
      DATA(lv_startzeile) = COND i( WHEN p_head = abap_true THEN 2 ELSE 1 ).
      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<zeile>) FROM lv_startzeile TO 50.
        DATA(ls_table) = VALUE zdr_dataengine( ).

*        <zeile> = |{ sy-tabix }{ p_sep }{ <zeile> }|.
        SPLIT <zeile> AT p_sep INTO TABLE DATA(lt_columns).
        DO.
          ASSIGN COMPONENT sy-index OF STRUCTURE ls_table TO FIELD-SYMBOL(<fs_comp>).
          IF sy-subrc <> 0 OR
             sy-index > lines( lt_columns ).
            EXIT.
          ENDIF.
          <fs_comp> = lt_columns[ sy-index ].
        ENDDO.

        INSERT zdr_dataengine FROM ls_table.
      ENDLOOP.

      CALL TRANSACTION 'SE16N'.

    ENDIF.
  CATCH cx_root INTO DATA(e_text).
    MESSAGE e_text->get_text( ) TYPE 'I'.
ENDTRY.
