interface ZIF_SAPNUTS_MATERIAL_EXAMPLE
  public .


  methods GET_METERIAL_DETAILS
    importing
      !IM_MATNR type MARA-MATNR
    exporting
      !EX_MARA type MARA .
  methods GET_MATERIAL_DESCRIPTIONS
    importing
      !IM_MATNR type MARA-MATNR
    exporting
      !EX_MAKT type MAKT .
endinterface.
