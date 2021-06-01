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
REPORT zdr_generator_v2.

* Anzahl hinzuzufügender Zeilen
PARAMETERS: p_n TYPE i DEFAULT 100.
* Tabelle vorher leeren
PARAMETERS: p_delet AS CHECKBOX.

PERFORM generate_from_datacat.

*&---------------------------------------------------------------------*
*&      Form  GENERATE_FROM_DATACAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_from_datacat .
  TRY .
      TABLES: /ado/sql_datacat,
              /ado/sql_suprem..
      DATA: ls_datasuprem  TYPE /ado/sql_suprem.

*    erzeuge tiefe struktur <struc_expl> mit einer tabelle von beispieldaten für jede komponente
      DATA(o_struc_desc) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_datasuprem ) ).
      DATA(lt_component) = VALUE cl_abap_structdescr=>component_table(
        FOR <comp> IN o_struc_desc->components FROM 2 (
          VALUE #(
            name = <comp>-name
            type = CAST #( cl_abap_tabledescr=>describe_by_name( 'STRING_TABLE' ) )
          )
        )
      ).
      o_struc_desc = cl_abap_structdescr=>create( lt_component ).
      DATA o_struc_expl TYPE REF TO data.
      CREATE DATA o_struc_expl TYPE HANDLE o_struc_desc.
      ASSIGN o_struc_expl->* TO FIELD-SYMBOL(<struc_expl>).


*    fülle die tabellen der tiefen struktur mit daten
      FIELD-SYMBOLS <tab> TYPE table.
      LOOP AT o_struc_desc->components ASSIGNING FIELD-SYMBOL(<comp1>).
        ASSIGN COMPONENT <comp1>-name OF STRUCTURE <struc_expl> TO <tab>.

        SELECT exampledata
          FROM /ado/sql_datacat
          INTO TABLE <tab>
          WHERE fieldname = <comp1>-name.
      ENDLOOP.

*    fülle die datenbanktabelle mit random daten aus der tiefen
      DATA(randomi) = cl_abap_random=>create( ).
      IF p_delet = abap_true.
        DELETE FROM /ado/sql_suprem.
      ENDIF.
      DO p_n TIMES.
        ls_datasuprem-id = sy-index.

        LOOP AT o_struc_desc->components ASSIGNING FIELD-SYMBOL(<comp2>).
          ASSIGN COMPONENT <comp2>-name OF STRUCTURE <struc_expl> TO <tab>.
          ASSIGN COMPONENT <comp2>-name OF STRUCTURE ls_datasuprem TO FIELD-SYMBOL(<value>).

          <value> = <tab>[ randomi->intinrange( low = 1 high = lines( <tab> ) ) ].
        ENDLOOP.

        INSERT /ado/sql_suprem FROM ls_datasuprem.
      ENDDO.

      CALL TRANSACTION 'SE16N'.

    CATCH cx_root INTO DATA(e_text).
      MESSAGE e_text->get_text( ) TYPE 'I'.
  ENDTRY.
ENDFORM.
