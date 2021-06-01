CLASS zhar_cl_access_if DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES  zhar_if_constants.
     ALIASES   mc_main_seg for  zhar_if_constants~mc_main_segment.
   "CONSTANTS  mif  type ref to zhar_if_constants value new zhar_cl_access_if( ).
    METHODS:
      test.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zhar_cl_access_if IMPLEMENTATION.
  method test.
    data x type char10.
    x = zhar_if_constants=>mc_main_segment.

    data(meif) = CAST zhar_if_constants( me ).
    x = meif->mc_main_segment.

    x = mc_main_seg.

    "x = me->zhar_if_constants=>mc_main_segment.
    "x = me=>mc_main_segment.
    data(lif) = new zhar_cl_access_if(  ).


  endmethod.
ENDCLASS.

