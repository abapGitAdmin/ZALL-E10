FUNCTION /ADZ/FM_GET_MEMIDOC_TO_DUN.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     REFERENCE(ET_MEMIDOC) TYPE  /IDXMM/T_MEMI_DOC
*"  TABLES
*"      T_FKKOP STRUCTURE  FKKOP
*"--------------------------------------------------------------------
*Anpasung : Auch Gutschriften sollen im Mahnvorschlag angezeigt werden
  DATA:
    ls_doc_status_range TYPE /idxmm/s_doc_status_range,
    lt_doc_status_range TYPE /idxmm/t_doc_status_range,
    ls_docstscfg        TYPE /idxmm/docstscfg,
    lt_docstscfg        TYPE STANDARD TABLE OF /idxmm/docstscfg.

  IF t_fkkop[] IS INITIAL.
    RETURN.
  ENDIF.

* Get document statuses that are dunning enabled from configuration
  TRY.
      CALL METHOD /idxmm/cl_customizing_access=>/idxmm/if_customizing_access~get_doc_status_config
        EXPORTING
          iv_dunning_enabled = abap_true
        IMPORTING
          et_docstscfg       = lt_docstscfg.
    CATCH /idxmm/cx_config_error .
* No document status is dunning enabled, we can just return.
      RETURN.
  ENDTRY.
  ls_doc_status_range-sign   = /idxgc/if_constants=>gc_sel_sign_include.
  ls_doc_status_range-option = /idxgc/if_constants=>gc_sel_opt_equal.
  LOOP AT lt_docstscfg INTO ls_docstscfg.
    ls_doc_status_range-low = ls_docstscfg-doc_status.
    APPEND ls_doc_status_range TO lt_doc_status_range.
  ENDLOOP.

  SELECT * FROM /idxmm/memidoc
    INTO TABLE et_memidoc
    FOR ALL ENTRIES IN t_fkkop
    WHERE doc_status IN lt_doc_status_range " Only dunning-enabled statuses should be considered
      AND simulation = space
     " AND gross_amount > 0
      AND ci_fica_doc_no = t_fkkop-opbel
      AND opupk = t_fkkop-opupk.



ENDFUNCTION.
