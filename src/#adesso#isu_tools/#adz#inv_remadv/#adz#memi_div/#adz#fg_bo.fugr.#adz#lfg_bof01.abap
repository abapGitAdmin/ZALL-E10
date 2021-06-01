*----------------------------------------------------------------------*
***INCLUDE /ADZ/LFG_BOF01.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZ_FG_BOF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PF_INSERT_MEMI_DUN_HIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CT_FKKMAZE[]  text
*----------------------------------------------------------------------*
FORM pf_update_memi_dun_hist TABLES it_fkkmaze_insert TYPE STANDARD TABLE.

  DATA:
    lt_fkkmaze               TYPE STANDARD TABLE OF fkkmaze,
    ls_fkkmaze               TYPE fkkmaze,
    ls_dunstatus_enabled     TYPE /idxmm/docstscfg,
    lt_dunstatus_enabled     TYPE /idxmm/t_docstscfg,
    ls_dunstatus_excluded    TYPE /idxmm/docstscfg,
    lt_dunstatus_excluded    TYPE /idxmm/t_docstscfg,
    ls_fica_doc_ref          TYPE /idxmm/s_fica_doc_ref,
    lt_fica_doc_ref          TYPE /idxmm/t_fica_doc_ref,
    ls_range_status          TYPE isu_ranges,
    lt_range_status          TYPE isu_ranges_tab,
    lt_range_status_excluded TYPE isu_ranges_tab,
    ls_memi_doc              TYPE /idxmm/memidoc,
    lt_memi_doc              TYPE /idxmm/t_memi_doc,
    ls_dun_hist_insert       TYPE /idxmm/dun_hist,
    lt_dun_hist_insert       TYPE /idxmm/t_dun_hist,
    lt_memi_fkkmavs          TYPE TABLE OF ts_memi_fkkmavs,
    lt_dun_level_conf        TYPE STANDARD TABLE OF tfk047b,
    ls_dun_level_conf        TYPE tfk047b,
    lv_dun_level_upd         TYPE flag,
    lv_current_mahnv         TYPE mahnv_kk,
    lv_max_dun_level         TYPE mahns_kk.

  DATA: ls_mloc     TYPE /adz/mem_mloc,
        ls_dun_hist TYPE /idxmm/dun_hist.

  LOOP AT it_fkkmaze_insert[] INTO ls_fkkmaze.
    ls_fica_doc_ref-ci_fica_doc_no = ls_fkkmaze-opbel.
    ls_fica_doc_ref-opupk = ls_fkkmaze-opupk.
    APPEND ls_fica_doc_ref TO lt_fica_doc_ref.
  ENDLOOP.

* Get dunning level configuration.
  lt_memi_fkkmavs = gt_memi_fkkmavs.
  SORT lt_memi_fkkmavs BY mahnv.
  DELETE ADJACENT DUPLICATES FROM lt_memi_fkkmavs COMPARING mahnv.
  SELECT * FROM tfk047b
    INTO TABLE lt_dun_level_conf
    FOR ALL ENTRIES IN lt_memi_fkkmavs
    WHERE mahnv = lt_memi_fkkmavs-mahnv.                    "#EC *
  SORT lt_dun_level_conf BY mahnv mahns.

* Get document statuses that are dunning enabled and excluded from configuration
  TRY.
      CALL METHOD /idxmm/cl_customizing_access=>/idxmm/if_customizing_access~get_doc_status_config
        EXPORTING
          iv_dunning_enabled = abap_true
        IMPORTING
          et_docstscfg       = lt_dunstatus_enabled.
    CATCH /idxmm/cx_config_error .
      RETURN. "No status is enable to do dunning.
  ENDTRY.

  TRY.
      CALL METHOD /idxmm/cl_customizing_access=>/idxmm/if_customizing_access~get_doc_status_config
        EXPORTING
          iv_dunning_excluded = abap_true
        IMPORTING
          et_docstscfg        = lt_dunstatus_excluded.
    CATCH /idxmm/cx_config_error .                          "#EC *
      "Do nothing
  ENDTRY.

  LOOP AT lt_dunstatus_enabled INTO ls_dunstatus_enabled.
    ls_range_status-sign = /idxgc/if_constants=>gc_sel_sign_include.
    ls_range_status-option = /idxgc/if_constants=>gc_sel_opt_equal.
    ls_range_status-low = ls_dunstatus_enabled-doc_status.
    APPEND ls_range_status TO lt_range_status.
  ENDLOOP.

  LOOP AT lt_dunstatus_excluded INTO ls_dunstatus_excluded.
    ls_range_status-sign = /idxgc/if_constants=>gc_sel_sign_include.
    ls_range_status-option = /idxgc/if_constants=>gc_sel_opt_equal.
    ls_range_status-low = ls_dunstatus_excluded-doc_status.
    APPEND ls_range_status TO lt_range_status.
    APPEND ls_range_status TO lt_range_status_excluded.
  ENDLOOP.

  TRY.
      /idxmm/cl_memi_document_db=>query_by_open_item(
        EXPORTING
          it_fica_doc_ref = lt_fica_doc_ref
          it_range_status = lt_range_status
        IMPORTING
          et_doc          = lt_memi_doc
      ).
    CATCH /idxmm/cx_bo_error.
      RETURN. "Dunning is not MeMi related
  ENDTRY.

  lt_fkkmaze = it_fkkmaze_insert[].
  SORT lt_fkkmaze BY laufd laufi gpart vkont mazae opbel opupk.
  DELETE ADJACENT DUPLICATES FROM lt_fkkmaze
    COMPARING laufd laufi gpart vkont mazae opbel opupk.

  LOOP AT lt_fkkmaze INTO ls_fkkmaze.
