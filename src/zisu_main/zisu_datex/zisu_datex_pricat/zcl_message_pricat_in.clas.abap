class ZCL_MESSAGE_PRICAT_IN definition
  public
  inheriting from /IDXGL/CL_MESSAGE_PRICAT_IN
  final
  create public .

public section.

  methods GET_REF_FROM_DOCIDENT_WITH_MS
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MESSAGE_PRICAT_IN IMPLEMENTATION.


  method GET_REF_FROM_DOCIDENT_WITH_MS.
**TRY.
*CALL METHOD SUPER->GET_REF_FROM_DOCIDENT_WITH_MS
*  EXPORTING
*    IV_DOCUMENT_IDENT =
*    IV_DOCNAME_CODE   =
*    IV_MESTYP         =
*    IV_SENDER         =
*    IV_DIRECT         =
**  IMPORTING
**    ev_proc_ref       =
*    .
** CATCH /idxgc/cx_ide_error .
**ENDTRY.
  endmethod.
ENDCLASS.
