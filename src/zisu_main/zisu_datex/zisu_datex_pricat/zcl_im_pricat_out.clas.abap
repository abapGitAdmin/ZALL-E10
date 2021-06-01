class ZCL_IM_PRICAT_OUT definition
  public
  final
  create public .

public section.

  interfaces /IDEXGE/IF_EX_PRICAT_OUT .
  interfaces IF_BADI_INTERFACE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_PRICAT_OUT IMPLEMENTATION.


  METHOD /idexge/if_ex_pricat_out~overwrite_idoc_data.
    zcl_datex_utility=>modify_externalid_outbound( CHANGING cs_idoc_data = cs_idoc_data ).
  ENDMETHOD.
ENDCLASS.
