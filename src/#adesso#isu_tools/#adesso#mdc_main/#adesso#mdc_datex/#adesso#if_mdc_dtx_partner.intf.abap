interface /ADESSO/IF_MDC_DTX_PARTNER
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA
    importing
      !IS_OLD_DATA type ISU01_PARTNER_DATA
      !IS_NEW_DATA type ISU01_PARTNER_DATA
      !IS_BP_CRM_DATA type BUS_EI_COM_EXTERN optional
      !IV_BP_ID type BU_PARTNER optional
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IS_OLD_DATA type ISU01_PARTNER_DATA
      !IS_NEW_DATA type ISU01_PARTNER_DATA
      !IS_BP_CRM_DATA type BUS_EI_COM_EXTERN optional
      !IV_BP_ID type BU_PARTNER optional
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      !CV_FLAG_SEND type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
