class /ADZ/SCI_RESULT_SCAN definition
  public
  inheriting from CL_CI_RESULT_ROOT
  final
  create public .

public section.

  methods IF_CI_TEST~NAVIGATE
    redefinition .
ENDCLASS.



CLASS /ADZ/SCI_RESULT_SCAN IMPLEMENTATION.


  method IF_CI_TEST~NAVIGATE.
    if ( me->result-sobjtype is not initial ).
      call function 'RS_TOOL_ACCESS'
        exporting
          operation   = 'SHOW'
          object_name = result-sobjname
          object_type = result-sobjtype
        exceptions
          others = 1.
      if ( sy-subrc = 0 ).
        return.
      endif.
    endif.

    call function 'RS_TOOL_ACCESS'
      exporting
        operation   = 'SHOW'
        object_name = result-objname
        object_type = result-objtype
      exceptions
        others = 0.
  endmethod.
ENDCLASS.
