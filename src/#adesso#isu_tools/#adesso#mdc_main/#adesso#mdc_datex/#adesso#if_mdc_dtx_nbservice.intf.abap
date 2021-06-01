interface /ADESSO/IF_MDC_DTX_NBSERVICE
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA_NBSERVICE
    importing
      !IS_ESERVICE_OLD type ESERVICE
      !IS_ESERVICE_NEW type ESERVICE
      !IV_UPD_MODE type DAMODUS
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IS_ESERVICE_OLD type ESERVICE
      !IS_ESERVICE_NEW type ESERVICE
      !IV_UPD_MODE type DAMODUS
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      value(CV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
