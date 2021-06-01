class ZCL_ISU_UTILITY definition
  public
  final
  create public .

public section.

  methods PRESELECT_SWITCHDOCS .
  class-methods GET_ALL_RELATED_INT_UI
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type /IDXGC/DE_KEYDATE default SY-DATUM
      !IT_INT_UI_TO_EXCLUDE type INT_UI_TABLE optional
    returning
      value(RT_INT_UI) type INT_UI_TABLE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ISU_UTILITY IMPLEMENTATION.


  METHOD get_all_related_int_ui.
    DATA: lt_pod_rel           TYPE /idxgc/t_pod_rel,
          lt_int_ui            TYPE int_ui_table,
          lt_int_ui_to_exclude TYPE int_ui_table.

    SELECT * FROM /idxgc/pod_rel INTO TABLE lt_pod_rel
      WHERE ( int_ui1 = iv_int_ui OR int_ui2 = iv_int_ui ) AND datefrom <= iv_keydate AND dateto >= iv_keydate.

    LOOP AT lt_pod_rel ASSIGNING FIELD-SYMBOL(<ls_pod_rel>).
      READ TABLE it_int_ui_to_exclude TRANSPORTING NO FIELDS WITH KEY table_line = <ls_pod_rel>-int_ui1.
      IF sy-subrc <> 0.
        APPEND <ls_pod_rel>-int_ui1 TO lt_int_ui.
      ENDIF.
      READ TABLE it_int_ui_to_exclude TRANSPORTING NO FIELDS WITH KEY table_line = <ls_pod_rel>-int_ui2.
      IF sy-subrc <> 0.
        APPEND <ls_pod_rel>-int_ui2 TO lt_int_ui.
      ENDIF.
    ENDLOOP.

    lt_int_ui_to_exclude = it_int_ui_to_exclude.
    APPEND LINES OF lt_int_ui TO lt_int_ui_to_exclude.
    LOOP AT lt_int_ui ASSIGNING FIELD-SYMBOL(<lv_int_ui>) WHERE table_line <> iv_int_ui.
      APPEND LINES OF get_all_related_int_ui( iv_int_ui = <lv_int_ui> iv_keydate = iv_keydate
      it_int_ui_to_exclude = lt_int_ui_to_exclude ) TO rt_int_ui.
    ENDLOOP.

    APPEND LINES OF lt_int_ui TO rt_int_ui.
    SORT rt_int_ui.
    DELETE ADJACENT DUPLICATES FROM rt_int_ui.
  ENDMETHOD.


  method PRESELECT_SWITCHDOCS.

    DATA: lt_int_ui TYPE int_ui_table,
          ls_isu_ranges TYPE isu_ranges,
          lv_int_ui TYPE int_ui.

    FIELD-SYMBOLS: <lt_sel_int_ui> TYPE isu00_range_tab.

    TRY.

      ASSIGN ('(/IDXGC/RP_PDOC_MONITORING)GET_SEL_INT_UI[]') TO <lt_sel_int_ui>.

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

  endmethod.
ENDCLASS.
