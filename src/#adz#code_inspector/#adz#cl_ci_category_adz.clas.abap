class /ADZ/CL_CI_CATEGORY_ADZ definition
  public
  inheriting from CL_CI_CATEGORY_ROOT
  final
  create public .

*"* public components of class /ADZ/CL_CI_CATEGORY_ADZ
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR .
protected section.
*"* protected components of class CL_CI_CATEGORY_SLIN
*"* do not include other source files here!!!
private section.
*"* private components of class /ADZ/CL_CI_CATEGORY_ADZ
*"* do not include other source files here!!!
ENDCLASS.



CLASS /ADZ/CL_CI_CATEGORY_ADZ IMPLEMENTATION.


METHOD CONSTRUCTOR .

  super->constructor( ).

  description         = 'adesso-orange Prüfungen'(000).
  category            = 'CL_CI_CATEGORY_TOP'.
  position            = '999'.

ENDMETHOD.
ENDCLASS.
