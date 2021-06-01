interface /ADZ/INF_REMADV_CHECK_4_COMDIS
  public .


  interfaces IF_BADI_INTERFACE .

  methods CHECK_4_COMDIS
    importing
      !IS_OUT type /ADZ/INV_S_OUT_REKLAMON
    changing
      !CV_NO_COMDIS type FLAG .
endinterface.
