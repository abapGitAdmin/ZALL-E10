*****           Implementation of object type /ADZ/BDR_D           *****
INCLUDE <object>.
begin_data object. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
  " begin of private,
  "   to declare private attributes remove comments and
  "   insert private attributes here ...
  " end of private,
  BEGIN OF key,
    switchnum LIKE eideswtdoc-switchnum,
  END OF key.
end_data object. " Do not change.. DATA is generated


begin_method executesolvingmethod changing container.
DATA: lr_ctx               TYPE REF TO /idxgc/cl_pd_doc_context,
      lx_previous          TYPE REF TO /idxgc/cx_general,
      ls_check_list_result TYPE /idxgc/s_check_list_result,
      ls_proc_step_data    TYPE /idxgc/s_proc_step_data,
      lv_proc_step_ref     TYPE /idxgc/prst_amid-proc_step_ref,
      lv_exception_code    TYPE /idxgc/de_excp_code,
      lv_addinfo           TYPE /idxgc/de_add_info.

FIELD-SYMBOLS: <ls_check>      TYPE /idxgc/s_check_details.

swc_get_element container 'IV_PROC_STEP_REF'  lv_proc_step_ref.
swc_get_element container 'IV_EXCEPTION_CODE' lv_exception_code.
swc_get_element container 'IV_ADDINFO'        lv_addinfo.

TRY.
    lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no     = object-key-switchnum
                                                     iv_wmode       = cl_isu_wmode=>co_display
                                                     iv_skip_buffer = abap_true ).
  CATCH /idxgc/cx_process_error.
    MESSAGE ID sy-msgid  TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDTRY.

TRY.
    lr_ctx->get_proc_step_data( EXPORTING iv_proc_step_ref  = lv_proc_step_ref
                                IMPORTING es_proc_step_data = ls_proc_step_data ).
  CATCH /idxgc/cx_process_error INTO lx_previous.
    TRY.
        lr_ctx->close( ).
      CATCH /idxgc/cx_process_error.
        MESSAGE ID sy-msgid  TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        RETURN.
    ENDTRY.
    MESSAGE ID sy-msgid  TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
ENDTRY.

LOOP AT ls_proc_step_data-check ASSIGNING <ls_check> WHERE exception_code = lv_exception_code
  AND excp_solving_cls IS NOT INITIAL AND excp_solving_mtd IS NOT INITIAL.
  ls_check_list_result               = CORRESPONDING #( <ls_check> ).
  ls_check_list_result-proc_ref      = ls_proc_step_data-proc_ref.
  ls_check_list_result-proc_step_ref = ls_proc_step_data-proc_step_ref.
  ls_check_list_result-addinfo       = lv_addinfo.
  TRY.
      /idxgc/cl_check_list_result=>use_cl_2_solve_exception( is_check_list_result = ls_check_list_result ).
    CATCH /idxgc/cx_utility_error.
      MESSAGE ID sy-msgid  TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDTRY.
ENDLOOP.
end_method.
