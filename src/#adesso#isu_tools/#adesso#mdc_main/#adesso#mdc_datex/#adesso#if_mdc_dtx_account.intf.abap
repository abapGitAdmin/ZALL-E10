interface /ADESSO/IF_MDC_DTX_ACCOUNT
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA_ACCOUNT
    importing
      !IT_FKKVKP_NEW type ISU_FKKVKP_TAB
      !IT_FKKVKP_OLD type ISU_FKKVKP_TAB
      value(IV_ACCOUNT_HOLDER) type FKKVKP-GPART
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IT_FKKVKP_NEW type ISU_FKKVKP_TAB
      !IT_FKKVKP_OLD type ISU_FKKVKP_TAB
      !IV_ACCOUNT_HOLDER type FKKVKP-GPART
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      value(CV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
