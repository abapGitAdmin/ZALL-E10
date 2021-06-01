interface /ADZ/IF_MDC_PRO_CHG
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_AUTO
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
      !IS_PROC_STEP_DATA_SRC type /IDXGC/S_PROC_STEP_DATA_ALL optional
    raising
      /IDXGC/CX_UTILITY_ERROR .
  methods CHANGE_MANUAL
    importing
      !IS_PROC_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      /IDXGC/CX_UTILITY_ERROR .
endinterface.
