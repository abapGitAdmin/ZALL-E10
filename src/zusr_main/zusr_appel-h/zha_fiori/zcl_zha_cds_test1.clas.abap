class ZCL_ZHA_CDS_TEST1 definition
  public
  inheriting from CL_SADL_GTK_EXPOSURE_MPC
  final
  create public .

public section.
protected section.

  methods GET_PATHS
    redefinition .
  methods GET_TIMESTAMP
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZHA_CDS_TEST1 IMPLEMENTATION.


  method GET_PATHS.
et_paths = VALUE #(
( `CDS~ZHA_CDS_TEST1` )
).
  endmethod.


  method GET_TIMESTAMP.
RV_TIMESTAMP = 20201229124233.
  endmethod.
ENDCLASS.
