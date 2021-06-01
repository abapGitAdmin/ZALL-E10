class ZCL_ISU_IM_BADI_PDOC_MONITOR definition
  public
  inheriting from /IDXGC/CL_BADI_PDOC_MONITOR
  final
  create public .

public section.

  methods IF_ISU_IDE_SWTDOC_MON~PRESELECT_SWITCHDOCS
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ISU_IM_BADI_PDOC_MONITOR IMPLEMENTATION.


  METHOD if_isu_ide_swtdoc_mon~preselect_switchdocs.

    DATA: lt_int_ui     TYPE int_ui_table,
          ls_isu_ranges TYPE isu_ranges,
          lv_int_ui     TYPE int_ui.

    FIELD-SYMBOLS: <lt_sel_int_ui> TYPE isu00_range_tab.

    TRY.

        ASSIGN ('(/IDXGC/RP_PDOC_MONITORING)GT_SEL_INT_UI[]') TO <lt_sel_int_ui>.

        IF <lt_sel_int_ui> IS ASSIGNED AND <lt_sel_int_ui> IS NOT INITIAL.
          ls_isu_ranges-sign = 'I'.
          ls_isu_ranges-option = 'EQ'.
          LOOP AT <lt_sel_int_ui> ASSIGNING FIELD-SYMBOL(<ls_sel_int_ui>) WHERE sign = 'I' AND option = 'EQ'.
            lv_int_ui = <ls_sel_int_ui>-low.
            APPEND LINES OF zcl_isu_utility=>get_all_related_int_ui( iv_int_ui = lv_int_ui iv_keydate = sy-datum ) TO lt_int_ui.
          ENDLOOP.
          LOOP AT lt_int_ui ASSIGNING FIELD-SYMBOL(<lv_int_ui>).
            ls_isu_ranges-low = <lv_int_ui>.
            APPEND ls_isu_ranges TO <lt_sel_int_ui>.
          ENDLOOP.
          SORT <lt_sel_int_ui> BY low.
          DELETE ADJACENT DUPLICATES FROM <lt_sel_int_ui>.
        ENDIF.
      CATCH /idxgc/cx_general.

    ENDTRY.

    CALL METHOD super->if_isu_ide_swtdoc_mon~preselect_switchdocs
      EXPORTING
        x_p_maxrec    = x_p_maxrec
        x_p_view      = x_p_view
        x_sparty      = x_sparty
        x_so_swtdo    = x_so_swtdo
        x_so_bppar    = x_so_bppar
        x_so_movin    = x_so_movin
        x_so_movou    = x_so_movou
        x_so_intui    = x_so_intui
        x_so_oldsu    = x_so_oldsu
        x_so_newsu    = x_so_newsu
        x_so_distr    = x_so_distr
        x_so_docst    = x_so_docst
        x_so_swtyp    = x_so_swtyp
        x_so_srcsc    = x_so_srcsc
        x_so_tarsc    = x_so_tarsc
      IMPORTING
        yt_swtnum     = yt_swtnum
        y_preselected = y_preselected.
  ENDMETHOD.
ENDCLASS.
