*&---------------------------------------------------------------------*
*&  Include           ZALV_UB6CREATE_AND_TRANSFER
*&---------------------------------------------------------------------*
MODule ZALV_UB8CREATE_AND_TRANSFER OUTPUT.

if go_cont is INITIAL.

  CREATE OBJECT go_cont
    EXPORTING
*      parent                      =
      container_name              = 'MY_CONTROL_AREA'

    EXCEPTIONS
      others                      = 1.

  IF sy-subrc <> 0 and sy-batch is INITIAL.
MESSAGE a010(bc405_408).
  ENDIF.

  "alv objekt

  create OBJECT go_alv
  EXPORTING
    i_parent = go_cont
   EXCEPTIONS
     OTHERS = 1.
  IF sy-subrc <> 0 and sy-batch is INITIAL.
    MESSAGE a010(bc405_408).
  ENDIF.

  gv_variant-report =  sy-cprog.
  gv_variant-variant = pa_lv.
  " üb8
  "Titlevo Grid und
gs_layout-grid_title = 'Fluege'(h01).
gs_layout-no_hgridln = 'X'.
gs_layout-no_vgridln = 'X'.
"7
gs_layout-info_fname = 'COLOR'.
" info über farbe der zelle
gs_layout-ctab_fname = 'IT_FIELD_COLORS'.
"feld enthält info mit Exception
gs_layout-excp_fname = 'LIGHT'.
"4
gs_layout-sel_mode = 'A'.


  go_alv->set_table_for_first_display(
  EXPORTING
    i_structure_name = 'SFLIGHT'
    is_variant = gv_variant
    i_save = 'A'
    "üb8
    is_layout = gs_layout
    CHANGING
      it_outtab = gt_flights
     EXCEPTIONS
       OTHERS = 1 ).
  IF sy-subrc <> 0.
    MESSAGE a010(bc405_408).
  ENDIF.
  endif.
  ENDMODULE.
