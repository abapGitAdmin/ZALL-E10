interface /ADESSO/IF_BPM_TRANS_START
  public .


  interfaces IF_BADI_INTERFACE .

  methods TRANSACTION_START
    importing
      !IV_CASENR type EMMA_CNR
      !IV_CCAT type EMMA_CCAT
      !IV_TEMPLATE_CASE type EMMA_CNR
      !IV_WMODE type EMMA_CTXN_WMODE
      !IV_ALLOW_TOGGLE_DISPCHAN type FLAG
      !IV_NEXT_PREV_CASE type NUM1
    exporting
      !EV_CASENR type EMMA_CNR
      !EV_OKCODE type SYUCOMM
    raising
      /ADESSO/CX_BPM_GENERAL .
endinterface.
