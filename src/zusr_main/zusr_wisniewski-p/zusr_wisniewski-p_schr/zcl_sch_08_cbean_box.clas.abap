class ZCL_SCH_08_CBEAN_BOX definition
  public
  final
  create public .

public section.

  constants GC_MAX_VOLUME type I value 700000 ##NO_TEXT.

  events LOADED .

  methods ADD_BEAN_TO_BOX
    importing
      !IR_CBEAN type ref to ZCL_SCH_08_CBEAN .
protected section.
private section.

  data GD_VOLUME type I .
ENDCLASS.



CLASS ZCL_SCH_08_CBEAN_BOX IMPLEMENTATION.


  METHOD add_bean_to_box.
    DATA ld_volume LIKE me->gd_volume.
    ld_volume = me->gd_volume + ir_cbean->get_volume( ).
    IF ld_volume > me->gc_max_volume.
      RAISE EVENT loaded.
    ELSE.
      me->gd_volume = ld_volume.
      WRITE: / 'Vol: ', me->gd_volume.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
