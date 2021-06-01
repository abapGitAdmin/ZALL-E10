class ZCL_IM_ADM_REQUEST_CHECK definition
  public
  final
  create public .

public section.

  interfaces IF_EX_CTS_REQUEST_CHECK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_ADM_REQUEST_CHECK IMPLEMENTATION.


  method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_ADD_OBJECTS.

    if 1 = 5.
      ENDIF.
  endmethod.


  method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_CHANGING_OWNER.
  endmethod.


  method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_CREATION.

    IF 1 = 5.

    ENDIF.

  endmethod.


  method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_RELEASE.

    if owner = 'struck-f'.
      BREAK-POINT.
    endif.

  endmethod.


  method IF_EX_CTS_REQUEST_CHECK~CHECK_BEFORE_RELEASE_SLIN.
  endmethod.
ENDCLASS.
