*&---------------------------------------------------------------------*
*&  Include           ZBC405_ALV_UNTERPRO_UB25
*&---------------------------------------------------------------------*

" ub25
FORM define_settings
  USING po_alv TYPE REF TO cl_salv_table.
  PERFORM:set_display USING po_alv,
          set_spalte USING po_alv.
ENDFORM.

"Form display
FORM set_display
  USING po_alv TYPE REF TO cl_salv_table.
  DATA: lo_dis   TYPE REF TO cl_salv_display_settings,
        lv_title TYPE  lvc_title.

  " get anzeigeeinstellungen
  lo_dis = po_alv->get_display_settings( ).
  "änderung vom Title

  lv_title = text-tt1.
  lo_dis->set_list_header( value = TEXT-tt1 ).
  "Änderug  horizentale Trennlinie
  lo_dis->set_horizontal_lines( value = ' ' ).
  "Steifenmuster prüfen ob eingeschaltet
  lo_dis->set_striped_pattern( value = 'X' ).

ENDFORM.

FORM set_spalte
  USING po_al TYPE REF TO cl_salv_table.
  DATA lo_spa TYPE REF TO cl_salv_columns_table.

  "get spalte optimale spaltenbreite
  lo_spa = po_al->get_columns( ).
  "fixierun der Schlüsslespalten
  lo_spa->set_key_fixation(
  "value =  if_salv_C-bool_sap*true
  ).
  "optimale spaltebreite
  lo_spa->set_optimize( ).

  ENDFORM..
