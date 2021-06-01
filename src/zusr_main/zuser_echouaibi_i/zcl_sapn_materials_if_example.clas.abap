class ZCL_SAPN_MATERIALS_IF_EXAMPLE definition
  public
  final
  create public .

public section.

  interfaces ZIF_SAPNUTS_MATERIAL_EXAMPLE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SAPN_MATERIALS_IF_EXAMPLE IMPLEMENTATION.


  method ZIF_SAPNUTS_MATERIAL_EXAMPLE~GET_MATERIAL_DESCRIPTIONS.

    select SINGLE * from makt
      into ex_makt WHERE matnr = im_matnr.


  endmethod.


  method ZIF_SAPNUTS_MATERIAL_EXAMPLE~GET_METERIAL_DETAILS.


    select SINGLE * FROM mara
      into ex_mara WHERE matnr = im_matnr.
  endmethod.
ENDCLASS.
