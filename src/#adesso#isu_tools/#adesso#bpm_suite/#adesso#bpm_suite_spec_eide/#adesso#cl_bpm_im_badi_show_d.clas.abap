class /ADESSO/CL_BPM_IM_BADI_SHOW_D definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_MDC_PRO_SHOW_DISP .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPM_IM_BADI_SHOW_D IMPLEMENTATION.


  METHOD /adesso/if_mdc_pro_show_disp~btn5_action.
    /adesso/cl_bpm_exe_proc_eide=>av_seqnr_to_exc_bpem_proc = '001'.
    /adesso/cl_bpm_exe_proc_eide=>av_no_transaction_start = abap_true.
  ENDMETHOD.


  METHOD /adesso/if_mdc_pro_show_disp~btn6_action.
    /adesso/cl_bpm_exe_proc_eide=>av_seqnr_to_exc_bpem_proc = '001'.
    /adesso/cl_bpm_exe_proc_eide=>av_no_transaction_start = abap_true.
  ENDMETHOD.


  METHOD /adesso/if_mdc_pro_show_disp~btn7_action.
    /adesso/cl_bpm_exe_proc_eide=>av_seqnr_to_exc_bpem_proc = '001'.
    /adesso/cl_bpm_exe_proc_eide=>av_no_transaction_start = abap_true.
  ENDMETHOD.
ENDCLASS.
