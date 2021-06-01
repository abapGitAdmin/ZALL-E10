interface /ADESSO/IF_MDC_COMPARE_STEPS
  public .


  interfaces IF_BADI_INTERFACE .

  methods COMPARE_PROC_STEP_DATA
    importing
      value(IS_PROC_STEP_DATA_1) type /IDXGC/S_PROC_STEP_DATA
      !IS_PROC_STEP_DATA_2 type /IDXGC/S_PROC_STEP_DATA
    changing
      !CT_MTD_CODE_RESULT type /IDXGC/T_MTD_CODE_DETAILS
    raising
      /IDXGC/CX_GENERAL .
endinterface.
