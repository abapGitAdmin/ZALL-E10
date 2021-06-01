*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MTE_MACROS_NN
*&---------------------------------------------------------------------*

DEFINE mac_add_relevanz.

  wrel-firma = firma.
  wrel-object = &1.
  wrel-obj_key = &2.
*  wrel-quelle = 'I'.
  append wrel to irel.

END-OF-DEFINITION.
