class ZDR_CI_CATEGORY_ISU definition
  public
  inheriting from CL_CI_CATEGORY_ROOT
  final
  create public .

*"* public components of class ZDR_CI_CATEGORY_ISU
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .
protected section.
*"* protected components of class CL_CI_CATEGORY_SLIN
*"* do not include other source files here!!!
private section.
*"* private components of class ZDR_CI_CATEGORY_ISU
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZDR_CI_CATEGORY_ISU IMPLEMENTATION.


METHOD CONSTRUCTOR .

  super->constructor( ).

  description         = 'Category for ISU'(000).
  category            = 'CL_CI_CATEGORY_TOP'.
  position            = '999'.

ENDMETHOD.
ENDCLASS.
