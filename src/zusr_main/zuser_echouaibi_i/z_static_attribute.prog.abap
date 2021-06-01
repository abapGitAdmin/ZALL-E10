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
REPORT z_static_attribute.


CLASS class1 DEFINITION.

  PUBLIC SECTION.

    CLASS-DATA: static_var_text  TYPE c LENGTH 30,
                static_var_count TYPE i.

    METHODS: methode_class1.
ENDCLASS.


CLASS class1 IMPLEMENTATION.

  METHOD methode_class1.

    static_var_text = 'SAP ABAP OBJECT ORIENTED'.
    static_var_count = 10.

    DO static_var_count TIMES.

      WRITE:/ sy-index, '>', static_var_text.

      SKIP.

    ENDDO.

  ENDMETHOD.

ENDCLASS.


data: obj TYPE REF TO class1.

start-OF-SELECTION.

create OBJECT obj.

CALL METHOD obj->methode_class1( ).


class1=>static_var_text = 'SAP ABAP DYNPRO'.

class1=>static_var_count = 5.

  DO class1=>static_var_count TIMES.

      WRITE:/ sy-index, '>', class1=>static_var_text.

      SKIP.

    ENDDO.
