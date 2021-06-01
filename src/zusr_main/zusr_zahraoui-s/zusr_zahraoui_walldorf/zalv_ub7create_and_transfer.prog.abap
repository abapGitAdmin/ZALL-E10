*&---------------------------------------------------------------------*
*&  Include           ZALV_UB6CREATE_AND_TRANSFER
*&---------------------------------------------------------------------*
MODule ZALV_UB7CREATE_AND_TRANSFER OUTPUT.

if go_cont is INITIAL.

  CREATE OBJECT go_cont
    EXPORTING
*      parent                      =
      container_name              = 'MY_CONTROL_AREA'

    EXCEPTIONS
      others                      = 1
      .
  IF sy-subrc <> 0.
MESSAGE a010(bc405_408).
  ENDIF.

  "alv objekt

  create OBJECT go_alv
  EXPORTING
    i_parent = go_cont
   EXCEPTIONS
     OTHERS = 1.
  IF sy-subrc <> 0.
    MESSAGE a010(bc405_408).
  ENDIF.
  gv_variant-report =  sy-cprog.
  gv_variant-variant = pa_lv.


  go_alv->set_table_for_first_display(
  EXPORTING
    i_structure_name = 'SFLIGHT'
    is_variant = gv_variant
    i_save = 'A'
    CHANGING
      it_outtab = gt_flights
     EXCEPTIONS
       OTHERS = 1 ).
  IF sy-subrc <> 0.
    MESSAGE a010(bc405_408).
  ENDIF.
  endif.
  ENDMODULE.
