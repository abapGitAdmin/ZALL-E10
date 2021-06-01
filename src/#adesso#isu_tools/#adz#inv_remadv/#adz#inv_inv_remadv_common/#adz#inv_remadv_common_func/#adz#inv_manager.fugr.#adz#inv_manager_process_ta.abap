FUNCTION /adz/inv_manager_process_ta .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IT_INV_DOC_NR) TYPE  TINV_INT_INV_DOC_NO
*"  CHANGING
*"     VALUE(PROCESS_DOCUMENT) TYPE  /ADZ/MANAGER_PROZ_COLLECT_T
*"----------------------------------------------------------------------

  DATA: lv_inv_doc_nr       TYPE inv_int_inv_doc_no,
        ls_process_document TYPE /adz/manager_proz_collect_s.

  LOOP AT it_inv_doc_nr INTO lv_inv_doc_nr.

    ls_process_document-int_inv_doc_no = lv_inv_doc_nr.

    CALL METHOD cl_inv_inv_remadv_doc=>process_document
      EXPORTING
        im_doc_number          = lv_inv_doc_nr
      IMPORTING
        ex_return              = ls_process_document-ex_return
        ex_exit_process_type   = ls_process_document-ex_exit_process_type
        ex_proc_error_occurred = ls_process_document-ex_proc_error_occurred
      EXCEPTIONS
        OTHERS                 = 1.


    APPEND ls_process_document TO process_document.
  ENDLOOP.



ENDFUNCTION.
