class ZCL_SCH_08_CBEAN definition
  public
  final
  create public .

public section.

  methods SET_VOLUME
    importing
      value(ID_VOLUME) type I .
  methods GET_VOLUME
    returning
      value(ID_VOLUME) type I .
protected section.
private section.

  data GD_VOLUME type I value 350 ##NO_TEXT.
ENDCLASS.



CLASS ZCL_SCH_08_CBEAN IMPLEMENTATION.


  method GET_VOLUME.
    id_volume = me->gd_volume.
  endmethod.


  method SET_VOLUME.
    me->gd_volume = id_volume.
  endmethod.
ENDCLASS.
