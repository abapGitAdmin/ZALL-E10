*&---------------------------------------------------------------------*
*&  Include           ZALV_UB6CREATE_AND_TRANSFER
*&---------------------------------------------------------------------*
MODULE zalv_ub11create_and_transfer OUTPUT.

  IF go_cont IS INITIAL.

    CREATE OBJECT go_cont
      EXPORTING
*       parent         =
        container_name = 'MY_CONTROL_AREA'
      EXCEPTIONS
        OTHERS         = 1.

    IF sy-subrc <> 0.
      MESSAGE a010(bc405_408).
    ENDIF.

    "alv objekt

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_cont
      EXCEPTIONS
        OTHERS   = 1.
    IF sy-subrc <> 0.
      MESSAGE a010(bc405_408).
    ENDIF.
    " Event handlung

    " übun10 registrieren von der  Event durch set handler

    SET HANDLER:
     lcl_handler=>on_doubleclick FOR go_alv,
    " üb11
    lcl_handler=>on_print_top FOR go_alv,
    lcl_handler=>on_print_tol for go_alv.

    gv_variant-report =  sy-cprog.
    IF not  pa_lv is INITIAL.
      gv_variant-variant = pa_lv.

    ENDIF.
    "gv_variant-variant = pa_lv.

    " aufgabe 11 Info über sortierung und zwischensummen und und definiertetn filter

    gs_print-prntlstinf = 'X'.
    gs_print-grpchgedit = 'X'.
    " üb8
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

    "üb9
    " summe spalte mit belegten Plätzr summe bilden ->do_dum
    gs_field_cat-fieldname = 'SEATSOCC'.
    gs_field_cat-do_sum = 'X'.
    APPEND gs_field_cat TO gt_field_cat.

    " spate mit aktuellenn buchnugssumen ausbelenden
    "jedesmal clear diese gs_field_cat
    CLEAR gs_field_cat.
    gs_field_cat-fieldname = 'PAYMENTSUM'.
    gs_field_cat-do_sum = 'X'.
    APPEND gs_field_cat TO gt_field_cat.

    "Ampelsymbol für die Auslastung dargestellt .soll eoem übersetzbare
    CLEAR gs_field_cat.
    gs_field_cat-fieldname = 'LIGHT'.
    gs_field_cat-coltext = 'Utilization'(h02).
    APPEND gs_field_cat TO gt_field_cat.
    " aufgabe 9

    CLEAR gs_field_cat.
    gs_field_cat-fieldname = 'CHANGES_POSSIBLE'.
    gs_field_cat-col_pos = '5'.
    gs_field_cat-coltext = 'Aenderungen moeglich?'(h03).
    gs_field_cat-tooltip = ' sind möglich die Änderungen'(t01).
    APPEND gs_field_cat TO gt_field_cat.
    " wenn Flugdatum in Vergangenheit liegt ,soll wert icon space erhalen ansonten icon_okay



    " löschen dieses lokal pgs_field und ändere nur ein paar hier no_out
    "hier spalte ausbelenden


    go_alv->set_table_for_first_display(
    EXPORTING
      i_structure_name = 'SFLIGHT'
      is_variant = gv_variant
      i_save = 'A'
      is_layout = gs_layout
      is_print = gs_print
      CHANGING
        it_outtab = gt_flights
        it_fieldcatalog = gt_field_cat
        EXCEPTIONS
         OTHERS = 1 ).
    IF sy-subrc <> 0.
      MESSAGE a010(bc405_408).
    ENDIF.
  ENDIF.
ENDMODULE.
