class ZCL_AGC_IDE_SWTDOC_MON definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_ISU_IDE_SWTDOC_MON .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AGC_IDE_SWTDOC_MON IMPLEMENTATION.


  method IF_ISU_IDE_SWTDOC_MON~ALV_ACTION.
  endmethod.


  method IF_ISU_IDE_SWTDOC_MON~ALV_FILL_DATA.
  endmethod.


  method IF_ISU_IDE_SWTDOC_MON~ALV_SET_FIELDCATALOG.
  endmethod.


  method IF_ISU_IDE_SWTDOC_MON~FILTER_SWTDOCS.
  endmethod.


  method IF_ISU_IDE_SWTDOC_MON~PRESELECT_SWITCHDOCS.
  endmethod.
ENDCLASS.