*    PERFORM pf_is_update_dun_level
*      USING ls_fkkmaze-opbel ls_fkkmaze-opupk
*      CHANGING lv_dun_level_upd lv_current_mahnv lv_max_dun_level.

    CLEAR ls_dun_hist_insert.
    ls_dun_hist_insert-laufd = ls_fkkmaze-laufd.
    ls_dun_hist_insert-laufi = ls_fkkmaze-laufi.
    ls_dun_hist_insert-gpart = ls_fkkmaze-gpart.
    ls_dun_hist_insert-vkont = ls_fkkmaze-vkont.
    ls_dun_hist_insert-mazae = ls_fkkmaze-mazae.

    LOOP AT lt_memi_doc INTO ls_memi_doc                 "#EC CI_NESTED
      WHERE ci_fica_doc_no EQ ls_fkkmaze-opbel
        AND opupk EQ ls_fkkmaze-opupk.

      CLEAR: ls_dun_hist.
      SELECT SINGLE * FROM /idxmm/dun_hist INTO ls_dun_hist
        WHERE laufd = ls_fkkmaze-laufd
          AND laufi = ls_fkkmaze-laufi
          AND gpart = ls_fkkmaze-gpart
          AND vkont = ls_fkkmaze-vkont
          AND mazae = ls_fkkmaze-mazae
          AND doc_id = ls_memi_doc-doc_id
          AND dunning_excluded = abap_true.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR:
        ls_dun_hist_insert-doc_id,
        ls_dun_hist_insert-doc_status,
        ls_dun_hist_insert-gross_amount,
        ls_dun_hist_insert-currency,
        ls_dun_hist_insert-opbel,
        ls_dun_hist_insert-opupk,
        ls_dun_hist_insert-dunning_excluded,
        ls_dun_hist_insert-prev_mahns,
        ls_dun_hist_insert-mahns.

      ls_dun_hist_insert-doc_id = ls_memi_doc-doc_id.
      ls_dun_hist_insert-doc_status = ls_memi_doc-doc_status.
      ls_dun_hist_insert-gross_amount = ls_memi_doc-gross_amount.
      ls_dun_hist_insert-currency = ls_memi_doc-currency.
      ls_dun_hist_insert-opbel = ls_fkkmaze-opbel.
      ls_dun_hist_insert-opupk = ls_fkkmaze-opupk.

      CLEAR ls_mloc.
      SELECT SINGLE * FROM /adz/mem_mloc INTO ls_mloc
        WHERE doc_id = ls_memi_doc-doc_id
          AND fdate LE ls_fkkmaze-ausdt
          AND tdate GE ls_fkkmaze-ausdt
          AND lvorm EQ ''.

      IF sy-subrc = 0.
        ls_dun_hist_insert-dunning_excluded = abap_true.


*      IF ls_memi_doc-doc_status IN lt_range_status_excluded.
*        ls_dun_hist_insert-dunning_excluded = abap_true.
      ELSE.
        IF lv_dun_level_upd EQ abap_true.
          " Determine previous MeMi dunning level
          PERFORM pf_det_prev_dun_level
            USING ls_memi_doc-doc_id
            CHANGING ls_dun_hist_insert-prev_mahns.

          " Determine new MeMi dunning level
          LOOP AT lt_dun_level_conf INTO ls_dun_level_conf "#EC CI_NESTED
            WHERE mahnv = lv_current_mahnv
              AND mahns GT ls_dun_hist_insert-prev_mahns.
            ls_dun_hist_insert-mahns = ls_dun_level_conf-mahns.
            EXIT.
          ENDLOOP.

          IF ls_dun_hist_insert-mahns GT lv_max_dun_level.
            ls_dun_hist_insert-mahns = lv_max_dun_level.
          ENDIF.
        ELSE.
          " Determine previous MeMi dunning level
          PERFORM pf_det_prev_dun_level
           USING ls_memi_doc-doc_id
            CHANGING ls_dun_hist_insert-prev_mahns.

          ls_dun_hist_insert-mahns = ls_dun_hist_insert-prev_mahns.

          IF ls_dun_hist_insert-mahns GT lv_max_dun_level.
            ls_dun_hist_insert-mahns = lv_max_dun_level.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND ls_dun_hist_insert TO lt_dun_hist_insert.
    ENDLOOP.
  ENDLOOP.

  IF lt_dun_hist_insert IS NOT INITIAL.
    TRY .

        CALL METHOD /idxmm/cl_dunning_history_db=>update
          EXPORTING
            it_dun_hist_update = lt_dun_hist_insert.

      CATCH /idxmm/cx_bo_error.
        MESSAGE e001(/idxmm/bo) WITH /idxmm/if_constants=>gc_tabname_dun_hist. "#EC *
    ENDTRY.
  ENDIF.

  PERFORM pf_update_memi_dun_level TABLES lt_memi_doc lt_dun_hist_insert.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PF_UPDATE_MEMI_DUN_LEVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_MEMI_DOC  text
