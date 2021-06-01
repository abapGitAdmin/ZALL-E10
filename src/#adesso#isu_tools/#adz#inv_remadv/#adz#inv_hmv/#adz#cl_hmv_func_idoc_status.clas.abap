CLASS /adz/cl_hmv_func_idoc_status DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES /adz/if_inv_salv_table_evt_hlr.
    methods :
      constructor
        IMPORTING
          !irt_out_table TYPE REF TO data.

  PROTECTED SECTION.
    data mrt_out type ref to /adz/hmv_t_memi_out.
  PRIVATE SECTION.

ENDCLASS.



CLASS /adz/cl_hmv_func_idoc_status IMPLEMENTATION.
  method constructor.
     mrt_out ?= irt_out_table.
  endmethod.

  METHOD /adz/if_inv_salv_table_evt_hlr~on_hotspotclick.
    "value(E_ROW_ID) type LVC_S_ROW optional
    "value(E_COLUMN_ID) type LVC_S_COL optional
    "value(ES_ROW_NO) type LVC_S_ROID optional .

    " angeclickte Zeile holen
    "    ASSIGN mrt_out->* TO FIELD-SYMBOL(<lt_out>).
    "    READ TABLE <lt_out> INTO DATA(ls_out) INDEX e_row_id-index.

    " ueber Spaltename den Wert ermitteln
    "    ASSIGN COMPONENT e_column_id-fieldname OF STRUCTURE ls_out TO FIELD-SYMBOL(<lv_field_value>).
*# Nur mit Wert befüllten Feld funktionieren
    "CHECK <lv_field_value> IS NOT INITIAL.

    CASE e_column_id-fieldname.
*      WHEN 'SEL'.
*        READ TABLE <lt_out> ASSIGNING FIELD-SYMBOL(<ls_out>) INDEX e_row_id-index.
*        <ls_out>-sel = xsdbool( <ls_out>-sel <> abap_true ).
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD  /adz/if_inv_salv_table_evt_hlr~on_user_command.
*    DATA: lv_index TYPE i.
    " eigene Userkommandos behandeln
    " BREAK-POINT.
*    IF mrt_filter IS INITIAL.
*      sender->get_filtered_entries( IMPORTING et_filtered_entries = DATA(mrt_filter) ).
*    ENDIF.
*    IF lv_index IS INITIAL.
*      sender->get_selected_rows( IMPORTING et_index_rows =  lv_index  ).
*      IF lv_index IS NOT INITIAL.
*        READ TABLE mrt_out_table ASSIGNING FIELD-SYMBOL(<ls_out>) INDEX lv_index.
*      ENDIF.
*    ENDIF.

    " Ridvan mochete gerne dass Zeilenmarkierungen auch eine gueltige Auswahl fuer Aktionen darstellen
    " deswegen werden diese in die Sel-Spalte zusaetzlich uebernommen

    CASE e_ucomm.
*# aus Invoice-Manager
*# zu aktualisieren
      WHEN 'ZEFRESH'.
        "me->/adz/if_inv_salv_table_evt_hlr~mo_controller->refresh_data(  ).
        sender->refresh_table_display( ).
      WHEN OTHERS.
        " Standardfkt aufrufen
        DATA(lv_ucomm) = e_ucomm.
        sender->set_function_code( CHANGING c_ucomm = lv_ucomm  ).  " Funktionscode
    ENDCASE.
  ENDMETHOD.


ENDCLASS.
