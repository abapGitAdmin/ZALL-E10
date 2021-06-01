class ZCL_SAPNUTS_SINGLETON definition
  public
  final
  create public .

public section.

  class-methods INSTANTIATE
    returning
      value(RO_INST) type ref to ZCL_SAPNUTS_SINGLETON .
protected section.
private section.

  class-data LV_INST type ref to ZCL_SAPNUTS_SINGLETON .
ENDCLASS.



CLASS ZCL_SAPNUTS_SINGLETON IMPLEMENTATION.


  METHOD instantiate.


    IF lv_inst IS NOT BOUND.

      CREATE OBJECT: ro_inst.
      lv_inst = ro_inst.
    ELSE.
      ro_inst = lv_inst.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
