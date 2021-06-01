*&---------------------------------------------------------------------*
*& Report zr_house_hello_world
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_house_hello_world.

DATA(lv_name) = cl_abap_syst=>get_user_name( ).
DATA(lv_string) = |Hello { lv_name }, welcome to ABAP!|.

WRITE: lv_string.
