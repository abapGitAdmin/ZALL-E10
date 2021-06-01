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
REPORT zdr_generator.

* Überschriften vorhanden
PARAMETERS: p_head AS CHECKBOX DEFAULT ''.
* Separator / Trennzeichen
PARAMETERS: p_sep TYPE char1 DEFAULT ';'.

TABLES: zdr_dataengine,
        zdr_table.

**********************************************************************
* füllt eine gegebene Tabelle mit Beispieldaten aus ZDR_DATAENGINE.
* Die übergebene Tabelle muss dafür ausschließlich Felder enthalten,
* die auch in ZDR_DATAENGINE vertreten sind
**********************************************************************

**********************************************************************
* Idee kacke! mach DATAENGINE als Tabelle von Tabellen! zu jedem
* Fieldname gibt es eine beliebig lange Tabelle mit Beispieldaten
* (evlt initialen Daten wie "Nichts")
**********************************************************************

TYPES:
  BEGIN OF my_struct,
    fname TYPE string,
    name  TYPE string,
  END OF my_struct.

DATA:
  descr_ref TYPE REF TO cl_abap_structdescr.

START-OF-SELECTION.
  DATA(my_data) = VALUE my_struct( ).
  descr_ref ?= cl_abap_typedescr=>describe_by_data( my_data ).

*  Loop über alle Komponenten der Struktur der übergebenen Tabelle
  LOOP AT descr_ref->components ASSIGNING FIELD-SYMBOL(<comp>).
*    Hole den der Komponente entsprechenden Datensatz mit den Beispieldaten aus
*    der "Dataengine"
    SELECT SINGLE *
      FROM zdr_dataengine
      INTO @DATA(example_data)
      WHERE fieldname = @<comp>-name.

*    Loop über alle Komponenten des Beispieldatensatzes und wähle per Zufall einen aus,
*
    DO.
*      DATA().
*      ASSIGN COMPONENT sy-index OF STRUCTURE example_data TO FIELD-SYMBOL(<data_entry>).
*      IF sy-subrc <> 0.
*        EXIT.
*      ENDIF.
*      IF sy-index > 0 AND <data_entry> IS NOT INITIAL.
*        APPEND <data>
*      ENDIF.
    ENDDO.
  ENDLOOP.