*      -->P_LT_DUN_HIST_INSERT  text
*----------------------------------------------------------------------*
FORM pf_update_memi_dun_level  TABLES   it_memi_doc TYPE STANDARD TABLE
                                        it_dun_hist_insert TYPE STANDARD TABLE.

  DATA:
    lt_memi_doc_key    TYPE /idxmm/t_doc_key,
    lt_memi_doc        TYPE /idxmm/t_memi_doc,
    lt_dun_hist_insert TYPE /idxmm/t_dun_hist,
    ls_dun_hist_insert TYPE /idxmm/dun_hist,
    lr_memi_doc        TYPE REF TO /idxmm/if_memi_document.

  FIELD-SYMBOLS:
    <fs_memi_doc> TYPE /idxmm/memidoc.

  lt_dun_hist_insert = it_dun_hist_insert[].
  MOVE-CORRESPONDING it_memi_doc[] TO lt_memi_doc_key.

  TRY.
      CALL METHOD /idxmm/cl_memi_document=>get_instance
        EXPORTING
          it_doc_key = lt_memi_doc_key
          iv_mode    = cl_isu_wmode=>co_change
        IMPORTING
          et_doc     = lt_memi_doc
        RECEIVING
          rr_doc     = lr_memi_doc.

      LOOP AT lt_memi_doc ASSIGNING <fs_memi_doc>.
        READ TABLE lt_dun_hist_insert INTO ls_dun_hist_insert
          WITH KEY doc_id = <fs_memi_doc>-doc_id.
        IF sy-subrc EQ 0.
          IF ls_dun_hist_insert-dunning_excluded NE abap_true.
            <fs_memi_doc>-dunning_level = ls_dun_hist_insert-mahns.
          ENDIF.
        ENDIF.
      ENDLOOP.

      lr_memi_doc->update( lt_memi_doc ).
      lr_memi_doc->close( ).
    CATCH /idxmm/cx_bo_error.
      IF lr_memi_doc IS BOUND.
        lr_memi_doc->close( ).
      ENDIF.
      MESSAGE e001(/idxmm/bo) WITH /idxmm/if_constants=>gc_tabname_memidoc. "#EC *
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_DET_PREV_DUN_LEVEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pf_det_prev_dun_level USING iv_doc_id
                           CHANGING cv_prev_mahns.

  DATA:
    lt_select_cond   TYPE /idxmm/t_select_cond,
    ls_select_cond   TYPE /idxmm/s_select_cond,
    ls_range         TYPE isu_ranges,
    lt_prev_dun_hist TYPE /idxmm/t_dun_hist,
    ls_prev_dun_hist TYPE /idxmm/dun_hist.

  CLEAR cv_prev_mahns.

  CLEAR: ls_select_cond, ls_range.
  ls_range-sign = /idxgc/if_constants=>gc_sel_sign_include.
  ls_range-option = /idxgc/if_constants=>gc_sel_opt_equal.
  ls_range-low = iv_doc_id.
  APPEND ls_range TO ls_select_cond-range_tab.

  ls_select_cond-fieldname = /idxmm/if_constants=>gc_fname_doc_id.
  APPEND ls_select_cond TO lt_select_cond.

  CLEAR: ls_select_cond, ls_range.
  ls_range-sign = /idxgc/if_constants=>gc_sel_sign_include.
  ls_range-option = /idxgc/if_constants=>gc_sel_opt_not_equal.
  ls_range-low = abap_true.
  APPEND ls_range TO ls_select_cond-range_tab.

  ls_select_cond-fieldname = /idxmm/if_constants=>gc_fname_dunning_excluded.
  APPEND ls_select_cond TO lt_select_cond.

  ls_select_cond-fieldname = /idxmm/if_constants=>gc_fname_xmsto.
  APPEND ls_select_cond TO lt_select_cond.

  TRY .
      /idxmm/cl_dunning_history_db=>select(
          EXPORTING
            it_select_cond     = lt_select_cond
          IMPORTING
            et_dun_hist        = lt_prev_dun_hist ).

      SORT lt_prev_dun_hist BY mahns DESCENDING.
      READ TABLE lt_prev_dun_hist INTO ls_prev_dun_hist INDEX 1.
      cv_prev_mahns = ls_prev_dun_hist-mahns.

    CATCH /idxmm/cx_bo_error. "#EC *
      "Do nothing
  ENDTRY.

ENDFORM.
