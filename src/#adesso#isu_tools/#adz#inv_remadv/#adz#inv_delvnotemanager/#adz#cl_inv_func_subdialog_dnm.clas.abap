CLASS /adz/cl_inv_func_subdialog_dnm DEFINITION INHERITING FROM /adz/cl_inv_func_delvnoteman
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      constructor     IMPORTING      !irt_out_table    TYPE REF TO data.

  PROTECTED SECTION.
    METHODS get_hotspot_row REDEFINITION.

  PRIVATE SECTION.
    DATA mrt_out_any TYPE REF TO data.
ENDCLASS.



CLASS /adz/cl_inv_func_subdialog_dnm IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).
    IF irt_out_table IS NOT INITIAL.
      " Kopie von Eingabetabelle erstellen
      FIELD-SYMBOLS <lt_src> TYPE STANDARD TABLE.
      FIELD-SYMBOLS <lt_tar> TYPE STANDARD TABLE.
      ASSIGN irt_out_table->* TO <lt_src>.
      CREATE DATA mrt_out_any LIKE <lt_src>.
      ASSIGN mrt_out_any->*   TO <lt_tar>.
      <lt_tar> = <lt_src>.
    ENDIF.
  ENDMETHOD.

  METHOD get_hotspot_row.
    " angeclickte Zeile holen
    FIELD-SYMBOLS <lt_out> TYPE STANDARD TABLE.
    ASSIGN mrt_out_any->* TO <lt_out>.
    rrs_row = REF #( <lt_out>[ iv_rownr ] ).
    "READ TABLE <lt_out> INTO DATA(rs_row) INDEX iv_rownr.
  ENDMETHOD.

ENDCLASS.
