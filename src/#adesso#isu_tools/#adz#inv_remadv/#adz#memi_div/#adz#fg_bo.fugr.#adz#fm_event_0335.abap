FUNCTION /ADZ/FM_EVENT_0335.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(PARA_0300) TYPE  FKKMA_0300
*"     REFERENCE(I_GPART) TYPE  GPART_KK
*"     REFERENCE(I_VKONT) TYPE  VKONT_KK OPTIONAL
*"  TABLES
*"      I_FKKMAVS STRUCTURE  FKKMAVS
*"      I_FKKMAGRP STRUCTURE  FKKMAGRP
*"      C_FKKMARED STRUCTURE  FKKMARED
*"      E_FIMSG STRUCTURE  FIMSG
*"--------------------------------------------------------------------
  DATA:
    ls_fkkmavs       TYPE fkkmavs,
    ls_docstscfg     TYPE /idxmm/docstscfg,
    lt_docstscfg     TYPE /idxmm/t_docstscfg,
    ls_memi_doc      TYPE /idxmm/memidoc,
    lt_memi_doc      TYPE /idxmm/t_memi_doc,
    ls_fica_doc_ref  TYPE /idxmm/s_fica_doc_ref,
    lt_fica_doc_ref  TYPE /idxmm/t_fica_doc_ref,
    ls_range_status  TYPE isu_ranges,
    lt_range_status  TYPE isu_ranges_tab,
    lv_sum_reduction TYPE /idxmm/de_gross_amount,
    ls_reduction     TYPE fkkmared,
    lv_group_count   TYPE i,
    ls_msg           TYPE fimsg.

  DATA: ls_mloc TYPE /adz/mem_mloc.

  CLEAR lt_range_status[].

* select by posting document to be dunned
  LOOP AT i_fkkmavs INTO ls_fkkmavs.
    ls_fica_doc_ref-ci_fica_doc_no = ls_fkkmavs-opbel.
    ls_fica_doc_ref-opupk = ls_fkkmavs-opupk.
    "ls_fica_doc_ref-psgrp = ls_fkkmavs-psgrp.
    APPEND ls_fica_doc_ref TO lt_fica_doc_ref.
  ENDLOOP.

* Get document statuses that are dunning excluded from configuration
*   wait for outgoing payment: this should not be excluded because the open items are not selected by FICA
  TRY.
      CALL METHOD /idxmm/cl_customizing_access=>/idxmm/if_customizing_access~get_doc_status_config
        EXPORTING
          iv_dunning_excluded = abap_false
        IMPORTING
          et_docstscfg        = lt_docstscfg.
    CATCH /idxmm/cx_config_error .
      "No document should be excluded from dunning.
      RETURN.
  ENDTRY.

  LOOP AT lt_docstscfg INTO ls_docstscfg.
    ls_range_status-sign = /idxgc/if_constants=>gc_sel_sign_include.
    ls_range_status-option = /idxgc/if_constants=>gc_sel_opt_equal.
    ls_range_status-low = ls_docstscfg-doc_status.
    APPEND ls_range_status TO lt_range_status.
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
      "No document should be excluded from dunning.
      RETURN.
  ENDTRY.

* sum up gross amount of excluded MeMi documents
* actually we could ask the DB to compute the SUM so that only the SUM is returned from the DB and not all MeMI docs
* but for testing purposes I do a loop now
* only those for the FICA posting document number and OPUPK should be summed up

* Belege ausschließen, die über HMV oder Reklamationsmanager erfolgt sind
  LOOP AT lt_memi_doc INTO ls_memi_doc. "USING KEY open_item
    CLEAR ls_mloc.
    SELECT SINGLE * FROM /adz/mem_mloc INTO ls_mloc
    WHERE doc_id = ls_memi_doc-doc_id
      AND fdate LE para_0300-ausdt
      AND tdate GE para_0300-ausdt
      AND lvorm EQ ''.


    IF sy-subrc = 0.

      lv_sum_reduction = lv_sum_reduction + ls_memi_doc-gross_amount.
      ls_msg-msgid = '/ADZ/MEMI'.
      ls_msg-msgty = 'I'.
      ls_msg-msgno = 112.
      ls_msg-msgv1 = ls_memi_doc-doc_id.
      ls_msg-msgv2 = ls_memi_doc-doc_status.
      APPEND ls_msg TO e_fimsg.
    ENDIF.
  ENDLOOP.

* Check that there is only one group
  DESCRIBE TABLE i_fkkmagrp LINES lv_group_count.
  IF lv_group_count <> 1.
    MESSAGE e105(/idxmm/bo).
  ENDIF.

* create a line with the sum in C_FKKMARED
* MGRPX darf nicht aufsummiert werden.
  READ TABLE c_fkkmared WITH KEY mgrpx = 1.
  IF sy-subrc NE 0.
    ls_reduction-mgrpx = 1.
  ELSE.
    CLEAR ls_reduction-mgrpx.
  ENDIF.
  ls_reduction-betrw = lv_sum_reduction.
  ls_reduction-waers = /idxmm/if_constants=>gc_currency_eur.

  COLLECT ls_reduction INTO c_fkkmared.

ENDFUNCTION.
