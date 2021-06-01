class /ADESSO/CL_BPU_IM_BADI_EC definition
  public
  create public .

public section.

  interfaces IF_BADI_EMMA_CASE .
  interfaces IF_BADI_INTERFACE .

  class-data GR_BPU_EMMA_CASE type ref to /ADESSO/CL_BPU_EMMA_CASE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPU_IM_BADI_EC IMPLEMENTATION.


  METHOD if_badi_emma_case~transaction_start.
    DATA: ls_check_list_result TYPE /idxgc/s_check_list_result,
          ls_case              TYPE emma_case,
          ls_cust_gen          TYPE /adesso/bpu_s_gen,
          lv_wmode             TYPE emma_ctxn_wmode,
          lv_start_screen      TYPE /adesso/bpu_start_screen.


***** Initialiserung (Customizing lesen, Status lesen) ********************************************
    TRY.
        ls_cust_gen = /adesso/cl_bpu_customizing=>get_cust_gen( ).
        gr_bpu_emma_case = /adesso/cl_bpu_emma_case=>get_instance( iv_casenr = iv_casenr ).
        ls_case = gr_bpu_emma_case->get_case( iv_skip_buffer = abap_true ).
      CATCH /idxgc/cx_general.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDTRY.


***** Modus (Ändern / Anzeigen) bei der Klärfallanzeige setzen ************************************
    IF iv_wmode = cl_emma_case_txn=>co_wmode_display OR iv_wmode = cl_emma_case_txn=>co_wmode_change.
      CASE sy-tcode.
        WHEN /adesso/if_bpu_co=>gc_tcode_emmacl.
          lv_wmode = ls_cust_gen-wmode_start_emmacl.
        WHEN /adesso/if_bpu_co=>gc_tcode_emmacls.
          lv_wmode = ls_cust_gen-wmode_start_emmacls.
      ENDCASE.
    ENDIF.

    IF lv_wmode IS INITIAL.
      lv_wmode = iv_wmode.
    ENDIF.


***** Direktes Ausführen von Lösungsmethoden ******************************************************
    IF ls_case-mainobjtype = /idxgc/if_constants=>gc_object_pdoc_bor. "Nur für Klärfälle zu Prozessdokumenten
      "Nur im Änderungsmodus und wenn BPEM-Fall noch nicht abgeschlossen ist
      IF lv_wmode = cl_emma_case_txn=>co_wmode_change AND ( ls_case-status = cl_emma_case=>co_status_new OR ls_case-status = cl_emma_case=>co_status_inproc ).
        TRY.
            ls_check_list_result = /adesso/cl_bpu_utility=>det_auto_exec_check_result( iv_casenr = iv_casenr ).
            IF ls_check_list_result IS NOT INITIAL.
              gr_bpu_emma_case->execute_solving_method( is_check_list_result = ls_check_list_result ).
            ELSE.
              gr_bpu_emma_case->set_start_transaction_flag( iv_start_transaction_flag = abap_true ).
            ENDIF.

          CATCH /idxgc/cx_general.
            "Bei Fehler Transaktion normal starten
            gr_bpu_emma_case->set_start_transaction_flag( iv_start_transaction_flag = abap_true ).
        ENDTRY.
      ENDIF.
    ENDIF.


***** Startbild setzen ****************************************************************************
    GET PARAMETER ID /adesso/if_bpu_co=>gc_param_id_emma_start_screen FIELD lv_start_screen.
    IF lv_start_screen IS INITIAL.
      SET PARAMETER ID /adesso/if_bpu_co=>gc_param_id_emma_start_screen FIELD ls_cust_gen-start_screen.
    ENDIF.

***** Klärungsfall aufrufen ***********************************************************************
    IF gr_bpu_emma_case->get_start_transaction_flag( ) = abap_true.
      gr_bpu_emma_case->clear_seqnr_to_excecute( ).
      CALL FUNCTION 'EMMA_CASE_TRANSACTION_START'
        EXPORTING
          iv_casenr                = iv_casenr
          iv_ccat                  = iv_ccat
          iv_template_case         = iv_template_case
          iv_wmode                 = lv_wmode
          iv_allow_toggle_dispchan = iv_allow_toggle_dispchan
          iv_next_prev_case        = iv_next_prev_case
        IMPORTING
          ev_casenr                = ev_casenr
          ev_okcode                = ev_okcode
        EXCEPTIONS
          case_not_found           = 1
          incorrect_workmode       = 2
          incorrect_parameters     = 3.
      CASE sy-subrc.
        WHEN 1.
          RAISE case_not_found.
        WHEN 2.
          RAISE incorrect_workmode.
        WHEN 3.
          RAISE incorrect_parameters.
      ENDCASE.
    ELSE.
      gr_bpu_emma_case->set_start_transaction_flag( iv_start_transaction_flag = abap_true ).
      gr_bpu_emma_case->clear_seqnr_to_excecute( ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
