interface /ADESSO/IF_MDC_DTX_BILLINGINST
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA
    importing
      !IS_CHANGED_DATA type ISUID_BILLINGINST_CHANGED
      !IS_OLD_DATA type ISUID_BILLINGINST_CHANGED
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IS_CHANGED_DATA type ISUID_BILLINGINST_CHANGED
      !IS_OLD_DATA type ISUID_BILLINGINST_CHANGED
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      value(CV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
