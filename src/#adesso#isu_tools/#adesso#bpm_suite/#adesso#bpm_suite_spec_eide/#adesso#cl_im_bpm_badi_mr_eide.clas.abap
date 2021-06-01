class /ADESSO/CL_IM_BPM_BADI_MR_EIDE definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_BPM_MULTIRULE .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_IM_BPM_BADI_MR_EIDE IMPLEMENTATION.


  METHOD /adesso/if_bpm_multirule~solve_rule.
    "******************************************************************************************
    "Implementierung der Bearbeiterfindung im Bereich des Datenaustausches (Common-Layer usw.)
    "******************************************************************************************

    DATA: lr_ctx              TYPE REF TO /idxgc/cl_pd_doc_context,
          lr_bpm_sb_find_eide TYPE REF TO /adesso/cl_bpm_fill_cont_eide,
          lr_pdoc             TYPE swc_object,
          lv_proc_ref         TYPE  /idxgc/de_proc_ref,
          lv_proc_id          TYPE  /idxgc/de_proc_id,
          lv_proc_step_ref    TYPE  /idxgc/de_proc_step_ref,
          lv_proc_step_no     TYPE  /idxgc/de_proc_step_no,
          lv_exceptioncode    TYPE  /idxgc/de_excp_code,
          lv_ccat             TYPE emma_ccat,
          ls_gen_cust         TYPE /adesso/bpm_gen.

    swc_get_element it_container_multirule 'PROZESSDOKUMENT' lr_pdoc.
    swc_get_property lr_pdoc 'SwitchNum' lv_proc_ref.

    swc_get_element it_container_multirule 'PROCESSID' lv_proc_id.
    swc_get_element it_container_multirule 'PROCSTEPREF' lv_proc_step_ref.
    swc_get_element it_container_multirule 'PROCSTEPNO' lv_proc_step_no.
    swc_get_element it_container_multirule 'EXCEPTIONCODE' lv_exceptioncode.
    swc_get_element it_container_multirule 'CCAT' lv_ccat.

    TRY.
        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = lv_proc_ref iv_wmode = cl_isu_wmode=>co_display ).

        TRY.
            ls_gen_cust = /adesso/cl_bpm_utility=>det_gen_cust( iv_bparea = /adesso/cl_bpm_utility=>det_bparea( iv_ccat = lv_ccat ) ).
            CREATE OBJECT lr_bpm_sb_find_eide TYPE (ls_gen_cust-ad_bpm_dp_cl_rul)
              EXPORTING
                iv_proc_step_ref = lv_proc_step_ref
                iv_proc_step_no  = lv_proc_step_no
                iv_proc_ref      = lv_proc_ref
                ir_ctx           = lr_ctx
                iv_ccat          = lv_ccat
                iv_proc_id       = lv_proc_id
                iv_exceptioncode = lv_exceptioncode.

            lr_bpm_sb_find_eide->execute( ).

            lr_bpm_sb_find_eide->get_class_attribute( EXPORTING iv_attribute = 'AT_ACTORS'
                                                      IMPORTING et_attribute = rt_actors ).

            lr_ctx->close( ).

          CATCH /adesso/cx_bpm_general.
            lr_ctx->close( ).
        ENDTRY.
      CATCH /idxgc/cx_process_error /idxgc/cx_general.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
