class ZLS_GCL_SCH_08_CBEAN_BOX definition
  public
  final
  create public .

public section.

  constants GC_MAX_VOLUME type I value 25000 ##NO_TEXT.

  events LOADED .

  methods ADD_BEAN_TO_BOX
    importing
      !IR_CBEAN type ref to ZLS_GCL_SCH_08_CBEAN .
protected section.
private section.

  data GD_VOLUME type I .
ENDCLASS.



CLASS ZLS_GCL_SCH_08_CBEAN_BOX IMPLEMENTATION.


  METHOD add_bean_to_box.

    DATA: bean_volume      TYPE i,
          new_fuellvolumen TYPE i.

    bean_volume      = ir_cbean->get_volume( ).
    new_fuellvolumen = bean_volume + gd_volume.

    IF new_fuellvolumen > gc_max_volume.
      RAISE EVENT loaded.
    ELSE.
      GD_VOLUME = new_fuellvolumen.
      WRITE: / 'Vol: ', me->gd_volume.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
