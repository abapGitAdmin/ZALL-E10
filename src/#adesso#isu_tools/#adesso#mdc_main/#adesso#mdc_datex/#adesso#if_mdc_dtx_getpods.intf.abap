interface /ADESSO/IF_MDC_DTX_GETPODS
  public .


  interfaces IF_BADI_INTERFACE .

  methods GET_PODS
    importing
      !IV_VERTRAG type VERTRAG optional
      !IV_ANLAGE type ANLAGE optional
      !IV_VKONT type VKONT_KK optional
      !IV_VSTELLE type VSTELLE optional
      !IV_BU_PARTNER type BU_PARTNER optional
      !IV_HAUS type HAUS optional
      !IV_KEYDATE type SY-DATUM default SY-DATUM
      !IV_ONLY_DEREG type KENNZX default 'X'
    changing
      !CT_EVER type IEEVER optional
      !CT_INT_UI type INT_UI_TABLE
    exceptions
      /ADESSO/CX_MDC_DATEX .
endinterface.
