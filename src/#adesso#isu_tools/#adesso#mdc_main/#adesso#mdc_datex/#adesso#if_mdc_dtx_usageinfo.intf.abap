interface /ADESSO/IF_MDC_DTX_USAGEINFO
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA_USAGEINFO
    importing
      !IS_BILL_DOC type ISU2A_BILL_DOC
      !IS_DATA_COLLECTOR type ISU2A_DATA_COLLECTOR
      !IS_BILLING_DATA type ISU2A_BILLING_DATA
      !IT_USAGE type ISU2A_IUSAGE
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IS_BILL_DOC type ISU2A_BILL_DOC
      !IS_DATA_COLLECTOR type ISU2A_DATA_COLLECTOR
      !IS_BILLING_DATA type ISU2A_BILLING_DATA
      !IT_USAGE type ISU2A_IUSAGE
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      value(CV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
