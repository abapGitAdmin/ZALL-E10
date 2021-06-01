interface /ADESSO/IF_MDC_DTX_COADDR
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA
    importing
      !IV_ADDR_REF type ISU02_ADDRESS-ADDR_REF
      !IS_ADDR1_VAL_NEW type ADDR1_VAL
      !IS_ADDR1_VAL_OLD type ADDR1_VAL
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IV_ADDR_REF type ISU02_ADDRESS-ADDR_REF
      !IS_ADDR1_VAL_NEW type ADDR1_VAL
      !IS_ADDR1_VAL_OLD type ADDR1_VAL
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      value(CV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
