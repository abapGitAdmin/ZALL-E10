interface /ADESSO/IF_MDC_DP_OUT
  public .


  interfaces /IDXGC/IF_DP_OUT .

  methods CALL_METHOD
    importing
      !IS_BMID_CONFIG type /IDXGC/BMID_CONF
    changing
      value(CS_PROCESS_STEP_DATA) type /IDXGC/S_PROC_STEP_DATA_ALL
    raising
      CX_SY_DYN_CALL_ILLEGAL_METHOD
      /IDXGC/CX_PROCESS_ERROR .
  methods SET_PROCESS_STEP_DATA
    importing
      !IS_PROCESS_STEP_DATA type /IDXGC/S_PROC_STEP_DATA_ALL .
endinterface.
