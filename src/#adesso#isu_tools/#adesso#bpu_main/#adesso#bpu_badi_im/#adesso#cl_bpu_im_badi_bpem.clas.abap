class /ADESSO/CL_BPU_IM_BADI_BPEM definition
  public
  inheriting from /IDXGC/CL_DEF_BADI_BPEM
  create public .

public section.

  methods /IDXGC/IF_DEF_BADI_BPEM~CHECK_IF_BPEM_TO_BE_CLOSED
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS /ADESSO/CL_BPU_IM_BADI_BPEM IMPLEMENTATION.


  METHOD /idxgc/if_def_badi_bpem~check_if_bpem_to_be_closed.
    super->/idxgc/if_def_badi_bpem~check_if_bpem_to_be_closed( EXPORTING is_ccat_sop     = is_ccat_sop
                                                                         iv_mainobjkey   = iv_mainobjkey
                                                               IMPORTING ev_closing_flag = ev_closing_flag ).

    IF ev_closing_flag = abap_false.
      /adz/cl_bdr_utility=>check_if_bpem_to_be_closed( EXPORTING is_ccat_sop     = is_ccat_sop
                                                                 iv_mainobjkey   = iv_mainobjkey
                                                       IMPORTING ev_closing_flag = ev_closing_flag ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
