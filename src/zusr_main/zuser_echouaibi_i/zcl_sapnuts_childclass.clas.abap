class ZCL_SAPNUTS_CHILDCLASS definition
  public
  inheriting from ZCL_SAPNUTS_SUPERCLASS
  final
  create public .

public section.

  data LS_MAKT type MAKT .

  methods GET_MATERIAL_DETAILS
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SAPNUTS_CHILDCLASS IMPLEMENTATION.


  method GET_MATERIAL_DETAILS.

CALL METHOD SUPER->GET_MATERIAL_DETAILS
  EXPORTING
    IM_MATNR = im_matnr
  IMPORTING
    ex_mara  = ex_mara
    .

  SELECT SINGLE * from makt
    into ls_makt WHERE matnr = ex_mara-matnr.

  endmethod.
ENDCLASS.
