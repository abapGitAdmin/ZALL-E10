class /ADESSO/CL_IM_BPM_CO_CA_EIDE definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_BPM_COMPL_CASE .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_IM_BPM_CO_CA_EIDE IMPLEMENTATION.


  METHOD /adesso/if_bpm_compl_case~complete_case.
    DATA: lr_ctx               TYPE REF TO /idxgc/cl_pd_doc_context,
          lr_bpm_find_obj_eide TYPE REF TO /adesso/cl_bpm_fill_cont_eide,
          lv_proc_id           TYPE /idxgc/de_proc_id,
          lv_proc_ref          TYPE /idxgc/de_proc_ref,
          lv_proc_step_ref     TYPE /idxgc/de_proc_step_ref,
          lv_proc_step_no      TYPE /idxgc/de_proc_step_no,
          lv_exceptioncode     TYPE /idxgc/de_excp_code,
          ls_gen_cust          TYPE /adesso/bpm_gen,
          lt_proc_step_data	   TYPE /idxgc/t_proc_step_data.


    FIELD-SYMBOLS: <fs_object>         LIKE LINE OF it_objects,
                   <fs_proc_step_data> LIKE LINE OF lt_proc_step_data,
                   <fs_diverse_data>   TYPE /idxgc/s_diverse_details.

    TRY.
        lv_proc_ref = is_case-mainobjkey.

        lr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = lv_proc_ref iv_wmode = cl_isu_wmode=>co_display ).

        LOOP AT it_objects ASSIGNING <fs_object>.
          CASE <fs_object>-celemname.
            WHEN /idxgc/if_constants_ddic=>gc_bor_param_proc_step_ref.
              lv_proc_step_ref = <fs_object>-id.
            WHEN /idxgc/if_constants_ddic=>gc_bor_param_proc_step_no.
              lv_proc_step_no = <fs_object>-id.
            WHEN /idxgc/if_constants_ddic=>gc_bor_param_proc_id.
              lv_proc_id = <fs_object>-id.
            WHEN /idxgc/if_constants_ddic=>gc_bor_param_exception_code.
              lv_exceptioncode = <fs_object>-id.
          ENDCASE.
        ENDLOOP.

        "Individuelle Objekte am Klärungsfall erzeugen
        TRY.
            ls_gen_cust = /adesso/cl_bpm_utility=>det_gen_cust( iv_bparea = /adesso/cl_bpm_utility=>det_bparea( iv_ccat = iv_ccat ) ).
            CREATE OBJECT lr_bpm_find_obj_eide TYPE (ls_gen_cust-ad_bpm_dp_cl_obj)
              EXPORTING
                iv_proc_step_ref = lv_proc_step_ref
                iv_proc_step_no  = lv_proc_step_no
                iv_proc_ref      = lv_proc_ref
                ir_ctx           = lr_ctx
                iv_ccat          = iv_ccat
                iv_proc_id       = lv_proc_id
                iv_exceptioncode = lv_exceptioncode.

            lr_bpm_find_obj_eide->execute( ).

            lr_bpm_find_obj_eide->get_class_attribute( EXPORTING iv_attribute = 'AT_BPM_CONT'
                                                       IMPORTING et_attribute = et_objects ).

          CATCH /adesso/cx_bpm_general /adesso/cx_bpm_utility.
            lr_ctx->close( ).
        ENDTRY.

        lr_ctx->get_proc_step_data( IMPORTING et_proc_step_data = lt_proc_step_data ).
        LOOP AT lt_proc_step_data ASSIGNING <fs_proc_step_data> WHERE diverse IS NOT INITIAL.
          READ TABLE <fs_proc_step_data>-diverse ASSIGNING <fs_diverse_data> INDEX 1.
          IF <fs_diverse_data>-msgtransreason IS NOT INITIAL.
            ev_custfields-zz_msgtransreason = <fs_diverse_data>-msgtransreason.
            EXIT.
          ENDIF.
        ENDLOOP.
        ev_custfields-zz_proc_id = lv_proc_id.
      CATCH /idxgc/cx_process_error /idxgc/cx_general.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
