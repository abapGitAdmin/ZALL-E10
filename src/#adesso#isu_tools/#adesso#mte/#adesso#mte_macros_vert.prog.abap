*&---------------------------------------------------------------------*
*&  Include           /ADESSO/MTE_MACROS_VERT
*&---------------------------------------------------------------------*

define mac_add_relevanz.

  wrel-firma = firma.
  wrel-object = &1.
  wrel-obj_key = &2.
*  wrel-quelle = 'I'.
  append wrel to irel.

end-of-definition.
