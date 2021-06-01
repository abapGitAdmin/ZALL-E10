class ZTC_GCL_SCH_08_CBEAN_BOX definition
  public
  final
  create public .

public section.

  methods ADD_BEAN_TO_BOX
    importing
      !IR_CBEAN type ref to ZTC_GCL_SCH_08_CBEAN .
protected section.
private section.

  data GD_VOLUME type I .
  constants GC_MAX_VOLUME type I value 700000 ##NO_TEXT.
ENDCLASS.



CLASS ZTC_GCL_SCH_08_CBEAN_BOX IMPLEMENTATION.


  method ADD_BEAN_TO_BOX.

    me->gd_volume = me->gd_volume + ir_cbean->get_volume( ).



  endmethod.
ENDCLASS.
