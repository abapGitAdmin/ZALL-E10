class ZCL_COD_IM_UTILITIES_REPL_CONF definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_COD_UTILITIES_REPL_CONF .
protected section.
private section.
ENDCLASS.



CLASS ZCL_COD_IM_UTILITIES_REPL_CONF IMPLEMENTATION.


  METHOD if_cod_utilities_repl_conf~get_logical_port.
    cv_logical_port = 'XXXXXXXXXX'.
  ENDMETHOD.


  METHOD if_cod_utilities_repl_conf~get_receiver_system.
    APPEND 'XXXXXXXXXX' TO ct_receiver_system.
  ENDMETHOD.
ENDCLASS.
