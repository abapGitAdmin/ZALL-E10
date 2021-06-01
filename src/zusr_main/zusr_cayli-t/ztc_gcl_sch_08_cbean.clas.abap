class ZTC_GCL_SCH_08_CBEAN definition
  public
  final
  create public .

public section.

  methods SET_VOLUME
    importing
      value(ID_VOLUME) type I .
  methods GET_VOLUME
    returning
      value(RP_VOLUME) type I .
protected section.
private section.

  data GD_VOLUME type I value 350 ##NO_TEXT.
ENDCLASS.



CLASS ZTC_GCL_SCH_08_CBEAN IMPLEMENTATION.


  method GET_VOLUME.





  endmethod.


  METHOD set_volume.
    "Call by Referenze probieren.
    me->gd_volume = id_volume.
  ENDMETHOD.
ENDCLASS.
