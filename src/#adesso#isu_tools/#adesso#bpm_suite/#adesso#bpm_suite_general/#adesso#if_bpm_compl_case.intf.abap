interface /ADESSO/IF_BPM_COMPL_CASE
  public .


  interfaces IF_BADI_INTERFACE .

  methods COMPLETE_CASE
    importing
      !IV_CCAT type EMMA_CCAT
      !IS_CASE type EMMA_CASE
      !IT_OBJECTS type EMMA_COBJ_T
    exporting
      !EV_CUSTFIELDS type EMMA_CCI
      !ET_OBJECTS type EMMA_COBJ_T
    raising
      /ADESSO/CX_BPM_GENERAL .
endinterface.
