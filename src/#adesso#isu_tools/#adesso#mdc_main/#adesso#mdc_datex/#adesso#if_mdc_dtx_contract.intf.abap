interface /ADESSO/IF_MDC_DTX_CONTRACT
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA
    importing
      !IS_EVER_OLD type EVER
      !IS_EVER_NEW type EVER
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IS_EVER_OLD type EVER
      !IS_EVER_NEW type EVER
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      value(CV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
