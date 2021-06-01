interface /ADESSO/IF_MDC_INTCODE
  public .


  interfaces IF_BADI_INTERFACE .

  methods GET_INTCODE_SERVPROV
    importing
      !IV_SERVICE type SERCODE
      !IV_SERVICEID type SERVICEID
    changing
      !CV_INTCODE type /ADESSO/MDC_INTCODE
    raising
      /IDXGC/CX_GENERAL .
endinterface.
