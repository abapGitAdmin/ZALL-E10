class /ADESSO/CL_MDC_IM_PRO_UISETTL definition
  public
  create public .

public section.

  interfaces /ADESSO/IF_MDC_PRO_CHG .
  interfaces IF_BADI_INTERFACE .
protected section.

  class-data GR_PREVIOUS type ref to CX_ROOT .
  class-data GV_MTEXT type STRING .

  methods SET_UISETTL_DATA
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      /IDXGC/CX_GENERAL .
private section.
ENDCLASS.



CLASS /ADESSO/CL_MDC_IM_PRO_UISETTL IMPLEMENTATION.


  method /ADESSO/IF_MDC_PRO_CHG~CHANGE_AUTO.
  endmethod.


  METHOD /adesso/if_mdc_pro_chg~change_manual.

    CALL FUNCTION '/ADESSO/MDC_CHANGE_UISETTL' STARTING NEW TASK 'MDC_CHANGE_UISETTL'
      EXPORTING
        is_proc_step_data = is_proc_step_data.

  ENDMETHOD.


  method SET_UISETTL_DATA.
  endmethod.
ENDCLASS.
