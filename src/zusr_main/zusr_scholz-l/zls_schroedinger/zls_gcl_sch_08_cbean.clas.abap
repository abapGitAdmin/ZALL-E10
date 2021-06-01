class ZLS_GCL_SCH_08_CBEAN definition
  public
  final
  create public .

public section.

  methods SET_VOLUME
    importing
      value(CD_VOLUME) type I .
  methods GET_VOLUME
    returning
      value(RD_VOLUME) type I .
protected section.
private section.

  data GD_VOLUME type I value 350 ##NO_TEXT.
ENDCLASS.



CLASS ZLS_GCL_SCH_08_CBEAN IMPLEMENTATION.


  method GET_VOLUME.
   	 rd_VOLUME = gd_VOLUME.

  endmethod.


  method SET_VOLUME.
    GD_VOLUME = CD_VOLUME.
  endmethod.
ENDCLASS.
