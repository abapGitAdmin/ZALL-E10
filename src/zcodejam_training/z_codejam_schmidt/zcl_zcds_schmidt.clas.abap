class ZCL_ZCDS_SCHMIDT definition
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



CLASS ZCL_ZCDS_SCHMIDT IMPLEMENTATION.


  method GET_PATHS.
et_paths = VALUE #(
( `CDS~ZCDS_SCHMIDT` )
).
  endmethod.


  method GET_TIMESTAMP.
RV_TIMESTAMP = 20180525134001.
  endmethod.
ENDCLASS.
