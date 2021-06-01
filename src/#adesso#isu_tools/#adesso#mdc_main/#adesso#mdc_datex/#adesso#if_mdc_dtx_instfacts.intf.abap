interface /ADESSO/IF_MDC_DTX_INSTFACTS
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHANGE_PROC_DATA
    importing
      !IT_NEW_FACTS type ISU_IETTIF
      !IT_OLD_FACTS type ISU_IETTIF
    changing
      !CT_PROC_DATA type /IDXGC/T_PROC_DATA
    raising
      /IDXGC/CX_GENERAL .
  methods CHANGE_PROC_DATA_AND_SEND_FLAG
    importing
      !IT_NEW_FACTS type ISU_IETTIF
      !IT_OLD_FACTS type ISU_IETTIF
    changing
      !CS_PROC_DATA type /IDXGC/S_PROC_DATA
      value(CV_FLAG_SEND) type /ADESSO/MDC_FLAG_SEND
    raising
      /IDXGC/CX_GENERAL .
endinterface.
