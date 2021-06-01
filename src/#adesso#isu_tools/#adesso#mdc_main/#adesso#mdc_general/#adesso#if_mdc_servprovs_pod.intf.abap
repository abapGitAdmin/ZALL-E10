interface /ADESSO/IF_MDC_SERVPROVS_POD
  public .


  interfaces IF_BADI_INTERFACE .

  methods GET_SERVPROVS_FOR_POD
    importing
      !IV_INT_UI type INT_UI
      !IV_KEYDATE type /IDXGC/DE_KEYDATE
    changing
      !CT_SERVPROV_DETAILS type /IDXGC/T_SERVPROV_DETAILS
    raising
      /IDXGC/CX_GENERAL .
endinterface.
