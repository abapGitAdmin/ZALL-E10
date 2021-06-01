class ZCL_SAPNUTS_SUPERCLASS definition
  public
  create public .

public section.

  methods GET_MATERIAL_DETAILS
    importing
      !IM_MATNR type MARA-MATNR
    exporting
      !EX_MARA type MARA .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SAPNUTS_SUPERCLASS IMPLEMENTATION.


  method GET_MATERIAL_DETAILS.


    select SINGLE * from mara
      into ex_mara WHERE matnr = im_matnr.


  endmethod.
ENDCLASS.
