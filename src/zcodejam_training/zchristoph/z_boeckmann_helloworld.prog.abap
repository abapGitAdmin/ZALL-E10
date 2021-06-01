*&---------------------------------------------------------------------*
*& Report z_boeckmann_helloworld
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_boeckmann_helloworld.

WRITE: 'Hello World!'.

DATA(lv_name) = cl_abap_syst=>get_user_name( ).
DATA(lv_string) = |Hello { lv_name }, welcome to the SAP HANA CodeJAM! |.

WRITE: lv_string.

SELECT * FROM t100
    INTO @DATA(ls_t100)
    WHERE sprsl = 'E'
    AND arbgb = 'S_EPM_OIA'.
  WRITE: / ls_t100-text.
ENDSELECT.
