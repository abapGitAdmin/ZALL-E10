FUNCTION /ADZ/MDC_SHOW_DISPLAY.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IS_PROCESS_STEP_KEY) TYPE  /IDXGC/S_PROC_STEP_KEY
*"----------------------------------------------------------------------
  DATA: ls_proc_step_data TYPE /idxgc/s_proc_step_data,
        ls_proc_step_key  TYPE /idxgc/s_proc_step_key,
        ls_proc_config    TYPE /idxgc/s_proc_config_all.

  FIELD-SYMBOLS: <fs_proc_step_config> TYPE /idxgc/s_proc_step_config_all.

  TRY.
*IR---> Übernahme aus dem adesso-Paket: BAdI entfernt
*      TRY.
*          GET BADI gr_badi_mdc_pro_show_disp
*            FILTERS
*              mandt = sy-mandt
*              sysid = sy-sysid.
*        CATCH cx_badi_not_implemented cx_badi_multiply_implemented cx_badi_unknown_error cx_badi_initial_context cx_badi_filter_error cx_badi_context_error.
*          FREE gr_badi_mdc_pro_show_disp.
*      ENDTRY.

      gs_proc_step_key  = is_process_step_key.
      gr_ctx            = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = is_process_step_key-proc_ref ).
      gs_proc_step_data = gr_ctx->gr_process_data_extern->get_process_step_data( gs_proc_step_key ).

      "Zusätzlichen Quellschritt lesen. Dieser enthält die eigentlichen Nachrichtendaten.
      TRY.
          /idxgc/cl_cust_access=>/idxgc/if_cust_access~get_process_config( EXPORTING iv_process_id = gs_proc_step_data-proc_id
                                                                           IMPORTING es_process_config = ls_proc_config ).
        CATCH /idxgc/cx_config_error.
          "Daten werden für automatische Verbuchung gebraucht. Bei Fehler muss manuell verbucht werden.
      ENDTRY.

      READ TABLE ls_proc_config-steps ASSIGNING <fs_proc_step_config> WITH KEY proc_step_no = gs_proc_step_key-proc_step_no.
      IF sy-subrc = 0.
        ls_proc_step_key-proc_id  = is_process_step_key-proc_id.
        IF <fs_proc_step_config>-step_no_src_add IS NOT INITIAL.
          ls_proc_step_key-proc_step_no = <fs_proc_step_config>-step_no_src_add.
          TRY.
              gs_proc_step_data_src_add = gr_ctx->gr_process_data_extern->get_process_step_data( ls_proc_step_key ).
            CATCH /idxgc/cx_process_error.
              "Daten werden für automatische Verbuchung gebraucht. Bei Fehler muss manuell verbucht werden.
          ENDTRY.
        ENDIF.
      ENDIF.

      FREE: gr_grid, gr_custom_container.
      CALL SCREEN '9000' STARTING AT 19 9.

      gr_ctx->close( ).

* Schrittdaten aktualisieren
      gr_ctx = /idxgc/cl_pd_doc_context=>get_instance( iv_pdoc_no = is_process_step_key-proc_ref
                                                       iv_wmode = cl_isu_wmode=>co_change ).
      ls_proc_step_data-step2    = gs_proc_step_data-step.
      ls_proc_step_data-proc_ref = gs_proc_step_data-proc_ref.
      gr_ctx->update_proc_steps( is_proc_step_data = ls_proc_step_data ).
      gr_ctx->close_and_save( ).

    CATCH /idxgc/cx_process_error.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDTRY.
ENDFUNCTION.
