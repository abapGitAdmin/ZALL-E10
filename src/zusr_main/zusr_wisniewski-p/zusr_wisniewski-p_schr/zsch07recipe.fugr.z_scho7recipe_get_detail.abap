FUNCTION z_scho7recipe_get_detail.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ID_RID) TYPE  ZSCH06RECIPE-RID DEFAULT '002'
*"  EXPORTING
*"     REFERENCE(ES_RECIPE) TYPE  ZSCH06RECIPE
*"----------------------------------------------------------------------

  SELECT SINGLE * FROM zsch06recipe INTO es_recipe WHERE rid = id_rid.

ENDFUNCTION.
