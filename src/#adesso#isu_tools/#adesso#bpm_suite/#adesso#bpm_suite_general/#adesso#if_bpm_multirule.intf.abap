interface /ADESSO/IF_BPM_MULTIRULE
  public .


  interfaces IF_BADI_INTERFACE .

  methods SOLVE_RULE
    importing
      !IT_CONTAINER_MULTIRULE type SWCONTTAB
    returning
      value(RT_ACTORS) type TSWHACTOR .
endinterface.
