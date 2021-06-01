interface /ADESSO/IF_MDC_DTX_LPASS
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA_LPASS
    importing
      !IS_OLD_DATA type ISULP_LPASSLIST_DATA
      !IS_NEW_DATA type ISULP_LPASSLIST_DATA
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IS_OLD_DATA type ISULP_LPASSLIST_DATA
      !IS_NEW_DATA type ISULP_LPASSLIST_DATA
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      value(CV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
