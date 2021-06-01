CLASS zha_cl_smo_data2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
    SHARED MEMORY ENABLED .

  PUBLIC SECTION.
    DATA mv_blubber TYPE string.
    DATA mo_struct  type ref to cl_abap_structdescr.

    methods:
      to_string
          RETURNING VALUE(rv_str) type string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zha_cl_smo_data2 IMPLEMENTATION.
    method to_string.
       rv_str =  | blubber = { mv_blubber }|.
    ENDMETHOD.

ENDCLASS.
